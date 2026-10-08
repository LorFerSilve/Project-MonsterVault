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
-- Local visual offsets only. The gameplay root and capture range never move.
function Feedback.pose(
	role: string,
	time: number,
	phase: number,
	reaction: number,
	reduced: boolean
): (number, number, number, number)
	if reduced then
		return 0, 0, 0, 0
	end
	local legendary = role == "legendary"
	local breath = math.sin(time * 1.7 + phase)
	local glance = math.sin(time * 0.65 + phase)
	return (if legendary then 0.12 else 0.07) * breath,
		0.025 * breath + reaction,
		0.09 * glance ^ 3,
		(if legendary then 0.045 else 0.02) * math.sin(time * 1.1 + phase)
end
return Feedback
