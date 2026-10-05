--!strict

local FakeClock = require("../fixtures/FakeClock")
local FakeRepository = require("../fixtures/FakeProfileRepository")
local Schema = require("../../src/server/infrastructure/persistence/ProfileSchemaV1")
local ProfileSession = require("../../src/server/infrastructure/persistence/ProfileSession")
local Queue = require("../../src/server/infrastructure/persistence/SingleWriterQueue")
local Retry = require("../../src/server/infrastructure/persistence/RetryPolicy")
local Finalization = require("../fixtures/CaptureFinalization")
local VariantIdentity = require("../../src/server/domains/capture/VariantIdentity")
local Fixture = require("../../src/server/domains/world/FixtureDefinition")
local Definitions = require("../../src/server/domains/world/WorldDefinitions")

local function sessionFor(repository: any, clock: any, lockId: string, userId: number?): any
	return ProfileSession.new({
		userId = userId or 42,
		lockId = lockId,
		jobId = "fixture-job",
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

local function setup(): (any, any, any)
	local repository = FakeRepository.new()
	local clock = FakeClock.new(1_700_000_000, 0)
	local session = sessionFor(repository, clock, "capture-owner")
	assert(session.acquire().status == "Ready", "fixture profile acquired")
	return session, repository, clock
end

local function payload(): any
	return {
		operationId = "capture-operation",
		creatureInstanceId = "capture-creature",
		ownerUserId = 42,
		speciesId = Fixture.speciesId,
		variantIdentity = VariantIdentity.generate(Fixture, {
			nextUnit = function()
				return 0.1
			end,
		}),
		origin = {
			spawnContextId = Fixture.spawnContextId,
			contentSnapshotId = Fixture.contentSnapshotId,
		},
		securedAt = 1_700_000_001,
	}
end

local function assertRejoined(repository: any, clock: any)
	local rejoined = sessionFor(repository, clock, "rejoined-owner")
	assert(rejoined.acquire().status == "Ready", "released lease permits rejoin")
	local profile = rejoined.snapshot()
	local record = profile.collection.creaturesById["capture-creature"]
	assert(record.creatureInstanceId == "capture-creature", "same exact creature survives rejoin")
	assert(
		record.ownerUserId == 42 and record.operationId == "capture-operation",
		"same owner and operation"
	)
	assert(profile.profileRevision == 2, "reconciliation does not mint a second revision")
	assert(profile.recentOperations["capture-operation"] == 2, "durable dedupe marker survives")
	assert(profile.discovery.speciesById[Fixture.speciesId], "discovery remains in same commit")
	assert(record.securedAt == 1_700_000_001, "retries preserve original secure time")
end

local function intendedOwnerAndLegacyProfiles()
	local session, repository, clock = setup()
	local item = payload()
	item.ownerUserId = 43
	local calls = repository.calls()
	assert(
		Finalization.finalize(session, item).status == "Rejected",
		"cross-owner finalization rejected"
	)
	assert(repository.calls() == calls, "rejected owner never reaches persistence")
	item.ownerUserId = 42
	assert(Finalization.finalize(session, item).status == "Secured", "correct owner finalizes")
	assert(session.release(25).status == "Closed", "owner test releases lease")
	local profile = repository.read("player/42").value
	local record = profile.collection.creaturesById["capture-creature"]
	record.ownerUserId = -1
	assert(not Schema.validate(profile), "invalid explicit owner fails schema")
	record.ownerUserId = 42
	repository.seed("player/43", profile, {})
	assert(
		sessionFor(repository, clock, "wrong-owner", 43).acquire().status == "ProtectedLoadFailure",
		"explicit wrong profile owner fails closed"
	)
	assert(
		repository.read("player/43").metadata.mvLease == nil,
		"wrong owner does not acquire a lease"
	)
	-- Earlier DEV V1 records inferred ownership from their Player Profile key.
	record.ownerUserId = nil
	assert(Schema.validate(profile), "legacy V1 creature record remains valid")
	repository.seed("player/42", profile, {})
	assert(
		sessionFor(repository, clock, "legacy-owner").acquire().status == "Ready",
		"legacy DEV captures stay readable"
	)
end

local function lostResultReleaseAndRejoin()
	local session, repository, clock = setup()
	repository.loseNextResultAfterWrite()
	assert(
		Finalization.finalize(session, payload()).status == "OutcomeUnknown",
		"lost response remains pending"
	)
	assert(session.snapshot().collection.creaturesById == nil, "local ownership is not fabricated")
	assert(
		session.release(clock.monotonicClock.seconds() + 25).status == "Closed",
		"release reconciles lost write response"
	)
	assert(
		repository.read("player/42").metadata.mvLease == nil,
		"lease released after reconciliation"
	)
	assertRejoined(repository, clock)
end

local function beforeWriteReleaseKeepsCandidate()
	local session, repository, clock = setup()
	for _ = 1, 3 do
		repository.failNext({ status = "error", reason = "TRANSIENT", retryable = true })
	end
	assert(
		Finalization.finalize(session, payload()).status == "OutcomeUnknown",
		"failed write retains pending candidate"
	)
	assert(
		repository.read("player/42").value.collection.creaturesById == nil,
		"failed writes have no ownership"
	)
	assert(
		session.release(clock.monotonicClock.seconds() + 25).status == "Closed",
		"release retries same accepted candidate"
	)
	assertRejoined(repository, clock)
end

local function uncertainReleaseRetainsPendingCheckpoint()
	local session, repository, clock = setup()
	repository.loseNextResultAfterWrite()
	assert(
		Finalization.finalize(session, payload()).status == "OutcomeUnknown",
		"lost response remains pending"
	)
	for _ = 1, 3 do
		repository.failNext({ status = "error", reason = "TRANSIENT", retryable = true })
	end
	assert(
		session.release(clock.monotonicClock.seconds() + 25).status == "OutcomeUnknown",
		"uncertain release cannot close"
	)
	assert(session.state() == "PersistenceAtRisk", "uncertainty keeps reconcilable state")
	assert(
		repository.read("player/42").metadata.mvLease.lockId == "capture-owner",
		"pending operation retains lease"
	)
	local calls = repository.calls()
	assert(
		session.release(clock.monotonicClock.seconds()).status == "OutcomeUnknown",
		"expired drain budget remains protected"
	)
	assert(repository.calls() == calls, "expired deadline makes no additional write")
	assert(
		session.release(clock.monotonicClock.seconds() + 25).status == "Closed",
		"later drain reconciles retained operation"
	)
	assertRejoined(repository, clock)
end

local function protectedVariantFaultsRejoinAndDedupe()
	for _, fault in { "before", "after" } do
		local session, repository, clock = setup()
		local item = payload()
		item.speciesId = Definitions.protectedEncounter.speciesId
		item.origin = {
			spawnContextId = Definitions.protectedEncounter.spawnContextId,
			contentSnapshotId = Definitions.contentSnapshotId,
		}
		item.variantIdentity = VariantIdentity.generate({
			speciesId = item.speciesId,
			rarityId = "rarity/legendary",
			spawnContextId = item.origin.spawnContextId,
			contentSnapshotId = item.origin.contentSnapshotId,
		}, {
			nextUnit = function()
				return 0.75
			end,
		})
		repository.setReplayTransform(true)
		if fault == "before" then
			for _ = 1, 3 do
				repository.failNext({ status = "error", reason = "TRANSIENT", retryable = true })
			end
		else
			repository.loseNextResultAfterWrite()
		end
		assert(
			Finalization.finalize(session, item).status == "OutcomeUnknown",
			"fault remains pending"
		)
		assert(session.snapshot().collection.creaturesById == nil, "unknown is not ownership")
		assert(
			session.release(clock.monotonicClock.seconds() + 25).status == "Closed",
			"same candidate drained"
		)
		local rejoined = sessionFor(repository, clock, "protected-rejoin")
		assert(rejoined.acquire().status == "Ready", "rejoined protected profile")
		local profile = rejoined.snapshot()
		local record = profile.collection.creaturesById[item.creatureInstanceId]
		assert(
			record.locked and record.speciesId == item.speciesId,
			"Protected Variant auto-lock shares P2"
		)
		assert(
			record.variantIdentity.protectedVariantReasons[1]
				== "protected-variant/legendary-species",
			"classification persisted"
		)
		assert(
			record.operationId == item.operationId
				and record.origin.contentSnapshotId == Definitions.contentSnapshotId,
			"original operation and content epoch persisted"
		)
		assert(
			profile.profileRevision == 2 and next(profile.economy) == nil,
			"capture creates no wallet grant"
		)
		assert(profile.discovery.speciesById[item.speciesId], "same-commit discovery")
		assert(Finalization.finalize(rejoined, item).status == "Secured", "same operation deduped")
		assert(
			rejoined.snapshot().profileRevision == profile.profileRevision,
			"rejoin replay minted value"
		)
		item.operationId = "different-capture-operation"
		assert(
			Finalization.finalize(rejoined, item).status == "Rejected",
			"new operation resurrected consumed creature"
		)
		assert(rejoined.release(25).status == "Closed", "rejoin cleanup")
	end
end

return {
	protectedVariantFaultsRejoinAndDedupe = protectedVariantFaultsRejoinAndDedupe,
	intendedOwnerAndLegacyProfiles = intendedOwnerAndLegacyProfiles,
	lostResultReleaseAndRejoin = lostResultReleaseAndRejoin,
	beforeWriteReleaseKeepsCandidate = beforeWriteReleaseKeepsCandidate,
	uncertainReleaseRetainsPendingCheckpoint = uncertainReleaseRetainsPendingCheckpoint,
}
