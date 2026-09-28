--!strict

export type Mode = "World" | "Capture" | "Blocked"

export type Options = {
	parent: any,
	button: any,
	userInputService: any,
	guiService: any,
	onActivate: () -> (),
	onInputChanged: ((string) -> ())?,
}

local InputRouter = {}

function InputRouter.new(options: Options)
	local globals = getfenv() :: any
	local Enum = globals.Enum
	local Instance = globals.Instance
	local input = options.userInputService
	local gui = options.guiService
	local connections: { any } = {}
	local heldInputs: { [any]: boolean } = {}
	local context: any = nil
	local action: any = nil
	local mode: Mode = "Blocked"
	local started = false
	local stopped = false
	local windowFocused = true
	local menuOpen = false
	local guarded = false
	local lastBindingText: string? = nil

	local function blocked(): boolean
		return mode == "Blocked"
			or not windowFocused
			or menuOpen
			or gui.MenuIsOpen
			or input:GetFocusedTextBox() ~= nil
	end

	local function physicallyHeld(): boolean
		for object in heldInputs do
			if
				object.UserInputState == Enum.UserInputState.End
				or object.UserInputState == Enum.UserInputState.Cancel
			then
				heldInputs[object] = nil
			end
		end
		if (action ~= nil and action:GetState() == true) or next(heldInputs) ~= nil then
			return true
		end
		if input:IsKeyDown(Enum.KeyCode.E) then
			return true
		end
		for _, gamepad in input:GetConnectedGamepads() do
			if input:IsGamepadButtonDown(gamepad, Enum.KeyCode.ButtonX) then
				return true
			end
			if
				gui.SelectedObject == options.button
				and input:IsGamepadButtonDown(gamepad, Enum.KeyCode.ButtonA)
			then
				return true
			end
		end
		return false
	end

	local function updateGuard()
		guarded = physicallyHeld()
	end

	local function updateBindingText()
		local preferred = input.PreferredInput
		local text = "E"
		if preferred == Enum.PreferredInput.Touch then
			text = "Tap"
		elseif preferred == Enum.PreferredInput.Gamepad then
			local binding = if action ~= nil then action.PreferredBinding else nil
			local keyCode = if binding ~= nil and binding.UIButton == nil
				then binding.KeyCode
				else Enum.KeyCode.ButtonX
			text = input:GetStringForKeyCode(keyCode):gsub("^Button", "")
			if text == "" then
				text = "X"
			end
		else
			local binding = if action ~= nil then action.PreferredBinding else nil
			if binding ~= nil and binding.UIButton ~= nil then
				text = "Click"
			else
				text = input:GetStringForKeyCode(Enum.KeyCode.E)
				if text == "" then
					text = "E"
				end
			end
		end
		if text ~= lastBindingText then
			lastBindingText = text
			if options.onInputChanged ~= nil then
				options.onInputChanged(text)
			end
		end
	end

	local function connect(event: any, callback: (...any) -> ())
		table.insert(connections, event:Connect(callback))
	end

	local router = {}
	function router.refresh()
		if stopped or not started then
			return
		end
		updateGuard()
		updateBindingText()
	end

	function router.setMode(nextMode: Mode)
		if stopped then
			return
		end
		assert(
			nextMode == "World" or nextMode == "Capture" or nextMode == "Blocked",
			"invalid capture input mode"
		)
		if nextMode ~= mode then
			mode = nextMode
			-- Keep the native action alive while blocked. Disabling/recreating it
			-- would reset its state and could turn a held gesture into a new press.
			updateGuard()
		end
	end

	function router.start()
		assert(not stopped, "capture input router has a one-shot lifecycle")
		if started then
			return
		end
		started = true
		context = Instance.new("InputContext")
		context.Name = "MonsterVaultCaptureInput"
		context.Enabled = false
		context.Priority = 2000
		context.Sink = true
		action = Instance.new("InputAction")
		action.Name = "CapturePrimary"
		action.Type = Enum.InputActionType.Bool
		action.Parent = context
		for _, keyCode in { Enum.KeyCode.E, Enum.KeyCode.ButtonX } do
			local binding = Instance.new("InputBinding")
			binding.Name = keyCode.Name
			binding.KeyCode = keyCode
			binding.Parent = action
		end
		local buttonBinding = Instance.new("InputBinding")
		buttonBinding.Name = "CaptureButton"
		buttonBinding.UIButton = options.button
		buttonBinding.Parent = action

		connect(action.Pressed, function()
			if stopped then
				return
			end
			if guarded or blocked() then
				guarded = true
				return
			end
			options.onActivate()
		end)
		connect(action.Released, updateGuard)
		connect(input.InputBegan, function(object: any)
			if object.KeyCode == Enum.KeyCode.E or object.KeyCode == Enum.KeyCode.ButtonX then
				heldInputs[object] = true
			end
		end)
		connect(options.button.InputBegan, function(object: any)
			if
				object.UserInputType == Enum.UserInputType.MouseButton1
				or object.UserInputType == Enum.UserInputType.Touch
				or object.KeyCode == Enum.KeyCode.ButtonA
			then
				heldInputs[object] = true
			end
		end)
		connect(input.InputEnded, function(object: any)
			heldInputs[object] = nil
			updateGuard()
		end)
		connect(input.WindowFocusReleased, function()
			windowFocused = false
			updateGuard()
		end)
		connect(input.WindowFocused, function()
			windowFocused = true
			updateGuard()
		end)
		connect(input.TextBoxFocused, updateGuard)
		connect(input.TextBoxFocusReleased, updateGuard)
		connect(gui.MenuOpened, function()
			menuOpen = true
			updateGuard()
		end)
		connect(gui.MenuClosed, function()
			menuOpen = false
			updateGuard()
		end)
		connect(input:GetPropertyChangedSignal("PreferredInput"), updateBindingText)
		connect(action:GetPropertyChangedSignal("PreferredBinding"), updateBindingText)
		updateGuard()
		context.Parent = options.parent
		context.Enabled = true
		updateBindingText()
	end

	function router.stop()
		if stopped then
			return
		end
		stopped = true
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
		table.clear(heldInputs)
		if context ~= nil then
			context:Destroy()
		end
		context = nil
		action = nil
	end

	return router
end

return InputRouter
