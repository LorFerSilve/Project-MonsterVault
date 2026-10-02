--!strict

-- AD-258 / TA-9: absolute server wall time, no timer or per-player reset.
local WorldCycle = {}
local function finite(value: any): boolean
	return type(value) == "number" and value == value and math.abs(value) < 2 ^ 53
end

function WorldCycle.new(definition: any, unixSeconds: () -> number): any
	-- The registry has already validated/frozen its definition.
	local lastTime = -math.huge
	local previous: any = nil
	local function sample(): any
		local ok, now = pcall(unixSeconds)
		if not ok or not finite(now) or now < lastTime then
			return nil -- Pause new admission, never destroy or rewrite existing custody.
		end
		lastTime = now
		local elapsed = math.max(0, now - definition.epochUnixSeconds)
		local cycleIndex = math.floor(elapsed / definition.durationSeconds)
		local offset = elapsed % definition.durationSeconds
		local start = 0
		for n = 1, #definition.phases do
			local phase = definition.phases[n]
			local finish = start + phase.durationSeconds
			if offset < finish then
				if previous and previous.cycleIndex == cycleIndex and previous.phaseIndex == n then
					return previous
				end
				local cycleStart = definition.epochUnixSeconds
					+ cycleIndex * definition.durationSeconds
				previous = table.freeze({
					definitionId = definition.id,
					definitionVersion = definition.version,
					phaseId = phase.id,
					cycleIndex = cycleIndex,
					phaseIndex = n,
					phaseStartedAtUnixSeconds = cycleStart + start,
					nextTransitionUnixSeconds = cycleStart + finish,
				})
				return previous
			end
			start = finish
		end
		return nil
	end
	return table.freeze({ sample = sample })
end

function WorldCycle.eligible(habitat: any, context: any, snapshot: any): boolean
	return type(snapshot) == "table"
		and type(habitat) == "table"
		and type(context) == "table"
		and habitat.cycleDefinitionId == snapshot.definitionId
		and context.cycleDefinitionId == snapshot.definitionId
		and type(habitat.cyclePhaseIds) == "table"
		and type(context.cyclePhaseIds) == "table"
		and table.find(habitat.cyclePhaseIds, snapshot.phaseId) ~= nil
		and table.find(context.cyclePhaseIds, snapshot.phaseId) ~= nil
end
return WorldCycle
