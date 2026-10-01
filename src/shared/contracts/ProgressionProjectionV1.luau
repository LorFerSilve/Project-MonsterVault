--!strict

local ProgressionProjectionV1 = {}
local MAX_EXACT = 9_007_199_254_740_991
local function integer(value: any, maximum: number): boolean
	return type(value) == "number" and value >= 0 and value <= maximum and value % 1 == 0
end
local function id(value: any, maximum: number): boolean
	return type(value) == "string" and #value > 0 and #value <= maximum
end
function ProgressionProjectionV1.validPurchase(payload: any, expectedRevision: any): boolean
	if
		type(payload) ~= "table"
		or not id(payload.unlockId, 128)
		or not id(payload.quoteId, 96)
		or not integer(payload.quoteRevision, MAX_EXACT)
		or payload.quoteRevision < 1
		or not integer(expectedRevision, MAX_EXACT)
		or expectedRevision < 1
	then
		return false
	end
	for key in payload do
		if key ~= "unlockId" and key ~= "quoteId" and key ~= "quoteRevision" then
			return false
		end
	end
	return true
end
function ProgressionProjectionV1.validSnapshot(payload: any): boolean
	if
		type(payload) ~= "table"
		or payload.domain ~= "progression"
		or not integer(payload.revision, MAX_EXACT)
		or payload.revision < 1
		or type(payload.state) ~= "table"
	then
		return false
	end
	for key in payload do
		if key ~= "domain" and key ~= "revision" and key ~= "state" then
			return false
		end
	end
	local s = payload.state
	if
		not id(s.unlockId, 128)
		or not integer(s.energyUnits, 1_000_000_000_000)
		or not integer(s.collectionCapacity, 2048)
		or type(s.owned) ~= "boolean"
		or (s.gateReason ~= "" and s.gateReason ~= "MISSING_MILESTONE" and s.gateReason ~= "ALREADY_OWNED")
		or type(s.receiptQuoteId) ~= "string"
		or #s.receiptQuoteId > 96
		or not integer(s.receiptExpectedRevision, MAX_EXACT)
		or not integer(s.receiptPriceUnits, 1_000_000_000_000)
	then
		return false
	end
	if
		s.receiptQuoteId ~= ""
		and (
			not s.owned
			or s.receiptExpectedRevision < 1
			or s.receiptExpectedRevision >= payload.revision
		)
	then
		return false
	end
	if s.receiptQuoteId == "" and (s.receiptExpectedRevision ~= 0 or s.receiptPriceUnits ~= 0) then
		return false
	end
	local q = s.quote
	if q ~= nil then
		if
			type(q) ~= "table"
			or s.owned
			or s.gateReason ~= ""
			or not id(q.quoteId, 96)
			or q.unlockId ~= s.unlockId
			or q.expectedRevision ~= payload.revision
			or not integer(q.quoteRevision, MAX_EXACT)
			or q.quoteRevision < 1
			or not integer(q.priceUnits, 1_000_000_000_000)
			or not id(q.configSnapshotId, 128)
			or q.expectedLevel ~= 0
			or not id(q.requiredMilestoneId, 128)
			or not integer(q.expiresUnixSeconds, MAX_EXACT)
		then
			return false
		end
		for key in q do
			if
				key ~= "quoteId"
				and key ~= "unlockId"
				and key ~= "quoteRevision"
				and key ~= "expectedRevision"
				and key ~= "priceUnits"
				and key ~= "configSnapshotId"
				and key ~= "expectedLevel"
				and key ~= "requiredMilestoneId"
				and key ~= "expiresUnixSeconds"
			then
				return false
			end
		end
	end
	for key in s do
		if
			key ~= "unlockId"
			and key ~= "energyUnits"
			and key ~= "collectionCapacity"
			and key ~= "owned"
			and key ~= "gateReason"
			and key ~= "receiptQuoteId"
			and key ~= "receiptExpectedRevision"
			and key ~= "receiptPriceUnits"
			and key ~= "quote"
		then
			return false
		end
	end
	return true
end
return table.freeze(ProgressionProjectionV1)
