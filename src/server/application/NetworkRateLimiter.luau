--!strict

-- Conservative TA-14 baseline: 8 msg/s sustained, <=16 burst globally.
local NetworkRateLimiter = {}

local CLASSES = table.freeze({
	A = { capacity = 6, refill = 3 },
	B = { capacity = 8, refill = 4 },
	C = { capacity = 4, refill = 2 },
	D = { capacity = 2, refill = 1 },
})

function NetworkRateLimiter.new(monotonicSeconds: () -> number)
	local byUser: { [number]: any } = {}

	local function charge(bucket: any, capacity: number, refill: number, now: number): boolean
		bucket.tokens = math.min(capacity, bucket.tokens + math.max(0, now - bucket.at) * refill)
		bucket.at = now
		if bucket.tokens < 1 then
			return false
		end
		bucket.tokens -= 1
		return true
	end

	local function userAt(userId: number, now: number): any
		local user = byUser[userId]
		if user == nil then
			user = { global = { tokens = 16, at = now }, routes = {} }
			byUser[userId] = user
		end
		return user
	end

	local function allowGlobal(userId: number): boolean
		local now = monotonicSeconds()
		return charge(userAt(userId, now).global, 16, 8, now)
	end

	local function allowRoute(userId: number, routeId: string, class: string): boolean
		local limits = CLASSES[class]
		assert(limits ~= nil, "invalid rate class")
		local now = monotonicSeconds()
		local user = userAt(userId, now)
		local route = user.routes[routeId]
		if route == nil then
			route = { tokens = limits.capacity, at = now }
			user.routes[routeId] = route
		end
		return charge(route, limits.capacity, limits.refill, now)
	end

	local function allow(userId: number, routeId: string, class: string): boolean
		return allowGlobal(userId) and allowRoute(userId, routeId, class)
	end

	return {
		allow = allow,
		allowGlobal = allowGlobal,
		allowRoute = allowRoute,
		forget = function(userId: number)
			byUser[userId] = nil
		end,
	}
end

return NetworkRateLimiter
