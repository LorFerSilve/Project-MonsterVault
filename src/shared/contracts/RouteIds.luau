--!strict

-- V1 route identifiers are a public allowlist. Handler registration and payload
-- validation belong to the server gateway in IMP-4.
local commands: { [string]: string } = table.freeze({
	sessionClientHello = "Session.ClientHello",
	sessionRequestResync = "Session.RequestResync",
	interactionPrimaryInteract = "Interaction.PrimaryInteract",
	captureSubmitAction = "Capture.SubmitAction",
	worldRequestFastTravel = "World.RequestFastTravel",
	creatureSetLock = "Creature.SetLock",
	creatureRelease = "Creature.Release",
	vaultSetProductionAssignment = "Vault.SetProductionAssignment",
	vaultClaimProduction = "Vault.ClaimProduction",
	progressionPurchaseUnlock = "Progression.PurchaseUnlock",
	socialPartyInvite = "Social.PartyInvite",
	socialPartyRespond = "Social.PartyRespond",
	socialPartyLeave = "Social.PartyLeave",
	socialPing = "Social.Ping",
	socialChallengeRequest = "Social.ChallengeRequest",
	socialChallengeRespond = "Social.ChallengeRespond",
	tradeStart = "Trade.Start",
	tradeSetOffer = "Trade.SetOffer",
	tradeSetReady = "Trade.SetReady",
	tradeFinalConfirm = "Trade.FinalConfirm",
	tradeCancel = "Trade.Cancel",
	commerceRefreshEntitlements = "Commerce.RefreshEntitlements",
	settingsUpdatePreferences = "Settings.UpdatePreferences",
})

local events: { [string]: string } = table.freeze({
	commandResult = "Command.Result",
	sessionReady = "Session.Ready",
	sessionProtectedOutcome = "Session.ProtectedOutcome",
	projectionSnapshot = "Projection.Snapshot",
	projectionDelta = "Projection.Delta",
	captureStateChanged = "Capture.StateChanged",
	worldStateChanged = "World.StateChanged",
	socialStateChanged = "Social.StateChanged",
	eventStateChanged = "Event.StateChanged",
	tradeStateChanged = "Trade.StateChanged",
	commerceStateChanged = "Commerce.StateChanged",
	systemNotification = "System.Notification",
})

local unreliableEvents: { [string]: string } = table.freeze({
	presentationCaptureTiming = "Presentation.CaptureTiming",
	presentationWorldCue = "Presentation.WorldCue",
})

local commandClassById = table.freeze({
	[commands.sessionClientHello] = "A",
	[commands.sessionRequestResync] = "A",
	[commands.interactionPrimaryInteract] = "B",
	[commands.captureSubmitAction] = "C",
	[commands.worldRequestFastTravel] = "C",
	[commands.creatureSetLock] = "C",
	[commands.creatureRelease] = "C",
	[commands.vaultSetProductionAssignment] = "C",
	[commands.vaultClaimProduction] = "C",
	[commands.progressionPurchaseUnlock] = "C",
	[commands.socialPartyInvite] = "B",
	[commands.socialPartyRespond] = "B",
	[commands.socialPartyLeave] = "B",
	[commands.socialPing] = "B",
	[commands.socialChallengeRequest] = "B",
	[commands.socialChallengeRespond] = "B",
	[commands.tradeStart] = "C",
	[commands.tradeSetOffer] = "C",
	[commands.tradeSetReady] = "C",
	[commands.tradeFinalConfirm] = "C",
	[commands.tradeCancel] = "C",
	[commands.commerceRefreshEntitlements] = "D",
	[commands.settingsUpdatePreferences] = "B",
})

local eventSet: { [string]: boolean } = {}
for _, routeId in events do
	eventSet[routeId] = true
end
table.freeze(eventSet)

local unreliableEventSet: { [string]: boolean } = {}
for _, routeId in unreliableEvents do
	unreliableEventSet[routeId] = true
end
table.freeze(unreliableEventSet)

local RouteIds = {
	commands = commands,
	events = events,
	unreliableEvents = unreliableEvents,
	commandClassById = commandClassById,
}

function RouteIds.isCommand(value: unknown): boolean
	return type(value) == "string" and commandClassById[value :: string] ~= nil
end

function RouteIds.isEvent(value: unknown): boolean
	return type(value) == "string" and eventSet[value :: string] == true
end

function RouteIds.isUnreliableEvent(value: unknown): boolean
	return type(value) == "string" and unreliableEventSet[value :: string] == true
end

return table.freeze(RouteIds)
