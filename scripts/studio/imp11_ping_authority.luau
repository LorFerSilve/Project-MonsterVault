--!strict
-- Mount as ServerScriptService.IMP11PingAuthorityProbe, beside the existing
-- IMP10WorldProbe and IMP10SpawnProbe. Ordinary boots disabled for this scope.
-- Reuses real authored geometry/capture/profile owners and an isolated DEV
-- DataStore. One real Player; no synthetic second-client claim.
local g = getfenv() :: any
local server: any = game:GetService("ServerScriptService")
local base: any = g.require(server.IMP10WorldProbe)
local spawn: any = g.require(server.IMP10SpawnProbe)
local s: any = nil
local function check(v: any, why: string?): any
	return assert(v, why or "native Ping owner invariant")
end
local function size(t: any): number
	local n = 0
	for _ in t do
		n += 1
	end
	return n
end
local function setup(): any
	base.setup(true)
	local b = base.scopeState()
	spawn.tick(1)
	local currentSession = b.session
	local root = check(b.player.Character:FindFirstChild("HumanoidRootPart"))
	local coordinator = {
		get = function(id)
			return if id == b.player.UserId then currentSession else nil
		end,
	}
	local timers, callbacks = {}, {}
	local peak = 0
	local scheduler = {
		delay = function(seconds, callback)
			table.insert(callbacks, callback)
			local thread: any
			thread = g.task.delay(seconds, function()
				timers[thread] = nil
				callback()
			end)
			timers[thread] = true
			peak = math.max(peak, size(timers))
			return thread
		end,
		cancel = function(thread)
			timers[thread] = nil
			g.task.cancel(thread)
		end,
	}
	local party = require(server.MonsterVaultServer.bootstrap.PartyRuntimeService).new({
		players = game:GetService("Players"),
		profileCoordinator = coordinator,
		worldRuntime = b.worldRuntime,
		httpService = game:GetService("HttpService"),
		event = b.remotes.Event,
		scheduler = scheduler,
	})
	party.start()
	b.network.stop()
	local network = require(server.MonsterVaultServer.bootstrap.NetworkingRuntimeService).new({
		players = game:GetService("Players"),
		profileCoordinator = coordinator,
		partyRuntime = party,
		command = b.remotes.Command,
		event = b.remotes.Event,
		unreliableEvent = b.remotes.UnreliableEvent,
		diagnostics = { emit = function() end },
	})
	network.start()
	s = {
		base = b,
		party = party,
		network = network,
		root = root,
		timers = timers,
		callbacks = callbacks,
		peak = function()
			return peak
		end,
		current = function()
			return currentSession
		end,
		replace = function(session)
			currentSession = session
		end,
	}
	check(party.owner.create(b.player) == "OK_PARTY_CREATED")
	check(party.owner.setPingPreference(b.player, false) == "OK_PREFERENCES_BUFFERED")
	s.before = currentSession.snapshot()
	s.initialPosition = root.CFrame
	check(b.worldRuntime.partyWaypoint(b.player, currentSession) ~= nil)
	check(b.worldRuntime.partyWaypoint(b.player, {}) == nil)
	root.CFrame = g.CFrame.new(100001, 100001, 100001)
	check(b.worldRuntime.partyWaypoint(b.player, currentSession) == nil, "outside authored world")
	root.CFrame = b.authored.MidARecovery.CFrame + g.Vector3.new(0, 3, 0)
	check(b.worldRuntime.partyWaypoint(b.player, currentSession) == nil, "locked-region point")
	root.CFrame = s.initialPosition
	local p = party.owner.snapshot(b.player).state.party
	s.envelope = {
		protocolVersion = 1,
		routeId = "Social.Ping",
		requestId = "native-ping-cache",
		expectedRevision = p.revision,
		payload = { partyId = p.partyId, pingKind = "ComeHere" },
	}
	check(network.gateway.handle(b.player, s.envelope).code == "OK_SOCIAL_PING")
	s.started = os.clock()
	check(size(timers) == 1 and party.owner.counts().pings == 1)
	local wire =
		require(game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts.WireValidation)
	check(wire.equal(s.before, currentSession.snapshot()), "ping changed profile")
	return {
		scope = b.scope,
		actualClients = 1,
		validAuthoredWaypoint = true,
		foreignSessionRejected = true,
		outsideWorldRejected = true,
		lockedRegionRejected = true,
		profileUnchanged = true,
		timerCount = size(timers),
	}
end
local function expiryAndReplacement(): any
	check(s ~= nil)
	check(s.party.owner.counts().pings == 0 and size(s.timers) == 0, "native expiry")
	local p = s.party.owner.snapshot(s.base.player).state.party
	local envelope = {
		protocolVersion = 1,
		routeId = "Social.Ping",
		requestId = "native-ping-rearm",
		expectedRevision = p.revision,
		payload = { partyId = p.partyId, pingKind = "ComeHere" },
	}
	check(s.network.gateway.handle(s.base.player, envelope).code == "OK_SOCIAL_PING")
	s.callbacks[1]()
	check(
		s.party.owner.counts().pings == 1 and size(s.timers) == 1,
		"consumed callback changed rearmed ping"
	)
	local old = s.current()
	check(old.release(os.clock() + 8).status == "Closed", "old scoped session release")
	local persistence = server.MonsterVaultServer.infrastructure.persistence
	local replacement = require(persistence.ProfileSession).new({
		userId = s.base.player.UserId,
		lockId = game:GetService("HttpService"):GenerateGUID(false),
		jobId = "IMP11-Ping",
		repository = require(server.MonsterVaultServer.adapters.RobloxProfileRepository).new(
			s.base.storeAdapter,
			true,
			"DEV"
		),
		schema = require(persistence.ProfileSchemaV1),
		queue = require(persistence.SingleWriterQueue).new(os.clock, g.task.wait, 5),
		retry = require(persistence.RetryPolicy).new(os.clock, g.task.wait, function()
			return 0.5
		end, 3),
		unixSeconds = s.base.clock.wallClock.unixSeconds,
		monotonicSeconds = os.clock,
	})
	local acquired = replacement.acquire()
	check(acquired.status == "Ready", "replacement acquire: " .. tostring(acquired.reason))
	check(replacement.snapshot().settings.socialPingsMuted == false, "P1 did not persist")
	s.replace(replacement)
	s.party.owner.observe(s.base.player.UserId)
	s.party.resync(s.base.player, "replacement-readback")
	check(
		s.party.owner.snapshot(s.base.player).state.party == nil
			and s.party.owner.counts().pings == 0,
		"replacement retained old membership or ping"
	)
	check(size(s.timers) == 0, "replacement retained a timer")
	-- The existing gateway checks the route bucket before replay inspection.
	g.task.wait(3.1)
	check(
		s.network.gateway.handle(s.base.player, envelope).code == "REJECT_VALIDATION_REQUEST_REUSE",
		"replacement replay fence"
	)
	s.callbacks[2]()
	check(s.party.owner.counts().pings == 0, "replacement callback resurrected ping")
	local elapsed = os.clock() - s.started
	return {
		elapsedSeconds = elapsed,
		nativeExpiry = true,
		peakTimers = s.peak(),
		consumedCallbackFence = true,
		profileReplaced = true,
		P1Persisted = true,
		noInheritedMembership = true,
		replayFenced = true,
		replacementCallbackFence = true,
	}
end
local function shutdown(): any
	check(s ~= nil)
	check(s.party.owner.create(s.base.player) == "OK_PARTY_CREATED")
	local p = s.party.owner.snapshot(s.base.player).state.party
	-- New session has no established world arrival; a ping correctly fails closed.
	check(
		s.party.owner.ping(s.base.player, p.partyId, "ComeHere", p.revision)
			== "REJECT_STATE_PING_WAYPOINT"
	)
	s.network.stop()
	s.party.stop()
	for _, callback in s.callbacks do
		callback()
	end
	check(
		size(s.timers) == 0
			and s.party.owner.counts().pings == 0
			and s.party.owner.counts().liveUsers == 0
	)
	check(s.current().release(os.clock() + 8).status == "Closed")
	base.release()
	return {
		staleSessionWaypointRejected = true,
		timerCount = size(s.timers),
		counts = s.party.owner.counts(),
		shutdownCallbackFence = true,
	}
end
return { setup = setup, expiryAndReplacement = expiryAndReplacement, shutdown = shutdown }
