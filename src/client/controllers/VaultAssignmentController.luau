--!strict

local VaultAssignmentController = {}
function VaultAssignmentController.new(options: {
	gateway: any,
	routes: any,
	projection: any,
	sessionReady: () -> boolean,
	clock: () -> number,
	onChanged: ((any) -> ())?,
})
	local snapshot: any = nil
	local selected: any = nil
	local pending: any = nil
	local pageRequest: any = nil
	local afterId: any = nil
	local nextRefresh = 0
	local message = "Loading Vault assignments..."
	local function view(): any
		return {
			snapshot = snapshot,
			selected = selected,
			pending = pending ~= nil,
			canAssign = snapshot ~= nil
				and selected ~= nil
				and pending == nil
				and options.sessionReady(),
			canClaim = snapshot ~= nil and pending == nil and options.sessionReady(),
			message = if options.sessionReady() then message else "Checking saved Vault...",
		}
	end
	local function changed()
		if options.onChanged then
			options.onChanged(view())
		end
	end
	local function refresh(cursor: string?)
		afterId = cursor
		pageRequest = options.gateway.send(
			options.routes.commands.sessionRequestResync,
			{ domain = "vaultAssignments", afterCreatureInstanceId = cursor }
		)
		nextRefresh = options.clock() + 5
	end
	local function rowFor(id: string?): any
		if snapshot then
			for _, row in snapshot.state.creatures do
				if row.creatureInstanceId == id then
					return row
				end
			end
		end
		return nil
	end
	local function selectCreature(id: string)
		local row = rowFor(id)
		if pending ~= nil or row == nil or row.overflowHeld or not options.sessionReady() then
			return
		end
		selected, message = id, "Choose a slot. Selecting the same assignment removes it."
		changed()
	end
	local function assign(kind: string, slot: string): string?
		if not view().canAssign or (kind ~= "production" and kind ~= "display") then
			return nil
		end
		local row = rowFor(selected)
		if row == nil or row.overflowHeld then
			return nil
		end
		local desired = if row[kind .. "SlotId"] == slot then nil else selected
		pageRequest = nil
		local request = options.gateway.send(
			if kind == "production"
				then options.routes.commands.vaultSetProductionAssignment
				else options.routes.commands.vaultSetDisplayAssignment,
			{ slotId = slot, creatureInstanceId = desired },
			snapshot.revision
		)
		pending = {
			requestId = request,
			creatureInstanceId = selected,
			kind = kind,
			slotId = slot,
			desired = desired,
		}
		message, nextRefresh = "Waiting for saved assignment...", options.clock() + 5
		changed()
		return request
	end
	local function handleSnapshot(envelope: any): string
		if
			not options.projection.validSnapshot(envelope.payload)
			or envelope.revision ~= envelope.payload.revision
			or not options.sessionReady()
		then
			return "Invalid"
		end
		if snapshot ~= nil and envelope.revision < snapshot.revision then
			return "Stale"
		end
		if
			envelope.correlationId ~= pageRequest
			and (pending == nil or envelope.correlationId ~= pending.requestId)
		then
			return "Stale"
		end
		if pending ~= nil then
			if pending.kind == "claim" then
				if envelope.payload.state.claimExpectedRevision ~= pending.expectedRevision then
					if
						envelope.correlationId ~= pageRequest
						or options.gateway.resultFor(pending.requestId) ~= "PENDING_VAULT_CLAIM"
					then
						return "Unconfirmed"
					end
					-- Busy proves this intent was not admitted. Readback refreshes its
					-- saved state; a read while another write yields cannot disprove
					-- an accepted/unknown claim just because its receipt is absent.
					message = "Claim not applied. Saved Energy refreshed."
				else
					message =
						string.format("Claim saved: +%d Energy.", envelope.payload.state.claimUnits)
				end
			else
				local present = false
				for _, row in envelope.payload.state.creatures do
					if row.creatureInstanceId == pending.creatureInstanceId then
						present = true
					end
				end
				if not present then
					return "MissingRow"
				end -- Absence from a page never proves an assignment.
				message = "Saved Vault refreshed."
			end
			pending = nil
		end
		snapshot = envelope.payload
		if pending == nil and message == "Loading Vault assignments..." then
			message = "Select a Stored or Active creature to manage its slots."
		end
		if rowFor(selected) == nil then
			selected = nil
		end
		changed()
		return "Applied"
	end
	local function tick()
		if pending ~= nil then
			local code = options.gateway.resultFor(pending.requestId)
			if code ~= nil and string.sub(code, 1, 7) == "REJECT_" then
				local wasClaim = pending.kind == "claim"
				pending, selected, message =
					nil,
					nil,
					if wasClaim
						then "Claim rejected. Refresh and try again."
						else "Assignment rejected. Refresh and select again."
				refresh(afterId)
			end
		end
		if options.clock() >= nextRefresh then
			refresh(afterId)
		end
		changed()
	end
	return {
		claim = function(): string?
			if not view().canClaim then
				return nil
			end
			pageRequest = nil
			local revision = snapshot.revision
			local request = options.gateway.send(
				options.routes.commands.vaultClaimProduction,
				{ claimScope = "All" },
				revision
			)
			pending = { requestId = request, kind = "claim", expectedRevision = revision }
			message, nextRefresh = "Waiting for saved Energy claim...", options.clock() + 5
			changed()
			return request
		end,
		view = view,
		selectCreature = selectCreature,
		assign = assign,
		handleSnapshot = handleSnapshot,
		tick = tick,
		firstPage = function()
			if pending == nil then
				selected = nil
				refresh(nil)
			end
		end,
		nextPage = function()
			if pending == nil and snapshot ~= nil and snapshot.state.hasMore then
				selected = nil
				refresh(snapshot.state.creatures[#snapshot.state.creatures].creatureInstanceId)
			end
		end,
	}
end
return VaultAssignmentController
