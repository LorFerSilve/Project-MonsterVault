--!strict

local MODULUS = 2147483647
local MULTIPLIER = 48271

local function assertSample(value: number)
	assert(value == value and value >= 0 and value <= 1, "sample must be in [0, 1]")
end

local function fromSequence(samples: { number })
	local copy = table.clone(samples)
	for _, sample in copy do
		assertSample(sample)
	end

	local index = 0
	return {
		nextUnit = function(): number
			assert(index < #copy, "random sequence exhausted")
			index += 1
			return copy[index]
		end,
		draws = function(): number
			return index
		end,
		remaining = function(): number
			return #copy - index
		end,
	}
end

local function fromSeed(seed: number)
	assert(
		seed == seed and seed % 1 == 0 and seed >= 1 and seed < MODULUS,
		"seed must be an integer in [1, 2147483646]"
	)
	local state = seed
	local drawCount = 0
	return {
		nextUnit = function(): number
			-- The product stays below 2^53, so Luau number arithmetic is exact here.
			state = (state * MULTIPLIER) % MODULUS
			drawCount += 1
			return state / MODULUS
		end,
		draws = function(): number
			return drawCount
		end,
	}
end

return {
	fromSequence = fromSequence,
	fromSeed = fromSeed,
}
