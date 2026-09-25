--!strict

local shared = game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts
local ProtocolV1 = require(shared.ProtocolV1)
local RouteIds = require(shared.RouteIds)
local ResultCodes = require(shared.ResultCodes)
local WireValidation = require(shared.WireValidation)
local ProjectionV1 = require(shared.ProjectionV1)
local RouteRegistry = require(script.Parent.Parent.application.RouteRegistry)
local NetworkRateLimiter = require(script.Parent.Parent.application.NetworkRateLimiter)
local ReplayWindow = require(script.Parent.Parent.application.ReplayWindow)
local ProjectionPublisher = require(script.Parent.Parent.application.ProjectionPublisher)
local NetworkingGateway = require(script.Parent.Parent.application.NetworkingGateway)

local NetworkingRuntimeService = {}

function NetworkingRuntimeService.new(options: {
	command: any,
	event: any,
	unreliableEvent: any,
	players: any,
	profileCoordinator: any?,
	diagnostics: any,
})
	local function getSession(player: any): any
		if options.profileCoordinator == nil then
			return { status = "Protected" }
		end
		local session = options.profileCoordinator.get(player.UserId)
		if session == nil then
			return { status = "Loading" }
		end
		local status = session.state()
		if status == "Ready" then
			local snapshot = session.snapshot()
			if type(snapshot) == "table" and type(snapshot.profileRevision) == "number" then
				return { status = "Ready", profileRevision = snapshot.profileRevision }
			end
		end
		if status == "Acquiring" then
			return { status = "Loading" }
		end
		return { status = "Protected" }
	end

	local projection = ProjectionPublisher.new({
		protocol = ProtocolV1,
		routes = RouteIds,
		projection = ProjectionV1,
		wire = WireValidation,
		emit = function(player, envelope)
			options.event:FireClient(player, envelope)
		end,
	})
	local gateway = NetworkingGateway.new({
		protocol = ProtocolV1,
		routes = RouteIds,
		resultCodes = ResultCodes,
		wire = WireValidation,
		registry = RouteRegistry.new(RouteIds),
		rate = NetworkRateLimiter.new(os.clock),
		replay = ReplayWindow.new(os.clock, WireValidation),
		projection = projection,
		getSession = getSession,
		emitReliable = function(player, envelope)
			options.event:FireClient(player, envelope)
		end,
		emitUnreliable = function(player, envelope)
			options.unreliableEvent:FireClient(player, envelope)
		end,
	})
	local connections = {}

	local function start()
		assert(options.command:IsA("RemoteEvent"), "invalid command remote")
		assert(options.event:IsA("RemoteEvent"), "invalid event remote")
		assert(options.unreliableEvent:IsA("UnreliableRemoteEvent"), "invalid unreliable remote")
		table.insert(
			connections,
			options.command.OnServerEvent:Connect(function(player, envelope)
				local ok = pcall(gateway.handle, player, envelope)
				if not ok then
					options.diagnostics.emit(
						"error",
						"NETWORK_GATEWAY_ERROR",
						{ component = "networking" }
					)
				end
			end)
		)
		table.insert(
			connections,
			options.players.PlayerRemoving:Connect(function(player)
				gateway.forget(player.UserId)
			end)
		)
	end

	local function stop()
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
		return {}
	end

	return {
		id = "networking",
		dependencies = if options.profileCoordinator == nil then {} else { "profiles" },
		start = start,
		stop = stop,
		gateway = gateway,
	}
end

return NetworkingRuntimeService
