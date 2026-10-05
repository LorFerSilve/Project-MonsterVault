--!strict

local ShowcaseProjectionV1 = {}

local function exact(value: any, keys: any): boolean
	if type(value) ~= "table" then
		return false
	end
	for key in value do
		if not keys[key] then
			return false
		end
	end
	return true
end
local function integer(v: any, minimum: number): boolean
	return type(v) == "number" and v >= minimum and v < 2 ^ 53 and v % 1 == 0
end
local function id(v: any, maximum: number?): boolean
	return type(v) == "string" and #v > 0 and #v <= (maximum or 128)
end
local function deadline(v: any): boolean
	return type(v) == "number" and v >= 0 and v < math.huge
end
local function array(v: any, maximum: number, valid: (any) -> boolean): boolean
	if type(v) ~= "table" or #v > maximum then
		return false
	end
	local n = 0
	for k, child in v do
		if not integer(k, 1) or k > #v or not valid(child) then
			return false
		end
		n += 1
	end
	return n == #v
end
function ShowcaseProjectionV1.validPolicyName(v: any): boolean
	return v == "Closed" or v == "Party" or v == "SameServer"
end
function ShowcaseProjectionV1.validPolicy(v: any, expected: any): boolean
	return exact(v, { audience = true })
		and ShowcaseProjectionV1.validPolicyName(v.audience)
		and integer(expected, 1)
end
function ShowcaseProjectionV1.validGrant(v: any, expected: any): boolean
	return exact(v, { targetUserId = true }) and integer(v.targetUserId, 1) and integer(expected, 1)
end
function ShowcaseProjectionV1.validRevoke(v: any, expected: any): boolean
	return exact(v, { grantId = true }) and id(v.grantId, 48) and integer(expected, 1)
end
function ShowcaseProjectionV1.validOpen(v: any, expected: any): boolean
	return exact(v, { ownerUserId = true, grantId = true })
		and integer(v.ownerUserId, 1)
		and id(v.grantId, 48)
		and expected == nil
end
function ShowcaseProjectionV1.validClose(v: any, expected: any): boolean
	return exact(v, { grantId = true }) and id(v.grantId, 48) and expected == nil
end
function ShowcaseProjectionV1.validCreature(v: any): boolean
	if
		not exact(v, {
			creatureInstanceId = true,
			speciesId = true,
			speciesRarityId = true,
			mutationIds = true,
			traitIds = true,
			displaySlotId = true,
		})
		or not id(v.creatureInstanceId)
		or not id(v.speciesId)
		or not id(v.speciesRarityId)
		or not id(v.displaySlotId, 32)
		or not array(v.mutationIds, 2, id)
		or not array(v.traitIds, 16, id)
	then
		return false
	end
	local prior = ""
	for _, mutation in v.mutationIds do
		if mutation <= prior then
			return false
		end
		prior = mutation
	end
	return true
end
local function validGrantSummary(v: any): boolean
	return exact(v, { id = true, userId = true, expiresAt = true })
		and id(v.id, 48)
		and integer(v.userId, 1)
		and deadline(v.expiresAt)
end
function ShowcaseProjectionV1.validSnapshot(v: any): boolean
	if
		not exact(v, { domain = true, revision = true, state = true })
		or not integer(v.revision, 1)
	then
		return false
	end
	local s = v.state
	if v.domain == "showcase" then
		return exact(
			s,
			{ audience = true, permissionRevision = true, visitors = true, incoming = true }
		) and ShowcaseProjectionV1.validPolicyName(s.audience) and integer(
			s.permissionRevision,
			0
		) and array(s.visitors, 2, validGrantSummary) and array(s.incoming, 2, validGrantSummary)
	end
	if
		v.domain ~= "showcaseView"
		or not exact(s, {
			mode = true,
			reason = true,
			ownerUserId = true,
			ownerDisplayName = true,
			grantId = true,
			expiresAt = true,
			creatures = true,
			hasMore = true,
		})
	then
		return false
	end
	if s.mode == "Closed" then
		return exact(s, { mode = true, reason = true })
			and (
				s.reason == "None"
				or s.reason == "Revoked"
				or s.reason == "Expired"
				or s.reason == "Left"
				or s.reason == "Disconnected"
				or s.reason == "SessionChanged"
				or s.reason == "PolicyChanged"
				or s.reason == "Unavailable"
			)
	end
	return s.mode == "ReadOnly"
		and s.reason == nil
		and integer(s.ownerUserId, 1)
		and id(s.ownerDisplayName, 64)
		and id(s.grantId, 48)
		and deadline(s.expiresAt)
		and type(s.hasMore) == "boolean"
		and array(s.creatures, 1, ShowcaseProjectionV1.validCreature)
end

return table.freeze(ShowcaseProjectionV1)
