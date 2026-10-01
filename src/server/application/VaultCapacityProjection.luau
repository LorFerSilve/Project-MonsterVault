--!strict

local VaultCapacityProjection = {}
function VaultCapacityProjection.fromProfile(profile: any, vault: any, afterId: string?): any
	local status = assert(vault.collectionStatus(profile), "validated Vault profile required")
	local candidates = {}
	for id, record in profile.collection.creaturesById or {} do
		if record.overflowHeld and (afterId == nil or id > afterId) then
			table.insert(candidates, id)
		end
	end
	table.sort(candidates)
	local page, chars = {}, 0
	for index = 1, math.min(#candidates, 5) do
		local id = candidates[index]
		if chars + #id > 480 then
			break
		end
		table.insert(page, id)
		chars += #id
	end
	return {
		domain = "vault",
		revision = profile.profileRevision,
		state = {
			capacity = status.capacity,
			ordinaryUsed = status.ordinaryUsed,
			overflowHeldCount = status.overflowHeldCount,
			components = status.components,
			overflowCreatureInstanceIds = page,
			hasMore = #candidates > #page,
		},
	}
end
return VaultCapacityProjection
