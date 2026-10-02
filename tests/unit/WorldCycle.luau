--!strict

local Cycle = require("../../src/server/domains/world/WorldCycle")
local Registry = require("../../src/server/domains/world/WorldRegistry")
local Definitions = require("../../src/server/domains/world/WorldDefinitions")
local World = require("../../src/server/domains/world/WorldService")
local Plan = require("../../src/server/domains/world/SpawnPlan")
local Fixture = require("../../src/server/domains/world/FixtureDefinition")
local function check(value: any, message: string?): any
	return assert(value, message or "world cycle invariant")
end
local function clone(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local result = {}
	for key, child in value do
		result[key] = clone(child)
	end
	return result
end
local function definitionsAndBindingsFailClosed()
	for _, mutate in
		{
			function(c: any)
				c.worldCycle = nil
			end,
			function(c: any)
				c.worldCycle.epochUnixSeconds = 0 / 0
			end,
			function(c: any)
				c.worldCycle.version = math.huge
			end,
			function(c: any)
				c.worldCycle.id = "world-cycle/ordinary-dev-v2"
			end,
			function(c: any)
				c.worldCycle.phases[1].id = "world-phase/night"
			end,
			function(c: any)
				c.worldCycle.phases[1].durationSeconds = 0
			end,
			function(c: any)
				c.worldCycle.phases[1].durationSeconds = 3601
			end,
			function(c: any)
				c.worldCycle.phases[1].durationSeconds = 1.5
			end,
			function(c: any)
				c.worldCycle.phases[4] = c.worldCycle.phases[1]
			end,
			function(c: any)
				c.worldCycle.phases.extra = {}
			end,
			function(c: any)
				c.worldCycle.phases[1] = nil
			end,
			function(c: any)
				c.worldCycle.clientPhase = "world-phase/day"
			end,
			function(c: any)
				c.worldCycle.phases[1].rarityBonus = 2
			end,
			function(c: any)
				c.habitats[1].cycleDefinitionId = nil
			end,
			function(c: any)
				c.spawnContexts[2].cyclePhaseIds = {}
			end,
			function(c: any)
				c.spawnContexts[2].cyclePhaseIds = { [2] = "world-phase/dusk" }
			end,
			function(c: any)
				c.spawnContexts[2].cyclePhaseIds = { "world-phase/fake" }
			end,
			function(c: any)
				c.spawnContexts[2].cyclePhaseIds = { "world-phase/day", "world-phase/day" }
			end,
			function(c: any)
				c.habitats[2].cyclePhaseIds = { "world-phase/day" }
			end,
		}
	do
		local config = clone(Definitions)
		mutate(config)
		check(not pcall(Registry.new, config), "invalid cycle binding accepted")
	end
	local restricted = clone(Definitions)
	restricted.spawnContexts[1].cyclePhaseIds = { "world-phase/day" }
	local registry = Registry.new(restricted)
	local positions = {}
	for id in registry.spawnContexts do
		positions[id] = clone(Fixture.position)
	end
	check(not pcall(Plan.new, registry, positions, Fixture), "protected fallback phase-gated")
end
local function absoluteBoundariesAndNoReset()
	local registry = Registry.new(Definitions)
	local now = -1
	local clock = function()
		return now
	end
	local cycle = Cycle.new(registry.worldCycle, clock)
	local cases: { { any } } = {
		{ -1, "day", 0, 0, 300 },
		{ 0, "day", 0, 0, 300 },
		{ 299.999, "day", 0, 0, 300 },
		{ 300, "dusk", 0, 300, 600 },
		{ 599.999, "dusk", 0, 300, 600 },
		{ 600, "night", 0, 600, 900 },
		{ 899.999, "night", 0, 600, 900 },
		{ 900, "day", 1, 900, 1200 },
		{ 1800300, "dusk", 2000, 1800300, 1800600 },
	}
	for _, case in cases do
		now = case[1]
		local state = cycle.sample()
		check(state.phaseId == "world-phase/" .. case[2] and state.cycleIndex == case[3])
		check(
			state.phaseStartedAtUnixSeconds == case[4]
				and state.nextTransitionUnixSeconds == case[5]
		)
		check(state == cycle.sample(), "duplicate sample must preserve snapshot")
		local other = Cycle.new(registry.worldCycle, clock).sample()
		check(
			other.phaseId == state.phaseId and other.cycleIndex == state.cycleIndex,
			"fresh server resets cycle"
		)
		check(table.isfrozen(state) and not pcall(function()
			state.phaseId = "client/fake"
		end))
	end
	check(table.isfrozen(registry.worldCycle) and table.isfrozen(registry.worldCycle.phases[1]))
end
local function authoredContextsRemainPhaseIndependent()
	local registry = Registry.new(Definitions)
	local now = 0
	local cycle = Cycle.new(registry.worldCycle, function()
		return now
	end)
	for _, time in { 0, 300, 600, 900 } do
		now = time
		local count = 0
		for _, context in registry.spawnContexts do
			check(Cycle.eligible(registry.habitats[context.habitatId], context, cycle.sample()))
			check(#context.cyclePhaseIds == 3, "DEV contexts cannot gain new phase rules")
			count += 1
		end
		check(count == 8)
	end
	local context = registry.spawnContexts[Fixture.spawnContextId]
	check(not Cycle.eligible(nil, context, cycle.sample()))
	check(not Cycle.eligible(registry.habitats[context.habitatId], context, nil))
	local missing = clone(context)
	missing.cycleDefinitionId = nil
	check(not Cycle.eligible(registry.habitats[context.habitatId], missing, cycle.sample()))
end
local function harness(restricted: boolean?, extra: any?): any
	local registry = Registry.new(Definitions)
	local context = clone(registry.spawnContexts[Fixture.spawnContextId])
	if restricted then
		context.cyclePhaseIds = { "world-phase/day" }
	end -- Test-only predicate.
	local habitat = registry.habitats[context.habitatId]
	local wall, mono, selected, evaluated, ids = 299, 0, 0, 0, 0
	local cycle = Cycle.new(registry.worldCycle, function()
		return wall
	end)
	local options: any = {
		fixture = Fixture,
		clock = function()
			return mono
		end,
		newId = function()
			ids += 1
			return "cycle-test-" .. ids
		end,
		evaluateContext = function()
			evaluated += 1
			local snapshot = cycle.sample()
			return if Cycle.eligible(habitat, context, snapshot) then snapshot else nil
		end,
		generateVariant = function()
			selected += 1
			return table.freeze({ signature = "fixed" })
		end,
		materialize = function()
			return {}
		end,
		activate = function() end,
		destroyProjection = function() end,
	}
	for key, value in extra or {} do
		options[key] = value
	end
	local world = World.new(options)
	local generation = world.start()
	return {
		world = world,
		options = options,
		generation = generation,
		step = function()
			return world.step(generation)
		end,
		time = function(w: number, m: number)
			wall, mono = w, m
		end,
		stats = function()
			return { selected = selected, evaluated = evaluated, ids = ids }
		end,
	}
end
local function prospectiveEligibilityAndFreshIdentity()
	local h = harness(true)
	h.step()
	local oldId = check(h.world.currentId())
	local oldIdentity = h.world.identity(oldId)
	h.time(300, 1)
	h.step()
	check(h.world.get(oldId) and h.world.identity(oldId).cycleContext == oldIdentity.cycleContext)
	check(h.stats().evaluated == 1 and h.stats().selected == 1, "existing entity re-evaluated")
	check(h.world.retire(oldId))
	h.time(600, 10)
	h.step()
	check(h.world.currentId() == nil and h.stats().ids == 1, "ineligible phase allocated/rerolled")
	h.time(900, 11)
	h.step()
	local id = check(h.world.currentId())
	check(id ~= oldId and h.world.identity(id).cycleContext.cycleIndex == 1)
	check(
		oldIdentity.cycleContext.cycleIndex == 0
			and oldIdentity.cycleContext.phaseId == "world-phase/day"
	)
	h.world.stop()
end
local function pendingReservationsPinContextAcrossTransition()
	local attempts = 0
	local h = harness(true, {
		materialize = function()
			attempts += 1
			if attempts == 1 then
				error("placement failure")
			end
			return {}
		end,
	})
	h.step()
	local id = check(h.world.currentId())
	local identity = h.world.identity(id)
	check(h.world.get(id) == nil and h.world.populationCount() == 1)
	h.time(300, 2)
	h.step()
	check(h.world.get(id), "phase transition cancelled valid prior reservation")
	check(h.world.identity(id).cycleContext == identity.cycleContext and h.stats().selected == 1)
	check(h.stats().evaluated == 1 and attempts == 2)
	h.world.stop()
end
local function captureCustodyAndHistoryAreProspective()
	for _, state in
		{ "Claimed", "AttemptActive", "ProvisionalCaptured", "InTransport", "FinalizationPending" }
	do
		local h = harness(true)
		h.step()
		local id = check(h.world.currentId())
		local identity = h.world.identity(id)
		check(h.world.transition(id, "IdleAvailable", state))
		h.time(1800, Fixture.lifetimeSeconds + 1)
		h.step()
		check(
			h.world.populationCount() == 1
				and h.world.identity(id).cycleContext == identity.cycleContext
		)
		check(not h.world.expireIfCurrent(id, 2) and h.stats().selected == 1)
		check(h.world.retire(id))
		h.time(2100, Fixture.lifetimeSeconds + 20)
		h.step()
		check(h.world.currentId() == nil, "old eligible context leaked into new reservation")
		check(identity.cycleContext.phaseId == "world-phase/day", "history rewritten")
		h.world.stop()
	end
end
local function invalidClockPausesAdmissionAndRecovers()
	local registry = Registry.new(Definitions)
	local value, throws = 300, false
	local cycle = Cycle.new(registry.worldCycle, function()
		if throws then
			error("clock failure")
		end
		return value
	end)
	local pinned = cycle.sample()
	for _, invalid in { 299, 0 / 0, math.huge, -math.huge } do
		value = invalid
		check(cycle.sample() == nil)
	end
	throws = true
	check(cycle.sample() == nil)
	throws, value = false, 600
	check(cycle.sample().phaseId == "world-phase/night" and pinned.phaseId == "world-phase/dusk")
	local h = harness()
	h.time(0 / 0, 0)
	h.step()
	check(h.world.populationCount() == 0 and h.stats().selected == 0 and h.stats().ids == 0)
	h.time(300, 1)
	h.step()
	check(
		h.world.populationCount() == 1
			and h.world.identity(h.world.currentId()).cycleContext.phaseId == "world-phase/dusk"
	)
	h.world.stop()
end
local function yieldedStaleContextCannotAllocate()
	local h = harness(false, {
		evaluateContext = function()
			coroutine.yield()
			return {}
		end,
	})
	local thread = coroutine.create(h.step)
	check(coroutine.resume(thread))
	check(h.step() == "Busy")
	h.world.stop()
	check(coroutine.resume(thread))
	check(h.world.populationCount() == 0 and h.stats().ids == 0)
	check(h.world.step(h.generation) == "Stale")
end
return {
	definitionsAndBindingsFailClosed = definitionsAndBindingsFailClosed,
	absoluteBoundariesAndNoReset = absoluteBoundariesAndNoReset,
	authoredContextsRemainPhaseIndependent = authoredContextsRemainPhaseIndependent,
	prospectiveEligibilityAndFreshIdentity = prospectiveEligibilityAndFreshIdentity,
	pendingReservationsPinContextAcrossTransition = pendingReservationsPinContextAcrossTransition,
	captureCustodyAndHistoryAreProspective = captureCustodyAndHistoryAreProspective,
	invalidClockPausesAdmissionAndRecovers = invalidClockPausesAdmissionAndRecovers,
	yieldedStaleContextCannotAllocate = yieldedStaleContextCannotAllocate,
}
