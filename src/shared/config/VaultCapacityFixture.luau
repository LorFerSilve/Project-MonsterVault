--!strict

-- Retains the IMP-6 DEV fixture balance. Production/content-backed capacity
-- components and upgrades remain later IMP-9 dependencies (TA-8 / GDS-8).
return table.freeze({
	contentSnapshotId = "content-snapshot/imp9-capacity-fixture-v1",
	baseCollectionCapacity = 10,
})
