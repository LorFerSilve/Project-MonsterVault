--!strict

local WorldRegistry = {}
local function id(value: any, kind: string): boolean
	if type(value) ~= "string" or #value > 128 then
		return false
	end
	local segments = string.split(value, "/")
	if #segments < 2 or segments[1] ~= kind then
		return false
	end
	for _, segment in segments do
		if
			string.match(segment, "^[a-z][a-z0-9-]*$") == nil
			or string.sub(segment, -1) == "-"
			or string.find(segment, "--", 1, true) ~= nil
		then
			return false
		end
	end
	return true
end
local function freeze(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local result = {}
	for key, child in value do
		result[key] = freeze(child)
	end
	return table.freeze(result)
end
local function index(values: any, kind: string, limit: number): any
	assert(type(values) == "table" and #values <= limit, "unbounded " .. kind)
	local result = {}
	for key, d in values do
		assert(
			type(key) == "number" and key % 1 == 0 and key >= 1 and key <= #values,
			"invalid registry array"
		)
		assert(type(d) == "table" and id(d.id, kind) and result[d.id] == nil, "invalid " .. kind)
		result[d.id] = freeze(d)
	end
	return table.freeze(result)
end
local function references(values: any, target: any, limit: number, repeated: boolean?)
	assert(type(values) == "table" and #values > 0 and #values <= limit, "invalid references")
	local seen = {}
	for key, value in values do
		assert(
			type(key) == "number" and key % 1 == 0 and key >= 1 and key <= #values,
			"invalid reference array"
		)
		assert(target[value] ~= nil and (repeated or not seen[value]), "invalid reference")
		seen[value] = true
	end
end

function WorldRegistry.new(config: any): any
	assert(id(config.contentSnapshotId, "content-snapshot"), "invalid world snapshot")
	local value = config.worldCycle
	assert(type(value) == "table", "missing cycle definition")
	for key in value do
		assert(
			key == "id" or key == "version" or key == "epochUnixSeconds" or key == "phases",
			"unknown cycle field"
		)
	end
	assert(
		type(value.version) == "number"
			and value.version >= 1
			and value.version < 2 ^ 53
			and value.version % 1 == 0,
		"invalid cycle version"
	)
	assert(value.id == "world-cycle/ordinary-dev-v" .. value.version, "invalid versioned cycle ID")
	assert(
		type(value.epochUnixSeconds) == "number"
			and value.epochUnixSeconds >= 0
			and value.epochUnixSeconds < 2 ^ 53
			and value.epochUnixSeconds % 1 == 0,
		"invalid cycle epoch"
	)
	assert(type(value.phases) == "table" and #value.phases == 3, "missing ordinary phases")
	local phaseIds = { "world-phase/day", "world-phase/dusk", "world-phase/night" }
	local total = 0
	local phaseCount = 0
	for key, phase in value.phases do
		assert(
			type(key) == "number" and key % 1 == 0 and key >= 1 and key <= 3,
			"invalid phase array"
		)
		assert(
			type(phase) == "table" and phase.id == phaseIds[key],
			"invalid ordered ordinary phase"
		)
		for field in phase do
			assert(field == "id" or field == "durationSeconds", "unknown phase field")
		end
		assert(
			type(phase.durationSeconds) == "number"
				and phase.durationSeconds >= 1
				and phase.durationSeconds <= 3600
				and phase.durationSeconds % 1 == 0,
			"invalid phase duration"
		)
		total += phase.durationSeconds
		phaseCount += 1
	end
	assert(phaseCount == 3, "missing ordered phase")
	local cycle = freeze({
		id = value.id,
		version = value.version,
		epochUnixSeconds = value.epochUnixSeconds,
		phases = value.phases,
		durationSeconds = total,
	})
	local phases = {}
	for _, phase in cycle.phases do
		phases[phase.id] = true
	end
	local function cycleBinding(definition: any)
		assert(definition.cycleDefinitionId == cycle.id, "unbound cycle definition")
		references(definition.cyclePhaseIds, phases, 3)
		for n = 1, #definition.cyclePhaseIds do
			assert(definition.cyclePhaseIds[n] ~= nil, "missing cycle phase binding")
		end
	end
	local regions = index(config.regions, "region", 5)
	local species = index(config.species, "species", 64)
	local habitats = index(config.habitats, "habitat", 64)
	local contexts = index(config.spawnContexts, "spawn-context", 64)
	local landmarks = index(config.landmarks, "landmark", 64)
	local objectives = index(config.objectives, "field-objective", 32)
	local safeOutposts = index(config.safeOutposts or {}, "safe-outpost", 4)
	local securePoints = index(config.securePoints or {}, "secure-point", 8)
	local recoveryAnchors = index(config.recoveryAnchors or {}, "recovery-anchor", 8)
	local vaultAccessPoints = index(config.vaultAccessPoints or {}, "vault-access-point", 8)
	local travelNodes = index(config.travelNodes or {}, "travel-node", 8)
	local roles, milestones = {}, {}
	local roleAccess = {
		HomeHub = false,
		Starter = false,
		MidA = "access/biome-mid-a",
		MidB = "access/biome-mid-b",
		Advanced = "access/biome-advanced",
	}
	local roleMilestone = {
		Starter = "milestone/region-mastery/starter",
		MidA = "milestone/region-mastery/mid-a",
		MidB = "milestone/region-mastery/mid-b",
		Advanced = "milestone/region-mastery/advanced",
	}
	for _, r in regions do
		assert(roleAccess[r.role] ~= nil and roles[r.role] == nil, "invalid world role")
		assert((r.accessUnlockId or false) == roleAccess[r.role], "invalid access binding")
		roles[r.role] = r.id
		if roleMilestone[r.role] then
			milestones[roleMilestone[r.role]] = r.id
		end
	end
	for role in roleAccess do
		assert(roles[role] ~= nil, "missing GDS-9 role")
	end
	for _, s in species do
		assert(
			s.rarityId == "rarity/common"
				or s.rarityId == "rarity/uncommon"
				or s.rarityId == "rarity/rare"
				or s.rarityId == "rarity/epic"
				or s.rarityId == "rarity/legendary",
			"unknown species rarity"
		)
	end
	for _, h in habitats do
		assert(regions[h.regionId] ~= nil, "orphan habitat")
		cycleBinding(h)
	end
	for _, c in contexts do
		assert(habitats[c.habitatId] ~= nil, "orphan spawn context")
		cycleBinding(c)
		for _, phaseId in c.cyclePhaseIds do
			assert(
				table.find(habitats[c.habitatId].cyclePhaseIds, phaseId),
				"context outside habitat phases"
			)
		end
		references(c.speciesIds, species, 64)
		assert(
			#c.contentSnapshotIds > 0 and #c.contentSnapshotIds <= 8,
			"invalid provenance epochs"
		)
		local seen = {}
		for key, epoch in c.contentSnapshotIds do
			assert(
				type(key) == "number" and key % 1 == 0 and key >= 1 and key <= #c.contentSnapshotIds,
				"invalid epoch array"
			)
			assert(id(epoch, "content-snapshot") and not seen[epoch], "invalid provenance epoch")
			seen[epoch] = true
		end
	end
	for _, l in landmarks do
		assert(regions[l.regionId] ~= nil, "orphan landmark")
		assert(type(l.radius) == "number" and l.radius > 0 and l.radius <= 12, "invalid radius")
	end
	for _, o in objectives do
		assert(regions[o.regionId] ~= nil and o.kind == "TraversalSequence", "invalid objective")
		references(o.landmarkIds, landmarks, 8, true)
		assert(#o.landmarkIds >= 2, "presence is not an objective")
		for n, landmarkId in o.landmarkIds do
			assert(landmarks[landmarkId].regionId == o.regionId, "objective region mismatch")
			assert(n == 1 or landmarkId ~= o.landmarkIds[n - 1], "objective needs traversal")
		end
	end
	for _, r in regions do
		local m = r.mastery
		if m ~= nil then
			assert(m.milestoneId == roleMilestone[r.role], "invalid mastery binding")
			assert(
				type(m.contentSnapshotIds) == "table"
					and #m.contentSnapshotIds > 0
					and #m.contentSnapshotIds <= 8,
				"invalid mastery epochs"
			)
			local seenEpochs = {}
			for key, epoch in m.contentSnapshotIds do
				assert(
					type(key) == "number"
						and key % 1 == 0
						and key >= 1
						and key <= #m.contentSnapshotIds
						and id(epoch, "content-snapshot")
						and not seenEpochs[epoch],
					"invalid mastery epoch"
				)
				seenEpochs[epoch] = true
			end
			assert(seenEpochs[config.contentSnapshotId], "unbound current mastery recipe")
			references(m.landmarkIds, landmarks, 64)
			references(m.coreSpeciesIds, species, 64)
			references(m.objectiveIds, objectives, 32)
			assert(
				type(m.coreSpeciesThreshold) == "number"
					and m.coreSpeciesThreshold % 1 == 0
					and m.coreSpeciesThreshold >= 1
					and m.coreSpeciesThreshold < #m.coreSpeciesIds,
				"mastery must be below full pool"
			)
			for _, l in m.landmarkIds do
				assert(landmarks[l].regionId == r.id, "survey region mismatch")
			end
			for _, o in m.objectiveIds do
				assert(objectives[o].regionId == r.id, "mastery objective mismatch")
			end
			for _, s in m.coreSpeciesIds do
				assert(
					species[s].rarityId == "rarity/common"
						or species[s].rarityId == "rarity/uncommon",
					"DEV core rarity"
				)
				local eligible = false
				for _, c in contexts do
					if habitats[c.habitatId].regionId == r.id and table.find(c.speciesIds, s) then
						eligible = true
					end
				end
				assert(eligible, "core species has no regional provenance")
			end
		end
	end
	local topology = {
		HomeHub = { Starter = true },
		Starter = { HomeHub = true, MidA = true, MidB = true },
		MidA = { Starter = true, Advanced = true },
		MidB = { Starter = true, Advanced = true },
		Advanced = { MidA = true, MidB = true },
	}
	if config.authoringVersion ~= nil then
		assert(config.authoringVersion == 1, "unsupported authoring version")
		for _, r in regions do
			references(r.neighborIds, regions, 3)
			local expected = topology[r.role]
			local count = 0
			for _ in expected do
				count += 1
			end
			assert(#r.neighborIds == count, "invalid launch topology")
			for _, neighbor in r.neighborIds do
				assert(expected[regions[neighbor].role], "invalid launch edge")
			end
			if r.role ~= "HomeHub" then
				assert(
					r.mastery ~= nil and safeOutposts[r.entryOutpostId] ~= nil,
					"missing field entry/mastery"
				)
				assert(safeOutposts[r.entryOutpostId].regionId == r.id, "wrong entry region")
				local countHabitats = 0
				for _, h in habitats do
					if h.regionId == r.id then
						countHabitats += 1
					end
				end
				assert(countHabitats >= 2, "missing habitat choice")
			end
		end
	end
	for _, utilities in
		{ safeOutposts, securePoints, recoveryAnchors, vaultAccessPoints, travelNodes }
	do
		for _, d in utilities do
			assert(regions[d.regionId] ~= nil, "orphan utility")
			if d.radius ~= nil then
				assert(
					type(d.radius) == "number" and d.radius > 0 and d.radius <= 16,
					"invalid utility radius"
				)
			end
			if d.outpostId ~= nil then
				assert(
					safeOutposts[d.outpostId] ~= nil
						and safeOutposts[d.outpostId].regionId == d.regionId,
					"orphan field utility"
				)
			end
		end
	end
	for _, utilities in { safeOutposts, securePoints, vaultAccessPoints } do
		for _, d in utilities do
			assert(
				type(d.radius) == "number" and d.radius > 0 and d.radius <= 16,
				"missing utility radius"
			)
		end
	end
	for _, o in safeOutposts do
		assert(regions[o.regionId].role ~= "HomeHub", "invalid field outpost")
		assert(
			securePoints[o.securePointId] ~= nil and securePoints[o.securePointId].outpostId == o.id,
			"missing outpost extraction"
		)
		assert(
			recoveryAnchors[o.recoveryAnchorId] ~= nil
				and recoveryAnchors[o.recoveryAnchorId].outpostId == o.id,
			"missing outpost recovery"
		)
	end
	for _, t in travelNodes do
		assert(
			recoveryAnchors[t.recoveryAnchorId] ~= nil
				and recoveryAnchors[t.recoveryAnchorId].regionId == t.regionId,
			"unsafe travel binding"
		)
	end
	if config.authoringVersion ~= nil then
		local home = roles.HomeHub
		for _, map in { securePoints, recoveryAnchors, vaultAccessPoints, travelNodes } do
			local found = false
			for _, d in map do
				found = found or d.regionId == home
			end
			assert(found, "missing Home Hub utility")
		end
	end
	return table.freeze({
		contentSnapshotId = config.contentSnapshotId,
		worldCycle = cycle,
		spawnPolicy = freeze(config.spawnPolicy),
		regions = regions,
		roles = table.freeze(roles),
		milestones = table.freeze(milestones),
		species = species,
		habitats = habitats,
		spawnContexts = contexts,
		landmarks = landmarks,
		objectives = objectives,
		authoringVersion = config.authoringVersion,
		safeOutposts = safeOutposts,
		securePoints = securePoints,
		recoveryAnchors = recoveryAnchors,
		vaultAccessPoints = vaultAccessPoints,
		travelNodes = travelNodes,
	})
end
return WorldRegistry
