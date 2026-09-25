--!strict

-- IMP-5 authored fixture. The matching Studio anchor is validated at startup.
-- This fixed identity is presentation-only until TA-7 owns Variant generation.
return table.freeze({
	regionId = "region/fixture-clearing",
	habitatId = "habitat/fixture-clearing",
	spawnContextId = "spawn-context/fixture-clearing",
	contentSnapshotId = "content-snapshot/imp5-fixture-v1",
	speciesId = "species/fixture-orb",
	rarityId = "rarity/common",
	position = table.freeze({ x = 0, y = 3, z = -16 }),
	cellSize = 32,
	interactionRadius = 12,
	lifetimeSeconds = 180,
	retrySeconds = 2,
	refillSeconds = 5,
	maxMaterializationAttempts = 3,
})
