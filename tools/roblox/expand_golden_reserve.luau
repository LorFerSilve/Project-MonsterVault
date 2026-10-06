-- Edit-only fourth composition pass after finish_golden_comfort.
-- Rebuilds the actual central station/court and adds a northern forest loop.
-- All utility, encounter, hazard, ownership and travel authority stays unchanged.
return function()
	assert(not game:GetService("RunService"):IsRunning(), "Edit only")
	local shared = game.ReplicatedStorage.MonsterVault.Shared.config
	local function fresh(source)
		local m = source:Clone()
		m.Parent = game.ServerStorage
		local result = require(m)
		m:Destroy()
		return result
	end
	local palette, layout = fresh(shared.MaterialPalette), fresh(shared.GoldenWorldLayout)
	local root = workspace.MonsterVaultPresentation
	local reserve, comfort, refresh = root.MosslineReserve, root.ComfortLayer, root.LibraryRefresh
	local prefabs = game.ReplicatedStorage.MonsterVault.PresentationAssets
	for name, entry in layout.world do
		workspace.MonsterVaultWorld[name].Position = Vector3.new(table.unpack(entry.position))
		workspace.MonsterVaultWorld[name].Size = Vector3.new(table.unpack(entry.size))
	end
	local old = root:FindFirstChild("ReclaimedReserve")
	if old then
		old:Destroy()
	end
	local layer = Instance.new("Model")
	layer.Name, layer.Parent = "ReclaimedReserve", root
	local function block(parent, name, group, size, cf, collide, shape)
		local p = Instance.new("Part")
		p.Name, p.Size, p.CFrame = name, size, cf
		p.Material, p.Color = palette[group].material, palette[group].color
		p:SetAttribute("MaterialGroup", group)
		p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch =
			true, collide == true, collide == true, false
		p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		if shape then
			p.Shape = shape
		end
		p.Parent = parent
		return p
	end
	local function asset(key, name, position, scale, yaw, parent)
		local m = prefabs[key]:Clone()
		m.Name, m.Parent = name, parent or layer
		m:SetAttribute("RefreshAssetKey", key)
		m.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
		m:ScaleTo(scale or 1)
		m:PivotTo(CFrame.new(position) * CFrame.Angles(0, math.rad(yaw or 0), 0))
		return m
	end
	local function sign(parent, name, text, cf, width, height, group)
		local p = block(parent, name, "PanelPlastic", Vector3.new(width, height, 0.15), cf)
		for _, face in { Enum.NormalId.Front, Enum.NormalId.Back } do
			local g = Instance.new("SurfaceGui")
			g.Face, g.SizingMode, g.PixelsPerStud =
				face, Enum.SurfaceGuiSizingMode.PixelsPerStud, 40
			g.LightInfluence, g.Parent = 0.35, p
			local label = Instance.new("TextLabel")
			label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
			label.Font, label.TextScaled, label.TextWrapped = Enum.Font.GothamBold, true, true
			label.Text, label.TextColor3, label.Parent =
				text, palette[group or "CreatureCream"].color, g
			local limit = Instance.new("UITextSizeConstraint")
			limit.MinTextSize, limit.MaxTextSize, limit.Parent = 14, 48, label
		end
		return p
	end
	local function move(item, position)
		item:PivotTo(CFrame.new(position) * item:GetPivot().Rotation)
	end
	-- Remove the old inner ring which made the bigger ground feel like the same
	-- small room. Keep outer silhouettes; reposition from stable authored values.
	for _, p in reserve:GetChildren() do
		if
			p.Name:match("^Ridge")
			or p.Name:match("^EncounterRocks")
			or p.Name:match("^NorthernRidge")
			or p.Name:match("^OuterRidge")
			or p.Name:match("^ClearingShoulder")
			or p.Name:match("^MeadowPath")
			or p.Name:match("^HomePath")
		then
			p:Destroy()
		elseif
			p.Name:match("^Canopy")
			or p.Name:match("^Understory")
			or p.Name:match("^ClearingFrame")
			or p.Name:match("^MeadowBank")
			or p.Name:match("^Fern%d")
		then
			p:Destroy()
		end
	end
	for _, p in refresh:GetChildren() do
		if
			p.Name:match("^StationBay")
			or p.Name:match("^StationSupplies")
			or p.Name == "FieldConsole"
			or p.Name:match("^Grass")
			or p.Name:match("^Flowers")
		then
			p:Destroy()
		end
	end
	-- Comfort's old northern shoreline is now an interior seam. The complete
	-- new shore is authored below, rather than leaving a rocky wall across it.
	for _, p in comfort:GetChildren() do
		if p.Name:match("^ReserveNorth") or p.Name:match("^ReserveCoast") then
			p:Destroy()
		end
	end
	reserve.ReserveCliffBase.Size, reserve.ReserveCliffBase.Position =
		Vector3.new(174, 14, 254), Vector3.new(0, -7.4, -48)
	local station = reserve.SafeOutpost
	for _, p in station:GetChildren() do
		p:Destroy()
	end
	-- 56 x 36 station and 88 x 52 court, with open central circulation. These
	-- thin native surfaces wrap, but do not relocate, existing spawn/secure pads.
	block(
		station,
		"StationCourt",
		"StoneLight",
		Vector3.new(88, 0.12, 52),
		CFrame.new(0, 0.06, 17),
		true
	)
	block(
		station,
		"StationDeck",
		"DarkMetal",
		Vector3.new(56, 0.10, 36),
		CFrame.new(0, 0.14, 12),
		true
	)
	block(
		station,
		"StationInset",
		"PanelPlastic",
		Vector3.new(50, 0.04, 32),
		CFrame.new(0, 0.21, 12)
	)
	-- Deliberate panel rhythm and bevel-like clipped corner paving, rather than
	-- rows of tiny props. The court reads from the entry and normal player camera.
	for _, x in { -35, 35 } do
		for i, z in { -2, 10, 22, 34 } do
			block(
				station,
				"CourtPanel" .. x .. "_" .. i,
				"WeatheredMetal",
				Vector3.new(13, 0.04, 10),
				CFrame.new(x, 0.145, z)
			)
		end
	end
	for _, side in { -1, 1 } do
		for _, z in { -3, 28 } do
			asset(
				"FoundryColumn",
				"StationPier" .. side .. "_" .. z,
				Vector3.new(side * 27, 0.2, z),
				0.68,
				if side < 0 then -90 else 90,
				station
			)
			block(
				station,
				"StationPierProxy",
				"DarkMetal",
				Vector3.new(1.3, 11.7, 1.3),
				CFrame.new(side * 27, 6, z),
				true
			).Transparency =
				1
		end
		block(
			station,
			"CanopyWing",
			"DarkMetal",
			Vector3.new(18, 0.65, 34),
			CFrame.new(side * 24, 12.25, 12) * CFrame.Angles(0, 0, math.rad(side * 6))
		)
		block(
			station,
			"CanopyFascia",
			"WeatheredMetal",
			Vector3.new(18, 1.2, 0.35),
			CFrame.new(side * 24, 11.8, -4.9)
		)
		block(
			station,
			"CanopyLight",
			"EyeLight",
			Vector3.new(0.15, 0.1, 26),
			CFrame.new(side * 24, 11.7, 12)
		)
		block(
			station,
			"CourtEnergy",
			"EnergyGreen",
			Vector3.new(0.12, 0.05, 34),
			CFrame.new(side * 28.2, 0.24, 12)
		)
		asset(
			"StationTerminal",
			"StationConsole" .. side,
			Vector3.new(side * 21, 0.22, 16),
			1.1,
			0,
			station
		)
		for i, z in { 8, 22 } do
			asset(
				"ServiceCrate",
				"StationSupplies" .. side .. "_" .. i,
				Vector3.new(side * 22, 0.24, z),
				0.9,
				side * 5,
				station
			)
		end
	end
	for _, z in { -4.6, 29 } do
		block(
			station,
			"StationHeader",
			"DarkMetal",
			Vector3.new(55, 0.85, 1.1),
			CFrame.new(0, 12, z)
		)
		block(
			station,
			"StationHeaderTrim",
			"SecondaryMetal",
			Vector3.new(52, 0.12, 0.2),
			CFrame.new(0, 11.5, z - 0.6)
		)
	end
	sign(station, "StationTitle", "FIELD STATION  /  MOSSLINE", CFrame.new(0, 10.8, -4.8), 26, 1.5)
	block(
		station,
		"ArrivalPlatform",
		"DarkMetal",
		Vector3.new(8.4, 1.06, 8.4),
		CFrame.new(0, 0.53, 18)
	)
	block(
		station,
		"ArrivalInset",
		"PanelPlastic",
		Vector3.new(6.6, 0.02, 6.6),
		CFrame.new(0, 1.08, 18)
	)
	block(
		station,
		"ArrivalStrip",
		"EnergyGreen",
		Vector3.new(6.6, 0.02, 0.08),
		CFrame.new(0, 1.1, 14.8)
	)
	asset("Relay", "TravelTerminal", Vector3.new(5.5, 0.22, 16), 0.38, 0, station)
	sign(station, "TerminalFace", "HOME", CFrame.new(5.5, 1.3, 15.3), 2.8, 0.6, "EnergyGreen")
	reserve.SecureRing.Position, reserve.SecureCenter.Position =
		Vector3.new(0, 0.27, 10), Vector3.new(0, 0.28, 10)
	reserve.SecureSign.CFrame = CFrame.new(-10, 2.2, 10) * CFrame.Angles(0, -math.pi / 2, 0)
	move(reserve.ArrivalGate, Vector3.new(0, 0, 42))
	reserve.ArrivalTitle.CFrame = CFrame.new(0, 9.7, 41.7)
	-- Main approach is 18 studs, encounter approach 16. Keep the real hazard's
	-- eastern branch visually marked and separate from the comfortable home path.
	for i = 0, 5 do
		block(
			layer,
			"HomeSpine" .. i,
			"StoneLight",
			Vector3.new(18, 0.08, 5.8),
			CFrame.new(0, 0.05, 35 + i * 4.5)
		)
	end
	for i = 0, 4 do
		block(
			layer,
			"EncounterApproach" .. i,
			"StoneLight",
			Vector3.new(16, 0.06, 4.4),
			CFrame.new(if i < 2 then 0 else -18, 0.05, -8 - i * 4.6)
		)
	end
	-- A larger playable loop gives the island a distinct northern landscape,
	-- rather than enlarging empty perimeter around the old central composition.
	local trail = {
		Vector3.new(-32, 0, -26),
		Vector3.new(-38, 0, -49),
		Vector3.new(-37, 0, -74),
		Vector3.new(-29, 0, -97),
		Vector3.new(-15, 0, -118),
		Vector3.new(6, 0, -130),
		Vector3.new(26, 0, -117),
		Vector3.new(38, 0, -94),
		Vector3.new(43, 0, -72),
		Vector3.new(35, 0, -56),
		Vector3.new(21, 0, -34),
	}
	for i = 1, #trail - 1 do
		local a, b = trail[i], trail[i + 1]
		local length = (a - b).Magnitude
		local path = block(
			layer,
			"ForestTrail" .. i,
			"TrailEarth",
			Vector3.new(12, 0.065, length + 0.4),
			CFrame.lookAt((a + b) / 2 + Vector3.new(0, 0.035, 0), b + Vector3.new(0, 0.035, 0))
		)
		path.Material = palette.TrailEarth.material
		block(
			layer,
			"TrailTurn" .. i,
			"TrailEarth",
			Vector3.new(0.065, 12, 12),
			CFrame.new(a + Vector3.new(0, 0.035, 0)) * CFrame.Angles(0, 0, math.pi / 2),
			false,
			Enum.PartType.Cylinder
		)
	end
	for i, p in { Vector3.new(-31, 0, -31), Vector3.new(39, 0, -65), Vector3.new(3, 0, -132) } do
		sign(
			layer,
			"TrailMarker" .. i,
			if i == 3 then "MOSSLINE / SURVEY TRAIL" else "FIELD STATION  ↓",
			CFrame.new(p + Vector3.new(0, 2.7, 0)),
			5,
			1.1,
			"CreatureCream"
		)
		block(
			layer,
			"MarkerPost",
			"WeatheredMetal",
			Vector3.new(0.25, 2.4, 0.25),
			CFrame.new(p + Vector3.new(0, 1.2, 0)),
			true
		)
	end
	-- More generous clearings: tall silhouettes are clustered outside the court,
	-- first creature and protected opportunity, rather than encircling each one.
	local trees = {
		{ -58, 8 },
		{ 58, 5 },
		{ -61, 38 },
		{ 63, 58 },
		{ -59, -37 },
		{ 66, -43 },
		{ -66, -65 },
		{ 63, -77 },
		{ -64, -100 },
		{ 66, -115 },
		{ -48, -132 },
		{ 49, -141 },
		{ -24, -151 },
		{ 13, -155 },
		{ -68, -145 },
		{ 69, -155 },
		{ -7, -80 },
		{ 17, -91 },
		{ -16, -65 },
		{ 5, -105 },
		{ -58, 58 },
		{ -62, -18 },
	}
	for i, p in trees do
		local pos = Vector3.new(p[1], 0, p[2])
		asset(
			if i % 4 == 0 then "CanopyPine" else "CanopyOak",
			"ReserveGrove" .. i,
			pos,
			1.1 + (i % 3) * 0.1,
			i * 37
		)
		if i >= 9 and i <= 16 then
			for j = 1, 2 do
				asset(
					if j == 1 then "CanopyOak" else "CanopyPine",
					"GroveCanopy" .. i .. "_" .. j,
					pos + Vector3.new(if p[1] < 0 then j * 5 else -j * 5, 0, -j * 3.5),
					0.95 + j * 0.1,
					i * 47 + j * 73
				)
			end
		end
		for j = 1, 2 do
			asset(
				"LeafBush",
				"GroveBush" .. i .. "_" .. j,
				pos + Vector3.new(j * 3.5 - 5, 0, 4 + j),
				0.8,
				i * 21 + j * 49
			)
			asset(
				"FernCluster",
				"GroveFern" .. i .. "_" .. j,
				pos + Vector3.new(j * 3 + 1, 0, -4),
				0.4,
				i * 41 + j * 17
			)
		end
	end
	for i, p in { { -63, -90 }, { 61, -123 }, { -60, -145 }, { 54, -160 } } do
		local m = asset(
			"MossBank",
			"ForestShoulder" .. i,
			Vector3.new(p[1], -0.2, p[2]),
			1.1 + (i % 2) * 0.2,
			i * 51
		)
		for _, part in m:GetDescendants() do
			if part:IsA("MeshPart") then
				part.CanCollide, part.CanQuery = true, true
				part.CollisionFidelity = Enum.CollisionFidelity.Hull
			end
		end
	end
	for i, p in
		{
			{ -66, -8 },
			{ 68, -28 },
			{ -67, -53 },
			{ 65, -98 },
			{ -54, -121 },
			{ 51, -151 },
			{
				-68,
				54,
			},
			{
				68,
				67,
			},
		}
	do
		local m = asset(
			"ReserveBoulderWide",
			"GroveShoulder" .. i,
			Vector3.new(p[1], -1.6, p[2]),
			0.9 + (i % 3) * 0.15,
			i * 61
		)
		for _, part in m:GetChildren() do
			if part:IsA("MeshPart") then
				part.CanCollide, part.CanQuery = true, true
				part.CollisionFidelity = Enum.CollisionFidelity.Hull
			end
		end
	end
	for _, x in { -84, 84 } do
		for i = 0, 11 do
			local m = asset(
				"ReserveBoulderWide",
				"ExpandedCoast" .. x .. "_" .. i,
				Vector3.new(x, -10.5, -168 + i * 22),
				2.9 + (i % 2) * 0.25,
				i * 41
			)
			for _, part in m:GetChildren() do
				if part:IsA("MeshPart") then
					part.CanCollide, part.CanQuery = true, true
					part.CollisionFidelity = Enum.CollisionFidelity.Hull
				end
			end
		end
	end
	for i, x in { -70, -45, -20, 5, 30, 55, 76 } do
		local m =
			asset("ReserveBoulder", "ExpandedNorth" .. i, Vector3.new(x, -7, -172), 2.8, i * 37)
		for _, p in m:GetChildren() do
			if p:IsA("MeshPart") then
				p.CanCollide, p.CanQuery = true, true
				p.CollisionFidelity = Enum.CollisionFidelity.Hull
			end
		end
	end
	-- Reclaimed technology is grouped at former survey sites. Preserve the sealed
	-- cell's cosmetic meaning; no fake hazards or extra interaction permissions.
	if prefabs:FindFirstChild("RelayRuins") then
		local delta = Vector3.new(-53, 0, -93) - comfort.ReclaimedStation1:GetPivot().Position
		move(comfort.ReclaimedStation1, Vector3.new(-53, 0, -93))
		-- Relocate all nine collision proxies and its overgrowth by the same delta.
		for _, p in comfort:GetChildren() do
			if p.Name:match("^RuinOvergrowth1_") then
				p:PivotTo(p:GetPivot() + delta)
			elseif p.Name == "RuinStaticProxy" and p.Position.X < 0 then
				p.CFrame += delta
			end
		end
	end
	-- Rebuild static trunk proxies after layout changes: never leave invisible
	-- colliders where trees were removed. No new runtime controller or loop.
	for _, p in comfort.PhysicalShell:GetChildren() do
		if p.Name:match("^Trunk") or p.Name == "GatePillar" then
			p:Destroy()
		end
	end
	local trunks = 0
	for _, m in root:GetDescendants() do
		if
			m:IsA("Model")
			and (
				m:GetAttribute("RefreshAssetKey") == "CanopyOak"
				or m:GetAttribute("RefreshAssetKey") == "CanopyPine"
			)
		then
			local s = m:GetScale()
			local p = block(
				layer,
				"Trunk" .. trunks,
				"BarkWood",
				Vector3.new(7 * s, 1.15, 1.15),
				CFrame.new(m:GetPivot().Position + Vector3.new(0, 3.5 * s, 0))
					* CFrame.Angles(0, 0, math.pi / 2),
				true,
				Enum.PartType.Cylinder
			)
			p.Transparency, p.CastShadow = 1, false
			trunks += 1
		end
	end
	for _, gate in { reserve.ArrivalGate, reserve.HomeThreshold } do
		local cf, s = gate:GetPivot(), gate:GetScale()
		for _, side in { -1, 1 } do
			local p = block(
				layer,
				"GatePillar",
				"DarkMetal",
				Vector3.new(2.3, 14, 2.7) * s,
				cf * CFrame.new(side * 8 * s, 7 * s, 0),
				true
			)
			p.Transparency, p.CastShadow = 1, false
		end
	end
	-- Native armor shoulders and paired cooling towers supplement the Blender
	-- shell's detailed walls and portal with a stronger, stepped bunker skyline.
	if prefabs:FindFirstChild("ContainmentShell") then
		local vault = root.VaultFoundry
		-- Collision carrier parts share the shell's faces. Hide their rendering
		-- so imported armor owns the appearance without coplanar flickering.
		for _, p in comfort:GetChildren() do
			if p.Name == "VaultFrontWing" or p.Name == "VaultPortalFoot" then
				p.Transparency, p.CastShadow = 1, false
			end
		end
		vault.EntryTitle.CFrame, vault.EntryTitle.Size =
			CFrame.new(0, 14.2, 105.8), Vector3.new(13, 1.8, 0.18)
		for _, side in { -1, 1 } do
			local shoulder = Instance.new("WedgePart")
			shoulder.Name, shoulder.Size, shoulder.CFrame =
				"ShieldedRoofShoulder",
				Vector3.new(66, 4.8, 9),
				CFrame.new(side * 34.5, 24.8, 142) * CFrame.Angles(0, math.rad(side * 90), 0)
			shoulder.Anchored, shoulder.CanCollide, shoulder.CanQuery, shoulder.CanTouch =
				true, true, true, false
			shoulder.Material, shoulder.Color = palette.DarkMetal.material, palette.DarkMetal.color
			shoulder:SetAttribute("MaterialGroup", "DarkMetal")
			shoulder.Parent = layer
			local x, z = side * 22, 158
			for i, entry in
				{
					{ 22.9, 0.8, 9, "DarkMetal" },
					{ 24.1, 1.6, 7.4, "WeatheredMetal" },
					{ 27.4, 5.0, 6.4, "PanelPlastic" },
					{ 29.4, 0.18, 6.6, "EnergyGreen" },
					{ 30.3, 1.0, 8.1, "DarkMetal" },
					{ 31.0, 0.5, 6.5, "SecondaryMetal" },
				}
			do
				block(
					layer,
					"CoolingTower" .. side .. "_" .. i,
					entry[4],
					Vector3.new(entry[2], entry[3], entry[3]),
					CFrame.new(x, entry[1], z) * CFrame.Angles(0, 0, math.pi / 2),
					false,
					Enum.PartType.Cylinder
				)
			end
			for j = 0, 5 do
				block(
					layer,
					"CoolingShield",
					"WeatheredMetal",
					Vector3.new(0.5, 4.2, 1.5),
					CFrame.new(x, 27.5, z)
						* CFrame.Angles(0, j * math.pi / 3, 0)
						* CFrame.new(3.4, 0, 0)
				)
			end
			block(
				layer,
				"ServiceSkirt",
				"DarkMetal",
				Vector3.new(9, 1.0, 67),
				CFrame.new(side * 41, 0.5, 142),
				true
			)
			for i = 0, 5 do
				block(
					layer,
					"EntrySafetyStripe",
					"HazardAmber",
					Vector3.new(0.55, 0.06, 2.2),
					CFrame.new(side * (17 + i * 2.8), 0.14, 104) * CFrame.Angles(0, math.rad(35), 0)
				)
			end
		end
		sign(
			layer,
			"ContainmentIdentity",
			"ENERGY CONTAINMENT  //  VAULT",
			CFrame.new(0, 23.0, 105.6),
			27,
			1.4,
			"EnergyGreen"
		)
		for _, x in { -14.3, 14.3 } do
			block(
				layer,
				"ContainmentHeaderPost",
				"DarkMetal",
				Vector3.new(0.7, 4.5, 0.7),
				CFrame.new(x, 21.8, 106.0)
			)
		end
		block(
			layer,
			"ContainmentHeaderBeam",
			"DarkMetal",
			Vector3.new(29.3, 0.45, 0.9),
			CFrame.new(0, 23.9, 106.0)
		)
	end
	-- Low planting pockets and resting places give the larger court deliberate
	-- detail while retaining its open routes and unobstructed encounter sightline.
	for i, p in { { -38, 32 }, { 38, -6 }, { -38, -8 }, { 38, 23 } } do
		local pos = Vector3.new(p[1], 0, p[2])
		block(
			station,
			"CourtPlanter",
			"DarkMetal",
			Vector3.new(9, 0.7, 4),
			CFrame.new(pos + Vector3.new(0, 0.35, 0)),
			true
		)
		for j = 1, 2 do
			asset(
				"LeafBush",
				"CourtPlant" .. i .. "_" .. j,
				pos + Vector3.new(j * 3 - 4.5, 0.65, 0),
				0.8,
				i * 57 + j * 21,
				station
			)
		end
	end
	for _, side in { -1, 1 } do
		local bench = comfort.GardenBench1:Clone()
		bench.Name, bench.Parent = "StationBench" .. side, station
		local cf, size = bench:GetBoundingBox()
		bench:PivotTo(
			CFrame.new(side * 38, 0, 10)
				* CFrame.Angles(0, math.rad(-side * 90), 0)
				* CFrame.new(-cf.Position.X, -(cf.Position.Y - size.Y / 2), -cf.Position.Z)
				* bench:GetPivot()
		)
	end
	root:SetAttribute("VisualVersion", "Mossline-Foundry-v4-Reclaimed")
	return { courtWidth = 88, stationWidth = 56, starterArea = 176 * 256, treeProxies = trunks }
end
