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
	local energy = Energy.new(progression.boundSinks)
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
	local actions =
		WorldActions.new({ world = world, progression = progression, newOperationId = operation })
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
	check(p.economy.energyUnits == before.economy.energyUnits, "unbound world reward minted")
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
	check(p.economy.energyUnits == 600)
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
	check(rejoined.session.snapshot().economy.energyUnits == 600)
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
	local poor = harness({ energy = 73 })
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
end
return {
	authoredContracts = authoredContracts,
	registryContracts = registryContracts,
	masteryRequiresActiveEvidence = masteryRequiresActiveEvidence,
	regionalProvenanceAndHeld = regionalProvenanceAndHeld,
	accessBindingsAndRejoin = accessBindingsAndRejoin,
	unknownWriteCutPoints = unknownWriteCutPoints,
	racesStaleAndInsufficient = racesStaleAndInsufficient,
	protectedStateAndHistoricalMastery = protectedStateAndHistoricalMastery,
	captureActionsFailClosed = captureActionsFailClosed,
}
