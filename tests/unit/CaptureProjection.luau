--!strict

local CaptureProjection = require("../../src/shared/contracts/CaptureProjectionV1")
local CaptureService = require("../../src/server/domains/capture/CaptureService")
local Protocol = require("../../src/shared/contracts/ProtocolV1")
local Routes = require("../../src/shared/contracts/RouteIds")
local Codes = require("../../src/shared/contracts/ResultCodes")
local Wire = require("../../src/shared/contracts/WireValidation")
local SessionProjection = require("../../src/shared/contracts/ProjectionV1")
local Registry = require("../../src/server/application/RouteRegistry")
local Rate = require("../../src/server/application/NetworkRateLimiter")
local Replay = require("../../src/server/application/ReplayWindow")
local Publisher = require("../../src/server/application/ProjectionPublisher")
local Gateway = require("../../src/server/application/NetworkingGateway")

local function check(value: any, message: string?)
	assert(value, message or "capture projection invariant")
end

local NEAR = { x = 0, y = 0, z = 0 }
local READY = {
	state = function()
		return "Ready"
	end,
}

local function captureHarness(roll: number?): any
	local now, ids, finalizations = 100, 0, 0
	local durable = false
	local states: { [string]: string } = { creature = "IdleAvailable" }
	local changed: { any } = {}
	local capture = CaptureService.new({
		world = {
			interaction = function(id)
				return if states[id] == "IdleAvailable" then "Available" else "Unavailable",
					{ position = NEAR }
			end,
			identity = function()
				return {
					speciesId = "species",
					variantIdentity = {},
					spawnContextId = "spawn",
					contentSnapshotId = "content",
				}
			end,
			transition = function(id, from, to)
				if states[id] ~= from then
					return false
				end
				states[id] = to
				return true
			end,
			retire = function(id)
				states[id] = nil
			end,
		},
		clock = function()
			return now
		end,
		unixSeconds = function()
			return 1_700_000_000
		end,
		newId = function()
			ids += 1
			return "server-" .. ids
		end,
		random = {
			nextUnit = function()
				return roll or 0.1
			end,
		},
		canInitiate = function()
			return true
		end,
		finalize = function()
			finalizations += 1
			return if durable
				then { status = "Secured", profileRevision = 9 }
				else { status = "OutcomeUnknown" }
		end,
		onChanged = function(userId, state)
			check(
				userId == 42 and CaptureProjection.validState(state),
				"only valid authoritative projection"
			)
			table.insert(changed, state)
		end,
	})
	return {
		capture = capture,
		changed = changed,
		advance = function(seconds)
			now += seconds
		end,
		commit = function()
			durable = true
		end,
		finalizations = function()
			return finalizations
		end,
	}
end

local function projectionRejectsForgedOwnershipAndRevision()
	check(CaptureProjection.validState({ status = "Idle", revision = 1 }))
	local secured = {
		status = "Secured",
		revision = 5,
		captureSessionId = "claim",
		creatureInstanceId = "creature",
		custodyId = "custody",
		profileRevision = 2,
	}
	check(CaptureProjection.validState(secured))
	for _, status in { "Claimed", "Failed", "Interrupted", "Expired" } do
		check(CaptureProjection.validState({
			status = status,
			revision = 2,
			captureSessionId = "claim",
			creatureInstanceId = "creature",
		}))
	end
	for _, status in { "TransportActive", "FinalizationPending" } do
		check(CaptureProjection.validState({
			status = status,
			revision = 3,
			captureSessionId = "claim",
			creatureInstanceId = "creature",
			custodyId = "custody",
		}))
	end
	for _, invalid in
		{
			{ status = "Idle", revision = 0 },
			{ status = "Idle", revision = 0 / 0 },
			{ status = "Idle", revision = math.huge },
			{ status = "Idle", revision = 1, profileRevision = 7 },
			{ status = "Idle", revision = 1, owned = true },
			{ status = "Claimed", revision = 2 },
			{
				status = "TransportActive",
				revision = 3,
				captureSessionId = "claim",
				creatureInstanceId = "creature",
			},
			{
				status = "Secured",
				revision = 4,
				captureSessionId = "claim",
				creatureInstanceId = "creature",
				custodyId = "custody",
			},
			{
				status = "FinalizationPending",
				revision = 4,
				captureSessionId = "claim",
				creatureInstanceId = "creature",
				custodyId = "custody",
				profileRevision = 2,
			},
		}
	do
		check(not CaptureProjection.validState(invalid), "malformed state cannot grant ownership")
	end
end

local function latestStateRecoversDroppedCaptureAndFinalization()
	local h = captureHarness()
	local capture = h.capture
	check(capture.snapshot(42).status == "Idle" and capture.snapshot(42).revision == 1)
	local claim = capture.begin(42, "creature", NEAR, 1, {})
	local claimed = capture.snapshot(42)
	check(claimed.status == "Claimed" and claimed.claimExpiresAt == 120 and claimed.revision == 2)
	check(claimed.captureSessionId == claim.captureSessionId)
	capture.submit(42, claim.captureSessionId, "capture", 1, NEAR, 1)
	local transport = capture.snapshot(42)
	check(
		transport.status == "TransportActive"
			and transport.revision == 3
			and transport.custodyId ~= nil
	)
	capture.submit(42, claim.captureSessionId, "capture", 1, NEAR, 1)
	check(capture.snapshot(42).revision == 3, "idempotent submit cannot invent another revision")
	check(capture.secure(42, NEAR, NEAR, 1, READY).status == "OutcomeUnknown")
	local pending = capture.snapshot(42)
	check(
		pending.status == "FinalizationPending"
			and pending.revision == 4
			and pending.profileRevision == nil
	)
	check(
		h.changed[#h.changed].status == "FinalizationPending",
		"pending emitted before uncertain P2"
	)
	capture.disconnect(42)
	capture.interrupt(42)
	h.advance(40)
	capture.tick()
	check(
		capture.snapshot(42).revision == pending.revision,
		"pending survives reconnect/reset and timeout"
	)
	capture.reconcile(42, READY)
	check(capture.snapshot(42).status == "FinalizationPending", "unconfirmed outcome stays pending")
	h.commit()
	capture.reconcile(42, READY)
	local secured = capture.snapshot(42)
	check(secured.status == "Secured" and secured.revision == 5 and secured.profileRevision == 9)
	check(
		secured.captureSessionId == claimed.captureSessionId
			and secured.custodyId == transport.custodyId
	)
	check(secured.creatureInstanceId == "creature" and capture.recordCounts().active == 0)
	secured.status = "Idle"
	check(capture.snapshot(42).status == "Secured", "resync copies cannot corrupt server state")
	check(capture.snapshot(7).status == "Idle", "projection is private to its owner")
	local restarted = captureHarness()
	check(
		restarted.capture.snapshot(42).status == "Idle",
		"new server cannot transfer provisional custody"
	)
end

local function interruptionsAndExpiryRecoverWithoutOwnership()
	local failed = captureHarness(0.9)
	local claim = failed.capture.begin(42, "creature", NEAR, 1, {})
	failed.capture.submit(42, claim.captureSessionId, "capture", 1, NEAR, 1)
	check(failed.capture.snapshot(42).status == "Failed" and failed.finalizations() == 0)
	local h = captureHarness()
	claim = h.capture.begin(42, "creature", NEAR, 1, {})
	h.capture.interrupt(42)
	check(h.capture.snapshot(42).status == "Interrupted")
	claim = h.capture.begin(42, "creature", NEAR, 2, {})
	h.advance(20)
	h.capture.tick()
	check(h.capture.snapshot(42).status == "Expired")
	claim = h.capture.begin(42, "creature", NEAR, 2, {})
	h.capture.submit(42, claim.captureSessionId, "capture", 1, NEAR, 2)
	local custodyId = h.capture.snapshot(42).custodyId
	h.capture.disconnect(42)
	check(h.capture.snapshot(42).status == "Interrupted")
	h.capture.resume(42, 3, {})
	check(
		h.capture.snapshot(42).status == "TransportActive"
			and h.capture.snapshot(42).custodyId == custodyId
	)
	h.capture.disconnect(42)
	h.advance(30)
	h.capture.tick()
	check(h.capture.snapshot(42).status == "Expired" and h.finalizations() == 0)
end

local function recentProjectionCacheRetainsActiveAndConnectedTruth()
	local connected: { [number]: boolean } = { [1] = true }
	local states: { [string]: string } = {}
	local ids = 0
	local capture = CaptureService.new({
		world = {
			interaction = function(creatureId)
				return if states[creatureId] == "IdleAvailable" then "Available" else "Busy",
					{ position = NEAR }
			end,
			identity = function()
				return { speciesId = "species", variantIdentity = {} }
			end,
			transition = function(creatureId, from, to)
				if states[creatureId] ~= from then
					return false
				end
				states[creatureId] = to
				return true
			end,
			retire = function(creatureId)
				states[creatureId] = nil
			end,
		},
		clock = function()
			return 100
		end,
		unixSeconds = function()
			return 1_700_000_000
		end,
		newId = function()
			ids += 1
			return "claim-" .. ids
		end,
		random = {
			nextUnit = function()
				return 0.1
			end,
		},
		canInitiate = function()
			return true
		end,
		finalize = function()
			return { status = "OutcomeUnknown" }
		end,
		isPlayerConnected = function(userId)
			return connected[userId] == true
		end,
	})
	local function claim(userId: number, interrupt: boolean)
		local creatureId = "creature-" .. userId
		states[creatureId] = "IdleAvailable"
		check(capture.begin(userId, creatureId, NEAR, 1, {}).status == "Claimed")
		if interrupt then
			capture.interrupt(userId)
		end
	end
	claim(1, true) -- Terminal summary belongs to a still-connected player.
	claim(2, false) -- Active claim survives churn even while disconnected.
	for userId = 3, 280 do
		claim(userId, true)
	end
	local counts = capture.projectionCounts()
	check(counts.total <= 258 and counts.recent <= 256, "disconnected terminal cache stays bounded")
	check(
		capture.snapshot(1).status == "Interrupted" and capture.snapshot(1).revision == 3,
		"connected terminal remains exact"
	)
	check(
		capture.snapshot(2).status == "Claimed" and capture.snapshot(2).revision == 2,
		"active claim and revision survive eviction"
	)
	check(
		capture.snapshot(280).status == "Interrupted",
		"recent same-server outcome remains available"
	)
	check(capture.snapshot(3).status == "Idle", "evicted old result cannot become fake ownership")
	connected[1] = false
	capture.playerLeft(1)
	connected[1] = true
	check(
		capture.snapshot(1).status == "Interrupted",
		"quick same-server reconnect recovers recent outcome"
	)
	connected[1] = false
	capture.playerLeft(1)
	for userId = 281, 580 do
		claim(userId, true)
	end
	check(capture.snapshot(1).status == "Idle", "departed old summary eventually evicts")
	check(capture.snapshot(2).status == "Claimed", "cold eviction never deletes active authority")
	counts = capture.projectionCounts()
	check(
		counts.total <= 257 and counts.recent <= 256,
		"cold cache remains bounded after reconnect churn"
	)
end

local function resyncUsesExistingRouteAndServerAuthority()
	local emitted: { any } = {}
	local status, calls = "Ready", 0
	local function emit(_player, envelope)
		table.insert(emitted, envelope)
	end
	local gateway = Gateway.new({
		protocol = Protocol,
		routes = Routes,
		resultCodes = Codes,
		wire = Wire,
		registry = Registry.new(Routes),
		rate = Rate.new(function()
			return 0
		end),
		replay = Replay.new(function()
			return 0
		end, Wire),
		projection = Publisher.new({
			protocol = Protocol,
			routes = Routes,
			projection = SessionProjection,
			wire = Wire,
			emit = emit,
		}),
		getSession = function()
			return { status = status, profileRevision = 1 }
		end,
		emitReliable = emit,
		emitUnreliable = function() end,
		captureResync = function(player, requestId)
			check(player.UserId == 42)
			calls += 1
			emit(player, {
				protocolVersion = 1,
				routeId = Routes.events.captureStateChanged,
				correlationId = requestId,
				payload = { status = "Idle", revision = 1 },
			})
			return "OK_CAPTURE_RESYNC"
		end,
	})
	local function command(requestId, payload)
		return {
			protocolVersion = 1,
			routeId = Routes.commands.sessionRequestResync,
			requestId = requestId,
			payload = payload,
		}
	end
	local player = { UserId = 42 }
	check(
		gateway.handle(
			player,
			command("capture-resync", { domain = "capture", knownRevision = 999 })
		).code == "OK_CAPTURE_RESYNC"
	)
	check(
		calls == 1
			and emitted[1].correlationId == "capture-resync"
			and emitted[1].payload.revision == 1,
		"client revision is only a hint"
	)
	check(
		gateway.handle(player, command("forged-owner", { domain = "capture", userId = 7 })).code
			== "REJECT_VALIDATION_PAYLOAD"
	)
	check(
		gateway.handle(
			player,
			command("invalid-revision", { domain = "capture", knownRevision = -1 })
		).code == "REJECT_VALIDATION_PAYLOAD"
	)
	check(
		gateway.handle(player, command("invalid-domain", { domain = "collection" })).code
			== "REJECT_VALIDATION_PAYLOAD"
	)
	status = "Protected"
	check(
		gateway.handle(player, command("not-ready", { domain = "capture" })).code
			== "REJECT_STATE_NOT_READY"
	)
	check(calls == 1, "protected player cannot read a capture projection")
end

return {
	projectionRejectsForgedOwnershipAndRevision = projectionRejectsForgedOwnershipAndRevision,
	latestStateRecoversDroppedCaptureAndFinalization = latestStateRecoversDroppedCaptureAndFinalization,
	interruptionsAndExpiryRecoverWithoutOwnership = interruptionsAndExpiryRecoverWithoutOwnership,
	recentProjectionCacheRetainsActiveAndConnectedTruth = recentProjectionCacheRetainsActiveAndConnectedTruth,
	resyncUsesExistingRouteAndServerAuthority = resyncUsesExistingRouteAndServerAuthority,
}
