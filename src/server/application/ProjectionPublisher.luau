--!strict

local ProjectionPublisher = {}

function ProjectionPublisher.new(options: {
	protocol: any,
	routes: any,
	projection: any,
	wire: any,
	emit: (any, any) -> (),
})
	local byUser: { [number]: any } = {}

	local function envelope(routeId: string, payload: any, revision: number)
		return {
			protocolVersion = options.protocol.version,
			routeId = routeId,
			revision = revision,
			payload = payload,
		}
	end

	local function current(player: any, state: any): any
		assert(options.projection.validSession(state), "invalid session projection")
		local userId = player.UserId
		local prior = byUser[userId]
		if prior == nil then
			prior = { revision = 1, state = options.wire.copy(state) }
			byUser[userId] = prior
		elseif not options.wire.equal(prior.state, state) then
			prior = { revision = prior.revision + 1, state = options.wire.copy(state) }
			byUser[userId] = prior
		end
		return prior
	end

	local function snapshot(player: any, state: any): number
		local entry = current(player, state)
		local payload = {
			domain = "session",
			revision = entry.revision,
			state = options.wire.copy(entry.state),
		}
		options.emit(
			player,
			envelope(options.routes.events.projectionSnapshot, payload, entry.revision)
		)
		return entry.revision
	end

	local function delta(player: any, state: any): number
		local previous = byUser[player.UserId]
		if previous == nil then
			return snapshot(player, state)
		end
		local entry = current(player, state)
		if entry.revision ~= previous.revision then
			local payload = {
				domain = "session",
				baseRevision = previous.revision,
				revision = entry.revision,
				state = options.wire.copy(entry.state),
			}
			options.emit(
				player,
				envelope(options.routes.events.projectionDelta, payload, entry.revision)
			)
		end
		return entry.revision
	end

	return {
		snapshot = snapshot,
		delta = delta,
		forget = function(userId: number)
			byUser[userId] = nil
		end,
	}
end

return ProjectionPublisher
