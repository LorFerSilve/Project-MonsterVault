--!strict
-- Cosmetic prefabs never own the root, attributes, tags or spawn lifecycle.
local shared = game:GetService("ReplicatedStorage").MonsterVault
local Catalog = require(shared.Shared.config.CreaturePresentationCatalog)
local Palette = require(shared.Shared.config.MaterialPalette)
local globals: any = getfenv()
local Instance, Enum, Vector3, CFrame =
	globals.Instance, globals.Enum, globals.Vector3, globals.CFrame
local Factory = {}
function Factory.create(projection: any): any
	local model = Instance.new("Model")
	model.Name, model.ModelStreamingMode = "WorldCreature", Enum.ModelStreamingMode.Atomic
	local root = Instance.new("Part")
	root.Name, root.Shape, root.Size = "Body", Enum.PartType.Ball, Vector3.new(4, 4, 4)
	root.Position = Vector3.new(projection.position.x, projection.position.y, projection.position.z)
	root.Anchored, root.CanCollide, root.CanTouch = true, false, false
	root.Color, root.Material = Palette.FixtureCreature.color, Palette.FixtureCreature.material
	root:SetAttribute("MaterialGroup", "FixtureCreature")
	root.Parent, model.PrimaryPart = model, root
	local definition = (Catalog :: any)[projection.speciesId]
	local library = shared:FindFirstChild("PresentationAssets")
	local prefab = definition
		and definition.rarity == projection.rarityId
		and library
		and library:FindFirstChild(definition.asset)
	if prefab then
		local visual = prefab:Clone()
		visual.Name = "CreatureVisual"
		for _, part in visual:GetDescendants() do
			if part:IsA("BasePart") then
				part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery =
					true, false, false, false
			end
		end
		visual:PivotTo(CFrame.new(root.Position) * CFrame.new(0, -2.8, 0))
		visual.Parent, root.Transparency = model, 1
	end
	return model
end
return Factory
