--!strict

local VaultAssignmentProjection = {}
function VaultAssignmentProjection.fromProfile(
	profile: any,
	production: any,
	afterId: string?,
	presentationFits: ((any) -> boolean)?,
	displayCard: any?
): any
	local ids, rows = {}, {}
	for id in profile.collection.creaturesById or {} do
		if afterId == nil or id > afterId then
			table.insert(ids, id)
		end
	end
	table.sort(ids)
	local chars = 0
	for index = 1, math.min(2, #ids) do
		local id = ids[index]
		local record = profile.collection.creaturesById[id]
		local row = {
			creatureInstanceId = id,
			overflowHeld = record.overflowHeld,
			locked = record.locked,
		} :: any
		local rowChars = #id
		for _, kind in { "production", "display" } do
			for slot, assigned in profile.vault[kind .. "Assignments"] do
				if assigned == id then
					row[kind .. "SlotId"] = slot
					rowChars += #slot
				end
			end
		end
		if chars + rowChars > 240 then
			break
		end
		table.insert(rows, row)
		chars += rowChars
	end
	local caps = production.capabilities(profile)
	local audit = profile.economy.recentEnergyOperations or {}
	local claim = nil
	for index = #audit, 1, -1 do
		if audit[index].reasonCode == "production-claim" then
			claim = audit[index]
			break
		end
	end
	local payload: any = {
		domain = "vaultAssignments",
		revision = profile.profileRevision,
		state = {
			energyUnits = profile.economy.energyUnits or 0,
			claimExpectedRevision = if claim then claim.expectedRevision else 0,
			claimUnits = if claim then claim.deltaUnits else 0,
			bufferMilli = profile.vault.productionBufferMilli,
			bufferCapacityMilli = caps.bufferCapacityMilli,
			productionSlotCount = caps.productionSlotCount,
			displaySlotCount = caps.displaySlotCount,
			offlineWindowSeconds = caps.offlineWindowSeconds,
			offlineCreditedMilli = if profile.vault.lastOfflineSettlement
				then profile.vault.lastOfflineSettlement.creditedMilli
				else 0,
			creatures = rows,
			hasMore = #ids > #rows,
		},
	}
	-- Optional intrinsic facts for owner cards. Keep assignment/claim state when
	-- a presentation would exceed the existing wire budget. No profile tables
	-- or authority-bearing creature fields are shared through this readback.
	if presentationFits then
		-- The existing Showcase filter supplies one owner-bound display card.
		-- It is independent of the management cursor and has budget priority.
		if displayCard then
			payload.state.displayCard = {
				creatureInstanceId = displayCard.creatureInstanceId,
				speciesId = displayCard.speciesId,
				speciesRarityId = displayCard.speciesRarityId,
				mutationIds = table.clone(displayCard.mutationIds),
				traitIds = table.clone(displayCard.traitIds),
				displaySlotId = displayCard.displaySlotId,
			}
			if not presentationFits(payload) then
				payload.state.displayCard = nil
			end
		end
		local presentationRows = table.clone(rows)
		table.sort(presentationRows, function(a, b)
			local aDisplay, bDisplay = a.displaySlotId ~= nil, b.displaySlotId ~= nil
			if aDisplay ~= bDisplay then
				return aDisplay
			end
			return a.creatureInstanceId < b.creatureInstanceId
		end)
		for _, row in presentationRows do
			local record = profile.collection.creaturesById[row.creatureInstanceId]
			local variant = record.variantIdentity
			if type(variant) == "table" then
				row.speciesId = record.speciesId
				row.rarityId = variant.speciesRarityId
				row.mutationIds = table.clone(variant.mutationIdsCanonical)
				row.traitIds = table.clone(variant.traitIds)
				if not presentationFits(payload) then
					row.speciesId, row.rarityId, row.mutationIds, row.traitIds = nil, nil, nil, nil
				end
			end
		end
	end
	return payload
end
return VaultAssignmentProjection
