--!strict

local Production = require("../../src/server/domains/vault/VaultProductionService")
local UseCase = require("../../src/server/application/VaultProductionUseCase")
local Vault = require("../../src/server/domains/vault/VaultService")
local Config = require("../../src/shared/config/VaultProductionFixture")
local CapacityConfig = require("../../src/shared/config/VaultCapacityFixture")
local Schema = require("../../src/server/infrastructure/persistence/ProfileSchemaV1")
local Session = require("../../src/server/infrastructure/persistence/ProfileSession")
local Queue = require("../../src/server/infrastructure/persistence/SingleWriterQueue")
local Retry = require("../../src/server/infrastructure/persistence/RetryPolicy")
local Repository = require("../fixtures/FakeProfileRepository")
local Clock = require("../fixtures/FakeClock")
local Projection = require("../../src/server/application/VaultAssignmentProjection")
local Contract = require("../../src/shared/contracts/VaultAssignmentProjectionV1")
local Controller = require("../../src/client/controllers/VaultAssignmentController")
local Routes = require("../../src/shared/contracts/RouteIds")
local Wire = require("../../src/shared/contracts/WireValidation")

local function check(condition: boolean, message: string?)
	assert(condition, message or "production fixture invariant")
end

local function copy(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local result = {}
	for key, child in value do
		result[key] = copy(child)
	end
	return result
end
local function equal(a: any, b: any): boolean
	if type(a) ~= type(b) then
		return false
	end
	if type(a) ~= "table" then
		return a == b
	end
	for key, child in a do
		if not equal(child, b[key]) then
			return false
		end
	end
	for key in b do
		if a[key] == nil then
			return false
		end
	end
	return true
end
local function fixture(): any
	local p = Schema.default(1000)
	p.profileRevision, p.lastSuccessfulSaveAt = 10, 1000
	p.economy = { energyUnits = 73 }
	p.collection.creaturesById = {}
	for index = 1, 3 do
		local id = "creature-" .. index
		p.collection.creaturesById[id] = {
			creatureInstanceId = id,
			ownerUserId = 42,
			speciesId = "species/fixture-orb",
			operationId = "capture-" .. index,
			securedAt = 1000,
			securedSequence = index,
			locked = true,
			overflowHeld = index == 3,
			origin = { spawnContextId = "spawn/test", contentSnapshotId = "content/test" },
			variantIdentity = {
				speciesRarityId = "rarity/legendary",
				variantSignature = "variant/test",
				mutationIdsCanonical = { "mutation/glow" },
				traitIds = { "trait/test" },
				protectedVariantReasons = { "protected/test" },
				spawnContextId = "spawn/test",
				contentSnapshotId = "content/test",
			},
		}
	end
	check(Vault.new(CapacityConfig).prepare(p).status == "Prepared")
	check(Production.new(Config).prepareLoad(p, 1000).status == "Prepared")
	check(Schema.validate(p))
	return p
end
local function setup(
	repo: any?,
	config: any?,
	clock: any?,
	lock: string?
): (any, any, any, any, any)
	local repository, fakeClock = repo or Repository.new(), clock or Clock.new(1000, 0)
	local production, vault = Production.new(config or Config), Vault.new(CapacityConfig)
	local serial = 0
	local useCase = UseCase.new({
		production = production,
		vault = vault,
		unixSeconds = function()
			return math.floor(fakeClock.wallClock.unixSeconds())
		end,
		monotonicSeconds = fakeClock.monotonicClock.seconds,
		newOperationId = function()
			serial += 1
			return (lock or "session") .. "-assignment-" .. serial
		end,
	})
	if repo == nil then
		repository.seed("player/42", fixture())
	end
	local loadAt = fakeClock.wallClock.unixSeconds()
	local active = Session.new({
		userId = 42,
		lockId = lock or "session",
		jobId = "production-test",
		repository = repository,
		schema = Schema,
		prepareProfile = function(p: any)
			return useCase.prepareProfile(p, loadAt)
		end,
		prepareSave = useCase.prepareSave,
		queue = Queue.new(fakeClock.monotonicClock.seconds, fakeClock.advance, 10),
		retry = Retry.new(fakeClock.monotonicClock.seconds, fakeClock.advance, function()
			return 0.5
		end, 3),
		unixSeconds = function()
			return math.floor(fakeClock.wallClock.unixSeconds())
		end,
		monotonicSeconds = fakeClock.monotonicClock.seconds,
	})
	return active, repository, fakeClock, useCase, production
end
local function set(active: any, useCase: any, kind: string, slot: string, id: string?): any
	return useCase.assign(active, kind, slot, id, active.snapshot().profileRevision)
end

local function canonicalAssignments()
	local active, _, clock, useCase = setup()
	check(active.acquire().status == "Ready")
	local before = copy(active.snapshot().collection)
	check(
		set(active, useCase, "production", "production/1", "creature-1").status == "Committed",
		"locked protected variant may produce"
	)
	check(
		set(active, useCase, "display", "display/1", "creature-1").status == "Committed",
		"display is an independent view"
	)
	check(
		set(active, useCase, "production", "production/2", "creature-1").reason
			== "ALREADY_ASSIGNED",
		"no duplicate production"
	)
	check(
		set(active, useCase, "display", "display/2", "creature-1").reason == "ALREADY_ASSIGNED",
		"no display cloning"
	)
	check(
		set(active, useCase, "production", "production/2", "creature-3").reason == "OVERFLOW_HELD"
	)
	check(set(active, useCase, "display", "display/2", "creature-3").reason == "OVERFLOW_HELD")
	check(set(active, useCase, "production", "production/9", "creature-2").reason == "SLOT_LOCKED")
	check(set(active, useCase, "display", "display/1", "foreign-id").reason == "OWNERSHIP")
	local revision = active.snapshot().profileRevision
	check(
		useCase.assign(active, "production", "production/2", "creature-2", revision - 1).reason
			== "STALE_REVISION"
	)
	clock.advance(13)
	check(set(active, useCase, "production", "production/1", nil).status == "Committed")
	local saved = active.snapshot()
	check(
		saved.vault.productionBufferMilli == 1300 and next(saved.vault.productionAssignments) == nil,
		"unassignment preserves old elapsed output"
	)
	check(
		saved.economy.energyUnits == 73 and equal(saved.collection, before),
		"no reward/ownership/identity/lock changes"
	)
end

local function continuousTimeline()
	local active, repo, clock, useCase = setup()
	repo.setReplayTransform(true)
	check(active.acquire().status == "Ready")
	check(set(active, useCase, "production", "production/1", "creature-1").status == "Committed")
	clock.advance(10.5)
	check(active.renew().status == "Ready")
	check(active.snapshot().vault.productionBufferMilli == 1000)
	clock.advance(0.5)
	check(active.renew().status == "Ready")
	check(
		active.snapshot().vault.productionBufferMilli == 1100,
		"subsecond boundaries cannot lose progress"
	)
	check(active.release(clock.monotonicClock.seconds() + 25).status == "Closed")
	check(repo.read("player/42").value.vault.lastPresenceBoundary == "CleanOffline")
	clock.advance(19)
	local rejoined = setup(repo, nil, clock, "rejoin")
	check(rejoined.acquire().status == "Ready")
	check(
		rejoined.snapshot().vault.productionBufferMilli == 3000,
		"online plus clean offline one timeline"
	)
	check(rejoined.snapshot().vault.lastOfflineSettlement.creditedMilli == 1900)
	local persisted = repo.read("player/42").value.vault.productionBufferMilli
	check(
		rejoined.renew().status == "Ready"
			and rejoined.snapshot().vault.productionBufferMilli == persisted,
		"load cannot replay"
	)
end

local function epochAndCapabilityChanges()
	local config = copy(Config)
	config.epochs[1].bufferCapacityMilli = 10000
	local nextEpoch = copy(config.epochs[1])
	nextEpoch.epochId, nextEpoch.effectiveUnixSeconds, nextEpoch.productionSlotCount =
		"epoch/reduced", 1005, 1
	nextEpoch.bufferCapacityMilli, nextEpoch.ratesMilliBySpeciesId["species/fixture-orb"] =
		1200, 200
	config.epochs[2] = nextEpoch
	local third = copy(nextEpoch)
	third.epochId, third.effectiveUnixSeconds, third.productionSlotCount, third.bufferCapacityMilli =
		"epoch/expanded", 1010, 2, 10000
	config.epochs[3] = third
	local p, production = fixture(), Production.new(config)
	p.vault.productionAssignments =
		{ ["production/1"] = "creature-1", ["production/2"] = "creature-2" }
	p.vault.productionRateEpochId = config.epochs[1].epochId
	local result = production.settle(p, 1015, "Online")
	check(
		result.status == "Prepared" and p.vault.productionBufferMilli == 2200,
		"5s two old producers, reduced cap then 5s one producer"
	)
	check(
		p.vault.productionAssignments["production/2"] == nil,
		"slot reduction never resurrects an ended assignment"
	)
	local again = production.settle(p, 1015, "Online")
	check(not again.changed and again.creditedMilli == 0, "same epoch interval consumed once")
	local q = fixture()
	q.vault.productionRateEpochId = config.epochs[1].epochId
	q.vault.productionBufferMilli = 4000
	q.vault.productionAssignments = { ["production/1"] = "creature-1" }
	check(
		production.settle(q, 1006, "Online").status == "Prepared"
			and q.vault.productionBufferMilli == 4500,
		"cap reduction preserves over-cap accrued output"
	)
end

local function boundedOfflineAndCrash()
	local production = Production.new(Config)
	for _, presence in { "CleanOffline", "Active" } do
		local p = fixture()
		p.vault.productionAssignments["production/1"] = "creature-1"
		p.vault.lastPresenceBoundary = presence
		check(production.prepareLoad(p, 100000).status == "Prepared")
		local seconds = if presence == "CleanOffline" then 7200 else 7380
		check(
			p.vault.productionBufferMilli == seconds * 100
				and p.vault.productionCursorUnixSeconds == 100000
		)
		check(p.vault.lastOfflineSettlement.eligibleSeconds == seconds)
		check(production.settle(p, 100000, "Online").creditedMilli == 0)
	end
	local p = fixture()
	p.vault.productionAssignments["production/1"] = "creature-1"
	p.vault.productionBufferMilli = 1_439_950
	check(production.settle(p, 1020, "Online").creditedMilli == 50, "buffer cap stops accrual")
	check(
		production.settle(p, 999, "Online").clockRegressed
			and p.vault.productionCursorUnixSeconds == 1020,
		"clock regression never rewinds cursor"
	)
	check(production.settle(p, 1020, "Online").creditedMilli == 0)
end

local function monotonicAuthority()
	local active, _, clock, useCase = setup()
	check(active.acquire().status == "Ready")
	check(set(active, useCase, "production", "production/1", "creature-1").status == "Committed")
	clock.advance(5)
	clock.setWall(999999)
	check(
		active.renew().status == "Ready" and active.snapshot().vault.productionBufferMilli == 500,
		"wall jump cannot multiply online production"
	)
	clock.setWall(1)
	clock.advance(5)
	check(
		active.renew().status == "Ready" and active.snapshot().vault.productionBufferMilli == 1000,
		"online progress survives wall regression"
	)
	local p = fixture()
	p.vault.productionAssignments["production/1"] = "creature-1"
	check(Production.new(Config).prepareLoad(p, 900).status == "Prepared")
	check(
		p.vault.productionCursorUnixSeconds == 1000 and p.vault.lastOfflineSettlement.clockRegressed,
		"future persisted cursor protected from replay"
	)
end

local function protectedLoads()
	local mutations = {
		function(p: any)
			p.vault.productionBufferMilli = 0.5
		end,
		function(p: any)
			p.vault.productionRateEpochId = "missing/epoch"
		end,
		function(p: any)
			p.vault.productionAssignments["production/1"] = "foreign"
		end,
		function(p: any)
			p.vault.productionAssignments["production/1"] = "creature-3"
		end,
		function(p: any)
			p.vault.productionAssignments =
				{ ["production/1"] = "creature-1", ["production/2"] = "creature-1" }
		end,
		function(p: any)
			p.commerce.productionGrants = { paid = true }
		end,
		function(p: any)
			p.vault.temporaryProductionGrants = { timed = 100 }
		end,
		function(p: any)
			p.vault.productionAssignments["production/1"] = "creature-1"
			p.collection.creaturesById["creature-1"].activeRoleId = "unbound/role"
		end,
		function(p: any)
			p.vault.productionAssignments["production/1"] = "creature-1"
			p.collection.creaturesById["creature-1"].speciesId = "species/unknown"
		end,
	}
	for _, mutate in mutations do
		local repo, seed = Repository.new(), fixture()
		mutate(seed)
		repo.seed("player/42", seed)
		local active = setup(repo)
		check(
			active.acquire().status == "ProtectedLoadFailure",
			"unprovable production state stays protected"
		)
		check(
			equal(repo.read("player/42").value, seed),
			"protected load must not overwrite progress"
		)
	end
	local config = copy(Config)
	config.epochs[1].ratesMilliBySpeciesId["species/fixture-orb"] = 9_007_199_254_740_991
	check(not pcall(Production.new, config), "inexact rate/window config rejected")
end

local function uncertainAssignmentWrites()
	for _, lostAfter in { false, true } do
		local active, repo, clock, useCase = setup()
		check(active.acquire().status == "Ready")
		clock.advance(10)
		if lostAfter then
			repo.loseNextResultAfterWrite()
		else
			repo.failNext({ status = "error", reason = "BEFORE_WRITE", retryable = false })
		end
		check(
			set(active, useCase, "production", "production/1", "creature-1").status
				== "OutcomeUnknown"
		)
		check(
			active.snapshot().vault.productionAssignments["production/1"] == nil,
			"uncertain result cannot fabricate success"
		)
		clock.advance(15)
		check(useCase.reconcile(active).status == "Unchanged")
		local saved = active.snapshot()
		check(
			saved.vault.productionCursorUnixSeconds == 1010
				and saved.vault.productionBufferMilli == 0,
			"retry reuses original assignment boundary"
		)
		check(saved.vault.productionAssignments["production/1"] == "creature-1")
		check(
			active.renew().status == "Ready"
				and active.snapshot().vault.productionBufferMilli
					== math.floor(clock.monotonicClock.seconds() - 10) * 100,
			"later elapsed production credited once"
		)
	end
end

local function uncertainSavesAndLeave()
	for _, lostAfter in { false, true } do
		local active, repo, clock, useCase = setup()
		check(active.acquire().status == "Ready")
		check(
			set(active, useCase, "production", "production/1", "creature-1").status == "Committed"
		)
		clock.advance(10)
		if lostAfter then
			local first = true
			repo.setBeforeTransform(function()
				if first then
					first = false
					repo.loseNextResultAfterWrite()
					repo.failNext({ status = "error", reason = "LOST_RESULT", retryable = false })
				end
			end)
		else
			repo.failNext({ status = "error", reason = "BEFORE_SAVE", retryable = false })
		end
		check(active.release(clock.monotonicClock.seconds() + 25).status == "PersistenceAtRisk")
		clock.advance(20)
		repo.setBeforeTransform(nil)
		check(active.release(clock.monotonicClock.seconds() + 25).status == "Closed")
		local saved = repo.read("player/42").value
		check(
			saved.vault.productionCursorUnixSeconds == 1010
				and saved.vault.productionBufferMilli == 1000
				and saved.vault.lastPresenceBoundary == "CleanOffline",
			"lost save retains original leave boundary"
		)
		local rejoin = setup(repo, nil, clock, "next-session")
		check(rejoin.acquire().status == "Ready")
		check(
			rejoin.snapshot().vault.productionBufferMilli
				== (math.floor(clock.wallClock.unixSeconds()) - 1000) * 100,
			"offline after lost unlock credited once"
		)
	end
	local active, repo, clock, useCase = setup()
	check(active.acquire().status == "Ready", "late renewal fixture ready")
	check(
		set(active, useCase, "production", "production/1", "creature-1").status == "Committed",
		"late renewal producer saved"
	)
	clock.advance(90)
	repo.failNext({ status = "error", reason = "BEFORE_RENEW", retryable = false })
	check(active.renew().status == "PersistenceAtRisk", "unknown renewal retains candidate")
	clock.advance(200)
	check(
		active.renew().status == "Ready" and active.snapshot().vault.productionBufferMilli == 9000,
		"delayed renewal retry preserves original buffer boundary"
	)
	check(
		active.leaseExpiresAt() == math.floor(clock.wallClock.unixSeconds()) + 300,
		"delayed retry refreshes lease independently from value cursor"
	)
	check(
		active.renew().status == "Ready" and active.snapshot().vault.productionBufferMilli == 29000,
		"remaining online progress survives delayed retry"
	)
end

local function capacitySettlementAndRaces()
	local active, repo, clock, useCase = setup()
	check(active.acquire().status == "Ready")
	check(set(active, useCase, "production", "production/1", "creature-1").status == "Committed")
	clock.advance(10)
	local nested: any = nil
	repo.setBeforeTransform(function()
		nested = set(active, useCase, "production", "production/2", "creature-1")
	end)
	check(set(active, useCase, "display", "display/1", "creature-2").status == "Committed")
	check(
		nested.status == "Rejected" or nested.status == "Busy",
		"concurrent command cannot clone assignments"
	)
	repo.setBeforeTransform(nil)
	check(active.checkpoint("capacity-drop", function(p: any)
		p.vault.capacityBase = { units = 0, sourceId = "migration/imp9-dev-capacity-v1" }
		check(Vault.new(CapacityConfig).prepare(p, useCase.settleProfile).status == "Prepared")
	end).status == "Committed")
	local saved = active.snapshot()
	check(
		saved.vault.productionBufferMilli == 1000 and next(saved.vault.productionAssignments) == nil
	)
	check(
		saved.collection.creaturesById["creature-1"].overflowHeld
			and saved.collection.creaturesById["creature-1"].locked
	)
	clock.advance(10)
	check(
		active.renew().status == "Ready" and active.snapshot().vault.productionBufferMilli == 1000,
		"held creatures never ghost-produce"
	)
end

local function projectionsAndClientReadback()
	local production, p = Production.new(Config), fixture()
	p.vault.productionAssignments["production/1"] = "creature-1"
	local snapshot = Projection.fromProfile(p, production, nil)
	check(Contract.validSnapshot(snapshot) and Wire.payload(snapshot))
	local request, envelopes, codes = 0, {}, {}
	local now = 0
	local controller = Controller.new({
		routes = Routes,
		projection = Contract,
		sessionReady = function()
			return true
		end,
		clock = function()
			return now
		end,
		gateway = {
			send = function(route, payload, revision)
				request += 1
				envelopes[request] = { route = route, payload = payload, revision = revision }
				return tostring(request)
			end,
			resultFor = function(req)
				return codes[req]
			end,
		},
	})
	controller.tick()
	check(controller.handleSnapshot({
		correlationId = "1",
		revision = p.profileRevision,
		payload = snapshot,
	}) == "Applied")
	controller.selectCreature("creature-1")
	local assignment = controller.assign("production", "production/1")
	check(
		assignment == "2" and envelopes[2].payload.creatureInstanceId == nil,
		"unassign is intent only"
	)
	codes["2"] = "OK_VAULT_ASSIGNMENT_SAVED"
	controller.tick()
	check(controller.view().pending, "success result alone cannot change local assignment")
	local stale = copy(snapshot)
	stale.revision -= 1
	check(controller.handleSnapshot({
		correlationId = "2",
		revision = stale.revision,
		payload = stale,
	}) == "Stale")
	p.vault.productionAssignments["production/1"] = nil
	p.profileRevision += 1
	snapshot = Projection.fromProfile(p, production, nil)
	check(controller.handleSnapshot({
		correlationId = "2",
		revision = p.profileRevision,
		payload = snapshot,
	}) == "Applied" and not controller.view().pending)
	check(
		not Contract.validAssignment({ slotId = "production/1", now = 10000, rate = 99 }, 10),
		"no client time/rate/owner authority"
	)
	for index = 1, 3 do
		local old, new = "creature-" .. index, string.rep("x", 127) .. tostring(index)
		local record = p.collection.creaturesById[old]
		p.collection.creaturesById[old] = nil
		record.creatureInstanceId = new
		p.collection.creaturesById[new] = record
	end
	local page = Projection.fromProfile(p, production, nil)
	check(
		Contract.validSnapshot(page) and Wire.payload(page) and page.state.hasMore,
		"maximum ID length has bounded pages"
	)
end

return {
	canonicalAssignments = canonicalAssignments,
	continuousTimeline = continuousTimeline,
	epochAndCapabilityChanges = epochAndCapabilityChanges,
	boundedOfflineAndCrash = boundedOfflineAndCrash,
	monotonicAuthority = monotonicAuthority,
	protectedLoads = protectedLoads,
	uncertainAssignmentWrites = uncertainAssignmentWrites,
	uncertainSavesAndLeave = uncertainSavesAndLeave,
	capacitySettlementAndRaces = capacitySettlementAndRaces,
	projectionsAndClientReadback = projectionsAndClientReadback,
}
