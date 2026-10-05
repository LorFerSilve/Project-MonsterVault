--!strict

-- Actual RemoteEvent boundary; no reward fields have an accepted wire route.
local globals = getfenv() :: any
local function survey(id: string, forged: boolean?): any
	local remotes: any = game.ReplicatedStorage:WaitForChild("IMP10RewardProbe")
	local replies = {}
	local connection = remotes.Event.OnClientEvent:Connect(function(packet: any)
		if packet.routeId == "Command.Result" then
			replies[packet.correlationId] = packet.payload.code
		end
	end)
	local function send(payload: any, requestId: string?, route: string?): string
		local op = requestId or game:GetService("HttpService"):GenerateGUID(false)
		remotes.Command:FireServer({
			protocolVersion = 1,
			routeId = route or "Interaction.PrimaryInteract",
			requestId = op,
			payload = payload,
		})
		local deadline = os.clock() + 10
		repeat
			globals.task.wait(0.05)
		until replies[op] or os.clock() >= deadline
		return assert(replies[op], "actual survey command result")
	end
	local rejected: any = nil
	if forged then
		rejected = send({
			interactionId = id,
			energyUnits = 999999,
			sourceId = "world-reward/forged",
			operationId = "client-op",
			completed = true,
			eligible = true,
			position = { x = 0, y = 3, z = 10 },
		})
		assert(rejected == "REJECT_VALIDATION_PAYLOAD", "client reward fields authorized")
		local unknown =
			send({ sourceId = "world-reward/forged", amount = 999999 }, nil, "World.ClaimReward")
		assert(unknown == "REJECT_VALIDATION_ROUTE", "invented reward remote")
	end
	local requestId = game:GetService("HttpService"):GenerateGUID(false)
	local first = send({ interactionId = id }, requestId)
	assert(first == "OK_WORLD_VISITED", first)
	replies[requestId] = nil
	local replay = send({ interactionId = id }, requestId)
	assert(replay == "OK_WORLD_VISITED", replay)
	local repeated = send({ interactionId = id })
	assert(repeated == "OK_WORLD_VISITED", repeated)
	connection:Disconnect()
	return {
		passed = true,
		actualRemote = true,
		first = first,
		replay = replay,
		repeated = repeated,
		forged = rejected,
		serverOwnerPrivate = game.ServerScriptService:FindFirstChild("MonsterVaultServer") == nil,
	}
end
local function streamIn(): any
	game:GetService("Players").LocalPlayer
		:RequestStreamAroundAsync(globals.Vector3.new(0, 3, 10), 5)
	local root = assert(workspace:FindFirstChild("IMP10RewardWorld"))
	local authored = assert(root:FindFirstChild("MonsterVaultWorld"))
	assert(authored:FindFirstChild("FixtureSecurePoint"), "actual objective streamed in")
	return { streamingEnabled = workspace.StreamingEnabled, objectiveVisible = true }
end
local function streamOut(): any
	local deadline = os.clock() + 20
	local function present(): boolean
		local root = workspace:FindFirstChild("IMP10RewardWorld")
		local authored = if root then root:FindFirstChild("MonsterVaultWorld") else nil
		return authored ~= nil and authored:FindFirstChild("FixtureSecurePoint") ~= nil
	end
	repeat
		globals.task.wait(0.1)
	until not present() or os.clock() >= deadline
	assert(not present(), "actual engine objective eviction required")
	return { actualEngineEvicted = true }
end
local function tamper(): any
	streamIn()
	local part = workspace.IMP10RewardWorld.MonsterVaultWorld.FixtureSecurePoint
	part:SetAttribute("LandmarkId", "landmark/client-completed")
	part:SetAttribute("RewardAmount", 999999)
	game:GetService("Players").LocalPlayer:SetAttribute("MonsterVaultCharacterGeneration", 999999)
	return { localMetadataForged = true, localGenerationForged = true }
end
return { survey = survey, streamIn = streamIn, streamOut = streamOut, tamper = tamper }
