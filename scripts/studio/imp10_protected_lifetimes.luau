--!strict

-- Mount beside IMP10RewardProbe. Reuse shipped runtime/profile/P2 owners and
-- actual authored geometry. DEV scope, RNG draw, clocks and pulse dispatch only.
local globals = getfenv() :: any
local container: any = game:GetService("ServerScriptService")
local base: any = globals.require(container.IMP10RewardProbe)
local CONTEXT = "spawn-context/starter-field"
local function check(value: any, message: string?): any
	return assert(value, message or "protected native lifetime invariant")
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
local function state(): any
	return check(base.scopeState(), "protected probe setup required")
end
local function tick(count: number)
	base.tick(count)
	local world = state().world.world()
	check(world.populationCount() <= 8, "shared population cap")
	for _, bucket in world.bucketStatus() do
		check(bucket.count <= 1 and not bucket.paused, "one healthy slot per habitat")
	end
end
local function idFor(context: string): string?
	for _, bucket in state().world.world().bucketStatus() do
		if bucket.spawnContextId == context then
			return bucket.creatureInstanceId
		end
	end
	return nil
end
local function modelFor(id: string): any
	for _, model in state().root.MonsterVaultRuntime.Creatures:GetChildren() do
		if model:GetAttribute("CreatureInstanceId") == id then
			return model
		end
	end
	error("missing native opportunity projection")
end
local function setup(): (any, string)
	local s = base.setup(nil, nil, 0.999999, true)
	base.move(s.authored.StarterFieldAnchor)
	tick(4)
	local id = check(idFor(CONTEXT), "authored protected encounter selected")
	local record, identity = s.world.world().get(id), s.world.world().identity(id)
	check(identity.speciesId == s.profile.worldProgression.registry.protectedEncounter.speciesId)
	check(
		record.lifetimeClass == "ProtectedVariant"
			and record.idleExpiresAt - record.availableAt == 300
	)
	check(modelFor(id).ProtectedEncounterCue.State.Text:find("Legendary DEV", 1, true))
	s.protectedId = id
	return s, id
end
local function capturePulse()
	local s = state()
	check(#s.captureCallbacks == 1, "one capture lifecycle pulse")
	check(table.remove(s.captureCallbacks, 1))()
	check(#s.captureCallbacks == 1, "bounded capture pulse")
end
local function claim(id: string): any
	local s = state()
	check(s.capture.interact(s.player, id, "protected-native-claim") == "OK_CAPTURE_CLAIMED")
	return check(s.captureStates[s.player.UserId])
end
local function provisional(id: string): any
	local s = state()
	local admitted = claim(id)
	local payload =
		{ captureSessionId = admitted.captureSessionId, actionId = "capture", clientSequence = 1 }
	check(
		s.capture.submit(s.player, payload, "protected-native-attempt") == "OK_CAPTURE_PROVISIONAL"
	)
	check(
		s.capture.submit(s.player, payload, "protected-native-duplicate")
			== "OK_CAPTURE_PROVISIONAL"
	)
	check(
		(s.session.snapshot().collection.creaturesById or {})[id] == nil,
		"custody is not ownership"
	)
	return payload
end
local function beginVisibility(): any
	local s, id = setup()
	local record = s.world.world().get(id)
	local ordinary = check(idFor("spawn-context/fixture-clearing"))
	s.mono = 181
	tick(4)
	check(s.world.world().identity(ordinary) == nil, "ordinary encounter did not expire")
	s.wall = 900 -- Cycle transition applies to new reservations only.
	tick(4)
	check(
		idFor(CONTEXT) == id
			and s.world.world().identity(id).cycleContext.phaseId == "world-phase/day"
	)
	check(
		s.world.cycleState().phaseId == "world-phase/day" and s.world.cycleState().cycleIndex == 1
	)
	s.beforeVisibility = s.session.snapshot()
	return {
		scope = s.scope,
		creatureId = id,
		record = record,
		nativeCue = true,
		ordinaryExpired = true,
		pinnedContext = true,
	}
end
local function finishVisibility(): any
	local s, id = state(), state().protectedId
	local world, record = s.world.world(), s.world.world().get(id)
	check(
		record and record.lifetimeClass == "ProtectedVariant",
		"client absence/tampering destroyed authority"
	)
	check(equal(s.beforeVisibility, s.session.snapshot()), "streaming/cycle changed durable value")
	local admitted = claim(id)
	check(modelFor(id):GetAttribute("Availability") == "Claimed")
	s.mono = record.idleExpiresAt
	tick(4)
	check(
		idFor(CONTEXT) == id and not world.expireIfCurrent(id, record.runtimeRevision),
		"claimed lifetime unfair"
	)
	capturePulse() -- Authored 20-second Engagement Claim timeout releases same identity.
	check(world.get(id) and world.get(id).idleExpiresAt == record.idleExpiresAt)
	check(s.capture.submit(s.player, {
		captureSessionId = admitted.captureSessionId,
		actionId = "capture",
		clientSequence = 1,
	}, "expired-claim") ~= "OK_CAPTURE_PROVISIONAL")
	tick(4)
	check(world.identity(id) == nil, "expired released encounter immortal")
	tick(12)
	local fresh = check(idFor(CONTEXT))
	check(
		fresh ~= id and not world.expireIfCurrent(id, record.runtimeRevision),
		"stale callback destroyed replacement"
	)
	check(equal(s.beforeVisibility, s.session.snapshot()), "expiry granted value")
	local saved = base.close()
	return {
		passed = true,
		scope = saved.scope,
		claimTimeout = true,
		replacementId = fresh,
		immutableWindow = true,
		streamingClientTamperingInert = true,
	}
end
local function finalizationFaults(): any
	local results = {}
	for _, fault in { "Before", "After" } do
		local s, id = setup()
		local identity = s.world.world().identity(id)
		local payload = provisional(id)
		s.mono, s.wall = 700, 600
		tick(4)
		check(idFor(CONTEXT) == id and s.capture.state(id) == "TransportActive")
		-- Within the server extraction envelope without touching its automatic
		-- trigger: only the explicit secure below admits the faulted candidate.
		local root = check(s.player.Character:FindFirstChild("HumanoidRootPart"))
		root.CFrame = s.authored.FixtureSecurePoint.CFrame + globals.Vector3.new(8, 3, 0)
		root.AssemblyLinearVelocity = globals.Vector3.zero
		s.fault = fault
		s.capture.secure(s.player, "secure-point/fixture-spawn")
		check(s.capture.state(id) == "FinalizationPending", "fault lost admitted P2 candidate")
		check(s.session.state() == "PersistenceAtRisk")
		s.mono = 1400
		tick(4)
		check(
			s.world.world().identity(id) and idFor(CONTEXT) == id,
			"idle scheduler destroyed pending owner"
		)
		s.fault = nil
		s.capture.reconcile(s.player.UserId)
		local profile = s.session.snapshot()
		local owned = check(profile.collection.creaturesById[id], "same admitted P2 secured")
		check(owned.locked and owned.variantIdentity.speciesRarityId == "rarity/legendary")
		check(
			equal(owned.variantIdentity, identity.variantIdentity)
				and owned.origin.contentSnapshotId == identity.contentSnapshotId
		)
		check(
			profile.world.regionalSpecies["region/fixture-clearing"][owned.speciesId],
			"same-commit world history"
		)
		check(
			profile.economy.energyUnits == 0
				and not s.profile.worldProgression.mastery(
					profile,
					"milestone/region-mastery/starter"
				),
			"optional protected capture granted reward/mastery"
		)
		check(s.world.world().identity(id) == nil, "secured encounter not consumed")
		s.capture.submit(s.player, payload, "protected-native-replay")
		s.capture.reconcile(s.player.UserId)
		check(equal(profile, s.session.snapshot()), "duplicate captured value")
		local saved = base.close()
		local rejoin = base.setup(saved.scope, nil, 0.999999, true)
		check(
			equal(rejoin.session.snapshot().collection, saved.profile.collection),
			"locked protected value lost on rejoin"
		)
		check(equal(rejoin.session.snapshot().world, saved.profile.world), "history lost on rejoin")
		base.move(rejoin.authored.StarterFieldAnchor)
		tick(4)
		check(
			idFor(CONTEXT) ~= id and rejoin.world.world().identity(id) == nil,
			"rejoin resurrected consumed generation"
		)
		check(rejoin.capture.interact(rejoin.player, id, "rejoin-old-id") ~= "OK_CAPTURE_CLAIMED")
		check(
			rejoin.session.snapshot().collection.creaturesById[id].operationId == owned.operationId
		)
		base.close()
		table.insert(results, {
			scope = saved.scope,
			fault = fault,
			faultCuts = saved.faults,
			creatureId = id,
			operationId = owned.operationId,
			locked = true,
			history = true,
			rejoin = true,
		})
	end
	return { passed = true, cases = results, exactOnce = true }
end
local function replacementHazardAndCorruptBinding(): any
	local s, id = setup()
	local before = s.session.snapshot()
	provisional(id)
	s.replacement = {
		state = function()
			return "Ready"
		end,
		snapshot = s.session.snapshot,
	}
	tick(1)
	check(
		s.world.world().identity(id) == nil and s.capture.state(id) == "Interrupted",
		"replacement session retained custody"
	)
	check(equal(before, s.session.snapshot()), "replacement recovery extracted custody")
	s.replacement = nil
	tick(1)
	base.move(s.authored.StarterFieldAnchor)
	tick(12)
	id = check(idFor(CONTEXT))
	provisional(id)
	base.move(s.authored.StarterCorrosiveHazard)
	tick(1)
	check(
		s.world.world().identity(id) == nil and equal(before, s.session.snapshot()),
		"hazard recovery secured protected custody"
	)
	base.move(s.authored.StarterFieldAnchor)
	tick(12)
	id = check(idFor(CONTEXT))
	s.authored.StarterFieldAnchor:SetAttribute("SpeciesId", "species/corrupt-binding")
	tick(4)
	check(
		s.world.world().identity(id) == nil,
		"exceptional corrupt server binding stayed actionable"
	)
	s.authored.StarterFieldAnchor:SetAttribute("SpeciesId", "species/fixture-orb")
	tick(12)
	check(idFor(CONTEXT) ~= id, "repaired binding resurrected old opportunity")
	check(equal(before, s.session.snapshot()), "binding repair granted value")
	local saved = base.close()
	return {
		passed = true,
		scope = saved.scope,
		replacementAndHazardNeverExtract = true,
		corruptBindingFailClosed = true,
	}
end
local function shutdownCustodyRejoin(): any
	local s, id = setup()
	provisional(id)
	s.mono, s.wall = 700, 600
	tick(4)
	local saved = base.close() -- Existing TA-7 trusted ProvisionalShutdown, same original operation.
	local owned = check(saved.profile.collection.creaturesById[id])
	check(owned.locked and saved.profile.economy.energyUnits == 0)
	local rejoin = base.setup(saved.scope, nil, 0.999999, true)
	check(equal(rejoin.session.snapshot().collection, saved.profile.collection))
	check(rejoin.world.world().identity(id) == nil, "shutdown consumed identity resurrected")
	base.close()
	return {
		passed = true,
		scope = saved.scope,
		creatureId = id,
		operationId = owned.operationId,
		trustedShutdownOnly = true,
		rejoin = true,
	}
end
return {
	beginVisibility = beginVisibility,
	finishVisibility = finishVisibility,
	finalizationFaults = finalizationFaults,
	replacementHazardAndCorruptBinding = replacementHazardAndCorruptBinding,
	shutdownCustodyRejoin = shutdownCustodyRejoin,
}
