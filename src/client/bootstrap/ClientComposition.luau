--!strict

local StartupPlan =
	require(game:GetService("ReplicatedStorage").MonsterVault.Shared.util.StartupPlan)
local StructuredDiagnostics =
	require(game:GetService("ReplicatedStorage").MonsterVault.Shared.util.StructuredDiagnostics)

local ClientComposition = {}

function ClientComposition.new(options: {
	sink: (any) -> (),
	unixSeconds: () -> number,
	services: { StartupPlan.Service }?,
	buildServices: ((any) -> { StartupPlan.Service })?,
})
	local diagnostics = StructuredDiagnostics.new(options.sink, options.unixSeconds, "client")
	assert(
		options.services == nil or options.buildServices == nil,
		"choose services or buildServices"
	)
	local services = if options.buildServices
		then options.buildServices(diagnostics)
		else options.services or {}
	local ordered = StartupPlan.prepare(services)
	local started = false
	local stopServices: (() -> { string })? = nil

	local function start()
		assert(not started, "client composition already started")
		local ok, stopOrFailure = pcall(StartupPlan.start, ordered)
		if not ok then
			diagnostics.emit("error", "BOOTSTRAP_FAILED", { component = "client" })
			error(stopOrFailure, 2)
		end
		stopServices = stopOrFailure
		started = true
		diagnostics.emit("info", "BOOTSTRAP_READY", { component = "client" })
	end

	local function stop(): { string }
		if not started then
			return {}
		end
		started = false
		local failures = (stopServices :: () -> { string })()
		if #failures > 0 then
			diagnostics.emit(
				"error",
				"SHUTDOWN_FAILED",
				{ component = "client", count = #failures }
			)
		end
		return failures
	end

	return { start = start, stop = stop, diagnostics = diagnostics }
end

return ClientComposition
