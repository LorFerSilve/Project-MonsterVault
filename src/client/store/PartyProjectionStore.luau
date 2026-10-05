--!strict

local PartyProjectionStore = {}

function PartyProjectionStore.new(contract: any, wire: any)
	local current: any = nil
	return {
		snapshot = function(payload: any): string
			if not contract.validSnapshot(payload) or not wire.payload(payload) then
				return "Invalid"
			end
			if current ~= nil and payload.revision <= current.revision then
				return "Stale"
			end
			current = wire.copy(payload)
			return "Party"
		end,
		view = function(): any
			return if current then wire.copy(current) else nil
		end,
		reset = function()
			current = nil
		end,
	}
end

return PartyProjectionStore
