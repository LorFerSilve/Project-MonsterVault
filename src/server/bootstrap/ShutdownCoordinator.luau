--!strict

local ShutdownCoordinator = {}

function ShutdownCoordinator.new(monotonicSeconds: () -> number)
	assert(type(monotonicSeconds) == "function", "monotonic clock required")
	local steps = {}
	local ids = {}
	local closed = false
	local finished = false

	local function register(id: string, stop: () -> { string })
		assert(not closed, "shutdown registration closed")
		assert(type(id) == "string" and string.match(id, "^[%w_]+$"), "invalid shutdown id")
		assert(type(stop) == "function", "shutdown stop required")
		assert(not ids[id], "duplicate shutdown registration: " .. id)
		ids[id] = true
		table.insert(steps, { id = id, stop = stop })
	end

	local function shutdown(budgetSeconds: number): { string }
		if finished then
			return {}
		end
		assert(
			type(budgetSeconds) == "number" and budgetSeconds >= 0 and budgetSeconds < math.huge,
			"invalid shutdown budget"
		)
		closed = true -- admission closes before any drain step
		finished = true
		local deadline = monotonicSeconds() + budgetSeconds
		local failures = {}
		for index = #steps, 1, -1 do
			local step = steps[index]
			if monotonicSeconds() >= deadline then
				table.insert(failures, "deadline before " .. step.id)
				break
			end
			local ok, result = pcall(step.stop)
			if ok and type(result) == "table" then
				for _, failure in result do
					table.insert(failures, step.id .. ": " .. tostring(failure))
				end
			elseif ok then
				table.insert(failures, step.id .. ": invalid stop result")
			else
				table.insert(failures, step.id .. ": " .. tostring(result))
			end
		end
		return failures
	end

	return {
		register = register,
		shutdown = shutdown,
		isAdmissionClosed = function(): boolean
			return closed
		end,
	}
end

return ShutdownCoordinator
