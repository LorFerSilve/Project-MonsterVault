--!strict

-- Studio-only probe: native character/actions and the real DEV P2 adapter,
-- isolated DataStore scope. No normal profile or shipped content is fabricated.
local globals = getfenv() :: any
local state: any = nil
local function check(value: any, message: string): any
	assert(value, message)
	return value
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
local function setup(): any
	check(
		state == nil
			and game:GetService("RunService"):IsStudio()
			and game:GetService("RunService"):IsServer(),
		"fresh Studio server required"
	)
	local server: any = game:GetService("ServerScriptService").MonsterVaultServer
	local shared: any = game:GetService("ReplicatedStorage").MonsterVault.Shared
	local http, players, stores, cs =
		game:GetService("HttpService"),
		game:GetService("Players"),
		game:GetService("DataStoreService"),
		game:GetService("CollectionService")
	local binding = require(server.bootstrap.ProfileBinding)
	check(
		binding.environment == "DEV" and binding.declaredUniverseId == game.GameId,
		"verified DEV binding"
	)
	local player = check(players:GetPlayers()[1], "native player required")
	local scope = "IMP10World-" .. http:GenerateGUID(false)
	local storeAdapter = {
		GetDataStore = function(_self: any, name: string)
			return stores:GetDataStore(name, scope)
		end,
	}
	local realRepository =
		require(server.adapters.RobloxProfileRepository).new(storeAdapter, true, "DEV")
	local fault: string? = nil
	local repository = {
		update = function(key: string, transform: any): any
			if fault == "Before" then
				return { status = "error", reason = "PROBE_BEFORE", retryable = true }
			end
			local result = realRepository.update(key, transform)
			if fault == "After" and result.status == "ok" then
				fault = nil
				return { status = "error", reason = "PROBE_LOST_RESULT", retryable = true }
			end
			return result
		end,
	}
	local wall, mono = os.time() - 7200, 0
	local clock: any = {
		wallClock = {
			unixSeconds = function()
				return math.floor(wall)
			end,
		},
		monotonicClock = {
			seconds = function()
				return mono
			end,
		},
		advance = function(seconds: number)
			wall += seconds
			mono += seconds
		end,
	}
	local world = require(server.domains.world.WorldProgressionService).new(
		require(server.domains.world.WorldRegistry).new(
			require(server.domains.world.WorldDefinitions)
		)
	)
	local progression = require(server.domains.progression.ProgressionService).new(
		require(shared.config.ProgressionFixture),
		{ mastery = world.mastery }
	)
	local energy = require(server.domains.economy.EnergyService).new(progression.boundSinks)
	local capacity = table.clone(require(shared.config.VaultCapacityFixture))
	capacity.baseCollectionCapacity = 2
	local vault = require(server.domains.vault.VaultService).new(capacity)
	local production = require(server.domains.vault.VaultProductionService).new(
		require(shared.config.VaultProductionFixture)
	)
	local function operation(): string
		return http:GenerateGUID(false)
	end
	local assignments = require(server.application.VaultProductionUseCase).new({
		production = production,
		vault = vault,
		unixSeconds = clock.wallClock.unixSeconds,
		monotonicSeconds = clock.monotonicClock.seconds,
		newOperationId = operation,
	})
	local session = require(server.infrastructure.persistence.ProfileSession).new({
		userId = player.UserId,
		lockId = operation(),
		jobId = "IMP10-World-Studio",
		repository = repository,
		schema = require(server.infrastructure.persistence.ProfileSchemaV1),
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
		prepareSave = function(p: any, release: boolean, at: number): any
			local invalid = world.validate(p) or energy.validate(p) or progression.validate(p)
			if invalid then
				return { status = "Protected", reason = invalid }
			end
			return assignments.prepareSave(p, release, at)
		end,
		queue = require(server.infrastructure.persistence.SingleWriterQueue).new(
			clock.monotonicClock.seconds,
			clock.advance,
			25
		),
		retry = require(server.infrastructure.persistence.RetryPolicy).new(
			clock.monotonicClock.seconds,
			clock.advance,
			function()
				return 0.5
			end,
			3
		),
		unixSeconds = clock.wallClock.unixSeconds,
		monotonicSeconds = clock.monotonicClock.seconds,
	})
	check(session.acquire().status == "Ready", "scoped native profile Ready")
	local coordinator = {
		get = function(userId: number)
			return if userId == player.UserId then session else nil
		end,
	}
	local actions = require(server.application.WorldActionUseCase).new({
		world = world,
		progression = progression,
		newOperationId = operation,
	})
	local purchases = require(server.application.ProgressionPurchaseUseCase).new({
		progression = progression,
		energy = energy,
		vault = vault,
		production = production,
		assignments = assignments,
		monotonicSeconds = clock.monotonicClock.seconds,
		newOperationId = operation,
	})
	local claims = require(server.application.ProductionClaimUseCase).new({
		energy = energy,
		production = production,
		vault = vault,
		assignments = assignments,
		newOperationId = operation,
	})
	local root = globals.Instance.new("Folder")
	root.Name = "IMP10ProbeWorld"
	root.Parent = workspace
	local authored = workspace.MonsterVaultWorld:Clone()
	authored.Parent = root
	local collectionService = {
		GetTagged = function(_self: any, tag: string): any
			local result = {}
			for _, v in cs:GetTagged(tag) do
				if v:IsDescendantOf(authored) then
					table.insert(result, v)
				end
			end
			return result
		end,
		AddTag = function(_self: any, v: any, tag: string)
			cs:AddTag(v, tag)
		end,
	}
	local diagnostics = { emit = function(_level: string, _code: string, _fields: any) end }
	local remotes = globals.Instance.new("Folder")
	remotes.Name = "IMP10WorldProbe"
	remotes.Parent = game:GetService("ReplicatedStorage")
	for _, pair in
		{
			{ "Command", "RemoteEvent" },
			{ "Event", "RemoteEvent" },
			{ "UnreliableEvent", "UnreliableRemoteEvent" },
		}
	do
		local remote = globals.Instance.new(pair[2])
		remote.Name, remote.Parent = pair[1], remotes
	end
	local worldRuntime = require(server.bootstrap.WorldRuntimeService).new({
		workspace = root,
		collectionService = collectionService,
		httpService = http,
		diagnostics = diagnostics,
		worldProgression = world,
		worldActions = actions,
		event = remotes.Event,
		profileCoordinator = coordinator,
	})
	worldRuntime.start()
	local captureStates = {}
	local captureEvents = {
		FireClient = function(_self: any, target: any, packet: any)
			if packet.routeId == "Capture.StateChanged" then
				captureStates[target.UserId] = packet.payload
			end
			remotes.Event:FireClient(target, packet)
		end,
	}
	local captureRuntime = require(server.bootstrap.CaptureRuntimeService).new({
		worldRuntime = worldRuntime,
		vault = vault,
		progression = progression,
		worldProgression = world,
		profileCoordinator = coordinator,
		players = players,
		workspace = {
			FindFirstChild = function(_self: any, name: string)
				return root:FindFirstChild(name)
			end,
			GetServerTimeNow = function()
				return workspace:GetServerTimeNow()
			end,
		},
		event = captureEvents,
		httpService = http,
		diagnostics = diagnostics,
		random = {
			NextNumber = function()
				return 0
			end,
		},
	})
	captureRuntime.start()
	local network = require(server.bootstrap.NetworkingRuntimeService).new({
		command = remotes.Command,
		event = remotes.Event,
		unreliableEvent = remotes.UnreliableEvent,
		players = players,
		profileCoordinator = coordinator,
		captureRuntime = captureRuntime,
		worldRuntime = worldRuntime,
		vault = vault,
		capacity = nil,
		production = production,
		assignments = assignments,
		energy = energy,
		claims = claims,
		progression = progression,
		purchases = purchases,
		diagnostics = diagnostics,
	})
	network.start()
	state = {
		scope = scope,
		userId = player.UserId,
		player = player,
		storeAdapter = storeAdapter,
		session = session,
		world = world,
		worldRuntime = worldRuntime,
		captureRuntime = captureRuntime,
		network = network,
		root = root,
		remotes = remotes,
		authored = authored,
		clock = clock,
		assignments = assignments,
		claims = claims,
		purchases = purchases,
		progression = progression,
		actions = actions,
		energy = energy,
		receipts = {},
		captureStates = captureStates,
		setFault = function(value: string?)
			fault = value
		end,
	}
	return {
		scope = scope,
		userId = player.UserId,
		initial = session.snapshot(),
		registry = world.registry.roles,
	}
end
local function move(part: any)
	local root = check(
		state.player.Character and state.player.Character:FindFirstChild("HumanoidRootPart"),
		"active native character"
	)
	root.CFrame = part.CFrame + globals.Vector3.new(0, 3, 0)
	root.AssemblyLinearVelocity = globals.Vector3.zero
	globals.task.wait(0.1)
end
local function interact(id: string, extra: any?): any
	local payload: any = { interactionId = id }
	if extra then
		for k, v in extra do
			payload[k] = v
		end
	end
	return state.network.gateway.handle(state.player, {
		protocolVersion = 1,
		routeId = "Interaction.PrimaryInteract",
		requestId = game:GetService("HttpService"):GenerateGUID(false),
		payload = payload,
	}).code
end
local function surveyAndCapture(): any
	local s = state
	move(s.authored.FixtureSecurePoint)
	local before = s.session.snapshot()
	check(
		interact("landmark/fixture-clearing") == "REJECT_STATE_WORLD_OUT_OF_RANGE",
		"native distance fails closed"
	)
	check(equal(before, s.session.snapshot()), "out of range did not mutate")
	check(
		interact("landmark/fixture-entry", { mastery = true }) == "REJECT_VALIDATION_PAYLOAD",
		"client mastery tampering rejected"
	)
	check(interact("landmark/fixture-entry") == "OK_WORLD_VISITED", "native entry visit")
	local after = s.session.snapshot()
	check(
		interact("landmark/fixture-entry") == "OK_WORLD_VISITED"
			and equal(after, s.session.snapshot()),
		"native visit duplicate no mutation"
	)
	move(s.authored.FixtureCreatureAnchor)
	check(interact("landmark/fixture-clearing") == "OK_WORLD_VISITED", "native clearing visit")
	local creature = check(s.worldRuntime.world().currentId(), "live server creature")
	check(
		s.captureRuntime.interact(s.player, creature, "probe-capture") == "OK_CAPTURE_CLAIMED",
		"native capture claim"
	)
	local claim = s.captureStates[s.player.UserId]
	check(
		s.captureRuntime.submit(
			s.player,
			{ captureSessionId = claim.captureSessionId, actionId = "capture", clientSequence = 1 },
			"probe-submit"
		) == "OK_CAPTURE_PROVISIONAL",
		"native capture attempt"
	)
	move(s.authored.FixtureSecurePoint)
	s.captureRuntime.secure(s.player)
	local deadline = os.clock() + 10
	local secured: any = nil
	repeat
		secured = (s.session.snapshot().collection.creaturesById or {})[creature]
		if secured == nil then
			globals.task.wait(0.1)
		end
	until secured ~= nil or os.clock() >= deadline
	check(
		secured ~= nil
			and s.session.snapshot().world.regionalSpecies["region/fixture-clearing"][secured.speciesId]
				~= nil,
		"native secured and regional proof share write"
	)
	check(
		not s.world.mastery(s.session.snapshot(), "milestone/region-mastery/starter"),
		"survey and collection cannot skip active return objective"
	)
	check(interact("landmark/fixture-entry") == "OK_WORLD_VISITED", "native return objective")
	check(
		s.world.mastery(s.session.snapshot(), "milestone/region-mastery/starter"),
		"native mastery finalized"
	)
	s.creatureId = creature
	return {
		profile = s.session.snapshot(),
		creatureId = creature,
		outOfRange = true,
		tampering = true,
		duplicate = true,
		nativeMastery = true,
	}
end
local function productionAndAccess(): any
	local s = state
	check(
		s.assignments.assign(
			s.session,
			"production",
			"production/1",
			s.creatureId,
			s.session.snapshot().profileRevision
		).status == "Committed",
		"native production assignment"
	)
	s.clock.advance(7200)
	local claim = s.claims.claim(s.session, s.session.snapshot().profileRevision)
	check(claim.status == "Committed" and claim.units == 720, "real production claim funded access")
	local receipts = {}
	for _, unlock in { "access/biome-mid-b", "access/biome-mid-a" } do
		local q = s.purchases.quote(s.session, unlock).quote
		check(q ~= nil, "real mastery bound to quote")
		local payload = { unlockId = unlock, quoteId = q.quoteId, quoteRevision = q.quoteRevision }
		local result = s.purchases.purchase(s.session, payload, q.expectedRevision)
		check(result.status == "Committed", "native access purchase")
		local p = s.session.snapshot()
		check(
			s.purchases.purchase(s.session, payload, q.expectedRevision).status
					== "AlreadyCommitted"
				and equal(p, s.session.snapshot()),
			"exact historic purchase retry"
		)
		table.insert(receipts, { payload = payload, expectedRevision = q.expectedRevision })
	end
	local p = s.session.snapshot()
	check(p.economy.energyUnits == 520, "two access debits only")
	check(
		s.world.canAccess(p, "region/biome-mid-a", s.progression.hasAccess)
			and s.world.canAccess(p, "region/biome-mid-b", s.progression.hasAccess),
		"native access owner consumes both receipts"
	)
	check(
		s.purchases.quote(s.session, "access/biome-advanced").status == "Rejected",
		"access purchase does not fabricate Mid mastery"
	)
	check(
		not s.world.canAccess(p, "region/biome-advanced", s.progression.hasAccess),
		"Advanced remains locked"
	)
	s.receipts = receipts
	return { profile = p, receipts = receipts, productionClaim = claim, advancedBlocked = true }
end

local function release(): any
	local s = state
	s.network.stop()
	check(#s.captureRuntime.stop() == 0, "native capture drain")
	s.worldRuntime.stop()
	check(
		s.session.release(s.clock.monotonicClock.seconds() + 25).status == "Closed",
		"native scoped save/release"
	)
	local profile = game:GetService("DataStoreService")
		:GetDataStore("MV_DEV_PlayerProfile_v1", s.scope)
		:GetAsync("player/" .. s.userId)
	local r = { scope = s.scope, userId = s.userId, profile = profile, receipts = s.receipts }
	s.root:Destroy()
	s.remotes:Destroy()
	state = nil
	return r
end
local function faultCases(): any
	check(state == nil, "happy path released before fault probes")
	local results = {}
	for _, mode in { "Before", "After" } do
		setup()
		local s = state
		move(s.authored.FixtureSecurePoint)
		s.setFault(mode)
		check(
			s.worldRuntime.discover(s.player, "landmark/fixture-entry")
				== "OUTCOME_UNKNOWN_WORLD_WRITE",
			"native admitted world visit uncertain"
		)
		s.setFault(nil)
		local restored = s.network.gateway.handle(s.player, {
			protocolVersion = 1,
			routeId = "Session.RequestResync",
			requestId = game:GetService("HttpService"):GenerateGUID(false),
			payload = { domain = "world" },
		})
		check(
			restored.code == "OK_WORLD_RECONCILED",
			"Class A world resync restored accepted candidate"
		)
		move(s.authored.FixtureCreatureAnchor)
		check(
			s.worldRuntime.discover(s.player, "landmark/fixture-entry")
				== "REJECT_STATE_WORLD_OUT_OF_RANGE",
			"accepted candidate restored after departure"
		)
		check(
			s.session.state() == "Ready"
				and s.session.snapshot().world.objectives["field-objective/fixture-return-route"]
					== 1,
			"native world candidate restored once"
		)
		move(s.authored.FixtureSecurePoint)
		local p = s.session.snapshot()
		check(
			s.worldRuntime.discover(s.player, "landmark/fixture-entry") == "OK_WORLD_VISITED"
				and equal(p, s.session.snapshot()),
			"native duplicate after uncertainty unchanged"
		)
		local saved = release()
		check(
			saved.profile.economy.energyUnits == 0 and equal(saved.profile.world, p.world),
			"fault world evidence persisted with no reward"
		)
		table.insert(results, {
			mode = mode,
			scope = saved.scope,
			profile = saved.profile,
			restoredAfterDeparture = true,
			duplicate = true,
		})
	end
	return { passed = true, cases = results }
end

local function rejoin(resume: any): any
	local server: any = game:GetService("ServerScriptService").MonsterVaultServer
	local players = game:GetService("Players")
	local http = game:GetService("HttpService")
	local runtime = require(server.bootstrap.ProfileRuntimeService).new({
		environment = "DEV",
		declaredUniverseId = game.GameId,
		gameUniverseId = game.GameId,
		gameJobId = "IMP10-fresh-rejoin",
		dataStoreService = {
			GetDataStore = function(_self: any, name: string)
				return game:GetService("DataStoreService"):GetDataStore(name, resume.scope)
			end,
		},
		players = players,
		runService = game:GetService("RunService"),
		httpService = http,
		diagnostics = { emit = function() end },
	})
	check(
		runtime.coordinator.open(resume.userId).status == "Ready",
		"fresh shipped profile composition rejoined"
	)
	local session = runtime.coordinator.get(resume.userId)
	local p = session.snapshot()
	check(equal(resume.profile.world, p.world), "all native world history persisted")
	check(equal(resume.profile.collection, p.collection), "exact ownership preserved")
	check(
		equal(resume.profile.progression, p.progression) and p.economy.energyUnits == 520,
		"access and exact wallet persisted"
	)
	check(
		runtime.worldProgression.mastery(p, "milestone/region-mastery/starter"),
		"shipped mastery owner bound after rejoin"
	)
	check(
		runtime.worldProgression.canAccess(p, "region/biome-mid-a", runtime.progression.hasAccess),
		"shipped access owner after rejoin"
	)
	for _, receipt in resume.receipts do
		check(
			runtime.purchases.purchase(session, receipt.payload, receipt.expectedRevision).status
				== "AlreadyCommitted",
			"fresh native exact retry"
		)
	end
	check(
		runtime.purchases.quote(session, "access/biome-advanced").status == "Rejected",
		"fresh native Advanced fails closed"
	)
	check(#runtime.stop() == 0, "fresh shipped profile drain")
	return { passed = true, profile = p, exactRetries = #resume.receipts }
end
return {
	setup = setup,
	surveyAndCapture = surveyAndCapture,
	productionAndAccess = productionAndAccess,
	faultCases = faultCases,
	release = release,
	rejoin = rejoin,
}
