--!strict

-- Mount as ServerScriptService.IMP11PartyProbe; mount the existing test fixture
-- FakeProfileRepository beside it as IMP11Repository. Disable ordinary boot for
-- this scoped probe. Real Player, remotes, ProfileSession and task scheduler;
-- in-memory profile storage because Party is P0 and has no DataStore outcome.
local globals = getfenv() :: any
local server: any = game:GetService("ServerScriptService")
local state: any = nil
local function check(value: any, message: string?): any
	return assert(value, message or "native Party invariant")
end
local function session(s: any, userId: number): any
	local root = server.MonsterVaultServer.infrastructure.persistence
	local owner = require(root.ProfileSession).new({
		userId = userId,
		lockId = game:GetService("HttpService"):GenerateGUID(false),
		jobId = "IMP11-native",
		repository = s.repository,
		schema = require(root.ProfileSchemaV1),
		queue = require(root.SingleWriterQueue).new(os.clock, globals.task.wait, 5),
		retry = require(root.RetryPolicy).new(os.clock, globals.task.wait, function()
			return 0.5
		end, 3),
		unixSeconds = os.time,
		monotonicSeconds = os.clock,
	})
	check(owner.acquire().status == "Ready", "native ProfileSession acquire")
	return owner
end
local function remotes(name: string): any
	local folder = globals.Instance.new("Folder")
	folder.Name, folder.Parent = name, game:GetService("ReplicatedStorage")
	for key, className in
		{
			Command = "RemoteEvent",
			Event = "RemoteEvent",
			UnreliableEvent = "UnreliableRemoteEvent",
		}
	do
		local object = globals.Instance.new(className)
		object.Name, object.Parent = key, folder
	end
	return folder
end
local function setup(remoteName: string?): any
	check(state == nil and game:GetService("RunService"):IsStudio())
	local player = check(game:GetService("Players"):GetPlayers()[1])
	local s: any = {
		player = player,
		repository = globals.require(server.IMP11Repository).new(),
		sessions = {},
	}
	s.sessions[player.UserId] = session(s, player.UserId)
	s.baseline = s.sessions[player.UserId].snapshot()
	s.storageCalls = s.repository.calls()
	s.coordinator = {
		get = function(userId: number)
			return s.sessions[userId]
		end,
	}
	s.remotes = remotes(remoteName or "IMP11PartyProbeRemotes")
	s.party = require(server.MonsterVaultServer.bootstrap.PartyRuntimeService).new({
		players = game:GetService("Players"),
		profileCoordinator = s.coordinator,
		httpService = game:GetService("HttpService"),
		event = s.remotes.Event,
	})
	s.network = require(server.MonsterVaultServer.bootstrap.NetworkingRuntimeService).new({
		players = game:GetService("Players"),
		profileCoordinator = s.coordinator,
		partyRuntime = s.party,
		command = s.remotes.Command,
		event = s.remotes.Event,
		unreliableEvent = s.remotes.UnreliableEvent,
		diagnostics = {
			emit = function(_level, code)
				print("IMP11_NETWORK " .. code)
			end,
		},
	})
	s.composition = require(server.MonsterVaultServer.bootstrap.ServerComposition).new({
		unixSeconds = os.time,
		monotonicSeconds = os.clock,
		sink = function(record)
			print("IMP11_COMPOSITION " .. game:GetService("HttpService"):JSONEncode(record))
		end,
		services = {
			{
				id = "profiles",
				dependencies = {},
				start = function() end,
				stop = function()
					return {}
				end,
			},
			s.party,
			s.network,
		},
	})
	s.composition.start()
	s.removingConnection = game:GetService("Players").PlayerRemoving
		:Connect(function(leaving, reason)
			if leaving == player then
				s.departure = { reason = tostring(reason), counts = s.party.owner.counts() }
				print(
					"IMP11_NATIVE_PLAYER_REMOVING "
						.. game:GetService("HttpService"):JSONEncode(s.departure)
				)
			end
		end)
	state = s
	game:BindToClose(function()
		globals.task.wait(0.2) -- let native PlayerRemoving listeners settle in the live server.
		if s.departure then
			s.departure.settledCounts = s.party.owner.counts()
			print(
				"IMP11_NATIVE_DEPARTURE_SETTLED "
					.. game:GetService("HttpService"):JSONEncode(s.departure)
			)
		end
		local failures = s.composition.shutdown(5)
		print(
			"IMP11_NATIVE_SHUTDOWN "
				.. game:GetService("HttpService")
					:JSONEncode({ failures = failures, counts = s.party.owner.counts() })
		)
	end)
	return {
		userId = player.UserId,
		profileState = s.sessions[player.UserId].state(),
		counts = s.party.owner.counts(),
		storageCalls = s.storageCalls,
	}
end
local function verifyNoValueMutation(): any
	local s = check(state)
	local wire =
		require(game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts.WireValidation)
	check(s.repository.calls() == s.storageCalls, "Party performed profile writes")
	check(
		wire.equal(s.baseline, s.sessions[s.player.UserId].snapshot()),
		"Party changed personal value"
	)
	return {
		profileUnchanged = true,
		storageCalls = s.storageCalls,
		counts = s.party.owner.counts(),
	}
end
local function replaceProfile(): any
	local s = check(state)
	local prior = s.sessions[s.player.UserId]
	check(prior.release(os.clock() + 5).status == "Closed")
	s.sessions[s.player.UserId] = session(s, s.player.UserId)
	s.baseline = s.sessions[s.player.UserId].snapshot()
	s.storageCalls = s.repository.calls()
	s.party.owner.observe(s.player.UserId)
	s.party.resync(s.player, "native-replaced-session")
	local projection = s.party.owner.snapshot(s.player)
	check(
		projection.state.party == nil
			and projection.state.rejoin == nil
			and not projection.state.allowInvites,
		"replacement inherited private authority"
	)
	return {
		replaced = prior ~= s.sessions[s.player.UserId],
		oldState = prior.state(),
		projection = projection,
	}
end
local function beginTimer(): any
	local s = check(state)
	check(s.timer == nil)
	-- This peer is a scheduler adapter fixture, NOT a second connected client.
	local peer = { UserId = 6_000_000_001 }
	s.sessions[peer.UserId] = session(s, peer.UserId)
	local added, removed =
		globals.Instance.new("BindableEvent"), globals.Instance.new("BindableEvent")
	local t: any = {
		peer = peer,
		added = added,
		removed = removed,
		callbacks = {},
		handles = {},
		active = 0,
		peak = 0,
		peerPackets = {},
	}
	local scheduler = {
		delay = function(seconds: number, callback: () -> ()): any
			t.active += 1
			t.peak = math.max(t.peak, t.active)
			table.insert(t.callbacks, callback)
			local handle: any = nil
			handle = globals.task.delay(seconds, function()
				t.handles[handle] = nil
				t.active -= 1
				callback()
			end)
			t.handles[handle] = true
			return handle
		end,
		cancel = function(handle: any)
			if t.handles[handle] then
				t.handles[handle] = nil
				t.active -= 1
				globals.task.cancel(handle)
			end
		end,
	}
	local players = {
		PlayerAdded = added.Event,
		PlayerRemoving = removed.Event,
		GetPlayerByUserId = function(_self, userId)
			return if userId == peer.UserId
				then peer
				else if userId == s.player.UserId then s.player else nil
		end,
	}
	t.runtime = require(server.MonsterVaultServer.bootstrap.PartyRuntimeService).new({
		players = players,
		profileCoordinator = s.coordinator,
		httpService = game:GetService("HttpService"),
		scheduler = scheduler,
		event = {
			FireClient = function(_self, player, envelope)
				if player == peer then
					t.peerPackets[1] = envelope
				end -- bounded last readback only.
			end,
		},
	})
	t.runtime.start()
	local routes = require(
		game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts.RouteIds
	).commands
	local function command(player: any, route: string, payload: any, expected: number?): string
		return t.runtime.handlers[route](player, { payload = payload, expectedRevision = expected })
	end
	t.command = command
	check(command(s.player, routes.socialPartyCreate, {}, nil) == "OK_PARTY_CREATED")
	check(
		command(peer, routes.socialPartySetInvitePolicy, { allowInvites = true }, nil)
			== "OK_PARTY_INVITE_POLICY"
	)
	check(
		command(s.player, routes.socialPartyInvite, { targetUserId = peer.UserId }, 1)
			== "OK_PARTY_INVITED"
	)
	check(t.active == 1 and t.peak == 1)
	t.start = os.clock()
	state.timer = t
	return { timerCount = t.active, expirySeconds = 30, nativePeerClients = 0 }
end
local function finishTimer(): any
	local s, t = check(state), check(state.timer)
	check(os.clock() - t.start >= 30, "wait for actual engine task.delay expiry")
	check(
		t.active == 0 and t.runtime.owner.counts().invites == 0,
		"native expiry leaked timer/invite"
	)
	check(#t.peerPackets[1].payload.state.incoming == 0)
	local routes = require(
		game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts.RouteIds
	).commands
	check(
		t.command(s.player, routes.socialPartyInvite, { targetUserId = t.peer.UserId }, 1)
			== "OK_PARTY_INVITED"
	)
	check(t.active == 1 and t.peak == 1)
	t.callbacks[1]() -- callback from the expired timer must not consume the replacement.
	check(t.active == 1 and t.runtime.owner.counts().invites == 1)
	local pendingCallback = t.callbacks[#t.callbacks]
	t.runtime.stop()
	pendingCallback()
	local counts = t.runtime.owner.counts()
	check(
		t.active == 0
			and counts.parties == 0
			and counts.invites == 0
			and counts.memberships == 0
			and counts.liveUsers == 0
	)
	t.added:Destroy()
	t.removed:Destroy()
	return {
		elapsed = os.clock() - t.start,
		peakTimers = t.peak,
		nativeExpiry = true,
		rearmedCallbackFence = true,
		shutdownCallbackFence = true,
		counts = counts,
	}
end
local function kick(): any
	local s = check(state)
	check(
		s.party.owner.snapshot(s.player).state.party ~= nil,
		"create native Party before departure"
	)
	s.player:Kick("IMP11 native lifecycle probe complete")
	return "native CreatorKick requested"
end
local function departure(): any
	local s = check(state)
	local d = check(s.departure, "native PlayerRemoving not yet observed")
	-- Native signal callbacks may be scheduled in either order. Assert the
	-- settled owner, not the counts captured by another listener at signal entry.
	local deadline = os.clock() + 2
	while s.party.owner.counts().liveUsers > 0 and os.clock() < deadline do
		globals.task.wait(0.02)
	end
	d.settledCounts = s.party.owner.counts()
	check(
		d.settledCounts.parties == 0
			and d.settledCounts.memberships == 0
			and d.settledCounts.invites == 0
			and d.settledCounts.liveUsers == 0,
		"native departure leaked: " .. game:GetService("HttpService"):JSONEncode(d)
	)
	return d
end
local function cleanup(): any
	local s = check(state)
	check(#s.composition.shutdown(5) == 0)
	s.removingConnection:Disconnect()
	s.remotes:Destroy()
	local counts = s.party.owner.counts()
	check(
		counts.parties == 0
			and counts.memberships == 0
			and counts.invites == 0
			and counts.liveUsers == 0
	)
	state = nil
	return counts
end

return {
	setup = setup,
	verifyNoValueMutation = verifyNoValueMutation,
	replaceProfile = replaceProfile,
	beginTimer = beginTimer,
	finishTimer = finishTimer,
	kick = kick,
	departure = departure,
	cleanup = cleanup,
}
