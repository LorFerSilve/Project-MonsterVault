--!strict

local ProductionClaimUseCase = {}
function ProductionClaimUseCase.new(options: {
	energy: any,
	production: any,
	vault: any,
	assignments: any,
	newOperationId: () -> string,
})
	local pending: { [any]: string } = setmetatable({}, { __mode = "k" }) :: any
	local function reconcile(session: any): any
		if session == nil then
			return { status = "Unavailable" }
		end
		local operation = pending[session]
		if operation ~= nil then
			-- Release can have already reconciled the exact checkpoint.
			if
				session.state() == "Ready"
				and session.snapshot().recentOperations[operation] ~= nil
			then
				pending[session] = nil
			else
				local result = session.reconcileCheckpoint(operation)
				if result.status ~= "Committed" and result.status ~= "AlreadyCommitted" then
					return result
				end
				pending[session] = nil
			end
		end
		return if session.state() == "Ready"
			then { status = "Unchanged" }
			else { status = session.state() }
	end
	local function claim(session: any, expectedRevision: number): any
		local reconciled = reconcile(session)
		if reconciled.status ~= "Unchanged" then
			return reconciled
		end
		local snapshot = session.snapshot()
		local invalid = options.energy.validate(snapshot)
		if invalid ~= nil then
			return { status = "Protected", reason = invalid }
		end
		local receipt = options.energy.claimReceipt(snapshot, expectedRevision)
		if receipt ~= nil then
			return {
				status = "AlreadyCommitted",
				operationId = receipt.operationId,
				units = receipt.deltaUnits,
			}
		end
		if snapshot.profileRevision ~= expectedRevision then
			return { status = "Rejected", reason = "STALE_REVISION" }
		end
		local at = options.assignments.boundary(nil)
		local operation = options.newOperationId()
		local function mutate(profile: any): any
			local prepared = options.vault.prepare(profile, function(p: any)
				local result = options.production.settle(p, at, "Online")
				return result.status == "Prepared", result.changed == true
			end)
			if prepared.status ~= "Prepared" then
				return prepared
			end
			local settled = options.production.settle(profile, at, "Online")
			if settled.status ~= "Prepared" then
				return settled
			end
			local units = math.min(
				math.floor(profile.vault.productionBufferMilli / 1000),
				options.energy.maxUnits - profile.economy.energyUnits
			)
			local applied = options.energy.apply(profile, {
				operationId = operation,
				reasonCode = "production-claim",
				sourceOrSinkId = "vault/production",
				deltaUnits = units,
				timestamp = at,
				expectedRevision = expectedRevision,
				configSnapshotId = options.production.capabilities(profile).contentSnapshotId,
			})
			if applied.status ~= "Applied" then
				return applied
			end
			profile.vault.productionBufferMilli -= units * 1000
			return applied
		end
		local preview = mutate(snapshot)
		if preview.status ~= "Applied" then
			return preview
		end
		local result = session.checkpoint(operation, function(profile: any)
			assert(profile.profileRevision == expectedRevision, "claim revision changed")
			assert(mutate(profile).status == "Applied", "claim invalidated")
		end)
		if result.status == "OutcomeUnknown" then
			pending[session] = operation
		end
		result.operationId, result.units = operation, preview.units
		return result
	end
	return { claim = claim, reconcile = reconcile }
end
return ProductionClaimUseCase
