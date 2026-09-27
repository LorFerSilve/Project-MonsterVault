--!strict

local fsModuleName = "@lune/fs"
local luauModuleName = "@lune/luau"
local fs = require(fsModuleName) :: any
local luau = require(luauModuleName) :: any

local function signal(): any
	local listeners = {}
	return {
		Connect = function(_self: any, callback: (...any) -> ())
			local connection: any = { Connected = true }
			connection.Disconnect = function(self: any)
				self.Connected = false
			end
			table.insert(listeners, { connection = connection, callback = callback })
			return connection
		end,
		Fire = function(_self: any, ...: any)
			for _, listener in table.clone(listeners) do
				if listener.connection.Connected then
					listener.callback(...)
				end
			end
		end,
	}
end

local function character(): any
	local humanoid = { Health = 100, Died = signal() }
	local root = { Position = { X = 1, Y = 3, Z = 10 } }
	return {
		humanoid = humanoid,
		root = root,
		FindFirstChild = function(_self: any, name: string)
			return if name == "HumanoidRootPart" then root else nil
		end,
		FindFirstChildOfClass = function(_self: any, name: string)
			return if name == "Humanoid" then humanoid else nil
		end,
	}
end

local function harness(): any
	local calls: { any } = {}
	local pending: { number } = {}
	local custodies: { any } = {}
	local profiles: { [number]: any } = {}
	local playersById: { [number]: any } = {}
	local delayed: { any } = {}
	local spawned: { any } = {}
	local events: { any } = {}
	local capture: any = {}
	local function record(method: string, ...: any)
		local entry = { method = method, arguments = table.pack(...) }
		table.insert(calls, entry)
		return entry
	end
	for _, method in { "interrupt", "disconnect", "resume", "tick" } do
		capture[method] = function(...: any)
			record(method, ...)
			return { status = "TransportActive" }
		end
	end
	for _, method in { "secure", "finalizeForShutdown", "reconcile" } do
		capture[method] = function(...: any)
			record(method, ...)
			return { status = "Secured", profileRevision = 2 }
		end
	end
	capture.begin = function(...: any)
		record("begin", ...)
		return { status = "Claimed", captureSessionId = "server-capture-id" }
	end
	capture.submit = function(...: any)
		record("submit", ...)
		return { status = "TransportActive", custodyId = "custody-id" }
	end
	capture.activeCustodies = function()
		return custodies
	end
	capture.pendingFinalizations = function()
		return pending
	end
	capture.state = function()
		return "TransportActive"
	end
	local scheduler = {
		spawn = function(callback: () -> ())
			local item = { callback = callback, cancelled = false }
			table.insert(spawned, item)
			return item
		end,
		delay = function(seconds: number, callback: () -> ())
			assert(seconds == 1, "capture pulse is bounded to one second")
			local item = { callback = callback, cancelled = false }
			table.insert(delayed, item)
			return item
		end,
		cancel = function(item: any)
			item.cancelled = true
		end,
	}
	local players: any = {
		PlayerAdded = signal(),
		PlayerRemoving = signal(),
		GetPlayers = function()
			local result = {}
			for _, player in playersById do
				table.insert(result, player)
			end
			return result
		end,
		GetPlayerByUserId = function(_self: any, userId: number)
			return playersById[userId]
		end,
		GetPlayerFromCharacter = function(_self: any, model: any)
			for _, player in playersById do
				if player.Character == model then
					return player
				end
			end
			return nil
		end,
	}
	local securePoint: any = {
		Position = { X = 0, Y = 1, Z = 10 },
		Touched = signal(),
		IsA = function(_self: any, className: string)
			return className == "BasePart"
		end,
		GetAttribute = function(_self: any, name: string)
			return if name == "SecurePointId" then "secure-point/fixture-spawn" else nil
		end,
	}
	local captureToken, finalizationToken, routesToken = {}, {}, {}
	local moduleMap: { [any]: any } = {
		[captureToken] = {
			new = function(_options: any)
				return capture
			end,
		},
		[finalizationToken] = {
			canInitiate = function()
				return true
			end,
			finalize = function()
				return { status = "Secured", profileRevision = 2 }
			end,
		},
		[routesToken] = { events = { captureStateChanged = "capture-state" } },
	}
	-- Execute the shipped Roblox module unchanged. Only its engine imports are
	-- replaced; lifecycle, admission, drain and queued callbacks are real code.
	local runtimeModule =
		luau.load(fs.readFile("src/server/bootstrap/CaptureRuntimeService.luau"), {
			debugName = "CaptureRuntimeService runtime test",
			environment = {
				script = {
					Parent = {
						Parent = {
							domains = { capture = { CaptureService = captureToken } },
							application = { CaptureFinalizationUseCase = finalizationToken },
						},
					},
				},
				game = {
					GetService = function(_self: any, name: string)
						assert(name == "ReplicatedStorage", "unexpected engine service")
						return {
							MonsterVault = { Shared = { contracts = { RouteIds = routesToken } } },
						}
					end,
				},
				require = function(token: any)
					assert(moduleMap[token] ~= nil, "unexpected runtime dependency")
					return moduleMap[token]
				end,
			},
			injectGlobals = true,
		})()
	local runtime = runtimeModule.new({
		worldRuntime = {
			world = function()
				return {}
			end,
		},
		profileCoordinator = {
			get = function(userId: number)
				return profiles[userId]
			end,
		},
		players = players,
		workspace = {
			FindFirstChild = function(_self: any, name: string)
				assert(name == "MonsterVaultWorld", "authored world is selected")
				return {
					FindFirstChild = function(_authored: any, childName: string)
						return if childName == "FixtureSecurePoint" then securePoint else nil
					end,
				}
			end,
		},
		event = {
			FireClient = function(_self: any, player: any, envelope: any)
				table.insert(events, { player = player, envelope = envelope })
			end,
		},
		httpService = {
			GenerateGUID = function()
				return "runtime-server-id"
			end,
		},
		diagnostics = { emit = function() end },
		scheduler = scheduler,
		random = {
			NextNumber = function()
				return 0.1
			end,
		},
	})
	local function addPlayer(userId: number): any
		local model = character()
		local player = {
			UserId = userId,
			Character = model,
			CharacterAdded = signal(),
			CharacterRemoving = signal(),
		}
		playersById[userId] = player
		profiles[userId] = {
			state = function()
				return "Ready"
			end,
			snapshot = function()
				return { userId = userId }
			end,
		}
		return player
	end
	return {
		runtime = runtime,
		capture = capture,
		players = players,
		playersById = playersById,
		profiles = profiles,
		securePoint = securePoint,
		pending = pending,
		custodies = custodies,
		calls = calls,
		delayed = delayed,
		spawned = spawned,
		events = events,
		addPlayer = addPlayer,
		callsFor = function(method: string): { any }
			local result = {}
			for _, call in calls do
				if call.method == method then
					table.insert(result, call.arguments)
				end
			end
			return result
		end,
		runSpawned = function()
			local queued = table.clone(spawned)
			table.clear(spawned)
			for _, item in queued do
				if not item.cancelled then
					item.callback()
				end
			end
		end,
		runNextPulse = function()
			local item = table.remove(delayed, 1)
			assert(item ~= nil, "next capture pulse is queued")
			if not item.cancelled then
				item.callback()
			end
		end,
	}
end

local function shutdownRequiresLiveMatchingCharacter()
	local h = harness()
	local live = h.addPlayer(42)
	local dead = h.addPlayer(43)
	dead.Character.humanoid.Health = 0
	local noCharacter = h.addPlayer(44)
	noCharacter.Character = nil
	h.addPlayer(45)
	h.addPlayer(46)
	h.runtime.start()
	assert(
		h.runtime.interact(live, "creature-a", "request-a") == "OK_CAPTURE_CLAIMED",
		"live context admitted"
	)
	local generation = h.callsFor("begin")[1][4]
	for _, custody in
		{
			{ userId = 42, generation = generation },
			{ userId = 43, generation = generation },
			{ userId = 44, generation = generation },
			{ userId = 45, generation = generation + 1 },
			{ userId = 46, generation = generation },
		}
	do
		table.insert(h.custodies, custody)
	end
	h.players.PlayerRemoving:Fire(h.playersById[46])
	h.playersById[46] = nil
	local failures = h.runtime.stop()
	assert(#failures == 0, "eligible custody finalized without drain failure")
	local finalizations = h.callsFor("finalizeForShutdown")
	assert(
		#finalizations == 1 and finalizations[1][1] == 42,
		"only the live matching custody drains"
	)
	assert(finalizations[1][2] == h.profiles[42], "the ready owner session is used")
end

local function pendingPulseReconcilesWithoutSpatialProof()
	local h = harness()
	local player = h.addPlayer(42)
	player.Character = nil
	h.profiles[42].state = function()
		return "PersistenceAtRisk"
	end
	table.insert(h.pending, 42)
	h.runtime.start()
	h.playersById[42] = nil
	h.runSpawned()
	local reconciliations = h.callsFor("reconcile")
	assert(#reconciliations == 1, "pending operation reconciles after player disconnect")
	assert(
		reconciliations[1][1] == 42 and reconciliations[1][2] == h.profiles[42],
		"reconciliation uses the original profile even while persistence is at risk"
	)
	assert(#h.callsFor("secure") == 0, "pending retries do not readmit spatial ownership")
	h.runtime.stop()
end

local function shutdownReconcilesPendingWithoutPlayer()
	local h = harness()
	h.addPlayer(42)
	table.insert(h.pending, 42)
	h.runtime.start()
	h.playersById[42] = nil
	table.clear(h.calls)
	local failures = h.runtime.stop()
	assert(#failures == 0, "pending operation reconciled on shutdown")
	local reconciliations = h.callsFor("reconcile")
	assert(#reconciliations == 1 and reconciliations[1][1] == 42, "pending owner reconciled once")
	assert(reconciliations[1][2] == h.profiles[42], "shutdown keeps the original pending session")
	assert(#h.callsFor("finalizeForShutdown") == 0, "reconciliation does not invent active custody")
end

local function playerLifecycleInterruptsAndResumes()
	local h = harness()
	local player = h.addPlayer(42)
	h.runtime.start()
	assert(
		h.runtime.interact(player, "creature-a", "request-a") == "OK_CAPTURE_CLAIMED",
		"initial context"
	)
	local originalGeneration = h.callsFor("begin")[1][4]
	table.clear(h.calls)
	player.Character.humanoid.Health = 0
	player.Character.humanoid.Died:Fire()
	assert(#h.callsFor("interrupt") == 1, "death interrupts custody immediately")
	local oldCharacter = player.Character
	player.CharacterRemoving:Fire(oldCharacter)
	player.Character = nil
	h.runNextPulse()
	assert(#h.callsFor("interrupt") >= 2, "missing live character invalidates custody on pulse")
	local replacement = character()
	player.Character = replacement
	player.CharacterAdded:Fire(replacement)
	h.runNextPulse()
	local resume = h.callsFor("resume")
	assert(
		#resume >= 1 and resume[#resume][1] == 42 and resume[#resume][2] > originalGeneration,
		"replacement character receives a new presence generation"
	)
	assert(resume[#resume][3].userId == 42, "resuming uses the ready profile snapshot")
	local beforeOldDeath = #h.callsFor("interrupt")
	oldCharacter.humanoid.Died:Fire()
	assert(#h.callsFor("interrupt") == beforeOldDeath, "old humanoid listener is removed")
	h.players.PlayerRemoving:Fire(player)
	assert(#h.callsFor("disconnect") == 1, "disconnect enters domain grace lifecycle")
	local interruptsAfterDisconnect = #h.callsFor("interrupt")
	replacement.humanoid.Died:Fire()
	assert(
		#h.callsFor("interrupt") == interruptsAfterDisconnect,
		"disconnected death listener removed"
	)
	h.runtime.stop()
end

local function queuedPulseAndTouchCallbacksCannotRunAfterStop()
	local h = harness()
	local player = h.addPlayer(42)
	table.insert(h.pending, 42)
	h.runtime.start()
	h.securePoint.Touched:Fire({
		FindFirstAncestorOfClass = function(_self: any, className: string)
			return if className == "Model" then player.Character else nil
		end,
	})
	assert(#h.delayed == 1 and #h.spawned >= 1, "callbacks queued before shutdown")
	h.runtime.stop()
	local restarted = pcall(h.runtime.start)
	assert(not restarted, "capture runtime has a one-shot lifecycle")
	local callsAfterStop = #h.calls
	local delayedAfterStop = #h.delayed
	h.runSpawned()
	for _, item in table.clone(h.delayed :: { any }) do
		if not item.cancelled then
			item.callback()
		end
	end
	player.Character.humanoid.Died:Fire()
	player.CharacterAdded:Fire(character())
	h.players.PlayerRemoving:Fire(player)
	h.players.PlayerAdded:Fire(h.addPlayer(43))
	h.securePoint.Touched:Fire({
		FindFirstAncestorOfClass = function()
			return player.Character
		end,
	})
	assert(#h.spawned == 0, "stop disconnects world and player event subscriptions")
	assert(#h.runtime.stop() == 0, "repeated stop is idempotent")
	assert(#h.calls == callsAfterStop, "stale queued callbacks cannot mutate stopped capture")
	assert(#h.delayed == delayedAfterStop, "stopped pulse cannot schedule another pulse")
end

return {
	shutdownRequiresLiveMatchingCharacter = shutdownRequiresLiveMatchingCharacter,
	pendingPulseReconcilesWithoutSpatialProof = pendingPulseReconcilesWithoutSpatialProof,
	shutdownReconcilesPendingWithoutPlayer = shutdownReconcilesPendingWithoutPlayer,
	playerLifecycleInterruptsAndResumes = playerLifecycleInterruptsAndResumes,
	queuedPulseAndTouchCallbacksCannotRunAfterStop = queuedPulseAndTouchCallbacksCannotRunAfterStop,
}
