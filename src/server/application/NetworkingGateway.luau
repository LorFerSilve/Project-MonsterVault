--!strict

local NetworkingGateway = {}

function NetworkingGateway.new(options: {
	protocol: any,
	routes: any,
	resultCodes: any,
	wire: any,
	registry: any,
	rate: any,
	replay: any,
	projection: any,
	getSession: (any) -> any,
	emitReliable: (any, any) -> (),
	emitUnreliable: (any, any) -> (),
})
	local function event(player: any, routeId: string, payload: any, correlationId: string?)
		options.emitReliable(player, {
			protocolVersion = options.protocol.version,
			routeId = routeId,
			correlationId = correlationId,
			payload = payload,
		})
	end

	local function result(player: any, requestId: string?, code: string): any
		assert(options.resultCodes.familyOf(code) ~= nil, "invalid public result code")
		local payload = { code = code }
		event(player, options.routes.events.commandResult, payload, requestId)
		return payload
	end

	local function presentSession(player: any, requestId: string): string
		local session = options.getSession(player)
		local status = session.status
		local projectionState: any
		local code: string
		if
			status == "Ready"
			and type(session.profileRevision) == "number"
			and session.profileRevision >= 0
			and session.profileRevision % 1 == 0
			and session.profileRevision < math.huge
		then
			projectionState = { status = "Ready", profileRevision = session.profileRevision }
			code = "OK_SESSION_READY"
			event(
				player,
				options.routes.events.sessionReady,
				{ profileRevision = session.profileRevision },
				requestId
			)
		elseif status == "Loading" then
			projectionState = { status = "Loading" }
			code = "PENDING_PROFILE_LOAD"
			event(
				player,
				options.routes.events.sessionProtectedOutcome,
				{ status = "Loading" },
				requestId
			)
		else
			projectionState = { status = "Protected" }
			code = "PROTECTED_PROFILE_UNAVAILABLE"
			event(
				player,
				options.routes.events.sessionProtectedOutcome,
				{ status = "Protected" },
				requestId
			)
		end
		options.projection.snapshot(player, projectionState)
		return code
	end

	options.registry.bind(
		options.routes.commands.sessionClientHello,
		function(player: any, envelope: any)
			return presentSession(player, envelope.requestId)
		end
	)
	options.registry.bind(
		options.routes.commands.sessionRequestResync,
		function(player: any, envelope: any)
			return presentSession(player, envelope.requestId)
		end
	)
	options.registry.seal()

	local function handle(player: any, envelope: any): any
		if player == nil or type(player.UserId) ~= "number" or player.UserId < 1 then
			return { code = "REJECT_VALIDATION_SENDER" }
		end
		if not options.rate.allowGlobal(player.UserId) then
			return { code = options.resultCodes.rejectRateLimit }
		end
		local requestId = if type(envelope) == "table"
				and type(envelope.requestId) == "string"
				and #envelope.requestId <= 64
			then envelope.requestId
			else nil
		local valid, reason = options.wire.envelope(envelope)
		if not valid then
			return result(player, requestId, "REJECT_VALIDATION_" .. (reason or "ENVELOPE"))
		end
		local contract, handler = options.registry.get(envelope.routeId)
		if contract == nil then
			return result(player, envelope.requestId, "REJECT_VALIDATION_ROUTE")
		end
		if not options.rate.allowRoute(player.UserId, envelope.routeId, contract.class) then
			return { code = options.resultCodes.rejectRateLimit }
		end
		if handler == nil then
			return result(player, envelope.requestId, "UNAVAILABLE_ROUTE")
		end
		if contract.requiresReady and options.getSession(player).status ~= "Ready" then
			return result(player, envelope.requestId, "REJECT_STATE_NOT_READY")
		end
		if
			not options.wire.payload(envelope.payload)
			or not contract.schema(envelope.payload, envelope.expectedRevision)
		then
			return result(player, envelope.requestId, "REJECT_VALIDATION_PAYLOAD")
		end
		local replayState, cached = options.replay.inspect(
			player.UserId,
			envelope.requestId,
			envelope.routeId,
			envelope.payload,
			envelope.expectedRevision
		)
		if replayState == "Misuse" then
			return result(player, envelope.requestId, "REJECT_VALIDATION_REQUEST_REUSE")
		end
		if replayState == "Duplicate" and not contract.retryAllowed then
			return result(
				player,
				envelope.requestId,
				if cached then cached.code else "PENDING_REQUEST"
			)
		end
		local ok, code = pcall(handler, player, envelope)
		if not ok or options.resultCodes.familyOf(code) == nil then
			code = "UNAVAILABLE_ROUTE"
		end
		local public = result(player, envelope.requestId, code)
		options.replay.complete(player.UserId, envelope.requestId, public)
		return public
	end

	local function cosmetic(player: any, routeId: string, payload: any): boolean
		local schema = options.registry.cosmeticSchema(routeId)
		if
			not options.routes.isUnreliableEvent(routeId)
			or schema == nil
			or not options.wire.payload(payload, 768)
		then
			return false
		end
		local ok, allowed = pcall(schema, payload)
		if not ok or not allowed then
			return false
		end
		options.emitUnreliable(player, {
			protocolVersion = options.protocol.version,
			routeId = routeId,
			payload = options.wire.copy(payload),
		})
		return true
	end

	return {
		handle = handle,
		cosmetic = cosmetic,
		forget = function(userId: number)
			options.rate.forget(userId)
			options.replay.forget(userId)
			options.projection.forget(userId)
		end,
	}
end

return NetworkingGateway
