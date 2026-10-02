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
}

for _, style in styles do
	table.freeze(style)
end

return table.freeze(styles)
