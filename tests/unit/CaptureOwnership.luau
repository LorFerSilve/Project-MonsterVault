--!strict

local Fixture = require("../../src/server/domains/world/FixtureDefinition")
local WorldService = require("../../src/server/domains/world/WorldService")
local VariantIdentity = require("../../src/server/domains/capture/VariantIdentity")
local CaptureService = require("../../src/server/domains/capture/CaptureService")
local Finalization = require("../../src/server/application/CaptureFinalizationUseCase")
local FakeClock = require("../fixtures/FakeClock")
local FakeRepository = require("../fixtures/FakeProfileRepository")
local ProfileSchema = require("../../src/server/infrastructure/persistence/ProfileSchemaV1")
local ProfileSession = require("../../src/server/infrastructure/persistence/ProfileSession")
local Queue = require("../../src/server/infrastructure/persistence/SingleWriterQueue")
local Retry = require("../../src/server/infrastructure/persistence/RetryPolicy")

local function check<T>(value: T?, message: string?): T
	if not value then
		error(message or "capture ownership invariant")
	end
	return value :: T
end

local function profileHarness()
	local repository = FakeRepository.new()
	local clock = FakeClock.new(1_700_000_000, 0)
	local session = ProfileSession.new({
		userId = 42,
		lockId = "owner",
		jobId = "job",
		repository = repository,
		schema = ProfileSchema,
		queue = Queue.new(clock.monotonicClock.seconds, function(seconds)
			clock.advance(seconds)
		end, 10),
		retry = Retry.new(clock.monotonicClock.seconds, function(seconds)
			clock.advance(seconds)
		end, function()
			return 0.5
		end, 3),
		unixSeconds = clock.wallClock.unixSeconds,
		monotonicSeconds = clock.monotonicClock.seconds,
	})
	check(session.acquire().status == "Ready")
	return session, repository
end

local function payload(id: string, op: string)
	return {
		ownerUserId = 42,
		operationId = op,
		creatureInstanceId = id,
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

local function worldHarness(failFirst: boolean?)
	local nextId = 0
	local draws = 0
	local attempts = 0
	local world = WorldService.new({
		fixture = Fixture,
		clock = function()
			return 0
		end,
		newId = function()
			nextId += 1
			return "creature-" .. nextId
		end,
		generateVariant = function(candidate)
			return VariantIdentity.generate(candidate, {
				nextUnit = function()
					draws += 1
					return 0.1
				end,
			})
		end,
		materialize = function()
			attempts += 1
			if failFirst and attempts == 1 then
				error("injected failure")
			end
			return {}
		end,
		activate = function() end,
		destroyProjection = function() end,
	})
	local generation = world.start()
	world.step(generation)
	return world, function()
		return draws
	end
end

local function variantDoesNotRerollOnMaterializationRetry()
	local world, draws = worldHarness(true)
	local id = check(world.currentId(), "reserved creature ID")
	check(id ~= nil and draws() == 2, "two identity draws at reservation")
	local variant = world.identity(id).variantIdentity
	check(variant.variantSignature == Fixture.speciesId .. "|mutation/fixture-luminous")
	check(world.step(1) == "Idle", "retry waits on server scheduler")
	check(world.identity(id).variantIdentity == variant and draws() == 2, "retry reuses identity")
	world.stop()
end

local function claimAndProvisionalRequireServerContext()
	local world = worldHarness()
	local id = check(world.currentId(), "spawned creature ID")
	local ids = 0
	local writes = 0
	local capture = CaptureService.new({
		world = world,
		clock = function()
			return 0
		end,
		unixSeconds = function()
			return 1
		end,
		newId = function()
			ids += 1
			return "server-id-" .. ids
		end,
		random = {
			nextUnit = function()
				return 0.1
			end,
		},
		canInitiate = function()
			return true
		end,
		finalize = function()
			writes += 1
			return { status = "Secured", profileRevision = 2 }
		end,
	})
	local near = { x = 0, y = 3, z = -16 }
	local claim = capture.begin(42, id, near, 1, {})
	check(claim.status == "Claimed")
	check(capture.begin(43, id, near, 1, {}).status ~= "Claimed", "first claim wins")
	check(capture.submit(43, claim.captureSessionId, "capture", 1, near, 1).status == "Rejected")
	check(capture.submit(42, "forged", "capture", 1, near, 1).status == "Rejected")
	check(
		capture.submit(42, claim.captureSessionId, "capture", 1, near, 2).status == "Invalidated",
		"character reset invalidates"
	)
	local second = capture.begin(42, id, near, 2, {})
	check(second.status == "Claimed")
	local provisional = capture.submit(42, second.captureSessionId, "capture", 1, near, 2)
	check(provisional.status == "TransportActive" and writes == 0, "success is provisional")
	check(
		capture.submit(42, second.captureSessionId, "capture", 1, near, 2).custodyId
			== provisional.custodyId,
		"duplicate action is stable"
	)
	local ready = {
		state = function()
			return "Ready"
		end,
	}
	check(
		capture.secure(42, near, { x = 0, y = 0, z = 10 }, 2, ready).status == "Rejected",
		"remote secure hint requires spatial proof"
	)
	check(
		capture.secure(42, near, { x = 0, y = 0 }, 2, ready).status == "Rejected",
		"invalid Secure Point position rejects without raising"
	)
	check(capture.secure(42, { x = 0, y = 1, z = 10 }, { x = 0, y = 0, z = 10 }, 2, {
		state = function()
			return "PersistenceAtRisk"
		end,
	}).status == "Unavailable", "profile uncertainty blocks new finalization admission")
	check(
		capture.secure(42, { x = 0, y = 1, z = 10 }, { x = 0, y = 0, z = 10 }, 2, ready).status
			== "Secured"
	)
	check(writes == 1 and capture.state(id) == "Secured")
	world.stop()
end

local function durableFinalizationAndRetry()
	local session, repository = profileHarness()
	local item = payload("creature-a", "operation-a")
	local first = Finalization.finalize(session, item)
	check(first.status == "Secured" and first.profileRevision == 2)
	local stored = repository.read("player/42").value
	check(stored.collection.creaturesById["creature-a"].creatureInstanceId == "creature-a")
	check(
		stored.collection.creaturesById["creature-a"].variantIdentity.variantSignature
			== item.variantIdentity.variantSignature
	)
	check(stored.discovery.speciesById[Fixture.speciesId] == true)
	local calls = repository.calls()
	check(
		Finalization.finalize(session, item).status == "Secured" and repository.calls() == calls,
		"same operation idempotent"
	)
	check(
		Finalization.finalize(session, payload("creature-a", "other-op")).status == "Rejected",
		"same instance cannot be minted twice"
	)
end

local function lostResultReconcilesExactOnce()
	local session, repository = profileHarness()
	local item = payload("creature-b", "operation-b")
	repository.loseNextResultAfterWrite()
	check(
		Finalization.finalize(session, item).status == "OutcomeUnknown",
		"lost response stays pending"
	)
	check(session.state() == "PersistenceAtRisk")
	local committed = repository.read("player/42").value
	check(
		committed.collection.creaturesById["creature-b"] ~= nil and committed.profileRevision == 2
	)
	check(
		Finalization.finalize(session, item).status == "Secured",
		"retry reconciles durable operation"
	)
	check(
		repository.read("player/42").value.profileRevision == 2,
		"reconcile did not duplicate value"
	)
end

local function failureBeforeWriteNeverFabricatesOwnership()
	local session, repository = profileHarness()
	local item = payload("creature-c", "operation-c")
	for _ = 1, 3 do
		repository.failNext({ status = "error", reason = "TRANSIENT", retryable = true })
	end
	check(Finalization.finalize(session, item).status == "OutcomeUnknown")
	check(repository.read("player/42").value.collection.creaturesById == nil)
	check(session.snapshot().collection.creaturesById == nil)
	check(Finalization.finalize(session, item).status == "Secured", "same candidate can retry")
	check(repository.read("player/42").value.profileRevision == 2)
end

local function capacityRaceKeepsExactCreatureInOverflow()
	local session = profileHarness()
	check(session.checkpoint("capacity", function(profile)
		profile.progression.collectionCapacity = 1
	end).status == "Committed")
	check(Finalization.canInitiate(session.snapshot()))
	check(Finalization.finalize(session, payload("other", "operation-other")).status == "Secured")
	local item = payload("creature-d", "operation-d")
	check(Finalization.finalize(session, item).status == "Secured")
	local record = session.snapshot().collection.creaturesById["creature-d"]
	check(record.overflowHeld and record.creatureInstanceId == "creature-d")
	check(not Finalization.canInitiate(session.snapshot()))
end

local NEAR = { x = 0, y = 3, z = -16 }
local SECURE = { x = 0, y = 0, z = 10 }
local READY = {
	state = function()
		return "Ready"
	end,
}

local function captureHarness(finalize: ((any, any) -> any)?)
	local world, draws = worldHarness()
	local clock = FakeClock.new(1_700_000_000, 0)
	local ids = 0
	local writes = 0
	local capture = CaptureService.new({
		world = world,
		clock = clock.monotonicClock.seconds,
		unixSeconds = clock.wallClock.unixSeconds,
		newId = function()
			ids += 1
			return "capture-id-" .. ids
		end,
		random = {
			nextUnit = function()
				return 0.1
			end,
		},
		canInitiate = function()
			return true
		end,
		finalize = function(session, candidate)
			writes += 1
			if finalize then
				return finalize(session, candidate)
			end
			return { status = "Secured" }
		end,
	})
	return capture, world, clock, draws, function()
		return writes
	end
end

local function claimAndCapture(capture: any, id: string, generation: number?): any
	local currentGeneration = generation or 1
	local claim = capture.begin(42, id, NEAR, currentGeneration, {})
	check(claim.status == "Claimed")
	check(
		capture.submit(42, claim.captureSessionId, "capture", 1, NEAR, currentGeneration).status
			== "TransportActive"
	)
	return check(capture.custody(42))
end

local function transportGraceResumesSameIdentityAndExpires()
	local capture, world, clock, draws, writes = captureHarness()
	local id = check(world.currentId())
	local prior = claimAndCapture(capture, id)
	local custodyId, operationId = prior.custodyId, prior.operationId
	local variant = prior.identity.variantIdentity
	capture.disconnect(42)
	check(capture.state(id) == "TransportGrace" and capture.custody(42) == nil)
	capture.interrupt(42)
	check(capture.state(id) == "TransportGrace", "new avatar binding preserves suspended custody")
	check(#capture.activeCustodies() == 0, "grace is suspended custody")
	check(capture.finalizeForShutdown(42, READY).status == "Rejected", "shutdown excludes grace")
	check(capture.secure(42, SECURE, SECURE, 1, READY).status == "Rejected")
	check(capture.resume(42, 2, nil).status == "Rejected", "profile must be reacquired")
	check(capture.begin(42, "other-creature", NEAR, 2, {}).status == "Busy")
	clock.advance(29)
	local resumed = capture.begin(42, id, { x = 999, y = 0, z = 999 }, 2, {})
	check(resumed.status == "TransportActive" and resumed.custodyId == custodyId)
	check(resumed.captureSessionId == prior.captureSessionId and resumed.creatureInstanceId == id)
	local active = check(capture.custody(42))
	check(active.generation == 2 and active.operationId == operationId)
	check(active.identity.variantIdentity == variant and draws() == 2, "resume cannot reroll")
	local otherServer, otherWorld = captureHarness()
	check(otherServer.resume(42, 2, {}).status == "Rejected", "custody cannot cross servers")
	otherWorld.stop()
	capture.disconnect(42)
	clock.advance(30)
	capture.tick()
	check(capture.state(id) == "Expired" and world.populationCount() == 0)
	check(capture.resume(42, 3, {}).status == "Rejected")
	check(capture.recordCounts().active == 0 and writes() == 0, "expiry never secures ownership")
	world.stop()
end

local function resetInterruptsClaimsAndCustodyWithoutOwnership()
	local capture, world, _, _, writes = captureHarness()
	local id = check(world.currentId())
	local claim = capture.begin(42, id, NEAR, 1, {})
	check(claim.status == "Claimed")
	capture.interrupt(42)
	check(capture.state(id) == "Interrupted" and capture.recordCounts().active == 0)
	check(world.interaction(id, NEAR) == "Available", "claim returns to ordinary encounter")
	check(capture.submit(42, claim.captureSessionId, "capture", 1, NEAR, 1).status == "Rejected")
	claimAndCapture(capture, id, 2)
	capture.interrupt(42)
	check(capture.state(id) == "Interrupted" and capture.custody(42) == nil)
	check(world.populationCount() == 0 and writes() == 0, "reset is never extraction")
	check(capture.finalizeForShutdown(42, READY).status == "Rejected")
	check(capture.reconcile(42, READY).status == "Rejected")
	world.stop()
end

local function controlledShutdownUsesExistingOperationOnly()
	local candidate: any = nil
	local capture, world = captureHarness(function(_, value)
		candidate = value
		return { status = "Secured" }
	end)
	local id = check(world.currentId())
	check(capture.begin(42, id, NEAR, 1, {}).status == "Claimed")
	check(capture.finalizeForShutdown(42, READY).status == "Rejected", "claim is not custody")
	-- A fresh claim replaces an interrupted one without changing instance identity.
	capture.interrupt(42)
	local custody = claimAndCapture(capture, id, 2)
	check(capture.finalizeForShutdown(42, READY).status == "Secured")
	check(candidate.operationId == custody.operationId and candidate.ownerUserId == 42)
	check(candidate.creatureInstanceId == id and capture.state(id) == "Secured")
	check(capture.recordCounts().active == 0 and #capture.activeCustodies() == 0)
	world.stop()
end

local function pendingFinalizationReconcilesAfterResetAndDisconnect()
	local session, repository = profileHarness()
	local admitted: any = nil
	local calls = 0
	local capture, world, clock = captureHarness(function(candidateSession, candidate)
		calls += 1
		if admitted == nil then
			admitted = candidate
		else
			check(candidate == admitted, "retry uses same immutable payload")
		end
		return Finalization.finalize(candidateSession, candidate)
	end)
	local id = check(world.currentId())
	local custody = claimAndCapture(capture, id)
	repository.loseNextResultAfterWrite()
	check(capture.secure(42, SECURE, SECURE, 1, session).status == "OutcomeUnknown")
	check(capture.state(id) == "FinalizationPending" and session.state() == "PersistenceAtRisk")
	check(admitted.operationId == custody.operationId and admitted.securedAt == 1_700_000_000)
	check(table.isfrozen(admitted) and table.isfrozen(admitted.variantIdentity))
	check(table.isfrozen(admitted.origin), "nested operation context is immutable")
	capture.interrupt(42)
	capture.disconnect(42)
	clock.advance(45)
	capture.tick()
	check(capture.state(id) == "FinalizationPending", "uncertain ownership cannot expire")
	check(capture.custody(42) == nil and #capture.activeCustodies() == 0)
	check(capture.begin(42, id, NEAR, 2, {}).status == "Busy")
	check(capture.resume(42, 2, {}).status == "Rejected", "pending is not grace")
	check(capture.reconcile(42, nil).status == "Unavailable")
	check(capture.reconcile(42, session).status == "Secured", "reconciliation needs no avatar")
	local stored = repository.read("player/42").value
	check(stored.profileRevision == 2 and calls == 2, "lost result reconciles exactly once")
	check(stored.collection.creaturesById[id].securedAt == admitted.securedAt)
	check(capture.state(id) == "Secured" and capture.recordCounts().active == 0)
	check(#capture.pendingFinalizations() == 0 and world.populationCount() == 0)
	world.stop()
end

local function pendingFinalizationRetriesUnchangedAfterThrownOutcome()
	local admitted: any = nil
	local capture: any = nil
	local world: any = nil
	local clock: any = nil
	local attempts = 0
	capture, world, clock = captureHarness(function(_, candidate)
		attempts += 1
		if admitted == nil then
			admitted = candidate
			check(capture.reconcile(42, READY).status == "Rejected", "one serialized finalizer")
			capture.interrupt(42)
			capture.disconnect(42)
			error("injected unknown write result")
		end
		check(candidate == admitted and candidate.securedAt == 1_700_000_000)
		return { status = "Secured" }
	end)
	local id = check(world.currentId())
	claimAndCapture(capture, id)
	check(capture.secure(42, SECURE, SECURE, 1, READY).status == "OutcomeUnknown")
	clock.advance(100)
	check(capture.state(id) == "FinalizationPending" and capture.recordCounts().active == 1)
	check(#capture.pendingFinalizations() == 1)
	-- An old request hint cannot force spatial/character re-admission after a
	-- trusted extraction candidate has already entered persistence.
	check(capture.secure(42, nil, nil, 999, READY).status == "Secured")
	check(attempts == 2 and capture.recordCounts().active == 0)
	world.stop()
end

local function terminalCaptureRecordsAreBounded()
	local clock = FakeClock.new(1_700_000_000, 0)
	local states: { [string]: string } = {}
	local ids = 0
	local identity = payload("fixture", "fixture").variantIdentity
	local capture = CaptureService.new({
		world = {
			interaction = function(id)
				return if states[id] == "IdleAvailable" then "Available" else "Unavailable",
					{ position = NEAR }
			end,
			identity = function()
				return {
					speciesId = Fixture.speciesId,
					variantIdentity = identity,
					spawnContextId = Fixture.spawnContextId,
					contentSnapshotId = Fixture.contentSnapshotId,
				}
			end,
			transition = function(id, from, to)
				if states[id] ~= from then
					return false
				end
				states[id] = to
				return true
			end,
			retire = function(id)
				states[id] = nil
			end,
		},
		clock = clock.monotonicClock.seconds,
		unixSeconds = clock.wallClock.unixSeconds,
		newId = function()
			ids += 1
			return "claim-" .. ids
		end,
		random = {
			nextUnit = function()
				return 0.1
			end,
		},
		canInitiate = function()
			return true
		end,
		finalize = function()
			error("expiry must not finalize")
		end,
	})
	for index = 1, 200 do
		local id = "expiry-" .. index
		states[id] = "IdleAvailable"
		check(capture.begin(42, id, NEAR, 1, {}).status == "Claimed")
		clock.advance(20)
		capture.tick()
		check(states[id] == "IdleAvailable")
	end
	check(capture.recordCounts().active == 0 and capture.recordCounts().terminal <= 128)
	check(capture.state("expiry-1") == nil and capture.state("expiry-200") == "Expired")
	-- Repeated attempts on one world instance cannot leave a growing terminal queue.
	for _ = 1, 200 do
		check(capture.begin(42, "expiry-200", NEAR, 1, {}).status == "Claimed")
		capture.interrupt(42)
	end
	check(capture.recordCounts().active == 0 and capture.recordCounts().terminal <= 128)
end

return {
	variantDoesNotRerollOnMaterializationRetry = variantDoesNotRerollOnMaterializationRetry,
	claimAndProvisionalRequireServerContext = claimAndProvisionalRequireServerContext,
	durableFinalizationAndRetry = durableFinalizationAndRetry,
	lostResultReconcilesExactOnce = lostResultReconcilesExactOnce,
	failureBeforeWriteNeverFabricatesOwnership = failureBeforeWriteNeverFabricatesOwnership,
	capacityRaceKeepsExactCreatureInOverflow = capacityRaceKeepsExactCreatureInOverflow,
	transportGraceResumesSameIdentityAndExpires = transportGraceResumesSameIdentityAndExpires,
	resetInterruptsClaimsAndCustodyWithoutOwnership = resetInterruptsClaimsAndCustodyWithoutOwnership,
	controlledShutdownUsesExistingOperationOnly = controlledShutdownUsesExistingOperationOnly,
	pendingFinalizationReconcilesAfterResetAndDisconnect = pendingFinalizationReconcilesAfterResetAndDisconnect,
	pendingFinalizationRetriesUnchangedAfterThrownOutcome = pendingFinalizationRetriesUnchangedAfterThrownOutcome,
	terminalCaptureRecordsAreBounded = terminalCaptureRecordsAreBounded,
}
