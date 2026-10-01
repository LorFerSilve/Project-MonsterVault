--!strict

local VaultAssignmentProjection = {}
function VaultAssignmentProjection.fromProfile(profile: any, production: any, afterId: string?): any
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
	local claim = audit[#audit]
	return {
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
end
return VaultAssignmentProjection
