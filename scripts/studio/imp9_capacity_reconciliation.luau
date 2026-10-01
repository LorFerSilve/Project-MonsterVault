--!strict

-- Explicit DEV test harness; uses real UpdateAsync and the shipped server gateway.
-- Install temporarily via Roblox MCP. Does not reset the normal player profile.
local globals = getfenv() :: any
local state: any = nil
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

local function setup(): any
	assert(state == nil, "probe already running")
	assert(
		game:GetService("RunService"):IsStudio() and game:GetService("RunService"):IsServer(),
		"Studio server only"
	)
	local server: any = game:GetService("ServerScriptService").MonsterVaultServer
	local shared: any = game:GetService("ReplicatedStorage").MonsterVault.Shared
	local binding = require(server.bootstrap.ProfileBinding)
	assert(
		binding.environment == "DEV" and binding.declaredUniverseId == game.GameId,
		"verified DEV binding"
	)
	local http = game:GetService("HttpService")
	local players = game:GetService("Players")
	local player = assert(players:GetPlayers()[1], "real joined client")
	local storeService = game:GetService("DataStoreService")
	local scope = "IMP9Reconcile-" .. http:GenerateGUID(false)
	local key = "player/" .. player.UserId
	local schema = require(server.infrastructure.persistence.ProfileSchemaV1)
	local config = table.clone(require(shared.config.VaultCapacityFixture))
	config.baseCollectionCapacity = 2
	local vault = require(server.domains.vault.VaultService).new(config)
	local function repositoryFor(scopeName: string): any
		return require(server.adapters.RobloxProfileRepository).new({
			GetDataStore = function(_self: any, name: string)
				return storeService:GetDataStore(name, scopeName)
			end,
		}, true, "DEV")
	end
	local repository = repositoryFor(scope)
	local function newSession(repo: any?): any
		return require(server.infrastructure.persistence.ProfileSession).new({
			userId = player.UserId,
			lockId = http:GenerateGUID(false),
			jobId = "imp9-" .. http:GenerateGUID(false),
			repository = repo or repository,
			schema = schema,
			prepareProfile = vault.prepare,
			queue = require(server.infrastructure.persistence.SingleWriterQueue).new(
				os.clock,
				globals.task.wait,
				25
			),
			retry = require(server.infrastructure.persistence.RetryPolicy).new(
				os.clock,
				globals.task.wait,
				function()
					return 0.5
				end,
				3
			),
			unixSeconds = os.time,
			monotonicSeconds = os.clock,
		})
	end
	local active = newSession()
	assert(active.acquire().status == "Ready", "isolated profile ready")
	local finalization = require(server.application.CaptureFinalizationUseCase).new(vault)
	local fixture = require(server.domains.world.FixtureDefinition)
	local variant = require(server.domains.capture.VariantIdentity)
	local ids, operations = {}, {}
	for index = 1, 3 do
		local id, operation = "imp9-creature-" .. http:GenerateGUID(false), http:GenerateGUID(false)
		ids[index], operations[index] = id, operation
		local outcome = finalization.finalize(active, {
			ownerUserId = player.UserId,
			operationId = operation,
			creatureInstanceId = id,
			speciesId = fixture.speciesId,
			securedAt = os.time(),
			origin = {
				spawnContextId = fixture.spawnContextId,
				contentSnapshotId = fixture.contentSnapshotId,
			},
			variantIdentity = variant.generate(fixture, {
				nextUnit = function()
					return 0.1
				end,
			}),
		})
		assert(
			outcome.status == "Secured" and outcome.overflowHeld == (index == 3),
			"real P2 finalization placement"
		)
	end
	local capacity = require(server.application.VaultCapacityUseCase).new({
		vault = vault,
		newOperationId = function()
			return http:GenerateGUID(false)
		end,
	})
	local full = capacity.resolve(active, ids[3], active.snapshot().profileRevision)
	assert(full.status == "Rejected" and full.reason == "CAPACITY_FULL", "full collection rejects")
	assert(active.checkpoint(http:GenerateGUID(false), function(p)
		p.vault.earnedUpgradeLevels = { [config.collectionCapacityUpgradeId] = 1 }
	end).status == "Committed", "server-earned test state saved")
	assert(
		active.snapshot().collection.creaturesById[ids[3]].overflowHeld,
		"gain never auto-resolves"
	)
	local root = globals.Instance.new("Folder")
	root.Name, root.Parent = "IMP9CapacityProbeRemotes", game:GetService("ReplicatedStorage")
	local command, event, unreliable =
		globals.Instance.new("RemoteEvent"),
		globals.Instance.new("RemoteEvent"),
		globals.Instance.new("UnreliableRemoteEvent")
	command.Name, event.Name, unreliable.Name = "Command", "Event", "UnreliableEvent"
	command.Parent, event.Parent, unreliable.Parent = root, root, root
	local result: any = {
		testId = "T15.vault.Studio.reconciliationResolution",
		seedId = "fixture:imp9-capacity-reconciliation-v1",
		criticality = "C0",
		verificationClass = "V4",
		environment = "DEV",
		scope = scope,
		placeId = game.PlaceId,
		universeId = game.GameId,
		studioVersion = globals.version(),
		userId = player.UserId,
		creatureInstanceIds = ids,
		captureOperationIds = operations,
		fullCapacityResult = full,
		beforeResolutionRevision = active.snapshot().profileRevision,
		events = {},
		diagnostics = {},
		beforeResolutionProfile = active.snapshot(),
	}
	local networking = require(server.bootstrap.NetworkingRuntimeService).new({
		command = command,
		event = event,
		unreliableEvent = unreliable,
		players = players,
		vault = vault,
		capacity = capacity,
		profileCoordinator = {
			get = function(userId: number)
				return if userId == player.UserId then active else nil
			end,
		},
		diagnostics = {
			emit = function(severity: string, code: string, fields: any)
				table.insert(
					result.diagnostics,
					{ severity = severity, code = code, fields = fields }
				)
			end,
		},
	})
	local observer = command.OnServerEvent:Connect(function(sender, envelope)
		table.insert(result.events, { userId = sender.UserId, envelope = envelope })
	end)
	networking.start()
	state = {
		active = active,
		root = root,
		networking = networking,
		observer = observer,
		result = result,
		vault = vault,
		capacity = capacity,
		newSession = newSession,
		storeService = storeService,
		repositoryFor = repositoryFor,
		schema = schema,
		key = key,
		config = config,
	}
	return {
		scope = scope,
		targetId = ids[3],
		revision = active.snapshot().profileRevision,
		capacity = vault.collectionStatus(active.snapshot()),
		normalProfile = storeService:GetDataStore("MV_DEV_PlayerProfile_v1"):GetAsync(key),
	}
end
local function status(): any
	assert(state ~= nil, "probe not started")
	return {
		capacity = state.vault.collectionStatus(state.active.snapshot()),
		profileRevision = state.active.snapshot().profileRevision,
		events = state.result.events,
		diagnostics = state.result.diagnostics,
	}
end
local function finish(): any
	assert(state ~= nil, "probe not started")
	local result, active, ids = state.result, state.active, state.result.creatureInstanceIds
	local resolved = active.snapshot()
	assert(
		not resolved.collection.creaturesById[ids[3]].overflowHeld,
		"real client explicitly resolved selected instance"
	)
	assert(
		resolved.profileRevision == result.beforeResolutionRevision + 1,
		"exactly one resolution checkpoint"
	)
	local before = result.beforeResolutionProfile.collection.creaturesById[ids[3]]
	before.overflowHeld = false
	assert(
		equal(before, resolved.collection.creaturesById[ids[3]])
			and equal(resolved.economy, result.beforeResolutionProfile.economy),
		"identity/lock/progress unchanged"
	)
	result.afterResolutionRevision = resolved.profileRevision
	result.duplicateResult = state.capacity.resolve(active, ids[3], result.beforeResolutionRevision)
	assert(
		result.duplicateResult.status == "AlreadyStored"
			and active.snapshot().profileRevision == resolved.profileRevision,
		"duplicate adds no write/value"
	)
	assert(active.checkpoint(game:GetService("HttpService"):GenerateGUID(false), function(p)
		p.vault.earnedUpgradeLevels = nil
		p.collection.capacityPriority = { ids[3] }
		p.vault.displayAssignments = { ["display/test"] = ids[2] }
		assert(state.vault.prepare(p).status == "Prepared", "atomic drop reconciliation")
	end).status == "Committed", "drop checkpoint")
	local dropped = active.snapshot()
	assert(
		dropped.collection.creaturesById[ids[2]].overflowHeld
			and not dropped.collection.creaturesById[ids[3]].overflowHeld,
		"pinned then original sequence survive"
	)
	assert(next(dropped.vault.displayAssignments) == nil, "affected display cleared")
	assert(not state.vault.prepare(dropped).changed, "idempotent drop")
	result.afterDropRevision, result.afterDropCapacity =
		dropped.profileRevision, state.vault.collectionStatus(dropped)
	assert(active.release(os.clock() + 25).status == "Closed", "isolated lease released")
	local rejoin = state.newSession()
	state.rejoin = rejoin
	assert(rejoin.acquire().status == "Ready", "real reacquire")
	local loaded = rejoin.snapshot()
	assert(
		loaded.profileRevision == dropped.profileRevision
			and equal(loaded.collection, dropped.collection),
		"rejoin retains all three exact instances and placement"
	)
	result.rejoinRevision, result.rejoinCapacity =
		loaded.profileRevision, state.vault.collectionStatus(loaded)
	result.rejoinOwnedCount = 0
	for _ in loaded.collection.creaturesById do
		result.rejoinOwnedCount += 1
	end
	assert(result.rejoinOwnedCount == 3, "no ownership lost")
	local badScope = "IMP9Bad-" .. game:GetService("HttpService"):GenerateGUID(false)
	local badStore = state.storeService:GetDataStore("MV_DEV_PlayerProfile_v1", badScope)
	local bad = loaded
	bad.vault.earnedUpgradeLevels = { ["unknown/upgrade"] = 1 }
	badStore:UpdateAsync(state.key, function()
		return bad
	end)
	result.protectedLoad = state.newSession(state.repositoryFor(badScope)).acquire()
	assert(
		result.protectedLoad.status == "ProtectedLoadFailure"
			and equal(badStore:GetAsync(state.key), bad),
		"invalid authority preserves durable profile"
	)
	assert(rejoin.release(os.clock() + 25).status == "Closed", "rejoin lease released")
	state.networking.stop()
	state.observer:Disconnect()
	state.root:Destroy()
	result.result = "PASS"
	result.beforeResolutionProfile = nil
	state = nil
	return result
end
return {
	setup = setup,
	status = status,
	finish = finish,
	abort = function()
		if state == nil then
			return
		end
		state.networking.stop()
		state.observer:Disconnect()
		state.root:Destroy()
		if state.rejoin ~= nil then
			state.rejoin.release(os.clock() + 25)
		end
		state.active.release(os.clock() + 25)
		state = nil
	end,
}
