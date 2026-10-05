--!strict

local PartyService = require("../../src/server/domains/social/PartyService")
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
local Publisher = require("../../src/server/application/ProjectionPublisher")
local Gateway = require("../../src/server/application/NetworkingGateway")
local Projection = require("../../src/shared/contracts/ProjectionV1")
local ClientGateway = require("../../src/client/networking/ClientGateway")
local SessionStore = require("../../src/client/store/ProjectionStore")

local function check(value: any, message: string?): any
	return assert(value, message or "Party invariant")
end

local function fixture(config: any?)
	local at, sequence = 0, 0
	local contexts: { [number]: any } = {}
	local players: { any } = {}
	for userId = 1, 10 do
		players[userId] = { UserId = userId }
		contexts[userId] = { player = players[userId], session = {}, ready = true }
	end
	local owner = PartyService.new({
		policy = config or Policy,
		monotonicSeconds = function()
			return at
		end,
		context = function(userId)
			return contexts[userId]
		end,
		newId = function()
			sequence += 1
			return string.format("party-id-%036d", sequence)
		end,
	})
	return {
		owner = owner,
		players = players,
		contexts = contexts,
		advance = function(seconds: number)
			at += seconds
		end,
		time = function(value: number)
			at = value
		end,
	}
end
local function party(f: any, userId: number): any
	return f.owner.snapshot(f.players[userId]).state.party
end
local function incoming(f: any, userId: number): any
	return f.owner.snapshot(f.players[userId]).state.incoming[1]
end
local function create(f: any, userId: number)
	check(f.owner.create(f.players[userId]) == "OK_PARTY_CREATED")
	return party(f, userId)
end
local function invite(f: any, leaderId: number, targetId: number): any
	f.advance(3)
	check(f.owner.setInvitePolicy(f.players[targetId], true) == "OK_PARTY_INVITE_POLICY")
	check(
		f.owner.invite(f.players[leaderId], targetId, party(f, leaderId).revision)
			== "OK_PARTY_INVITED"
	)
	return incoming(f, targetId)
end
local function join(f: any, leaderId: number, targetId: number)
	local pending = invite(f, leaderId, targetId)
	check(
		f.owner.respond(f.players[targetId], pending.invitationId, true, pending.partyRevision)
			== "OK_PARTY_JOINED"
	)
end
local function absent(f: any, userId: number, unexpected: boolean)
	local session = f.contexts[userId].session
	check(f.owner.disconnect(f.players[userId], session, unexpected))
	f.contexts[userId] = nil
	return session
end
local function returnPlayer(f: any, userId: number)
	f.players[userId] = { UserId = userId }
	f.contexts[userId] = { player = f.players[userId], session = {}, ready = true }
end

local function creationConsentAndDecline()
	local f = fixture()
	local initial = create(f, 1)
	check(initial.leaderUserId == 1 and initial.revision == 1 and #initial.members == 1)
	check(f.owner.create(f.players[1]) == "REJECT_STATE_PARTY_MEMBERSHIP")
	check(f.owner.invite(f.players[1], 2, 1) == "REJECT_PERMISSION_PARTY_INVITES")
	local pending = invite(f, 1, 2)
	check(party(f, 2) == nil and #party(f, 1).members == 1, "receiving an invite is not consent")
	check(f.owner.respond(f.players[2], pending.invitationId, false, 1) == "OK_PARTY_DECLINED")
	check(party(f, 2) == nil and incoming(f, 2) == nil and party(f, 1).revision == 1)
end
local function invitationExpiryAndBoundedHistory()
	local f = fixture()
	create(f, 1)
	local pending = invite(f, 1, 2)
	check(pending.status == "Pending" and pending.expiresAt == 33)
	f.advance(29.999)
	check(incoming(f, 2) ~= nil)
	f.time(33)
	f.owner.expire()
	check(f.owner.respond(f.players[2], pending.invitationId, true, 1) ~= "OK_PARTY_JOINED")
	check(incoming(f, 2) == nil and f.owner.counts().invites == 0 and f.owner.nextDeadline() == nil)
	for _ = 1, 100 do
		invite(f, 1, 2)
		f.advance(30)
		f.owner.expire()
	end
	check(f.owner.counts().invites == 0 and party(f, 1).revision == 1)
end
local function revisionAndDuplicateAcceptance()
	local f = fixture()
	create(f, 1)
	local pending = invite(f, 1, 2)
	check(
		f.owner.respond(f.players[2], pending.invitationId, true, 999)
			== "REJECT_STATE_PARTY_REVISION"
	)
	check(f.owner.respond(f.players[2], pending.invitationId, true, 1) == "OK_PARTY_JOINED")
	check(f.owner.respond(f.players[2], pending.invitationId, true, 1) ~= "OK_PARTY_JOINED")
	check(#party(f, 1).members == 2 and party(f, 1).revision == 2)
	check(f.owner.leave(f.players[2], party(f, 2).partyId, 1) == "REJECT_STATE_PARTY_REVISION")
	check(#party(f, 1).members == 2)
end
local function simultaneousFinalSeatAndFifthMember()
	local f = fixture()
	create(f, 1)
	join(f, 1, 2)
	join(f, 1, 3)
	local a, b = invite(f, 1, 4), invite(f, 1, 5)
	local winners = 0
	local contenders: { any } = { { 4, a }, { 5, b } }
	for _, pair in contenders do
		local thread = coroutine.create(function()
			local code = f.owner.respond(
				f.players[pair[1]],
				pair[2].invitationId,
				true,
				pair[2].partyRevision
			)
			if code == "OK_PARTY_JOINED" then
				winners += 1
			end
		end)
		check(coroutine.resume(thread))
		check(coroutine.status(thread) == "dead", "membership transition yielded")
	end
	check(winners == 1 and #party(f, 1).members == 4 and party(f, 5) == nil)
	local fifth = invite(f, 1, 5)
	check(
		f.owner.respond(f.players[5], fifth.invitationId, true, fifth.partyRevision)
			== "REJECT_STATE_PARTY_FULL"
	)
	check(f.owner.counts().memberships == 4)
end
local function conflictingPartiesAndExplicitLeave()
	local f = fixture()
	create(f, 1)
	create(f, 2)
	local a, b = invite(f, 1, 3), invite(f, 2, 3)
	check(f.owner.respond(f.players[3], a.invitationId, true, 1) == "OK_PARTY_JOINED")
	check(f.owner.respond(f.players[3], b.invitationId, true, 1) ~= "OK_PARTY_JOINED")
	check(f.owner.invite(f.players[2], 3, 1) == "REJECT_STATE_PARTY_MEMBERSHIP")
	check(#party(f, 1).members == 2 and #party(f, 2).members == 1)
	local current = party(f, 3)
	check(f.owner.leave(f.players[3], current.partyId, current.revision) == "OK_PARTY_LEFT")
	join(f, 2, 3)
	check(#party(f, 1).members == 1 and #party(f, 2).members == 2)
end
local function forgedIdentityAndLeaderAuthority()
	local f = fixture()
	create(f, 1)
	local pending = invite(f, 1, 2)
	check(
		f.owner.respond(f.players[3], pending.invitationId, true, 1)
			== "REJECT_PERMISSION_PARTY_INVITE"
	)
	check(f.owner.respond(f.players[2], "forged", true, 1) == "REJECT_PERMISSION_PARTY_INVITE")
	join(f, 1, 3)
	local current = party(f, 1)
	check(
		f.owner.remove(f.players[3], current.partyId, 1, current.revision)
			== "REJECT_PERMISSION_PARTY_LEADER"
	)
	check(
		f.owner.disband(f.players[3], current.partyId, current.revision)
			== "REJECT_PERMISSION_PARTY_LEADER"
	)
	check(f.owner.leave(f.players[3], "forged", current.revision) == "REJECT_STATE_PARTY_REVISION")
	check(
		f.owner.remove(f.players[1], current.partyId, 999, current.revision)
			== "REJECT_STATE_PARTY_MEMBER"
	)
	check(
		f.owner.remove(f.players[1], current.partyId, 1, current.revision)
			== "REJECT_STATE_PARTY_MEMBER"
	)
	check(#party(f, 1).members == 2)
end
local function deterministicSuccessionAndDissolution()
	local f = fixture()
	create(f, 1)
	join(f, 1, 5)
	join(f, 1, 2)
	local current = party(f, 1)
	check(f.owner.leave(f.players[1], current.partyId, current.revision) == "OK_PARTY_LEFT")
	check(party(f, 5).leaderUserId == 5, "succession follows join sequence, not UserId")
	current = party(f, 5)
	check(f.owner.remove(f.players[5], current.partyId, 2, current.revision) == "OK_PARTY_REMOVED")
	current = party(f, 5)
	check(f.owner.leave(f.players[5], current.partyId, current.revision) == "OK_PARTY_LEFT")
	check(f.owner.counts().parties == 0 and f.owner.counts().memberships == 0)
end
local function sessionReplacementCancelsInvitesAndMembership()
	local f = fixture()
	create(f, 1)
	local pending = invite(f, 1, 2)
	f.contexts[2].session = {}
	check(f.owner.respond(f.players[2], pending.invitationId, true, 1) ~= "OK_PARTY_JOINED")
	check(incoming(f, 2) == nil and not f.owner.snapshot(f.players[2]).state.allowInvites)
	join(f, 1, 2)
	local oldSession = f.contexts[2].session
	f.contexts[2].session = {}
	f.owner.observe(2)
	check(party(f, 2) == nil and #party(f, 1).members == 1)
	check(not f.owner.disconnect(f.players[2], oldSession, true), "stale session cleanup admitted")
	check(f.owner.create(f.players[2]) == "OK_PARTY_CREATED")
end
local function replacementPlayerCannotInheritAuthority()
	local f = fixture()
	create(f, 1)
	join(f, 1, 2)
	local oldPlayer, oldSession = f.players[1], f.contexts[1].session
	returnPlayer(f, 1)
	f.owner.observe(1)
	check(party(f, 1) == nil and party(f, 2).leaderUserId == 2)
	check(f.owner.create(oldPlayer) == "REJECT_STATE_PARTY_SESSION")
	check(not f.owner.disconnect(oldPlayer, oldSession, true))
	check(party(f, 2).leaderUserId == 2)
end
local function sameServerRejoinRequiresCurrentConsent()
	local f = fixture()
	create(f, 1)
	join(f, 1, 2)
	local original = party(f, 2)
	absent(f, 2, true)
	check(#party(f, 1).members == 2 and not party(f, 1).members[2].present)
	returnPlayer(f, 2)
	local state = f.owner.snapshot(f.players[2]).state
	check(state.party == nil and state.rejoin.partyId == original.partyId)
	check(f.owner.create(f.players[2]) == "REJECT_STATE_PARTY_MEMBERSHIP")
	check(
		f.owner.rejoin(f.players[2], original.partyId, original.revision)
			== "REJECT_STATE_PARTY_REVISION"
	)
	check(
		f.owner.rejoin(f.players[2], state.rejoin.partyId, state.rejoin.revision)
			== "OK_PARTY_REJOINED"
	)
	check(party(f, 2).leaderUserId == 1 and #party(f, 1).members == 2)
	check(
		f.owner.rejoin(f.players[2], original.partyId, state.rejoin.revision) ~= "OK_PARTY_REJOINED"
	)
end
local function leaderDisconnectDoesNotSeizeLeadershipOnReturn()
	local f = fixture()
	create(f, 1)
	join(f, 1, 5)
	join(f, 1, 2)
	absent(f, 1, true)
	check(party(f, 5).leaderUserId == 5)
	returnPlayer(f, 1)
	local reservation = f.owner.snapshot(f.players[1]).state.rejoin
	check(
		f.owner.rejoin(f.players[1], reservation.partyId, reservation.revision)
			== "OK_PARTY_REJOINED"
	)
	check(party(f, 1).leaderUserId == 5)
	local current = party(f, 5)
	check(f.owner.leave(f.players[5], current.partyId, current.revision) == "OK_PARTY_LEFT")
	check(party(f, 1).leaderUserId == 1, "rejoin retained original join sequence")
end
local function graceExpiryRemovalAndDisbandCannotResurrect()
	for _, mode in { "expiry", "remove", "disband", "voluntary" } do
		local f = fixture()
		create(f, 1)
		join(f, 1, 2)
		local oldId = party(f, 1).partyId
		absent(f, 2, mode ~= "voluntary")
		local current = party(f, 1)
		if mode == "expiry" then
			f.advance(30)
			f.owner.expire()
		elseif mode == "remove" then
			check(f.owner.remove(f.players[1], oldId, 2, current.revision) == "OK_PARTY_REMOVED")
		elseif mode == "disband" then
			check(f.owner.disband(f.players[1], oldId, current.revision) == "OK_PARTY_DISBANDED")
		end
		returnPlayer(f, 2)
		check(f.owner.snapshot(f.players[2]).state.rejoin == nil)
		check(f.owner.rejoin(f.players[2], oldId, current.revision) ~= "OK_PARTY_REJOINED")
		check(f.owner.create(f.players[2]) == "OK_PARTY_CREATED", "ghost membership after " .. mode)
	end
end
local function reservationCanBeReleasedWithoutRejoining()
	local f = fixture()
	create(f, 1)
	join(f, 1, 2)
	absent(f, 2, true)
	returnPlayer(f, 2)
	local reservation = f.owner.snapshot(f.players[2]).state.rejoin
	check(f.owner.leave(f.players[2], reservation.partyId, reservation.revision) == "OK_PARTY_LEFT")
	check(f.owner.create(f.players[2]) == "OK_PARTY_CREATED")
end
local function staleDisconnectCannotRemoveNewMembership()
	local f = fixture()
	create(f, 1)
	join(f, 1, 2)
	local oldPlayer, oldSession = f.players[2], absent(f, 2, true)
	returnPlayer(f, 2)
	local reservation = f.owner.snapshot(f.players[2]).state.rejoin
	check(
		f.owner.rejoin(f.players[2], reservation.partyId, reservation.revision)
			== "OK_PARTY_REJOINED"
	)
	check(not f.owner.disconnect(oldPlayer, oldSession, true))
	check(#party(f, 1).members == 2 and party(f, 2) ~= nil)
end
local function senderTargetDisconnectAndPolicyRevocation()
	for _, who in { 1, 2 } do
		local f = fixture()
		create(f, 1)
		local pending = invite(f, 1, 2)
		absent(f, who, true)
		check(f.owner.counts().invites == 0)
		if who == 2 then
			returnPlayer(f, 2)
		end
		check(f.owner.respond(f.players[2], pending.invitationId, true, 1) ~= "OK_PARTY_JOINED")
	end
	local f = fixture()
	create(f, 1)
	invite(f, 1, 2)
	check(f.owner.setInvitePolicy(f.players[2], false) == "OK_PARTY_INVITE_POLICY")
	check(incoming(f, 2) == nil)
	check(f.owner.invite(f.players[1], 2, 1) == "REJECT_PERMISSION_PARTY_INVITES")
end
local function unavailableIdentityCannotHoldLeadership()
	local f = fixture()
	create(f, 1)
	join(f, 1, 2)
	f.contexts[1].ready = false
	f.owner.observe(1)
	check(party(f, 2).leaderUserId == 2 and party(f, 1) == nil)
	check(f.owner.invite(f.players[1], 3, 2) == "REJECT_STATE_PARTY_SESSION")
	local snapshot = party(f, 2)
	f.players[2].Character = {} -- avatar reset/travel has no social identity authority.
	check(Wire.equal(snapshot, party(f, 2)))
end
local function invitationCooldownAndCountBounds()
	local f = fixture()
	create(f, 1)
	for userId = 2, 7 do
		f.owner.setInvitePolicy(f.players[userId], true)
	end
	check(f.owner.invite(f.players[1], 2, 1) == "OK_PARTY_INVITED")
	check(f.owner.invite(f.players[1], 2, 1) == "REJECT_STATE_PARTY_DUPLICATE_INVITE")
	check(f.owner.invite(f.players[1], 3, 1) == "REJECT_RATE_LIMIT")
	for userId = 3, 5 do
		f.advance(3)
		check(f.owner.invite(f.players[1], userId, 1) == "OK_PARTY_INVITED")
	end
	f.advance(3)
	check(f.owner.invite(f.players[1], 6, 1) == "REJECT_STATE_PARTY_INVITE_BOUNDS")
	check(f.owner.counts().invites == 4)
	create(f, 6)
	check(f.owner.invite(f.players[6], 2, 1) == "OK_PARTY_INVITED")
	create(f, 7)
	f.advance(3)
	check(f.owner.invite(f.players[7], 2, 1) == "REJECT_STATE_PARTY_INVITE_BOUNDS")
	check(#f.owner.snapshot(f.players[2]).state.incoming == 2)
	check(f.owner.invite(f.players[1], 1, 1) == "REJECT_STATE_PARTY_TARGET")
	check(f.owner.invite(f.players[1], 999, 1) == "REJECT_STATE_PARTY_TARGET")
end
local function partyBoundsShutdownAndClockFailure()
	local config = table.clone(Policy)
	config.maxParties = 2
	local f = fixture(config)
	create(f, 1)
	create(f, 2)
	check(f.owner.create(f.players[3]) == "REJECT_STATE_PARTY_BOUNDS")
	f.time(-1)
	check(f.owner.create(f.players[3]) == "REJECT_STATE_PARTY_SESSION")
	f.time(1)
	f.owner.stop()
	local counts = f.owner.counts()
	check(
		counts.parties == 0
			and counts.memberships == 0
			and counts.invites == 0
			and counts.liveUsers == 0
	)
	check(f.owner.snapshot(f.players[1]) == nil and f.owner.nextDeadline() == nil)
	check(f.owner.create(f.players[3]) == "REJECT_STATE_PARTY_SESSION")
	f.owner.expire()
	check(f.owner.counts().parties == 0)
end
local function projectionRevisionAndImmutableDeadlines()
	local f = fixture()
	local store = Store.new(Contract, Wire)
	create(f, 1)
	invite(f, 1, 2)
	local first = f.owner.snapshot(f.players[2])
	check(Contract.validSnapshot(first) and Wire.payload(first))
	f.advance(2)
	check(
		Wire.equal(first, f.owner.snapshot(f.players[2])),
		"unchanged revision changed projection content"
	)
	check(store.snapshot(first) == "Party")
	local inviteState = first.state.incoming[1]
	check(f.owner.respond(f.players[2], inviteState.invitationId, true, 1) == "OK_PARTY_JOINED")
	local joined = f.owner.snapshot(f.players[2])
	check(joined.revision > first.revision and store.snapshot(joined) == "Party")
	check(store.snapshot(first) == "Stale")
	local current = party(f, 2)
	check(f.owner.leave(f.players[2], current.partyId, current.revision) == "OK_PARTY_LEFT")
	local left = f.owner.snapshot(f.players[2])
	check(store.snapshot(left) == "Party" and store.snapshot(joined) == "Stale")
	check(store.view().state.party == nil)
	local copy = store.view()
	copy.state.allowInvites = false
	check(store.view().state.allowInvites)
	store.reset()
	check(store.view() == nil)
end
local function strictProjectionAndPayloadSchemas()
	check(Contract.validCreate({}, nil) and not Contract.validCreate({ owner = 2 }, nil))
	check(
		Contract.validInvite({ targetUserId = 2 }, 1)
			and not Contract.validInvite({ targetUserId = 2, inviter = 1 }, 1)
	)
	check(
		not Contract.validInvite({ targetUserId = 2 }, nil)
			and not Contract.validInvite({ targetUserId = 0 / 0 }, 1)
	)
	check(not Contract.validRespond({ invitationId = "id", accept = true, expiry = 999 }, 1))
	check(not Contract.validParty({ partyId = "id", members = { 1 } }, 1))
	check(not Contract.validRemove({ partyId = "id", targetUserId = 2, session = "forged" }, 1))
	check(not Contract.validInvitePolicy({ allowInvites = true, paid = true }, nil))
	local f = fixture()
	create(f, 1)
	local payload = f.owner.snapshot(f.players[1])
	check(Contract.validSnapshot(payload) and Wire.payload(payload))
	for _, mutate in
		{
			function(p: any)
				p.state.party.members[2] = p.state.party.members[1]
			end,
			function(p: any)
				p.state.party.leaderUserId = 999
			end,
			function(p: any)
				p.state.party.members[1].present = false
			end,
			function(p: any)
				p.state.party.session = "private"
			end,
			function(p: any)
				p.revision = 2 ^ 53
			end,
			function(p: any)
				p.state.incoming[3] = {}
			end,
		}
	do
		local invalid = Wire.copy(payload)
		mutate(invalid)
		check(not Contract.validSnapshot(invalid))
	end
end

local function networkFixture()
	local f: any = fixture()
	local clock = 0
	local function time()
		return clock
	end
	local schemas = {
		[Routes.commands.socialPartyCreate] = Contract.validCreate,
		[Routes.commands.socialPartyInvite] = Contract.validInvite,
		[Routes.commands.socialPartyRespond] = Contract.validRespond,
		[Routes.commands.socialPartyLeave] = Contract.validParty,
	}
	local events = {}
	f.events = events
	local function emit(_player, envelope)
		table.insert(events, envelope)
	end
	local handlers: { [string]: any } = {
		[Routes.commands.socialPartyCreate] = function(player)
			return f.owner.create(player)
		end,
		[Routes.commands.socialPartyInvite] = function(player, envelope)
			return f.owner.invite(player, envelope.payload.targetUserId, envelope.expectedRevision)
		end,
		[Routes.commands.socialPartyRespond] = function(player, envelope)
			return f.owner.respond(
				player,
				envelope.payload.invitationId,
				envelope.payload.accept,
				envelope.expectedRevision
			)
		end,
		[Routes.commands.socialPartyLeave] = function(player, envelope)
			return f.owner.leave(player, envelope.payload.partyId, envelope.expectedRevision)
		end,
	}
	local gateway = Gateway.new({
		protocol = Protocol,
		routes = Routes,
		resultCodes = Codes,
		wire = Wire,
		registry = Registry.new(Routes, schemas),
		rate = Rate.new(time),
		replay = Replay.new(time, Wire),
		projection = Publisher.new({
			protocol = Protocol,
			routes = Routes,
			projection = Projection,
			wire = Wire,
			emit = emit,
		}),
		getSession = function(player)
			local current = f.contexts[player.UserId]
			return if current and current.ready
				then { status = "Ready", identity = current.session, profileRevision = 1 }
				else { status = "Protected" }
		end,
		emitReliable = emit,
		emitUnreliable = emit,
		routeHandlers = handlers,
		partyResync = function(player)
			emit(player, f.owner.snapshot(player))
			return "OK_PARTY_SNAPSHOT"
		end,
	})
	return f,
		gateway,
		function(player: any, route: string, request: string, payload: any, expected: number?): any
			clock += 0.5
			return gateway.handle(player, {
				protocolVersion = 1,
				routeId = route,
				requestId = request,
				payload = payload,
				expectedRevision = expected,
			}).code
		end
end
local function gatewayRejectsHostilePartyIntent()
	local f, _, send = networkFixture()
	check(
		send(f.players[1], Routes.commands.socialPartyCreate, "create", {}, nil)
			== "OK_PARTY_CREATED"
	)
	local badPayloads: { any } = {
		{ targetUserId = 2, partyId = "forged" },
		{ targetUserId = 2, inviterUserId = 1 },
		{ targetUserId = 2, expiry = 999 },
		{ targetUserId = -1 },
		{ targetUserId = 0 / 0 },
		{ targetUserId = 2, sessionIdentity = {} },
		{ targetUserId = 2, members = { 2 } },
		{ targetUserId = 2, text = string.rep("x", 4097) },
	}
	for i, bad in badPayloads do
		check(
			send(f.players[1], Routes.commands.socialPartyInvite, "bad-" .. i, bad, 1)
				== "REJECT_VALIDATION_PAYLOAD"
		)
	end
	check(
		send(
			f.players[1],
			Routes.commands.socialPartyInvite,
			"missing-rev",
			{ targetUserId = 2 },
			nil
		) == "REJECT_VALIDATION_PAYLOAD"
	)
	check(
		send(
			f.players[1],
			Routes.commands.socialPartyInvite,
			"forged-rev",
			{ targetUserId = 2 },
			999
		) == "REJECT_STATE_PARTY_REVISION"
	)
	local pending = invite(f, 1, 2)
	check(
		send(
			f.players[3],
			Routes.commands.socialPartyRespond,
			"other",
			{ invitationId = pending.invitationId, accept = true },
			1
		) == "REJECT_PERMISSION_PARTY_INVITE"
	)
	f.contexts[2].ready = false
	check(
		send(
			f.players[2],
			Routes.commands.socialPartyRespond,
			"unready",
			{ invitationId = pending.invitationId, accept = true },
			1
		) == "REJECT_STATE_NOT_READY"
	)
	check(#party(f, 1).members == 1)
end
local function gatewayReplayBindsTrustedSession()
	local f, gateway, send = networkFixture()
	check(
		send(f.players[1], Routes.commands.socialPartyCreate, "create", {}, nil)
			== "OK_PARTY_CREATED"
	)
	check(
		send(f.players[1], Routes.commands.socialPartyCreate, "create", {}, nil)
			== "OK_PARTY_CREATED"
	)
	local pending = invite(f, 1, 2)
	local payload = { invitationId = pending.invitationId, accept = true }
	check(
		send(f.players[2], Routes.commands.socialPartyRespond, "accept", payload, 1)
			== "OK_PARTY_JOINED"
	)
	check(
		send(f.players[2], Routes.commands.socialPartyRespond, "accept", payload, 1)
			== "OK_PARTY_JOINED"
	)
	check(
		send(
			f.players[2],
			Routes.commands.socialPartyRespond,
			"accept",
			{ invitationId = pending.invitationId, accept = false },
			1
		) == "REJECT_VALIDATION_REQUEST_REUSE"
	)
	f.contexts[2].session = {}
	check(
		send(f.players[2], Routes.commands.socialPartyRespond, "accept", payload, 1)
			== "REJECT_VALIDATION_REQUEST_REUSE",
		"cache bypassed replacement-session fence"
	)
	check(#party(f, 1).members == 1)
	check(
		send(
			f.players[2],
			Routes.commands.sessionRequestResync,
			"resync",
			{ domain = "party" },
			nil
		) == "OK_PARTY_SNAPSHOT"
	)
	absent(f, 2, false)
	gateway.forget(2)
	returnPlayer(f, 2)
	check(
		send(f.players[2], Routes.commands.socialPartyCreate, "accept", {}, nil)
			== "OK_PARTY_CREATED",
		"new Player lifetime could not reuse bounded request numbering"
	)
end
local function clientGatewayAcceptsOnlyCoherentPartyProjection()
	local f = fixture()
	local store = Store.new(Contract, Wire)
	local client = ClientGateway.new({
		protocol = Protocol,
		routes = Routes,
		resultCodes = Codes,
		wire = Wire,
		store = SessionStore.new(Projection, Wire),
		partyProjection = Contract,
		partyStore = store,
		sendCommand = function() end,
	})
	create(f, 1)
	local snapshot = f.owner.snapshot(f.players[1])
	local envelope = {
		protocolVersion = 1,
		routeId = Routes.events.socialStateChanged,
		revision = snapshot.revision,
		payload = snapshot,
	}
	check(client.handleEvent(envelope) == "Party")
	check(client.handleEvent(envelope) == "Stale")
	envelope.revision += 1
	check(client.handleEvent(envelope) == "Invalid")
	envelope.revision = snapshot.revision
	envelope.payload.state.party.members[1].userId = 999
	check(client.handleEvent(envelope) == "Invalid")
	client.reset()
	check(store.view() == nil)
end

return {
	gatewayRejectsHostilePartyIntent = gatewayRejectsHostilePartyIntent,
	gatewayReplayBindsTrustedSession = gatewayReplayBindsTrustedSession,
	clientGatewayAcceptsOnlyCoherentPartyProjection = clientGatewayAcceptsOnlyCoherentPartyProjection,
	creationConsentAndDecline = creationConsentAndDecline,
	invitationExpiryAndBoundedHistory = invitationExpiryAndBoundedHistory,
	revisionAndDuplicateAcceptance = revisionAndDuplicateAcceptance,
	simultaneousFinalSeatAndFifthMember = simultaneousFinalSeatAndFifthMember,
	conflictingPartiesAndExplicitLeave = conflictingPartiesAndExplicitLeave,
	forgedIdentityAndLeaderAuthority = forgedIdentityAndLeaderAuthority,
	deterministicSuccessionAndDissolution = deterministicSuccessionAndDissolution,
	sessionReplacementCancelsInvitesAndMembership = sessionReplacementCancelsInvitesAndMembership,
	replacementPlayerCannotInheritAuthority = replacementPlayerCannotInheritAuthority,
	sameServerRejoinRequiresCurrentConsent = sameServerRejoinRequiresCurrentConsent,
	leaderDisconnectDoesNotSeizeLeadershipOnReturn = leaderDisconnectDoesNotSeizeLeadershipOnReturn,
	graceExpiryRemovalAndDisbandCannotResurrect = graceExpiryRemovalAndDisbandCannotResurrect,
	reservationCanBeReleasedWithoutRejoining = reservationCanBeReleasedWithoutRejoining,
	staleDisconnectCannotRemoveNewMembership = staleDisconnectCannotRemoveNewMembership,
	senderTargetDisconnectAndPolicyRevocation = senderTargetDisconnectAndPolicyRevocation,
	unavailableIdentityCannotHoldLeadership = unavailableIdentityCannotHoldLeadership,
	invitationCooldownAndCountBounds = invitationCooldownAndCountBounds,
	partyBoundsShutdownAndClockFailure = partyBoundsShutdownAndClockFailure,
	projectionRevisionAndImmutableDeadlines = projectionRevisionAndImmutableDeadlines,
	strictProjectionAndPayloadSchemas = strictProjectionAndPayloadSchemas,
}
