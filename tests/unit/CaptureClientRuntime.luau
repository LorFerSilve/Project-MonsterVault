--!strict

local fsModuleName = "@lune/fs"
local luauModuleName = "@lune/luau"
local fs = require(fsModuleName) :: any
local luau = require(luauModuleName) :: any
local Controller = require("../../src/client/controllers/CaptureController")
local Projection = require("../../src/shared/contracts/CaptureProjectionV1")
local Routes = require("../../src/shared/contracts/RouteIds")

local function check(value: any, message: string?)
	assert(value, message or "capture client runtime invariant")
end

local function vector(x: number): any
	return setmetatable({ x = x }, {
		__sub = function(left: any, right: any)
			return { Magnitude = math.abs(left.x - right.x) }
		end,
	})
end

local function state(status: string, revision: number): any
	if status == "Idle" then
		return { status = status, revision = revision }
	end
	local value: any = {
		status = status,
		revision = revision,
		captureSessionId = "server-claim",
		creatureInstanceId = "creature-a",
	}
	if status == "Claimed" then
		value.claimExpiresAt = 120
	end
	if status == "TransportActive" or status == "FinalizationPending" or status == "Secured" then
		value.custodyId = "server-custody"
	end
	if status == "Secured" then
		value.profileRevision = 9
	end
	return value
end

local function harness(): any
	local now = 0
	local requests: { any } = {}
	local subscriber: ((any) -> ())? = nil
	local pollThread: thread? = nil
	local view: any = nil
	local inputOptions: any = nil
	local stoppedView, stoppedInput = false, false
	local renderAfterStop = 0
	local mode = "Blocked"
	local root = { Position = vector(0) }
	local model: any = { Parent = {} }
	model.GetPivot = function()
		return { Position = vector(5) }
	end
	local entry =
		{ creatureInstanceId = "creature-a", availability = "IdleAvailable", model = model }
	local entries: { any } = { entry }
	local gateway = {
		send = function(routeId, payload)
			local requestId = "request-" .. (#requests + 1)
			table.insert(requests, { routeId = routeId, payload = payload, requestId = requestId })
			return requestId
		end,
		resend = function()
			return true
		end,
		resultFor = function()
			return nil
		end,
	}
	local projectionToken, routesToken, controllerToken, viewToken, inputToken = {}, {}, {}, {}, {}
	local modules: { [any]: any } = {
		[projectionToken] = Projection,
		[routesToken] = Routes,
		[controllerToken] = Controller,
		[viewToken] = {
			new = function()
				return {
					button = {},
					render = function(nextView)
						if stoppedView then
							return
						end
						view = nextView
					end,
					setGlyph = function() end,
					stop = function()
						stoppedView = true
					end,
				}
			end,
		},
		[inputToken] = {
			new = function(options)
				inputOptions = options
				return {
					start = function() end,
					refresh = function()
						if stoppedInput then
							renderAfterStop += 1
						end
					end,
					setMode = function(nextMode)
						if not stoppedInput then
							mode = nextMode
						end
					end,
					stop = function()
						stoppedInput = true
					end,
				}
			end,
		},
	}
	local scheduler = {
		spawn = function(callback)
			pollThread = coroutine.create(callback)
			local ok, failure = coroutine.resume(pollThread :: thread)
			check(ok, tostring(failure))
		end,
		wait = function(seconds)
			check(seconds == 0.2, "runtime polling remains bounded")
			coroutine.yield()
		end,
	}
	-- Load the shipped runtime unchanged, retaining its real controller. Engine
	-- adapters and the clock are the only replacements.
	local runtimeModule =
		luau.load(fs.readFile("src/client/bootstrap/CaptureRuntimeService.luau"), {
			debugName = "Capture client runtime test",
			environment = {
				game = {
					GetService = function(_self, name)
						check(name == "ReplicatedStorage", "only shared contracts are imported")
						return {
							MonsterVault = {
								Shared = {
									contracts = {
										CaptureProjectionV1 = projectionToken,
										RouteIds = routesToken,
									},
								},
							},
						}
					end,
				},
				script = {
					Parent = {
						Parent = {
							controllers = { CaptureController = controllerToken },
							presentation = { CaptureView = viewToken },
							input = { InputRouter = inputToken },
						},
					},
				},
				require = function(token)
					check(modules[token] ~= nil, "runtime imports only the expected modules")
					return modules[token]
				end,
				os = {
					clock = function()
						return now
					end,
				},
				task = scheduler,
			},
			injectGlobals = true,
		})()
	local runtime = runtimeModule.new({
		networking = {
			gateway = gateway,
			store = {
				view = function()
					return { status = "Ready" }
				end,
			},
			subscribeCapture = function(listener)
				check(subscriber == nil, "only one capture subscription")
				subscriber = listener
				return function()
					subscriber = nil
				end
			end,
		},
		worldObserver = { store = {
			present = function()
				return entries
			end,
		} },
		player = {
			WaitForChild = function(_self, name)
				check(name == "PlayerGui", "only PlayerGui is awaited")
				return {}
			end,
			Character = {
				FindFirstChildOfClass = function()
					return { Health = 100 }
				end,
				FindFirstChild = function()
					return root
				end,
			},
		},
		userInputService = {},
		guiService = {},
	})
	return {
		runtime = runtime,
		requests = requests,
		entry = entry,
		model = model,
		view = function()
			return view
		end,
		mode = function()
			return mode
		end,
		activate = function()
			inputOptions.onActivate()
		end,
		streamOut = function()
			entries = {}
			model.Parent = nil
		end,
		streamIn = function()
			model.Parent = {}
			entries = { entry }
		end,
		move = function(x)
			root.Position = vector(x)
		end,
		advance = function(seconds)
			now += seconds
			if pollThread ~= nil and coroutine.status(pollThread) ~= "dead" then
				local ok, failure = coroutine.resume(pollThread)
				check(ok, tostring(failure))
			end
		end,
		deliver = function(payload, correlationId)
			if subscriber ~= nil then
				subscriber({ payload = payload, correlationId = correlationId })
			end
		end,
		stopped = function()
			return stoppedInput and stoppedView and subscriber == nil
		end,
		refreshAfterStop = function()
			return renderAfterStop
		end,
	}
end

local function periodicResyncRecoversLostUnsolicitedCaptureStates()
	local h = harness()
	h.runtime.start()
	check(
		#h.requests == 1 and h.requests[1].payload.domain == "capture",
		"startup requests capture state"
	)
	h.deliver(state("Claimed", 2))
	h.entry.availability = "Claimed"
	h.advance(4.8)
	check(#h.requests == 1, "active refresh does not run before its five-second cadence")
	-- Transport and touch-extraction states arrive without any pending client
	-- command. Simulate their first event being lost, then answer the refresh.
	h.advance(0.2)
	check(#h.requests == 2, "claimed capture refreshes after its command is complete")
	h.deliver(state("TransportActive", 3), h.requests[2].requestId)
	check(
		h.view().state == "TransportActive" and not h.view().canActivate,
		"lost transport recovers without inventing ownership"
	)
	h.advance(5)
	check(#h.requests == 3, "transport continues refreshing for unsolicited extraction")
	h.deliver(state("FinalizationPending", 4), h.requests[3].requestId)
	check(
		h.view().state == "FinalizationPending" and not h.view().canActivate,
		"uncertain P2 stays blocked"
	)
	h.advance(5)
	check(#h.requests == 4, "pending finalization continues authoritative refresh")
	h.deliver(state("Secured", 5), h.requests[4].requestId)
	check(h.view().state == "Secured", "lost secured result is recovered from authority")
	h.advance(10)
	check(#h.requests == 4, "confirmed terminal capture stops periodic refresh")
	h.runtime.stop()
end

local function streamedOutClaimBlocksActionWithoutChangingAuthority()
	local h = harness()
	h.runtime.start()
	h.deliver(state("Claimed", 2))
	h.entry.availability = "Claimed"
	h.advance(0.2)
	check(h.view().canActivate and h.mode() == "Capture", "present nearby claim can be attempted")
	h.streamOut()
	h.advance(0.2)
	check(
		h.view().state == "Claimed" and not h.view().canActivate and h.mode() == "Blocked",
		"streaming only disables the local action"
	)
	check(
		h.view().captureSessionId == "server-claim",
		"server claim survives streamed-out presentation"
	)
	local before = #h.requests
	h.activate()
	check(#h.requests == before, "streamed-out action cannot emit a capture command")
	h.streamIn()
	h.advance(0.2)
	check(
		h.view().canActivate and h.mode() == "Capture",
		"same claim becomes usable after streaming returns"
	)
	h.move(100)
	h.advance(0.2)
	check(
		h.view().state == "Claimed" and not h.view().canActivate,
		"distance disables presentation without asserting failure"
	)
	h.runtime.stop()
end

local function stoppedRuntimeCancelsQueuedPollingAndSubscription()
	local h = harness()
	h.runtime.start()
	h.deliver(state("TransportActive", 3))
	local before = #h.requests
	h.runtime.stop()
	check(h.stopped(), "stop removes capture subscription and both UI adapters")
	h.advance(10)
	h.deliver(state("Secured", 5))
	check(
		#h.requests == before and h.refreshAfterStop() == 0,
		"queued poll cannot refresh or emit RPC after stop"
	)
	check(not pcall(h.runtime.start), "capture client cannot accidentally restart old state")
	check(#h.runtime.stop() == 0, "repeated stop is harmless")
end

return {
	periodicResyncRecoversLostUnsolicitedCaptureStates = periodicResyncRecoversLostUnsolicitedCaptureStates,
	streamedOutClaimBlocksActionWithoutChangingAuthority = streamedOutClaimBlocksActionWithoutChangingAuthority,
	stoppedRuntimeCancelsQueuedPollingAndSubscription = stoppedRuntimeCancelsQueuedPollingAndSubscription,
}
