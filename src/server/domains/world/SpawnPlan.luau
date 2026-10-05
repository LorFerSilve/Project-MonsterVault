--!strict

local SpawnPlan = {}

local function positive(value: any, maximum: number): boolean
	return type(value) == "number" and value == value and value > 0 and value <= maximum
end

-- The current authored DEV slice has one fixed placement/slot per habitat.
-- Policy, pool weights and rarity stay server-only; no new world/cycle rules.
function SpawnPlan.new(registry: any, positions: any, FixtureDefinition: any): any
	local policy = registry.spawnPolicy
	assert(type(policy) == "table", "unbound spawn policy")
	assert(positive(policy.stepSeconds, 60), "invalid scheduler cadence")
	assert(positive(policy.maxBuckets, 8) and policy.maxBuckets % 1 == 0, "invalid bucket cap")
	assert(
		positive(policy.maxBucketsPerStep, policy.maxBuckets) and policy.maxBucketsPerStep % 1 == 0,
		"invalid work cap"
	)
	assert(policy.cellSize == FixtureDefinition.cellSize, "unbound spatial envelope")
	assert(positive(policy.interactionRadius, 12), "invalid interaction envelope")
	for _, key in { "lifetimeSeconds", "retrySeconds", "refillSeconds" } do
		assert(positive(policy[key], 3600), "invalid spawn time envelope")
	end
	assert(
		positive(policy.maxMaterializationAttempts, 3)
			and policy.maxMaterializationAttempts % 1 == 0,
		"invalid retry bound"
	)
	assert(
		policy.protectedFixtureContextId == FixtureDefinition.spawnContextId,
		"missing proven Starter opportunity"
	)
	local ids = {}
	for id in registry.spawnContexts do
		table.insert(ids, id)
	end
	table.sort(ids)
	assert(
		#ids > 0 and #ids <= policy.maxBuckets and policy.maxBucketsPerStep <= #ids,
		"unbounded world population"
	)
	local buckets = {}
	local seenHabitats, regionCounts = {}, {}
	for _, id in ids do
		local context = registry.spawnContexts[id]
		local habitat = registry.habitats[context.habitatId]
		assert(not seenHabitats[context.habitatId], "multiple buckets exceed habitat budget")
		seenHabitats[context.habitatId] = true
		regionCounts[habitat.regionId] = (regionCounts[habitat.regionId] or 0) + 1
		assert(regionCounts[habitat.regionId] <= 2, "unbounded region population")
		assert(
			habitat and registry.regions[habitat.regionId].role ~= "HomeHub",
			"invalid public spawn region"
		)
		assert(
			table.find(context.contentSnapshotIds, registry.contentSnapshotId),
			"unbound current spawn epoch"
		)
		local position = positions[id]
		assert(type(position) == "table", "missing authored spawn placement")
		for _, axis in { "x", "y", "z" } do
			assert(
				type(position[axis]) == "number" and math.abs(position[axis]) < math.huge,
				"invalid placement"
			)
		end
		assert(
			type(context.speciesWeights) == "table"
				and #context.speciesWeights == #context.speciesIds,
			"unbound spawn weights"
		)
		local total, speciesDefinitions = 0, {}
		for n, speciesId in context.speciesIds do
			assert(positive(context.speciesWeights[n], 1000000), "invalid spawn weight")
			local rarityId = registry.species[speciesId].rarityId
			local protected = registry.protectedEncounter
			local stabilitySeconds = if speciesId == protected.speciesId
					and id == protected.spawnContextId
				then protected.stabilitySeconds
				else 0
			assert(
				rarityId == "rarity/common"
					or (rarityId == "rarity/legendary" and stabilitySeconds > 0),
				"unbound lifetime class"
			)
			speciesDefinitions[speciesId] =
				table.freeze({ rarityId = rarityId, stabilitySeconds = stabilitySeconds })
			total += context.speciesWeights[n]
		end
		local bucket: any = table.clone(policy)
		bucket.regionId, bucket.habitatId, bucket.spawnContextId = habitat.regionId, habitat.id, id
		bucket.contentSnapshotId = registry.contentSnapshotId
		bucket.speciesId, bucket.rarityId =
			context.speciesIds[1], registry.species[context.speciesIds[1]].rarityId
		bucket.position = table.freeze(table.clone(position))
		bucket.speciesIds, bucket.speciesWeights, bucket.totalWeight =
			context.speciesIds, context.speciesWeights, total
		bucket.speciesDefinitions = table.freeze(speciesDefinitions)
		bucket.replenishingFixture = id == policy.protectedFixtureContextId
		if bucket.replenishingFixture then
			for _, phase in registry.worldCycle.phases do
				assert(
					table.find(habitat.cyclePhaseIds, phase.id)
						and table.find(context.cyclePhaseIds, phase.id),
					"Starter fallback must remain phase-independent"
				)
			end
			assert(
				habitat.regionId == FixtureDefinition.regionId
					and habitat.id == FixtureDefinition.habitatId,
				"Starter fixture provenance changed"
			)
			assert(
				position.x == FixtureDefinition.position.x
					and position.y == FixtureDefinition.position.y
					and position.z == FixtureDefinition.position.z,
				"Starter placement changed"
			)
			assert(
				table.find(context.speciesIds, FixtureDefinition.speciesId)
					and table.find(context.contentSnapshotIds, FixtureDefinition.contentSnapshotId),
				"Starter fallback unbound"
			)
			bucket.speciesId, bucket.rarityId, bucket.contentSnapshotId =
				FixtureDefinition.speciesId,
				FixtureDefinition.rarityId,
				FixtureDefinition.contentSnapshotId
			table.insert(buckets, 1, table.freeze(bucket))
		else
			table.insert(buckets, table.freeze(bucket))
		end
	end
	return table.freeze({ buckets = table.freeze(buckets), policy = policy })
end

function SpawnPlan.select(bucket: any, random: any): any
	if bucket.replenishingFixture then
		return { speciesId = bucket.speciesId, rarityId = bucket.rarityId }
	end
	local draw = random.nextUnit()
	assert(
		type(draw) == "number" and draw == draw and draw >= 0 and draw < 1,
		"invalid species draw"
	)
	local target = draw * bucket.totalWeight
	local cumulative = 0
	for n, speciesId in bucket.speciesIds do
		cumulative += bucket.speciesWeights[n]
		if target < cumulative then
			return {
				speciesId = speciesId,
				rarityId = bucket.speciesDefinitions[speciesId].rarityId,
			}
		end
	end
	error("spawn selection outside authored pool")
end

return SpawnPlan
