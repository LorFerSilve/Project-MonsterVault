--!strict

-- V1 reserves domain-owned aggregates without inventing later domain schemas.
-- Unknown root keys, non-serializable values and unsupported versions fail closed.
local ProfileSchemaV1 = {}
local BUCKETS = {
	"collection",
	"discovery",
	"vault",
	"economy",
	"progression",
	"events",
	"trading",
	"commerce",
	"settings",
}
local ROOT_KEYS = {
	schemaVersion = true,
	profileRevision = true,
	createdAt = true,
	lastSuccessfulSaveAt = true,
	recentOperations = true,
}
for _, bucket in BUCKETS do
	ROOT_KEYS[bucket] = true
end

local function finiteInteger(value: any, minimum: number): boolean
	return type(value) == "number"
		and value == value
		and value < math.huge
		and value % 1 == 0
		and value >= minimum
end

local function validId(value: any): boolean
	return type(value) == "string" and #value > 0 and #value <= 128
end

local function validIdArray(value: any, limit: number, sorted: boolean): boolean
	if type(value) ~= "table" or #value > limit then
		return false
	end
	local previous = ""
	for index, id in value do
		if
			type(index) ~= "number"
			or index % 1 ~= 0
			or index < 1
			or index > #value
			or not validId(id)
		then
			return false
		end
		if sorted and id <= previous then
			return false
		end
		previous = id
	end
	return true
end

local function validCreature(id: any, record: any): boolean
	if
		not validId(id)
		or type(record) ~= "table"
		or record.creatureInstanceId ~= id
		or (record.ownerUserId ~= nil and not finiteInteger(record.ownerUserId, 1))
		or not validId(record.speciesId)
		or not validId(record.operationId)
		or not finiteInteger(record.securedAt, 0)
		or type(record.locked) ~= "boolean"
		or type(record.overflowHeld) ~= "boolean"
		or (record.securedSequence ~= nil and not finiteInteger(record.securedSequence, 1))
		or type(record.origin) ~= "table"
		or not validId(record.origin.spawnContextId)
		or not validId(record.origin.contentSnapshotId)
	then
		return false
	end
	local variant = record.variantIdentity
	return type(variant) == "table"
		and validId(variant.speciesRarityId)
		and validId(variant.variantSignature)
		and variant.contentSnapshotId == record.origin.contentSnapshotId
		and variant.spawnContextId == record.origin.spawnContextId
		and validIdArray(variant.mutationIdsCanonical, 2, true)
		and validIdArray(variant.traitIds, 16, false)
		and validIdArray(variant.protectedVariantReasons, 16, false)
end

local function serializable(
	value: any,
	depth: number,
	seen: { [any]: boolean },
	budget: { remaining: number }
): boolean
	if depth > 12 then
		return false
	end
	local kind = type(value)
	if kind == "string" then
		budget.remaining -= 6 * #value + 2
		return #value <= 4096 and budget.remaining >= 0
	elseif kind == "number" then
		budget.remaining -= 32
		return value == value and math.abs(value) < math.huge and budget.remaining >= 0
	elseif kind == "boolean" then
		budget.remaining -= 5
		return budget.remaining >= 0
	elseif kind ~= "table" or seen[value] then
		return false
	end
	seen[value] = true
	budget.remaining -= 2
	local entries = 0
	local arrayCount = 0
	local highestIndex = 0
	local hasStringKey = false
	for key, child in value do
		entries += 1
		if type(key) == "string" then
			budget.remaining -= 6 * #key + 4
		else
			budget.remaining -= 36
		end
		if
			entries > 4096
			or budget.remaining < 0
			or (type(key) ~= "string" and not finiteInteger(key, 1))
			or not serializable(child, depth + 1, seen, budget)
		then
			seen[value] = nil
			return false
		end
		if type(key) == "number" then
			arrayCount += 1
			highestIndex = math.max(highestIndex, key)
		else
			hasStringKey = true
		end
	end
	seen[value] = nil
	if arrayCount > 0 and (hasStringKey or highestIndex ~= arrayCount) then
		return false
	end
	return true
end

function ProfileSchemaV1.default(now: number)
	assert(finiteInteger(now, 0), "invalid profile creation time")
	local profile: { [string]: any } = {
		schemaVersion = 1,
		profileRevision = 0,
		createdAt = now,
		lastSuccessfulSaveAt = 0,
		recentOperations = {},
	}
	for _, bucket in BUCKETS do
		profile[bucket] = {}
	end
	return profile
end

function ProfileSchemaV1.validate(profile: any): (boolean, string?)
	if type(profile) ~= "table" then
		return false, "profile_not_table"
	end
	if profile.schemaVersion ~= 1 then
		return false, "unsupported_schema"
	end
	if
		not finiteInteger(profile.profileRevision, 0)
		or not finiteInteger(profile.createdAt, 0)
		or not finiteInteger(profile.lastSuccessfulSaveAt, 0)
	then
		return false, "invalid_profile_header"
	end
	for key in profile do
		if not ROOT_KEYS[key] then
			return false, "unknown_root_field"
		end
	end
	for _, bucket in BUCKETS do
		if type(profile[bucket]) ~= "table" then
			return false, "invalid_domain_bucket"
		end
	end
	-- The legacy DEV capacity scalar is optional, but must never silently fall
	-- back to base capacity after corrupt or inexact persisted data.
	local capacity = profile.progression.collectionCapacity
	if capacity ~= nil and (not finiteInteger(capacity, 0) or capacity > 9_007_199_254_740_991) then
		return false, "invalid_collection_capacity"
	end
	local vault = profile.vault
	local energy = profile.economy
	if
		energy.energyUnits ~= nil
		and (not finiteInteger(energy.energyUnits, 0) or energy.energyUnits > 1_000_000_000_000)
	then
		return false, "invalid_energy_wallet"
	end
	if energy.energySchemaVersion ~= nil then
		if
			energy.energySchemaVersion ~= 1
			or energy.energyUnits == nil
			or type(energy.recentEnergyOperations) ~= "table"
			or #energy.recentEnergyOperations > 32
		then
			return false, "invalid_energy_state"
		end
	end
	if vault.productionSchemaVersion ~= nil then
		if
			vault.productionSchemaVersion ~= 1
			or not finiteInteger(vault.productionBufferMilli, 0)
			or vault.productionBufferMilli > 1_000_000_000_000_000
			or not finiteInteger(vault.productionCursorUnixSeconds, 0)
			or vault.productionCursorUnixSeconds > 9_007_199_254_740_991
			or not validId(vault.productionRateEpochId)
			or (
				vault.lastPresenceBoundary ~= "Active"
				and vault.lastPresenceBoundary ~= "CleanOffline"
			)
		then
			return false, "invalid_production_state"
		end
		for _, assignments in { vault.productionAssignments, vault.displayAssignments } do
			if type(assignments) ~= "table" then
				return false, "invalid_assignments"
			end
			local count = 0
			for slot, creatureId in assignments do
				count += 1
				if count > 24 or not validId(slot) or not validId(creatureId) then
					return false, "invalid_assignments"
				end
			end
		end
		if vault.lastOfflineSettlement ~= nil then
			local recap = vault.lastOfflineSettlement
			if
				type(recap) ~= "table"
				or not finiteInteger(recap.creditedMilli, 0)
				or recap.creditedMilli > 1_000_000_000_000_000
				or not finiteInteger(recap.eligibleSeconds, 0)
				or recap.eligibleSeconds > 43380
				or (recap.mode ~= "CleanOffline" and recap.mode ~= "CrashRecovery")
				or type(recap.clockRegressed) ~= "boolean"
			then
				return false, "invalid_production_recap"
			end
		end
	end
	if vault.capacitySchemaVersion ~= nil and vault.capacitySchemaVersion ~= 1 then
		return false, "invalid_capacity_schema"
	end
	if vault.capacityBase ~= nil then
		if
			type(vault.capacityBase) ~= "table"
			or vault.capacityBase.sourceId ~= "migration/imp9-dev-capacity-v1"
			or not finiteInteger(vault.capacityBase.units, 0)
			or vault.capacityBase.units > 2048
		then
			return false, "invalid_capacity_base"
		end
		for key in vault.capacityBase do
			if key ~= "units" and key ~= "sourceId" then
				return false, "invalid_capacity_base"
			end
		end
	end
	if capacity ~= nil and (vault.capacityBase ~= nil or vault.capacitySchemaVersion ~= nil) then
		return false, "conflicting_capacity_sources"
	end
	if vault.earnedUpgradeLevels ~= nil then
		if type(vault.earnedUpgradeLevels) ~= "table" then
			return false, "invalid_upgrade_levels"
		end
		for id, level in vault.earnedUpgradeLevels do
			if not validId(id) or not finiteInteger(level, 0) or level > 2048 then
				return false, "invalid_upgrade_levels"
			end
		end
	end
	if
		profile.collection.capacityPriority ~= nil
		and not validIdArray(profile.collection.capacityPriority, 2048, false)
	then
		return false, "invalid_capacity_priority"
	end
	local owned = profile.collection.creaturesById
	if owned ~= nil then
		if type(owned) ~= "table" then
			return false, "invalid_collection"
		end
		local ownedCount = 0
		for id, record in owned do
			ownedCount += 1
			if ownedCount > 2048 then
				return false, "collection_limit"
			end
			if not validCreature(id, record) then
				return false, "invalid_creature_record"
			end
		end
	end
	if type(profile.recentOperations) ~= "table" then
		return false, "invalid_operation_ledger"
	end
	local count = 0
	for id, revision in profile.recentOperations do
		count += 1
		if count > 512 or type(id) ~= "string" or #id > 96 or not finiteInteger(revision, 1) then
			return false, "invalid_operation_ledger"
		end
	end
	-- Conservative JSON upper bound (including worst-case escapes) stays below
	-- TA-14's 1.5 MiB hard profile limit before any DataStore write.
	if not serializable(profile, 0, {}, { remaining = 1_500_000 }) then
		return false, "nonserializable_profile"
	end
	return true, nil
end

-- There is no released pre-V1 profile. Keep the migration boundary explicit;
-- do not invent a legacy shape and silently reinterpret unknown player data.
function ProfileSchemaV1.migrate(profile: any): (any?, string?)
	if type(profile) ~= "table" or not finiteInteger(profile.schemaVersion, 0) then
		return nil, "missing_schema_version"
	end
	if profile.schemaVersion > 1 then
		return nil, "newer_schema"
	end
	if profile.schemaVersion < 1 then
		return nil, "unsupported_legacy_schema"
	end
	local valid, reason = ProfileSchemaV1.validate(profile)
	return if valid then profile else nil, reason
end

return ProfileSchemaV1
