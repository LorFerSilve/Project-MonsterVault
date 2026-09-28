--!strict

local fsModuleName = "@lune/fs"
local luauModuleName = "@lune/luau"
local fs = require(fsModuleName) :: any
local luau = require(luauModuleName) :: any

local function signal(): any
	local listeners = {}
	return {
		Connect = function(_self: any, callback: (...any) -> ())
			local connection: any = { Connected = true }
			connection.Disconnect = function(self: any)
				self.Connected = false
			end
			table.insert(listeners, { connection = connection, callback = callback })
			return connection
		end,
		Fire = function(_self: any, ...: any)
			for _, listener in table.clone(listeners) do
				if listener.connection.Connected then
					listener.callback(...)
				end
			end
		end,
		connected = function(): number
			local count = 0
			for _, listener in listeners do
				if listener.connection.Connected then
					count += 1
				end
			end
			return count
		end,
	}
end

local function harness(initialKeyDown: boolean?): any
	local created: { any } = {}
	local signals: { any } = {}
	local activations = 0
	local glyphs: { string } = {}
	local enum = {
		KeyCode = {
			E = { Name = "E" },
			ButtonX = { Name = "ButtonX" },
			ButtonA = { Name = "ButtonA" },
		},
		InputActionType = { Bool = "Bool" },
		UserInputState = { End = "End", Cancel = "Cancel" },
		UserInputType = { MouseButton1 = "MouseButton1", Touch = "Touch" },
		PreferredInput = {
			Touch = "Touch",
			Gamepad = "Gamepad",
			KeyboardAndMouse = "KeyboardAndMouse",
		},
	}
	local function trackedSignal(): any
		local event = signal()
		table.insert(signals, event)
		return event
	end
	local preferredInputChanged = trackedSignal()
	local input: any = {
		PreferredInput = enum.PreferredInput.KeyboardAndMouse,
		keyDown = initialKeyDown == true,
		gamepadDown = false,
		focusedTextBox = nil,
		InputBegan = trackedSignal(),
		InputEnded = trackedSignal(),
		WindowFocusReleased = trackedSignal(),
		WindowFocused = trackedSignal(),
		TextBoxFocused = trackedSignal(),
		TextBoxFocusReleased = trackedSignal(),
		GetFocusedTextBox = function(self: any)
			return self.focusedTextBox
		end,
		IsKeyDown = function(self: any, keyCode: any)
			assert(keyCode == enum.KeyCode.E, "router only queries its keyboard binding")
			return self.keyDown
		end,
		GetConnectedGamepads = function()
			return { "Gamepad1" }
		end,
		IsGamepadButtonDown = function(self: any, _gamepad: any, keyCode: any)
			return keyCode == enum.KeyCode.ButtonX and self.gamepadDown
		end,
		GetStringForKeyCode = function(_self: any, keyCode: any)
			return keyCode.Name
		end,
		GetPropertyChangedSignal = function(_self: any, property: string)
			assert(property == "PreferredInput", "router observes preferred input family")
			return preferredInputChanged
		end,
	}
	local gui = { MenuIsOpen = false, MenuOpened = trackedSignal(), MenuClosed = trackedSignal() }
	local button = { InputBegan = trackedSignal() }
	local parent = {}
	local module = luau.load(fs.readFile("src/client/input/InputRouter.luau"), {
		debugName = "InputRouter runtime test",
		environment = {
			Enum = enum,
			Instance = {
				new = function(className: string)
					local object: any = {
						ClassName = className,
						Destroy = function(self: any)
							self.destroyed = true
						end,
					}
					if className == "InputAction" then
						object.state = false
						object.Pressed = trackedSignal()
						object.Released = trackedSignal()
						object.GetState = function(self: any)
							return self.state
						end
						object.preferredChanged = trackedSignal()
						object.GetPropertyChangedSignal = function(self: any, property: string)
							assert(
								property == "PreferredBinding",
								"router observes preferred action binding"
							)
							return self.preferredChanged
						end
					end
					table.insert(created, object)
					return object
				end,
			},
		},
		injectGlobals = true,
	})()
	local router = module.new({
		parent = parent,
		button = button,
		userInputService = input,
		guiService = gui,
		onActivate = function()
			activations += 1
		end,
		onInputChanged = function(text: string)
			table.insert(glyphs, text)
		end,
	})
	router.setMode("World")
	router.start()
	local action = created[2]
	return {
		router = router,
		input = input,
		gui = gui,
		button = button,
		action = action,
		created = created,
		glyphs = glyphs,
		enum = enum,
		signals = signals,
		activations = function()
			return activations
		end,
		press = function()
			input.keyDown = true
			action.state = true
			action.Pressed:Fire()
		end,
		release = function()
			input.keyDown = false
			input.gamepadDown = false
			action.state = false
			action.Released:Fire()
		end,
		changeDevice = function(device: any)
			input.PreferredInput = device
			preferredInputChanged:Fire()
		end,
	}
end

local function heldGestureCannotActivateNextStage()
	local h = harness()
	h.press()
	assert(h.activations() == 1, "fresh world action accepted")
	h.router.setMode("Capture")
	h.action.Pressed:Fire()
	assert(h.activations() == 1, "held world gesture cannot activate capture")
	h.router.setMode("Blocked")
	h.router.setMode("Capture")
	h.action.Pressed:Fire()
	assert(h.activations() == 1, "pending to capture does not reset a held native action")
	h.release()
	h.press()
	assert(h.activations() == 2, "capture requires a fresh gesture")
	h.router.stop()
end

local function blockedFocusAndMenusRequireFreshGesture()
	local h = harness()
	h.input.focusedTextBox = {}
	h.press()
	assert(h.activations() == 0, "typing cannot capture")
	h.input.focusedTextBox = nil
	h.input.TextBoxFocusReleased:Fire()
	h.action.Pressed:Fire()
	assert(h.activations() == 0, "text box dismissal cannot leak held action")
	h.release()
	h.gui.MenuIsOpen = true
	h.gui.MenuOpened:Fire()
	h.press()
	assert(h.activations() == 0, "Roblox menu owns input")
	h.gui.MenuIsOpen = false
	h.gui.MenuClosed:Fire()
	h.action.Pressed:Fire()
	assert(h.activations() == 0, "menu dismissal cannot capture")
	h.release()
	h.input.WindowFocusReleased:Fire()
	h.press()
	h.input.WindowFocused:Fire()
	assert(h.activations() == 0, "unfocused window cannot capture")
	h.release()
	h.press()
	assert(h.activations() == 1, "fresh gesture after focus restoration accepted")
	h.router.stop()
end

local function deviceSwitchOnlyUpdatesBindingText()
	local h = harness()
	h.press()
	h.router.setMode("Capture")
	h.changeDevice(h.enum.PreferredInput.Touch)
	assert(h.glyphs[#h.glyphs] == "Tap", "touch has semantic button hint")
	h.changeDevice(h.enum.PreferredInput.Gamepad)
	assert(h.glyphs[#h.glyphs] == "X", "gamepad has binding text fallback")
	h.changeDevice(h.enum.PreferredInput.KeyboardAndMouse)
	assert(h.glyphs[#h.glyphs] == "E", "keyboard hint restored")
	assert(h.activations() == 1, "input family switching cannot issue gameplay intent")
	h.action.Pressed:Fire()
	assert(h.activations() == 1, "device switching preserves handoff guard")
	h.router.stop()
end

local function nativeBindingsAndLifecycleAreSingleOwner()
	local h = harness(true)
	h.press()
	assert(h.activations() == 0, "already held startup key requires release")
	h.release()
	h.press()
	assert(h.activations() == 1, "fresh key after startup admitted")
	local context = h.created[1]
	assert(context.Enabled and context.Sink, "one native context owns shared bindings")
	assert(h.created[3].KeyCode == h.enum.KeyCode.E, "keyboard binding")
	assert(h.created[4].KeyCode == h.enum.KeyCode.ButtonX, "gamepad binding")
	assert(h.created[5].UIButton == h.button, "one GUI binding covers pointer, touch and selection")
	h.router.start()
	assert(#h.created == 5, "repeated start cannot duplicate semantic actions")
	h.router.stop()
	h.router.stop()
	assert(context.destroyed, "stop removes all native bindings with their context")
	for _, event in h.signals do
		assert(event.connected() == 0, "stop disconnects every input listener")
	end
	h.release()
	h.press()
	h.changeDevice(h.enum.PreferredInput.Touch)
	assert(h.activations() == 1, "stopped native callbacks cannot submit")
	assert(not pcall(h.router.start), "stopped router cannot restart")
end

local function pointerReleaseNeutralizesHandoff()
	local h = harness()
	local touch = { UserInputType = h.enum.UserInputType.Touch }
	h.button.InputBegan:Fire(touch)
	h.action.state = true
	h.action.Pressed:Fire()
	assert(h.activations() == 1, "GUI binding submits once")
	h.router.setMode("Capture")
	h.action.state = false
	h.action.Released:Fire()
	h.input.InputEnded:Fire(touch)
	local nextTouch = { UserInputType = h.enum.UserInputType.Touch }
	h.button.InputBegan:Fire(nextTouch)
	h.action.state = true
	h.action.Pressed:Fire()
	assert(h.activations() == 2, "released pointer permits a new capture gesture")
	h.input.WindowFocusReleased:Fire()
	nextTouch.UserInputState = h.enum.UserInputState.Cancel
	h.action.state = false
	h.input.WindowFocused:Fire()
	h.press()
	assert(h.activations() == 3, "cancelled touch cannot latch input after focus restoration")
	h.router.stop()
end

return {
	heldGestureCannotActivateNextStage = heldGestureCannotActivateNextStage,
	blockedFocusAndMenusRequireFreshGesture = blockedFocusAndMenusRequireFreshGesture,
	deviceSwitchOnlyUpdatesBindingText = deviceSwitchOnlyUpdatesBindingText,
	nativeBindingsAndLifecycleAreSingleOwner = nativeBindingsAndLifecycleAreSingleOwner,
	pointerReleaseNeutralizesHandoff = pointerReleaseNeutralizesHandoff,
}
