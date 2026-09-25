--!strict

local RetryPolicy = {}

function RetryPolicy.new(
	monotonicSeconds: () -> number,
	waitSeconds: (number) -> (),
	nextUnit: () -> number,
	maxAttempts: number
)
	assert(
		type(monotonicSeconds) == "function"
			and type(waitSeconds) == "function"
			and type(nextUnit) == "function",
		"retry dependencies required"
	)
	assert(
		type(maxAttempts) == "number"
			and maxAttempts % 1 == 0
			and maxAttempts >= 1
			and maxAttempts <= 6,
		"invalid retry cap"
	)

	local function run(call: () -> any, deadline: number)
		assert(
			type(call) == "function" and type(deadline) == "number" and deadline == deadline,
			"invalid retry call"
		)
		local last = nil
		for attempt = 1, maxAttempts do
			if monotonicSeconds() >= deadline then
				return { status = "error", reason = "RETRY_DEADLINE", retryable = false }
			end
			local result = call()
			last = result
			if result.status ~= "error" or not result.retryable then
				return result
			end
			if attempt == maxAttempts then
				break
			end
			local sample = nextUnit()
			assert(type(sample) == "number" and sample >= 0 and sample < 1, "invalid retry jitter")
			local delay = math.min(16, 2 ^ (attempt - 1)) * (0.8 + 0.4 * sample)
			if monotonicSeconds() + delay >= deadline then
				return { status = "error", reason = "RETRY_DEADLINE", retryable = false }
			end
			waitSeconds(delay)
		end
		return last
	end

	return { run = run }
end

return RetryPolicy
