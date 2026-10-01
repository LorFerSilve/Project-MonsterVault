--!strict

-- The only mastery owner. Evidence is written inside the existing profile P2.
local WorldProgressionService = {}
local function integer(value: any, maximum: number): boolean
	return type(value) == "number" and value >= 0 and value <= maximum and value % 1 == 0
end
function WorldProgressionService.new(registry: any): any
	local function validate(profile: any): string?
		if
			type(profile) ~= "table" or not integer(profile.profileRevision, 9_007_199_254_740_991)
		then
			return "INVALID_WORLD_PROFILE"
		end
		local w = profile.world
		if type(w) ~= "table" or w.schemaVersion ~= 1 then
			return "INVALID_WORLD_SCHEMA"
		end
		local allowed = {
			schemaVersion = true,
			landmarks = true,
			objectives = true,
			regionalSpecies = true,
			mastery = true,
		}
		for key in w do
			if not allowed[key] then
				return "UNBOUND_WORLD_STATE"
			end
		end
		local function facts(values: any, definitions: any, limit: number): boolean
			if type(values) ~= "table" then
				return false
			end
			local count = 0
			for id, fact in values do
				count += 1
				if count > limit or definitions[id] == nil or type(fact) ~= "table" then
					return false
				end
				if
					type(fact.operationId) ~= "string"
					or #fact.operationId < 1
					or #fact.operationId > 96
					or not integer(fact.revision, 9_007_199_254_740_991)
					or fact.revision < 1
					or fact.revision > profile.profileRevision
					or type(fact.contentSnapshotId) ~= "string"
					or #fact.contentSnapshotId < 1
					or #fact.contentSnapshotId > 128
				then
					return false
				end
				for key in fact do
					if
						key ~= "operationId"
						and key ~= "revision"
						and key ~= "contentSnapshotId"
					then
						return false
					end
				end
			end
			return true
		end
		if
			not facts(w.landmarks, registry.landmarks, 64)
			or not facts(w.mastery, registry.milestones, 4)
		then
			return "INVALID_WORLD_FACT"
		end
		for milestone in w.mastery do
			if registry.regions[registry.milestones[milestone]].mastery == nil then
				return "UNBOUND_MASTERY_FACT"
			end
		end
		if type(w.objectives) ~= "table" or type(w.regionalSpecies) ~= "table" then
			return "INVALID_WORLD_PROGRESS"
		end
		local count = 0
		for id, progress in w.objectives do
			count += 1
			local d = registry.objectives[id]
			if count > 32 or d == nil or not integer(progress, #d.landmarkIds) then
				return "INVALID_OBJECTIVE_PROGRESS"
			end
		end
		count = 0
		for regionId, species in w.regionalSpecies do
			count += 1
			if
				count > 4
				or registry.regions[regionId] == nil
				or not facts(species, registry.species, 64)
			then
				return "INVALID_REGIONAL_EVIDENCE"
			end
			for speciesId in species do
				local eligible = false
				for _, context in registry.spawnContexts do
					if
						registry.habitats[context.habitatId].regionId == regionId
						and table.find(context.speciesIds, speciesId)
					then
						eligible = true
					end
				end
				if not eligible then
					return "INVALID_REGIONAL_EVIDENCE"
				end
			end
		end
		return nil
	end
	local function prepare(profile: any): any
		if
			profile.world == nil or (type(profile.world) == "table" and next(profile.world) == nil)
		then
			profile.world = {
				schemaVersion = 1,
				landmarks = {},
				objectives = {},
				regionalSpecies = {},
				mastery = {},
			}
			-- Do not infer exploration/objectives from global discovery or old ownership.
			return { status = "Prepared", changed = true }
		end
		local invalid = validate(profile)
		return if invalid
			then { status = "Protected", reason = invalid }
			else { status = "Prepared", changed = false }
	end
	local function fact(profile: any, operation: string): any
		return {
			operationId = operation,
			revision = profile.profileRevision + 1,
			contentSnapshotId = registry.contentSnapshotId,
		}
	end
	local function evaluate(profile: any, regionId: string, operation: string)
		local m = registry.regions[regionId].mastery
		local w = profile.world
		if m == nil or w.mastery[m.milestoneId] ~= nil then
			return
		end
		for _, id in m.landmarkIds do
			if w.landmarks[id] == nil then
				return
			end
		end
		for _, id in m.objectiveIds do
			if w.objectives[id] ~= #registry.objectives[id].landmarkIds then
				return
			end
		end
		local count = 0
		local evidence = w.regionalSpecies[regionId] or {}
		for _, id in m.coreSpeciesIds do
			if evidence[id] ~= nil then
				count += 1
			end
		end
		if count >= m.coreSpeciesThreshold then
			w.mastery[m.milestoneId] = fact(profile, operation)
		end
	end
	local function canAccess(profile: any, regionId: string, hasAccess: any): boolean
		local r = registry.regions[regionId]
		if r == nil or validate(profile) ~= nil then
			return false
		end
		if r.accessUnlockId == nil then
			return true
		end
		local ok, allowed = pcall(hasAccess, profile, r.accessUnlockId)
		return ok and allowed == true
	end
	local function provenance(record: any): string?
		if type(record) ~= "table" or type(record.origin) ~= "table" then
			return nil
		end
		local c = registry.spawnContexts[record.origin.spawnContextId]
		if
			c == nil
			or not table.find(c.contentSnapshotIds, record.origin.contentSnapshotId)
			or not table.find(c.speciesIds, record.speciesId)
		then
			return nil
		end
		return registry.habitats[c.habitatId].regionId
	end
	local function secured(profile: any, record: any)
		assert(validate(profile) == nil, "invalid world state")
		local regionId = provenance(record)
		if regionId == nil then
			return
		end
		local w = profile.world
		w.regionalSpecies[regionId] = w.regionalSpecies[regionId] or {}
		if w.regionalSpecies[regionId][record.speciesId] == nil then
			w.regionalSpecies[regionId][record.speciesId] = fact(profile, record.operationId)
		end
		evaluate(profile, regionId, record.operationId)
	end
	local function visit(profile: any, landmarkId: string, operation: string): boolean
		assert(validate(profile) == nil, "invalid world state")
		local l = assert(registry.landmarks[landmarkId], "unknown landmark")
		local w, changed = profile.world, false
		if w.landmarks[landmarkId] == nil then
			w.landmarks[landmarkId] = fact(profile, operation)
			changed = true
		end
		for id, o in registry.objectives do
			local progress = w.objectives[id] or 0
			if o.regionId == l.regionId and o.landmarkIds[progress + 1] == landmarkId then
				w.objectives[id] = progress + 1
				changed = true
			end
		end
		evaluate(profile, l.regionId, operation)
		return changed
	end
	return {
		registry = registry,
		validate = validate,
		prepare = prepare,
		visit = visit,
		secured = secured,
		provenance = provenance,
		canAccess = canAccess,
		mastery = function(profile: any, milestoneId: string): boolean
			return validate(profile) == nil
				and registry.milestones[milestoneId] ~= nil
				and profile.world.mastery[milestoneId] ~= nil
		end,
	}
end
return WorldProgressionService
