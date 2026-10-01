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
function EnergyService.new(boundSinks: { [string]: boolean }?)
	local sinks = table.clone(boundSinks or {})
	local function authorized(operation: any): boolean
		return (
			operation.reasonCode == "production-claim"
			and operation.sourceOrSinkId == "vault/production"
			and integer(operation.deltaUnits, MAX_UNITS)
		)
			or (
				operation.reasonCode == "vault-upgrade-purchase"
				and sinks[operation.sourceOrSinkId] == true
				and integer(-operation.deltaUnits, MAX_UNITS)
			)
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
		for key, value in e do
			if
				key ~= "energySchemaVersion"
				and key ~= "energyUnits"
				and key ~= "recentEnergyOperations"
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
			if record.reasonCode == "vault-upgrade-purchase" then
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
			and (
				operation.reasonCode ~= "vault-upgrade-purchase"
				or sinks[operation.sourceOrSinkId] ~= true
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
