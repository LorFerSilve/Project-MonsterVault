--!strict

local ReplayWindow = {}

function ReplayWindow.new(monotonicSeconds: () -> number, WireValidation: any)
	local byUser: { [number]: any } = {}

	local function inspect(
		userId: number,
		requestId: string,
		routeId: string,
		payload: any,
		expectedRevision: number?
	): (string, any?)
		local now = monotonicSeconds()
		local user = byUser[userId]
		if user == nil then
			user = { entries = {}, order = {} }
			byUser[userId] = user
		end
		local entry = user.entries[requestId]
		if entry ~= nil and now - entry.at <= 120 then
			if
				entry.routeId ~= routeId
				or entry.expectedRevision ~= expectedRevision
				or not WireValidation.equal(entry.payload, payload)
			then
				return "Misuse", nil
			end
			return "Duplicate", entry.result
		end
		if entry ~= nil then
			user.entries[requestId] = nil
			for index = #user.order, 1, -1 do
				if user.order[index] == requestId then
					table.remove(user.order, index)
				end
			end
		end
		while #user.order >= 128 do
			local oldest = table.remove(user.order, 1)
			if user.entries[oldest] ~= nil then
				user.entries[oldest] = nil
			end
		end
		user.entries[requestId] = {
			at = now,
			routeId = routeId,
			payload = WireValidation.copy(payload),
			expectedRevision = expectedRevision,
			result = nil,
		}
		table.insert(user.order, requestId)
		return "Fresh", nil
	end

	return {
		inspect = inspect,
		complete = function(userId: number, requestId: string, result: any)
			local user = byUser[userId]
			if user ~= nil and user.entries[requestId] ~= nil then
				user.entries[requestId].result = WireValidation.copy(result)
			end
		end,
		forget = function(userId: number)
			byUser[userId] = nil
		end,
	}
end

return ReplayWindow
