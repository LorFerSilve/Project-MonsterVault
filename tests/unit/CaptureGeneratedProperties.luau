--!strict

-- A fixed seed generates independent capture histories. On failure, the case
-- number and action history are enough to replay the exact sequence.
local Fixture = require("../../src/server/domains/world/FixtureDefinition")
local WorldService = require("../../src/server/domains/world/WorldService")
local VariantIdentity = require("../../src/server/domains/capture/VariantIdentity")
local CaptureService = require("../../src/server/domains/capture/CaptureService")
local Finalization = require("../../src/server/application/CaptureFinalizationUseCase")
local ProfileSession = require("../../src/server/infrastructure/persistence/ProfileSession")
local ProfileSchema = require("../../src/server/infrastructure/persistence/ProfileSchemaV1")
local Queue = require("../../src/server/infrastructure/persistence/SingleWriterQueue")
local Retry = require("../../src/server/infrastructure/persistence/RetryPolicy")
local FakeClock = require("../fixtures/FakeClock")
local FakeRepository = require("../fixtures/FakeProfileRepository")
local FakeRandom = require("../fixtures/FakeRandomSource")

local SEED = 2307
local CASES = 1000
local OWNER = 42
local NEAR = { x = 0, y = 3, z = -16 }
local FAR = { x = 999, y = 3, z = 999 }
local SECURE = { x = 0, y = 0, z = 10 }

local function runCase(caseNumber: number, choices: any, steps: { string }): boolean
	local function step(name: string)
		table.insert(steps, name)
	end
	local clock = FakeClock.new(1_700_000_000, 0)
	local repository = FakeRepository.new()
	local session = ProfileSession.new({
		userId = OWNER,
		lockId = "property-owner",
		jobId = "property-job",
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
	assert(session.acquire().status == "Ready", "fixture profile acquired")

	local variantRandom = FakeRandom.fromSeed(100_000 + caseNumber)
	local materializationAttempts = 0
	local failFirstMaterialization = choices.nextUnit() < 0.25
	local creatureId = "creature-" .. tostring(caseNumber)
	local world = WorldService.new({
		fixture = Fixture,
		clock = clock.monotonicClock.seconds,
		newId = function()
			return creatureId
		end,
		generateVariant = function()
			return VariantIdentity.generate(Fixture, variantRandom)
		end,
		materialize = function()
			materializationAttempts += 1
			if failFirstMaterialization and materializationAttempts == 1 then
				return nil
			end
			return {}
		end,
		activate = function() end,
		destroyProjection = function() end,
	})
	local worldGeneration = world.start()
	step("materialize")
	world.step(worldGeneration)
	local identity = world.identity(creatureId)
	assert(identity ~= nil, "server reserved one creature")
	local variant = identity.variantIdentity
	if failFirstMaterialization then
		assert(world.currentId() == creatureId, "retry keeps runtime ID")
		clock.advance(2)
		world.step(worldGeneration)
		assert(world.identity(creatureId).variantIdentity == variant, "retry keeps Variant")
	end
	assert(world.interaction(creatureId, NEAR) == "Available", "creature materialized")
	assert(variantRandom.draws() == 2, "Variant generated once")

	local newIds = 0
	local captureDraws = 0
	local firstRoll = choices.nextUnit()
	local admitted: any = nil
	local finalizationCalls = 0
	local capture = CaptureService.new({
		world = world,
		clock = clock.monotonicClock.seconds,
		unixSeconds = clock.wallClock.unixSeconds,
		newId = function()
			newIds += 1
			return "capture-" .. tostring(caseNumber) .. "-" .. tostring(newIds)
		end,
		random = {
			nextUnit = function()
				captureDraws += 1
				return if captureDraws == 1 then firstRoll else 0.1
			end,
		},
		canInitiate = Finalization.canInitiate,
		finalize = function(activeSession, candidate)
			finalizationCalls += 1
			if admitted == nil then
				admitted = candidate
			else
				assert(candidate == admitted, "retry keeps immutable operation payload")
			end
			return Finalization.finalize(activeSession, candidate)
		end,
	})

	step("hostile-claim")
	assert(
		capture.begin(OWNER, "forged-creature", NEAR, 1, session.snapshot()).status ~= "Claimed",
		"unknown creature denied"
	)
	assert(
		capture.begin(OWNER, creatureId, FAR, 1, session.snapshot()).status ~= "Claimed",
		"distant claim denied"
	)
	local generation = 1
	local claim = capture.begin(OWNER, creatureId, NEAR, generation, session.snapshot())
	assert(claim.status == "Claimed", "owner claims fixture")
	assert(
		capture.begin(43, creatureId, NEAR, 1, session.snapshot()).status ~= "Claimed",
		"second owner denied"
	)
	assert(
		capture.submit(43, claim.captureSessionId, "capture", 1, NEAR, generation).status
			== "Rejected",
		"foreign submit denied"
	)
	assert(
		capture.submit(OWNER, "forged-session", "capture", 1, NEAR, generation).status == "Rejected",
		"forged session denied"
	)
	assert(
		capture.submit(OWNER, claim.captureSessionId, "capture", 2, NEAR, generation).status
			== "Rejected",
		"wrong sequence denied"
	)

	local invalidation = choices.nextUnit()
	if invalidation < 0.5 then
		step("invalidate-and-reclaim")
		local wrongGeneration = invalidation < 0.25
		local result = capture.submit(
			OWNER,
			claim.captureSessionId,
			"capture",
			1,
			if wrongGeneration then NEAR else FAR,
			if wrongGeneration then generation + 1 else generation
		)
		assert(result.status == "Invalidated", "bad server context invalidates claim")
		assert(
			repository.read("player/42").value.collection.creaturesById == nil,
			"invalidation cannot grant ownership"
		)
		generation += 1
		local renewed = capture.begin(OWNER, creatureId, NEAR, generation, session.snapshot())
		assert(
			renewed.status == "Claimed" and renewed.captureSessionId ~= claim.captureSessionId,
			"new claim identity"
		)
		claim = renewed
		assert(world.identity(creatureId).variantIdentity == variant, "reclaim cannot reroll")
	end

	step("capture")
	local provisional =
		capture.submit(OWNER, claim.captureSessionId, "capture", 1, NEAR, generation)
	if provisional.status == "Failed" then
		assert(
			repository.read("player/42").value.collection.creaturesById == nil,
			"failed roll cannot grant ownership"
		)
		assert(
			world.identity(creatureId).variantIdentity == variant,
			"failed attempt cannot reroll"
		)
		step("retry-failed-attempt")
		claim = capture.begin(OWNER, creatureId, NEAR, generation, session.snapshot())
		assert(claim.status == "Claimed", "failed attempt releases creature")
		provisional = capture.submit(OWNER, claim.captureSessionId, "capture", 1, NEAR, generation)
	end
	assert(provisional.status == "TransportActive", "generated history reaches custody")
	local custody = capture.custody(OWNER)
	assert(custody ~= nil and custody.operationId ~= nil, "server creates operation")
	local idsAtCustody = newIds
	local drawsAtCustody = captureDraws
	local duplicateCount = 1 + math.floor(choices.nextUnit() * 4)
	for _ = 1, duplicateCount do
		local duplicate =
			capture.submit(OWNER, claim.captureSessionId, "capture", 1, NEAR, generation)
		assert(
			duplicate.status == "TransportActive" and duplicate.custodyId == custody.custodyId,
			"duplicate custody stable"
		)
	end
	assert(newIds == idsAtCustody and captureDraws == drawsAtCustody, "duplicates do not reroll")
	assert(
		capture.secure(43, SECURE, SECURE, generation, session).status == "Rejected",
		"foreign extraction denied"
	)
	assert(
		capture.secure(OWNER, FAR, SECURE, generation, session).status == "Rejected",
		"remote extraction denied"
	)
	assert(
		repository.read("player/42").value.collection.creaturesById == nil,
		"custody is not ownership"
	)

	local fault = math.floor(choices.nextUnit() * 3)
	if fault == 1 then
		step("lost-result-after-write")
		repository.loseNextResultAfterWrite()
	elseif fault == 2 then
		step("failure-before-write")
		for _ = 1, 3 do
			repository.failNext({ status = "error", reason = "TRANSIENT", retryable = true })
		end
	end
	step("secure")
	local result = capture.secure(OWNER, SECURE, SECURE, generation, session)
	if fault ~= 0 then
		assert(result.status == "OutcomeUnknown", "fault cannot fabricate success")
		assert(capture.state(creatureId) == "FinalizationPending", "operation stays pending")
		if fault == 2 then
			assert(
				repository.read("player/42").value.collection.creaturesById == nil,
				"pre-write failure has no ownership"
			)
		end
		step("reconcile")
		result = capture.reconcile(OWNER, session)
	end
	assert(result.status == "Secured", "durable reconciliation succeeds")
	assert(
		admitted ~= nil and admitted.operationId == custody.operationId,
		"same server operation finalized"
	)
	assert(
		admitted.creatureInstanceId == creatureId and admitted.ownerUserId == OWNER,
		"candidate identity and owner"
	)
	assert(
		admitted.variantIdentity.variantSignature == variant.variantSignature,
		"candidate Variant unchanged"
	)
	assert(
		table.isfrozen(admitted) and table.isfrozen(admitted.variantIdentity),
		"candidate immutable"
	)
	assert(newIds == idsAtCustody and variantRandom.draws() == 2, "retry preserves all IDs")
	local stored = repository.read("player/42").value
	local creatures = stored.collection.creaturesById
	local count = 0
	for _ in creatures do
		count += 1
	end
	assert(
		count == 1 and creatures[creatureId].operationId == custody.operationId,
		"exactly one durable creature"
	)
	assert(
		creatures[creatureId].variantIdentity.variantSignature == variant.variantSignature,
		"durable Variant unchanged"
	)
	assert(
		stored.profileRevision == 2 and capture.state(creatureId) == "Secured",
		"one P2 revision"
	)
	assert(world.populationCount() == 0 and capture.recordCounts().active == 0, "terminal cleanup")

	step("replay-and-foreign-owner")
	local writes = repository.calls()
	assert(
		Finalization.finalize(session, admitted).status == "Secured",
		"replay returns durable fact"
	)
	local foreign = table.clone(admitted)
	foreign.ownerUserId = 43
	assert(Finalization.finalize(session, foreign).status == "Rejected", "foreign owner denied")
	assert(
		repository.calls() == writes and repository.read("player/42").value.profileRevision == 2,
		"replay cannot write twice"
	)
	assert(
		capture.secure(OWNER, SECURE, SECURE, generation, session).status == "Rejected",
		"terminal extraction denied"
	)
	assert(capture.reconcile(OWNER, session).status == "Rejected", "terminal reconciliation denied")
	assert(finalizationCalls == (if fault == 0 then 1 else 2), "one or two finalization attempts")
	world.stop()
	return true
end

local function generatedCaptureHistoriesPreserveIdentityAndOwnership()
	local choices = FakeRandom.fromSeed(SEED)
	for caseNumber = 1, CASES do
		local steps: { string } = {}
		local ok, failure = pcall(runCase, caseNumber, choices, steps)
		if not ok then
			error(
				"seed="
					.. tostring(SEED)
					.. " case="
					.. tostring(caseNumber)
					.. " sequence="
					.. table.concat(steps, ",")
					.. " cause="
					.. tostring(failure),
				2
			)
		end
	end
end

return {
	generatedCaptureHistoriesPreserveIdentityAndOwnership = generatedCaptureHistoriesPreserveIdentityAndOwnership,
}
