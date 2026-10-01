--!strict

local ClientGateway = {}

function ClientGateway.new(options: {
	protocol: any,
	routes: any,
	resultCodes: any,
	wire: any,
	store: any,
	captureProjection: any?,
	vaultProjection: any?,
	securedCollectionProjection: any?,
	securedCollectionStore: any?,
	sendCommand: (any) -> (),
})
	local nextRequest = 0
	local resyncInFlight = false
	local results: { [string]: string } = {}
	local resultOrder: { string } = {}
	local outgoing: { [string]: any } = {}
	local outgoingOrder: { string } = {}

	local function send(routeId: string, payload: any, expectedRevision: number?): string
		assert(options.routes.isCommand(routeId), "unknown client command")
		assert(options.wire.payload(payload), "invalid client payload")
		nextRequest += 1
		local requestId = "client-" .. tostring(nextRequest)
		local envelope = {
			protocolVersion = options.protocol.version,
			routeId = routeId,
			requestId = requestId,
			payload = options.wire.copy(payload),
			expectedRevision = expectedRevision,
		}
		outgoing[requestId] = envelope
		table.insert(outgoingOrder, requestId)
		if #outgoingOrder > 128 then
			local oldest = table.remove(outgoingOrder, 1)
			if oldest ~= nil then
				outgoing[oldest] = nil
			end
		end
		options.sendCommand(options.wire.copy(envelope))
		return requestId
	end

	local function requestResync()
		if resyncInFlight then
			return
		end
		resyncInFlight = true
		send(options.routes.commands.sessionRequestResync, { domain = "session" })
	end

	local function validEvent(envelope: any): boolean
		if
			type(envelope) ~= "table"
			or envelope.protocolVersion ~= options.protocol.version
			or not options.routes.isEvent(envelope.routeId)
			or type(envelope.payload) ~= "table"
			or not options.wire.payload(envelope.payload)
		then
			return false
		end
		for key in envelope do
			if
				key ~= "protocolVersion"
				and key ~= "routeId"
				and key ~= "correlationId"
				and key ~= "revision"
				and key ~= "payload"
			then
				return false
			end
		end
		return envelope.correlationId == nil or type(envelope.correlationId) == "string"
	end

	local function handleEvent(envelope: any): string
		if not validEvent(envelope) then
			return "Invalid"
		end
		if envelope.routeId == options.routes.events.projectionSnapshot then
			if envelope.payload.domain == "vault" then
				if
					options.vaultProjection == nil
					or not options.vaultProjection.validSnapshot(envelope.payload)
					or envelope.revision ~= envelope.payload.revision
				then
					return "Invalid"
				end
				local session = options.store.view()
				return if session ~= nil
						and session.status == "Ready"
						and session.profileRevision == envelope.revision
					then "Vault"
					else "Stale"
			end
			if
				type(envelope.payload) == "table"
				and envelope.payload.domain == "securedCollection"
			then
				if
					options.securedCollectionProjection == nil
					or options.securedCollectionStore == nil
					or not options.securedCollectionProjection.validSnapshot(envelope.payload)
					or envelope.revision ~= envelope.payload.revision
				then
					return "Invalid"
				end
				return options.securedCollectionStore.snapshot(
					envelope.payload,
					options.store.view()
				)
			end
			local outcome = options.store.snapshot(envelope.payload)
			if outcome == "Applied" then
				resyncInFlight = false
				if options.securedCollectionStore ~= nil then
					local session = options.store.view()
					local collection = options.securedCollectionStore.view()
					if
						session.status ~= "Ready"
						or collection == nil
						or collection.profileRevision ~= session.profileRevision
					then
						options.securedCollectionStore.reset()
					end
				end
			end
			return outcome
		elseif envelope.routeId == options.routes.events.projectionDelta then
			local outcome = options.store.delta(envelope.payload)
			if outcome == "Applied" and options.securedCollectionStore ~= nil then
				local session = options.store.view()
				local collection = options.securedCollectionStore.view()
				if
					session.status ~= "Ready"
					or collection == nil
					or collection.profileRevision ~= session.profileRevision
				then
					options.securedCollectionStore.reset()
				end
			end
			if outcome == "Gap" then
				requestResync()
			end
			return outcome
		elseif envelope.routeId == options.routes.events.commandResult then
			local code = envelope.payload.code
			if
				type(envelope.correlationId) ~= "string"
				or #envelope.correlationId > 64
				or options.resultCodes.familyOf(code) == nil
			then
				return "Invalid"
			end
			if results[envelope.correlationId] == nil then
				table.insert(resultOrder, envelope.correlationId)
			end
			results[envelope.correlationId] = code
			while #resultOrder > 128 do
				local oldest = table.remove(resultOrder, 1)
				if oldest ~= nil then
					results[oldest] = nil
				end
			end
			return "Result"
		elseif envelope.routeId == options.routes.events.captureStateChanged then
			if
				options.captureProjection == nil
				or not options.captureProjection.validState(envelope.payload)
				or (envelope.revision ~= nil and envelope.revision ~= envelope.payload.revision)
			then
				return "Invalid"
			end
			return "Capture"
		end
		-- Session.Ready is a server hint; only a validated projection updates
		-- the client store, and no client store value grants server permission.
		return "Notice"
	end

	return {
		send = send,
		resend = function(requestId: string): boolean
			local envelope = outgoing[requestId]
			if envelope == nil then
				return false
			end
			options.sendCommand(options.wire.copy(envelope))
			return true
		end,
		handleEvent = handleEvent,
		hello = function(): string
			return send(options.routes.commands.sessionClientHello, {})
		end,
		resultFor = function(requestId: string): string?
			return results[requestId]
		end,
		reset = function()
			resyncInFlight = false
			results = {}
			resultOrder = {}
			outgoing = {}
			outgoingOrder = {}
			options.store.reset()
			if options.securedCollectionStore ~= nil then
				options.securedCollectionStore.reset()
			end
		end,
	}
end

return ClientGateway
