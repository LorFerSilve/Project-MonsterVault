--!strict

local HttpService = game:GetService("HttpService")
local ServerComposition = require(script.Parent.ServerComposition)
local ProfileBinding = require(script.Parent.ProfileBinding)
local ProfileRuntimeService = require(script.Parent.ProfileRuntimeService)
local NetworkingRuntimeService = require(script.Parent.NetworkingRuntimeService)

local composition = ServerComposition.new({
	sink = function(record)
		print(HttpService:JSONEncode(record))
	end,
	unixSeconds = os.time,
	monotonicSeconds = os.clock,
	buildServices = function(diagnostics)
		local services: { any } = {}
		local profileRuntime = nil
		if ProfileBinding.environment ~= nil then
			local declaredUniverseId = ProfileBinding.declaredUniverseId
			assert(declaredUniverseId ~= nil, "profile universe binding required")
			profileRuntime = ProfileRuntimeService.new({
				environment = ProfileBinding.environment,
				declaredUniverseId = declaredUniverseId,
				dataStoreService = game:GetService("DataStoreService"),
				players = game:GetService("Players"),
				runService = game:GetService("RunService"),
				httpService = HttpService,
				gameUniverseId = game.GameId,
				gameJobId = game.JobId,
				diagnostics = diagnostics,
			})
			table.insert(services, profileRuntime)
		end
		local remotes = game:GetService("ReplicatedStorage").MonsterVault.Remotes.V1
		table.insert(
			services,
			NetworkingRuntimeService.new({
				command = remotes.Command,
				event = remotes.Event,
				unreliableEvent = remotes.UnreliableEvent,
				players = game:GetService("Players"),
				profileCoordinator = if profileRuntime then profileRuntime.coordinator else nil,
				diagnostics = diagnostics,
			})
		)
		return services
	end,
})

composition.start()
game:BindToClose(function()
	composition.shutdown(25)
end)
