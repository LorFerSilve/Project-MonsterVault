--!strict

-- All value changes remain single-profile P2 checkpoints. Pending candidates
-- keep their server operation identity until durable reconciliation succeeds.
local VaultCapacityUseCase = {}

function VaultCapacityUseCase.new(options: {
	vault: any,
	newOperationId: () -> string,
	settleProduction: ((any) -> (boolean, boolean))?,
})
	local pending: { [any]: any } = setmetatable({}, { __mode = "k" }) :: any

	local function commit(session: any, mutate: (any) -> (), creatureId: string?): any
		local operationId = options.newOperationId()
		local result = session.checkpoint(operationId, mutate)
		if result.status == "OutcomeUnknown" then
			pending[session] = { operationId = operationId, creatureInstanceId = creatureId }
		end
		return result
	end

	local function reconcile(session: any): any
		if session == nil then
			return { status = "Unavailable" }
		end
		local unresolved = pending[session]
		if unresolved ~= nil then
			local result = session.reconcileCheckpoint(unresolved.operationId)
			if result.status ~= "Committed" and result.status ~= "AlreadyCommitted" then
				return result
			end
			pending[session] = nil
		end
		if session.state() ~= "Ready" then
			return { status = session.state() }
		end
		local snapshot = session.snapshot()
		local prepared = options.vault.prepare(snapshot, options.settleProduction)
		if prepared.status ~= "Prepared" then
			return prepared
		end
		if not prepared.changed then
			return { status = "Unchanged", profileRevision = snapshot.profileRevision }
		end
		return commit(session, function(profile: any)
			assert(profile.profileRevision == snapshot.profileRevision, "capacity revision changed")
			assert(
				options.vault.prepare(profile, options.settleProduction).status == "Prepared",
				"capacity reconciliation failed"
			)
		end, nil)
	end

	local function resolve(session: any, creatureId: string, expectedRevision: number): any
		local reconciled = reconcile(session)
		if
			reconciled.status ~= "Committed"
			and reconciled.status ~= "AlreadyCommitted"
			and reconciled.status ~= "Unchanged"
		then
			return reconciled
		end
		local snapshot = session.snapshot()
		local record = (snapshot.collection.creaturesById or {})[creatureId]
		if record == nil then
			return { status = "Rejected", reason = "OWNERSHIP" }
		end
		if not record.overflowHeld then
			return { status = "AlreadyStored", profileRevision = snapshot.profileRevision }
		end
		if snapshot.profileRevision ~= expectedRevision then
			return { status = "Rejected", reason = "STALE_REVISION" }
		end
		local result = options.vault.resolveOverflow(snapshot, creatureId, options.settleProduction)
		if result.status ~= "Resolved" then
			return result
		end
		return commit(session, function(profile: any)
			assert(profile.profileRevision == expectedRevision, "resolution revision changed")
			assert(
				options.vault.resolveOverflow(profile, creatureId, options.settleProduction).status
					== "Resolved",
				"resolution invalidated"
			)
		end, creatureId)
	end

	return { reconcile = reconcile, resolve = resolve }
end

return VaultCapacityUseCase
