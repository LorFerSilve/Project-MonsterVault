--!strict

local FixtureDefinition = require(script.Parent.Parent.domains.world.FixtureDefinition)
local WorldService = require(script.Parent.Parent.domains.world.WorldService)
local WorldRegistry = require(script.Parent.Parent.domains.world.WorldRegistry)
local WorldDefinitions = require(script.Parent.Parent.domains.world.WorldDefinitions)
local VariantIdentity = require(script.Parent.Parent.domains.capture.VariantIdentity)

local WorldRuntimeService = {}

function WorldRuntimeService.new(options: {
	workspace: any,
	collectionService: any,
	httpService: any,
	diagnostics: any,
	worldProgression: any?,
	worldActions: any?,
	profileCoordinator: any?,
	event: any?,
	clock: (() -> number)?,
	scheduler: any?,
	random: any?,
})
	local globals = getfenv() :: any
	local Instance = globals.Instance
	local Vector3 = globals.Vector3
	local Color3 = globals.Color3
	local Enum = globals.Enum
	local clock = options.clock or os.clock
	local scheduler = options.scheduler or globals.task
	local random = options.random or globals.Random.new()
	local world: any = nil
	local runtimeRoot: any = nil
	local creatures: any = nil
	local running = false
	local generation = 0
	local registry = if options.worldProgression
		then options.worldProgression.registry
		else WorldRegistry.new(WorldDefinitions)
	local landmarkIndex: any = nil
	local landmarkConnections = {}
	local prompts = {}
	local function resync(player: any, requestId: string): string
		if
			not running
			or options.worldActions == nil
			or options.profileCoordinator == nil
			or options.worldProgression == nil
		then
			return "UNAVAILABLE_WORLD"
		end
		local session = options.profileCoordinator.get(player.UserId)
		local result = options.worldActions.reconcile(session)
		if result.status == "OutcomeUnknown" then
			return "OUTCOME_UNKNOWN_WORLD_WRITE"
		end
		if result.status ~= "Unchanged" then
			return "PROTECTED_WORLD_UNAVAILABLE"
		end
		if options.event then
			local p = session.snapshot()
			local milestones = {}
			for id in registry.milestones do
				if options.worldProgression.mastery(p, id) then
					table.insert(milestones, id)
				end
			end
			table.sort(milestones)
			-- At most four registry-backed IDs; no private evidence or operation IDs.
			options.event:FireClient(player, {
				protocolVersion = 1,
				routeId = "World.StateChanged",
				correlationId = requestId,
				payload = {
					profileRevision = p.profileRevision,
					masteryMilestoneIds = milestones,
				},
			})
		end
		return "OK_WORLD_RECONCILED"
	end

	local function discover(player: any, landmarkId: string): string
		if
			not running
			or landmarkIndex == nil
			or options.worldActions == nil
			or options.profileCoordinator == nil
		then
			return "UNAVAILABLE_WORLD"
		end
		local bound = landmarkIndex[landmarkId]
		if bound == nil then
			return "REJECT_STATE_WORLD_UNKNOWN_LANDMARK"
		end
		local session = options.profileCoordinator.get(player.UserId)
		local result = options.worldActions.visit(session, landmarkId, function(): boolean
			local character = player.Character
			local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
			local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
			return root ~= nil
				and humanoid ~= nil
				and humanoid.Health > 0
				and (root.Position - bound.position).Magnitude <= bound.radius
		end)
		if result.status == "Committed" or result.status == "AlreadyCommitted" then
			return "OK_WORLD_VISITED"
		end
		if result.status == "OutcomeUnknown" then
			return "OUTCOME_UNKNOWN_WORLD_WRITE"
		end
		return "REJECT_STATE_WORLD_" .. (result.reason or string.upper(result.status))
	end

	local function validateAuthoring()
		local authored = options.workspace:FindFirstChild("MonsterVaultWorld")
		assert(authored ~= nil and authored:IsA("Folder"), "missing authored world folder")
		local anchor = authored:FindFirstChild("FixtureCreatureAnchor")
		assert(anchor ~= nil and anchor:IsA("BasePart"), "missing fixture creature anchor")
		assert(
			anchor:GetAttribute("SpawnContextId") == FixtureDefinition.spawnContextId,
			"fixture spawn context mismatch"
		)
		assert(
			anchor:GetAttribute("SpeciesId") == FixtureDefinition.speciesId,
			"fixture species mismatch"
		)
		local expected = FixtureDefinition.position
		assert(
			(anchor.Position - Vector3.new(expected.x, expected.y, expected.z)).Magnitude < 0.01,
			"fixture anchor position mismatch"
		)
		local context = assert(
			registry.spawnContexts[FixtureDefinition.spawnContextId],
			"unknown fixture context"
		)
		assert(
			registry.habitats[context.habitatId].regionId == FixtureDefinition.regionId
				and context.habitatId == FixtureDefinition.habitatId,
			"fixture registry region mismatch"
		)
		assert(
			table.find(context.speciesIds, FixtureDefinition.speciesId) ~= nil
				and table.find(context.contentSnapshotIds, FixtureDefinition.contentSnapshotId)
					~= nil,
			"fixture registry provenance mismatch"
		)
		local index = {}
		for _, part in options.collectionService:GetTagged("MonsterVaultLandmark") do
			local landmarkId = part:GetAttribute("LandmarkId")
			local d = registry.landmarks[landmarkId]
			assert(
				d ~= nil
					and index[landmarkId] == nil
					and part:IsA("BasePart")
					and part:IsDescendantOf(authored)
					and part.Anchored,
				"invalid authored landmark"
			)
			assert(part:GetAttribute("RegionId") == d.regionId, "landmark region mismatch")
			index[landmarkId] =
				table.freeze({ position = part.Position, radius = d.radius, part = part })
		end
		for landmarkId in registry.landmarks do
			assert(index[landmarkId] ~= nil, "missing authored landmark")
		end
		for a, va in index do
			for b, vb in index do
				assert(
					a == b or (va.position - vb.position).Magnitude > va.radius + vb.radius,
					"overlapping route points"
				)
			end
		end
		landmarkIndex = table.freeze(index)
	end

	local function materialize(projection: any): any
		local model = Instance.new("Model")
		model.Name = "FixtureCreature"
		model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
		local body = Instance.new("Part")
		body.Name = "Body"
		body.Shape = Enum.PartType.Ball
		body.Size = Vector3.new(4, 4, 4)
		body.Position =
			Vector3.new(projection.position.x, projection.position.y, projection.position.z)
		body.Anchored = true
		body.CanCollide = false
		body.CanTouch = false
		body.Color = Color3.fromRGB(77, 205, 255)
		body.Material = Enum.Material.Neon
		body.Parent = model
		model.PrimaryPart = body
		return model
	end

	local function activate(model: any, projection: any)
		model:SetAttribute("CreatureInstanceId", projection.creatureInstanceId)
		model:SetAttribute("SpeciesId", projection.speciesId)
		model:SetAttribute("RarityId", projection.rarityId)
		model:SetAttribute("SpawnContextId", projection.spawnContextId)
		model:SetAttribute("RuntimeRevision", projection.runtimeRevision)
		model:SetAttribute("Availability", projection.availability)
		options.collectionService:AddTag(model, "MonsterVaultWorldCreature")
		model.Parent = creatures
	end

	local function pulse(expectedGeneration: number)
		if not running or expectedGeneration ~= generation then
			return
		end
		local ok, outcome = pcall(world.step, expectedGeneration)
		if not ok then
			running = false
			generation += 1
			pcall(world.stop)
			if runtimeRoot ~= nil then
				runtimeRoot:Destroy()
				runtimeRoot = nil
				creatures = nil
			end
			options.diagnostics.emit("error", "WORLD_SCHEDULER_FAILED", { component = "world" })
			return
		end
		if outcome == "Spawned" or outcome == "Expired" then
			options.diagnostics.emit(
				"info",
				"WORLD_" .. string.upper(outcome),
				{ component = "world" }
			)
		end
		scheduler.delay(1, function()
			pulse(expectedGeneration)
		end)
	end

	local function start()
		assert(not running and world == nil, "world service already started")
		validateAuthoring()
		assert(
			options.workspace:FindFirstChild("MonsterVaultRuntime") == nil,
			"runtime container already exists"
		)
		local root = Instance.new("Folder")
		root.Name = "MonsterVaultRuntime"
		local creatureFolder = Instance.new("Folder")
		creatureFolder.Name = "Creatures"
		creatureFolder.Parent = root
		root.Parent = options.workspace
		runtimeRoot = root
		creatures = creatureFolder
		world = WorldService.new({
			fixture = FixtureDefinition,
			clock = clock,
			newId = function()
				return "creature-" .. options.httpService:GenerateGUID(false)
			end,
			generateVariant = function(candidate)
				return VariantIdentity.generate(candidate, {
					nextUnit = function()
						return random:NextNumber()
					end,
				})
			end,
			materialize = materialize,
			activate = activate,
			updateProjection = function(model, projection)
				model:SetAttribute("Availability", projection.availability)
				model:SetAttribute("RuntimeRevision", projection.runtimeRevision)
			end,
			destroyProjection = function(model)
				model:Destroy()
			end,
		})
		generation = world.start()
		running = true
		if options.worldActions then
			for landmarkId, bound in landmarkIndex do
				local prompt = Instance.new("ProximityPrompt")
				prompt.Name = "MonsterVaultSurvey"
				prompt.ActionText = "Survey"
				prompt.ObjectText = if landmarkId == "landmark/fixture-entry"
					then "Entry landmark"
					else "Clearing landmark"
				prompt.MaxActivationDistance = bound.radius
				prompt.RequiresLineOfSight = false
				prompt.Parent = bound.part
				table.insert(prompts, prompt)
				table.insert(
					landmarkConnections,
					prompt.Triggered:Connect(function(player)
						discover(player, landmarkId)
					end)
				)
			end
		end
		pulse(generation)
	end

	local function stop(): { string }
		running = false
		generation += 1
		for _, connection in landmarkConnections do
			connection:Disconnect()
		end
		for _, prompt in prompts do
			prompt:Destroy()
		end
		table.clear(landmarkConnections)
		table.clear(prompts)
		if world ~= nil then
			world.stop()
		end
		if runtimeRoot ~= nil then
			runtimeRoot:Destroy()
			runtimeRoot = nil
			creatures = nil
		end
		return {}
	end

	return {
		id = "world",
		dependencies = {},
		start = start,
		stop = stop,
		world = function(): any
			return world
		end,
		discover = discover,
		resync = resync,
		isLandmark = function(id: string): boolean
			return registry.landmarks[id] ~= nil
		end,
		registry = registry,
	}
end

return WorldRuntimeService
