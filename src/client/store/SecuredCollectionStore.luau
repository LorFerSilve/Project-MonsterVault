--!strict

local SecuredCollectionStore = {}

function SecuredCollectionStore.new(projection: any, wire: any)
	local state: any = nil

	local function snapshot(payload: any, session: any): string
		if
			not projection.validSnapshot(payload)
			or type(session) ~= "table"
			or session.status ~= "Ready"
			or session.profileRevision ~= payload.revision
		then
			return "Invalid"
		end
		if state ~= nil and payload.revision < state.profileRevision then
			return "Stale"
		end
		if state ~= nil and payload.revision == state.profileRevision then
			return if wire.equal(state, payload.state) then "Stale" else "Invalid"
		end
		state = wire.copy(payload.state)
		return "Applied"
	end

	return {
		snapshot = snapshot,
		view = function(): any
			return wire.copy(state)
		end,
		reset = function()
			state = nil
		end,
	}
end

return SecuredCollectionStore
