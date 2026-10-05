--!strict

-- AD-259: bounded character-presence transitions in the existing world pulse.
-- Native geometry/capture/profile owners are injected; no value or position input from clients.
local WorldTravelService = {}
function WorldTravelService.new(options: any): any
	local records: { [number]: any } = {}
	local running = true
	local function record(player: any): any
		local r = records[player.UserId]
		if r == nil then
			r = {
				session = nil,
				generation = nil,
				character = nil,
				busy = false,
				retryAt = 0,
				nextTravelAt = 0,
				lastRegion = nil,
				hazard = nil,
				recoveryObservationNodeId = nil,
				position = nil,
			}
			records[player.UserId] = r
		end
		return r
	end
	local function observedContext(context: any, r: any): any
		if
			context
			and r
			and context.finitePosition ~= false
			and r.session == context.session
			and r.character == context.character
			and r.generation == context.generation
			and r.position ~= nil
			and context.position ~= nil
			and options.hazardBetween
		then
			local hazard = options.hazardBetween(context, r.position)
			if hazard then
				context.hazardId, context.validPosition = hazard, false
			end
		end
		if context and r then
			local h = r.hazard
			local same = h
				and h.session == context.session
				and h.character == context.character
				and h.generation == context.generation
			if context.hazardId and not same then
				r.hazard = {
					session = context.session,
					character = context.character,
					generation = context.generation,
					id = context.hazardId,
					interrupted = false,
				}
				h, same = r.hazard, true
			end
			if same then
				context.hazardId, context.validPosition = h.id, false
			end
		end
		return context
	end
	local function current(player: any, context: any): boolean
		local live = options.context(player)
		return running
			and live ~= nil
			and live.session == context.session
			and live.character == context.character
			and live.generation == context.generation
	end
	local function transition(player: any, context: any, target: any, recovery: boolean): string
		local r = record(player)
		if r.busy then
			return "REJECT_STATE_TRAVEL_BUSY"
		end
		r.busy = true
		-- Optional passive social observation. Failure cannot change ordinary travel.
		local observation: any = nil
		if options.beginTravelObservation then
			local observed, value =
				pcall(options.beginTravelObservation, player, context, target, recovery)
			if observed then
				observation = value
			end
		end
		local ok, moved = pcall(options.relocate, player, context, target, recovery, function()
			local live = observedContext(options.context(player), r)
			return current(player, context) and (recovery or (live ~= nil and live.validPosition))
		end)
		r.busy = false
		if not running then
			return "REJECT_STATE_TRAVEL_STALE"
		end
		local live = options.context(player)
		if
			not ok
			or moved ~= true
			or live == nil
			or live.character ~= context.character
			or live.session ~= context.session
			or not live.validPosition
			or (not recovery and live.generation ~= context.generation)
		then
			r.generation = nil -- Next central pass performs recovery, never repeats a travel request.
			r.retryAt = options.clock() + 1
			return "UNAVAILABLE_TRAVEL_ARRIVAL"
		end
		r.session, r.generation, r.character, r.lastRegion =
			live.session, live.generation, live.character, target.regionId
		r.hazard = nil
		r.recoveryObservationNodeId = if recovery then target.recoveryObservationNodeId else nil
		r.position = live.position -- Authorized relocation starts a new observation segment.
		if not recovery and observation ~= nil and options.completeTravelObservation then
			pcall(options.completeTravelObservation, observation)
		end
		return if recovery then "OK_WORLD_RECOVERED" else "OK_WORLD_TRAVELLED"
	end
	local function interruptHazard(player: any, context: any, r: any): boolean
		local h = r.hazard
		local same = h
			and h.session == context.session
			and h.character == context.character
			and h.generation == context.generation
		if (same and h.interrupted) or (not same and context.hazardId == nil) then
			return true
		end
		-- Latch an observed consequence even if interruption fails and the player leaves.
		r.hazard = {
			session = context.session,
			character = context.character,
			generation = context.generation,
			id = context.hazardId,
			interrupted = false,
		}
		r.busy = true
		local ok, interrupted = pcall(options.interrupt, player, context, function()
			return current(player, context)
		end)
		r.busy = false
		if not ok or interrupted ~= true or not current(player, context) then
			r.retryAt = options.clock() + 1
			return false
		end
		r.hazard.interrupted = true
		return true
	end
	local function step(players: { any })
		if not running then
			return
		end
		local present = {}
		for _, player in players do
			present[player.UserId] = true
			local r = record(player)
			local context = observedContext(options.context(player), r)
			if context ~= nil and not r.busy then
				if r.session ~= context.session then
					-- A new trusted session must establish its own safe arrival.
					r.lastRegion = nil
				end
				if
					r.session ~= context.session
					or r.generation ~= context.generation
					or r.character ~= context.character
					or not context.validPosition
				then
					r.generation = nil
					if options.clock() >= r.retryAt and interruptHazard(player, context, r) then
						local target = options.recovery(context, r.lastRegion)
						if target ~= nil then
							transition(player, context, target, true)
						else
							r.retryAt = options.clock() + 1
						end
					end
				elseif context.regionId then
					r.lastRegion = context.regionId
				end
				local live = options.context(player)
				if
					live
					and live.session == r.session
					and live.generation == r.generation
					and live.character == r.character
					and live.validPosition
				then
					r.position = live.position
					if live.nodeId ~= r.recoveryObservationNodeId then
						r.recoveryObservationNodeId = nil
					end
					if r.recoveryObservationNodeId == nil then
						options.observe(player, live)
					end
				end
			end
		end
		for userId in records do
			if not present[userId] then
				records[userId] = nil
			end
		end
	end
	return {
		step = step,
		available = function(player: any, generation: number, nodeId: string): boolean
			local r = records[player.UserId]
			local c = if running then observedContext(options.context(player), r) else nil
			if
				r == nil
				or c == nil
				or r.busy
				or not c.validPosition
				or r.session ~= c.session
				or r.character ~= c.character
				or r.generation ~= generation
				or c.generation ~= generation
				or options.clock() < r.nextTravelAt
			then
				return false
			end
			return options.destination(c, nodeId) ~= nil
		end,
		ready = function(player: any, generation: number): boolean
			local r = records[player.UserId]
			local context = if running then observedContext(options.context(player), r) else nil
			return running
				and context ~= nil
				and context.validPosition
				and context.generation == generation
				and r ~= nil
				and not r.busy
				and r.session == context.session
				and r.generation == generation
				and r.character == player.Character
		end,
		travel = function(player: any, nodeId: string, generation: number): string
			if not running then
				return "REJECT_STATE_TRAVEL_CONTEXT"
			end
			local r = record(player)
			local context = observedContext(options.context(player), r)
			if context == nil then
				return "REJECT_STATE_TRAVEL_CONTEXT"
			end
			if r.busy then
				return "REJECT_STATE_TRAVEL_BUSY"
			end
			if
				r.session ~= context.session
				or generation ~= context.generation
				or r.generation ~= generation
				or r.character ~= context.character
			then
				return "REJECT_STATE_TRAVEL_STALE"
			end
			local target, reason = options.destination(context, nodeId)
			if target == nil then
				return "REJECT_STATE_TRAVEL_" .. reason
			end
			if options.clock() < r.nextTravelAt then
				return "REJECT_RATE_LIMIT"
			end
			r.nextTravelAt = options.clock() + 1
			return transition(player, context, target, false)
		end,
		stop = function()
			running = false
			table.clear(records)
		end,
	}
end
return WorldTravelService
