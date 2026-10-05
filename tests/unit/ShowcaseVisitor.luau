--!strict

local Showcase = require("../../src/server/domains/social/ShowcaseService")
local Policy = require("../../src/shared/config/ShowcasePolicy")
local Contract = require("../../src/shared/contracts/ShowcaseProjectionV1")
local Project = require("../../src/server/application/ShowcaseProjection")
local Store = require("../../src/client/store/ShowcaseProjectionStore")
local Wire = require("../../src/shared/contracts/WireValidation")
local Schema = require("../../src/server/infrastructure/persistence/ProfileSchemaV1")
local Session = require("../../src/server/infrastructure/persistence/ProfileSession")
local Coordinator = require("../../src/server/application/SessionCoordinator")
local Queue = require("../../src/server/infrastructure/persistence/SingleWriterQueue")
local Retry = require("../../src/server/infrastructure/persistence/RetryPolicy")
local Repository = require("../fixtures/FakeProfileRepository")
local Production = require("../../src/server/domains/vault/VaultProductionService")
local Config = require("../../src/shared/config/VaultProductionFixture")
local Vault = require("../../src/server/domains/vault/VaultService")
local Capacity = require("../../src/shared/config/VaultCapacityFixture")
local Assignments = require("../../src/server/application/VaultProductionUseCase")
local AssignmentContract = require("../../src/shared/contracts/VaultAssignmentProjectionV1")
local Routes = require("../../src/shared/contracts/RouteIds")
local Registry = require("../../src/server/application/RouteRegistry")
local Gateway = require("../../src/server/application/NetworkingGateway")
local Rate = require("../../src/server/application/NetworkRateLimiter")
local Replay = require("../../src/server/application/ReplayWindow")
local Publisher = require("../../src/server/application/ProjectionPublisher")
local Projection = require("../../src/shared/contracts/ProjectionV1")
local Protocol = require("../../src/shared/contracts/ProtocolV1")
local Codes = require("../../src/shared/contracts/ResultCodes")
local ClientGateway = require("../../src/client/networking/ClientGateway")
local ProjectionStore = require("../../src/client/store/ProjectionStore")
local function check(value: any, why: string?): any
	return assert(value, why or "Showcase/Visitor invariant")
end
local function creature(id: string, owner: number): any
	return {
		creatureInstanceId = id,
		ownerUserId = owner,
		speciesId = "species/fixture-orb",
		operationId = "capture-" .. id,
		securedAt = 1000,
		locked = true,
		overflowHeld = false,
		origin = { spawnContextId = "private-spawn", contentSnapshotId = "content/fixture" },
		variantIdentity = {
			speciesRarityId = "rarity/legendary",
			variantSignature = "private-signature",
			contentSnapshotId = "content/fixture",
			spawnContextId = "private-spawn",
			mutationIdsCanonical = { "mutation/neon" },
			traitIds = { "trait/calm" },
			protectedVariantReasons = { "Legendary" },
		},
	}
end
local function fixture(): any
	local f: any = {
		players = {},
		sessions = {},
		present = {},
		allow = {},
		parties = {},
		reads = 0,
		repository = Repository.new(),
		production = Production.new(Config),
		at = 100,
		ids = 0,
		locks = 0,
	}
	f.clock = function()
		return f.at
	end
	f.advance = function(n: number)
		f.at += n
	end
	f.acquire = function(id: number)
		f.locks += 1
		local session = Session.new({
			userId = id,
			lockId = "showcase-lock-" .. f.locks,
			jobId = "showcase-test",
			repository = f.repository,
			schema = Schema,
			queue = Queue.new(f.clock, f.advance, 5),
			retry = Retry.new(f.clock, f.advance, function()
				return 0.5
			end, 3),
			unixSeconds = function()
				return 1000 + math.floor(f.at)
			end,
			monotonicSeconds = f.clock,
		})
		check(session.acquire().status == "Ready")
		f.sessions[id] = session
		session.subscribe(function()
			if f.owner then
				f.owner.profileChanged(id, session)
			end
		end)
		return session
	end
	for id = 1, 8 do
		local p = Schema.default(1000)
		check(Vault.new(Capacity).prepare(p).status == "Prepared")
		check(f.production.prepareLoad(p, 1000).status == "Prepared")
		local first, second = "creature-" .. id .. "-a", "creature-" .. id .. "-b"
		p.collection.creaturesById =
			{ [first] = creature(first, id), [second] = creature(second, id) }
		p.vault.displayAssignments["display/1"] = first
		p.economy.energyUnits, p.vault.productionBufferMilli = 75, 1234
		p.commerce = { Supporter = true, VaultClub = true, privateReceipt = "do-not-disclose" }
		p.settings = { privatePreference = true }
		check(Schema.validate(p))
		f.repository.seed("player/" .. id, p)
		f.players[id], f.present[id], f.allow[id] =
			{ UserId = id, DisplayName = "Owner " .. id }, true, true
		f.acquire(id)
	end
	f.options = {
		policy = table.clone(Policy),
		contract = Contract,
		wire = Wire,
		context = function(id)
			return if f.present[id]
				then {
					player = f.players[id],
					session = f.sessions[id],
					ready = f.sessions[id].state() == "Ready",
				}
				else nil
		end,
		eligible = function(a, b, audience)
			return f.allow[b.UserId]
				and (
					audience == "SameServer"
					or (
						audience == "Party"
						and f.parties[a.UserId] ~= nil
						and f.parties[a.UserId] == f.parties[b.UserId]
					)
				)
		end,
		presentation = function(player, session)
			f.reads += 1
			local result = Project.fromProfile(session.snapshot(), player.UserId, f.production)
			if f.afterRead then
				f.afterRead()
			end
			return result
		end,
		monotonicSeconds = f.clock,
		presentationSeconds = f.clock,
		newId = function()
			f.ids += 1
			return string.format("%048d", f.ids)
		end,
	}
	f.owner = Showcase.new(f.options)
	f.permission = function(id)
		return f.owner.snapshot(f.players[id]).state
	end
	f.view = function(id)
		return f.owner.viewSnapshot(f.players[id]).state
	end
	f.revision = function(id)
		return f.permission(id).permissionRevision
	end
	f.policy = function(id, audience)
		return f.owner.setPolicy(f.players[id], audience, f.revision(id))
	end
	f.grant = function(id, target)
		check(f.owner.grant(f.players[id], target, f.revision(id)) == "OK_SHOWCASE_GRANTED")
		return f.permission(target).incoming[#f.permission(target).incoming]
	end
	f.active = function()
		check(f.policy(1, "SameServer") == "OK_SHOWCASE_POLICY")
		local g = f.grant(1, 2)
		check(f.owner.open(f.players[2], 1, g.id) == "OK_SHOWCASE_READ_ONLY")
		return g
	end
	f.change = function(id, mutate)
		f.ids += 1
		check(f.sessions[id].checkpoint("fixture-update-" .. f.ids, mutate).status == "Committed")
	end
	f.replace = function(id)
		local old = f.sessions[id]
		check(old.release(f.at + 5).status == "Closed")
		f.acquire(id)
		f.owner.profileChanged(id, f.sessions[id])
		return old
	end
	return f
end
local function network(f: any): any
	local c = Routes.commands
	local schemas = {
		[c.socialShowcaseSetPolicy] = Contract.validPolicy,
		[c.socialShowcaseGrant] = Contract.validGrant,
		[c.socialShowcaseRevoke] = Contract.validRevoke,
		[c.socialShowcaseOpen] = Contract.validOpen,
		[c.socialShowcaseClose] = Contract.validClose,
	}
	local ops = {
		[c.socialShowcaseSetPolicy] = function(p: any, e: any)
			return f.owner.setPolicy(p, e.payload.audience, e.expectedRevision)
		end,
		[c.socialShowcaseGrant] = function(p: any, e: any)
			return f.owner.grant(p, e.payload.targetUserId, e.expectedRevision)
		end,
		[c.socialShowcaseRevoke] = function(p: any, e: any)
			return f.owner.revoke(p, e.payload.grantId, e.expectedRevision)
		end,
		[c.socialShowcaseOpen] = function(p: any, e: any)
			return f.owner.open(p, e.payload.ownerUserId, e.payload.grantId)
		end,
		[c.socialShowcaseClose] = function(p: any, e: any)
			return f.owner.close(p, e.payload.grantId)
		end,
	}
	local serial = 0
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
			emit = function() end,
		}),
		getSession = function(player)
			local s = f.sessions[player.UserId]
			return if f.players[player.UserId] == player
					and f.present[player.UserId]
					and s.state() == "Ready"
				then { status = "Ready", identity = s }
				else { status = "Protected" }
		end,
		emitReliable = function() end,
		emitUnreliable = function() end,
		routeHandlers = ops,
	})
	return {
		gateway = gateway,
		send = function(id, route, payload, expected, request)
			serial += 1
			return gateway.handle(f.players[id], {
				protocolVersion = 1,
				routeId = route,
				requestId = request or "showcase-test-" .. serial,
				payload = payload,
				expectedRevision = expected,
			}).code
		end,
	}
end
local tests = {}
function tests.explicitGrantAndVisitorConsent()
	local f = fixture()
	check(f.policy(1, "SameServer") == "OK_SHOWCASE_POLICY")
	local g = f.grant(1, 2)
	check(f.view(2).mode == "Closed" and f.reads == 0)
	check(f.owner.open(f.players[2], 1, g.id) == "OK_SHOWCASE_READ_ONLY")
	check(f.view(2).mode == "ReadOnly" and f.view(2).ownerDisplayName == "Owner 1")
end
function tests.defaultClosedAndNoSelfAuthorization()
	local f = fixture()
	check(f.permission(1).audience == "Closed")
	check(f.owner.grant(f.players[1], 2, f.revision(1)) == "REJECT_PERMISSION_SHOWCASE_AUDIENCE")
	check(f.owner.open(f.players[2], 1, "forged") == "REJECT_PERMISSION_SHOWCASE_VISITOR")
	check(
		f.owner.setPolicy({ UserId = 1 }, "SameServer", f.revision(1))
			== "REJECT_STATE_SHOWCASE_SESSION"
	)
end
function tests.foreignIdentityAndNoTransfer()
	local f, g = fixture(), nil
	g = f.active()
	check(f.owner.open(f.players[3], 1, g.id) == "REJECT_PERMISSION_SHOWCASE_VISITOR")
	check(f.owner.open(f.players[2], 3, g.id) == "REJECT_PERMISSION_SHOWCASE_VISITOR")
	check(f.owner.grant(f.players[1], 1, f.revision(1)) == "REJECT_PERMISSION_SHOWCASE_SELF")
	check(f.owner.grant(f.players[1], 999, f.revision(1)) == "REJECT_STATE_SHOWCASE_TARGET")
	check(f.owner.revoke(f.players[2], g.id, f.revision(2)) == "REJECT_PERMISSION_SHOWCASE_OWNER")
end
function tests.audiencePartyAndChallengeIndependence()
	local f = fixture()
	f.parties[1], f.parties[2] = "party", "party"
	f.players[2].challengeParticipant = true
	check(f.owner.open(f.players[2], 1, "none") == "REJECT_PERMISSION_SHOWCASE_VISITOR")
	check(f.policy(1, "Party") == "OK_SHOWCASE_POLICY")
	check(f.owner.grant(f.players[1], 3, f.revision(1)) == "REJECT_PERMISSION_SHOWCASE_AUDIENCE")
	local g = f.grant(1, 2)
	check(f.owner.open(f.players[2], 1, g.id) == "OK_SHOWCASE_READ_ONLY")
	f.parties[2] = nil
	f.owner.refreshAudience(2)
	check(f.view(2).reason == "PolicyChanged")
	check(f.policy(1, "SameServer") == "OK_SHOWCASE_POLICY")
	check(f.grant(1, 3) ~= nil)
end
function tests.recipientSuppressionRevokes()
	local f = fixture()
	f.active()
	f.allow[2] = false
	f.owner.refreshAudience(2)
	check(f.view(2).mode == "Closed" and #f.permission(1).visitors == 0)
	check(f.owner.grant(f.players[1], 2, f.revision(1)) == "REJECT_PERMISSION_SHOWCASE_AUDIENCE")
end
function tests.explicitRevokeAndClose()
	local f = fixture()
	local g = f.active()
	check(f.owner.revoke(f.players[1], g.id, f.revision(1)) == "OK_SHOWCASE_REVOKED")
	check(f.view(2).reason == "Revoked" and #f.permission(2).incoming == 0)
	check(f.owner.open(f.players[2], 1, g.id) == "REJECT_PERMISSION_SHOWCASE_VISITOR")
	local nextGrant = f.grant(1, 2)
	check(f.owner.open(f.players[2], 1, nextGrant.id) == "OK_SHOWCASE_READ_ONLY")
	check(f.owner.close(f.players[2], nextGrant.id) == "OK_SHOWCASE_CLOSED")
	check(f.view(2).reason == "Left" and f.owner.counts().grants == 0)
end
function tests.policyChangeRequiresFreshGrant()
	local f = fixture()
	local g = f.active()
	check(f.policy(1, "Closed") == "OK_SHOWCASE_POLICY")
	check(f.view(2).reason == "PolicyChanged")
	check(f.policy(1, "SameServer") == "OK_SHOWCASE_POLICY")
	check(f.owner.open(f.players[2], 1, g.id) == "REJECT_PERMISSION_SHOWCASE_VISITOR")
end
function tests.multipleVisitorsAndOwnerBound()
	local f = fixture()
	f.active()
	local g = f.grant(1, 3)
	check(f.owner.open(f.players[3], 1, g.id) == "OK_SHOWCASE_READ_ONLY")
	check(f.owner.grant(f.players[1], 4, f.revision(1)) == "REJECT_STATE_SHOWCASE_BOUND")
	check(f.owner.counts().visits == 2 and f.view(2).ownerUserId == f.view(3).ownerUserId)
	check(f.reads == 1, "one filtered owner read shared by visitors")
	local bounded = fixture()
	bounded.options.policy.maxLiveUsers = 3
	bounded.active()
	bounded.grant(1, 3)
	check(
		bounded.owner.grant(bounded.players[1], 4, bounded.revision(1))
			== "REJECT_STATE_SHOWCASE_TARGET"
	)
	check(bounded.owner.counts().liveUsers == 3)
end
function tests.incomingAndActiveViewBounds()
	local f = fixture()
	f.active()
	check(f.policy(3, "SameServer") == "OK_SHOWCASE_POLICY")
	local g = f.grant(3, 2)
	check(f.owner.open(f.players[2], 3, g.id) == "REJECT_STATE_SHOWCASE_BUSY")
	check(f.policy(4, "SameServer") == "OK_SHOWCASE_POLICY")
	check(f.owner.grant(f.players[4], 2, f.revision(4)) == "REJECT_STATE_SHOWCASE_BOUND")
end
function tests.ownerDisconnect()
	local f = fixture()
	local g = f.active()
	f.present[1] = false
	check(f.owner.disconnect(f.players[1], f.sessions[1]))
	check(f.view(2).reason == "Disconnected" and f.owner.counts().grants == 0)
	check(f.owner.open(f.players[2], 1, g.id) == "REJECT_PERMISSION_SHOWCASE_VISITOR")
end
function tests.visitorDisconnect()
	local f = fixture()
	f.active()
	f.present[2] = false
	check(f.owner.disconnect(f.players[2], f.sessions[2]))
	check(#f.permission(1).visitors == 0 and f.owner.counts().visits == 0)
end
function tests.ownerSessionReplacement()
	local f = fixture()
	local g = f.active()
	local prior = f.revision(1)
	local old = f.replace(1)
	check(f.permission(1).audience == "Closed" and f.revision(1) ~= prior)
	check(f.view(2).mode == "Closed")
	check(f.owner.setPolicy(f.players[1], "SameServer", prior) == "REJECT_STATE_SHOWCASE_REVISION")
	f.owner.profileChanged(1, old)
	check(
		f.owner.counts().grants == 0
			and f.owner.open(f.players[2], 1, g.id) == "REJECT_PERMISSION_SHOWCASE_VISITOR"
	)
end
function tests.visitorSessionReplacement()
	local f = fixture()
	local g = f.active()
	local old = f.replace(2)
	check(f.view(2).mode == "Closed" and #f.permission(1).visitors == 0)
	check(f.owner.open(f.players[2], 1, g.id) == "REJECT_PERMISSION_SHOWCASE_VISITOR")
	check(not f.owner.disconnect(f.players[2], old))
end
function tests.playerReplacementAndStaleCleanup()
	local f = fixture()
	f.active()
	local old = f.players[2]
	f.players[2] = { UserId = 2, DisplayName = "Replacement" }
	f.owner.observe(2)
	check(f.owner.counts().grants == 0)
	check(not f.owner.disconnect(old, f.sessions[2]))
end
function tests.replayedGrantCannotRenew()
	local f = fixture()
	local g = f.active()
	f.advance(10)
	check(f.owner.grant(f.players[1], 2, f.revision(1)) == "OK_SHOWCASE_ALREADY_GRANTED")
	check(f.permission(2).incoming[1].expiresAt == g.expiresAt and f.owner.counts().grants == 1)
end
function tests.staleRevokeAndGrantCannotResurrect()
	local f = fixture()
	local g = f.active()
	local before = f.revision(1)
	check(f.owner.revoke(f.players[1], g.id, before) == "OK_SHOWCASE_REVOKED")
	local nextGrant = f.grant(1, 2)
	check(f.owner.revoke(f.players[1], g.id, before) == "REJECT_STATE_SHOWCASE_REVISION")
	check(f.owner.grant(f.players[1], 2, before) == "REJECT_STATE_SHOWCASE_REVISION")
	check(f.permission(1).visitors[1].id == nextGrant.id)
end
function tests.expiryCannotResurrect()
	local f = fixture()
	local g = f.active()
	f.advance(60)
	f.owner.expire()
	check(f.view(2).reason == "Expired" and f.owner.nextDeadline() == nil)
	check(f.owner.open(f.players[2], 1, g.id) == "REJECT_PERMISSION_SHOWCASE_VISITOR")
	f.at = 0 / 0
	check(f.owner.grant(f.players[1], 3, f.revision(1)) == "REJECT_STATE_SHOWCASE_SESSION")
end
function tests.staleProjectionAfterRevoke()
	local f = fixture()
	local g = f.active()
	f.afterRead = function()
		f.afterRead = nil
		check(f.owner.revoke(f.players[1], g.id, f.revision(1)) == "OK_SHOWCASE_REVOKED")
	end
	check(f.view(2).mode == "Closed" and f.view(2).reason == "Revoked")
end
function tests.staleProjectionAfterProfileChange()
	local f = fixture()
	f.active()
	f.afterRead = function()
		f.afterRead = nil
		f.change(1, function(p)
			p.vault.displayAssignments["display/1"] = nil
		end)
	end
	check(f.view(2).mode == "Closed", "stale read discarded")
	check(#f.view(2).creatures == 0, "fresh read cannot recreate display")
end
function tests.exactIdentityAndHiddenFields()
	local f = fixture()
	f.active()
	local row = f.view(2).creatures[1]
	check(row.creatureInstanceId == "creature-1-a" and row.speciesRarityId == "rarity/legendary")
	check(row.mutationIds[1] == "mutation/neon" and row.traitIds[1] == "trait/calm")
	check(
		row.displaySlotId == "display/1"
			and row.locked == nil
			and row.operationId == nil
			and row.origin == nil
	)
	for _, field in
		{
			"profile",
			"profileRevision",
			"energyUnits",
			"bufferMilli",
			"production",
			"commerce",
			"discovery",
			"settings",
			"progression",
			"mastery",
			"session",
			"variantSignature",
		}
	do
		check(f.view(2)[field] == nil)
	end
	f.change(1, function(p)
		p.vault.displayAssignments["display/1"] = "creature-1-b"
	end)
	check(
		f.view(2).creatures[1].creatureInstanceId == "creature-1-b",
		"same species retains distinct instance"
	)
end
function tests.invalidDisplayReferencesFailClosed()
	local f = fixture()
	local p = f.sessions[1].snapshot()
	for _, change in
		{
			function()
				p.collection.creaturesById["creature-1-a"].ownerUserId = 2
			end,
			function()
				p.collection.creaturesById["creature-1-a"].overflowHeld = true
			end,
			function()
				p.vault.productionAssignments["production/1"] = "creature-1-a"
			end,
			function()
				p.collection.creaturesById["creature-1-a"] = nil
			end,
		}
	do
		change()
		check(#Project.fromProfile(p, 1, f.production).creatures == 0)
	end
	check(#Project.fromProfile(f.sessions[1].snapshot(), 1, f.production).creatures == 1)
end
function tests.profileChangeRefreshesWithoutPolling()
	local f = fixture()
	f.active()
	check(#f.view(2).creatures == 1)
	f.owner.takeChanges()
	f.change(1, function(p)
		p.vault.displayAssignments["display/1"] = nil
	end)
	check(table.find(f.owner.takeChanges(), 2) ~= nil)
	check(#f.view(2).creatures == 0)
end
function tests.noProfileOrValueMutation()
	local f = fixture()
	local before = {}
	local calls = f.repository.calls()
	for id = 1, 8 do
		before[id] = f.sessions[id].snapshot()
	end
	local g = f.active()
	f.view(2)
	check(f.owner.close(f.players[2], g.id) == "OK_SHOWCASE_CLOSED")
	for id = 1, 8 do
		check(Wire.equal(before[id], f.sessions[id].snapshot()))
	end
	check(f.repository.calls() == calls, "permission/presentation performs no storage writes")
end
function tests.paidStatusNeverGrantsAuthority()
	local f = fixture()
	for _, audience in { "Closed", "Party" } do
		check(f.policy(1, audience) == "OK_SHOWCASE_POLICY")
		check(
			f.owner.grant(f.players[1], 2, f.revision(1)) == "REJECT_PERMISSION_SHOWCASE_AUDIENCE"
		)
	end
	f.allow[2] = false
	check(f.policy(1, "SameServer") == "OK_SHOWCASE_POLICY")
	check(f.owner.grant(f.players[1], 2, f.revision(1)) == "REJECT_PERMISSION_SHOWCASE_AUDIENCE")
end
function tests.shutdownAndLateCallbacks()
	local f = fixture()
	local g = f.active()
	local s = f.sessions[1]
	f.owner.stop()
	f.owner.profileChanged(1, s)
	f.owner.observe(2)
	f.owner.expire()
	for _, n in f.owner.counts() do
		check(n == 0)
	end
	check(
		f.owner.nextDeadline() == nil
			and f.owner.open(f.players[2], 1, g.id) == "REJECT_STATE_SHOWCASE_SESSION"
	)
end
function tests.hostileSchemasAndPrivateInspection()
	local f, c = fixture(), Routes.commands
	local n = network(f)
	local hostile: { any } = {
		{ targetUserId = 2, ownerUserId = 1 },
		{ targetUserId = 2, session = "forged" },
		{ targetUserId = 2, fields = { "commerce", "energyUnits" } },
		{ targetUserId = -1 },
		{ targetUserId = 0 / 0 },
		{ targetUserId = 2, text = string.rep("a", 300) },
	}
	for _, payload in hostile do
		check(
			string.find(
				n.send(1, c.socialShowcaseGrant, payload, f.revision(1)),
				"REJECT_VALIDATION_",
				1,
				true
			) == 1
		)
		f.advance(3)
	end
	check(
		n.send(
			2,
			c.socialShowcaseOpen,
			{ ownerUserId = 1, grantId = "unknown", fields = { "profile" } }
		) == "REJECT_VALIDATION_PAYLOAD"
	)
	check(f.owner.counts().grants == 0)
end
function tests.gatewayReplayRateAndSessionFence()
	local f, c = fixture(), Routes.commands
	local n = network(f)
	check(
		n.send(1, c.socialShowcaseSetPolicy, { audience = "SameServer" }, f.revision(1))
			== "OK_SHOWCASE_POLICY"
	)
	local rev = f.revision(1)
	check(
		n.send(1, c.socialShowcaseGrant, { targetUserId = 2 }, rev, "grant-replay")
			== "OK_SHOWCASE_GRANTED"
	)
	check(
		n.send(1, c.socialShowcaseGrant, { targetUserId = 3 }, f.revision(1))
			== Codes.rejectRateLimit
	)
	f.advance(3)
	check(
		n.send(1, c.socialShowcaseGrant, { targetUserId = 2 }, rev, "grant-replay")
			== "OK_SHOWCASE_GRANTED"
	)
	check(f.owner.counts().grants == 1)
	f.replace(1)
	f.advance(3)
	check(
		n.send(1, c.socialShowcaseGrant, { targetUserId = 2 }, rev, "grant-replay")
			== "REJECT_VALIDATION_REQUEST_REUSE"
	)
	check(f.owner.counts().grants == 0)
end
function tests.visitorCannotMutateOwner()
	local f = fixture()
	f.active()
	local assignments = Assignments.new({
		production = f.production,
		vault = Vault.new(Capacity),
		unixSeconds = function()
			return 1000 + f.at
		end,
		monotonicSeconds = f.clock,
		newOperationId = function()
			return "foreign-write"
		end,
	})
	local before = f.sessions[1].snapshot()
	local result = assignments.assign(
		f.sessions[2],
		"display",
		"display/1",
		"creature-1-a",
		f.sessions[2].snapshot().profileRevision
	)
	check(result.status == "Rejected" and result.reason == "OWNERSHIP")
	check(
		not AssignmentContract.validAssignment(
			{ slotId = "display/1", creatureInstanceId = "creature-1-a", ownerUserId = 1 },
			1
		)
	)
	check(not AssignmentContract.validClaim({ ownerUserId = 1 }, 1))
	check(Wire.equal(before, f.sessions[1].snapshot()))
end
function tests.boundedReadbackAndNoPartialIntrinsicFacts()
	local f = fixture()
	f.active()
	f.grant(1, 3)
	check(f.policy(4, "SameServer") == "OK_SHOWCASE_POLICY")
	f.grant(4, 1)
	check(f.policy(5, "SameServer") == "OK_SHOWCASE_POLICY")
	f.grant(5, 1)
	for id = 1, 5 do
		for _, p in { f.owner.snapshot(f.players[id]), f.owner.viewSnapshot(f.players[id]) } do
			check(Contract.validSnapshot(p) and Wire.payload(p))
		end
	end
	f.change(1, function(p)
		local traits = {}
		for i = 1, 16 do
			table.insert(traits, string.rep("t", 125) .. string.format("%03d", i))
		end
		p.collection.creaturesById["creature-1-a"].variantIdentity.traitIds = traits
	end)
	local p = f.owner.viewSnapshot(f.players[2])
	check(
		#p.state.creatures == 0
			and p.state.hasMore
			and Contract.validSnapshot(p)
			and Wire.payload(p)
	)
end
function tests.storeOrderingExpiryAndIsolation()
	local f = fixture()
	local g = f.active()
	local store = Store.new(Contract, Wire, f.clock)
	local old = f.owner.viewSnapshot(f.players[2])
	check(store.snapshot(old) == "Showcase")
	local copy = store.view()
	copy.visit.state.creatures[1].speciesId = "forged"
	check(store.view().visit.state.creatures[1].speciesId == "species/fixture-orb")
	check(f.owner.revoke(f.players[1], g.id, f.revision(1)) == "OK_SHOWCASE_REVOKED")
	check(store.snapshot(f.owner.viewSnapshot(f.players[2])) == "Showcase")
	check(store.snapshot(old) == "Stale" and store.view().visit.state.reason == "Revoked")
	local nextGrant = f.grant(1, 2)
	f.owner.open(f.players[2], 1, nextGrant.id)
	check(store.snapshot(f.owner.viewSnapshot(f.players[2])) == "Showcase")
	f.advance(60)
	check(store.view().visit.state.reason == "Expired" and store.nextDeadline() == nil)
end
function tests.clientProtectedReadbackAndWatermarks()
	local f = fixture()
	f.active()
	local sessionStore, showcaseStore =
		ProjectionStore.new(Projection, Wire), Store.new(Contract, Wire, f.clock)
	local client = ClientGateway.new({
		protocol = Protocol,
		routes = Routes,
		resultCodes = Codes,
		wire = Wire,
		store = sessionStore,
		showcaseStore = showcaseStore,
		showcaseProjection = Contract,
		sendCommand = function() end,
	})
	local p = f.owner.viewSnapshot(f.players[2])
	local e = {
		protocolVersion = 1,
		routeId = Routes.events.socialStateChanged,
		revision = p.revision,
		payload = p,
	}
	check(client.handleEvent(e) == "Stale")
	check(sessionStore.snapshot({
		domain = "session",
		revision = 1,
		state = { status = "Ready", profileRevision = 1 },
	}) == "Applied")
	check(client.handleEvent(e) == "Showcase")
	showcaseStore.invalidate()
	check(client.handleEvent(e) == "Stale" and showcaseStore.view().visit.state.mode == "Closed")
end
function tests.writerAndCoordinatorObserverFences()
	local f = fixture()
	local changes = {}
	local pending = {}
	local coordinator = Coordinator.new({
		createSession = function(id)
			return {
				state = function()
					return "Ready"
				end,
				acquire = function()
					return { status = "Ready" }
				end,
				release = function()
					return { status = "Closed" }
				end,
				subscribe = function(fn)
					pending[id] = fn
					return function()
						pending[id] = nil
					end
				end,
			}
		end,
		unixSeconds = f.clock,
		monotonicSeconds = f.clock,
		spawn = function(fn)
			fn()
		end,
		waitSeconds = f.advance,
	})
	local off = coordinator.subscribe(function(id, s)
		table.insert(changes, { id, s })
	end)
	coordinator.open(20)
	local stale = pending[20]
	stale()
	check(#changes == 1)
	coordinator.close(20, f.at + 5)
	coordinator.open(20)
	stale()
	check(#changes == 1)
	pending[20]()
	check(#changes == 2)
	off()
	pending[20]()
	check(#changes == 2)
	-- A failing presentation observer cannot alter a successful durable checkpoint.
	local repo = Repository.new()
	local s = Session.new({
		userId = 99,
		lockId = "notify",
		jobId = "notify",
		repository = repo,
		schema = Schema,
		queue = Queue.new(f.clock, f.advance, 5),
		retry = Retry.new(f.clock, f.advance, function()
			return 0.5
		end, 3),
		unixSeconds = function()
			return 1000
		end,
		monotonicSeconds = f.clock,
	})
	check(s.acquire().status == "Ready")
	local detach = s.subscribe(function()
		error("presentation failed")
	end)
	check(s.checkpoint("notify-write", function(p)
		p.economy.energyUnits = 7
	end).status == "Committed")
	check(s.snapshot().economy.energyUnits == 7 and s.state() == "Ready")
	detach()
	check(s.release(f.at + 5).status == "Closed")
end
return tests
