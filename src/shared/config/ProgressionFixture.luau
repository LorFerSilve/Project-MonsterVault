--!strict

-- Named DEV price/gate snapshot for the already authored +6 capacity tier.
-- No launch balance, world access, paid grant or temporary effect is inferred.
return table.freeze({
	unlockId = "vault-upgrade/collection-capacity/1",
	upgradeId = "vault-upgrade/collection-capacity",
	expectedLevel = 0,
	targetLevel = 1,
	priceUnits = 25,
	quoteRevision = 1,
	configSnapshotId = "content-snapshot/imp9-progression-dev-v1",
	requiredMilestoneId = "milestone/secured-species-discovery",
	quoteLifetimeSeconds = 60,
})
