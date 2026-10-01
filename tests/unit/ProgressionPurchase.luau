--!strict

local Energy = require("../../src/server/domains/economy/EnergyService")
local Progression = require("../../src/server/domains/progression/ProgressionService")
local Purchase = require("../../src/server/application/ProgressionPurchaseUseCase")
local Claim = require("../../src/server/application/ProductionClaimUseCase")
local Production = require("../../src/server/domains/vault/VaultProductionService")
local Assignments = require("../../src/server/application/VaultProductionUseCase")
local Vault = require("../../src/server/domains/vault/VaultService")
local Config = require("../../src/shared/config/VaultProductionFixture")
local CapacityConfig = require("../../src/shared/config/VaultCapacityFixture")
local Price = require("../../src/shared/config/ProgressionFixture")
local Schema = require("../../src/server/infrastructure/persistence/ProfileSchemaV1")
local Session = require("../../src/server/infrastructure/persistence/ProfileSession")
local Queue = require("../../src/server/infrastructure/persistence/SingleWriterQueue")
local Retry = require("../../src/server/infrastructure/persistence/RetryPolicy")
local Repository = require("../fixtures/FakeProfileRepository")
local Clock = require("../fixtures/FakeClock")
local Projection = require("../../src/server/application/ProgressionProjection")
local AssignmentProjection = require("../../src/server/application/VaultAssignmentProjection")
local AssignmentContract = require("../../src/shared/contracts/VaultAssignmentProjectionV1")
local Contract = require("../../src/shared/contracts/ProgressionProjectionV1")
local Controller = require("../../src/client/controllers/ProgressionController")
local Routes = require("../../src/shared/contracts/RouteIds")
local Wire = require("../../src/shared/contracts/WireValidation")

local function check(value: boolean, message: string?)
	assert(value, message or "progression invariant")
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
local function fixture(): any
	local p = Schema.default(1000)
	p.profileRevision, p.lastSuccessfulSaveAt = 10, 1000
	p.economy.energyUnits, p.progression.collectionCapacity = 73, 2
	p.collection.creaturesById = {}
	for index = 1, 3 do
		local id = "creature-" .. index
		p.collection.creaturesById[id] = {
			creatureInstanceId = id,
			ownerUserId = 42,
			speciesId = "species/fixture-orb",
			operationId = "captured-" .. index,
			securedAt = 1000,
			securedSequence = index,
			locked = true,
			overflowHeld = index == 3,
			origin = { spawnContextId = "spawn/test", contentSnapshotId = "content/test" },
			variantIdentity = {
				speciesRarityId = "rarity/common",
				variantSignature = "variant/" .. index,
				mutationIdsCanonical = {},
				traitIds = {},
				protectedVariantReasons = {},
				spawnContextId = "spawn/test",
				contentSnapshotId = "content/test",
			},
		}
	end
	p.discovery.speciesById = { ["species/fixture-orb"] = true }
	check(Vault.new(CapacityConfig).prepare(p).status == "Prepared")
	check(Production.new(Config).prepareLoad(p, 1000).status == "Prepared")
	p.vault.productionAssignments["production/1"] = "creature-1"
	p.vault.displayAssignments["display/1"] = "creature-1"
	p.vault.productionBufferMilli = 2350
	return p
end
local function setup(repo: any?, clock: any?, lock: string?, seed: any?, config: any?): any
	local repository, fakeClock = repo or Repository.new(), clock or Clock.new(1000, 0)
	local energy, vault, production, progression =
		Energy.new({ [Price.unlockId] = true }),
		Vault.new(CapacityConfig),
		Production.new(Config),
		Progression.new(config or Price)
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
	local purchases = Purchase.new({
		progression = progression,
		energy = energy,
		vault = vault,
		assignments = assignments,
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
		repository.seed("player/42", seed or fixture())
	end
	local at = fakeClock.wallClock.unixSeconds()
	local active = Session.new({
		userId = 42,
		lockId = lock or "first",
		jobId = "purchase-test",
		repository = repository,
		schema = Schema,
		prepareProfile = function(p: any): any
			local wallet = energy.prepare(p)
			if wallet.status ~= "Prepared" then
				return wallet
			end
			local prepared = assignments.prepareProfile(p, at)
			if prepared.status ~= "Prepared" then
				return prepared
			end
			local unlocks = progression.prepare(p)
			if unlocks.status ~= "Prepared" then
				return unlocks
			end
			prepared.changed = prepared.changed or wallet.changed or unlocks.changed
			return prepared
		end,
		prepareSave = function(p: any, release: boolean, mono: number): any
			local invalid = energy.validate(p) or progression.validate(p)
			if invalid then
				return { status = "Protected", reason = invalid }
			end
			return assignments.prepareSave(p, release, mono)
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
		vault = vault,
		production = production,
		progression = progression,
		purchases = purchases,
		claims = claims,
		assignments = assignments,
	}
end
local function quote(s: any): any
	local result = s.purchases.quote(s.active)
	check(result.status == "Quoted", result.reason)
	return result.quote
end
local function payload(q: any): any
	return { unlockId = q.unlockId, quoteId = q.quoteId, quoteRevision = q.quoteRevision }
end
local function buy(s: any, q: any): any
	return s.purchases.purchase(s.active, payload(q), q.expectedRevision)
end
local function quotePurchaseSaveRejoin()
	local s = setup()
	check(s.active.acquire().status == "Ready")
	local before = s.active.snapshot()
	local q = quote(s)
	check(q.priceUnits == 25 and q.expectedRevision == before.profileRevision)
	check(quote(s).quoteId == q.quoteId, "refresh retains open confirmation")
	check(buy(s, q).status == "Committed")
	local p = s.active.snapshot()
	check(p.economy.energyUnits == 48 and s.vault.collectionStatus(p).capacity == 8)
	check(p.profileRevision == before.profileRevision + 1)
	check(Wire.equal(p.collection, before.collection) and Wire.equal(p.discovery, before.discovery))
	check(
		p.collection.creaturesById["creature-3"].overflowHeld,
		"capacity purchase cannot auto-resolve Held"
	)
	check(Wire.equal(p.vault.productionAssignments, before.vault.productionAssignments))
	check(Wire.equal(p.vault.displayAssignments, before.vault.displayAssignments))
	check(p.vault.productionBufferMilli == before.vault.productionBufferMilli)
	check(s.energy.validate(p) == nil and s.progression.validate(p) == nil and Schema.validate(p))
	check(s.active.renew().status == "Ready")
	check(s.active.release(100).status == "Closed")
	s.clock.advance(19)
	local changed = table.clone(Price)
	changed.priceUnits, changed.quoteRevision, changed.configSnapshotId = 90, 2, "config/rebalanced"
	local fresh = setup(s.repo, s.clock, "second", nil, changed)
	check(fresh.active.acquire().status == "Ready")
	local restored = fresh.active.snapshot()
	check(
		restored.economy.energyUnits == 48 and fresh.vault.collectionStatus(restored).capacity == 8
	)
	check(
		Wire.equal(restored.progression, p.progression)
			and Wire.equal(restored.collection, p.collection)
	)
	check(restored.vault.productionBufferMilli == 4250, "ordinary offline settlement is unchanged")
	check(buy(fresh, q).status == "AlreadyCommitted")
	check(
		Wire.equal(restored, fresh.active.snapshot()),
		"reconnect old quote does not charge again"
	)
end
local function rejectionNoMutation()
	for _, entry in { { energy = 24 }, { missing = true }, { owned = true } } :: { any } do
		local p = fixture()
		if entry.energy then
			p.economy.energyUnits = entry.energy
		end
		if entry.missing then
			p.discovery.speciesById = {}
		end
		if entry.owned then
			p.vault.earnedUpgradeLevels = { [Price.upgradeId] = 1 }
		end
		local s = setup(nil, nil, nil, p)
		check(s.active.acquire().status == "Ready")
		local before = s.active.snapshot()
		local qResult = s.purchases.quote(s.active)
		local q = qResult.quote
			or {
				unlockId = Price.unlockId,
				quoteId = "invented",
				quoteRevision = 1,
				expectedRevision = before.profileRevision,
			}
		local result = buy(s, q)
		check(
			result.reason
				== (
					if entry.energy
						then "INSUFFICIENT_ENERGY"
						else if entry.missing then "MISSING_MILESTONE" else "ALREADY_OWNED"
				)
		)
		check(Wire.equal(before, s.active.snapshot()))
	end
	local s = setup()
	check(s.active.acquire().status == "Ready")
	local q, before = quote(s), s.active.snapshot()
	for _, field in
		{
			"priceUnits",
			"ownerUserId",
			"operationId",
			"milestones",
			"targetLevel",
			"configSnapshotId",
		}
	do
		local forged = payload(q)
		forged[field] = 0
		check(not Contract.validPurchase(forged, q.expectedRevision))
		check(
			s.purchases.purchase(s.active, forged, q.expectedRevision).reason == "INVALID_PURCHASE"
		)
	end
	local forged = payload(q)
	forged.unlockId = "access/unbound"
	check(s.purchases.purchase(s.active, forged, q.expectedRevision).reason == "INVALID_UNLOCK")
	check(Wire.equal(before, s.active.snapshot()))
	check(not Contract.validPurchase(payload(q), nil))
	local full = fixture()
	full.vault.capacityBase.units = 2048
	local limit = setup(nil, nil, "limit", full)
	check(limit.active.acquire().status == "Ready")
	local saved = limit.active.snapshot()
	check(buy(limit, quote(limit)).reason == "CAPACITY_LIMIT")
	check(
		Wire.equal(saved, limit.active.snapshot()),
		"invalid effect cannot persist a staged debit"
	)
end
local function staleTamperAndIsolation()
	local s = setup()
	check(s.active.acquire().status == "Ready")
	local q, before = quote(s), s.active.snapshot()
	local forged = payload(q)
	forged.quoteId = "forged"
	check(s.purchases.purchase(s.active, forged, q.expectedRevision).reason == "STALE_QUOTE")
	forged = payload(q)
	forged.quoteRevision += 1
	check(s.purchases.purchase(s.active, forged, q.expectedRevision).reason == "STALE_QUOTE")
	q.priceUnits = 0 -- Quote response is a copy of the stored server quote.
	local other = setup(nil, nil, "other")
	check(other.active.acquire().status == "Ready")
	check(buy(other, q).reason == "STALE_QUOTE", "quote belongs to one session")
	s.clock.advance(60)
	check(buy(s, q).reason == "STALE_QUOTE" and Wire.equal(before, s.active.snapshot()))
	local fresh = quote(s)
	check(fresh.quoteId ~= q.quoteId)
	check(s.claims.claim(s.active, fresh.expectedRevision).status == "Committed")
	check(buy(s, fresh).reason == "STALE_QUOTE", "claim invalidates open quote revision")
	local priced = quote(s)
	local original = s.progression.definition()
	local repriced = table.clone(original)
	repriced.priceUnits, repriced.quoteRevision, repriced.configSnapshotId = 26, 2, "config/new"
	s.progression.definition = function()
		return repriced
	end
	check(buy(s, priced).reason == "STALE_QUOTE")
	local reQuote = quote(s)
	check(reQuote.priceUnits == 26 and reQuote.quoteRevision == 2)
	check(buy(s, reQuote).status == "Committed")
	check(
		s.active.snapshot().economy.energyUnits == 55,
		"server price including previous claim used"
	)
end
local function uncertainCutPoints()
	for _, after in { false, true } do
		local s = setup()
		check(s.active.acquire().status == "Ready")
		local q, before = quote(s), s.active.snapshot()
		if after then
			s.repo.loseNextResultAfterWrite()
		else
			s.repo.failNext({ status = "error", reason = "BEFORE", retryable = false })
		end
		local result = buy(s, q)
		check(result.status == "OutcomeUnknown")
		check(Wire.equal(before, s.active.snapshot()), "unknown never projects staged debit")
		local stored = s.repo.read("player/42").value
		check(stored.economy.energyUnits == (if after then 48 else 73))
		check(
			(stored.vault.earnedUpgradeLevels or {})[Price.upgradeId] == (if after then 1 else nil)
		)
		s.clock.advance(121)
		s.repo.setReplayTransform(true)
		check(
			buy(s, q).status == "AlreadyCommitted",
			"admitted candidate outlives quote expiration"
		)
		local p = s.active.snapshot()
		check(p.economy.energyUnits == 48 and p.profileRevision == before.profileRevision + 1)
		check(p.progression.purchasesByUnlockId[Price.unlockId].operationId == result.operationId)
		check(buy(s, q).status == "AlreadyCommitted" and Wire.equal(p, s.active.snapshot()))
	end
end
local function duplicateRaceAndClaim()
	local s = setup()
	check(s.active.acquire().status == "Ready")
	check(s.claims.claim(s.active, s.active.snapshot().profileRevision).status == "Committed")
	local q, before = quote(s), s.active.snapshot()
	local nestedPurchase, nestedClaim, nestedAssignment: any = nil, nil, nil
	s.repo.setBeforeTransform(function()
		s.repo.setBeforeTransform(nil)
		nestedPurchase = buy(s, q)
		nestedClaim = s.claims.claim(s.active, q.expectedRevision)
		nestedAssignment =
			s.assignments.assign(s.active, "production", "production/1", nil, q.expectedRevision)
	end)
	check(buy(s, q).status == "Committed")
	check(
		nestedPurchase.status == "Busy"
			and nestedClaim.status == "Busy"
			and nestedAssignment.status == "Busy"
	)
	local p = s.active.snapshot()
	check(p.economy.energyUnits == 50 and p.profileRevision == before.profileRevision + 1)
	check(buy(s, q).status == "AlreadyCommitted")
	local assignment = AssignmentProjection.fromProfile(p, s.production, nil)
	check(AssignmentContract.validSnapshot(assignment) and assignment.state.claimUnits == 2)
	check(
		assignment.state.claimExpectedRevision
			== before.economy.recentEnergyOperations[1].expectedRevision,
		"sink must never masquerade as a claim"
	)
	check(s.claims.claim(s.active, q.expectedRevision).reason == "STALE_REVISION")
	check(Wire.equal(p, s.active.snapshot()))
end
local function unknownDisconnectAndTakeover()
	for _, after in { false, true } do
		local s = setup()
		check(s.active.acquire().status == "Ready")
		local q = quote(s)
		if after then
			s.repo.loseNextResultAfterWrite()
		else
			s.repo.failNext({ status = "error", reason = "BEFORE", retryable = false })
		end
		check(buy(s, q).status == "OutcomeUnknown")
		check(s.active.release(100).status == "Closed")
		local fresh = setup(s.repo, s.clock, "second")
		check(fresh.active.acquire().status == "Ready")
		check(
			buy(fresh, q).status == "AlreadyCommitted"
				and fresh.active.snapshot().economy.energyUnits == 48
		)
	end
	local s = setup()
	check(s.active.acquire().status == "Ready")
	local q = quote(s)
	s.repo.loseNextResultAfterWrite()
	check(buy(s, q).status == "OutcomeUnknown")
	s.clock.advance(301)
	local fresh = setup(s.repo, s.clock, "takeover")
	check(fresh.active.acquire().status == "Ready")
	check(
		buy(fresh, q).status == "AlreadyCommitted"
			and fresh.active.snapshot().economy.energyUnits == 48
	)
	check(s.purchases.reconcile(s.active).reason == "OWNERSHIP_LOST")
	-- A crash before any durable write owns no outcome; the expired session quote cannot be re-admitted.
	local b = setup()
	check(b.active.acquire().status == "Ready")
	local old = quote(b)
	b.repo.failNext({ status = "error", reason = "BEFORE", retryable = false })
	check(buy(b, old).status == "OutcomeUnknown")
	b.clock.advance(301)
	local nextSession = setup(b.repo, b.clock, "takeover")
	check(nextSession.active.acquire().status == "Ready")
	check(
		buy(nextSession, old).reason == "STALE_QUOTE"
			and nextSession.active.snapshot().economy.energyUnits == 73
	)
	check(buy(nextSession, quote(nextSession)).status == "Committed")
end
local function protectedLoadsAndAuditEviction()
	for _, kind in { "unversioned", "badVersion", "unbound", "receipt", "deferred" } do
		local p = fixture()
		if kind == "unversioned" then
			p.progression.purchasesByUnlockId = { paid = { priceUnits = 10 } }
		elseif kind == "badVersion" then
			p.progression.progressionSchemaVersion = 2
		elseif kind == "unbound" then
			p.progression.milestones = { unbound = true }
		elseif kind == "receipt" then
			p.progression.progressionSchemaVersion, p.progression.purchasesByUnlockId =
				1, { [Price.unlockId] = { priceUnits = 25 } }
		else
			p.economy.deferredEnergyGrants = { grant = { remainingUnits = 10 } }
		end
		local s = setup(nil, nil, nil, p)
		check(s.active.acquire().status == "ProtectedLoadFailure")
		check(Wire.equal(s.repo.read("player/42").value, p), "protected stored value unchanged")
	end
	local s = setup()
	check(s.active.acquire().status == "Ready")
	local q = quote(s)
	check(buy(s, q).status == "Committed")
	for _ = 1, 34 do
		check(s.claims.claim(s.active, s.active.snapshot().profileRevision).status == "Committed")
	end
	local p = s.active.snapshot()
	check(
		#p.economy.recentEnergyOperations == 32
			and s.energy.validate(p) == nil
			and s.progression.validate(p) == nil
	)
	check(
		buy(s, q).status == "AlreadyCommitted" and Wire.equal(p, s.active.snapshot()),
		"unlock receipt survives audit eviction"
	)
	local corrupt = copy(p)
	corrupt.progression.purchasesByUnlockId[Price.unlockId].expectedRevision += 1
	local bad = setup(nil, nil, nil, corrupt)
	check(bad.active.acquire().status == "ProtectedLoadFailure")
end
local function authoritativeReadback()
	local s = setup()
	check(s.active.acquire().status == "Ready")
	local q = quote(s)
	local snap = Projection.fromProfile(s.active.snapshot(), s.progression, s.vault, q)
	check(Contract.validSnapshot(snap) and Wire.payload(snap))
	local sent, codes, serial, now = {}, {}, 0, 0
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
			send = function(route: string, body: any, revision: number?): string
				serial += 1
				local request = "request-" .. serial
				table.insert(
					sent,
					{ requestId = request, route = route, payload = body, revision = revision }
				)
				return request
			end,
			resultFor = function(request: string): string?
				return codes[request]
			end,
		},
	})
	controller.tick()
	check(controller.handleSnapshot({
		payload = snap,
		revision = snap.revision,
		correlationId = sent[#sent].requestId,
	}) == "Applied")
	check(controller.confirm() == nil, "explicit review required")
	controller.review()
	local request = controller.confirm()
	check(request ~= nil and controller.view().pending and sent[#sent].payload.quoteId == q.quoteId)
	codes[request] = "OK_PROGRESSION_PURCHASED"
	now = 6
	controller.tick()
	check(controller.view().pending, "ack and timeout cannot debit or infer unlock")
	check(controller.handleSnapshot({
		payload = snap,
		revision = snap.revision,
		correlationId = sent[#sent].requestId,
	}) == "Unconfirmed")
	check(buy(s, q).status == "Committed")
	local saved = Projection.fromProfile(s.active.snapshot(), s.progression, s.vault, nil)
	check(Contract.validSnapshot(saved) and Wire.payload(saved))
	check(controller.handleSnapshot({
		payload = saved,
		revision = saved.revision,
		correlationId = sent[#sent].requestId,
	}) == "Applied")
	check(
		not controller.view().pending
			and controller.view().snapshot.state.energyUnits == 48
			and not controller.view().canReview
	)
	-- Busy proves non-admission only after correlated authoritative readback.
	local fresh = setup(nil, nil, "busy")
	check(fresh.active.acquire().status == "Ready")
	local idle = Projection.fromProfile(
		fresh.active.snapshot(),
		fresh.progression,
		fresh.vault,
		quote(fresh)
	)
	local serial2 = 0
	local busyCodes = {}
	local c = Controller.new({
		routes = Routes,
		projection = Contract,
		sessionReady = function()
			return true
		end,
		clock = function()
			return now
		end,
		gateway = {
			send = function(): string
				serial2 += 1
				return "busy-" .. serial2
			end,
			resultFor = function(key: string): string?
				return busyCodes[key]
			end,
		},
	})
	c.tick()
	check(
		c.handleSnapshot({ payload = idle, revision = idle.revision, correlationId = "busy-1" })
			== "Applied"
	)
	c.review()
	local r = c.confirm()
	busyCodes[r] = "PENDING_PROGRESSION_PURCHASE"
	now += 6
	c.tick()
	check(c.view().pending)
	check(
		c.handleSnapshot({ payload = idle, revision = idle.revision, correlationId = "busy-3" })
			== "Applied"
	)
	check(not c.view().pending and not c.view().canConfirm)
end
return {
	quotePurchaseSaveRejoin = quotePurchaseSaveRejoin,
	rejectionNoMutation = rejectionNoMutation,
	staleTamperAndIsolation = staleTamperAndIsolation,
	uncertainCutPoints = uncertainCutPoints,
	duplicateRaceAndClaim = duplicateRaceAndClaim,
	unknownDisconnectAndTakeover = unknownDisconnectAndTakeover,
	protectedLoadsAndAuditEviction = protectedLoadsAndAuditEviction,
	authoritativeReadback = authoritativeReadback,
}
