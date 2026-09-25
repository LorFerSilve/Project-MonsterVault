--!strict

local ShutdownCoordinator = require("../../src/server/bootstrap/ShutdownCoordinator")

local function closesAdmissionAndDrainsInReverse()
	local time = 10
	local events = {}
	local coordinator = ShutdownCoordinator.new(function()
		return time
	end)
	coordinator.register("first", function()
		assert(coordinator.isAdmissionClosed(), "admission closes before callbacks")
		table.insert(events, "first")
		return {}
	end)
	coordinator.register("second", function()
		table.insert(events, "second")
		time += 1
		return {}
	end)
	assert(not coordinator.isAdmissionClosed(), "admission open before shutdown")
	assert(#coordinator.shutdown(2) == 0, "drain succeeds")
	assert(table.concat(events, ",") == "second,first", "callbacks drain in reverse order")
	assert(coordinator.isAdmissionClosed(), "admission stays closed")
	assert(#coordinator.shutdown(2) == 0 and #events == 2, "shutdown is idempotent")
	assert(not pcall(coordinator.register, "late", function()
		return {}
	end), "registration closes on shutdown")
end

local function duplicatesFailuresAndDeadline()
	local time = 0
	local coordinator = ShutdownCoordinator.new(function()
		return time
	end)
	coordinator.register("first", function()
		return {}
	end)
	assert(not pcall(coordinator.register, "first", function()
		return {}
	end), "duplicate stop registration rejected")
	coordinator.register("second", function()
		time = 5
		return { "synthetic failure" }
	end)
	local failures = coordinator.shutdown(2)
	assert(#failures == 2, "callback failure and skipped deadline are reported")
	assert(string.find(failures[1], "second", 1, true) ~= nil, "callback failure names owner")
	assert(string.find(failures[2], "first", 1, true) ~= nil, "deadline names skipped owner")
end

return {
	closesAdmissionAndDrainsInReverse = closesAdmissionAndDrainsInReverse,
	duplicatesFailuresAndDeadline = duplicatesFailuresAndDeadline,
}
