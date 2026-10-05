--!strict

-- Copy only approved Display references. Locks, production, economy, discovery,
-- operation IDs, origin/session/audit data and commercial aggregates stay private.
local ShowcaseProjection = {}
function ShowcaseProjection.fromProfile(profile: any, ownerUserId: number, production: any): any
	local result = { creatures = {}, hasMore = false } :: any
	local capacity = production.capabilities(profile).displaySlotCount
	local shown = 0
	for index, slotId in production.displaySlotIds do
		if index > capacity then
			break
		end
		local creatureId = profile.vault.displayAssignments[slotId]
		local record = (profile.collection.creaturesById or {})[creatureId]
		local producing = false
		for _, assigned in profile.vault.productionAssignments do
			producing = producing or assigned == creatureId
		end
		if
			creatureId ~= nil
			and record ~= nil
			and record.creatureInstanceId == creatureId
			and (record.ownerUserId == nil or record.ownerUserId == ownerUserId)
			and record.overflowHeld == false
			and not producing
		then
			shown += 1
			if #result.creatures == 0 then
				local variant = record.variantIdentity
				if type(variant) == "table" then
					table.insert(result.creatures, {
						creatureInstanceId = creatureId,
						speciesId = record.speciesId,
						speciesRarityId = variant.speciesRarityId,
						mutationIds = table.clone(variant.mutationIdsCanonical),
						traitIds = table.clone(variant.traitIds),
						displaySlotId = slotId,
					})
				end
			end
		end
	end
	result.hasMore = shown > #result.creatures
	return result
end
return ShowcaseProjection
