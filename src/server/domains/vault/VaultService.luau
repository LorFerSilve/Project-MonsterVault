--!strict

-- Only server composition supplies capacity definitions/verified source readers.
-- No capacity quantity is accepted from a client command.
local VaultService = {}
local MAX_CAPACITY = 2048 -- TA-14 hard owned-record bound.
local LEGACY_SOURCE = "migration/imp9-dev-capacity-v1"

local function quantity(value: any): boolean
	return type(value) == "number"
		and value == value
		and value >= 0
		and value <= MAX_CAPACITY
		and value % 1 == 0
end

local function nonempty(value: any): boolean
	return value ~= nil and (type(value) ~= "table" or next(value) ~= nil)
end

function VaultService.new(config: any, authorities: any?)
	assert(quantity(config.baseCollectionCapacity), "invalid base collection capacity")
	local tiers = table.clone(config.earnedCollectionCapacityByLevel or { [0] = 0 })
	local upgradeId = config.collectionCapacityUpgradeId or "vault-upgrade/collection-capacity"
	local commercialDefinitions = table.clone(config.commercialCapacityById or {})
	local temporaryDefinitions = table.clone(config.temporaryCapacityById or {})
	assert(tiers[0] == 0, "capacity level zero required")
	for level, amount in tiers do
		assert(quantity(level) and quantity(amount), "invalid capacity tier")
	end
	local baseCapacity = config.baseCollectionCapacity
	local readers = table.clone(authorities or {})
	for _, definitions in { commercialDefinitions, temporaryDefinitions } do
		for id, units in definitions do
			assert(
				type(id) == "string" and #id > 0 and #id <= 128 and quantity(units),
				"invalid capacity source definition"
			)
		end
	end

	local function sourceCapacity(profile: any, kind: string): (number?, string?)
		local reader = readers[kind]
		local persisted = if kind == "commercial"
			then profile.commerce.collectionCapacityEntitlements
			else profile.vault.temporaryCollectionCapacityGrants
		if reader == nil then
			if nonempty(persisted) then
				return nil, "CAPACITY_AUTHORITY_UNBOUND"
			end
			return 0, nil
		end
		local ok, sources = pcall(reader, profile)
		if not ok or type(sources) ~= "table" then
			return nil, "INVALID_CAPACITY_AUTHORITY"
		end
		local definitions = if kind == "commercial"
			then commercialDefinitions
			else temporaryDefinitions
		local total = 0
		for id, units in sources do
			if
				type(id) ~= "string"
				or type(definitions) ~= "table"
				or definitions[id] ~= units
				or not quantity(units)
			then
				return nil, "UNAUTHORIZED_CAPACITY_SOURCE"
			end
			total += units
			if total > MAX_CAPACITY then
				return nil, "CAPACITY_LIMIT"
			end
		end
		return total, nil
	end

	local function collectionStatus(profile: any): (any?, string?)
		if
			type(profile) ~= "table"
			or type(profile.collection) ~= "table"
			or type(profile.progression) ~= "table"
			or type(profile.vault) ~= "table"
			or type(profile.commerce) ~= "table"
		then
			return nil, "INVALID_CAPACITY_PROFILE"
		end
		local base = baseCapacity
		local legacy = profile.progression.collectionCapacity
		local imported = profile.vault.capacityBase
		if legacy ~= nil then
			if
				imported ~= nil
				or profile.vault.capacitySchemaVersion ~= nil
				or not quantity(legacy)
			then
				return nil, "INVALID_LEGACY_CAPACITY"
			end
			base = legacy
		elseif imported ~= nil then
			if
				type(imported) ~= "table"
				or imported.sourceId ~= LEGACY_SOURCE
				or not quantity(imported.units)
			then
				return nil, "INVALID_CAPACITY_BASE"
			end
			base = imported.units
		end
		local levels = if profile.vault.earnedUpgradeLevels == nil
			then {}
			else profile.vault.earnedUpgradeLevels
		if type(levels) ~= "table" then
			return nil, "INVALID_CAPACITY_UPGRADES"
		end
		for id in levels do
			if id ~= upgradeId then
				return nil, "UNKNOWN_UPGRADE_ID"
			end
		end
		local level = levels[upgradeId]
		if level == nil then
			level = 0
		end
		local earned = if quantity(level) then tiers[level] else nil
		if earned == nil then
			return nil, "UNKNOWN_UPGRADE_LEVEL"
		end
		local commercial, commercialReason = sourceCapacity(profile, "commercial")
		if commercial == nil then
			return nil, commercialReason
		end
		local temporary, temporaryReason = sourceCapacity(profile, "temporary")
		if temporary == nil then
			return nil, temporaryReason
		end
		local capacity = base + earned + commercial + temporary
		if capacity > MAX_CAPACITY then
			return nil, "CAPACITY_LIMIT"
		end
		local owned = profile.collection.creaturesById
		if owned ~= nil and type(owned) ~= "table" then
			return nil, "INVALID_COLLECTION"
		end
		local ordinaryUsed, overflowHeldCount = 0, 0
		for _, record in owned or {} do
			if type(record) ~= "table" or type(record.overflowHeld) ~= "boolean" then
				return nil, "INVALID_COLLECTION"
			end
			if record.overflowHeld then
				overflowHeldCount += 1
			else
				ordinaryUsed += 1
			end
		end
		if ordinaryUsed + overflowHeldCount > MAX_CAPACITY then
			return nil, "COLLECTION_LIMIT"
		end
		return {
			capacity = capacity,
			ordinaryUsed = ordinaryUsed,
			overflowHeldCount = overflowHeldCount,
			components = {
				base = base,
				earned = earned,
				commercial = commercial,
				temporary = temporary,
			},
			canInitiate = ordinaryUsed < capacity and overflowHeldCount == 0,
		},
			nil
	end

	local function prepare(profile: any, settleProduction: ((any) -> (boolean, boolean))?): any
		local status, reason = collectionStatus(profile)
		if status == nil then
			return { status = "Protected", reason = reason }
		end
		local owned = profile.collection.creaturesById or {}
		local vault = profile.vault
		if vault.capacitySchemaVersion ~= nil and vault.capacitySchemaVersion ~= 1 then
			return { status = "Protected", reason = "UNKNOWN_CAPACITY_SCHEMA" }
		end
		local production = if vault.productionAssignments == nil
			then {}
			else vault.productionAssignments
		local display = if vault.displayAssignments == nil then {} else vault.displayAssignments
		if type(production) ~= "table" or type(display) ~= "table" then
			return { status = "Protected", reason = "INVALID_ASSIGNMENTS" }
		end
		for slot, id in production do
			if
				type(slot) ~= "string"
				or type(id) ~= "string"
				or owned[id] == nil
				or owned[id].overflowHeld
			then
				return { status = "Protected", reason = "INVALID_PRODUCTION_REFERENCE" }
			end
		end
		for slot, id in display do
			if type(slot) ~= "string" or type(id) ~= "string" then
				return { status = "Protected", reason = "INVALID_DISPLAY_REFERENCE" }
			end
		end
		local priority = if profile.collection.capacityPriority == nil
			then {}
			else profile.collection.capacityPriority
		if type(priority) ~= "table" or #priority > MAX_CAPACITY then
			return { status = "Protected", reason = "INVALID_CAPACITY_PRIORITY" }
		end
		local seen, ordered = {}, {}
		for index, id in priority do
			if
				type(index) ~= "number"
				or index % 1 ~= 0
				or index < 1
				or index > #priority
				or type(id) ~= "string"
				or owned[id] == nil
				or seen[id]
			then
				return { status = "Protected", reason = "INVALID_CAPACITY_PRIORITY" }
			end
			seen[id] = true
			if not owned[id].overflowHeld then
				table.insert(ordered, id)
			end
		end
		local slots, activeSeen = {}, {}
		for slot, id in production do
			if activeSeen[id] then
				return { status = "Protected", reason = "DUPLICATE_PRODUCTION_REFERENCE" }
			end
			activeSeen[id] = true
			table.insert(slots, slot)
		end
		table.sort(slots)
		for _, slot in slots do
			local id = production[slot]
			if not seen[id] then
				seen[id] = true
				table.insert(ordered, id)
			end
		end
		local remaining = {}
		for id, record in owned do
			if not record.overflowHeld and not seen[id] then
				local sequence = record.securedSequence
					or profile.recentOperations[record.operationId]
				if status.ordinaryUsed > status.capacity and sequence == nil then
					return { status = "Protected", reason = "ACQUISITION_ORDER_UNAVAILABLE" }
				end
				table.insert(remaining, { id = id, sequence = sequence or 0 })
			end
		end
		table.sort(remaining, function(a, b)
			return if a.sequence == b.sequence then a.id < b.id else a.sequence < b.sequence
		end)
		for _, item in remaining do
			table.insert(ordered, item.id)
		end
		local hasProduction = next(production) ~= nil
			or nonempty(vault.productionRateEpochId)
			or (vault.productionBufferMilli ~= nil and vault.productionBufferMilli ~= 0)
			or vault.productionCursorUnixSeconds ~= nil
		local changed = false
		if hasProduction then
			if settleProduction == nil then
				return { status = "Protected", reason = "PRODUCTION_SETTLEMENT_REQUIRED" }
			end
			local settled, productionChanged = settleProduction(profile)
			if not settled then
				return { status = "Protected", reason = "PRODUCTION_SETTLEMENT_REQUIRED" }
			end
			changed = productionChanged == true
		end
		if vault.capacitySchemaVersion == nil then
			vault.capacitySchemaVersion = 1
			changed = true
		end
		if profile.progression.collectionCapacity ~= nil then
			vault.capacityBase =
				{ units = profile.progression.collectionCapacity, sourceId = LEGACY_SOURCE }
			profile.progression.collectionCapacity = nil
			changed = true
		end
		for _, record in owned do
			if
				record.securedSequence == nil
				and profile.recentOperations[record.operationId] ~= nil
			then
				record.securedSequence = profile.recentOperations[record.operationId]
				changed = true
			end
		end
		local overflowed = {}
		for index = status.capacity + 1, #ordered do
			local id = ordered[index]
			owned[id].overflowHeld = true
			table.insert(overflowed, id)
			for slot, assigned in production do
				if assigned == id then
					production[slot] = nil
				end
			end
			changed = true
		end
		-- Display references have no economic value; clear stale/overflow copies losslessly.
		local displaySlots, displayed = {}, {}
		for slot in display do
			table.insert(displaySlots, slot)
		end
		table.sort(displaySlots)
		for _, slot in displaySlots do
			local id = display[slot]
			if owned[id] == nil or owned[id].overflowHeld or displayed[id] then
				display[slot] = nil
				changed = true
			else
				displayed[id] = true
			end
		end
		return { status = "Prepared", changed = changed, overflowedCreatureInstanceIds = overflowed }
	end

	local function resolveOverflow(
		profile: any,
		id: string,
		settleProduction: ((any) -> (boolean, boolean))?
	): any
		local prepared = prepare(profile, settleProduction)
		if prepared.status ~= "Prepared" then
			return prepared
		end
		local record = (profile.collection.creaturesById or {})[id]
		if record == nil then
			return { status = "Rejected", reason = "OWNERSHIP" }
		end
		if not record.overflowHeld then
			return { status = "AlreadyStored" }
		end
		local status = collectionStatus(profile)
		if status == nil or status.ordinaryUsed >= status.capacity then
			return { status = "Rejected", reason = "CAPACITY_FULL" }
		end
		record.overflowHeld = false
		return { status = "Resolved" }
	end

	return {
		collectionStatus = collectionStatus,
		prepare = prepare,
		resolveOverflow = resolveOverflow,
	}
end

return VaultService
