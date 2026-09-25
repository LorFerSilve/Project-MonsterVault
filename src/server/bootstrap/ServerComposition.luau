--!strict

local StartupValidator = require(script.Parent.StartupValidator)
local StartupPlan =
	require(game:GetService("ReplicatedStorage").MonsterVault.Shared.util.StartupPlan)
local StructuredDiagnostics =
	require(game:GetService("ReplicatedStorage").MonsterVault.Shared.util.StructuredDiagnostics)
local PerformanceCounters =
	require(script.Parent.Parent.infrastructure.performance.PerformanceCounters)
local ShutdownCoordinator = require(script.Parent.ShutdownCoordinator)

local ServerComposition = {}

function ServerComposition.new(options: {
	sink: (any) -> (),
	unixSeconds: () -> number,
	monotonicSeconds: () -> number,
	services: { StartupPlan.Service }?,
	buildServices: ((any) -> { StartupPlan.Service })?,
})
	local diagnostics = StructuredDiagnostics.new(options.sink, options.unixSeconds, "server")
	assert(
		options.services == nil or options.buildServices == nil,
		"choose services or buildServices"
	)
	local services = if options.buildServices
		then options.buildServices(diagnostics)
		else options.services or {}
	local ordered = StartupValidator.validate(services)
	local counters = PerformanceCounters.new({
		"bootstrap_attempts",
		"bootstrap_failures",
		"bootstrap_ms",
		"shutdown_failures",
	})
	local coordinator = ShutdownCoordinator.new(options.monotonicSeconds)
	local started = false
	local shutdownReported = false

	local function start()
		assert(not started, "server composition already started")
		assert(not coordinator.isAdmissionClosed(), "server composition is shutting down")
		counters.increment("bootstrap_attempts")
		local startTime = options.monotonicSeconds()
		local ok, stopOrFailure = pcall(StartupPlan.start, ordered)
		counters.observe("bootstrap_ms", (options.monotonicSeconds() - startTime) * 1000)
		if not ok then
			counters.increment("bootstrap_failures")
			diagnostics.emit("error", "BOOTSTRAP_FAILED", { component = "server" })
			error(stopOrFailure, 2)
		end
		coordinator.register("services", stopOrFailure)
		started = true
		diagnostics.emit("info", "BOOTSTRAP_READY", { component = "server" })
	end

	local function shutdown(budgetSeconds: number): { string }
		if shutdownReported then
			return {}
		end
		local failures = coordinator.shutdown(budgetSeconds)
		shutdownReported = true
		if #failures > 0 then
			counters.increment("shutdown_failures", #failures)
			diagnostics.emit(
				"error",
				"SHUTDOWN_FAILED",
				{ component = "server", count = #failures }
			)
		else
			diagnostics.emit("info", "SHUTDOWN_COMPLETE", { component = "server" })
		end
		return failures
	end

	return {
		start = start,
		shutdown = shutdown,
		isAdmissionClosed = coordinator.isAdmissionClosed,
		counters = counters,
		diagnostics = diagnostics,
	}
end

return ServerComposition
