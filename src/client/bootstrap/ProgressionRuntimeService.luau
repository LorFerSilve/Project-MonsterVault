--!strict

local shared = game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts
local Controller = require(script.Parent.Parent.controllers.ProgressionController)
local Projection = require(shared.ProgressionProjectionV1)
local Routes = require(shared.RouteIds)
local ProgressionRuntimeService = {}
function ProgressionRuntimeService.new(options: { networking: any, player: any, guiService: any })
	local globals = getfenv() :: any
	local screen, panel, summary, message, review, confirm, cancel: any =
		nil, nil, nil, nil, nil, nil, nil
	local previous, nextButton: any = nil, nil
	local running, expanded = false, false
	local connections, unsubscribe = {}, nil :: any
	local function enable(button: any, enabled: boolean)
		button.Active, button.Interactable, button.Selectable = enabled, enabled, enabled
		button.BackgroundColor3 = if enabled
			then globals.Color3.fromRGB(20, 118, 77)
			else globals.Color3.fromRGB(67, 79, 75)
	end
	local controller = Controller.new({
		gateway = options.networking.gateway,
		routes = Routes,
		projection = Projection,
		catalog = require(
			game:GetService("ReplicatedStorage").MonsterVault.Shared.config.ProgressionFixture
		).definitions,
		clock = os.clock,
		sessionReady = function()
			local state = options.networking.store.view()
			return state ~= nil and state.status == "Ready"
		end,
		onChanged = function(state)
			if screen == nil then
				return
			end
			local s = if state.snapshot then state.snapshot.state else nil
			summary.Text = if s
				then string.format(
					"Energy %d | Collection capacity %d\n%s",
					s.energyUnits,
					s.collectionCapacity,
					s.label
						.. (
							if s.owned
								then " | Owned"
								else if s.gateReason == "INVALID_UNLOCK_LEVEL"
									then " | Previous tier required"
									else if s.gateReason ~= ""
										then " | Active milestone required"
										else ""
						)
				)
				else "Loading progression..."
			message.Text = state.message
			confirm.Text = if state.reviewed
				then string.format("Confirm: %d Energy", state.reviewed.priceUnits)
				else "Confirm purchase"
			enable(review, state.canReview)
			enable(confirm, state.canConfirm)
			enable(cancel, not state.pending)
			enable(previous, state.canNavigate and s ~= nil and s.catalogIndex > 1)
			enable(nextButton, state.canNavigate and s ~= nil and s.catalogIndex < s.catalogSize)
		end,
	})
	return {
		id = "progression_client",
		dependencies = { "networking" },
		start = function()
			running = true
			local Instance, UDim2, Enum = globals.Instance, globals.UDim2, globals.Enum
			screen = Instance.new("ScreenGui")
			screen.Name, screen.ResetOnSpawn, screen.DisplayOrder =
				"MonsterVaultProgression", false, 9
			screen.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
			local toggle = Instance.new("TextButton")
			toggle.Name, toggle.Text, toggle.Size, toggle.Position =
				"Toggle", "Progression", UDim2.fromOffset(150, 36), UDim2.new(1, -162, 0, 12)
			toggle.Parent = screen
			panel = Instance.new("Frame")
			panel.Name, panel.Size, panel.Position =
				"Panel", UDim2.new(0.7, 0, 0, 370), UDim2.new(1, -12, 0, 52)
			panel.AnchorPoint, panel.Visible, panel.Parent =
				globals.Vector2.new(1, 0), false, screen
			panel.BackgroundColor3 = globals.Color3.fromRGB(18, 31, 28)
			local size = Instance.new("UISizeConstraint")
			size.MaxSize, size.Parent = globals.Vector2.new(320, 370), panel
			local layout = Instance.new("UIListLayout")
			layout.Padding, layout.SortOrder, layout.Parent =
				globals.UDim.new(0, 6), Enum.SortOrder.LayoutOrder, panel
			local function item(
				class: string,
				name: string,
				text: string,
				order: number,
				height: number
			): any
				local object = Instance.new(class)
				object.Name, object.Text, object.LayoutOrder, object.Size =
					name, text, order, UDim2.new(1, -8, 0, height)
				object.Font, object.TextSize, object.TextColor3, object.TextWrapped =
					Enum.Font.Gotham, 14, globals.Color3.new(1, 1, 1), true
				object.Parent = panel
				return object
			end
			summary = item("TextLabel", "Summary", "", 1, 76)
			message = item("TextLabel", "Message", "", 2, 54)
			summary.BackgroundTransparency, message.BackgroundTransparency = 1, 1
			review = item("TextButton", "Review", "Review upgrade", 3, 36)
			confirm = item("TextButton", "Confirm", "Confirm purchase", 4, 36)
			cancel = item("TextButton", "Cancel", "Cancel", 5, 36)
			previous = item("TextButton", "Previous", "Previous upgrade", 6, 30)
			nextButton = item("TextButton", "Next", "Next upgrade", 7, 30)
			table.insert(
				connections,
				toggle.Activated:Connect(function()
					expanded = not expanded
					panel.Visible = expanded
				end)
			)
			table.insert(connections, review.Activated:Connect(controller.review))
			table.insert(connections, confirm.Activated:Connect(controller.confirm))
			table.insert(connections, cancel.Activated:Connect(controller.cancel))
			table.insert(connections, previous.Activated:Connect(controller.previous))
			table.insert(connections, nextButton.Activated:Connect(controller.next))
			screen.Parent = options.player:WaitForChild("PlayerGui")
			unsubscribe = options.networking.subscribeProgression(controller.handleSnapshot)
			controller.tick()
			globals.task.spawn(function()
				while running do
					globals.task.wait(0.5)
					if running then
						controller.tick()
					end
				end
			end)
		end,
		stop = function(): { string }
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
		end,
	}
end
return ProgressionRuntimeService
