--!strict
-- Shared Roblox-native appearance values for authored assets.
-- Blender/glTF material names identify these groups; shaders do not own them.

-- Native values enter through the same boundary as the existing Roblox views.
local globals: any = getfenv()
local Enum, Color3 = globals.Enum, globals.Color3
local styles: { [string]: { material: any, color: any } } = {
	DarkMetal = { material = Enum.Material.Metal, color = Color3.fromRGB(50, 63, 76) },
	SecondaryMetal = { material = Enum.Material.Metal, color = Color3.fromRGB(153, 172, 187) },
	PanelPlastic = { material = Enum.Material.SmoothPlastic, color = Color3.fromRGB(19, 25, 33) },
	EnergyGreen = { material = Enum.Material.Neon, color = Color3.fromRGB(76, 255, 110) },
	-- Reused IMP-5 DEV encounter body; the four Energy Core groups stay unchanged.
	FixtureCreature = { material = Enum.Material.Neon, color = Color3.fromRGB(77, 205, 255) },
	MossRock = { material = Enum.Material.Slate, color = Color3.fromRGB(76, 99, 88) },
	StoneLight = { material = Enum.Material.Concrete, color = Color3.fromRGB(148, 168, 145) },
	LeafGreen = { material = Enum.Material.Fabric, color = Color3.fromRGB(79, 139, 87) },
	CreatureMoss = { material = Enum.Material.SmoothPlastic, color = Color3.fromRGB(106, 184, 146) },
	CreatureCream = {
		material = Enum.Material.SmoothPlastic,
		color = Color3.fromRGB(233, 234, 202),
	},
	EyeInk = { material = Enum.Material.SmoothPlastic, color = Color3.fromRGB(12, 23, 29) },
	EyeLight = { material = Enum.Material.SmoothPlastic, color = Color3.fromRGB(247, 255, 234) },
	RareBlue = { material = Enum.Material.SmoothPlastic, color = Color3.fromRGB(70, 155, 210) },
	RareGlow = { material = Enum.Material.Neon, color = Color3.fromRGB(99, 221, 244) },
	LegendaryGold = { material = Enum.Material.SmoothPlastic, color = Color3.fromRGB(228, 166, 64) },
	LegendaryGlow = { material = Enum.Material.Neon, color = Color3.fromRGB(255, 208, 91) },
	ForestDeep = { material = Enum.Material.Fabric, color = Color3.fromRGB(31, 66, 49) },
	GrassMeadow = { material = Enum.Material.Grass, color = Color3.fromRGB(65, 104, 72) },
	RavineWater = { material = Enum.Material.SmoothPlastic, color = Color3.fromRGB(29, 75, 86) },
	BarkWood = { material = Enum.Material.Wood, color = Color3.fromRGB(65, 53, 45) },
	HarvestOrange = { material = Enum.Material.SmoothPlastic, color = Color3.fromRGB(255, 138, 52) },
	CandleGold = { material = Enum.Material.Neon, color = Color3.fromRGB(255, 211, 122) },
	SpectralViolet = { material = Enum.Material.Neon, color = Color3.fromRGB(167, 107, 255) },
	NightPlum = { material = Enum.Material.SmoothPlastic, color = Color3.fromRGB(42, 23, 56) },
	AutumnLeaf = { material = Enum.Material.SmoothPlastic, color = Color3.fromRGB(172, 90, 52) },
}

for _, style in styles do
	table.freeze(style)
end

return table.freeze(styles)
