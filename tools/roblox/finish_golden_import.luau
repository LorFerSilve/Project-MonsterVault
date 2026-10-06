-- Edit-only follow-up to ordinary Studio Import of golden_studio_import.fbx.
-- Normalizes bounds/origins from Blender, applies the central native palette,
-- and fails before replacing prefabs if any persistent imported mesh is absent.
return function(data, importRoot, extend, textureIds)
	assert(not game:GetService("RunService"):IsRunning(), "Edit only")
	local paletteModule = game.ReplicatedStorage.MonsterVault.Shared.config.MaterialPalette:Clone()
	paletteModule.Parent = game.ServerStorage
	local palette = require(paletteModule)
	paletteModule:Destroy()
	local sources = {}
	local wanted = {}
	local assets = {}
	for _, a in data.assets do
		if a.runtime ~= false then
			table.insert(assets, a)
		end
	end
	for _, a in assets do
		for _, g in a.groups do
			wanted[g.name] = true
		end
	end
	for _, p in (importRoot or workspace):GetDescendants() do
		if p:IsA("MeshPart") and wanted[p.Name] and p.MeshId ~= "" then
			assert(not sources[p.Name], "duplicate imported mesh " .. p.Name)
			sources[p.Name] = p
		end
	end
	for _, a in assets do
		for _, g in a.groups do
			assert(sources[g.name], "missing persistent mesh " .. g.name)
		end
	end
	local parent = game.ReplicatedStorage.MonsterVault
	local old = parent:FindFirstChild("PresentationAssets")
	local folder = if extend and old then old:Clone() else Instance.new("Folder")
	folder.Name = "PresentationAssets"
	local manifest = { version = 1, assets = {} }
	for _, a in assets do
		local previous = folder:FindFirstChild(a.key)
		if previous then
			previous:Destroy()
		end
		local m = Instance.new("Model")
		m.Name, m.Parent = a.key, folder
		m.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
		m:SetAttribute("GeometrySha256", a.geometrySha256)
		m:SetAttribute("TriangleCount", a.triangles)
		local entry =
			{ key = a.key, geometrySha256 = a.geometrySha256, triangles = a.triangles, meshes = {} }
		for _, g in a.groups do
			local p = sources[g.name]:Clone()
			-- Ordinary FBX import bakes a 180-degree Y conversion into mesh-local
			-- vertices. Restore its axes around each group centroid, not the model.
			p.Size, p.CFrame =
				Vector3.new(table.unpack(g.size)),
				CFrame.new(table.unpack(g.center)) * CFrame.Angles(0, math.pi, 0)
			-- FBX imports retain centimeter-scale pivots. Model:ScaleTo also scales
			-- these offsets, so reset them before composing material-group meshes.
			p.PivotOffset = CFrame.identity
			p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
			p.TextureID, p.MaterialVariant = "", ""
			for _, c in p:GetChildren() do
				c:Destroy()
			end
			local style = assert(palette[g.material], "unknown material " .. g.material)
			p.Color, p.Material = style.color, style.material
			p:SetAttribute("MaterialGroup", g.material)
			p:SetAttribute(
				"TriangleCount",
				if typeof(g.triangles) == "number" then g.triangles else #g.triangles
			)
			p:SetAttribute("GeometrySha256", a.geometrySha256)
			if g.doubleSided then
				p.DoubleSided = true
			end
			if g.texture then
				local id =
					assert(textureIds and textureIds[g.texture], "missing texture " .. g.texture)
				local appearance = Instance.new("SurfaceAppearance")
				appearance.Name, appearance.ColorMap = "PaletteAtlas", id
				appearance.AlphaMode = if g.alpha
					then Enum.AlphaMode.Transparency
					else Enum.AlphaMode.Overlay
				appearance.Parent = p
				p:SetAttribute("PaletteAtlas", g.texture)
			end
			if g.glass then
				p.Transparency, p.CastShadow = 0.35, false
			end
			p.Parent = m
			table.insert(entry.meshes, {
				name = g.name,
				meshId = p.MeshId,
				group = g.material,
				size = g.size,
				center = g.center,
				texture = g.texture,
			})
		end
		m.WorldPivot = CFrame.identity
		table.insert(manifest.assets, entry)
	end
	if old then
		old:Destroy()
	end
	folder.Parent = parent
	return manifest
end
