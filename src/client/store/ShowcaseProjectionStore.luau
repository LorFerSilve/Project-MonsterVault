--!strict

local ShowcaseProjectionStore = {}
function ShowcaseProjectionStore.new(contract: any, wire: any, clock: () -> number)
	local permissions: any = nil
	local visit: any = nil
	local permissionRevision, viewRevision, lastTime = 0, 0, 0
	local function expire()
		local at = clock()
		local valid = type(at) == "number" and at >= lastTime and at < math.huge
		if valid then
			lastTime = at
		end
		if permissions then
			for _, field in { "visitors", "incoming" } do
				local visible = {}
				for _, g in permissions.state[field] do
					if valid and at < g.expiresAt then
						table.insert(visible, g)
					end
				end
				permissions.state[field] = visible
			end
		end
		if
			visit
			and visit.state.mode == "ReadOnly"
			and (not valid or at >= visit.state.expiresAt)
		then
			visit.state = { mode = "Closed", reason = "Expired" }
		end
	end
	return {
		snapshot = function(payload: any): string
			if not contract.validSnapshot(payload) or not wire.payload(payload) then
				return "Invalid"
			end
			if payload.domain == "showcase" then
				if payload.revision <= permissionRevision then
					return "Stale"
				end
				permissions, permissionRevision = wire.copy(payload), payload.revision
			else
				if payload.revision <= viewRevision then
					return "Stale"
				end
				visit, viewRevision = wire.copy(payload), payload.revision
			end
			expire()
			return "Showcase"
		end,
		view = function(): any
			expire()
			return {
				permissions = if permissions then wire.copy(permissions) else nil,
				visit = if visit then wire.copy(visit) else nil,
			}
		end,
		nextDeadline = function(): number?
			expire()
			local at = math.huge
			if permissions then
				for _, field in { "visitors", "incoming" } do
					for _, g in permissions.state[field] do
						at = math.min(at, g.expiresAt)
					end
				end
			end
			if visit and visit.state.mode == "ReadOnly" then
				at = math.min(at, visit.state.expiresAt)
			end
			return if at < math.huge then at else nil
		end,
		invalidate = function()
			permissions = nil
			if visit then
				visit.state = { mode = "Closed", reason = "Unavailable" }
			end
			-- Retain watermarks: a delayed old packet cannot undo invalidation.
		end,
		reset = function()
			permissions, visit = nil, nil
			permissionRevision, viewRevision, lastTime = 0, 0, 0
		end,
	}
end
return ShowcaseProjectionStore
