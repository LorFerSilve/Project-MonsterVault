--!strict

-- AD-255: immutable DEV content. Only the existing clearing is authored.
-- GDS-9 fixes the five roles; later biome placement remains an IMP-10 gate.
local entry, clearing = "landmark/fixture-entry", "landmark/fixture-clearing"
return {
	contentSnapshotId = "content-snapshot/imp10-world-dev-v1",
	regions = {
		{ id = "region/home-hub", role = "HomeHub" },
		{
			id = "region/fixture-clearing",
			role = "Starter",
			mastery = {
				milestoneId = "milestone/region-mastery/starter",
				landmarkIds = { entry, clearing },
				coreSpeciesIds = { "species/fixture-orb", "species/fixture-companion" },
				coreSpeciesThreshold = 1,
				objectiveIds = { "field-objective/fixture-return-route" },
			},
		},
		{ id = "region/biome-mid-a", role = "MidA", accessUnlockId = "access/biome-mid-a" },
		{ id = "region/biome-mid-b", role = "MidB", accessUnlockId = "access/biome-mid-b" },
		{
			id = "region/biome-advanced",
			role = "Advanced",
			accessUnlockId = "access/biome-advanced",
		},
	},
	species = {
		{ id = "species/fixture-orb", rarityId = "rarity/common" },
		{ id = "species/fixture-companion", rarityId = "rarity/common" },
	},
	habitats = { { id = "habitat/fixture-clearing", regionId = "region/fixture-clearing" } },
	spawnContexts = {
		{
			id = "spawn-context/fixture-clearing",
			habitatId = "habitat/fixture-clearing",
			speciesIds = { "species/fixture-orb", "species/fixture-companion" },
			contentSnapshotIds = {
				"content-snapshot/imp5-fixture-v1", -- Immutable historic provenance binding.
				"content-snapshot/imp10-world-dev-v1",
			},
		},
	},
	landmarks = {
		{ id = entry, regionId = "region/fixture-clearing", radius = 8 },
		{ id = clearing, regionId = "region/fixture-clearing", radius = 6 },
	},
	objectives = {
		{
			id = "field-objective/fixture-return-route",
			regionId = "region/fixture-clearing",
			kind = "TraversalSequence",
			landmarkIds = { entry, clearing, entry },
		},
	},
}
