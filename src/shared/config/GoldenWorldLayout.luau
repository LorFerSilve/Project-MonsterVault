--!strict
-- Authored Golden geometry, not gameplay entitlements or interaction radii.
-- Native region/ground overrides are mirrored in default.project.json.
local layout: {
	world: { [string]: { position: { number }, size: { number } } },
	vault: { width: number, depth: number, front: number, back: number, height: number },
	displays: { { number } },
	core: { number },
} =
	{
		world = {
			FixtureGround = { position = { 0, -0.5, 8 }, size = { 176, 1, 144 } },
			StarterBounds = { position = { 0, 10, 8 }, size = { 176, 40, 144 } },
			HomeHubGround = { position = { 0, -0.5, 160 }, size = { 160, 1, 144 } },
			HomeHubBounds = { position = { 0, 10, 160 }, size = { 160, 40, 144 } },
			MidABounds = { position = { -160, 10, -128 }, size = { 144, 40, 160 } },
			MidBBounds = { position = { 160, 10, -128 }, size = { 144, 40, 160 } },
		},
		vault = { width = 76, depth = 68, front = 108, back = 176, height = 22 },
		displays = { { -24, 0.22, 132 }, { -24, 0.22, 150 } },
		core = { 26, 0.22, 154 },
	}
for _, item in layout.world do
	table.freeze(item.position)
	table.freeze(item.size)
	table.freeze(item)
end
for _, item in layout.displays do
	table.freeze(item)
end
table.freeze(layout.world)
table.freeze(layout.vault)
table.freeze(layout.displays)
table.freeze(layout.core)
return table.freeze(layout)
