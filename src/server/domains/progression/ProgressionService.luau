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

function ProgressionService.new(config: any, authorities: any?)
	local definitions, byId, maximumLevels, sinks = {}, {}, {}, {}
	local fields = {
		["vault-upgrade/collection-capacity"] = "collectionCapacity",
		["vault-upgrade/production-slots"] = "productionSlotCount",
		["vault-upgrade/display-slots"] = "displaySlotCount",
		["vault-upgrade/production-buffer"] = "bufferCapacityMilli",
		["vault-upgrade/offline-window"] = "offlineWindowSeconds",
	}
	local accessGates = {
		["access/biome-mid-a"] = { "milestone/region-mastery/starter" },
		["access/biome-mid-b"] = { "milestone/region-mastery/starter" },
		["access/biome-advanced"] = {
			"milestone/region-mastery/mid-a",
			"milestone/region-mastery/mid-b",
		},
	}
	local chances = table.clone(config.captureSuccessChanceByLevel or { [0] = 0.8, [1] = 0.85 })
	assert(chances[0] == 0.8 and chances[1] == 0.85 and #chances == 1, "unbound capture tuning")
	local readers = table.clone(authorities or {})
	local authored = config.definitions or { config }
	assert(#authored > 0 and #authored <= 16, "bounded progression catalog required")
	for index, original in authored do
		local d: any = table.clone(if index == 1 then config else original)
		d.definitions, d.captureSuccessChanceByLevel = nil, nil
		d.kind = d.kind or "Vault"
		d.effectField = d.effectField or "collectionCapacity"
		d.label = d.label or "Collection capacity +6"
		d.requiredMilestoneIds =
			table.freeze(table.clone(d.requiredMilestoneIds or { d.requiredMilestoneId }))
		d.requiredUnlockIds = table.freeze(table.clone(d.requiredUnlockIds or {}))
		assert(
			id(d.unlockId, 128) and id(d.upgradeId, 128) and byId[d.unlockId] == nil,
			"invalid unlock identity"
		)
		assert(
			integer(d.targetLevel, 8) and d.targetLevel > 0 and d.expectedLevel == d.targetLevel - 1,
			"invalid tier"
		)
		assert(
			integer(d.priceUnits, MAX_ENERGY)
				and integer(d.quoteRevision, MAX_EXACT)
				and d.quoteRevision > 0,
			"invalid price epoch"
		)
		assert(id(d.configSnapshotId, 128) and id(d.label, 160), "invalid definition")
		assert(
			integer(d.quoteLifetimeSeconds, 60) and d.quoteLifetimeSeconds > 0,
			"invalid quote TTL"
		)
		if d.kind == "Access" then
			local gates = accessGates[d.unlockId]
			assert(
				gates ~= nil
					and d.upgradeId == d.unlockId
					and d.targetLevel == 1
					and d.effectField == "accessUnlocksById",
				"unbound access"
			)
			assert(#gates == #d.requiredMilestoneIds, "unbound access gate")
			for i, gate in gates do
				assert(d.requiredMilestoneIds[i] == gate, "unbound mastery gate")
			end
			if d.unlockId == "access/biome-advanced" then
				assert(
					#d.requiredUnlockIds == 2
						and d.requiredUnlockIds[1] == "access/biome-mid-a"
						and d.requiredUnlockIds[2] == "access/biome-mid-b",
					"unbound prior access gates"
				)
			else
				assert(#d.requiredUnlockIds == 0, "unbound prior access gate")
			end
		else
			assert(#d.requiredUnlockIds == 0, "unbound prior unlock gate")
			assert(
				#d.requiredMilestoneIds == 1
					and d.requiredMilestoneIds[1] == "milestone/secured-species-discovery"
					and d.requiredMilestoneId == d.requiredMilestoneIds[1],
				"unbound milestone"
			)
			if d.kind == "Vault" then
				assert(
					fields[d.upgradeId] == d.effectField
						and d.unlockId == d.upgradeId .. "/" .. d.targetLevel,
					"unbound Vault effect"
				)
			else
				assert(
					d.kind == "Capture"
						and d.upgradeId == "capture-capability"
						and d.unlockId == "capture-capability/1"
						and d.targetLevel == 1
						and d.effectField == "captureCapabilityLevel",
					"unbound capability"
				)
			end
		end
		assert(
			d.expectedLevel == (maximumLevels[d.upgradeId] or 0),
			"noncontiguous progression ladder"
		)
		maximumLevels[d.upgradeId] = d.targetLevel
		local reason = if d.kind == "Vault"
			then "vault-upgrade-purchase"
			else if d.kind == "Capture"
				then "capture-capability-purchase"
				else "access-unlock-purchase"
		d.reasonCode = reason
		sinks[d.unlockId] = reason
		byId[d.unlockId], definitions[index] = table.freeze(d), d
	end
	local defaultId = definitions[1].unlockId
	local function definition(unlockId: string?): any
		return byId[unlockId or defaultId]
	end
	local function level(profile: any, d: any): number
		if d.kind == "Capture" then
			return profile.progression.captureCapabilityLevel or 0
		end
		if d.kind == "Access" then
			return if (profile.progression.accessUnlocksById or {})[d.unlockId] == true
				then 1
				else 0
		end
		return (profile.vault.earnedUpgradeLevels or {})[d.upgradeId] or 0
	end
	local function validate(profile: any): string?
		local p = profile.progression
		if
			p.progressionSchemaVersion ~= 1
			or type(p.purchasesByUnlockId) ~= "table"
			or (p.captureCapabilityLevel ~= nil and not integer(p.captureCapabilityLevel, 1))
			or (p.accessUnlocksById ~= nil and type(p.accessUnlocksById) ~= "table")
			or (
				profile.vault.earnedUpgradeLevels ~= nil
				and type(profile.vault.earnedUpgradeLevels) ~= "table"
			)
		then
			return "INVALID_PROGRESSION_STATE"
		end
		for key, value in p do
			if
				key ~= "progressionSchemaVersion"
				and key ~= "purchasesByUnlockId"
				and key ~= "captureCapabilityLevel"
				and key ~= "accessUnlocksById"
				and (type(value) ~= "table" or next(value) ~= nil)
			then
				return "PROGRESSION_AUTHORITY_UNBOUND"
			end
		end
		for unlockId, owned in p.accessUnlocksById or {} do
			if
				byId[unlockId] == nil
				or byId[unlockId].kind ~= "Access"
				or owned ~= true
				or p.purchasesByUnlockId[unlockId] == nil
			then
				return "INVALID_ACCESS_UNLOCK"
			end
		end
		for _, d in definitions do
			local current = level(profile, d)
			if not integer(current, maximumLevels[d.upgradeId]) then
				return "INVALID_UNLOCK_LEVEL"
			end
			-- AD-250 authorized the pre-purchase capacity tier. All newly bound
			-- effects require the permanent receipt, including each previous tier.
			if
				current >= d.targetLevel
				and d.unlockId ~= "vault-upgrade/collection-capacity/1"
				and p.purchasesByUnlockId[d.unlockId] == nil
			then
				return "UNRECEIPTED_UNLOCK"
			end
		end
		local seenOperations, seenQuotes = {}, {}
		for unlockId, receipt in p.purchasesByUnlockId do
			local d = byId[unlockId]
			if
				d == nil
				or type(receipt) ~= "table"
				or not id(receipt.quoteId, 96)
				or seenQuotes[receipt.quoteId]
				or not id(receipt.operationId, 96)
				or seenOperations[receipt.operationId]
				or not integer(receipt.quoteRevision, MAX_EXACT)
				or receipt.quoteRevision < 1
				or not integer(receipt.expectedRevision, MAX_EXACT - 1)
				or receipt.expectedRevision < 1
				or not integer(receipt.priceUnits, MAX_ENERGY)
				or not integer(receipt.timestamp, MAX_EXACT)
				or not id(receipt.configSnapshotId, 128)
				or profile.recentOperations[receipt.operationId] ~= receipt.expectedRevision + 1
				or level(profile, d) < d.targetLevel
			then
				return "INVALID_PROGRESSION_RECEIPT"
			end
			for _, record in profile.economy.recentEnergyOperations or {} do
				if
					record.operationId == receipt.operationId
					and (
						record.reasonCode ~= d.reasonCode
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
			seenOperations[receipt.operationId], seenQuotes[receipt.quoteId] = true, true
		end
		return nil
	end
	local function prepare(profile: any): any
		local p, changed = profile.progression, false
		if p.progressionSchemaVersion == nil then
			for _, value in p do
				if type(value) ~= "table" or next(value) ~= nil then
					return { status = "Protected", reason = "UNVERSIONED_PROGRESSION_STATE" }
				end
			end
			p.progressionSchemaVersion, p.purchasesByUnlockId = 1, {}
			changed = true
		end
		if p.captureCapabilityLevel == nil then
			p.captureCapabilityLevel, changed = 0, true
		end
		if p.accessUnlocksById == nil then
			p.accessUnlocksById, changed = {}, true
		end
		local reason = validate(profile)
		return if reason
			then { status = "Protected", reason = reason }
			else { status = "Prepared", changed = changed }
	end
	local function eligible(profile: any, unlockId: string?): string?
		local invalid = validate(profile)
		if invalid then
			return invalid
		end
		local d = definition(unlockId)
		if d == nil then
			return "INVALID_UNLOCK"
		end
		if level(profile, d) >= d.targetLevel then
			return "ALREADY_OWNED"
		end
		if level(profile, d) ~= d.expectedLevel then
			return "INVALID_UNLOCK_LEVEL"
		end
		for _, previous in d.requiredUnlockIds do
			if level(profile, byId[previous]) ~= 1 then
				return "MISSING_PREREQUISITE"
			end
		end
		for _, milestone in d.requiredMilestoneIds do
			if milestone == "milestone/secured-species-discovery" then
				local found = false
				for _, secured in profile.discovery.speciesById or {} do
					found = found or secured == true
				end
				if not found then
					return "MISSING_MILESTONE"
				end
			else
				if readers.mastery == nil then
					return "MILESTONE_AUTHORITY_UNBOUND"
				end
				local ok, completed = pcall(readers.mastery, profile, milestone)
				if not ok or completed ~= true then
					return "MISSING_MILESTONE"
				end
			end
		end
		return nil
	end
	return {
		prepare = prepare,
		validate = validate,
		eligible = eligible,
		definition = definition,
		definitions = table.freeze(definitions),
		boundSinks = table.freeze(sinks),
		owned = function(profile: any, unlockId: string?): boolean
			local d = definition(unlockId)
			return d ~= nil and level(profile, d) >= d.targetLevel
		end,
		hasAccess = function(profile: any, unlockId: string): boolean
			local d = definition(unlockId)
			return d ~= nil
				and d.kind == "Access"
				and validate(profile) == nil
				and level(profile, d) == 1
		end,
		captureChance = function(profile: any): number?
			return if validate(profile) == nil
				then chances[profile.progression.captureCapabilityLevel or 0]
				else nil
		end,
		apply = function(profile: any, receipt: any, unlockId: string?)
			local d = definition(unlockId)
			assert(eligible(profile, unlockId) == nil, "progression gate changed")
			if d.kind == "Vault" then
				profile.vault.earnedUpgradeLevels = profile.vault.earnedUpgradeLevels or {}
				profile.vault.earnedUpgradeLevels[d.upgradeId] = d.targetLevel
			elseif d.kind == "Capture" then
				profile.progression.captureCapabilityLevel = d.targetLevel
			else
				profile.progression.accessUnlocksById[d.unlockId] = true
			end
			profile.progression.purchasesByUnlockId[d.unlockId] = table.clone(receipt)
		end,
	}
end
return ProgressionService
