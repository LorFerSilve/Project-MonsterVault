--!strict

-- Engine adapter only. The DataStore is opened when new() is explicitly called.
-- Callers must supply a verified environment binding; Studio is DEV-only.
local RobloxProfileRepository = {}

function RobloxProfileRepository.new(dataStoreService: any, isStudio: boolean, environment: string)
	assert(
		environment == "DEV" or environment == "STG" or environment == "PROD",
		"invalid profile environment"
	)
	assert(not isStudio or environment == "DEV", "Studio may access only DEV profiles")
	local storeName = "MV_" .. environment .. "_PlayerProfile_v1"
	local store = dataStoreService:GetDataStore(storeName)

	local function update(key: string, transform: (any, { [string]: any }) -> any): any
		assert(string.match(key, "^player/[1-9]%d*$") ~= nil, "invalid profile key")
		local abortReason: string? = nil
		local ok, value, info = pcall(function()
			return store:UpdateAsync(key, function(currentValue, keyInfo)
				local metadata = if keyInfo then keyInfo:GetMetadata() else {}
				local userIds = if keyInfo then keyInfo:GetUserIds() else {}
				local decision = transform(currentValue, metadata)
				if decision.kind == "abort" then
					abortReason = decision.reason
					return nil
				end
				assert(
					decision.kind == "write" and decision.value ~= nil,
					"invalid profile write decision"
				)
				abortReason = nil
				return decision.value, userIds, decision.metadata
			end)
		end)
		if not ok then
			return { status = "error", reason = "DATASTORE_ERROR", retryable = true }
		end
		if abortReason ~= nil then
			return { status = "aborted", reason = abortReason }
		end
		if value == nil then
			return { status = "error", reason = "EMPTY_UPDATE_RESULT", retryable = false }
		end
		return { status = "ok", value = value, metadata = if info then info:GetMetadata() else {} }
	end

	return { update = update, storeName = storeName }
end

return RobloxProfileRepository
