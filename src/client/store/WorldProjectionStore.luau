--!strict

local WorldProjectionStore = {}

function WorldProjectionStore.new(contract: any)
	local byId: { [string]: any } = {}
	local byModel: { [any]: string } = {}
	local order: { string } = {}

	local function streamIn(model: any, attributes: any): string
		if not contract.valid(attributes) then
			return "Invalid"
		end
		local id = attributes.CreatureInstanceId
		local oldId = byModel[model]
		if oldId ~= nil and oldId ~= id then
			return "Invalid"
		end
		local previous = byId[id]
		if previous ~= nil and attributes.RuntimeRevision < previous.revision then
			return "Stale"
		end
		if previous ~= nil and previous.model ~= nil and previous.model ~= model then
			byModel[previous.model] = nil
		end
		byModel[model] = id
		if previous == nil then
			table.insert(order, id)
		end
		byId[id] = {
			id = id,
			speciesId = attributes.SpeciesId,
			rarityId = attributes.RarityId,
			spawnContextId = attributes.SpawnContextId,
			revision = attributes.RuntimeRevision,
			availability = attributes.Availability,
			model = model,
		}
		while #order > 256 do
			local oldest = table.remove(order, 1)
			if oldest ~= nil then
				local evicted = byId[oldest]
				if evicted ~= nil and evicted.model ~= nil then
					byModel[evicted.model] = nil
				end
				byId[oldest] = nil
			end
		end
		return "Applied"
	end

	local function streamOut(model: any): boolean
		local id = byModel[model]
		if id == nil then
			return false
		end
		byModel[model] = nil
		local entry = byId[id]
		if entry ~= nil and entry.model == model then
			entry.model = nil -- Stream-out is never a server-side terminal transition.
		end
		return true
	end

	local function view(id: string): any
		local entry = byId[id]
		if entry == nil then
			return nil
		end
		return {
			creatureInstanceId = entry.id,
			speciesId = entry.speciesId,
			rarityId = entry.rarityId,
			spawnContextId = entry.spawnContextId,
			runtimeRevision = entry.revision,
			availability = entry.availability,
			present = entry.model ~= nil,
		}
	end

	return {
		streamIn = streamIn,
		streamOut = streamOut,
		view = view,
		reset = function()
			byId = {}
			byModel = {}
			order = {}
		end,
	}
end

return WorldProjectionStore
