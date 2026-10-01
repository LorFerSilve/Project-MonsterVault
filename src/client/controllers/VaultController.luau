--!strict

-- Intent/UI state only. Only a fresh server projection describes stored ownership.
local VaultController = {}
function VaultController.new(options: {
	gateway: any,
	routes: any,
	projection: any,
	sessionReady: () -> boolean,
	clock: () -> number,
	onChanged: ((any) -> ())?,
})
	local snapshot: any = nil
	local selected: string? = nil
	local pending: any = nil
	local pageRequest: string? = nil
	local afterId: string? = nil
	local nextRefresh = 0
	local message = "Loading collection..."
	local function view(): any
		local ready = options.sessionReady()
		return {
			snapshot = snapshot,
			selected = selected,
			pending = pending ~= nil,
			message = if not ready then "Checking saved collection..." else message,
			canResolve = ready
				and snapshot ~= nil
				and selected ~= nil
				and pending == nil
				and snapshot.state.ordinaryUsed < snapshot.state.capacity,
		}
	end
	local function changed()
		if options.onChanged ~= nil then
			options.onChanged(view())
		end
	end
	local function refresh(cursor: string?)
		afterId = cursor
		pageRequest = options.gateway.send(
			options.routes.commands.sessionRequestResync,
			{ domain = "vault", afterCreatureInstanceId = cursor }
		)
		nextRefresh = options.clock() + 5
	end
	local function selectCreature(id: string)
		if snapshot == nil or pending ~= nil or not options.sessionReady() then
			return
		end
		if table.find(snapshot.state.overflowCreatureInstanceIds, id) == nil then
			return
		end
		selected = id
		message = "Move this creature into the collection when space is available."
		changed()
	end
	local function resolve(): string?
		if not view().canResolve then
			return nil
		end
		local id = selected
		pageRequest = nil -- Responses requested before this intent cannot settle it.
		local requestId = options.gateway.send(
			options.routes.commands.vaultResolveOverflow,
			{ creatureInstanceId = id },
			snapshot.revision
		)
		pending = { requestId = requestId, creatureInstanceId = id }
		message = "Waiting for saved confirmation..."
		nextRefresh = options.clock() + 5
		changed()
		return requestId
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
		snapshot = envelope.payload
		if pending ~= nil then
			-- A server readback is conclusive after reconciliation; a missing page row alone
			-- never means ownership changed. The authoritative counts/rows simply refresh.
			pending = nil
			afterId = nil
			message = "Saved collection refreshed."
		else
			message = if snapshot.state.overflowHeldCount == 0
				then "No creatures held in overflow."
				elseif
					snapshot.state.ordinaryUsed >= snapshot.state.capacity
				then "Free collection space before resolving overflow."
				else "Select one held creature to move into the collection."
		end
		if
			selected ~= nil
			and table.find(snapshot.state.overflowCreatureInstanceIds, selected) == nil
		then
			selected = nil
		end
		changed()
		return "Applied"
	end
	local function tick()
		if pending ~= nil then
			local code = options.gateway.resultFor(pending.requestId)
			if code ~= nil and string.sub(code, 1, 7) == "REJECT_" then
				pending = nil
				selected = nil
				message = "Collection changed. Refresh and select again."
				refresh(nil)
			end
		end
		if options.clock() >= nextRefresh then
			refresh(afterId)
		end
		changed()
	end
	return {
		view = view,
		selectCreature = selectCreature,
		resolve = resolve,
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
				refresh(
					snapshot.state.overflowCreatureInstanceIds[#snapshot.state.overflowCreatureInstanceIds]
				)
			end
		end,
	}
end
return VaultController
