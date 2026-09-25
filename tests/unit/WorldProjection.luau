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

return {
	streamOutDoesNotClaimTerminalLifecycle = streamOutDoesNotClaimTerminalLifecycle,
	lateStreamInReconstructsByStableId = lateStreamInReconstructsByStableId,
	staleRevisionCannotReplaceCurrentProjection = staleRevisionCannotReplaceCurrentProjection,
	malformedOrReboundModelIsRejected = malformedOrReboundModelIsRejected,
	cacheIsBoundedAcrossRefills = cacheIsBoundedAcrossRefills,
}
