--!strict

-- Disposable presentation of server capture state. A command timeout never
-- proves capture failure, custody or durable ownership.
local CaptureController = {}

local REQUEST_SECONDS = 4
local RECOVERY_SECONDS = 5
-- Server replay identities are retained for 120 seconds. Leave margin and
-- keep refreshing state after retries can no longer be proven idempotent.
local RESEND_SECONDS = 90

function CaptureController.new(options: {
	gateway: any,
	routes: any,
	captureProjection: any,
	sessionReady: () -> boolean,
	clock: () -> number,
	actionAvailable: ((string?) -> boolean)?,
	onChanged: ((any) -> ())?,
})
	local targetId: string? = nil
	local capture: any = { status = "Idle", revision = 0 }
	local pending: any = nil
	local feedback: string? = nil
	local notification: string? = nil
	local notificationRevision: number? = nil
	local lastView: any = nil

	local function view(): any
		local ready = options.sessionReady()
		local state = if pending then pending.state else capture.status
		local heading, message, actionLabel =
			"Capture", "Approach a creature to begin.", "Start capture"
		local canActivate = ready and pending == nil
		if state == "Pending" then
			heading, message = "Waiting for the server", "Your capture action is being checked."
			canActivate = false
		elseif state == "OutcomeUnknown" then
			heading, message =
				"Checking capture outcome",
				"The reply is delayed. Waiting for the server to confirm."
			canActivate = false
		elseif state == "Claimed" then
			heading, message, actionLabel =
				"Creature claimed", "Press Capture to attempt this creature.", "Capture"
			canActivate = canActivate
				and (
					options.actionAvailable == nil
					or options.actionAvailable(capture.creatureInstanceId)
				)
			if not canActivate and ready then
				message = "Return within reach of your claimed creature."
			end
		elseif state == "TransportActive" then
			heading, message =
				"Bring it to safety", "Carry the creature to the secure point. It is not owned yet."
			canActivate = false
		elseif state == "FinalizationPending" then
			heading, message = "Saving capture", "Waiting for durable ownership confirmation."
			canActivate = false
		elseif state == "Secured" then
			heading, message =
				"Capture secured", "The server confirmed this creature is saved in your collection."
		elseif state == "Failed" then
			heading, message =
				"Capture failed",
				"The creature escaped. Approach an available creature to try again."
		elseif state == "Interrupted" then
			heading, message =
				"Capture interrupted",
				"This capture ended. Approach an available creature to start again."
		elseif state == "Expired" then
			heading, message =
				"Capture expired",
				"This claim ended. Approach an available creature to start again."
		end
		if capture.status ~= "Claimed" then
			canActivate = canActivate and targetId ~= nil
		end
		if not ready then
			canActivate = false
			message = "Your profile is not ready. Capture actions are unavailable."
		elseif feedback ~= nil and pending == nil then
			message = feedback
		end
		return {
			state = state,
			heading = heading,
			message = message,
			actionLabel = actionLabel,
			canActivate = canActivate,
			targetId = targetId,
			creatureInstanceId = capture.creatureInstanceId,
			captureSessionId = capture.captureSessionId,
			custodyId = capture.custodyId,
			notification = notification,
			notificationRevision = notificationRevision,
		}
	end

	local function changed()
		local nextView = view()
		if lastView ~= nil then
			local same = true
			for key, value in nextView do
				if lastView[key] ~= value then
					same = false
					break
				end
			end
			for key, value in lastView do
				if nextView[key] ~= value then
					same = false
					break
				end
			end
			if same then
				return
			end
		end
		lastView = nextView
		if options.onChanged ~= nil then
			options.onChanged(table.clone(nextView))
		end
	end

	local function resync()
		pending.resyncId = options.gateway.send(options.routes.commands.sessionRequestResync, {
			domain = "capture",
			knownRevision = capture.revision,
		})
		pending.nextRecoveryAt = options.clock() + RECOVERY_SECONDS
	end

	local function activate(): boolean
		if not view().canActivate then
			return false
		end
		local isSubmit = capture.status == "Claimed"
		local routeId = if isSubmit
			then options.routes.commands.captureSubmitAction
			else options.routes.commands.interactionPrimaryInteract
		local payload = if isSubmit
			then {
				captureSessionId = capture.captureSessionId,
				actionId = "capture",
				clientSequence = 1,
			}
			else { interactionId = targetId }
		pending = {
			state = "Pending",
			kind = if isSubmit then "submit" else "claim",
			creatureId = if isSubmit then capture.creatureInstanceId else targetId,
			captureSessionId = capture.captureSessionId,
			baselineRevision = capture.revision,
			resendUntil = options.clock() + RESEND_SECONDS,
			timeoutAt = options.clock() + REQUEST_SECONDS,
			nextRecoveryAt = options.clock() + REQUEST_SECONDS,
		}
		feedback, notification, notificationRevision = nil, nil, nil
		pending.requestId = options.gateway.send(routeId, payload)
		changed()
		return true
	end

	local function handleCapture(
		payload: any,
		envelopeRevision: number?,
		correlationId: string?
	): string
		if not options.captureProjection.validState(payload) then
			return "Invalid"
		end
		if envelopeRevision ~= nil and envelopeRevision ~= payload.revision then
			return "Invalid"
		end
		if payload.revision < capture.revision then
			return "Stale"
		end
		local isRecovery = pending ~= nil
			and correlationId ~= nil
			and correlationId == pending.resyncId
		local correlated = pending ~= nil
			and correlationId ~= nil
			and correlationId == pending.requestId
		if payload.revision == capture.revision and not isRecovery and not correlated then
			return "Stale"
		end
		local notApplied = false
		if pending ~= nil then
			local matches = payload.creatureInstanceId == pending.creatureId
			if pending.kind == "submit" then
				matches = matches
					and payload.captureSessionId == pending.captureSessionId
					and payload.status ~= "Claimed"
			else
				matches = matches and payload.captureSessionId ~= pending.captureSessionId
			end
			local completed = isRecovery
				or (payload.revision > pending.baselineRevision and (matches or correlated))
			if completed then
				notApplied = not matches
				pending = nil
			end
		end
		local transition = payload.status ~= capture.status
			or payload.captureSessionId ~= capture.captureSessionId
		capture = table.clone(payload)
		if transition then
			feedback = nil
			if
				pending == nil
				and not notApplied
				and payload.status ~= "Idle"
				and payload.status ~= "Claimed"
			then
				notification = view().heading
				notificationRevision = payload.revision
			end
		end
		if notApplied then
			feedback = "The server did not apply this action. You can try again."
		end
		changed()
		return "Applied"
	end

	local function tick()
		if pending ~= nil then
			local code = options.gateway.resultFor(pending.requestId)
			if code ~= nil and code ~= pending.lastResult then
				pending.lastResult = code
				if
					string.sub(code, 1, 21) == "REJECT_STATE_CAPTURE_"
					or string.sub(code, 1, 12) == "UNAVAILABLE_"
					or string.sub(code, 1, 16) == "OUTCOME_UNKNOWN_"
					or string.sub(code, 1, 10) == "PROTECTED_"
				then
					-- Capture can expire or be invalidated before a rejection is sent.
					-- A handler can also fail after applying state. Reconcile either case.
					pending.state = "OutcomeUnknown"
					resync()
				elseif string.sub(code, 1, 7) == "REJECT_" then
					if code == "REJECT_STATE_NOT_READY" then
						options.gateway.send(
							options.routes.commands.sessionRequestResync,
							{ domain = "session" }
						)
					end
					feedback =
						"The server could not accept this action. Check your target and try again."
					pending = nil
				elseif string.sub(code, 1, 3) == "OK_" then
					-- A result acknowledges processing, but never invents the capture
					-- session/custody IDs or durable ownership projection.
					resync()
				end
			end
			if pending ~= nil and options.clock() >= pending.timeoutAt then
				pending.state = "OutcomeUnknown"
				if options.clock() >= pending.nextRecoveryAt then
					if options.clock() < pending.resendUntil then
						options.gateway.resend(pending.requestId)
					end
					resync()
				end
			end
		end
		changed()
	end

	return {
		view = view,
		activate = activate,
		tick = tick,
		handleCapture = handleCapture,
		setTarget = function(id: string?)
			targetId = if type(id) == "string" and #id > 0 and #id <= 96 then id else nil
			changed()
		end,
		reset = function()
			targetId, pending, feedback, notification, notificationRevision, lastView =
				nil, nil, nil, nil, nil, nil
			capture = { status = "Idle", revision = 0 }
			changed()
		end,
	}
end

return CaptureController
