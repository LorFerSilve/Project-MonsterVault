--!strict

local ProtocolV1 = require("../../src/shared/contracts/ProtocolV1")
local RouteIds = require("../../src/shared/contracts/RouteIds")

local function check(condition: boolean, message: string?)
	if not condition then
		error(message or "protocol contract assertion failed", 2)
	end
end

local function assertRouteSet(actual: { [string]: string }, expected: { string })
	local seen: { [string]: boolean } = {}
	local count = 0
	for _, routeId in actual do
		check(not seen[routeId], `duplicate route {routeId}`)
		seen[routeId] = true
		count += 1
	end
	check(count == #expected, `expected {#expected} routes, got {count}`)
	for _, routeId in expected do
		check(seen[routeId], `missing route {routeId}`)
	end
end

local function run()
	check(ProtocolV1.version == 1)
	check(ProtocolV1.isSupportedVersion(1))
	check(not ProtocolV1.isSupportedVersion(0))
	check(not ProtocolV1.isSupportedVersion("1"))
	check(ProtocolV1.remoteNames.command == "Command")
	check(ProtocolV1.remoteNames.event == "Event")
	check(ProtocolV1.remoteNames.unreliableEvent == "UnreliableEvent")

	assertRouteSet(RouteIds.commands, {
		"Session.ClientHello",
		"Session.RequestResync",
		"Interaction.PrimaryInteract",
		"Capture.SubmitAction",
		"World.RequestFastTravel",
		"Creature.SetLock",
		"Creature.Release",
		"Vault.SetProductionAssignment",
		"Vault.ClaimProduction",
		"Progression.PurchaseUnlock",
		"Social.PartyInvite",
		"Social.PartyRespond",
		"Social.PartyLeave",
		"Social.Ping",
		"Social.ChallengeRequest",
		"Social.ChallengeRespond",
		"Trade.Start",
		"Trade.SetOffer",
		"Trade.SetReady",
		"Trade.FinalConfirm",
		"Trade.Cancel",
		"Commerce.RefreshEntitlements",
		"Settings.UpdatePreferences",
	})
	assertRouteSet(RouteIds.events, {
		"Command.Result",
		"Session.Ready",
		"Session.ProtectedOutcome",
		"Projection.Snapshot",
		"Projection.Delta",
		"Capture.StateChanged",
		"World.StateChanged",
		"Social.StateChanged",
		"Event.StateChanged",
		"Trade.StateChanged",
		"Commerce.StateChanged",
		"System.Notification",
	})
	assertRouteSet(RouteIds.unreliableEvents, {
		"Presentation.CaptureTiming",
		"Presentation.WorldCue",
	})

	for _, routeId in RouteIds.commands do
		check(RouteIds.isCommand(routeId))
		check(RouteIds.commandClassById[routeId :: string] ~= nil)
		check(not RouteIds.isEvent(routeId))
		check(not RouteIds.isUnreliableEvent(routeId))
	end
	for _, routeId in RouteIds.events do
		check(RouteIds.isEvent(routeId))
		check(not RouteIds.isCommand(routeId))
		check(not RouteIds.isUnreliableEvent(routeId))
	end
	for _, routeId in RouteIds.unreliableEvents do
		check(RouteIds.isUnreliableEvent(routeId))
		check(not RouteIds.isCommand(routeId))
		check(not RouteIds.isEvent(routeId))
	end

	local expectedClassByRoute = {
		[RouteIds.commands.sessionClientHello] = "A",
		[RouteIds.commands.sessionRequestResync] = "A",
		[RouteIds.commands.interactionPrimaryInteract] = "B",
		[RouteIds.commands.captureSubmitAction] = "C",
		[RouteIds.commands.worldRequestFastTravel] = "C",
		[RouteIds.commands.creatureSetLock] = "C",
		[RouteIds.commands.creatureRelease] = "C",
		[RouteIds.commands.vaultSetProductionAssignment] = "C",
		[RouteIds.commands.vaultClaimProduction] = "C",
		[RouteIds.commands.progressionPurchaseUnlock] = "C",
		[RouteIds.commands.socialPartyInvite] = "B",
		[RouteIds.commands.socialPartyRespond] = "B",
		[RouteIds.commands.socialPartyLeave] = "B",
		[RouteIds.commands.socialPing] = "B",
		[RouteIds.commands.socialChallengeRequest] = "B",
		[RouteIds.commands.socialChallengeRespond] = "B",
		[RouteIds.commands.tradeStart] = "C",
		[RouteIds.commands.tradeSetOffer] = "C",
		[RouteIds.commands.tradeSetReady] = "C",
		[RouteIds.commands.tradeFinalConfirm] = "C",
		[RouteIds.commands.tradeCancel] = "C",
		[RouteIds.commands.commerceRefreshEntitlements] = "D",
		[RouteIds.commands.settingsUpdatePreferences] = "B",
	}
	for routeId, expectedClass in expectedClassByRoute do
		check(RouteIds.commandClassById[routeId] == expectedClass, `wrong class for {routeId}`)
	end

	check(table.isfrozen(ProtocolV1))
	check(table.isfrozen(ProtocolV1.remoteNames))
	check(table.isfrozen(RouteIds))
	check(table.isfrozen(RouteIds.commands))
	check(table.isfrozen(RouteIds.events))
	check(table.isfrozen(RouteIds.unreliableEvents))
	check(table.isfrozen(RouteIds.commandClassById))
	check(not RouteIds.isCommand("Unknown.Route"))
	check(not RouteIds.isEvent({}))
	check(not RouteIds.isUnreliableEvent(nil))
end

return { run = run }
