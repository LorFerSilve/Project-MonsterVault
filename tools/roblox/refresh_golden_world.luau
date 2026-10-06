-- Edit-only design pass over the source-backed Golden world. No gameplay tags,
-- triggers, spawn anchors, travel points or owner actions are edited here.
return function(root)
	assert(not game:GetService("RunService"):IsRunning(), "Edit only")
	root = root or workspace.MonsterVaultPresentation
	local prefabs = game.ReplicatedStorage.MonsterVault.PresentationAssets
	for _, key in
		{
			"CanopyOak",
			"CanopyPine",
			"ReserveBoulder",
			"ReserveBoulderWide",
			"FernCluster",
			"MeadowGrass",
			"FlowerPatch",
			"LeafBush",
			"FoundryColumn",
			"FoundryWall",
			"FoundryWindow",
			"FoundryVent",
			"ServiceCrate",
			"CableHeader",
			"StationTerminal",
		}
	do
		assert(prefabs:FindFirstChild(key), "refresh prefab missing: " .. key)
	end
	local reserve, vault = root.MosslineReserve, root.VaultFoundry
	local previous = root:FindFirstChild("LibraryRefresh")
	if previous then
		previous:Destroy()
	end
	local dressing = Instance.new("Model")
	dressing.Name, dressing.Parent = "LibraryRefresh", root
	dressing.WorldPivot = CFrame.identity
	local function place(parent, key, name, position, scale, yaw)
		local model = prefabs[key]:Clone()
		model.Name = name
		model:SetAttribute("RefreshAssetKey", key)
		model:ScaleTo(scale or 1)
		model:PivotTo(CFrame.new(position) * CFrame.Angles(0, math.rad(yaw or 0), 0))
		model.Parent = parent
		return model
	end
	local function resize(model, size)
		local cf, current = model:GetBoundingBox()
		local ratio = size / current
		local pivot = model:GetPivot()
		for _, part in model:GetDescendants() do
			if part:IsA("BasePart") then
				local localCf = pivot:ToObjectSpace(part.CFrame)
				part.Size *= ratio
				part.CFrame = pivot * (localCf + localCf.Position * (ratio - Vector3.one))
			end
		end
		local after = model:GetBoundingBox()
		model:PivotTo(model:GetPivot() + cf.Position - after.Position)
	end
	local ground =
		{ workspace.MonsterVaultWorld.FixtureGround, workspace.MonsterVaultWorld.HomeHubGround }
	for _, region in { reserve, vault } do
		for _, child in region:GetChildren() do
			if child.Name:match("^MeadowBank") or child.Name:match("^FoundryBank") then
				table.insert(ground, child)
			end
		end
	end
	local params = RaycastParams.new()
	params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Include, ground
	local function grounded(p)
		local hit = workspace:Raycast(Vector3.new(p.X, 40, p.Z), Vector3.new(0, -60, 0), params)
		return Vector3.new(p.X, if hit then hit.Position.Y - 0.08 else p.Y, p.Z)
	end
	local oldRock = prefabs.Basalt:GetAttribute("GeometrySha256")
	local oldPine = prefabs.ReservePine:GetAttribute("GeometrySha256")
	local oldFern = prefabs.Fern:GetAttribute("GeometrySha256")
	local replacements = 0
	for _, region in { reserve, vault } do
		for _, old in region:GetChildren() do
			if not old:IsA("Model") then
				continue
			end
			local hash = old:GetAttribute("GeometrySha256")
			local replacement = nil
			if hash == oldRock then
				local cf, size = old:GetBoundingBox()
				local key = if replacements % 2 == 0 then "ReserveBoulder" else "ReserveBoulderWide"
				replacement = place(region, key, old.Name, Vector3.zero)
				resize(replacement, size)
				local bounds = replacement:GetBoundingBox()
				replacement:PivotTo(cf * CFrame.new(-bounds.Position))
				-- Old stretched ridge silhouettes sometimes had their entire lower
				-- edge above the meadow. Sink those visual rocks into the bank.
				if region == reserve then
					local actual, extents = replacement:GetBoundingBox()
					local bottom = actual.Position.Y - extents.Y / 2
					local floor = grounded(actual.Position).Y - 0.8
					if bottom > floor then
						replacement:PivotTo(
							replacement:GetPivot() + Vector3.new(0, floor - bottom, 0)
						)
					end
				end
			elseif hash == oldPine then
				local understory = old.Name:match("^Understory") ~= nil
				local key = if understory
					then "LeafBush"
					elseif replacements % 3 == 0 then "CanopyPine"
					else "CanopyOak"
				local scale = if understory
					then 1.1
					elseif old.Name:match("^Clearing") then 0.95
					else 1.1 + (replacements % 3) * 0.1
				replacement = place(
					region,
					key,
					old.Name,
					grounded(old:GetPivot().Position),
					scale,
					replacements * 47
				)
			elseif hash == oldFern then
				replacement = place(
					region,
					"FernCluster",
					old.Name,
					grounded(old:GetPivot().Position),
					0.4,
					replacements * 29
				)
			end
			if replacement then
				old:Destroy()
				replacements += 1
			end
		end
	end
	-- Clusters flank the route, leaving the first encounter and secure ring open.
	for i, p in
		{
			Vector3.new(-9, 0, -8),
			Vector3.new(11, 0, -10),
			Vector3.new(-13, 0, -24),
			Vector3.new(14, 0, -27),
			Vector3.new(-18, 0, -38),
			Vector3.new(32, 0, -27),
			Vector3.new(-17, 0, 27),
			Vector3.new(17, 0, 34),
			Vector3.new(-26, 0, 14),
			Vector3.new(32, 0, 9),
			Vector3.new(-24, 0, -6),
			Vector3.new(39, 0, -18),
		}
	do
		for j = 1, 4 do
			local offset = Vector3.new(math.sin(i * 2 + j) * 1.6, 0, math.cos(i + j * 2) * 1.4)
			place(
				dressing,
				"MeadowGrass",
				"Grass" .. i .. "_" .. j,
				grounded(p + offset),
				0.8 + j * 0.08,
				i * 31 + j * 57
			)
		end
		if i % 2 == 0 then
			place(
				dressing,
				"FlowerPatch",
				"Flowers" .. i,
				grounded(p + Vector3.new(1.9, 0, 1.2)),
				1,
				i * 39
			)
		end
	end
	local outpost = reserve.SafeOutpost
	for _, x in { -12, 12 } do
		for i, z in { 5.4, 13.6 } do
			place(
				dressing,
				"FoundryWindow",
				"StationBay" .. x .. "_" .. i,
				Vector3.new(x, 0.02, z),
				0.85,
				if x < 0 then -90 else 90
			)
		end
	end
	for i, p in
		{ Vector3.new(-8.8, 0.05, 20), Vector3.new(-8.5, 2.85, 20.1), Vector3.new(9.5, 0.05, 20.8) }
	do
		place(dressing, "ServiceCrate", "StationSupplies" .. i, p, 1, i * 5)
	end
	place(dressing, "StationTerminal", "FieldConsole", Vector3.new(8.8, 0.2, 14.7), 1.3, 0)
	-- Native wall collision remains; textured bays become its visible skin.
	for _, child in vault:GetChildren() do
		if child.Name == "WallInset" or child.Name == "FoundryRib" then
			child:Destroy()
		end
	end
	for _, x in { -21.4, 21.4 } do
		for i = 0, 3 do
			local z, yaw = 118.4 + i * 9.6, if x < 0 then -90 else 90
			place(
				dressing,
				"FoundryWall",
				"WallBay" .. x .. "_" .. i,
				Vector3.new(x, 0.2, z),
				1,
				yaw
			)
			place(
				dressing,
				"FoundryWindow",
				"ObservationBay" .. x .. "_" .. i,
				Vector3.new(x, 7.4, z),
				1,
				yaw
			)
		end
		for i, z in { 113.6, 132.8, 152 } do
			place(
				dressing,
				"FoundryColumn",
				"Support" .. x .. "_" .. i,
				Vector3.new(x, 0.2, z),
				1,
				if x < 0 then -90 else 90
			)
		end
	end
	for i, x in { -14.4, -4.8, 4.8, 14.4 } do
		place(dressing, "FoundryWall", "RearBay" .. i, Vector3.new(x, 0.2, 151.4), 1, 0)
		place(dressing, "FoundryWall", "RearUpperBay" .. i, Vector3.new(x, 7.4, 151.4), 1, 0)
		place(dressing, "CableHeader", "PowerHeader" .. i, Vector3.new(x, 12.7, 151.1), 1, 0)
	end
	for i, p in
		{ Vector3.new(-18, 0.2, 146), Vector3.new(-17.7, 3, 146), Vector3.new(18, 0.2, 115.5) }
	do
		place(dressing, "ServiceCrate", "MaintenanceSupplies" .. i, p, 1, i * 11)
	end
	place(dressing, "StationTerminal", "CollectionConsole", Vector3.new(-17.8, 0.2, 123.3), 1.2, 0)
	for i, x in { -15, -5, 5, 15 } do
		place(dressing, "FoundryVent", "ReturnVent" .. i, Vector3.new(x, 11.1, 151), 1.5, 180)
	end
	-- Broader entrance framing, retaining the actual entry and arrival locations.
	for _, x in { -17, 17 } do
		place(dressing, "FoundryColumn", "EntrySupport" .. x, Vector3.new(x, 0.2, 110.2), 1.04, 0)
	end
	vault.FoundryTitle.CFrame = CFrame.new(0, 16.35, 150.2)
	root:SetAttribute("VisualVersion", "Mossline-Foundry-v2-CC0")
	root:SetAttribute("RefreshReplacements", replacements)
	return { replacements = replacements, addedInstances = #dressing:GetDescendants() }
end
