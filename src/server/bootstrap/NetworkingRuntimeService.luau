--!strict

local shared = game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts
local ProtocolV1 = require(shared.ProtocolV1)
local RouteIds = require(shared.RouteIds)
local ResultCodes = require(shared.ResultCodes)
local WireValidation = require(shared.WireValidation)
local ProjectionV1 = require(shared.ProjectionV1)
local SecuredCollectionProjectionV1 = require(shared.SecuredCollectionProjectionV1)
local RouteRegistry = require(script.Parent.Parent.application.RouteRegistry)
local NetworkRateLimiter = require(script.Parent.Parent.application.NetworkRateLimiter)
local ReplayWindow = require(script.Parent.Parent.application.ReplayWindow)
local ProjectionPublisher = require(script.Parent.Parent.application.ProjectionPublisher)
local NetworkingGateway = require(script.Parent.Parent.application.NetworkingGateway)
local SecuredCollectionProjection =
	require(script.Parent.Parent.application.SecuredCollectionProjection)

local VaultCapacityProjection = require(script.Parent.Parent.application.VaultCapacityProjection)
local VaultProjectionV1 =
	require(game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts.VaultProjectionV1)
local NetworkingRuntimeService = {}

function NetworkingRuntimeService.new(options: {
	command: any,
	event: any,
	unreliableEvent: any,
	players: any,
	profileCoordinator: any?,
	diagnostics: any,
	captureRuntime: any?,
	vault: any?,
	capacity: any?,
})
	local function id(value: any): boolean
		return type(value) == "string" and #value > 0 and #value <= 96
	end
	local schemas = {}
	local handlers = {}
	local publishVault: any = nil
	if options.captureRuntime ~= nil then
		schemas[RouteIds.commands.interactionPrimaryInteract] = function(
			payload: any,
			expected: any
		): boolean
			if expected ~= nil or type(payload) ~= "table" or not id(payload.interactionId) then
				return false
			end
			for key in payload do
				if key ~= "interactionId" then
					return false
				end
			end
			return true
		end
		schemas[RouteIds.commands.captureSubmitAction] = function(
			payload: any,
			expected: any
		): boolean
			if
				expected ~= nil
				or type(payload) ~= "table"
				or not id(payload.captureSessionId)
				or payload.actionId ~= "capture"
				or payload.clientSequence ~= 1
			then
				return false
			end
			for key in payload do
				if key ~= "captureSessionId" and key ~= "actionId" and key ~= "clientSequence" then
					return false
				end
			end
			return true
		end
		handlers[RouteIds.commands.interactionPrimaryInteract] = function(
			player: any,
			envelope: any
		): string
			return options.captureRuntime.interact(
				player,
				envelope.payload.interactionId,
				envelope.requestId
			)
		end
		handlers[RouteIds.commands.captureSubmitAction] = function(
			player: any,
			envelope: any
		): string
			return options.captureRuntime.submit(player, envelope.payload, envelope.requestId)
		end
	end
	if options.vault ~= nil and options.capacity ~= nil then
		schemas[RouteIds.commands.vaultResolveOverflow] = VaultProjectionV1.validResolve
		handlers[RouteIds.commands.vaultResolveOverflow] = function(
			player: any,
			envelope: any
		): string
			local active = options.profileCoordinator.get(player.UserId)
			local outcome = options.capacity.resolve(
				active,
				envelope.payload.creatureInstanceId,
				envelope.expectedRevision
			)
			local publication = publishVault(player, envelope.requestId, nil)
			if publication == "OK_VAULT_SNAPSHOT" then
				local saved = active.snapshot()
				local record = (saved.collection.creaturesById or {})[envelope.payload.creatureInstanceId]
				if record ~= nil and not record.overflowHeld then
					return if outcome.status == "AlreadyStored"
						then "OK_VAULT_ALREADY_STORED"
						else "OK_VAULT_OVERFLOW_RESOLVED"
				end
			end
			if outcome.status == "Rejected" then
				return if outcome.reason == "OWNERSHIP"
					then "REJECT_PERMISSION_VAULT_OWNERSHIP"
					else "REJECT_STATE_VAULT_" .. (outcome.reason or "INVALID")
			end
			return if outcome.status == "OutcomeUnknown"
					or outcome.status == "PersistenceAtRisk"
				then "OUTCOME_UNKNOWN_VAULT_RESOLUTION"
				else "PROTECTED_VAULT_UNAVAILABLE"
		end
	end
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
				return {
					status = "Ready",
					profileRevision = snapshot.profileRevision,
					securedCollection = function()
						return SecuredCollectionProjection.fromProfile(snapshot, player.UserId)
					end,
				}
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
	publishVault = function(player: any, requestId: string, afterId: string?): string
		if options.capacity == nil or options.vault == nil or options.profileCoordinator == nil then
			return "UNAVAILABLE_VAULT"
		end
		local active = options.profileCoordinator.get(player.UserId)
		local result = options.capacity.reconcile(active)
		local ready = active ~= nil
			and active.state() == "Ready"
			and (
				result.status == "Unchanged"
				or result.status == "Committed"
				or result.status == "AlreadyCommitted"
			)
		projection.snapshot(
			player,
			if ready
				then { status = "Ready", profileRevision = active.snapshot().profileRevision }
				else { status = "Protected" }
		)
		if not ready then
			return if result.status == "OutcomeUnknown"
					or result.status == "PersistenceAtRisk"
				then "OUTCOME_UNKNOWN_VAULT_RESOLUTION"
				else "PROTECTED_VAULT_UNAVAILABLE"
		end
		local payload =
			VaultCapacityProjection.fromProfile(active.snapshot(), options.vault, afterId)
		assert(
			VaultProjectionV1.validSnapshot(payload) and WireValidation.payload(payload),
			"invalid bounded Vault projection"
		)
		options.event:FireClient(player, {
			protocolVersion = 1,
			routeId = RouteIds.events.projectionSnapshot,
			correlationId = requestId,
			revision = payload.revision,
			payload = payload,
		})
		return "OK_VAULT_SNAPSHOT"
	end
	local gateway = NetworkingGateway.new({
		protocol = ProtocolV1,
		routes = RouteIds,
		resultCodes = ResultCodes,
		wire = WireValidation,
		registry = RouteRegistry.new(RouteIds, schemas),
		rate = NetworkRateLimiter.new(os.clock),
		replay = ReplayWindow.new(os.clock, WireValidation),
		projection = projection,
		securedCollectionProjection = SecuredCollectionProjectionV1,
		getSession = getSession,
		emitReliable = function(player, envelope)
			options.event:FireClient(player, envelope)
		end,
		emitUnreliable = function(player, envelope)
			options.unreliableEvent:FireClient(player, envelope)
		end,
		routeHandlers = handlers,
		vaultResync = publishVault,
		captureResync = if options.captureRuntime ~= nil
			then options.captureRuntime.resync
			else nil,
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
		dependencies = if options.captureRuntime ~= nil
			then { "capture" }
			else if options.profileCoordinator == nil then {} else { "profiles" },
		start = start,
		stop = stop,
		gateway = gateway,
	}
end

return NetworkingRuntimeService
