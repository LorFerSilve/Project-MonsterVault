--!strict

-- A P2 mutation owns the only secured collection entry. Operation identity is
-- minted at provisional capture, not from a network request or secure trigger.
local CaptureFinalizationUseCase = {}
local BASE_CAPACITY = 10 -- DEV fixture; TA-8 will own progression/commercial capacity.

local function creatures(profile: any): any
	return profile.collection.creaturesById or {}
end

local function capacity(profile: any): number
	local configured = profile.progression.collectionCapacity
	if type(configured) == "number" and configured >= 0 and configured % 1 == 0 then
		return configured
	end
	return BASE_CAPACITY
end

function CaptureFinalizationUseCase.canInitiate(profile: any): boolean
	if type(profile) ~= "table" or type(profile.collection) ~= "table" then
		return false
	end
	local count = 0
	for _, record in creatures(profile) do
		if record.overflowHeld then
			return false
		end
		count += 1
	end
	return count < capacity(profile)
end

function CaptureFinalizationUseCase.finalize(session: any, payload: any): any
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
			local ordinary = 0
			for _, record in profile.collection.creaturesById do
				if not record.overflowHeld then
					ordinary += 1
				end
			end
			local overflowHeld = ordinary >= capacity(profile)
			profile.collection.creaturesById[id] = {
				creatureInstanceId = id,
				ownerUserId = payload.ownerUserId,
				speciesId = payload.speciesId,
				variantIdentity = payload.variantIdentity,
				origin = payload.origin,
				operationId = op,
				securedAt = payload.securedAt,
				locked = #payload.variantIdentity.protectedVariantReasons > 0,
				overflowHeld = overflowHeld,
			}
			profile.discovery.speciesById = profile.discovery.speciesById or {}
			profile.discovery.speciesById[payload.speciesId] = true
			profile.discovery.variantBySignature = profile.discovery.variantBySignature or {}
			profile.discovery.variantBySignature[payload.variantIdentity.variantSignature] = true
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

return CaptureFinalizationUseCase
