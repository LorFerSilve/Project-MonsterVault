--!strict

-- DEV snapshot retains the base of 10. GDS-8 PE-08 supports +6 capacity
-- increments. ProgressionFixture binds the purchase of this one earned tier.
-- No commercial/temporary grant is authorized by this fixture.
return table.freeze({
	contentSnapshotId = "content-snapshot/imp9-capacity-fixture-v2",
	baseCollectionCapacity = 10,
	collectionCapacityUpgradeId = "vault-upgrade/collection-capacity",
	earnedCollectionCapacityByLevel = table.freeze({ [0] = 0, [1] = 6, [2] = 12 }),
	otherEarnedUpgradeLevelsById = table.freeze({
		["vault-upgrade/production-slots"] = table.freeze({ [0] = true, [1] = true }),
		["vault-upgrade/display-slots"] = table.freeze({ [0] = true, [1] = true }),
		["vault-upgrade/production-buffer"] = table.freeze({ [0] = true, [1] = true }),
		["vault-upgrade/offline-window"] = table.freeze({
			[0] = true,
			[1] = true,
			[2] = true,
			[3] = true,
		}),
	}),
	commercialCapacityById = table.freeze({}),
	temporaryCapacityById = table.freeze({}),
})
