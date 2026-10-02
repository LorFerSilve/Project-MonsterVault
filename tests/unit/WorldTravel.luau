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
			context.regionId, context.validPosition = target.regionId, true
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
return {
	discoveryPreparationAndProtectedEpochs = discoveryPreparationAndProtectedEpochs,
	arrivalRecoveryAndNoRepeatedRelocation = arrivalRecoveryAndNoRepeatedRelocation,
	staleGenerationAndBoundedSpam = staleGenerationAndBoundedSpam,
	interruptedRelocationRecoversWithoutReplay = interruptedRelocationRecoversWithoutReplay,
	yieldedRaceAndReplacedCharacterFence = yieldedRaceAndReplacedCharacterFence,
	yieldedShutdownAndMissingAnchorsFailClosed = yieldedShutdownAndMissingAnchorsFailClosed,
}
