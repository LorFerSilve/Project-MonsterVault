--!strict

-- Native bootstrap negatives use actual authored parts, never a replacement index.
return function(): any
	local globals = getfenv() :: any
	local Vector3, RaycastParams, Enum = globals.Vector3, globals.RaycastParams, globals.Enum
	assert(
		game:GetService("RunService"):IsStudio() and game:GetService("RunService"):IsServer(),
		"native Studio server required"
	)
	local server: any = game.ServerScriptService.MonsterVaultServer
	local registry = require(server.domains.world.WorldRegistry).new(
		require(server.domains.world.WorldDefinitions)
	)
	local Index = require(server.domains.world.WorldAuthoringIndex)
	local cs = game:GetService("CollectionService")
	local cases: any = { Valid = false }
	local mutations: any = {
		Valid = function(_root: any) end,
		MissingRegion = function(root: any)
			root.MidABounds:Destroy()
		end,
		MissingHabitat = function(root: any)
			root.MidBFieldAnchorHabitat:Destroy()
		end,
		MissingOutpost = function(root: any)
			root.AdvancedOutpost:Destroy()
		end,
		MissingSecurePoint = function(root: any)
			root.MidASecurePoint:RemoveTag("MonsterVaultSecurePoint")
		end,
		MissingRecovery = function(root: any)
			root.HomeHubRecovery:Destroy()
		end,
		MissingVault = function(root: any)
			root.HomeHubVault:Destroy()
		end,
		MissingTravel = function(root: any)
			root.MidBTravel:Destroy()
		end,
		MissingSpawnContext = function(root: any)
			root.MidAEdgeAnchor:Destroy()
		end,
		UnknownLandmark = function(root: any)
			root.MidAFieldAnchor:SetAttribute("LandmarkId", "landmark/unknown")
		end,
		DuplicateUtility = function(root: any)
			root.HomeHubVault:Clone().Parent = root
		end,
		WrongUtilityRegion = function(root: any)
			root.MidASecurePoint:SetAttribute("RegionId", "region/biome-mid-b")
		end,
		Unanchored = function(root: any)
			root.MidBSecurePoint.Anchored = false
		end,
		OverlappingRegion = function(root: any)
			root.MidABounds.Position = root.MidBBounds.Position
		end,
		OverlappingSurvey = function(root: any)
			root.MidAEdgeAnchor.Position = root.MidAFieldAnchor.Position
		end,
		UnsafeRecovery = function(root: any)
			root.MidARecovery.Position += Vector3.new(40, 0, 0)
		end,
		SpawnInsideOutpost = function(root: any)
			root.MidAFieldAnchor.Position = root.MidASecurePoint.Position
		end,
		UnknownPool = function(root: any)
			root.MidBFieldAnchor:SetAttribute("SpeciesId", "species/field-pebble")
		end,
		UnknownHazard = function(root: any)
			root.HomeHubVault:AddTag("MonsterVaultHazard")
		end,
	}
	for name, mutate in mutations do
		local root = workspace.MonsterVaultWorld:Clone()
		root.Name = "IMP10AuthoringNegative"
		root.Parent = workspace
		local collection = {
			GetTagged = function(_self: any, tag: string): any
				local result = {}
				for _, part in cs:GetTagged(tag) do
					if part:IsDescendantOf(root) then
						table.insert(result, part)
					end
				end
				return result
			end,
		}
		mutate(root)
		local ok, result = pcall(Index.new, registry, root, collection)
		root:Destroy()
		assert(ok == (name == "Valid"), "bootstrap case: " .. name)
		cases[name] =
			{ passed = true, rejected = not ok, detail = if ok then nil else tostring(result) }
	end
	-- Baseline locomotion routes have collidable native ground at every sampled leg.
	local routes = {
		{ Vector3.new(0, 0, 128), Vector3.new(0, 0, 18) },
		{ Vector3.new(0, 0, 18), Vector3.new(-48, 0, -48), Vector3.new(-96, 0, -72) },
		{ Vector3.new(0, 0, 18), Vector3.new(48, 0, -48), Vector3.new(96, 0, -72) },
		{
			Vector3.new(-96, 0, -72),
			Vector3.new(-80, 0, -196),
			Vector3.new(-40, 0, -250),
			Vector3.new(0, 0, -248),
		},
		{
			Vector3.new(96, 0, -72),
			Vector3.new(80, 0, -196),
			Vector3.new(40, 0, -250),
			Vector3.new(0, 0, -248),
		},
	}
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.RespectCanCollide = true
	params.FilterDescendantsInstances = { workspace.MonsterVaultWorld }
	local samples = 0
	for _, route in routes do
		for i = 2, #route do
			for step = 0, 20 do
				local position = route[i - 1]:Lerp(route[i], step / 20)
				local hit = workspace:Raycast(
					position + Vector3.new(0, 20, 0),
					Vector3.new(0, -40, 0),
					params
				)
				assert(hit ~= nil and hit.Instance.CanCollide, "missing baseline route ground")
				samples += 1
			end
		end
	end
	return { passed = true, cases = cases, baselineRouteGroundSamples = samples }
end
