-- Edit-only, reproducible composition. No gameplay tags, remotes or writers.
local Builder = {}
function Builder.run()
	assert(not game:GetService("RunService"):IsRunning(), "Edit only")
	local paletteSource = game.ReplicatedStorage.MonsterVault.Shared.config.MaterialPalette:Clone()
	paletteSource.Parent = game.ServerStorage
	local palette = require(paletteSource)
	paletteSource:Destroy()
	local prefabs = game.ReplicatedStorage.MonsterVault.PresentationAssets
	local old = workspace:FindFirstChild("MonsterVaultPresentation")
	if old then
		old:Destroy()
	end
	local root = Instance.new("Model")
	root.Name, root.Parent = "MonsterVaultPresentation", workspace
	root:SetAttribute("VisualVersion", "Mossline-Foundry-v1")
	local starter, vault = Instance.new("Model"), Instance.new("Model")
	starter.Name, starter.Parent = "MosslineReserve", root
	vault.Name, vault.Parent = "VaultFoundry", root
	local function style(part, group)
		local values = assert(palette[group], "unmapped " .. group)
		part.Material, part.Color = values.material, values.color
		part:SetAttribute("MaterialGroup", group)
		part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, false, false
		part.TopSurface, part.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	end
	local function block(parent, name, group, size, cf, shape)
		local p = Instance.new("Part")
		p.Name, p.Size, p.CFrame = name, size, cf
		if shape then
			p.Shape = shape
		end
		style(p, group)
		p.Parent = parent
		return p
	end
	local function asset(parent, key, name, position, scale, yaw, stretch)
		local model = assert(prefabs:FindFirstChild(key), key):Clone()
		model.Name = name
		model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
		if stretch then
			-- Recombine the reusable rock kit into broad shoulders and ridges.
			-- Prefabs have normalized bottom pivots and axis-aligned mesh groups.
			for _, p in model:GetDescendants() do
				if p:IsA("BasePart") then
					p.Size *= stretch
					p.CFrame = CFrame.new(p.Position * stretch) * p.CFrame.Rotation
				end
			end
		end
		if scale and scale ~= 1 then
			model:ScaleTo(scale)
		end
		model:PivotTo(CFrame.new(position) * CFrame.Angles(0, math.rad(yaw or 0), 0))
		model.Parent = parent
		return model
	end
	local function sign(parent, name, text, cf, width, height, accent)
		local p = block(parent, name, "PanelPlastic", Vector3.new(width, height, 0.18), cf)
		local gui = Instance.new("SurfaceGui")
		gui.Face, gui.SizingMode, gui.PixelsPerStud =
			Enum.NormalId.Front, Enum.SurfaceGuiSizingMode.PixelsPerStud, 40
		gui.LightInfluence, gui.AlwaysOnTop, gui.Parent = 0.4, false, p
		local label = Instance.new("TextLabel")
		label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
		label.Font, label.TextSize, label.TextWrapped = Enum.Font.GothamBold, 24, true
		label.TextScaled = true
		local textLimit = Instance.new("UITextSizeConstraint")
		textLimit.MinTextSize, textLimit.MaxTextSize, textLimit.Parent = 14, 48, label
		label.Text, label.TextColor3, label.Parent =
			text, palette[accent or "CreatureCream"].color, gui
		local back = gui:Clone()
		back.Face, back.Parent = Enum.NormalId.Back, p
		return p
	end
	local function rail(parent, name, a, b, group, thickness)
		return block(
			parent,
			name,
			group,
			Vector3.new(thickness or 0.12, thickness or 0.12, (a - b).Magnitude),
			CFrame.lookAt((a + b) / 2, b)
		)
	end
	local function arrivalPad(parent, z)
		-- Wrap the unchanged eight-stud spawn collider, whose top is Y=1.
		block(
			parent,
			"ArrivalPlatform",
			"DarkMetal",
			Vector3.new(8.4, 1.06, 8.4),
			CFrame.new(0, 0.53, z)
		)
		block(
			parent,
			"ArrivalInset",
			"PanelPlastic",
			Vector3.new(6.6, 0.02, 6.6),
			CFrame.new(0, 1.08, z)
		)
		block(
			parent,
			"ArrivalStrip",
			"EnergyGreen",
			Vector3.new(6.6, 0.02, 0.08),
			CFrame.new(0, 1.10, z - 3.2)
		)
	end
	-- Low paths sit below existing functional pads and keep traversable surfaces.
	block(
		starter,
		"ReserveCliffBase",
		"MossRock",
		Vector3.new(124, 12, 124),
		CFrame.new(0, -6.4, 0)
	)
	block(vault, "FoundryCliffBase", "MossRock", Vector3.new(76, 9, 76), CFrame.new(0, -5, 128))
	-- Reused faceted shoulders conceal the rectangular functional island edges.
	-- They remain cosmetic: the original ground and bridge own traversal.
	for i = 0, 4 do
		for _, x in { -38, 38 } do
			asset(
				vault,
				"Basalt",
				"FoundryCliff" .. x .. "_" .. i,
				Vector3.new(x + math.sin(i * 2.4) * 2, -12.6, 92 + i * 17),
				2.5 + (i % 2) * 0.25,
				i * 59 + x,
				Vector3.new(1.5, 0.95, 1.4)
			)
		end
	end
	for _, z in { 90, 166 } do
		for _, x in { -27, 27 } do
			asset(
				vault,
				"Basalt",
				"FoundryShore" .. x .. "_" .. z,
				Vector3.new(x, -12.4, z),
				2.55,
				x * 2 + z,
				Vector3.new(2.2, 0.95, 1.6)
			)
		end
	end
	local ravine = block(
		root,
		"RavineWater",
		"RavineWater",
		Vector3.new(430, 0.12, 430),
		CFrame.new(0, -14, 0)
	)
	ravine.CastShadow = false
	local outpost = Instance.new("Model")
	outpost.Name, outpost.Parent = "SafeOutpost", starter
	block(outpost, "StationDeck", "DarkMetal", Vector3.new(26, 0.12, 24), CFrame.new(0, 1.02, 11))
	block(
		outpost,
		"StationInset",
		"PanelPlastic",
		Vector3.new(22, 0.04, 20),
		CFrame.new(0, 1.10, 11)
	)
	for _, x in { -12, 12 } do
		for _, z in { 1, 21 } do
			block(
				outpost,
				"StationColumn",
				"DarkMetal",
				Vector3.new(0.85, 7.5, 0.85),
				CFrame.new(x, 4.9, z)
			)
			block(
				outpost,
				"ColumnFoot",
				"SecondaryMetal",
				Vector3.new(1.45, 0.45, 1.45),
				CFrame.new(x, 1.35, z)
			)
		end
		block(
			outpost,
			"StationRail",
			"SecondaryMetal",
			Vector3.new(0.35, 0.6, 20),
			CFrame.new(x, 3, 11)
		)
		block(
			outpost,
			"StationRoofEdge",
			"DarkMetal",
			Vector3.new(1.8, 0.65, 24),
			CFrame.new(x, 8.65, 11)
		)
		block(
			outpost,
			"StationRoof",
			"DarkMetal",
			Vector3.new(7, 0.38, 24),
			CFrame.new(x * 0.73, 8.7, 11) * CFrame.Angles(0, 0, math.rad(if x > 0 then -8 else 8))
		)
		block(
			outpost,
			"UtilityLight",
			"EyeLight",
			Vector3.new(0.12, 0.15, 14),
			CFrame.new(x * 0.72, 8.35, 11)
		)
	end
	for _, z in { 1, 21 } do
		block(
			outpost,
			"StationHeader",
			"DarkMetal",
			Vector3.new(26, 0.75, 1.1),
			CFrame.new(0, 8.7, z)
		)
		block(
			outpost,
			"StationHeaderTrim",
			"SecondaryMetal",
			Vector3.new(25, 0.12, 0.2),
			CFrame.new(0, 8.3, z - 0.6)
		)
	end
	for _, x in { -9, 9 } do
		block(
			outpost,
			"SupplyCabinet",
			"PanelPlastic",
			Vector3.new(3, 3, 2.4),
			CFrame.new(x, 2.65, 18.2)
		)
		block(
			outpost,
			"CabinetTrim",
			"SecondaryMetal",
			Vector3.new(2.7, 0.15, 0.08),
			CFrame.new(x, 3.5, 16.97)
		)
	end
	sign(
		outpost,
		"StationTitle",
		"FIELD STATION  /  MOSSLINE",
		CFrame.new(0, 7.2, 0.35),
		16,
		1.3,
		"CreatureCream"
	)
	asset(outpost, "Relay", "TravelTerminal", Vector3.new(7, 1.1, 15.5), 0.38, 0)
	sign(
		outpost,
		"TerminalFace",
		"TRAVEL  /  HOME",
		CFrame.new(7, 2.1, 14.8),
		3.5,
		0.75,
		"EnergyGreen"
	)
	-- The existing safe-outpost volume is not a floor collider. Keep this
	-- cosmetic deck on the original ground so characters do not sink into it.
	outpost:PivotTo(outpost:GetPivot() + Vector3.new(0, -1, 0))
	arrivalPad(outpost, 18)
	for i = 0, 7 do
		block(
			starter,
			"MeadowPath" .. i,
			"StoneLight",
			Vector3.new(6, 0.09, 4.3),
			CFrame.new(math.sin(i * 0.4) * 1.7, 0.05, 17 - i * 4.8)
				* CFrame.Angles(0, math.rad(i * 5), 0)
		)
	end
	for i = 0, 6 do
		block(
			starter,
			"HomePath" .. i,
			"StoneLight",
			Vector3.new(8, 0.09, 5.5),
			CFrame.new(0, 0.05, 26 + i * 5.6)
		)
	end
	asset(starter, "Gate", "ArrivalGate", Vector3.new(0, 0, 31), 0.78, 0)
	sign(
		starter,
		"ArrivalTitle",
		"M O S S L I N E\nC R E A T U R E   R E S E R V E",
		CFrame.new(0, 9.7, 30.72),
		11,
		2,
		"CreatureCream"
	)
	asset(starter, "Relay", "ReserveRelay", Vector3.new(-31, 0, -21), 1.75, 10)
	block(
		starter,
		"SecureRing",
		"EnergyGreen",
		Vector3.new(0.12, 11.4, 11.4),
		CFrame.new(0, 0.18, 10) * CFrame.Angles(0, 0, math.pi / 2),
		Enum.PartType.Cylinder
	)
	block(
		starter,
		"SecureCenter",
		"DarkMetal",
		Vector3.new(0.14, 10.5, 10.5),
		CFrame.new(0, 0.19, 10) * CFrame.Angles(0, 0, math.pi / 2),
		Enum.PartType.Cylinder
	)
	sign(
		starter,
		"SecureSign",
		"SECURE YOUR FIND\nReturn with your creature",
		CFrame.new(-7, 2, 10) * CFrame.Angles(0, math.pi, 0),
		7,
		1.8,
		"EnergyGreen"
	)
	asset(starter, "Gate", "HomeThreshold", Vector3.new(0, 0, 62), 1, 180)
	sign(
		starter,
		"HomeDirection",
		"VAULT FOUNDRY  ↑",
		CFrame.new(0, 10, 61.8),
		11,
		1.7,
		"EnergyGreen"
	)
	-- Faceted boundary silhouette; inner capture meadow and optional hazard clear.
	for i = 0, 11 do
		local angle = math.pi * 2 * i / 12
		local x, z = math.cos(angle) * 59, math.sin(angle) * 55 - 2
		if math.abs(x) > 15 or z < -20 then
			asset(
				starter,
				"Basalt",
				"Ridge" .. i,
				Vector3.new(x, -2, z),
				1.4 + (i % 4) * 0.25,
				i * 31,
				Vector3.new(1.8 + (i % 3) * 0.3, 0.85, 1.25)
			)
			asset(
				starter,
				"Basalt",
				"RidgeFoot" .. i,
				Vector3.new(x * 0.82, -1, z * 0.84),
				0.8 + (i % 2) * 0.2,
				i * 63,
				Vector3.new(1.8, 0.65, 1.4)
			)
		end
	end
	for i = 0, 3 do
		for _, x in { -60, 60 } do
			asset(
				starter,
				"Basalt",
				"OuterRidge" .. x .. "_" .. i,
				Vector3.new(x, -2, -48 + i * 28),
				1.6 + (i % 3) * 0.3,
				i * 47 + 20,
				Vector3.new(2.5, 1.0 + (i % 2) * 0.2, 1.5)
			)
		end
	end
	for _, x in { -35, -10, 15, 40 } do
		asset(
			starter,
			"Basalt",
			"NorthernRidge" .. x,
			Vector3.new(x, -2, -62),
			2 + (x % 3) * 0.3,
			x * 3,
			Vector3.new(2.7, 1.15, 1.4)
		)
	end
	-- Broad banks live at the clearing edge, clear of every contract-bound anchor.
	if prefabs:FindFirstChild("MossBank") then
		for i, p in
			{
				Vector3.new(-49, -0.3, -27),
				Vector3.new(55, -0.3, -53),
				Vector3.new(-41, -0.3, -58),
				Vector3.new(50, -0.3, 9),
				Vector3.new(-53, -0.3, 24),
				Vector3.new(33, -0.3, -62),
			}
		do
			local bank = asset(starter, "MossBank", "MeadowBank" .. i, p, 1, i * 39)
			for _, part in bank:GetDescendants() do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
	end
	if prefabs:FindFirstChild("ReservePine") then
		for i, p in
			{
				Vector3.new(-45, 2, -21),
				Vector3.new(-39, 0.2, -32),
				Vector3.new(-51, 0.2, 8),
				Vector3.new(-32, 0.2, 32),
				Vector3.new(25, 0.2, 38),
				Vector3.new(56, 2, -55),
				Vector3.new(45, 0.2, -57),
				Vector3.new(-41, 2, -60),
				Vector3.new(-27, 0.2, -56),
				Vector3.new(53, 2, 4),
				Vector3.new(54, 0.2, -10),
				Vector3.new(27, 0.2, -55),
			}
		do
			asset(starter, "ReservePine", "Canopy" .. i, p, 1.9 + (i % 4) * 0.22, i * 29)
			-- Shared canopy groups create depth rather than evenly scattered trees.
			for j = 1, 2 do
				asset(
					starter,
					"ReservePine",
					"Understory" .. i .. "_" .. j,
					p + Vector3.new(j * 3.8 - 6, -math.min(p.Y, 1.5), j * 3.2),
					0.92 + j * 0.2,
					i * 37 + j * 45
				)
			end
		end
		for i, p in
			{
				Vector3.new(-22, 0.1, -32),
				Vector3.new(-26, 0.1, -8),
				Vector3.new(-15, 0.1, -48),
				Vector3.new(17, 0.1, -55),
				Vector3.new(19, 0.1, 6),
			}
		do
			asset(starter, "ReservePine", "ClearingFrame" .. i, p, 1.3 + (i % 2) * 0.25, i * 71)
			asset(
				starter,
				"Basalt",
				"ClearingShoulder" .. i,
				p + Vector3.new(2, -0.65, 1),
				0.6,
				i * 49,
				Vector3.new(2.0, 0.55, 1.6)
			)
		end
	end
	for i = 1, 20 do
		local x = (if i % 2 == 0 then 1 else -1) * (17 + (i % 5) * 5)
		local z = -46 + ((i * 17) % 87)
		if not (x > 33 and z > 22) then
			asset(
				starter,
				"Fern",
				"Fern" .. i,
				Vector3.new(x, 0.05, z),
				0.8 + (i % 3) * 0.18,
				i * 42
			)
		end
	end
	for i = 0, 5 do
		local x, z = 23 + math.cos(i) * 9, -40 + math.sin(i) * 8
		asset(
			starter,
			"Basalt",
			"EncounterRocks" .. i,
			Vector3.new(x, -0.3, z),
			0.6 + (i % 3) * 0.2,
			i * 36
		)
	end
	-- Hazard readability uses the existing footprint, with space around it.
	sign(
		starter,
		"HazardSign",
		"CAUTION / ENERGY SURGE\nUnstable ground",
		CFrame.new(44, 3, 26),
		7,
		2,
		"LegendaryGold"
	)
	for _, x in { 36, 52 } do
		block(
			starter,
			"HazardEdge",
			"LegendaryGold",
			Vector3.new(0.18, 0.12, 16),
			CFrame.new(x, 0.12, 36)
		)
	end
	-- Home approach: original ground/entry/recovery remain the walkable authority.
	local bridge = Instance.new("Model")
	bridge.Name, bridge.Parent = "ExpeditionBridge", root
	-- Wrap the existing 18 x 38 walkable route. Decoration owns no collision.
	for i = 0, 9 do
		block(
			bridge,
			"BridgeDeck" .. i,
			"DarkMetal",
			Vector3.new(17.8, 0.06, 3.7),
			CFrame.new(0, 0.04, 59.9 + i * 3.8)
		)
		block(
			bridge,
			"DeckInset" .. i,
			"PanelPlastic",
			Vector3.new(13.2, 0.02, 3.4),
			CFrame.new(0, 0.09, 59.9 + i * 3.8)
		)
	end
	for _, x in { -8.5, 8.5 } do
		for i = 0, 4 do
			block(
				bridge,
				"BridgePost",
				"SecondaryMetal",
				Vector3.new(0.45, 3.2, 0.45),
				CFrame.new(x, 1.6, 59 + i * 9)
			)
		end
		rail(
			bridge,
			"Handrail",
			Vector3.new(x, 3, 58.8),
			Vector3.new(x, 3, 95.2),
			"DarkMetal",
			0.38
		)
		rail(
			bridge,
			"RouteLight",
			Vector3.new(x, 0.18, 58.8),
			Vector3.new(x, 0.18, 95.2),
			"EnergyGreen",
			0.08
		)
		rail(
			bridge,
			"BridgeGirder",
			Vector3.new(x, -2, 58),
			Vector3.new(x, -2, 96),
			"DarkMetal",
			1.1
		)
	end
	for i = 0, 5 do
		block(
			vault,
			"Approach" .. i,
			"StoneLight",
			Vector3.new(9, 0.08, 5),
			CFrame.new(0, 0.06, 91 + i * 4.8)
		)
	end
	if prefabs:FindFirstChild("ReservePine") then
		for i, p in
			{
				Vector3.new(-31, 0.2, 98),
				Vector3.new(30, 0.2, 99),
				Vector3.new(-34, 0.2, 143),
				Vector3.new(34, 0.2, 148),
			}
		do
			asset(vault, "ReservePine", "HomeCanopy" .. i, p, 1.8, i * 46)
		end
	end
	if prefabs:FindFirstChild("MossBank") then
		for i, p in
			{
				Vector3.new(-33, -0.5, 111),
				Vector3.new(33, -0.5, 143),
				Vector3.new(-30, -0.5, 153),
				Vector3.new(30, -0.5, 103),
				Vector3.new(-31, -1.2, 91),
				Vector3.new(32, -1.2, 164),
			}
		do
			asset(vault, "MossBank", "FoundryBank" .. i, p, 0.8, i * 43)
		end
	end
	block(vault, "Floor", "DarkMetal", Vector3.new(42, 0.14, 44), CFrame.new(0, 0.08, 130))
	block(vault, "FloorInset", "PanelPlastic", Vector3.new(34, 0.04, 35), CFrame.new(0, 0.17, 130))
	arrivalPad(vault, 128)
	local backWall =
		block(vault, "BackWall", "PanelPlastic", Vector3.new(44, 18, 0.6), CFrame.new(0, 9, 152))
	backWall.CanCollide, backWall.CanQuery = true, true
	for _, x in { -22, 22 } do
		local wall =
			block(vault, "SideWall", "DarkMetal", Vector3.new(0.7, 18, 34), CFrame.new(x, 9, 132))
		wall.CanCollide, wall.CanQuery = true, true
		for i = 0, 3 do
			block(
				vault,
				"WallInset",
				"PanelPlastic",
				Vector3.new(0.14, 7, 6),
				CFrame.new(x - (if x > 0 then 0.42 else -0.42), 6, 119 + i * 9)
			)
		end
	end
	for i = 0, 4 do
		local z = 111 + i * 9.6
		for _, x in { -21, 21 } do
			block(
				vault,
				"FoundryRib",
				"SecondaryMetal",
				Vector3.new(0.8, 18, 0.8),
				CFrame.new(x, 9, z)
			)
		end
		block(vault, "RoofRib", "DarkMetal", Vector3.new(43, 1.3, 1.2), CFrame.new(0, 18, z))
		block(
			vault,
			"RoofInset",
			"EnergyGreen",
			Vector3.new(23, 0.08, 0.15),
			CFrame.new(0, 17.3, z)
		)
	end
	for _, x in { -16, 16 } do
		block(vault, "RoofRail", "DarkMetal", Vector3.new(3, 0.6, 42), CFrame.new(x, 18, 131))
	end
	for _, x in { -14, 0, 14 } do
		local roof = block(
			vault,
			"RoofPanel",
			"DarkMetal",
			Vector3.new(13.8, 0.35, 42),
			CFrame.new(x, 18.4, 131)
		)
		roof.CanCollide, roof.CanQuery = true, true
	end
	for i, position in
		{ Vector3.new(-13, 12, 121), Vector3.new(13, 12, 133), Vector3.new(8, 13, 146) }
	do
		local lamp = block(
			vault,
			"UtilityLamp" .. i,
			"EyeLight",
			Vector3.new(2.4, 0.12, 0.4),
			CFrame.new(position)
		)
		local light = Instance.new("PointLight")
		light.Color, light.Brightness, light.Range, light.Shadows, light.Parent =
			Color3.fromRGB(235, 221, 174), 1.1, 26, false, lamp
	end
	asset(vault, "Gate", "VaultEntry", Vector3.new(0, 0.12, 108), 1.2, 180)
	sign(
		vault,
		"FoundryTitle",
		"M O N S T E R V A U L T\nF O U N D R Y",
		CFrame.new(0, 14.3, 151.6),
		28,
		3,
		"CreatureCream"
	)
	sign(vault, "EntryTitle", "YOUR VAULT", CFrame.new(0, 12.8, 107.8), 13, 1.8, "EnergyGreen")
	for i, z in { 120, 133 } do
		local pad = asset(vault, "Plinth", "Display" .. i, Vector3.new(-12, 0.22, z), 1.15, 0)
		pad:SetAttribute("PresentationSlotIndex", i)
		sign(
			vault,
			"DisplayLabel" .. i,
			"DISPLAY  0" .. i,
			CFrame.new(-12, 1.3, z - 3),
			5,
			1,
			"CreatureCream"
		)
	end
	local core = prefabs:FindFirstChild("EnergyCore")
		or workspace:FindFirstChild("EnergyCoreGenerator_Source")
	if not core then
		for _, m in workspace:GetDescendants() do
			if m.Name == "EnergyCoreGenerator_Source" then
				core = m
				break
			end
		end
	end
	assert(core, "existing Energy Core missing")
	local machine = core:Clone()
	machine.Name = "FoundryEnergyCore"
	machine:ScaleTo(1.5)
	for _, d in machine:GetDescendants() do
		if d:IsA("LuaSourceContainer") then
			d:Destroy()
		elseif d:IsA("BasePart") then
			d.Anchored, d.CanCollide, d.CanTouch, d.CanQuery = true, false, false, false
		end
	end
	local cf = machine:GetPivot()
	local bounds, size = machine:GetBoundingBox()
	-- The preserved Core uses a bottom pivot, not a center pivot. Ground its
	-- bounds without changing that editable pivot or its native orientation.
	machine:PivotTo(
		cf
			+ Vector3.new(
				13 - bounds.Position.X,
				0.22 - (bounds.Position.Y - size.Y / 2),
				141 - bounds.Position.Z
			)
	)
	machine.Parent = vault
	local accumulator =
		asset(vault, "Accumulator", "EnergyAccumulator", Vector3.new(12, 0.22, 128), 1.3, 0)
	accumulator:SetAttribute("SensoryRole", "EnergyClaim")
	local readout = sign(
		accumulator,
		"OutputReadout",
		"ASSIGN A PRODUCER",
		CFrame.new(12, 2.1, 125.45),
		2.9,
		1.15,
		"CreatureCream"
	)
	readout:FindFirstChildOfClass("SurfaceGui"):FindFirstChildOfClass("TextLabel").Name =
		"OutputState"
	local rotor = Instance.new("Model")
	rotor.Name, rotor.Parent = "EnergyRotor", vault
	for i = 0, 2 do
		block(
			rotor,
			"RotorVane",
			"SecondaryMetal",
			Vector3.new(3, 0.12, 0.16),
			CFrame.new(13, 8.6, 141) * CFrame.Angles(0, i * math.pi / 3, 0)
		)
	end
	rotor.WorldPivot = CFrame.new(13, 8.6, 141)
	sign(
		vault,
		"ClaimLabel",
		"ENERGY ACCUMULATOR\nClaim your saved output",
		CFrame.new(12, 5.5, 125.2),
		8,
		2,
		"EnergyGreen"
	)
	for _, x in { -12, 12 } do
		rail(
			vault,
			"EnergyRoute",
			Vector3.new(x, 0.27, 141),
			Vector3.new(x, 0.27, 114),
			"EnergyGreen",
			0.10
		)
	end
	rail(
		vault,
		"EnergyBridge",
		Vector3.new(-12, 0.27, 141),
		Vector3.new(13, 0.27, 141),
		"EnergyGreen",
		0.10
	)
	sign(
		vault,
		"TravelLabel",
		"RETURN TO MOSSLINE\nTravel terminal",
		CFrame.new(-18, 2.7, 124.7),
		4.8,
		1.8,
		"CreatureCream"
	)
	asset(vault, "Relay", "TravelRelay", Vector3.new(-18, 0.2, 126), 0.52, 0)
	-- Rare concept remains offline; this permanent space shows the next aspiration.
	asset(vault, "Relay", "AspirationRelay", Vector3.new(0, 0.2, 145), 0.75, 0)
	sign(
		vault,
		"AspirationLabel",
		"EXPAND YOUR COLLECTION\nReview your next aspiration",
		CFrame.new(0, 7.2, 143.2),
		9,
		1.5,
		"CreatureCream"
	)
	for i = 0, 5 do
		asset(
			vault,
			"Basalt",
			"HomeRock" .. i,
			Vector3.new((if i % 2 == 0 then -1 else 1) * 31, -1, 108 + math.floor(i / 2) * 18),
			1.5,
			i * 61
		)
	end
	root.WorldPivot = CFrame.identity
	return root
end
return Builder
