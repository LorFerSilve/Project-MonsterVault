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
	local presentationListener: any = nil
	local function publish(model: any)
		if presentationListener then
			local view = store.view(model:GetAttribute("CreatureInstanceId"))
			pcall(presentationListener, model, if view and view.present then view else nil)
		end
	end

	local function observe(model: any)
		if observed[model] ~= nil or not model:IsA("Model") then
			return
		end
		local outcome = store.streamIn(model, model:GetAttributes())
		if outcome == "Invalid" then
			options.diagnostics.emit("warn", "WORLD_PROJECTION_INVALID", { component = "world" })
			return
		end
		if outcome == "Applied" then
			publish(model)
		end
		observed[model] = model.AttributeChanged:Connect(function()
			if running then
				if store.streamIn(model, model:GetAttributes()) == "Applied" then
					publish(model)
				end
			end
		end)
	end

	local function forget(model: any)
		local connection = observed[model]
		if connection ~= nil then
			connection:Disconnect()
			observed[model] = nil
		end
		if store.streamOut(model) and presentationListener then
			pcall(presentationListener, model, nil)
		end
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

	return {
		id = "world_observer",
		dependencies = {},
		start = start,
		stop = stop,
		store = store,
		subscribePresentation = function(listener: any)
			assert(presentationListener == nil, "world presentation already subscribed")
			presentationListener = listener
			for _, row in store.present() do
				publish(row.model)
			end
			return function()
				if presentationListener == listener then
					presentationListener = nil
				end
			end
		end,
	}
end

return WorldModelObserver
