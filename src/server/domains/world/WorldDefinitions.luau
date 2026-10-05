--!strict

-- AD-256: canonical DEV authored roles, pools, active routes and safe utilities.
-- Historic Starter IDs/provenance remain valid; one fixed active objective reward.
local config = {
	contentSnapshotId = "content-snapshot/imp10-world-dev-v2",
	authoringVersion = 1,
	worldReward = {
		id = "world-reward/starter-return-dev-v1",
		objectiveId = "field-objective/fixture-return-route",
		completionProgress = 3,
		energyUnits = 5,
		configSnapshotId = "content-snapshot/world-reward-starter-dev-v1",
	},
	-- One optional, visibly marked DEV exposure pocket; no reward or travel edge.
	hazards = {
		{
			id = "hazard/starter-corrosive-dev-v1",
			regionId = "region/fixture-clearing",
			consequence = "Recovery",
			warningText = "CORROSIVE PATCH\nEntry causes recovery.\nCarried capture is interrupted.",
		},
	},
	regions = {
		{
			id = "region/home-hub",
			role = "HomeHub",
			neighborIds = { "region/fixture-clearing" },
		},
		{
			id = "region/fixture-clearing",
			role = "Starter",
			neighborIds = { "region/home-hub", "region/biome-mid-a", "region/biome-mid-b" },
			entryOutpostId = "safe-outpost/starter-entry",
			mastery = {
				milestoneId = "milestone/region-mastery/starter",
				contentSnapshotIds = {
					"content-snapshot/imp10-world-dev-v1",
					"content-snapshot/imp10-world-dev-v2",
				},
				landmarkIds = { "landmark/fixture-entry", "landmark/fixture-clearing" },
				coreSpeciesIds = { "species/fixture-orb", "species/fixture-companion" },
				coreSpeciesThreshold = 1,
				objectiveIds = { "field-objective/fixture-return-route" },
			},
		},
		{
			id = "region/biome-mid-a",
			role = "MidA",
			neighborIds = { "region/fixture-clearing", "region/biome-advanced" },
			accessUnlockId = "access/biome-mid-a",
			entryOutpostId = "safe-outpost/mid-a-entry",
			mastery = {
				milestoneId = "milestone/region-mastery/mid-a",
				contentSnapshotIds = { "content-snapshot/imp10-world-dev-v2" },
				landmarkIds = { "landmark/mid-a-entry", "landmark/mid-a-field" },
				coreSpeciesIds = { "species/fixture-orb", "species/field-pebble" },
				coreSpeciesThreshold = 1,
				objectiveIds = { "field-objective/mid-a-route" },
			},
		},
		{
			id = "region/biome-mid-b",
			role = "MidB",
			neighborIds = { "region/fixture-clearing", "region/biome-advanced" },
			accessUnlockId = "access/biome-mid-b",
			entryOutpostId = "safe-outpost/mid-b-entry",
			mastery = {
				milestoneId = "milestone/region-mastery/mid-b",
				contentSnapshotIds = { "content-snapshot/imp10-world-dev-v2" },
				landmarkIds = { "landmark/mid-b-entry", "landmark/mid-b-field" },
				coreSpeciesIds = { "species/fixture-orb", "species/field-leaf" },
				coreSpeciesThreshold = 1,
				objectiveIds = { "field-objective/mid-b-route" },
			},
		},
		{
			id = "region/biome-advanced",
			role = "Advanced",
			neighborIds = { "region/biome-mid-a", "region/biome-mid-b" },
			accessUnlockId = "access/biome-advanced",
			entryOutpostId = "safe-outpost/advanced-entry",
			mastery = {
				milestoneId = "milestone/region-mastery/advanced",
				contentSnapshotIds = { "content-snapshot/imp10-world-dev-v2" },
				landmarkIds = { "landmark/advanced-entry", "landmark/advanced-field" },
				coreSpeciesIds = {
					"species/fixture-orb",
					"species/fixture-companion",
					"species/field-pebble",
					"species/field-leaf",
				},
				coreSpeciesThreshold = 1,
				objectiveIds = { "field-objective/advanced-route" },
			},
		},
	},
	species = {
		{
			id = "species/fixture-orb",
			rarityId = "rarity/common",
		},
		{
			id = "species/fixture-companion",
			rarityId = "rarity/common",
		},
		{
			id = "species/field-pebble",
			rarityId = "rarity/common",
		},
		{
			id = "species/field-leaf",
			rarityId = "rarity/common",
		},
	},
	habitats = {
		{
			id = "habitat/fixture-clearing",
			regionId = "region/fixture-clearing",
		},
		{
			id = "habitat/starter-field",
			regionId = "region/fixture-clearing",
		},
		{
			id = "habitat/mid-a",
			regionId = "region/biome-mid-a",
		},
		{
			id = "habitat/mid-a-edge",
			regionId = "region/biome-mid-a",
		},
		{
			id = "habitat/mid-b",
			regionId = "region/biome-mid-b",
		},
		{
			id = "habitat/mid-b-edge",
			regionId = "region/biome-mid-b",
		},
		{
			id = "habitat/advanced",
			regionId = "region/biome-advanced",
		},
		{
			id = "habitat/advanced-edge",
			regionId = "region/biome-advanced",
		},
	},
	spawnContexts = {
		{
			id = "spawn-context/fixture-clearing",
			habitatId = "habitat/fixture-clearing",
			speciesIds = { "species/fixture-orb", "species/fixture-companion" },
			contentSnapshotIds = {
				"content-snapshot/imp5-fixture-v1",
				"content-snapshot/imp10-world-dev-v1",
				"content-snapshot/imp10-world-dev-v2",
			},
		},
		{
			id = "spawn-context/starter-field",
			habitatId = "habitat/starter-field",
			speciesIds = { "species/fixture-orb", "species/fixture-companion" },
			contentSnapshotIds = { "content-snapshot/imp10-world-dev-v2" },
		},
		{
			id = "spawn-context/mid-a",
			habitatId = "habitat/mid-a",
			speciesIds = { "species/fixture-orb", "species/field-pebble" },
			contentSnapshotIds = { "content-snapshot/imp10-world-dev-v2" },
		},
		{
			id = "spawn-context/mid-a-edge",
			habitatId = "habitat/mid-a-edge",
			speciesIds = { "species/fixture-orb", "species/field-pebble" },
			contentSnapshotIds = { "content-snapshot/imp10-world-dev-v2" },
		},
		{
			id = "spawn-context/mid-b",
			habitatId = "habitat/mid-b",
			speciesIds = { "species/fixture-orb", "species/field-leaf" },
			contentSnapshotIds = { "content-snapshot/imp10-world-dev-v2" },
		},
		{
			id = "spawn-context/mid-b-edge",
			habitatId = "habitat/mid-b-edge",
			speciesIds = { "species/fixture-orb", "species/field-leaf" },
			contentSnapshotIds = { "content-snapshot/imp10-world-dev-v2" },
		},
		{
			id = "spawn-context/advanced",
			habitatId = "habitat/advanced",
			speciesIds = {
				"species/fixture-orb",
				"species/fixture-companion",
				"species/field-pebble",
				"species/field-leaf",
			},
			contentSnapshotIds = { "content-snapshot/imp10-world-dev-v2" },
		},
		{
			id = "spawn-context/advanced-edge",
			habitatId = "habitat/advanced-edge",
			speciesIds = {
				"species/fixture-orb",
				"species/fixture-companion",
				"species/field-pebble",
				"species/field-leaf",
			},
			contentSnapshotIds = { "content-snapshot/imp10-world-dev-v2" },
		},
	},
	landmarks = {
		{
			id = "landmark/fixture-clearing",
			regionId = "region/fixture-clearing",
			radius = 6,
			label = "Starter field",
		},
		{
			id = "landmark/starter-field",
			regionId = "region/fixture-clearing",
			radius = 6,
			label = "Starter field",
		},
		{
			id = "landmark/mid-a-field",
			regionId = "region/biome-mid-a",
			radius = 6,
			label = "MidA field",
		},
		{
			id = "landmark/mid-a-edge",
			regionId = "region/biome-mid-a",
			radius = 6,
			label = "MidA edge",
		},
		{
			id = "landmark/mid-b-field",
			regionId = "region/biome-mid-b",
			radius = 6,
			label = "MidB field",
		},
		{
			id = "landmark/mid-b-edge",
			regionId = "region/biome-mid-b",
			radius = 6,
			label = "MidB edge",
		},
		{
			id = "landmark/advanced-field",
			regionId = "region/biome-advanced",
			radius = 6,
			label = "Advanced field",
		},
		{
			id = "landmark/advanced-edge",
			regionId = "region/biome-advanced",
			radius = 6,
			label = "Advanced edge",
		},
		{
			id = "landmark/fixture-entry",
			regionId = "region/fixture-clearing",
			radius = 8,
			label = "Starter entry",
		},
		{
			id = "landmark/mid-a-entry",
			regionId = "region/biome-mid-a",
			radius = 8,
			label = "MidA entry",
		},
		{
			id = "landmark/mid-b-entry",
			regionId = "region/biome-mid-b",
			radius = 8,
			label = "MidB entry",
		},
		{
			id = "landmark/advanced-entry",
			regionId = "region/biome-advanced",
			radius = 8,
			label = "Advanced entry",
		},
	},
	objectives = {
		{
			id = "field-objective/fixture-return-route",
			regionId = "region/fixture-clearing",
			kind = "TraversalSequence",
			landmarkIds = {
				"landmark/fixture-entry",
				"landmark/fixture-clearing",
				"landmark/fixture-entry",
			},
		},
		{
			id = "field-objective/mid-a-route",
			regionId = "region/biome-mid-a",
			kind = "TraversalSequence",
			landmarkIds = { "landmark/mid-a-entry", "landmark/mid-a-field", "landmark/mid-a-entry" },
		},
		{
			id = "field-objective/mid-b-route",
			regionId = "region/biome-mid-b",
			kind = "TraversalSequence",
			landmarkIds = { "landmark/mid-b-entry", "landmark/mid-b-field", "landmark/mid-b-entry" },
		},
		{
			id = "field-objective/advanced-route",
			regionId = "region/biome-advanced",
			kind = "TraversalSequence",
			landmarkIds = {
				"landmark/advanced-entry",
				"landmark/advanced-field",
				"landmark/advanced-entry",
			},
		},
	},
	safeOutposts = {
		{
			id = "safe-outpost/starter-entry",
			regionId = "region/fixture-clearing",
			radius = 14,
			securePointId = "secure-point/fixture-spawn",
			recoveryAnchorId = "recovery-anchor/starter",
		},
		{
			id = "safe-outpost/mid-a-entry",
			regionId = "region/biome-mid-a",
			radius = 14,
			securePointId = "secure-point/mid-a",
			recoveryAnchorId = "recovery-anchor/mid-a",
		},
		{
			id = "safe-outpost/mid-b-entry",
			regionId = "region/biome-mid-b",
			radius = 14,
			securePointId = "secure-point/mid-b",
			recoveryAnchorId = "recovery-anchor/mid-b",
		},
		{
			id = "safe-outpost/advanced-entry",
			regionId = "region/biome-advanced",
			radius = 14,
			securePointId = "secure-point/advanced",
			recoveryAnchorId = "recovery-anchor/advanced",
		},
	},
	securePoints = {
		{
			id = "secure-point/home-hub",
			regionId = "region/home-hub",
			radius = 10,
		},
		{
			id = "secure-point/fixture-spawn",
			regionId = "region/fixture-clearing",
			radius = 10,
			outpostId = "safe-outpost/starter-entry",
		},
		{
			id = "secure-point/mid-a",
			regionId = "region/biome-mid-a",
			radius = 10,
			outpostId = "safe-outpost/mid-a-entry",
		},
		{
			id = "secure-point/mid-b",
			regionId = "region/biome-mid-b",
			radius = 10,
			outpostId = "safe-outpost/mid-b-entry",
		},
		{
			id = "secure-point/advanced",
			regionId = "region/biome-advanced",
			radius = 10,
			outpostId = "safe-outpost/advanced-entry",
		},
	},
	recoveryAnchors = {
		{
			id = "recovery-anchor/home-hub",
			regionId = "region/home-hub",
		},
		{
			id = "recovery-anchor/starter",
			regionId = "region/fixture-clearing",
			outpostId = "safe-outpost/starter-entry",
		},
		{
			id = "recovery-anchor/mid-a",
			regionId = "region/biome-mid-a",
			outpostId = "safe-outpost/mid-a-entry",
		},
		{
			id = "recovery-anchor/mid-b",
			regionId = "region/biome-mid-b",
			outpostId = "safe-outpost/mid-b-entry",
		},
		{
			id = "recovery-anchor/advanced",
			regionId = "region/biome-advanced",
			outpostId = "safe-outpost/advanced-entry",
		},
	},
	vaultAccessPoints = {
		{
			id = "vault-access-point/home-hub",
			regionId = "region/home-hub",
			radius = 8,
		},
	},
	travelNodes = {
		{
			id = "travel-node/home-hub",
			regionId = "region/home-hub",
			recoveryAnchorId = "recovery-anchor/home-hub",
		},
		{
			id = "travel-node/starter",
			regionId = "region/fixture-clearing",
			recoveryAnchorId = "recovery-anchor/starter",
		},
		{
			id = "travel-node/mid-a",
			regionId = "region/biome-mid-a",
			recoveryAnchorId = "recovery-anchor/mid-a",
		},
		{
			id = "travel-node/mid-b",
			regionId = "region/biome-mid-b",
			recoveryAnchorId = "recovery-anchor/mid-b",
		},
		{
			id = "travel-node/advanced",
			regionId = "region/biome-advanced",
			recoveryAnchorId = "recovery-anchor/advanced",
		},
	},
}

-- AD-257: small DEV envelope, one reservation/live encounter per authored anchor.
-- Existing Common pools have explicit equal weights; no rarity-label formula.
-- AD-258: explicit DEV timings, phase-independent existing content.
-- Unix epoch is fixed across servers. No Lighting, weights or biome rules change.
config.worldCycle = {
	id = "world-cycle/ordinary-dev-v1",
	version = 1,
	epochUnixSeconds = 0,
	phases = {
		{ id = "world-phase/day", durationSeconds = 300 },
		{ id = "world-phase/dusk", durationSeconds = 300 },
		{ id = "world-phase/night", durationSeconds = 300 },
	},
}
local cycleBindings: { any } = { config.habitats, config.spawnContexts, config.hazards }
for _, definitions in cycleBindings do
	for _, definition in definitions do
		definition.cycleDefinitionId = config.worldCycle.id
		definition.cyclePhaseIds = { "world-phase/day", "world-phase/dusk", "world-phase/night" }
	end
end
-- AD-259: interaction envelopes on the existing five authored nodes only.
for _, node in config.travelNodes do
	node.radius = 16
	node.discoveryContentSnapshotIds = { config.contentSnapshotId }
end
config.spawnPolicy = {
	stepSeconds = 1,
	maxBucketsPerStep = 2,
	maxBuckets = 8,
	cellSize = 32,
	interactionRadius = 12,
	lifetimeSeconds = 180,
	retrySeconds = 2,
	refillSeconds = 5,
	maxMaterializationAttempts = 3,
	protectedFixtureContextId = "spawn-context/fixture-clearing",
}
for _, context in config.spawnContexts do
	context.speciesWeights = table.create(#context.speciesIds, 1)
end
return config
