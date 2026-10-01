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
	local regions = index(config.regions, "region", 5)
	local species = index(config.species, "species", 64)
	local habitats = index(config.habitats, "habitat", 64)
	local contexts = index(config.spawnContexts, "spawn-context", 64)
	local landmarks = index(config.landmarks, "landmark", 64)
	local objectives = index(config.objectives, "field-objective", 32)
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
	end
	for _, c in contexts do
		assert(habitats[c.habitatId] ~= nil, "orphan spawn context")
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
	return table.freeze({
		contentSnapshotId = config.contentSnapshotId,
		regions = regions,
		roles = table.freeze(roles),
		milestones = table.freeze(milestones),
		species = species,
		habitats = habitats,
		spawnContexts = contexts,
		landmarks = landmarks,
		objectives = objectives,
	})
end
return WorldRegistry
