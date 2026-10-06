--!strict
-- Isolated in-memory DEV profiles with one real Player/client and three explicit
-- adapter peers. Mount with IMP11Repository; disable ordinary boots for this probe.
local g = getfenv() :: any
local server: any = game:GetService("ServerScriptService").MonsterVaultServer
local shared: any = game:GetService("ReplicatedStorage").MonsterVault.Shared
local s: any = nil
local function check(v: any, why: string?): any
	return assert(v, why or "native Showcase authority invariant")
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
local function permission(player: any): any
	return s.social.showcase.snapshot(player).state
end
local function view(): any
	return s.social.showcase.viewSnapshot(s.player).state
end
local function packet(route: string, payload: any, expected: number?): any
	return {
		protocolVersion = 1,
		routeId = route,
		payload = payload,
		expectedRevision = expected,
		requestId = "showcase-native-" .. game:GetService("HttpService"):GenerateGUID(false),
	}
end
local function send(player: any, route: string, payload: any, expected: number?): (any, any)
	local e = packet(route, payload, expected)
	return s.network.gateway.handle(player, e).code, e
end
local function policy(player: any, audience: string)
	check(
		send(
			player,
			s.routes.socialShowcaseSetPolicy,
			{ audience = audience },
			permission(player).permissionRevision
		) == "OK_SHOWCASE_POLICY"
	)
end
local function grant(owner: any, visitor: any): any
	local code, e = send(
		owner,
		s.routes.socialShowcaseGrant,
		{ targetUserId = visitor.UserId },
		permission(owner).permissionRevision
	)
	check(
		code == "OK_SHOWCASE_GRANTED" or code == "OK_SHOWCASE_ALREADY_GRANTED",
		"native grant: " .. code
	)
	s.latestGrant = e
	for _, row in permission(visitor).incoming do
		if row.userId == owner.UserId then
			return row
		end
	end
	error("native grant missing")
end
local function summary(): any
	return {
		actualClients = 1,
		adapterPeers = 3,
		cases = s.cases,
		counts = s.social.showcase.counts(),
		peakTimers = s.peak,
	}
end
local function fixtureProfile(id: number): any
	local p = require(server.infrastructure.persistence.ProfileSchemaV1).default(os.time())
	p.profileRevision = 1 -- Existing Vault commands require a positive revision.
	check(s.vault.prepare(p).status == "Prepared")
	check(s.production.prepareLoad(p, os.time()).status == "Prepared")
	check(s.energy.prepare(p).status == "Prepared")
	p.economy.energyUnits, p.vault.productionBufferMilli = 75, 1234
	p.commerce = { Supporter = true, VaultClub = true, privateReceipt = "private-native-receipt" }
	p.collection.creaturesById = {}
	for index = 1, 2 do
		local idText = "showcase-" .. id .. "-" .. index
		p.collection.creaturesById[idText] = {
			creatureInstanceId = idText,
			ownerUserId = id,
			speciesId = "species/stability-orb-dev",
			operationId = "capture-" .. idText,
			securedAt = os.time(),
			locked = true,
			overflowHeld = false,
			origin = { spawnContextId = "private-spawn", contentSnapshotId = "content/fixture" },
			variantIdentity = {
				speciesRarityId = "rarity/legendary",
				variantSignature = "private-signature",
				spawnContextId = "private-spawn",
				contentSnapshotId = "content/fixture",
				mutationIdsCanonical = { "mutation/neon" },
				traitIds = { "trait/calm" },
				protectedVariantReasons = { "Legendary" },
			},
		}
		p.vault.displayAssignments["display/" .. index] = idText
	end
	return p
end
local function setup(): any
	check(s == nil)
	s = {
		player = check(game:GetService("Players"):GetPlayers()[1]),
		cases = {},
		timers = {},
		callbacks = {},
		peak = 0,
		peers = {
			{ UserId = 700000010, DisplayName = "Showcase peer" },
			{ UserId = 700000011, DisplayName = "Second peer" },
			{ UserId = 700000012, DisplayName = "Third peer" },
		},
		repository = g.require(game:GetService("ServerScriptService").IMP11Repository).new(),
		routes = require(shared.contracts.RouteIds).commands,
	}
	s.wire = require(shared.contracts.WireValidation)
	s.production = require(server.domains.vault.VaultProductionService).new(
		require(shared.config.VaultProductionFixture)
	)
	s.vault =
		require(server.domains.vault.VaultService).new(require(shared.config.VaultCapacityFixture))
	s.present = {}
	s.energy = require(server.domains.economy.EnergyService).new()
	local actors = { s.player, table.unpack(s.peers) }
	for _, actor in actors do
		s.present[actor.UserId] = actor
		s.repository.seed("player/" .. actor.UserId, fixtureProfile(actor.UserId))
	end
	s.coordinator = require(server.application.SessionCoordinator).new({
		createSession = function(id)
			local p = server.infrastructure.persistence
			return require(p.ProfileSession).new({
				userId = id,
				lockId = game:GetService("HttpService"):GenerateGUID(false),
				jobId = "Showcase-Native",
				repository = s.repository,
				schema = require(p.ProfileSchemaV1),
				queue = require(p.SingleWriterQueue).new(os.clock, g.task.wait, 5),
				retry = require(p.RetryPolicy).new(os.clock, g.task.wait, function()
					return 0.5
				end, 3),
				unixSeconds = os.time,
				monotonicSeconds = os.clock,
			})
		end,
		unixSeconds = os.time,
		monotonicSeconds = os.clock,
		spawn = g.task.spawn,
		waitSeconds = g.task.wait,
	})
	for _, actor in actors do
		check(s.coordinator.open(actor.UserId).status == "Ready")
	end
	local players = game:GetService("Players")
	s.players = {
		PlayerAdded = players.PlayerAdded,
		PlayerRemoving = players.PlayerRemoving,
		GetPlayerByUserId = function(_self, id)
			if id == s.player.UserId then
				return players:GetPlayerByUserId(id)
			end
			return s.present[id]
		end,
	}
	s.remotes = game:GetService("ReplicatedStorage").IMP11ShowcaseProbe
	local event = {
		IsA = function(_self, class)
			return s.remotes.Event:IsA(class)
		end,
		FireClient = function(_self, player, e)
			if player == s.player then
				s.remotes.Event:FireClient(player, e)
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
	s.social = require(server.bootstrap.PartyRuntimeService).new({
		players = s.players,
		profileCoordinator = s.coordinator,
		httpService = game:GetService("HttpService"),
		event = event,
		production = s.production,
		scheduler = scheduler,
	})
	s.assignments = require(server.application.VaultProductionUseCase).new({
		production = s.production,
		vault = s.vault,
		unixSeconds = os.time,
		monotonicSeconds = os.clock,
		newOperationId = function()
			return game:GetService("HttpService"):GenerateGUID(false)
		end,
	})
	s.network = require(server.bootstrap.NetworkingRuntimeService).new({
		claims = require(server.application.ProductionClaimUseCase).new({
			energy = s.energy,
			production = s.production,
			vault = s.vault,
			assignments = s.assignments,
			newOperationId = function()
				return game:GetService("HttpService"):GenerateGUID(false)
			end,
		}),
		command = s.remotes.Command,
		event = event,
		unreliableEvent = s.remotes.UnreliableEvent,
		players = s.players,
		profileCoordinator = s.coordinator,
		partyRuntime = s.social,
		production = s.production,
		assignments = s.assignments,
		diagnostics = { emit = function() end },
	})
	s.social.start()
	s.network.start()
	for _, actor in actors do
		check(
			send(actor, s.routes.socialPartySetInvitePolicy, { allowInvites = true })
				== "OK_PARTY_INVITE_POLICY"
		)
	end
	policy(s.peers[1], "SameServer")
	policy(s.player, "SameServer")
	s.before = {}
	for _, actor in actors do
		s.before[actor.UserId] = s.coordinator.get(actor.UserId).snapshot()
	end
	s.beforeCalls = s.repository.calls()
	s.first = grant(s.peers[1], s.player)
	case(
		"ownerTargetedGrantDoesNotOpenVisitor",
		view().mode == "Closed" and s.social.showcase.counts().visits == 0
	)
	return summary()
end
local function readback(): any
	local v = view()
	case(
		"realPlayerExactReadOnlyProjection",
		v.mode == "ReadOnly"
			and v.ownerUserId == s.peers[1].UserId
			and v.creatures[1].creatureInstanceId == "showcase-700000010-1"
			and v.creatures[1].speciesRarityId == "rarity/legendary"
	)
	case(
		"noPrivateOrCommercialFields",
		v.profile == nil
			and v.energyUnits == nil
			and v.commerce == nil
			and v.creatures[1].locked == nil
			and v.creatures[1].origin == nil
			and v.creatures[1].variantSignature == nil
	)
	case("permissionAndViewDoNotWriteProfiles", s.repository.calls() == s.beforeCalls)
	for id, before in s.before do
		check(s.wire.equal(before, s.coordinator.get(id).snapshot()))
	end
	case("noOwnershipEnergyDiscoveryOrAssignmentMutation", true)
	return summary()
end
local function revoke(): any
	check(
		send(
			s.peers[1],
			s.routes.socialShowcaseRevoke,
			{ grantId = s.first.id },
			permission(s.peers[1]).permissionRevision
		) == "OK_SHOWCASE_REVOKED"
	)
	case(
		"ownerRevokeImmediatelyClearsNativeView",
		view().reason == "Revoked" and s.social.showcase.counts().grants == 0
	)
	return summary()
end
local function boundsAndRefresh(): any
	g.task.wait(3.1)
	local a = grant(s.player, s.peers[1])
	local callbacks: any = table.clone(s.callbacks)
	g.task.wait(3.1)
	local b = grant(s.player, s.peers[2])
	check(s.social.showcase.open(s.peers[1], s.player.UserId, a.id) == "OK_SHOWCASE_READ_ONLY")
	check(s.social.showcase.open(s.peers[2], s.player.UserId, b.id) == "OK_SHOWCASE_READ_ONLY")
	case(
		"twoVisitorsShareApprovedExactInstance",
		s.social.showcase.viewSnapshot(s.peers[1]).state.creatures[1].creatureInstanceId
			== s.social.showcase.viewSnapshot(s.peers[2]).state.creatures[1].creatureInstanceId
	)
	g.task.wait(3.1)
	case(
		"thirdVisitorBoundRejected",
		send(
			s.player,
			s.routes.socialShowcaseGrant,
			{ targetUserId = s.peers[3].UserId },
			permission(s.player).permissionRevision
		) == "REJECT_STATE_SHOWCASE_BOUND"
	)
	local session = s.coordinator.get(s.player.UserId)
	check(session.checkpoint("native-display-clear", function(p)
		p.vault.displayAssignments["display/1"], p.vault.displayAssignments["display/2"] = nil, nil
	end).status == "Committed")
	case(
		"realProfileObserverRefreshesBothVisitors",
		#s.social.showcase.viewSnapshot(s.peers[1]).state.creatures == 0
			and #s.social.showcase.viewSnapshot(s.peers[2]).state.creatures == 0
	)
	policy(s.player, "Closed")
	for _, callback in callbacks do
		callback()
	end
	case(
		"staleTimerCannotRestoreRevokedAuthority",
		s.social.showcase.counts().grants == 0 and s.social.showcase.counts().visits == 0
	)
	return summary()
end
local function replacement(): any
	g.task.wait(3.1)
	s.first = grant(s.peers[1], s.player)
	check(
		s.social.showcase.open(s.player, s.peers[1].UserId, s.first.id) == "OK_SHOWCASE_READ_ONLY"
	)
	local old = s.coordinator.get(s.player.UserId)
	check(s.coordinator.close(s.player.UserId, os.clock() + 5).status == "Closed")
	check(s.coordinator.open(s.player.UserId).status == "Ready")
	case(
		"actualProfileSessionReplacementRevokesVisitor",
		s.coordinator.get(s.player.UserId) ~= old
			and s.social.showcase.counts().grants == 0
			and view().mode == "Closed"
	)
	s.social.showcase.profileChanged(s.player.UserId, old)
	case("staleProfileCallbackCannotRestoreVisit", s.social.showcase.counts().grants == 0)
	case("replacementDoesNotInheritAudience", permission(s.player).audience == "Closed")
	check(
		send(s.player, s.routes.socialPartySetInvitePolicy, { allowInvites = true })
			== "OK_PARTY_INVITE_POLICY"
	)
	g.task.wait(3.1)
	s.first = grant(s.peers[1], s.player)
	local replay = s.latestGrant
	local ownerOld = s.coordinator.get(s.peers[1].UserId)
	check(s.coordinator.close(s.peers[1].UserId, os.clock() + 5).status == "Closed")
	check(s.coordinator.open(s.peers[1].UserId).status == "Ready")
	case(
		"ownerSessionReplacementRevokesPermission",
		s.coordinator.get(s.peers[1].UserId) ~= ownerOld and #permission(s.player).incoming == 0
	)
	g.task.wait(3.1)
	case(
		"privateReplayFenceRejectsReplacementSuccess",
		s.network.gateway.handle(s.peers[1], replay).code == "REJECT_VALIDATION_REQUEST_REUSE"
	)
	check(
		send(s.peers[1], s.routes.socialPartySetInvitePolicy, { allowInvites = true })
			== "OK_PARTY_INVITE_POLICY"
	)
	policy(s.peers[1], "SameServer")
	return summary()
end
local function timerStart(): any
	g.task.wait(3.1)
	s.first = grant(s.peers[1], s.player)
	s.timerStarted = os.clock()
	return { grant = s.first, cases = s.cases, peakTimers = s.peak }
end
local function timerFinish(): any
	case(
		"nativeGrantExpiryClearsAllAuthority",
		os.clock() - s.timerStarted >= 60
			and s.social.showcase.counts().grants == 0
			and view().mode == "Closed"
	)
	case(
		"singleSharedDeadlineOwner",
		s.peak == 1 and size(s.timers) == 0 and s.social.showcase.nextDeadline() == nil
	)
	return summary()
end
local function disconnectStart(): any
	g.task.wait(3.1) -- Respect the same grant bucket when called immediately after setup.
	check(
		send(s.player, s.routes.socialPartySetInvitePolicy, { allowInvites = true })
			== "OK_PARTY_INVITE_POLICY"
	)
	s.first = grant(s.peers[1], s.player)
	check(
		s.social.showcase.open(s.player, s.peers[1].UserId, s.first.id) == "OK_SHOWCASE_READ_ONLY"
	)
	s.player:Kick("IMP-11 isolated Showcase lifecycle probe complete")
	return { kicked = true }
end
local function finish(): any
	local deadline = os.clock() + 6
	while
		os.clock() < deadline
		and (
			game:GetService("Players"):GetPlayerByUserId(s.player.UserId) ~= nil
			or s.social.showcase.counts().grants ~= 0
		)
	do
		g.task.wait(0.05)
	end
	case(
		"actualPlayerRemovingClearsVisitorAuthority",
		game:GetService("Players"):GetPlayerByUserId(s.player.UserId) == nil
			and s.social.showcase.counts().grants == 0
			and s.social.showcase.counts().visits == 0
	)
	s.network.stop()
	s.social.stop()
	for _, callback in s.callbacks do
		callback()
	end
	for _, n in s.social.showcase.counts() do
		check(n == 0)
	end
	case("shutdownAndLateCallbacksLeaveZeroAuthority", size(s.timers) == 0)
	check(#s.coordinator.shutdown(os.clock() + 10) == 0)
	return summary()
end
return {
	setup = setup,
	readback = readback,
	revoke = revoke,
	boundsAndRefresh = boundsAndRefresh,
	replacement = replacement,
	timerStart = timerStart,
	timerFinish = timerFinish,
	disconnectStart = disconnectStart,
	finish = finish,
}
