--!strict

local VaultAssignmentProjectionV1 = {}
local function integer(value: any, maximum: number): boolean
	return type(value) == "number"
		and value == value
		and value >= 0
		and value <= maximum
		and value % 1 == 0
end
local function id(value: any): boolean
	return type(value) == "string" and #value > 0 and #value <= 128
end
local function ids(value: any, maximum: number): boolean
	if type(value) ~= "table" or #value > maximum then
		return false
	end
	local count = 0
	for k, v in value do
		if not integer(k, #value) or k < 1 or not id(v) then
			return false
		end
		count += 1
	end
	return count == #value
end
function VaultAssignmentProjectionV1.validAssignment(payload: any, revision: any): boolean
	if
		type(payload) ~= "table"
		or not integer(revision, 9_007_199_254_740_991)
		or revision < 1
		or not id(payload.slotId)
		or (payload.creatureInstanceId ~= nil and not id(payload.creatureInstanceId))
	then
		return false
	end
	for key in payload do
		if key ~= "slotId" and key ~= "creatureInstanceId" then
			return false
		end
	end
	return true
end
function VaultAssignmentProjectionV1.validClaim(payload: any, revision: any): boolean
	if
		type(payload) ~= "table"
		or payload.claimScope ~= "All"
		or not integer(revision, 9_007_199_254_740_991)
		or revision < 1
	then
		return false
	end
	for key in payload do
		if key ~= "claimScope" then
			return false
		end
	end
	return true
end
function VaultAssignmentProjectionV1.validSnapshot(payload: any): boolean
	if
		type(payload) ~= "table"
		or payload.domain ~= "vaultAssignments"
		or not integer(payload.revision, 9_007_199_254_740_991)
		or payload.revision < 1
		or type(payload.state) ~= "table"
	then
		return false
	end
	for key in payload do
		if key ~= "domain" and key ~= "revision" and key ~= "state" then
			return false
		end
	end
	local state = payload.state
	for key, maximum in
		{
			bufferMilli = 1_000_000_000_000_000,
			bufferCapacityMilli = 1_000_000_000_000_000,
			productionSlotCount = 8,
			displaySlotCount = 24,
			offlineWindowSeconds = 43200,
			offlineCreditedMilli = 1_000_000_000_000_000,
			energyUnits = 1_000_000_000_000,
			claimExpectedRevision = 9_007_199_254_740_991,
			claimUnits = 1_000_000_000_000,
		}
	do
		if not integer(state[key], maximum :: number) then
			return false
		end
	end
	if
		type(state.hasMore) ~= "boolean"
		or type(state.creatures) ~= "table"
		or #state.creatures > 2
	then
		return false
	end
	local previous = ""
	for index, row in state.creatures do
		if
			not integer(index, #state.creatures)
			or index < 1
			or type(row) ~= "table"
			or not id(row.creatureInstanceId)
			or row.creatureInstanceId <= previous
			or type(row.overflowHeld) ~= "boolean"
			or type(row.locked) ~= "boolean"
		then
			return false
		end
		for _, slot in { row.productionSlotId, row.displaySlotId } do
			if not id(slot) then
				return false
			end
		end
		if row.overflowHeld and (row.productionSlotId ~= nil or row.displaySlotId ~= nil) then
			return false
		end
		if
			row.speciesId ~= nil
			or row.rarityId ~= nil
			or row.mutationIds ~= nil
			or row.traitIds ~= nil
		then
			if
				not id(row.speciesId)
				or not id(row.rarityId)
				or not ids(row.mutationIds, 2)
				or not ids(row.traitIds, 16)
			then
				return false
			end
			local prior = ""
			for _, mutation in row.mutationIds do
				if mutation <= prior then
					return false
				end
				prior = mutation
			end
		end
		for key in row do
			if
				key ~= "creatureInstanceId"
				and key ~= "overflowHeld"
				and key ~= "locked"
				and key ~= "productionSlotId"
				and key ~= "displaySlotId"
				and key ~= "speciesId"
				and key ~= "rarityId"
				and key ~= "mutationIds"
				and key ~= "traitIds"
			then
				return false
			end
		end
		previous = row.creatureInstanceId
	end
	if state.hasMore and #state.creatures == 0 then
		return false
	end
	local display = state.displayCard
	if display ~= nil then
		if
			type(display) ~= "table"
			or not id(display.creatureInstanceId)
			or not id(display.speciesId)
			or not id(display.speciesRarityId)
			or not id(display.displaySlotId)
			or #display.displaySlotId > 32
			or not ids(display.mutationIds, 2)
			or not ids(display.traitIds, 16)
		then
			return false
		end
		local prior = ""
		for _, mutation in display.mutationIds do
			if mutation <= prior then
				return false
			end
			prior = mutation
		end
		for key in display do
			if
				key ~= "creatureInstanceId"
				and key ~= "speciesId"
				and key ~= "speciesRarityId"
				and key ~= "mutationIds"
				and key ~= "traitIds"
				and key ~= "displaySlotId"
			then
				return false
			end
		end
	end
	for key in state do
		if
			key ~= "bufferMilli"
			and key ~= "bufferCapacityMilli"
			and key ~= "productionSlotCount"
			and key ~= "displaySlotCount"
			and key ~= "offlineWindowSeconds"
			and key ~= "offlineCreditedMilli"
			and key ~= "energyUnits"
			and key ~= "claimExpectedRevision"
			and key ~= "claimUnits"
			and key ~= "creatures"
			and key ~= "displayCard"
			and key ~= "hasMore"
		then
			return false
		end
	end
	return true
end
return table.freeze(VaultAssignmentProjectionV1)
