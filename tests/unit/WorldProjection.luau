--!strict

local WorldProjectionV1 = require("../../src/shared/contracts/WorldProjectionV1")
local WorldProjectionStore = require("../../src/client/store/WorldProjectionStore")

local function attributes(id: string, revision: number): any
	return {
		CreatureInstanceId = id,
		SpeciesId = "species/fixture-orb",
		RarityId = "rarity/common",
		SpawnContextId = "spawn-context/fixture-clearing",
		RuntimeRevision = revision,
		Availability = "IdleAvailable",
	}
end

local function streamOutDoesNotClaimTerminalLifecycle()
	local store = WorldProjectionStore.new(WorldProjectionV1)
	local model = {}
	assert(store.streamIn(model, attributes("creature-1", 2)) == "Applied", "initial model")
	assert(store.view("creature-1").present, "model present")
	assert(store.streamOut(model), "stream-out tracked")
	local cached = store.view("creature-1")
	assert(cached ~= nil and not cached.present, "stream-out keeps presentation metadata")
	assert(cached.runtimeRevision == 2, "stream-out does not synthesize terminal revision")
	assert(not store.streamOut(model), "repeat stream-out is idempotent")
end

local function lateStreamInReconstructsByStableId()
	local store = WorldProjectionStore.new(WorldProjectionV1)
	local first = {}
	local replacement = {}
	assert(store.streamIn(first, attributes("creature-1", 2)) == "Applied", "first model")
	store.streamOut(first)
	assert(store.streamIn(replacement, attributes("creature-1", 3)) == "Applied", "late model")
	local cached = store.view("creature-1")
	assert(cached.present and cached.runtimeRevision == 3, "late model reconstructs cache")
	assert(not store.streamOut(first), "old model cannot remove replacement")
end

local function staleRevisionCannotReplaceCurrentProjection()
	local store = WorldProjectionStore.new(WorldProjectionV1)
	local current = {}
	local stale = {}
	assert(store.streamIn(current, attributes("creature-1", 3)) == "Applied", "current model")
	assert(store.streamIn(stale, attributes("creature-1", 2)) == "Stale", "stale rejected")
	assert(store.view("creature-1").runtimeRevision == 3, "revision retained")
	assert(store.view("creature-1").present, "current model retained")
end

local function malformedOrReboundModelIsRejected()
	local store = WorldProjectionStore.new(WorldProjectionV1)
	local model = {}
	local malformed = attributes("creature-1", 2)
	malformed.SecretSpawnWeight = 0.5
	assert(store.streamIn(model, malformed) == "Invalid", "unknown data rejected")
	assert(store.view("creature-1") == nil, "invalid model not cached")
	assert(store.streamIn(model, attributes("creature-1", 2)) == "Applied", "valid model")
	assert(
		store.streamIn(model, attributes("creature-2", 3)) == "Invalid",
		"model cannot change identity"
	)
	assert(store.view("creature-2") == nil, "rebound identity not cached")
	store.reset()
	assert(store.view("creature-1") == nil, "reset clears projection cache")
end

local function cacheIsBoundedAcrossRefills()
	local store = WorldProjectionStore.new(WorldProjectionV1)
	for index = 1, 300 do
		local model = {}
		local id = "creature-" .. tostring(index)
		assert(store.streamIn(model, attributes(id, 2)) == "Applied", "new presentation")
		store.streamOut(model)
	end
	assert(store.view("creature-1") == nil, "oldest presentation evicted")
	assert(store.view("creature-300") ~= nil, "recent presentation retained")
end

local function captureAvailabilityAndStreamOutKeepIdentity()
	local store = WorldProjectionStore.new(WorldProjectionV1)
	local model = {}
	for index, state in
		{
			"IdleAvailable",
			"Claimed",
			"AttemptActive",
			"Provisional",
			"TransportActive",
			"TransportGrace",
			"FinalizationPending",
			"Secured",
		}
	do
		local record = attributes("creature-1", index)
		record.Availability = state
		assert(store.streamIn(model, record) == "Applied", "known authoritative lifecycle accepted")
		assert(
			store.present()[1].model == model and store.present()[1].availability == state,
			"target presentation follows revision"
		)
	end
	local invalid = attributes("creature-1", 9)
	invalid.Availability = "OwnedForever"
	assert(store.streamIn(model, invalid) == "Invalid", "unknown authority rejected")
	store.streamOut(model)
	assert(
		#store.present() == 0 and store.view("creature-1").availability == "Secured",
		"stream loss removes target without local lifecycle change"
	)
end

local function lifetimeProjectionRetainsDistinctStates()
	local store = WorldProjectionStore.new(WorldProjectionV1)
	local model = {}
	for n, state in
		{
			"IdleAvailable",
			"Claimed",
			"AttemptActive",
			"Provisional",
			"TransportActive",
			"TransportGrace",
			"FinalizationPending",
			"Secured",
		}
	do
		local a = attributes("protected-1", n)
		a.LifetimeClass, a.AvailableAt, a.IdleExpiresAt, a.Availability =
			"ProtectedVariant", 3, 303, state
		assert(store.streamIn(model, a) == "Applied", "lifetime presentation accepted")
		local view = store.view("protected-1")
		assert(
			view.lifetimeClass == "ProtectedVariant"
				and view.availableAt == 3
				and view.idleExpiresAt == 303
				and view.availability == state,
			"distinct lifecycle and original deadline retained"
		)
	end
	store.streamOut(model)
	assert(
		store.view("protected-1").idleExpiresAt == 303 and not store.view("protected-1").present,
		"streaming preserves lifetime presentation"
	)
	local invalidTimes: { any } = { -1, 0 / 0, math.huge, "303" }
	for _, invalid in invalidTimes do
		local a = attributes("bad-lifetime", 1)
		a.IdleExpiresAt = invalid
		assert(not WorldProjectionV1.valid(a), "invalid lifetime hint rejected")
	end
	local a = attributes("bad-lifetime", 1)
	a.LifetimeClass = "Immortal"
	assert(not WorldProjectionV1.valid(a), "invented lifetime class rejected")
	a.LifetimeClass, a.AvailableAt, a.IdleExpiresAt = "Ordinary", 3, 2
	assert(not WorldProjectionV1.valid(a), "regressing lifetime hint rejected")
	assert(WorldProjectionV1.valid(attributes("legacy", 1)), "legacy projection remains readable")
end

return {
	lifetimeProjectionRetainsDistinctStates = lifetimeProjectionRetainsDistinctStates,
	captureAvailabilityAndStreamOutKeepIdentity = captureAvailabilityAndStreamOutKeepIdentity,
	streamOutDoesNotClaimTerminalLifecycle = streamOutDoesNotClaimTerminalLifecycle,
	lateStreamInReconstructsByStableId = lateStreamInReconstructsByStableId,
	staleRevisionCannotReplaceCurrentProjection = staleRevisionCannotReplaceCurrentProjection,
	malformedOrReboundModelIsRejected = malformedOrReboundModelIsRejected,
	cacheIsBoundedAcrossRefills = cacheIsBoundedAcrossRefills,
}
