--!strict

local Protocol = require("../../src/shared/contracts/ProtocolV1")
local Routes = require("../../src/shared/contracts/RouteIds")
local Codes = require("../../src/shared/contracts/ResultCodes")
local Wire = require("../../src/shared/contracts/WireValidation")
local SessionContract = require("../../src/shared/contracts/ProjectionV1")
local Contract = require("../../src/shared/contracts/SecuredCollectionProjectionV1")
local Builder = require("../../src/server/application/SecuredCollectionProjection")
local SessionStore = require("../../src/client/store/ProjectionStore")
local CollectionStore = require("../../src/client/store/SecuredCollectionStore")
local ClientGateway = require("../../src/client/networking/ClientGateway")
local ServerGateway = require("../../src/server/application/NetworkingGateway")
local Publisher = require("../../src/server/application/ProjectionPublisher")
local Registry = require("../../src/server/application/RouteRegistry")
local Rate = require("../../src/server/application/NetworkRateLimiter")
local Replay = require("../../src/server/application/ReplayWindow")

local function check(condition: any, message: string?)
	assert(condition, message or "secured collection projection invariant")
end

local function profile(owner: number, revision: number): any
	return {
		profileRevision = revision,
		recentOperations = {},
		collection = { creaturesById = {} },
		owner = owner,
	}
end

local function add(profileValue: any, id: string, revision: number, owner: number?)
	local operationId = "op-" .. id
	profileValue.recentOperations[operationId] = revision
	profileValue.collection.creaturesById[id] = {
		creatureInstanceId = id,
		operationId = operationId,
		ownerUserId = owner,
		securedAt = 1_700_000_000 + revision,
	}
end

local function boundedRecentSummaryUsesDurableOperationOrder()
	local owned = profile(42, 9)
	for index = 1, 7 do
		add(owned, "creature-" .. index, index + 1, 42)
	end
	add(owned, "foreign", 99, 43)
	local summary = Builder.fromProfile(owned, 42)
	check(Contract.validState(summary), "bounded valid ownership summary")
	check(Wire.payload({ domain = "securedCollection", revision = 9, state = summary }))
	check(summary.hasMore and #summary.creatureInstanceIds == 5, "overflow is explicit")
	for index, id in summary.creatureInstanceIds do
		check(id == "creature-" .. (8 - index), "most recent durable operations first")
	end
	check(owned.collection.creaturesById["creature-1"] ~= nil, "projection does not mutate profile")
	local fresh = Builder.fromProfile(owned, 42)
	check(Wire.equal(summary, fresh), "fresh-server profile yields the same exact IDs")
	local largest = profile(42, 10)
	for index = 1, 5 do
		add(largest, string.rep(tostring(index), 128), index + 1, 42)
	end
	local longIds = Builder.fromProfile(largest, 42)
	check(#longIds.creatureInstanceIds == 3 and longIds.hasMore, "long valid IDs remain bounded")
	check(
		Wire.payload({
			domain = "securedCollection",
			revision = 10,
			state = longIds,
		}),
		"maximum contracted IDs fit the reliable wire budget"
	)
	local empty = Builder.fromProfile(profile(42, 0), 42)
	check(
		Contract.validState(empty) and #empty.creatureInstanceIds == 0,
		"revision zero ready profile has empty snapshot"
	)
	local foreign = Builder.fromProfile(owned, 43)
	check(#foreign.creatureInstanceIds == 1 and foreign.creatureInstanceIds[1] == "foreign")
	local legacy = profile(42, 2)
	add(legacy, "legacy", 2, nil)
	check(Builder.fromProfile(legacy, 42).creatureInstanceIds[1] == "legacy")
end

local function clientRejectsUntrustedOrStaleCollectionSnapshots()
	local session = SessionStore.new(SessionContract, Wire)
	local collection = CollectionStore.new(Contract, Wire)
	local gateway = ClientGateway.new({
		protocol = Protocol,
		routes = Routes,
		resultCodes = Codes,
		wire = Wire,
		store = session,
		securedCollectionProjection = Contract,
		securedCollectionStore = collection,
		sendCommand = function() end,
	})
	local function snapshot(domain: string, revision: number, state: any): any
		return {
			protocolVersion = 1,
			routeId = Routes.events.projectionSnapshot,
			revision = revision,
			payload = { domain = domain, revision = revision, state = state },
		}
	end
	local owned = snapshot("securedCollection", 2, {
		profileRevision = 2,
		creatureInstanceIds = { "same-creature" },
		hasMore = false,
	})
	check(gateway.handleEvent(owned) == "Invalid", "ownership before ready is rejected")
	check(collection.view() == nil)
	check(
		gateway.handleEvent(snapshot("session", 1, { status = "Ready", profileRevision = 2 }))
			== "Applied"
	)
	check(gateway.handleEvent(owned) == "Applied")
	local view = collection.view()
	check(#view.creatureInstanceIds == 1 and view.creatureInstanceIds[1] == "same-creature")
	view.creatureInstanceIds[1] = "tampered"
	check(collection.view().creatureInstanceIds[1] == "same-creature", "view is disposable copy")
	check(gateway.handleEvent(owned) == "Stale", "duplicate projection cannot duplicate the ID")
	local duplicate = snapshot("securedCollection", 2, {
		profileRevision = 2,
		creatureInstanceIds = { "same-creature", "same-creature" },
		hasMore = false,
	})
	check(gateway.handleEvent(duplicate) == "Invalid")
	local conflicting = snapshot("securedCollection", 2, {
		profileRevision = 2,
		creatureInstanceIds = { "other-creature" },
		hasMore = false,
	})
	check(gateway.handleEvent(conflicting) == "Invalid", "same revision cannot change content")
	local oversized = snapshot("securedCollection", 2, {
		profileRevision = 2,
		creatureInstanceIds = { "1", "2", "3", "4", "5", "6" },
		hasMore = true,
	})
	check(gateway.handleEvent(oversized) == "Invalid")
	check(
		gateway.handleEvent(snapshot("session", 2, { status = "Ready", profileRevision = 3 }))
			== "Applied"
	)
	check(collection.view() == nil, "new profile revision invalidates old summary")
	check(gateway.handleEvent(owned) == "Invalid", "old profile revision cannot re-enter store")
	check(gateway.handleEvent(snapshot("session", 3, { status = "Protected" })) == "Applied")
	check(collection.view() == nil, "protected state has no ownership projection")
	gateway.reset()
	check(session.view() == nil and collection.view() == nil, "rejoin clears disposable stores")
end

local function freshServerRejoinProjectsExactOwnedIdOnce()
	local profiles: { [number]: any } = { [42] = profile(42, 2), [43] = profile(43, 2) }
	add(profiles[42], "same-creature", 2, 42)
	add(profiles[43], "other-creature", 2, 43)
	local function server()
		local emitted: { any } = {}
		local function emit(player, envelope)
			table.insert(emitted, { userId = player.UserId, envelope = envelope })
		end
		local gateway = ServerGateway.new({
			protocol = Protocol,
			routes = Routes,
			resultCodes = Codes,
			wire = Wire,
			registry = Registry.new(Routes),
			rate = Rate.new(function()
				return 0
			end),
			replay = Replay.new(function()
				return 0
			end, Wire),
			projection = Publisher.new({
				protocol = Protocol,
				routes = Routes,
				projection = SessionContract,
				wire = Wire,
				emit = emit,
			}),
			securedCollectionProjection = Contract,
			getSession = function(player)
				local owned = profiles[player.UserId]
				return {
					status = "Ready",
					profileRevision = owned.profileRevision,
					securedCollection = Builder.fromProfile(owned, player.UserId),
				}
			end,
			emitReliable = emit,
			emitUnreliable = function() end,
		})
		return gateway, emitted
	end
	local function client()
		local session = SessionStore.new(SessionContract, Wire)
		local collection = CollectionStore.new(Contract, Wire)
		return ClientGateway.new({
			protocol = Protocol,
			routes = Routes,
			resultCodes = Codes,
			wire = Wire,
			store = session,
			securedCollectionProjection = Contract,
			securedCollectionStore = collection,
			sendCommand = function() end,
		}),
			collection,
			session
	end
	local player = { UserId = 42 }
	for _ = 1, 2 do -- Second iteration represents a new server and client process.
		local serverGateway, emitted = server()
		local clientGateway, collection, sessionStore = client()
		local outcome = serverGateway.handle(player, {
			protocolVersion = 1,
			routeId = Routes.commands.sessionClientHello,
			requestId = "hello",
			payload = {},
		})
		check(outcome.code == "OK_SESSION_READY", "ready handshake: " .. tostring(outcome.code))
		local ownershipSnapshots = 0
		for _, delivery in emitted do
			check(delivery.userId == 42, "private owner delivery")
			local envelope = delivery.envelope
			if envelope.routeId == Routes.events.projectionSnapshot then
				if envelope.payload.domain == "securedCollection" then
					check(Contract.validSnapshot(envelope.payload), "server collection contract")
					check(Wire.payload(envelope.payload), "server collection wire payload")
					local sessionState = sessionStore.view()
					check(
						sessionState ~= nil and sessionState.status == "Ready",
						"session ready before collection"
					)
					check(
						sessionState.profileRevision == envelope.payload.revision,
						"profile revision matches"
					)
				end
				local applied = clientGateway.handleEvent(envelope)
				check(
					applied == "Applied",
					"client "
						.. tostring(envelope.payload.domain)
						.. " snapshot: "
						.. tostring(applied)
				)
				if envelope.payload.domain == "securedCollection" then
					ownershipSnapshots += 1
				end
			end
		end
		check(ownershipSnapshots == 1, "one ownership snapshot per join")
		local ids = collection.view().creatureInstanceIds
		check(#ids == 1 and ids[1] == "same-creature", "same exact durable ID after rejoin")
	end
	local foreignGateway, foreignEvents = server()
	local foreignOutcome = foreignGateway.handle({ UserId = 43 }, {
		protocolVersion = 1,
		routeId = Routes.commands.sessionClientHello,
		requestId = "hello-other",
		payload = {},
	})
	check(foreignOutcome.code == "OK_SESSION_READY", "foreign ready handshake")
	for _, delivery in foreignEvents do
		if
			delivery.envelope.routeId == Routes.events.projectionSnapshot
			and delivery.envelope.payload.domain == "securedCollection"
		then
			check(delivery.userId == 43, "second owner receives own profile only")
			local ids = delivery.envelope.payload.state.creatureInstanceIds
			check(#ids == 1 and ids[1] == "other-creature", "no cross-owner ID leak")
		end
	end
end

return {
	boundedRecentSummaryUsesDurableOperationOrder = boundedRecentSummaryUsesDurableOperationOrder,
	clientRejectsUntrustedOrStaleCollectionSnapshots = clientRejectsUntrustedOrStaleCollectionSnapshots,
	freshServerRejoinProjectsExactOwnedIdOnce = freshServerRejoinProjectsExactOwnedIdOnce,
}
