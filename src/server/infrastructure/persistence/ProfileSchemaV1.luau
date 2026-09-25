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
