--!strict

local FixtureDefinition = require(script.Parent.Parent.domains.world.FixtureDefinition)
local WorldService = require(script.Parent.Parent.domains.world.WorldService)

local WorldRuntimeService = {}

function WorldRuntimeService.new(options: {
	workspace: any,
	collectionService: any,
	httpService: any,
	diagnostics: any,
	clock: (() -> number)?,
	scheduler: any?,
})
	local globals = getfenv() :: any
	local Instance = globals.Instance
	local Vector3 = globals.Vector3
	local Color3 = globals.Color3
	local Enum = globals.Enum
	local clock = options.clock or os.clock
	local scheduler = options.scheduler or globals.task
	local world: any = nil
	local runtimeRoot: any = nil
	local creatures: any = nil
	local running = false
	local generation = 0

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
			materialize = materialize,
			activate = activate,
			destroyProjection = function(model)
				model:Destroy()
			end,
		})
		generation = world.start()
		running = true
		pulse(generation)
	end

	local function stop(): { string }
		running = false
		generation += 1
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
	}
end

return WorldRuntimeService
