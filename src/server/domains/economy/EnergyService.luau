--!strict

-- Profile-only wallet primitive. Persistence/eligibility are sequenced by the
-- owning application use case; unbound reward owners cannot mint value.
local EnergyService = {}
local MAX_UNITS = 1_000_000_000_000
local MAX_EXACT = 9_007_199_254_740_991
local AUDIT_LIMIT = 32
local function integer(value: any, maximum: number): boolean
	return type(value) == "number"
		and value == value
		and value >= 0
		and value <= maximum
		and value % 1 == 0
end
local function id(value: any, maximum: number): boolean
	return type(value) == "string" and #value > 0 and #value <= maximum
end
function EnergyService.new(boundSinks: { [string]: any }?, boundWorldReward: any?)
	local sinks = table.clone(boundSinks or {})
	-- A single immutable source supplied by the authoritative world registry.
	local reward = if boundWorldReward then table.freeze(table.clone(boundWorldReward)) else nil
	if reward then
		assert(
			id(reward.id, 128)
				and id(reward.objectiveId, 128)
				and id(reward.configSnapshotId, 128)
				and integer(reward.energyUnits, MAX_UNITS)
				and reward.energyUnits > 0
				and integer(reward.completionProgress, 8)
				and reward.completionProgress > 1,
			"invalid world reward binding"
		)
	end
	local function worldReason(reason: any): boolean
		return reason == "world-objective-reward" or reason == "world-objective-transfer"
	end
	local function sinkReason(sink: string): string?
		local reason = sinks[sink]
		if reason == true then
			return "vault-upgrade-purchase"
		end
		return if reason == "vault-upgrade-purchase"
				or reason == "capture-capability-purchase"
				or reason == "access-unlock-purchase"
			then reason
			else nil
	end
	local function authorized(operation: any): boolean
		return (
			operation.reasonCode == "production-claim"
			and operation.sourceOrSinkId == "vault/production"
			and integer(operation.deltaUnits, MAX_UNITS)
		)
			or (operation.reasonCode == sinkReason(operation.sourceOrSinkId) and sinkReason(
				operation.sourceOrSinkId
			) ~= nil and integer(-operation.deltaUnits, MAX_UNITS))
			or (
				reward ~= nil
				and worldReason(operation.reasonCode)
				and operation.sourceOrSinkId == reward.id
				and operation.configSnapshotId == reward.configSnapshotId
				and integer(operation.deltaUnits, reward.energyUnits)
				and (
					operation.reasonCode == "world-objective-reward"
					or (operation.deltaUnits > 0 and id(operation.grantOperationId, 96))
				)
			)
	end
	local function validRewardReceipt(profile: any): boolean
		local r = profile.economy.worldRewardReceipt
		if r == nil then
			return true
		end
		if
			reward == nil
			or type(r) ~= "table"
			or r.sourceReference ~= reward.id
			or r.objectiveId ~= reward.objectiveId
			or r.configSnapshotId ~= reward.configSnapshotId
			or r.energyUnits ~= reward.energyUnits
			or not integer(r.initialUnits, reward.energyUnits)
			or not integer(r.remainingUnits, reward.energyUnits - r.initialUnits)
			or not id(r.operationId, 96)
			or not integer(r.timestamp, MAX_EXACT)
			or not integer(r.expectedRevision, MAX_EXACT)
			or r.expectedRevision < 1
			or profile.recentOperations[r.operationId] ~= r.expectedRevision + 1
			or r.expectedRevision >= profile.profileRevision
			or type(profile.world) ~= "table"
			or type(profile.world.objectives) ~= "table"
			or profile.world.objectives[reward.objectiveId] ~= reward.completionProgress
		then
			return false
		end
		local transferred = r.remainingUnits < reward.energyUnits - r.initialUnits
		if transferred then
			if
				not id(r.lastTransferOperationId, 96)
				or not integer(r.lastTransferRevision, MAX_EXACT)
				or r.lastTransferRevision <= r.expectedRevision
				or r.lastTransferRevision >= profile.profileRevision
				or profile.recentOperations[r.lastTransferOperationId]
					~= r.lastTransferRevision + 1
			then
				return false
			end
		elseif r.lastTransferOperationId ~= nil or r.lastTransferRevision ~= nil then
			return false
		end
		for key in r do
			if
				key ~= "sourceReference"
				and key ~= "objectiveId"
				and key ~= "configSnapshotId"
				and key ~= "energyUnits"
				and key ~= "initialUnits"
				and key ~= "remainingUnits"
				and key ~= "operationId"
				and key ~= "timestamp"
				and key ~= "expectedRevision"
				and key ~= "lastTransferOperationId"
				and key ~= "lastTransferRevision"
			then
				return false
			end
		end
		return true
	end
	local function validate(profile: any): string?
		local e = profile.economy
		if
			e.energySchemaVersion ~= 1
			or not integer(e.energyUnits, MAX_UNITS)
			or type(e.recentEnergyOperations) ~= "table"
			or #e.recentEnergyOperations > AUDIT_LIMIT
		then
			return "INVALID_ENERGY_STATE"
		end
		if not validRewardReceipt(profile) then
			return "INVALID_WORLD_REWARD_RECEIPT"
		end
		for key, value in e do
			if
				key ~= "energySchemaVersion"
				and key ~= "energyUnits"
				and key ~= "recentEnergyOperations"
				and key ~= "worldRewardReceipt"
				and (type(value) ~= "table" or next(value) ~= nil)
			then
				return "ENERGY_AUTHORITY_UNBOUND"
			end
		end
		local seen, previousRevision = {}, 0
		for index, record in e.recentEnergyOperations do
			if
				not integer(index, #e.recentEnergyOperations)
				or index < 1
				or type(record) ~= "table"
				or not id(record.operationId, 96)
				or seen[record.operationId]
				or type(record.deltaUnits) ~= "number"
				or not authorized(record)
				or not integer(record.resultingWallet, MAX_UNITS)
				or not integer(record.timestamp, MAX_EXACT)
				or not id(record.configSnapshotId, 128)
				or not integer(record.expectedRevision, MAX_EXACT)
				or record.expectedRevision <= previousRevision
				or profile.recentOperations[record.operationId] ~= record.expectedRevision + 1
				or record.resultClass ~= "Applied"
			then
				return "INVALID_ENERGY_AUDIT"
			end
			if worldReason(record.reasonCode) then
				local r = e.worldRewardReceipt
				if r == nil then
					return "INVALID_ENERGY_AUDIT"
				end
				if record.reasonCode == "world-objective-reward" then
					if
						record.operationId ~= r.operationId
						or record.deltaUnits ~= r.initialUnits
						or record.expectedRevision ~= r.expectedRevision
					then
						return "INVALID_ENERGY_AUDIT"
					end
				elseif
					record.grantOperationId ~= r.operationId
					or record.expectedRevision <= r.expectedRevision
					or record.deltaUnits > r.energyUnits - r.initialUnits
				then
					return "INVALID_ENERGY_AUDIT"
				end
			elseif record.reasonCode ~= "production-claim" then
				local receipts = profile.progression.purchasesByUnlockId or {}
				if type(receipts) ~= "table" then
					return "INVALID_ENERGY_AUDIT"
				end
				local receipt = receipts[record.sourceOrSinkId]
				if
					type(receipt) ~= "table"
					or receipt.operationId ~= record.operationId
					or receipt.priceUnits ~= -record.deltaUnits
					or receipt.expectedRevision ~= record.expectedRevision
				then
					return "INVALID_ENERGY_AUDIT"
				end
			end
			seen[record.operationId], previousRevision = true, record.expectedRevision
		end
		return nil
	end
	local function prepare(profile: any): any
		local e = profile.economy
		if e.energySchemaVersion == nil then
			-- Preserve the sole legacy DEV wallet field; never infer grants/audit.
			for key, value in e do
				if key ~= "energyUnits" and (type(value) ~= "table" or next(value) ~= nil) then
					return { status = "Protected", reason = "UNVERSIONED_ENERGY_STATE" }
				end
			end
			if e.energyUnits ~= nil and not integer(e.energyUnits, MAX_UNITS) then
				return { status = "Protected", reason = "INVALID_ENERGY_STATE" }
			end
			e.energySchemaVersion, e.energyUnits, e.recentEnergyOperations =
				1, e.energyUnits or 0, {}
			return { status = "Prepared", changed = true }
		end
		local reason = validate(profile)
		return if reason
			then { status = "Protected", reason = reason }
			else { status = "Prepared", changed = false }
	end
	local function claimReceipt(profile: any, expectedRevision: number): any
		for _, record in profile.economy.recentEnergyOperations or {} do
			if
				record.expectedRevision == expectedRevision
				and record.reasonCode == "production-claim"
			then
				return record
			end
		end
		return nil
	end
	local function apply(profile: any, operation: any): any
		local reason = validate(profile)
		if reason then
			return { status = "Protected", reason = reason }
		end
		if
			operation.reasonCode ~= "production-claim"
			and not (reward ~= nil and worldReason(operation.reasonCode) and operation.sourceOrSinkId == reward.id)
			and (
				operation.reasonCode ~= sinkReason(operation.sourceOrSinkId)
				or sinkReason(operation.sourceOrSinkId) == nil
			)
		then
			return { status = "Protected", reason = "ENERGY_AUTHORITY_UNBOUND" }
		end
		local e = profile.economy
		if profile.recentOperations[operation.operationId] ~= nil then
			return { status = "AlreadyApplied" }
		end
		if
			not id(operation.operationId, 96)
			or type(operation.deltaUnits) ~= "number"
			or not authorized(operation)
			or not integer(operation.timestamp, MAX_EXACT)
			or not id(operation.configSnapshotId, 128)
			or operation.expectedRevision ~= profile.profileRevision
			or not integer(operation.expectedRevision, MAX_EXACT)
			or operation.expectedRevision < 1
		then
			return { status = "Rejected", reason = "INVALID_ENERGY_OPERATION" }
		end
		if
			operation.reasonCode == "production-claim"
			and claimReceipt(profile, operation.expectedRevision) ~= nil
		then
			return { status = "AlreadyApplied" }
		end
		if operation.deltaUnits > MAX_UNITS - e.energyUnits then
			return { status = "Rejected", reason = "ENERGY_WALLET_FULL" }
		end
		if operation.deltaUnits < -e.energyUnits then
			return { status = "Rejected", reason = "INSUFFICIENT_ENERGY" }
		end
		if worldReason(operation.reasonCode) then
			local definition = assert(reward, "world reward source unbound")
			local r = e.worldRewardReceipt
			if operation.reasonCode == "world-objective-reward" then
				if r ~= nil then
					return { status = "AlreadyApplied" }
				end
				if
					type(profile.world) ~= "table"
					or type(profile.world.objectives) ~= "table"
					or profile.world.objectives[definition.objectiveId] ~= definition.completionProgress
					or operation.deltaUnits
						~= math.min(definition.energyUnits, MAX_UNITS - e.energyUnits)
				then
					return { status = "Rejected", reason = "INVALID_WORLD_REWARD" }
				end
			else
				if
					r == nil
					or operation.grantOperationId ~= r.operationId
					or operation.deltaUnits
						~= math.min(r.remainingUnits, MAX_UNITS - e.energyUnits)
				then
					return { status = "Rejected", reason = "INVALID_WORLD_REWARD_TRANSFER" }
				end
			end
		end
		local record = {
			operationId = operation.operationId,
			reasonCode = operation.reasonCode,
			sourceOrSinkId = operation.sourceOrSinkId,
			deltaUnits = operation.deltaUnits,
			resultingWallet = e.energyUnits + operation.deltaUnits,
			timestamp = operation.timestamp,
			configSnapshotId = operation.configSnapshotId,
			expectedRevision = operation.expectedRevision,
			resultClass = "Applied",
		}
		if operation.reasonCode == "world-objective-reward" then
			local definition = assert(reward, "world reward source unbound")
			e.worldRewardReceipt = {
				operationId = operation.operationId,
				sourceReference = definition.id,
				objectiveId = definition.objectiveId,
				energyUnits = definition.energyUnits,
				initialUnits = operation.deltaUnits,
				remainingUnits = definition.energyUnits - operation.deltaUnits,
				timestamp = operation.timestamp,
				configSnapshotId = definition.configSnapshotId,
				expectedRevision = operation.expectedRevision,
			}
		elseif operation.reasonCode == "world-objective-transfer" then
			record.grantOperationId = operation.grantOperationId
			local r = e.worldRewardReceipt
			r.remainingUnits -= operation.deltaUnits
			r.lastTransferOperationId, r.lastTransferRevision =
				operation.operationId, operation.expectedRevision
		end
		e.energyUnits = record.resultingWallet
		if #e.recentEnergyOperations == AUDIT_LIMIT then
			table.remove(e.recentEnergyOperations, 1)
		end
		table.insert(e.recentEnergyOperations, record)
		return { status = "Applied", units = record.deltaUnits }
	end
	return {
		prepare = prepare,
		validate = validate,
		apply = apply,
		claimReceipt = claimReceipt,
		maxUnits = MAX_UNITS,
		auditLimit = AUDIT_LIMIT,
	}
end
return EnergyService
