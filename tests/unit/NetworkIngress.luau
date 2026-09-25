--!strict

local ProtocolV1 = require("../../src/shared/contracts/ProtocolV1")
local RouteIds = require("../../src/shared/contracts/RouteIds")
local ResultCodes = require("../../src/shared/contracts/ResultCodes")
local WireValidation = require("../../src/shared/contracts/WireValidation")
local ProjectionV1 = require("../../src/shared/contracts/ProjectionV1")
local RouteRegistry = require("../../src/server/application/RouteRegistry")
local NetworkRateLimiter = require("../../src/server/application/NetworkRateLimiter")
local ReplayWindow = require("../../src/server/application/ReplayWindow")
local ProjectionPublisher = require("../../src/server/application/ProjectionPublisher")
local NetworkingGateway = require("../../src/server/application/NetworkingGateway")

local function fixture(registry: any?)
	local now = 0
	local session: any = { status = "Protected" }
	local reliable: { any } = {}
	local cosmetic: { any } = {}
	local function emit(player, envelope)
		table.insert(reliable, { userId = player.UserId, envelope = envelope })
	end
	local gateway = NetworkingGateway.new({
		protocol = ProtocolV1,
		routes = RouteIds,
		resultCodes = ResultCodes,
		wire = WireValidation,
		registry = registry or RouteRegistry.new(RouteIds),
		rate = NetworkRateLimiter.new(function()
			return now
		end),
		replay = ReplayWindow.new(function()
			return now
		end, WireValidation),
		projection = ProjectionPublisher.new({
			protocol = ProtocolV1,
			routes = RouteIds,
			projection = ProjectionV1,
			wire = WireValidation,
			emit = emit,
		}),
		getSession = function()
			return session
		end,
		emitReliable = emit,
		emitUnreliable = function(player, envelope)
			table.insert(cosmetic, { userId = player.UserId, envelope = envelope })
		end,
	})
	return gateway,
		reliable,
		cosmetic,
		function(value)
			session = value
		end,
		function(value)
			now = value
		end
end

local function command(routeId: string, requestId: string, payload: any?): any
	return { protocolVersion = 1, routeId = routeId, requestId = requestId, payload = payload or {} }
end

local function hostileEnvelopesFailClosed()
	local gateway, reliable = fixture()
	local player = { UserId = 42 }
	assert(gateway.handle(player, nil).code ~= "OK_SESSION_READY", "nil rejected")
	local bad: { any } = {
		"hello",
		{
			protocolVersion = 1,
			routeId = RouteIds.commands.sessionClientHello,
			requestId = "a",
			payload = {},
			senderUserId = 7,
		},
		{
			protocolVersion = 2,
			routeId = RouteIds.commands.sessionClientHello,
			requestId = "b",
			payload = {},
		},
		command("Unknown.Route", "c"),
		command(RouteIds.events.sessionReady, "d"),
		command(RouteIds.commands.sessionClientHello, "bad id"),
		command(RouteIds.commands.sessionClientHello, "e", { player = 7 }),
		command(RouteIds.commands.sessionClientHello, "forged", { ready = true }),
		command(RouteIds.commands.sessionClientHello, "f", { touch = 0 / 0 }),
		command(RouteIds.commands.sessionClientHello, "g", { touch = string.rep("a", 300) }),
	}
	for _, envelope in bad do
		assert(
			string.sub(gateway.handle(player, envelope).code, 1, 3) ~= "OK_",
			"hostile command rejected"
		)
	end
	local cyclic = {}
	cyclic.self = cyclic
	assert(
		gateway.handle(player, command(RouteIds.commands.sessionClientHello, "cyclic", cyclic)).code
			== "REJECT_VALIDATION_PAYLOAD",
		"cyclic payload rejected"
	)
	assert(
		gateway.handle(player, command(RouteIds.commands.captureSubmitAction, "reserved")).code
			== "UNAVAILABLE_ROUTE",
		"future sensitive route not active"
	)
	for _, record in reliable do
		assert(record.userId == 42, "result only to authenticated sender")
		assert(record.envelope.routeId == RouteIds.events.commandResult, "no readiness event")
	end
end

local function helloCannotGrantReady()
	local gateway, reliable, _, setSession = fixture()
	local player = { UserId = 42 }
	local hello = command(
		RouteIds.commands.sessionClientHello,
		"same",
		{ touch = true, reducedMotion = false }
	)
	assert(
		gateway.handle(player, hello).code == "PROTECTED_PROFILE_UNAVAILABLE",
		"unbound profile protected"
	)
	setSession({ status = "Loading" })
	assert(
		gateway.handle(player, hello).code == "PENDING_PROFILE_LOAD",
		"same-ID retry can observe loading"
	)
	setSession({ status = "Ready", profileRevision = 7 })
	assert(
		gateway.handle(player, hello).code == "OK_SESSION_READY",
		"only server state can grant readiness"
	)
	local ready = 0
	local snapshots = 0
	for _, record in reliable do
		if record.envelope.routeId == RouteIds.events.sessionReady then
			ready += 1
			assert(record.envelope.payload.profileRevision == 7, "server revision only")
		elseif record.envelope.routeId == RouteIds.events.projectionSnapshot then
			snapshots += 1
			assert(
				ProjectionV1.validSnapshot(record.envelope.payload),
				"bounded session projection"
			)
		end
	end
	assert(ready == 1 and snapshots == 3, "only ready profile emits ready signal")
	assert(
		gateway.handle(
			player,
			command(RouteIds.commands.sessionRequestResync, "resync", { domain = "session" })
		).code == "OK_SESSION_READY",
		"resync from current server state"
	)
end

local function rateReplayAndCosmeticBoundary()
	local registry = RouteRegistry.new(RouteIds)
	registry.bindCosmetic(RouteIds.unreliableEvents.presentationWorldCue, function(payload)
		return payload.cue == "spark"
	end)
	local gateway, _, cosmetic, setSession, setNow = fixture(registry)
	local player = { UserId = 3 }
	setSession({ status = "Ready", profileRevision = 2 })
	assert(
		gateway.handle(player, command(RouteIds.commands.sessionClientHello, "one")).code
			== "OK_SESSION_READY",
		"first request"
	)
	assert(
		gateway.handle(player, command(RouteIds.commands.sessionRequestResync, "one")).code
			== "REJECT_VALIDATION_REQUEST_REUSE",
		"ID cannot change route"
	)
	assert(
		gateway.handle(
			player,
			command(RouteIds.commands.sessionClientHello, "one", { touch = true })
		).code == "REJECT_VALIDATION_REQUEST_REUSE",
		"ID cannot change payload"
	)
	local limited = false
	for index = 1, 9 do
		if
			gateway.handle(player, command(RouteIds.commands.sessionClientHello, "flood" .. index)).code
			== "REJECT_RATE_LIMIT"
		then
			limited = true
		end
	end
	assert(limited, "per-route bucket bounds flood")
	setNow(10)
	assert(
		gateway.handle(player, command(RouteIds.commands.sessionClientHello, "after-refill")).code
			== "OK_SESSION_READY",
		"tokens refill"
	)
	assert(
		not gateway.cosmetic(player, RouteIds.events.sessionReady, {}),
		"reliable fact cannot use unreliable transport"
	)
	assert(
		not gateway.cosmetic(
			player,
			RouteIds.unreliableEvents.presentationWorldCue,
			{ value = string.rep("a", 200) }
		),
		"conservative unreliable byte budget"
	)
	assert(
		gateway.cosmetic(player, RouteIds.unreliableEvents.presentationWorldCue, { cue = "spark" }),
		"validated cosmetic cue"
	)
	assert(#cosmetic == 1 and cosmetic[1].userId == 3, "cosmetic recipient scoped")
	local disabledGateway = fixture()
	assert(
		not disabledGateway.cosmetic(
			player,
			RouteIds.unreliableEvents.presentationWorldCue,
			{ cue = "spark" }
		),
		"future cosmetic route has no production schema"
	)
	local limiter = NetworkRateLimiter.new(function()
		return 0
	end)
	local accepted = 0
	for index = 1, 30 do
		if limiter.allow(99, "route-" .. tostring(index), "B") then
			accepted += 1
		end
	end
	assert(accepted == 16, "global ingress burst holds across routes")
	local floodGateway, floodResults = fixture()
	local dropped = false
	for index = 1, 30 do
		if
			floodGateway.handle(player, command("Unknown.Route", "bogus" .. index)).code
			== "REJECT_RATE_LIMIT"
		then
			dropped = true
		end
	end
	assert(dropped and #floodResults <= 16, "unknown-route flood does not create unlimited replies")
end

local function registryRejectsInvalidBinding()
	local registry = RouteRegistry.new(RouteIds)
	local handler = function()
		return "OK_SESSION_READY"
	end
	local ok = pcall(registry.bind, RouteIds.commands.captureSubmitAction, handler)
	assert(not ok, "reserved route needs owning phase schema")
	registry.bind(RouteIds.commands.sessionClientHello, handler)
	assert(
		not pcall(registry.bind, RouteIds.commands.sessionClientHello, handler),
		"duplicate handler fails"
	)
	registry.seal()
	assert(
		not pcall(registry.bind, RouteIds.commands.sessionRequestResync, handler),
		"sealed registry cannot change"
	)
end

return {
	hostileEnvelopesFailClosed = hostileEnvelopesFailClosed,
	helloCannotGrantReady = helloCannotGrantReady,
	rateReplayAndCosmeticBoundary = rateReplayAndCosmeticBoundary,
	registryRejectsInvalidBinding = registryRejectsInvalidBinding,
}
