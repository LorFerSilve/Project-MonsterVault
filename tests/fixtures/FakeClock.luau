--!strict

local function assertFinite(value: number, label: string)
	assert(
		value == value and value ~= math.huge and value ~= -math.huge,
		label .. " must be finite"
	)
end

local function new(wallSeconds: number, monotonicSeconds: number)
	assertFinite(wallSeconds, "wallSeconds")
	assertFinite(monotonicSeconds, "monotonicSeconds")

	local wall = wallSeconds
	local monotonic = monotonicSeconds

	return {
		wallClock = {
			unixSeconds = function(): number
				return wall
			end,
		},
		monotonicClock = {
			seconds = function(): number
				return monotonic
			end,
		},
		setWall = function(value: number)
			assertFinite(value, "wallSeconds")
			wall = value
		end,
		setMonotonic = function(value: number)
			assertFinite(value, "monotonicSeconds")
			monotonic = value
		end,
		advance = function(seconds: number)
			assertFinite(seconds, "seconds")
			assert(seconds >= 0, "advance must be non-negative")
			local nextWall = wall + seconds
			local nextMonotonic = monotonic + seconds
			assertFinite(nextWall, "advanced wallSeconds")
			assertFinite(nextMonotonic, "advanced monotonicSeconds")
			wall = nextWall
			monotonic = nextMonotonic
		end,
	}
end

return {
	new = new,
}
