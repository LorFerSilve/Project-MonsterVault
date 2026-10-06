--!strict

local shared = game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts
local CaptureProjectionV1 = require(shared.CaptureProjectionV1)
local RouteIds = require(shared.RouteIds)
local CaptureController = require(script.Parent.Parent.controllers.CaptureController)
local CaptureView = require(script.Parent.Parent.presentation.CaptureView)
local InputRouter = require(script.Parent.Parent.input.InputRouter)

local CaptureRuntimeService = {}

function CaptureRuntimeService.new(options: {
	networking: any,
	worldObserver: any,
	player: any,
	userInputService: any,
	guiService: any,
	onPresentation: ((any) -> ())?,
})
	local scheduler = (getfenv() :: any).task
	local running, started = false, false
	local presentation: any = nil
	local input: any = nil
	local unsubscribe: any = nil
	local captureSynced = false
	local nextResyncAt = 0
	local function ready(): boolean
		local state = options.networking.store.view()
		return state ~= nil and state.status == "Ready"
	end
	local function position(): any
		local character = options.player.Character
		local humanoid = if character ~= nil
			then character:FindFirstChildOfClass("Humanoid")
			else nil
		local root = if character ~= nil then character:FindFirstChild("HumanoidRootPart") else nil
		return if humanoid ~= nil
				and humanoid.Health > 0
				and root ~= nil
			then root.Position
			else nil
	end
	local function inReach(model: any, origin: any): boolean
		return model.Parent ~= nil and (model:GetPivot().Position - origin).Magnitude <= 12
	end
	local controller = CaptureController.new({
		gateway = options.networking.gateway,
		routes = RouteIds,
		captureProjection = CaptureProjectionV1,
		sessionReady = ready,
		clock = os.clock,
		actionAvailable = function(creatureId: string?): boolean
			local origin = position()
			if origin == nil then
				return false
			end
			for _, entry in options.worldObserver.store.present() do
				if entry.creatureInstanceId == creatureId then
					return inReach(entry.model, origin)
				end
			end
			return false
		end,
		onChanged = function(state)
			if options.onPresentation then
				pcall(options.onPresentation, state)
			end
			if presentation ~= nil then
				presentation.render(state)
			end
			if input ~= nil then
				input.setMode(
					if not state.canActivate
						then "Blocked"
						elseif state.state == "Claimed" then "Capture"
						else "World"
				)
			end
		end,
	})
	local function poll()
		local origin = position()
		local target: string? = nil
		local nearest = math.huge
		if origin ~= nil then
			for _, entry in options.worldObserver.store.present() do
				if entry.availability == "IdleAvailable" and inReach(entry.model, origin) then
					local distance = (entry.model:GetPivot().Position - origin).Magnitude
					if distance < nearest then
						target, nearest = entry.creatureInstanceId, distance
					end
				end
			end
		end
		controller.setTarget(target)
		controller.tick()
		input.refresh()
		local state = controller.view().state
		local active = state == "Claimed"
			or state == "TransportActive"
			or state == "FinalizationPending"
		-- Touch extraction, expiry and death are unsolicited server transitions.
		-- Refresh active captures even when the last command already completed.
		if ready() and (not captureSynced or active) and os.clock() >= nextResyncAt then
			nextResyncAt = os.clock() + 5
			options.networking.gateway.send(
				RouteIds.commands.sessionRequestResync,
				{ domain = "capture" }
			)
		end
	end
	local function start()
		assert(not started, "capture client is one-shot")
		started, running = true, true
		presentation = CaptureView.new({
			parent = options.player:WaitForChild("PlayerGui"),
			guiService = options.guiService,
			userInputService = options.userInputService,
			modalOpen = function()
				return options.player.PlayerGui:GetAttribute("GoldenModalOpen") == true
			end,
		})
		input = InputRouter.new({
			parent = options.player:WaitForChild("PlayerGui"),
			button = presentation.button,
			userInputService = options.userInputService,
			guiService = options.guiService,
			onActivate = function()
				controller.activate()
			end,
			onInputChanged = presentation.setGlyph,
			modalOpen = function()
				return options.player.PlayerGui:GetAttribute("GoldenModalOpen") == true
			end,
		})
		unsubscribe = options.networking.subscribeCapture(function(envelope)
			if
				controller.handleCapture(
					envelope.payload,
					envelope.revision,
					envelope.correlationId
				) == "Applied"
			then
				captureSynced = true
			end
		end)
		input.start()
		presentation.render(controller.view())
		poll()
		scheduler.spawn(function()
			while running do
				scheduler.wait(0.2)
				if running then
					poll()
				end
			end
		end)
	end
	local function stop(): { string }
		running = false
		if unsubscribe ~= nil then
			unsubscribe()
		end
		if input ~= nil then
			input.stop()
		end
		if presentation ~= nil then
			presentation.stop()
		end
		controller.reset()
		return {}
	end
	return {
		id = "capture_client",
		dependencies = { "networking", "world_observer" },
		start = start,
		stop = stop,
	}
end

return CaptureRuntimeService
