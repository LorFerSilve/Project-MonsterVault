--!strict

-- P0 DEV bounds, independent of wealth, entitlements and display capacity.
return table.freeze({
	maxLiveUsers = 60,
	maxVisitors = 2,
	maxIncoming = 2,
	grantSeconds = 60,
	maxCreatures = 1, -- One representative card; never a full owner profile.
})
