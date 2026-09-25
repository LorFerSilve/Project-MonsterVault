--!strict

local RobloxProfileRepository = require("../../src/server/adapters/RobloxProfileRepository")

local function metadataAndUserIdsPreserved()
	local seenName
	local storedValue = { schemaVersion = 1 }
	local storedMetadata: any = { operatorTag = "keep" }
	local storedUsers = { 42 }
	local updates = 0
	local service = {
		GetDataStore = function(_, name)
			seenName = name
			return {
				UpdateAsync = function(_, key, callback)
					assert(key == "player/42", "canonical key")
					updates += 1
					local info = {
						GetMetadata = function()
							return storedMetadata
						end,
						GetUserIds = function()
							return storedUsers
						end,
					}
					local value, users, metadata = callback(storedValue, info)
					if value ~= nil then
						storedValue = value
						storedUsers = users
						storedMetadata = metadata
					end
					return value, info
				end,
			}
		end,
	}
	local repository = RobloxProfileRepository.new(service, true, "DEV")
	assert(seenName == "MV_DEV_PlayerProfile_v1", "TA-17 store name")
	local result = repository.update("player/42", function(value, metadata)
		metadata.mvLease = { lockId = "test" }
		return { kind = "write", value = value, metadata = metadata }
	end)
	assert(result.status == "ok" and updates == 1, "adapter writes through UpdateAsync")
	assert(
		storedUsers[1] == 42 and storedMetadata.operatorTag == "keep",
		"existing user IDs and metadata preserved"
	)
	assert(storedMetadata.mvLease.lockId == "test", "lease metadata applied")
	assert(repository.update("player/42", function()
		return { kind = "abort", reason = "SESSION_LOCKED" }
	end).status == "aborted", "nil transform abort is distinguished from missing profile")
end

local function environmentGuardAndPlatformFailure()
	local service = {
		GetDataStore = function()
			return {
				UpdateAsync = function()
					error("synthetic service failure")
				end,
			}
		end,
	}
	assert(
		not pcall(RobloxProfileRepository.new, service, true, "PROD"),
		"Studio cannot open production store"
	)
	assert(
		not pcall(RobloxProfileRepository.new, service, false, "other"),
		"unknown environment rejected"
	)
	local repository = RobloxProfileRepository.new(service, false, "STG")
	local result = repository.update("player/42", function()
		return { kind = "write", value = {}, metadata = {} }
	end)
	assert(
		result.status == "error" and result.retryable,
		"platform failure is not an empty profile"
	)
	assert(
		not pcall(repository.update, "username/Loren", function() end),
		"invalid profile key rejected"
	)
end

return {
	metadataAndUserIdsPreserved = metadataAndUserIdsPreserved,
	environmentGuardAndPlatformFailure = environmentGuardAndPlatformFailure,
}
