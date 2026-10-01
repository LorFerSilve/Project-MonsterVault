--!strict

local VaultService = require("../../src/server/domains/vault/VaultService")
local Config = require("../../src/shared/config/VaultCapacityFixture")
local Schema = require("../../src/server/infrastructure/persistence/ProfileSchemaV1")
local Factory = require("../../src/server/application/CaptureFinalizationUseCase")
local ProfileSession = require("../../src/server/infrastructure/persistence/ProfileSession")
local Queue = require("../../src/server/infrastructure/persistence/SingleWriterQueue")
local Retry = require("../../src/server/infrastructure/persistence/RetryPolicy")
local FakeClock = require("../fixtures/FakeClock")
local FakeRepository = require("../fixtures/FakeProfileRepository")

local function sessionFor(repository: any): any
	local clock = FakeClock.new(1_700_000_000, 0)
	return ProfileSession.new({
		userId = 42,
		lockId = "vault-capacity",
		jobId = "vault-capacity-job",
		repository = repository,
		schema = Schema,
		queue = Queue.new(clock.monotonicClock.seconds, clock.advance, 10),
		retry = Retry.new(clock.monotonicClock.seconds, clock.advance, function()
			return 0.5
		end, 3),
		unixSeconds = clock.wallClock.unixSeconds,
		monotonicSeconds = clock.monotonicClock.seconds,
	})
end

local function capacityCountsInstancesAndBlocksOverflow()
	local vault = VaultService.new(Config)
	local profile = Schema.default(1_700_000_000)
	profile.collection.creaturesById = {
		ordinary = { overflowHeld = false },
		overflow = { overflowHeld = true },
	}
	profile.vault.displayAssignments = { display = "ordinary" }
	profile.vault.productionAssignments = { production = "ordinary" }
	local status = assert(vault.collectionStatus(profile), "valid capacity state")
	assert(status.capacity == 10 and status.ordinaryUsed == 1, "roles never count extra copies")
	assert(status.overflowHeldCount == 1 and not status.canInitiate, "unresolved overflow blocks")
	profile.collection.creaturesById.overflow = nil
	assert(
		assert(vault.collectionStatus(profile), "capacity available").canInitiate,
		"free ordinary capacity permits initiation"
	)
	profile.progression.collectionCapacity = 1
	assert(
		not assert(vault.collectionStatus(profile), "capacity available").canInitiate,
		"full capacity blocks"
	)
	profile.collection.creaturesById = {}
	profile.progression.collectionCapacity = 0
	assert(
		not assert(vault.collectionStatus(profile), "capacity available").canInitiate,
		"zero is explicit, not fallback"
	)
	local config = { baseCollectionCapacity = 2 }
	local snapshot = VaultService.new(config)
	config.baseCollectionCapacity = 0
	profile.progression.collectionCapacity = nil
	assert(
		assert(snapshot.collectionStatus(profile), "capacity available").capacity == 2,
		"config is sampled at composition"
	)
end

local function invalidCapacityProtectsLoadAndDoesNotFallback()
	local vault = VaultService.new(Config)
	local invalidValues: { any } = { -1, 0.5, "10", false, math.huge, 0 / 0, 9_007_199_254_740_992 }
	for _, value in invalidValues do
		local profile = Schema.default(1_700_000_000)
		profile.progression.collectionCapacity = value
		local valid, reason = Schema.validate(profile)
		assert(not valid and reason == "invalid_collection_capacity", "invalid scalar fails schema")
		assert(vault.collectionStatus(profile) == nil, "no silent base-capacity fallback")
		local repository = FakeRepository.new()
		repository.seed("player/42", profile)
		local active = sessionFor(repository)
		assert(
			active.acquire().status == "ProtectedLoadFailure",
			"corrupt capacity cannot become Ready"
		)
		assert(
			repository.read("player/42").value.profileRevision == 0,
			"protected load never overwrites"
		)
	end
	assert(
		vault.collectionStatus({ collection = {}, progression = false }) == nil,
		"malformed bucket"
	)
	local profile = Schema.default(1_700_000_000)
	profile.collection.creaturesById = { broken = { overflowHeld = "false" } }
	assert(vault.collectionStatus(profile) == nil, "malformed record fails closed")
end

local function finalizationUsesTheInjectedVaultAuthority()
	local calls = 0
	local vault = {
		collectionStatus = function(_profile: any)
			calls += 1
			return { capacity = 0, ordinaryUsed = 0, canInitiate = false }
		end,
	}
	local finalization = Factory.new(vault)
	local repository = FakeRepository.new()
	local active = sessionFor(repository)
	assert(active.acquire().status == "Ready", "owner profile acquired")
	assert(not finalization.canInitiate(active.snapshot()), "admission delegates to Vault")
	local payload = {
		ownerUserId = 42,
		operationId = "vault-capacity-operation",
		creatureInstanceId = "vault-capacity-creature",
		speciesId = "species/test",
		securedAt = 1_700_000_001,
		origin = { spawnContextId = "spawn/test", contentSnapshotId = "content/test" },
		variantIdentity = {
			speciesRarityId = "rarity/common",
			variantSignature = "variant/test",
			mutationIdsCanonical = {},
			traitIds = {},
			protectedVariantReasons = { "protected/test" },
			spawnContextId = "spawn/test",
			contentSnapshotId = "content/test",
		},
	}
	local result = finalization.finalize(active, payload)
	assert(result.status == "Secured" and result.overflowHeld, "capacity race preserves ownership")
	assert(calls == 2, "admission and finalization share one authority")
	local record = active.snapshot().collection.creaturesById[payload.creatureInstanceId]
	assert(
		record.locked and record.variantIdentity.variantSignature == "variant/test",
		"protection preserved"
	)
	local writes = repository.calls()
	assert(
		finalization.finalize(active, payload).status == "Secured",
		"duplicate returns durable result"
	)
	assert(
		repository.calls() == writes and calls == 2,
		"duplicate neither writes nor recalculates placement"
	)
	assert(next(active.snapshot().economy) == nil, "capture grants no Energy")

	local invalid = Factory.new({
		collectionStatus = function(_profile: any)
			return nil
		end,
	})
	payload.creatureInstanceId = "rejected-creature"
	payload.operationId = "rejected-operation"
	assert(not invalid.canInitiate(active.snapshot()), "unavailable capacity blocks admission")
	assert(
		invalid.finalize(active, payload).status == "Rejected",
		"invalid capacity cannot finalize"
	)
	assert(repository.calls() == writes, "invalid capacity makes no repository call")
	assert(
		active.snapshot().collection.creaturesById["rejected-creature"] == nil,
		"no ownership mutation"
	)
end

return {
	capacityCountsInstancesAndBlocksOverflow = capacityCountsInstancesAndBlocksOverflow,
	invalidCapacityProtectsLoadAndDoesNotFallback = invalidCapacityProtectsLoadAndDoesNotFallback,
	finalizationUsesTheInjectedVaultAuthority = finalizationUsesTheInjectedVaultAuthority,
}
