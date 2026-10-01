--!strict

-- Load as a temporary server ModuleScript through the Studio MCP in Play.
-- Real DEV UpdateAsync runs in this probe's scope, separate from player progress.
-- This verifies VS1-20; it is not gamepad, load, STG, or full-gateway evidence.
return function(): any
	local started = os.clock()
	local globals = getfenv() :: any
	local Instance = globals.Instance
	local Random = globals.Random
	local CFrame = globals.CFrame
	local scheduler = globals.task
	assert(game:GetService("RunService"):IsStudio(), "Studio probe only")
	assert(game:GetService("RunService"):IsServer(), "server probe only")
	local server: any = game:GetService("ServerScriptService").MonsterVaultServer
	local shared: any = game:GetService("ReplicatedStorage").MonsterVault.Shared
	local binding = require(server.bootstrap.ProfileBinding)
	assert(
		binding.environment == "DEV" and binding.declaredUniverseId == game.GameId,
		"DEV universe binding required"
	)
	local HttpService = game:GetService("HttpService")
	local Players = game:GetService("Players")
	local player = assert(Players:GetPlayers()[1], "one joined player required")
	local character = assert(player.Character, "live character required")
	local oldPivot = character:GetPivot()
	local scope = "IMP8Diagnostics20261001"
	local seedId = "fixture:imp8-diagnostics-v1"
	local result: any = {
		testId = "T15.imp8.Studio.captureDiagnostics",
		seedId = seedId,
		environment = "DEV",
		scope = scope,
		records = {},
		failures = {},
		requirements = { "TA-7", "TA-12", "TA-15", "VS1-20" },
		criticality = "C1",
		studioVersion = globals.version(),
		placeId = game.PlaceId,
		universeId = game.GameId,
		invocation = "Studio MCP Server Play; isolated runtime; owner event sink",
	}
	local diagnostics = require(shared.util.StructuredDiagnostics).new(function(record: any)
		table.insert(result.records, record)
		print(HttpService:JSONEncode(record))
	end, os.time, "server")
	local function check(condition: boolean, message: string)
		if not condition then
			table.insert(result.failures, message)
		end
	end
	local dataStoreService = game:GetService("DataStoreService")
	local repository = require(server.adapters.RobloxProfileRepository).new({
		GetDataStore = function(_self: any, name: string)
			assert(name == "MV_DEV_PlayerProfile_v1", "DEV namespace required")
			return dataStoreService:GetDataStore(name, scope)
		end,
	}, true, "DEV")
	local function newSession(): any
		return require(server.infrastructure.persistence.ProfileSession).new({
			userId = player.UserId,
			lockId = HttpService:GenerateGUID(false),
			jobId = "imp8-diagnostics-" .. HttpService:GenerateGUID(false),
			repository = repository,
			schema = require(server.infrastructure.persistence.ProfileSchemaV1),
			queue = require(server.infrastructure.persistence.SingleWriterQueue).new(
				os.clock,
				scheduler.wait,
				25
			),
			retry = require(server.infrastructure.persistence.RetryPolicy).new(
				os.clock,
				scheduler.wait,
				function()
					return 0.5
				end,
				3
			),
			unixSeconds = os.time,
			monotonicSeconds = os.clock,
		})
	end
	local active = newSession()
	local probeRoot: any = nil
	local world: any = nil
	local capture: any = nil
	local ok, failure = pcall(function()
		assert(active.acquire().status == "Ready", "isolated DEV profile must acquire")
		local before = active.snapshot()
		result.beforeRevision = before.profileRevision
		assert(
			require(server.application.CaptureFinalizationUseCase).canInitiate(before),
			"probe profile is full"
		)
		local storage = game:GetService("ServerStorage")
		assert(storage:FindFirstChild("IMP8DiagnosticsWorld") == nil, "probe already running")
		local root = Instance.new("Folder")
		root.Name = "IMP8DiagnosticsWorld"
		root.Parent = storage
		probeRoot = root
		workspace.MonsterVaultWorld:Clone().Parent = root
		world = require(server.bootstrap.WorldRuntimeService).new({
			workspace = root,
			collectionService = game:GetService("CollectionService"),
			httpService = HttpService,
			diagnostics = diagnostics,
			random = Random.new(8),
		})
		world.start()
		local envelopes: { any } = {}
		capture = require(server.bootstrap.CaptureRuntimeService).new({
			worldRuntime = world,
			profileCoordinator = {
				get = function(userId: number)
					return if userId == player.UserId then active else nil
				end,
			},
			players = Players,
			workspace = {
				FindFirstChild = function(_self: any, name: string)
					return root:FindFirstChild(name)
				end,
				GetServerTimeNow = function()
					return workspace:GetServerTimeNow()
				end,
			},
			event = {
				FireClient = function(_self: any, owner: any, envelope: any)
					assert(owner == player, "private owner projection")
					table.insert(envelopes, envelope)
				end,
			},
			httpService = HttpService,
			diagnostics = diagnostics,
			random = {
				NextNumber = function()
					return 0.1
				end,
			},
		})
		capture.start()
		diagnostics.emit("info", "VS1_PROBE", { component = "capture", seedId = seedId })
		local model = root.MonsterVaultRuntime.Creatures:FindFirstChildOfClass("Model")
		assert(model, "isolated fixture must materialize")
		local creatureId = model:GetAttribute("CreatureInstanceId")
		result.creatureInstanceId = creatureId
		character:PivotTo(CFrame.new(0, 3, -6))
		local claimRequest = "imp8-claim-" .. HttpService:GenerateGUID(false)
		assert(
			capture.interact(player, creatureId, claimRequest) == "OK_CAPTURE_CLAIMED",
			"valid scoped claim must succeed"
		)
		local claim = envelopes[#envelopes].payload
		local submitRequest = "imp8-submit-" .. HttpService:GenerateGUID(false)
		local payload =
			{ captureSessionId = claim.captureSessionId, actionId = "capture", clientSequence = 1 }
		assert(
			capture.submit(player, payload, submitRequest) == "OK_CAPTURE_PROVISIONAL",
			"seeded scoped capture must succeed"
		)
		check(
			envelopes[#envelopes].payload.profileRevision == nil,
			"provisional capture claimed ownership"
		)
		assert(
			capture.submit(player, payload, "imp8-duplicate") == "OK_CAPTURE_PROVISIONAL",
			"duplicate submit must be idempotent"
		)
		character:PivotTo(CFrame.new(0, 4, 10))
		capture.secure(player)
		check(capture.state(creatureId) == "Secured", "capture did not become durably secured")
		local byStatus: { [string]: any } = {}
		for _, record in result.records do
			if record.code == "CAPTURE_STATE" then
				byStatus[record.fields.detailCode] = record.fields
				for key in record.fields do
					check(
						key == "component"
							or key == "detailCode"
							or key == "requestId"
							or key == "operationId",
						"unexpected capture diagnostic field"
					)
				end
			end
		end
		check(byStatus.Claimed.requestId == claimRequest, "claim request correlation missing")
		local operationId = byStatus.TransportActive.operationId
		result.operationId = operationId
		result.requestId = submitRequest
		for _, status in { "TransportActive", "FinalizationPending", "Secured" } do
			check(
				byStatus[status].requestId == submitRequest,
				status .. " lost the original submit request"
			)
			check(
				byStatus[status].operationId == operationId,
				status .. " changed the server operation"
			)
		end
		check(
			envelopes[#envelopes].correlationId == nil,
			"diagnostic request leaked into delayed wire correlation"
		)
		local after = active.snapshot()
		check(
			after.profileRevision == before.profileRevision + 1,
			"duplicate submit applied more than once"
		)
		check(
			after.collection.creaturesById[creatureId].operationId == operationId,
			"durable operation mismatch"
		)
		result.afterRevision = after.profileRevision
		assert(active.release(os.clock() + 25).status == "Closed", "probe profile must release")
		active = newSession()
		assert(active.acquire().status == "Ready", "isolated DEV rejoin must acquire")
		local snapshot = require(server.application.SecuredCollectionProjection).fromProfile(
			active.snapshot(),
			player.UserId
		)
		local count = 0
		for _, id in snapshot.creatureInstanceIds do
			if id == creatureId then
				count += 1
			end
		end
		check(count == 1, "rejoin must project the captured creature once")
		result.rejoinRevision = snapshot.profileRevision
		result.rejoinOccurrences = count
	end)
	if not ok then
		table.insert(result.failures, tostring(failure))
	end
	local stopped, stopFailure = pcall(function()
		if capture then
			check(#capture.stop() == 0, "capture stop failed")
		end
		if world then
			world.stop()
		end
	end)
	if not stopped then
		table.insert(result.failures, tostring(stopFailure))
	end
	if probeRoot then
		probeRoot:Destroy()
	end
	check(
		active.release(os.clock() + 25).status == "Closed",
		"cleanup must release the probe lease"
	)
	if character.Parent then
		character:PivotTo(oldPivot)
	end
	result.result = if #result.failures == 0 then "PASS" else "FAIL"
	result.durationMs = (os.clock() - started) * 1000
	return result
end
