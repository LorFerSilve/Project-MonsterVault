--!strict

local Registry = require("../../src/server/domains/world/WorldRegistry")
local Definitions = require("../../src/server/domains/world/WorldDefinitions")
local WorldProgression = require("../../src/server/domains/world/WorldProgressionService")
local WorldActions = require("../../src/server/application/WorldActionUseCase")
local Progression = require("../../src/server/domains/progression/ProgressionService")
local Purchase = require("../../src/server/application/ProgressionPurchaseUseCase")
local Price = require("../../src/shared/config/ProgressionFixture")
local Energy = require("../../src/server/domains/economy/EnergyService")
local Vault = require("../../src/server/domains/vault/VaultService")
local Capacity = require("../../src/shared/config/VaultCapacityFixture")
local Production = require("../../src/server/domains/vault/VaultProductionService")
local ProductionConfig = require("../../src/shared/config/VaultProductionFixture")
local Assignments = require("../../src/server/application/VaultProductionUseCase")
local Finalize = require("../../src/server/application/CaptureFinalizationUseCase")
local Capture = require("../../src/server/domains/capture/CaptureService")
local World = require("../../src/server/domains/world/WorldService")
local Fixture = require("../../src/server/domains/world/FixtureDefinition")
local Variant = require("../../src/server/domains/capture/VariantIdentity")
local Schema = require("../../src/server/infrastructure/persistence/ProfileSchemaV1")
local Session = require("../../src/server/infrastructure/persistence/ProfileSession")
local Queue = require("../../src/server/infrastructure/persistence/SingleWriterQueue")
local Retry = require("../../src/server/infrastructure/persistence/RetryPolicy")
local Repository = require("../fixtures/FakeProfileRepository")
local Clock = require("../fixtures/FakeClock")

local function check(value: any, message: string?): any
	assert(value, debug.traceback(message or "world progression invariant", 2))
	return value
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
	for k, v in a do
		if not equal(v, b[k]) then
			return false
		end
	end
	for k in b do
		if a[k] == nil then
			return false
		end
	end
	return true
end

-- Exercise the shipped canonical definitions with the actual P2 owner.
local function catalog(): any
	return copy(Definitions)
end
local function harness(options: any?): any
	local o = options or {}
	local registry = Registry.new(o.config or catalog())
	local world = WorldProgression.new(registry)
	local progression = Progression.new(Price, { mastery = world.mastery })
	local energy = Energy.new(progression.boundSinks, registry.worldReward)
	local capacity = copy(Capacity)
	capacity.baseCollectionCapacity = o.capacity or Capacity.baseCollectionCapacity
	local vault, production = Vault.new(capacity), Production.new(ProductionConfig)
	local repository, clock = o.repository or Repository.new(), o.clock or Clock.new(1000, 0)
	local serial = 0
	local function operation(): string
		serial += 1
		return (o.lock or "world") .. "-op-" .. serial
	end
	if o.repository == nil then
		local seed = o.seed or Schema.default(1000)
		seed.economy.energyUnits = o.energy or 1000 -- Trusted legacy fixture funds; never a runtime grant.
		repository.seed("player/42", seed)
	end
	local assignments = Assignments.new({
		production = production,
		vault = vault,
		unixSeconds = clock.wallClock.unixSeconds,
		monotonicSeconds = clock.monotonicClock.seconds,
		newOperationId = operation,
	})
	local session = Session.new({
		userId = 42,
		lockId = o.lock or "world",
		jobId = "world-test",
		repository = repository,
		schema = Schema,
		prepareProfile = function(p: any): any
			local changed = false
			for _, owner in { world, energy, progression } do
				local result = owner.prepare(p)
				if result.status ~= "Prepared" then
					return result
				end
				changed = changed or result.changed
			end
			local result = assignments.prepareProfile(p, clock.wallClock.unixSeconds())
			result.changed = result.changed or changed
			return result
		end,
		prepareSave = function(p: any, release: boolean, mono: number): any
			local invalid = world.validate(p) or energy.validate(p) or progression.validate(p)
			if invalid then
				return { status = "Protected", reason = invalid }
			end
			return assignments.prepareSave(p, release, mono)
		end,
		queue = Queue.new(clock.monotonicClock.seconds, clock.advance, 25),
		retry = Retry.new(clock.monotonicClock.seconds, clock.advance, function()
			return 0.5
		end, 3),
		unixSeconds = clock.wallClock.unixSeconds,
		monotonicSeconds = clock.monotonicClock.seconds,
	})
	local load = session.acquire()
	local actions = WorldActions.new({
		world = world,
		progression = progression,
		energy = energy,
		unixSeconds = clock.wallClock.unixSeconds,
		newOperationId = operation,
	})
	local purchases = Purchase.new({
		progression = progression,
		energy = energy,
		vault = vault,
		production = production,
		assignments = assignments,
		monotonicSeconds = clock.monotonicClock.seconds,
		newOperationId = operation,
	})
	local finalize = Finalize.new(vault, world.secured)
	local h = {
		world = world,
		energy = energy,
		registry = registry,
		progression = progression,
		session = session,
		repository = repository,
		clock = clock,
		load = load,
		actions = actions,
		purchases = purchases,
		finalize = finalize,
	}
	h.visit = function(id: string, inside: boolean?): any
		return actions.visit(session, id, function()
			return inside ~= false
		end)
	end
	h.secure = function(context: string, custom: any?): any
		local payload = {
			ownerUserId = 42,
			operationId = operation(),
			creatureInstanceId = operation(),
			speciesId = Fixture.speciesId,
			origin = { spawnContextId = context, contentSnapshotId = registry.contentSnapshotId },
			securedAt = 1000,
		}
		if custom then
			for k, v in custom do
				payload[k] = v
			end
		end
		payload.variantIdentity = Variant.generate({
			speciesId = payload.speciesId,
			rarityId = "rarity/common",
			spawnContextId = payload.origin.spawnContextId,
			contentSnapshotId = payload.origin.contentSnapshotId,
		}, {
			nextUnit = function()
				return 0.5
			end,
		})
		return finalize.finalize(session, payload), payload
	end
	h.buy = function(id: string): any
		local result = purchases.quote(session, id)
		if result.status ~= "Quoted" then
			return result
		end
		local q = result.quote
		return purchases.purchase(
			session,
			{ unlockId = id, quoteId = q.quoteId, quoteRevision = q.quoteRevision },
			q.expectedRevision
		)
	end
	return h
end
local entry, clearing = "landmark/fixture-entry", "landmark/fixture-clearing"
local function starter(h: any)
	check(h.visit(entry).status == "Committed")
	check(h.visit(clearing).status == "Committed")
	check(h.secure(Fixture.spawnContextId).status == "Secured")
	check(h.visit(entry).status == "Committed")
	check(h.world.mastery(h.session.snapshot(), "milestone/region-mastery/starter"))
end

local function registryContracts()
	local r = Registry.new(Definitions)
	local optional = copy(Definitions)
	table.insert(
		optional.species,
		{ id = "species/optional-legendary", rarityId = "rarity/legendary" }
	)
	check(
		Registry.new(optional).species["species/optional-legendary"] ~= nil,
		"optional rarity must not be a mandatory mastery wall or be forbidden globally"
	)
	check(
		r.roles.Starter == Fixture.regionId
			and r.regions[r.roles.MidA].accessUnlockId == "access/biome-mid-a"
	)
	check(
		table.isfrozen(r.spawnContexts)
			and table.isfrozen(r.spawnContexts[Fixture.spawnContextId].speciesIds)
	)
	for _, mutate in
		{
			function(d: any)
				d.regions[3].accessUnlockId = "access/biome-mid-b"
			end,
			function(d: any)
				d.regions[3].role = "Starter"
			end,
			function(d: any)
				d.spawnContexts[1].habitatId = "habitat/unknown"
			end,
			function(d: any)
				d.regions[2].mastery.coreSpeciesThreshold = 2
			end,
			function(d: any)
				d.species[1].rarityId = "rarity/legendary"
			end,
			function(d: any)
				d.objectives[1].landmarkIds = { entry, entry }
			end,
			function(d: any)
				for _, l in d.landmarks do
					if l.id == clearing then
						l.regionId = "region/biome-mid-a"
					end
				end
			end,
			function(d: any)
				table.insert(d.landmarks, copy(d.landmarks[1]))
			end,
		}
	do
		local d = copy(Definitions)
		mutate(d)
		check(not pcall(Registry.new, d), "invalid registry admitted")
	end
end
local function authoredContracts()
	local r = Registry.new(Definitions)
	for _, role in { "Starter", "MidA", "MidB", "Advanced" } do
		local region = r.regions[r.roles[role]]
		check(region.mastery ~= nil and r.safeOutposts[region.entryOutpostId] ~= nil)
	end
	for _, mutate in
		{
			function(d: any)
				d.regions[3].neighborIds = { "region/biome-mid-b" }
			end,
			function(d: any)
				d.regions[4].mastery = nil
			end,
			function(d: any)
				d.safeOutposts[3].securePointId = "secure-point/fixture-spawn"
			end,
			function(d: any)
				d.travelNodes[4].recoveryAnchorId = "recovery-anchor/mid-a"
			end,
			function(d: any)
				d.securePoints[2].regionId = "region/missing"
			end,
			function(d: any)
				d.habitats[4].regionId = "region/biome-mid-b"
			end,
			function(d: any)
				d.vaultAccessPoints = {}
			end,
			function(d: any)
				d.securePoints[3].radius = nil
			end,
		}
	do
		local d = copy(Definitions)
		mutate(d)
		check(not pcall(Registry.new, d), "invalid canonical content admitted")
	end
end
local function masteryRequiresActiveEvidence()
	local h = harness()
	check(h.load.status == "Ready")
	local before = h.session.snapshot()
	check(h.visit(entry, false).status == "Rejected" and equal(before, h.session.snapshot()))
	check(h.visit("landmark/unknown").status == "Rejected")
	check(h.visit(entry).status == "Committed")
	local revision = h.session.snapshot().profileRevision
	for _ = 1, 3 do
		check(h.visit(entry).status == "AlreadyCommitted")
	end
	check(h.session.snapshot().profileRevision == revision)
	check(h.secure(Fixture.spawnContextId).status == "Secured")
	check(not h.world.mastery(h.session.snapshot(), "milestone/region-mastery/starter"))
	check(h.visit(clearing).status == "Committed")
	check(not h.world.mastery(h.session.snapshot(), "milestone/region-mastery/starter"))
	check(h.visit(entry).status == "Committed")
	local p = h.session.snapshot()
	check(h.world.mastery(p, "milestone/region-mastery/starter"))
	check(p.economy.energyUnits == before.economy.energyUnits + 5, "fixed authored reward missing")
	check(
		h.visit(entry).status == "AlreadyCommitted"
			and h.visit(clearing).status == "AlreadyCommitted"
	)
	check(h.session.snapshot().profileRevision == p.profileRevision)
end
local function regionalProvenanceAndHeld()
	local h = harness({ capacity = 2 })
	for _, origin in
		{
			{
				spawnContextId = Fixture.spawnContextId,
				contentSnapshotId = "content-snapshot/unknown",
			},
			{
				spawnContextId = "spawn-context/unknown",
				contentSnapshotId = Definitions.contentSnapshotId,
			},
		}
	do
		check(h.secure(Fixture.spawnContextId, { origin = origin }).status == "Secured")
	end
	check(next(h.session.snapshot().world.regionalSpecies) == nil)
	local secured, payload = h.secure(Fixture.spawnContextId)
	check(secured.status == "Secured" and secured.overflowHeld == true)
	local fact = h.session.snapshot().world.regionalSpecies[Fixture.regionId][Fixture.speciesId]
	check(fact.operationId == payload.operationId)
	check(h.finalize.finalize(h.session, payload).status == "Secured")
	check(h.secure(Fixture.spawnContextId).status == "Secured")
	local n = 0
	for _ in h.session.snapshot().world.regionalSpecies[Fixture.regionId] do
		n += 1
	end
	check(n == 1, "repeat species inflated regional count")
end
local function accessBindingsAndRejoin()
	local h = harness()
	local before = h.session.snapshot()
	check(
		h.visit("landmark/mid-a-entry").reason == "ACCESS_BLOCKED"
			and equal(before, h.session.snapshot())
	)
	check(h.buy("access/biome-mid-a").reason == "MISSING_MILESTONE")
	starter(h)
	check(h.buy("access/biome-mid-b").status == "Committed")
	check(not h.world.mastery(h.session.snapshot(), "milestone/region-mastery/mid-b"))
	check(h.buy("access/biome-advanced").status == "Rejected")
	check(h.visit("landmark/mid-b-entry").status == "Committed")
	check(h.visit("landmark/mid-b-field").status == "Committed")
	check(h.secure("spawn-context/mid-b").status == "Secured")
	check(h.visit("landmark/mid-b-entry").status == "Committed")
	check(h.buy("access/biome-advanced").status == "Rejected")
	check(h.buy("access/biome-mid-a").status == "Committed")
	check(h.visit("landmark/mid-a-entry").status == "Committed")
	check(h.visit("landmark/mid-a-field").status == "Committed")
	check(h.secure("spawn-context/mid-a").status == "Secured")
	check(h.visit("landmark/mid-a-entry").status == "Committed")
	check(h.buy("access/biome-advanced").status == "Committed")
	local p = h.session.snapshot()
	check(p.economy.energyUnits == 605)
	check(h.world.canAccess(p, "region/biome-advanced", h.progression.hasAccess))
	check(not h.world.canAccess(p, "region/unknown", h.progression.hasAccess))
	check(h.session.release(25).status == "Closed")
	local rejoined = harness({ repository = h.repository, clock = h.clock, lock = "rejoined" })
	check(rejoined.load.status == "Ready" and equal(p.world, rejoined.session.snapshot().world))
	for id, receipt in p.progression.purchasesByUnlockId do
		check(
			rejoined.purchases.purchase(
				rejoined.session,
				{ unlockId = id, quoteId = receipt.quoteId, quoteRevision = receipt.quoteRevision },
				receipt.expectedRevision
			).status == "AlreadyCommitted"
		)
	end
	check(rejoined.session.snapshot().economy.energyUnits == 605)
end
local function unknownWriteCutPoints()
	for _, mode in { "before", "after" } do
		local h = harness()
		h.repository.setReplayTransform(true)
		if mode == "before" then
			for _ = 1, 3 do
				h.repository.failNext({
					status = "error",
					reason = "BEFORE_WRITE",
					retryable = true,
				})
			end
		else
			h.repository.loseNextResultAfterWrite()
		end
		check(h.visit(entry).status == "OutcomeUnknown")
		check(h.session.state() == "PersistenceAtRisk")
		check(h.visit(entry, false).reason == "OUT_OF_RANGE") -- Restore accepted proof even after departure.
		check(
			h.session.state() == "Ready"
				and h.session.snapshot().world.objectives["field-objective/fixture-return-route"]
					== 1
		)
		local p = h.session.snapshot()
		check(h.visit(entry).status == "AlreadyCommitted" and equal(p, h.session.snapshot()))
		check(h.session.release(25).status == "Closed")
		local rejoined =
			harness({ repository = h.repository, clock = h.clock, lock = "after-" .. mode })
		check(rejoined.load.status == "Ready" and equal(p.world, rejoined.session.snapshot().world))
	end
end
local function travelDiscoveryCutPointsAndRace()
	for _, mode in { "before", "after" } do
		local h = harness()
		local before = h.session.snapshot()
		local function discover(inside: boolean?): any
			return h.actions.discoverTravel(h.session, "travel-node/starter", function()
				return inside ~= false
			end)
		end
		check(discover(false).reason == "OUT_OF_RANGE")
		check(equal(before, h.session.snapshot()))
		h.repository.setReplayTransform(true)
		if mode == "before" then
			for _ = 1, 3 do
				h.repository.failNext({
					status = "error",
					reason = "BEFORE_WRITE",
					retryable = true,
				})
			end
		else
			h.repository.loseNextResultAfterWrite()
		end
		check(discover().status == "OutcomeUnknown")
		check(discover(false).reason == "OUT_OF_RANGE")
		local p = h.session.snapshot()
		check(p.profileRevision == before.profileRevision + 1)
		check(p.world.travelNodes["travel-node/starter"] ~= nil)
		check(equal(p.world.mastery, before.world.mastery) and equal(p.economy, before.economy))
		check(discover().status == "AlreadyCommitted" and equal(p, h.session.snapshot()))
		check(h.session.release(25).status == "Closed")
		local rejoined =
			harness({ repository = h.repository, clock = h.clock, lock = "node-" .. mode })
		check(rejoined.load.status == "Ready" and equal(p.world, rejoined.session.snapshot().world))
	end
	local h = harness()
	local nested: any = nil
	h.repository.setBeforeTransform(function()
		h.repository.setBeforeTransform(nil)
		nested = h.actions.discoverTravel(h.session, "travel-node/starter", function()
			return true
		end)
	end)
	check(h.actions.discoverTravel(h.session, "travel-node/starter", function()
		return true
	end).status == "Committed")
	check(nested.status == "Busy")
end
local function racesStaleAndInsufficient()
	local h = harness()
	local nested: any = nil
	h.repository.setBeforeTransform(function()
		h.repository.setBeforeTransform(nil)
		nested = h.visit(entry)
	end)
	check(h.visit(entry).status == "Committed" and nested.status == "Busy")
	check(h.session.snapshot().world.objectives["field-objective/fixture-return-route"] == 1)
	check(h.visit(clearing).status == "Committed")
	check(h.secure(Fixture.spawnContextId).status == "Secured")
	check(h.visit(entry).status == "Committed")
	local q = h.purchases.quote(h.session, "access/biome-mid-a").quote
	check(h.secure(Fixture.spawnContextId).status == "Secured")
	local before = h.session.snapshot()
	check(
		h.purchases.purchase(
			h.session,
			{ unlockId = q.unlockId, quoteId = q.quoteId, quoteRevision = q.quoteRevision },
			q.expectedRevision
		).status == "Rejected"
	)
	check(equal(before, h.session.snapshot()))
	local poor = harness({ energy = 68 }) -- Starter reward preserves the insufficient-funds case.
	starter(poor)
	before = poor.session.snapshot()
	check(poor.buy("access/biome-mid-a").reason == "INSUFFICIENT_ENERGY")
	check(equal(before, poor.session.snapshot()))
end
local function protectedStateAndHistoricalMastery()
	local unbound = Schema.default(1000)
	unbound.profileRevision = 1
	unbound.world = {
		schemaVersion = 1,
		landmarks = {},
		objectives = {},
		regionalSpecies = {},
		mastery = {
			["milestone/region-mastery/mid-a"] = {
				operationId = "unbound-proof",
				revision = 1,
				contentSnapshotId = Definitions.contentSnapshotId,
			},
		},
	}
	local noRecipe = copy(Definitions)
	noRecipe.authoringVersion = nil
	noRecipe.regions[3].mastery = nil
	local blocked = harness({ seed = unbound, config = noRecipe })
	check(blocked.load.status == "ProtectedLoadFailure", "unbound mastery cannot grant authority")
	check(
		equal(blocked.repository.read("player/42").value.world, unbound.world),
		"unbound mastery value preserved"
	)
	unbound.world.mastery["milestone/region-mastery/mid-a"].contentSnapshotId =
		"content-snapshot/imp10-world-dev-v1"
	local oldUnbound = harness({ seed = unbound, config = Definitions })
	check(
		oldUnbound.load.status == "ProtectedLoadFailure",
		"new content cannot reinterpret previously unbound mastery"
	)
	check(
		equal(oldUnbound.repository.read("player/42").value.world, unbound.world),
		"unbound historical value preserved"
	)
	local invalidStates: { any } = {
		{ mastery = true },
		{ schemaVersion = 2 },
		{ schemaVersion = 1, rewardQueue = { "unbound" } },
	}
	for _, value in invalidStates do
		local seed = Schema.default(1000)
		seed.world = value
		local h = harness({ seed = seed })
		check(h.load.status == "ProtectedLoadFailure")
		check(equal(h.repository.read("player/42").value.world, value))
	end
	local h = harness()
	starter(h)
	local p = h.session.snapshot()
	local historical = copy(p)
	historical.world.mastery["milestone/region-mastery/starter"].contentSnapshotId =
		"content-snapshot/imp10-world-dev-v1"
	check(
		h.world.mastery(historical, "milestone/region-mastery/starter"),
		"authorized historic Starter mastery remains valid"
	)
	local expanded = catalog()
	local l = "landmark/starter-addition"
	table.insert(expanded.landmarks, { id = l, regionId = Fixture.regionId, radius = 6 })
	table.insert(expanded.regions[2].mastery.landmarkIds, l)
	check(
		WorldProgression.new(Registry.new(expanded)).mastery(p, "milestone/region-mastery/starter")
	)
	check(h.session.checkpoint("release-test", function(profile)
		profile.collection.creaturesById = {}
	end).status == "Committed")
	check(h.world.mastery(h.session.snapshot(), "milestone/region-mastery/starter"))
end
local function captureActionsFailClosed()
	local h = harness()
	local f = copy(Fixture)
	f.regionId, f.habitatId, f.spawnContextId, f.contentSnapshotId =
		"region/biome-mid-a", "habitat/mid-a", "spawn-context/mid-a", Definitions.contentSnapshotId
	local world = World.new({
		fixture = f,
		clock = function()
			return 0
		end,
		newId = function()
			return "gated-creature"
		end,
		materialize = function()
			return {}
		end,
		activate = function() end,
		destroyProjection = function() end,
		generateVariant = function(c)
			return Variant.generate(c, {
				nextUnit = function()
					return 0.5
				end,
			})
		end,
	})
	world.step(world.start())
	local admitted, draws = 0, 0
	local capture = Capture.new({
		world = world,
		clock = function()
			return 0
		end,
		unixSeconds = function()
			return 1000
		end,
		newId = function()
			admitted += 1
			return "capture-" .. admitted
		end,
		random = {
			nextUnit = function()
				draws += 1
				return 0
			end,
		},
		canInitiate = function()
			return true
		end,
		finalize = h.finalize.finalize,
		canAccess = function(p, identity)
			local region = h.world.provenance({ speciesId = identity.speciesId, origin = identity })
			return region ~= nil and h.world.canAccess(p, region, h.progression.hasAccess)
		end,
	})
	check(
		capture.begin(42, "gated-creature", f.position, 1, h.session.snapshot()).status
			== "AccessBlocked"
	)
	check(
		admitted == 0 and draws == 0 and world.get("gated-creature").availability == "IdleAvailable"
	)
	starter(h)
	check(h.buy("access/biome-mid-a").status == "Committed")
	local claim = capture.begin(42, "gated-creature", f.position, 1, h.session.snapshot())
	check(claim.status == "Claimed")
	check(capture.hasAcquisition(42), "engagement must block travel")
	check(
		capture.submit(42, claim.captureSessionId, "capture", 1, f.position, 1, {}).status
				== "AccessBlocked"
			and draws == 0
	)
	check(
		capture.submit(
			42,
			claim.captureSessionId,
			"capture",
			1,
			f.position,
			1,
			h.session.snapshot()
		).status == "TransportActive"
	)
	check(
		capture.submit(
			42,
			claim.captureSessionId,
			"capture",
			1,
			f.position,
			1,
			h.session.snapshot()
		).status
				== "TransportActive"
			and draws == 1
	)
	check(capture.hasAcquisition(42), "transport must block travel")
	local before = h.session.snapshot()
	capture.disconnect(42)
	check(capture.hasAcquisition(42) and capture.state("gated-creature") == "TransportGrace")
	capture.interrupt(42)
	check(capture.hasAcquisition(42), "ordinary interruption preserves grace")
	capture.interrupt(42, true)
	check(not capture.hasAcquisition(42) and capture.state("gated-creature") == "Interrupted")
	check(equal(before, h.session.snapshot()), "recovery is not extraction")
end
local objective = "field-objective/fixture-return-route"
local function rewardExactlyOnceAndRejoin()
	local h = harness({ energy = 0 })
	check(h.visit(entry).status == "Committed")
	check(h.visit(clearing).status == "Committed")
	local before = h.session.snapshot()
	check(h.visit(entry).status == "Committed")
	local p = h.session.snapshot()
	check(p.economy.energyUnits == 5, "authored completion did not reward five Energy")
	check(p.world.objectives[objective] == 3)
	local receipt = check(p.economy.worldRewardReceipt)
	check(receipt.sourceReference == "world-reward/starter-return-dev-v1")
	check(receipt.remainingUnits == 0 and receipt.energyUnits == 5)
	check(p.recentOperations[receipt.operationId] == before.profileRevision + 1)
	for _, domain in { "collection", "discovery", "progression", "vault" } do
		check(equal(before[domain], p[domain]), "reward changed another domain")
	end
	check(not h.world.mastery(p, "milestone/region-mastery/starter"), "reward invented mastery")
	for _ = 1, 3 do
		check(h.visit(entry).status == "AlreadyCommitted")
		check(h.visit(clearing).status == "AlreadyCommitted")
	end
	check(equal(p, h.session.snapshot()), "duplicate observation rewarded")
	check(h.session.release(25).status == "Closed")
	local rejoin = harness({ repository = h.repository, clock = h.clock, lock = "reward-rejoin" })
	local loaded = rejoin.session.snapshot()
	check(rejoin.load.status == "Ready" and equal(p.economy, loaded.economy))
	check(rejoin.visit(entry).status == "AlreadyCommitted")
	check(equal(loaded, rejoin.session.snapshot()), "rejoin rewarded twice")
end
local function rewardUnknownCutPoints()
	for _, after in { false, true } do
		local h = harness({ energy = 0 })
		check(h.visit(entry).status == "Committed" and h.visit(clearing).status == "Committed")
		local before = h.session.snapshot()
		h.repository.setReplayTransform(true)
		if after then
			h.repository.loseNextResultAfterWrite()
		else
			h.repository.failNext({ status = "error", reason = "BEFORE", retryable = false })
		end
		check(h.visit(entry).status == "OutcomeUnknown")
		check(equal(before, h.session.snapshot()), "unknown reward exposed candidate")
		local stored = h.repository.read("player/42").value
		check(stored.economy.energyUnits == (if after then 5 else 0))
		check(h.visit(entry, false).reason == "OUT_OF_RANGE")
		local p = h.session.snapshot()
		check(p.economy.energyUnits == 5 and p.world.objectives[objective] == 3)
		check(p.profileRevision == before.profileRevision + 1, "reward used a second operation")
		local original = p.economy.worldRewardReceipt.operationId
		if after then
			check(original == stored.economy.worldRewardReceipt.operationId)
		end
		check(h.visit(entry).status == "AlreadyCommitted" and equal(p, h.session.snapshot()))
		check(h.session.release(100).status == "Closed")
		local fresh = harness({
			repository = h.repository,
			clock = h.clock,
			lock = "reward-cut-" .. tostring(after),
		})
		check(fresh.load.status == "Ready")
		check(fresh.session.snapshot().economy.worldRewardReceipt.operationId == original)
		check(fresh.visit(entry).status == "AlreadyCommitted")
		check(fresh.session.snapshot().economy.energyUnits == 5)
	end
	-- Successful write, no acknowledgement/reconciliation, then process loss.
	local crashed = harness({ energy = 0 })
	check(
		crashed.visit(entry).status == "Committed" and crashed.visit(clearing).status == "Committed"
	)
	crashed.repository.loseNextResultAfterWrite()
	check(crashed.visit(entry).status == "OutcomeUnknown")
	local written = crashed.repository.read("player/42").value.economy.worldRewardReceipt
	crashed.clock.advance(301) -- Existing 300-second lease expires without a clean release.
	local takeover = harness({
		repository = crashed.repository,
		clock = crashed.clock,
		lock = "reward-takeover",
	})
	check(takeover.load.status == "Ready")
	local restored = takeover.session.snapshot()
	check(restored.economy.energyUnits == 5 and equal(written, restored.economy.worldRewardReceipt))
	check(takeover.visit(entry).status == "AlreadyCommitted")
	check(equal(restored, takeover.session.snapshot()), "unacknowledged rejoin rewarded twice")
	check(
		crashed.actions.reconcile(crashed.session).status ~= "Unchanged",
		"old lease recovered reward authority"
	)
	check(equal(restored.economy, crashed.repository.read("player/42").value.economy))
end
local function rewardRaceAndContextFence()
	local h = harness({ energy = 0 })
	check(h.visit(entry).status == "Committed" and h.visit(clearing).status == "Committed")
	local before = h.session.snapshot()
	local reads = 0
	local stale = h.actions.visit(h.session, entry, function()
		reads += 1
		return reads == 1 -- Presence/session changed before P2 admission.
	end)
	check(
		stale.status == "Rejected" and equal(before, h.session.snapshot()),
		"stale context rewarded"
	)
	local nested: any = nil
	h.repository.setBeforeTransform(function()
		h.repository.setBeforeTransform(nil)
		nested = h.visit(entry)
	end)
	check(h.visit(entry).status == "Committed" and nested.status == "Busy")
	local p = h.session.snapshot()
	check(p.economy.energyUnits == 5 and p.profileRevision == before.profileRevision + 1)
	check(h.visit(entry).status == "AlreadyCommitted" and equal(p, h.session.snapshot()))
end
local function rewardDeferredHeadroom()
	for _, headroom in { 0, 2, 5 } do
		local h = harness({ energy = 1_000_000_000_000 - headroom })
		check(h.secure(Fixture.spawnContextId).status == "Secured")
		check(h.visit(entry).status == "Committed" and h.visit(clearing).status == "Committed")
		check(h.visit(entry).status == "Committed")
		local p = h.session.snapshot()
		local receipt = check(p.economy.worldRewardReceipt)
		check(p.economy.energyUnits == 1_000_000_000_000)
		check(receipt.initialUnits == headroom and receipt.remainingUnits == 5 - headroom)
		local projected = require("../../src/server/application/ProgressionProjection").fromProfile(
			p,
			h.progression,
			Vault.new(Capacity)
		)
		check(projected.state.deferredEnergyUnits == 5 - headroom, "deferred reward invisible")
		check(h.visit(entry).status == "AlreadyCommitted" and equal(p, h.session.snapshot()))
		check(h.buy("vault-upgrade/collection-capacity/1").status == "Committed")
		check(h.actions.reconcile(h.session).status == "Unchanged")
		p = h.session.snapshot()
		check(p.economy.energyUnits == 1_000_000_000_000 - 25 + 5 - headroom)
		check(p.economy.worldRewardReceipt.remainingUnits == 0)
		check(p.economy.worldRewardReceipt.operationId == receipt.operationId)
		check(h.energy.validate(p) == nil)
		check(
			h.actions.reconcile(h.session).status == "Unchanged" and equal(p, h.session.snapshot())
		)
	end
end
local function rewardDeferredCutPoints()
	for _, after in { false, true } do
		local h = harness({ energy = 1_000_000_000_000 })
		check(h.secure(Fixture.spawnContextId).status == "Secured")
		check(h.visit(entry).status == "Committed" and h.visit(clearing).status == "Committed")
		check(h.visit(entry).status == "Committed")
		local grant = h.session.snapshot().economy.worldRewardReceipt.operationId
		check(h.buy("vault-upgrade/collection-capacity/1").status == "Committed")
		local before = h.session.snapshot()
		if after then
			h.repository.loseNextResultAfterWrite()
		else
			h.repository.failNext({ status = "error", reason = "BEFORE", retryable = false })
		end
		check(h.actions.reconcile(h.session).status == "OutcomeUnknown")
		check(equal(before, h.session.snapshot()))
		check(h.session.release(100).status == "Closed", "release did not reconcile transfer")
		local fresh = harness({
			repository = h.repository,
			clock = h.clock,
			lock = "defer-" .. tostring(after),
		})
		check(fresh.load.status == "Ready")
		local p = fresh.session.snapshot()
		check(p.economy.energyUnits == 1_000_000_000_000 - 20)
		check(
			p.economy.worldRewardReceipt.remainingUnits == 0
				and p.economy.worldRewardReceipt.operationId == grant
		)
		check(fresh.actions.reconcile(fresh.session).status == "Unchanged")
		check(fresh.visit(entry).status == "AlreadyCommitted")
		check(equal(p, fresh.session.snapshot()))
	end
end
local function rewardContractsAndProtectedLoads()
	local r = Registry.new(Definitions)
	local reward = check(r.worldReward, "missing immutable DEV reward")
	check(table.isfrozen(reward) and reward.energyUnits == 5 and reward.completionProgress == 3)
	for _, mutate in
		{
			function(c: any)
				c.worldReward = nil
			end,
			function(c: any)
				c.worldReward.id = "world-reward/forged"
			end,
			function(c: any)
				c.worldReward.objectiveId = "field-objective/mid-a-route"
			end,
			function(c: any)
				c.worldReward.energyUnits = 0
			end,
			function(c: any)
				c.worldReward.energyUnits = 5.5
			end,
			function(c: any)
				c.worldReward.energyUnits = math.huge
			end,
			function(c: any)
				c.worldReward.energyUnits = 6
			end,
			function(c: any)
				c.worldReward.completionProgress = 1
			end,
			function(c: any)
				c.worldReward.configSnapshotId = "client/forged"
			end,
		}
	do
		local c = copy(Definitions)
		mutate(c)
		check(not pcall(Registry.new, c), "unauthorized reward binding")
	end
	local h = harness({ energy = 0 })
	check(h.visit(entry, false).reason == "OUT_OF_RANGE")
	check(h.visit("landmark/unknown").reason == "ACCESS_BLOCKED")
	check(h.visit("landmark/mid-a-entry").reason == "ACCESS_BLOCKED")
	check(h.visit(entry).status == "Committed" and h.visit(clearing).status == "Committed")
	check(h.visit(entry).status == "Committed")
	local valid = h.session.snapshot()
	for _, mutate in
		{
			function(p: any)
				p.economy.worldRewardReceipt.remainingUnits = 6
			end,
			function(p: any)
				p.economy.worldRewardReceipt.sourceReference = "event/unbound"
			end,
			function(p: any)
				p.economy.worldRewardReceipt.energyUnits = 6
			end,
			function(p: any)
				p.world.objectives[objective] = 2
			end,
			function(p: any)
				p.economy.worldRewardReceipt.operationId = "forged"
			end,
		}
	do
		local bad = copy(valid)
		mutate(bad)
		check(h.energy.validate(bad) ~= nil, "invalid reward receipt trusted")
		check(harness({ seed = bad }).load.status == "ProtectedLoadFailure")
	end
	check(Energy.new().validate(valid) ~= nil, "unbound world reward accepted")
end
local function rewardReceiptSurvivesAuditAndLegacy()
	local h = harness({ energy = 0 })
	check(h.visit(entry).status == "Committed" and h.visit(clearing).status == "Committed")
	check(h.visit(entry).status == "Committed")
	local p = h.session.snapshot()
	local receipt = copy(p.economy.worldRewardReceipt)
	for n = 1, 33 do
		local snapshot = h.session.snapshot()
		local op = "audit-reward-" .. n
		check(h.session.checkpoint(op, function(candidate: any)
			check(h.energy.apply(candidate, {
				operationId = op,
				reasonCode = "production-claim",
				sourceOrSinkId = "vault/production",
				deltaUnits = 0,
				timestamp = 1000,
				configSnapshotId = "content-snapshot/imp9-production-dev-v1",
				expectedRevision = snapshot.profileRevision,
			}).status == "Applied")
		end).status == "Committed")
	end
	p = h.session.snapshot()
	check(#p.economy.recentEnergyOperations == 32 and equal(receipt, p.economy.worldRewardReceipt))
	check(h.visit(entry).status == "AlreadyCommitted" and equal(p, h.session.snapshot()))
	local legacy = copy(p)
	legacy.economy.worldRewardReceipt = nil
	legacy.economy.recentEnergyOperations = {}
	legacy.economy.energyUnits = 0 -- Already-completed pre-binding objective; no backfill.
	local old = harness({ seed = legacy })
	local before = old.session.snapshot()
	check(old.load.status == "Ready" and old.visit(entry).status == "AlreadyCommitted")
	check(old.actions.reconcile(old.session).status == "Unchanged")
	check(equal(before, old.session.snapshot()), "legacy completion generated retroactive reward")
end
return {
	rewardExactlyOnceAndRejoin = rewardExactlyOnceAndRejoin,
	rewardUnknownCutPoints = rewardUnknownCutPoints,
	rewardRaceAndContextFence = rewardRaceAndContextFence,
	rewardDeferredHeadroom = rewardDeferredHeadroom,
	rewardDeferredCutPoints = rewardDeferredCutPoints,
	rewardContractsAndProtectedLoads = rewardContractsAndProtectedLoads,
	rewardReceiptSurvivesAuditAndLegacy = rewardReceiptSurvivesAuditAndLegacy,
	authoredContracts = authoredContracts,
	registryContracts = registryContracts,
	masteryRequiresActiveEvidence = masteryRequiresActiveEvidence,
	regionalProvenanceAndHeld = regionalProvenanceAndHeld,
	accessBindingsAndRejoin = accessBindingsAndRejoin,
	unknownWriteCutPoints = unknownWriteCutPoints,
	travelDiscoveryCutPointsAndRace = travelDiscoveryCutPointsAndRace,
	racesStaleAndInsufficient = racesStaleAndInsufficient,
	protectedStateAndHistoricalMastery = protectedStateAndHistoricalMastery,
	captureActionsFailClosed = captureActionsFailClosed,
}
