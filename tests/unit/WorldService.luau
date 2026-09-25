--!strict

local FixtureDefinition = require("../../src/server/domains/world/FixtureDefinition")
local WorldService = require("../../src/server/domains/world/WorldService")

local function check<T>(value: T?, message: string?): T
	assert(value, message or "world test invariant")
	return value :: T
end

local function harness(failMaterializations: number?, failActivations: number?)
	local now = 0
	local allocated = 0
	local materializations = 0
	local activations = 0
	local destroyed = 0
	local world = WorldService.new({
		fixture = FixtureDefinition,
		clock = function()
			return now
		end,
		newId = function()
			allocated += 1
			return "creature-" .. tostring(allocated)
		end,
		materialize = function()
			materializations += 1
			if materializations <= (failMaterializations or 0) then
				error("injected materialization failure")
			end
			return { id = materializations }
		end,
		activate = function(handle)
			activations += 1
			if activations <= (failActivations or 0) then
				error("injected activation failure")
			end
			check(handle ~= nil)
		end,
		destroyProjection = function(handle)
			check(handle ~= nil)
			destroyed += 1
		end,
	})
	return {
		world = world,
		setTime = function(value: number)
			now = value
		end,
		allocated = function(): number
			return allocated
		end,
		materializations = function(): number
			return materializations
		end,
		destroyed = function(): number
			return destroyed
		end,
	}
end

local function oneAuthoredCreatureUsesOneCapacitySlot()
	local fake = harness()
	local world = fake.world
	local generation = world.start()
	check(world.step(generation) == "Spawned")
	check(world.populationCount() == 1)
	check(fake.allocated() == 1)
	local id = check(world.currentId())
	local projection = world.get(id)
	check(projection.creatureInstanceId == id)
	check(projection.speciesId == FixtureDefinition.speciesId)
	check(projection.rarityId == FixtureDefinition.rarityId)
	check(projection.runtimeRevision == 2)
	check(projection.availability == "IdleAvailable")
	check(world.step(generation) == "Idle" and fake.allocated() == 1)
	world.stop()
end

local function interactionUsesRegistryAndExactDistance()
	local fake = harness()
	local world = fake.world
	world.step(world.start())
	local id = check(world.currentId())
	local center = { x = 0, y = 3, z = -16 }
	local status, projection = world.interaction(id, center)
	check(status == "Available" and projection.creatureInstanceId == id)
	projection.position.x = 999
	check(world.get(id).position.x == 0, "public projection cannot mutate registry")
	check(world.interaction(id, { x = 12, y = 3, z = -16 }) == "Available")
	check(world.interaction(id, { x = 12.01, y = 3, z = -16 }) == "OutOfRange")
	check(world.interaction(id, { x = math.huge, y = 3, z = -16 }) == "InvalidPosition")
	check(world.interaction("creature-spoofed", center) == "Unavailable")
	check(#world.nearby(center, 12) == 1)
	check(#world.nearby({ x = 200, y = 3, z = -16 }, 12) == 0)
	world.stop()
end

local function staleExpiryCannotResurrectDestroyedEntity()
	local fake = harness()
	local world = fake.world
	local generation = world.start()
	world.step(generation)
	local oldId = check(world.currentId())
	check(not world.expireIfCurrent(oldId, 1), "old revision rejected")
	fake.setTime(180)
	check(world.expireIfCurrent(oldId, 2))
	check(not world.expireIfCurrent(oldId, 2), "terminal transition idempotent")
	check(world.populationCount() == 0 and world.get(oldId) == nil)
	check(fake.destroyed() == 1)
	check(world.step(generation) == "Idle")
	fake.setTime(185)
	check(world.step(generation) == "Spawned")
	check(world.currentId() ~= oldId)
	check(not world.expireIfCurrent(oldId, 2), "old callback cannot touch replacement")
	world.stop()
end

local function materializationRetryKeepsReservationIdentity()
	local fake = harness(1)
	local world = fake.world
	local generation = world.start()
	check(world.step(generation) == "Pending")
	local reservedId = check(world.currentId())
	check(world.populationCount() == 1 and world.get(reservedId) == nil)
	fake.setTime(1)
	check(world.step(generation) == "Idle")
	fake.setTime(2)
	check(world.step(generation) == "Spawned")
	check(world.currentId() == reservedId and fake.allocated() == 1)
	check(fake.materializations() == 2)
	world.stop()
end

local function activationFailureCleansProjectionBeforeRetry()
	local fake = harness(0, 1)
	local world = fake.world
	local generation = world.start()
	check(world.step(generation) == "Pending")
	check(fake.destroyed() == 1, "failed projection cleaned")
	local id = check(world.currentId())
	fake.setTime(2)
	check(world.step(generation) == "Spawned")
	check(world.currentId() == id and fake.allocated() == 1)
	world.stop()
	check(fake.destroyed() == 2)
end

local function exhaustedReservationReleasesBudget()
	local fake = harness(3)
	local world = fake.world
	local generation = world.start()
	check(world.step(generation) == "Pending")
	local oldId = check(world.currentId())
	fake.setTime(2)
	check(world.step(generation) == "Pending")
	fake.setTime(4)
	check(world.step(generation) == "Pending")
	check(world.populationCount() == 0 and world.currentId() == nil)
	fake.setTime(9)
	check(world.step(generation) == "Spawned")
	check(world.currentId() ~= oldId and fake.allocated() == 2)
	world.stop()
end

local function stoppedGenerationRejectsDelayedWork()
	local fake = harness()
	local world = fake.world
	local generation = world.start()
	world.step(generation)
	local id = check(world.currentId())
	world.stop()
	world.stop()
	check(world.populationCount() == 0 and fake.destroyed() == 1)
	fake.setTime(1000)
	check(world.step(generation) == "Stale")
	check(world.interaction(id, { x = 0, y = 3, z = -16 }) == "Unavailable")
	check(fake.allocated() == 1, "stale delayed callback never refills")
end

return {
	oneAuthoredCreatureUsesOneCapacitySlot = oneAuthoredCreatureUsesOneCapacitySlot,
	interactionUsesRegistryAndExactDistance = interactionUsesRegistryAndExactDistance,
	staleExpiryCannotResurrectDestroyedEntity = staleExpiryCannotResurrectDestroyedEntity,
	materializationRetryKeepsReservationIdentity = materializationRetryKeepsReservationIdentity,
	activationFailureCleansProjectionBeforeRetry = activationFailureCleansProjectionBeforeRetry,
	exhaustedReservationReleasesBudget = exhaustedReservationReleasesBudget,
	stoppedGenerationRejectsDelayedWork = stoppedGenerationRejectsDelayedWork,
}
