--!strict

-- Mount beside IMP10WorldProbe in a native Studio server. Reuses its scoped DEV
-- persistence/capture/progression composition; no fabricated eligibility or rewards.
local globals = getfenv() :: any
local probeContainer: any = game:GetService("ServerScriptService")
local base: any = globals.require(probeContainer.IMP10WorldProbe)
local function state(): any
	return assert(base.scopeState(), "regional probe setup required")
end
local function move(part: any)
	local root = assert(state().player.Character:FindFirstChild("HumanoidRootPart"))
	root.CFrame = part.CFrame + globals.Vector3.new(0, 3, 0)
	root.AssemblyLinearVelocity = globals.Vector3.zero
	globals.task.wait(0.1)
end
local function tick(count: number)
	local s = state()
	for _ = 1, count do
		assert(#s.worldCallbacks == 1, "one coordinator callback")
		s.clock.advanceWorld(1)
		local callback = assert(table.remove(s.worldCallbacks, 1), "scheduled callback exists")
		callback()
		local before = s.worldRuntime.world().populationCount()
		callback() -- Duplicate ticket cannot step or fork another delay chain.
		assert(
			#s.worldCallbacks == 1 and before == s.worldRuntime.world().populationCount(),
			"duplicate pulse is inert"
		)
		assert(before <= 8, "reservation + live cap")
		for _, bucket in s.worldRuntime.world().bucketStatus() do
			assert(bucket.count <= 1 and not bucket.paused, "habitat cap and healthy bucket")
		end
	end
end
local function idFor(context: string): string?
	for _, bucket in state().worldRuntime.world().bucketStatus() do
		if bucket.spawnContextId == context then
			return bucket.creatureInstanceId
		end
	end
	return nil
end
local function visit(id: string)
	assert(state().worldRuntime.discover(state().player, id) == "OK_WORLD_VISITED", id)
end
local function lockedAndStarter(): any
	base.setup(true)
	local s = state()
	move(s.authored.MidAFieldAnchor)
	tick(8)
	assert(
		idFor("spawn-context/mid-a") == nil and idFor("spawn-context/mid-a-edge") == nil,
		"locked region remains dormant"
	)
	assert(
		s.worldRuntime.discover(s.player, "landmark/mid-a-field")
			== "REJECT_STATE_WORLD_ACCESS_BLOCKED",
		"locked authored action rejected"
	)
	assert(s.session.snapshot().economy.energyUnits == 0, "locked scheduling grants no energy")
	move(s.authored.StarterFieldAnchor)
	tick(4)
	local id = assert(idFor("spawn-context/starter-field"), "eligible Starter regional spawn")
	local identity = s.worldRuntime.world().identity(id)
	assert(identity.speciesId == "species/fixture-companion", "injected weighted selection")
	assert(
		identity.contentSnapshotId == s.world.registry.contentSnapshotId,
		"current authored epoch"
	)
	assert(s.worldRuntime.world().populationCount() == 2, "preserved fixture plus ordinary Starter")
	return { passed = true, lockedClosed = true, starter = identity, duplicateTickets = true }
end
local function starterAndUnlocks(): any
	base.surveyAndCapture()
	local s = state()
	local oldId = s.creatureId
	tick(12)
	assert(s.worldRuntime.world().identity(oldId) == nil, "P2 retirement frees original bucket")
	local replacement = assert(idFor("spawn-context/fixture-clearing"))
	assert(
		replacement ~= oldId and not s.worldRuntime.world().retire(oldId),
		"one fresh replacement"
	)
	base.productionAndAccess()
	return {
		passed = true,
		capturedId = oldId,
		replacement = replacement,
		energy = 520,
		realMidAccess = true,
	}
end
local function regionalMastery(role: string): any
	local s = state()
	local slug = if role == "MidA" then "mid-a" elseif role == "MidB" then "mid-b" else "advanced"
	if role == "Advanced" then
		local q = assert(
			s.purchases.quote(s.session, "access/biome-advanced").quote,
			"real Mid mastery permits Advanced quote"
		)
		local payload = {
			unlockId = "access/biome-advanced",
			quoteId = q.quoteId,
			quoteRevision = q.quoteRevision,
		}
		assert(
			s.purchases.purchase(s.session, payload, q.expectedRevision).status == "Committed",
			"real Advanced purchase"
		)
		table.insert(s.receipts, { payload = payload, expectedRevision = q.expectedRevision })
	end
	local entry, field = s.authored[role .. "SecurePoint"], s.authored[role .. "FieldAnchor"]
	move(entry)
	visit("landmark/" .. slug .. "-entry")
	move(field)
	visit("landmark/" .. slug .. "-field")
	tick(12)
	local id = assert(idFor("spawn-context/" .. slug), "actual region scheduler spawned")
	local identity = s.worldRuntime.world().identity(id)
	local context = s.world.registry.spawnContexts[identity.spawnContextId]
	assert(table.find(context.speciesIds, identity.speciesId), "authored regional pool only")
	assert(
		s.captureRuntime.interact(s.player, id, "spawn-capture") == "OK_CAPTURE_CLAIMED",
		"real scheduled encounter claim"
	)
	local claim = s.captureStates[s.userId]
	local submit =
		{ captureSessionId = claim.captureSessionId, actionId = "capture", clientSequence = 1 }
	assert(
		s.captureRuntime.submit(s.player, submit, "spawn-submit") == "OK_CAPTURE_PROVISIONAL",
		"real scheduled capture attempt"
	)
	-- Real native capture owner remains authoritative while its bucket is occupied.
	tick(4)
	assert(idFor("spawn-context/" .. slug) == id, "provisional transport cannot replenish")
	move(entry)
	s.captureRuntime.secure(s.player, "secure-point/" .. slug)
	local deadline = os.clock() + 10
	local record: any = nil
	repeat
		record = s.session.snapshot().collection.creaturesById[id]
		if record == nil then
			globals.task.wait(0.1)
		end
	until record ~= nil or os.clock() >= deadline
	assert(record ~= nil and record.speciesId == identity.speciesId, "P2 exact scheduled identity")
	visit("landmark/" .. slug .. "-entry")
	local region = s.world.registry.regions[s.world.registry.roles[role]]
	assert(
		s.world.mastery(s.session.snapshot(), region.mastery.milestoneId),
		"actual regional mastery"
	)
	local before = s.session.snapshot().profileRevision
	s.captureRuntime.submit(s.player, submit, "spawn-retry")
	assert(s.session.snapshot().profileRevision == before, "old attempt cannot repeat grant")
	tick(12)
	assert(
		idFor("spawn-context/" .. slug) ~= id and s.worldRuntime.world().identity(id) == nil,
		"captured encounter replenished once"
	)
	return {
		passed = true,
		role = role,
		identity = identity,
		ownership = record.origin,
		mastery = true,
		replenished = true,
	}
end
local function lifecycleAndCaps(): any
	local s = state()
	for _, role in { "Starter", "MidA", "MidB", "Advanced" } do
		move(
			if role == "Starter"
				then s.authored.StarterFieldAnchor
				else s.authored[role .. "FieldAnchor"]
		)
		tick(4)
	end
	assert(s.worldRuntime.world().populationCount() == 8, "actual eight authored habitats bounded")
	local counts = {}
	for _, bucket in s.worldRuntime.world().bucketStatus() do
		counts[bucket.regionId] = (counts[bucket.regionId] or 0) + bucket.count
		assert(counts[bucket.regionId] <= 2, "region cap")
	end
	local context = "spawn-context/advanced"
	local old = assert(idFor(context))
	local creatures = s.root.MonsterVaultRuntime.Creatures
	for _, model in creatures:GetChildren() do
		if model:GetAttribute("CreatureInstanceId") == old then
			model:Destroy()
		end
	end
	tick(4)
	assert(s.worldRuntime.world().identity(old) == nil, "destroyed server projection retired")
	tick(12)
	local replacement = assert(idFor(context))
	assert(replacement ~= old, "destroyed entity replaced with fresh identity")
	local revision = s.worldRuntime.world().get(replacement).runtimeRevision
	s.clock.advanceWorld(181)
	tick(4)
	assert(s.worldRuntime.world().identity(replacement) == nil, "idle TTL despawn")
	assert(
		not s.worldRuntime.world().expireIfCurrent(replacement, revision),
		"stale expiry cannot revive"
	)
	tick(12)
	assert(idFor(context) ~= replacement, "idle refill fresh identity")
	-- A moved authoritative anchor is invalid until its original binding is restored.
	local anchor = s.authored.AdvancedEdgeAnchor
	local cf = anchor.CFrame
	local grove = assert(idFor("spawn-context/advanced-edge"))
	anchor.CFrame += globals.Vector3.new(2, 0, 0)
	tick(12)
	assert(
		s.worldRuntime.world().identity(grove) == nil,
		"invalid live content retires idle encounter"
	)
	assert(idFor("spawn-context/advanced-edge") == nil, "stale authoring fails closed")
	anchor.CFrame = cf
	tick(12)
	assert(idFor("spawn-context/advanced-edge") ~= nil, "restored valid binding")
	move(s.authored.AdvancedSecurePoint)
	return {
		passed = true,
		nativeCap = 8,
		destroyedReplaced = true,
		idleRefill = true,
		duplicateTickets = true,
		invalidBindingClosed = true,
		energy = s.session.snapshot().economy.energyUnits,
	}
end
local function release(): any
	local s = state()
	local pending = s.worldCallbacks[1]
	local world = s.worldRuntime.world()
	local resume = base.release()
	pending()
	assert(
		world.populationCount() == 0 and #s.worldCallbacks == 1,
		"stale shutdown callback cannot resurrect or schedule"
	)
	resume.expectedEnergy = 320
	return resume
end
local function captureFailure(mode: string): any
	assert(mode == "Before" or mode == "After", "supported DEV fault cut")
	base.setup(true)
	local s = state()
	move(s.authored.FixtureCreatureAnchor)
	local id = assert(idFor("spawn-context/fixture-clearing"))
	assert(
		s.captureRuntime.interact(s.player, id, "fault-claim") == "OK_CAPTURE_CLAIMED",
		"real fault capture claim"
	)
	local claim = s.captureStates[s.userId]
	local payload =
		{ captureSessionId = claim.captureSessionId, actionId = "capture", clientSequence = 1 }
	assert(
		s.captureRuntime.submit(s.player, payload, "fault-submit") == "OK_CAPTURE_PROVISIONAL",
		"real fault attempt"
	)
	s.setFault(mode)
	move(s.authored.FixtureSecurePoint)
	s.captureRuntime.secure(s.player)
	local deadline = os.clock() + 10
	repeat
		globals.task.wait(0.05)
	until s.session.state() == "PersistenceAtRisk"
		or s.captureRuntime.state(id) == "Secured"
		or os.clock() >= deadline
	assert(s.faultCuts[mode] > 0, "real repository fault cut exercised")
	local pending = s.captureRuntime.state(id) == "FinalizationPending"
	if pending then
		s.clock.advanceWorld(181)
		tick(4)
		assert(
			idFor("spawn-context/fixture-clearing") == id,
			"unknown P2 keeps reservation and identity past TTL"
		)
	end
	s.setFault(nil)
	deadline = os.clock() + 10
	repeat
		s.captureRuntime.reconcile(s.userId) -- Same recovery used by the central capture pulse at Risk.
		if s.captureRuntime.state(id) ~= "Secured" then
			globals.task.wait(0.05)
		end
	until s.captureRuntime.state(id) == "Secured" or os.clock() >= deadline
	assert(
		s.captureRuntime.resync(s.player, "fault-resync") == "OK_CAPTURE_RESYNC",
		"existing Class A recovery"
	)
	assert(s.session.snapshot().collection.creaturesById[id] ~= nil, "exact candidate recovered")
	local revision = s.session.snapshot().profileRevision
	s.captureRuntime.resync(s.player, "fault-duplicate")
	s.captureRuntime.submit(s.player, payload, "fault-submit-retry")
	assert(s.session.snapshot().profileRevision == revision, "no duplicate ownership write")
	tick(12)
	assert(
		idFor("spawn-context/fixture-clearing") ~= id and s.worldRuntime.world().identity(id) == nil,
		"one replacement after recovery only"
	)
	local saved = base.release()
	assert(
		saved.profile.collection.creaturesById[id] ~= nil and saved.profile.economy.energyUnits == 0,
		"native fault save owns exactly the original without reward"
	)
	return {
		passed = true,
		mode = mode,
		scope = saved.scope,
		creatureId = id,
		pendingObserved = pending,
		retryExact = true,
		replenished = true,
	}
end
local function rejoin(resume: any): any
	local probe: any = nil
	local result = base.rejoin(resume, function(runtime: any, session: any)
		local server: any = game.ServerScriptService.MonsterVaultServer
		local callbacks, mono = {}, 0
		local player = game:GetService("Players"):GetPlayers()[1]
		local root = globals.Instance.new("Folder")
		root.Name, root.Parent = "IMP10RejoinWorld", workspace
		local authored = workspace.MonsterVaultWorld:Clone()
		authored.Parent = root
		local cs = game:GetService("CollectionService")
		local world = require(server.bootstrap.WorldRuntimeService).new({
			workspace = root,
			players = game:GetService("Players"),
			collectionService = {
				GetTagged = function(_self: any, tag: string): any
					local items = {}
					for _, item in cs:GetTagged(tag) do
						if item:IsDescendantOf(authored) then
							table.insert(items, item)
						end
					end
					return items
				end,
				AddTag = function(_self: any, item: any, tag: string)
					cs:AddTag(item, tag)
				end,
			},
			httpService = game:GetService("HttpService"),
			diagnostics = { emit = function() end },
			worldProgression = runtime.worldProgression,
			worldActions = runtime.worldActions,
			profileCoordinator = runtime.coordinator,
			clock = function()
				return mono
			end,
			scheduler = {
				delay = function(_seconds: number, callback: () -> ())
					table.insert(callbacks, callback)
				end,
			},
		})
		player.Character.HumanoidRootPart.CFrame = authored.AdvancedFieldAnchor.CFrame
			+ globals.Vector3.new(0, 3, 0)
		world.start()
		for _ = 1, 4 do
			mono += 1
			assert(table.remove(callbacks, 1), "fresh runtime callback")()
		end
		local ids = {}
		for _, bucket in world.world().bucketStatus() do
			if bucket.creatureInstanceId then
				assert(
					session.snapshot().collection.creaturesById[bucket.creatureInstanceId] == nil,
					"fresh runtime identity distinct from durable ownership"
				)
				table.insert(ids, bucket.creatureInstanceId)
			end
		end
		assert(#ids == 3, "rejoined access activates two Advanced habitats plus protected fixture")
		probe = {
			freshIds = ids,
			energy = session.snapshot().economy.energyUnits,
			accessRestored = true,
		}
		world.stop()
		root:Destroy()
	end)
	result.spawn = probe
	return result
end
return {
	lockedAndStarter = lockedAndStarter,
	starterAndUnlocks = starterAndUnlocks,
	regionalMastery = regionalMastery,
	lifecycleAndCaps = lifecycleAndCaps,
	release = release,
	captureFailure = captureFailure,
	rejoin = rejoin,
}
