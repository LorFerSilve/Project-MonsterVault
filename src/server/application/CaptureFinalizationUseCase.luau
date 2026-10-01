--!strict

-- A P2 mutation owns the only secured collection entry. Operation identity is
-- minted at provisional capture, not from a network request or secure trigger.
local CaptureFinalizationUseCase = {}

local function creatures(profile: any): any
	return profile.collection.creaturesById or {}
end

function CaptureFinalizationUseCase.new(vault: any)
	assert(type(vault.collectionStatus) == "function", "Vault capacity authority required")

	local function canInitiate(profile: any): boolean
		local status = vault.collectionStatus(profile)
		return status ~= nil and status.canInitiate
	end

	local function finalize(session: any, payload: any): any
		if session == nil or type(payload) ~= "table" or type(session.userId) ~= "function" then
			return { status = "Rejected" }
		end
		if payload.ownerUserId ~= session.userId() then
			return { status = "Rejected", reason = "OWNER_MISMATCH" }
		end
		local op = payload.operationId
		local id = payload.creatureInstanceId
		if type(op) ~= "string" or #op < 1 or #op > 96 or type(id) ~= "string" or id == "" then
			return { status = "Rejected" }
		end
		local snapshot = session.snapshot()
		if type(snapshot) ~= "table" then
			return { status = "Unavailable" }
		end
		local existing = creatures(snapshot)[id]
		if existing ~= nil then
			return {
				status = if existing.operationId == op then "Secured" else "Rejected",
				creatureInstanceId = id,
				profileRevision = snapshot.profileRevision,
				overflowHeld = existing.overflowHeld,
			}
		end
		local result: any
		if session.state() == "PersistenceAtRisk" then
			result = session.reconcileCheckpoint(op)
		else
			result = session.checkpoint(op, function(profile: any)
				profile.collection.creaturesById = profile.collection.creaturesById or {}
				assert(profile.collection.creaturesById[id] == nil, "duplicate creature")
				local capacity = vault.collectionStatus(profile)
				assert(capacity ~= nil, "invalid collection capacity")
				local overflowHeld = capacity.ordinaryUsed >= capacity.capacity
				profile.collection.creaturesById[id] = {
					creatureInstanceId = id,
					ownerUserId = payload.ownerUserId,
					speciesId = payload.speciesId,
					variantIdentity = payload.variantIdentity,
					origin = payload.origin,
					operationId = op,
					securedAt = payload.securedAt,
					securedSequence = profile.profileRevision + 1,
					locked = #payload.variantIdentity.protectedVariantReasons > 0,
					overflowHeld = overflowHeld,
				}
				profile.discovery.speciesById = profile.discovery.speciesById or {}
				profile.discovery.speciesById[payload.speciesId] = true
				profile.discovery.variantBySignature = profile.discovery.variantBySignature or {}
				profile.discovery.variantBySignature[payload.variantIdentity.variantSignature] =
					true
				profile.discovery.mutationsById = profile.discovery.mutationsById or {}
				for _, mutationId in payload.variantIdentity.mutationIdsCanonical do
					profile.discovery.mutationsById[mutationId] = true
				end
			end)
		end
		if result.status == "Committed" or result.status == "AlreadyCommitted" then
			local committed = session.snapshot()
			local record = if committed then creatures(committed)[id] else nil
			if record ~= nil and record.operationId == op then
				return {
					status = "Secured",
					creatureInstanceId = id,
					profileRevision = result.profileRevision,
					overflowHeld = record.overflowHeld,
				}
			end
			return { status = "OutcomeUnknown" }
		end
		return result
	end

	return { canInitiate = canInitiate, finalize = finalize }
end

return CaptureFinalizationUseCase
