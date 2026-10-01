--!strict

local ProgressionController = {}
function ProgressionController.new(options: {
	gateway: any,
	routes: any,
	projection: any,
	sessionReady: () -> boolean,
	clock: () -> number,
	onChanged: ((any) -> ())?,
})
	local snapshot: any = nil
	local reviewed: any = nil
	local pending: any = nil
	local pageRequest: any = nil
	local nextRefresh = 0
	local message = "Loading progression..."
	local function view(): any
		return {
			snapshot = snapshot,
			reviewed = reviewed,
			pending = pending ~= nil,
			message = message,
			canReview = snapshot ~= nil
				and snapshot.state.quote ~= nil
				and pending == nil
				and options.sessionReady(),
			canConfirm = reviewed ~= nil and pending == nil and options.sessionReady(),
		}
	end
	local function changed()
		if options.onChanged then
			options.onChanged(view())
		end
	end
	local function refresh()
		pageRequest = options.gateway.send(
			options.routes.commands.sessionRequestResync,
			{ domain = "progression" }
		)
		nextRefresh = options.clock() + 5
	end
	local function handleSnapshot(envelope: any): string
		if
			not options.projection.validSnapshot(envelope.payload)
			or envelope.revision ~= envelope.payload.revision
			or not options.sessionReady()
		then
			return "Invalid"
		end
		if snapshot ~= nil and envelope.revision < snapshot.revision then
			return "Stale"
		end
		if
			envelope.correlationId ~= pageRequest
			and (pending == nil or envelope.correlationId ~= pending.requestId)
		then
			return "Stale"
		end
		if pending ~= nil then
			local s = envelope.payload.state
			if
				s.receiptQuoteId == pending.quoteId
				and s.receiptExpectedRevision == pending.expectedRevision
			then
				message =
					string.format("Capacity upgrade saved: %d Energy spent.", s.receiptPriceUnits)
			elseif
				envelope.correlationId == pageRequest
				and options.gateway.resultFor(pending.requestId)
					== "PENDING_PROGRESSION_PURCHASE"
			then
				message = "Purchase was busy. Review a fresh quote."
			else
				return "Unconfirmed"
			end
			pending, reviewed = nil, nil
		end
		snapshot = envelope.payload
		if message == "Loading progression..." then
			message = "Review the price before confirming."
		end
		changed()
		return "Applied"
	end
	return {
		view = view,
		handleSnapshot = handleSnapshot,
		review = function()
			if not view().canReview then
				return
			end
			reviewed = table.clone(snapshot.state.quote)
			message = string.format("Add 6 Collection places for %d Energy?", reviewed.priceUnits)
			changed()
		end,
		confirm = function(): string?
			if not view().canConfirm then
				return nil
			end
			pageRequest = nil
			local request =
				options.gateway.send(options.routes.commands.progressionPurchaseUnlock, {
					unlockId = reviewed.unlockId,
					quoteId = reviewed.quoteId,
					quoteRevision = reviewed.quoteRevision,
				}, reviewed.expectedRevision)
			pending = {
				requestId = request,
				quoteId = reviewed.quoteId,
				expectedRevision = reviewed.expectedRevision,
			}
			message, nextRefresh = "Checking saved purchase...", options.clock() + 5
			changed()
			return request
		end,
		cancel = function()
			if pending == nil then
				reviewed = nil
				message = "Review the price before confirming."
				changed()
			end
		end,
		tick = function()
			if pending ~= nil then
				local code = options.gateway.resultFor(pending.requestId)
				if code ~= nil and string.sub(code, 1, 7) == "REJECT_" then
					pending, reviewed, message =
						nil, nil, "Purchase rejected. Review a fresh quote."
					refresh()
				end
			end
			if options.clock() >= nextRefresh then
				refresh()
			end
			changed()
		end,
	}
end
return ProgressionController
