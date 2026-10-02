--!strict

local globals = getfenv() :: any
local function run(): any
	assert(
		game:GetService("RunService"):IsStudio() and game:GetService("RunService"):IsClient(),
		"native Studio client"
	)
	local player = game:GetService("Players").LocalPlayer
	local remotes: any = game.ReplicatedStorage.IMP10WorldProbe
	local results, world = {}, nil
	local listener = remotes.Event.OnClientEvent:Connect(function(packet: any)
		if packet.routeId == "Command.Result" then
			results[packet.correlationId] = packet.payload.code
		end
		if packet.routeId == "World.StateChanged" then
			world = packet.payload
		end
	end)
	local function send(route: string, payload: any): string
		local id = game:GetService("HttpService"):GenerateGUID(false)
		remotes.Command:FireServer({
			protocolVersion = 1,
			routeId = route,
			requestId = id,
			payload = payload,
		})
		local deadline = os.clock() + 5
		repeat
			globals.task.wait(0.05)
		until results[id] or os.clock() >= deadline
		return assert(results[id], "actual command result")
	end
	assert(
		send("Session.RequestResync", { domain = "world" }) == "OK_WORLD_RECONCILED",
		"owner readback"
	)
	local projection: any = assert(world, "owner public world state")
	assert(
		#projection.discoveredTravelNodeIds == 5 and #projection.masteryMilestoneIds == 4,
		"bounded public IDs"
	)
	assert(
		projection.travelNodes == nil and projection.operationId == nil,
		"private proofs excluded"
	)
	assert(
		game.ServerScriptService:FindFirstChild("MonsterVaultServer") == nil,
		"no client travel owner"
	)
	local hint = player:GetAttribute("MonsterVaultCharacterGeneration")
	player:SetAttribute("MonsterVaultCharacterGeneration", 999999)
	assert(
		send(
			"World.RequestFastTravel",
			{ nodeId = "travel-node/home-hub", characterGeneration = 999999 }
		) == "REJECT_STATE_TRAVEL_STALE",
		"client generation has no authority"
	)
	assert(send("World.RequestFastTravel", {
		nodeId = "travel-node/home-hub",
		characterGeneration = projection.characterGeneration,
		position = { x = 0, y = 3, z = 128 },
		unlocked = true,
		discovery = true,
	}) == "REJECT_VALIDATION_PAYLOAD", "position/unlock/discovery tampering")
	assert(send("World.RequestFastTravel", {
		nodeId = "travel-node/client-forged",
		characterGeneration = projection.characterGeneration,
	}) == "REJECT_STATE_TRAVEL_DESTINATION", "forged destination")
	assert(send("World.RequestFastTravel", {
		nodeId = "travel-node/home-hub",
		characterGeneration = projection.characterGeneration,
	}) == "OK_WORLD_TRAVELLED", "real client valid travel")
	player:SetAttribute("MonsterVaultCharacterGeneration", hint)
	listener:Disconnect()
	return {
		passed = true,
		realRemoteTravel = true,
		privateOwnerAbsent = true,
		readOnlyProjection = true,
		strictPayload = true,
		staleGeneration = true,
		forgedDestination = true,
		generation = projection.characterGeneration,
	}
end
local function race(): any
	local player = game:GetService("Players").LocalPlayer
	local remotes: any = game.ReplicatedStorage.IMP10WorldProbe
	local replies = {}
	local connection = remotes.Event.OnClientEvent:Connect(function(packet: any)
		if packet.routeId == "Command.Result" then
			replies[packet.correlationId] = packet.payload.code
		end
	end)
	local a, b =
		game:GetService("HttpService"):GenerateGUID(false),
		game:GetService("HttpService"):GenerateGUID(false)
	for _, id in { a, b } do
		remotes.Command:FireServer({
			protocolVersion = 1,
			routeId = "World.RequestFastTravel",
			requestId = id,
			payload = {
				nodeId = "travel-node/starter",
				characterGeneration = player:GetAttribute("MonsterVaultCharacterGeneration"),
			},
		})
	end
	local deadline = os.clock() + 5
	repeat
		globals.task.wait(0.05)
	until (replies[a] and replies[b]) or os.clock() >= deadline
	connection:Disconnect()
	local successes = (if replies[a] == "OK_WORLD_TRAVELLED" then 1 else 0)
		+ (if replies[b] == "OK_WORLD_TRAVELLED" then 1 else 0)
	assert(successes == 1, "two real client intents yield one relocation")
	return { passed = true, first = replies[a], second = replies[b], successCount = successes }
end
return { run = run, race = race }
