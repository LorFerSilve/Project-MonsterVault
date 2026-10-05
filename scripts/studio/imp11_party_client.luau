--!strict

-- Mount as ReplicatedStorage.IMP11PartyClientProbe. Actual client-side gateways
-- and native UI; no fake player/client is used for these wire cases.
local globals = getfenv() :: any
local state: any = nil
local function check(value: any, message: string?): any
	return assert(value, message or "native Party client invariant")
end
local function setup(): any
	check(state == nil)
	local player = game:GetService("Players").LocalPlayer
	local modules = player.PlayerScripts.MonsterVaultClient.bootstrap
	local remote = game:GetService("ReplicatedStorage"):WaitForChild("IMP11PartyProbeRemotes")
	local network = require(modules.NetworkingRuntimeService).new({
		command = remote.Command,
		event = remote.Event,
		unreliableEvent = remote.UnreliableEvent,
		diagnostics = {
			emit = function(_level, code)
				print("IMP11_CLIENT " .. code)
			end,
		},
	})
	local ui = require(modules.PartyRuntimeService).new({ networking = network, player = player })
	state = { player = player, network = network, ui = ui, remote = remote, results = {} }
	ui.start() -- listener binding before handshake; dependency behavior under test.
	network.start()
	local deadline = os.clock() + 5
	while network.partyStore.view() == nil and os.clock() < deadline do
		globals.task.wait(0.05)
	end
	local snapshot = check(network.partyStore.view(), "native handshake projection")
	check(snapshot.state.party == nil and not snapshot.state.allowInvites)
	return snapshot
end
local function command(route: string, payload: any, expected: number?, wanted: string): string
	local s = check(state)
	local request = s.network.gateway.send(route, payload, expected)
	local deadline = os.clock() + 5
	while s.network.gateway.resultFor(request) == nil and os.clock() < deadline do
		globals.task.wait(0.02)
	end
	local actual = s.network.gateway.resultFor(request)
	check(actual == wanted, route .. ": " .. tostring(actual) .. " expected " .. wanted)
	table.insert(s.results, { route = route, result = actual })
	return request
end
local function run(): any
	local s = check(state)
	local routes = require(
		game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts.RouteIds
	).commands
	local selected = game:GetService("GuiService").SelectedObject
	s.createRequest = command(routes.socialPartyCreate, {}, nil, "OK_PARTY_CREATED")
	local party = check(s.network.partyStore.view().state.party)
	check(party.leaderUserId == s.player.UserId and #party.members == 1 and party.revision == 1)
	check(
		game:GetService("GuiService").SelectedObject == selected,
		"Party projection stole input focus"
	)
	s.network.gateway.resend(s.createRequest)
	globals.task.wait(0.15)
	check(s.network.partyStore.view().state.party.partyId == party.partyId)
	command(routes.socialPartyCreate, { ownerUserId = 999 }, nil, "REJECT_VALIDATION_PAYLOAD")
	command(
		routes.socialPartyInvite,
		{ targetUserId = s.player.UserId },
		1,
		"REJECT_STATE_PARTY_TARGET"
	)
	command(routes.socialPartyInvite, { targetUserId = 2 ^ 53 - 1 }, 1, "REJECT_STATE_PARTY_TARGET")
	command(
		routes.socialPartyInvite,
		{ targetUserId = s.player.UserId, inviterUserId = 999 },
		1,
		"REJECT_VALIDATION_PAYLOAD"
	)
	command(
		routes.socialPartyInvite,
		{ targetUserId = s.player.UserId },
		999,
		"REJECT_STATE_PARTY_REVISION"
	)
	command(
		routes.socialPartyInvite,
		{ targetUserId = s.player.UserId, expiry = 999 },
		1,
		"REJECT_VALIDATION_PAYLOAD"
	)
	command(
		routes.socialPartyRespond,
		{ invitationId = "other-player-invite", accept = true },
		1,
		"REJECT_PERMISSION_PARTY_INVITE"
	)
	command(
		routes.socialPartyRemove,
		{ partyId = party.partyId, targetUserId = 999 },
		1,
		"REJECT_STATE_PARTY_MEMBER"
	)
	command(routes.socialPartyLeave, { partyId = "forged-party" }, 1, "REJECT_STATE_PARTY_REVISION")
	command(
		routes.socialPartyCreate,
		{ sessionIdentity = "forged" },
		nil,
		"REJECT_VALIDATION_PAYLOAD"
	)
	-- Exercise the physical remote with a payload the ordinary client gateway
	-- already refuses locally. Result still travels through the real listener.
	s.remote.Command:FireServer({
		protocolVersion = 1,
		routeId = routes.socialPartyInvite,
		requestId = "native-oversized",
		expectedRevision = 1,
		payload = { targetUserId = s.player.UserId, text = string.rep("x", 4097) },
	})
	globals.task.wait(0.2)
	check(s.network.gateway.resultFor("native-oversized") == "REJECT_VALIDATION_PAYLOAD")
	command(
		routes.socialPartySetInvitePolicy,
		{ allowInvites = true },
		nil,
		"OK_PARTY_INVITE_POLICY"
	)
	command(routes.socialPartyLeave, { partyId = party.partyId }, 1, "OK_PARTY_LEFT")
	check(s.network.partyStore.view().state.party == nil)
	globals.task.wait(0.5)
	s.createRequest = command(routes.socialPartyCreate, {}, nil, "OK_PARTY_CREATED")
	check(s.network.partyStore.view().state.party.partyId ~= party.partyId)
	return {
		cases = s.results,
		duplicateCreate = true,
		oversizedRemote = true,
		focusPreserved = true,
		projection = s.network.partyStore.view(),
	}
end
local function replaced(): any
	local s = check(state)
	check(
		s.network.partyStore.view().state.party == nil
			and not s.network.partyStore.view().state.allowInvites
	)
	s.network.gateway.resend(s.createRequest)
	globals.task.wait(0.2)
	check(s.network.gateway.resultFor(s.createRequest) == "REJECT_VALIDATION_REQUEST_REUSE")
	check(s.network.partyStore.view().state.party == nil)
	local routes = require(
		game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts.RouteIds
	).commands
	command(routes.socialPartyCreate, {}, nil, "OK_PARTY_CREATED")
	return {
		oldRequest = "REJECT_VALIDATION_REQUEST_REUSE",
		projection = s.network.partyStore.view(),
	}
end
local function cleanup(): any
	local s = check(state)
	s.ui.stop()
	s.network.stop()
	check(s.player.PlayerGui:FindFirstChild("MonsterVaultPartyDiagnostic") == nil)
	state = nil
	return "client listeners, stores and GUI released"
end
return { setup = setup, run = run, replaced = replaced, cleanup = cleanup }
