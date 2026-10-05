--!strict

local shared = game:GetService("ReplicatedStorage").MonsterVault.Shared
local PartyProjectionV1 = require(shared.contracts.PartyProjectionV1)
local WireValidation = require(shared.contracts.WireValidation)
local RouteIds = require(shared.contracts.RouteIds)
local PartyPolicy = require(shared.config.PartyPolicy)
local FriendlyChallengeDefinition = require(shared.config.FriendlyChallengeDefinition)
local PartyService = require(script.Parent.Parent.domains.social.PartyService)
local ShowcaseService = require(script.Parent.Parent.domains.social.ShowcaseService)
local ShowcaseProjection = require(script.Parent.Parent.application.ShowcaseProjection)
local ShowcaseProjectionV1 = require(shared.contracts.ShowcaseProjectionV1)
local ShowcasePolicy = require(shared.config.ShowcasePolicy)

local PartyRuntimeService = {}

function PartyRuntimeService.new(options: {
	players: any,
	profileCoordinator: any,
	httpService: any,
	event: any,
	monotonicSeconds: (() -> number)?,
	scheduler: any?,
	worldRuntime: any?,
	captureRuntime: any?,
	presentationSeconds: (() -> number)?,
	production: any?,
})
	local clock = options.monotonicSeconds or os.clock
	local scheduler = options.scheduler or (getfenv() :: any).task
	local running = false
	local generation = 0
	local ticket = 0
	local timer: any = nil
	local scheduledAt: number? = nil
	local connections = {}
	local unsubscribe: any = nil
	local owner = PartyService.new({
		policy = PartyPolicy,
		pingContract = PartyProjectionV1,
		challengeContract = PartyProjectionV1,
		challengeDefinition = FriendlyChallengeDefinition,
		projectionFits = WireValidation.payload,
		challengeCapability = function(player: any, session: any, atStart: boolean): any
			return if options.worldRuntime
				then options.worldRuntime.challengeCapability(player, session, atStart)
				else nil
		end,
		presentationSeconds = options.presentationSeconds or function()
			return game:GetService("Workspace"):GetServerTimeNow()
		end,
		waypoint = function(player: any, session: any): any
			return if options.worldRuntime
				then options.worldRuntime.partyWaypoint(player, session)
				else nil
		end,
		updatePingPreference = function(player: any, session: any, muted: boolean): string
			if
				options.players:GetPlayerByUserId(player.UserId) ~= player
				or options.profileCoordinator.get(player.UserId) ~= session
			then
				return "Stale"
			end
			return session.bufferSettings(function(settings)
				settings.socialPingsMuted = muted
			end).status
		end,
		monotonicSeconds = clock,
		newId = function()
			return options.httpService:GenerateGUID(false)
		end,
		context = function(userId: number): any
			local player = options.players:GetPlayerByUserId(userId)
			local session = options.profileCoordinator.get(userId)
			return if player ~= nil and session ~= nil
				then {
					player = player,
					session = session,
					ready = session.state() == "Ready",
					pingsMuted = session.state() ~= "Ready"
						or session.snapshot().settings.socialPingsMuted ~= false,
				}
				else nil
		end,
	})
	local showcase = ShowcaseService.new({
		policy = ShowcasePolicy,
		contract = ShowcaseProjectionV1,
		wire = WireValidation,
		monotonicSeconds = clock,
		presentationSeconds = options.presentationSeconds or function()
			return game:GetService("Workspace"):GetServerTimeNow()
		end,
		newId = function()
			return options.httpService:GenerateGUID(false)
		end,
		context = function(userId: number): any
			local player = options.players:GetPlayerByUserId(userId)
			local session = options.profileCoordinator.get(userId)
			return if player and session
				then { player = player, session = session, ready = session.state() == "Ready" }
				else nil
		end,
		eligible = function(first: any, second: any, audience: string): boolean
			return owner.invitesAllowed(second, options.profileCoordinator.get(second.UserId))
				and (
					audience == "SameServer"
					or (
						audience == "Party"
						and owner.sameParty(
							first,
							options.profileCoordinator.get(first.UserId),
							second,
							options.profileCoordinator.get(second.UserId)
						)
					)
				)
		end,
		presentation = function(player: any, session: any): any
			return if options.production
				then ShowcaseProjection.fromProfile(
					session.snapshot(),
					player.UserId,
					options.production
				)
				else { creatures = {}, hasMore = false }
		end,
	})
	local function publishShowcase(player: any, requestId: string?): boolean
		if not running or options.players:GetPlayerByUserId(player.UserId) ~= player then
			return false
		end
		for _, payload in { showcase.snapshot(player), showcase.viewSnapshot(player) } do
			assert(
				ShowcaseProjectionV1.validSnapshot(payload) and WireValidation.payload(payload),
				"invalid bounded Showcase projection"
			)
			options.event:FireClient(player, {
				protocolVersion = 1,
				routeId = RouteIds.events.socialStateChanged,
				correlationId = requestId,
				revision = payload.revision,
				payload = payload,
			})
		end
		return true
	end
	local function publish(player: any, requestId: string?): boolean
		if not running or options.players:GetPlayerByUserId(player.UserId) ~= player then
			return false
		end
		local payload = owner.snapshot(player)
		if payload == nil then
			return false
		end
		assert(
			PartyProjectionV1.validSnapshot(payload) and WireValidation.payload(payload),
			"invalid bounded Party projection"
		)
		options.event:FireClient(player, {
			protocolVersion = 1,
			routeId = RouteIds.events.socialStateChanged,
			correlationId = requestId,
			revision = payload.revision,
			payload = payload,
		})
		return true
	end
	local function flush()
		-- A readback can discover a replaced session and dirty another affected
		-- member. Drain that finite change set, never poll the player population.
		for _ = 1, PartyPolicy.maxLiveUsers + 1 do
			local changed = owner.takeChanges()
			for _, userId in changed do
				showcase.refreshAudience(userId)
			end
			local showcaseChanges = showcase.takeChanges()
			if #changed == 0 and #showcaseChanges == 0 then
				return
			end
			for _, userId in showcaseChanges do
				local player = options.players:GetPlayerByUserId(userId)
				if player then
					publishShowcase(player, nil)
				end
			end
			for _, userId in changed do
				local player = options.players:GetPlayerByUserId(userId)
				if player then
					publish(player, nil)
				end
			end
		end
		error("Party change drain exceeded live-user bound")
	end
	local arm: () -> ()
	arm = function()
		local deadline = if running then owner.nextDeadline() else nil
		local showcaseDeadline = if running then showcase.nextDeadline() else nil
		if showcaseDeadline then
			deadline = math.min(deadline or math.huge, showcaseDeadline)
		end
		if deadline == scheduledAt then
			return
		end
		ticket += 1
		if timer ~= nil then
			pcall(scheduler.cancel, timer)
		end
		timer, scheduledAt = nil, deadline
		if deadline == nil then
			return
		end
		local expectedGeneration, expectedTicket = generation, ticket
		timer = scheduler.delay(math.max(0, deadline - clock()), function()
			if not running or expectedGeneration ~= generation or expectedTicket ~= ticket then
				return
			end
			timer, scheduledAt = nil, nil
			ticket += 1 -- consume this callback before any projection/lifecycle work.
			owner.expire()
			showcase.expire()
			flush()
			arm()
		end)
	end
	local schemas = {
		[RouteIds.commands.socialShowcaseSetPolicy] = ShowcaseProjectionV1.validPolicy,
		[RouteIds.commands.socialShowcaseGrant] = ShowcaseProjectionV1.validGrant,
		[RouteIds.commands.socialShowcaseRevoke] = ShowcaseProjectionV1.validRevoke,
		[RouteIds.commands.socialShowcaseOpen] = ShowcaseProjectionV1.validOpen,
		[RouteIds.commands.socialShowcaseClose] = ShowcaseProjectionV1.validClose,
		[RouteIds.commands.socialPartyCreate] = PartyProjectionV1.validCreate,
		[RouteIds.commands.socialPartyInvite] = PartyProjectionV1.validInvite,
		[RouteIds.commands.socialPartyRespond] = PartyProjectionV1.validRespond,
		[RouteIds.commands.socialPartyLeave] = PartyProjectionV1.validParty,
		[RouteIds.commands.socialPartyRemove] = PartyProjectionV1.validRemove,
		[RouteIds.commands.socialPartyDisband] = PartyProjectionV1.validParty,
		[RouteIds.commands.socialPartyRejoin] = PartyProjectionV1.validParty,
		[RouteIds.commands.socialPartySetInvitePolicy] = PartyProjectionV1.validInvitePolicy,
		[RouteIds.commands.socialPing] = PartyProjectionV1.validPing,
		[RouteIds.commands.socialChallengeRequest] = PartyProjectionV1.validChallengeRequest,
		[RouteIds.commands.socialChallengeRespond] = PartyProjectionV1.validChallengeRespond,
		[RouteIds.commands.socialChallengeCancel] = PartyProjectionV1.validChallengeCancel,
		[RouteIds.commands.settingsUpdatePreferences] = PartyProjectionV1.validPingPreference,
	}
	local operations = {
		[RouteIds.commands.socialShowcaseSetPolicy] = function(
			player: any,
			payload: any,
			expected: any
		): string
			return showcase.setPolicy(player, payload.audience, expected)
		end,
		[RouteIds.commands.socialShowcaseGrant] = function(
			player: any,
			payload: any,
			expected: any
		): string
			return showcase.grant(player, payload.targetUserId, expected)
		end,
		[RouteIds.commands.socialShowcaseRevoke] = function(
			player: any,
			payload: any,
			expected: any
		): string
			return showcase.revoke(player, payload.grantId, expected)
		end,
		[RouteIds.commands.socialShowcaseOpen] = function(
			player: any,
			payload: any,
			_expected: any
		): string
			return showcase.open(player, payload.ownerUserId, payload.grantId)
		end,
		[RouteIds.commands.socialShowcaseClose] = function(
			player: any,
			payload: any,
			_expected: any
		): string
			return showcase.close(player, payload.grantId)
		end,
		[RouteIds.commands.socialChallengeRequest] = function(
			player: any,
			payload: any,
			_expected: any
		): string
			return owner.challengeRequest(
				player,
				payload.targetUserId,
				payload.definitionId,
				payload.definitionVersion
			)
		end,
		[RouteIds.commands.socialChallengeRespond] = function(
			player: any,
			payload: any,
			expected: any
		): string
			return owner.challengeRespond(player, payload.challengeId, payload.accept, expected)
		end,
		[RouteIds.commands.socialChallengeCancel] = function(
			player: any,
			payload: any,
			expected: any
		): string
			return owner.challengeCancel(player, payload.challengeId, expected)
		end,
		[RouteIds.commands.socialPing] = function(player: any, payload: any, expected: any): string
			return owner.ping(player, payload.partyId, payload.pingKind, expected)
		end,
		[RouteIds.commands.settingsUpdatePreferences] = function(
			player: any,
			payload: any,
			_expected: any
		): string
			return owner.setPingPreference(player, payload.socialPingsMuted)
		end,
		[RouteIds.commands.socialPartyCreate] = function(
			player: any,
			_payload: any,
			_expected: any
		): string
			return owner.create(player)
		end,
		[RouteIds.commands.socialPartyInvite] = function(
			player: any,
			payload: any,
			expected: any
		): string
			return owner.invite(player, payload.targetUserId, expected)
		end,
		[RouteIds.commands.socialPartyRespond] = function(
			player: any,
			payload: any,
			expected: any
		): string
			return owner.respond(player, payload.invitationId, payload.accept, expected)
		end,
		[RouteIds.commands.socialPartyLeave] = function(
			player: any,
			payload: any,
			expected: any
		): string
			return owner.leave(player, payload.partyId, expected)
		end,
		[RouteIds.commands.socialPartyRemove] = function(
			player: any,
			payload: any,
			expected: any
		): string
			return owner.remove(player, payload.partyId, payload.targetUserId, expected)
		end,
		[RouteIds.commands.socialPartyDisband] = function(
			player: any,
			payload: any,
			expected: any
		): string
			return owner.disband(player, payload.partyId, expected)
		end,
		[RouteIds.commands.socialPartyRejoin] = function(
			player: any,
			payload: any,
			expected: any
		): string
			return owner.rejoin(player, payload.partyId, expected)
		end,
		[RouteIds.commands.socialPartySetInvitePolicy] = function(
			player: any,
			payload: any,
			_expected: any
		): string
			return owner.setInvitePolicy(player, payload.allowInvites)
		end,
	}
	local handlers = {}
	for routeId, operation in operations do
		handlers[routeId] = function(player: any, envelope: any): string
			if not running then
				return "UNAVAILABLE_PARTY"
			end
			if not schemas[routeId](envelope.payload, envelope.expectedRevision) then
				return "REJECT_VALIDATION_PAYLOAD"
			end
			local code = operation(player, envelope.payload, envelope.expectedRevision)
			flush()
			arm()
			return code
		end
	end
	local function start()
		assert(not running and generation == 0, "Party runtime already started")
		running, generation = true, generation + 1
		if options.profileCoordinator.subscribe then
			unsubscribe = options.profileCoordinator.subscribe(
				function(userId: number, session: any)
					if not running then
						return
					end
					if options.profileCoordinator.get(userId) ~= session then
						return
					end
					owner.observe(userId)
					showcase.profileChanged(userId, session)
					flush()
					arm()
				end
			)
		end
		if options.worldRuntime and options.worldRuntime.bindChallengeLifecycle then
			options.worldRuntime.bindChallengeLifecycle({
				begin = function(player: any, context: any, target: any, recovery: boolean): any
					local observation =
						owner.beginChallengeTravel(player, context, target, recovery)
					flush()
					arm()
					return observation
				end,
				complete = function(observation: any)
					owner.completeChallengeTravel(observation)
					flush()
					arm()
				end,
			})
		end
		if options.captureRuntime and options.captureRuntime.bindChallengeInterruption then
			options.captureRuntime.bindChallengeInterruption(
				function(player: any, character: any, changed: boolean)
					owner.interruptChallenge(player, character, changed)
					flush()
					arm()
				end
			)
		end
		table.insert(
			connections,
			options.players.PlayerAdded:Connect(function(player)
				owner.observe(player.UserId) -- a replacement Player invalidates the old identity.
				showcase.observe(player.UserId)
				flush()
				arm()
			end)
		)
		table.insert(
			connections,
			options.players.PlayerRemoving:Connect(function(player, reason)
				-- Match TA-7's conservative treatment of ambiguous native Unknown.
				local session = owner.sessionFor(player)
				owner.disconnect(player, session, reason == nil or reason.Name == "Unknown")
				showcase.disconnect(player, showcase.sessionFor(player))
				flush()
				arm()
			end)
		)
	end
	local function stop(): { string }
		running, generation, ticket = false, generation + 1, ticket + 1
		if unsubscribe then
			unsubscribe()
			unsubscribe = nil
		end
		if options.worldRuntime and options.worldRuntime.bindChallengeLifecycle then
			options.worldRuntime.bindChallengeLifecycle(nil)
		end
		if options.captureRuntime and options.captureRuntime.bindChallengeInterruption then
			options.captureRuntime.bindChallengeInterruption(nil)
		end
		if timer ~= nil then
			pcall(scheduler.cancel, timer)
		end
		timer, scheduledAt = nil, nil
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
		owner.stop()
		showcase.stop()
		return {}
	end
	return {
		id = "social",
		dependencies = if options.captureRuntime
			then { "profiles", "world", "capture" }
			else if options.worldRuntime then { "profiles", "world" } else { "profiles" },
		start = start,
		stop = stop,
		schemas = schemas,
		handlers = handlers,
		resync = function(player: any, requestId: string): string
			local sent = publish(player, requestId)
			flush()
			arm()
			return if sent then "OK_PARTY_SNAPSHOT" else "REJECT_STATE_PARTY_SESSION"
		end,
		showcaseResync = function(player: any, requestId: string): string
			local sent = publishShowcase(player, requestId)
			flush()
			arm()
			return if sent then "OK_SHOWCASE_SNAPSHOT" else "REJECT_STATE_SHOWCASE_SESSION"
		end,
		showcase = showcase,
		owner = owner,
	}
end

return PartyRuntimeService
