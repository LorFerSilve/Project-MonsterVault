--!strict

local ProtocolV1 = require("../../src/shared/contracts/ProtocolV1")
local RouteIds = require("../../src/shared/contracts/RouteIds")
local ResultCodes = require("../../src/shared/contracts/ResultCodes")
local WireValidation = require("../../src/shared/contracts/WireValidation")
local ProjectionV1 = require("../../src/shared/contracts/ProjectionV1")
local ProjectionStore = require("../../src/client/store/ProjectionStore")
local ClientGateway = require("../../src/client/networking/ClientGateway")
local ProjectionPublisher = require("../../src/server/application/ProjectionPublisher")

local function event(routeId: string, payload: any, revision: number?): any
	return { protocolVersion = 1, routeId = routeId, revision = revision, payload = payload }
end

local function projectionRevisionAndResync()
	local store = ProjectionStore.new(ProjectionV1, WireValidation)
	local sent = {}
	local gateway = ClientGateway.new({
		protocol = ProtocolV1,
		routes = RouteIds,
		resultCodes = ResultCodes,
		wire = WireValidation,
		store = store,
		sendCommand = function(envelope)
			table.insert(sent, envelope)
		end,
	})
	assert(gateway.hello() == "client-1", "first request ID")
	assert(sent[1].routeId == RouteIds.commands.sessionClientHello, "hello after listener setup")
	local readyHint = event(RouteIds.events.sessionReady, { profileRevision = 99 })
	assert(gateway.handleEvent(readyHint) == "Notice", "ready hint alone cannot set client store")
	assert(store.view() == nil, "no local readiness from hint")
	local snap1 = { domain = "session", revision = 1, state = { status = "Loading" } }
	assert(
		gateway.handleEvent(event(RouteIds.events.projectionSnapshot, snap1, 1)) == "Applied",
		"initial snapshot"
	)
	local state: any, revision = store.view()
	assert(state.status == "Loading" and revision == 1, "initial state")
	local gap = {
		domain = "session",
		baseRevision = 2,
		revision = 3,
		state = { status = "Ready", profileRevision = 5 },
	}
	assert(
		gateway.handleEvent(event(RouteIds.events.projectionDelta, gap, 3)) == "Gap",
		"missing predecessor blocks merge"
	)
	assert(store.needsResync(), "gap marks resync")
	assert(
		#sent == 2 and sent[2].routeId == RouteIds.commands.sessionRequestResync,
		"one resync requested"
	)
	assert(
		gateway.handleEvent(event(RouteIds.events.projectionDelta, gap, 3)) == "Gap",
		"repeated gap"
	)
	assert(#sent == 2, "no resync flood")
	local snap3 =
		{ domain = "session", revision = 3, state = { status = "Ready", profileRevision = 5 } }
	assert(
		gateway.handleEvent(event(RouteIds.events.projectionSnapshot, snap3, 3)) == "Applied",
		"fresh snapshot reconciles"
	)
	local recovered: any, recoveredRevision = store.view()
	assert(
		recovered.status == "Ready" and recoveredRevision == 3 and not store.needsResync(),
		"authoritative recovery"
	)
	assert(
		gateway.handleEvent(event(RouteIds.events.projectionSnapshot, snap1, 1)) == "Stale",
		"older snapshot ignored"
	)
	local delta4 =
		{ domain = "session", baseRevision = 3, revision = 4, state = { status = "Protected" } }
	assert(
		gateway.handleEvent(event(RouteIds.events.projectionDelta, delta4, 4)) == "Applied",
		"adjacent delta applies"
	)
	assert(
		gateway.handleEvent(event(RouteIds.events.projectionDelta, delta4, 4)) == "Stale",
		"duplicate delta ignored"
	)
	local protected: any = store.view()
	assert(protected.status == "Protected", "projection can revoke displayed readiness")
	protected.status = "Ready"
	assert(store.view().status == "Protected", "callers cannot mutate store snapshot")
	gateway.reset()
	assert(store.view() == nil, "reconnect resets disposable cache")
end

local function invalidProjectionAndResultRejected()
	local store = ProjectionStore.new(ProjectionV1, WireValidation)
	local gateway = ClientGateway.new({
		protocol = ProtocolV1,
		routes = RouteIds,
		resultCodes = ResultCodes,
		wire = WireValidation,
		store = store,
		sendCommand = function() end,
	})
	local invalid = {
		{ domain = "session", revision = 1, state = { status = "Ready" } },
		{ domain = "session", revision = 1, state = { status = "Ready", profileRevision = 0 / 0 } },
		{ domain = "economy", revision = 1, state = { status = "Ready", profileRevision = 1 } },
	}
	for _, payload in invalid do
		assert(
			gateway.handleEvent(event(RouteIds.events.projectionSnapshot, payload)) == "Invalid",
			"invalid state rejected"
		)
	end
	assert(
		gateway.handleEvent(event(RouteIds.events.commandResult, { code = "fake" })) == "Invalid",
		"uncorrelated result rejected"
	)
	local correlated = event(RouteIds.events.commandResult, { code = "REJECT_STATE_NOT_READY" })
	correlated.correlationId = "client-1"
	assert(gateway.handleEvent(correlated) == "Result", "machine-readable rejection")
	assert(gateway.resultFor("client-1") == "REJECT_STATE_NOT_READY", "result correlated")
	for index = 2, 130 do
		local nextResult = event(RouteIds.events.commandResult, { code = "PENDING_PROFILE_LOAD" })
		nextResult.correlationId = "client-" .. tostring(index)
		assert(gateway.handleEvent(nextResult) == "Result", "result accepted")
	end
	assert(gateway.resultFor("client-1") == nil, "result cache bounded")
	assert(gateway.resultFor("client-130") == "PENDING_PROFILE_LOAD", "newest result retained")
	assert(
		gateway.handleEvent(event(RouteIds.commands.sessionClientHello, {})) == "Invalid",
		"wrong-direction route rejected"
	)
	assert(store.view() == nil, "invalid events cannot establish state")
end

local function publisherOrdersOwnerOnlyState()
	local sent: { any } = {}
	local publisher = ProjectionPublisher.new({
		protocol = ProtocolV1,
		routes = RouteIds,
		projection = ProjectionV1,
		wire = WireValidation,
		emit = function(player, envelope)
			table.insert(sent, { userId = player.UserId, envelope = envelope })
		end,
	})
	local owner = { UserId = 81 }
	assert(publisher.snapshot(owner, { status = "Loading" }) == 1, "first version")
	assert(publisher.delta(owner, { status = "Ready", profileRevision = 4 }) == 2, "next version")
	assert(
		publisher.delta(owner, { status = "Ready", profileRevision = 4 }) == 2,
		"unchanged state"
	)
	assert(#sent == 2, "no redundant delta")
	assert(sent[1].userId == 81 and sent[2].userId == 81, "private owner delivery")
	assert(ProjectionV1.validSnapshot(sent[1].envelope.payload), "snapshot contract")
	assert(ProjectionV1.validDelta(sent[2].envelope.payload), "delta contract")
	assert(sent[2].envelope.payload.baseRevision == 1, "delta predecessor")
	publisher.forget(81)
	assert(
		publisher.snapshot(owner, { status = "Protected" }) == 1,
		"new client session resets sequence"
	)
end

return {
	projectionRevisionAndResync = projectionRevisionAndResync,
	invalidProjectionAndResultRejected = invalidProjectionAndResultRejected,
	publisherOrdersOwnerOnlyState = publisherOrdersOwnerOnlyState,
}
