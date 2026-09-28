--!strict

-- One static, text-led panel: no animation, camera takeover or sound-only cues.
local CaptureView = {}

function CaptureView.new(options: { parent: any, guiService: any, userInputService: any })
	local globals = getfenv() :: any
	local Instance, Enum, Vector2 = globals.Instance, globals.Enum, globals.Vector2
	local UDim2, UDim, Color3 = globals.UDim2, globals.UDim, globals.Color3
	local screen = Instance.new("ScreenGui")
	screen.Name = "MonsterVaultCapture"
	screen.ResetOnSpawn = false
	screen.DisplayOrder = 10
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0)
	panel.Position = UDim2.new(0.5, 0, 0, 12)
	panel.Size = UDim2.fromScale(0.86, 0)
	panel.AutomaticSize = Enum.AutomaticSize.Y
	panel.BackgroundColor3 = Color3.fromRGB(18, 31, 28)
	panel.BorderSizePixel = 0
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
		item.BackgroundTransparency = 1
		item.Size = UDim2.fromScale(1, 0)
		item.AutomaticSize = Enum.AutomaticSize.Y
		item.Font = if order == 1 then Enum.Font.GothamBold else Enum.Font.Gotham
		item.TextSize = textSize
		item.TextColor3 = Color3.fromRGB(246, 250, 248)
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.TextWrapped = true
		item.Parent = panel
		return item
	end
	local heading = label("Heading", 1, 20)
	local body = label("Message", 2, 16)
	local button = Instance.new("TextButton")
	button.Name = "Action"
	button.LayoutOrder = 3
	button.Size = UDim2.new(1, 0, 0, 52)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 18
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextWrapped = true
	button.BorderSizePixel = 0
	button.Parent = panel
	local glyph = "E"
	local latest: any = nil
	local stopped = false

	local function render(state: any)
		if stopped then
			return
		end
		latest = state
		heading.Text = state.heading
		body.Text = state.message
		button.Text = "[" .. glyph .. "] " .. state.actionLabel
		button.Active = state.canActivate
		button.Interactable = state.canActivate
		button.Selectable = state.canActivate
		button.BackgroundColor3 = if state.canActivate
			then Color3.fromRGB(20, 118, 77)
			else Color3.fromRGB(67, 79, 75)
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
			if options.guiService.SelectedObject == button then
				options.guiService.SelectedObject = nil
			end
			screen:Destroy()
		end,
	}
end

return CaptureView
