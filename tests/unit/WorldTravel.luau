--!strict

local Travel = require("../../src/server/domains/world/WorldTravelService")
local Progress = require("../../src/server/domains/world/WorldProgressionService")
local Registry = require("../../src/server/domains/world/WorldRegistry")
local Definitions = require("../../src/server/domains/world/WorldDefinitions")
local Schema = require("../../src/server/infrastructure/persistence/ProfileSchemaV1")
local function check(value: any, message: string?): any
	return assert(value, message or "travel invariant")
end
local function copy(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local result = {}
	for key, child in value do
		result[key] = copy(child)
	end
	return result
end
local function discoveryPreparationAndProtectedEpochs()
	local world = Progress.new(Registry.new(Definitions))
	local p = Schema.default(1000)
	check(world.prepare(p).changed)
	local original = copy(p.world)
	p.world.travelNodes = nil
	check(
		world.prepare(p).changed and next(p.world.travelNodes) == nil,
		"legacy discovery backfilled"
	)
	for id, fact in original.landmarks do
		check(p.world.landmarks[id] == fact)
	end
	check(world.discoverTravel(p, "travel-node/starter", "observed-op"))
	p.profileRevision += 1
	check(world.travelDiscovered(p, "travel-node/starter"))
	check(not world.discoverTravel(p, "travel-node/starter", "duplicate"))
	check(p.world.travelNodes["travel-node/starter"].operationId == "observed-op")
	check(
		next(p.world.mastery) == nil and next(p.world.objectives) == nil and next(p.economy) == nil,
		"node discovery grants mastery/value"
	)
	p.world.travelNodes["travel-node/starter"].contentSnapshotId =
		"content-snapshot/imp10-world-dev-v1"
	check(
		world.validate(p) == "UNBOUND_TRAVEL_FACT"
			and not world.travelDiscovered(p, "travel-node/starter")
	)
	p.world.travelNodes = { ["travel-node/forged"] = original }
	check(world.validate(p) == "INVALID_WORLD_FACT")
	local config = copy(Definitions)
	config.travelNodes[1].discoveryContentSnapshotIds = nil
	check(not pcall(Registry.new, config), "missing discovery epoch accepted")
end
local function harness(extra: any?): any
	local player: any = { UserId = 42, Character = {} }
	local context: any = {
		session = {},
		character = player.Character,
		generation = 1,
		validPosition = true,
		regionId = "home",
		player = player,
	}
	local time, moves, observed, recovering = 0, 0, 0, 0
	local options: any = {
		clock = function()
			return time
		end,
		context = function()
			return context
		end,
		recovery = function(_c: any, last: string?)
			return { regionId = last or "home" }
		end,
		destination = function(c: any, id: string): (any, string)
			if not c.validPosition or id ~= "field" then
				return nil, "DESTINATION"
			end
			if c.blocked then
				return nil, "ACQUISITION"
			end
			return { regionId = "field" }, "OK"
		end,
		relocate = function(
			_p: any,
			_c: any,
			target: any,
			recovery: boolean,
			current: () -> boolean
		)
			check(current(), "stale relocation")
			moves += 1
			if recovery then
				context.generation += 1
				recovering += 1
			end
			context.regionId, context.validPosition, context.hazardId = target.regionId, true, nil
			return true
		end,
		observe = function()
			observed += 1
		end,
	}
	for key, value in extra or {} do
		options[key] = value
	end
	local owner = Travel.new(options)
	return {
		owner = owner,
		player = player,
		context = context,
		options = options,
		step = function()
			owner.step({ player })
		end,
		advance = function()
			time += 1
		end,
		stats = function()
			return { moves = moves, observed = observed, recovering = recovering }
		end,
		setContext = function(value: any)
			context = value
		end,
	}
end
local function arrivalRecoveryAndNoRepeatedRelocation()
	local h = harness()
	check(not h.owner.ready(h.player, 1), "unplaced character actionable")
	h.step()
	check(h.owner.ready(h.player, 2) and h.stats().moves == 1)
	for _ = 1, 30 do
		h.step()
		h.advance()
	end
	check(h.stats().moves == 1, "ordinary pulse repeats recovery")
	h.context.validPosition = false
	check(not h.owner.ready(h.player, 2), "invalid position remains actionable before recovery")
	h.step()
	check(h.stats().recovering == 2 and h.owner.ready(h.player, 3))
	h.step()
	check(h.stats().moves == 2)
	h.owner.step({})
	check(not h.owner.ready(h.player, 3), "disconnected presence retained")
	h.step()
	check(h.owner.ready(h.player, 4), "reconnect cannot recover")
end
local function staleGenerationAndBoundedSpam()
	local h = harness()
	h.step()
	check(h.owner.travel(h.player, "field", 1) == "REJECT_STATE_TRAVEL_STALE")
	check(h.owner.travel(h.player, "forged", 2) == "REJECT_STATE_TRAVEL_DESTINATION")
	check(h.owner.travel(h.player, "field", 2) == "OK_WORLD_TRAVELLED")
	local count = h.stats().moves
	for _ = 1, 100 do
		check(h.owner.travel(h.player, "field", 2) == "REJECT_RATE_LIMIT")
	end
	check(h.stats().moves == count)
	h.context.blocked = true
	h.advance()
	check(h.owner.travel(h.player, "field", 2) == "REJECT_STATE_TRAVEL_ACQUISITION")
	h.owner.stop()
	check(
		not h.owner.ready(h.player, 2)
			and h.owner.travel(h.player, "field", 2) == "REJECT_STATE_TRAVEL_CONTEXT"
	)
end
local function interruptedRelocationRecoversWithoutReplay()
	local fail, moves = false, 0
	local h = harness({
		relocate = function(
			_p: any,
			c: any,
			target: any,
			recovery: boolean,
			current: () -> boolean
		)
			check(current())
			moves += 1
			if fail then
				fail = false
				error("interrupted relocation")
			end
			if recovery then
				c.generation += 1
			end
			c.regionId, c.validPosition = target.regionId, true
			return true
		end,
	})
	h.step()
	fail = true
	check(h.owner.travel(h.player, "field", 2) == "UNAVAILABLE_TRAVEL_ARRIVAL")
	check(not h.owner.ready(h.player, 2))
	h.step()
	check(moves == 2, "recovery delay ignored")
	h.advance()
	h.step()
	check(
		h.owner.ready(h.player, 3) and h.context.regionId == "home",
		"failed travel replayed instead of recovery"
	)
end
local function yieldedRaceAndReplacedCharacterFence()
	local h = harness()
	h.step()
	local moves = 0
	h.options.relocate = function(_p: any, _c: any, _t: any, _r: boolean, current: () -> boolean)
		coroutine.yield()
		if not current() then
			return false
		end
		moves += 1
		return true
	end
	local outcome: any = nil
	local thread = coroutine.create(function()
		outcome = h.owner.travel(h.player, "field", 2)
	end)
	check(coroutine.resume(thread))
	check(h.owner.travel(h.player, "field", 2) == "REJECT_STATE_TRAVEL_BUSY")
	h.step()
	h.player.Character = {}
	local replacement = table.clone(h.context)
	replacement.character, replacement.generation = h.player.Character, 3
	h.setContext(replacement)
	check(coroutine.resume(thread))
	check(moves == 0 and outcome == "UNAVAILABLE_TRAVEL_ARRIVAL")
	h.options.relocate = function(_p: any, c: any, _t: any, _r: boolean, current: () -> boolean)
		check(current())
		c.generation += 1
		return true
	end
	h.advance()
	h.step()
	check(h.owner.ready(h.player, 4), "replacement avatar not recoverable")
end
local function yieldedShutdownAndMissingAnchorsFailClosed()
	local h = harness({
		recovery = function()
			return nil
		end,
	})
	h.step()
	check(not h.owner.ready(h.player, 1) and h.stats().moves == 0, "missing anchor relocates")
	h.options.recovery = function()
		return { regionId = "home" }
	end
	h.advance()
	h.step()
	h.options.relocate = function(_p: any, _c: any, _t: any, _r: boolean, current: () -> boolean)
		coroutine.yield()
		return current()
	end
	local outcome: any = nil
	local thread = coroutine.create(function()
		outcome = h.owner.travel(h.player, "field", 2)
	end)
	check(coroutine.resume(thread))
	h.owner.stop()
	check(coroutine.resume(thread))
	check(outcome == "REJECT_STATE_TRAVEL_STALE" and not h.owner.ready(h.player, 2))
end
local function replacementSessionRequiresSafeArrival()
	local h = harness()
	h.step()
	check(h.owner.travel(h.player, "field", 2) == "OK_WORLD_TRAVELLED")
	local replacement = table.clone(h.context)
	replacement.session = {}
	h.setContext(replacement)
	local before = h.stats()
	check(not h.owner.ready(h.player, 2), "replacement session inherited safe arrival")
	check(h.owner.travel(h.player, "field", 2) == "REJECT_STATE_TRAVEL_STALE")
	check(h.stats().moves == before.moves and h.stats().observed == before.observed)
	h.advance()
	h.step()
	check(
		replacement.regionId == "home" and h.owner.ready(h.player, 3),
		"replacement session inherited previous recovery region"
	)
	h.step()
	check(h.stats().moves == before.moves + 1, "replacement session recovered repeatedly")
	h.setContext(nil) -- A temporary trust pause is not a replacement session.
	h.step()
	check(not h.owner.ready(h.player, 3))
	h.setContext(replacement)
	h.step()
	check(h.owner.ready(h.player, 3) and h.stats().moves == before.moves + 1)
end
local function replacementSessionWaitsForValidAnchor()
	local available = true
	local h = harness({
		recovery = function(_c: any, last: string?): any
			return if available then { regionId = last or "home" } else nil
		end,
	})
	h.step()
	check(h.owner.travel(h.player, "field", 2) == "OK_WORLD_TRAVELLED")
	local replacement = table.clone(h.context)
	replacement.session = {}
	h.setContext(replacement)
	available = false
	local before = h.stats()
	h.advance()
	h.step()
	check(not h.owner.ready(h.player, 2), "missing new-session arrival stays actionable")
	check(h.stats().moves == before.moves and h.stats().observed == before.observed)
	available = true
	h.step()
	check(h.stats().moves == before.moves, "anchor retry ignored cooldown")
	h.advance()
	h.step()
	check(replacement.regionId == "home" and h.owner.ready(h.player, 3))
end
local function yieldedSessionReplacementCannotCompleteTravel()
	local h = harness()
	h.step()
	local moves = 0
	h.options.relocate = function(_p: any, _c: any, _t: any, _r: boolean, current: () -> boolean)
		coroutine.yield()
		if not current() then
			return false
		end
		moves += 1
		return true
	end
	local outcome: any = nil
	local thread = coroutine.create(function()
		outcome = h.owner.travel(h.player, "field", 2)
	end)
	check(coroutine.resume(thread))
	local replacement = table.clone(h.context)
	replacement.session = {}
	h.setContext(replacement)
	check(coroutine.resume(thread))
	check(moves == 0 and outcome == "UNAVAILABLE_TRAVEL_ARRIVAL")
	check(not h.owner.ready(h.player, 2), "yielded travel activated replacement session")
end
local function yieldedPresenceCheckCannotObserveReplacementSession()
	local h = harness()
	h.step()
	local readContext, reads = h.options.context, 0
	h.options.context = function()
		reads += 1
		if reads == 2 then
			coroutine.yield()
		end
		return readContext()
	end
	local before = h.stats()
	local thread = coroutine.create(h.step)
	check(coroutine.resume(thread))
	local replacement = table.clone(h.context)
	replacement.session = {}
	h.setContext(replacement)
	check(coroutine.resume(thread))
	check(h.stats().observed == before.observed, "unplaced replacement session observed")
	check(not h.owner.ready(h.player, 2))
	h.step()
	check(h.owner.ready(h.player, 3) and h.stats().observed == before.observed + 1)
end
local function hazardInterruptsBeforeMissingArrivalAndCannotEscape()
	local available, interruptions = true, 0
	local h = harness({
		recovery = function(_c: any, last: string?): any
			return if available then { regionId = last or "home" } else nil
		end,
		interrupt = function(_p: any, _c: any, current: () -> boolean): boolean
			check(current())
			interruptions += 1
			return true
		end,
	})
	h.step()
	available = false
	h.context.hazardId, h.context.validPosition = "hazard/starter-corrosive-dev-v1", false
	check(not h.owner.ready(h.player, 2))
	h.step()
	check(interruptions == 1, "hazard did not interrupt while arrival was unavailable")
	for _ = 1, 4 do
		h.advance()
		h.step()
	end
	check(interruptions == 1 and h.stats().moves == 1, "duplicate hazard consequence")
	h.context.hazardId, h.context.validPosition = nil, true
	check(not h.owner.ready(h.player, 2), "leaving the zone escaped pending recovery")
	available = true
	h.advance()
	h.step()
	check(h.owner.ready(h.player, 3) and h.stats().moves == 2)
	check(interruptions == 1 and h.stats().observed == 2, "recovery minted an observation")
end
local function yieldedHazardInterruptFencesReplacementAndShutdown()
	for _, replace in { "Session", "Character", "Shutdown" } do
		local interruptions = 0
		local h = harness({
			interrupt = function(_p: any, _c: any, current: () -> boolean): boolean
				coroutine.yield()
				if not current() then
					return false
				end
				interruptions += 1
				return true
			end,
		})
		h.step()
		h.context.hazardId, h.context.validPosition = "hazard/starter-corrosive-dev-v1", false
		local thread = coroutine.create(h.step)
		check(coroutine.resume(thread))
		check(coroutine.status(thread) == "suspended", "hazard interruption not observed")
		check(not h.owner.ready(h.player, 2))
		check(h.owner.travel(h.player, "field", 2) == "REJECT_STATE_TRAVEL_BUSY")
		if replace == "Shutdown" then
			h.owner.stop()
		else
			local replacement = table.clone(h.context)
			if replace == "Session" then
				replacement.session = {}
			else
				h.player.Character = {}
				replacement.character, replacement.generation = h.player.Character, 3
			end
			h.setContext(replacement)
		end
		check(coroutine.resume(thread))
		check(interruptions == 0 and h.stats().moves == 1, "stale hazard affected replacement")
	end
end
local function failedHazardInterruptKeepsPresenceInactive()
	local fail, calls = true, 0
	local h = harness({
		interrupt = function(_p: any, _c: any, current: () -> boolean): boolean
			check(current())
			calls += 1
			if fail then
				error("injected interruption failure")
			end
			return true
		end,
	})
	h.step()
	h.context.hazardId, h.context.validPosition = "hazard/starter-corrosive-dev-v1", false
	h.step()
	check(not h.owner.ready(h.player, 2) and h.stats().moves == 1)
	h.context.hazardId, h.context.validPosition = nil, true
	h.step()
	check(calls == 1, "failed interruption hot-looped")
	check(not h.owner.ready(h.player, 2), "leaving hazard escaped a failed interruption")
	fail = false
	h.advance()
	h.step()
	check(calls == 2 and h.owner.ready(h.player, 3) and h.stats().moves == 2)
end
local function hazardTravelRaceRecoversWithoutReplay()
	local interruptions = 0
	local h = harness({
		interrupt = function(_p: any, _c: any, current: () -> boolean): boolean
			check(current())
			interruptions += 1
			return true
		end,
	})
	h.step()
	local original = h.options.relocate
	h.options.relocate = function(p: any, c: any, t: any, recovery: boolean, current: () -> boolean)
		if not recovery then
			coroutine.yield()
			if not current() or not c.validPosition then
				return false
			end
		end
		return original(p, c, t, recovery, current)
	end
	local outcome: any = nil
	local thread = coroutine.create(function()
		outcome = h.owner.travel(h.player, "field", 2)
	end)
	check(coroutine.resume(thread))
	h.context.hazardId, h.context.validPosition = "hazard/starter-corrosive-dev-v1", false
	h.step()
	check(interruptions == 0, "hazard bypassed the transition lock")
	check(coroutine.resume(thread))
	check(outcome == "UNAVAILABLE_TRAVEL_ARRIVAL" and not h.owner.ready(h.player, 2))
	h.advance()
	h.step()
	check(interruptions == 1 and h.context.regionId == "home" and h.owner.ready(h.player, 3))
	check(h.owner.travel(h.player, "field", 2) == "REJECT_STATE_TRAVEL_STALE")
	h.step()
	check(interruptions == 1 and h.stats().moves == 2, "hazard replayed travel")
end
local function hazardRecoveryRequiresExplorationBeforeDiscovery()
	local h = harness({
		interrupt = function()
			return true
		end,
	})
	h.step()
	h.context.regionId = "field"
	h.step()
	local observed = h.stats().observed
	h.options.recovery = function()
		return { regionId = "field", recoveryObservationNodeId = "field-node" }
	end
	local relocate = h.options.relocate
	h.options.relocate = function(p: any, c: any, t: any, recovery: boolean, current: () -> boolean)
		local ok = relocate(p, c, t, recovery, current)
		h.context.nodeId = "field-node"
		return ok
	end
	h.context.hazardId, h.context.validPosition = "hazard/starter-corrosive-dev-v1", false
	h.step()
	check(h.owner.ready(h.player, 3), "recovery not safely active")
	for _ = 1, 3 do
		h.step()
	end
	check(h.stats().observed == observed, "recovery bypassed discovery")
	h.context.nodeId = nil -- Authoritative valid departure; streaming is not this context.
	h.step()
	h.context.nodeId = "field-node"
	h.step()
	check(h.stats().observed == observed + 2, "legitimate return cannot discover node")
end
local function hazardCannotSkipBetweenObservations()
	local h = harness({
		interrupt = function()
			return true
		end,
		hazardBetween = function(c: any, previous: number): string?
			return if previous < 1 and c.position > 1
				then "hazard/starter-corrosive-dev-v1"
				else nil
		end,
	})
	h.context.position = 0
	h.step()
	local relocate = h.options.relocate
	h.options.relocate = function(p: any, c: any, t: any, recovery: boolean, current: () -> boolean)
		local ok = relocate(p, c, t, recovery, current)
		h.context.position = 0 -- Existing authorized relocation resets the observed position.
		return ok
	end
	h.context.position = 2 -- Both endpoints are safe; the server-observed segment crosses.
	check(not h.owner.ready(h.player, 2), "fast crossing bypassed valuable action admission")
	h.context.position, h.context.validPosition, h.context.hazardId = 0, true, nil
	check(not h.owner.ready(h.player, 2), "returning before pulse cancelled an observed hazard")
	check(
		h.owner.travel(h.player, "field", 2) == "REJECT_STATE_TRAVEL_DESTINATION",
		"fast crossing bypassed travel"
	)
	h.step()
	check(h.owner.ready(h.player, 3) and h.stats().moves == 2, "crossing did not safely recover")
	h.step()
	check(h.stats().moves == 2, "authorized relocation retriggered crossing")
end
local function hazardRegistryIsBoundedAndPhaseIndependent()
	local r = Registry.new(Definitions)
	local d = check(r.hazards["hazard/starter-corrosive-dev-v1"])
	check(d.regionId == r.roles.Starter and d.consequence == "Recovery")
	check(#d.cyclePhaseIds == 3 and d.cycleDefinitionId == r.worldCycle.id)
	check(not pcall(function()
		d.consequence = "Extraction"
	end))
	for _, mutate in
		{
			function(c: any)
				c.hazards = {}
			end,
			function(c: any)
				table.insert(c.hazards, copy(c.hazards[1]))
			end,
			function(c: any)
				c.hazards[1].regionId = r.roles.HomeHub
			end,
			function(c: any)
				c.hazards[1].consequence = "Extraction"
			end,
			function(c: any)
				c.hazards[1].cyclePhaseIds = { "world-phase/night" }
			end,
			function(c: any)
				c.hazards[1].cycleDefinitionId = "world-cycle/forged"
			end,
			function(c: any)
				c.hazards[1].warningText = ""
			end,
		}
	do
		local c = copy(Definitions)
		mutate(c)
		check(not pcall(Registry.new, c), "unbound hazard registry accepted")
	end
end
return {
	discoveryPreparationAndProtectedEpochs = discoveryPreparationAndProtectedEpochs,
	arrivalRecoveryAndNoRepeatedRelocation = arrivalRecoveryAndNoRepeatedRelocation,
	staleGenerationAndBoundedSpam = staleGenerationAndBoundedSpam,
	interruptedRelocationRecoversWithoutReplay = interruptedRelocationRecoversWithoutReplay,
	yieldedRaceAndReplacedCharacterFence = yieldedRaceAndReplacedCharacterFence,
	yieldedShutdownAndMissingAnchorsFailClosed = yieldedShutdownAndMissingAnchorsFailClosed,
	replacementSessionRequiresSafeArrival = replacementSessionRequiresSafeArrival,
	replacementSessionWaitsForValidAnchor = replacementSessionWaitsForValidAnchor,
	yieldedSessionReplacementCannotCompleteTravel = yieldedSessionReplacementCannotCompleteTravel,
	yieldedPresenceCheckCannotObserveReplacementSession = yieldedPresenceCheckCannotObserveReplacementSession,
	hazardInterruptsBeforeMissingArrivalAndCannotEscape = hazardInterruptsBeforeMissingArrivalAndCannotEscape,
	yieldedHazardInterruptFencesReplacementAndShutdown = yieldedHazardInterruptFencesReplacementAndShutdown,
	failedHazardInterruptKeepsPresenceInactive = failedHazardInterruptKeepsPresenceInactive,
	hazardTravelRaceRecoversWithoutReplay = hazardTravelRaceRecoversWithoutReplay,
	hazardRecoveryRequiresExplorationBeforeDiscovery = hazardRecoveryRequiresExplorationBeforeDiscovery,
	hazardCannotSkipBetweenObservations = hazardCannotSkipBetweenObservations,
	hazardRegistryIsBoundedAndPhaseIndependent = hazardRegistryIsBoundedAndPhaseIndependent,
}
