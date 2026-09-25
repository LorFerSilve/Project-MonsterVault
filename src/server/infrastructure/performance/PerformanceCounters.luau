--!strict

-- Bounded counters and timing aggregates. The caller declares metric names at
-- construction so arbitrary user/content IDs cannot create unbounded series.
local MAX_SAFE = 9_007_199_254_740_991
local PerformanceCounters = {}

function PerformanceCounters.new(names: { string })
	local counters: { [string]: number } = {}
	local timings: { [string]: { count: number, totalMs: number, maxMs: number } } = {}
	for _, name in names do
		assert(
			type(name) == "string" and string.match(name, "^[a-z][a-z0-9_]+$"),
			"invalid metric name"
		)
		assert(counters[name] == nil, "duplicate metric: " .. name)
		counters[name] = 0
		timings[name] = { count = 0, totalMs = 0, maxMs = 0 }
	end

	local function increment(name: string, amount: number?)
		assert(counters[name] ~= nil, "unknown metric: " .. name)
		local step = if amount == nil then 1 else amount
		assert(
			type(step) == "number" and step >= 0 and step % 1 == 0 and step <= MAX_SAFE,
			"invalid count"
		)
		counters[name] = math.min(MAX_SAFE, counters[name] + step)
	end

	local function observe(name: string, milliseconds: number)
		local timing = timings[name]
		assert(timing ~= nil, "unknown metric: " .. name)
		assert(
			type(milliseconds) == "number" and milliseconds >= 0 and milliseconds < math.huge,
			"invalid timing"
		)
		timing.count = math.min(MAX_SAFE, timing.count + 1)
		timing.totalMs = math.min(MAX_SAFE, timing.totalMs + milliseconds)
		timing.maxMs = math.max(timing.maxMs, milliseconds)
	end

	local function snapshot()
		local result = {}
		for name, count in counters do
			local timing = timings[name]
			result[name] = {
				count = count,
				observations = timing.count,
				totalMs = timing.totalMs,
				maxMs = timing.maxMs,
			}
		end
		return result
	end

	return { increment = increment, observe = observe, snapshot = snapshot }
end

return PerformanceCounters
