--!strict

local VaultProductionUseCase = {}
function VaultProductionUseCase.new(options: {
	production: any,
	vault: any,
	unixSeconds: () -> number,
	monotonicSeconds: () -> number,
	newOperationId: () -> string,
})
	local anchorUnix, anchorMono = options.unixSeconds(), options.monotonicSeconds()
	local pending: { [any]: string } = setmetatable({}, { __mode = "k" }) :: any
	local function boundary(atMono: number?): number
		return anchorUnix
			+ math.floor(math.max(0, (atMono or options.monotonicSeconds()) - anchorMono))
	end
	local function prepareProfile(profile: any, now: number): any
		local status, reason = options.vault.collectionStatus(profile)
		if status == nil then
			return { status = "Protected", reason = reason }
		end
		local settled = options.production.prepareLoad(profile, now)
		if settled.status ~= "Prepared" then
			return settled
		end
		local prepared = options.vault.prepare(profile, function()
			return true, false
		end)
		if prepared.status ~= "Prepared" then
			return prepared
		end
		prepared.changed = prepared.changed or settled.changed
		return prepared
	end
	local function settleProfile(profile: any, atMono: number?): (boolean, boolean)
		local settled = options.production.settle(profile, boundary(atMono), "Online")
		return settled.status == "Prepared", settled.changed == true
	end
	local function prepareSave(profile: any, release: boolean, atMono: number): any
		local settled, changed = settleProfile(profile, atMono)
		if not settled then
			return { status = "Protected", reason = "PRODUCTION_SETTLEMENT_REQUIRED" }
		end
		local prepared = options.vault.prepare(profile, function()
			return true, false
		end)
		if prepared.status ~= "Prepared" then
			return prepared
		end
		local presence = if release then "CleanOffline" else "Active"
		prepared.changed = prepared.changed
			or changed
			or profile.vault.lastPresenceBoundary ~= presence
		profile.vault.lastPresenceBoundary = presence
		return prepared
	end
	local function reconcile(session: any): any
		if session == nil then
			return { status = "Unavailable" }
		end
		local operation = pending[session]
		if operation ~= nil then
			local result = session.reconcileCheckpoint(operation)
			if result.status ~= "Committed" and result.status ~= "AlreadyCommitted" then
				return result
			end
			pending[session] = nil
		end
		return if session.state() == "Ready"
			then { status = "Unchanged" }
			else { status = session.state() }
	end
	local function assign(
		session: any,
		kind: string,
		slot: string,
		creatureId: string?,
		expectedRevision: number
	): any
		local reconciled = reconcile(session)
		if reconciled.status ~= "Unchanged" then
			return reconciled
		end
		local snapshot = session.snapshot()
		if snapshot.profileRevision ~= expectedRevision then
			return { status = "Rejected", reason = "STALE_REVISION" }
		end
		local at = boundary(nil)
		local function mutate(profile: any): any
			local prepared = options.vault.prepare(profile, function(p)
				local result = options.production.settle(p, at, "Online")
				return result.status == "Prepared", result.changed == true
			end)
			if prepared.status ~= "Prepared" then
				return prepared
			end
			return options.production.assign(profile, kind, slot, creatureId, at)
		end
		local preview = mutate(snapshot)
		if preview.status ~= "Assigned" then
			return preview
		end
		local operation = options.newOperationId()
		local result = session.checkpoint(operation, function(profile: any)
			assert(profile.profileRevision == expectedRevision, "assignment revision changed")
			assert(mutate(profile).status == "Assigned", "assignment invalidated")
		end)
		if result.status == "OutcomeUnknown" then
			pending[session] = operation
		end
		return result
	end
	return {
		assign = assign,
		reconcile = reconcile,
		prepareProfile = prepareProfile,
		prepareSave = prepareSave,
		settleProfile = settleProfile,
		boundary = boundary,
	}
end
return VaultProductionUseCase
