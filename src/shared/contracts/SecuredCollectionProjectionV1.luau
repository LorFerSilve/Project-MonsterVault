--!strict

-- VS-1 exposes a bounded recent ownership summary. The profile remains the
-- authority; this projection cannot initiate or confirm a mutation.
local SecuredCollectionProjectionV1 = {}
local MAX_IDS = 5
local MAX_ID_CHARS = 480 -- Leaves room under WireValidation's conservative 4096-byte budget.

local function revision(value: any): boolean
	return type(value) == "number" and value >= 0 and value % 1 == 0 and value < math.huge
end

local function id(value: any): boolean
	return type(value) == "string" and #value > 0 and #value <= 128
end

function SecuredCollectionProjectionV1.validState(value: any): boolean
	if
		type(value) ~= "table"
		or not revision(value.profileRevision)
		or type(value.hasMore) ~= "boolean"
	then
		return false
	end
	for key in value do
		if key ~= "profileRevision" and key ~= "creatureInstanceIds" and key ~= "hasMore" then
			return false
		end
	end
	local ids = value.creatureInstanceIds
	if type(ids) ~= "table" or #ids > MAX_IDS then
		return false
	end
	local seen = {}
	local count = 0
	local characters = 0
	for index, creatureId in ids do
		count += 1
		if type(creatureId) == "string" then
			characters += #creatureId
		end
		if
			type(index) ~= "number"
			or index % 1 ~= 0
			or index < 1
			or index > #ids
			or not id(creatureId)
			or seen[creatureId]
		then
			return false
		end
		seen[creatureId] = true
	end
	return count == #ids and characters <= MAX_ID_CHARS
end

function SecuredCollectionProjectionV1.validSnapshot(value: any): boolean
	if
		type(value) ~= "table"
		or value.domain ~= "securedCollection"
		or not revision(value.revision)
		or not SecuredCollectionProjectionV1.validState(value.state)
		or value.state.profileRevision ~= value.revision
	then
		return false
	end
	for key in value do
		if key ~= "domain" and key ~= "revision" and key ~= "state" then
			return false
		end
	end
	return true
end

SecuredCollectionProjectionV1.maxIds = MAX_IDS
SecuredCollectionProjectionV1.maxIdChars = MAX_ID_CHARS
return table.freeze(SecuredCollectionProjectionV1)
