--!strict

-- Immutable DEV content, not launch balance or a live-ops ConfigService binding.
-- GDS-8 PE-08 supplies 2 production / 3 display slots and a two-hour window.
-- Keep historical epochs when adding a prospective rate/capability snapshot.
return table.freeze({
	earnedCapabilitiesByUpgradeId = table.freeze({
		["vault-upgrade/production-slots"] = table.freeze({
			field = "productionSlotCount",
			byLevel = table.freeze({ [0] = 0, [1] = 1 }),
		}),
		["vault-upgrade/display-slots"] = table.freeze({
			field = "displaySlotCount",
			byLevel = table.freeze({ [0] = 0, [1] = 1 }),
		}),
		["vault-upgrade/production-buffer"] = table.freeze({
			field = "bufferCapacityMilli",
			byLevel = table.freeze({ [0] = 0, [1] = 1_440_000 }),
		}),
		["vault-upgrade/offline-window"] = table.freeze({
			field = "offlineWindowSeconds",
			byLevel = table.freeze({ [0] = 0, [1] = 7200, [2] = 21600, [3] = 36000 }),
		}),
	}),
	productionSlotIds = table.freeze({ "production/1", "production/2", "production/3" }),
	displaySlotIds = table.freeze({ "display/1", "display/2", "display/3", "display/4" }),
	crashRecoveryAllowanceSeconds = 180, -- TA-14 >= healthy checkpoint gap.
	epochs = table.freeze({
		table.freeze({
			epochId = "production-epoch/imp9-dev-v1",
			contentSnapshotId = "content-snapshot/imp9-production-dev-v1",
			effectiveUnixSeconds = 0,
			productionSlotCount = 2,
			displaySlotCount = 3,
			bufferCapacityMilli = 1_440_000, -- Two hours of two fixture producers.
			offlineWindowSeconds = 7200,
			ratesMilliBySpeciesId = table.freeze({ ["species/fixture-orb"] = 100 }),
		}),
	}),
})
