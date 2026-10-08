--!strict

local shared = game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts
local VaultController = require(script.Parent.Parent.controllers.VaultController)
local VaultProjectionV1 = require(shared.VaultProjectionV1)
local RouteIds = require(shared.RouteIds)
local VaultRuntimeService = {}

function VaultRuntimeService.new(options: {
	networking: any,
	player: any,
	guiService: any,
	golden: boolean?,
})
	local globals = getfenv() :: any
	local screen: any = nil
	local panel: any = nil
	local unsubscribe: any = nil
	local running = false
	local connections: { any } = {}
	local heading: any = nil
	local message: any = nil
	local rows: { any } = {}
	local resolveButton: any = nil
	local firstButton: any = nil
	local nextButton: any = nil
	local function enabled(button: any, active: boolean)
		button.Active, button.Interactable, button.Selectable = active, active, active
		button.BackgroundColor3 = if active
			then globals.Color3.fromRGB(30, 41, 49)
			else globals.Color3.fromRGB(59, 73, 77)
	end
	local controller = VaultController.new({
		gateway = options.networking.gateway,
		routes = RouteIds,
		projection = VaultProjectionV1,
		sessionReady = function()
			local state = options.networking.store.view()
			return state ~= nil and state.status == "Ready"
		end,
		clock = os.clock,
		onChanged = function(state)
			if screen == nil then
				return
			end
			local data = if state.snapshot ~= nil then state.snapshot.state else nil
			if not options.golden then
				panel.Size = if data ~= nil and data.overflowHeldCount == 0
					then globals.UDim2.new(0.72, 0, 0, 110)
					else globals.UDim2.fromScale(0.72, 0.6)
			end
			heading.Text = if data ~= nil
				then string.format(
					"Collection %d / %d   |   Overflow %d",
					data.ordinaryUsed,
					data.capacity,
					data.overflowHeldCount
				)
				else "Collection"
			message.Text = state.message
			for index, row in rows do
				local id = if data ~= nil then data.overflowCreatureInstanceIds[index] else nil
				row.Visible = id ~= nil
				row.Text = if id == nil
					then ""
					else (if state.selected == id then "> " else "") .. id
				enabled(row, id ~= nil and not state.pending)
			end
			resolveButton.Visible = data ~= nil and data.overflowHeldCount > 0
			resolveButton.Text = if state.pending
				then "Checking saved result..."
				else "Move selected to Stored"
			enabled(resolveButton, state.canResolve)
			firstButton.Visible, nextButton.Visible = resolveButton.Visible, resolveButton.Visible
			enabled(firstButton, not state.pending)
			enabled(nextButton, not state.pending and data ~= nil and data.hasMore)
		end,
	})
	local function start()
		assert(not running and screen == nil, "Vault client is one-shot")
		running = true
		local Instance, Enum, UDim2 = globals.Instance, globals.Enum, globals.UDim2
		screen = Instance.new("ScreenGui")
		screen.Name = "MonsterVaultOverflow"
		screen.ResetOnSpawn = false
		screen.DisplayOrder = 9
		screen.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
		panel = Instance.new("ScrollingFrame")
		panel.Name = "Panel"
		panel.AnchorPoint = globals.Vector2.new(1, 1)
		panel.Position = UDim2.new(1, -12, 1, -12)
		panel.Size = UDim2.fromScale(0.72, 0.6)
		panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
		panel.CanvasSize = UDim2.new()
		panel.BackgroundColor3 = globals.Color3.fromRGB(18, 31, 28)
		panel.BorderSizePixel = 0
		panel.ScrollBarThickness = 4
		panel.Parent = screen
		local constraint = Instance.new("UISizeConstraint")
		constraint.MaxSize = globals.Vector2.new(340, 430)
		constraint.Parent = panel
		local padding = Instance.new("UIPadding")
		padding.PaddingTop, padding.PaddingBottom = globals.UDim.new(0, 10), globals.UDim.new(0, 10)
		padding.PaddingLeft, padding.PaddingRight = globals.UDim.new(0, 10), globals.UDim.new(0, 10)
		padding.Parent = panel
		local layout = Instance.new("UIListLayout")
		layout.Padding = globals.UDim.new(0, 6)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = panel
		local function item(class: string, name: string, order: number, height: number): any
			local obj = Instance.new(class)
			obj.Name, obj.LayoutOrder = name, order
			obj.Size = UDim2.new(1, -4, 0, height)
			obj.Font, obj.TextSize = Enum.Font.Gotham, 14
			obj.TextColor3 = globals.Color3.new(1, 1, 1)
			obj.TextWrapped = true
			obj.BorderSizePixel = 0
			obj.Parent = panel
			return obj
		end
		heading = item("TextLabel", "Heading", 1, 36)
		message = item("TextLabel", "Message", 2, 44)
		heading.BackgroundTransparency, message.BackgroundTransparency = 1, 1
		for index = 1, 5 do
			local row = item("TextButton", "Creature" .. tostring(index), index + 2, 40)
			rows[index] = row
			table.insert(
				connections,
				row.Activated:Connect(function()
					local state = controller.view()
					if state.snapshot ~= nil then
						local id = state.snapshot.state.overflowCreatureInstanceIds[index]
						if id ~= nil then
							controller.selectCreature(id)
						end
					end
				end)
			)
		end
		resolveButton = item("TextButton", "Resolve", 8, 44)
		firstButton = item("TextButton", "FirstPage", 9, 36)
		nextButton = item("TextButton", "NextPage", 10, 36)
		firstButton.Text, nextButton.Text = "First page", "Next page"
		table.insert(
			connections,
			resolveButton.Activated:Connect(function()
				controller.resolve()
			end)
		)
		table.insert(connections, firstButton.Activated:Connect(controller.firstPage))
		table.insert(connections, nextButton.Activated:Connect(controller.nextPage))
		screen.Parent = options.player:WaitForChild("PlayerGui")
		unsubscribe = options.networking.subscribeVault(controller.handleSnapshot)
		controller.tick()
		globals.task.spawn(function()
			while running do
				globals.task.wait(0.5)
				if running then
					controller.tick()
				end
			end
		end)
	end
	local function stop(): { string }
		running = false
		if unsubscribe ~= nil then
			unsubscribe()
		end
		for _, connection in connections do
			connection:Disconnect()
		end
		if screen ~= nil then
			if
				options.guiService.SelectedObject ~= nil
				and options.guiService.SelectedObject:IsDescendantOf(screen)
			then
				options.guiService.SelectedObject = nil
			end
			screen:Destroy()
		end
		return {}
	end
	return {
		id = "vault_client",
		dependencies = { "networking" },
		start = start,
		stop = stop,
		view = controller.view,
		ui = function()
			return screen, panel
		end,
		open = function(value: boolean)
			if panel then
				panel.Visible = value
			end
		end,
	}
end
return VaultRuntimeService
