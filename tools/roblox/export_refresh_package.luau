-- Edit-only native package/readback evidence. The optional local write callback
-- is supplied by the development bridge; no runtime HTTP or gameplay writer.
return function(write)
	assert(not game:GetService("RunService"):IsRunning(), "Edit only")
	local serialization = game:GetService("SerializationService")
	local evidence = { packages = {}, authority = {}, materials = {} }
	local function signatures(root)
		local result = {}
		local function visit(instance, path)
			local entry = {
				class = instance.ClassName,
				attributes = instance:GetAttributes(),
				tags = instance:GetTags(),
			}
			if instance:IsA("LuaSourceContainer") then
				error("script in art package: " .. path)
			end
			if instance:IsA("BasePart") then
				entry.size, entry.frame =
					{ instance.Size.X, instance.Size.Y, instance.Size.Z },
					{ instance.CFrame:GetComponents() }
				entry.color, entry.material = tostring(instance.Color), tostring(instance.Material)
				entry.pivot, entry.anchored =
					{ instance.PivotOffset:GetComponents() }, instance.Anchored
				entry.collide, entry.touch, entry.query =
					instance.CanCollide, instance.CanTouch, instance.CanQuery
				entry.transparency, entry.castShadow = instance.Transparency, instance.CastShadow
				if instance:IsA("MeshPart") then
					entry.mesh, entry.texture, entry.doubleSided =
						instance.MeshId, instance.TextureID, instance.DoubleSided
				end
			elseif instance:IsA("Model") then
				entry.frame, entry.scale, entry.streaming =
					{ instance:GetPivot():GetComponents() },
					instance:GetScale(),
					tostring(instance.ModelStreamingMode)
			elseif instance:IsA("SurfaceAppearance") then
				entry.colorMap, entry.alpha, entry.color =
					instance.ColorMap, tostring(instance.AlphaMode), tostring(instance.Color)
			elseif instance:IsA("TextLabel") then
				entry.text, entry.font, entry.textSize =
					instance.Text, tostring(instance.Font), instance.TextSize
			elseif instance:IsA("Light") then
				entry.color, entry.brightness, entry.range, entry.shadows =
					tostring(instance.Color), instance.Brightness, instance.Range, instance.Shadows
			end
			result[path] = entry
			local names = {}
			for _, child in instance:GetChildren() do
				names[child.Name] = (names[child.Name] or 0) + 1
				visit(child, path .. "/" .. child.Name .. "#" .. names[child.Name])
			end
		end
		visit(root, root.Name)
		return result
	end
	local differences = {}
	local function same(a, b, path)
		path = path or "root"
		if typeof(a) ~= typeof(b) then
			table.insert(differences, path .. ": type " .. typeof(a) .. " / " .. typeof(b))
			return false
		end
		if typeof(a) ~= "table" then
			if a ~= b and #differences < 12 then
				table.insert(differences, path .. ": " .. tostring(a) .. " / " .. tostring(b))
			end
			return a == b
		end
		local identical = true
		for k, v in a do
			if not same(v, b[k], path .. "/" .. tostring(k)) then
				identical = false
			end
		end
		for k in b do
			if a[k] == nil then
				identical = false
				if #differences < 12 then
					table.insert(differences, path .. "/" .. tostring(k) .. ": added")
				end
			end
		end
		return identical
	end
	for _, item in
		{
			{ "library", game.ReplicatedStorage.MonsterVault.PresentationAssets },
			{ "world", workspace.MonsterVaultPresentation },
		}
	do
		local label, source = item[1], item[2]
		local before = signatures(source)
		local blob = serialization:SerializeInstancesAsync({ source })
		local restored = serialization:DeserializeInstancesAsync(blob)[1]
		local after = signatures(restored)
		local identical = same(before, after)
		if not identical then
			restored:Destroy()
			error("native roundtrip differs: " .. label .. "\n" .. table.concat(differences, "\n"))
		end
		local parts, meshes, triangles, instances = 0, 0, 0, 0
		for _, entry in before do
			instances += 1
			if entry.class == "Part" or entry.class == "MeshPart" then
				parts += 1
			end
			if entry.class == "MeshPart" then
				meshes += 1
				triangles += entry.attributes.TriangleCount or 0
			end
		end
		evidence.packages[label] = {
			identical = identical,
			bytes = buffer.len(blob),
			parts = parts,
			meshes = meshes,
			triangles = triangles,
			instances = instances,
		}
		if write then
			write(label, buffer.tostring(blob))
		end
		restored:Destroy()
	end
	local prior = game:GetService("HttpService")
		:JSONDecode(game.ServerStorage.RefreshAnchorSnapshot.Value)
	local current = {}
	for _, p in workspace.MonsterVaultWorld:GetDescendants() do
		if p:IsA("BasePart") then
			table.insert(current, {
				name = p.Name,
				frame = { p.CFrame:GetComponents() },
				size = { p.Size.X, p.Size.Y, p.Size.Z },
				collide = p.CanCollide,
				touch = p.CanTouch,
				query = p.CanQuery,
				tags = p:GetTags(),
			})
		end
	end
	table.sort(current, function(a, b)
		return a.name < b.name
	end)
	assert(same(prior, current), "gameplay anchors changed")
	evidence.authority =
		{ before = #prior, after = #current, identical = true, decorativeWriters = 0 }
	local paletteModule = game.ReplicatedStorage.MonsterVault.Shared.config.MaterialPalette:Clone()
	paletteModule.Parent = game.ServerStorage
	local palette = require(paletteModule)
	paletteModule:Destroy()
	local checked, unknown, textures, lights = 0, {}, 0, 0
	for _, p in workspace.MonsterVaultPresentation:GetDescendants() do
		if p:IsA("BasePart") then
			checked += 1
			local style = palette[p:GetAttribute("MaterialGroup")]
			if not style or p.Color ~= style.color or p.Material ~= style.material then
				table.insert(unknown, p:GetFullName())
			end
		elseif p:IsA("SurfaceAppearance") then
			textures += 1
			assert(p.ColorMap ~= "", "missing palette atlas")
		elseif p:IsA("Light") then
			lights += 1
		end
	end
	assert(#unknown == 0, "unmapped materials")
	evidence.materials =
		{ checked = checked, unknown = unknown, atlasInstances = textures, lights = lights }
	if write then
		write("native", game:GetService("HttpService"):JSONEncode(evidence))
	end
	return evidence
end
