--!strict

local PartyProjectionStore = {}

function PartyProjectionStore.new(contract: any, wire: any, presentationSeconds: (() -> number)?)
	local current: any = nil
	local clock = presentationSeconds or os.clock
	local lastTime = 0
	local function expire()
		if current == nil then
			return
		end
		local now = clock()
		local valid = type(now) == "number" and now == now and now >= lastTime and now < 2 ^ 53
		if valid then
			lastTime = now
		end
		local visible = {}
		for _, ping in current.state.pings or {} do
			if valid and now < ping.expiresAt then
				table.insert(visible, ping)
			end
		end
		if current.state.pings then
			current.state.pings = visible
		end
		if current.state.challenge and (not valid or now >= current.state.challenge.expiresAt) then
			current.state.challenge = nil -- Presentation disposal grants no lifecycle transition.
		end
	end
	return {
		snapshot = function(payload: any): string
			if not contract.validSnapshot(payload) or not wire.payload(payload) then
				return "Invalid"
			end
			if current ~= nil and payload.revision <= current.revision then
				return "Stale"
			end
			current = wire.copy(payload)
			expire()
			return "Party"
		end,
		view = function(): any
			expire()
			return if current then wire.copy(current) else nil
		end,
		nextDeadline = function(): number?
			expire()
			local deadline = math.huge
			if current and current.state.challenge then
				deadline = current.state.challenge.expiresAt
			end
			for _, ping in if current and current.state.pings then current.state.pings else {} do
				deadline = math.min(deadline, ping.expiresAt)
			end
			return if deadline < math.huge then deadline else nil
		end,
		reset = function()
			current = nil
			lastTime = 0
		end,
	}
end

return PartyProjectionStore
