--!strict

local WorldProjectionV1 =
	require(game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts.WorldProjectionV1)
local WorldProjectionStore = require(script.Parent.Parent.store.WorldProjectionStore)

local WorldModelObserver = {}

function WorldModelObserver.new(options: { collectionService: any, diagnostics: any })
	local tag = "MonsterVaultWorldCreature"
	local store = WorldProjectionStore.new(WorldProjectionV1)
	local connections: { any } = {}
	local observed: { [any]: any } = {}
	local running = false

	local function observe(model: any)
		if observed[model] ~= nil or not model:IsA("Model") then
			return
		end
		local outcome = store.streamIn(model, model:GetAttributes())
		if outcome == "Invalid" then
			options.diagnostics.emit("warn", "WORLD_PROJECTION_INVALID", { component = "world" })
			return
		end
		observed[model] = model.AttributeChanged:Connect(function()
			if running then
				store.streamIn(model, model:GetAttributes())
			end
		end)
	end

	local function forget(model: any)
		local connection = observed[model]
		if connection ~= nil then
			connection:Disconnect()
			observed[model] = nil
		end
		store.streamOut(model)
	end

	local function start()
		assert(not running, "world observer already started")
		running = true
		table.insert(
			connections,
			options.collectionService:GetInstanceAddedSignal(tag):Connect(observe)
		)
		table.insert(
			connections,
			options.collectionService:GetInstanceRemovedSignal(tag):Connect(forget)
		)
		for _, model in options.collectionService:GetTagged(tag) do
			observe(model)
		end
	end

	local function stop(): { string }
		running = false
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
		for model in observed do
			forget(model)
		end
		store.reset()
		return {}
	end

	return { id = "world_observer", dependencies = {}, start = start, stop = stop, store = store }
end

return WorldModelObserver
