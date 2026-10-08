-- Edit-only final pass after build_golden_world + refresh_golden_world.
-- Six explicit source-backed ground/bounds changes; utility/spawn/hazard anchors
-- and all gameplay IDs/radii remain unchanged. Reuses existing imported assets.
return function()
	assert(not game:GetService("RunService"):IsRunning(), "Edit only")
	local shared = game.ReplicatedStorage.MonsterVault.Shared.config
	local function fresh(source)
		local module = source:Clone()
		module.Parent = game.ServerStorage
		local value = require(module)
		module:Destroy()
		return value
	end
	local palette, layout = fresh(shared.MaterialPalette), fresh(shared.GoldenWorldLayout)
	local root, world = workspace.MonsterVaultPresentation, workspace.MonsterVaultWorld
	local reserve, vault = root.MosslineReserve, root.VaultFoundry
	local prefabs = game.ReplicatedStorage.MonsterVault.PresentationAssets
	for _, key in
		{
			"ReserveBoulder",
			"ReserveBoulderWide",
			"CanopyOak",
			"CanopyPine",
			"LeafBush",
			"FernCluster",
			"FoundryWall",
			"FoundryWindow",
			"FoundryColumn",
			"CableHeader",
			"ServiceCrate",
		}
	do
		assert(prefabs:FindFirstChild(key), key)
	end
	for name, entry in layout.world do
		world[name].Position = Vector3.new(table.unpack(entry.position))
		world[name].Size = Vector3.new(table.unpack(entry.size))
	end
	local old = root:FindFirstChild("ComfortLayer")
	if old then
		old:Destroy()
	end
	local layer = Instance.new("Model")
	layer.Name, layer.Parent = "ComfortLayer", root
	local function block(parent, name, group, size, cf, collide, shape)
		local p = Instance.new("Part")
		p.Name, p.Size, p.CFrame = name, size, cf
		if shape then
			p.Shape = shape
		end
		p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch =
			true, collide == true, collide == true, false
		p.Material, p.Color = palette[group].material, palette[group].color
		p:SetAttribute("MaterialGroup", group)
		p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		p.Parent = parent
		return p
	end
	local function asset(key, name, position, scale, yaw, parent)
		local model = prefabs[key]:Clone()
		model.Name, model.Parent = name, parent or layer
		model:SetAttribute("RefreshAssetKey", key)
		model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
		model:ScaleTo(scale or 1)
		model:PivotTo(CFrame.new(position) * CFrame.Angles(0, math.rad(yaw or 0), 0))
		return model
	end
	local function reposition(model, position)
		model:PivotTo(CFrame.new(position) * model:GetPivot().Rotation)
	end
	local function removeNamed(parent, names)
		for _, item in parent:GetChildren() do
			if names[item.Name] then
				item:Destroy()
			end
		end
	end
	-- Old exterior landscaping belonged to the narrower hall; move it out of
	-- the expanded room instead of leaving trees/banks clipping its displays.
	for _, item in vault:GetChildren() do
		local homeTree = item.Name:match("^HomeCanopy(%d+)$")
		local homeRock = item.Name:match("^HomeRock(%d+)$")
		if homeTree then
			local i = tonumber(homeTree)
			reposition(item, Vector3.new(if i % 2 == 1 then -65 else 65, -0.08, 110 + i * 15))
		elseif homeRock then
			local i = tonumber(homeRock)
			reposition(item, Vector3.new(if i % 2 == 0 then -66 else 66, -0.1, 120 + i * 15))
		elseif item.Name:match("^FoundryBank") then
			local p = item:GetPivot().Position
			reposition(item, Vector3.new(if p.X < 0 then -66 else 66, p.Y, p.Z))
		elseif item.Name:match("^FoundryCliff%-?%d+_") then
			reposition(
				item,
				Vector3.new(
					if item:GetPivot().Position.X < 0 then -72 else 72,
					-10,
					item:GetPivot().Position.Z
				)
			)
		elseif item.Name:match("^FoundryShore.*_166$") then
			reposition(item, Vector3.new(item:GetPivot().Position.X, -10, 227))
		end
	end
	reserve.ReserveCliffBase.Size, reserve.ReserveCliffBase.Position =
		Vector3.new(174, 14, 142), Vector3.new(0, -7.4, 8)
	vault.FoundryCliffBase.Size, vault.FoundryCliffBase.Position =
		Vector3.new(158, 14, 142), Vector3.new(0, -7.4, 160)
	vault.Floor.Size, vault.Floor.Position = Vector3.new(76, 0.14, 68), Vector3.new(0, 0.08, 142)
	vault.Floor.CanCollide, vault.Floor.CanQuery = true, true
	vault.FloorInset.Size, vault.FloorInset.Position =
		Vector3.new(66, 0.04, 58), Vector3.new(0, 0.17, 142)
	vault.BackWall.Size, vault.BackWall.Position = Vector3.new(77, 22, 0.7), Vector3.new(0, 11, 176)
	for _, p in vault:GetChildren() do
		if p.Name == "SideWall" then
			p.Size, p.Position =
				Vector3.new(0.7, 22, 68), Vector3.new(if p.Position.X < 0 then -38 else 38, 11, 142)
		end
	end
	removeNamed(vault, {
		RoofRib = true,
		RoofInset = true,
		RoofRail = true,
		RoofPanel = true,
		EnergyRoute = true,
		EnergyBridge = true,
		EntryDoorLeft = true,
		EntryDoorRight = true,
	})
	local refresh = root.LibraryRefresh
	for _, item in refresh:GetChildren() do
		if
			item.Name:match("^WallBay")
			or item.Name:match("^ObservationBay")
			or item.Name:match("^Support")
			or item.Name:match("^Rear")
			or item.Name:match("^PowerHeader")
			or item.Name:match("^ReturnVent")
			or item.Name:match("^EntrySupport")
			or item.Name:match("^MaintenanceSupplies")
		then
			item:Destroy()
		end
	end
	for _, x in { -37.4, 37.4 } do
		for i = 0, 6 do
			local z, yaw = 112.4 + i * 9.6, if x < 0 then -90 else 90
			asset("FoundryWall", "HallLowerBay" .. x .. "_" .. i, Vector3.new(x, 0.2, z), 1, yaw)
			asset("FoundryWindow", "HallUpperBay" .. x .. "_" .. i, Vector3.new(x, 7.4, z), 1, yaw)
		end
		for i, z in { 108, 127.2, 146.4, 165.6, 175.5 } do
			asset(
				"FoundryColumn",
				"HallSupport" .. x .. "_" .. i,
				Vector3.new(x, 0.2, z),
				1.26,
				if x < 0 then -90 else 90
			)
		end
	end
	for i = 0, 7 do
		local x = -33.6 + i * 9.6
		asset("FoundryWall", "HallRearLower" .. i, Vector3.new(x, 0.2, 175.4), 1, 0)
		asset("FoundryWall", "HallRearUpper" .. i, Vector3.new(x, 7.4, 175.4), 1, 0)
		asset("CableHeader", "HallPowerHeader" .. i, Vector3.new(x, 15.6, 175.1), 1, 0)
	end
	for i = 0, 6 do
		local z = 108 + i * 11.1
		block(layer, "HallRoofRib" .. i, "DarkMetal", Vector3.new(76, 1, 1), CFrame.new(0, 22, z))
		block(
			layer,
			"HallRoofAccent" .. i,
			"EnergyGreen",
			Vector3.new(36, 0.08, 0.12),
			CFrame.new(0, 21.4, z)
		)
	end
	for _, x in { -28, -9.5, 9.5, 28 } do
		block(
			layer,
			"HallRoofPanel",
			"DarkMetal",
			Vector3.new(18.7, 0.35, 68),
			CFrame.new(x, 22.4, 142),
			true
		)
	end
	for i, pos in layout.displays do
		reposition(vault["Display" .. i], Vector3.new(table.unpack(pos)))
		vault["DisplayLabel" .. i].CFrame = CFrame.new(pos[1], 1.3, pos[3] - 3)
	end
	local core = vault.FoundryEnergyCore
	local cf, size = core:GetBoundingBox()
	core:PivotTo(
		core:GetPivot()
			+ Vector3.new(
				26 - cf.Position.X,
				0.22 - (cf.Position.Y - size.Y / 2),
				154 - cf.Position.Z
			)
	)
	reposition(vault.EnergyRotor, Vector3.new(26, 8.6, 154))
	reposition(vault.AspirationRelay, Vector3.new(0, 0.2, 165))
	vault.AspirationLabel.CFrame = CFrame.new(0, 7.2, 163.2)
	vault.FoundryTitle.CFrame, vault.FoundryTitle.Size =
		CFrame.new(0, 19.5, 173.8), Vector3.new(38, 3, 0.18)
	reposition(vault.TravelRelay, Vector3.new(-12, 0.2, 126))
	vault.TravelLabel.CFrame = CFrame.new(-12, 2.7, 124.7)
	local console = refresh:FindFirstChild("CollectionConsole")
	if console then
		reposition(console, Vector3.new(14, 0.2, 131.4))
	end
	-- The owner control station stays beside the original eight-stud Vault anchor.
	for _, points in
		{
			{ Vector3.new(12, 0.26, 128), Vector3.new(12, 0.26, 154) },
			{ Vector3.new(12, 0.26, 154), Vector3.new(26, 0.26, 154) },
			{ Vector3.new(-24, 0.26, 132), Vector3.new(-24, 0.26, 150) },
		}
	do
		local a, b = points[1], points[2]
		block(
			layer,
			"EnergyConduit",
			"EnergyGreen",
			Vector3.new(0.1, 0.1, (a - b).Magnitude),
			CFrame.lookAt((a + b) / 2, b)
		)
	end
	for i, p in { Vector3.new(-26, 15, 126), Vector3.new(26, 15, 151), Vector3.new(0, 17, 167) } do
		local lamp = vault["UtilityLamp" .. i]
		lamp.Position = p
		lamp:FindFirstChildOfClass("PointLight").Range = 38
	end
	-- Cover straight source plates with a complete, grounded coastline silhouette.
	for _, x in { -84, 84 } do
		for i = 0, 6 do
			asset(
				"ReserveBoulderWide",
				"ReserveCoast" .. x .. "_" .. i,
				Vector3.new(x, -10.5, -55 + i * 21),
				2.9 + (i % 2) * 0.25,
				i * 41
			)
		end
	end
	for i, x in { -70, -45, -20, 5, 30, 55, 76 } do
		asset("ReserveBoulder", "ReserveNorth" .. i, Vector3.new(x, -7, -62), 2.8, i * 37)
	end
	for _, x in { -73, -45, 45, 73 } do
		asset("ReserveBoulderWide", "ReserveSouth" .. x, Vector3.new(x, -9, 77), 3, 22 + x)
	end
	for _, x in { -77, 77 } do
		for i = 0, 5 do
			asset(
				"ReserveBoulderWide",
				"HomeCoast" .. x .. "_" .. i,
				Vector3.new(x, -10.5, 99 + i * 25),
				3,
				i * 53
			)
		end
	end
	for i, x in { -62, -32, 0, 32, 62 } do
		asset("ReserveBoulderWide", "HomeRearCoast" .. i, Vector3.new(x, -10, 227), 3.2, i * 49)
	end
	for _, x in { -63, -38, 38, 63 } do
		asset("ReserveBoulderWide", "HomeFrontCoast" .. x, Vector3.new(x, -10, 91), 3, 27 + x)
	end
	-- Expanded edges have clustered vegetation; the central playable route stays open.
	for i, p in
		{
			Vector3.new(-69, 0, -28),
			Vector3.new(69, 0, -28),
			Vector3.new(-67, 0, 16),
			Vector3.new(68, 0, 22),
			Vector3.new(-48, 0, 54),
			Vector3.new(47, 0, 55),
			Vector3.new(-63, 0, 107),
			Vector3.new(63, 0, 105),
			Vector3.new(-59, 0, 146),
			Vector3.new(59, 0, 158),
			Vector3.new(-49, 0, 204),
			Vector3.new(45, 0, 208),
		}
	do
		asset(
			if i % 3 == 0 then "CanopyPine" else "CanopyOak",
			"OuterCanopy" .. i,
			p,
			1.1 + (i % 3) * 0.1,
			i * 47
		)
		for j = 1, 2 do
			asset(
				"LeafBush",
				"GardenBush" .. i .. "_" .. j,
				p + Vector3.new(j * 3.8 - 5, 0, 3 + j),
				0.9,
				i * 19 + j * 43
			)
			asset(
				"FernCluster",
				"GardenFern" .. i .. "_" .. j,
				p + Vector3.new(j * 2.5 + 3, 0, -4),
				0.4,
				i * 39
			)
		end
	end
	for i, z in { 102, 123, 145, 169, 194, 216 } do
		for _, x in { -57, 57 } do
			block(
				layer,
				"GardenWalk" .. i,
				"StoneLight",
				Vector3.new(8, 0.08, 10),
				CFrame.new(x, 0.05, z)
			)
		end
	end
	for i, p in { Vector3.new(-56, 0, 116), Vector3.new(55, 0, 197) } do
		local bench = Instance.new("Model")
		bench.Name, bench.Parent = "GardenBench" .. i, layer
		block(
			bench,
			"BenchBase",
			"DarkMetal",
			Vector3.new(7, 0.5, 2.5),
			CFrame.new(p + Vector3.new(0, 1.4, 0)),
			true
		)
		block(
			bench,
			"BenchBack",
			"SecondaryMetal",
			Vector3.new(7, 1.3, 0.22),
			CFrame.new(p + Vector3.new(0, 2.3, 1.15)),
			true
		)
		for _, x in { -2.5, 2.5 } do
			block(
				bench,
				"BenchLeg",
				"DarkMetal",
				Vector3.new(0.3, 1.3, 1.8),
				CFrame.new(p + Vector3.new(x, 0.65, 0)),
				true
			)
		end
		local seat = Instance.new("Seat")
		seat.Name = "Seat"
		seat.Size = Vector3.new(2, 0.2, 2)
		seat.Position = p + Vector3.new(0, 1.8, 0)
		seat.Anchored = true
		seat.CanCollide = true
		seat.CanTouch = true
		seat.Material = palette.PanelPlastic.material
		seat.Color = palette.PanelPlastic.color
		seat:SetAttribute("MaterialGroup", "PanelPlastic")
		seat.Parent = bench
	end
	-- Broad, automatic presentation doors; they do not implement access policy.
	for _, side in { -1, 1 } do
		local door = Instance.new("Model")
		door.Name, door.Parent = if side < 0 then "EntryDoorLeft" else "EntryDoorRight", vault
		door:SetAttribute("MotionRole", "Door")
		door:SetAttribute("OpenOffsetX", side * 10)
		local p = block(
			door,
			"DoorLeaf",
			"PanelPlastic",
			Vector3.new(9.9, 11, 0.4),
			CFrame.new(side * 5, 5.7, 108.1)
		)
		block(
			door,
			"DoorTrim",
			"SecondaryMetal",
			Vector3.new(0.3, 10.7, 0.12),
			CFrame.new(side * 0.13, 5.7, 107.82)
		)
		block(
			door,
			"DoorPower",
			"EnergyGreen",
			Vector3.new(0.12, 8, 0.1),
			CFrame.new(side * 4.5, 5.7, 107.8)
		)
		door.PrimaryPart = p
		door.WorldPivot = CFrame.new(side * 5, 5.7, 108.1)
	end
	-- The exterior is a shielded facility. Its arch stays open and its static
	-- proxies never enclose the usable room in one convex imported mesh hull.
	if prefabs:FindFirstChild("ContainmentShell") then
		asset("ContainmentShell", "RadioactiveVaultShell", Vector3.new(0, 0, 142), 1, 0)
		for _, x in { -26, 26 } do
			local p = block(
				layer,
				"VaultFrontWing",
				"DarkMetal",
				Vector3.new(24, 20, 1.2),
				CFrame.new(x, 10, 107.4),
				true
			)
			p.Transparency, p.CastShadow = 1, false
		end
		for _, x in { -12, 12 } do
			local p = block(
				layer,
				"VaultPortalFoot",
				"SecondaryMetal",
				Vector3.new(4, 13, 3),
				CFrame.new(x, 6.5, 107),
				true
			)
			p.Transparency, p.CastShadow = 1, false
		end
		for _, side in { -1, 1 } do
			for _, z in { 118, 136, 154, 172 } do
				local p = block(
					layer,
					"ArmorFootprint",
					"DarkMetal",
					Vector3.new(5, 8, 3.2),
					CFrame.new(side * 40.5, 4, z),
					true
				)
				p.Transparency, p.CastShadow = 1, false
			end
		end
		-- Retire the small old portal, which otherwise floats inside the new one.
		local oldGate = vault:FindFirstChild("VaultEntry")
		if oldGate then
			oldGate:Destroy()
		end
	end
	if prefabs:FindFirstChild("RelayRuins") then
		for i, entry in { { -54, -40, 18 }, { 58, 49, -28 } } do
			asset(
				"RelayRuins",
				"ReclaimedStation" .. i,
				Vector3.new(entry[1], 0, entry[2]),
				1,
				entry[3]
			)
			for j = 1, 3 do
				asset(
					"LeafBush",
					"RuinOvergrowth" .. i .. "_" .. j,
					Vector3.new(entry[1] - 7 + j * 4, 0.4, entry[2] + 5),
					0.7,
					j * 51
				)
			end
			local base = CFrame.new(entry[1], 0, entry[2]) * CFrame.Angles(0, math.rad(entry[3]), 0)
			local footprints = {
				{ Vector3.new(15, 0.5, 12), CFrame.new(0, 0.25, 0) },
				{ Vector3.new(6, 3.2, 1), CFrame.new(-2, 1.6, 4.8) },
				{ Vector3.new(1.6, 2.2, 1.6), CFrame.new(4.2, 1.3, 2.2) },
			}
			for _, x in { -6, 6 } do
				for _, z in { -4.8, 4.8 } do
					local height = if z < 0 then 6.5 else 8.5
					table.insert(
						footprints,
						{ Vector3.new(2, height, 2), CFrame.new(x, height / 2 + 0.15, z) }
					)
				end
				table.insert(footprints, { Vector3.new(1, 2.5, 8), CFrame.new(x, 1.5, 0) })
			end
			for _, footprint in footprints do
				local p = block(
					layer,
					"RuinStaticProxy",
					"WeatheredMetal",
					footprint[1],
					base * footprint[2],
					true
				)
				p.Transparency, p.CastShadow = 1, false
			end
		end
	end
	if prefabs:FindFirstChild("SurveyRover") then
		local center = Vector3.new(-45, 0.1, 38)
		local rover = asset("SurveyRover", "AbandonedSurveyRover", center, 1, 32)
		local p = block(
			layer,
			"RoverFootprint",
			"WeatheredMetal",
			Vector3.new(5.4, 4.6, 9),
			rover:GetPivot() * CFrame.new(0, 2.3, 0),
			true
		)
		p.Transparency, p.CastShadow = 1, false
		asset("LeafBush", "RoverOvergrowth", center + Vector3.new(3, 0, 2), 0.8, 71)
		asset("FernCluster", "RoverFern", center + Vector3.new(-3, 0, -3), 0.5, 27)
	end
	-- Simple static collision proxies: trunks and machine/structure footprints.
	local colliders = Instance.new("Model")
	colliders.Name, colliders.Parent = "PhysicalShell", layer
	local protected = {}
	for _, p in world:GetChildren() do
		if
			p:IsA("BasePart")
			and (
				p:HasTag("MonsterVaultSpawnAnchor")
				or p:HasTag("MonsterVaultSecurePoint")
				or p:HasTag("MonsterVaultRecoveryAnchor")
				or p:HasTag("MonsterVaultTravelNode")
				or p:HasTag("MonsterVaultVaultAccessPoint")
			)
		then
			table.insert(protected, p.Position)
		end
	end
	local rockCount, trunkCount = 0, 0
	for _, model in root:GetDescendants() do
		if model:IsA("Model") then
			local key = model:GetAttribute("RefreshAssetKey")
			if key == "CanopyOak" or key == "CanopyPine" then
				local pivot = model:GetPivot().Position
				local trunk = block(
					colliders,
					"Trunk" .. trunkCount,
					"BarkWood",
					Vector3.new(7, 1.15, 1.15) * Vector3.new(model:GetScale(), 1, 1),
					CFrame.new(pivot + Vector3.new(0, 3.5 * model:GetScale(), 0))
						* CFrame.Angles(0, 0, math.pi / 2),
					true,
					Enum.PartType.Cylinder
				)
				trunk.Transparency = 1
				trunk.CastShadow = false
				trunkCount += 1
			elseif key == "ReserveBoulder" or key == "ReserveBoulderWide" then
				local cf, size = model:GetBoundingBox()
				for _, point in protected do
					local delta = Vector3.new(cf.Position.X - point.X, 0, cf.Position.Z - point.Z)
					local separation = math.max(size.X, size.Z) * 0.5 + 7
					if
						delta.Magnitude < separation
						and math.abs(cf.Position.Y - point.Y) < size.Y / 2 + 8
					then
						model:PivotTo(
							model:GetPivot()
								+ (if delta.Magnitude > 0.01 then delta.Unit else Vector3.xAxis)
									* (separation - delta.Magnitude)
						)
						cf = model:GetBoundingBox()
					end
				end
				for _, part in model:GetChildren() do
					if part:IsA("MeshPart") then
						part.CanCollide, part.CanQuery = true, true
						part.CollisionFidelity = Enum.CollisionFidelity.Hull
						rockCount += 1
					end
				end
			elseif key == "FoundryColumn" then
				local cf, size = model:GetBoundingBox()
				local post = block(
					colliders,
					"StructuralPost",
					"DarkMetal",
					Vector3.new(math.min(size.X, 1.6), size.Y, math.min(size.Z, 1.6)),
					cf,
					true
				)
				post.Transparency, post.CastShadow = 1, false
			end
		end
	end
	for _, gate in { reserve.ArrivalGate, reserve.HomeThreshold } do
		local cf, scale = gate:GetPivot(), gate:GetScale()
		for _, side in { -1, 1 } do
			local p = block(
				colliders,
				"GatePillar",
				"DarkMetal",
				Vector3.new(2.3, 14, 2.7) * scale,
				cf * CFrame.new(side * 8 * scale, 7 * scale, 0),
				true
			)
			p.Transparency, p.CastShadow = 1, false
		end
	end
	for _, entry in
		{
			{ vault.FoundryEnergyCore, Vector3.new(8, 9, 8) },
			{ vault.EnergyAccumulator, Vector3.new(4, 4, 4) },
			{ vault.AspirationRelay, Vector3.new(2.4, 5, 2.4) },
		}
	do
		local cf, size = entry[1]:GetBoundingBox()
		local box = block(
			colliders,
			entry[1].Name .. "Collider",
			"PanelPlastic",
			entry[2],
			CFrame.new(cf.Position.X, entry[2].Y / 2, cf.Position.Z),
			true
		)
		box.Transparency = 1
		box.CastShadow = false
	end
	for _, p in root:GetDescendants() do
		if
			p:IsA("Part")
			and (
				p.Name == "StationColumn"
				or p.Name == "StationRail"
				or p.Name == "SupplyCabinet"
				or p.Name == "Handrail"
				or p.Name == "BridgePost"
			)
		then
			p.CanCollide, p.CanQuery = true, true
		end
	end
	root:SetAttribute("VisualVersion", "Mossline-Foundry-v3-Spacious")
	return {
		solidRocks = rockCount,
		trunkProxies = trunkCount,
		parts = #layer:GetDescendants(),
		groundOverrides = 6,
	}
end
