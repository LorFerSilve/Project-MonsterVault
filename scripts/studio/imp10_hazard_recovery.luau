--!strict

-- Scoped native DEV composition, real character/geometry and real P2 persistence.
-- Mount beside IMP10WorldProbe and IMP10SpawnProbe with ordinary boots disabled.
local globals = getfenv() :: any
local base: any = globals.require(game.ServerScriptService.IMP10WorldProbe)
local pulse: any = globals.require(game.ServerScriptService.IMP10SpawnProbe)
local function check(value: any, message: string?): any
	return assert(value, message or "native hazard invariant")
end
local function state(): any
	return check(base.scopeState(), "hazard scope required")
end
local function equal(a: any, b: any): boolean
	if type(a) ~= type(b) then
		return false
	elseif type(a) ~= "table" then
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
local function generation(): number
	return state().player:GetAttribute("MonsterVaultCharacterGeneration")
end
local function move(position: any)
	local root = state().player.Character.HumanoidRootPart
	root.CFrame = globals.CFrame.new(position + globals.Vector3.new(0, 3, 0))
	root.AssemblyLinearVelocity = globals.Vector3.zero
	globals.task.wait(0.1)
end
local function at(part: any): boolean
	return (state().player.Character.HumanoidRootPart.Position - part.Position).Magnitude < 4.5
end
local function setup(wall: (() -> number)?)
	base.setup(true, wall)
	move(state().authored.StarterTravel.Position)
	pulse.tick(1)
	check(state().worldRuntime.presenceReady(state().player, generation()))
end
local function acquire(submit: boolean): string
	local s = state()
	move(s.authored.FixtureCreatureAnchor.Position)
	pulse.tick(4)
	local id = check(s.worldRuntime.world().currentId(), "actual scheduled encounter")
	check(s.captureRuntime.interact(s.player, id, "hazard-claim") == "OK_CAPTURE_CLAIMED")
	if submit then
		local claim = s.captureStates[s.userId]
		check(s.captureRuntime.submit(s.player, {
			captureSessionId = claim.captureSessionId,
			actionId = "capture",
			clientSequence = 1,
		}, "hazard-submit") == "OK_CAPTURE_PROVISIONAL")
	end
	return id
end
local function walk(position: any)
	local character = state().player.Character
	character.Humanoid:MoveTo(position)
	local deadline = os.clock() + 8
	repeat
		globals.task.wait(0.05)
	until (character.HumanoidRootPart.Position - position).Magnitude < 3.5 or os.clock() >= deadline
	check((character.HumanoidRootPart.Position - position).Magnitude < 3.5, "baseline native walk")
end
local function observedRecoveryAndCycle(): any
	local wall = 299
	setup(function()
		return wall
	end)
	local s = state()
	local before, gen = s.session.snapshot(), generation()
	local opportunity = s.worldRuntime.world().currentId()
	local identity = s.worldRuntime.world().identity(opportunity)
	move(globals.Vector3.new(30, 0, 36))
	check(s.worldRuntime.presenceReady(s.player, gen), "safe approach")
	walk(globals.Vector3.new(44, 3, 36))
	check(not s.worldRuntime.presenceReady(s.player, gen), "actual hazard entry actionable")
	check(s.worldRuntime.secureDestination(s.player) == nil, "hazard extraction")
	check(
		s.worldRuntime.travel(s.player, "travel-node/home-hub", gen)
			== "REJECT_STATE_TRAVEL_CONTEXT"
	)
	wall = 300
	pulse.tick(1)
	check(at(s.authored.StarterRecovery) and generation() > gen, "safe known-region recovery")
	check(s.worldRuntime.cycleState().phaseId == "world-phase/dusk", "cycle boundary exercised")
	check(equal(before, s.session.snapshot()), "recovery/cycle rewrote persistent value")
	gen = generation()
	pulse.tick(3)
	check(generation() == gen and equal(before, s.session.snapshot()), "duplicate hazard recovery")
	check(
		s.worldRuntime.world().currentId() == opportunity
			and equal(identity, s.worldRuntime.world().identity(opportunity)),
		"recovery rerolled opportunity/context"
	)
	local saved = base.release()
	return {
		passed = true,
		scope = saved.scope,
		nativeWalkEntry = true,
		phaseBoundary = true,
		noValueChange = true,
		noOpportunityReset = true,
	}
end
local function acquisitionRecovery(): any
	local cases = {}
	for _, submit in { false, true } do
		setup()
		local s = state()
		local id = acquire(submit)
		local before, gen = s.session.snapshot(), generation()
		move(s.authored.StarterCorrosiveHazard.Marker.Position)
		pulse.tick(1)
		check(s.captureStates[s.userId].status == "Interrupted", "TA-7 hazard interruption")
		check(at(s.authored.StarterRecovery) and generation() > gen, "capture safe recovery")
		check(
			equal(before, s.session.snapshot())
				and (before.collection.creaturesById or {})[id] == nil,
			"hazard extracted custody"
		)
		gen = generation()
		pulse.tick(2)
		check(
			generation() == gen and equal(before, s.session.snapshot()),
			"duplicate custody consequence"
		)
		local saved = base.release()
		table.insert(
			cases,
			{ scope = saved.scope, creatureId = id, provisional = submit, noExtraction = true }
		)
	end
	return { passed = true, cases = cases }
end
local function unavailableArrival(): any
	setup()
	local s = state()
	local id = acquire(true)
	local before, gen = s.session.snapshot(), generation()
	local starter, home = s.authored.StarterRecovery, s.authored.HomeHubRecovery
	local parent = starter.Parent
	starter.Parent, home.Parent = nil, nil
	move(s.authored.StarterCorrosiveHazard.Marker.Position)
	pulse.tick(2)
	check(s.captureStates[s.userId].status == "Interrupted", "missing anchor retained custody")
	check(
		generation() == gen and not s.worldRuntime.presenceReady(s.player, gen),
		"unsafe missing arrival"
	)
	move(s.authored.StarterTravel.Position)
	pulse.tick(1)
	check(not s.worldRuntime.presenceReady(s.player, gen), "walk-out escaped pending recovery")
	starter.Parent = parent
	local original = starter.CFrame
	starter.CFrame += globals.Vector3.new(44, 0, 18)
	pulse.tick(1)
	check(
		generation() == gen and not s.worldRuntime.presenceReady(s.player, gen),
		"corrupt anchor accepted"
	)
	starter.CFrame, home.Parent = original, parent
	pulse.tick(1)
	check(at(starter) and generation() > gen, "validated recovery did not resume")
	check(
		equal(before, s.session.snapshot()) and (before.collection.creaturesById or {})[id] == nil,
		"recovery granted progress"
	)
	local marker = s.authored.StarterCorrosiveHazard.Marker
	marker.Transparency = 1
	pulse.tick(1)
	check(not s.worldRuntime.presenceReady(s.player, generation()), "invisible hazard allowed play")
	marker.Transparency = 0
	pulse.tick(1)
	check(
		at(starter) and s.worldRuntime.presenceReady(s.player, generation()),
		"restored authored warning"
	)
	check(equal(before, s.session.snapshot()), "authoring repair granted progress")
	local saved = base.release()
	return {
		passed = true,
		scope = saved.scope,
		interruptedWithoutAnchor = true,
		corruptAnchorClosed = true,
		walkOutClosed = true,
		missingMarkerClosed = true,
	}
end
local function pendingFinalization(): any
	setup()
	local s = state()
	local id = acquire(true)
	local identity = s.worldRuntime.world().identity(id)
	s.setFault("Before")
	move(s.authored.FixtureSecurePoint.Position)
	s.captureRuntime.secure(s.player, "secure-point/fixture-spawn")
	check(
		s.session.state() == "PersistenceAtRisk"
			and s.captureStates[s.userId].status == "FinalizationPending"
	)
	move(s.authored.StarterCorrosiveHazard.Marker.Position)
	pulse.tick(1)
	check(s.captureStates[s.userId].status == "FinalizationPending", "hazard lost admitted P2")
	s.setFault(nil)
	s.captureRuntime.reconcile(s.userId)
	check(s.captureRuntime.resync(s.player, "hazard-reconcile") == "OK_CAPTURE_RESYNC")
	local before = s.session.snapshot()
	local owned = check((before.collection.creaturesById or {})[id], "original candidate missing")
	check(
		owned.origin.spawnContextId == identity.spawnContextId
			and owned.origin.contentSnapshotId == identity.contentSnapshotId
	)
	pulse.tick(1)
	check(
		at(s.authored.StarterRecovery) and equal(before, s.session.snapshot()),
		"hazard changed admitted result"
	)
	check(s.captureRuntime.resync(s.player, "hazard-duplicate") == "OK_CAPTURE_RESYNC")
	check(equal(before, s.session.snapshot()), "P2 duplicate changed value")
	local saved = base.release()
	return {
		passed = true,
		scope = saved.scope,
		creatureId = id,
		admittedP2Preserved = true,
		exactOnce = true,
	}
end
local function safeTransport(): any
	setup()
	local s = state()
	local before = s.session.snapshot()
	check(
		s.worldRuntime.travel(s.player, "travel-node/mid-a", generation())
			== "REJECT_STATE_TRAVEL_ACCESS",
		"locked travel shortcut"
	)
	check(
		s.worldRuntime.travel(s.player, "travel-node/client-forged", generation())
			== "REJECT_STATE_TRAVEL_DESTINATION",
		"unknown destination shortcut"
	)
	move(s.authored.HomeHubRecovery.Position)
	pulse.tick(1) -- Real server observation discovers Home; no profile fixture grant.
	move(s.authored.StarterTravel.Position)
	pulse.tick(1)
	before = s.session.snapshot()
	local id = acquire(true)
	local gen = generation()
	-- Approach the travel node around the physical extraction plate, then extract
	-- explicitly in its validated radius. Crossing the plate would legitimately secure.
	walk(globals.Vector3.new(18, 3, -16))
	walk(globals.Vector3.new(18, 3, 24))
	walk(globals.Vector3.new(0, 3, 24))
	pulse.tick(1)
	check(
		s.worldRuntime.presenceReady(s.player, gen) and generation() == gen,
		"safe transport crossed hazard"
	)
	check(s.captureRuntime.state(id) == "TransportActive", "safe walk lost custody")
	check(
		s.worldRuntime.travel(s.player, "travel-node/home-hub", gen)
			== "REJECT_STATE_TRAVEL_ACQUISITION",
		"fast travel bypassed transport"
	)
	check(equal(before, s.session.snapshot()), "safe walk finalized capture")
	walk(s.authored.FixtureSecurePoint.Position + globals.Vector3.new(0, 3, 0))
	s.captureRuntime.secure(s.player, "secure-point/fixture-spawn")
	local deadline = os.clock() + 10
	repeat
		globals.task.wait(0.05)
	until s.captureStates[s.userId].status == "Secured" or os.clock() >= deadline
	check(s.captureStates[s.userId].status == "Secured", "legitimate safe extraction")
	local owned = check(s.session.snapshot().collection.creaturesById[id])
	check(owned.origin.spawnContextId == "spawn-context/fixture-clearing")
	local secured = s.session.snapshot()
	move(s.authored.StarterCorrosiveHazard.Marker.Position)
	pulse.tick(1)
	check(
		at(s.authored.StarterRecovery) and equal(secured, s.session.snapshot()),
		"hazard erased secured creature/history"
	)
	local saved = base.release()
	return {
		passed = true,
		scope = saved.scope,
		creatureId = id,
		baselineWalkTransport = true,
		validatedOutpostExtraction = true,
		securedValueSurvivedHazard = true,
		lockedAndUnknownRejected = true,
	}
end
local function respawnRejoin(): any
	setup()
	local s = state()
	local id = acquire(true)
	local before, gen, old = s.session.snapshot(), generation(), s.player.Character
	move(s.authored.StarterCorrosiveHazard.Marker.Position)
	old.Humanoid.Health = 0
	globals.task.wait(0.2)
	pulse.tick(1)
	check(not s.worldRuntime.presenceReady(s.player, gen), "dead hazard presence actionable")
	s.player:LoadCharacterAsync()
	globals.task.wait(0.2)
	check(
		s.player.Character ~= old and not s.worldRuntime.presenceReady(s.player, gen),
		"stale character survived respawn"
	)
	pulse.tick(1)
	check(at(s.authored.HomeHubRecovery) and generation() > gen, "respawn unsafe arrival")
	check(
		s.captureStates[s.userId].status == "Interrupted"
			and (s.session.snapshot().collection.creaturesById or {})[id] == nil,
		"respawn extracted hazard custody"
	)
	local after = s.session.snapshot()
	check(
		equal(before.collection, after.collection)
			and equal(before.progression, after.progression)
			and equal(before.economy, after.economy),
		"respawn changed secured value"
	)
	local saved = base.release()
	local runtime = globals
		.require(game.ServerScriptService.MonsterVaultServer.bootstrap.ProfileRuntimeService)
		.new({
			environment = "DEV",
			declaredUniverseId = game.GameId,
			gameUniverseId = game.GameId,
			gameJobId = "IMP10-hazard-rejoin",
			dataStoreService = s.storeAdapter,
			players = game:GetService("Players"),
			runService = game:GetService("RunService"),
			httpService = game:GetService("HttpService"),
			diagnostics = { emit = function() end },
		})
	check(runtime.coordinator.open(saved.userId).status == "Ready", "fresh scoped rejoin")
	local restored = runtime.coordinator.get(saved.userId).snapshot()
	check(
		equal(saved.profile.world, restored.world)
			and equal(saved.profile.collection, restored.collection)
			and equal(saved.profile.progression, restored.progression)
			and equal(saved.profile.economy, restored.economy),
		"hazard/respawn persistence changed"
	)
	check(#runtime.stop() == 0, "fresh rejoin drained")
	return {
		passed = true,
		scope = saved.scope,
		staleCharacterFenced = true,
		transportGraceInterrupted = true,
		persistedRejoin = true,
	}
end
local function sweptCrossing(): any
	setup()
	local s = state()
	local id = acquire(true)
	move(globals.Vector3.new(30, 0, 36))
	pulse.tick(1)
	local before, gen = s.session.snapshot(), generation()
	move(globals.Vector3.new(58, 0, 36)) -- Both endpoints are outside; segment crosses.
	check(not s.worldRuntime.presenceReady(s.player, gen), "fast crossing admitted value")
	move(globals.Vector3.new(30, 0, 36))
	check(not s.worldRuntime.presenceReady(s.player, gen), "return-before-pulse cancelled hazard")
	check(s.worldRuntime.secureDestination(s.player) == nil, "crossing bypassed extraction")
	check(
		s.worldRuntime.travel(s.player, "travel-node/home-hub", gen)
			== "REJECT_STATE_TRAVEL_CONTEXT",
		"crossing bypassed travel"
	)
	pulse.tick(1)
	check(at(s.authored.StarterRecovery) and generation() > gen, "swept crossing did not recover")
	check(
		s.captureStates[s.userId].status == "Interrupted"
			and (s.session.snapshot().collection.creaturesById or {})[id] == nil,
		"crossing extracted provisional custody"
	)
	check(equal(before, s.session.snapshot()), "crossing changed persistent value")
	local saved = base.release()
	return {
		passed = true,
		scope = saved.scope,
		safeEndpointsCrossed = true,
		admissionBlockedBeforePulse = true,
		custodyInterrupted = true,
		noValueChange = true,
	}
end
local function recoveryDoesNotDiscover(): any
	base.setup(true)
	local s = state()
	check(
		s.session.snapshot().world.travelNodes["travel-node/starter"] == nil,
		"fresh field node already discovered"
	)
	move(globals.Vector3.new(0, 0, 60))
	pulse.tick(1) -- Valid Starter presence, outside its authored travel node.
	local before = s.session.snapshot()
	move(s.authored.StarterCorrosiveHazard.Marker.Position)
	pulse.tick(1)
	check(at(s.authored.StarterRecovery), "known region recovery")
	pulse.tick(3)
	check(equal(before, s.session.snapshot()), "recovery discovered an unvisited node")
	check(
		s.worldRuntime.travel(s.player, "travel-node/home-hub", generation())
			== "REJECT_STATE_TRAVEL_SOURCE",
		"recovery bypassed exploration"
	)
	local node, parent = s.authored.StarterTravel, s.authored.StarterTravel.Parent
	node.Parent = nil
	pulse.tick(1)
	node.Parent = parent
	pulse.tick(1)
	check(equal(before, s.session.snapshot()), "binding loss simulated departure")
	move(s.authored.FixtureCreatureAnchor.Position)
	pulse.tick(1)
	move(node.Position)
	pulse.tick(1)
	check(
		s.world.travelDiscovered(s.session.snapshot(), "travel-node/starter"),
		"legitimate departure/return did not discover"
	)
	local after = s.session.snapshot()
	pulse.tick(2)
	check(equal(after, s.session.snapshot()), "duplicate discovery")
	local saved = base.release()
	return {
		passed = true,
		scope = saved.scope,
		recoveryDidNotDiscover = true,
		unavailableNodeDidNotFakeDeparture = true,
		realDepartureAndReturnDiscovered = true,
		duplicateInert = true,
	}
end
return {
	observedRecoveryAndCycle = observedRecoveryAndCycle,
	acquisitionRecovery = acquisitionRecovery,
	unavailableArrival = unavailableArrival,
	pendingFinalization = pendingFinalization,
	safeTransport = safeTransport,
	respawnRejoin = respawnRejoin,
	recoveryDoesNotDiscover = recoveryDoesNotDiscover,
	sweptCrossing = sweptCrossing,
}
