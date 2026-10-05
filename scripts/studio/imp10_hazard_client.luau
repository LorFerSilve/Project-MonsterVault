--!strict

-- Native streaming and actual remote boundary; no client authority is supplied.
local globals = getfenv() :: any
local hazard: any = nil
local marker: any = nil
local generation: number? = nil
local function find(): any
	local root = workspace:FindFirstChild("IMP10ProbeWorld")
	local authored = if root then root:FindFirstChild("MonsterVaultWorld") else nil
	return if authored then authored:FindFirstChild("StarterCorrosiveHazard") else nil
end
local function begin(): any
	assert(game:GetService("RunService"):IsClient(), "native client required")
	game:GetService("Players").LocalPlayer
		:RequestStreamAroundAsync(globals.Vector3.new(44, 3, 36), 3)
	hazard = assert(find(), "authored hazard streamed in")
	marker = assert(hazard:FindFirstChild("Marker"), "visible marker streamed in")
	assert(
		hazard.Warning.Text.Text:find("Carried capture is interrupted", 1, true),
		"visible consequence warning"
	)
	return { streamIn = true, streamingEnabled = workspace.StreamingEnabled }
end
local function eviction(): any
	local deadline = os.clock() + 12
	repeat
		globals.task.wait(0.1)
	until find() == nil or os.clock() >= deadline
	assert(find() == nil, "actual engine hazard stream-out required")
	return { engineEvicted = true }
end
local function tamper(): any
	begin()
	local player = game:GetService("Players").LocalPlayer
	generation = player:GetAttribute("MonsterVaultCharacterGeneration")
	hazard:SetAttribute("HazardId", "hazard/client-safe")
	hazard:SetAttribute("RegionId", "region/biome-advanced")
	marker.Parent = nil
	player:SetAttribute("MonsterVaultCharacterGeneration", 999999)
	return { engineRestored = true, localMarkerHidden = true, localMetadataForged = true }
end
local function requests(): any
	local remotes: any = game.ReplicatedStorage.IMP10WorldProbe
	local replies = {}
	local connection = remotes.Event.OnClientEvent:Connect(function(packet: any)
		if packet.routeId == "Command.Result" then
			replies[packet.correlationId] = packet.payload.code
		end
	end)
	local function send(payload: any): string
		local id = game:GetService("HttpService"):GenerateGUID(false)
		remotes.Command:FireServer({
			protocolVersion = 1,
			routeId = "World.RequestFastTravel",
			requestId = id,
			payload = payload,
		})
		local deadline = os.clock() + 5
		repeat
			globals.task.wait(0.05)
		until replies[id] or os.clock() >= deadline
		return assert(replies[id], "actual hazard command response")
	end
	local stale = send({ nodeId = "travel-node/home-hub", characterGeneration = 999999 })
	assert(stale == "REJECT_STATE_TRAVEL_STALE", "forged generation authority")
	local forged = send({
		nodeId = "travel-node/home-hub",
		characterGeneration = generation,
		position = { x = 0, y = 3, z = 128 },
		hazardId = false,
		unlocked = true,
	})
	assert(forged == "REJECT_VALIDATION_PAYLOAD", "forged position/state accepted")
	local context = send({ nodeId = "travel-node/home-hub", characterGeneration = generation })
	assert(
		context == "REJECT_STATE_TRAVEL_CONTEXT",
		"hidden client hazard bypassed server presence"
	)
	connection:Disconnect()
	return {
		passed = true,
		stale = stale,
		forged = forged,
		context = context,
		serverOwnerPrivate = game.ServerScriptService:FindFirstChild("MonsterVaultServer") == nil,
	}
end
return { begin = begin, eviction = eviction, tamper = tamper, requests = requests }
