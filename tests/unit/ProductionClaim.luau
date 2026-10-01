--!strict

local Energy = require("../../src/server/domains/economy/EnergyService")
local Claim = require("../../src/server/application/ProductionClaimUseCase")
local Production = require("../../src/server/domains/vault/VaultProductionService")
local Assignments = require("../../src/server/application/VaultProductionUseCase")
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

local function check(value: boolean, message: string?)
	assert(value, message or "Energy/claim invariant")
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
	return Wire.equal(a, b)
end
local function fixture(): any
	local p = Schema.default(1000)
	p.profileRevision, p.lastSuccessfulSaveAt = 10, 1000
	p.economy.energyUnits = 73
	check(Vault.new(CapacityConfig).prepare(p).status == "Prepared")
	check(Production.new(Config).prepareLoad(p, 1000).status == "Prepared")
	p.vault.productionBufferMilli = 2350
	return p
end
local function setup(repo: any?, clock: any?, lock: string?, seeded: any?): any
	local repository, fakeClock = repo or Repository.new(), clock or Clock.new(1000, 0)
	local energy, vault, production =
		Energy.new(), Vault.new(CapacityConfig), Production.new(Config)
	local serial = 0
	local function operation(): string
		serial += 1
		return (lock or "first") .. "-operation-" .. serial
	end
	local assignments = Assignments.new({
		production = production,
		vault = vault,
		unixSeconds = fakeClock.wallClock.unixSeconds,
		monotonicSeconds = fakeClock.monotonicClock.seconds,
		newOperationId = operation,
	})
	local claims = Claim.new({
		energy = energy,
		production = production,
		vault = vault,
		assignments = assignments,
		newOperationId = operation,
	})
	if repo == nil then
		repository.seed("player/42", seeded or fixture())
	end
	local loadAt = fakeClock.wallClock.unixSeconds()
	local active = Session.new({
		userId = 42,
		lockId = lock or "first",
		jobId = "claim-test",
		repository = repository,
		schema = Schema,
		prepareProfile = function(p: any): any
			local wallet = energy.prepare(p)
			if wallet.status ~= "Prepared" then
				return wallet
			end
			local prepared = assignments.prepareProfile(p, loadAt)
			prepared.changed = prepared.changed or wallet.changed
			return prepared
		end,
		prepareSave = function(p: any, release: boolean, at: number): any
			local invalid = energy.validate(p)
			if invalid then
				return { status = "Protected", reason = invalid }
			end
			return assignments.prepareSave(p, release, at)
		end,
		queue = Queue.new(fakeClock.monotonicClock.seconds, fakeClock.advance, 10),
		retry = Retry.new(fakeClock.monotonicClock.seconds, fakeClock.advance, function()
			return 0.5
		end, 3),
		unixSeconds = fakeClock.wallClock.unixSeconds,
		monotonicSeconds = fakeClock.monotonicClock.seconds,
	})
	return {
		active = active,
		repo = repository,
		clock = fakeClock,
		energy = energy,
		production = production,
		assignments = assignments,
		claims = claims,
	}
end
local function claim(s: any): any
	return s.claims.claim(s.active, s.active.snapshot().profileRevision)
end
local function produced(s: any)
	check(s.active.checkpoint("server-owned-producer", function(p: any)
		p.collection.creaturesById = {
			producer = {
				creatureInstanceId = "producer",
				ownerUserId = 42,
				speciesId = "species/fixture-orb",
				operationId = "server-capture",
				securedAt = 1000,
				securedSequence = 1,
				locked = true,
				overflowHeld = false,
				origin = { spawnContextId = "spawn/test", contentSnapshotId = "content/test" },
				variantIdentity = {
					speciesRarityId = "rarity/common",
					variantSignature = "variant/test",
					mutationIdsCanonical = {},
					traitIds = {},
					protectedVariantReasons = {},
					spawnContextId = "spawn/test",
					contentSnapshotId = "content/test",
				},
			},
		}
		p.vault.productionAssignments["production/1"] = "producer"
		p.vault.displayAssignments["display/1"] = "producer"
	end).status == "Committed")
end
local function readyClaimSaveRejoin()
	local s = setup()
	check(s.active.acquire().status == "Ready")
	produced(s)
	s.clock.advance(11)
	local before = s.active.snapshot()
	local result = claim(s)
	check(result.status == "Committed" and result.units == 3)
	local p = s.active.snapshot()
	check(p.economy.energyUnits == 76 and p.vault.productionBufferMilli == 450)
	check(p.vault.productionCursorUnixSeconds == 1011)
	check(equal(p.collection, before.collection), "claim preserves exact identity/provenance/lock")
	check(equal(p.vault.productionAssignments, before.vault.productionAssignments))
	check(s.energy.validate(p) == nil and Schema.validate(p))
	check(s.active.renew().status == "Ready")
	check(s.active.release(100).status == "Closed")
	s.clock.advance(19)
	local nextSession = setup(s.repo, s.clock, "second")
	check(nextSession.active.acquire().status == "Ready")
	local restored = nextSession.active.snapshot()
	check(restored.economy.energyUnits == 76 and restored.vault.productionBufferMilli == 2350)
	check(
		nextSession.claims.claim(nextSession.active, before.profileRevision).status
			== "AlreadyCommitted"
	)
	check(
		equal(restored, nextSession.active.snapshot()),
		"old claim never consumes new offline production"
	)
	check(claim(nextSession).units == 2 and nextSession.active.snapshot().economy.energyUnits == 78)
end
local function numericRemainders()
	for _, entry in
		{
			{ 73, 350, 0, 350 },
			{ 999_999_999_999, 2350, 1, 1350 },
			{ 1_000_000_000_000, 2350, 0, 2350 },
			{ 0, 1_000_000_000_000_000, 1_000_000_000_000, 0 },
		}
	do
		local p = fixture()
		p.economy.energyUnits, p.vault.productionBufferMilli = entry[1], entry[2]
		local s = setup(nil, nil, nil, p)
		check(s.active.acquire().status == "Ready")
		local revision = s.active.snapshot().profileRevision
		local result = claim(s)
		check(result.status == "Committed" and result.units == entry[3])
		local saved = s.active.snapshot()
		check(
			saved.economy.energyUnits == entry[1] + entry[3]
				and saved.vault.productionBufferMilli == entry[4]
		)
		check(s.claims.claim(s.active, revision).status == "AlreadyCommitted")
		check(equal(saved, s.active.snapshot()), "zero/partial/full claims remain replay safe")
	end
end
local function uncertainCutPoints()
	for _, after in { false, true } do
		local s = setup()
		check(s.active.acquire().status == "Ready")
		local before = s.active.snapshot()
		if after then
			s.repo.loseNextResultAfterWrite()
		else
			s.repo.failNext({ status = "error", reason = "BEFORE", retryable = false })
		end
		local result = claim(s)
		check(result.status == "OutcomeUnknown" and s.active.state() == "PersistenceAtRisk")
		check(equal(before, s.active.snapshot()), "unknown result keeps the last confirmed view")
		local stored = s.repo.read("player/42").value
		check(stored.economy.energyUnits == (if after then 75 else 73))
		s.clock.advance(130)
		check(s.claims.reconcile(s.active).status == "Unchanged")
		local saved = s.active.snapshot()
		check(saved.economy.energyUnits == 75 and saved.vault.productionBufferMilli == 350)
		check(saved.vault.productionCursorUnixSeconds == 1000, "retain original accepted boundary")
		check(saved.profileRevision == before.profileRevision + 1)
		check(s.claims.claim(s.active, before.profileRevision).operationId == result.operationId)
		check(equal(saved, s.active.snapshot()))
	end
	local s = setup()
	check(s.active.acquire().status == "Ready")
	s.repo.setReplayTransform(true)
	check(claim(s).status == "Committed" and s.active.snapshot().economy.energyUnits == 75)
end
local function unknownDisconnect()
	for _, after in { false, true } do
		local s = setup()
		check(s.active.acquire().status == "Ready")
		local revision = s.active.snapshot().profileRevision
		if after then
			s.repo.loseNextResultAfterWrite()
		else
			s.repo.failNext({ status = "error", reason = "BEFORE", retryable = false })
		end
		check(claim(s).status == "OutcomeUnknown")
		check(s.active.release(100).status == "Closed", "leave reconciles accepted claim first")
		local nextSession = setup(s.repo, s.clock, "second")
		check(nextSession.active.acquire().status == "Ready")
		check(nextSession.active.snapshot().economy.energyUnits == 75)
		check(nextSession.claims.claim(nextSession.active, revision).status == "AlreadyCommitted")
		check(nextSession.active.snapshot().vault.productionBufferMilli == 350)
	end
	-- If the old process dies after commit and before reconciliation, takeover
	-- reads the durable receipt; its new application instance has no pending map.
	local s = setup()
	check(s.active.acquire().status == "Ready")
	local revision = s.active.snapshot().profileRevision
	s.repo.loseNextResultAfterWrite()
	check(claim(s).status == "OutcomeUnknown")
	s.clock.advance(301)
	local fresh = setup(s.repo, s.clock, "takeover")
	check(fresh.active.acquire().status == "Ready")
	check(fresh.claims.claim(fresh.active, revision).status == "AlreadyCommitted")
	check(fresh.active.snapshot().economy.energyUnits == 75)
	check(s.claims.reconcile(s.active).reason == "OWNERSHIP_LOST")
end
local function duplicateAndRace()
	local s = setup()
	check(s.active.acquire().status == "Ready")
	produced(s)
	local revision = s.active.snapshot().profileRevision
	local nestedClaim, nestedAssignment: any = nil, nil
	s.repo.setBeforeTransform(function()
		s.repo.setBeforeTransform(nil)
		nestedClaim = s.claims.claim(s.active, revision)
		nestedAssignment =
			s.assignments.assign(s.active, "production", "production/1", nil, revision)
	end)
	check(claim(s).status == "Committed")
	check(nestedClaim.status == "Busy" and nestedAssignment.status == "Busy")
	local saved = s.active.snapshot()
	s.clock.advance(130)
	check(s.claims.claim(s.active, revision).status == "AlreadyCommitted")
	check(equal(saved, s.active.snapshot()), "replay window expiry cannot claim the new interval")
	check(
		s.assignments.assign(s.active, "production", "production/1", nil, revision).reason
			== "STALE_REVISION"
	)
	check(s.active.checkpoint("capacity-loss", function(p: any)
		local reduced = table.clone(CapacityConfig)
		reduced.baseCollectionCapacity = 0
		local prepared = Vault.new(reduced).prepare(p, s.assignments.settleProfile)
		check(prepared.status == "Prepared")
	end).status == "Committed")
	local held = s.active.snapshot()
	check(
		held.collection.creaturesById.producer.overflowHeld
			and held.collection.creaturesById.producer.locked
	)
	check(
		next(held.vault.productionAssignments) == nil and next(held.vault.displayAssignments) == nil
	)
	check(claim(s).units == 13, "preserved production remains claimable after capacity loss")
	check(s.active.snapshot().vault.productionBufferMilli == 350)
end
local function protectedLoadsAndPrimitive()
	for _, value in { -1, 0.5, math.huge, 1_000_000_000_001, 0 / 0 } do
		local p = fixture()
		p.economy.energyUnits = value
		local s = setup(nil, nil, nil, p)
		check(s.active.acquire().status == "ProtectedLoadFailure")
		local saved = s.repo.read("player/42").value.economy.energyUnits
		check(saved == value or (saved ~= saved and value ~= value))
	end
	for _, key in
		{
			"deferredEnergyGrants",
			"temporaryEnergyGrants",
			"commercialEnergyGrants",
			"recentEnergyOperations",
		}
	do
		local p = fixture()
		p.economy[key] = { unbound = { remainingUnits = 100 } }
		local s = setup(nil, nil, nil, p)
		check(s.active.acquire().status == "ProtectedLoadFailure")
		check(equal(s.repo.read("player/42").value, p), "unbound grants preserve stored value")
	end
	local s = setup()
	check(s.active.acquire().status == "Ready")
	local p = s.active.snapshot()
	for _, delta in { -1, 0.5, math.huge, 1_000_000_000_000 } do
		local candidate = copy(p)
		local result = s.energy.apply(candidate, {
			operationId = "bad",
			reasonCode = "production-claim",
			sourceOrSinkId = "vault/production",
			deltaUnits = delta,
			timestamp = 1000,
			configSnapshotId = "config/test",
			expectedRevision = p.profileRevision,
		})
		check(result.status == "Rejected" and equal(p, candidate))
	end
	check(
		s.energy.apply(copy(p), { reasonCode = "starter-commercial-grant" }).status == "Protected"
	)
	check(claim(s).status == "Committed")
	local saved = s.active.snapshot()
	local duplicate = s.energy.apply(copy(saved), saved.economy.recentEnergyOperations[1])
	check(duplicate.status == "AlreadyApplied")
	local corrupt = copy(saved)
	corrupt.economy.recentEnergyOperations[1].expectedRevision += 1
	local bad = setup(nil, nil, nil, corrupt)
	check(bad.active.acquire().status == "ProtectedLoadFailure")
	check(equal(bad.repo.read("player/42").value, corrupt))
end
local function boundedAudit()
	local s = setup()
	check(s.active.acquire().status == "Ready")
	local oldest = s.active.snapshot().profileRevision
	for _ = 1, 34 do
		check(claim(s).status == "Committed")
	end
	local p = s.active.snapshot()
	check(#p.economy.recentEnergyOperations == 32 and p.economy.energyUnits == 75)
	check(s.energy.validate(p) == nil)
	check(s.claims.claim(s.active, oldest).reason == "STALE_REVISION")
	check(equal(p, s.active.snapshot()), "audit eviction never re-enables an old claim")
end
local function authoritativeReadback()
	check(Contract.validClaim({ claimScope = "All" }, 10))
	for _, payload in
		{
			{ claimScope = "Other" },
			{ claimScope = "All", energyUnits = 99 },
			{ claimScope = "All", ownerUserId = 1 },
			{ claimScope = "All", operationId = "forged" },
			{ claimScope = "All", now = 123, rate = 1000 },
		}
	do
		check(not Contract.validClaim(payload, 10))
	end
	check(not Contract.validClaim({ claimScope = "All" }, nil))
	local s = setup()
	check(s.active.acquire().status == "Ready")
	local snapshot = Projection.fromProfile(s.active.snapshot(), s.production, nil)
	check(Contract.validSnapshot(snapshot) and Wire.payload(snapshot))
	local serial, now, codes, sent = 0, 0, {}, {}
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
				serial += 1
				sent[serial] = { route = route, payload = payload, revision = revision }
				return tostring(serial)
			end,
			resultFor = function(id)
				return codes[id]
			end,
		},
	})
	controller.tick()
	check(controller.handleSnapshot({
		payload = snapshot,
		revision = snapshot.revision,
		correlationId = "1",
	}) == "Applied")
	check(controller.claim() == "2" and sent[2].payload.claimScope == "All")
	check(controller.claim() == nil and not controller.view().canAssign)
	codes["2"] = "OK_VAULT_PRODUCTION_CLAIMED"
	controller.tick()
	check(controller.view().pending and controller.view().snapshot.state.energyUnits == 73)
	check(controller.handleSnapshot({
		payload = snapshot,
		revision = snapshot.revision,
		correlationId = "2",
	}) == "Unconfirmed")
	now = 6
	controller.tick()
	check(sent[3].route == Routes.commands.sessionRequestResync and controller.view().pending)
	check(controller.handleSnapshot({
		payload = snapshot,
		revision = snapshot.revision,
		correlationId = "3",
	}) == "Unconfirmed", "a read while a claim write is in flight cannot infer not-applied")
	check(claim(s).status == "Committed")
	local saved = Projection.fromProfile(s.active.snapshot(), s.production, nil)
	check(controller.handleSnapshot({
		payload = saved,
		revision = saved.revision,
		correlationId = "2",
	}) == "Applied")
	check(not controller.view().pending and controller.view().snapshot.state.energyUnits == 75)
	check(controller.handleSnapshot({
		payload = snapshot,
		revision = snapshot.revision,
		correlationId = "3",
	}) == "Stale")
	local maximum = copy(saved)
	maximum.state.energyUnits, maximum.state.claimUnits = 1_000_000_000_000, 1_000_000_000_000
	maximum.state.creatures = {
		{
			creatureInstanceId = string.rep("x", 128),
			overflowHeld = false,
			locked = true,
			productionSlotId = string.rep("p", 32),
			displaySlotId = string.rep("d", 32),
		},
	}
	check(
		Contract.validSnapshot(maximum) and Wire.payload(maximum),
		"worst-length readback fits reliable budget"
	)
	local busyRequest = controller.claim()
	check(busyRequest == "4")
	codes["4"] = "PENDING_VAULT_CLAIM"
	now = 12
	controller.tick()
	check(controller.view().pending and serial == 5)
	check(controller.handleSnapshot({
		payload = saved,
		revision = saved.revision,
		correlationId = "5",
	}) == "Applied")
	check(
		not controller.view().pending and controller.view().snapshot.state.energyUnits == 75,
		"fresh readback proves a Busy submit was not applied and permits a fresh claim"
	)
end
return {
	readyClaimSaveRejoin = readyClaimSaveRejoin,
	numericRemainders = numericRemainders,
	uncertainCutPoints = uncertainCutPoints,
	unknownDisconnect = unknownDisconnect,
	duplicateAndRace = duplicateAndRace,
	protectedLoadsAndPrimitive = protectedLoadsAndPrimitive,
	boundedAudit = boundedAudit,
	authoritativeReadback = authoritativeReadback,
}
