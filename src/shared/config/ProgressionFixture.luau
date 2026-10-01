--!strict

-- Bounded DEV tuning for GDS-8 PE-08 / TA-8. Region roles and mastery gates
-- come from GDS-9; this catalog does not author world geometry or proofs.
local definitions = {}
local function add(
	unlock: string,
	kind: string,
	upgrade: string,
	level: number,
	price: number,
	field: string,
	value: number,
	label: string,
	milestones: { string }
)
	table.insert(
		definitions,
		table.freeze({
			unlockId = unlock,
			kind = kind,
			upgradeId = upgrade,
			expectedLevel = level - 1,
			targetLevel = level,
			priceUnits = price,
			effectField = field,
			effectValue = value,
			label = label,
			quoteRevision = 1,
			configSnapshotId = "content-snapshot/imp9-progression-dev-v1",
			requiredMilestoneId = milestones[1],
			requiredMilestoneIds = table.freeze(milestones),
			quoteLifetimeSeconds = 60,
		})
	)
end
local discovery = "milestone/secured-species-discovery"
add(
	"vault-upgrade/collection-capacity/1",
	"Vault",
	"vault-upgrade/collection-capacity",
	1,
	25,
	"collectionCapacity",
	6,
	"Collection capacity +6 (tier 1)",
	{ discovery }
)
add(
	"vault-upgrade/collection-capacity/2",
	"Vault",
	"vault-upgrade/collection-capacity",
	2,
	50,
	"collectionCapacity",
	12,
	"Collection capacity +6 (tier 2)",
	{ discovery }
)
add(
	"vault-upgrade/production-slots/1",
	"Vault",
	"vault-upgrade/production-slots",
	1,
	50,
	"productionSlotCount",
	1,
	"Production slots: 2 to 3",
	{ discovery }
)
add(
	"vault-upgrade/display-slots/1",
	"Vault",
	"vault-upgrade/display-slots",
	1,
	25,
	"displaySlotCount",
	1,
	"Display slots: 3 to 4",
	{ discovery }
)
add(
	"vault-upgrade/production-buffer/1",
	"Vault",
	"vault-upgrade/production-buffer",
	1,
	75,
	"bufferCapacityMilli",
	1_440_000,
	"Production buffer +1440 Energy",
	{ discovery }
)
add(
	"vault-upgrade/offline-window/1",
	"Vault",
	"vault-upgrade/offline-window",
	1,
	100,
	"offlineWindowSeconds",
	7200,
	"Offline window: 2h to 4h",
	{ discovery }
)
add(
	"vault-upgrade/offline-window/2",
	"Vault",
	"vault-upgrade/offline-window",
	2,
	200,
	"offlineWindowSeconds",
	21600,
	"Offline window: 4h to 8h",
	{ discovery }
)
add(
	"vault-upgrade/offline-window/3",
	"Vault",
	"vault-upgrade/offline-window",
	3,
	400,
	"offlineWindowSeconds",
	36000,
	"Offline window: 8h to 12h",
	{ discovery }
)
add(
	"capture-capability/1",
	"Capture",
	"capture-capability",
	1,
	50,
	"captureCapabilityLevel",
	1,
	"Capture capability 1: success chance 80% to 85%",
	{ discovery }
)
add(
	"access/biome-mid-a",
	"Access",
	"access/biome-mid-a",
	1,
	100,
	"accessUnlocksById",
	1,
	"Mid biome A access (requires Starter mastery)",
	{ "milestone/region-mastery/starter" }
)
add(
	"access/biome-mid-b",
	"Access",
	"access/biome-mid-b",
	1,
	100,
	"accessUnlocksById",
	1,
	"Mid biome B access (requires Starter mastery)",
	{ "milestone/region-mastery/starter" }
)
add(
	"access/biome-advanced",
	"Access",
	"access/biome-advanced",
	1,
	200,
	"accessUnlocksById",
	1,
	"Advanced access (requires both Mid masteries)",
	{
		"milestone/region-mastery/mid-a",
		"milestone/region-mastery/mid-b",
	}
)
local config = table.clone(definitions[1]) -- Preserve the first DEV quote API/receipt.
local advanced = table.clone(definitions[#definitions])
advanced.requiredUnlockIds = table.freeze({ "access/biome-mid-a", "access/biome-mid-b" })
definitions[#definitions] = table.freeze(advanced)
config.definitions = table.freeze(definitions)
config.captureSuccessChanceByLevel = table.freeze({ [0] = 0.8, [1] = 0.85 })
return table.freeze(config)
