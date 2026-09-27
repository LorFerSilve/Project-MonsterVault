--!strict

local SessionCoordinator = require("../../src/server/application/SessionCoordinator")
local FakeClock = require("../fixtures/FakeClock")
local FakeRepository = require("../fixtures/FakeProfileRepository")
local Schema = require("../../src/server/infrastructure/persistence/ProfileSchemaV1")
local ProfileSession = require("../../src/server/infrastructure/persistence/ProfileSession")
local Queue = require("../../src/server/infrastructure/persistence/SingleWriterQueue")
local Retry = require("../../src/server/infrastructure/persistence/RetryPolicy")
local Finalization = require("../../src/server/application/CaptureFinalizationUseCase")
local VariantIdentity = require("../../src/server/domains/capture/VariantIdentity")
local Fixture = require("../../src/server/domains/world/FixtureDefinition")

local function multipleSessionsAutosaveAndShutdown()
	local now = 100
	local created = {}
	local saved = {}
	local coordinator = SessionCoordinator.new({
		createSession = function(userId)
			created[userId] = true
			local state = "NoSession"
			return {
				acquire = function()
					state = "Ready"
					return { status = "Ready" }
				end,
				state = function()
					return state
				end,
				renew = function()
					saved[userId] = (saved[userId] or 0) + 1
					return { status = "Ready" }
				end,
				release = function()
					state = "Closed"
					return { status = "Closed" }
				end,
			}
		end,
		unixSeconds = function()
			return now
		end,
		monotonicSeconds = function()
			return now
		end,
		spawn = function(callback)
			callback()
		end,
		waitSeconds = function(seconds)
			now += seconds
		end,
	})
	assert(next(created) == nil, "construction has no import-time startup")
	assert(
		coordinator.open(1).status == "Ready" and coordinator.open(2).status == "Ready",
		"sessions open"
	)
	assert(coordinator.open(1).status == "DuplicateSession", "duplicate local session rejected")
	now = 176
	coordinator.tick()
	assert(saved[1] == 1 and saved[2] == nil, "autosaves stagger by player")
	now = 177
	coordinator.tick()
	assert(saved[2] == 1, "second player renews separately")
	assert(#coordinator.shutdown(now + 10) == 0, "all profiles drain")
	assert(coordinator.get(1) == nil and coordinator.get(2) == nil, "closed sessions removed")
	assert(coordinator.open(3).status == "Closing", "shutdown closes admission")
end

local function closeWaitsForActiveWriter()
	local now = 0
	local releaseCalls = 0
	local coordinator = SessionCoordinator.new({
		createSession = function()
			return {
				acquire = function()
					return { status = "Ready" }
				end,
				state = function()
					return "Ready"
				end,
				release = function()
					releaseCalls += 1
					return { status = if releaseCalls == 1 then "Busy" else "Closed" }
				end,
			}
		end,
		unixSeconds = function()
			return now
		end,
		monotonicSeconds = function()
			return now
		end,
		spawn = function(callback)
			callback()
		end,
		waitSeconds = function(seconds)
			now += seconds
		end,
	})
	assert(coordinator.open(42).status == "Ready", "acquired")
	assert(coordinator.close(42, 1).status == "Closed", "close waits for busy writer")
	assert(releaseCalls == 2 and now > 0, "writer gets time to finish")
end

local function leaveDuringAcquireReleasesLease()
	local now = 0
	local releaseCalls = 0
	local coordinator
	coordinator = SessionCoordinator.new({
		createSession = function()
			local state = "NoSession"
			return {
				acquire = function()
					state = "Acquiring"
					local closeResult = coordinator.close(73, now + 0.1)
					assert(
						closeResult.status == "PendingClose",
						"departure recorded during acquisition"
					)
					state = "Ready"
					return { status = "Ready" }
				end,
				state = function()
					return state
				end,
				release = function()
					releaseCalls += 1
					state = "Closed"
					return { status = "Closed" }
				end,
			}
		end,
		unixSeconds = function()
			return now
		end,
		monotonicSeconds = function()
			return now
		end,
		spawn = function(callback)
			callback()
		end,
		waitSeconds = function(seconds)
			now += seconds
		end,
	})
	assert(coordinator.open(73).status == "Closed", "acquired lease immediately released")
	assert(releaseCalls == 1 and coordinator.get(73) == nil, "no orphan session")
end

local function uncertainCloseRetriesOnTick()
	local now = 0
	local releaseCalls = 0
	local coordinator = SessionCoordinator.new({
		createSession = function()
			local state = "NoSession"
			return {
				acquire = function()
					state = "Ready"
					return { status = "Ready" }
				end,
				state = function()
					return state
				end,
				renew = function()
					error("closing sessions must retry release, not renew")
				end,
				release = function()
					releaseCalls += 1
					state = if releaseCalls == 1 then "PersistenceAtRisk" else "Closed"
					return { status = if releaseCalls == 1 then "OutcomeUnknown" else "Closed" }
				end,
			}
		end,
		unixSeconds = function()
			return now
		end,
		monotonicSeconds = function()
			return now
		end,
		spawn = function(callback)
			callback()
		end,
		waitSeconds = function(seconds)
			now += seconds
		end,
	})
	assert(coordinator.open(42).status == "Ready", "fixture acquired")
	local retained = coordinator.get(42)
	assert(coordinator.close(42, 25).status == "OutcomeUnknown", "uncertain release retained")
	assert(coordinator.get(42) == retained, "same pending candidate remains owned")
	now = 4
	coordinator.tick()
	assert(releaseCalls == 1, "retry interval is bounded")
	now = 5
	coordinator.tick()
	assert(
		releaseCalls == 2 and coordinator.get(42) == nil,
		"tick releases retained closing session"
	)
end

local function rejoinReconcilesUnknownReleaseBeforeAcquire()
	local clock = FakeClock.new(1_700_000_000, 0)
	local repository = FakeRepository.new()
	local created = 0
	local coordinator = SessionCoordinator.new({
		createSession = function(userId)
			created += 1
			if created > 1 then
				assert(
					repository.read("player/42").metadata.mvLease == nil,
					"prior lease must release before replacement"
				)
			end
			return ProfileSession.new({
				userId = userId,
				lockId = "coordinator-owner-" .. created,
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
		end,
		unixSeconds = clock.wallClock.unixSeconds,
		monotonicSeconds = clock.monotonicClock.seconds,
		spawn = function(callback)
			callback()
		end,
		waitSeconds = clock.advance,
	})
	assert(coordinator.open(42).status == "Ready", "first session acquired")
	local original = coordinator.get(42)
	repository.loseNextResultAfterWrite()
	assert(Finalization.finalize(original, {
		operationId = "rejoin-operation",
		creatureInstanceId = "rejoin-creature",
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
	}).status == "OutcomeUnknown", "lost capture result remains pending")
	for _ = 1, 3 do
		repository.failNext({ status = "error", reason = "TRANSIENT", retryable = true })
	end
	assert(
		coordinator.close(42, clock.monotonicClock.seconds() + 25).status == "OutcomeUnknown",
		"release reconciliation is temporarily unavailable"
	)
	assert(coordinator.get(42) == original and created == 1, "unresolved session is never replaced")
	local concurrentStatus
	repository.setBeforeTransform(function()
		repository.setBeforeTransform(nil)
		concurrentStatus = coordinator.open(42).status
	end)
	assert(
		coordinator.open(42).status == "Ready",
		"same-user rejoin drains retained session then acquires"
	)
	assert(
		concurrentStatus == "PendingClose",
		"concurrent reopen never starts a second acquisition"
	)
	assert(created == 2 and coordinator.get(42) ~= original, "exactly one replacement session")
	local profile = coordinator.get(42).snapshot()
	assert(profile.profileRevision == 2, "rejoin does not recommit creature value")
	assert(
		profile.collection.creaturesById["rejoin-creature"].operationId == "rejoin-operation",
		"same exact creature and operation survive rejoin"
	)
	assert(
		profile.recentOperations["rejoin-operation"] == 2,
		"dedupe proof survives lease replacement"
	)
end

local function unsuccessfulReopenAndShutdownAreBounded()
	local now = 0
	local created = 0
	local releases = 0
	local coordinator = SessionCoordinator.new({
		createSession = function()
			created += 1
			return {
				acquire = function()
					return { status = "Ready" }
				end,
				state = function()
					return "PersistenceAtRisk"
				end,
				release = function()
					releases += 1
					return { status = "OutcomeUnknown" }
				end,
			}
		end,
		unixSeconds = function()
			return now
		end,
		monotonicSeconds = function()
			return now
		end,
		spawn = function(callback)
			callback()
		end,
		waitSeconds = function(seconds)
			now += seconds
		end,
	})
	assert(coordinator.open(42).status == "Ready", "fixture acquired")
	local retained = coordinator.get(42)
	assert(coordinator.close(42, 25).status == "OutcomeUnknown", "release uncertain")
	assert(
		coordinator.open(42).status == "OutcomeUnknown",
		"reopen stays protected while release unresolved"
	)
	assert(now == 25 and releases <= 27, "reopen retries respect one bounded deadline and delay")
	assert(
		created == 1 and coordinator.get(42) == retained,
		"no duplicate session or lease during uncertainty"
	)
	local failures = coordinator.shutdown(now + 1)
	assert(
		#failures == 1 and coordinator.get(42) == retained,
		"shutdown reports retained unresolved drain"
	)
	assert(coordinator.open(42).status == "Closing", "shutdown forbids replacement acquisition")
end

return {
	multipleSessionsAutosaveAndShutdown = multipleSessionsAutosaveAndShutdown,
	closeWaitsForActiveWriter = closeWaitsForActiveWriter,
	leaveDuringAcquireReleasesLease = leaveDuringAcquireReleasesLease,
	uncertainCloseRetriesOnTick = uncertainCloseRetriesOnTick,
	rejoinReconcilesUnknownReleaseBeforeAcquire = rejoinReconcilesUnknownReleaseBeforeAcquire,
	unsuccessfulReopenAndShutdownAreBounded = unsuccessfulReopenAndShutdownAreBounded,
}
