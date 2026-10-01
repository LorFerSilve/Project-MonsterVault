--!strict
local Vault = require("../../src/server/domains/vault/VaultService")
local UseCase = require("../../src/server/application/VaultCapacityUseCase")
local Publisher = require("../../src/server/application/VaultCapacityProjection")
local Contract = require("../../src/shared/contracts/VaultProjectionV1")
local Config = require("../../src/shared/config/VaultCapacityFixture")
local Schema = require("../../src/server/infrastructure/persistence/ProfileSchemaV1")
local Session = require("../../src/server/infrastructure/persistence/ProfileSession")
local Queue = require("../../src/server/infrastructure/persistence/SingleWriterQueue")
local Retry = require("../../src/server/infrastructure/persistence/RetryPolicy")
local Clock = require("../fixtures/FakeClock")
local Repository = require("../fixtures/FakeProfileRepository")
local Controller = require("../../src/client/controllers/VaultController")
local ClientGateway = require("../../src/client/networking/ClientGateway")
local Store = require("../../src/client/store/ProjectionStore")
local ProjectionV1 = require("../../src/shared/contracts/ProjectionV1")
local Routes = require("../../src/shared/contracts/RouteIds")
local Protocol = require("../../src/shared/contracts/ProtocolV1")
local Codes = require("../../src/shared/contracts/ResultCodes")
local Wire = require("../../src/shared/contracts/WireValidation")

local function copy(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local out = {}
	for key, child in value do
		out[key] = copy(child)
	end
	return out
end
local function equal(a: any, b: any): boolean
	if type(a) ~= type(b) then
		return false
	end
	if type(a) ~= "table" then
		return a == b
	end
	for key, value in a do
		if not equal(value, b[key]) then
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
local function profile(count: number, base: number): any
	local p = Schema.default(1_700_000_000)
	p.profileRevision, p.lastSuccessfulSaveAt = 20, 1_700_000_000
	p.vault = {
		capacitySchemaVersion = 1,
		capacityBase = { units = base, sourceId = "migration/imp9-dev-capacity-v1" },
	}
	p.collection.creaturesById = {}
	p.economy = { energyMilli = 5000 }
	for index = 1, count do
		local id, op = string.format("creature-%02d", index), "capture-op-" .. index
		p.collection.creaturesById[id] = {
			creatureInstanceId = id,
			ownerUserId = 42,
			speciesId = "species/test",
			operationId = op,
			securedAt = 1_700_000_000,
			securedSequence = index + 1,
			locked = true,
			overflowHeld = false,
			origin = { spawnContextId = "spawn/test", contentSnapshotId = "content/test" },
			variantIdentity = {
				speciesRarityId = "rarity/common",
				variantSignature = "variant/test",
				mutationIdsCanonical = {},
				traitIds = {},
				protectedVariantReasons = { "protected/test" },
				spawnContextId = "spawn/test",
				contentSnapshotId = "content/test",
			},
		}
		p.recentOperations[op] = index + 1
	end
	assert(Schema.validate(p), "valid owned fixture")
	return p
end
local function session(repository: any, vault: any, lock: string?): any
	local clock = Clock.new(1_700_000_000, 0)
	return Session.new({
		userId = 42,
		lockId = lock or "vault-owner",
		jobId = "vault-job",
		repository = repository,
		schema = Schema,
		prepareProfile = vault.prepare,
		queue = Queue.new(clock.monotonicClock.seconds, clock.advance, 10),
		retry = Retry.new(clock.monotonicClock.seconds, clock.advance, function()
			return 0.5
		end, 3),
		unixSeconds = clock.wallClock.unixSeconds,
		monotonicSeconds = clock.monotonicClock.seconds,
	})
end
local function harness(): (any, any, any, () -> number)
	local vault = Vault.new(Config)
	local repo = Repository.new()
	local seed = profile(3, 2)
	seed.collection.creaturesById["creature-03"].overflowHeld = true
	repo.seed("player/42", seed)
	local active = session(repo, vault)
	assert(active.acquire().status == "Ready", "owner acquired")
	local ids = 0
	local useCase = UseCase.new({
		vault = vault,
		newOperationId = function()
			ids += 1
			return "vault-op-" .. ids
		end,
	})
	return active, repo, useCase, function()
		return ids
	end
end
local function makeSpace(active: any)
	assert(active.checkpoint("earned-capacity", function(p)
		p.vault.earnedUpgradeLevels = { [Config.collectionCapacityUpgradeId] = 1 }
	end).status == "Committed", "server upgrade state saved")
end

local function authorizedComponents()
	local config = table.clone(Config)
	config.commercialCapacityById, config.temporaryCapacityById =
		{ ["entitlement/test"] = 3 }, { ["grant/test"] = 2 }
	local readers: any = {
		commercial = function()
			return { ["entitlement/test"] = 3 }
		end,
		temporary = function()
			return { ["grant/test"] = 2 }
		end,
	}
	local vault = Vault.new(config, readers)
	config.baseCollectionCapacity, config.commercialCapacityById["entitlement/test"] = 0, 100
	readers.commercial = function()
		return { ["forged/test"] = 100 }
	end
	local p = profile(1, 10)
	p.vault.capacityBase = nil
	p.vault.earnedUpgradeLevels = { [Config.collectionCapacityUpgradeId] = 1 }
	local status = assert(vault.collectionStatus(p), "server-verified sources")
	assert(
		status.capacity == 21
			and equal(status.components, { base = 10, earned = 6, commercial = 3, temporary = 2 }),
		"additive identifiable snapshot"
	)
	assert(p.economy.energyMilli == 5000, "capacity sources do not affect production/wallet")
	local unbound = Vault.new(Config)
	p.commerce.collectionCapacityEntitlements = { forged = 99 }
	assert(
		unbound.prepare(p).reason == "CAPACITY_AUTHORITY_UNBOUND",
		"persisted claims do not authorize paid capacity"
	)
	assert(
		Vault.new(config, { commercial = readers.commercial }).prepare(p).status == "Protected",
		"unknown source fails protected"
	)
	p.commerce = {}
	p.vault.earnedUpgradeLevels = { ["unknown/upgrade"] = 1 }
	assert(unbound.prepare(p).reason == "UNKNOWN_UPGRADE_ID", "no silent unknown upgrade loss")
	p.vault.earnedUpgradeLevels = { [Config.collectionCapacityUpgradeId] = 99 }
	assert(unbound.prepare(p).reason == "UNKNOWN_UPGRADE_LEVEL", "no fallback or clamp")
end

local function deterministicReconciliation()
	local vault, p = Vault.new(Config), profile(6, 2)
	p.collection.capacityPriority = { "creature-06" }
	p.vault.productionAssignments = { ["slot/z"] = "creature-04", ["slot/a"] = "creature-03" }
	p.vault.displayAssignments = {
		["display/a"] = "creature-04",
		["display/b"] = "creature-06",
		["display/c"] = "creature-06",
		["display/d"] = "missing",
	}
	p.vault.productionBufferMilli = 100
	local before = copy(p)
	assert(
		vault.prepare(p).reason == "PRODUCTION_SETTLEMENT_REQUIRED" and equal(p, before),
		"no clearing before settlement"
	)
	local settled = 0
	local result = vault.prepare(p, function(staged)
		assert(
			staged.vault.productionAssignments["slot/z"] == "creature-04"
				and not staged.collection.creaturesById["creature-04"].overflowHeld,
			"settlement precedes invalidation"
		)
		staged.vault.productionBufferMilli += 20
		settled += 1
		return true, true
	end)
	assert(result.status == "Prepared" and result.changed and settled == 1, "staged settlement")
	for id, record in p.collection.creaturesById do
		assert(
			record.overflowHeld == (id ~= "creature-06" and id ~= "creature-03"),
			"priority then stable active role survives"
		)
		local unchanged = copy(record)
		unchanged.overflowHeld = before.collection.creaturesById[id].overflowHeld
		assert(
			equal(unchanged, before.collection.creaturesById[id]),
			"ownership/lock/identity/provenance preserved"
		)
	end
	assert(
		p.vault.productionAssignments["slot/z"] == nil
			and p.vault.productionAssignments["slot/a"] == "creature-03",
		"only affected assignment removed"
	)
	assert(
		equal(p.vault.displayAssignments, { ["display/b"] = "creature-06" })
			and p.vault.productionBufferMilli == 120,
		"references repaired without economic loss"
	)
	assert(p.economy.energyMilli == 5000, "no release/reward")
	assert(not vault.prepare(p, function()
		return true, false
	end).changed, "second reconciliation is idempotent")
	local q = profile(4, 2)
	q.collection.creaturesById["creature-01"].securedSequence = 5
	q.collection.creaturesById["creature-02"].securedSequence = 5
	q.collection.creaturesById["creature-03"].securedSequence = 4
	q.collection.creaturesById["creature-04"].securedSequence = 6
	assert(vault.prepare(q).status == "Prepared", "sequence fallback")
	assert(
		not q.collection.creaturesById["creature-01"].overflowHeld
			and not q.collection.creaturesById["creature-03"].overflowHeld,
		"acquisition sequence then lexical tie"
	)
end

local function protectedLoad()
	local vault = Vault.new(Config)
	local invalid = {}
	local p = profile(3, 2)
	p.collection.capacityPriority = { "creature-01", "creature-01" }
	table.insert(invalid, p)
	p = profile(3, 2)
	p.vault.earnedUpgradeLevels = { ["unknown/upgrade"] = 1 }
	table.insert(invalid, p)
	p = profile(3, 2)
	p.commerce.collectionCapacityEntitlements = { ["fake/entitlement"] = 1 }
	table.insert(invalid, p)
	p = profile(3, 2)
	p.vault.productionBufferMilli = 100
	table.insert(invalid, p)
	p = profile(3, 2)
	p.collection.creaturesById["creature-01"].securedSequence = nil
	p.recentOperations["capture-op-1"] = nil
	table.insert(invalid, p)
	for _, seed in invalid do
		local repo = Repository.new()
		repo.seed("player/42", seed)
		assert(
			session(repo, vault).acquire().status == "ProtectedLoadFailure",
			"invalid authority/order never Ready"
		)
		assert(
			equal(repo.read("player/42").value, seed),
			"protected load does not overwrite ownership/progress"
		)
	end
end

local function idempotentMigration()
	local vault, p = Vault.new(Config), profile(3, 2)
	p.vault = {}
	p.progression.collectionCapacity = 2
	for _, record in p.collection.creaturesById do
		record.securedSequence = nil
	end
	local repo = Repository.new()
	repo.seed("player/42", p)
	repo.setReplayTransform(true)
	local active = session(repo, vault)
	assert(active.acquire().status == "Ready", "reconciliation before Ready")
	local saved = active.snapshot()
	assert(
		saved.profileRevision == 21
			and saved.progression.collectionCapacity == nil
			and saved.vault.capacityBase.units == 2,
		"migration advances once and preserves legacy base"
	)
	assert(
		saved.collection.creaturesById["creature-03"].overflowHeld
			and saved.collection.creaturesById["creature-01"].securedSequence == 2,
		"durable ledger preserves original sequence"
	)
	assert(not vault.prepare(saved).changed, "transform replay and repeated preparation idempotent")
	local ids = 0
	local useCase = UseCase.new({
		vault = vault,
		newOperationId = function()
			ids += 1
			return "reconcile-" .. ids
		end,
	})
	assert(
		useCase.reconcile(active).status == "Unchanged" and ids == 0,
		"healthy reads do not checkpoint"
	)
	assert(active.release(10).status == "Closed", "lease released")
	local rejoin = session(repo, vault, "vault-rejoin")
	assert(
		rejoin.acquire().status == "Ready"
			and rejoin.snapshot().collection.creaturesById["creature-03"].overflowHeld,
		"rejoin keeps exact owned record"
	)
end

local function resolutionExactlyOnce()
	local active, repo, useCase = harness()
	local rev = active.snapshot().profileRevision
	assert(
		useCase.resolve(active, "foreign-creature", rev).reason == "OWNERSHIP",
		"authenticated owner's exact collection"
	)
	assert(
		useCase.resolve(active, "creature-03", rev).reason == "CAPACITY_FULL",
		"full capacity rejects without loss"
	)
	makeSpace(active)
	local before = active.snapshot()
	local held = before.collection.creaturesById["creature-03"]
	assert(held.overflowHeld, "capacity gain never auto-resolves")
	assert(
		useCase.resolve(active, "creature-03", rev).reason == "STALE_REVISION",
		"explicit action requires fresh revision"
	)
	assert(
		useCase.resolve(active, "creature-03", before.profileRevision).status == "Committed",
		"P2 saves selected instance"
	)
	local after = active.snapshot()
	held.overflowHeld = false
	assert(
		equal(after.collection.creaturesById["creature-03"], held)
			and equal(after.economy, before.economy),
		"only placement flag changes"
	)
	assert(
		after.vault.displayAssignments == nil and after.vault.productionAssignments == nil,
		"no implicit role assignment"
	)
	local writes = repo.calls()
	assert(
		useCase.resolve(active, "creature-03", rev).status == "AlreadyStored"
			and repo.calls() == writes,
		"duplicate old-revision selection does not create value/write"
	)
end

local function uncertainResults()
	for _, afterWrite in { false, true } do
		local active, repo, useCase, ids = harness()
		makeSpace(active)
		local rev = active.snapshot().profileRevision
		if afterWrite then
			repo.loseNextResultAfterWrite()
		else
			for _ = 1, 3 do
				repo.failNext({ status = "error", reason = "TRANSIENT", retryable = true })
			end
		end
		assert(
			useCase.resolve(active, "creature-03", rev).status == "OutcomeUnknown",
			"lost/failed write stays uncertain"
		)
		assert(
			active.state() == "PersistenceAtRisk"
				and active.snapshot().collection.creaturesById["creature-03"].overflowHeld,
			"no inferred success"
		)
		assert(
			repo.read("player/42").value.collection.creaturesById["creature-03"].overflowHeld
				== not afterWrite,
			"durable cut point distinguished"
		)
		assert(
			useCase.reconcile(active).status == "Unchanged" and active.state() == "Ready",
			"same pending operation reconciled"
		)
		assert(
			ids() == 1
				and active.snapshot().profileRevision == rev + 1
				and not active.snapshot().collection.creaturesById["creature-03"].overflowHeld,
			"exactly one mutation/revision"
		)
		assert(
			useCase.resolve(active, "creature-03", rev).status == "AlreadyStored",
			"replay remains idempotent"
		)
	end
end

local function boundedProjections()
	local vault, p = Vault.new(Config), profile(0, 10)
	for index = 1, 12 do
		local id = string.format("%03d", index) .. string.rep("x", 125)
		local seed = profile(1, 10).collection.creaturesById["creature-01"]
		seed.creatureInstanceId, seed.overflowHeld = id, true
		p.collection.creaturesById[id] = seed
	end
	local seen, cursor, pages = {}, nil, 0
	repeat
		local payload = Publisher.fromProfile(p, vault, cursor)
		assert(
			Contract.validSnapshot(payload) and Wire.payload(payload),
			"worst ID lengths fit reliable bound"
		)
		pages += 1
		for _, id in payload.state.overflowCreatureInstanceIds do
			assert(not seen[id], "no duplicate page identity")
			seen[id] = true
			cursor = id
		end
		if not payload.state.hasMore then
			break
		end
	until pages > 12
	assert(pages == 4, "bounded cursor traverses all overflow")
	assert(Contract.validResolve({ creatureInstanceId = cursor }, 20), "exact-instance intent")
	local hostilePayloads: { any } = {
		{ creatureInstanceId = cursor, capacity = 100 },
		{ creatureInstanceId = cursor, ownerUserId = 42 },
		{ creatureInstanceId = cursor, quantity = 2 },
	}
	for _, payload in hostilePayloads do
		assert(not Contract.validResolve(payload, 20), "client cannot supply authority")
	end
	assert(
		not Contract.validResolve({ creatureInstanceId = cursor }, nil),
		"Class C revision required"
	)
	assert(
		Routes.commandClassById[Routes.commands.vaultResolveOverflow] == "C",
		"sensitive route remains Class C"
	)
end

local function clientIntentOnly()
	local now, sent, store = 0, {}, Store.new(ProjectionV1, Wire)
	local gateway = ClientGateway.new({
		protocol = Protocol,
		routes = Routes,
		resultCodes = Codes,
		wire = Wire,
		store = store,
		vaultProjection = Contract,
		sendCommand = function(e)
			table.insert(sent, e)
		end,
	})
	assert(store.snapshot({
		domain = "session",
		revision = 1,
		state = { status = "Ready", profileRevision = 20 },
	}) == "Applied", "trusted ready state")
	local controller = Controller.new({
		gateway = gateway,
		routes = Routes,
		projection = Contract,
		sessionReady = function()
			return store.view().status == "Ready"
		end,
		clock = function()
			return now
		end,
	})
	controller.tick()
	local p = profile(1, 2)
	p.collection.creaturesById["creature-01"].overflowHeld = true
	local payload = Publisher.fromProfile(p, Vault.new(Config))
	local envelope = {
		protocolVersion = 1,
		routeId = Routes.events.projectionSnapshot,
		revision = 20,
		correlationId = sent[1].requestId,
		payload = payload,
	}
	assert(
		gateway.handleEvent(envelope) == "Vault"
			and controller.handleSnapshot(envelope) == "Applied",
		"bounded trusted projection"
	)
	controller.selectCreature("foreign-creature")
	assert(not controller.view().canResolve, "selection restricted to server page")
	controller.selectCreature("creature-01")
	local requestId = controller.resolve()
	assert(
		requestId ~= nil
			and sent[2].expectedRevision == 20
			and equal(sent[2].payload, { creatureInstanceId = "creature-01" }),
		"explicit exact selection only"
	)
	assert(controller.resolve() == nil, "double activation blocked")
	assert(
		controller.handleSnapshot(envelope) == "Stale" and controller.view().pending,
		"pre-intent readback cannot confirm action"
	)
	gateway.handleEvent({
		protocolVersion = 1,
		routeId = Routes.events.commandResult,
		correlationId = requestId,
		payload = { code = "OUTCOME_UNKNOWN_VAULT_RESOLUTION" },
	})
	now = 5
	controller.tick()
	assert(
		controller.view().pending and controller.view().snapshot.state.overflowHeldCount == 1,
		"unknown result never fabricates stored ownership"
	)
	local stale = copy(envelope)
	stale.revision = 19
	stale.payload.revision = 19
	assert(gateway.handleEvent(stale) == "Stale", "client rejects wrong aggregate revision")
	p.profileRevision = 21
	p.collection.creaturesById["creature-01"].overflowHeld = false
	assert(store.snapshot({
		domain = "session",
		revision = 2,
		state = { status = "Ready", profileRevision = 21 },
	}) == "Applied", "server session revision refreshed")
	envelope.payload, envelope.revision, envelope.correlationId =
		Publisher.fromProfile(p, Vault.new(Config)), 21, sent[3].requestId
	assert(
		gateway.handleEvent(envelope) == "Vault"
			and controller.handleSnapshot(envelope) == "Applied"
			and not controller.view().pending,
		"durable readback concludes uncertainty"
	)
	assert(controller.view().snapshot.state.overflowHeldCount == 0, "authoritative state only")
end

return {
	authorizedComponents = authorizedComponents,
	deterministicReconciliation = deterministicReconciliation,
	protectedLoad = protectedLoad,
	idempotentMigration = idempotentMigration,
	resolutionExactlyOnce = resolutionExactlyOnce,
	uncertainResults = uncertainResults,
	boundedProjections = boundedProjections,
	clientIntentOnly = clientIntentOnly,
}
