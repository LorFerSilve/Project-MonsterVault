--!strict

local SecuredCollectionProjection = {}
local MAX_IDS = 5 -- Matches the bounded VS-1 wire contract.
local MAX_ID_CHARS = 480

function SecuredCollectionProjection.fromProfile(profile: any, ownerUserId: number): any
	local candidates = {}
	for creatureId, record in profile.collection.creaturesById or {} do
		-- Legacy V1 records inherit ownership from their Player Profile key.
		if record.ownerUserId == nil or record.ownerUserId == ownerUserId then
			table.insert(candidates, {
				id = creatureId,
				revision = profile.recentOperations[record.operationId] or 0,
				securedAt = record.securedAt,
			})
		end
	end
	table.sort(candidates, function(a, b)
		if a.revision ~= b.revision then
			return a.revision > b.revision
		end
		if a.securedAt ~= b.securedAt then
			return a.securedAt > b.securedAt
		end
		return a.id < b.id
	end)
	local ids = {}
	local characters = 0
	for index = 1, math.min(#candidates, MAX_IDS) do
		local id = candidates[index].id
		if characters + #id > MAX_ID_CHARS then
			break
		end
		table.insert(ids, id)
		characters += #id
	end
	return {
		profileRevision = profile.profileRevision,
		creatureInstanceIds = ids,
		hasMore = #candidates > #ids,
	}
end

return SecuredCollectionProjection
