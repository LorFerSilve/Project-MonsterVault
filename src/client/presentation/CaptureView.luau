--!strict

-- Static semantic feedback uses the same native components as the Golden HUD.
local CaptureView = {}
local Theme = require(script.Parent.GoldenTheme)

function CaptureView.new(options: {
	parent: any,
	guiService: any,
	userInputService: any,
	modalOpen: (() -> boolean)?,
})
	local globals = getfenv() :: any
	local Instance, Enum, Vector2 = globals.Instance, globals.Enum, globals.Vector2
	local UDim2, UDim = globals.UDim2, globals.UDim
	local screen = Instance.new("ScreenGui")
	screen.Name = "MonsterVaultCapture"
	screen.ResetOnSpawn = false
	screen.DisplayOrder = 10
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 1)
	panel.Position = UDim2.new(0.5, 0, 1, -76)
	panel.Size = UDim2.fromScale(0.86, 0)
	panel.AutomaticSize = Enum.AutomaticSize.Y
	Theme.panel(panel)
	panel.Parent = screen
	local constraint = Instance.new("UISizeConstraint")
	constraint.MaxSize = Vector2.new(420, math.huge)
	constraint.Parent = panel
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 12)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.PaddingLeft = UDim.new(0, 14)
	padding.PaddingRight = UDim.new(0, 14)
	padding.Parent = panel
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = panel
	local function label(name: string, order: number, textSize: number): any
		local item = Instance.new("TextLabel")
		item.Name = name
		item.LayoutOrder = order
		Theme.text(item, textSize, order == 1)
		item.Size = UDim2.fromScale(1, 0)
		item.AutomaticSize = Enum.AutomaticSize.Y
		item.Parent = panel
		return item
	end
	local heading = label("Heading", 1, 20)
	local body = label("Message", 2, 16)
	local button = Instance.new("TextButton")
	button.Name = "Action"
	button.LayoutOrder = 3
	button.Size = UDim2.new(1, 0, 0, 52)
	Theme.button(button, true)
	button:SetAttribute("GoldenPrimary", true)
	button.TextSize = 18
	button.AutomaticSize = Enum.AutomaticSize.Y
	button.Parent = panel
	local glyph = "E"
	local latest: any = nil
	local stopped = false
	local terminalKey: string? = nil
	local terminalTask: any = nil
	local function cancelTerminal()
		if terminalTask then
			globals.task.cancel(terminalTask)
			terminalTask = nil
		end
	end

	local function render(state: any)
		if stopped then
			return
		end
		latest = state
		panel.Visible = state.state ~= "Idle" or state.canActivate
		local terminal = state.state == "Secured"
			or state.state == "Failed"
			or state.state == "Interrupted"
			or state.state == "Expired"
		local key = if terminal and not state.canActivate
			then state.state .. ":" .. tostring(state.creatureInstanceId)
			else nil
		if key ~= terminalKey then
			cancelTerminal()
			terminalKey = key
			if key then
				terminalTask = globals.task.delay(5, function()
					terminalTask = nil
					if not stopped and terminalKey == key then
						panel.Visible = false
					end
				end)
			end
		elseif key and terminalTask == nil then
			panel.Visible = false
		end
		heading.Text = state.heading
		body.Text = state.message
		if state.state == "Idle" and state.canActivate then
			heading.Text = "Creature within reach"
			body.Text = "Engage the creature, then bring your catch back to the Field Station."
		end
		button.Text = "[" .. glyph .. "] " .. state.actionLabel
		if not state.canActivate then
			button.Text = if state.state == "TransportActive"
				then "Return to safety"
				elseif state.state == "FinalizationPending" then "Saving..."
				elseif state.state == "Secured" then "Saved to Collection"
				else "Awaiting capture"
		end
		Theme.enabled(button, state.canActivate)
		if state.canActivate then
			Theme.button(button, true)
		end
		Theme.inputGlyph(button, glyph, state.canActivate)
		-- Only claim otherwise-unowned gamepad focus. Existing UI keeps its focus.
		local gamepad = options.userInputService.PreferredInput == Enum.PreferredInput.Gamepad
		if
			options.guiService.SelectedObject == button and (not state.canActivate or not gamepad)
		then
			options.guiService.SelectedObject = nil
		elseif
			gamepad
			and state.canActivate
			and options.guiService.SelectedObject == nil
			and not options.guiService.MenuIsOpen
			and not (options.modalOpen and options.modalOpen())
		then
			options.guiService.SelectedObject = button
		end
	end
	screen.Parent = options.parent
	return {
		button = button,
		render = render,
		setGlyph = function(value: string)
			glyph = value
			if latest ~= nil then
				render(latest)
			end
		end,
		stop = function()
			if stopped then
				return
			end
			stopped = true
			cancelTerminal()
			if options.guiService.SelectedObject == button then
				options.guiService.SelectedObject = nil
			end
			screen:Destroy()
		end,
	}
end

return CaptureView
