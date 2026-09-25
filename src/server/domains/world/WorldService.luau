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
	clock: () -> number,
	newId: () -> string,
	materialize: (any) -> any,
	activate: (any, any) -> (),
	destroyProjection: (any) -> (),
})
	local fixture = options.fixture
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
		{ "regionId", "habitatId", "spawnContextId", "contentSnapshotId", "speciesId", "rarityId" }
	do
		assert(type(fixture[key]) == "string" and fixture[key] ~= "", "invalid fixture identity")
	end

	local records: { [string]: any } = {}
	local usedIds: { [string]: boolean } = {}
	local cells: { [string]: { [string]: boolean } } = {}
	local currentId: string? = nil
	local nextSpawnAt = 0
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
		local key = cellKey(record.position, fixture.cellSize)
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
		if currentId == record.id then
			currentId = nil
		end
		nextSpawnAt = now + fixture.refillSeconds
		return true
	end

	local function reserve(now: number): any
		local id = options.newId()
		assert(type(id) == "string" and id ~= "" and not usedIds[id], "reused creature ID")
		usedIds[id] = true
		local record = {
			id = id,
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
		}
		records[id] = record
		currentId = id -- A reservation already consumes the one-creature budget.
		return record
	end

	local function tryMaterialize(record: any, now: number)
		record.attempts += 1
		local ok, handle = pcall(options.materialize, public(record))
		if ok and handle ~= nil then
			local projected = public(record)
			projected.availability = "IdleAvailable"
			projected.runtimeRevision = record.revision + 1
			local activated = pcall(options.activate, handle, projected)
			if activated then
				record.projection = handle
				record.state = "IdleAvailable"
				record.revision += 1
				local key = cellKey(record.position, fixture.cellSize)
				cells[key] = cells[key] or {}
				cells[key][record.id] = true
				return
			end
			pcall(options.destroyProjection, handle)
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
		nextSpawnAt = options.clock()
		return generation
	end

	local function step(expectedGeneration: number): string
		if not running or expectedGeneration ~= generation then
			return "Stale"
		end
		local now = options.clock()
		assert(finite(now), "invalid world clock")
		local record = if currentId ~= nil then records[currentId] else nil
		if record ~= nil and record.state == "IdleAvailable" and now >= record.expiresAt then
			terminate(record, now)
			return "Expired"
		end
		if record == nil and now >= nextSpawnAt then
			record = reserve(now)
		end
		if record ~= nil and record.state == "Reserved" and now >= record.nextAttemptAt then
			tryMaterialize(record, now)
			local live = records[record.id]
			return if live ~= nil and live.state == "IdleAvailable" then "Spawned" else "Pending"
		end
		return "Idle"
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
		if dx * dx + dy * dy + dz * dz > fixture.interactionRadius ^ 2 then
			return "OutOfRange", nil
		end
		return "Available", public(record)
	end

	local function nearby(position: any, radius: number): { any }
		if not validPosition(position) or not finite(radius) or radius < 0 or radius > 256 then
			return {}
		end
		local result = {}
		local minX = math.floor((position.x - radius) / fixture.cellSize)
		local maxX = math.floor((position.x + radius) / fixture.cellSize)
		local minZ = math.floor((position.z - radius) / fixture.cellSize)
		local maxZ = math.floor((position.z + radius) / fixture.cellSize)
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
		local record = if currentId ~= nil then records[currentId] else nil
		if record ~= nil then
			terminate(record, options.clock())
		end
	end

	return {
		start = start,
		step = step,
		stop = stop,
		currentId = function(): string?
			return currentId
		end,
		get = function(id: string): any
			local record = records[id]
			return if record ~= nil and record.state == "IdleAvailable" then public(record) else nil
		end,
		populationCount = function(): number
			return if currentId == nil then 0 else 1
		end,
		nearby = nearby,
		interaction = interaction,
		expireIfCurrent = expireIfCurrent,
	}
end

return WorldService
