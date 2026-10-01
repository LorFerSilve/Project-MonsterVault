--!strict

-- Temporary real-client probe. Input still uses native mouse/gamepad tools.
local state: any = nil
local function setup(): any
	assert(
		game:GetService("RunService"):IsStudio() and game:GetService("RunService"):IsClient(),
		"Studio client only"
	)
	assert(state == nil, "probe already running")
	local player = game:GetService("Players").LocalPlayer
	local gui = player:WaitForChild("PlayerGui")
	local normal = gui:FindFirstChild("MonsterVaultOverflow")
	if normal then
		normal.Name = "MonsterVaultOverflowNormalProbe"
		normal.Enabled = false
	end
	local modules = player.PlayerScripts.MonsterVaultClient.bootstrap
	local remotes = game:GetService("ReplicatedStorage"):WaitForChild("IMP9CapacityProbeRemotes")
	local events = {}
	local observer = remotes.Event.OnClientEvent:Connect(function(e)
		table.insert(events, e)
	end)
	local networking = require(modules.NetworkingRuntimeService).new({
		command = remotes.Command,
		event = remotes.Event,
		unreliableEvent = remotes.UnreliableEvent,
		diagnostics = {
			emit = function(...)
				print("IMP9_CLIENT_DIAGNOSTIC", ...)
			end,
		},
	})
	local vault = require(modules.VaultRuntimeService).new({
		networking = networking,
		player = player,
		guiService = game:GetService("GuiService"),
	})
	state = {
		networking = networking,
		vault = vault,
		events = events,
		observer = observer,
		normal = normal,
	}
	networking.start()
	vault.start()
	return true
end
local function results(): any
	assert(state ~= nil, "probe not started")
	local panel = game:GetService("Players").LocalPlayer.PlayerGui.MonsterVaultOverflow.Panel
	return {
		events = state.events,
		heading = panel.Heading.Text,
		message = panel.Message.Text,
		row = panel.Creature1.Text,
		resolveActive = panel.Resolve.Active,
		resolveVisible = panel.Resolve.Visible,
	}
end
local function stop(): any
	assert(state ~= nil, "probe not started")
	local result = results()
	state.vault.stop()
	state.networking.stop()
	state.observer:Disconnect()
	if state.normal then
		state.normal.Name = "MonsterVaultOverflow"
		state.normal.Enabled = true
	end
	state = nil
	return result
end
return {
	setup = setup,
	results = results,
	stop = stop,
	networking = function()
		assert(state ~= nil, "probe not started")
		return state.networking
	end,
}
