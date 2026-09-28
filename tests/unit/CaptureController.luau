--!strict

local CaptureController = require("../../src/client/controllers/CaptureController")
local CaptureProjectionV1 = require("../../src/shared/contracts/CaptureProjectionV1")
local RouteIds = require("../../src/shared/contracts/RouteIds")

local function harness(): any
	local now, ready, available = 0, true, true
	local requests, retries, changes, results = {}, {}, {}, {}
	local controller = CaptureController.new({
		gateway = {
			send = function(routeId: string, payload: any): string
				local requestId = "request-" .. tostring(#requests + 1)
				table.insert(
					requests,
					{ routeId = routeId, payload = table.clone(payload), requestId = requestId }
				)
				return requestId
			end,
			resend = function(requestId: string)
				table.insert(retries, requestId)
			end,
			resultFor = function(requestId: string): string?
				return results[requestId]
			end,
		},
		routes = RouteIds,
		captureProjection = CaptureProjectionV1,
		sessionReady = function(): boolean
			return ready
		end,
		actionAvailable = function(creatureId: string?): boolean
			assert(creatureId == "creature-a", "reachability checks the server claim creature")
			return available
		end,
		clock = function(): number
			return now
		end,
		onChanged = function(value: any)
			table.insert(changes, value)
		end,
	})
	return {
		controller = controller,
		requests = requests,
		retries = retries,
		results = results,
		changes = changes,
		advance = function(seconds: number)
			now += seconds
			controller.tick()
		end,
		ready = function(value: boolean)
			ready = value
			controller.tick()
		end,
		available = function(value: boolean)
			available = value
			controller.tick()
		end,
	}
end

local function captureState(status: string, revision: number, captureId: string?): any
	if status == "Idle" then
		return { status = status, revision = revision }
	end
	local state: any = {
		status = status,
		revision = revision,
		captureSessionId = captureId or "capture-a",
		creatureInstanceId = "creature-a",
	}
	if status == "Claimed" then
		state.claimExpiresAt = 30
	elseif
		status == "TransportActive"
		or status == "FinalizationPending"
		or status == "Secured"
	then
		state.custodyId = "custody-a"
		if status == "Secured" then
			state.profileRevision = 8
		end
	end
	return state
end

local function duplicateAndTimeoutRetainRequestIdentity()
	local h = harness()
	h.controller.setTarget("creature-a")
	assert(h.controller.activate(), "one semantic activation sends a claim")
	assert(not h.controller.activate(), "rapid duplicate activation is blocked")
	assert(#h.requests == 1, "only one new claim envelope")
	h.advance(4)
	assert(h.controller.view().state == "OutcomeUnknown", "timeout is an unknown outcome")
	assert(not h.controller.activate(), "unknown claim blocks a blind second claim")
	assert(h.retries[1] == "request-1", "retry uses the original request identity")
	assert(
		h.requests[2].routeId == RouteIds.commands.sessionRequestResync,
		"capture refresh is requested"
	)
	assert(h.requests[2].payload.domain == "capture", "owning domain is refreshed")
	h.advance(1)
	assert(
		#h.retries == 1 and #h.requests == 2,
		"recovery is bounded to one attempt per five seconds"
	)
	h.advance(4)
	assert(
		#h.retries == 2 and h.retries[2] == "request-1",
		"continued recovery keeps the original claim"
	)
	assert(
		h.controller.view().state ~= "Failed" and h.controller.view().state ~= "Secured",
		"elapsed time never invents an outcome"
	)
	h.advance(92)
	assert(
		#h.retries == 2 and #h.requests == 4,
		"after replay safety expires only authoritative resync continues"
	)
	assert(not h.controller.activate(), "long uncertainty still blocks new capture commands")
end

local function lostReplyResyncReconstructsClaimAndDurableOutcome()
	local h = harness()
	h.controller.handleCapture(captureState("Idle", 1))
	h.controller.setTarget("creature-a")
	h.controller.activate()
	h.advance(4)
	assert(
		h.controller.handleCapture(captureState("Claimed", 2), nil, "request-2") == "Applied",
		"lost claim restored by resync"
	)
	assert(h.controller.view().captureSessionId == "capture-a", "server-issued claim retained")
	assert(
		h.controller.view().creatureInstanceId == "creature-a",
		"server creature is exposed without recursive view reads"
	)
	h.controller.setTarget(nil)
	assert(h.controller.activate(), "claim action does not depend on nearest idle target")
	local submit = h.requests[3]
	assert(submit.routeId == RouteIds.commands.captureSubmitAction, "semantic capture submit")
	assert(
		submit.payload.captureSessionId == "capture-a" and submit.payload.clientSequence == 1,
		"server claim identity used"
	)
	h.advance(4)
	assert(
		h.controller.handleCapture(captureState("FinalizationPending", 4), nil, "request-4")
			== "Applied",
		"lost submit reconstructed"
	)
	assert(
		h.controller.view().state == "FinalizationPending" and not h.controller.view().canActivate,
		"saving remains non-owned and blocked"
	)
	assert(
		h.controller.handleCapture(captureState("Secured", 5)) == "Applied",
		"durable terminal projection received"
	)
	assert(h.controller.view().state == "Secured", "only durable server state declares secured")
end

local function staleTerminalCannotReplaceNewClaim()
	local h = harness()
	h.controller.handleCapture(captureState("Secured", 5, "capture-old"))
	h.controller.setTarget("creature-a")
	h.controller.activate()
	assert(
		h.controller.handleCapture(captureState("Secured", 5, "capture-old")) == "Stale",
		"old secured replay cannot satisfy new command"
	)
	assert(h.controller.view().state == "Pending", "new claim remains pending")
	assert(
		h.controller.handleCapture(captureState("Claimed", 6, "capture-new")) == "Applied",
		"new server claim acknowledged"
	)
	assert(
		h.controller.handleCapture(captureState("Secured", 5, "capture-old")) == "Stale",
		"late older terminal rejected"
	)
	assert(
		h.controller.view().state == "Claimed"
			and h.controller.view().captureSessionId == "capture-new",
		"new identity remains current"
	)
end

local function equalRevisionResyncProvesNotApplied()
	local h = harness()
	h.controller.handleCapture(captureState("Idle", 1))
	h.controller.setTarget("creature-a")
	h.controller.activate()
	h.advance(4)
	assert(
		h.controller.handleCapture(captureState("Idle", 1)) == "Stale",
		"unrelated equal snapshot cannot clear pending"
	)
	assert(
		h.controller.handleCapture(captureState("Idle", 1), nil, "request-2") == "Applied",
		"ordered resync proves no transition"
	)
	assert(
		h.controller.view().state == "Idle" and h.controller.view().canActivate,
		"known non-application permits a fresh action"
	)
	assert(
		h.controller.view().message == "The server did not apply this action. You can try again.",
		"non-application is explicit"
	)
	local prior = harness()
	prior.controller.handleCapture(captureState("Secured", 5, "capture-old"))
	prior.controller.setTarget("creature-a")
	prior.controller.activate()
	prior.advance(4)
	prior.controller.handleCapture(captureState("Secured", 5, "capture-old"), nil, "request-2")
	assert(
		prior.controller.view().message
			== "The server did not apply this action. You can try again.",
		"prior secured capture cannot imply new success"
	)
	assert(
		prior.controller.view().notification == nil,
		"prior secured capture does not emit a new success notification"
	)
end

local function profileTargetAndStreamoutGateActions()
	local h = harness()
	assert(not h.controller.activate(), "no context target blocks claim")
	h.controller.setTarget("creature-a")
	h.ready(false)
	assert(not h.controller.activate() and #h.requests == 0, "protected profile blocks claim")
	h.ready(true)
	assert(h.controller.activate(), "ready profile and target allows claim")
	h.controller.handleCapture(captureState("Claimed", 2), nil, "request-1")
	h.available(false)
	assert(not h.controller.activate(), "claim streamed out or out of reach blocks submit")
	assert(h.controller.view().state == "Claimed", "streamout cannot invent claim expiry")
	h.available(true)
	h.ready(false)
	assert(not h.controller.activate(), "protected profile blocks submit")
	h.ready(true)
	assert(h.controller.activate(), "restored reachable claim allows submit")
end

local function acknowledgmentsDoNotInventAuthorityAndNotificationsDedupe()
	local unavailable = harness()
	unavailable.controller.setTarget("creature-a")
	unavailable.controller.activate()
	unavailable.results["request-1"] = "UNAVAILABLE_ROUTE"
	unavailable.controller.tick()
	assert(
		unavailable.controller.view().state == "OutcomeUnknown",
		"handler failure can occur after mutation"
	)
	assert(
		not unavailable.controller.activate(),
		"handler failure cannot unlock a blind second action"
	)
	assert(
		unavailable.requests[2].payload.domain == "capture",
		"handler failure refreshes canonical capture"
	)
	local h = harness()
	h.controller.setTarget("creature-a")
	h.controller.activate()
	h.results["request-1"] = "OK_CAPTURE_CLAIMED"
	h.controller.tick()
	assert(
		h.controller.view().state == "Pending" and h.controller.view().captureSessionId == nil,
		"result alone cannot invent a claim ID"
	)
	assert(#h.requests == 2, "acknowledged command requests its lost projection")
	h.controller.handleCapture(captureState("Claimed", 2), nil, "request-2")
	h.controller.activate()
	h.controller.handleCapture(captureState("TransportActive", 3), nil, "request-3")
	local count = #h.changes
	local revision = h.controller.view().notificationRevision
	h.controller.handleCapture(captureState("TransportActive", 4))
	assert(
		h.controller.view().notificationRevision == revision and #h.changes == count,
		"same authoritative state does not repeat notification"
	)
	h.controller.handleCapture(captureState("Secured", 5))
	assert(
		h.controller.view().notificationRevision == 5
			and h.controller.view().notification == "Capture secured",
		"durable transition gets one notification"
	)
	count = #h.changes
	h.controller.tick()
	assert(#h.changes == count, "unchanged tick does not redraw or notify")
end

local function rejectionAndMalformedProjectionRemainTruthful()
	local readiness = harness()
	readiness.controller.setTarget("creature-a")
	readiness.controller.activate()
	readiness.results["request-1"] = "REJECT_STATE_NOT_READY"
	readiness.controller.tick()
	assert(
		readiness.requests[2].payload.domain == "session",
		"readiness rejection refreshes stale profile readiness"
	)
	readiness.controller.tick()
	assert(#readiness.requests == 2, "readiness refresh is sent once per rejected command")
	readiness.ready(false)
	assert(not readiness.controller.activate(), "protected snapshot blocks further capture actions")
	local h = harness()
	h.controller.setTarget("creature-a")
	h.controller.activate()
	local malformed = captureState("Secured", 3)
	malformed.profileRevision = nil
	assert(h.controller.handleCapture(malformed) == "Invalid", "incomplete secured state rejected")
	assert(
		h.controller.handleCapture(captureState("Secured", 3), 4) == "Invalid",
		"conflicting envelope revision rejected"
	)
	assert(h.controller.view().state == "Pending", "invalid data does not declare success")
	h.results["request-1"] = "REJECT_VALIDATION_PAYLOAD"
	h.controller.tick()
	assert(
		h.controller.view().state == "Idle" and h.controller.view().canActivate,
		"known rejection permits another action"
	)
	assert(h.controller.view().notification == nil, "rejection does not emit durable success")
	h.controller.reset()
	assert(
		h.controller.view().state == "Idle" and h.controller.view().targetId == nil,
		"reset discards disposable presentation"
	)
end

local function captureRejectionsReconcileLostTerminalEvents()
	local invalidated = harness()
	invalidated.controller.handleCapture(captureState("Claimed", 2))
	assert(invalidated.controller.activate(), "claimed creature can be submitted")
	invalidated.results["request-1"] = "REJECT_STATE_CAPTURE_INVALIDATED"
	invalidated.controller.tick()
	assert(
		invalidated.controller.view().state == "OutcomeUnknown"
			and not invalidated.controller.activate(),
		"invalidated result cannot re-enable a stale claim when its event is lost"
	)
	assert(invalidated.requests[2].payload.domain == "capture", "invalidated claim resyncs")
	assert(
		invalidated.controller.handleCapture(captureState("Interrupted", 3), nil, "request-2")
				== "Applied"
			and invalidated.controller.view().state == "Interrupted",
		"server interruption resolves the unknown result"
	)

	local expired = harness()
	expired.controller.handleCapture(captureState("Idle", 1))
	expired.controller.setTarget("creature-a")
	assert(expired.controller.activate(), "available creature can be claimed")
	expired.results["request-1"] = "REJECT_STATE_CAPTURE_EXPIRED"
	expired.controller.tick()
	assert(
		expired.controller.view().state == "OutcomeUnknown" and not expired.controller.activate(),
		"expired resume result cannot be treated as an unchanged world"
	)
	assert(expired.requests[2].payload.domain == "capture", "expired claim resyncs")
	assert(
		expired.controller.handleCapture(captureState("Expired", 2), nil, "request-2") == "Applied"
			and expired.controller.view().state == "Expired",
		"server expiry resolves the unknown result"
	)
end

return {
	duplicateAndTimeoutRetainRequestIdentity = duplicateAndTimeoutRetainRequestIdentity,
	lostReplyResyncReconstructsClaimAndDurableOutcome = lostReplyResyncReconstructsClaimAndDurableOutcome,
	staleTerminalCannotReplaceNewClaim = staleTerminalCannotReplaceNewClaim,
	equalRevisionResyncProvesNotApplied = equalRevisionResyncProvesNotApplied,
	profileTargetAndStreamoutGateActions = profileTargetAndStreamoutGateActions,
	acknowledgmentsDoNotInventAuthorityAndNotificationsDedupe = acknowledgmentsDoNotInventAuthorityAndNotificationsDedupe,
	rejectionAndMalformedProjectionRemainTruthful = rejectionAndMalformedProjectionRemainTruthful,
	captureRejectionsReconcileLostTerminalEvents = captureRejectionsReconcileLostTerminalEvents,
}
