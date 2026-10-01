--!strict

-- Pure profile arithmetic. No clock, network, persistence or client authority.
local VaultProductionService = {}
local MAX_EXACT = 9_007_199_254_740_991
local MAX_BUFFER = 1_000_000_000_000_000

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
local function nonempty(value: any): boolean
	return value ~= nil and (type(value) ~= "table" or next(value) ~= nil)
end

function VaultProductionService.new(config: any)
	local productionSlots, displaySlots =
		table.clone(config.productionSlotIds), table.clone(config.displaySlotIds)
	local allowance = config.crashRecoveryAllowanceSeconds
	assert(integer(allowance, 180) and allowance == 180, "TA-14 crash allowance required")
	local function slots(list: any, maximum: number): any
		assert(#list > 0 and #list <= maximum, "slot registry bound")
		local indices = {}
		for index, slot in list do
			assert(
				integer(index, #list)
					and index > 0
					and id(slot)
					and #slot <= 32
					and indices[slot] == nil,
				"invalid slot registry"
			)
			indices[slot] = index
		end
		return indices
	end
	local productionIndices, displayIndices = slots(productionSlots, 8), slots(displaySlots, 24)
	assert(
		type(config.epochs) == "table" and #config.epochs > 0 and #config.epochs <= 128,
		"bounded epoch history required"
	)
	local epochs, byId = {}, {}
	for index, authored in config.epochs do
		local epoch: any = table.clone(authored)
		epoch.ratesMilliBySpeciesId = table.clone(authored.ratesMilliBySpeciesId)
		assert(
			integer(index, #config.epochs)
				and index > 0
				and id(epoch.epochId)
				and id(epoch.contentSnapshotId)
				and byId[epoch.epochId] == nil
				and integer(epoch.effectiveUnixSeconds, MAX_EXACT)
				and (
					index == 1
					or epoch.effectiveUnixSeconds > epochs[index - 1].effectiveUnixSeconds
				),
			"invalid epoch identity"
		)
		assert(
			integer(epoch.productionSlotCount, #productionSlots)
				and integer(epoch.displaySlotCount, #displaySlots)
				and integer(epoch.bufferCapacityMilli, MAX_BUFFER)
				and integer(epoch.offlineWindowSeconds, 43200),
			"invalid production capabilities"
		)
		local maximumRate, count = 0, 0
		for speciesId, rate in epoch.ratesMilliBySpeciesId do
			count += 1
			assert(
				id(speciesId) and integer(rate, MAX_EXACT) and count <= 2048,
				"invalid species production rate"
			)
			maximumRate = math.max(maximumRate, rate)
		end
		assert(
			maximumRate
				<= math.floor(
					MAX_EXACT
						/ math.max(1, #productionSlots * (epoch.offlineWindowSeconds + allowance))
				),
			"inexact rate/window product"
		)
		epochs[index], byId[epoch.epochId] = epoch, index
	end
	local function epochIndexAt(now: number): number?
		for index = #epochs, 1, -1 do
			if epochs[index].effectiveUnixSeconds <= now then
				return index
			end
		end
		return nil
	end
	local function validate(profile: any): string?
		local v, owned = profile.vault, profile.collection.creaturesById or {}
		-- Future role and grant owners must explicitly bind their compatibility.
		for _, value in
			{
				profile.commerce.productionGrants,
				profile.commerce.displayCapacityEntitlements,
				v.temporaryProductionGrants,
				v.temporaryDisplayCapacityGrants,
				profile.collection.activeRolesByCreatureId,
			}
		do
			if nonempty(value) then
				return "PRODUCTION_AUTHORITY_UNBOUND"
			end
		end
		if
			v.productionSchemaVersion ~= 1
			or not integer(v.productionBufferMilli, MAX_BUFFER)
			or not integer(v.productionCursorUnixSeconds, MAX_EXACT)
			or (v.lastPresenceBoundary ~= "Active" and v.lastPresenceBoundary ~= "CleanOffline")
		then
			return "INVALID_PRODUCTION_STATE"
		end
		local index = byId[v.productionRateEpochId]
		if index == nil or epochIndexAt(v.productionCursorUnixSeconds) ~= index then
			return "PRODUCTION_HISTORY_UNAVAILABLE"
		end
		local epoch = epochs[index]
		for _, kind in { "production", "display" } do
			local assignments = v[kind .. "Assignments"]
			local indices = if kind == "production" then productionIndices else displayIndices
			local count = if kind == "production"
				then epoch.productionSlotCount
				else epoch.displaySlotCount
			if type(assignments) ~= "table" then
				return "INVALID_ASSIGNMENTS"
			end
			local seen = {}
			for slot, creatureId in assignments do
				local record = owned[creatureId]
				if
					indices[slot] == nil
					or indices[slot] > count
					or not id(creatureId)
					or seen[creatureId]
					or record == nil
					or record.creatureInstanceId ~= creatureId
					or record.overflowHeld
					or (record.activeRoleId ~= nil)
				then
					return "INVALID_ASSIGNMENT_REFERENCE"
				end
				if
					kind == "production"
					and epoch.ratesMilliBySpeciesId[record.speciesId] == nil
				then
					return "PRODUCTION_PROFILE_UNAVAILABLE"
				end
				seen[creatureId] = true
			end
		end
		return nil
	end

	local function settle(profile: any, boundary: number, mode: string): any
		if not integer(boundary, MAX_EXACT) then
			return { status = "Protected", reason = "INVALID_PRODUCTION_CLOCK" }
		end
		local reason = validate(profile)
		if reason ~= nil then
			return { status = "Protected", reason = reason }
		end
		assert(
			mode == "Online" or mode == "CleanOffline" or mode == "CrashRecovery",
			"invalid presence mode"
		)
		local v = profile.vault
		local cursor = v.productionCursorUnixSeconds
		if boundary < cursor then
			return {
				status = "Prepared",
				changed = false,
				creditedMilli = 0,
				eligibleSeconds = 0,
				clockRegressed = true,
				mode = mode,
			}
		end
		local first, last = byId[v.productionRateEpochId], epochIndexAt(boundary)
		if last == nil then
			return { status = "Protected", reason = "PRODUCTION_HISTORY_UNAVAILABLE" }
		end
		local elapsed = boundary - cursor
		if mode ~= "Online" then
			elapsed = math.min(
				elapsed,
				epochs[first].offlineWindowSeconds
					+ (if mode == "CrashRecovery" then allowance else 0)
			)
		end
		local creditEnd = cursor + elapsed
		local production, display =
			table.clone(v.productionAssignments), table.clone(v.displayAssignments)
		local buffer, before = v.productionBufferMilli, v.productionBufferMilli
		local assignmentsChanged = false
		for index = first, last do
			local epoch = epochs[index]
			for slot in production do
				if productionIndices[slot] > epoch.productionSlotCount then
					production[slot] = nil
					assignmentsChanged = true
				end
			end
			for slot in display do
				if displayIndices[slot] > epoch.displaySlotCount then
					display[slot] = nil
					assignmentsChanged = true
				end
			end
			local rate = 0
			for _, creatureId in production do
				local contribution =
					epoch.ratesMilliBySpeciesId[profile.collection.creaturesById[creatureId].speciesId]
				if contribution == nil then
					return { status = "Protected", reason = "PRODUCTION_HISTORY_UNAVAILABLE" }
				end
				rate += contribution
			end
			local startAt = math.max(cursor, epoch.effectiveUnixSeconds)
			local endAt = math.min(
				creditEnd,
				if epochs[index + 1] then epochs[index + 1].effectiveUnixSeconds else boundary
			)
			local seconds = math.max(0, endAt - startAt)
			local headroom = math.max(0, epoch.bufferCapacityMilli - buffer)
			-- Saturate before multiplying an arbitrarily long online interval.
			local credit = if rate == 0
				then 0
				else if seconds > math.floor(MAX_EXACT / rate)
					then headroom
					else math.min(headroom, rate * seconds)
			buffer += credit
		end
		v.productionAssignments, v.displayAssignments = production, display
		v.productionBufferMilli, v.productionCursorUnixSeconds, v.productionRateEpochId =
			buffer, boundary, epochs[last].epochId
		return {
			status = "Prepared",
			changed = boundary ~= cursor or buffer ~= before or assignmentsChanged,
			creditedMilli = buffer - before,
			eligibleSeconds = elapsed,
			clockRegressed = false,
			mode = mode,
		}
	end

	local function prepareLoad(profile: any, now: number): any
		local v = profile.vault
		if v.productionSchemaVersion == nil then
			for _, key in
				{
					"productionAssignments",
					"displayAssignments",
					"productionBufferMilli",
					"productionCursorUnixSeconds",
					"productionRateEpochId",
					"lastPresenceBoundary",
				}
			do
				if nonempty(v[key]) and v[key] ~= 0 then
					return { status = "Protected", reason = "UNVERSIONED_PRODUCTION_STATE" }
				end
			end
			local index = epochIndexAt(now)
			if index == nil then
				return { status = "Protected", reason = "PRODUCTION_HISTORY_UNAVAILABLE" }
			end
			v.productionSchemaVersion, v.productionAssignments, v.displayAssignments = 1, {}, {}
			v.productionBufferMilli, v.productionCursorUnixSeconds, v.productionRateEpochId =
				0, now, epochs[index].epochId
			v.lastPresenceBoundary = "Active"
			local reason = validate(profile)
			return if reason
				then { status = "Protected", reason = reason }
				else { status = "Prepared", changed = true }
		end
		local result = settle(
			profile,
			now,
			if v.lastPresenceBoundary == "CleanOffline" then "CleanOffline" else "CrashRecovery"
		)
		if result.status ~= "Prepared" then
			return result
		end
		v.lastPresenceBoundary = "Active"
		v.lastOfflineSettlement = {
			creditedMilli = result.creditedMilli,
			eligibleSeconds = result.eligibleSeconds,
			mode = result.mode,
			clockRegressed = result.clockRegressed,
		}
		result.changed = true -- Presence/recap is persisted with lease acquisition.
		return result
	end
	local function assign(
		profile: any,
		kind: string,
		slot: string,
		creatureId: string?,
		boundary: number
	): any
		if kind ~= "production" and kind ~= "display" then
			return { status = "Rejected", reason = "ASSIGNMENT_KIND" }
		end
		local settled = settle(profile, boundary, "Online")
		if settled.status ~= "Prepared" then
			return settled
		end
		local v, owned = profile.vault, profile.collection.creaturesById or {}
		local epoch = epochs[byId[v.productionRateEpochId]]
		local indices = if kind == "production" then productionIndices else displayIndices
		local count = if kind == "production"
			then epoch.productionSlotCount
			else epoch.displaySlotCount
		if indices[slot] == nil or indices[slot] > count then
			return { status = "Rejected", reason = "SLOT_LOCKED" }
		end
		local assignments = v[kind .. "Assignments"]
		if creatureId ~= nil then
			local record = owned[creatureId]
			if record == nil then
				return { status = "Rejected", reason = "OWNERSHIP" }
			end
			if record.overflowHeld then
				return { status = "Rejected", reason = "OVERFLOW_HELD" }
			end
			if record.activeRoleId ~= nil then
				return { status = "Rejected", reason = "ROLE_CONFLICT" }
			end
			if kind == "production" and epoch.ratesMilliBySpeciesId[record.speciesId] == nil then
				return { status = "Rejected", reason = "PRODUCTION_PROFILE_UNAVAILABLE" }
			end
			for otherSlot, assigned in assignments do
				if assigned == creatureId and otherSlot ~= slot then
					return { status = "Rejected", reason = "ALREADY_ASSIGNED" }
				end
			end
		end
		assignments[slot] = creatureId
		return { status = "Assigned", settlement = settled }
	end
	return {
		validate = validate,
		settle = settle,
		prepareLoad = prepareLoad,
		assign = assign,
		capabilities = function(profile: any): any
			local epoch = table.clone(epochs[byId[profile.vault.productionRateEpochId]])
			epoch.ratesMilliBySpeciesId = table.clone(epoch.ratesMilliBySpeciesId)
			return epoch
		end,
		productionSlotIds = table.freeze(productionSlots),
		displaySlotIds = table.freeze(displaySlots),
	}
end
return VaultProductionService
