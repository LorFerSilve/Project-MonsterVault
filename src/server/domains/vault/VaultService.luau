--!strict

-- Vault owns usable collection capacity. The scalar progression override is the
-- existing DEV fixture contract, not a commercial entitlement or upgrade grant.
local VaultService = {}
local MAX_EXACT_INTEGER = 9_007_199_254_740_991

local function validCapacity(value: any): boolean
	return type(value) == "number"
		and value == value
		and value >= 0
		and value <= MAX_EXACT_INTEGER
		and value % 1 == 0
end

function VaultService.new(config: { baseCollectionCapacity: number })
	assert(validCapacity(config.baseCollectionCapacity), "invalid base collection capacity")
	local baseCapacity = config.baseCollectionCapacity

	local function collectionStatus(profile: any): any?
		if
			type(profile) ~= "table"
			or type(profile.collection) ~= "table"
			or type(profile.progression) ~= "table"
		then
			return nil
		end
		local capacity = profile.progression.collectionCapacity
		if capacity == nil then
			capacity = baseCapacity
		elseif not validCapacity(capacity) then
			return nil
		end
		local owned = profile.collection.creaturesById
		if owned ~= nil and type(owned) ~= "table" then
			return nil
		end
		local ordinaryUsed, overflowHeldCount = 0, 0
		for _, record in owned or {} do
			if type(record) ~= "table" or type(record.overflowHeld) ~= "boolean" then
				return nil
			end
			if record.overflowHeld then
				overflowHeldCount += 1
			else
				ordinaryUsed += 1
			end
		end
		return {
			capacity = capacity,
			ordinaryUsed = ordinaryUsed,
			overflowHeldCount = overflowHeldCount,
			canInitiate = ordinaryUsed < capacity and overflowHeldCount == 0,
		}
	end

	return { collectionStatus = collectionStatus }
end

return VaultService
