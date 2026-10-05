--!strict

-- Semantic definitions own meaning; native geometry is validated/snapshotted once.
local WorldAuthoringIndex = {}
function WorldAuthoringIndex.new(registry: any, authored: any, collection: any): any
	assert(registry.authoringVersion == 1, "unbound canonical authoring")
	assert(authored ~= nil and authored:IsA("Folder"), "missing authored world folder")
	local function bind(tag: string, attribute: string, definitions: any): any
		local result = {}
		for _, part in collection:GetTagged(tag) do
			local id = part:GetAttribute(attribute)
			local d = definitions[id]
			assert(
				d ~= nil
					and result[id] == nil
					and part:IsA("BasePart")
					and part:IsDescendantOf(authored)
					and part.Anchored,
				"invalid authored " .. tag
			)
			assert(
				part:GetAttribute("RegionId") == (d.regionId or d.id),
				"authored region mismatch"
			)
			result[id] = table.freeze({
				part = part,
				position = part.Position,
				cframe = part.CFrame,
				size = part.Size,
				radius = d.radius,
				regionId = d.regionId or d.id,
				id = id,
				attribute = attribute,
				tag = tag,
				root = authored,
			})
		end
		for id in definitions do
			assert(result[id] ~= nil, "missing authored " .. tag)
		end
		return table.freeze(result)
	end
	local regions = bind("MonsterVaultRegion", "RegionId", registry.regions)
	local habitats = bind("MonsterVaultHabitat", "HabitatId", registry.habitats)
	local landmarks = bind("MonsterVaultLandmark", "LandmarkId", registry.landmarks)
	local outposts = bind("MonsterVaultSafeOutpost", "SafeOutpostId", registry.safeOutposts)
	local secure = bind("MonsterVaultSecurePoint", "SecurePointId", registry.securePoints)
	local recovery =
		bind("MonsterVaultRecoveryAnchor", "RecoveryAnchorId", registry.recoveryAnchors)
	local vault =
		bind("MonsterVaultVaultAccessPoint", "VaultAccessPointId", registry.vaultAccessPoints)
	local travel = bind("MonsterVaultTravelNode", "TravelNodeId", registry.travelNodes)
	local function inside(bound: any, position: any, margin: any?): boolean
		local localPoint = bound.cframe:PointToObjectSpace(position)
		local m = margin or bound.size * 0
		return math.abs(localPoint.X) + m.X <= bound.size.X / 2
			and math.abs(localPoint.Y) + m.Y <= bound.size.Y / 2
			and math.abs(localPoint.Z) + m.Z <= bound.size.Z / 2
	end
	for id, a in regions do
		assert(
			a.part.CFrame.Rotation == getfenv().CFrame.identity,
			"region bounds must be axis aligned"
		)
		for other, b in regions do
			assert(
				id == other
					or math.abs(a.position.X - b.position.X) >= (a.size.X + b.size.X) / 2
					or math.abs(a.position.Z - b.position.Z) >= (a.size.Z + b.size.Z) / 2,
				"overlapping regions"
			)
		end
	end
	for _, map in { landmarks, outposts, secure, recovery, vault, travel } do
		for _, point in map do
			assert(inside(regions[point.regionId], point.position), "point outside region")
		end
	end
	for _, habitat in habitats do
		assert(
			inside(regions[habitat.regionId], habitat.position, habitat.size / 2),
			"habitat outside region"
		)
	end
	for id, a in landmarks do
		for other, b in landmarks do
			assert(
				id == other or (a.position - b.position).Magnitude > a.radius + b.radius,
				"overlapping route points"
			)
		end
	end
	for id, o in outposts do
		local d = registry.safeOutposts[id]
		for _, utility in { secure[d.securePointId], recovery[d.recoveryAnchorId] } do
			assert(
				(o.position - utility.position).Magnitude <= o.radius,
				"utility outside protected outpost"
			)
		end
	end
	local anchors = {}
	for _, part in collection:GetTagged("MonsterVaultSpawnAnchor") do
		local id = part:GetAttribute("SpawnContextId")
		local d = registry.spawnContexts[id]
		assert(
			d ~= nil
				and anchors[id] == nil
				and part:IsA("BasePart")
				and part.Anchored
				and part:IsDescendantOf(authored),
			"invalid spawn anchor"
		)
		local habitat = habitats[d.habitatId]
		assert(
			part:GetAttribute("HabitatId") == d.habitatId
				and part:GetAttribute("RegionId") == habitat.regionId
				and table.find(d.speciesIds, part:GetAttribute("SpeciesId")) ~= nil
				and inside(habitat, part.Position),
			"spawn membership mismatch"
		)
		for _, o in outposts do
			assert(
				(o.position - part.Position).Magnitude > o.radius + 12,
				"encounter trivializes transport"
			)
		end
		anchors[id] = table.freeze({
			part = part,
			position = part.Position,
			cframe = part.CFrame,
			size = part.Size,
			root = authored,
			regionId = habitat.regionId,
			habitatId = d.habitatId,
			speciesId = part:GetAttribute("SpeciesId"),
			spawnContextId = id,
		})
	end
	for id in registry.spawnContexts do
		assert(anchors[id] ~= nil, "orphan spawn context")
	end
	local hazards = {}
	for id, bound in bind("MonsterVaultHazard", "HazardId", registry.hazards) do
		local region = regions[bound.regionId]
		assert(
			bound.cframe.Rotation == getfenv().CFrame.identity
				and bound.size.X >= 8
				and bound.size.X <= 32
				and bound.size.Z >= 8
				and bound.size.Z <= 32
				and bound.size.Y == region.size.Y
				and inside(region, bound.position, bound.size / 2)
				and not bound.part.CanCollide
				and not bound.part.CanTouch,
			"invalid DEV hazard volume"
		)
		for _, points in { outposts, secure, recovery, vault, travel, landmarks, anchors } do
			for _, point in points do
				local dx =
					math.max(math.abs(point.position.X - bound.position.X) - bound.size.X / 2, 0)
				local dz =
					math.max(math.abs(point.position.Z - bound.position.Z) - bound.size.Z / 2, 0)
				assert(
					dx * dx + dz * dz > ((point.radius or 12) + 2) ^ 2,
					"hazard overlaps safe utility or required encounter"
				)
			end
		end
		local marker = bound.part:FindFirstChild("Marker")
		local warning = bound.part:FindFirstChild("Warning")
		local label = if warning then warning:FindFirstChild("Text") else nil
		assert(
			marker
				and marker:IsA("BasePart")
				and marker.Anchored
				and not marker.CanCollide
				and not marker.CanTouch
				and marker.Transparency == 0
				and marker.CFrame.Rotation == bound.cframe.Rotation
				and marker.Position.X == bound.position.X
				and marker.Position.Z == bound.position.Z
				and marker.Size.X == bound.size.X
				and marker.Size.Z == bound.size.Z
				and inside(bound, marker.Position)
				and warning
				and warning:IsA("BillboardGui")
				and warning.Enabled
				and label
				and label:IsA("TextLabel")
				and label.Text == registry.hazards[id].warningText,
			"hazard needs its visible marker and warning"
		)
		local h = table.clone(bound)
		h.marker = marker
		local visuals = {}
		for _, part in { marker, marker:FindFirstChild("CrossA"), marker:FindFirstChild("CrossB") } do
			assert(
				part
					and part:IsA("BasePart")
					and part.Anchored
					and not part.CanCollide
					and not part.CanTouch
					and part.Transparency == 0
					and inside(bound, part.Position),
				"missing visible hazard cross"
			)
			table.insert(
				visuals,
				table.freeze({
					part = part,
					parent = part.Parent,
					cframe = part.CFrame,
					size = part.Size,
					materialGroup = part:GetAttribute("MaterialGroup"),
				})
			)
		end
		assert(#visuals == 3, "missing visible hazard cross")
		h.visuals = table.freeze(visuals)
		h.warning, h.label = warning, label
		hazards[id] = table.freeze(h)
	end
	return table.freeze({
		regions = regions,
		habitats = habitats,
		landmarks = landmarks,
		safeOutposts = outposts,
		securePoints = secure,
		recoveryAnchors = recovery,
		vaultAccessPoints = vault,
		travelNodes = travel,
		spawnAnchors = table.freeze(anchors),
		hazards = table.freeze(hazards),
	})
end
return WorldAuthoringIndex
