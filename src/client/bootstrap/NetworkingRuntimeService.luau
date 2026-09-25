--!strict

local shared = game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts
local ProtocolV1 = require(shared.ProtocolV1)
local RouteIds = require(shared.RouteIds)
local ResultCodes = require(shared.ResultCodes)
local WireValidation = require(shared.WireValidation)
local ProjectionV1 = require(shared.ProjectionV1)
local ProjectionStore = require(script.Parent.Parent.store.ProjectionStore)
local ClientGateway = require(script.Parent.Parent.networking.ClientGateway)

local NetworkingRuntimeService = {}

function NetworkingRuntimeService.new(options: {
	command: any,
	event: any,
	unreliableEvent: any,
	diagnostics: any,
})
	local store = ProjectionStore.new(ProjectionV1, WireValidation)
	local gateway = ClientGateway.new({
		protocol = ProtocolV1,
		routes = RouteIds,
		resultCodes = ResultCodes,
		wire = WireValidation,
		store = store,
		sendCommand = function(envelope)
			options.command:FireServer(envelope)
		end,
	})
	local connections = {}
	local scheduler = (getfenv() :: any).task
	local running = false

	local function start()
		assert(not running, "networking already started")
		running = true
		assert(options.command:IsA("RemoteEvent"), "invalid command remote")
		assert(options.event:IsA("RemoteEvent"), "invalid event remote")
		assert(options.unreliableEvent:IsA("UnreliableRemoteEvent"), "invalid unreliable remote")
		table.insert(
			connections,
			options.event.OnClientEvent:Connect(function(envelope)
				local ok, outcome = pcall(gateway.handleEvent, envelope)
				if not ok or outcome == "Invalid" then
					options.diagnostics.emit(
						"warn",
						"NETWORK_EVENT_INVALID",
						{ component = "networking" }
					)
				end
			end)
		)
		table.insert(
			connections,
			options.unreliableEvent.OnClientEvent:Connect(function(envelope)
				if
					type(envelope) ~= "table"
					or envelope.protocolVersion ~= ProtocolV1.version
					or not RouteIds.isUnreliableEvent(envelope.routeId)
					or not WireValidation.payload(envelope.payload, 768)
				then
					options.diagnostics.emit(
						"warn",
						"NETWORK_COSMETIC_INVALID",
						{ component = "networking" }
					)
				end
				-- Cosmetic consumers are registered by their owning later phase.
			end)
		)
		gateway.hello() -- Listener binding precedes the first handshake command.
		scheduler.spawn(function()
			while running do
				scheduler.wait(5)
				if not running then
					break
				end
				local state = store.view()
				if state ~= nil and state.status ~= "Loading" then
					break
				end
				gateway.hello() -- Bounded cadence covers load/listener races.
			end
		end)
	end

	local function stop()
		running = false
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
		gateway.reset()
		return {}
	end

	return {
		id = "networking",
		dependencies = {},
		start = start,
		stop = stop,
		gateway = gateway,
		store = store,
	}
end

return NetworkingRuntimeService
