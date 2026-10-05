--!strict

local shared = game:GetService("ReplicatedStorage").MonsterVault.Shared
local PartyProjectionV1 = require(shared.contracts.PartyProjectionV1)
local WireValidation = require(shared.contracts.WireValidation)
local RouteIds = require(shared.contracts.RouteIds)
local PartyPolicy = require(shared.config.PartyPolicy)
local PartyService = require(script.Parent.Parent.domains.social.PartyService)

local PartyRuntimeService = {}

function PartyRuntimeService.new(options: {
	players: any,
	profileCoordinator: any,
	httpService: any,
	event: any,
	monotonicSeconds: (() -> number)?,
	scheduler: any?,
})
	local clock = options.monotonicSeconds or os.clock
	local scheduler = options.scheduler or (getfenv() :: any).task
	local running = false
	local generation = 0
	local ticket = 0
	local timer: any = nil
	local scheduledAt: number? = nil
	local connections = {}
	local owner = PartyService.new({
		policy = PartyPolicy,
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
				}
				else nil
		end,
	})
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
			if #changed == 0 then
				return
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
			flush()
			arm()
		end)
	end
	local schemas = {
		[RouteIds.commands.socialPartyCreate] = PartyProjectionV1.validCreate,
		[RouteIds.commands.socialPartyInvite] = PartyProjectionV1.validInvite,
		[RouteIds.commands.socialPartyRespond] = PartyProjectionV1.validRespond,
		[RouteIds.commands.socialPartyLeave] = PartyProjectionV1.validParty,
		[RouteIds.commands.socialPartyRemove] = PartyProjectionV1.validRemove,
		[RouteIds.commands.socialPartyDisband] = PartyProjectionV1.validParty,
		[RouteIds.commands.socialPartyRejoin] = PartyProjectionV1.validParty,
		[RouteIds.commands.socialPartySetInvitePolicy] = PartyProjectionV1.validInvitePolicy,
	}
	local operations = {
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
		table.insert(
			connections,
			options.players.PlayerAdded:Connect(function(player)
				owner.observe(player.UserId) -- a replacement Player invalidates the old identity.
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
				flush()
				arm()
			end)
		)
	end
	local function stop(): { string }
		running, generation, ticket = false, generation + 1, ticket + 1
		if timer ~= nil then
			pcall(scheduler.cancel, timer)
		end
		timer, scheduledAt = nil, nil
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
		owner.stop()
		return {}
	end
	return {
		id = "social",
		dependencies = { "profiles" },
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
		owner = owner,
	}
end

return PartyRuntimeService
