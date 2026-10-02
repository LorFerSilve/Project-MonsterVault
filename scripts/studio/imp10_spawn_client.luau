--!strict

-- Native client boundary probe. Engine eviction is recorded separately from the
-- deterministic projection-loss simulation; neither can retire a server entity.
local globals = getfenv() :: any
local observer: any = nil
local target: any = nil
local identity: any = nil
local function begin(): any
	assert(
		game:GetService("RunService"):IsStudio() and game:GetService("RunService"):IsClient(),
		"native Studio client"
	)
	local player = game:GetService("Players").LocalPlayer
	local client: any = player.PlayerScripts.MonsterVaultClient
	observer = require(client.bootstrap.WorldModelObserver).new({
		collectionService = game:GetService("CollectionService"),
		diagnostics = { emit = function() end },
	})
	observer.start()
	player:RequestStreamAroundAsync(globals.Vector3.new(0, 3, -248), 3)
	for _, model in game:GetService("CollectionService"):GetTagged("MonsterVaultWorldCreature") do
		if
			model:GetAttribute("SpawnContextId") == "spawn-context/advanced"
			and model:IsDescendantOf(workspace.IMP10ProbeWorld)
		then
			target = model
		end
	end
	assert(target ~= nil, "streamed authored encounter")
	identity = target:GetAttribute("CreatureInstanceId")
	assert(observer.store.view(identity).present, "native observer stream-in")
	return {
		creatureInstanceId = identity,
		streamingEnabled = workspace.StreamingEnabled,
		streamIn = true,
	}
end
local function eviction(): any
	local deadline = os.clock() + 12
	repeat
		globals.task.wait(0.1)
	until not observer.store.view(identity).present or os.clock() >= deadline
	return {
		creatureInstanceId = identity,
		engineEvicted = not observer.store.view(identity).present,
	}
end
local function restoreAndTamper(): any
	local player = game:GetService("Players").LocalPlayer
	player:RequestStreamAroundAsync(globals.Vector3.new(0, 3, -248), 3)
	local deadline = os.clock() + 5
	repeat
		globals.task.wait(0.1)
	until observer.store.view(identity).present or os.clock() >= deadline
	assert(observer.store.view(identity).present, "observer restored same server identity")
	for _, model in game:GetService("CollectionService"):GetTagged("MonsterVaultWorldCreature") do
		if model:GetAttribute("CreatureInstanceId") == identity then
			target = model
		end
	end
	local parent, species = target.Parent, target:GetAttribute("SpeciesId")
	target:SetAttribute("SpeciesId", "species/client-invented")
	target.Parent = nil
	globals.task.wait(0.1)
	assert(not observer.store.view(identity).present, "local projection loss")
	target:SetAttribute("SpeciesId", species)
	target.Parent = parent
	globals.task.wait(0.1)
	assert(observer.store.view(identity).present, "local projection restoration")
	local remotes: any = game.ReplicatedStorage.IMP10WorldProbe
	local replies: any = {}
	local connection = remotes.Event.OnClientEvent:Connect(function(packet: any)
		if packet.routeId == "Command.Result" then
			replies[packet.correlationId] = packet.payload.code
		end
	end)
	local id = game:GetService("HttpService"):GenerateGUID(false)
	remotes.Command:FireServer({
		protocolVersion = 1,
		routeId = "Interaction.PrimaryInteract",
		requestId = id,
		payload = {
			interactionId = identity,
			speciesId = "species/client-invented",
			rarityId = "rarity/legendary",
			spawnContextId = "spawn-context/advanced",
			position = { x = 0, y = 3, z = -248 },
		},
	})
	deadline = os.clock() + 5
	repeat
		globals.task.wait(0.05)
	until replies[id] ~= nil or os.clock() >= deadline
	connection:Disconnect()
	assert(
		replies[id] == "REJECT_VALIDATION_PAYLOAD",
		"client selection/rarity/identity/position tampering rejected"
	)
	observer.stop()
	return {
		passed = true,
		sameIdentity = identity,
		engineRestored = true,
		simulatedLossRestored = true,
		tampering = replies[id],
	}
end
return { begin = begin, eviction = eviction, restoreAndTamper = restoreAndTamper }
