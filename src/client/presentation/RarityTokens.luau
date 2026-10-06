--!strict
-- Intrinsic rarity tokens only; seasonal/paid presentation cannot choose these.
return table.freeze({
	["rarity/common"] = table.freeze({
		label = "COMMON",
		shape = "circle",
		rgb = table.freeze({ 187, 198, 185 }),
	}),
	["rarity/uncommon"] = table.freeze({
		label = "UNCOMMON",
		shape = "chevron",
		rgb = table.freeze({
			115,
			218,
			167,
		}),
	}),
	["rarity/rare"] = table.freeze({
		label = "RARE",
		shape = "diamond",
		rgb = table.freeze({ 99, 221, 244 }),
	}),
	["rarity/epic"] = table.freeze({
		label = "EPIC",
		shape = "doubleDiamond",
		rgb = table.freeze({ 190, 148, 255 }),
	}),
	["rarity/legendary"] = table.freeze({
		label = "LEGENDARY",
		shape = "crown",
		rgb = table.freeze({
			255,
			208,
			91,
		}),
	}),
})
