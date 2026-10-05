--!strict

local Party = require("../../src/server/domains/social/PartyService")
local Policy = require("../../src/shared/config/PartyPolicy")
local Contract = require("../../src/shared/contracts/PartyProjectionV1")
local Store = require("../../src/client/store/PartyProjectionStore")
local Wire = require("../../src/shared/contracts/WireValidation")
local Routes = require("../../src/shared/contracts/RouteIds")
local Protocol = require("../../src/shared/contracts/ProtocolV1")
local Codes = require("../../src/shared/contracts/ResultCodes")
local Registry = require("../../src/server/application/RouteRegistry")
local Rate = require("../../src/server/application/NetworkRateLimiter")
local Replay = require("../../src/server/application/ReplayWindow")
local Gateway = require("../../src/server/application/NetworkingGateway")
local Publisher = require("../../src/server/application/ProjectionPublisher")
local Projection = require("../../src/shared/contracts/ProjectionV1")
local ProfileSession = require("../../src/server/infrastructure/persistence/ProfileSession")
local Schema = require("../../src/server/infrastructure/persistence/ProfileSchemaV1")
local Queue = require("../../src/server/infrastructure/persistence/SingleWriterQueue")
local Retry = require("../../src/server/infrastructure/persistence/RetryPolicy")
local Repository = require("../fixtures/FakeProfileRepository")

local function check(value: any, message: string?): any
	return assert(value, message or "Social Ping invariant")
end
local function fixture()
	local at, sequence = 100, 0
	local f: any = { players = {}, contexts = {}, position = { x = 1, y = 4, z = 3 } }
	for userId = 1, 6 do
		local player = { UserId = userId }
		f.players[userId] = player
		f.contexts[userId] = { player = player, session = {}, ready = true, pingsMuted = false }
	end
	f.clock = function()
		return at
	end
	f.advance = function(seconds: number)
		at += seconds
	end
	f.owner = Party.new({
		policy = Policy,
		pingContract = Contract,
		context = function(userId)
			return f.contexts[userId]
		end,
		monotonicSeconds = f.clock,
		presentationSeconds = f.clock,
		newId = function()
			sequence += 1
			return string.format("%048d", sequence)
		end,
		waypoint = function(_player, _session)
			return f.position
		end,
		updatePingPreference = function(player, expectedSession, muted)
			if f.preferenceStatus then
				return f.preferenceStatus
			end
			local c = f.contexts[player.UserId]
			if c.session ~= expectedSession then
				return "Stale"
			end
			c.pingsMuted = muted
			return "Buffered"
		end,
	})
	check(f.owner.create(f.players[1]) == "OK_PARTY_CREATED")
	f.view = function(userId)
		return f.owner.snapshot(f.players[userId])
	end
	f.party = function()
		return f.view(1).state.party
	end
	f.join = function(userId)
		f.advance(3)
		f.owner.setInvitePolicy(f.players[userId], true)
		check(f.owner.invite(f.players[1], userId, f.party().revision) == "OK_PARTY_INVITED")
		local i = f.view(userId).state.incoming[1]
		check(
			f.owner.respond(f.players[userId], i.invitationId, true, i.partyRevision)
				== "OK_PARTY_JOINED"
		)
	end
	f.ping = function(userId)
		local p = f.view(userId).state.party
		return f.owner.ping(f.players[userId], p.partyId, "ComeHere", p.revision)
	end
	return f
end
local function network(f: any): any
	local originalParty = f.party()
	local schemas = {
		[Routes.commands.socialPing] = Contract.validPing,
		[Routes.commands.settingsUpdatePreferences] = Contract.validPingPreference,
	}
	local function emit(player: any, envelope: any)
		f.events = f.events or {}
		table.insert(f.events, { userId = player.UserId, envelope = envelope })
	end
	local handlers: { [string]: any } = {
		[Routes.commands.socialPing] = function(player, e)
			local code =
				f.owner.ping(player, e.payload.partyId, e.payload.pingKind, e.expectedRevision)
			for _, userId in f.owner.takeChanges() do
				emit(f.players[userId], f.view(userId))
			end
			return code
		end,
		[Routes.commands.settingsUpdatePreferences] = function(player, e)
			return f.owner.setPingPreference(player, e.payload.socialPingsMuted)
		end,
	}
	local gateway = Gateway.new({
		protocol = Protocol,
		routes = Routes,
		resultCodes = Codes,
		wire = Wire,
		registry = Registry.new(Routes, schemas),
		rate = Rate.new(f.clock),
		replay = Replay.new(f.clock, Wire),
		projection = Publisher.new({
			protocol = Protocol,
			routes = Routes,
			projection = Projection,
			wire = Wire,
			emit = emit,
		}),
		getSession = function(player)
			local c = f.contexts[player.UserId]
			return if c and c.ready
				then { status = "Ready", identity = c.session, profileRevision = 1 }
				else { status = "Protected" }
		end,
		emitReliable = emit,
		emitUnreliable = emit,
		routeHandlers = handlers,
	})
	f.owner.takeChanges()
	return function(userId: number, requestId: string, payload: any?, expected: number?): any
		local p = f.party() or originalParty
		return gateway.handle(f.players[userId], {
			protocolVersion = 1,
			routeId = Routes.commands.socialPing,
			requestId = requestId,
			payload = payload or { partyId = p.partyId, pingKind = "ComeHere" },
			expectedRevision = expected or p.revision,
		}).code
	end
end

local function currentMembersAndDisclosure()
	local f = fixture()
	f.join(2)
	f.join(3)
	local revision = f.party().revision
	check(f.ping(2) == "OK_SOCIAL_PING")
	for _, id in { 1, 2, 3 } do
		local snapshot = f.view(id)
		local ping = snapshot.state.pings[1]
		check(
			ping.senderUserId == 2 and ping.kind == "ComeHere" and ping.expiresAt == f.clock() + 6
		)
		check(Wire.equal(ping.position, f.position) and snapshot.state.party.revision == revision)
		check(Contract.validSnapshot(snapshot) and Wire.payload(snapshot))
	end
	check(#f.view(4).state.pings == 0 and f.view(4).state.party == nil)
end
local function nonMemberAndForgedContext()
	local f = fixture()
	check(
		f.owner.ping(f.players[2], f.party().partyId, "ComeHere", 1)
			== "REJECT_STATE_PARTY_REVISION"
	)
	check(f.owner.ping(f.players[1], "foreign", "ComeHere", 1) == "REJECT_STATE_PARTY_REVISION")
	check(
		f.owner.ping(f.players[1], f.party().partyId, "ComeHere", 999)
			== "REJECT_STATE_PARTY_REVISION"
	)
	check(f.owner.counts().pings == 0)
end
local function exactPredefinedIntentSchemas()
	local valid = { partyId = "party", pingKind = "ComeHere" }
	check(Contract.validPing(valid, 1))
	local bad: { any } = {
		{ partyId = "party", pingKind = "CreatureHere" },
		{ partyId = "party", pingKind = "Danger" },
		{ partyId = "party", pingKind = "" },
		{ partyId = "party", pingKind = {} },
		{ partyId = "party", pingKind = "ComeHere", targetId = "secret" },
		{ partyId = "party", pingKind = "ComeHere", recipients = { 2 } },
		{ partyId = "party", pingKind = "ComeHere", senderUserId = 2 },
		{ partyId = "party", pingKind = "ComeHere", bypassMute = true },
		{ partyId = "party", pingKind = "ComeHere", text = "custom text" },
	}
	for _, payload in bad do
		check(not Contract.validPing(payload, 1))
	end
	check(not Contract.validPing(valid, nil) and not Contract.validPing(valid, 0 / 0))
	check(
		not Contract.validPingPreference({ socialPingsMuted = false, reducedMotion = false }, nil)
	)
end
local function malformedWaypointAndClientInjection()
	local f = fixture()
	local send = network(f)
	local bad: { any } = {
		{ x = 0 / 0, y = 0, z = 0 },
		{ x = math.huge, y = 0, z = 0 },
		{ x = 100001, y = 0, z = 0 },
		{ x = 0, y = -math.huge, z = 0 },
		{ x = 0, y = 0 },
		{ 0, 0, 0 },
		{ x = "1", y = 0, z = 0 },
		{ x = 0, y = 0, z = 0, owner = 2 },
	}
	for i, point in bad do
		check(not Contract.validWaypoint(point))
		f.position = point
		check(f.ping(1) == "REJECT_STATE_PING_WAYPOINT")
		f.advance(3)
		check(
			send(
				1,
				"bad-" .. i,
				{ partyId = f.party().partyId, pingKind = "ComeHere", position = point }
			) == "REJECT_VALIDATION_PAYLOAD"
		)
	end
	f.position = { x = 1, y = 4, z = 3 }
	check(f.ping(1) == "OK_SOCIAL_PING")
end
local function boundedSlotsAndFanout()
	local f = fixture()
	f.join(2)
	f.join(3)
	f.join(4)
	check(f.ping(1) == "OK_SOCIAL_PING" and f.ping(2) == "OK_SOCIAL_PING")
	check(f.ping(3) == "REJECT_STATE_PING_BOUNDS")
	for _, id in { 1, 2, 3, 4 } do
		local projection = f.view(id)
		check(#projection.state.pings == 2 and Wire.payload(projection))
	end
	check(f.owner.counts().pings == 2)
end
local function repeatedSameSenderReplacesBoundedSlot()
	local f = fixture()
	for _ = 1, 1000 do
		check(f.ping(1) == "OK_SOCIAL_PING")
	end
	check(f.owner.counts().pings == 1 and #f.view(1).state.pings == 1)
end
local function routeRateLimitAndIndependentSenders()
	local f = fixture()
	f.join(2)
	local send = network(f)
	check(send(1, "first") == "OK_SOCIAL_PING")
	check(send(1, "spam") == "REJECT_RATE_LIMIT")
	check(send(2, "peer") == "OK_SOCIAL_PING")
	f.advance(2.999)
	check(send(1, "early") == "REJECT_RATE_LIMIT")
	f.advance(0.001)
	check(send(1, "later") == "OK_SOCIAL_PING")
	check(f.owner.counts().pings == 2)
end
local function replayDoesNotMultiplyDelivery()
	local f = fixture()
	f.join(2)
	local send = network(f)
	check(send(1, "original") == "OK_SOCIAL_PING")
	local before = f.view(2)
	f.advance(3)
	check(send(1, "original") == "OK_SOCIAL_PING")
	check(Wire.equal(before, f.view(2)) and f.owner.counts().pings == 1)
end
local function hostileGatewayPayloads()
	local f = fixture()
	local send = network(f)
	local bad: { any } = {
		{ partyId = f.party().partyId, pingKind = "ComeHere", text = string.rep("x", 4097) },
		{ partyId = f.party().partyId, pingKind = "ComeHere", recipients = { 2 } },
		{ partyId = f.party().partyId, pingKind = "ComeHere", sessionIdentity = {} },
		{ partyId = f.party().partyId, pingKind = "LookHere" },
	}
	for i, payload in bad do
		f.advance(3)
		check(send(1, "hostile-" .. i, payload) == "REJECT_VALIDATION_PAYLOAD")
	end
	check(f.owner.counts().pings == 0)
end
local function muteOnlyChangesRecipientPresentation()
	local f = fixture()
	f.join(2)
	local revision = f.party().revision
	check(f.owner.setPingPreference(f.players[2], true) == "OK_PREFERENCES_BUFFERED")
	check(f.ping(1) == "OK_SOCIAL_PING")
	check(#f.view(2).state.pings == 0 and f.view(2).state.pingsMuted)
	check(
		#f.view(1).state.pings == 1 and f.party().revision == revision and #f.party().members == 2
	)
	check(f.owner.setPingPreference(f.players[2], false) == "OK_PREFERENCES_BUFFERED")
	check(#f.view(2).state.pings == 1)
end
local function muteRevokesAlreadyVisiblePing()
	local f = fixture()
	f.join(2)
	f.ping(1)
	local before = f.view(2)
	f.owner.setPingPreference(f.players[2], true)
	local after = f.view(2)
	check(after.revision > before.revision and #after.state.pings == 0)
end
local function removedMemberAndDissolutionInvalidate()
	local f = fixture()
	f.join(2)
	f.join(3)
	f.ping(2)
	local p = f.party()
	check(f.owner.remove(f.players[1], p.partyId, 2, p.revision) == "OK_PARTY_REMOVED")
	check(#f.view(2).state.pings == 0 and f.view(2).state.party == nil)
	check(#f.view(3).state.pings == 0 and f.owner.counts().pings == 0)
	f.ping(1)
	p = f.party()
	check(f.owner.disband(f.players[1], p.partyId, p.revision) == "OK_PARTY_DISBANDED")
	check(f.owner.counts().pings == 0 and f.view(3).state.party == nil)
end
local function senderReplacementCannotReuseAuthority()
	local f = fixture()
	f.join(2)
	f.ping(1)
	local send = network(f)
	f.contexts[1].session = {}
	check(send(1, "replaced") == "REJECT_STATE_PARTY_REVISION")
	check(f.view(1).state.party == nil and #f.view(2).state.pings == 0)
end
local function recipientReplacementCannotInheritDelivery()
	local f = fixture()
	f.join(2)
	f.ping(1)
	f.contexts[2].session = {}
	check(f.view(2).state.party == nil and #f.view(2).state.pings == 0)
	check(f.owner.counts().pings == 0 and #f.party().members == 1)
end
local function disconnectReservationAndExplicitRejoin()
	local f = fixture()
	f.join(2)
	f.owner.setPingPreference(f.players[2], true)
	f.ping(1)
	local oldPlayer, oldSession = f.players[2], f.contexts[2].session
	check(f.owner.disconnect(oldPlayer, oldSession, true))
	f.contexts[2] = nil
	f.ping(1)
	check(f.owner.snapshot(oldPlayer) == nil)
	f.players[2] = { UserId = 2 }
	f.contexts[2] = { player = f.players[2], session = {}, ready = true, pingsMuted = true }
	local r = f.view(2).state.rejoin
	check(#f.view(2).state.pings == 0 and f.view(2).state.party == nil)
	check(
		f.owner.ping(f.players[2], r.partyId, "ComeHere", r.revision)
			== "REJECT_STATE_PARTY_REVISION"
	)
	check(f.owner.rejoin(f.players[2], r.partyId, r.revision) == "OK_PARTY_REJOINED")
	check(f.view(2).state.pingsMuted and #f.view(2).state.pings == 0)
	check(not f.owner.disconnect(oldPlayer, oldSession, false))
end
local function observationCannotAdmitChangedSession()
	local f = fixture()
	local owner = Party.new({
		policy = Policy,
		pingContract = Contract,
		context = function(id)
			return f.contexts[id]
		end,
		monotonicSeconds = f.clock,
		newId = function()
			return "observed-party"
		end,
		waypoint = function()
			f.contexts[1].session = {}
			return f.position
		end,
	})
	check(owner.create(f.players[1]) == "OK_PARTY_CREATED")
	check(
		owner.ping(f.players[1], "observed-party", "ComeHere", 1) == "REJECT_STATE_PARTY_REVISION"
	)
	check(owner.counts().pings == 0)
end
local function simultaneousPingsHaveBoundedAdmission()
	local f = fixture()
	f.join(2)
	f.join(3)
	f.join(4)
	local won = 0
	for id = 1, 4 do
		local thread = coroutine.create(function()
			if f.ping(id) == "OK_SOCIAL_PING" then
				won += 1
			end
		end)
		check(coroutine.resume(thread))
		check(coroutine.status(thread) == "dead", "Ping admission yielded")
	end
	check(won == 2 and f.owner.counts().pings == 2)
end
local function expiryAndShutdownClearAllPingState()
	local f = fixture()
	f.join(2)
	f.ping(1)
	local revision, viewRevision = f.party().revision, f.view(2).revision
	check(f.owner.nextDeadline() == f.clock() + 6)
	f.advance(6)
	f.owner.expire()
	check(f.owner.nextDeadline() == nil and f.owner.counts().pings == 0)
	check(f.party().revision == revision and f.view(2).revision > viewRevision)
	f.ping(1)
	f.owner.stop()
	f.owner.expire()
	check(f.owner.counts().pings == 0 and f.owner.nextDeadline() == nil)
end
local function clientExpiryCannotResurrectStaleDisplay()
	local f = fixture()
	f.ping(1)
	local snapshot = f.view(1)
	local store = Store.new(Contract, Wire, f.clock)
	check(store.snapshot(snapshot) == "Party" and store.nextDeadline() == f.clock() + 6)
	f.advance(6)
	check(#store.view().state.pings == 0 and store.nextDeadline() == nil)
	f.advance(-3)
	check(#store.view().state.pings == 0 and store.snapshot(snapshot) == "Stale")
end
local function strictBoundedProjection()
	local f = fixture()
	f.ping(1)
	local good = f.view(1)
	local mutations = {
		function(p: any)
			p.state.pings[1].senderUserId = 5
		end,
		function(p: any)
			p.state.pingsMuted = true
		end,
		function(p: any)
			p.state.pings[1].position.x = math.huge
		end,
		function(p: any)
			p.state.pings[1].kind = "CreatureHere"
		end,
		function(p: any)
			p.state.pings[1].text = "free text"
		end,
		function(p: any)
			p.state.party = nil
		end,
		function(p: any)
			p.state.pings[2] = Wire.copy(p.state.pings[1])
		end,
	}
	for _, mutate in mutations do
		local payload = Wire.copy(good)
		mutate(payload)
		check(not Contract.validSnapshot(payload))
	end
end
local function unavailableAndOldPlayerFailClosed()
	local f = fixture()
	f.join(2)
	local p = f.party()
	f.contexts[1].ready = false
	check(f.owner.ping(f.players[1], p.partyId, "ComeHere", 2) == "REJECT_STATE_PARTY_SESSION")
	check(f.owner.counts().pings == 0)
end

local function persistenceFixture()
	local at = 0
	local repo = Repository.new()
	local function clock()
		return at
	end
	local function wait(seconds: number)
		at += seconds
	end
	local function session()
		local owner = ProfileSession.new({
			userId = 1,
			lockId = "ping-lock-" .. repo.calls(),
			jobId = "ping-test",
			repository = repo,
			schema = Schema,
			queue = Queue.new(clock, wait, 5),
			retry = Retry.new(clock, wait, function()
				return 0.5
			end, 3),
			unixSeconds = function()
				return 1000 + math.floor(at)
			end,
			monotonicSeconds = clock,
		})
		check(owner.acquire().status == "Ready")
		return owner
	end
	return repo, session, clock
end
local function preferenceUsesExistingP1AndSurvivesReload()
	local repo, acquire, clock = persistenceFixture()
	local session = acquire()
	local initial = session.snapshot()
	check(session.bufferSettings(function(settings)
		settings.socialPingsMuted = false
	end).status == "Buffered")
	check(repo.calls() == 1 and session.snapshot().profileRevision == initial.profileRevision)
	local buffered = session.snapshot()
	buffered.settings = initial.settings
	check(Wire.equal(initial, buffered), "Preference altered personal value")
	check(session.release(clock() + 5).status == "Closed")
	local replacement = acquire()
	check(replacement.snapshot().settings.socialPingsMuted == false)
	check(replacement.bufferSettings(function(settings)
		settings.socialPingsMuted = true
	end).status == "Buffered")
	check(replacement.release(clock() + 5).status == "Closed")
	check(acquire().snapshot().settings.socialPingsMuted == true)
end
local function pingsDoNotMutateProfileAndMalformedPreferenceIsSafe()
	local repo, acquire = persistenceFixture()
	local session = acquire()
	local f = fixture()
	f.contexts[1] = { player = f.players[1], session = session, ready = true }
	check(f.view(1).state.pingsMuted)
	check(f.owner.create(f.players[1]) == "OK_PARTY_CREATED")
	local before = session.snapshot()
	check(f.ping(1) == "OK_SOCIAL_PING")
	check(Wire.equal(before, session.snapshot()) and repo.calls() == 1)
	check(session.bufferSettings(function(settings)
		settings.socialPingsMuted = "invalid"
	end).status == "Buffered")
	f.contexts[1].pingsMuted = session.snapshot().settings.socialPingsMuted ~= false
	check(f.view(1).state.pingsMuted and #f.view(1).state.pings == 0)
end

local function replacementSessionCannotReplayPing()
	local f = fixture()
	f.join(2)
	local send = network(f)
	check(send(1, "cached-ping") == "OK_SOCIAL_PING")
	f.contexts[1].session = {}
	f.advance(3)
	check(send(1, "cached-ping") == "REJECT_VALIDATION_REQUEST_REUSE")
	check(#f.view(2).state.pings == 0)
end
local function leaveBeforeReadbackAndStaleRevision()
	local f = fixture()
	f.join(2)
	f.ping(1)
	local p = f.party()
	check(f.owner.leave(f.players[2], p.partyId, p.revision) == "OK_PARTY_LEFT")
	check(f.view(2).state.party == nil and #f.view(2).state.pings == 0)
	check(
		f.owner.ping(f.players[1], p.partyId, "ComeHere", p.revision)
			== "REJECT_STATE_PARTY_REVISION"
	)
end
local function unavailablePreferenceWriterDoesNotAcknowledgeChange()
	local f = fixture()
	f.preferenceStatus = "Busy"
	check(f.owner.setPingPreference(f.players[1], true) == "UNAVAILABLE_PREFERENCES")
	check(not f.view(1).state.pingsMuted and f.party().revision == 1)
end
return {
	replacementSessionCannotReplayPing = replacementSessionCannotReplayPing,
	leaveBeforeReadbackAndStaleRevision = leaveBeforeReadbackAndStaleRevision,
	unavailablePreferenceWriterDoesNotAcknowledgeChange = unavailablePreferenceWriterDoesNotAcknowledgeChange,
	currentMembersAndDisclosure = currentMembersAndDisclosure,
	nonMemberAndForgedContext = nonMemberAndForgedContext,
	exactPredefinedIntentSchemas = exactPredefinedIntentSchemas,
	malformedWaypointAndClientInjection = malformedWaypointAndClientInjection,
	boundedSlotsAndFanout = boundedSlotsAndFanout,
	repeatedSameSenderReplacesBoundedSlot = repeatedSameSenderReplacesBoundedSlot,
	routeRateLimitAndIndependentSenders = routeRateLimitAndIndependentSenders,
	replayDoesNotMultiplyDelivery = replayDoesNotMultiplyDelivery,
	hostileGatewayPayloads = hostileGatewayPayloads,
	muteOnlyChangesRecipientPresentation = muteOnlyChangesRecipientPresentation,
	muteRevokesAlreadyVisiblePing = muteRevokesAlreadyVisiblePing,
	removedMemberAndDissolutionInvalidate = removedMemberAndDissolutionInvalidate,
	senderReplacementCannotReuseAuthority = senderReplacementCannotReuseAuthority,
	recipientReplacementCannotInheritDelivery = recipientReplacementCannotInheritDelivery,
	disconnectReservationAndExplicitRejoin = disconnectReservationAndExplicitRejoin,
	observationCannotAdmitChangedSession = observationCannotAdmitChangedSession,
	simultaneousPingsHaveBoundedAdmission = simultaneousPingsHaveBoundedAdmission,
	expiryAndShutdownClearAllPingState = expiryAndShutdownClearAllPingState,
	clientExpiryCannotResurrectStaleDisplay = clientExpiryCannotResurrectStaleDisplay,
	strictBoundedProjection = strictBoundedProjection,
	unavailableAndOldPlayerFailClosed = unavailableAndOldPlayerFailClosed,
	preferenceUsesExistingP1AndSurvivesReload = preferenceUsesExistingP1AndSurvivesReload,
	pingsDoNotMutateProfileAndMalformedPreferenceIsSafe = pingsDoNotMutateProfileAndMalformedPreferenceIsSafe,
}
