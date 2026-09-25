--!strict

-- One queue is created per profile key. Critical checkpoints can pass queued
-- background work, but never interrupt an operation already in UpdateAsync.
local SingleWriterQueue = {}

function SingleWriterQueue.new(
	monotonicSeconds: () -> number,
	waitSeconds: (number) -> (),
	timeoutSeconds: number
)
	assert(
		type(monotonicSeconds) == "function" and type(waitSeconds) == "function",
		"queue clock and wait required"
	)
	assert(
		type(timeoutSeconds) == "number" and timeoutSeconds > 0 and timeoutSeconds < math.huge,
		"invalid queue timeout"
	)
	local pending: { any } = {}
	local busy = false
	local nextSequence = 0
	local closed = false

	local function remove(ticket: any)
		for index, current in pending do
			if current == ticket then
				table.remove(pending, index)
				return
			end
		end
	end

	local function run(priority: string, operation: () -> any)
		assert(priority == "critical" or priority == "routine", "invalid queue priority")
		assert(type(operation) == "function", "queue operation required")
		if closed then
			return { status = "closed" }
		end
		nextSequence += 1
		local ticket = { priority = priority, sequence = nextSequence }
		table.insert(pending, ticket)
		local deadline = monotonicSeconds() + timeoutSeconds
		while true do
			if closed then
				remove(ticket)
				return { status = "closed" }
			end
			local first: any = ticket
			for _, current in pending do
				if
					current.priority == "critical" and first.priority ~= "critical"
					or current.priority == first.priority and current.sequence < first.sequence
				then
					first = current
				end
			end
			if not busy and first == ticket then
				break
			end
			if monotonicSeconds() >= deadline then
				remove(ticket)
				return { status = "timeout" }
			end
			waitSeconds(0.03)
		end
		busy = true
		remove(ticket)
		local ok, value = pcall(operation :: () -> any)
		busy = false
		if not ok then
			return { status = "error", reason = "QUEUE_OPERATION_ERROR" }
		end
		return { status = "ok", value = value }
	end

	return {
		run = run,
		close = function()
			closed = true
		end,
		isClosed = function(): boolean
			return closed
		end,
		pendingCount = function(): number
			return #pending + if busy then 1 else 0
		end,
	}
end

return SingleWriterQueue
