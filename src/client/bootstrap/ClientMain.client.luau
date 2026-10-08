--!strict

local HttpService = game:GetService("HttpService")
local ClientComposition = require(script.Parent.ClientComposition)
local NetworkingRuntimeService = require(script.Parent.NetworkingRuntimeService)
local WorldModelObserver = require(script.Parent.WorldModelObserver)
local CaptureRuntimeService = require(script.Parent.CaptureRuntimeService)
local VaultRuntimeService = require(script.Parent.VaultRuntimeService)
local VaultAssignmentRuntimeService = require(script.Parent.VaultAssignmentRuntimeService)
local ProgressionRuntimeService = require(script.Parent.ProgressionRuntimeService)
local PartyRuntimeService = require(script.Parent.PartyRuntimeService)
local GoldenRuntimeService = require(script.Parent.GoldenRuntimeService)
local GoldenTheme = require(script.Parent.Parent.presentation.GoldenTheme)
local ShowcaseRuntimeService = require(script.Parent.ShowcaseRuntimeService)

local composition = ClientComposition.new({
	sink = function(record)
		print(HttpService:JSONEncode(record))
	end,
	unixSeconds = os.time,
	buildServices = function(diagnostics)
		local remotes = game:GetService("ReplicatedStorage")
			:WaitForChild("MonsterVault")
			:WaitForChild("Remotes")
			:WaitForChild("V1")
		local networking = NetworkingRuntimeService.new({
			command = remotes:WaitForChild("Command"),
			event = remotes:WaitForChild("Event"),
			unreliableEvent = remotes:WaitForChild("UnreliableEvent"),
			diagnostics = diagnostics,
		})
		local world = WorldModelObserver.new({
			collectionService = game:GetService("CollectionService"),
			diagnostics = diagnostics,
		})
		local player = game:GetService("Players").LocalPlayer
		local social = PartyRuntimeService.new({
			networking = networking,
			player = player,
			presentation = GoldenTheme,
		})
		local showcase = ShowcaseRuntimeService.new({ networking = networking, player = player })
		local progression = ProgressionRuntimeService.new({
			networking = networking,
			player = player,
			guiService = game:GetService("GuiService"),
		})
		local assignments = VaultAssignmentRuntimeService.new({
			networking = networking,
			player = player,
			guiService = game:GetService("GuiService"),
		})
		local vault = VaultRuntimeService.new({
			networking = networking,
			player = player,
			guiService = game:GetService("GuiService"),
			golden = true,
		})
		local golden = GoldenRuntimeService.new({
			networking = networking,
			worldObserver = world,
			player = player,
			assignments = assignments,
			progression = progression,
			vault = vault,
			social = social,
			showcase = showcase,
		})
		return {
			social,
			showcase,
			progression,
			assignments,
			vault,
			networking,
			world,
			golden,
			CaptureRuntimeService.new({
				networking = networking,
				worldObserver = world,
				player = game:GetService("Players").LocalPlayer,
				userInputService = game:GetService("UserInputService"),
				guiService = game:GetService("GuiService"),
				onPresentation = golden.capture,
			}),
		}
	end,
})

composition.start()
