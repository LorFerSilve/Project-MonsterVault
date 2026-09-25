--!strict

local ProjectionStore = {}

function ProjectionStore.new(projection: any, wire: any)
	local session: any = nil
	local revision = 0
	local resyncNeeded = false

	local function snapshot(payload: any): string
		if not projection.validSnapshot(payload) then
			return "Invalid"
		end
		if payload.revision < revision then
			return "Stale"
		end
		session = wire.copy(payload.state)
		revision = payload.revision
		resyncNeeded = false
		return "Applied"
	end

	local function delta(payload: any): string
		if not projection.validDelta(payload) then
			return "Invalid"
		end
		if payload.revision <= revision then
			return "Stale"
		end
		if session == nil or payload.baseRevision ~= revision then
			resyncNeeded = true
			return "Gap"
		end
		session = wire.copy(payload.state)
		revision = payload.revision
		return "Applied"
	end

	return {
		snapshot = snapshot,
		delta = delta,
		view = function()
			return wire.copy(session), revision
		end,
		needsResync = function(): boolean
			return resyncNeeded
		end,
		reset = function()
			session = nil
			revision = 0
			resyncNeeded = false
		end,
	}
end

return ProjectionStore
