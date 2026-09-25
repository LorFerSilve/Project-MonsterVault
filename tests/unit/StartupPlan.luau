--!strict

local StartupPlan = require("../../src/shared/util/StartupPlan")

local function lifecycleOrder()
	local events = {}
	local function service(id: string, dependencies: { string })
		return {
			id = id,
			dependencies = dependencies,
			start = function()
				table.insert(events, `start:{id}`)
			end,
			stop = function()
				table.insert(events, `stop:{id}`)
			end,
		}
	end
	local plan =
		StartupPlan.prepare({ service("z", { "a" }), service("a", {}), service("m", { "a" }) })
	assert(#events == 0, "planning must not start features")
	assert(plan[1].id == "a" and plan[2].id == "m" and plan[3].id == "z", "stable dependency order")
	local stop = StartupPlan.start(plan)
	assert(table.concat(events, ",") == "start:a,start:m,start:z", "start order")
	assert(#stop() == 0, "clean stop")
	assert(
		table.concat(events, ",") == "start:a,start:m,start:z,stop:z,stop:m,stop:a",
		"reverse stop"
	)
	assert(#stop() == 0 and #events == 6, "stop is idempotent")
end

local function invalidGraphRejected()
	local function service(id: string, dependencies: { string })
		return {
			id = id,
			dependencies = dependencies,
			start = function() end,
			stop = function() end,
		}
	end
	assert(
		not pcall(StartupPlan.prepare, { service("a", {}), service("a", {}) }),
		"duplicate registration"
	)
	assert(not pcall(StartupPlan.prepare, { service("a", { "missing" }) }), "missing dependency")
	assert(
		not pcall(StartupPlan.prepare, { service("a", { "b" }), service("b", { "a" }) }),
		"cycle"
	)
	assert(
		not pcall(StartupPlan.prepare, { service("a", { "b", "b" }), service("b", {}) }),
		"duplicate edge"
	)
end

local function startupFailureRollsBack()
	local events = {}
	local plan = StartupPlan.prepare({
		{
			id = "a",
			dependencies = {},
			start = function()
				table.insert(events, "start:a")
			end,
			stop = function()
				table.insert(events, "stop:a")
			end,
		},
		{
			id = "b",
			dependencies = { "a" },
			start = function()
				table.insert(events, "start:b")
				error("intentional failure")
			end,
			stop = function()
				table.insert(events, "stop:b")
			end,
		},
	})
	assert(not pcall(StartupPlan.start, plan), "startup failure propagates")
	assert(
		table.concat(events, ",") == "start:a,start:b,stop:b,stop:a",
		"partial service stops before earlier services"
	)
end

return {
	lifecycleOrder = lifecycleOrder,
	invalidGraphRejected = invalidGraphRejected,
	startupFailureRollsBack = startupFailureRollsBack,
}
