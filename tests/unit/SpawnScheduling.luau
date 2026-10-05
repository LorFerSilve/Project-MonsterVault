--!strict

local World = require("../../src/server/domains/world/WorldService")
local Plan = require("../../src/server/domains/world/SpawnPlan")
local Registry = require("../../src/server/domains/world/WorldRegistry")
local Definitions = require("../../src/server/domains/world/WorldDefinitions")
local Fixture = require("../../src/server/domains/world/FixtureDefinition")
local Variant = require("../../src/server/domains/capture/VariantIdentity")
local Capture = require("../../src/server/domains/capture/CaptureService")
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
		clock = function(): number
			return now
		end,
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
					and selected.rarityId
						== bucket.speciesDefinitions[selected.speciesId].rarityId
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

local function protectedHarness(extra: any?): any
	local options: any = {
		selectCandidate = function(bucket: any)
			return Plan.select(bucket, {
				nextUnit = function()
					return 0.999999
				end,
			})
		end,
		generateVariant = function(candidate: any)
			return Variant.generate(candidate, {
				nextUnit = function()
					return 0.75
				end,
			})
		end,
	}
	for key, value in extra or {} do
		options[key] = value
	end
	return harness(options)
end
local function protectedId(h: any): string
	for _ = 1, 4 do
		h.step()
		h.advance()
	end
	for _, bucket in h.world.bucketStatus() do
		if bucket.spawnContextId == Definitions.protectedEncounter.spawnContextId then
			return assert(bucket.creatureInstanceId, "protected bucket reserved")
		end
	end
	error("missing protected authored bucket")
end
local function captureFor(h: any): any
	local ids = 0
	return Capture.new({
		world = h.world,
		clock = h.clock,
		unixSeconds = h.clock,
		newId = function()
			ids += 1
			return "protected-claim-" .. ids
		end,
		random = {
			nextUnit = function()
				return h.captureDraw or 0
			end,
		},
		canInitiate = function()
			return true
		end,
		finalize = function()
			return { status = "OutcomeUnknown" }
		end,
	})
end
local function protectedBindingAndClassification()
	for _, mutate in
		{
			function(c: any)
				c.protectedEncounter = nil
			end,
			function(c: any)
				c.protectedEncounter.speciesId = "species/unknown"
			end,
			function(c: any)
				c.protectedEncounter.spawnContextId = "spawn-context/fixture-clearing"
			end,
			function(c: any)
				c.protectedEncounter.stabilitySeconds = 179
			end,
			function(c: any)
				c.protectedEncounter.stabilitySeconds = 3601
			end,
			function(c: any)
				c.protectedEncounter.stabilitySeconds = 0 / 0
			end,
			function(c: any)
				c.protectedEncounter.stabilitySeconds = math.huge
			end,
			function(c: any)
				c.protectedEncounter.stabilitySeconds = 300.5
			end,
			function(c: any)
				table.insert(c.spawnContexts[3].speciesIds, c.protectedEncounter.speciesId)
				table.insert(c.spawnContexts[3].speciesWeights, 1)
			end,
			function(c: any)
				c.species[5].rarityId = "rarity/rare"
			end,
		}
	do
		local config = clone(Definitions)
		mutate(config)
		check(not pcall(plan, config), "unbound protected lifetime accepted")
	end
	local h = protectedHarness()
	local id = protectedId(h)
	local variant = h.world.identity(id).variantIdentity
	check(variant.speciesRarityId == "rarity/legendary" and #variant.protectedVariantReasons == 1)
	check(variant.protectedVariantReasons[1] == "protected-variant/legendary-species")
	check(#h.world.identity(h.world.currentId()).variantIdentity.protectedVariantReasons == 0)
	h.world.stop()
end
local function protectedIdleWindowAndCycleReplan()
	local phase: any = { phaseId = "world-phase/day", cycleIndex = 0 }
	local h = protectedHarness({
		evaluateContext = function()
			return phase
		end,
	})
	local id = protectedId(h)
	local record, identity = h.world.get(id), h.world.identity(id)
	check(
		record.lifetimeClass == "ProtectedVariant"
			and record.idleExpiresAt == record.availableAt + 300
	)
	local ordinary = assert(h.world.currentId())
	local forged = h.world.get(id)
	forged.idleExpiresAt, forged.lifetimeClass, forged.position.x = 0, "Ordinary", 999
	check(h.world.get(id).idleExpiresAt == record.idleExpiresAt, "projection became authority")
	h.setTime(181)
	check(
		h.world.expireIfCurrent(ordinary, h.world.get(ordinary).runtimeRevision),
		"ordinary expiry"
	)
	phase = nil -- New cycle/context no longer permits any fresh reservation.
	h.setActive(false)
	for _ = 1, 4 do
		h.step()
		h.advance()
	end
	check(
		h.world.identity(id).cycleContext == identity.cycleContext,
		"cycle rewrote encounter context"
	)
	check(not h.world.expireIfCurrent(id, record.runtimeRevision), "protected window shortened")
	h.setTime(record.idleExpiresAt)
	check(h.world.expireIfCurrent(id, record.runtimeRevision), "legitimate protected idle expiry")
	check(not h.world.expireIfCurrent(id, record.runtimeRevision), "duplicate termination")
	for _ = 1, 12 do
		h.advance()
		h.step()
	end
	check(h.world.populationCount() == 0, "ineligible replan replenished content")
	h.world.stop()
end
local function protectedWindowStartsAfterActivation()
	local delayed = false
	local h: any = nil
	h = protectedHarness({
		activate = function(_handle: any, record: any)
			if record.spawnContextId == Definitions.protectedEncounter.spawnContextId then
				delayed = true
				coroutine.yield("activation pending")
			end
		end,
	})
	local job = coroutine.create(function()
		protectedId(h)
	end)
	check(coroutine.resume(job))
	check(delayed and h.step() == "Busy")
	h.setTime(200)
	check(coroutine.resume(job))
	local id: any = nil
	for _, bucket in h.world.bucketStatus() do
		if bucket.spawnContextId == Definitions.protectedEncounter.spawnContextId then
			id = bucket.creatureInstanceId
		end
	end
	local record = h.world.get(id)
	check(
		record.availableAt == 200 and record.idleExpiresAt == 500,
		"reservation consumed stability"
	)
	h.setTime(499)
	check(not h.world.expireIfCurrent(id, record.runtimeRevision))
	h.setTime(500)
	check(h.world.expireIfCurrent(id, record.runtimeRevision))
	h.world.stop()
end
local function yieldedProjectionCheckCannotKillClaim()
	for _, callback in { "isProjectionAlive", "isBucketActive" } do
		local block = false
		local h = protectedHarness({
			[callback] = function(_handle: any, record: any)
				local context = if callback == "isBucketActive"
					then _handle.spawnContextId
					else record.spawnContextId
				if block and context == Definitions.protectedEncounter.spawnContextId then
					coroutine.yield("checking old idle generation")
					return false
				end
				return true
			end,
		})
		local id = protectedId(h)
		local revision = h.world.get(id).runtimeRevision
		h.setTime(h.world.get(id).idleExpiresAt - 5)
		block = true
		local job = coroutine.create(function()
			for _ = 1, 4 do
				h.step()
				h.advance()
			end
		end)
		check(coroutine.resume(job))
		local capture = captureFor(h)
		check(capture.begin(42, id, h.world.get(id).position, 1, {}).status == "Claimed")
		check(coroutine.resume(job))
		check(h.world.identity(id) ~= nil, "stale observation killed claimed opportunity")
		check(not h.world.expireIfCurrent(id, revision))
		h.world.stop()
	end
end
local function acquisitionReleaseDoesNotRestartWindow()
	for _, outcome in { "timeout", "failure", "generation", "disconnect" } do
		local h = protectedHarness()
		local id = protectedId(h)
		local p, original = h.world.get(id).position, h.world.get(id)
		local capture = captureFor(h)
		h.setTime(original.idleExpiresAt - 1)
		local claim = capture.begin(42, id, p, 1, {})
		check(claim.status == "Claimed")
		check(capture.begin(43, id, p, 1, {}).status ~= "Claimed", "finite opportunity multi-claim")
		h.setTime(original.idleExpiresAt + 1)
		for _ = 1, 4 do
			h.step()
			h.advance()
		end
		check(h.world.identity(id) ~= nil and h.world.populationCount() <= 8)
		if outcome == "timeout" then
			h.advance(21)
			capture.tick()
		elseif outcome == "failure" then
			h.captureDraw = 0.999999
			check(capture.submit(42, claim.captureSessionId, "capture", 1, p, 1).status == "Failed")
		elseif outcome == "generation" then
			check(
				capture.submit(42, claim.captureSessionId, "capture", 1, p, 2).status
					== "Invalidated"
			)
		else
			capture.disconnect(42)
		end
		local released = assert(h.world.get(id), "claim release did not preserve same opportunity")
		check(released.idleExpiresAt == original.idleExpiresAt, "release renewed stability")
		check(
			capture.begin(42, id, p, 2, {}).status ~= "Claimed",
			"expired opportunity re-claimed before scheduler cleanup"
		)
		check(
			not h.world.expireIfCurrent(id, original.runtimeRevision),
			"old idle callback gained authority"
		)
		check(
			h.world.expireIfCurrent(id, released.runtimeRevision),
			"released expired content immortal"
		)
		for _ = 1, 12 do
			h.advance()
			h.step()
		end
		check(h.world.identity(id) == nil and h.world.populationCount() <= 8)
		check(capture.submit(42, claim.captureSessionId, "capture", 1, p, 1).status == "Rejected")
		h.world.stop()
	end
end
local function custodyGracePendingAndShutdownLifetime()
	for _, outcome in { "grace", "interrupt", "pending" } do
		local h = protectedHarness()
		local id = protectedId(h)
		local p = h.world.get(id).position
		local capture = captureFor(h)
		local claim = capture.begin(42, id, p, 1, {})
		check(
			capture.submit(42, claim.captureSessionId, "capture", 1, p, 1).status
				== "TransportActive"
		)
		local custody = capture.custody(42)
		h.setTime(600)
		for _ = 1, 4 do
			h.step()
			h.advance()
		end
		check(
			h.world.identity(id) ~= nil and capture.custody(42).operationId == custody.operationId
		)
		if outcome == "grace" then
			capture.disconnect(42)
			check(capture.state(id) == "TransportGrace")
			for _ = 1, 4 do
				h.step()
				h.advance()
			end
			check(capture.resume(42, 2, {}).status == "TransportActive")
			check(capture.custody(42).operationId == custody.operationId)
			capture.disconnect(42)
			h.advance(30)
			capture.tick()
			check(capture.resume(42, 3, {}).status == "Rejected" and h.world.identity(id) == nil)
		elseif outcome == "interrupt" then
			capture.interrupt(42, true)
			check(h.world.identity(id) == nil and capture.custody(42) == nil)
		else
			local session = {
				state = function()
					return "Ready"
				end,
			}
			check(capture.secure(42, p, p, 1, session).status == "OutcomeUnknown")
			capture.interrupt(42, true)
			h.advance(600)
			for _ = 1, 4 do
				h.step()
				h.advance()
			end
			check(capture.state(id) == "FinalizationPending" and h.world.identity(id) ~= nil)
		end
		h.world.stop()
		check(h.world.populationCount() == 0 and h.step() == "Stale")
	end
end

return {
	protectedBindingAndClassification = protectedBindingAndClassification,
	protectedIdleWindowAndCycleReplan = protectedIdleWindowAndCycleReplan,
	protectedWindowStartsAfterActivation = protectedWindowStartsAfterActivation,
	yieldedProjectionCheckCannotKillClaim = yieldedProjectionCheckCannotKillClaim,
	acquisitionReleaseDoesNotRestartWindow = acquisitionReleaseDoesNotRestartWindow,
	custodyGracePendingAndShutdownLifetime = custodyGracePendingAndShutdownLifetime,
	authoredBoundsAndPools = authoredBoundsAndPools,
	staggeredCapsDormancyAndDuplicates = staggeredCapsDormancyAndDuplicates,
	reservationsRetriesAndFaultIsolation = reservationsRetriesAndFaultIsolation,
	captureProtectionRetirementAndReplenishment = captureProtectionRetirementAndReplenishment,
	destroyedProjectionsAndPlacementExhaustion = destroyedProjectionsAndPlacementExhaustion,
	yieldedMaterializationCannotResurrect = yieldedMaterializationCannotResurrect,
	clockAndSelectionFailClosed = clockAndSelectionFailClosed,
	longRunBoundsAndFreshSessionIdentity = longRunBoundsAndFreshSessionIdentity,
}
