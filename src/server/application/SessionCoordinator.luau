--!strict

-- Coordinates player sessions; ProfileSession remains the only owner of each
-- profile's writer queue and durable state transitions.
local SessionCoordinator = {}

function SessionCoordinator.new(options: {
	createSession: (number) -> any,
	unixSeconds: () -> number,
	monotonicSeconds: () -> number,
	spawn: (() -> ()) -> (),
	waitSeconds: (number) -> (),
})
	local sessions: { [number]: any } = {}
	local dueAt: { [number]: number } = {}
	local pendingClose: { [number]: boolean } = {}
	local reopening: { [number]: boolean } = {}
	local admissionClosed = false
	local loopStarted = false
	local close: (number, number) -> any

	local function interval(userId: number): number
		return 75 + userId % 16 -- 75..90 seconds, staggered and within TA-14 renewal target.
	end

	local function open(userId: number)
		if admissionClosed then
			return { status = "Closing" }
		end
		if sessions[userId] ~= nil then
			if not pendingClose[userId] then
				return { status = "DuplicateSession" }
			end
			if reopening[userId] then
				return { status = "PendingClose" }
			end
			reopening[userId] = true
			local prior = sessions[userId]
			local absoluteDeadline = options.monotonicSeconds() + 25
			local outcome = close(userId, absoluteDeadline)
			while sessions[userId] == prior and options.monotonicSeconds() < absoluteDeadline do
				options.waitSeconds(math.min(1, absoluteDeadline - options.monotonicSeconds()))
				outcome = close(userId, absoluteDeadline)
			end
			reopening[userId] = nil
			if sessions[userId] ~= nil then
				return if sessions[userId] == prior
					then outcome
					else { status = "DuplicateSession" }
			end
			if admissionClosed then
				return { status = "Closing" }
			end
		end
		local session = options.createSession(userId)
		sessions[userId] = session
		local outcome = session.acquire()
		if outcome.status == "Ready" then
			if pendingClose[userId] or admissionClosed then
				return close(userId, options.monotonicSeconds() + 25)
			end
			dueAt[userId] = options.unixSeconds() + interval(userId)
		elseif pendingClose[userId] and sessions[userId] == session then
			sessions[userId] = nil
			pendingClose[userId] = nil
		end
		return outcome
	end

	close = function(userId: number, absoluteDeadline: number)
		local session = sessions[userId]
		if session == nil then
			return { status = "NoSession" }
		end
		local state = session.state()
		pendingClose[userId] = true
		if state == "Acquiring" then
			while state == "Acquiring" and options.monotonicSeconds() < absoluteDeadline do
				options.waitSeconds(0.05)
				state = session.state()
			end
			if state == "Acquiring" then
				return { status = "PendingClose" }
			end
		end
		if state ~= "Ready" and state ~= "PersistenceAtRisk" and state ~= "Releasing" then
			if sessions[userId] == session then
				sessions[userId] = nil
				dueAt[userId] = nil
				pendingClose[userId] = nil
			end
			return { status = state }
		end
		local outcome = session.release(absoluteDeadline)
		while outcome.status == "Busy" and options.monotonicSeconds() < absoluteDeadline do
			options.waitSeconds(0.05)
			outcome = session.release(absoluteDeadline)
		end
		if outcome.status == "Closed" then
			if sessions[userId] == session then
				sessions[userId] = nil
				dueAt[userId] = nil
				pendingClose[userId] = nil
			end
		elseif sessions[userId] == session then
			dueAt[userId] = options.unixSeconds() + 5
		end
		return outcome
	end

	local function tick()
		if admissionClosed then
			return
		end
		local now = options.unixSeconds()
		for userId, session in sessions do
			local state = session.state()
			if pendingClose[userId] then
				if now >= (dueAt[userId] or math.huge) and not reopening[userId] then
					close(userId, options.monotonicSeconds() + 25)
				end
			elseif
				(state == "Ready" or state == "PersistenceAtRisk")
				and now >= (dueAt[userId] or math.huge)
			then
				local result = session.renew()
				if result.status == "Ready" then
					dueAt[userId] = options.unixSeconds() + interval(userId)
				else
					dueAt[userId] = options.unixSeconds() + 5
				end
			end
		end
	end

	local function startLoop()
		assert(not loopStarted, "session loop already started")
		assert(not admissionClosed, "session coordinator closing")
		loopStarted = true
		options.spawn(function()
			while not admissionClosed do
				tick()
				options.waitSeconds(1)
			end
		end)
	end

	local function shutdown(absoluteDeadline: number): { string }
		admissionClosed = true
		local failures = {}
		local remaining = 0
		local userIds = {}
		for userId in sessions do
			table.insert(userIds, userId)
		end
		for _, userId in userIds do
			remaining += 1
			options.spawn(function()
				local ok, outcome = pcall(close, userId, absoluteDeadline)
				if not ok then
					table.insert(failures, tostring(userId) .. ": drain error")
				elseif outcome.status ~= "Closed" and outcome.status ~= "NoSession" then
					table.insert(failures, tostring(userId) .. ": " .. outcome.status)
				end
				remaining -= 1
			end)
		end
		while remaining > 0 and options.monotonicSeconds() < absoluteDeadline do
			options.waitSeconds(0.05)
		end
		if remaining > 0 then
			table.insert(failures, "shutdown deadline with pending profile drains")
		end
		return failures
	end

	return {
		open = open,
		close = close,
		tick = tick,
		startLoop = startLoop,
		shutdown = shutdown,
		get = function(userId: number)
			return sessions[userId]
		end,
		isAdmissionClosed = function(): boolean
			return admissionClosed
		end,
	}
end

return SessionCoordinator
