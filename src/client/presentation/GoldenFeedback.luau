--!strict
-- Semantic decisions are pure; the native effect player is disposable.
local Feedback = {}
function Feedback.new()
	local previous = ""
	local terminalRevision = 0
	return {
		capture = function(state: any): string?
			local key = state.state
				.. ":"
				.. tostring(state.captureSessionId)
				.. ":"
				.. tostring(state.creatureInstanceId)
			if key == previous then
				return nil
			end
			previous = key
			if state.state == "Secured" then
				local revision = state.notificationRevision or 0
				if revision <= terminalRevision then
					return nil
				end
				terminalRevision = revision
				return "Secured"
			end
			if state.state == "Pending" then
				return "Engage"
			end
			if state.state == "TransportActive" then
				return "Containment"
			end
			if
				state.state == "Failed"
				or state.state == "Interrupted"
				or state.state == "Expired"
			then
				return "Failure"
			end
			return nil -- Unknown/pending persistence never implies ownership.
		end,
		reset = function()
			previous, terminalRevision = "", 0
		end,
	}
end
function Feedback.claim(amount: number, balance: number, reducedMotion: boolean): any
	return {
		from = balance - amount,
		to = balance,
		duration = if reducedMotion
			then 0
			else math.min(1.5, 0.6 + math.log10(math.max(1, amount)) * 0.2),
		strong = amount >= 25,
	}
end
return Feedback
