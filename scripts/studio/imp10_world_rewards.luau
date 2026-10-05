--!strict

-- Native DEV probe: shipped profile/world/capture/network owners, actual authored
-- bindings and character. Only DataStore scope, fault cuts and pulse timing vary.
local globals = getfenv() :: any
local state: any = nil
local OBJECTIVE = "field-objective/fixture-return-route"
local function check(value: any, message: string?): any
	return assert(value, message or "native world reward invariant")
end
local function equal(a: any, b: any): boolean
	if type(a) ~= type(b) then
		return false
	elseif type(a) ~= "table" then
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
local function tick(count: number)
	local s = check(state)
	for _ = 1, count do
		s.mono += 1
		check(#s.callbacks == 1, "one shared world pulse")
		local callback = check(table.remove(s.callbacks, 1))
		callback()
		callback() -- Duplicate pulse cannot fork or grant anything.
		check(#s.callbacks == 1, "duplicate pulse fenced")
	end
end
local function move(part: any)
	local root = check(state.player.Character:FindFirstChild("HumanoidRootPart"))
	root.CFrame = part.CFrame + globals.Vector3.new(0, 3, 0)
	root.AssemblyLinearVelocity = globals.Vector3.zero
	globals.task.wait(0.1)
end
local function setup(
	scope: string?,
	seedEnergy: number?,
	worldDraw: number?,
	manualCapturePulse: boolean?
): any
	check(state == nil and game:GetService("RunService"):IsStudio())
	check(game:GetService("RunService"):IsServer())
	local server: any = game.ServerScriptService.MonsterVaultServer
	local http, players, stores, cs =
		game:GetService("HttpService"),
		game:GetService("Players"),
		game:GetService("DataStoreService"),
		game:GetService("CollectionService")
	local binding: any = require(server.bootstrap.ProfileBinding)
	check(binding.environment == "DEV" and binding.declaredUniverseId == game.GameId)
	local player = check(players:GetPlayers()[1], "native player required")
	local s: any = {
		scope = scope or "IMP10Reward-" .. http:GenerateGUID(false),
		player = player,
		fault = nil,
		faultCuts = { Before = 0, After = 0 },
		mono = 0,
		wall = 299,
		callbacks = {},
		captureCallbacks = {},
		packets = {},
		captureStates = {},
	}
	local realStore = stores:GetDataStore("MV_DEV_PlayerProfile_v1", s.scope)
	if seedEnergy then
		-- Explicit legacy headroom fixture only; never runtime reward authorization.
		check(scope == nil, "only fresh headroom fixture")
		local seed = require(server.infrastructure.persistence.ProfileSchemaV1).default(os.time())
		seed.economy.energyUnits = seedEnergy
		realStore:SetAsync("player/" .. player.UserId, seed)
	end
	local storeAdapter = {
		GetDataStore = function(_self: any, name: string): any
			check(name == "MV_DEV_PlayerProfile_v1")
			return {
				UpdateAsync = function(_store: any, key: string, transform: any): any
					if s.fault == "Before" then
						s.faultCuts.Before += 1
						error("PROBE_BEFORE_WRITE")
					end
					local value, info = realStore:UpdateAsync(key, transform)
					if s.fault == "After" then
						s.faultCuts.After += 1
						s.fault = nil
						error("PROBE_LOST_RESULT")
					end
					return value, info
				end,
			}
		end,
	}
	local diagnostics = { emit = function() end }
	s.profile = require(server.bootstrap.ProfileRuntimeService).new({
		environment = binding.environment,
		declaredUniverseId = binding.declaredUniverseId,
		gameUniverseId = game.GameId,
		gameJobId = "IMP10Reward-Studio",
		dataStoreService = storeAdapter,
		players = players,
		runService = game:GetService("RunService"),
		httpService = http,
		diagnostics = diagnostics,
	})
	check(s.profile.coordinator.open(player.UserId).status == "Ready", "shipped profile Ready")
	s.session = s.profile.coordinator.get(player.UserId)
	s.root = globals.Instance.new("Folder")
	s.root.Name, s.root.Parent = "IMP10RewardWorld", workspace
	s.authored = workspace.MonsterVaultWorld:Clone()
	s.authored.Parent = s.root
	local collection = {
		GetTagged = function(_self: any, tag: string): any
			local result = {}
			for _, part in cs:GetTagged(tag) do
				if part:IsDescendantOf(s.authored) then
					table.insert(result, part)
				end
			end
			return result
		end,
		AddTag = function(_self: any, part: any, tag: string)
			cs:AddTag(part, tag)
		end,
	}
	s.remotes = globals.Instance.new("Folder")
	s.remotes.Name, s.remotes.Parent = "IMP10RewardProbe", game.ReplicatedStorage
	for _, pair in
		{
			{ "Command", "RemoteEvent" },
			{ "Event", "RemoteEvent" },
			{ "UnreliableEvent", "UnreliableRemoteEvent" },
		}
	do
		local remote = globals.Instance.new(pair[2])
		remote.Name, remote.Parent = pair[1], s.remotes
	end
	local event = {
		IsA = function(_self: any, className: string): boolean
			return s.remotes.Event:IsA(className)
		end,
		FireClient = function(_self: any, target: any, packet: any)
			s.packets[packet.routeId] = packet
			if packet.payload and packet.payload.domain == "progression" then
				s.packets.progression = packet
			end
			if packet.routeId == "Capture.StateChanged" then
				s.captureStates[target.UserId] = packet.payload
			end
			s.remotes.Event:FireClient(target, packet)
		end,
	}
	local coordinator = {
		get = function(userId: number): any
			return if s.replacement then s.replacement else s.profile.coordinator.get(userId)
		end,
	}
	s.world = require(server.bootstrap.WorldRuntimeService).new({
		workspace = s.root,
		collectionService = collection,
		players = players,
		httpService = http,
		diagnostics = diagnostics,
		worldProgression = s.profile.worldProgression,
		worldActions = s.profile.worldActions,
		profileCoordinator = coordinator,
		event = event,
		clock = function()
			return s.mono
		end,
		cycleUnixSeconds = function()
			return s.wall
		end,
		scheduler = {
			delay = function(_seconds: number, callback: () -> ())
				table.insert(s.callbacks, callback)
			end,
		},
		random = {
			NextNumber = function()
				return worldDraw or 0.75
			end,
		},
	})
	s.world.start()
	s.capture = require(server.bootstrap.CaptureRuntimeService).new({
		worldRuntime = s.world,
		profileCoordinator = coordinator,
		vault = s.profile.vault,
		progression = s.profile.progression,
		worldProgression = s.profile.worldProgression,
		players = players,
		httpService = http,
		diagnostics = diagnostics,
		event = event,
		scheduler = if manualCapturePulse
			then {
				spawn = globals.task.spawn,
				delay = function(_seconds: number, callback: () -> ())
					table.insert(s.captureCallbacks, callback)
				end,
			}
			else nil,
		workspace = {
			FindFirstChild = function(_self: any, name: string): any
				return s.root:FindFirstChild(name)
			end,
			GetServerTimeNow = function(): number
				return if manualCapturePulse then s.mono else workspace:GetServerTimeNow()
			end,
		},
		random = {
			NextNumber = function()
				return 0
			end,
		},
	})
	s.capture.start()
	s.network = require(server.bootstrap.NetworkingRuntimeService).new({
		command = s.remotes.Command,
		event = event,
		unreliableEvent = s.remotes.UnreliableEvent,
		players = players,
		profileCoordinator = coordinator,
		diagnostics = diagnostics,
		captureRuntime = s.capture,
		worldRuntime = s.world,
		worldActions = s.profile.worldActions,
		vault = s.profile.vault,
		capacity = s.profile.capacity,
		production = s.profile.production,
		assignments = s.profile.assignments,
		energy = s.profile.energy,
		claims = s.profile.claims,
		progression = s.profile.progression,
		purchases = s.profile.purchases,
	})
	s.network.start()
	state = s
	move(s.authored.FixtureSecurePoint)
	tick(1)
	check(s.world.presenceReady(player, player:GetAttribute("MonsterVaultCharacterGeneration")))
	return s
end
local function command(route: string, payload: any, revision: number?): string
	return state.network.gateway.handle(state.player, {
		protocolVersion = 1,
		routeId = route,
		requestId = game:GetService("HttpService"):GenerateGUID(false),
		payload = payload,
		expectedRevision = revision,
	}).code
end
local function survey(id: string)
	check(command("Interaction.PrimaryInteract", { interactionId = id }) == "OK_WORLD_VISITED", id)
end
local function prepareReturn()
	survey("landmark/fixture-entry")
	move(state.authored.FixtureCreatureAnchor)
	tick(1)
	survey("landmark/fixture-clearing")
	move(state.authored.FixtureSecurePoint)
	tick(1)
	check(state.session.snapshot().world.objectives[OBJECTIVE] == 2)
end
local function close(): any
	local s = check(state)
	s.fault, s.replacement = nil, nil
	s.network.stop()
	check(#s.capture.stop() == 0, "capture owner drained")
	s.world.stop()
	local p = s.session.snapshot()
	check(#s.profile.stop() == 0, "shipped profile drain")
	s.root:Destroy()
	s.remotes:Destroy()
	state = nil
	return { scope = s.scope, profile = p, faults = s.faultCuts }
end
local function rejoin(saved: any): any
	local s = setup(saved.scope)
	local p = s.session.snapshot()
	check(
		equal(p.economy, saved.profile.economy) and equal(p.world, saved.profile.world),
		"reward durable on rejoin"
	)
	check(
		equal(p.collection, saved.profile.collection)
			and equal(p.progression, saved.profile.progression),
		"other owners preserved"
	)
	local before = s.session.snapshot()
	survey("landmark/fixture-entry")
	check(equal(before, s.session.snapshot()), "rejoin repeated observation grants zero")
	close()
	return { passed = true, energy = p.economy.energyUnits, receipt = p.economy.worldRewardReceipt }
end
local function beginHappy(): any
	local s = setup()
	return { scope = s.scope, energy = s.session.snapshot().economy.energyUnits }
end
local function stage(name: string): any
	local s, p = check(state), state.session.snapshot()
	check(
		p.world.objectives[OBJECTIVE] == (if name == "clearing" then 1 else 2),
		"actual client survey progress"
	)
	check(
		p.economy.energyUnits == 0 and p.economy.worldRewardReceipt == nil,
		"partial route granted reward"
	)
	move(
		if name == "clearing"
			then s.authored.FixtureCreatureAnchor
			else s.authored.FixtureSecurePoint
	)
	tick(1)
	return { progress = p.world.objectives[OBJECTIVE], energy = p.economy.energyUnits }
end
local function finishHappy(): any
	local s, p = check(state), state.session.snapshot()
	check(p.economy.energyUnits == 5 and p.world.objectives[OBJECTIVE] == 3)
	local receipt = check(p.economy.worldRewardReceipt)
	check(
		receipt.initialUnits == 5
			and receipt.remainingUnits == 0
			and #p.economy.recentEnergyOperations == 1
	)
	check(
		not s.profile.worldProgression.mastery(p, "milestone/region-mastery/starter"),
		"reward invented collection/mastery"
	)
	check(
		next(p.collection.creaturesById or {}) == nil
			and next(p.progression.purchasesByUnlockId or {}) == nil
	)
	local before = s.session.snapshot()
	s.wall = 300
	tick(2)
	check(
		s.world.cycleState().phaseId == "world-phase/dusk" and equal(before, s.session.snapshot())
	)
	check(command("Session.RequestResync", { domain = "progression" }) == "OK_PROGRESSION_SNAPSHOT")
	check(equal(before, s.session.snapshot()), "readback granted reward")
	local saved = close()
	return {
		passed = true,
		scope = saved.scope,
		receipt = receipt,
		energy = 5,
		actualClientRoute = true,
		cycleDuplicateInert = true,
		rejoin = rejoin(saved),
	}
end
local function faultRecovery(): any
	local results = {}
	for _, mode in { "Before", "After" } do
		local s = setup()
		prepareReturn()
		s.fault = mode
		check(s.world.discover(s.player, "landmark/fixture-entry") == "OUTCOME_UNKNOWN_WORLD_WRITE")
		check(s.session.state() == "PersistenceAtRisk")
		check(s.session.snapshot().economy.energyUnits == 0, "unconfirmed wallet published")
		s.fault = nil
		move(s.authored.FixtureCreatureAnchor) -- Reconcile admitted candidate after departure.
		check(command("Session.RequestResync", { domain = "world" }) == "OK_WORLD_RECONCILED")
		local before = s.session.snapshot()
		check(before.economy.energyUnits == 5 and before.world.objectives[OBJECTIVE] == 3)
		check(
			#before.economy.recentEnergyOperations == 1
				and before.economy.worldRewardReceipt.remainingUnits == 0
		)
		move(s.authored.FixtureSecurePoint)
		survey("landmark/fixture-entry")
		check(equal(before, s.session.snapshot()), "fault retry duplicated grant")
		local saved = close()
		table.insert(results, {
			mode = mode,
			scope = saved.scope,
			faultCuts = saved.faults,
			originalReceipt = before.economy.worldRewardReceipt,
			rejoin = rejoin(saved),
		})
	end
	return { passed = true, cases = results }
end
local function acquire(): string
	local s = check(state)
	move(s.authored.FixtureCreatureAnchor)
	tick(4)
	local id = check(s.world.world().currentId(), "actual authored encounter")
	check(s.capture.interact(s.player, id, "reward-capture") == "OK_CAPTURE_CLAIMED")
	local claim = s.captureStates[s.player.UserId]
	check(
		s.capture.submit(
			s.player,
			{ captureSessionId = claim.captureSessionId, actionId = "capture", clientSequence = 1 },
			"reward-submit"
		) == "OK_CAPTURE_PROVISIONAL"
	)
	return id
end
local function unsafeAndFences(): any
	local s = setup()
	prepareReturn()
	local before = s.session.snapshot()
	move(s.authored.MidASecurePoint)
	check(s.world.discover(s.player, "landmark/mid-a-entry") == "REJECT_STATE_WORLD_ACCESS_BLOCKED")
	check(equal(before, s.session.snapshot()))
	move(s.authored.FixtureSecurePoint)
	tick(1)
	-- Suspend between initial presence check and the actual candidate admission.
	local visit = s.profile.worldActions.visit
	local function race(mutate: () -> ())
		local calls = 0
		s.profile.worldActions.visit = function(
			session: any,
			id: string,
			inside: () -> boolean
		): any
			return visit(session, id, function(): boolean
				calls += 1
				if calls == 2 then
					mutate()
				end
				return inside()
			end)
		end
		check(s.world.discover(s.player, "landmark/fixture-entry") ~= "OK_WORLD_VISITED")
		s.profile.worldActions.visit = visit
		check(equal(before, s.session.snapshot()), "stale admission granted reward")
	end
	local original = s.player.Character
	race(function()
		s.player:LoadCharacterAsync()
	end)
	check(s.player.Character ~= original, "real character replacement")
	tick(1)
	move(s.authored.FixtureSecurePoint)
	tick(1)
	local server: any = game.ServerScriptService.MonsterVaultServer
	local secondScope = "IMP10Reward-" .. game:GetService("HttpService"):GenerateGUID(false)
	local second = require(server.bootstrap.ProfileRuntimeService).new({
		environment = "DEV",
		declaredUniverseId = game.GameId,
		gameUniverseId = game.GameId,
		gameJobId = "IMP10Reward-replacement",
		players = game:GetService("Players"),
		runService = game:GetService("RunService"),
		httpService = game:GetService("HttpService"),
		diagnostics = { emit = function() end },
		dataStoreService = {
			GetDataStore = function(_self: any, name: string): any
				return game:GetService("DataStoreService"):GetDataStore(name, secondScope)
			end,
		},
	})
	check(second.coordinator.open(s.player.UserId).status == "Ready")
	local replacement = second.coordinator.get(s.player.UserId)
	race(function()
		s.replacement = replacement
	end)
	s.replacement = nil
	check(#second.stop() == 0, "replacement profile drained")
	tick(1)
	local id = acquire()
	move(s.authored.StarterCorrosiveHazard.Marker)
	check(s.world.discover(s.player, "landmark/fixture-entry") ~= "OK_WORLD_VISITED")
	tick(1)
	check(
		s.captureStates[s.player.UserId].status == "Interrupted",
		"hazard TA-7 custody interruption"
	)
	check(
		(s.player.Character.HumanoidRootPart.Position - s.authored.StarterRecovery.Position).Magnitude
			< 4.5
	)
	check(
		equal(before, s.session.snapshot()) and (before.collection.creaturesById or {})[id] == nil
	)
	tick(2)
	check(equal(before, s.session.snapshot()), "recovery/duplicate pulse rewarded objective")
	local saved = close()
	return {
		passed = true,
		scope = saved.scope,
		staleCharacter = true,
		replacementSession = true,
		lockedClosed = true,
		hazardInterruptedCustody = true,
		noCompletionOrExtraction = true,
	}
end
local function deferredGrant(): any
	local s = setup(nil, 1_000_000_000_000 - 2)
	prepareReturn()
	survey("landmark/fixture-entry")
	local p = s.session.snapshot()
	local original = check(p.economy.worldRewardReceipt).operationId
	check(
		p.economy.energyUnits == s.profile.energy.maxUnits
			and p.economy.worldRewardReceipt.remainingUnits == 3
	)
	check(command("Session.RequestResync", { domain = "progression" }) == "OK_PROGRESSION_SNAPSHOT")
	check(s.packets.progression.payload.state.deferredEnergyUnits == 3, "pending value visible")
	local id = acquire()
	move(s.authored.FixtureSecurePoint)
	s.capture.secure(s.player, "secure-point/fixture-spawn")
	local deadline = os.clock() + 15
	repeat
		globals.task.wait(0.1)
	until s.session.snapshot().collection.creaturesById[id] or os.clock() >= deadline
	check(
		s.session.snapshot().collection.creaturesById[id],
		"real secured SpeciesDiscovery for purchase"
	)
	local q =
		check(s.profile.purchases.quote(s.session, "vault-upgrade/collection-capacity/1").quote)
	check(
		command(
			"Progression.PurchaseUnlock",
			{ unlockId = q.unlockId, quoteId = q.quoteId, quoteRevision = q.quoteRevision },
			q.expectedRevision
		) == "OK_PROGRESSION_PURCHASED"
	)
	p = s.session.snapshot()
	check(
		p.economy.energyUnits == s.profile.energy.maxUnits - 22
			and p.economy.worldRewardReceipt.remainingUnits == 0
	)
	check(
		p.economy.worldRewardReceipt.operationId == original
			and #p.economy.recentEnergyOperations == 3
	)
	check(p.collection.creaturesById[id] and p.progression.purchasesByUnlockId[q.unlockId])
	check(s.packets.progression.payload.state.deferredEnergyUnits == 0)
	local before = s.session.snapshot()
	survey("landmark/fixture-entry")
	check(equal(before, s.session.snapshot()))
	local saved = close()
	return {
		passed = true,
		scope = saved.scope,
		legacyHeadroomFixture = true,
		initialUnits = 2,
		deferredUnits = 3,
		purchasePrice = 25,
		finalEnergy = p.economy.energyUnits,
		originalGrantPreserved = true,
		rejoin = rejoin(saved),
	}
end
return {
	setup = setup,
	tick = tick,
	move = move,
	rejoin = rejoin,
	beginHappy = beginHappy,
	stage = stage,
	finishHappy = finishHappy,
	faultRecovery = faultRecovery,
	unsafeAndFences = unsafeAndFences,
	deferredGrant = deferredGrant,
	scopeState = function(): any
		return state
	end,
	close = close,
}
