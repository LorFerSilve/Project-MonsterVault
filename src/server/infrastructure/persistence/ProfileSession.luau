--!strict

-- One server-owned profile session. All DataStore operations run through its
-- injected single-writer queue and UpdateAsync repository.
local LEASE_SECONDS = 300
local LEASE_MARGIN_SECONDS = 30
local ProfileSession = {}

local function copy(value: any, seen: { [any]: any }?): any
	if type(value) ~= "table" then
		return value
	end
	local memo = seen or {}
	if memo[value] then
		return memo[value]
	end
	local result = {}
	memo[value] = result
	for key, child in value do
		result[copy(key, memo)] = copy(child, memo)
	end
	return result
end

local function validLease(lease: any): boolean
	return type(lease) == "table"
		and type(lease.lockId) == "string"
		and lease.lockId ~= ""
		and type(lease.jobId) == "string"
		and type(lease.epoch) == "number"
		and lease.epoch >= 1
		and lease.epoch % 1 == 0
		and type(lease.expiresAt) == "number"
		and lease.expiresAt == lease.expiresAt
		and lease.expiresAt < math.huge
end

function ProfileSession.new(options: {
	userId: number,
	lockId: string,
	jobId: string,
	repository: any,
	schema: any,
	queue: any,
	retry: any,
	unixSeconds: () -> number,
	monotonicSeconds: () -> number,
})
	assert(
		type(options.userId) == "number" and options.userId >= 1 and options.userId % 1 == 0,
		"invalid user ID"
	)
	assert(
		type(options.lockId) == "string"
			and options.lockId ~= ""
			and type(options.jobId) == "string"
			and options.jobId ~= "",
		"session identity required"
	)
	local key = "player/" .. tostring(options.userId)
	local state = "NoSession"
	local profile: any = nil
	local persistedRevision: number? = nil
	local leaseEpoch: number? = nil
	local leaseExpiresAt = 0
	local dirty = false
	local mutating = false
	local closingRequested = false

	local function deadline(seconds: number): number
		return options.monotonicSeconds() + seconds
	end

	local function queued(priority: string, operation: () -> any): any
		local queuedResult = options.queue.run(priority, operation)
		if queuedResult.status ~= "ok" then
			return {
				status = "error",
				reason = "WRITER_" .. string.upper(queuedResult.status),
				retryable = false,
			}
		end
		return queuedResult.value
	end

	local function ownLease(metadata: { [string]: any }): boolean
		local lease = metadata.mvLease
		return validLease(lease) and lease.lockId == options.lockId and lease.epoch == leaseEpoch
	end

	local function classifyFailure(result: any)
		if result.status == "aborted" and result.reason == "OWNERSHIP_LOST" then
			state = "OwnershipLost"
		elseif
			(result.status == "aborted" and result.reason == "REVISION_MISMATCH")
			or options.unixSeconds() >= leaseExpiresAt - LEASE_MARGIN_SECONDS
		then
			state = "PersistenceAtRisk"
		end
	end

	local function acquire(): any
		assert(state == "NoSession", "profile acquisition already attempted")
		state = "Acquiring"
		local now = options.unixSeconds()
		local result = queued("critical", function()
			return options.retry.run(function()
				return options.repository.update(
					key,
					function(current: any, metadata: { [string]: any }): any
						local prior = metadata.mvLease
						if prior ~= nil and not validLease(prior) then
							return { kind = "abort", reason = "INVALID_LEASE" }
						end
						if
							prior ~= nil
							and prior.lockId ~= options.lockId
							and prior.expiresAt > now
						then
							return { kind = "abort", reason = "SESSION_LOCKED" }
						end
						local candidate
						if current == nil then
							candidate = options.schema.default(now)
							candidate.profileRevision = 1
							candidate.lastSuccessfulSaveAt = now
						else
							local migrated = options.schema.migrate(current)
							if migrated == nil then
								return { kind = "abort", reason = "PROFILE_INVALID" }
							end
							candidate = copy(migrated)
						end
						local nextMetadata = copy(metadata)
						nextMetadata.mvLease = {
							lockId = options.lockId,
							jobId = options.jobId,
							epoch = if prior then prior.epoch + 1 else 1,
							expiresAt = now + LEASE_SECONDS,
						}
						return { kind = "write", value = candidate, metadata = nextMetadata }
					end
				)
			end, deadline(25))
		end)
		if result.status ~= "ok" then
			state = if result.status == "aborted" and result.reason == "SESSION_LOCKED"
				then "SessionLocked"
				else "ProtectedLoadFailure"
			return { status = state, reason = result.reason }
		end
		local valid = options.schema.validate(result.value)
		if
			not valid
			or not validLease(result.metadata.mvLease)
			or result.metadata.mvLease.lockId ~= options.lockId
		then
			state = "ProtectedLoadFailure"
			return { status = state, reason = "INVALID_ACQUIRE_RESULT" }
		end
		profile = copy(result.value)
		persistedRevision = profile.profileRevision
		leaseEpoch = result.metadata.mvLease.epoch
		leaseExpiresAt = result.metadata.mvLease.expiresAt
		state = "Ready"
		return { status = "Ready", profileRevision = persistedRevision }
	end

	local function save(release: boolean, isCritical: boolean, absoluteDeadline: number): any
		if state ~= "Ready" and state ~= "PersistenceAtRisk" and state ~= "Releasing" then
			return { status = state, reason = "NOT_WRITABLE" }
		end
		local now = options.unixSeconds()
		local expectedRevision = persistedRevision :: number
		local candidate = copy(profile)
		if dirty then
			candidate.profileRevision = expectedRevision + 1
			candidate.lastSuccessfulSaveAt = now
		end
		local valid = options.schema.validate(candidate)
		if not valid then
			state = "PersistenceAtRisk"
			return { status = state, reason = "INVALID_BUFFER" }
		end
		local result = queued(if isCritical then "critical" else "routine", function()
			return options.retry.run(function()
				return options.repository.update(
					key,
					function(current: any, metadata: { [string]: any }): any
						if not ownLease(metadata) then
							return { kind = "abort", reason = "OWNERSHIP_LOST" }
						end
						if
							type(current) ~= "table"
							or current.profileRevision ~= expectedRevision
						then
							return { kind = "abort", reason = "REVISION_MISMATCH" }
						end
						local nextMetadata = copy(metadata)
						if release then
							nextMetadata.mvLease = nil
						else
							nextMetadata.mvLease.expiresAt = now + LEASE_SECONDS
						end
						return { kind = "write", value = candidate, metadata = nextMetadata }
					end
				)
			end, absoluteDeadline)
		end)
		if result.status ~= "ok" then
			classifyFailure(result)
			return { status = state, reason = result.reason }
		end
		profile = copy(result.value)
		persistedRevision = profile.profileRevision
		dirty = false
		if release then
			state = "Closed"
			profile = nil
			leaseEpoch = nil
		else
			leaseExpiresAt = now + LEASE_SECONDS
			state = "Ready"
		end
		return { status = state, profileRevision = persistedRevision }
	end

	local function checkpoint(operationId: string, mutate: (any) -> ()): any
		if closingRequested then
			return { status = "Closing", reason = "SESSION_RELEASING" }
		end
		if state ~= "Ready" then
			return { status = state, reason = "NOT_READY" }
		end
		assert(
			type(operationId) == "string" and #operationId > 0 and #operationId <= 96,
			"invalid operation ID"
		)
		assert(type(mutate) == "function", "checkpoint mutation required")
		if profile.recentOperations[operationId] ~= nil then
			return {
				status = "AlreadyCommitted",
				profileRevision = profile.recentOperations[operationId],
			}
		end
		local candidate = copy(profile)
		local ok = pcall(mutate, candidate)
		if
			not ok
			or candidate.profileRevision ~= persistedRevision
			or candidate.schemaVersion ~= 1
			or candidate.createdAt ~= profile.createdAt
			or candidate.lastSuccessfulSaveAt ~= profile.lastSuccessfulSaveAt
		then
			return { status = "Rejected", reason = "INVALID_MUTATION" }
		end
		if type(candidate.recentOperations) ~= "table" then
			return { status = "Rejected", reason = "INVALID_MUTATION" }
		end
		for id, revision in profile.recentOperations do
			if candidate.recentOperations[id] ~= revision then
				return { status = "Rejected", reason = "INVALID_MUTATION" }
			end
		end
		for id in candidate.recentOperations do
			if profile.recentOperations[id] == nil then
				return { status = "Rejected", reason = "INVALID_MUTATION" }
			end
		end
		candidate.profileRevision = (persistedRevision :: number) + 1
		candidate.lastSuccessfulSaveAt = options.unixSeconds()
		candidate.recentOperations[operationId] = candidate.profileRevision
		if not options.schema.validate(candidate) then
			return { status = "Rejected", reason = "INVALID_MUTATION" }
		end
		local now = options.unixSeconds()
		local expectedRevision = persistedRevision :: number
		local result = queued("critical", function()
			return options.retry.run(function()
				return options.repository.update(
					key,
					function(current: any, metadata: { [string]: any }): any
						if not ownLease(metadata) then
							return { kind = "abort", reason = "OWNERSHIP_LOST" }
						end
						if
							type(current) == "table"
							and type(current.recentOperations) == "table"
							and current.recentOperations[operationId] ~= nil
						then
							return { kind = "abort", reason = "OUTCOME_UNKNOWN" }
						end
						if
							type(current) ~= "table"
							or current.profileRevision ~= expectedRevision
						then
							return { kind = "abort", reason = "REVISION_MISMATCH" }
						end
						local nextMetadata = copy(metadata)
						nextMetadata.mvLease.expiresAt = now + LEASE_SECONDS
						return { kind = "write", value = candidate, metadata = nextMetadata }
					end
				)
			end, deadline(25))
		end)
		if result.status ~= "ok" then
			classifyFailure(result)
			if result.reason == "OUTCOME_UNKNOWN" or result.status == "error" then
				state = "PersistenceAtRisk"
				return { status = "OutcomeUnknown", reason = result.reason }
			end
			return { status = state, reason = result.reason }
		end
		profile = copy(result.value)
		persistedRevision = profile.profileRevision
		leaseExpiresAt = now + LEASE_SECONDS
		dirty = false
		return { status = "Committed", profileRevision = persistedRevision }
	end

	local function bufferSettings(mutate: (any) -> ()): any
		if closingRequested then
			return { status = "Closing", reason = "SESSION_RELEASING" }
		end
		if state ~= "Ready" then
			return { status = state, reason = "NOT_READY" }
		end
		local candidate = copy(profile)
		local ok = pcall(mutate, candidate.settings)
		if not ok or not options.schema.validate(candidate) then
			return { status = "Rejected", reason = "INVALID_SETTINGS" }
		end
		profile = candidate
		dirty = true
		return { status = "Buffered" }
	end

	local function renew(): any
		return save(false, false, deadline(25))
	end

	local function release(absoluteDeadline: number): any
		if state == "Closed" then
			return { status = "Closed" }
		end
		if state ~= "Ready" and state ~= "PersistenceAtRisk" and state ~= "Releasing" then
			return { status = state, reason = "NOT_OWNED" }
		end
		state = "Releasing"
		return save(true, true, absoluteDeadline)
	end

	local function serialized(operation: () -> any): any
		if mutating then
			return { status = "Busy", reason = "SESSION_WRITER_ACTIVE" }
		end
		mutating = true
		local ok, result = pcall(operation :: () -> any)
		mutating = false
		if not ok then
			state = "PersistenceAtRisk"
			return { status = state, reason = "SESSION_OPERATION_ERROR" }
		end
		return result
	end

	return {
		acquire = function()
			return serialized(acquire)
		end,
		checkpoint = function(operationId: string, mutate: (any) -> ())
			if closingRequested then
				return { status = "Closing", reason = "SESSION_RELEASING" }
			end
			return serialized(function()
				return checkpoint(operationId, mutate)
			end)
		end,
		bufferSettings = function(mutate: (any) -> ())
			if closingRequested then
				return { status = "Closing", reason = "SESSION_RELEASING" }
			end
			return serialized(function()
				return bufferSettings(mutate)
			end)
		end,
		renew = function()
			if closingRequested then
				return { status = "Closing", reason = "SESSION_RELEASING" }
			end
			return serialized(renew)
		end,
		release = function(absoluteDeadline: number)
			closingRequested = true
			return serialized(function()
				return release(absoluteDeadline)
			end)
		end,
		state = function(): string
			return state
		end,
		snapshot = function()
			return copy(profile)
		end,
		leaseExpiresAt = function(): number
			return leaseExpiresAt
		end,
		isDirty = function(): boolean
			return dirty
		end,
	}
end

return ProfileSession
