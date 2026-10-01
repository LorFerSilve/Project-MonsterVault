--!strict

local HttpService = game:GetService("HttpService")
local ClientComposition = require(script.Parent.ClientComposition)
local NetworkingRuntimeService = require(script.Parent.NetworkingRuntimeService)
local WorldModelObserver = require(script.Parent.WorldModelObserver)
local CaptureRuntimeService = require(script.Parent.CaptureRuntimeService)
local VaultRuntimeService = require(script.Parent.VaultRuntimeService)
local VaultAssignmentRuntimeService = require(script.Parent.VaultAssignmentRuntimeService)

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
		return {
			VaultAssignmentRuntimeService.new({
				networking = networking,
				player = game:GetService("Players").LocalPlayer,
				guiService = game:GetService("GuiService"),
			}),
			VaultRuntimeService.new({
				networking = networking,
				player = game:GetService("Players").LocalPlayer,
				guiService = game:GetService("GuiService"),
			}),
			networking,
			world,
			CaptureRuntimeService.new({
				networking = networking,
				worldObserver = world,
				player = game:GetService("Players").LocalPlayer,
				userInputService = game:GetService("UserInputService"),
				guiService = game:GetService("GuiService"),
			}),
		}
	end,
})

composition.start()
