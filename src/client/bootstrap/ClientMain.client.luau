--!strict

local HttpService = game:GetService("HttpService")
local ClientComposition = require(script.Parent.ClientComposition)
local NetworkingRuntimeService = require(script.Parent.NetworkingRuntimeService)
local WorldModelObserver = require(script.Parent.WorldModelObserver)

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
		return {
			NetworkingRuntimeService.new({
				command = remotes:WaitForChild("Command"),
				event = remotes:WaitForChild("Event"),
				unreliableEvent = remotes:WaitForChild("UnreliableEvent"),
				diagnostics = diagnostics,
			}),
			WorldModelObserver.new({
				collectionService = game:GetService("CollectionService"),
				diagnostics = diagnostics,
			}),
		}
	end,
})

composition.start()
