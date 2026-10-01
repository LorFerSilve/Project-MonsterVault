--!strict

local ProgressionService = {}
local MAX_EXACT = 9_007_199_254_740_991
local MAX_ENERGY = 1_000_000_000_000
local function integer(value: any, maximum: number): boolean
	return type(value) == "number" and value >= 0 and value <= maximum and value % 1 == 0
end
local function id(value: any, maximum: number): boolean
	return type(value) == "string" and #value > 0 and #value <= maximum
end

function ProgressionService.new(config: any)
	local definition = table.freeze(table.clone(config))
	assert(definition.upgradeId == "vault-upgrade/collection-capacity", "unbound upgrade")
	assert(definition.unlockId == "vault-upgrade/collection-capacity/1", "unbound unlock")
	assert(definition.expectedLevel == 0 and definition.targetLevel == 1, "unbound tier")
	assert(integer(definition.priceUnits, MAX_ENERGY))
	assert(
		integer(definition.quoteRevision, MAX_EXACT) and definition.quoteRevision > 0,
		"invalid price epoch"
	)
	assert(id(definition.configSnapshotId, 128))
	assert(
		definition.requiredMilestoneId == "milestone/secured-species-discovery",
		"unbound milestone"
	)
	assert(
		integer(definition.quoteLifetimeSeconds, 60) and definition.quoteLifetimeSeconds > 0,
		"invalid quote TTL"
	)
	local function level(profile: any): number
		return (profile.vault.earnedUpgradeLevels or {})[definition.upgradeId] or 0
	end
	local function validate(profile: any): string?
		local p = profile.progression
		if p.progressionSchemaVersion ~= 1 or type(p.purchasesByUnlockId) ~= "table" then
			return "INVALID_PROGRESSION_STATE"
		end
		for key, value in p do
			if
				key ~= "progressionSchemaVersion"
				and key ~= "purchasesByUnlockId"
				and (type(value) ~= "table" or next(value) ~= nil)
			then
				return "PROGRESSION_AUTHORITY_UNBOUND"
			end
		end
		for unlockId, receipt in p.purchasesByUnlockId do
			if
				unlockId ~= definition.unlockId
				or type(receipt) ~= "table"
				or not id(receipt.quoteId, 96)
				or not id(receipt.operationId, 96)
				or not integer(receipt.quoteRevision, MAX_EXACT)
				or receipt.quoteRevision < 1
				or not integer(receipt.expectedRevision, MAX_EXACT)
				or receipt.expectedRevision < 1
				or not integer(receipt.priceUnits, MAX_ENERGY)
				or not integer(receipt.timestamp, MAX_EXACT)
				or not id(receipt.configSnapshotId, 128)
				or profile.recentOperations[receipt.operationId] ~= receipt.expectedRevision + 1
				or level(profile) ~= definition.targetLevel
			then
				return "INVALID_PROGRESSION_RECEIPT"
			end
			-- Retained Energy audit must agree; receipt remains after bounded audit eviction.
			for _, record in profile.economy.recentEnergyOperations or {} do
				if
					record.operationId == receipt.operationId
					and (
						record.reasonCode ~= "vault-upgrade-purchase"
						or record.sourceOrSinkId ~= unlockId
						or record.deltaUnits ~= -receipt.priceUnits
						or record.expectedRevision ~= receipt.expectedRevision
						or record.configSnapshotId ~= receipt.configSnapshotId
						or record.timestamp ~= receipt.timestamp
					)
				then
					return "INVALID_PROGRESSION_RECEIPT"
				end
			end
		end
		return nil
	end
	local function prepare(profile: any): any
		local p = profile.progression
		if p.progressionSchemaVersion == nil then
			for _, value in p do
				if type(value) ~= "table" or next(value) ~= nil then
					return { status = "Protected", reason = "UNVERSIONED_PROGRESSION_STATE" }
				end
			end
			p.progressionSchemaVersion, p.purchasesByUnlockId = 1, {}
			return { status = "Prepared", changed = true }
		end
		local reason = validate(profile)
		return if reason
			then { status = "Protected", reason = reason }
			else { status = "Prepared", changed = false }
	end
	local function eligible(profile: any): string?
		local invalid = validate(profile)
		if invalid then
			return invalid
		end
		if level(profile) == definition.targetLevel then
			return "ALREADY_OWNED"
		end
		if level(profile) ~= definition.expectedLevel then
			return "INVALID_UNLOCK_LEVEL"
		end
		local discovered = profile.discovery.speciesById or {}
		for _, secured in discovered do
			if secured == true then
				return nil
			end
		end
		return "MISSING_MILESTONE"
	end
	return {
		prepare = prepare,
		validate = validate,
		eligible = eligible,
		owned = function(profile: any): boolean
			return level(profile) == definition.targetLevel
		end,
		definition = function(): any
			return definition
		end,
		apply = function(profile: any, receipt: any)
			assert(eligible(profile) == nil, "progression gate changed")
			profile.vault.earnedUpgradeLevels = profile.vault.earnedUpgradeLevels or {}
			profile.vault.earnedUpgradeLevels[definition.upgradeId] = definition.targetLevel
			profile.progression.purchasesByUnlockId[definition.unlockId] = table.clone(receipt)
		end,
	}
end
return ProgressionService
