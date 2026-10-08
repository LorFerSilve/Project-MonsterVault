--!strict
local Feedback = require("../../src/client/presentation/GoldenFeedback")
local Projection = require("../../src/server/application/VaultAssignmentProjection")
local Contract = require("../../src/shared/contracts/VaultAssignmentProjectionV1")
local Controller = require("../../src/client/controllers/VaultAssignmentController")
local Schema = require("../../src/server/infrastructure/persistence/ProfileSchemaV1")
local Wire = require("../../src/shared/contracts/WireValidation")
local Routes = require("../../src/shared/contracts/RouteIds")
local Production = require("../../src/server/domains/vault/VaultProductionService")
local Config = require("../../src/shared/config/VaultProductionFixture")
local Preferences = require("../../src/client/presentation/PresentationPreferences")
local Showcase = require("../../src/server/application/ShowcaseProjection")
local ShowcaseContract = require("../../src/shared/contracts/ShowcaseProjectionV1")
local function boundedCreatureMotion()
	for _, role in { "world", "legendary", "display", "custody" } do
		for tick = 0, 600 do
			local lift, pitch, yaw, roll = Feedback.pose(role, tick / 20, tick % 10, 0.15, false)
			assert(
				lift == lift and math.abs(lift) <= 0.12,
				"idle stays inside the display clearance"
			)
			assert(
				math.abs(pitch) <= 0.175 and math.abs(yaw) <= 0.09 and math.abs(roll) <= 0.045,
				"reaction/idle cannot turn a visual out of its readable framing"
			)
		end
	end
end
local function reducedCreatureMotion()
	for _, role in { "world", "legendary", "display", "custody" } do
		local lift, pitch, yaw, roll = Feedback.pose(role, 5.1, 2.7, -0.15, true)
		assert(
			lift == 0 and pitch == 0 and yaw == 0 and roll == 0,
			"reduced effects retain the exact authored framing even during a reaction"
		)
	end
end
local function platformReducedMotionAndDisconnect()
	local listener, disconnected, updates = nil, false, 0
	local service = { ReducedMotionEnabled = true } :: any
	function service:GetPropertyChangedSignal(name)
		assert(name == "ReducedMotionEnabled", "bind exactly the platform motion preference")
		return {
			Connect = function(_self, fn)
				listener = fn
				return {
					Disconnect = function()
						disconnected = true
						listener = nil
					end,
				}
			end,
		}
	end
	local state = { reducedMotion = false }
	local binding = Preferences.bind(service, state, function()
		updates += 1
	end)
	assert(state.reducedMotion and updates == 1, "platform Reduced Motion applies immediately")
	binding.toggleReduced()
	binding.toggleReduced()
	assert(state.reducedMotion, "manual preference cannot defeat the platform setting")
	service.ReducedMotionEnabled = false
	assert(listener, "platform preference listener was connected")()
	assert(not state.reducedMotion, "platform change updates the current presentation")
	binding.toggleReduced()
	assert(state.reducedMotion, "manual reduction survives a platform opt-out")
	binding.stop()
	assert(disconnected and listener == nil, "shutdown disconnects the platform listener")
end
local function fixture(): any
	local p = Schema.default(1000)
	p.profileRevision = 10
	p.economy.energyUnits = 73
	p.collection.creaturesById = {
		a = {
			creatureInstanceId = "a",
			speciesId = "species/fixture-orb",
			ownerUserId = 42,
			locked = true,
			overflowHeld = false,
			operationId = "private-operation",
			origin = { private = "provenance" },
			variantIdentity = {
				speciesRarityId = "rarity/common",
				mutationIdsCanonical = { "mutation/test" },
				traitIds = { "trait/test" },
				variantSignature = "private-signature",
			},
		},
	}
	p.vault.displayAssignments = { ["display/1"] = "a" }
	p.vault.productionAssignments = {}
	p.vault.productionBufferMilli = 27000
	p.vault.productionRateEpochId = Config.epochs[1].epochId
	return p
end
local function projected(p: any, afterId: string?): any
	local production = Production.new(Config)
	return Projection.fromProfile(
		p,
		production,
		afterId,
		Wire.payload,
		Showcase.fromProfile(p, 42, production).creatures[1]
	)
end
local function noUnconfirmedCelebration()
	local f = Feedback.new()
	for _, state in
		{
			"Claimed",
			"AttemptActive",
			"Provisional",
			"TransportGrace",
			"FinalizationPending",
			"OutcomeUnknown",
		}
	do
		assert(f.capture({
			state = state,
			notification = "Secured",
			notificationRevision = 900,
			creatureInstanceId = "a",
		}) == nil, "unconfirmed state cannot celebrate ownership")
	end
	assert(
		f.capture({ state = "TransportActive", creatureInstanceId = "a", captureSessionId = "c" })
			== "Containment",
		"custody remains separate from ownership"
	)
end
local function terminalDeduplication()
	local f = Feedback.new()
	local s = {
		state = "Secured",
		notificationRevision = 12,
		creatureInstanceId = "a",
		captureSessionId = "c",
	}
	assert(f.capture(s) == "Secured", "first confirmed Secured celebrates")
	assert(f.capture(s) == nil, "duplicate Secured is quiet")
	f.capture({ state = "Idle" })
	assert(f.capture(s) == nil, "old terminal readback cannot replay payoff")
	s.notificationRevision = 13
	s.creatureInstanceId = "b"
	s.captureSessionId = "d"
	assert(f.capture(s) == "Secured", "new confirmed capture celebrates")
end
local function receiptAmountAndReducedMotion()
	local a = Feedback.claim(27, 100, false)
	assert(
		a.from == 73 and a.to == 100 and a.duration <= 1.5 and a.strong,
		"claim starts at previous balance and ends at authoritative total"
	)
	local b = Feedback.claim(27, 100, true)
	assert(
		b.from == a.from and b.to == a.to and b.duration == 0,
		"Reduced Motion retains the exact claim amount"
	)
	assert(Feedback.claim(0, 100, false).to == 100, "zero claim retains the confirmed balance")
end
local function safeIntrinsicCopy()
	local p = fixture()
	local before = Wire.copy(p)
	local payload = projected(p)
	local r = payload.state.creatures[1]
	assert(
		Contract.validSnapshot(payload) and Wire.payload(payload),
		"safe owner facts fit strict contract and gateway budget"
	)
	assert(
		r.creatureInstanceId == "a"
			and r.speciesId == "species/fixture-orb"
			and r.rarityId == "rarity/common"
			and r.displaySlotId == "display/1",
		"exact instance and intrinsic facts survive projection"
	)
	assert(
		r.ownerUserId == nil
			and r.origin == nil
			and r.operationId == nil
			and r.variantSignature == nil
			and r.profile == nil,
		"private owner fields are absent"
	)
	assert(Wire.equal(p, before), "projection cannot mutate profile or Energy")
	r.mutationIds[1] = "client-edit"
	r.traitIds[1] = "client-edit"
	assert(Wire.equal(p, before), "intrinsic arrays must not alias private records")
end
local function budgetFallbackKeepsGameplay()
	local p = fixture()
	local before = Wire.copy(p)
	p.collection.creaturesById.a.variantIdentity.traitIds = {}
	for _i = 1, 16 do
		table.insert(p.collection.creaturesById.a.variantIdentity.traitIds, string.rep("t", 128))
	end
	local payload = Projection.fromProfile(p, Production.new(Config), nil, function(value)
		return Wire.payload(value, 4096)
	end)
	local r = payload.state.creatures[1]
	assert(
		r.speciesId == nil and r.rarityId == nil and r.mutationIds == nil and r.traitIds == nil,
		"over-budget facts are withheld together"
	)
	assert(
		payload.state.energyUnits == before.economy.energyUnits and r.displaySlotId == "display/1",
		"fallback retains assignment and authoritative Energy"
	)
	assert(
		Contract.validSnapshot(payload) and Wire.payload(payload, 4096),
		"fallback remains valid under the existing wire budget"
	)
end
local function partialAndHiddenFactsRejected()
	local payload = projected(fixture())
	local r = payload.state.creatures[1]
	r.operationId = "forged"
	assert(not Contract.validSnapshot(payload), "hidden field is rejected")
	r.operationId = nil
	r.traitIds = nil
	assert(not Contract.validSnapshot(payload), "partial intrinsic facts are rejected")
	r.traitIds = {}
	r.mutationIds = { [1] = "mutation/a", [3] = "mutation/b" }
	assert(not Contract.validSnapshot(payload), "sparse Mutation array is rejected")
end
local function displayedFactsSurviveBoundedPage()
	local p = fixture()
	local first = p.collection.creaturesById.a
	local second = Wire.copy(first)
	local a = "creature-43aed3cd-585c-4589-84b8-6b7365b05b98-1"
	local b = "creature-8c4ca8d1-e318-493f-a23a-28dba650b639-6"
	first.creatureInstanceId, second.creatureInstanceId = a, b
	first.variantIdentity.traitIds, first.variantIdentity.mutationIdsCanonical =
		{ "trait/fixture-steady" }, {}
	second.variantIdentity.traitIds, second.variantIdentity.mutationIdsCanonical = {}, {}
	p.collection.creaturesById = { [a] = first, [b] = second }
	p.vault.productionAssignments = { ["production/1"] = a }
	p.vault.displayAssignments = { ["display/1"] = b }
	local before = Wire.copy(p)
	local payload = projected(p)
	assert(
		Contract.validSnapshot(payload) and Wire.payload(payload),
		"display page fits strict contract and wire budget"
	)
	assert(payload.state.creatures[1].creatureInstanceId == a, "page order is unchanged")
	assert(
		payload.state.displayCard.speciesId == second.speciesId,
		"independent display card gets bounded presentation priority"
	)
	assert(
		payload.state.creatures[1].productionSlotId == "production/1",
		"production assignment survives presentation ordering"
	)
	assert(Wire.equal(p, before), "profile is unchanged by presentation ordering")
end
local function displayIndependentOfManagementPage()
	local p = fixture()
	for _, name in { "b", "c" } do
		local record = Wire.copy(p.collection.creaturesById.a)
		record.creatureInstanceId = name
		p.collection.creaturesById[name] = record
	end
	p.vault.displayAssignments = { ["display/1"] = "c" }
	p.vault.productionAssignments = { ["production/1"] = "a" }
	local before = Wire.copy(p)
	local first, last = projected(p), projected(p, "b")
	assert(
		first.state.creatures[2].creatureInstanceId == "b" and first.state.hasMore,
		"management page is still bounded and ordered"
	)
	assert(
		last.state.creatures[1].creatureInstanceId == "c" and not last.state.hasMore,
		"management cursor still works"
	)
	assert(first.state.displayCard.creatureInstanceId == "c", "off-page display is projected")
	assert(
		Wire.equal(first.state.displayCard, last.state.displayCard),
		"paging cannot remove or redefine the displayed instance"
	)
	assert(
		ShowcaseContract.validCreature(first.state.displayCard),
		"display uses the existing exact safe Showcase card"
	)
	assert(
		Contract.validSnapshot(first) and Wire.payload(first),
		"first page retains its protocol budget"
	)
	assert(
		Contract.validSnapshot(last) and Wire.payload(last),
		"later page retains its protocol budget"
	)
	assert(Wire.equal(p, before), "display readback cannot mutate any owner value")
	first.state.displayCard.mutationIds[1] = "mutation/client"
	assert(
		p.collection.creaturesById.c.variantIdentity.mutationIdsCanonical[1] == "mutation/test",
		"presentation arrays do not alias the saved creature"
	)
end
local function displayDisclosureAndBudget()
	local p = fixture()
	local production = Production.new(Config)
	p.collection.creaturesById.a.ownerUserId = 99
	assert(projected(p).state.displayCard == nil, "foreign ownership cannot be displayed")
	p.collection.creaturesById.a.ownerUserId = 42
	p.collection.creaturesById.a.overflowHeld = true
	assert(projected(p).state.displayCard == nil, "overflow creatures cannot be displayed")
	p.collection.creaturesById.a.overflowHeld = false
	p.vault.productionAssignments = { ["production/1"] = "a" }
	assert(
		projected(p).state.displayCard == nil,
		"production does not become a second display instance"
	)
	p.vault.productionAssignments = {}
	local payload = projected(p)
	payload.state.displayCard.locked = true
	assert(
		not Contract.validSnapshot(payload),
		"owner management fields cannot enter the display card"
	)
	payload.state.displayCard.locked = nil
	payload.state.displayCard.traitIds = nil
	assert(not Contract.validSnapshot(payload), "partial intrinsic identity is rejected")
	local traits = {}
	for i = 1, 16 do
		traits[i] = "trait/" .. string.rep("x", 110) .. tostring(i)
	end
	p.collection.creaturesById.a.variantIdentity.traitIds = traits
	local before = Wire.copy(p)
	local safe = Showcase.fromProfile(p, 42, production).creatures[1]
	local bounded = Projection.fromProfile(p, production, nil, function(value)
		return Wire.payload(value, 4096)
	end, safe)
	assert(
		bounded.state.displayCard == nil,
		"withhold the complete display card when it cannot fit"
	)
	assert(
		Contract.validSnapshot(bounded) and Wire.payload(bounded, 4096),
		"gameplay readback survives the presentation budget"
	)
	assert(
		bounded.state.energyUnits == before.economy.energyUnits and Wire.equal(p, before),
		"budget fallback changes no saved owner value"
	)
end
local function receiptFixture(observer: any): any
	local serial, now, codes = 0, 0, {}
	local c = Controller.new({
		gateway = {
			send = function()
				serial += 1
				return tostring(serial)
			end,
			resultFor = function(id)
				return codes[id]
			end,
		},
		routes = Routes,
		projection = Contract,
		sessionReady = function()
			return true
		end,
		clock = function()
			return now
		end,
		onClaimSettled = observer,
	})
	local initial = projected(fixture())
	c.tick()
	assert(
		c.handleSnapshot({ payload = initial, revision = 10, correlationId = "1" }) == "Applied",
		"matching page is accepted"
	)
	assert(c.claim() == "2", "claim uses the current authoritative revision")
	return {
		controller = c,
		initial = initial,
		setTime = function(t)
			now = t
		end,
		codes = codes,
	}
end
local function confirmedReceiptOnlyOnce()
	local cues: { any } = {}
	local f: any = nil
	f = receiptFixture(function(amount, revision, balance)
		local view = f.controller.view()
		table.insert(cues, {
			amount,
			revision,
			balance,
			not view.pending and view.snapshot.state.energyUnits == balance,
		})
	end)
	local c = f.controller
	assert(
		c.handleSnapshot({ payload = f.initial, revision = 10, correlationId = "2" })
				== "Unconfirmed"
			and #cues == 0,
		"unconfirmed receipt cannot animate"
	)
	f.setTime(6)
	c.tick()
	local saved = Wire.copy(f.initial)
	saved.revision = 11
	saved.state.claimExpectedRevision = 10
	saved.state.claimUnits = 27
	saved.state.energyUnits = 100
	assert(
		c.handleSnapshot({ payload = saved, revision = 11, correlationId = "foreign" }) == "Stale"
			and #cues == 0,
		"unrelated callback cannot animate"
	)
	assert(
		c.handleSnapshot({ payload = saved, revision = 11, correlationId = "3" }) == "Applied"
			and #cues == 1,
		"matching recovery receipt animates once"
	)
	assert(
		cues[1][1] == 27 and cues[1][2] == 10 and cues[1][3] == 100 and cues[1][4],
		"observer receives exact values after client settlement"
	)
	c.handleSnapshot({ payload = saved, revision = 11, correlationId = "3" })
	assert(#cues == 1, "replayed receipt is quiet")
end
local function cosmeticFailureCannotInterruptClaim()
	local f = receiptFixture(function()
		error("cosmetic failure")
	end)
	local saved = Wire.copy(f.initial)
	saved.revision = 11
	saved.state.claimExpectedRevision = 10
	saved.state.claimUnits = 27
	saved.state.energyUnits = 100
	assert(
		f.controller.handleSnapshot({ payload = saved, revision = 11, correlationId = "2" })
			== "Applied",
		"cosmetic failure cannot block receipt settlement"
	)
	assert(
		not f.controller.view().pending and f.controller.view().snapshot.state.energyUnits == 100,
		"cosmetic failure leaves confirmed wallet and clears pending"
	)
end
return {
	boundedCreatureMotion = boundedCreatureMotion,
	reducedCreatureMotion = reducedCreatureMotion,
	platformReducedMotionAndDisconnect = platformReducedMotionAndDisconnect,
	noUnconfirmedCelebration = noUnconfirmedCelebration,
	terminalDeduplication = terminalDeduplication,
	receiptAmountAndReducedMotion = receiptAmountAndReducedMotion,
	safeIntrinsicCopy = safeIntrinsicCopy,
	budgetFallbackKeepsGameplay = budgetFallbackKeepsGameplay,
	partialAndHiddenFactsRejected = partialAndHiddenFactsRejected,
	displayedFactsSurviveBoundedPage = displayedFactsSurviveBoundedPage,
	displayIndependentOfManagementPage = displayIndependentOfManagementPage,
	displayDisclosureAndBudget = displayDisclosureAndBudget,
	confirmedReceiptOnlyOnce = confirmedReceiptOnlyOnce,
	cosmeticFailureCannotInterruptClaim = cosmeticFailureCannotInterruptClaim,
}
