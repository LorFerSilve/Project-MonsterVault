--!strict

-- Server-owned minimal world registry and centralized scheduler. Roblox models
-- are disposable projections; only records in this service can be interacted with.
local WorldService = {}

local function finite(value: any): boolean
	return type(value) == "number" and value == value and math.abs(value) < math.huge
end

local function validPosition(position: any): boolean
	return type(position) == "table"
		and finite(position.x)
		and finite(position.y)
		and finite(position.z)
end

local function copyPosition(position: any): any
	return { x = position.x, y = position.y, z = position.z }
end

local function cellKey(position: any, cellSize: number): string
	return tostring(math.floor(position.x / cellSize))
		.. ":"
		.. tostring(math.floor(position.z / cellSize))
end

function WorldService.new(options: {
	fixture: any,
	buckets: { any }?,
	maxBucketsPerStep: number?,
	stepSeconds: number?,
	isBucketActive: ((any) -> boolean)?,
	canMaterialize: ((any) -> boolean)?,
	isProjectionAlive: ((any, any) -> boolean)?,
	selectCandidate: ((any) -> any)?,
	onBucketError: ((string) -> ())?,
	clock: () -> number,
	newId: () -> string,
	materialize: (any) -> any,
	activate: (any, any) -> (),
	destroyProjection: (any) -> (),
	generateVariant: ((any) -> any)?,
	updateProjection: ((any, any) -> ())?,
})
	local baseFixture = options.fixture
	local function validateFixture(fixture: any)
		assert(validPosition(fixture.position), "invalid fixture position")
		assert(finite(fixture.cellSize) and fixture.cellSize > 0, "invalid cell size")
		assert(
			finite(fixture.interactionRadius) and fixture.interactionRadius > 0,
			"invalid interaction radius"
		)
		assert(finite(fixture.lifetimeSeconds) and fixture.lifetimeSeconds > 0, "invalid lifetime")
		assert(finite(fixture.retrySeconds) and fixture.retrySeconds > 0, "invalid retry delay")
		assert(finite(fixture.refillSeconds) and fixture.refillSeconds > 0, "invalid refill delay")
		assert(
			type(fixture.maxMaterializationAttempts) == "number"
				and fixture.maxMaterializationAttempts >= 1
				and fixture.maxMaterializationAttempts % 1 == 0,
			"invalid attempt limit"
		)
		for _, key in
			{
				"regionId",
				"habitatId",
				"spawnContextId",
				"contentSnapshotId",
				"speciesId",
				"rarityId",
			}
		do
			assert(
				type(fixture[key]) == "string" and fixture[key] ~= "",
				"invalid fixture identity"
			)
		end
	end
	local definitions: { any } = options.buckets or { baseFixture }
	assert(#definitions > 0 and #definitions <= 8, "unbounded spawn buckets")
	local buckets: { any } = {}
	local seen = {}
	for _, definition in definitions do
		validateFixture(definition)
		assert(not seen[definition.spawnContextId], "duplicate spawn bucket")
		assert(definition.cellSize == baseFixture.cellSize, "inconsistent spatial cells")
		seen[definition.spawnContextId] = true
		table.insert(
			buckets,
			{ definition = definition, currentId = nil, nextSpawnAt = 0, paused = false }
		)
	end
	local workLimit = options.maxBucketsPerStep or 1
	assert(workLimit % 1 == 0 and workLimit >= 1 and workLimit <= #buckets, "invalid work bound")
	assert(
		options.stepSeconds == nil or (finite(options.stepSeconds) and options.stepSeconds > 0),
		"invalid step cadence"
	)

	local records: { [string]: any } = {}
	local usedIds: { [string]: boolean } = {}
	local cells: { [string]: { [string]: boolean } } = {}
	local cursor = 1
	local nextStepAt = 0
	local lastStepAt = -math.huge
	local stepping = false
	local idPrefix: string? = nil
	local allocation = 0
	local running = false
	local generation = 0

	local function public(record: any): any
		return {
			creatureInstanceId = record.id,
			speciesId = record.speciesId,
			rarityId = record.rarityId,
			spawnContextId = record.spawnContextId,
			runtimeRevision = record.revision,
			availability = record.state,
			position = copyPosition(record.position),
		}
	end

	local function unindex(record: any)
		local key = cellKey(record.position, baseFixture.cellSize)
		local bucket = cells[key]
		if bucket ~= nil then
			bucket[record.id] = nil
			if next(bucket) == nil then
				cells[key] = nil
			end
		end
	end

	local function terminate(record: any, now: number): boolean
		if records[record.id] ~= record then
			return false
		end
		record.state = "Destroyed"
		record.revision += 1
		unindex(record)
		if record.projection ~= nil then
			pcall(options.destroyProjection, record.projection)
			record.projection = nil
		end
		records[record.id] = nil
		if record.bucket.currentId == record.id then
			record.bucket.currentId = nil
		end
		record.bucket.nextSpawnAt = now + record.bucket.definition.refillSeconds
		return true
	end

	local function reserve(bucket: any, now: number): any
		local fixture = bucket.definition
		allocation += 1
		assert(allocation < 2 ^ 53, "exhausted world identity sequence")
		local id = if idPrefix
			then idPrefix .. "-" .. string.format("%.0f", allocation)
			else options.newId()
		assert(type(id) == "string" and id ~= "" and not usedIds[id], "reused creature ID")
		-- Regional IDs are namespace + monotonic sequence; no lifetime-sized ID set.
		if idPrefix == nil then
			usedIds[id] = true
		end
		local record = {
			id = id,
			bucket = bucket,
			regionId = fixture.regionId,
			habitatId = fixture.habitatId,
			spawnContextId = fixture.spawnContextId,
			contentSnapshotId = fixture.contentSnapshotId,
			speciesId = fixture.speciesId,
			rarityId = fixture.rarityId,
			position = copyPosition(fixture.position),
			createdAt = now,
			expiresAt = now + fixture.lifetimeSeconds,
			nextAttemptAt = now,
			attempts = 0,
			revision = 1,
			state = "Reserved",
			projection = nil,
			variantIdentity = nil,
		}
		records[id] = record
		bucket.currentId = id -- Pending selection/placement consumes capacity immediately.
		if options.selectCandidate then
			local candidate = options.selectCandidate(fixture)
			assert(
				type(candidate.speciesId) == "string" and type(candidate.rarityId) == "string",
				"invalid selected species"
			)
			assert(
				fixture.speciesIds == nil or table.find(fixture.speciesIds, candidate.speciesId),
				"species outside authored bucket"
			)
			assert(candidate.rarityId == fixture.rarityId, "unbound selected rarity")
			record.speciesId, record.rarityId = candidate.speciesId, candidate.rarityId
		end
		if options.generateVariant ~= nil then
			record.variantIdentity = options.generateVariant({
				creatureInstanceId = id,
				speciesId = record.speciesId,
				rarityId = record.rarityId,
				contentSnapshotId = record.contentSnapshotId,
				spawnContextId = record.spawnContextId,
			})
		end
		return record
	end

	local function tryMaterialize(record: any, now: number)
		local expectedGeneration, expectedRevision = generation, record.revision
		local function current(): boolean
			return running
				and generation == expectedGeneration
				and records[record.id] == record
				and record.state == "Reserved"
				and record.revision == expectedRevision
		end
		record.attempts += 1
		local fixture = record.bucket.definition
		local placed, valid = true, true
		if options.canMaterialize then
			placed, valid = pcall(options.canMaterialize, fixture)
		end
		local ok, handle = false, nil
		if placed and valid == true and current() then
			ok, handle = pcall(options.materialize, public(record))
		end
		if not current() then
			if ok and handle ~= nil then
				pcall(options.destroyProjection, handle)
			end
			return
		end
		if ok and handle ~= nil then
			local projected = public(record)
			projected.availability = "IdleAvailable"
			projected.runtimeRevision = record.revision + 1
			local activated = pcall(options.activate, handle, projected)
			if activated and current() then
				record.projection = handle
				record.state = "IdleAvailable"
				record.revision += 1
				local key = cellKey(record.position, baseFixture.cellSize)
				cells[key] = cells[key] or {}
				cells[key][record.id] = true
				return
			end
			pcall(options.destroyProjection, handle)
		end
		if not current() then
			return
		end
		if record.attempts >= fixture.maxMaterializationAttempts then
			terminate(record, now)
		else
			record.nextAttemptAt = now + fixture.retrySeconds
		end
	end

	local function start(): number
		assert(not running and generation == 0, "world service already started")
		running = true
		generation += 1
		local now = options.clock()
		assert(finite(now), "invalid world clock")
		for _, bucket in buckets do
			bucket.nextSpawnAt = now
		end
		if options.buckets then
			idPrefix = options.newId()
			assert(type(idPrefix) == "string" and idPrefix ~= "", "invalid world namespace")
		end
		return generation
	end

	local function stepBucket(bucket: any, now: number, expectedGeneration: number): string
		local record = if bucket.currentId ~= nil then records[bucket.currentId] else nil
		local active = options.isBucketActive == nil
			or options.isBucketActive(bucket.definition) == true
		if not running or expectedGeneration ~= generation then
			return "Stale"
		end
		if record ~= nil and record.state == "Reserved" and not active then
			terminate(record, now)
			return "Expired"
		end
		if
			record ~= nil
			and record.state == "IdleAvailable"
			and options.isProjectionAlive
			and not options.isProjectionAlive(record.projection, public(record))
		then
			terminate(record, now)
			return "Expired"
		end
		if record ~= nil and record.state == "IdleAvailable" and now >= record.expiresAt then
			terminate(record, now)
			return "Expired"
		end
		if record == nil and active and now >= bucket.nextSpawnAt then
			record = reserve(bucket, now)
		end
		if record ~= nil and record.state == "Reserved" and now >= record.nextAttemptAt then
			tryMaterialize(record, now)
			local live = records[record.id]
			return if live ~= nil and live.state == "IdleAvailable" then "Spawned" else "Pending"
		end
		return "Idle"
	end

	local function step(expectedGeneration: number): string
		if not running or expectedGeneration ~= generation then
			return "Stale"
		end
		if stepping then
			return "Busy"
		end
		local now = options.clock()
		assert(finite(now) and now >= lastStepAt, "invalid/regressing world clock")
		if now < nextStepAt then
			return "NotDue"
		end
		lastStepAt = now
		nextStepAt = now + (options.stepSeconds or 0)
		stepping = true
		local outcome = "Idle"
		for _ = 1, workLimit do
			if not running or expectedGeneration ~= generation then
				break
			end
			local bucket = buckets[cursor]
			cursor = cursor % #buckets + 1
			if not bucket.paused then
				local ok, result = pcall(stepBucket, bucket, now, expectedGeneration)
				if not ok then
					bucket.paused = true
					local record = if bucket.currentId then records[bucket.currentId] else nil
					if
						record and (record.state == "Reserved" or record.state == "IdleAvailable")
					then
						terminate(record, now)
					end
					if options.onBucketError then
						pcall(options.onBucketError, bucket.definition.spawnContextId)
					end
					outcome = "BucketPaused"
				elseif result ~= "Idle" then
					outcome = result
				end
			end
		end
		stepping = false
		return outcome
	end

	local function expireIfCurrent(id: string, expectedRevision: number): boolean
		local record = records[id]
		if
			record == nil
			or record.state ~= "IdleAvailable"
			or record.revision ~= expectedRevision
		then
			return false
		end
		local now = options.clock()
		if now < record.expiresAt then
			return false
		end
		return terminate(record, now)
	end

	local function interaction(id: string, position: any): (string, any?)
		local record = records[id]
		if record == nil or record.state ~= "IdleAvailable" then
			return "Unavailable", nil
		end
		if not validPosition(position) then
			return "InvalidPosition", nil
		end
		local dx = position.x - record.position.x
		local dy = position.y - record.position.y
		local dz = position.z - record.position.z
		if dx * dx + dy * dy + dz * dz > record.bucket.definition.interactionRadius ^ 2 then
			return "OutOfRange", nil
		end
		return "Available", public(record)
	end

	local function transition(id: string, from: string, to: string): boolean
		local record = records[id]
		if record == nil or record.state ~= from then
			return false
		end
		record.state = to
		record.revision += 1
		if record.projection ~= nil and options.updateProjection ~= nil then
			options.updateProjection(record.projection, public(record))
		end
		return true
	end

	local function identity(id: string): any
		local record = records[id]
		if record == nil then
			return nil
		end
		return {
			creatureInstanceId = record.id,
			speciesId = record.speciesId,
			spawnContextId = record.spawnContextId,
			contentSnapshotId = record.contentSnapshotId,
			variantIdentity = record.variantIdentity,
		}
	end

	local function nearby(position: any, radius: number): { any }
		if not validPosition(position) or not finite(radius) or radius < 0 or radius > 256 then
			return {}
		end
		local result = {}
		local minX = math.floor((position.x - radius) / baseFixture.cellSize)
		local maxX = math.floor((position.x + radius) / baseFixture.cellSize)
		local minZ = math.floor((position.z - radius) / baseFixture.cellSize)
		local maxZ = math.floor((position.z + radius) / baseFixture.cellSize)
		for x = minX, maxX do
			for z = minZ, maxZ do
				local bucket = cells[tostring(x) .. ":" .. tostring(z)]
				if bucket ~= nil then
					for id in bucket do
						local record = records[id]
						if record ~= nil and record.state == "IdleAvailable" then
							local dx = position.x - record.position.x
							local dy = position.y - record.position.y
							local dz = position.z - record.position.z
							if dx * dx + dy * dy + dz * dz <= radius * radius then
								table.insert(result, public(record))
							end
						end
					end
				end
			end
		end
		table.sort(result, function(a, b)
			return a.creatureInstanceId < b.creatureInstanceId
		end)
		return result
	end

	local function stop()
		if not running then
			return
		end
		running = false
		generation += 1
		for _, record in records do
			terminate(record, options.clock())
		end
	end

	return {
		start = start,
		step = step,
		stop = stop,
		currentId = function(): string?
			return buckets[1].currentId
		end,
		get = function(id: string): any
			local record = records[id]
			return if record ~= nil and record.state == "IdleAvailable" then public(record) else nil
		end,
		populationCount = function(): number
			local count = 0
			for _ in records do
				count += 1
			end
			return count
		end,
		bucketStatus = function(): { any }
			local result = {}
			for _, bucket in buckets do
				table.insert(result, {
					spawnContextId = bucket.definition.spawnContextId,
					regionId = bucket.definition.regionId,
					habitatId = bucket.definition.habitatId,
					count = if bucket.currentId then 1 else 0,
					paused = bucket.paused,
					creatureInstanceId = bucket.currentId,
				})
			end
			return result
		end,
		nearby = nearby,
		interaction = interaction,
		transition = transition,
		identity = identity,
		retire = function(id: string): boolean
			local record = records[id]
			return record ~= nil and terminate(record, options.clock())
		end,
		expireIfCurrent = expireIfCurrent,
	}
end

return WorldService
