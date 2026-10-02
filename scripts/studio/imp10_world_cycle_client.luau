--!strict

-- Native client evidence; delegates the actual streaming observer to its existing probe.
local globals = getfenv() :: any
local scripts: any = game:GetService("Players").LocalPlayer.PlayerScripts
local stream: any = globals.require(scripts.IMP10SpawnClientProbe)
local originalEligibility: any = nil
local function tamperReadback(): any
	local root = workspace.IMP10ProbeWorld.MonsterVaultRuntime
	local phase = root:GetAttribute("WorldCyclePhaseId")
	assert(phase == "world-phase/day", "native cycle readback before eviction")
	originalEligibility = root:GetAttribute("EligibleSpawnContextIds")
	assert(#string.split(originalEligibility, ",") == 8, "native phase eligibility readback")
	root:SetAttribute("WorldCyclePhaseId", "world-phase/client-fake")
	root:SetAttribute("EligibleSpawnContextIds", "spawn-context/client-fake")
	local remotes: any = game.ReplicatedStorage.IMP10WorldProbe
	local result: any = nil
	local requestId = game:GetService("HttpService"):GenerateGUID(false)
	local connection = remotes.Event.OnClientEvent:Connect(function(packet: any)
		if packet.correlationId == requestId and packet.routeId == "Command.Result" then
			result = packet.payload.code
		end
	end)
	remotes.Command:FireServer({
		protocolVersion = 1,
		routeId = "Interaction.PrimaryInteract",
		requestId = requestId,
		payload = {
			interactionId = "landmark/advanced-field",
			phaseId = "world-phase/day",
			cycleIndex = 0,
			eligible = true,
			unixSeconds = 0,
		},
	})
	local deadline = os.clock() + 5
	repeat
		globals.task.wait(0.05)
	until result ~= nil or os.clock() >= deadline
	connection:Disconnect()
	assert(result == "REJECT_VALIDATION_PAYLOAD", "client cycle/eligibility authority rejected")
	assert(
		game.ServerScriptService:FindFirstChild("MonsterVaultServer") == nil,
		"clock/config owner server-only"
	)
	return {
		passed = true,
		beforePhase = phase,
		forgedAttributesAreLocal = true,
		result = result,
		serverOwnerHidden = true,
	}
end
local function restoredCycle(): any
	local root = workspace.IMP10ProbeWorld.MonsterVaultRuntime
	assert(
		root:GetAttribute("WorldCyclePhaseId") == "world-phase/dusk"
			and root:GetAttribute("WorldCycleIndex") == 1,
		"server phase restored after real stream-in"
	)
	-- Local tampering can mask an unchanged replicated value. Server eligibility
	-- was checked separately; restore this client-only mutation for clean teardown.
	root:SetAttribute("EligibleSpawnContextIds", originalEligibility)
	return {
		passed = true,
		phase = root:GetAttribute("WorldCyclePhaseId"),
		index = root:GetAttribute("WorldCycleIndex"),
	}
end
return {
	begin = stream.begin,
	eviction = stream.eviction,
	restoreAndTamper = stream.restoreAndTamper,
	tamperReadback = tamperReadback,
	restoredCycle = restoredCycle,
}
