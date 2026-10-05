--!strict
-- One actual native client; ordinary boots disabled for the isolated probe.
local g = getfenv() :: any
local s: any = nil
local function check(v: any, why: string?): any
	return assert(v, why or "native Showcase client invariant")
end
local function case(name: string, v: any)
	check(v, name)
	table.insert(s.cases, name)
end
local function view(): any
	return s.network.showcaseStore.view()
end
local function send(route: string, payload: any, expected: number?, wanted: string): any
	local e = {
		protocolVersion = 1,
		routeId = route,
		requestId = "showcase-client-" .. game:GetService("HttpService"):GenerateGUID(false),
		payload = payload,
		expectedRevision = expected,
	}
	s.remotes.Command:FireServer(e)
	local at = os.clock() + 6
	while not s.results[e.requestId] and os.clock() < at do
		g.task.wait(0.03)
	end
	check(s.results[e.requestId] == wanted, route .. ": " .. tostring(s.results[e.requestId]))
	return e
end
local function labels(fragment: string): number
	local n = 0
	for _, item in s.player.PlayerGui.MonsterVaultPartyDiagnostic:GetDescendants() do
		if item:IsA("TextLabel") and item.Text:find(fragment, 1, true) then
			n += 1
		end
	end
	return n
end
local function setup(): any
	s = {
		player = game:GetService("Players").LocalPlayer,
		remotes = game:GetService("ReplicatedStorage").IMP11ShowcaseProbe,
		cases = {},
		results = {},
		events = 0,
	}
	local client = s.player.PlayerScripts.MonsterVaultClient
	s.routes = g.require(
		game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts.RouteIds
	).commands
	s.listener = s.remotes.Event.OnClientEvent:Connect(function(e)
		if e.routeId == "Command.Result" and e.correlationId then
			s.results[e.correlationId] = e.payload.code
		end
		if
			e.routeId == "Social.StateChanged"
			and (e.payload.domain == "showcase" or e.payload.domain == "showcaseView")
		then
			s.events += 1
		end
	end)
	s.network = g.require(client.bootstrap.NetworkingRuntimeService).new({
		command = s.remotes.Command,
		event = s.remotes.Event,
		unreliableEvent = s.remotes.UnreliableEvent,
		diagnostics = { emit = function() end },
	})
	s.ui = g.require(client.bootstrap.PartyRuntimeService)
		.new({ networking = s.network, player = s.player })
	s.network.start()
	s.ui.start()
	send(s.routes.sessionRequestResync, { domain = "showcase" }, nil, "OK_SHOWCASE_SNAPSHOT")
	case(
		"nativePermissionReadback",
		#view().permissions.state.incoming == 1 and view().visit.state.mode == "Closed"
	)
	case(
		"nativeCollapsedNoFocusChange",
		not s.player.PlayerGui.MonsterVaultPartyDiagnostic:FindFirstChildOfClass(
				"ScrollingFrame"
			).Visible and game:GetService("UserInputService"):GetFocusedTextBox() == nil
	)
	return { actualClients = 1, cases = s.cases }
end
local function open(): any
	local row = check(view().permissions.state.incoming[1])
	send(
		s.routes.socialShowcaseOpen,
		{ ownerUserId = row.userId, grantId = row.id },
		nil,
		"OK_SHOWCASE_READ_ONLY"
	)
	local v = view().visit.state
	case(
		"nativeExplicitOpenReadOnlyCard",
		v.mode == "ReadOnly"
			and v.ownerDisplayName == "Showcase peer"
			and v.creatures[1].creatureInstanceId == "showcase-700000010-1"
	)
	case(
		"nativeIntrinsicAndCosmeticSeparation",
		v.creatures[1].speciesRarityId == "rarity/legendary"
			and v.creatures[1].mutationIds[1] == "mutation/neon"
			and v.commerce == nil
	)
	case(
		"nativeVisibleReadOnlyOwnerAndReturn",
		labels("READ-ONLY Showcase") == 1 and labels("Instance:") == 1
	)
	return { cases = s.cases, state = v }
end
local function hostile(): any
	local row = view().permissions.state.incoming[1]
	g.task.wait(3.1)
	send(
		s.routes.socialShowcaseOpen,
		{ ownerUserId = 700000011, grantId = row.id },
		nil,
		"REJECT_PERMISSION_SHOWCASE_VISITOR"
	)
	g.task.wait(3.1)
	send(
		s.routes.socialShowcaseOpen,
		{ ownerUserId = row.userId, grantId = row.id, fields = { "profile", "commerce" } },
		nil,
		"REJECT_VALIDATION_PAYLOAD"
	)
	send(
		s.routes.socialShowcaseGrant,
		{ targetUserId = row.userId, ownerUserId = 700000010 },
		view().permissions.state.permissionRevision,
		"REJECT_VALIDATION_PAYLOAD"
	)
	send(
		s.routes.vaultSetDisplayAssignment,
		{ slotId = "display/1", creatureInstanceId = "showcase-700000010-1" },
		s.network.store.view().profileRevision,
		"REJECT_PERMISSION_VAULT_OWNERSHIP"
	)
	send(
		s.routes.vaultClaimProduction,
		{ claimScope = "All", ownerUserId = 700000010 },
		s.network.store.view().profileRevision,
		"REJECT_VALIDATION_PAYLOAD"
	)
	case("nativeForgedOwnerAndPrivateFieldsRejected", true)
	case("nativeVisitorCannotAssignOwnerCreature", true)
	return { cases = s.cases }
end
local function revoked(): any
	case(
		"nativeRevokedViewAndUI",
		view().visit.state.reason == "Revoked"
			and labels("Revoked") == 1
			and #view().permissions.state.incoming == 0
	)
	return { cases = s.cases }
end
local function expired(): any
	case(
		"nativeClientExpiryAndDisposal",
		view().visit.state.mode == "Closed"
			and view().visit.state.reason == "Expired"
			and s.network.showcaseStore.nextDeadline() == nil
	)
	return { cases = s.cases }
end
local function stop(): any
	s.ui.stop()
	s.network.stop()
	s.listener:Disconnect()
	case(
		"nativeClientDisposalRemovesUI",
		s.player.PlayerGui:FindFirstChild("MonsterVaultPartyDiagnostic") == nil
	)
	return { cases = s.cases, events = s.events }
end
return {
	setup = setup,
	open = open,
	hostile = hostile,
	revoked = revoked,
	expired = expired,
	stop = stop,
}
