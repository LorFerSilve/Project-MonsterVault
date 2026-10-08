-- Native readback and strict isolation for the removable art template.
return function(write)
	assert(not game:GetService("RunService"):IsRunning(), "Edit only")
	local library = game.ReplicatedStorage.MonsterVault.SeasonalAssets
	local module = game.ReplicatedStorage.MonsterVault.Shared.config.MaterialPalette:Clone()
	module.Parent = game.ServerStorage
	local palette = require(module)
	module:Destroy()
	local function audit(root)
		local records, totals =
			{}, { parts = 0, meshes = 0, triangles = 0, lights = 0, emitters = 0 }
		local function visit(object, path)
			assert(not object:IsA("LuaSourceContainer"), "seasonal writer")
			assert(#object:GetTags() == 0, "seasonal authority tag")
			local entry =
				{ path = path, class = object.ClassName, attributes = object:GetAttributes() }
			if object:IsA("Model") then
				entry.pivot = { object:GetPivot():GetComponents() }
				entry.scale = object:GetScale()
			elseif object:IsA("BasePart") then
				assert(
					object.Anchored
						and not object.CanCollide
						and not object.CanTouch
						and not object.CanQuery,
					"seasonal physics"
				)
				local material = assert(
					palette[object:GetAttribute("MaterialGroup")],
					"unknown seasonal material"
				)
				assert(
					object.Material == material.material and object.Color == material.color,
					"unmapped seasonal mesh"
				)
				entry.frame, entry.size =
					{ object.CFrame:GetComponents() },
					{ object.Size.X, object.Size.Y, object.Size.Z }
				entry.material, entry.color, entry.transparency =
					object.Material.Name, tostring(object.Color), object.Transparency
				totals.parts += 1
				if object:IsA("MeshPart") then
					entry.mesh, entry.texture = object.MeshId, object.TextureID
					totals.meshes += 1
					totals.triangles += object:GetAttribute("TriangleCount") or 0
				end
			elseif object:IsA("Light") then
				assert(not object.Shadows, "seasonal shadow cost")
				totals.lights += 1
				entry.color, entry.range, entry.brightness =
					tostring(object.Color), object.Range, object.Brightness
			elseif object:IsA("ParticleEmitter") then
				assert(object.Rate <= 3 and object.Lifetime.Max <= 3, "seasonal emission budget")
				totals.emitters += 1
				entry.rate, entry.texture = object.Rate, object.Texture
			end
			table.insert(records, entry)
			for index, child in object:GetChildren() do
				visit(child, path .. "/" .. index .. ":" .. child.Name)
			end
		end
		visit(root, root.Name)
		assert(
			totals.parts <= 180
				and totals.triangles <= 35000
				and totals.lights == 3
				and totals.emitters == 1,
			"seasonal composition budget"
		)
		return records, totals
	end
	local before, totals = audit(library)
	local serializer = game:GetService("SerializationService")
	local bytes = serializer:SerializeInstancesAsync({ library })
	local restored = serializer:DeserializeInstancesAsync(bytes)[1]
	local after = audit(restored)
	local function same(a, b)
		if typeof(a) ~= typeof(b) then
			return false
		end
		if typeof(a) ~= "table" then
			return a == b
		end
		for key, value in a do
			if not same(value, b[key]) then
				return false
			end
		end
		for key in b do
			if a[key] == nil then
				return false
			end
		end
		return true
	end
	local identical = same(before, after)
	restored:Destroy()
	assert(identical, "seasonal serialization readback differs")
	local result = {
		version = library.Halloween2026:GetAttribute("ArtVersion"),
		identical = true,
		bytes = buffer.len(bytes),
		totals = totals,
		physicsWriters = 0,
		unmapped = 0,
		instances = #before,
	}
	if write then
		write("seasonal", buffer.tostring(bytes))
		write("seasonal_native", game:GetService("HttpService"):JSONEncode(result))
	end
	return result
end
