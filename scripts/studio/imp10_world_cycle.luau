--!strict

-- Native Studio integration probe. Uses the existing scoped DEV repository,
-- actual authored actions/captures and one scheduler; wall time alone is injected.
local globals = getfenv() :: any
local container: any = game.ServerScriptService
local base: any = globals.require(container.IMP10WorldProbe)
local regional: any = globals.require(container.IMP10SpawnProbe)
local wall = 299
local function state(): any
	return assert(base.scopeState(), "cycle probe setup required")
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
local function move(part: any)
	local root = assert(state().player.Character:FindFirstChild("HumanoidRootPart"), "character")
	root.CFrame = part.CFrame + globals.Vector3.new(0, 3, 0)
	root.AssemblyLinearVelocity = globals.Vector3.zero
	globals.task.wait(0.1)
end
local function advance(time: number, ticks: number?): any
	wall = time
	regional.tick(ticks or 4)
	return state().worldRuntime.cycleState()
end
local function setup(): any
	wall = 299
	local result = regional.lockedAndStarter(function()
		return wall
	end)
	assert(result.starter.cycleContext.phaseId == "world-phase/day", "initial absolute Day")
	local root = state().root.MonsterVaultRuntime
	assert(root:GetAttribute("WorldCyclePhaseId") == "world-phase/day", "public cycle readback")
	assert(
		#string.split(root:GetAttribute("EligibleSpawnContextIds"), ",") == 8,
		"all DEV contexts phase-independent"
	)
	return result
end
local function captureAcrossBoundary(): any
	local s = state()
	move(s.authored.FixtureSecurePoint)
	assert(
		s.worldRuntime.discover(s.player, "landmark/fixture-entry") == "OK_WORLD_VISITED",
		"actual entry"
	)
	move(s.authored.FixtureCreatureAnchor)
	assert(
		s.worldRuntime.discover(s.player, "landmark/fixture-clearing") == "OK_WORLD_VISITED",
		"actual field objective"
	)
	local id = assert(s.worldRuntime.world().currentId(), "protected Starter encounter")
	local identity = s.worldRuntime.world().identity(id)
	assert(identity.cycleContext.phaseId == "world-phase/day", "claim before boundary")
	assert(
		s.captureRuntime.interact(s.player, id, "cycle-claim") == "OK_CAPTURE_CLAIMED",
		"actual claim"
	)
	local claim = s.captureStates[s.userId]
	local payload =
		{ captureSessionId = claim.captureSessionId, actionId = "capture", clientSequence = 1 }
	assert(
		s.captureRuntime.submit(s.player, payload, "cycle-submit") == "OK_CAPTURE_PROVISIONAL",
		"actual capture before transition"
	)
	local before = s.session.snapshot()
	assert(advance(300).phaseId == "world-phase/dusk", "exact boundary belongs to new phase")
	assert(
		regional.idFor("spawn-context/fixture-clearing") == id,
		"transition cannot replenish custody"
	)
	assert(equal(s.session.snapshot(), before), "transition cannot mutate profile/history")
	assert(equal(s.worldRuntime.world().identity(id), identity), "reservation never rebound")
	move(s.authored.FixtureSecurePoint)
	s.captureRuntime.secure(s.player)
	local deadline = os.clock() + 10
	local record: any = nil
	repeat
		record = s.session.snapshot().collection.creaturesById[id]
		if record == nil then
			globals.task.wait(0.1)
		end
	until record ~= nil or os.clock() >= deadline
	assert(
		record ~= nil and record.origin.spawnContextId == identity.spawnContextId,
		"P2 original origin"
	)
	assert(
		s.worldRuntime.discover(s.player, "landmark/fixture-entry") == "OK_WORLD_VISITED",
		"active return"
	)
	assert(
		s.world.mastery(s.session.snapshot(), "milestone/region-mastery/starter"),
		"actual Starter mastery"
	)
	s.creatureId = id
	local revision = s.session.snapshot().profileRevision
	s.captureRuntime.submit(s.player, payload, "cycle-duplicate")
	assert(s.session.snapshot().profileRevision == revision, "old attempt no duplicate grant")
	regional.tick(12)
	local replacement =
		assert(regional.idFor("spawn-context/fixture-clearing"), "replenished fallback")
	assert(
		replacement ~= id
			and s.worldRuntime.world().identity(replacement).cycleContext.phaseId
				== "world-phase/dusk",
		"future spawn uses Dusk"
	)
	base.productionAndAccess()
	return {
		passed = true,
		captured = identity,
		ownership = record.origin,
		replacement = s.worldRuntime.world().identity(replacement),
		energy = s.session.snapshot().economy.energyUnits,
	}
end
local function regionalFlows(): any
	local a, b = regional.regionalMastery("MidA"), regional.regionalMastery("MidB")
	assert(
		a.identity.cycleContext.phaseId == "world-phase/dusk"
			and b.identity.cycleContext.phaseId == "world-phase/dusk",
		"real post-transition captures"
	)
	advance(600)
	local advanced = regional.regionalMastery("Advanced")
	assert(
		advanced.identity.cycleContext.phaseId == "world-phase/night",
		"future Advanced Night context"
	)
	local caps = regional.lifecycleAndCaps()
	return { passed = true, midA = a, midB = b, advanced = advanced, caps = caps }
end
local function boundariesAndInvalidClock(): any
	local s = state()
	local before, identities = s.session.snapshot(), {}
	for _, bucket in s.worldRuntime.world().bucketStatus() do
		if bucket.creatureInstanceId then
			identities[bucket.creatureInstanceId] =
				s.worldRuntime.world().identity(bucket.creatureInstanceId)
		end
	end
	assert(advance(899.999).phaseId == "world-phase/night", "half-open Night end")
	local stale = assert(s.worldCallbacks[1], "callback before transition")
	local snapshot = advance(900, 1)
	assert(snapshot.phaseId == "world-phase/day" and snapshot.cycleIndex == 1, "exact next cycle")
	stale()
	assert(
		#s.worldCallbacks == 1 and s.root.MonsterVaultRuntime:GetAttribute("WorldCycleIndex") == 1,
		"stale ticket cannot restore previous context"
	)
	for id, identity in identities do
		assert(
			equal(identity, s.worldRuntime.world().identity(id)),
			"live identity/history rewritten"
		)
	end
	local available = s.worldRuntime.world().populationCount()
	wall = 0 / 0
	regional.tick(1)
	assert(
		not s.root.MonsterVaultRuntime:GetAttribute("WorldCycleAvailable")
			and s.worldRuntime.cycleState() == nil,
		"invalid clock readback fails closed"
	)
	assert(
		s.worldRuntime.world().populationCount() == available,
		"invalid clock preserves live entities"
	)
	local context = "spawn-context/advanced"
	local old = assert(regional.idFor(context), "ordinary Advanced")
	assert(s.worldRuntime.world().retire(old), "genuine terminal")
	regional.tick(12)
	assert(regional.idFor(context) == nil, "invalid cycle cannot allocate")
	assert(advance(901).cycleIndex == 1, "valid absolute clock resumes")
	local replacement = assert(regional.idFor(context), "future context resumes safely")
	assert(
		replacement ~= old
			and s.worldRuntime.world().identity(replacement).cycleContext.cycleIndex == 1,
		"new identity after recovery"
	)
	assert(
		equal(before, s.session.snapshot()),
		"cycle/scheduling never writes player history/economy"
	)
	return {
		passed = true,
		exactBoundary = snapshot,
		invalidClock = true,
		staleTickets = true,
		retainedLive = available,
		replacement = replacement,
	}
end
local function streamingTransition(): any
	local s = state()
	local id = assert(regional.idFor("spawn-context/advanced"), "streaming target")
	local identity, before = s.worldRuntime.world().identity(id), s.session.snapshot()
	local snapshot = advance(1200)
	assert(
		snapshot.phaseId == "world-phase/dusk" and snapshot.cycleIndex == 1,
		"transition during stream-out"
	)
	assert(
		equal(identity, s.worldRuntime.world().identity(id)),
		"server identity unaffected by engine streaming/phase"
	)
	assert(equal(before, s.session.snapshot()), "streaming transition cannot rewrite player state")
	return {
		passed = true,
		identity = identity,
		currentCycle = snapshot,
		population = s.worldRuntime.world().populationCount(),
	}
end
local function release(): any
	local resume = regional.release()
	resume.cycleUnixSeconds = wall
	return resume
end
local function rejoin(resume: any): any
	local result = regional.rejoin(resume, function()
		return resume.cycleUnixSeconds
	end)
	assert(
		result.spawn.cycle.phaseId == "world-phase/dusk" and result.spawn.cycle.cycleIndex == 1,
		"fresh Play cannot reset absolute cycle"
	)
	return result
end
return {
	setup = setup,
	captureAcrossBoundary = captureAcrossBoundary,
	regionalFlows = regionalFlows,
	boundariesAndInvalidClock = boundariesAndInvalidClock,
	streamingTransition = streamingTransition,
	release = release,
	rejoin = rejoin,
}
