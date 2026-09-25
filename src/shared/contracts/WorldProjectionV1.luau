--!strict

-- Public model attributes are presentation data only. A client cache built from
-- them never grants interaction, capture, or ownership authority.
local WorldProjectionV1 = {}

local function publicId(value: any): boolean
	return type(value) == "string" and #value > 0 and #value <= 96
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
		and value.Availability == "IdleAvailable"
end

return table.freeze(WorldProjectionV1)
