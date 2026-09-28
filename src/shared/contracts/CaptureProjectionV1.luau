--!strict

-- Capture feedback is a full authoritative state, never an ownership grant.
local CaptureProjectionV1 = {}
local statuses = table.freeze({
	Idle = true,
	Claimed = true,
	TransportActive = true,
	FinalizationPending = true,
	Secured = true,
	Failed = true,
	Interrupted = true,
	Expired = true,
})
local fields = table.freeze({
	status = true,
	revision = true,
	captureSessionId = true,
	creatureInstanceId = true,
	custodyId = true,
	claimExpiresAt = true,
	profileRevision = true,
})

local function revision(value: any): boolean
	return type(value) == "number" and value >= 0 and value % 1 == 0 and value < math.huge
end

local function id(value: any): boolean
	return type(value) == "string" and #value > 0 and #value <= 96
end

function CaptureProjectionV1.validState(value: any): boolean
	if
		type(value) ~= "table"
		or not statuses[value.status]
		or not revision(value.revision)
		or value.revision < 1
	then
		return false
	end
	for key in value do
		if not fields[key] then
			return false
		end
	end
	if value.status == "Idle" then
		return value.captureSessionId == nil
			and value.creatureInstanceId == nil
			and value.custodyId == nil
			and value.claimExpiresAt == nil
			and value.profileRevision == nil
	end
	if not id(value.captureSessionId) or not id(value.creatureInstanceId) then
		return false
	end
	if value.custodyId ~= nil and not id(value.custodyId) then
		return false
	end
	if
		value.status == "TransportActive"
		or value.status == "FinalizationPending"
		or value.status == "Secured"
	then
		if not id(value.custodyId) then
			return false
		end
	end
	if value.claimExpiresAt ~= nil then
		if
			value.status ~= "Claimed"
			or type(value.claimExpiresAt) ~= "number"
			or value.claimExpiresAt ~= value.claimExpiresAt
			or math.abs(value.claimExpiresAt) == math.huge
		then
			return false
		end
	end
	if value.status == "Secured" then
		return revision(value.profileRevision)
	end
	return value.profileRevision == nil
end

return table.freeze(CaptureProjectionV1)
