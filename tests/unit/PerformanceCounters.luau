--!strict

local PerformanceCounters =
	require("../../src/server/infrastructure/performance/PerformanceCounters")

local function boundedCountersAndTimings()
	local counters = PerformanceCounters.new({ "bootstrap", "shutdown" })
	counters.increment("bootstrap", 2)
	counters.observe("bootstrap", 12.5)
	counters.observe("bootstrap", 4)
	local snapshot = counters.snapshot()
	assert(snapshot.bootstrap.count == 2, "counter tracks events")
	assert(
		snapshot.bootstrap.observations == 2 and snapshot.bootstrap.totalMs == 16.5,
		"timings aggregate"
	)
	assert(snapshot.bootstrap.maxMs == 12.5, "max observed")
	snapshot.bootstrap.count = 100
	assert(counters.snapshot().bootstrap.count == 2, "snapshot is independent")
	counters.increment("shutdown", 9_007_199_254_740_991)
	counters.increment("shutdown", 1)
	assert(counters.snapshot().shutdown.count == 9_007_199_254_740_991, "counter saturates")
end

local function invalidMetricRejected()
	assert(not pcall(PerformanceCounters.new, { "one", "one" }), "duplicate names rejected")
	local counters = PerformanceCounters.new({ "known" })
	assert(not pcall(counters.increment, "unknown"), "unknown metric rejected")
	assert(not pcall(counters.increment, "known", -1), "negative count rejected")
	assert(not pcall(counters.observe, "known", 0 / 0), "NaN timing rejected")
end

return {
	boundedCountersAndTimings = boundedCountersAndTimings,
	invalidMetricRejected = invalidMetricRejected,
}
