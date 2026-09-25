--!strict

local SessionCoordinator = require(script.Parent.Parent.application.SessionCoordinator)
local ProfileSession = require(script.Parent.Parent.infrastructure.persistence.ProfileSession)
local ProfileSchemaV1 = require(script.Parent.Parent.infrastructure.persistence.ProfileSchemaV1)
local SingleWriterQueue = require(script.Parent.Parent.infrastructure.persistence.SingleWriterQueue)
local RetryPolicy = require(script.Parent.Parent.infrastructure.persistence.RetryPolicy)
local RobloxProfileRepository = require(script.Parent.Parent.adapters.RobloxProfileRepository)

local ProfileRuntimeService = {}

function ProfileRuntimeService.new(options: {
	environment: string,
	declaredUniverseId: number,
	dataStoreService: any,
	players: any,
	runService: any,
	httpService: any,
	gameUniverseId: number,
	gameJobId: string,
	diagnostics: any,
})
	assert(
		type(options.declaredUniverseId) == "number" and options.declaredUniverseId > 0,
		"profile universe binding required"
	)
	assert(
		options.gameUniverseId == options.declaredUniverseId,
		"profile universe binding mismatch"
	)
	local repository = RobloxProfileRepository.new(
		options.dataStoreService,
		options.runService:IsStudio(),
		options.environment
	)
	local runtime = getfenv() :: any
	local scheduler = runtime.task
	local random = runtime.Random.new()
	local jobId = if options.gameJobId ~= ""
		then options.gameJobId
		else options.httpService:GenerateGUID(false)
	local coordinator = SessionCoordinator.new({
		createSession = function(userId: number)
			local queue = SingleWriterQueue.new(os.clock, scheduler.wait, 25)
			local retry = RetryPolicy.new(os.clock, scheduler.wait, function()
				return random:NextNumber()
			end, 3)
			return ProfileSession.new({
				userId = userId,
				lockId = options.httpService:GenerateGUID(false),
				jobId = jobId,
				repository = repository,
				schema = ProfileSchemaV1,
				queue = queue,
				retry = retry,
				unixSeconds = os.time,
				monotonicSeconds = os.clock,
			})
		end,
		unixSeconds = os.time,
		monotonicSeconds = os.clock,
		spawn = scheduler.spawn,
		waitSeconds = scheduler.wait,
	})
	local connections = {}
	local departed: { [any]: boolean } = setmetatable({}, { __mode = "k" }) :: any
	local scheduled: { [any]: boolean } = setmetatable({}, { __mode = "k" }) :: any

	local function logOutcome(code: string, result: any)
		if result.status ~= "Ready" and result.status ~= "Closed" then
			options.diagnostics.emit(
				"warn",
				code,
				{ component = "profiles", detailCode = result.status }
			)
		end
	end

	local function scheduleOpen(player: any)
		if scheduled[player] then
			return
		end
		scheduled[player] = true
		scheduler.spawn(function()
			if not departed[player] then
				logOutcome("PROFILE_ACQUIRE_RESULT", coordinator.open(player.UserId))
			end
		end)
	end

	local function start()
		table.insert(
			connections,
			options.players.PlayerAdded:Connect(function(player)
				scheduleOpen(player)
			end)
		)
		table.insert(
			connections,
			options.players.PlayerRemoving:Connect(function(player)
				departed[player] = true
				scheduler.spawn(function()
					logOutcome(
						"PROFILE_RELEASE_RESULT",
						coordinator.close(player.UserId, os.clock() + 25)
					)
				end)
			end)
		)
		for _, player in options.players:GetPlayers() do
			scheduleOpen(player)
		end
		coordinator.startLoop()
	end

	local function stop(): { string }
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
		return coordinator.shutdown(os.clock() + 25)
	end

	return {
		id = "profiles",
		dependencies = {},
		start = start,
		stop = stop,
		coordinator = coordinator,
	}
end

return ProfileRuntimeService
