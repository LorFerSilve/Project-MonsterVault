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
local Capture = require("../../src/server/domains/capture/CaptureService")
local World = require("../../src/server/domains/world/WorldService")
local CreatureFixture = require("../../src/server/domains/world/FixtureDefinition")
local Variant = require("../../src/server/domains/capture/VariantIdentity")
local RouteRegistry = require("../../src/server/application/RouteRegistry")
local Capacity = require("../../src/server/application/VaultCapacityUseCase")
local Finalization = require("../../src/server/application/CaptureFinalizationUseCase")

local function check(value: boolean, message: string?)
	assert(value, debug.traceback(message or "progression invariant", 2))
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
local function setup(
	repo: any?,
	clock: any?,
	lock: string?,
	seed: any?,
	config: any?,
	authorities: any?
): any
	local repository, fakeClock = repo or Repository.new(), clock or Clock.new(1000, 0)
	local progression = Progression.new(config or Price, authorities)
	local energy, vault, production =
		Energy.new(progression.boundSinks), Vault.new(CapacityConfig), Production.new(Config)
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
		production = production,
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
	local presentationReceipts = {}
	local controller: any = nil
	controller = Controller.new({
		onPurchaseConfirmed = function(state: any)
			table.insert(presentationReceipts, {
				state.receiptPriceUnits,
				state.energyUnits,
				state.unlockId,
				not controller.view().pending
					and controller.view().snapshot.state.energyUnits == state.energyUnits,
			})
			error("cosmetic renderer unavailable") -- Saved purchase must still settle.
		end,
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
	check(#presentationReceipts == 0, "initial readback cannot celebrate an old receipt")
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
	check(#presentationReceipts == 0, "unconfirmed readback cannot celebrate a purchase")
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
	check(
		#presentationReceipts == 1
			and presentationReceipts[1][1] == 25
			and presentationReceipts[1][2] == 48
			and presentationReceipts[1][4],
		"only the matching saved purchase supplies its exact receipt after settlement"
	)
	controller.handleSnapshot({
		payload = saved,
		revision = saved.revision,
		correlationId = sent[#sent].requestId,
	})
	check(#presentationReceipts == 1, "replayed purchase readback cannot duplicate the payoff")
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
local function catalogSetup(proofs: any?): any
	local seed = fixture()
	seed.economy.energyUnits = 2000 -- Isolated server fixture, never a runtime grant.
	local s = setup(nil, nil, nil, seed, nil, proofs and {
		mastery = function(_profile: any, milestone: string): boolean
			return proofs[milestone] == true
		end,
	})
	check(s.active.acquire().status == "Ready")
	return s
end
local function targetQuote(s: any, unlockId: string): any
	local result = s.purchases.quote(s.active, unlockId)
	check(result.status == "Quoted", result.reason)
	return result.quote
end
local function allProofs(): any
	return {
		["milestone/region-mastery/starter"] = true,
		["milestone/region-mastery/mid-a"] = true,
		["milestone/region-mastery/mid-b"] = true,
	}
end
local function catalogRoundTrip()
	local proofs, s = allProofs(), nil :: any
	s = catalogSetup(proofs)
	local before, quotes, total = s.active.snapshot(), {}, 0
	for _, d in Price.definitions do
		local q = targetQuote(s, d.unlockId)
		check(
			Contract.validSnapshot(
				Projection.fromProfile(s.active.snapshot(), s.progression, s.vault, q, d.unlockId)
			)
		)
		check(
			Wire.payload(
				Projection.fromProfile(s.active.snapshot(), s.progression, s.vault, q, d.unlockId)
			),
			"one page remains under reliable wire limits"
		)
		check(buy(s, q).status == "Committed", d.unlockId)
		quotes[d.unlockId], total = q, total + d.priceUnits
	end
	local p = s.active.snapshot()
	check(
		p.economy.energyUnits == 2000 - total
			and p.profileRevision == before.profileRevision + #Price.definitions
	)
	local caps = s.production.capabilities(p)
	check(
		s.vault.collectionStatus(p).capacity == 14
			and caps.productionSlotCount == 3
			and caps.displaySlotCount == 4
	)
	check(caps.bufferCapacityMilli == 2_880_000 and caps.offlineWindowSeconds == 43200)
	check(s.progression.captureChance(p) == 0.85)
	for _, access in { "access/biome-mid-a", "access/biome-mid-b", "access/biome-advanced" } do
		check(s.progression.hasAccess(p, access))
	end
	check(not s.progression.hasAccess(p, "access/forged"))
	check(
		Wire.equal(before.collection, p.collection)
			and Wire.equal(before.discovery, p.discovery)
			and Wire.equal(before.world, p.world),
		"purchases never fabricate active world progress or mutate creatures"
	)
	check(p.collection.creaturesById["creature-3"].overflowHeld)
	check(s.active.renew().status == "Ready" and s.active.release(100).status == "Closed")
	s.clock.advance(19)
	local changed = copy(Price)
	changed.priceUnits, changed.quoteRevision, changed.configSnapshotId = 90, 2, "config/rebalanced"
	for _, d in changed.definitions do
		d.priceUnits, d.quoteRevision, d.configSnapshotId = d.priceUnits * 2, 2, "config/rebalanced"
	end
	local fresh = setup(s.repo, s.clock, "rejoined", nil, changed) -- Even an unbound mastery reader cannot revoke purchased access.
	check(fresh.active.acquire().status == "Ready")
	local restored = fresh.active.snapshot()
	check(
		Wire.equal(restored.progression, p.progression)
			and restored.economy.energyUnits == p.economy.energyUnits
	)
	for _, q in quotes do
		check(buy(fresh, q).status == "AlreadyCommitted")
	end
	check(
		Wire.equal(restored, fresh.active.snapshot()),
		"all historic retries survive save/rejoin and repricing"
	)
end
local function vaultEffectBoundaries()
	local s = catalogSetup()
	check(
		s.assignments.assign(
			s.active,
			"production",
			"production/3",
			"creature-2",
			s.active.snapshot().profileRevision
		).reason == "SLOT_LOCKED"
	)
	check(
		s.assignments.assign(
			s.active,
			"display",
			"display/4",
			"creature-2",
			s.active.snapshot().profileRevision
		).reason == "SLOT_LOCKED"
	)
	check(
		s.purchases.quote(s.active, "vault-upgrade/offline-window/2").reason
			== "INVALID_UNLOCK_LEVEL"
	)
	check(s.active.checkpoint("saturated-fixture", function(p: any)
		p.vault.productionBufferMilli = 1_440_000
	end).status == "Committed")
	s.clock.advance(10)
	check(buy(s, targetQuote(s, "vault-upgrade/production-buffer/1")).status == "Committed")
	local p = s.active.snapshot()
	check(
		p.vault.productionBufferMilli == 1_440_000 and p.vault.productionCursorUnixSeconds == 1010,
		"expanded headroom cannot credit the old saturated interval"
	)
	s.clock.advance(10)
	check(buy(s, targetQuote(s, "vault-upgrade/production-slots/1")).status == "Committed")
	check(s.active.snapshot().vault.productionBufferMilli == 1_441_000)
	check(
		s.assignments.assign(
			s.active,
			"production",
			"production/3",
			"creature-2",
			s.active.snapshot().profileRevision
		).status == "Committed"
	)
	check(buy(s, targetQuote(s, "vault-upgrade/display-slots/1")).status == "Committed")
	check(
		s.assignments.assign(
			s.active,
			"display",
			"display/4",
			"creature-2",
			s.active.snapshot().profileRevision
		).status == "Committed"
	)
	check(s.claims.claim(s.active, s.active.snapshot().profileRevision).status == "Committed")
	check(buy(s, targetQuote(s, "vault-upgrade/offline-window/1")).status == "Committed")
	local saved = s.active.snapshot()
	check(s.active.release(100).status == "Closed")
	s.clock.advance(20000)
	local fresh = setup(s.repo, s.clock, "offline-4h")
	check(fresh.active.acquire().status == "Ready")
	local restored = fresh.active.snapshot()
	check(
		restored.vault.lastOfflineSettlement.eligibleSeconds == 14400
			and restored.vault.productionBufferMilli == 2_880_000
	)
	check(
		Wire.equal(saved.vault.productionAssignments, restored.vault.productionAssignments)
			and Wire.equal(saved.vault.displayAssignments, restored.vault.displayAssignments)
	)
	-- An authoritative wall clock behind the saved cursor must not expand caps
	-- before that old interval can be settled.
	local regressionSeed = fixture()
	regressionSeed.economy.energyUnits = 2000
	regressionSeed.vault.productionCursorUnixSeconds = 1100
	local regressed = setup(nil, nil, nil, regressionSeed)
	check(regressed.active.acquire().status == "Ready")
	local before = regressed.active.snapshot()
	check(
		buy(regressed, targetQuote(regressed, "vault-upgrade/production-buffer/1")).reason
			== "PRODUCTION_CLOCK_REGRESSION"
	)
	check(Wire.equal(before, regressed.active.snapshot()))
end
local function accessProofGates()
	local unbound = catalogSetup()
	check(
		unbound.purchases.quote(unbound.active, "access/biome-mid-a").reason
			== "MILESTONE_AUTHORITY_UNBOUND"
	)
	local proofs, s = {}, nil :: any
	s = catalogSetup(proofs)
	local before = s.active.snapshot()
	check(s.purchases.quote(s.active, "access/biome-mid-a").reason == "MISSING_MILESTONE")
	proofs["milestone/region-mastery/mid-a"], proofs["milestone/region-mastery/mid-b"] = true, true
	check(s.purchases.quote(s.active, "access/biome-advanced").reason == "MISSING_PREREQUISITE")
	check(
		Wire.equal(before, s.active.snapshot()),
		"Energy and passive output cannot bypass active gates"
	)
	proofs["milestone/region-mastery/starter"] = true
	local qA = targetQuote(s, "access/biome-mid-a")
	check(buy(s, qA).status == "Committed")
	local qB = targetQuote(s, "access/biome-mid-b")
	check(qB.priceUnits == 100, "parallel Mid purchase never reprices or locks the other")
	proofs["milestone/region-mastery/starter"] = false
	before = s.active.snapshot()
	check(
		buy(s, qB).reason == "MISSING_MILESTONE" and Wire.equal(before, s.active.snapshot()),
		"proof rechecked at execution"
	)
	proofs["milestone/region-mastery/starter"] = true
	check(buy(s, targetQuote(s, "access/biome-mid-b")).status == "Committed")
	proofs["milestone/region-mastery/mid-b"] = false
	check(s.purchases.quote(s.active, "access/biome-advanced").reason == "MISSING_MILESTONE")
	proofs["milestone/region-mastery/mid-b"] = true
	local advanced = targetQuote(s, "access/biome-advanced")
	check(advanced.prerequisiteDefinitionId == advanced.unlockId)
	check(buy(s, advanced).status == "Committed")
	check(s.progression.hasAccess(s.active.snapshot(), advanced.unlockId))
	check(
		Wire.equal(before.discovery, s.active.snapshot().discovery)
			and Wire.equal(before.world, s.active.snapshot().world)
	)
end
local function catalogFaultsAndRejections()
	for _, after in { false, true } do
		local s = catalogSetup(allProofs())
		for _, d in Price.definitions do
			local q, before = targetQuote(s, d.unlockId), s.active.snapshot()
			local forged = payload(q)
			forged.priceUnits = 0
			check(
				s.purchases.purchase(s.active, forged, q.expectedRevision).reason
					== "INVALID_PURCHASE"
			)
			forged = payload(q)
			forged.unlockId = "access/forged"
			check(
				s.purchases.purchase(s.active, forged, q.expectedRevision).reason
					== "INVALID_UNLOCK"
			)
			check(Wire.equal(before, s.active.snapshot()))
			if after then
				s.repo.loseNextResultAfterWrite()
			else
				s.repo.failNext({ status = "error", reason = "BEFORE", retryable = false })
			end
			local outcome = buy(s, q)
			check(outcome.status == "OutcomeUnknown" and Wire.equal(before, s.active.snapshot()))
			local stored = s.repo.read("player/42").value
			check(
				stored.economy.energyUnits
					== before.economy.energyUnits - (if after then d.priceUnits else 0)
			)
			s.clock.advance(121)
			s.repo.setReplayTransform(true)
			check(
				buy(s, q).status == "AlreadyCommitted",
				"the admitted exact candidate survives timeout/replay"
			)
			local confirmed = s.active.snapshot()
			check(confirmed.economy.energyUnits == before.economy.energyUnits - d.priceUnits)
			check(
				confirmed.progression.purchasesByUnlockId[d.unlockId].operationId
					== outcome.operationId
			)
			check(
				buy(s, q).status == "AlreadyCommitted"
					and Wire.equal(confirmed, s.active.snapshot())
			)
		end
	end
	-- Each new reason is constrained to its own exact authored sink.
	local s = catalogSetup(allProofs())
	local first = targetQuote(s, "capture-capability/1")
	local second = targetQuote(s, "vault-upgrade/production-slots/1")
	check(
		buy(s, first).reason == "STALE_QUOTE",
		"switching selection invalidates the first live quote"
	)
	local before = s.active.snapshot()
	local nested: any = nil
	s.repo.setBeforeTransform(function()
		s.repo.setBeforeTransform(nil)
		nested = { buy(s, second).status, s.claims.claim(s.active, second.expectedRevision).status }
	end)
	check(buy(s, second).status == "Committed" and nested[1] == "Busy" and nested[2] == "Busy")
	check(s.active.snapshot().economy.energyUnits == before.economy.energyUnits - 50)
	local poor = fixture()
	poor.economy.energyUnits = 0
	local insufficient = setup(nil, nil, nil, poor, nil, {
		mastery = function()
			return true
		end,
	})
	check(insufficient.active.acquire().status == "Ready")
	before = insufficient.active.snapshot()
	for _, target in
		{ "vault-upgrade/production-slots/1", "capture-capability/1", "access/biome-mid-a" }
	do
		check(buy(insufficient, targetQuote(insufficient, target)).reason == "INSUFFICIENT_ENERGY")
		check(Wire.equal(before, insufficient.active.snapshot()))
	end
	for _, change in
		{
			function(p: any)
				p.progression.captureCapabilityLevel = 1
			end,
			function(p: any)
				p.progression.accessUnlocksById = { ["access/biome-mid-a"] = true }
			end,
			function(p: any)
				p.vault.earnedUpgradeLevels = { ["vault-upgrade/offline-window"] = 3 }
			end,
			function(p: any)
				p.progression.progressionSchemaVersion, p.progression.purchasesByUnlockId = 1, {}
				p.progression.captureCapabilityLevel = false
			end,
			function(p: any)
				p.progression.progressionSchemaVersion, p.progression.purchasesByUnlockId = 1, {}
				p.progression.accessUnlocksById = false
			end,
		}
	do
		local forged = fixture()
		change(forged)
		local protected = setup(nil, nil, nil, forged)
		local outcome = protected.active.acquire()
		check(
			outcome.status == "ProtectedLoadFailure",
			outcome.status .. ":" .. tostring(outcome.reason)
		)
	end
end
local function captureCapabilityEffect()
	local s = catalogSetup()
	local held = s.active.snapshot()
	check(buy(s, targetQuote(s, Price.unlockId)).status == "Committed")
	local capacityUseCase = Capacity.new({
		vault = s.vault,
		settleProduction = s.assignments.settleProfile,
		newOperationId = function()
			return "resolve-capability-held"
		end,
	})
	check(
		capacityUseCase.resolve(s.active, "creature-3", s.active.snapshot().profileRevision).status
			== "Committed"
	)
	local canInitiate = Finalization.new(s.vault).canInitiate
	local before = s.active.snapshot()
	local serial, draws = 0, 0
	local function attempt(profile: any, capacity: boolean): (any, any, any)
		local world = World.new({
			fixture = CreatureFixture,
			clock = function()
				return 0
			end,
			newId = function()
				serial += 1
				return "capability-creature-" .. serial
			end,
			materialize = function()
				return {}
			end,
			activate = function() end,
			destroyProjection = function() end,
			generateVariant = function(candidate: any)
				return Variant.generate(candidate, {
					nextUnit = function()
						return 0.1
					end,
				})
			end,
		})
		world.step(world.start())
		local creatureId = assert(world.currentId())
		local identity = world.identity(creatureId)
		local capture = Capture.new({
			world = world,
			clock = function()
				return 0
			end,
			unixSeconds = function()
				return 1000
			end,
			newId = function()
				serial += 1
				return "capture-" .. serial
			end,
			random = {
				nextUnit = function()
					draws += 1
					return 0.82
				end,
			},
			canInitiate = function(candidate: any)
				return capacity and canInitiate(candidate)
			end,
			captureChance = s.progression.captureChance,
			finalize = function()
				error("secure finalization still required")
			end,
		})
		local claimed = capture.begin(42, creatureId, CreatureFixture.position, 1, profile)
		if not capacity or not canInitiate(profile) then
			check(claimed.status == "CapacityBlocked")
			return claimed, identity, world
		end
		check(claimed.status == "Claimed")
		local result =
			capture.submit(42, claimed.captureSessionId, "capture", 1, CreatureFixture.position, 1)
		if result.status == "TransportActive" then
			check(
				capture.submit(
					42,
					claimed.captureSessionId,
					"capture",
					1,
					CreatureFixture.position,
					1
				).status == "TransportActive"
			)
		end
		return result, identity, world
	end
	check(attempt(before, true).status == "Failed")
	check(buy(s, targetQuote(s, "capture-capability/1")).status == "Committed")
	local p = s.active.snapshot()
	local result, identity, world = attempt(p, true)
	check(
		result.status == "TransportActive" and draws == 2,
		"server capability improves bounded challenge; duplicate submit never rerolls"
	)
	check(Wire.equal(identity, world.identity(identity.creatureInstanceId)))
	check(
		attempt(p, false).status == "CapacityBlocked" and draws == 2,
		"capability cannot bypass capacity"
	)
	check(
		attempt(held, true).status == "CapacityBlocked" and draws == 2,
		"real Vault admission still rejects unresolved Held/full capacity"
	)
	check(
		Wire.equal(before.collection, s.active.snapshot().collection),
		"success is provisional until secure checkpoint"
	)
end
local function catalogNavigationAndHostility()
	local s = catalogSetup(allProofs())
	local registry = RouteRegistry.new(Routes)
	check(registry.get(Routes.commands.sessionRequestResync).schema({
		domain = "progression",
		unlockId = "capture-capability/1",
	}))
	check(not registry.get(Routes.commands.sessionRequestResync).schema({
		domain = "vault",
		unlockId = "capture-capability/1",
	}))
	local sent, clock = {}, 0
	local gateway = {
		send = function(route: string, value: any, revision: number?): string
			table.insert(sent, { route = route, payload = value, revision = revision })
			return "navigation-" .. #sent
		end,
		resultFor = function()
			return nil
		end,
	}
	local c = Controller.new({
		catalog = Price.definitions,
		gateway = gateway,
		routes = Routes,
		projection = Contract,
		sessionReady = function()
			return true
		end,
		clock = function()
			return clock
		end,
	})
	c.tick()
	local p = s.active.snapshot()
	local snapshot =
		Projection.fromProfile(p, s.progression, s.vault, targetQuote(s, Price.unlockId))
	check(c.handleSnapshot({
		payload = snapshot,
		revision = p.profileRevision,
		correlationId = "navigation-1",
	}) == "Applied")
	c.review()
	c.next()
	check(
		not c.view().canConfirm
			and sent[2].payload.unlockId == "vault-upgrade/collection-capacity/2"
	)
	check(c.handleSnapshot({
		payload = snapshot,
		revision = p.profileRevision,
		correlationId = "navigation-2",
	}) == "Stale")
	clock = 6
	c.tick()
	check(sent[#sent].payload.unlockId == "vault-upgrade/collection-capacity/2")
	for _, target in { "capture-capability/1", "access/biome-mid-a", "access/biome-advanced" } do
		local quoted = s.purchases.quote(s.active, target)
		local page = Projection.fromProfile(p, s.progression, s.vault, quoted.quote, target)
		check(Contract.validSnapshot(page) and Wire.payload(page))
	end
end
return {
	catalogRoundTrip = catalogRoundTrip,
	vaultEffectBoundaries = vaultEffectBoundaries,
	accessProofGates = accessProofGates,
	catalogFaultsAndRejections = catalogFaultsAndRejections,
	captureCapabilityEffect = captureCapabilityEffect,
	catalogNavigationAndHostility = catalogNavigationAndHostility,
	quotePurchaseSaveRejoin = quotePurchaseSaveRejoin,
	rejectionNoMutation = rejectionNoMutation,
	staleTamperAndIsolation = staleTamperAndIsolation,
	uncertainCutPoints = uncertainCutPoints,
	duplicateRaceAndClaim = duplicateRaceAndClaim,
	unknownDisconnectAndTakeover = unknownDisconnectAndTakeover,
	protectedLoadsAndAuditEviction = protectedLoadsAndAuditEviction,
	authoritativeReadback = authoritativeReadback,
}
