--!strict

local WorldActionUseCase = {}
function WorldActionUseCase.new(options: {
	world: any,
	progression: any,
	energy: any?,
	unixSeconds: (() -> number)?,
	newOperationId: () -> string,
}): any
	local pending: { [any]: string } = setmetatable({}, { __mode = "k" }) :: any
	local function timestamp(): number
		return if options.unixSeconds then options.unixSeconds() else os.time()
	end
	local function reconcile(session: any): any
		if session == nil then
			return { status = "Unavailable" }
		end
		local op = pending[session]
		if op ~= nil then
			if session.state() ~= "Ready" or session.snapshot().recentOperations[op] == nil then
				local result = session.reconcileCheckpoint(op)
				if result.status ~= "Committed" and result.status ~= "AlreadyCommitted" then
					return result
				end
			end
			pending[session] = nil
		end
		if session.state() ~= "Ready" then
			return { status = session.state() }
		end
		-- One bound deferred grant; reconciliation never creates a new reward.
		local snapshot = session.snapshot()
		if options.energy then
			local invalid = options.energy.validate(snapshot)
			if invalid then
				return { status = "Protected", reason = invalid }
			end
		end
		local receipt = snapshot.economy.worldRewardReceipt
		if
			options.energy
			and receipt
			and receipt.remainingUnits > 0
			and snapshot.economy.energyUnits < options.energy.maxUnits
		then
			local operation, at = options.newOperationId(), timestamp()
			local units = math.min(
				receipt.remainingUnits,
				options.energy.maxUnits - snapshot.economy.energyUnits
			)
			local function mutate(candidate: any): any
				return options.energy.apply(candidate, {
					operationId = operation,
					reasonCode = "world-objective-transfer",
					sourceOrSinkId = receipt.sourceReference,
					grantOperationId = receipt.operationId,
					deltaUnits = units,
					timestamp = at,
					expectedRevision = snapshot.profileRevision,
					configSnapshotId = receipt.configSnapshotId,
				})
			end
			local preview = mutate(snapshot)
			if preview.status ~= "Applied" then
				return preview
			end
			local result = session.checkpoint(operation, function(candidate: any)
				assert(
					candidate.profileRevision == snapshot.profileRevision,
					"reward transfer revision changed"
				)
				assert(mutate(candidate).status == "Applied", "reward transfer invalidated")
			end)
			if result.status == "OutcomeUnknown" then
				pending[session] = operation
			end
			if result.status ~= "Committed" and result.status ~= "AlreadyCommitted" then
				return result
			end
		end
		return { status = "Unchanged" }
	end
	-- Spatial authority is injected from the validated, immutable authored index.
	local function visit(session: any, landmarkId: string, inside: () -> boolean): any
		local result = reconcile(session)
		if result.status ~= "Unchanged" then
			return result
		end
		local l = options.world.registry.landmarks[landmarkId]
		local snapshot = session.snapshot()
		if
			l == nil
			or not options.world.canAccess(snapshot, l.regionId, options.progression.hasAccess)
		then
			return { status = "Rejected", reason = "ACCESS_BLOCKED" }
		end
		local ok, present = pcall(inside)
		if not ok or present ~= true then
			return { status = "Rejected", reason = "OUT_OF_RANGE" }
		end
		local op = options.newOperationId()
		local reward, expected = options.world.registry.worldReward, snapshot.profileRevision
		local at = timestamp()
		local function mutate(profile: any): any
			local progress = profile.world.objectives[reward.objectiveId] or 0
			if not options.world.visit(profile, landmarkId, op) then
				return { status = "AlreadyCommitted" }
			end
			if
				progress < reward.completionProgress
				and profile.world.objectives[reward.objectiveId] == reward.completionProgress
			then
				if options.energy == nil then
					return { status = "Protected", reason = "ENERGY_AUTHORITY_UNBOUND" }
				end
				return options.energy.apply(profile, {
					operationId = op,
					reasonCode = "world-objective-reward",
					sourceOrSinkId = reward.id,
					deltaUnits = math.min(
						reward.energyUnits,
						options.energy.maxUnits - profile.economy.energyUnits
					),
					timestamp = at,
					configSnapshotId = reward.configSnapshotId,
					expectedRevision = expected,
				})
			end
			return { status = "Applied" }
		end
		local preview = mutate(snapshot)
		if preview.status ~= "Applied" then
			return preview
		end
		local committed = session.checkpoint(op, function(profile: any)
			assert(profile.profileRevision == expected, "world revision changed")
			assert(inside(), "world presence changed")
			assert(
				options.world.canAccess(profile, l.regionId, options.progression.hasAccess),
				"world access changed"
			)
			assert(mutate(profile).status == "Applied", "world evidence/reward changed")
		end)
		if committed.status == "OutcomeUnknown" then
			pending[session] = op
		end
		return committed
	end
	return {
		discoverTravel = function(session: any, nodeId: string, inside: () -> boolean): any
			local result = reconcile(session)
			if result.status ~= "Unchanged" then
				return result
			end
			local d = options.world.registry.travelNodes[nodeId]
			local profile = session.snapshot()
			if
				d == nil
				or not options.world.canAccess(profile, d.regionId, options.progression.hasAccess)
			then
				return { status = "Rejected", reason = "ACCESS_BLOCKED" }
			end
			local ok, present = pcall(inside)
			if not ok or present ~= true then
				return { status = "Rejected", reason = "OUT_OF_RANGE" }
			end
			if options.world.travelDiscovered(profile, nodeId) then
				return { status = "AlreadyCommitted" }
			end
			local expected, op = profile.profileRevision, options.newOperationId()
			local committed = session.checkpoint(op, function(candidate: any)
				assert(
					candidate.profileRevision == expected and inside(),
					"travel discovery context changed"
				)
				assert(
					options.world.canAccess(candidate, d.regionId, options.progression.hasAccess),
					"travel access changed"
				)
				assert(
					options.world.discoverTravel(candidate, nodeId, op),
					"travel discovery changed"
				)
			end)
			if committed.status == "OutcomeUnknown" then
				pending[session] = op
			end
			return committed
		end,
		visit = visit,
		reconcile = reconcile,
		canAccess = function(profile: any, regionId: string): boolean
			return options.world.canAccess(profile, regionId, options.progression.hasAccess)
		end,
	}
end
return WorldActionUseCase
