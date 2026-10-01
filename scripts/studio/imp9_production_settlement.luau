--!strict

-- Temporary Studio-only native DEV probe. Unique scopes preserve normal progress.
local globals = getfenv() :: any
local state: any = nil
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
local function setup(resume: any?, withEnergy: boolean?): any
	assert(
		state == nil
			and game:GetService("RunService"):IsStudio()
			and game:GetService("RunService"):IsServer(),
		"fresh Studio server probe"
	)
	local server: any = game:GetService("ServerScriptService").MonsterVaultServer
	local shared: any = game:GetService("ReplicatedStorage").MonsterVault.Shared
	local http, players, stores =
		game:GetService("HttpService"),
		game:GetService("Players"),
		game:GetService("DataStoreService")
	local player = assert(players:GetPlayers()[1], "joined native client")
	local binding = require(server.bootstrap.ProfileBinding)
	assert(
		binding.environment == "DEV" and binding.declaredUniverseId == game.GameId,
		"verified DEV binding"
	)
	local scope = if resume then resume.scope else "IMP9Prod-" .. http:GenerateGUID(false)
	local key = "player/" .. player.UserId
	local repository = require(server.adapters.RobloxProfileRepository).new({
		GetDataStore = function(_self: any, name: string)
			return stores:GetDataStore(name, scope)
		end,
	}, true, "DEV")
	local normalStore = stores:GetDataStore("MV_DEV_PlayerProfile_v1")
	local normal = normalStore:GetAsync(key)
	local schema = require(server.infrastructure.persistence.ProfileSchemaV1)
	local config = table.clone(require(shared.config.VaultCapacityFixture))
	config.baseCollectionCapacity = 2
	local vault = require(server.domains.vault.VaultService).new(config)
	local production = require(server.domains.vault.VaultProductionService).new(
		require(shared.config.VaultProductionFixture)
	)
	local assignments = require(server.application.VaultProductionUseCase).new({
		production = production,
		vault = vault,
		unixSeconds = os.time,
		monotonicSeconds = os.clock,
		newOperationId = function()
			return http:GenerateGUID(false)
		end,
	})
	local energy: any = if withEnergy
		then require(server.domains.economy.EnergyService).new()
		else nil
	local claims: any = if withEnergy
		then require(server.application.ProductionClaimUseCase).new({
			energy = energy,
			production = production,
			vault = vault,
			assignments = assignments,
			newOperationId = function()
				return http:GenerateGUID(false)
			end,
		})
		else nil
	local capacity = require(server.application.VaultCapacityUseCase).new({
		vault = vault,
		settleProduction = assignments.settleProfile,
		newOperationId = function()
			return http:GenerateGUID(false)
		end,
	})
	local fault: any = nil
	local nested: any = nil
	local wrapped = {
		update = function(k: string, transform: any): any
			if nested then
				local callback = nested
				nested = nil
				callback()
			end
			if fault == "Before" then
				fault = nil
				return { status = "error", reason = "PROBE_BEFORE_WRITE", retryable = false }
			end
			local result = repository.update(k, transform)
			if fault == "After" and result.status == "ok" then
				fault = nil
				return { status = "error", reason = "PROBE_LOST_RESULT", retryable = false }
			end
			return result
		end,
	}
	local loadAt = os.time()
	local active = require(server.infrastructure.persistence.ProfileSession).new({
		userId = player.UserId,
		lockId = http:GenerateGUID(false),
		jobId = "imp9-production-probe",
		repository = wrapped,
		schema = schema,
		prepareProfile = function(p: any)
			if energy then
				local wallet = energy.prepare(p)
				if wallet.status ~= "Prepared" then
					return wallet
				end
			end
			return assignments.prepareProfile(p, loadAt)
		end,
		prepareSave = assignments.prepareSave,
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
	assert(active.acquire().status == "Ready", "real UpdateAsync acquire/settlement")
	local ids = if resume then resume.creatureInstanceIds else {}
	if resume == nil then
		local fixture = require(server.domains.world.FixtureDefinition)
		local finalization = require(server.application.CaptureFinalizationUseCase).new(vault)
		for index = 1, 3 do
			local id, op =
				"imp9-prod-" .. index .. "-" .. http:GenerateGUID(false), http:GenerateGUID(false)
			ids[index] = id
			local result = finalization.finalize(active, {
				ownerUserId = player.UserId,
				operationId = op,
				creatureInstanceId = id,
				speciesId = fixture.speciesId,
				securedAt = os.time(),
				origin = {
					spawnContextId = fixture.spawnContextId,
					contentSnapshotId = fixture.contentSnapshotId,
				},
				variantIdentity = require(server.domains.capture.VariantIdentity).generate(
					fixture,
					{
						nextUnit = function()
							return 0.1
						end,
					}
				),
			})
			assert(
				result.status == "Secured" and result.overflowHeld == (index == 3),
				"exact durable capture fixture placement"
			)
		end
	else
		local restored = active.snapshot()
		assert(
			equal(restored.collection, resume.cleanProfile.collection),
			"fresh Play server preserves exact collection"
		)
		assert(
			restored.vault.productionAssignments["production/1"] == ids[1]
				and restored.vault.displayAssignments["display/1"] == ids[1],
			"fresh server restores canonical assignments"
		)
		local elapsed = math.min(
			7200,
			math.max(0, loadAt - resume.cleanProfile.vault.productionCursorUnixSeconds)
		)
		assert(
			restored.vault.productionBufferMilli
				== resume.cleanProfile.vault.productionBufferMilli + elapsed * 100,
			"fresh server offline credit exactly once"
		)
		if withEnergy then
			assert(
				equal(restored.economy, resume.cleanProfile.economy),
				"fresh server restores exact wallet/audit"
			)
			assert(
				claims.claim(active, resume.claimRevision).status == "AlreadyCommitted",
				"rejoin retry keeps original claim"
			)
		end
	end
	local root = globals.Instance.new("Folder")
	root.Name, root.Parent = "IMP9ProductionProbeRemotes", game:GetService("ReplicatedStorage")
	local command, event, unreliable =
		globals.Instance.new("RemoteEvent"),
		globals.Instance.new("RemoteEvent"),
		globals.Instance.new("UnreliableRemoteEvent")
	command.Name, event.Name, unreliable.Name = "Command", "Event", "UnreliableEvent"
	command.Parent, event.Parent, unreliable.Parent = root, root, root
	local result: any = {
		testId = "T15.vault.Studio.productionSettlement",
		verificationClass = "V4",
		criticality = "C0",
		environment = "DEV",
		scope = scope,
		placeId = game.PlaceId,
		universeId = game.GameId,
		studioVersion = globals.version(),
		userId = player.UserId,
		creatureInstanceIds = ids,
		events = {},
		diagnostics = {},
		initialProfile = active.snapshot(),
		normalCollectionBefore = normal.collection,
		normalEconomyBefore = normal.economy,
		loadAt = loadAt,
	}
	local networking = require(server.bootstrap.NetworkingRuntimeService).new({
		command = command,
		unreliableEvent = unreliable,
		event = {
			IsA = function(_self: any, class: string)
				return event:IsA(class)
			end,
			FireClient = function(_self: any, target: any, envelope: any)
				table.insert(result.events, envelope)
				event:FireClient(target, envelope)
			end,
		},
		players = players,
		vault = vault,
		production = production,
		assignments = assignments,
		capacity = capacity,
		energy = energy,
		claims = claims,
		profileCoordinator = {
			get = function(userId: number)
				return if userId == player.UserId then active else nil
			end,
		},
		diagnostics = {
			emit = function(severity: string, code: string)
				table.insert(result.diagnostics, { severity = severity, code = code })
			end,
		},
	})
	networking.start()
	state = {
		active = active,
		networking = networking,
		root = root,
		repository = repository,
		key = key,
		ids = ids,
		result = result,
		normalStore = normalStore,
		vault = vault,
		assignments = assignments,
		production = production,
		energy = energy,
		claims = claims,
		setFault = function(value: string)
			fault = value
		end,
		setNested = function(callback: any)
			nested = callback
		end,
	}
	return result
end
local function prepareClaims(): any
	assert(state ~= nil and state.claims ~= nil, "Energy probe setup")
	local active, app, id = state.active, state.assignments, state.ids[1]
	assert(
		app.assign(active, "production", "production/1", id, active.snapshot().profileRevision).status
			== "Committed",
		"native claim producer assigned"
	)
	assert(
		app.assign(active, "display", "display/1", id, active.snapshot().profileRevision).status
			== "Committed",
		"native claim display assigned"
	)
	state.result.beforeClaimProfile = active.snapshot()
	state.result.claimRevision = active.snapshot().profileRevision
	return state.result.beforeClaimProfile
end
local function claimCases(): any
	assert(state ~= nil and state.claims ~= nil, "Energy probe setup")
	local active, claims = state.active, state.claims
	local saved = active.snapshot()
	state.result.nativeClaimProfile = saved
	assert(saved.economy.energyUnits > 0, "native GUI claim grants real Energy")
	local first = saved.economy.recentEnergyOperations[1]
	assert(
		first.expectedRevision == state.result.claimRevision,
		"claim is bound to clicked revision"
	)
	assert(saved.profileRevision == first.expectedRevision + 1, "one durable claim revision")
	assert(
		equal(saved.collection, state.result.beforeClaimProfile.collection),
		"claim preserves exact collection"
	)
	assert(
		claims.claim(active, first.expectedRevision).status == "AlreadyCommitted",
		"durable duplicate receipt"
	)
	assert(equal(saved, active.snapshot()), "duplicate consumes no new interval")
	state.result.claimFaults = {}
	for _, point in { "Before", "After" } do
		local before = active.snapshot()
		state.setFault(point)
		local result = claims.claim(active, before.profileRevision)
		assert(
			result.status == "OutcomeUnknown" and equal(before, active.snapshot()),
			"claim fault remains uncertain"
		)
		assert(claims.reconcile(active).status == "Unchanged", "claim reconciles exact checkpoint")
		local p = active.snapshot()
		assert(
			p.profileRevision == before.profileRevision + 1 and state.energy.validate(p) == nil,
			"exact claim revision"
		)
		assert(
			claims.claim(active, before.profileRevision).operationId == result.operationId,
			"retry retains GUID"
		)
		table.insert(state.result.claimFaults, { point = point, result = result, profile = p })
	end
	local raced: any = nil
	state.setNested(function()
		raced = claims.claim(active, active.snapshot().profileRevision)
	end)
	assert(
		claims.claim(active, active.snapshot().profileRevision).status == "Committed",
		"primary claim commits"
	)
	assert(raced.status == "Busy", "same profile writer fences concurrent claim")
	state.result.claimRace = raced
	-- Separate source authority remains unbound and cannot mint at a full wallet.
	assert(
		state.energy.apply(active.snapshot(), { reasonCode = "starter-commercial-grant" }).status
			== "Protected",
		"unbound starter authority protected"
	)
	state.result.unboundStarterGrant = "Protected"
	return state.result
end
local function inspect(): any
	assert(state ~= nil, "probe setup required")
	return { profile = state.active.snapshot(), result = state.result }
end
local function armClaimFault(point: string): any
	assert(state ~= nil and state.claims ~= nil, "Energy probe setup")
	state.result.clientFaultBefore = state.active.snapshot()
	state.setFault(point)
	return { expectedRevision = state.result.clientFaultBefore.profileRevision, point = point }
end
local function verifyClaimFault(): any
	local before, after = state.result.clientFaultBefore, state.active.snapshot()
	assert(
		state.active.state() == "Ready" and after.profileRevision == before.profileRevision + 1,
		"client Class A resync reconciles exactly one claim"
	)
	local audit = after.economy.recentEnergyOperations[#after.economy.recentEnergyOperations]
	assert(
		audit.expectedRevision == before.profileRevision and state.energy.validate(after) == nil,
		"correlated claim receipt and wallet after lost response"
	)
	state.result.clientFaultAfter = after
	return { profile = after, audit = audit }
end
local function saveLeave(): any
	assert(state ~= nil, "probe setup required")
	local active = state.active
	local before = active.snapshot()
	assert(
		before.vault.productionAssignments["production/1"] == state.ids[1]
			and before.vault.displayAssignments["display/1"] == state.ids[1],
		"native owner UI assignments saved"
	)
	assert(active.renew().status == "Ready", "production autosave native UpdateAsync")
	local saved = active.snapshot()
	assert(
		saved.vault.productionBufferMilli
			== (
						saved.vault.productionCursorUnixSeconds
						- before.vault.productionCursorUnixSeconds
					)
					* 100
				+ before.vault.productionBufferMilli,
		"online elapsed accounting"
	)
	assert(active.release(os.clock() + 25).status == "Closed", "clean save/unlock")
	local stored = state.repository.update(state.key, function(current: any, metadata: any)
		return { kind = "write", value = current, metadata = metadata }
	end)
	assert(
		stored.status == "ok" and stored.value.vault.lastPresenceBoundary == "CleanOffline",
		"durable clean offline boundary"
	)
	state.result.cleanProfile = stored.value
	state.networking.stop()
	state.root:Destroy()
	return state.result
end
local function faultRaceAndFinish(): any
	assert(state ~= nil, "probe setup required")
	local active, app, ids = state.active, state.assignments, state.ids
	state.result.rejoinedProfile = active.snapshot()
	for _, point in { "Before", "After" } do
		local before = active.snapshot()
		state.setFault(point)
		local desired = if point == "Before" then ids[2] else nil
		local outcome =
			app.assign(active, "production", "production/2", desired, before.profileRevision)
		assert(
			outcome.status == "OutcomeUnknown" and active.state() == "PersistenceAtRisk",
			"native persistence cut point remains uncertain"
		)
		assert(equal(active.snapshot(), before), "no optimistic profile mutation")
		assert(app.reconcile(active).status == "Unchanged", "same operation durable reconciliation")
		local saved = active.snapshot()
		assert(
			saved.profileRevision == before.profileRevision + 1
				and saved.vault.productionAssignments["production/2"] == desired,
			"one revision and exact intended assignment"
		)
		state.result["fault" .. point] =
			{ outcome = outcome, beforeRevision = before.profileRevision, afterProfile = saved }
	end
	local raced: any = nil
	state.setNested(function()
		raced = app.assign(
			active,
			"production",
			"production/2",
			ids[2],
			active.snapshot().profileRevision
		)
	end)
	assert(
		app.assign(active, "display", "display/2", ids[2], active.snapshot().profileRevision).status
			== "Committed",
		"primary writer commits"
	)
	assert(raced.status == "Busy", "concurrent writer admission fenced")
	state.result.concurrentWriterResult = raced
	local prior = active.snapshot()
	assert(active.checkpoint("probe-capacity-drop", function(p: any)
		p.vault.capacityBase = { units = 0, sourceId = "migration/imp9-dev-capacity-v1" }
		assert(
			state.vault.prepare(p, app.settleProfile).status == "Prepared",
			"settlement before capacity invalidation"
		)
	end).status == "Committed", "atomic lossless capacity drop")
	local reconciled = active.snapshot()
	assert(
		next(reconciled.vault.productionAssignments) == nil
			and next(reconciled.vault.displayAssignments) == nil,
		"no overflow assignments retained"
	)
	assert(
		reconciled.vault.productionBufferMilli >= prior.vault.productionBufferMilli,
		"accrued output preserved"
	)
	for _, id in ids do
		assert(
			reconciled.collection.creaturesById[id].overflowHeld
				and equal(
					reconciled.collection.creaturesById[id].variantIdentity,
					prior.collection.creaturesById[id].variantIdentity
				),
			"lossless exact held identity"
		)
	end
	state.result.capacityReconciledProfile = reconciled
	state.result.protectedLoads = {}
	local server: any = game:GetService("ServerScriptService").MonsterVaultServer
	local stores, http = game:GetService("DataStoreService"), game:GetService("HttpService")
	local protectedKinds = { "CommercialGrant", "MissingEpoch" }
	if state.energy then
		table.insert(protectedKinds, "InvalidEnergy")
		table.insert(protectedKinds, "DeferredGrant")
	end
	for _, kind in protectedKinds do
		local badScope = "IMP9PB-" .. http:GenerateGUID(false)
		local badStore = stores:GetDataStore("MV_DEV_PlayerProfile_v1", badScope)
		local invalid = active.snapshot()
		if kind == "CommercialGrant" then
			invalid.commerce.productionGrants = { unbound = true }
		elseif kind == "MissingEpoch" then
			invalid.vault.productionRateEpochId = "production-epoch/unavailable"
		elseif kind == "InvalidEnergy" then
			invalid.economy.energyUnits = 1_000_000_000_001
		else
			invalid.economy.deferredEnergyGrants = { unbound = { remainingUnits = 100 } }
		end
		local badRepository = require(server.adapters.RobloxProfileRepository).new({
			GetDataStore = function()
				return badStore
			end,
		}, true, "DEV")
		assert(badRepository.update(state.key, function()
			return { kind = "write", value = invalid, metadata = {} }
		end).status == "ok", "isolated invalid-data fixture saved")
		local now = os.time()
		local badSession = require(server.infrastructure.persistence.ProfileSession).new({
			userId = active.userId(),
			lockId = http:GenerateGUID(false),
			jobId = "protected-production-probe",
			repository = badRepository,
			schema = require(server.infrastructure.persistence.ProfileSchemaV1),
			prepareProfile = function(p: any)
				if state.energy then
					local wallet = state.energy.prepare(p)
					if wallet.status ~= "Prepared" then
						return wallet
					end
				end
				return app.prepareProfile(p, now)
			end,
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
		local protected = badSession.acquire()
		assert(
			protected.status == "ProtectedLoadFailure"
				and equal(badStore:GetAsync(state.key), invalid),
			"unbound grant/history protected without overwrite"
		)
		table.insert(
			state.result.protectedLoads,
			{ kind = kind, scope = badScope, outcome = protected, preserved = true }
		)
	end
	if state.claims then
		local before = active.snapshot()
		state.setFault("After")
		local unknown = state.claims.claim(active, before.profileRevision)
		assert(unknown.status == "OutcomeUnknown", "native unknown claim before disconnect")
		state.result.unknownDisconnect = { before = before, outcome = unknown }
	end
	assert(active.release(os.clock() + 25).status == "Closed", "fixture lease released")
	if state.claims then
		local stored = state.repository.update(state.key, function(current: any, metadata: any)
			return { kind = "write", value = current, metadata = metadata }
		end)
		local before = state.result.unknownDisconnect.before
		local receipt = state.energy.claimReceipt(stored.value, before.profileRevision)
		assert(
			receipt ~= nil
				and stored.value.economy.energyUnits
					== before.economy.energyUnits + receipt.deltaUnits,
			"native release preserves accepted unknown wallet/buffer transfer"
		)
		state.result.unknownDisconnect.savedProfile = stored.value
	end
	local normal = state.normalStore:GetAsync(state.key)
	assert(
		equal(normal.collection, state.result.normalCollectionBefore)
			and equal(normal.economy, state.result.normalEconomyBefore),
		"normal player progress unchanged"
	)
	state.result.normalProgressUnchanged = true
	for _, diagnostic in state.result.diagnostics do
		assert(diagnostic.severity ~= "error", "native gateway diagnostics clean")
	end
	state.networking.stop()
	state.root:Destroy()
	local result = state.result
	state = nil
	return result
end
return {
	setup = setup,
	inspect = inspect,
	saveLeave = saveLeave,
	prepareClaims = prepareClaims,
	claimCases = claimCases,
	armClaimFault = armClaimFault,
	verifyClaimFault = verifyClaimFault,
	faultRaceAndFinish = faultRaceAndFinish,
}
