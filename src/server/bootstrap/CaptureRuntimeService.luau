--!strict

local CaptureService = require(script.Parent.Parent.domains.capture.CaptureService)
local CaptureFinalizationUseCase =
	require(script.Parent.Parent.application.CaptureFinalizationUseCase)
local RouteIds =
	require(game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts.RouteIds)
local CaptureProjectionV1 =
	require(game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts.CaptureProjectionV1)
local CaptureRuntimeService = {}

function CaptureRuntimeService.new(options: {
	worldRuntime: any,
	profileCoordinator: any,
	players: any,
	workspace: any,
	event: any,
	httpService: any,
	diagnostics: any,
	scheduler: any?,
	random: any?,
})
	local globals = getfenv() :: any
	local scheduler = options.scheduler or globals.task
	local random = options.random or globals.Random.new()
	local capture: any = nil
	local securePoint: any = nil
	local connections = {}
	local playerConnections: { [number]: { any } } = {}
	local generations: { [number]: number } = {}
	local correlations: { [number]: string } = {}
	local running = false
	local pulseGeneration = 0

	local function position(player: any): (any?, number?)
		local character = player.Character
		if character == nil then
			return nil, nil
		end
		local root = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if root == nil or humanoid == nil or humanoid.Health <= 0 then
			return nil, nil
		end
		local p = root.Position
		return { x = p.X, y = p.Y, z = p.Z }, generations[player.UserId] or 0
	end

	local function session(player: any): any
		local active = options.profileCoordinator.get(player.UserId)
		return if active ~= nil and active.state() == "Ready" then active else nil
	end

	local function emit(player: any, state: any, requestId: string?)
		if
			options.players:GetPlayerByUserId(player.UserId) ~= player
			or not CaptureProjectionV1.validState(state)
		then
			return
		end
		options.event:FireClient(player, {
			protocolVersion = 1,
			routeId = RouteIds.events.captureStateChanged,
			correlationId = requestId,
			payload = state,
		})
	end

	local function interact(player: any, creatureId: string, requestId: string): string
		if not running or capture == nil then
			return "UNAVAILABLE_CAPTURE"
		end
		local active = session(player)
		local p, generation = position(player)
		if active == nil or p == nil or generation == nil then
			return "REJECT_STATE_CAPTURE_CONTEXT"
		end
		local priorRevision = capture.snapshot(player.UserId).revision
		correlations[player.UserId] = requestId
		local result = capture.begin(player.UserId, creatureId, p, generation, active.snapshot())
		correlations[player.UserId] = nil
		if result.status == "Claimed" then
			if capture.snapshot(player.UserId).revision == priorRevision then
				emit(player, capture.snapshot(player.UserId), requestId)
			end
			return "OK_CAPTURE_CLAIMED"
		elseif result.status == "TransportActive" then
			if capture.snapshot(player.UserId).revision == priorRevision then
				emit(player, capture.snapshot(player.UserId), requestId)
			end
			return "OK_CAPTURE_RESUMED"
		end
		return "REJECT_STATE_CAPTURE_" .. string.upper(result.status)
	end

	local function submit(player: any, payload: any, requestId: string): string
		if not running or capture == nil then
			return "UNAVAILABLE_CAPTURE"
		end
		local active = session(player)
		local p, generation = position(player)
		if active == nil or p == nil or generation == nil then
			return "REJECT_STATE_CAPTURE_CONTEXT"
		end
		local priorRevision = capture.snapshot(player.UserId).revision
		correlations[player.UserId] = requestId
		local result = capture.submit(
			player.UserId,
			payload.captureSessionId,
			payload.actionId,
			payload.clientSequence,
			p,
			generation
		)
		correlations[player.UserId] = nil
		if result.status == "TransportActive" then
			if capture.snapshot(player.UserId).revision == priorRevision then
				emit(player, capture.snapshot(player.UserId), requestId)
			end
			return "OK_CAPTURE_PROVISIONAL"
		elseif result.status == "Failed" then
			if capture.snapshot(player.UserId).revision == priorRevision then
				emit(player, capture.snapshot(player.UserId), requestId)
			end
			return "OK_CAPTURE_FAILED"
		end
		return "REJECT_STATE_CAPTURE_" .. string.upper(result.status)
	end

	local function secure(player: any)
		if not running or capture == nil or securePoint == nil then
			return
		end
		local p, generation = position(player)
		local active = options.profileCoordinator.get(player.UserId)
		if p == nil or generation == nil or active == nil then
			return
		end
		local s = securePoint.Position
		capture.secure(player.UserId, p, { x = s.X, y = s.Y, z = s.Z }, generation, active)
	end

	local function reconcile(userId: number)
		if not running or capture == nil then
			return
		end
		local active = options.profileCoordinator.get(userId)
		if active == nil then
			return
		end
		capture.reconcile(userId, active)
	end

	local function resync(player: any, requestId: string): string
		if not running or capture == nil then
			return "UNAVAILABLE_CAPTURE"
		end
		local active = session(player)
		if active == nil then
			return "REJECT_STATE_CAPTURE_CONTEXT"
		end
		local p, generation = position(player)
		if p ~= nil and generation ~= nil then
			capture.resume(player.UserId, generation, active.snapshot())
		end
		-- Only the existing exact P2 reconciliation can turn Pending into Secured.
		-- A client hint or a locally expired countdown never establishes ownership.
		capture.reconcile(player.UserId, active)
		emit(player, capture.snapshot(player.UserId), requestId)
		return "OK_CAPTURE_RESYNC"
	end

	local function pulse(generation: number)
		if not running or generation ~= pulseGeneration then
			return
		end
		capture.tick()
		for _, userId in capture.pendingFinalizations() do
			scheduler.spawn(function()
				reconcile(userId)
			end)
		end
		for _, player in options.players:GetPlayers() do
			local active = session(player)
			local p, presenceGeneration = position(player)
			if active ~= nil and p ~= nil and presenceGeneration ~= nil then
				capture.resume(player.UserId, presenceGeneration, active.snapshot())
			elseif p == nil then
				capture.interrupt(player.UserId)
			end
		end
		scheduler.delay(1, function()
			pulse(generation)
		end)
	end

	local function start()
		assert(not running and capture == nil, "capture runtime already started")
		local authored = options.workspace:FindFirstChild("MonsterVaultWorld")
		securePoint = if authored then authored:FindFirstChild("FixtureSecurePoint") else nil
		assert(securePoint ~= nil and securePoint:IsA("BasePart"), "missing fixture secure point")
		assert(
			securePoint:GetAttribute("SecurePointId") == "secure-point/fixture-spawn",
			"secure point mismatch"
		)
		local world = options.worldRuntime.world()
		assert(world ~= nil, "world runtime unavailable")
		capture = CaptureService.new({
			world = world,
			clock = function()
				return options.workspace:GetServerTimeNow()
			end,
			unixSeconds = os.time,
			newId = function()
				return options.httpService:GenerateGUID(false)
			end,
			random = {
				nextUnit = function()
					return random:NextNumber()
				end,
			},
			canInitiate = CaptureFinalizationUseCase.canInitiate,
			finalize = CaptureFinalizationUseCase.finalize,
			isPlayerConnected = function(userId: number): boolean
				return playerConnections[userId] ~= nil
			end,
			onChanged = function(userId: number, state: any)
				local player = options.players:GetPlayerByUserId(userId)
				if player ~= nil then
					emit(player, state, correlations[userId])
				end
			end,
		})
		running = true
		pulseGeneration += 1
		local function untrack(userId: number)
			local tracked = playerConnections[userId]
			if tracked ~= nil then
				for _, connection in tracked do
					connection:Disconnect()
				end
			end
			playerConnections[userId] = nil
		end
		local function track(player: any)
			untrack(player.UserId)
			generations[player.UserId] = 1
			local tracked = {}
			playerConnections[player.UserId] = tracked
			local deathConnection: any = nil
			local function characterReady(character: any)
				capture.interrupt(player.UserId)
				generations[player.UserId] = (generations[player.UserId] or 0) + 1
				if deathConnection ~= nil then
					deathConnection:Disconnect()
				end
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid ~= nil then
					deathConnection = humanoid.Died:Connect(function()
						capture.interrupt(player.UserId)
					end)
				end
			end
			table.insert(tracked, player.CharacterAdded:Connect(characterReady))
			table.insert(tracked, {
				Disconnect = function()
					if deathConnection ~= nil then
						deathConnection:Disconnect()
					end
				end,
			})
			if player.Character ~= nil then
				characterReady(player.Character)
			end
		end
		for _, player in options.players:GetPlayers() do
			track(player)
		end
		table.insert(
			connections,
			options.players.PlayerAdded:Connect(function(player)
				track(player)
			end)
		)
		table.insert(
			connections,
			options.players.PlayerRemoving:Connect(function(player)
				untrack(player.UserId)
				generations[player.UserId] = nil
				capture.disconnect(player.UserId)
				capture.playerLeft(player.UserId)
			end)
		)
		table.insert(
			connections,
			securePoint.Touched:Connect(function(part)
				local character = part:FindFirstAncestorOfClass("Model")
				local player = if character
					then options.players:GetPlayerFromCharacter(character)
					else nil
				if player ~= nil then
					scheduler.spawn(function()
						secure(player)
					end)
				end
			end)
		)
		pulse(pulseGeneration)
	end

	local function stop(): { string }
		if not running then
			return {}
		end
		running = false
		pulseGeneration += 1
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
		for _, tracked in playerConnections do
			for _, connection in tracked do
				connection:Disconnect()
			end
		end
		table.clear(playerConnections)
		local failures = {}
		if capture ~= nil then
			for _, userId in capture.pendingFinalizations() do
				local active = options.profileCoordinator.get(userId)
				local result = capture.reconcile(userId, active)
				if result.status ~= "Secured" then
					table.insert(failures, tostring(userId) .. ": " .. result.status)
				end
			end
			for _, custody in capture.activeCustodies() do
				local player = options.players:GetPlayerByUserId(custody.userId)
				local active = options.profileCoordinator.get(custody.userId)
				local p: any = nil
				local generation: number? = nil
				if player ~= nil then
					p, generation = position(player)
				end
				if player ~= nil and p ~= nil and generation == custody.generation then
					local result = capture.finalizeForShutdown(custody.userId, active)
					if result.status ~= "Secured" then
						table.insert(failures, tostring(custody.userId) .. ": " .. result.status)
					end
				end
			end
		end
		return failures
	end

	return {
		id = "capture",
		dependencies = { "world", "profiles" },
		start = start,
		stop = stop,
		interact = interact,
		submit = submit,
		secure = secure,
		reconcile = reconcile,
		resync = resync,
		state = function(id: string): string?
			return if capture then capture.state(id) else nil
		end,
	}
end

return CaptureRuntimeService
