--!strict

-- Public model attributes are presentation data only. A client cache built from
-- them never grants interaction, capture, or ownership authority.
local WorldProjectionV1 = {}
local availability = table.freeze({
	IdleAvailable = true,
	Claimed = true,
	AttemptActive = true,
	Provisional = true,
	TransportActive = true,
	TransportGrace = true,
	FinalizationPending = true,
	Secured = true,
})

local function publicId(value: any): boolean
	return type(value) == "string" and #value > 0 and #value <= 96
end
local function optionalTime(value: any): boolean
	return value == nil or (type(value) == "number" and value >= 0 and value < math.huge)
end

function WorldProjectionV1.valid(value: any): boolean
	if type(value) ~= "table" then
		return false
	end
	for key in value do
		if
			key ~= "CreatureInstanceId"
			and key ~= "SpeciesId"
			and key ~= "RarityId"
			and key ~= "SpawnContextId"
			and key ~= "RuntimeRevision"
			and key ~= "Availability"
			and key ~= "LifetimeClass"
			and key ~= "AvailableAt"
			and key ~= "IdleExpiresAt"
		then
			return false
		end
	end
	return publicId(value.CreatureInstanceId)
		and publicId(value.SpeciesId)
		and publicId(value.RarityId)
		and publicId(value.SpawnContextId)
		and type(value.RuntimeRevision) == "number"
		and value.RuntimeRevision >= 1
		and value.RuntimeRevision % 1 == 0
		and value.RuntimeRevision < math.huge
		and availability[value.Availability] == true
		and (value.LifetimeClass == nil or value.LifetimeClass == "Ordinary" or value.LifetimeClass == "ProtectedVariant")
		and optionalTime(value.AvailableAt)
		and optionalTime(value.IdleExpiresAt)
		and (
			value.AvailableAt == nil
			or value.IdleExpiresAt == nil
			or value.IdleExpiresAt >= value.AvailableAt
		)
end

return table.freeze(WorldProjectionV1)
