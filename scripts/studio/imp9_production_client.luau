--!strict

local globals = getfenv() :: any
local state: any = nil
local function setup(): any
	assert(
		state == nil
			and game:GetService("RunService"):IsStudio()
			and game:GetService("RunService"):IsClient(),
		"Studio client probe"
	)
	local root = game:GetService("ReplicatedStorage"):WaitForChild("IMP9ProductionProbeRemotes")
	local client: any = game:GetService("Players").LocalPlayer.PlayerScripts.MonsterVaultClient
	local player, gui = game:GetService("Players").LocalPlayer, game:GetService("GuiService")
	local hidden = {}
	for _, screen in player.PlayerGui:GetChildren() do
		if screen:IsA("ScreenGui") and string.sub(screen.Name, 1, 12) == "MonsterVault" then
			hidden[screen] = screen.Enabled
			screen.Enabled = false
		end
	end
	local networking = require(client.bootstrap.NetworkingRuntimeService).new({
		command = root.Command,
		event = root.Event,
		unreliableEvent = root.UnreliableEvent,
		diagnostics = { emit = function() end },
	})
	local runtime = require(client.bootstrap.VaultAssignmentRuntimeService).new({
		networking = networking,
		player = player,
		guiService = gui,
	})
	networking.start()
	runtime.start()
	for _, screen in player.PlayerGui:GetChildren() do
		if screen.Name == "MonsterVaultAssignments" and hidden[screen] == nil then
			screen.Name = "IMP9ProductionAssignments"
		end
	end
	state = { networking = networking, runtime = runtime, hidden = hidden, root = root, serial = 0 }
	return { guiName = "IMP9ProductionAssignments" }
end
local function negative(id: string, held: string): any
	assert(state ~= nil, "client probe setup")
	local session = state.networking.store.view()
	local revision = session.profileRevision
	local function send(payload: any, expected: number?): string
		state.serial += 1
		local request = "probe-negative-" .. state.serial
		state.root.Command:FireServer({
			protocolVersion = 1,
			routeId = "Vault.SetProductionAssignment",
			requestId = request,
			expectedRevision = expected or revision,
			payload = payload,
		})
		globals.task.wait(1.1)
		return state.networking.gateway.resultFor(request)
	end
	local results = {
		foreign = send({ slotId = "production/2", creatureInstanceId = "foreign-creature" }),
		duplicate = send({ slotId = "production/2", creatureInstanceId = id }),
		held = send({ slotId = "production/2", creatureInstanceId = held }),
		stale = send({ slotId = "production/2", creatureInstanceId = id }, revision - 1),
		clockSpoof = send({
			slotId = "production/2",
			creatureInstanceId = id,
			now = 9_999_999_999,
			rate = 1_000_000,
			ownerUserId = 1,
		}),
	}
	assert(
		results.foreign == "REJECT_PERMISSION_VAULT_OWNERSHIP"
			and results.duplicate == "REJECT_STATE_VAULT_ALREADY_ASSIGNED"
			and results.held == "REJECT_STATE_VAULT_OVERFLOW_HELD"
			and results.stale == "REJECT_STATE_VAULT_STALE_REVISION"
			and results.clockSpoof == "REJECT_VALIDATION_PAYLOAD",
		"real client gateway rejects hostile assignments"
	)
	return results
end
local function finish(): any
	if state == nil then
		return {}
	end
	state.runtime.stop()
	state.networking.stop()
	for screen, enabled in state.hidden do
		if screen.Parent then
			screen.Enabled = enabled
		end
	end
	state = nil
	return { restored = true }
end
return { setup = setup, negative = negative, finish = finish }
