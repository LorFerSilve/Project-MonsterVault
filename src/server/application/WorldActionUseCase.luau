--!strict

local WorldActionUseCase = {}
function WorldActionUseCase.new(
	options: { world: any, progression: any, newOperationId: () -> string }
): any
	local pending: { [any]: string } = setmetatable({}, { __mode = "k" }) :: any
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
		return if session.state() == "Ready"
			then { status = "Unchanged" }
			else { status = session.state() }
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
		if not options.world.visit(snapshot, landmarkId, op) then
			return { status = "AlreadyCommitted" }
		end
		local expected = session.snapshot().profileRevision
		local committed = session.checkpoint(op, function(profile: any)
			assert(profile.profileRevision == expected, "world revision changed")
			assert(
				options.world.canAccess(profile, l.regionId, options.progression.hasAccess),
				"world access changed"
			)
			assert(options.world.visit(profile, landmarkId, op), "world evidence changed")
		end)
		if committed.status == "OutcomeUnknown" then
			pending[session] = op
		end
		return committed
	end
	return {
		visit = visit,
		reconcile = reconcile,
		canAccess = function(profile: any, regionId: string): boolean
			return options.world.canAccess(profile, regionId, options.progression.hasAccess)
		end,
	}
end
return WorldActionUseCase
