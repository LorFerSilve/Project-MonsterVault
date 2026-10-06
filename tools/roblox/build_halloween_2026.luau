-- Edit-only seasonal dressing. The permanent scene and gameplay anchors are untouched.
local Builder = {}
function Builder.run()
	assert(not game:GetService("RunService"):IsRunning(), "Edit only")
	local mv = game.ReplicatedStorage.MonsterVault
	local prefabs = mv.PresentationAssets
	local paletteSource = mv.Shared.config.MaterialPalette:Clone()
	paletteSource.Parent = game.ServerStorage
	local palette = require(paletteSource)
	paletteSource:Destroy()
	local library = mv:FindFirstChild("SeasonalAssets") or Instance.new("Folder")
	library.Name, library.Parent = "SeasonalAssets", mv
	local old = library:FindFirstChild("Halloween2026")
	if old then
		old:Destroy()
	end
	local root = Instance.new("Model")
	root.Name, root.Parent = "Halloween2026", library
	root:SetAttribute("PresentationOnly", true)
	root:SetAttribute("ArtVersion", "SpectralHarvest-v1")
	local function style(p, group)
		local material = assert(palette[group], group)
		p.Material, p.Color = material.material, material.color
		p:SetAttribute("MaterialGroup", group)
		p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
		p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	end
	local function part(parent, name, group, size, cf, shape)
		local p = Instance.new("Part")
		p.Name, p.Size, p.CFrame = name, size, cf
		if shape then
			p.Shape = shape
		end
		style(p, group)
		p.Parent = parent
		return p
	end
	local function asset(key, name, pos, scale, yaw)
		local model = assert(prefabs:FindFirstChild(key), key):Clone()
		model.Name = name
		model:ScaleTo(scale or 1)
		model:PivotTo(CFrame.new(pos) * CFrame.Angles(0, math.rad(yaw or 0), 0))
		model.Parent = root
		return model
	end
	local function line(parent, name, a, b, group, width)
		return part(
			parent,
			name,
			group,
			Vector3.new(width or 0.018, width or 0.018, (a - b).Magnitude),
			CFrame.lookAt((a + b) / 2, b)
		)
	end
	local function candle(pos, scale)
		part(
			root,
			"Candle",
			"CreatureCream",
			Vector3.new(0.65, 0.24, 0.24) * scale,
			CFrame.new(pos + Vector3.new(0, 0.325 * scale, 0)) * CFrame.Angles(0, 0, math.pi / 2),
			Enum.PartType.Cylinder
		)
		part(
			root,
			"CandleFlame",
			"CandleGold",
			Vector3.new(0.12, 0.2, 0.12) * scale,
			CFrame.new(pos + Vector3.new(0, 0.7 * scale, 0)),
			Enum.PartType.Ball
		)
	end
	-- Small clustered props frame navigation, never become navigation or collision.
	for i, p in
		{
			Vector3.new(-15, 0.1, 28),
			Vector3.new(-17, 0.1, 30),
			Vector3.new(15, 0.1, 28),
			Vector3.new(15, 0.1, 3),
			Vector3.new(17, 0.1, 5),
			Vector3.new(-15, 0.1, 19),
			Vector3.new(-30, 0.1, -10),
			Vector3.new(-28, 0.1, -11),
			Vector3.new(25, 0.1, -33),
			Vector3.new(-15, 0.2, 107),
			Vector3.new(16, 0.2, 109),
			Vector3.new(18, 0.2, 143),
		}
	do
		asset("HarvestPumpkin", "HarvestPumpkin" .. i, p, 0.65 + (i % 3) * 0.17, i * 37)
	end
	for i, p in
		{
			Vector3.new(-12, 8.2, 1),
			Vector3.new(12, 8.2, 1),
			Vector3.new(-12, 8.2, 21),
			Vector3.new(12, 8.2, 21),
			Vector3.new(-17, 0.2, 29),
			Vector3.new(17, 0.2, 29),
			Vector3.new(-18, 0.25, 113),
			Vector3.new(18, 0.25, 113),
			Vector3.new(-18, 0.25, 148),
			Vector3.new(18, 0.25, 148),
		}
	do
		asset("HarvestLantern", "HarvestLantern" .. i, p, if i < 5 then 0.42 else 0.65, i * 42)
	end
	for _, p in
		{
			Vector3.new(-9, 4.16, 18.2),
			Vector3.new(9, 4.16, 18.2),
			Vector3.new(-20, 0.3, 137),
			Vector3.new(20, 0.3, 137),
			Vector3.new(-20, 0.3, 139),
			Vector3.new(20, 0.3, 140),
		}
	do
		candle(p, 1)
	end
	-- The webs use opaque thin threads, not layered transparent sheets.
	for _, x in { -12, 12 } do
		local corner = Vector3.new(x, 8.1, 1.2)
		local web = Instance.new("Model")
		web.Name, web.Parent = "OutpostWeb", root
		for i = 0, 4 do
			local angle = math.pi / 2 * i / 4
			line(
				web,
				"WebRadial",
				corner,
				corner
					+ Vector3.new(
						(if x < 0 then 1 else -1) * math.sin(angle) * 3,
						-math.cos(angle) * 3,
						0
					),
				"StoneLight"
			)
		end
		for radius = 1, 3 do
			for i = 0, 3 do
				local a, b = math.pi / 2 * i / 4, math.pi / 2 * (i + 1) / 4
				line(
					web,
					"WebArc",
					corner
						+ Vector3.new(
							(if x < 0 then 1 else -1) * math.sin(a) * radius,
							-math.cos(a) * radius,
							0
						),
					corner
						+ Vector3.new(
							(if x < 0 then 1 else -1) * math.sin(b) * radius,
							-math.cos(b) * radius,
							0
						),
					"StoneLight"
				)
			end
		end
	end
	for i, p in
		{ Vector3.new(-37, 0.1, -35), Vector3.new(-42, 0.1, -30), Vector3.new(38, 0.1, -54) }
	do
		local ruin = part(
			root,
			"AncientWard" .. i,
			"MossRock",
			Vector3.new(1.7, 3.7, 0.8),
			CFrame.new(p + Vector3.new(0, 1.8, 0)) * CFrame.Angles(0, i * 0.7, -0.15)
		)
		local glyph = part(
			root,
			"WardMark",
			"SpectralViolet",
			Vector3.new(0.10, 1.2, 0.02),
			ruin.CFrame * CFrame.new(0, 0.1, -0.42)
		)
		glyph.CastShadow = false
	end
	for i, p in
		{
			Vector3.new(-25, 0.1, 23),
			Vector3.new(24, 0.1, 17),
			Vector3.new(-34, 0.1, -39),
			Vector3.new(42, 0.1, -44),
			Vector3.new(31, 0.1, 106),
			Vector3.new(-32, 0.1, 142),
		}
	do
		local foliage = asset("Fern", "AutumnCluster" .. i, p, 1.15, i * 31)
		for _, mesh in foliage:GetDescendants() do
			if mesh:IsA("BasePart") then
				style(mesh, "AutumnLeaf")
			end
		end
	end
	local hero =
		asset("SpectralReliquary", "SpectralReliquary", Vector3.new(-34, 0.1, -13), 1.35, 20)
	local mote = Instance.new("ParticleEmitter")
	mote.Name, mote.Rate, mote.Lifetime, mote.Speed =
		"SpectralMotes", 3, NumberRange.new(2, 3), NumberRange.new(0.25, 0.6)
	mote.Texture, mote.Color =
		"rbxasset://textures/particles/sparkles_main.dds",
		ColorSequence.new(palette.SpectralViolet.color)
	mote.Size, mote.Transparency, mote.LightEmission =
		NumberSequence.new(0.1), NumberSequence.new(0.45), 0.4
	mote.Parent = hero:FindFirstChildWhichIsA("BasePart", true)
	for i, p in { Vector3.new(-34, 4, -13), Vector3.new(0, 6, 11), Vector3.new(0, 5, 130) } do
		local holder =
			part(root, "SeasonalLight" .. i, "PanelPlastic", Vector3.one * 0.1, CFrame.new(p))
		holder.Transparency, holder.CastShadow = 1, false
		local light = Instance.new("PointLight")
		light.Name, light.Color, light.Brightness, light.Range, light.Shadows =
			"HarvestFill",
			palette[if i == 1 then "SpectralViolet" else "CandleGold"].color,
			0.8,
			14,
			false
		light.Parent = holder
	end
	root.WorldPivot = CFrame.identity
	return root
end
return Builder
