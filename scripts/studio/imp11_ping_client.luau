--!strict
-- Mount as ReplicatedStorage.IMP11PingClientProbe during the normal shipped boot.
-- Unique request IDs use the actual three remotes; shipped native UI consumes
-- the same authoritative events. This probe adds no second network runtime.
local g = getfenv() :: any
local s: any = nil
local function check(v: any, why: string?): any
	return assert(v, why or "native Ping invariant")
end
local function send(route: string, payload: any, expected: number?, wanted: string): string
	local id = "ping-probe-" .. game:GetService("HttpService"):GenerateGUID(false)
	s.remote.Command:FireServer({
		protocolVersion = 1,
		routeId = route,
		requestId = id,
		payload = payload,
		expectedRevision = expected,
	})
	local deadline = os.clock() + 6
	while s.results[id] == nil and os.clock() < deadline do
		g.task.wait(0.03)
	end
	check(
		s.results[id] == wanted,
		route .. " " .. tostring(s.results[id]) .. " expected " .. wanted
	)
	table.insert(s.cases, { route = route, result = wanted })
	return id
end
local function setup(): any
	check(s == nil)
	local shared = game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts
	local contract = require(shared.PartyProjectionV1)
	local wire = require(shared.WireValidation)
	s = {
		remote = game:GetService("ReplicatedStorage").MonsterVault.Remotes.V1,
		results = {},
		cases = {},
		events = 0,
		routes = require(shared.RouteIds).commands,
	}
	s.store = require(
		game:GetService("Players").LocalPlayer.PlayerScripts.MonsterVaultClient.store.PartyProjectionStore
	).new(contract, wire, function()
		return workspace:GetServerTimeNow()
	end)
	s.listener = s.remote.Event.OnClientEvent:Connect(function(e)
		if e.routeId == "Command.Result" and e.correlationId then
			s.results[e.correlationId] = e.payload.code
		end
		if e.routeId == "Social.StateChanged" then
			check(contract.validSnapshot(e.payload) and wire.payload(e.payload))
			s.store.snapshot(e.payload)
			s.events += 1
		end
	end)
	send(s.routes.sessionRequestResync, { domain = "party" }, nil, "OK_PARTY_SNAPSHOT")
	return s.store.view()
end
local function positive(): any
	send(s.routes.socialPartyCreate, {}, nil, "OK_PARTY_CREATED")
	send(
		s.routes.settingsUpdatePreferences,
		{ socialPingsMuted = false },
		nil,
		"OK_PREFERENCES_BUFFERED"
	)
	local p = check(s.store.view().state.party)
	g.task.wait(3.1) -- a prior diagnostic action may have consumed the route bucket.
	s.pingRequest = send(
		s.routes.socialPing,
		{ partyId = p.partyId, pingKind = "ComeHere" },
		p.revision,
		"OK_SOCIAL_PING"
	)
	local view = s.store.view()
	local ping = check(view.state.pings[1])
	check(
		ping.senderUserId == game:GetService("Players").LocalPlayer.UserId
			and ping.kind == "ComeHere"
	)
	s.ping = ping
	local labels = 0
	for _, v in
		game:GetService("Players").LocalPlayer.PlayerGui.MonsterVaultPartyDiagnostic
			:GetDescendants()
	do
		if v:IsA("TextLabel") and v.Text:find("Waypoint:", 1, true) then
			labels += 1
		end
	end
	check(labels == 1)
	local before = s.events
	s.remote.Command:FireServer({
		protocolVersion = 1,
		routeId = s.routes.socialPing,
		requestId = "ping-spam",
		expectedRevision = p.revision,
		payload = { partyId = p.partyId, pingKind = "ComeHere" },
	})
	g.task.wait(0.25)
	check(s.events == before, "rate-limited request multiplied delivery")
	return {
		projection = view,
		diagnosticWaypoint = labels,
		rateSpamDropped = true,
		actualClients = 1,
	}
end
local function replay(): any
	g.task.wait(3.1)
	local before = s.store.view()
	local p = check(before.state.party)
	s.remote.Command:FireServer({
		protocolVersion = 1,
		routeId = s.routes.socialPing,
		requestId = s.pingRequest,
		expectedRevision = p.revision,
		payload = { partyId = p.partyId, pingKind = "ComeHere" },
	})
	g.task.wait(0.2)
	check(s.store.view().revision == before.revision, "replay multiplied delivery")
	return { duplicateDidNotDeliver = true, projectionRevision = before.revision }
end
local function expiry(): any
	g.task.wait(3.1)
	check(#s.store.view().state.pings == 0)
	local labels = 0
	for _, v in
		game:GetService("Players").LocalPlayer.PlayerGui.MonsterVaultPartyDiagnostic
			:GetDescendants()
	do
		if v:IsA("TextLabel") and v.Text:find("Waypoint:", 1, true) then
			labels += 1
		end
	end
	check(labels == 0)
	return { clientExpired = true, diagnosticExpired = true, projection = s.store.view() }
end
local function hostile(): any
	local bad: { any } = {
		{ pingKind = "ComeHere", recipients = { 999 } },
		{ pingKind = "ComeHere", position = { x = 0 / 0, y = 0, z = 0 } },
		{ pingKind = "ComeHere", targetId = "secret-creature" },
		{ pingKind = "CreatureHere" },
		{ pingKind = "ComeHere", bypassMute = true },
		{ pingKind = "ComeHere", text = string.rep("x", 4097) },
	}
	for _, payload in bad do
		g.task.wait(3.1)
		local p = s.store.view().state.party
		payload.partyId = p.partyId
		send(s.routes.socialPing, payload, p.revision, "REJECT_VALIDATION_PAYLOAD")
	end
	g.task.wait(3.1)
	send(
		s.routes.socialPing,
		{ partyId = "forged", pingKind = "ComeHere" },
		1,
		"REJECT_STATE_PARTY_REVISION"
	)
	g.task.wait(3.1)
	send(
		s.routes.socialPing,
		{ partyId = s.store.view().state.party.partyId, pingKind = "ComeHere" },
		999,
		"REJECT_STATE_PARTY_REVISION"
	)
	return { cases = s.cases, hostileDidNotCreatePing = #s.store.view().state.pings == 0 }
end
local function muteAndLeave(): any
	send(
		s.routes.settingsUpdatePreferences,
		{ socialPingsMuted = true },
		nil,
		"OK_PREFERENCES_BUFFERED"
	)
	local p = s.store.view().state.party
	g.task.wait(3.1)
	send(
		s.routes.socialPing,
		{ partyId = p.partyId, pingKind = "ComeHere" },
		p.revision,
		"OK_SOCIAL_PING"
	)
	check(s.store.view().state.pingsMuted and #s.store.view().state.pings == 0)
	send(s.routes.socialPartyLeave, { partyId = p.partyId }, p.revision, "OK_PARTY_LEFT")
	check(s.store.view().state.party == nil and #s.store.view().state.pings == 0)
	return { suppression = true, noParty = true, cases = s.cases }
end
local function cleanup()
	s.listener:Disconnect()
	s.store.reset()
	s = nil
	return "probe listener/store released"
end
return {
	setup = setup,
	positive = positive,
	replay = replay,
	expiry = expiry,
	hostile = hostile,
	muteAndLeave = muteAndLeave,
	cleanup = cleanup,
}
