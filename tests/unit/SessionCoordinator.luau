--!strict

local SessionCoordinator = require("../../src/server/application/SessionCoordinator")

local function multipleSessionsAutosaveAndShutdown()
	local now = 100
	local created = {}
	local saved = {}
	local coordinator = SessionCoordinator.new({
		createSession = function(userId)
			created[userId] = true
			local state = "NoSession"
			return {
				acquire = function()
					state = "Ready"
					return { status = "Ready" }
				end,
				state = function()
					return state
				end,
				renew = function()
					saved[userId] = (saved[userId] or 0) + 1
					return { status = "Ready" }
				end,
				release = function()
					state = "Closed"
					return { status = "Closed" }
				end,
			}
		end,
		unixSeconds = function()
			return now
		end,
		monotonicSeconds = function()
			return now
		end,
		spawn = function(callback)
			callback()
		end,
		waitSeconds = function(seconds)
			now += seconds
		end,
	})
	assert(next(created) == nil, "construction has no import-time startup")
	assert(
		coordinator.open(1).status == "Ready" and coordinator.open(2).status == "Ready",
		"sessions open"
	)
	assert(coordinator.open(1).status == "DuplicateSession", "duplicate local session rejected")
	now = 176
	coordinator.tick()
	assert(saved[1] == 1 and saved[2] == nil, "autosaves stagger by player")
	now = 177
	coordinator.tick()
	assert(saved[2] == 1, "second player renews separately")
	assert(#coordinator.shutdown(now + 10) == 0, "all profiles drain")
	assert(coordinator.get(1) == nil and coordinator.get(2) == nil, "closed sessions removed")
	assert(coordinator.open(3).status == "Closing", "shutdown closes admission")
end

local function closeWaitsForActiveWriter()
	local now = 0
	local releaseCalls = 0
	local coordinator = SessionCoordinator.new({
		createSession = function()
			return {
				acquire = function()
					return { status = "Ready" }
				end,
				state = function()
					return "Ready"
				end,
				release = function()
					releaseCalls += 1
					return { status = if releaseCalls == 1 then "Busy" else "Closed" }
				end,
			}
		end,
		unixSeconds = function()
			return now
		end,
		monotonicSeconds = function()
			return now
		end,
		spawn = function(callback)
			callback()
		end,
		waitSeconds = function(seconds)
			now += seconds
		end,
	})
	assert(coordinator.open(42).status == "Ready", "acquired")
	assert(coordinator.close(42, 1).status == "Closed", "close waits for busy writer")
	assert(releaseCalls == 2 and now > 0, "writer gets time to finish")
end

local function leaveDuringAcquireReleasesLease()
	local now = 0
	local releaseCalls = 0
	local coordinator
	coordinator = SessionCoordinator.new({
		createSession = function()
			local state = "NoSession"
			return {
				acquire = function()
					state = "Acquiring"
					local closeResult = coordinator.close(73, now + 0.1)
					assert(
						closeResult.status == "PendingClose",
						"departure recorded during acquisition"
					)
					state = "Ready"
					return { status = "Ready" }
				end,
				state = function()
					return state
				end,
				release = function()
					releaseCalls += 1
					state = "Closed"
					return { status = "Closed" }
				end,
			}
		end,
		unixSeconds = function()
			return now
		end,
		monotonicSeconds = function()
			return now
		end,
		spawn = function(callback)
			callback()
		end,
		waitSeconds = function(seconds)
			now += seconds
		end,
	})
	assert(coordinator.open(73).status == "Closed", "acquired lease immediately released")
	assert(releaseCalls == 1 and coordinator.get(73) == nil, "no orphan session")
end

return {
	multipleSessionsAutosaveAndShutdown = multipleSessionsAutosaveAndShutdown,
	closeWaitsForActiveWriter = closeWaitsForActiveWriter,
	leaveDuringAcquireReleasesLease = leaveDuringAcquireReleasesLease,
}
