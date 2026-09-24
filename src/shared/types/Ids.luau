--!strict

-- Public identity names remain separate from their authority. Runtime IDs and
-- durable operation IDs are created by the server, never accepted as authority
-- merely because they are syntactically well formed.
export type StaticContentId = string
export type SpeciesId = string
export type MutationId = string
export type TraitId = string
export type RarityId = string
export type RegionId = string
export type LandmarkId = string
export type SpawnContextId = string
export type EventTemplateId = string
export type EventObjectiveDefinitionId = string
export type CosmeticDefinitionId = string
export type ProductDefinitionId = string
export type CapacityUpgradeDefinitionId = string

export type CreatureInstanceId = string
export type EncounterInstanceId = string
export type CaptureClaimId = string
export type TradeSessionId = string
export type PartyId = string
export type RuntimeEventInstanceId = string

export type OperationId = string
export type TradeTransactionId = string
export type CommercialGrantOperationId = string
export type EventRewardOperationId = string
export type ContentSnapshotId = string

local Ids = {}

local function validSegment(segment: string): boolean
	return string.match(segment, "^[a-z][a-z0-9-]*$") ~= nil
		and string.sub(segment, -1) ~= "-"
		and string.find(segment, "--", 1, true) == nil
end

-- Checks only the public TA-5 grammar and optional kind. Registry membership,
-- lifecycle and permission checks remain server-owned.
function Ids.isStaticContentId(value: unknown, expectedKind: string?): boolean
	if type(value) ~= "string" or #value == 0 then
		return false
	end

	local segments = string.split(value, "/")
	if #segments < 2 then
		return false
	end
	for _, segment in segments do
		if not validSegment(segment) then
			return false
		end
	end
	return expectedKind == nil or (validSegment(expectedKind) and segments[1] == expectedKind)
end

return table.freeze(Ids)
