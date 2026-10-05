--!strict

-- The fixture uses a server-only content snapshot until the content registry
-- arrives. Every draw is injected and made once when a world record is reserved.
local VariantIdentity = {}

local function draw(random: any): number
	local value = random.nextUnit()
	assert(
		type(value) == "number" and value == value and value >= 0 and value < 1,
		"invalid RNG draw"
	)
	return value
end

function VariantIdentity.generate(candidate: any, random: any): any
	assert(type(candidate) == "table", "candidate required")
	for _, key in { "speciesId", "rarityId", "contentSnapshotId", "spawnContextId" } do
		assert(
			type(candidate[key]) == "string" and candidate[key] ~= "",
			"invalid candidate identity"
		)
	end
	local mutations = {}
	if draw(random) < 0.25 then
		table.insert(mutations, "mutation/fixture-luminous")
	end
	local traits = {}
	if draw(random) < 0.5 then
		table.insert(traits, "trait/fixture-steady")
	end
	local signature = candidate.speciesId .. "|" .. table.concat(mutations, "+")
	return table.freeze({
		speciesRarityId = candidate.rarityId,
		mutationIdsCanonical = table.freeze(mutations),
		traitIds = table.freeze(traits),
		variantSignature = signature,
		contentSnapshotId = candidate.contentSnapshotId,
		spawnContextId = candidate.spawnContextId,
		protectedVariantReasons = table.freeze(
			if candidate.rarityId == "rarity/legendary"
				then { "protected-variant/legendary-species" }
				else {}
		),
	})
end

return VariantIdentity
