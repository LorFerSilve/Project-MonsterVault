--!strict
-- Mount beside IMP10WorldProbe, IMP10SpawnProbe and IMP11Repository. Disable
-- ordinary boots for this isolated DEV scope. Real Player/avatar/world/profile,
-- real remotes and scheduler; one adapter peer with a real ProfileSession.
local g = getfenv() :: any
local server: any = game:GetService("ServerScriptService")
local base: any = g.require(server.IMP10WorldProbe)
local spawn: any = g.require(server.IMP10SpawnProbe)
local s: any = nil
local function check(v: any, why: string?): any
	return assert(v, why or "native Friendly Challenge authority invariant")
end
local function case(name: string, v: any)
	check(v, name)
	table.insert(s.cases, name)
end
local function size(t: any): number
	local n = 0
	for _ in t do
		n += 1
	end
	return n
end
local function view(): any
	return s.party.owner.snapshot(s.b.player).state.challenge
end
local function peerSession(): any
	local p = server.MonsterVaultServer.infrastructure.persistence
	local session = require(p.ProfileSession).new({
		userId = s.peer.UserId,
		lockId = game:GetService("HttpService"):GenerateGUID(false),
		jobId = "IMP11-Challenge-Peer",
		repository = s.repository,
		schema = require(p.ProfileSchemaV1),
		queue = require(p.SingleWriterQueue).new(os.clock, g.task.wait, 5),
		retry = require(p.RetryPolicy).new(os.clock, g.task.wait, function()
			return 0.5
		end, 3),
		unixSeconds = os.time,
		monotonicSeconds = os.clock,
	})
	check(session.acquire().status == "Ready")
	return session
end
local function packet(route: string, payload: any, expected: number?): any
	return {
		protocolVersion = 1,
		routeId = route,
		requestId = "native-challenge-" .. game:GetService("HttpService"):GenerateGUID(false),
		payload = payload,
		expectedRevision = expected,
	}
end
local function moveToStart()
	local root = check(s.b.player.Character:FindFirstChild("HumanoidRootPart"))
	root.CFrame = s.b.authored.StarterTravel.CFrame + g.Vector3.new(0, 3, 0)
	root.AssemblyLinearVelocity = g.Vector3.zero
	g.task.wait(0.15)
	spawn.tick(2)
	check(
		s.b.worldRuntime.challengeCapability(s.b.player, s.b.session, true),
		"ordinary start capability"
	)
end
local function offer(): any
	local d = s.definition
	local e = packet(
		"Social.ChallengeRequest",
		{ targetUserId = s.b.player.UserId, definitionId = d.id, definitionVersion = d.version }
	)
	local code = s.network.gateway.handle(s.peer, e).code
	check(code == "OK_CHALLENGE_OFFERED", "native peer offer: " .. code)
	s.latestOffer = e
	return check(view())
end
local function setup(): any
	base.setup(true)
	local b = base.scopeState()
	-- Keep the unattended native fixture on its authored ground during deadlines.
	-- Normal travel still uses the shipped owner and post-relocation validation.
	check(b.player.Character:FindFirstChild("HumanoidRootPart")).Anchored = true
	s = {
		b = b,
		cases = {},
		peer = { UserId = 700000001 },
		repository = g.require(server.IMP11Repository).new(),
		timers = {},
		callbacks = {},
		peak = 0,
		peerPresent = true,
	}
	s.peer.Character = g.Instance.new("Model") -- adapter capability only; never placed in world.
	s.peerCurrent = peerSession()
	s.realCurrent = b.session
	local players = game:GetService("Players")
	local adapter = {
		PlayerAdded = players.PlayerAdded,
		PlayerRemoving = players.PlayerRemoving,
		GetPlayerByUserId = function(_self, id)
			return if id == s.peer.UserId
				then (if s.peerPresent then s.peer else nil)
				else players:GetPlayerByUserId(id)
		end,
	}
	local coordinator = {
		get = function(id)
			return if id == b.player.UserId
				then s.realCurrent
				else if id == s.peer.UserId and s.peerPresent then s.peerCurrent else nil
		end,
	}
	local event = {
		IsA = function(_self, class)
			return b.remotes.Event:IsA(class)
		end,
		FireClient = function(_self, player, e)
			if player == b.player then
				b.remotes.Event:FireClient(player, e)
			else
				s.peerLastEvent = e
			end
		end,
	}
	local scheduler = {
		delay = function(seconds, callback)
			table.insert(s.callbacks, callback)
			local thread: any
			thread = g.task.delay(seconds, function()
				s.timers[thread] = nil
				callback()
			end)
			s.timers[thread] = true
			s.peak = math.max(s.peak, size(s.timers))
			return thread
		end,
		cancel = function(thread)
			s.timers[thread] = nil
			g.task.cancel(thread)
		end,
	}
	local world = {
		challengeCapability = function(player, session, atStart)
			if player == s.peer then
				return if s.peerPresent
						and session == s.peerCurrent
						and session.state() == "Ready"
					then { character = s.peer.Character, generation = 1 }
					else nil
			end
			return b.worldRuntime.challengeCapability(player, session, atStart)
		end,
		bindChallengeLifecycle = b.worldRuntime.bindChallengeLifecycle,
	}
	s.party = require(server.MonsterVaultServer.bootstrap.PartyRuntimeService).new({
		players = adapter,
		profileCoordinator = coordinator,
		httpService = game:GetService("HttpService"),
		event = event,
		worldRuntime = world,
		captureRuntime = b.captureRuntime,
		scheduler = scheduler,
	})
	s.party.start()
	b.network.stop()
	s.network = require(server.MonsterVaultServer.bootstrap.NetworkingRuntimeService).new({
		players = adapter,
		profileCoordinator = coordinator,
		partyRuntime = s.party,
		worldRuntime = b.worldRuntime,
		captureRuntime = b.captureRuntime,
		command = b.remotes.Command,
		event = event,
		unreliableEvent = b.remotes.UnreliableEvent,
		diagnostics = {
			emit = function(_level, code)
				error(code)
			end,
		},
	})
	s.network.start()
	moveToStart()
	s.before, s.peerBefore, s.calls =
		b.session.snapshot(), s.peerCurrent.snapshot(), s.repository.calls()
	case(
		"ordinaryAuthoredStartCapability",
		b.worldRuntime.challengeCapability(b.player, b.session, true) ~= nil
	)
	case(
		"foreignSessionCapabilityRejected",
		b.worldRuntime.challengeCapability(b.player, {}, true) == nil
	)
	case(
		"noNewGameplayOrPartyAuthority",
		s.party.owner.counts().parties == 0 and s.party.owner.counts().challenges == 0
	)
	return { scope = b.scope, actualClients = 1, adapterPeers = 1, cases = s.cases }
end
local function offerForClient(): any
	local c = offer()
	case(
		"nativeOfferPinnedDefinitionAndConsent",
		c.phase == "Offered"
			and c.definitionId == s.definition.id
			and c.definitionVersion == 1
			and c.rules == nil
			and c.title == nil
	)
	case("singleExistingDeadlineOwner", size(s.timers) == 1 and s.peak == 1)
	local before =
		require(game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts.WireValidation)
	case(
		"offerNoProfileOrStorageMutation",
		before.equal(s.before, s.b.session.snapshot())
			and before.equal(s.peerBefore, s.peerCurrent.snapshot())
			and s.repository.calls() == s.calls
	)
	local duplicate = s.network.gateway.handle(s.peer, s.latestOffer)
	check(duplicate.code == "REJECT_RATE_LIMIT") -- Gateway bucket intentionally precedes replay.
	case(
		"offerSpamCannotMultiply",
		s.party.owner.counts().challenges == 1 and s.party.owner.counts().challengeParticipants == 2
	)
	return { challenge = c, cases = s.cases }
end
local function afterClientFinish(): any
	local c = check(view())
	case(
		"realWorldOutcomeOnlyResolution",
		c.phase == "Resolved" and c.winnerUserId == s.b.player.UserId and c.elapsedMs >= 0
	)
	local root = check(s.b.player.Character:FindFirstChild("HumanoidRootPart"))
	case(
		"ordinaryValidatedHomeArrival",
		(root.Position - s.b.authored.HomeHubRecovery.Position).Magnitude < 4.5
	)
	local wire =
		require(game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts.WireValidation)
	case(
		"resultNoProfileValueMutation",
		wire.equal(s.before, s.b.session.snapshot())
			and wire.equal(s.peerBefore, s.peerCurrent.snapshot())
			and s.repository.calls() == s.calls
	)
	local revision = c.revision
	check(
		s.network.gateway.handle(
			s.peer,
			packet("Social.ChallengeRespond", { challengeId = c.id, accept = true }, revision)
		).code == "REJECT_STATE_CHALLENGE_PHASE"
	)
	case(
		"terminalResultFreeze",
		view().revision == revision and view().winnerUserId == c.winnerUserId
	)
	return { result = c, cases = s.cases }
end
local function resultCleanAndArmExpiry(): any
	case(
		"terminalNativeCleanup",
		view() == nil and s.party.owner.counts().challenges == 0 and size(s.timers) == 0
	)
	moveToStart()
	s.expiryOffer = offer()
	local current = s.expiryOffer.id
	s.callbacks[1]()
	case(
		"staleConsumedTimerCannotChangeNewOffer",
		view().id == current and view().phase == "Offered" and size(s.timers) == 1
	)
	return { offered = s.expiryOffer, cases = s.cases }
end
local function afterOfferExpiry(): any
	local c = check(view())
	case("actualOfferExpiryNoPenalty", c.phase == "Expired" and c.reason == "Ignored")
	local wire =
		require(game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts.WireValidation)
	case(
		"ignoredNoValueMutation",
		wire.equal(s.before, s.b.session.snapshot())
			and wire.equal(s.peerBefore, s.peerCurrent.snapshot())
	)
	return { expired = c, cases = s.cases }
end
local function resetAndReplacement(): any
	check(view() == nil, "expiry result cleaned")
	moveToStart()
	local c = offer()
	check(
		s.network.gateway.handle(
			s.b.player,
			packet("Social.ChallengeRespond", { challengeId = c.id, accept = true }, c.revision)
		).code == "OK_CHALLENGE_ACTIVE"
	)
	local oldCharacter = s.b.player.Character
	local oldGeneration = s.b.player:GetAttribute("MonsterVaultCharacterGeneration")
	s.b.player:LoadCharacterAsync()
	local untilAt = os.clock() + 6
	while
		s.b.player:GetAttribute("MonsterVaultCharacterGeneration") <= oldGeneration
		and os.clock() < untilAt
	do
		g.task.wait(0.05)
	end
	check(s.b.player.Character:WaitForChild("HumanoidRootPart")).Anchored = true
	case(
		"actualCharacterResetCancels",
		view().phase == "Cancelled"
			and view().reason == "Interrupted"
			and s.b.player.Character ~= oldCharacter
	)
	s.party.owner.interruptChallenge(s.b.player, oldCharacter, false)
	case("oldAvatarCallbackCannotRewrite", view().phase == "Cancelled")
	g.task.wait(6.1)
	moveToStart()
	c = offer()
	local old = s.peerCurrent
	check(old.release(os.clock() + 5).status == "Closed")
	s.peerCurrent = peerSession()
	g.task.wait(3.1) -- Respect the existing route budget before testing private replay fencing.
	local outcome = s.network.gateway.handle(s.peer, s.latestOffer)
	case(
		"privateProfileSessionReplacementFencesReplay",
		outcome.code == "REJECT_VALIDATION_REQUEST_REUSE"
	)
	check(
		s.network.gateway.handle(s.b.player, packet("Session.RequestResync", { domain = "party" })).code
			== "OK_PARTY_SNAPSHOT"
	)
	case(
		"replacementHasNoChallengeAuthority",
		s.party.owner.snapshot(s.peer).state.challenge == nil and view().phase == "Cancelled"
	)
	check(s.party.owner.counts().challengeParticipants == 1)
	return { cases = s.cases }
end
local function shutdown(): any
	s.network.stop()
	s.party.stop()
	for _, callback in s.callbacks do
		callback()
	end
	local counts = s.party.owner.counts()
	for _, n in counts do
		check(n == 0)
	end
	case(
		"shutdownAndStaleCallbacksAllZero",
		size(s.timers) == 0 and counts.challenges == 0 and s.peak == 1
	)
	check(s.peerCurrent.release(os.clock() + 5).status == "Closed")
	s.peer.Character:Destroy()
	check(#s.b.captureRuntime.stop() == 0)
	s.b.worldRuntime.stop()
	check(s.b.player.Character:FindFirstChild("HumanoidRootPart")).Anchored = false
	base.release()
	check(s.b.session.state() == "Closed")
	return {
		cases = s.cases,
		peakTimers = s.peak,
		counts = counts,
		actualClients = 1,
		adapterPeers = 1,
	}
end
return {
	setup = function(): any
		local result = setup()
		s.definition = require(
			game:GetService("ReplicatedStorage").MonsterVault.Shared.config.FriendlyChallengeDefinition
		)
		return result
	end,
	offerForClient = offerForClient,
	afterClientFinish = afterClientFinish,
	resultCleanAndArmExpiry = resultCleanAndArmExpiry,
	afterOfferExpiry = afterOfferExpiry,
	resetAndReplacement = resetAndReplacement,
	shutdown = shutdown,
}
