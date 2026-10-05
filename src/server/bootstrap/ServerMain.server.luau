--!strict

local HttpService = game:GetService("HttpService")
local ServerComposition = require(script.Parent.ServerComposition)
local ProfileBinding = require(script.Parent.ProfileBinding)
local ProfileRuntimeService = require(script.Parent.ProfileRuntimeService)
local NetworkingRuntimeService = require(script.Parent.NetworkingRuntimeService)
local WorldRuntimeService = require(script.Parent.WorldRuntimeService)
local CaptureRuntimeService = require(script.Parent.CaptureRuntimeService)
local PartyRuntimeService = require(script.Parent.PartyRuntimeService)

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
		local worldRuntime = WorldRuntimeService.new({
			workspace = game:GetService("Workspace"),
			collectionService = game:GetService("CollectionService"),
			players = game:GetService("Players"),
			httpService = HttpService,
			diagnostics = diagnostics,
			worldProgression = if profileRuntime then profileRuntime.worldProgression else nil,
			worldActions = if profileRuntime then profileRuntime.worldActions else nil,
			profileCoordinator = if profileRuntime then profileRuntime.coordinator else nil,
			event = remotes.Event,
		})
		table.insert(services, worldRuntime)
		local captureRuntime = nil
		if profileRuntime ~= nil then
			captureRuntime = CaptureRuntimeService.new({
				worldRuntime = worldRuntime,
				profileCoordinator = profileRuntime.coordinator,
				vault = profileRuntime.vault,
				progression = profileRuntime.progression,
				worldProgression = profileRuntime.worldProgression,
				players = game:GetService("Players"),
				workspace = game:GetService("Workspace"),
				event = remotes.Event,
				httpService = HttpService,
				diagnostics = diagnostics,
			})
			table.insert(services, captureRuntime)
		end
		local partyRuntime = nil
		if profileRuntime ~= nil then
			partyRuntime = PartyRuntimeService.new({
				production = profileRuntime.production,
				worldRuntime = worldRuntime,
				captureRuntime = captureRuntime,
				players = game:GetService("Players"),
				profileCoordinator = profileRuntime.coordinator,
				httpService = HttpService,
				event = remotes.Event,
			})
			table.insert(services, partyRuntime)
		end
		table.insert(
			services,
			NetworkingRuntimeService.new({
				command = remotes.Command,
				event = remotes.Event,
				unreliableEvent = remotes.UnreliableEvent,
				players = game:GetService("Players"),
				profileCoordinator = if profileRuntime then profileRuntime.coordinator else nil,
				captureRuntime = captureRuntime,
				worldRuntime = worldRuntime,
				partyRuntime = partyRuntime,
				worldActions = if profileRuntime then profileRuntime.worldActions else nil,
				vault = if profileRuntime then profileRuntime.vault else nil,
				capacity = if profileRuntime then profileRuntime.capacity else nil,
				production = if profileRuntime then profileRuntime.production else nil,
				assignments = if profileRuntime then profileRuntime.assignments else nil,
				energy = if profileRuntime then profileRuntime.energy else nil,
				claims = if profileRuntime then profileRuntime.claims else nil,
				progression = if profileRuntime then profileRuntime.progression else nil,
				purchases = if profileRuntime then profileRuntime.purchases else nil,
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
