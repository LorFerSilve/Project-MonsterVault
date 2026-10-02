--!strict

local World = require("../../src/server/domains/world/WorldService")
local Plan = require("../../src/server/domains/world/SpawnPlan")
local Registry = require("../../src/server/domains/world/WorldRegistry")
local Definitions = require("../../src/server/domains/world/WorldDefinitions")
local Fixture = require("../../src/server/domains/world/FixtureDefinition")
local function check(value: any, message: string?)
	assert(value, message or "spawn invariant")
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
local function plan(config: any?): any
	local registry = Registry.new(config or Definitions)
	local positions, n = {}, 0
	for id in registry.spawnContexts do
		n += 1
		positions[id] = { x = n * 100, y = 3, z = 0 }
	end
	positions[Fixture.spawnContextId] = clone(Fixture.position)
	return Plan.new(registry, positions, Fixture)
end
local function harness(extra: any?): any
	local p = plan()
	local now, selected, variants, attempts, destroyed = 0, 0, 0, 0, 0
	local enabled = true
	local options: any = {
		fixture = Fixture,
		buckets = p.buckets,
		maxBucketsPerStep = 2,
		stepSeconds = 1,
		clock = function()
			return now
		end,
		newId = function()
			return "server-namespace"
		end,
		isBucketActive = function(bucket: any)
			return bucket.replenishingFixture or enabled
		end,
		selectCandidate = function(bucket: any)
			selected += 1
			return Plan.select(bucket, {
				nextUnit = function()
					return 0.75
				end,
			})
		end,
		generateVariant = function(candidate: any)
			variants += 1
			return { variantSignature = candidate.speciesId .. "|fixed" }
		end,
		materialize = function()
			attempts += 1
			return { alive = true }
		end,
		activate = function() end,
		isProjectionAlive = function(handle: any)
			return handle.alive
		end,
		destroyProjection = function(handle: any)
			handle.alive = false
			destroyed += 1
		end,
	}
	for key, value in extra or {} do
		options[key] = value
	end
	local world = World.new(options)
	local generation = world.start()
	return {
		world = world,
		generation = generation,
		options = options,
		plan = p,
		advance = function(seconds: number?)
			now += seconds or 1
		end,
		setTime = function(value: number)
			now = value
		end,
		setActive = function(value: boolean)
			enabled = value
		end,
		step = function()
			return world.step(generation)
		end,
		stats = function()
			return {
				selected = selected,
				variants = variants,
				attempts = attempts,
				destroyed = destroyed,
			}
		end,
	}
end

local function authoredBoundsAndPools()
	local p = plan()
	check(#p.buckets == 8 and p.buckets[1].replenishingFixture)
	for _, bucket in p.buckets do
		for _, sample in { 0, 0.499999, 0.5, 0.999999 } do
			local selected = Plan.select(bucket, {
				nextUnit = function()
					return sample
				end,
			})
			check(
				table.find(bucket.speciesIds, selected.speciesId)
					and selected.rarityId == "rarity/common"
			)
		end
	end
	for _, mutate in
		{
			function(c: any)
				c.spawnPolicy.maxBuckets = 9
			end,
			function(c: any)
				c.spawnPolicy.maxBucketsPerStep = 0
			end,
			function(c: any)
				c.spawnPolicy.refillSeconds = math.huge
			end,
			function(c: any)
				c.spawnPolicy.protectedFixtureContextId = "spawn-context/mid-a"
			end,
			function(c: any)
				c.spawnContexts[2].speciesWeights = { 0, 1 }
			end,
			function(c: any)
				c.spawnContexts[2].speciesWeights = { 0 / 0, 1 }
			end,
			function(c: any)
				c.spawnContexts[2].speciesWeights = { 1 }
			end,
			function(c: any)
				c.spawnContexts[2].contentSnapshotIds = { "content-snapshot/old" }
			end,
			function(c: any)
				c.species[1].rarityId = "rarity/legendary"
			end,
			function(c: any)
				c.spawnContexts[2].habitatId = c.spawnContexts[1].habitatId
			end,
		}
	do
		local c = clone(Definitions)
		mutate(c)
		check(not pcall(plan, c), "invalid plan accepted")
	end
	check(not pcall(Plan.select, p.buckets[2], {
		nextUnit = function()
			return 1
		end,
	}))
end

local function staggeredCapsDormancyAndDuplicates()
	local h = harness()
	h.step()
	check(h.world.populationCount() == 2)
	check(h.step() == "NotDue" and h.world.populationCount() == 2)
	for _ = 1, 12 do
		h.advance()
		h.step()
		check(h.world.populationCount() <= 8)
	end
	check(h.world.populationCount() == 8 and h.stats().selected == 8)
	for _, bucket in h.world.bucketStatus() do
		check(bucket.count == 1)
	end
	h.world.stop()
	local dormant = harness()
	dormant.setActive(false)
	for _ = 1, 12 do
		dormant.step()
		dormant.advance()
	end
	check(
		dormant.world.populationCount() == 1 and dormant.world.currentId() ~= nil,
		"Starter opportunity lost"
	)
	dormant.setActive(true)
	for _ = 1, 4 do
		dormant.step()
		dormant.advance()
	end
	check(dormant.world.populationCount() == 8)
	dormant.world.stop()
end

local function reservationsRetriesAndFaultIsolation()
	local failures = 0
	local h = harness({
		materialize = function()
			failures += 1
			if failures <= 2 then
				error("placement failure")
			end
			return { alive = true }
		end,
	})
	h.step()
	check(h.world.populationCount() == 2, "pending does not reserve capacity")
	local id = h.world.currentId()
	local identity = h.world.identity(id)
	for _ = 1, 4 do
		h.advance()
		h.step()
	end
	check(h.world.currentId() == id and h.world.get(id) ~= nil)
	check(
		h.world.identity(id).variantIdentity == identity.variantIdentity,
		"retry rerolled identity"
	)
	check(h.stats().variants == h.stats().selected)
	h.world.stop()
	local bad = harness({
		isBucketActive = function(bucket: any)
			if bucket.spawnContextId == Fixture.spawnContextId then
				error("one bucket invalid")
			end
			return true
		end,
	})
	for _ = 1, 4 do
		bad.step()
		bad.advance()
	end
	check(bad.world.bucketStatus()[1].paused and bad.world.populationCount() == 7)
	bad.world.stop()
end

local function captureProtectionRetirementAndReplenishment()
	local h = harness()
	for _ = 1, 4 do
		h.step()
		h.advance()
	end
	local id = h.world.currentId()
	for _, state in
		{ "Claimed", "AttemptActive", "Provisional", "TransportActive", "FinalizationPending" }
	do
		local from = if state == "Claimed"
			then "IdleAvailable"
			else ({
				AttemptActive = "Claimed",
				Provisional = "AttemptActive",
				TransportActive = "Provisional",
				FinalizationPending = "TransportActive",
			})[state]
		check(h.world.transition(id, from, state))
		h.advance(200)
		h.step()
		check(h.world.identity(id) ~= nil, "idle lifetime killed acquisition")
	end
	check(h.world.retire(id) and not h.world.retire(id))
	for _ = 1, 12 do
		h.advance()
		h.step()
	end
	local replacement = h.world.currentId()
	check(replacement ~= nil and replacement ~= id)
	check(not h.world.expireIfCurrent(id, 2) and h.world.identity(replacement) ~= nil)
	h.world.stop()
	check(h.world.populationCount() == 0 and h.step() == "Stale")
end

local function destroyedProjectionsAndPlacementExhaustion()
	local handles = {}
	local h = harness({
		materialize = function()
			local handle = { alive = true }
			table.insert(handles, handle)
			return handle
		end,
	})
	h.step()
	local old = h.world.currentId()
	handles[1].alive = false
	for _ = 1, 4 do
		h.advance()
		h.step()
	end
	check(h.world.identity(old) == nil, "destroyed server projection not retired")
	for _ = 1, 9 do
		h.advance()
		h.step()
	end
	check(h.world.currentId() ~= nil and h.world.currentId() ~= old)
	h.world.stop()
	local failed = harness({
		canMaterialize = function()
			return false
		end,
	})
	failed.step()
	local id = failed.world.currentId()
	for _ = 1, 8 do
		failed.advance()
		failed.step()
	end
	check(failed.world.identity(id) == nil and failed.stats().attempts == 0)
	failed.world.stop()
end

local function yieldedMaterializationCannotResurrect()
	for _, where in { "materialize", "activate" } do
		local activated, destroyed = 0, 0
		local options: any = {
			materialize = function()
				if where == "materialize" then
					coroutine.yield("pending")
				end
				return { alive = true }
			end,
			activate = function()
				activated += 1
				if where == "activate" then
					coroutine.yield("pending")
				end
			end,
			destroyProjection = function()
				destroyed += 1
			end,
		}
		local h = harness(options)
		local job = coroutine.create(h.step)
		check(coroutine.resume(job))
		check(h.world.populationCount() == 1 and h.step() == "Busy")
		h.world.stop()
		check(coroutine.resume(job))
		check(h.world.populationCount() == 0 and destroyed == 1)
		check(
			activated == (if where == "activate" then 1 else 0),
			"late handle activated after stop"
		)
		check(h.step() == "Stale")
	end
end

local function clockAndSelectionFailClosed()
	local h = harness()
	h.step()
	local before = h.world.populationCount()
	h.setTime(-1)
	check(not pcall(h.step) and h.world.populationCount() == before)
	h.setTime(1)
	h.world.stop()
	local invalid = harness({
		selectCandidate = function()
			return { speciesId = "species/client-spoof", rarityId = "rarity/legendary" }
		end,
	})
	for _ = 1, 4 do
		invalid.step()
		invalid.advance()
	end
	check(invalid.world.populationCount() == 0 and invalid.stats().variants == 0)
	invalid.world.stop()
end

local function longRunBoundsAndFreshSessionIdentity()
	local h = harness()
	local seen = {}
	for _ = 1, 400 do
		h.step()
		check(h.world.populationCount() <= 8 and #h.world.bucketStatus() == 8)
		for _, bucket in h.world.bucketStatus() do
			if bucket.creatureInstanceId then
				check(not seen[bucket.creatureInstanceId], "reused terminated identity")
				seen[bucket.creatureInstanceId] = true
				h.world.retire(bucket.creatureInstanceId)
			end
		end
		h.advance(5)
	end
	h.world.stop()
	local fresh = harness({
		newId = function()
			return "fresh-session-namespace"
		end,
	})
	fresh.step()
	check(not seen[fresh.world.currentId()])
	fresh.world.stop()
end

return {
	authoredBoundsAndPools = authoredBoundsAndPools,
	staggeredCapsDormancyAndDuplicates = staggeredCapsDormancyAndDuplicates,
	reservationsRetriesAndFaultIsolation = reservationsRetriesAndFaultIsolation,
	captureProtectionRetirementAndReplenishment = captureProtectionRetirementAndReplenishment,
	destroyedProjectionsAndPlacementExhaustion = destroyedProjectionsAndPlacementExhaustion,
	yieldedMaterializationCannotResurrect = yieldedMaterializationCannotResurrect,
	clockAndSelectionFailClosed = clockAndSelectionFailClosed,
	longRunBoundsAndFreshSessionIdentity = longRunBoundsAndFreshSessionIdentity,
}
