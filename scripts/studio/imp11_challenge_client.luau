--!strict
-- Normal boot or isolated IMP10WorldProbe remotes. One real native client;
-- the server peer is explicitly an adapter fixture, not a second real client.
local g = getfenv() :: any
local s: any = nil
local function check(v: any, why: string?): any
	return assert(v, why or "native Friendly Challenge client invariant")
end
local function case(name: string, v: any)
	check(v, name)
	table.insert(s.cases, name)
end
local function view(): any
	return s.store.view().state.challenge
end
local function send(route: string, payload: any, expected: number?, wanted: string): any
	local e = {
		protocolVersion = 1,
		routeId = route,
		requestId = "challenge-probe-" .. game:GetService("HttpService"):GenerateGUID(false),
		payload = payload,
		expectedRevision = expected,
	}
	s.remote.Command:FireServer(e)
	local untilAt = os.clock() + 6
	while s.results[e.requestId] == nil and os.clock() < untilAt do
		g.task.wait(0.03)
	end
	check(s.results[e.requestId] == wanted, route .. ": " .. tostring(s.results[e.requestId]))
	return e
end
local function labels(fragment: string): number
	local n = 0
	for _, v in s.player.PlayerGui.MonsterVaultPartyDiagnostic:GetDescendants() do
		if v:IsA("TextLabel") and v.Text:find(fragment, 1, true) then
			n += 1
		end
	end
	return n
end
local function setup(scoped: boolean?): any
	check(s == nil)
	local shared = game:GetService("ReplicatedStorage").MonsterVault.Shared
	local contracts = shared.contracts
	local contract, wire =
		g.require(contracts.PartyProjectionV1), g.require(contracts.WireValidation)
	s = {
		player = game:GetService("Players").LocalPlayer,
		remote = if scoped
			then game:GetService("ReplicatedStorage").IMP10WorldProbe
			else game:GetService("ReplicatedStorage").MonsterVault.Remotes.V1,
		results = {},
		cases = {},
		events = 0,
		routes = g.require(contracts.RouteIds).commands,
		definition = g.require(shared.config.FriendlyChallengeDefinition),
	}
	if scoped then
		local boot = s.player.PlayerScripts.MonsterVaultClient.bootstrap
		s.network = g.require(boot.NetworkingRuntimeService).new({
			command = s.remote.Command,
			event = s.remote.Event,
			unreliableEvent = s.remote.UnreliableEvent,
			diagnostics = { emit = function() end },
		})
		s.network.start()
		s.ui = g.require(boot.PartyRuntimeService)
			.new({ networking = s.network, player = s.player })
		s.ui.start()
		s.store = s.network.partyStore
	else
		s.store = g.require(s.player.PlayerScripts.MonsterVaultClient.store.PartyProjectionStore)
			.new(contract, wire, function()
				return workspace:GetServerTimeNow()
			end)
	end
	s.listener = s.remote.Event.OnClientEvent:Connect(function(e)
		if e.routeId == "Command.Result" and e.correlationId then
			s.results[e.correlationId] = e.payload.code
		elseif e.routeId == "Social.StateChanged" then
			check(contract.validSnapshot(e.payload) and wire.payload(e.payload))
			if not scoped then
				s.store.snapshot(e.payload)
			end
			s.events += 1
		end
	end)
	send(s.routes.sessionRequestResync, { domain = "party" }, nil, "OK_PARTY_SNAPSHOT")
	local ui = s.player.PlayerGui.MonsterVaultPartyDiagnostic
	case("initialNoChallenge", view() == nil)
	case(
		"collapsedNoModalFocus",
		not ui:FindFirstChildOfClass("ScrollingFrame").Visible
			and game:GetService("UserInputService"):GetFocusedTextBox() == nil
	)
	case(
		"visibleAuthoredDefinition",
		labels(s.definition.title) == 1 and labels(s.definition.rules) == 1
	)
	if scoped then
		send(
			s.routes.socialPartySetInvitePolicy,
			{ allowInvites = true },
			nil,
			"OK_PARTY_INVITE_POLICY"
		)
	end
	return { actualClients = 1, cases = s.cases }
end
local function hostile(): any
	local p =
		{ targetUserId = s.player.UserId, definitionId = s.definition.id, definitionVersion = 1 }
	local bad: any = table.clone(p)
	bad.score = 999
	send(s.routes.socialChallengeRequest, bad, nil, "REJECT_VALIDATION_PAYLOAD")
	case("remoteForgedScoreRejected", view() == nil)
	g.task.wait(3.1)
	bad = table.clone(p)
	bad.definitionId = "challenge/forged"
	send(s.routes.socialChallengeRequest, bad, nil, "REJECT_STATE_CHALLENGE_DEFINITION")
	case("remoteForgedDefinitionRejected", view() == nil)
	g.task.wait(3.1)
	send(s.routes.socialChallengeRequest, p, nil, "REJECT_STATE_CHALLENGE_TARGET")
	case("remoteSelfTargetRejected", view() == nil)
	send("Social.ChallengeResolve", {}, nil, "REJECT_VALIDATION_ROUTE")
	case("remoteResolveAbsent", view() == nil)
	return { cases = s.cases }
end
local function acceptAndFinish(): any
	local c = check(view())
	case("incomingOfferDoesNotStart", c.phase == "Offered" and c.toUserId == s.player.UserId)
	case(
		"incomingRulesNoFocus",
		labels(s.definition.rules) == 1
			and c.definitionId == s.definition.id
			and c.definitionVersion == s.definition.version
			and game:GetService("UserInputService"):GetFocusedTextBox() == nil
	)
	local e = send(
		s.routes.socialChallengeRespond,
		{ challengeId = c.id, accept = true },
		c.revision,
		"OK_CHALLENGE_ACTIVE"
	)
	local active = check(view())
	case("explicitNativeAccept", active.phase == "Active" and active.revision == c.revision + 1)
	local before = s.events
	s.remote.Command:FireServer(e)
	g.task.wait(0.15)
	case("nativeReplayNoSecondStart", s.events == before and view().revision == active.revision)
	send(s.routes.worldRequestFastTravel, {
		nodeId = s.definition.targetNodeId,
		characterGeneration = s.player:GetAttribute("MonsterVaultCharacterGeneration"),
	}, nil, "OK_WORLD_TRAVELLED")
	local result = check(view())
	case(
		"nativeTravelResultProjection",
		result.phase == "Resolved"
			and result.winnerUserId == s.player.UserId
			and result.elapsedMs >= 0
			and labels("Winner:") == 1
	)
	send(
		s.routes.socialChallengeCancel,
		{ challengeId = result.id },
		result.revision,
		"REJECT_STATE_CHALLENGE_PHASE"
	)
	case(
		"resolvedCancelCannotRewrite",
		view().revision == result.revision and view().winnerUserId == result.winnerUserId
	)
	return { challenge = result, cases = s.cases }
end
local function expiryReadback(): any
	case("nativeDisplayExpired", view() == nil)
	return { cases = s.cases }
end
local function stop(): any
	s.listener:Disconnect()
	if s.ui then
		s.ui.stop()
		s.network.stop()
	end
	return { cases = s.cases }
end
return {
	setup = setup,
	hostile = hostile,
	acceptAndFinish = acceptAndFinish,
	expiryReadback = expiryReadback,
	stop = stop,
}
