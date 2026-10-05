--!strict

local FixtureDefinition = require(script.Parent.Parent.domains.world.FixtureDefinition)
local WorldService = require(script.Parent.Parent.domains.world.WorldService)
local WorldCycle = require(script.Parent.Parent.domains.world.WorldCycle)
local WorldTravelService = require(script.Parent.Parent.domains.world.WorldTravelService)
local WorldRegistry = require(script.Parent.Parent.domains.world.WorldRegistry)
local WorldDefinitions = require(script.Parent.Parent.domains.world.WorldDefinitions)
local WorldAuthoringIndex = require(script.Parent.Parent.domains.world.WorldAuthoringIndex)
local SpawnPlan = require(script.Parent.Parent.domains.world.SpawnPlan)
local VariantIdentity = require(script.Parent.Parent.domains.capture.VariantIdentity)
local MaterialPalette =
	require(game:GetService("ReplicatedStorage").MonsterVault.Shared.config.MaterialPalette)

local WorldRuntimeService = {}

function WorldRuntimeService.new(
	options: {
		workspace: any,
		collectionService: any,
		players: any?,
		httpService: any,
		diagnostics: any,
		worldProgression: any?,
		worldActions: any?,
		profileCoordinator: any?,
		event: any?,
		fixture: any?, -- Server composition/test injection; never a wire field.
		clock: (() -> number)?,
		cycleUnixSeconds: (() -> number)?, -- Absolute server wall time, separate from lifecycle time.
		scheduler: any?,
		random: any?,
	}
)
	local globals = getfenv() :: any
	local Instance = globals.Instance
	local Vector3 = globals.Vector3
	local Enum = globals.Enum
	local clock = options.clock or os.clock
	local scheduler = options.scheduler or globals.task
	local random = options.random or globals.Random.new()
	local spatialWorkspace = game:GetService("Workspace")
	local world: any = nil
	local runtimeRoot: any = nil
	local creatures: any = nil
	local running = false
	local generation = 0
	local pulseTicket = 0
	local activeRegions: { [string]: number } = {}
	local registry = if options.worldProgression
		then options.worldProgression.registry
		else WorldRegistry.new(WorldDefinitions)
	local fixture = options.fixture or FixtureDefinition
	local cycle = WorldCycle.new(registry.worldCycle, options.cycleUnixSeconds or os.time)
	local publishedCycle: any = nil
	local cycleAvailable: boolean? = nil
	local function publishCycle()
		local snapshot = cycle.sample()
		if runtimeRoot == nil then
			return
		end
		local available = snapshot ~= nil
		if available == cycleAvailable and snapshot == publishedCycle then
			return
		end
		cycleAvailable, publishedCycle = available, snapshot
		runtimeRoot:SetAttribute("WorldCycleAvailable", available)
		runtimeRoot:SetAttribute(
			"WorldCycleDefinitionId",
			if snapshot then snapshot.definitionId else nil
		)
		runtimeRoot:SetAttribute("WorldCyclePhaseId", if snapshot then snapshot.phaseId else nil)
		runtimeRoot:SetAttribute("WorldCycleIndex", if snapshot then snapshot.cycleIndex else nil)
		runtimeRoot:SetAttribute(
			"WorldCyclePhaseStartedAt",
			if snapshot then snapshot.phaseStartedAtUnixSeconds else nil
		)
		runtimeRoot:SetAttribute(
			"WorldCycleNextTransitionAt",
			if snapshot then snapshot.nextTransitionUnixSeconds else nil
		)
		local eligible = {}
		for id, context in registry.spawnContexts do
			if WorldCycle.eligible(registry.habitats[context.habitatId], context, snapshot) then
				table.insert(eligible, id)
			end
		end
		table.sort(eligible)
		runtimeRoot:SetAttribute("EligibleSpawnContextIds", table.concat(eligible, ","))
	end
	local authoringIndex: any = nil
	local landmarkIndex: any = nil
	local vaultAccessHandler: any = nil
	local landmarkConnections = {}
	local prompts = {}
	local captureLifecycle: any = nil
	local travelOwner: any = nil
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
			local discovered = {}
			for id in registry.travelNodes do
				if options.worldProgression.travelDiscovered(p, id) then
					table.insert(discovered, id)
				end
			end
			table.sort(discovered)
			local presence = if captureLifecycle then captureLifecycle.presence(player) else nil
			-- At most four registry-backed IDs; no private evidence or operation IDs.
			options.event:FireClient(player, {
				protocolVersion = 1,
				routeId = "World.StateChanged",
				correlationId = requestId,
				payload = {
					profileRevision = p.profileRevision,
					masteryMilestoneIds = milestones,
					discoveredTravelNodeIds = discovered,
					characterGeneration = if presence then presence.generation else nil,
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
			local presence = if captureLifecycle then captureLifecycle.presence(player) else nil
			if
				presence == nil
				or travelOwner == nil
				or not travelOwner.ready(player, presence.generation)
			then
				return false
			end
			local character = player.Character
			local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
			local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
			return root ~= nil
				and humanoid ~= nil
				and humanoid.Health > 0
				and bound.part.Parent ~= nil
				and bound.part:IsDescendantOf(bound.root)
				and bound.part:HasTag(bound.tag)
				and bound.part.Anchored
				and bound.part.Position == bound.position
				and bound.part:GetAttribute("LandmarkId") == landmarkId
				and bound.part:GetAttribute("RegionId") == bound.regionId
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
		authoringIndex = WorldAuthoringIndex.new(registry, authored, options.collectionService)
		landmarkIndex = authoringIndex.landmarks
		local anchor =
			assert(authoringIndex.spawnAnchors[fixture.spawnContextId], "unknown encounter anchor")
		local context = registry.spawnContexts[fixture.spawnContextId]
		assert(
			anchor.regionId == fixture.regionId
				and anchor.habitatId == fixture.habitatId
				and table.find(context.speciesIds, fixture.speciesId)
				and registry.species[fixture.speciesId].rarityId == fixture.rarityId
				and table.find(context.contentSnapshotIds, fixture.contentSnapshotId),
			"encounter provenance mismatch"
		)
		local p = fixture.position
		assert(
			(anchor.position - Vector3.new(p.x, p.y, p.z)).Magnitude < 0.01,
			"encounter anchor position mismatch"
		)
	end
	local function liveBinding(bound: any): boolean
		local part = bound.part
		return part.Parent ~= nil
			and part:IsDescendantOf(bound.root)
			and part:HasTag(bound.tag)
			and part.Anchored
			and part.Position == bound.position
			and part.CFrame == bound.cframe
			and part.Size == bound.size
			and part:GetAttribute(bound.attribute) == bound.id
			and part:GetAttribute("RegionId") == bound.regionId
	end
	local function liveSpawn(bucket: any): boolean
		local anchor = authoringIndex.spawnAnchors[bucket.spawnContextId]
		return anchor ~= nil
			and anchor.part.Parent ~= nil
			and anchor.part:IsDescendantOf(anchor.root)
			and anchor.part.Anchored
			and anchor.part:HasTag("MonsterVaultSpawnAnchor")
			and anchor.part.CFrame == anchor.cframe
			and anchor.part.Size == anchor.size
			and anchor.part:GetAttribute("SpawnContextId") == bucket.spawnContextId
			and anchor.part:GetAttribute("RegionId") == bucket.regionId
			and anchor.part:GetAttribute("HabitatId") == bucket.habitatId
			and anchor.part:GetAttribute("SpeciesId") == anchor.speciesId
			and liveBinding(authoringIndex.regions[bucket.regionId])
			and liveBinding(authoringIndex.habitats[bucket.habitatId])
	end
	local function countEligiblePresence()
		table.clear(activeRegions)
		if options.profileCoordinator == nil or options.worldActions == nil then
			return
		end
		local players = options.players or game:GetService("Players")
		for _, player in players:GetPlayers() do
			local presence = if captureLifecycle then captureLifecycle.presence(player) else nil
			local session = options.profileCoordinator.get(player.UserId)
			local character = player.Character
			local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
			local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
			if
				session
				and session.state() == "Ready"
				and presence ~= nil
				and travelOwner ~= nil
				and travelOwner.ready(player, presence.generation)
				and root
				and humanoid
				and humanoid.Health > 0
			then
				local profile = session.snapshot()
				for id, region in authoringIndex.regions do
					local p = region.cframe:PointToObjectSpace(root.Position)
					if
						liveBinding(region)
						and math.abs(p.X) <= region.size.X / 2
						and math.abs(p.Y) <= region.size.Y / 2
						and math.abs(p.Z) <= region.size.Z / 2
						and options.worldActions.canAccess(profile, id)
					then
						activeRegions[id] = (activeRegions[id] or 0) + 1
					end
				end
			end
		end
	end
	local function placementValid(bucket: any): boolean
		if not liveSpawn(bucket) or creatures == nil or creatures.Parent == nil then
			return false
		end
		local position = authoringIndex.spawnAnchors[bucket.spawnContextId].position
		local ray = globals.RaycastParams.new()
		ray.FilterType = Enum.RaycastFilterType.Include
		ray.FilterDescendantsInstances = { authoringIndex.spawnAnchors[bucket.spawnContextId].root }
		for _, offset in
			{
				Vector3.zero,
				Vector3.new(1.8, 0, 1.8),
				Vector3.new(-1.8, 0, 1.8),
				Vector3.new(1.8, 0, -1.8),
				Vector3.new(-1.8, 0, -1.8),
			}
		do
			local hit = spatialWorkspace:Raycast(position + offset, Vector3.new(0, -8, 0), ray)
			if
				hit == nil
				or not hit.Instance.CanCollide
				or hit.Normal.Y < 0.5
				or position.Y - hit.Position.Y < 2
				or position.Y - hit.Position.Y > 4
			then
				return false
			end
		end
		local overlap = globals.OverlapParams.new()
		overlap.FilterType = Enum.RaycastFilterType.Include
		overlap.FilterDescendantsInstances = { creatures }
		overlap.MaxParts = 1
		return #spatialWorkspace:GetPartBoundsInBox(
			globals.CFrame.new(position),
			Vector3.new(4, 4, 4),
			overlap
		) == 0
	end
	local function eligible(player: any, bound: any): boolean
		if
			not running
			or bound == nil
			or not liveBinding(bound)
			or options.worldProgression == nil
			or options.profileCoordinator == nil
		then
			return false
		end
		local session = options.profileCoordinator.get(player.UserId)
		if session == nil or session.state() ~= "Ready" then
			return false
		end
		local presence = if captureLifecycle then captureLifecycle.presence(player) else nil
		if
			presence == nil
			or travelOwner == nil
			or not travelOwner.ready(player, presence.generation)
		then
			return false
		end
		local character = player.Character
		local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
		local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
		return root ~= nil
			and humanoid ~= nil
			and humanoid.Health > 0
			and (root.Position - bound.position).Magnitude <= bound.radius
			and options.worldActions ~= nil
			and options.worldActions.canAccess(session.snapshot(), bound.regionId)
	end
	local function useUtility(player: any, id: string, requestId: string): string
		local bound = if authoringIndex then authoringIndex.vaultAccessPoints[id] else nil
		if not eligible(player, bound) then
			return "REJECT_STATE_WORLD_UTILITY"
		end
		if vaultAccessHandler == nil then
			return "UNAVAILABLE_WORLD_VAULT"
		end
		return vaultAccessHandler(player, requestId)
	end
	local function secureDestination(player: any, pointId: string?): any
		if authoringIndex == nil then
			return nil
		end
		for id, bound in authoringIndex.securePoints do
			if (pointId == nil or pointId == id) and eligible(player, bound) then
				return bound.position
			end
		end
		return nil
	end

	local function regionAt(position: any): string?
		if
			position.X ~= position.X
			or position.Y ~= position.Y
			or position.Z ~= position.Z
			or math.abs(position.X) >= math.huge
			or math.abs(position.Y) >= math.huge
			or math.abs(position.Z) >= math.huge
		then
			return nil
		end
		for id, bound in authoringIndex.regions do
			local p = bound.cframe:PointToObjectSpace(position)
			if
				math.abs(p.X) <= bound.size.X / 2
				and math.abs(p.Y) <= bound.size.Y / 2
				and math.abs(p.Z) <= bound.size.Z / 2
			then
				return id
			end
		end
		return nil
	end
	local function hazardAt(position: any, clearance: any?, previous: any?): (string?, boolean)
		local found, available = nil, true
		for id, bound in authoringIndex.hazards do
			local marker, warning, label = bound.marker, bound.warning, bound.label
			available = available
				and liveBinding(bound)
				and marker.Parent == bound.part
				and warning.Parent == bound.part
				and warning.Enabled
				and label.Parent == warning
				and label.Text == registry.hazards[id].warningText
			for _, visual in bound.visuals do
				local part, style = visual.part, MaterialPalette[visual.materialGroup]
				available = available
					and part.Parent == visual.parent
					and part.Anchored
					and part.CFrame == visual.cframe
					and part.Size == visual.size
					and part.Transparency == 0
					and not part.CanCollide
					and not part.CanTouch
					and style ~= nil
					and part:GetAttribute("MaterialGroup") == visual.materialGroup
					and part.Material == style.material
					and part.Color == style.color
			end
			local p, m = bound.cframe:PointToObjectSpace(position), clearance or Vector3.zero
			local intersects = math.abs(p.X) <= bound.size.X / 2 + m.X
				and math.abs(p.Y) <= bound.size.Y / 2 + m.Y
				and math.abs(p.Z) <= bound.size.Z / 2 + m.Z
			if previous and not intersects then
				local a, half = bound.cframe:PointToObjectSpace(previous), bound.size / 2
				local enter, leave = 0, 1
				for _, axis in { "X", "Y", "Z" } do
					local delta = p[axis] - a[axis]
					if delta == 0 then
						if math.abs(a[axis]) > half[axis] then
							leave = -1
						end
					else
						local first, last =
							(-half[axis] - a[axis]) / delta, (half[axis] - a[axis]) / delta
						enter, leave =
							math.max(enter, math.min(first, last)),
							math.min(leave, math.max(first, last))
					end
				end
				intersects = enter <= leave
			end
			if intersects then
				found = id
			end
		end
		return found, available
	end
	local function nodeAt(context: any, includeUnavailable: boolean?): string?
		for id, bound in authoringIndex.travelNodes do
			if
				context.regionId == bound.regionId
				and (includeUnavailable or liveBinding(bound))
				and (context.root.Position - bound.position).Magnitude <= bound.radius
			then
				return id
			end
		end
		return nil
	end
	local function travelContext(player: any): any
		if
			not running
			or captureLifecycle == nil
			or options.profileCoordinator == nil
			or options.worldActions == nil
		then
			return nil
		end
		local session = options.profileCoordinator.get(player.UserId)
		local p = captureLifecycle.presence(player)
		if
			session == nil
			or session.state() ~= "Ready"
			or p == nil
			or type(p.generation) ~= "number"
		then
			return nil
		end
		local profile = session.snapshot()
		local regionId = regionAt(p.root.Position)
		local v = p.root.Position
		local finite = v.X == v.X
			and v.Y == v.Y
			and v.Z == v.Z
			and math.abs(v.X) < math.huge
			and math.abs(v.Y) < math.huge
			and math.abs(v.Z) < math.huge
		local ground: any = nil
		if finite then
			local ray = globals.RaycastParams.new()
			ray.FilterType, ray.FilterDescendantsInstances, ray.RespectCanCollide =
				Enum.RaycastFilterType.Include,
				{ authoringIndex.regions[registry.roles.HomeHub].root },
				true
			ground = spatialWorkspace:Raycast(v + Vector3.new(0, 3, 0), Vector3.new(0, -24, 0), ray)
		end
		p.session, p.profile, p.player, p.regionId = session, profile, player, regionId
		p.position = v
		p.finitePosition = finite
		local hazard, hazardsAvailable = hazardAt(v)
		p.hazardId = hazard
		-- Authored connectors remain walkable even outside a region volume.
		p.validPosition = ground ~= nil
			and hazardsAvailable
			and hazard == nil
			and ground.Normal.Y >= 0.5
			and (
				regionId == nil
				or (
					liveBinding(authoringIndex.regions[regionId])
					and options.worldActions.canAccess(profile, regionId)
				)
			)
		-- A missing/corrupt node is not an observed departure from its authored location.
		p.nodeId = nodeAt(p, true)
		return p
	end
	local function safeTarget(context: any, anchorId: string): any
		local d, bound =
			registry.recoveryAnchors[anchorId], authoringIndex.recoveryAnchors[anchorId]
		if
			d == nil
			or bound == nil
			or not liveBinding(bound)
			or not liveBinding(authoringIndex.regions[d.regionId])
			or not options.worldActions.canAccess(context.profile, d.regionId)
		then
			return nil
		end
		if d.outpostId and not liveBinding(authoringIndex.safeOutposts[d.outpostId]) then
			return nil
		end
		local ray = globals.RaycastParams.new()
		ray.FilterType, ray.FilterDescendantsInstances, ray.RespectCanCollide =
			Enum.RaycastFilterType.Include, { bound.root }, true
		local ground: any = nil
		for _, offset in
			{
				Vector3.zero,
				Vector3.new(1.8, 0, 1.8),
				Vector3.new(-1.8, 0, 1.8),
				Vector3.new(1.8, 0, -1.8),
				Vector3.new(-1.8, 0, -1.8),
			}
		do
			local hit = spatialWorkspace:Raycast(
				bound.position + offset + Vector3.new(0, 12, 0),
				Vector3.new(0, -24, 0),
				ray
			)
			if
				hit == nil
				or not hit.Instance.CanCollide
				or hit.Normal.Y < 0.5
				or hit.Position.Y > bound.position.Y + 0.01
				or bound.position.Y - hit.Position.Y > 4
			then
				return nil
			end
			if ground and math.abs(hit.Position.Y - ground) > 0.25 then
				return nil
			end
			ground = hit.Position.Y
		end
		local hip = context.humanoid.HipHeight
		if hip ~= hip or hip < 0 or hip > 16 or context.root.Size.Y > 16 then
			return nil
		end
		-- R6 standing height also includes its leg; R15 encodes it in HipHeight.
		if context.humanoid.RigType == Enum.HumanoidRigType.R6 then
			local leg = context.character:FindFirstChild("Left Leg")
			if leg == nil or not leg:IsA("BasePart") or leg.Size.Y > 16 then
				return nil
			end
			hip += leg.Size.Y
		end
		local position = Vector3.new(
			bound.position.X,
			ground + hip + context.root.Size.Y / 2 + 0.1,
			bound.position.Z
		)
		if regionAt(position) ~= d.regionId then
			return nil
		end
		local hazard, hazardsAvailable = hazardAt(position, Vector3.new(2, 0, 2))
		if hazard or not hazardsAvailable then
			return nil
		end
		local overlap = globals.OverlapParams.new()
		overlap.FilterType, overlap.FilterDescendantsInstances, overlap.MaxParts =
			Enum.RaycastFilterType.Include, { bound.root }, 1
		overlap.RespectCanCollide = true
		local height = math.max(4, hip + context.root.Size.Y + 2)
		for _, part in
			spatialWorkspace:GetPartBoundsInBox(
				globals.CFrame.new(Vector3.new(position.X, ground + height / 2 + 0.2, position.Z)),
				Vector3.new(4, height, 4),
				overlap
			)
		do
			if part.CanCollide then
				return nil
			end
		end
		local recoveryObservationNodeId: string? = nil
		for nodeId, node in registry.travelNodes do
			if node.recoveryAnchorId == anchorId and node.regionId ~= registry.roles.HomeHub then
				recoveryObservationNodeId = nodeId
			end
		end
		return {
			recoveryObservationNodeId = recoveryObservationNodeId,
			anchorId = anchorId,
			regionId = d.regionId,
			cframe = globals.CFrame.new(position) * bound.cframe.Rotation,
		}
	end
	local function observeNode(player: any, context: any): string
		local id = nodeAt(context)
		if id == nil or not context.validPosition or cycle.sample() == nil then
			return "REJECT_STATE_TRAVEL_DISCOVERY_CONTEXT"
		end
		local result = options.worldActions.discoverTravel(context.session, id, function(): boolean
			local live = travelContext(player)
			return live ~= nil
				and live.character == context.character
				and live.generation == context.generation
				and live.validPosition
				and nodeAt(live) == id
				and cycle.sample() ~= nil
		end)
		if result.status == "Committed" or result.status == "AlreadyCommitted" then
			return "OK_WORLD_TRAVEL_DISCOVERED"
		end
		return if result.status == "OutcomeUnknown"
			then "OUTCOME_UNKNOWN_WORLD_WRITE"
			else "PROTECTED_WORLD_UNAVAILABLE"
	end
	local function destination(context: any, nodeId: string): (any, string)
		local d, bound = registry.travelNodes[nodeId], authoringIndex.travelNodes[nodeId]
		if d == nil or bound == nil or not liveBinding(bound) then
			return nil, "DESTINATION"
		end
		if not context.validPosition or cycle.sample() == nil then
			return nil, "CONTEXT"
		end
		if not options.worldActions.canAccess(context.profile, d.regionId) then
			return nil, "ACCESS"
		end
		if not options.worldProgression.travelDiscovered(context.profile, nodeId) then
			return nil, "UNDISCOVERED"
		end
		if captureLifecycle.blocked(context.player) then
			return nil, "ACQUISITION"
		end
		local source = nodeAt(context)
		if
			source == nil or not options.worldProgression.travelDiscovered(context.profile, source)
		then
			return nil, "SOURCE"
		end
		local home = registry.roles.HomeHub
		if registry.travelNodes[source].regionId ~= home and d.regionId ~= home then
			return nil, "ROUTE"
		end
		if source == nodeId then
			return nil, "ROUTE"
		end
		local target = safeTarget(context, d.recoveryAnchorId)
		if target == nil then
			return nil, "ARRIVAL"
		end
		target.nodeId = nodeId
		return target, "OK"
	end
	local function stepTravel()
		if travelOwner then
			travelOwner.step((options.players or game:GetService("Players")):GetPlayers())
		end
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
		body.Color = MaterialPalette.FixtureCreature.color
		body.Material = MaterialPalette.FixtureCreature.material
		body:SetAttribute("MaterialGroup", "FixtureCreature")
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

	local function pulse(expectedGeneration: number, expectedTicket: number)
		if not running or expectedGeneration ~= generation or expectedTicket ~= pulseTicket then
			return
		end
		pulseTicket += 1
		publishCycle()
		if not running or expectedGeneration ~= generation then
			return
		end
		stepTravel()
		if not running or expectedGeneration ~= generation then
			return
		end
		countEligiblePresence()
		local ok, outcome = pcall(world.step, expectedGeneration)
		if not running or expectedGeneration ~= generation then
			return
		end
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
		local nextTicket = pulseTicket
		scheduler.delay(if options.fixture then 1 else registry.spawnPolicy.stepSeconds, function()
			pulse(expectedGeneration, nextTicket)
		end)
	end

	local function start()
		assert(not running and world == nil, "world service already started")
		validateAuthoring()
		-- The same central palette maps every part of this native authored asset.
		local targets = {}
		for _, bound in authoringIndex.hazards do
			local parts = bound.part:GetDescendants()
			table.insert(parts, bound.part)
			for _, part in parts do
				if part:IsA("BasePart") then
					local style = MaterialPalette[part:GetAttribute("MaterialGroup")]
					assert(style, "unmapped hazard material group")
					table.insert(targets, { part = part, style = style })
				end
			end
		end
		for _, target in targets do
			target.part.Material, target.part.Color = target.style.material, target.style.color
		end
		local plan: any = nil
		if options.fixture == nil then
			local positions = {}
			for id, anchor in authoringIndex.spawnAnchors do
				positions[id] =
					{ x = anchor.position.X, y = anchor.position.Y, z = anchor.position.Z }
			end
			plan = SpawnPlan.new(registry, positions, FixtureDefinition)
		end
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
			evaluateContext = function(bucket: any): any
				-- Only new reservations sample the current server clock. Never read client attributes.
				local context = registry.spawnContexts[bucket.spawnContextId]
				local snapshot = cycle.sample()
				return if context
						and WorldCycle.eligible(
							registry.habitats[bucket.habitatId],
							context,
							snapshot
						)
					then snapshot
					else nil
			end,
			fixture = fixture,
			buckets = if plan then plan.buckets else nil,
			maxBucketsPerStep = if plan then plan.policy.maxBucketsPerStep else nil,
			stepSeconds = if plan then plan.policy.stepSeconds else nil,
			isBucketActive = if plan
				then function(bucket: any): boolean
					return liveSpawn(bucket)
						and (
							bucket.replenishingFixture
							or (activeRegions[bucket.regionId] or 0) > 0
						)
				end
				else nil,
			canMaterialize = if plan then placementValid else nil,
			isProjectionAlive = function(model: any, projection: any): boolean
				local anchor = authoringIndex.spawnAnchors[projection.spawnContextId]
				return model ~= nil
					and model.Parent ~= nil
					and model:IsDescendantOf(creatures)
					and model.PrimaryPart ~= nil
					and model.PrimaryPart:IsDescendantOf(model)
					and (plan == nil or (anchor ~= nil and liveSpawn(anchor)))
			end,
			selectCandidate = if plan
				then function(bucket: any): any
					return SpawnPlan.select(bucket, {
						nextUnit = function()
							return random:NextNumber()
						end,
					})
				end
				else nil,
			onBucketError = function(_contextId: string)
				options.diagnostics.emit("error", "WORLD_BUCKET_PAUSED", { component = "world" })
			end,
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
		travelOwner = WorldTravelService.new({
			clock = clock,
			context = travelContext,
			hazardBetween = function(context: any, previous: any): string?
				return (hazardAt(context.position, nil, previous))
			end,
			destination = destination,
			observe = observeNode,
			interrupt = function(player: any, context: any, current: () -> boolean): boolean
				return current() and captureLifecycle.interrupt(player, context.generation)
			end,
			recovery = function(context: any, lastRegion: string?): any
				local preferred = if context.validPosition and lastRegion
					then context.regionId
					else lastRegion
				for _, role in { "Starter", "MidA", "MidB", "Advanced" } do
					local id = registry.roles[role]
					if id == preferred then
						local anchor =
							registry.safeOutposts[registry.regions[id].entryOutpostId].recoveryAnchorId
						local target = safeTarget(context, anchor)
						if target then
							return target
						end
					end
				end
				return safeTarget(context, "recovery-anchor/home-hub")
			end,
			relocate = function(
				player: any,
				context: any,
				target: any,
				recovery: boolean,
				current: () -> boolean
			): boolean
				if not current() then
					return false
				end
				local fresh = travelContext(player)
				if fresh == nil then
					return false
				end
				if not recovery then
					local valid = destination(fresh, target.nodeId)
					if valid == nil then
						return false
					end
				end
				local liveTarget = safeTarget(fresh, target.anchorId)
				if liveTarget == nil or liveTarget.cframe ~= target.cframe then
					return false
				end
				if recovery and not captureLifecycle.recover(player, context.generation) then
					return false
				end
				if player.Character ~= context.character or context.session.state() ~= "Ready" then
					return false
				end
				pcall(function()
					context.root:SetNetworkOwner(nil)
				end)
				context.character:PivotTo(
					liveTarget.cframe * context.root.CFrame:Inverse() * context.character:GetPivot()
				)
				context.root.AssemblyLinearVelocity, context.root.AssemblyAngularVelocity =
					Vector3.zero, Vector3.zero
				pcall(function()
					context.root:SetNetworkOwnershipAuto()
				end)
				return regionAt(context.root.Position) == target.regionId
					and (context.root.Position - target.cframe.Position).Magnitude < 0.1
			end,
		})
		if options.worldActions then
			for _, role in { "Starter", "MidA", "MidB", "Advanced", "HomeHub" } do
				local nodeId = if role == "HomeHub"
					then "travel-node/home-hub"
					elseif role == "Starter" then "travel-node/starter"
					elseif role == "MidA" then "travel-node/mid-a"
					elseif role == "MidB" then "travel-node/mid-b"
					else "travel-node/advanced"
				local bound = authoringIndex.travelNodes[nodeId]
				local destinations: { string } = if role == "HomeHub"
					then {
						"travel-node/starter",
						"travel-node/mid-a",
						"travel-node/mid-b",
						"travel-node/advanced",
					}
					else { "travel-node/home-hub" }
				for n, targetId in destinations do
					local prompt = Instance.new("ProximityPrompt")
					prompt.Name, prompt.ActionText = "MonsterVaultTravel", "Travel"
					prompt.ObjectText = if targetId == "travel-node/home-hub"
						then "Home Hub"
						else registry.regions[registry.travelNodes[targetId].regionId].role
					prompt.MaxActivationDistance, prompt.RequiresLineOfSight = bound.radius, false
					prompt.KeyboardKeyCode = ({
						Enum.KeyCode.E,
						Enum.KeyCode.F,
						Enum.KeyCode.R,
						Enum.KeyCode.T,
					})[n]
					prompt.GamepadKeyCode = ({
						Enum.KeyCode.ButtonX,
						Enum.KeyCode.ButtonY,
						Enum.KeyCode.ButtonL1,
						Enum.KeyCode.ButtonR1,
					})[n]
					prompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
					prompt.UIOffset = globals.Vector2.new(0, (n - 1) * 60)
					prompt.Parent = bound.part
					table.insert(prompts, prompt)
					table.insert(
						landmarkConnections,
						prompt.Triggered:Connect(function(player)
							local context = travelContext(player)
							if context then
								travelOwner.travel(player, targetId, context.generation)
							end
						end)
					)
				end
			end
			for landmarkId, bound in landmarkIndex do
				local prompt = Instance.new("ProximityPrompt")
				prompt.Name = "MonsterVaultSurvey"
				prompt.ActionText = "Survey"
				prompt.ObjectText = registry.landmarks[landmarkId].label or "Survey landmark"
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
		for id, bound in authoringIndex.vaultAccessPoints do
			local prompt = Instance.new("ProximityPrompt")
			prompt.Name, prompt.ActionText, prompt.ObjectText =
				"MonsterVaultVault", "View Vault", "Vault terminal"
			prompt.MaxActivationDistance = bound.radius
			prompt.RequiresLineOfSight = false
			prompt.Parent = bound.part
			table.insert(prompts, prompt)
			table.insert(
				landmarkConnections,
				prompt.Triggered:Connect(function(player)
					useUtility(player, id, options.httpService:GenerateGUID(false))
				end)
			)
		end
		pulse(generation, pulseTicket)
	end

	local function stop(): { string }
		running = false
		generation += 1
		if travelOwner then
			travelOwner.stop()
		end
		captureLifecycle = nil
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
		travel = function(player: any, nodeId: string, characterGeneration: number): string
			return if travelOwner
				then travelOwner.travel(player, nodeId, characterGeneration)
				else "UNAVAILABLE_WORLD"
		end,
		presenceReady = function(player: any, characterGeneration: number): boolean
			return travelOwner ~= nil and travelOwner.ready(player, characterGeneration)
		end,
		bindCaptureLifecycle = function(owner: any)
			captureLifecycle = owner
			if owner then
				stepTravel()
			end
		end,
		isTravelNode = function(id: string): boolean
			return registry.travelNodes[id] ~= nil
		end,
		discoverTravel = function(player: any, id: string): string
			local context = travelContext(player)
			return if context
					and nodeAt(context) == id
					and travelOwner.ready(player, context.generation)
				then observeNode(player, context)
				else "REJECT_STATE_TRAVEL_DISCOVERY_CONTEXT"
		end,
		cycleState = function(): any
			return if running then cycle.sample() else nil
		end,
		authoring = function(): any
			return authoringIndex
		end,
		secureDestination = secureDestination,
		useUtility = useUtility,
		bindVaultAccess = function(handler: any)
			vaultAccessHandler = handler
		end,
		isUtility = function(id: string): boolean
			return registry.vaultAccessPoints[id] ~= nil
		end,
	}
end

return WorldRuntimeService
