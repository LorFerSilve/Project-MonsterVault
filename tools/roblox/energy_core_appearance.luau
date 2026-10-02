--!strict
-- Install as an EnergyCoreAppearance ModuleScript inside the imported asset.
-- GLB names/metadata identify four groups; no per-component name list is needed.
-- The palette is shared through the main Rojo project, never copied per asset.

local styles =
	require(game:GetService("ReplicatedStorage").MonsterVault.Shared.config.MaterialPalette)

local function namedGroup(name: string): string?
	local group = name:gsub("^EC_", ""):gsub("_Mesh$", "")
	return if styles[group] then group else nil
end

local function materialGroup(part: MeshPart, asset: Instance): string?
	local attribute = part:GetAttribute("EnergyCoreMaterialGroup")
	if attribute ~= nil then
		return if typeof(attribute) == "string" and styles[attribute] then attribute else nil
	end
	local current: Instance? = part
	while current and current ~= asset do
		local group = namedGroup(current.Name)
		if group then
			return group
		end
		current = current.Parent
	end
	for _, child in part:GetChildren() do
		if child:IsA("SurfaceAppearance") then
			local group = namedGroup(child.Name)
			if group then
				return group
			end
		end
	end
	return nil
end

return function(asset: Instance): number
	local targets: { { part: MeshPart, group: string } } = {}
	local unmapped: { string } = {}
	for _, descendant in asset:GetDescendants() do
		if descendant:IsA("MeshPart") then
			local group = materialGroup(descendant, asset)
			if group then
				table.insert(targets, { part = descendant, group = group })
			else
				table.insert(unmapped, descendant:GetFullName())
			end
		end
	end
	assert(#unmapped == 0, "Unknown Energy Core material groups: " .. table.concat(unmapped, ", "))
	assert(#targets > 0, "Energy Core contains no MeshParts")
	-- Validate the whole mapping before changing any appearance properties.
	for _, target in targets do
		local style = styles[target.group]
		-- Native Material/Color must not be masked by imported texture/PBR maps.
		target.part.TextureID = ""
		for _, child in target.part:GetChildren() do
			if child:IsA("SurfaceAppearance") then
				child:Destroy()
			end
		end
		target.part.MaterialVariant = ""
		target.part.Material = style.material
		target.part.Color = style.color
		target.part:SetAttribute("EnergyCoreMaterialGroup", target.group)
	end
	return #targets
end
