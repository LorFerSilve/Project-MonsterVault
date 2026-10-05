--!strict

-- Native server fixture: real characters, authored index and scoped DEV P2.
-- Disable the ordinary bootstrap only for this isolated composition; restore in Edit.
local globals = getfenv() :: any
local container: any = game:GetService("ServerScriptService")
local base: any = globals.require(container.IMP10WorldProbe)
local spawn: any = globals.require(container.IMP10SpawnProbe)
local phase = 299
local function check(value: any, message: string?): any
	return assert(value, message or "native travel invariant")
end
local function state(): any
	return check(base.scopeState(), "native travel setup")
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
local function root(): any
	return check(state().player.Character:FindFirstChild("HumanoidRootPart"))
end
local function generation(): number
	return state().player:GetAttribute("MonsterVaultCharacterGeneration")
end
local function move(part: any)
	root().CFrame = part.CFrame + globals.Vector3.new(0, 3, 0)
	root().AssemblyLinearVelocity = globals.Vector3.zero
	globals.task.wait(0.1)
end
local function travel(node: string, gen: number?): string
	return state().worldRuntime.travel(state().player, node, gen or generation())
end
local function packet(node: string, extra: any?): any
	local payload: any = { nodeId = node, characterGeneration = generation() }
	for k, v in extra or {} do
		payload[k] = v
	end
	return {
		protocolVersion = 1,
		routeId = "World.RequestFastTravel",
		requestId = game:GetService("HttpService"):GenerateGUID(false),
		payload = payload,
	}
end
local function at(part: any): boolean
	return (root().Position - part.Position).Magnitude < 4.5
end
local function setup(): any
	phase = 299
	base.setup(true, function()
		return phase
	end)
	local s = state()
	check(at(s.authored.HomeHubRecovery), "initial safe authored placement")
	check(s.worldRuntime.presenceReady(s.player, generation()), "placed generation active")
	check(s.session.snapshot().world.travelNodes["travel-node/home-hub"], "observed Home discovery")
	local before, position = s.session.snapshot(), root().CFrame
	check(travel("travel-node/mid-a") == "REJECT_STATE_TRAVEL_ACCESS", "locked destination")
	check(travel("travel-node/forged") == "REJECT_STATE_TRAVEL_DESTINATION", "forged destination")
	check(travel("travel-node/starter") == "REJECT_STATE_TRAVEL_UNDISCOVERED", "unreached outpost")
	check(
		travel("travel-node/starter", generation() + 1) == "REJECT_STATE_TRAVEL_STALE",
		"forged generation"
	)
	check(s.network.gateway.handle(
		s.player,
		packet("travel-node/starter", {
			position = { x = 0, y = 0, z = 16 },
			discovery = true,
		})
	).code == "REJECT_VALIDATION_PAYLOAD", "client position/discovery")
	check(
		root().CFrame == position and equal(before, s.session.snapshot()),
		"negative requests unchanged"
	)
	move(s.authored.HomeHubTravel)
	check(
		s.worldRuntime.discoverTravel(s.player, "travel-node/starter")
			== "REJECT_STATE_TRAVEL_DISCOVERY_CONTEXT",
		"remote discovery"
	)
	move(s.authored.StarterTravel)
	spawn.tick(1)
	check(
		s.session.snapshot().world.travelNodes["travel-node/starter"],
		"actual Starter arrival discovery"
	)
	local discovered = s.session.snapshot()
	check(
		s.worldRuntime.discoverTravel(s.player, "travel-node/starter")
			== "OK_WORLD_TRAVEL_DISCOVERED"
	)
	check(equal(discovered, s.session.snapshot()), "node duplicate no write")
	local command = packet("travel-node/home-hub")
	check(
		s.network.gateway.handle(s.player, command).code == "OK_WORLD_TRAVELLED",
		"native Class C travel"
	)
	check(at(s.authored.HomeHubRecovery), "Home safe arrival")
	local pos = root().CFrame
	check(
		s.network.gateway.handle(s.player, command).code == "OK_WORLD_TRAVELLED"
			and root().CFrame == pos,
		"cached duplicate"
	)
	spawn.tick(1)
	phase = 300
	check(travel("travel-node/starter") == "OK_WORLD_TRAVELLED", "transition boundary travel")
	check(
		at(s.authored.StarterRecovery) and s.worldRuntime.cycleState().phaseId == "world-phase/dusk"
	)
	pos = root().CFrame
	check(
		s.network.gateway.handle(s.player, command).code == "OK_WORLD_TRAVELLED"
			and root().CFrame == pos,
		"old duplicate cannot relocate again"
	)
	for _ = 1, 25 do
		check(travel("travel-node/home-hub") == "REJECT_RATE_LIMIT")
	end
	check(equal(discovered.world, s.session.snapshot().world), "travel preserves history")
	return {
		passed = true,
		scope = s.scope,
		initialSafeArrival = true,
		locked = true,
		unknown = true,
		undiscovered = true,
		strictPayload = true,
		observedDiscovery = true,
		duplicate = true,
		boundedSpam = true,
		transitionTime = phase,
	}
end
local function unavailableRecovery(): any
	local s = state()
	spawn.tick(1)
	check(travel("travel-node/home-hub") == "OK_WORLD_TRAVELLED", "source Home for binding tests")
	spawn.tick(1)
	local before, gen = s.session.snapshot(), generation()
	local region = s.worldRuntime.authoring().regions[s.world.registry.roles.HomeHub].part
	local regionId = region:GetAttribute("RegionId")
	region:SetAttribute("RegionId", "region/forged")
	check(
		not s.worldRuntime.presenceReady(s.player, gen),
		"corrupt current region is not a connector"
	)
	check(travel("travel-node/starter") == "REJECT_STATE_TRAVEL_CONTEXT", "corrupt source context")
	region:SetAttribute("RegionId", regionId)
	local anchor, parent = s.authored.HomeHubRecovery, s.authored.HomeHubRecovery.Parent
	anchor.Parent = nil
	root().CFrame = globals.CFrame.new(10000, 100, 10000)
	spawn.tick(1)
	check(
		not s.worldRuntime.presenceReady(s.player, gen) and generation() == gen,
		"missing recovery anchor keeps presence inactive"
	)
	check(
		(root().Position - globals.Vector3.new(10000, 100, 10000)).Magnitude < 5,
		"no invented fallback"
	)
	check(
		s.captureRuntime.interact(s.player, s.worldRuntime.world().currentId(), "inactive")
			== "REJECT_STATE_CAPTURE_CONTEXT",
		"inactive capture context"
	)
	anchor.Parent = parent
	spawn.tick(1)
	check(
		at(anchor) and generation() > gen and s.worldRuntime.presenceReady(s.player, generation()),
		"restored safe recovery"
	)
	phase = 0 / 0
	check(travel("travel-node/starter") == "REJECT_STATE_TRAVEL_CONTEXT", "invalid cycle context")
	check(
		s.worldRuntime.discoverTravel(s.player, "travel-node/home-hub")
			== "REJECT_STATE_TRAVEL_DISCOVERY_CONTEXT",
		"invalid cycle discovery"
	)
	phase = 301
	spawn.tick(1)
	check(equal(before, s.session.snapshot()), "failed arrival/context does not rewrite history")
	return {
		passed = true,
		corruptRegion = true,
		missingRecovery = true,
		restored = true,
		inactiveCaptureRejected = true,
		invalidCycle = true,
		generation = generation(),
	}
end
local function masteryAndRoutes(): any
	local s = state()
	base.surveyAndCapture()
	base.productionAndAccess()
	for _, role in { "MidA", "MidB", "Advanced" } do
		spawn.regionalMastery(role)
		move(s.authored[role .. "Travel"])
		spawn.tick(1)
		local node = if role == "MidA"
			then "travel-node/mid-a"
			elseif role == "MidB" then "travel-node/mid-b"
			else "travel-node/advanced"
		check(s.session.snapshot().world.travelNodes[node], "legitimate unlocked outpost discovery")
		local other = if role == "MidA" then "travel-node/mid-b" else "travel-node/mid-a"
		if s.world.travelDiscovered(s.session.snapshot(), other) then
			check(travel(other) == "REJECT_STATE_TRAVEL_ROUTE", "no invented field-to-field route")
		end
		local before = s.session.snapshot()
		check(travel("travel-node/home-hub") == "OK_WORLD_TRAVELLED")
		check(at(s.authored.HomeHubRecovery))
		spawn.tick(1)
		check(travel(node) == "OK_WORLD_TRAVELLED" and at(s.authored[role .. "Recovery"]))
		check(equal(before, s.session.snapshot()), "roundtrip grants no value or mastery")
		spawn.tick(1)
	end
	check(s.session.snapshot().economy.energyUnits == 325)
	return {
		passed = true,
		roles = { "MidA", "MidB", "Advanced" },
		realMastery = true,
		discoveredNodes = s.session.snapshot().world.travelNodes,
		energy = 325,
		noFieldToField = true,
	}
end
local function captureAndRecovery(): any
	local s = state()
	move(s.authored.AdvancedFieldAnchor)
	spawn.tick(12)
	local id = check(spawn.idFor("spawn-context/advanced"))
	check(s.captureRuntime.interact(s.player, id, "travel-capture") == "OK_CAPTURE_CLAIMED")
	local claim = s.captureStates[s.userId]
	-- Inside the travel radius, outside the real extraction radius.
	root().CFrame = s.authored.AdvancedTravel.CFrame + globals.Vector3.new(12, 3, 0)
	check(
		travel("travel-node/home-hub") == "REJECT_STATE_TRAVEL_ACQUISITION",
		"engagement blocks travel"
	)
	move(s.authored.AdvancedFieldAnchor)
	check(
		s.captureRuntime.submit(
			s.player,
			{ captureSessionId = claim.captureSessionId, actionId = "capture", clientSequence = 1 },
			"travel-submit"
		) == "OK_CAPTURE_PROVISIONAL"
	)
	root().CFrame = s.authored.AdvancedTravel.CFrame + globals.Vector3.new(12, 3, 0)
	check(
		travel("travel-node/home-hub") == "REJECT_STATE_TRAVEL_ACQUISITION",
		"transport blocks travel"
	)
	local before, oldGeneration = s.session.snapshot(), generation()
	root().CFrame = globals.CFrame.new(10000, 100, 10000)
	spawn.tick(1)
	check(
		at(s.authored.AdvancedRecovery) and generation() > oldGeneration,
		"invalid-position recovery"
	)
	check(s.captureRuntime.state(id) == "Interrupted", "recovery interrupts custody")
	s.captureRuntime.secure(s.player, "secure-point/advanced")
	check(s.session.snapshot().collection.creaturesById[id] == nil, "recovery is not extraction")
	check(equal(before, s.session.snapshot()), "recovery preserves history and wallet")
	local freshGeneration = generation()
	spawn.tick(5)
	check(
		generation() == freshGeneration and at(s.authored.AdvancedRecovery),
		"recovery idempotent"
	)
	check(travel("travel-node/home-hub", oldGeneration) == "REJECT_STATE_TRAVEL_STALE")
	check(travel("travel-node/home-hub") == "OK_WORLD_TRAVELLED")
	spawn.tick(1)
	return {
		passed = true,
		captureSessionId = claim.captureSessionId,
		interruptedId = id,
		noExtraction = true,
		engagementBlocked = true,
		transportBlocked = true,
		generationFenced = true,
		idempotentRecovery = true,
	}
end
local function corruptBindings(): any
	local s = state()
	move(s.authored.HomeHubTravel)
	local before, position = s.session.snapshot(), root().CFrame
	local anchor, node = s.authored.AdvancedRecovery, s.authored.AdvancedTravel
	local parent, cframe = anchor.Parent, anchor.CFrame
	anchor.Parent = nil
	check(travel("travel-node/advanced") == "REJECT_STATE_TRAVEL_ARRIVAL", "missing arrival anchor")
	anchor.Parent = parent
	anchor.CFrame += globals.Vector3.new(0, 2, 0)
	check(travel("travel-node/advanced") == "REJECT_STATE_TRAVEL_ARRIVAL", "moved arrival anchor")
	anchor.CFrame = cframe
	local id = node:GetAttribute("TravelNodeId")
	node:SetAttribute("TravelNodeId", "travel-node/forged")
	check(
		travel("travel-node/advanced") == "REJECT_STATE_TRAVEL_DESTINATION",
		"corrupt target metadata"
	)
	node:SetAttribute("TravelNodeId", id)
	local obstruction = globals.Instance.new("Part")
	obstruction.Anchored, obstruction.Size = true, globals.Vector3.new(4, 8, 4)
	obstruction.Position, obstruction.Parent =
		anchor.Position + globals.Vector3.new(0, 4, 0), s.authored
	check(travel("travel-node/advanced") == "REJECT_STATE_TRAVEL_ARRIVAL", "unsafe headroom")
	obstruction:Destroy()
	check(
		position == root().CFrame and equal(before, s.session.snapshot()),
		"corrupt targets do not relocate or mutate"
	)
	check(travel("travel-node/advanced") == "OK_WORLD_TRAVELLED", "restored binding recovers")
	spawn.tick(4)
	phase = 600
	local identity = s.worldRuntime.world().identity(check(spawn.idFor("spawn-context/advanced")))
	spawn.tick(1)
	check(
		identity.creatureInstanceId == spawn.idFor("spawn-context/advanced"),
		"transition preserves existing encounter"
	)
	check(travel("travel-node/home-hub") == "OK_WORLD_TRAVELLED")
	spawn.tick(1)
	check(travel("travel-node/advanced") == "OK_WORLD_TRAVELLED")
	spawn.tick(1)
	return {
		passed = true,
		missing = true,
		moved = true,
		forged = true,
		unsafe = true,
		phase = s.worldRuntime.cycleState(),
		preservedIdentity = identity.creatureInstanceId,
	}
end
local function release(): any
	local saved = spawn.release()
	check(saved.profile.economy.energyUnits == 325)
	local count = 0
	for _ in saved.profile.world.travelNodes do
		count += 1
	end
	check(count == 5, "bounded persisted node discovery")
	return saved
end
local function avatarArrival(): any
	base.setup(true)
	local s = state()
	local old = s.player.Character
	local players = game:GetService("Players")
	local rig = players:CreateHumanoidModelFromDescriptionAsync(
		globals.Instance.new("HumanoidDescription"),
		globals.Enum.HumanoidRigType.R6
	)
	rig.Name, rig.Parent = s.player.Name, workspace
	rig:PivotTo(globals.CFrame.new(0, 100, 128))
	s.player.Character = rig
	spawn.tick(1)
	local r6Height = root().Position.Y
	check(
		math.abs(r6Height - 4.1) < 0.2 and at(s.authored.HomeHubRecovery),
		"R6 safe standing height"
	)
	move(s.authored.StarterTravel)
	spawn.tick(1)
	check(travel("travel-node/home-hub") == "OK_WORLD_TRAVELLED", "R6 travel")
	check(math.abs(root().Position.Y - 4.1) < 0.2, "R6 arrival does not clip feet")
	s.player:LoadCharacterAsync()
	spawn.tick(1)
	check(s.worldRuntime.presenceReady(s.player, generation()), "default avatar recovered")
	old:Destroy()
	rig:Destroy()
	local saved = base.release()
	return {
		passed = true,
		r6RootY = r6Height,
		scope = saved.scope,
		economyUnchanged = saved.profile.economy.energyUnits == 0,
	}
end
local function rejoin(resume: any): any
	return spawn.rejoin(resume, function()
		return 1200
	end, function(world: any, player: any, session: any, authored: any, step: (number) -> ())
		local before, gen =
			session.snapshot(), player:GetAttribute("MonsterVaultCharacterGeneration")
		player.Character.HumanoidRootPart.CFrame = authored.AdvancedTravel.CFrame
			+ globals.Vector3.new(0, 3, 0)
		check(
			world.travel(player, "travel-node/home-hub", gen) == "OK_WORLD_TRAVELLED",
			"persisted node and access"
		)
		step(1)
		check(
			world.travel(player, "travel-node/advanced", gen) == "OK_WORLD_TRAVELLED",
			"fresh server roundtrip"
		)
		step(1)
		local oldCharacter = player.Character
		player:LoadCharacterAsync()
		local deadline = os.clock() + 5
		repeat
			globals.task.wait(0.05)
		until (
				player.Character ~= oldCharacter
				and player.Character
				and player.Character:FindFirstChild("HumanoidRootPart")
			) or os.clock() >= deadline
		check(player.Character ~= oldCharacter, "native replacement avatar")
		step(1)
		local newGen = player:GetAttribute("MonsterVaultCharacterGeneration")
		check(newGen > gen and world.presenceReady(player, newGen), "recovered before actions")
		check(
			world.travel(player, "travel-node/home-hub", gen) == "REJECT_STATE_TRAVEL_STALE",
			"old avatar intent"
		)
		local position, safe = player.Character.HumanoidRootPart.Position, false
		for _, part in
			{
				authored.HomeHubRecovery,
				authored.StarterRecovery,
				authored.MidARecovery,
				authored.MidBRecovery,
				authored.AdvancedRecovery,
			}
		do
			safe = safe or (position - part.Position).Magnitude < 4.5
		end
		check(safe, "authored replacement arrival")
		local p = session.snapshot()
		check(
			equal(before.world, p.world)
				and equal(before.collection, p.collection)
				and equal(before.progression, p.progression),
			"travel/respawn retains exact history"
		)
		check(p.economy.energyUnits == 325, "wallet retained")
		return {
			passed = true,
			persistedDiscoveries = true,
			staleAvatarRejected = true,
			oldGeneration = gen,
			newGeneration = newGen,
			recoveryPosition = tostring(position),
		}
	end)
end
local function discoveryFaults(): any
	local results = {}
	for _, mode in { "Before", "After" } do
		base.setup(true)
		local s = state()
		move(s.authored.StarterTravel)
		local before = s.session.snapshot()
		s.setFault(mode)
		check(
			s.worldRuntime.discoverTravel(s.player, "travel-node/starter")
				== "OUTCOME_UNKNOWN_WORLD_WRITE"
		)
		check(s.session.state() == "PersistenceAtRisk")
		s.setFault(nil)
		move(s.authored.HomeHubTravel)
		check(s.worldRuntime.resync(s.player, "discovery-retry") == "OK_WORLD_RECONCILED")
		local p = s.session.snapshot()
		check(
			p.profileRevision == before.profileRevision + 1
				and p.world.travelNodes["travel-node/starter"]
		)
		check(
			equal(before.collection, p.collection)
				and equal(before.economy, p.economy)
				and equal(before.world.mastery, p.world.mastery),
			"discovery retries grant no value"
		)
		move(s.authored.StarterTravel)
		check(
			s.worldRuntime.discoverTravel(s.player, "travel-node/starter")
				== "OK_WORLD_TRAVEL_DISCOVERED"
		)
		check(equal(p, s.session.snapshot()), "uncertain discovery never repeated")
		local saved = base.release()
		check(equal(saved.profile.world, p.world), "unknown discovery persisted once")
		table.insert(results, {
			mode = mode,
			scope = saved.scope,
			cuts = s.faultCuts,
			operation = p.world.travelNodes["travel-node/starter"],
			passed = true,
		})
	end
	return { passed = true, cases = results }
end
return {
	setup = setup,
	unavailableRecovery = unavailableRecovery,
	masteryAndRoutes = masteryAndRoutes,
	captureAndRecovery = captureAndRecovery,
	corruptBindings = corruptBindings,
	release = release,
	rejoin = rejoin,
	avatarArrival = avatarArrival,
	discoveryFaults = discoveryFaults,
}
