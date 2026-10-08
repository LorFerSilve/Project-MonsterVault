--!strict
-- Visual aliases map onto existing registry identities; they add no Species,
-- rarity, spawn opportunity, production rate or commercial entitlement.
return table.freeze({
	["species/fixture-orb"] = table.freeze({
		asset = "Mossbud",
		label = "Mossbud",
		rarity = "rarity/common",
	}),
	["species/fixture-companion"] = table.freeze({
		asset = "Mossbud",
		label = "Mossbud Companion",
		rarity = "rarity/common",
	}),
	["species/stability-orb-dev"] = table.freeze({
		asset = "Helion",
		label = "Helion · Legendary DEV",
		rarity = "rarity/legendary",
	}),
})
