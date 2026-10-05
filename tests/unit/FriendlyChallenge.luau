--!strict

local Party = require("../../src/server/domains/social/PartyService")
local Policy = require("../../src/shared/config/PartyPolicy")
local Definition = require("../../src/shared/config/FriendlyChallengeDefinition")
local Contract = require("../../src/shared/contracts/PartyProjectionV1")
local Wire = require("../../src/shared/contracts/WireValidation")
local Store = require("../../src/client/store/PartyProjectionStore")
local Session = require("../../src/server/infrastructure/persistence/ProfileSession")
local Schema = require("../../src/server/infrastructure/persistence/ProfileSchemaV1")
local Queue = require("../../src/server/infrastructure/persistence/SingleWriterQueue")
local Retry = require("../../src/server/infrastructure/persistence/RetryPolicy")
local Repository = require("../fixtures/FakeProfileRepository")
local Travel = require("../../src/server/domains/world/WorldTravelService")
local Routes = require("../../src/shared/contracts/RouteIds")
local Registry = require("../../src/server/application/RouteRegistry")
local Rate = require("../../src/server/application/NetworkRateLimiter")
local Replay = require("../../src/server/application/ReplayWindow")
local Gateway = require("../../src/server/application/NetworkingGateway")
local Protocol = require("../../src/shared/contracts/ProtocolV1")
local Codes = require("../../src/shared/contracts/ResultCodes")
local Projection = require("../../src/shared/contracts/ProjectionV1")
local Publisher = require("../../src/server/application/ProjectionPublisher")
local function check(value: any, why: string?): any
	return assert(value, why or "Friendly Challenge invariant")
end

local function fixture(optIn: boolean?): any
	local at, guid, locks = 100, 0, 0
	local f: any = {
		players = {},
		sessions = {},
		caps = {},
		eligible = {},
		present = {},
		repository = Repository.new(),
	}
	f.clock = function()
		return at
	end
	f.advance = function(seconds: number)
		at += seconds
	end
	f.acquire = function(id: number)
		locks += 1
		local session = Session.new({
			userId = id,
			lockId = "challenge-lock-" .. locks,
			jobId = "challenge-test",
			repository = f.repository,
			schema = Schema,
			queue = Queue.new(f.clock, f.advance, 5),
			retry = Retry.new(f.clock, f.advance, function()
				return 0.5
			end, 3),
			unixSeconds = function()
				return 1000 + math.floor(at)
			end,
			monotonicSeconds = f.clock,
		})
		check(session.acquire().status == "Ready")
		f.sessions[id] = session
		return session
	end
	for id = 1, 6 do
		f.players[id], f.caps[id] = { UserId = id }, { character = {}, generation = 1 }
		f.eligible[id], f.present[id] = true, true
		f.acquire(id)
	end
	f.options = {
		policy = table.clone(Policy),
		challengeDefinition = Definition,
		challengeContract = Contract,
		projectionFits = Wire.payload,
		context = function(id)
			return if f.present[id]
				then {
					player = f.players[id],
					session = f.sessions[id],
					ready = f.sessions[id].state() == "Ready",
					pingsMuted = true,
				}
				else nil
		end,
		monotonicSeconds = f.clock,
		presentationSeconds = f.clock,
		newId = function()
			guid += 1
			return string.format("%048d", guid)
		end,
		challengeCapability = function(player, session, atStart)
			if f.observe then
				f.observe(player.UserId)
			end
			return if session == f.sessions[player.UserId]
					and f.present[player.UserId]
					and (not atStart or f.eligible[player.UserId])
				then f.caps[player.UserId]
				else nil
		end,
	}
	f.owner = Party.new(f.options)
	f.view = function(id)
		return f.owner.snapshot(f.players[id])
	end
	f.challenge = function(id)
		return f.view(id or 1).state.challenge
	end
	f.offer = function(from: number?, to: number?)
		local d = f.options.challengeDefinition
		return f.owner.challengeRequest(f.players[from or 1], to or 2, d.id, d.version)
	end
	f.respond = function(id: number, accept: boolean, expected: number?)
		local c = f.challenge(id)
		return f.owner.challengeRespond(f.players[id], c.id, accept, expected or c.revision)
	end
	f.active = function()
		check(f.offer() == "OK_CHALLENGE_OFFERED")
		check(f.respond(2, true) == "OK_CHALLENGE_ACTIVE")
	end
	f.begin = function(id: number, recovery: boolean?, targetId: string?)
		return f.owner.beginChallengeTravel(f.players[id], {
			session = f.sessions[id],
			character = f.caps[id].character,
			generation = f.caps[id].generation,
			nodeId = Definition.sourceNodeId,
		}, { nodeId = targetId or Definition.targetNodeId }, recovery == true)
	end
	f.replace = function(id: number)
		check(f.sessions[id].release(at + 5).status == "Closed")
		f.acquire(id)
	end
	if optIn ~= false then
		for id = 1, 6 do
			check(f.owner.setInvitePolicy(f.players[id], true) == "OK_PARTY_INVITE_POLICY")
		end
	end
	return f
end

local function network(f: any): any
	local schemas = {
		[Routes.commands.socialChallengeRequest] = Contract.validChallengeRequest,
		[Routes.commands.socialChallengeRespond] = Contract.validChallengeRespond,
		[Routes.commands.socialChallengeCancel] = Contract.validChallengeCancel,
	}
	f.events = {}
	local function emit(player: any, e: any)
		table.insert(f.events, { userId = player.UserId, event = e })
	end
	local operations = {
		[Routes.commands.socialChallengeRequest] = function(player: any, e: any)
			return f.owner.challengeRequest(
				player,
				e.payload.targetUserId,
				e.payload.definitionId,
				e.payload.definitionVersion
			)
		end,
		[Routes.commands.socialChallengeRespond] = function(player: any, e: any)
			return f.owner.challengeRespond(
				player,
				e.payload.challengeId,
				e.payload.accept,
				e.expectedRevision
			)
		end,
		[Routes.commands.socialChallengeCancel] = function(player: any, e: any)
			return f.owner.challengeCancel(player, e.payload.challengeId, e.expectedRevision)
		end,
	}
	local handlers = {}
	for route, operation in operations do
		handlers[route] = function(player: any, e: any)
			local result = operation(player, e)
			for _, id in f.owner.takeChanges() do
				local snapshot = f.view(id)
				check(Contract.validSnapshot(snapshot) and Wire.payload(snapshot))
				emit(f.players[id], snapshot)
			end
			return result
		end
	end
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
			return if f.present[player.UserId]
					and f.sessions[player.UserId].state() == "Ready"
					and f.players[player.UserId] == player
				then { status = "Ready", identity = f.sessions[player.UserId], profileRevision = 1 }
				else { status = "Protected" }
		end,
		emitReliable = emit,
		emitUnreliable = emit,
		routeHandlers = handlers,
	})
	f.owner.takeChanges()
	return function(
		id: number,
		route: string,
		requestId: string,
		payload: any,
		expected: number?
	): string
		return gateway.handle(f.players[id], {
			protocolVersion = 1,
			routeId = route,
			requestId = requestId,
			payload = payload,
			expectedRevision = expected,
		}).code
	end
end
local function requestPayload(target: number?): any
	return {
		targetUserId = target or 2,
		definitionId = Definition.id,
		definitionVersion = Definition.version,
	}
end

local function offeredIsVisibleAndNonBinding()
	local f = fixture()
	check(f.offer() == "OK_CHALLENGE_OFFERED")
	for _, id in { 1, 2 } do
		local c = f.challenge(id)
		check(c.phase == "Offered")
		check(c.definitionId == Definition.id and c.definitionVersion == Definition.version)
		check(c.fromUserId == 1 and c.toUserId == 2 and c.expiresAt == 120)
		check(Contract.validSnapshot(f.view(id)) and Wire.payload(f.view(id)))
	end
	check(f.begin(1) == nil and f.challenge(1).phase == "Offered")
	check(
		f.view(1).state.party == nil and f.challenge(3) == nil,
		"Party/proximity enrolled participant"
	)
end
local function intendedLiveInviteeOnly()
	local f = fixture()
	f.offer()
	local c = f.challenge(1)
	check(f.owner.challengeRespond(f.players[1], c.id, true, 1) == "REJECT_STATE_CHALLENGE_PHASE")
	check(
		f.owner.challengeRespond(f.players[3], c.id, true, 1) == "REJECT_STATE_CHALLENGE_REVISION"
	)
	check(f.owner.challengeRespond({ UserId = 2 }, c.id, true, 1) == "REJECT_STATE_PARTY_SESSION")
	check(f.challenge(2).phase == "Offered")
end
local function explicitAcceptAndDuplicate()
	local f = fixture()
	f.offer()
	f.advance(2)
	check(f.respond(2, true) == "OK_CHALLENGE_ACTIVE")
	local c = f.challenge(2)
	check(c.phase == "Active" and c.revision == 2 and c.expiresAt == 132)
	check(f.respond(2, true, 1) == "REJECT_STATE_CHALLENGE_REVISION")
	check(f.respond(2, true, 2) == "REJECT_STATE_CHALLENGE_PHASE")
	check(Wire.equal(c, f.challenge(2)), "duplicate restarted challenge")
end
local function declineAndIgnoreHaveNoPenalty()
	local f = fixture()
	local before, calls = f.sessions[2].snapshot(), f.repository.calls()
	f.offer()
	check(f.respond(2, false) == "OK_CHALLENGE_DECLINED")
	check(f.challenge(2).phase == "Declined" and f.begin(1) == nil)
	check(Wire.equal(before, f.sessions[2].snapshot()) and f.repository.calls() == calls)
	f.advance(6)
	check(f.challenge(1) == nil and f.owner.counts().challengeParticipants == 0)
	f.offer()
	f.advance(20)
	check(f.challenge(1).phase == "Expired" and f.challenge(1).reason == "Ignored")
	check(Wire.equal(before, f.sessions[2].snapshot()) and f.repository.calls() == calls)
end
local function expiryAndAcceptBoundary()
	local f = fixture()
	f.offer()
	local id = f.challenge(2).id
	f.advance(20)
	check(f.owner.challengeRespond(f.players[2], id, true, 1) == "REJECT_STATE_CHALLENGE_REVISION")
	check(f.challenge(2).phase == "Expired")
	local g = fixture()
	g.offer()
	g.advance(19.999)
	check(g.respond(2, true) == "OK_CHALLENGE_ACTIVE")
	g.advance(30)
	check(g.challenge(1).phase == "Expired" and g.challenge(1).reason == "TimedOut")
end
local function pendingActiveAndGlobalBounds()
	local f = fixture()
	f.options.policy.maxChallenges = 2
	check(f.offer(1, 2) == "OK_CHALLENGE_OFFERED")
	check(f.offer(3, 2) == "REJECT_STATE_CHALLENGE_BUSY")
	check(f.offer(2, 4) == "REJECT_STATE_CHALLENGE_BUSY")
	f.respond(2, true)
	check(f.offer(1, 3) == "REJECT_STATE_CHALLENGE_BUSY")
	check(f.offer(3, 4) == "OK_CHALLENGE_OFFERED")
	check(f.offer(5, 6) == "REJECT_STATE_CHALLENGE_BOUNDS")
	check(f.owner.counts().challenges == 2 and f.owner.counts().challengeParticipants == 4)
end
local function simultaneousOfferAndAccept()
	local f = fixture()
	local won = 0
	for _, pair in { { 1, 2 }, { 3, 2 } } do
		local thread = coroutine.create(function()
			if f.offer(pair[1], pair[2]) == "OK_CHALLENGE_OFFERED" then
				won += 1
			end
		end)
		check(coroutine.resume(thread) and coroutine.status(thread) == "dead", "offer yielded")
	end
	check(won == 1)
	local started = 0
	for _ = 1, 2 do
		local c = f.challenge(2)
		local thread = coroutine.create(function()
			if f.owner.challengeRespond(f.players[2], c.id, true, 1) == "OK_CHALLENGE_ACTIVE" then
				started += 1
			end
		end)
		check(coroutine.resume(thread) and coroutine.status(thread) == "dead", "accept yielded")
	end
	check(started == 1 and f.challenge(1).revision == 2)
end
local function capabilityLimitAndRecheck()
	local f = fixture()
	f.eligible[2] = false
	check(f.offer() == "REJECT_STATE_CHALLENGE_CAPABILITY")
	f.eligible[2] = true
	f.offer()
	f.eligible[1] = false
	check(f.respond(2, true) == "REJECT_STATE_CHALLENGE_CAPABILITY")
	check(f.challenge(2).phase == "Cancelled")
	local g = fixture()
	g.caps[2].generation = math.huge
	check(g.offer() == "REJECT_STATE_CHALLENGE_CAPABILITY")
end
local function definitionPinnedAndRenewedConsent()
	local f = fixture()
	check(
		f.owner.challengeRequest(f.players[1], 2, "forged", 1)
			== "REJECT_STATE_CHALLENGE_DEFINITION"
	)
	check(
		f.owner.challengeRequest(f.players[1], 2, Definition.id, 999)
			== "REJECT_STATE_CHALLENGE_DEFINITION"
	)
	f.offer()
	local revised = table.clone(Definition)
	revised.version = 2
	f.options.challengeDefinition = revised
	check(f.respond(2, true, 1) == "REJECT_STATE_CHALLENGE_REVISION")
	check(f.challenge(2).phase == "Cancelled" and f.challenge(2).reason == "DefinitionChanged")
	f.advance(6)
	check(f.offer() == "OK_CHALLENGE_OFFERED" and f.challenge(2).definitionVersion == 2)
	check(f.respond(2, true) == "OK_CHALLENGE_ACTIVE")
end
local function suppressionAndRevocation()
	local f = fixture(false)
	check(f.offer() == "REJECT_STATE_CHALLENGE_TARGET")
	f.owner.setInvitePolicy(f.players[2], true)
	f.offer()
	f.owner.setInvitePolicy(f.players[2], false)
	check(f.challenge(1).phase == "Cancelled" and f.challenge(1).reason == "AudienceRestricted")
	local g = fixture()
	g.active()
	g.owner.setInvitePolicy(g.players[2], false)
	check(g.challenge(2).phase == "Active", "audience preference rewrote completed consent")
	check(g.owner.challengeCancel(g.players[2], g.challenge(2).id, 2) == "OK_CHALLENGE_CANCELLED")
end
local function invalidSelfAndUnavailableTarget()
	local f = fixture()
	check(f.offer(1, 1) == "REJECT_STATE_CHALLENGE_TARGET")
	check(f.offer(1, 999) == "REJECT_STATE_CHALLENGE_TARGET")
	f.present[2] = false
	check(f.offer() == "REJECT_STATE_CHALLENGE_TARGET")
	check(f.owner.counts().challenges == 0)
end
local function partyChangesAreIndependent()
	local f = fixture()
	f.active()
	local challengeId = f.challenge(1).id
	check(f.owner.create(f.players[1]) == "OK_PARTY_CREATED")
	f.advance(3)
	local p = f.view(1).state.party
	check(f.owner.invite(f.players[1], 2, p.revision) == "OK_PARTY_INVITED")
	local i = f.view(2).state.incoming[1]
	check(f.owner.respond(f.players[2], i.invitationId, true, i.partyRevision) == "OK_PARTY_JOINED")
	p = f.view(1).state.party
	f.owner.remove(f.players[1], p.partyId, 2, p.revision)
	check(f.challenge(2).phase == "Active" and f.challenge(2).id == challengeId)
end
local function serverObservedFinishAndFreeze()
	local f = fixture()
	f.active()
	local first, second = f.begin(1), f.begin(2)
	f.advance(1.25)
	f.owner.completeChallengeTravel(first)
	local c = f.challenge(1)
	check(c.phase == "Resolved" and c.winnerUserId == 1 and c.elapsedMs == 1250 and c.revision == 3)
	f.owner.completeChallengeTravel(first)
	f.owner.completeChallengeTravel(second)
	check(Wire.equal(c, f.challenge(1)))
	check(f.owner.challengeCancel(f.players[2], c.id, 3) == "REJECT_STATE_CHALLENGE_PHASE")
end
local function sameTimeFinishesUseAdmissionOrder()
	local f = fixture()
	f.active()
	local first, second = f.begin(1), f.begin(2)
	f.owner.completeChallengeTravel(second)
	f.owner.completeChallengeTravel(first)
	check(f.challenge(1).winnerUserId == 2 and f.challenge(1).elapsedMs == 0)
end
local function cancellationAndStaleGeneration()
	local f = fixture()
	f.active()
	local old = f.begin(1)
	check(f.owner.challengeCancel(f.players[1], f.challenge(1).id, 2) == "OK_CHALLENGE_CANCELLED")
	f.advance(6)
	f.active()
	local newer = f.challenge(1)
	f.owner.completeChallengeTravel(old)
	check(Wire.equal(newer, f.challenge(1)))
	f.owner.completeChallengeTravel(f.begin(2))
	check(f.challenge(1).winnerUserId == 2)
end
local function interruptionAndOldAvatarCallback()
	local f = fixture()
	f.active()
	f.owner.interruptChallenge(f.players[1], {}, false)
	check(f.challenge(1).phase == "Active", "old avatar callback interrupted current challenge")
	f.owner.interruptChallenge(f.players[1], f.caps[1].character, false)
	check(f.challenge(2).phase == "Cancelled")
	local g = fixture()
	g.offer()
	g.caps[2].character = {}
	g.owner.interruptChallenge(g.players[2], g.caps[2].character, true)
	check(g.challenge(1).phase == "Cancelled")
end
local function recoveryAndOtherAuthorizedTravelCancel()
	local f = fixture()
	f.active()
	check(f.begin(1, true) == nil and f.challenge(1).phase == "Cancelled")
	local g = fixture()
	g.active()
	check(g.begin(2, false, "travel-node/mid-a") == nil and g.challenge(2).phase == "Cancelled")
end
local function senderAndRecipientSessionReplacement()
	for _, id in { 1, 2 } do
		local f = fixture()
		f.offer()
		f.replace(id)
		check(f.challenge(id) == nil and f.challenge(if id == 1 then 2 else 1).phase == "Cancelled")
		check(f.owner.counts().challengeParticipants == 1)
	end
end
local function replacedPlayerCannotAccept()
	local f = fixture()
	f.offer()
	local old = f.players[2]
	f.players[2] = { UserId = 2 }
	check(f.owner.challengeRespond(old, f.challenge(1).id, true, 1) == "REJECT_STATE_PARTY_SESSION")
	check(f.challenge(2) == nil and f.challenge(1).phase == "Cancelled")
end
local function disconnectRejoinCannotInherit()
	local f = fixture()
	f.active()
	local old, session, pending = f.players[2], f.sessions[2], f.begin(2)
	check(f.owner.disconnect(old, session, true))
	f.present[2] = false
	check(f.challenge(1).phase == "Cancelled")
	f.players[2], f.present[2], f.caps[2] = { UserId = 2 }, true, { character = {}, generation = 1 }
	f.replace(2)
	check(f.challenge(2) == nil and f.view(2).state.rejoin == nil)
	f.owner.completeChallengeTravel(pending)
	check(f.challenge(1).phase == "Cancelled")
	check(not f.owner.disconnect(old, session, false))
end
local function disconnectVersusResult()
	local f = fixture()
	f.active()
	local pending = f.begin(1)
	f.owner.disconnect(f.players[2], f.sessions[2], false)
	f.owner.completeChallengeTravel(pending)
	check(f.challenge(1).phase == "Cancelled" and f.challenge(1).winnerUserId == nil)
	local g = fixture()
	g.active()
	g.owner.completeChallengeTravel(g.begin(1))
	g.owner.disconnect(g.players[2], g.sessions[2], false)
	check(g.challenge(1).phase == "Resolved" and g.challenge(1).winnerUserId == 1)
end
local function staleObservationCannotAdmit()
	local f = fixture()
	f.observe = function(id)
		if id == 2 then
			f.players[2] = { UserId = 2 }
		end
	end
	check(f.offer() == "REJECT_STATE_CHALLENGE_STALE")
	check(f.owner.counts().challenges == 0)
end
local function unavailableSessionCancels()
	local f = fixture()
	f.active()
	check(f.sessions[2].release(f.clock() + 5).status == "Closed")
	check(f.challenge(1).phase == "Cancelled" and f.challenge(2) == nil)
end
local function expiryAndShutdownReleaseAllState()
	local f = fixture()
	f.active()
	local pending = f.begin(1)
	check(f.owner.nextDeadline() == 130)
	f.advance(30)
	f.owner.expire()
	check(f.challenge(1).phase == "Expired" and f.owner.nextDeadline() == 136)
	f.advance(6)
	f.owner.expire()
	check(f.owner.counts().challenges == 0 and f.owner.counts().challengeParticipants == 0)
	f.active()
	f.owner.stop()
	f.owner.completeChallengeTravel(pending)
	f.owner.expire()
	for _, count in f.owner.counts() do
		check(count == 0)
	end
	check(f.owner.nextDeadline() == nil)
end
local function noProfileValueOrRepositoryMutation()
	local f = fixture()
	local before, calls = {}, f.repository.calls()
	for id = 1, 6 do
		before[id] = f.sessions[id].snapshot()
	end
	f.active()
	f.owner.completeChallengeTravel(f.begin(1))
	f.advance(6)
	f.owner.expire()
	for id = 1, 6 do
		check(Wire.equal(before[id], f.sessions[id].snapshot()) and not f.sessions[id].isDirty())
	end
	check(f.repository.calls() == calls, "Challenge wrote personal value")
end
local function projectionRevisionAndExpiry()
	local f = fixture()
	f.offer()
	local store = Store.new(Contract, Wire, f.clock)
	local before = f.view(2)
	check(store.snapshot(before) == "Party" and store.nextDeadline() == 120)
	f.respond(2, true)
	local active = f.view(2)
	check(active.revision > before.revision and store.snapshot(active) == "Party")
	check(store.snapshot(before) == "Stale" and store.view().state.challenge.phase == "Active")
	f.advance(30)
	check(store.view().state.challenge == nil)
	f.advance(-2)
	check(store.snapshot(active) == "Stale" and store.view().state.challenge == nil)
end
local function exactBoundedChallengeProjection()
	local f = fixture()
	f.active()
	local valid = f.view(2)
	local mutations = {
		function(p: any)
			p.state.challenge.phase = "WonByClient"
		end,
		function(p: any)
			p.state.challenge.accepted = false
		end,
		function(p: any)
			p.state.challenge.startedAt = math.huge
		end,
		function(p: any)
			p.state.challenge.toUserId = 1
		end,
		function(p: any)
			p.state.challenge.definitionVersion = 0 / 0
		end,
		function(p: any)
			p.state.challenge.score = 50
		end,
		function(p: any)
			p.state.challenge.rules = string.rep("x", 257)
		end,
		function(p: any)
			p.state.challenge.winnerUserId = 3
		end,
	}
	for _, mutate in mutations do
		local p = Wire.copy(valid)
		mutate(p)
		check(not Contract.validSnapshot(p))
	end
	check(Contract.validSnapshot(valid) and Wire.payload(valid))
	-- Exercise a reachable four-member Party plus two live pings and challenge.
	f.options.pingContract = Contract
	f.options.waypoint = function()
		return { x = 100000, y = -100000, z = 100000 }
	end
	local context = f.options.context
	f.options.context = function(id)
		local c = context(id)
		if c then
			c.pingsMuted = false
		end
		return c
	end
	check(f.owner.create(f.players[1]) == "OK_PARTY_CREATED")
	for id = 2, 4 do
		f.advance(3)
		check(
			f.owner.invite(f.players[1], id, f.view(1).state.party.revision) == "OK_PARTY_INVITED"
		)
		local i = f.view(id).state.incoming[1]
		check(
			f.owner.respond(f.players[id], i.invitationId, true, i.partyRevision)
				== "OK_PARTY_JOINED"
		)
	end
	local p = f.view(1).state.party
	check(f.owner.ping(f.players[1], p.partyId, "ComeHere", p.revision) == "OK_SOCIAL_PING")
	check(f.owner.ping(f.players[3], p.partyId, "ComeHere", p.revision) == "OK_SOCIAL_PING")
	check(f.owner.counts().pings == 2)
	for id = 1, 4 do
		local full = f.view(id)
		check(
			#full.state.party.members == 4 and Contract.validSnapshot(full) and Wire.payload(full),
			"combined readback exceeds wire budget"
		)
		if id <= 2 then
			check(full.state.challenge.phase == "Active" and #full.state.pings < 2)
		end
	end
	f.owner.completeChallengeTravel(f.begin(1))
	local full = f.view(1)
	check(
		full.state.challenge.phase == "Resolved"
			and Contract.validSnapshot(full)
			and Wire.payload(full),
		"result disclosure must fit existing wire budget"
	)
	check(
		f.owner.counts().pings == 2 and f.view(3).state.party.revision == p.revision,
		"backpressure changed social authority"
	)
	local g = fixture()
	g.active()
	for id = 3, 4 do
		check(g.owner.create(g.players[id]) == "OK_PARTY_CREATED")
		g.advance(3)
		check(
			g.owner.invite(g.players[id], 1, g.view(id).state.party.revision) == "OK_PARTY_INVITED"
		)
	end
	g.owner.completeChallengeTravel(g.begin(1))
	local invited = g.view(1)
	check(
		#invited.state.incoming == 2
			and invited.state.challenge.phase == "Resolved"
			and Wire.payload(invited),
		"challenge result and both Party invitations must survive without backpressure loss"
	)
end
local function hostileIngressAndForgedDefinition()
	local f = fixture()
	local send = network(f)
	local extras: { any } = {
		{ participant = 3 },
		{ score = 999 },
		{ result = "Win" },
		{ stake = 10 },
		{ supporter = true },
		{ text = string.rep("x", 4097) },
		{ sessionIdentity = {} },
		{ expiry = 999 },
	}
	for i, extra in extras do
		local payload = requestPayload()
		for key, value in extra do
			payload[key] = value
		end
		f.advance(3)
		check(
			send(1, Routes.commands.socialChallengeRequest, "bad-" .. i, payload)
				== "REJECT_VALIDATION_PAYLOAD"
		)
	end
	local bad = requestPayload()
	bad.definitionId = "forged"
	f.advance(3)
	check(
		send(1, Routes.commands.socialChallengeRequest, "forged", bad)
			== "REJECT_STATE_CHALLENGE_DEFINITION"
	)
	check(send(1, "Social.ChallengeResolve", "resolve", {}) == "REJECT_VALIDATION_ROUTE")
	check(f.owner.counts().challenges == 0)
end
local function replayAcceptCancelAndSessionFence()
	local f = fixture()
	local send = network(f)
	check(
		send(1, Routes.commands.socialChallengeRequest, "offer", requestPayload())
			== "OK_CHALLENGE_OFFERED"
	)
	local id = f.challenge(2).id
	local accept = { challengeId = id, accept = true }
	check(
		send(2, Routes.commands.socialChallengeRespond, "accept", accept, 1)
			== "OK_CHALLENGE_ACTIVE"
	)
	local active = f.challenge(2)
	check(
		send(2, Routes.commands.socialChallengeRespond, "accept", accept, 1)
			== "OK_CHALLENGE_ACTIVE"
	)
	check(Wire.equal(active, f.challenge(2)))
	check(
		send(1, Routes.commands.socialChallengeCancel, "cancel", { challengeId = id }, 2)
			== "OK_CHALLENGE_CANCELLED"
	)
	check(
		send(1, Routes.commands.socialChallengeCancel, "cancel", { challengeId = id }, 2)
			== "OK_CHALLENGE_CANCELLED"
	)
	f.replace(2)
	f.advance(3)
	check(
		send(2, Routes.commands.socialChallengeRespond, "accept", accept, 1)
			== "REJECT_VALIDATION_REQUEST_REUSE"
	)
end
local function rateSpamAndChurnBounds()
	local f = fixture()
	local send = network(f)
	check(
		send(1, Routes.commands.socialChallengeRequest, "first", requestPayload())
			== "OK_CHALLENGE_OFFERED"
	)
	for i = 1, 100 do
		check(
			send(1, Routes.commands.socialChallengeRequest, "spam-" .. i, requestPayload())
				== "REJECT_RATE_LIMIT"
		)
	end
	check(f.owner.counts().challenges == 1)
	f.advance(3)
	check(
		send(1, Routes.commands.socialChallengeRequest, "busy", requestPayload())
			== "REJECT_STATE_CHALLENGE_BUSY"
	)
	f.respond(2, false)
	f.advance(6)
	check(
		send(1, Routes.commands.socialChallengeRequest, "after", requestPayload())
			== "OK_CHALLENGE_OFFERED"
	)
end
local function forgedIdRevisionAndResult()
	local f = fixture()
	local send = network(f)
	f.offer()
	local id = f.challenge(2).id
	check(
		send(
			2,
			Routes.commands.socialChallengeRespond,
			"foreign",
			{ challengeId = "forged", accept = true },
			1
		) == "REJECT_STATE_CHALLENGE_REVISION"
	)
	check(
		send(
			2,
			Routes.commands.socialChallengeRespond,
			"revision",
			{ challengeId = id, accept = true },
			999
		) == "REJECT_STATE_CHALLENGE_REVISION"
	)
	check(
		send(
			2,
			Routes.commands.socialChallengeRespond,
			"score",
			{ challengeId = id, accept = true, score = 999 },
			1
		) == "REJECT_VALIDATION_PAYLOAD"
	)
	check(f.challenge(2).phase == "Offered")
end
local function ordinaryTravelObservationAndFailureIsolation()
	local f = fixture()
	local context = {
		player = f.players[1],
		session = f.sessions[1],
		character = f.caps[1].character,
		generation = 1,
		validPosition = true,
		regionId = "starter",
		nodeId = Definition.sourceNodeId,
	}
	local fail = false
	local options = {
		clock = f.clock,
		context = function()
			return context
		end,
		recovery = function()
			return { regionId = "starter", nodeId = Definition.sourceNodeId }
		end,
		destination = function(_c: any, id: string): (any, string)
			return if id == Definition.targetNodeId then { regionId = "home", nodeId = id } else nil,
				"INVALID"
		end,
		relocate = function(_p: any, _c: any, target: any)
			if fail then
				return false
			end
			context.regionId = target.regionId
			return true
		end,
		interrupt = function()
			return true
		end,
		observe = function() end,
		beginTravelObservation = f.owner.beginChallengeTravel,
		completeTravelObservation = f.owner.completeChallengeTravel,
	}
	local world = Travel.new(options)
	f.players[1].Character = context.character
	world.step({ f.players[1] })
	check(world.available(f.players[1], 1, Definition.targetNodeId))
	f.active()
	check(world.travel(f.players[1], "forged", 1) == "REJECT_STATE_TRAVEL_INVALID")
	check(f.challenge(1).phase == "Active")
	check(world.travel(f.players[1], Definition.targetNodeId, 1) == "OK_WORLD_TRAVELLED")
	check(f.challenge(1).phase == "Resolved" and f.challenge(1).winnerUserId == 1)
	f.advance(1)
	check(not world.available(f.players[1], 999, Definition.targetNodeId))
	options.beginTravelObservation = function()
		error("observer failure")
	end
	check(
		world.travel(f.players[1], Definition.targetNodeId, 1) == "OK_WORLD_TRAVELLED",
		"social observer changed ordinary authority"
	)
	local g = fixture()
	g.players[1].Character = g.caps[1].character
	context.session, context.character = g.sessions[1], g.caps[1].character
	options.beginTravelObservation, options.completeTravelObservation =
		g.owner.beginChallengeTravel, g.owner.completeChallengeTravel
	fail = false
	world = Travel.new(options)
	world.step({ g.players[1] })
	g.active()
	fail = true
	check(world.travel(g.players[1], Definition.targetNodeId, 1) == "UNAVAILABLE_TRAVEL_ARRIVAL")
	check(g.challenge(1).phase == "Active", "failed travel scored")
end
return {
	offeredIsVisibleAndNonBinding = offeredIsVisibleAndNonBinding,
	intendedLiveInviteeOnly = intendedLiveInviteeOnly,
	explicitAcceptAndDuplicate = explicitAcceptAndDuplicate,
	declineAndIgnoreHaveNoPenalty = declineAndIgnoreHaveNoPenalty,
	expiryAndAcceptBoundary = expiryAndAcceptBoundary,
	pendingActiveAndGlobalBounds = pendingActiveAndGlobalBounds,
	simultaneousOfferAndAccept = simultaneousOfferAndAccept,
	capabilityLimitAndRecheck = capabilityLimitAndRecheck,
	definitionPinnedAndRenewedConsent = definitionPinnedAndRenewedConsent,
	suppressionAndRevocation = suppressionAndRevocation,
	invalidSelfAndUnavailableTarget = invalidSelfAndUnavailableTarget,
	partyChangesAreIndependent = partyChangesAreIndependent,
	serverObservedFinishAndFreeze = serverObservedFinishAndFreeze,
	sameTimeFinishesUseAdmissionOrder = sameTimeFinishesUseAdmissionOrder,
	cancellationAndStaleGeneration = cancellationAndStaleGeneration,
	interruptionAndOldAvatarCallback = interruptionAndOldAvatarCallback,
	recoveryAndOtherAuthorizedTravelCancel = recoveryAndOtherAuthorizedTravelCancel,
	senderAndRecipientSessionReplacement = senderAndRecipientSessionReplacement,
	replacedPlayerCannotAccept = replacedPlayerCannotAccept,
	disconnectRejoinCannotInherit = disconnectRejoinCannotInherit,
	disconnectVersusResult = disconnectVersusResult,
	staleObservationCannotAdmit = staleObservationCannotAdmit,
	unavailableSessionCancels = unavailableSessionCancels,
	expiryAndShutdownReleaseAllState = expiryAndShutdownReleaseAllState,
	noProfileValueOrRepositoryMutation = noProfileValueOrRepositoryMutation,
	projectionRevisionAndExpiry = projectionRevisionAndExpiry,
	exactBoundedChallengeProjection = exactBoundedChallengeProjection,
	hostileIngressAndForgedDefinition = hostileIngressAndForgedDefinition,
	replayAcceptCancelAndSessionFence = replayAcceptCancelAndSessionFence,
	rateSpamAndChurnBounds = rateSpamAndChurnBounds,
	forgedIdRevisionAndResult = forgedIdRevisionAndResult,
	ordinaryTravelObservationAndFailureIsolation = ordinaryTravelObservationAndFailureIsolation,
}
