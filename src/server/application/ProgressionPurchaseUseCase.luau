--!strict

local ProgressionPurchaseUseCase = {}
function ProgressionPurchaseUseCase.new(options: {
	progression: any,
	energy: any,
	vault: any,
	assignments: any,
	production: any?,
	newOperationId: () -> string,
	monotonicSeconds: () -> number,
})
	-- One live quote and one admitted P2 operation per owned session.
	local quotes: { [any]: any } = setmetatable({}, { __mode = "k" }) :: any
	local pending: { [any]: string } = setmetatable({}, { __mode = "k" }) :: any
	local function reconcile(session: any): any
		if session == nil then
			return { status = "Unavailable" }
		end
		local operation = pending[session]
		if operation ~= nil then
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
	local function quote(session: any, unlockId: string?): any
		local reconciled = reconcile(session)
		if reconciled.status ~= "Unchanged" then
			return reconciled
		end
		local profile, d = session.snapshot(), options.progression.definition(unlockId)
		if d == nil then
			return { status = "Rejected", reason = "INVALID_UNLOCK" }
		end
		local invalid = options.energy.validate(profile) or options.progression.validate(profile)
		if invalid then
			return { status = "Protected", reason = invalid }
		end
		local reason = options.progression.eligible(profile, d.unlockId)
		if reason then
			return { status = "Rejected", reason = reason }
		end
		local current, now = quotes[session], options.monotonicSeconds()
		if
			current == nil
			or current.unlockId ~= d.unlockId
			or current.deadline <= now
			or current.expectedRevision ~= profile.profileRevision
			or current.configSnapshotId ~= d.configSnapshotId
			or current.quoteRevision ~= d.quoteRevision
			or current.priceUnits ~= d.priceUnits
		then
			current = {
				quoteId = options.newOperationId(),
				unlockId = d.unlockId,
				quoteRevision = d.quoteRevision,
				expectedRevision = profile.profileRevision,
				priceUnits = d.priceUnits,
				configSnapshotId = d.configSnapshotId,
				expectedLevel = d.expectedLevel,
				requiredMilestoneId = d.requiredMilestoneId,
				requiredMilestoneIds = table.clone(d.requiredMilestoneIds),
				requiredUnlockIds = table.clone(d.requiredUnlockIds),
				expiresUnixSeconds = options.assignments.boundary(nil) + d.quoteLifetimeSeconds,
				deadline = now + d.quoteLifetimeSeconds,
			}
			quotes[session] = current
		end
		local visible = table.clone(current)
		visible.deadline = nil
		-- The target + immutable config snapshot reference all prerequisite IDs.
		-- Keep private proof lists out of the conservative reliable wire budget.
		visible.requiredMilestoneId, visible.requiredMilestoneIds, visible.requiredUnlockIds =
			nil, nil, nil
		visible.prerequisiteDefinitionId = d.unlockId
		return { status = "Quoted", quote = visible }
	end
	local function purchase(session: any, payload: any, expectedRevision: number): any
		if
			type(payload) ~= "table"
			or type(payload.unlockId) ~= "string"
			or type(payload.quoteId) ~= "string"
			or type(payload.quoteRevision) ~= "number"
			or type(expectedRevision) ~= "number"
		then
			return { status = "Rejected", reason = "INVALID_PURCHASE" }
		end
		for key in payload do
			if key ~= "unlockId" and key ~= "quoteId" and key ~= "quoteRevision" then
				return { status = "Rejected", reason = "INVALID_PURCHASE" }
			end
		end
		local reconciled = reconcile(session)
		if reconciled.status ~= "Unchanged" then
			return reconciled
		end
		local profile, d = session.snapshot(), options.progression.definition(payload.unlockId)
		local invalid = options.energy.validate(profile) or options.progression.validate(profile)
		if invalid then
			return { status = "Protected", reason = invalid }
		end
		if d == nil then
			return { status = "Rejected", reason = "INVALID_UNLOCK" }
		end
		local receipt = profile.progression.purchasesByUnlockId[payload.unlockId]
		if
			receipt ~= nil
			and receipt.quoteId == payload.quoteId
			and receipt.quoteRevision == payload.quoteRevision
			and receipt.expectedRevision == expectedRevision
		then
			return {
				status = "AlreadyCommitted",
				operationId = receipt.operationId,
				units = receipt.priceUnits,
			}
		end
		local reason = options.progression.eligible(profile, d.unlockId)
		if reason then
			return { status = "Rejected", reason = reason }
		end
		local q = quotes[session]
		if
			q == nil
			or q.quoteId ~= payload.quoteId
			or q.quoteRevision ~= payload.quoteRevision
			or q.unlockId ~= payload.unlockId
			or q.expectedRevision ~= expectedRevision
			or expectedRevision ~= profile.profileRevision
			or options.monotonicSeconds() >= q.deadline
			or q.configSnapshotId ~= d.configSnapshotId
			or q.quoteRevision ~= d.quoteRevision
			or q.priceUnits ~= d.priceUnits
			or q.expectedLevel ~= d.expectedLevel
			or q.requiredMilestoneId ~= d.requiredMilestoneId
		then
			return { status = "Rejected", reason = "STALE_QUOTE" }
		end
		if profile.economy.energyUnits < q.priceUnits then
			return { status = "Rejected", reason = "INSUFFICIENT_ENERGY" }
		end
		local operation, at = options.newOperationId(), options.assignments.boundary(nil)
		local function mutate(candidate: any): any
			if candidate.profileRevision ~= expectedRevision then
				return { status = "Rejected", reason = "STALE_QUOTE" }
			end
			local gate = options.progression.eligible(candidate, d.unlockId)
			if gate then
				return { status = "Rejected", reason = gate }
			end
			if d.kind == "Vault" and d.effectField ~= "collectionCapacity" then
				if options.production == nil then
					return { status = "Protected", reason = "PRODUCTION_AUTHORITY_UNBOUND" }
				end
				local settled = options.production.settle(candidate, at, "Online")
				if settled.status ~= "Prepared" then
					return settled
				end
				-- Never retroactively apply an upgraded cap to an unsettled interval.
				if settled.clockRegressed then
					return { status = "Rejected", reason = "PRODUCTION_CLOCK_REGRESSION" }
				end
			end
			local applied = options.energy.apply(candidate, {
				operationId = operation,
				reasonCode = d.reasonCode,
				sourceOrSinkId = q.unlockId,
				deltaUnits = -q.priceUnits,
				timestamp = at,
				configSnapshotId = q.configSnapshotId,
				expectedRevision = expectedRevision,
			})
			if applied.status ~= "Applied" then
				return applied
			end
			options.progression.apply(candidate, {
				quoteId = q.quoteId,
				quoteRevision = q.quoteRevision,
				operationId = operation,
				expectedRevision = expectedRevision,
				priceUnits = q.priceUnits,
				timestamp = at,
				configSnapshotId = q.configSnapshotId,
			}, d.unlockId)
			-- An upgrade never auto-resolves Held creatures or changes their identity.
			local status, capacityReason = options.vault.collectionStatus(candidate)
			if status == nil then
				return { status = "Protected", reason = capacityReason }
			end
			if options.production ~= nil then
				local invalidProduction = options.production.validate(candidate)
				if invalidProduction then
					return { status = "Protected", reason = invalidProduction }
				end
			end
			return applied
		end
		local preview = mutate(profile)
		if preview.status ~= "Applied" then
			return preview
		end
		local result = session.checkpoint(operation, function(candidate: any)
			assert(mutate(candidate).status == "Applied", "purchase invalidated")
		end)
		if result.status == "OutcomeUnknown" then
			pending[session] = operation
		end
		result.operationId, result.units = operation, q.priceUnits
		return result
	end
	return { quote = quote, purchase = purchase, reconcile = reconcile }
end
return ProgressionPurchaseUseCase
