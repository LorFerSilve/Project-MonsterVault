--!strict

local HttpService = game:GetService("HttpService")
local ServerComposition = require(script.Parent.ServerComposition)
local ProfileBinding = require(script.Parent.ProfileBinding)
local ProfileRuntimeService = require(script.Parent.ProfileRuntimeService)

local composition = ServerComposition.new({
	sink = function(record)
		print(HttpService:JSONEncode(record))
	end,
	unixSeconds = os.time,
	monotonicSeconds = os.clock,
	buildServices = function(diagnostics)
		if ProfileBinding.environment == nil then
			return {}
		end
		local declaredUniverseId = ProfileBinding.declaredUniverseId
		assert(declaredUniverseId ~= nil, "profile universe binding required")
		return {
			ProfileRuntimeService.new({
				environment = ProfileBinding.environment,
				declaredUniverseId = declaredUniverseId,
				dataStoreService = game:GetService("DataStoreService"),
				players = game:GetService("Players"),
				runService = game:GetService("RunService"),
				httpService = HttpService,
				gameUniverseId = game.GameId,
				gameJobId = game.JobId,
				diagnostics = diagnostics,
			}),
		}
	end,
})

composition.start()
game:BindToClose(function()
	composition.shutdown(25)
end)
