--!strict

local shared = game:GetService("ReplicatedStorage").MonsterVault.Shared
local Controller = require(script.Parent.Parent.controllers.VaultAssignmentController)
local Projection = require(shared.contracts.VaultAssignmentProjectionV1)
local Routes = require(shared.contracts.RouteIds)
local Fixture = require(shared.config.VaultProductionFixture)
local VaultAssignmentRuntimeService = {}
function VaultAssignmentRuntimeService.new(
	options: { networking: any, player: any, guiService: any }
)
	local globals = getfenv() :: any
	local screen, panel, summary, message: any = nil, nil, nil, nil
	local rows: { any } = {}
	local buttons: { any } = {}
	local connections: { any } = {}
	local running, expanded = false, false
	local unsubscribe: any = nil
	local function enable(button: any, value: boolean)
		button.Active, button.Interactable, button.Selectable = value, value, value
		button.BackgroundColor3 = if value
			then globals.Color3.fromRGB(20, 118, 77)
			else globals.Color3.fromRGB(67, 79, 75)
	end
	local controller = Controller.new({
		gateway = options.networking.gateway,
		routes = Routes,
		projection = Projection,
		sessionReady = function()
			local session = options.networking.store.view()
			return session ~= nil and session.status == "Ready"
		end,
		clock = os.clock,
		onChanged = function(state)
			if screen == nil then
				return
			end
			panel.Visible = expanded
			local data = if state.snapshot then state.snapshot.state else nil
			summary.Text = if data
				then string.format(
					"Saved output %.3f / %.3f | Offline +%.3f",
					data.bufferMilli / 1000,
					data.bufferCapacityMilli / 1000,
					data.offlineCreditedMilli / 1000
				)
				else "Vault output loading..."
			message.Text = state.message
			for index, row in rows do
				local entry = if data then data.creatures[index] else nil
				row.Visible = entry ~= nil
				row.Text = if entry
					then (if state.selected == entry.creatureInstanceId then "> " else "")
						.. entry.creatureInstanceId
						.. "\n"
						.. (if entry.overflowHeld
							then "Overflow-Held"
							else if entry.productionSlotId then "Active" else "Stored")
						.. (if entry.productionSlotId then " | " .. entry.productionSlotId else "")
						.. (if entry.displaySlotId then " | " .. entry.displaySlotId else "")
					else ""
				enable(row, entry ~= nil and not entry.overflowHeld and not state.pending)
			end
			for _, entry in buttons do
				local count = if data then data[entry.kind .. "SlotCount"] else 0
				entry.button.Visible = entry.index <= count
				enable(entry.button, state.canAssign)
			end
		end,
	})
	local function start()
		assert(not running, "assignment UI one-shot")
		running = true
		local Instance, UDim2, Enum = globals.Instance, globals.UDim2, globals.Enum
		screen = Instance.new("ScreenGui")
		screen.Name, screen.ResetOnSpawn, screen.DisplayOrder = "MonsterVaultAssignments", false, 8
		screen.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
		local toggle = Instance.new("TextButton")
		toggle.Name, toggle.Text, toggle.Size, toggle.Position =
			"Toggle", "Manage Vault", UDim2.fromOffset(150, 36), UDim2.fromOffset(12, 12)
		toggle.Parent = screen
		table.insert(
			connections,
			toggle.Activated:Connect(function()
				expanded = not expanded
				panel.Visible = expanded
			end)
		)
		panel = Instance.new("ScrollingFrame")
		panel.Name, panel.Position, panel.Size =
			"Panel", UDim2.fromOffset(12, 52), UDim2.new(0.72, 0, 0.65, -52)
		panel.AutomaticCanvasSize, panel.CanvasSize, panel.ScrollBarThickness =
			Enum.AutomaticSize.Y, UDim2.new(), 4
		panel.BackgroundColor3, panel.Visible, panel.Parent =
			globals.Color3.fromRGB(18, 31, 28), false, screen
		local size = Instance.new("UISizeConstraint")
		size.MaxSize, size.Parent = globals.Vector2.new(340, 580), panel
		local layout = Instance.new("UIListLayout")
		layout.Padding, layout.SortOrder, layout.Parent =
			globals.UDim.new(0, 6), Enum.SortOrder.LayoutOrder, panel
		local order = 0
		local function item(class: string, name: string, text: string, height: number): any
			order += 1
			local object = Instance.new(class)
			object.Name, object.Text, object.LayoutOrder = name, text, order
			object.Size, object.Font, object.TextSize =
				UDim2.new(1, -8, 0, height), Enum.Font.Gotham, 14
			object.TextColor3, object.TextWrapped, object.Parent =
				globals.Color3.new(1, 1, 1), true, panel
			return object
		end
		summary = item("TextLabel", "Output", "", 44)
		message = item("TextLabel", "Message", "", 44)
		summary.BackgroundTransparency, message.BackgroundTransparency = 1, 1
		for index = 1, 2 do
			local row = item("TextButton", "Creature" .. index, "", 64)
			rows[index] = row
			table.insert(
				connections,
				row.Activated:Connect(function()
					local state = controller.view()
					if state.snapshot and state.snapshot.state.creatures[index] then
						controller.selectCreature(
							state.snapshot.state.creatures[index].creatureInstanceId
						)
					end
				end)
			)
		end
		for _, kind in { "production", "display" } do
			for index, slot in Fixture[kind .. "SlotIds"] do
				local button = item(
					"TextButton",
					kind .. index,
					(if kind == "production" then "Production slot " else "Display slot ") .. index,
					36
				)
				table.insert(buttons, { button = button, kind = kind, index = index })
				table.insert(
					connections,
					button.Activated:Connect(function()
						controller.assign(kind, slot)
					end)
				)
			end
		end
		local first, nextPage =
			item("TextButton", "FirstPage", "First page", 36),
			item("TextButton", "NextPage", "Next page", 36)
		table.insert(connections, first.Activated:Connect(controller.firstPage))
		table.insert(connections, nextPage.Activated:Connect(controller.nextPage))
		screen.Parent = options.player:WaitForChild("PlayerGui")
		unsubscribe = options.networking.subscribeAssignments(controller.handleSnapshot)
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
		if unsubscribe then
			unsubscribe()
		end
		for _, connection in connections do
			connection:Disconnect()
		end
		if screen then
			if
				options.guiService.SelectedObject
				and options.guiService.SelectedObject:IsDescendantOf(screen)
			then
				options.guiService.SelectedObject = nil
			end
			screen:Destroy()
		end
		return {}
	end
	return {
		id = "vault_assignments_client",
		dependencies = { "networking" },
		start = start,
		stop = stop,
	}
end
return VaultAssignmentRuntimeService
