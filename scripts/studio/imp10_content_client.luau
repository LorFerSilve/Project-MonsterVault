--!strict

-- Native client projection-loss/readback probe; no client world state is trusted.
return function(): any
	local globals = getfenv() :: any
	assert(
		game:GetService("RunService"):IsStudio() and game:GetService("RunService"):IsClient(),
		"native client required"
	)
	local player = game:GetService("Players").LocalPlayer
	local remotes: any = game.ReplicatedStorage.IMP10WorldProbe
	local target: any = workspace.IMP10ProbeWorld.MonsterVaultWorld.AdvancedSecurePoint
	local parent = target.Parent
	local requestResults: any = {}
	local world: any = nil
	local connection = remotes.Event.OnClientEvent:Connect(function(packet: any)
		if packet.routeId == "Command.Result" then
			requestResults[packet.correlationId] = packet.payload.code
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
		until requestResults[id] or os.clock() >= deadline
		return requestResults[id] or "MISSING_REPLY"
	end
	local streamOK = pcall(function()
		player:RequestStreamAroundAsync(target.Position, 3)
	end)
	-- Local absence models an evicted projection. Server authoring/permission must survive.
	target.Parent = nil
	local duplicate =
		send("Interaction.PrimaryInteract", { interactionId = "landmark/advanced-entry" })
	local tamper = send("Interaction.PrimaryInteract", {
		interactionId = "landmark/advanced-entry",
		mastery = true,
		regionId = "region/biome-advanced",
	})
	local resync = send("Session.RequestResync", { domain = "world" })
	target.Parent = parent
	connection:Disconnect()
	assert(
		duplicate == "OK_WORLD_VISITED" and tamper == "REJECT_VALIDATION_PAYLOAD",
		"projection absence cannot grant/revoke world authority"
	)
	assert(
		resync == "OK_WORLD_RECONCILED" and world ~= nil and #world.masteryMilestoneIds == 4,
		"actual owner mastery readback"
	)
	return {
		passed = true,
		streamingEnabled = workspace.StreamingEnabled,
		engineStreamRequest = streamOK,
		simulatedProjectionLoss = true,
		projectionRestored = target.Parent == parent,
		duplicate = duplicate,
		tamper = tamper,
		world = world,
	}
end
