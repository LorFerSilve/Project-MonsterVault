--!strict

-- Native locked-presence/session recovery probe; reuses the scoped DEV composition.
-- Mount beside IMP10WorldProbe and IMP10SpawnProbe with ordinary bootstrap disabled.
local globals = getfenv() :: any
local container: any = game:GetService("ServerScriptService")
local base: any = globals.require(container.IMP10WorldProbe)
local spawn: any = globals.require(container.IMP10SpawnProbe)
local function check(value: any, message: string?): any
	return assert(value, message or "native presence invariant")
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
local function state(): any
	return check(base.scopeState())
end
local function generation(): number
	return state().player:GetAttribute("MonsterVaultCharacterGeneration")
end
local function move(part: any)
	local root = state().player.Character.HumanoidRootPart
	root.CFrame = part.CFrame + globals.Vector3.new(0, 3, 0)
	root.AssemblyLinearVelocity = globals.Vector3.zero
	globals.task.wait(0.1)
end
local function at(part: any): boolean
	return (state().player.Character.HumanoidRootPart.Position - part.Position).Magnitude < 4.5
end
local function lockedPresence(): any
	base.setup(true)
	local s = state()
	move(s.authored.StarterTravel)
	spawn.tick(4)
	local before, gen = s.session.snapshot(), generation()
	move(s.authored.MidAFieldAnchor)
	check(not s.worldRuntime.presenceReady(s.player, gen), "locked presence actionable")
	check(s.worldRuntime.secureDestination(s.player) == nil, "locked extraction")
	check(
		s.worldRuntime.travel(s.player, "travel-node/home-hub", gen)
			== "REJECT_STATE_TRAVEL_CONTEXT",
		"locked source fast travel"
	)
	check(
		s.captureRuntime.interact(s.player, s.worldRuntime.world().currentId(), "locked")
			== "REJECT_STATE_CAPTURE_CONTEXT",
		"locked capture"
	)
	spawn.tick(1)
	check(at(s.authored.StarterRecovery) and generation() > gen, "known unlocked correction")
	check(equal(before, s.session.snapshot()), "locked correction changed persistent value")
	gen = generation()
	spawn.tick(3)
	check(generation() == gen, "repeated correction")
	local saved = base.release()
	return { passed = true, scope = saved.scope, knownUnlockedArrival = true, noValueChange = true }
end
local function replacementSession(): any
	base.setup(true)
	local s = state()
	move(s.authored.StarterTravel)
	spawn.tick(1)
	local old, gen = s.session, generation()
	local persisted = old.snapshot()
	check(old.release(s.clock.monotonicClock.seconds() + 25).status == "Closed")
	local server: any = container.MonsterVaultServer
	local runtime = globals.require(server.bootstrap.ProfileRuntimeService).new({
		environment = "DEV",
		declaredUniverseId = game.GameId,
		gameUniverseId = game.GameId,
		gameJobId = "IMP10-presence-replacement",
		dataStoreService = s.storeAdapter,
		players = game:GetService("Players"),
		runService = game:GetService("RunService"),
		httpService = game:GetService("HttpService"),
		diagnostics = { emit = function() end },
	})
	check(runtime.coordinator.open(s.userId).status == "Ready", "scoped replacement Ready")
	local replacement = runtime.coordinator.get(s.userId)
	s.coordinator.get = runtime.coordinator.get
	s.session = replacement
	local before = replacement.snapshot()
	check(
		equal(persisted.world, before.world)
			and equal(persisted.collection, before.collection)
			and equal(persisted.progression, before.progression)
			and persisted.economy.energyUnits == before.economy.energyUnits,
		"replacement lost persisted progress"
	)
	check(not s.worldRuntime.presenceReady(s.player, gen), "new session inherited presence")
	check(
		s.worldRuntime.travel(s.player, "travel-node/home-hub", gen) == "REJECT_STATE_TRAVEL_STALE",
		"new session inherited travel"
	)
	local anchor, parent = s.authored.HomeHubRecovery, s.authored.HomeHubRecovery.Parent
	anchor.Parent = nil
	spawn.tick(2)
	check(not s.worldRuntime.presenceReady(s.player, gen) and generation() == gen)
	check(equal(before, replacement.snapshot()), "unavailable arrival changed value")
	anchor.Parent = parent
	spawn.tick(1)
	check(at(anchor) and generation() > gen, "new session inherited old region")
	check(s.worldRuntime.presenceReady(s.player, generation()))
	check(equal(before, replacement.snapshot()), "safe replacement arrival changed value")
	gen = generation()
	spawn.tick(3)
	check(generation() == gen, "replacement recovered repeatedly")
	check(replacement.release(os.clock() + 25).status == "Closed", "replacement scoped save")
	local saved = base.release()
	check(
		equal(before.world, saved.profile.world)
			and equal(before.collection, saved.profile.collection)
	)
	check(#runtime.stop() == 0, "replacement profile drained")
	return {
		passed = true,
		scope = saved.scope,
		replacementReady = true,
		missingAnchor = true,
		saved = true,
	}
end
local function transportCorrection(): any
	base.setup(true)
	local s = state()
	move(s.authored.StarterTravel)
	spawn.tick(1)
	move(s.authored.FixtureCreatureAnchor)
	spawn.tick(4)
	local id = check(s.worldRuntime.world().currentId())
	check(s.captureRuntime.interact(s.player, id, "presence-claim") == "OK_CAPTURE_CLAIMED")
	local claim = s.captureStates[s.userId]
	check(s.captureRuntime.submit(s.player, {
		captureSessionId = claim.captureSessionId,
		actionId = "capture",
		clientSequence = 1,
	}, "presence-submit") == "OK_CAPTURE_PROVISIONAL")
	local before, gen = s.session.snapshot(), generation()
	move(s.authored.MidASecurePoint)
	s.captureRuntime.secure(s.player, "secure-point/mid-a")
	check(equal(before, s.session.snapshot()), "locked presence secured custody")
	spawn.tick(1)
	check(at(s.authored.StarterRecovery) and generation() > gen)
	check(s.captureStates[s.userId].status == "Interrupted", "recovery kept provisional custody")
	check(equal(before, s.session.snapshot()), "correction extracted provisional custody")
	check((before.collection.creaturesById or {})[id] == nil)
	local saved = base.release()
	return { passed = true, scope = saved.scope, creatureId = id, noExtraction = true }
end
local function pendingFinalization(): any
	base.setup(true)
	local s = state()
	move(s.authored.StarterTravel)
	spawn.tick(1)
	move(s.authored.FixtureCreatureAnchor)
	spawn.tick(4)
	local id = check(s.worldRuntime.world().currentId())
	local identity = s.worldRuntime.world().identity(id)
	check(s.captureRuntime.interact(s.player, id, "pending-claim") == "OK_CAPTURE_CLAIMED")
	local claim = s.captureStates[s.userId]
	check(s.captureRuntime.submit(s.player, {
		captureSessionId = claim.captureSessionId,
		actionId = "capture",
		clientSequence = 1,
	}, "pending-submit") == "OK_CAPTURE_PROVISIONAL")
	s.setFault("Before")
	move(s.authored.FixtureSecurePoint)
	s.captureRuntime.secure(s.player, "secure-point/fixture-spawn")
	check(s.session.state() == "PersistenceAtRisk", "admitted candidate uncertain")
	check(s.captureStates[s.userId].status == "FinalizationPending")
	move(s.authored.MidASecurePoint)
	spawn.tick(1)
	check(s.captureStates[s.userId].status == "FinalizationPending", "correction lost P2 candidate")
	s.setFault(nil)
	s.captureRuntime.reconcile(s.userId)
	check(s.captureRuntime.resync(s.player, "pending-resync") == "OK_CAPTURE_RESYNC")
	local before = s.session.snapshot()
	local owned = check(before.collection.creaturesById[id], "admitted P2 candidate lost")
	check(owned.origin.spawnContextId == identity.spawnContextId, "original capture context lost")
	spawn.tick(1)
	check(at(s.authored.StarterRecovery), "pending owner not safely corrected")
	check(equal(before, s.session.snapshot()), "correction changed finalized outcome")
	check(s.captureRuntime.resync(s.player, "pending-duplicate") == "OK_CAPTURE_RESYNC")
	check(equal(before, s.session.snapshot()), "duplicate reconciliation changed value")
	local saved = base.release()
	return {
		passed = true,
		scope = saved.scope,
		creatureId = id,
		originalCandidate = true,
		exactOnce = true,
	}
end
return {
	lockedPresence = lockedPresence,
	replacementSession = replacementSession,
	transportCorrection = transportCorrection,
	pendingFinalization = pendingFinalization,
}
