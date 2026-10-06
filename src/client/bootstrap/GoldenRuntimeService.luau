--!strict
-- The Golden Slice consumes validated views and reuses the existing controls.
local globals: any = getfenv()
local Instance, Enum, UDim2, UDim, Vector2 =
	globals.Instance, globals.Enum, globals.UDim2, globals.UDim, globals.Vector2
local Theme = require(script.Parent.Parent.presentation.GoldenTheme)
local Sensory = require(script.Parent.Parent.presentation.GoldenSensory)
local Visuals = require(script.Parent.Parent.presentation.GoldenCreatureVisuals)
local Feedback = require(script.Parent.Parent.presentation.GoldenFeedback)
local Preferences = require(script.Parent.Parent.presentation.PresentationPreferences)
local Seasonal = require(script.Parent.Parent.presentation.SeasonalPresentation)
local Routes = require(game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts.RouteIds)
local Golden = {}
function Golden.new(options: any)
	local gui: any = nil
	local playerGui: any = nil
	local sensory: any = nil
	local visuals: any = nil
	local wallet, objective, toast, brand: any = nil, nil, nil, nil
	local running = false
	local current: string? = nil
	local windows: { [string]: any } = {}
	local nav: { [string]: any } = {}
	local hud: { any } = {}
	local refreshHud: any = nil
	local connections: { any } = {}
	local unsubscribe: any = nil
	local lastFacts: any = nil
	local lastCapture: any = nil
	local lastRows = ""
	local preferenceBinding: any = nil
	local seasonal: any = nil
	local focusReturn: any = nil
	local assignmentCurrent = false
	local travelRequest: string? = nil
	local toastTicket = 0
	local feedback = Feedback.new()
	local preferences = {
		reducedMotion = false,
		lowEffects = game:GetService("UserInputService").TouchEnabled,
		audio = true,
		effectsAudio = true,
		ambienceAudio = true,
	}
	local function text(
		parent: any,
		name: string,
		content: string,
		size: number,
		bold: boolean?
	): any
		local p = Instance.new("TextLabel")
		p.Name, p.Text, p.Parent = name, content, parent
		Theme.text(p, size, bold)
		return p
	end
	local function button(parent: any, name: string, content: string, action: () -> ()): any
		local p = Instance.new("TextButton")
		p.Name, p.Text, p.Parent = name, content, parent
		Theme.button(p)
		table.insert(
			connections,
			p.Activated:Connect(function()
				if sensory then
					sensory.play("UI", 0.1)
				end
				action()
			end)
		)
		return p
	end
	local function notify(message: string)
		if not running then
			return
		end
		toastTicket += 1
		local ticket = toastTicket
		toast.Text, toast.Visible = message, true
		globals.task.delay(4, function()
			if running and ticket == toastTicket then
				toast.Visible = false
			end
		end)
	end
	local function open(name: string?)
		local guiService = game:GetService("GuiService")
		if
			name
			and (guiService.MenuIsOpen or game:GetService("UserInputService"):GetFocusedTextBox())
		then
			return
		end
		if name and current == nil then
			focusReturn = guiService.SelectedObject or nav[name]
		end
		current = name
		for _, item in hud do
			item.Visible = name == nil
		end
		if refreshHud then
			refreshHud()
		end
		for key, window in windows do
			window.frame.Visible = key == name
			if window.service then
				window.service.open(key == name)
			end
		end
		playerGui:SetAttribute("GoldenModalOpen", name ~= nil)
		local captureGui = playerGui:FindFirstChild("MonsterVaultCapture")
		if captureGui then
			captureGui.Enabled = name == nil
		end
		if
			name
			and windows[name]
			and (
				game:GetService("UserInputService").PreferredInput
					== Enum.PreferredInput.Gamepad
				or guiService.SelectedObject ~= nil
			)
		then
			guiService.SelectedObject = windows[name].close
		elseif
			guiService.SelectedObject and guiService.SelectedObject:IsDescendantOf(playerGui)
		then
			guiService.SelectedObject = if focusReturn
					and focusReturn.Parent
					and focusReturn:IsA("GuiButton")
					and focusReturn.Selectable
				then focusReturn
				else nil
		end
	end
	local function window(name: string, title: string, service: any?): any
		local screen, panel
		if service then
			screen, panel = service.ui()
			screen.DisplayOrder = gui.DisplayOrder + 1
		else
			screen = gui
			panel = Instance.new("Frame")
			panel.Parent = screen
		end
		for _, child in screen:GetChildren() do
			if child:IsA("TextButton") then
				child.Visible = false
			end
		end
		local frame = Instance.new("Frame")
		frame.Name, frame.AnchorPoint, frame.Size, frame.Position =
			"GoldenWindow_" .. name,
			Vector2.new(0.5, 0.5),
			UDim2.fromScale(0.94, 0.76),
			UDim2.fromScale(0.5, 0.5)
		frame.Visible, frame.Parent = false, screen
		Theme.panel(frame)
		local size = Instance.new("UISizeConstraint")
		size.MaxSize, size.Parent = Vector2.new(560, 670), frame
		local function fitWindow()
			local camera = workspace.CurrentCamera
			frame.Size = if camera and camera.ViewportSize.Y < 500
				then UDim2.new(0.94, 0, 1, -24)
				else UDim2.fromScale(0.94, 0.76)
		end
		local camera = workspace.CurrentCamera
		if camera then
			table.insert(
				connections,
				camera:GetPropertyChangedSignal("ViewportSize"):Connect(fitWindow)
			)
		end
		fitWindow()
		local heading = text(frame, "Title", title, 23, true)
		heading.Size, heading.Position = UDim2.new(1, -90, 0, 46), UDim2.fromOffset(18, 10)
		local close = button(frame, "Close", "×", function()
			open(nil)
		end)
		close.Size, close.Position = UDim2.fromOffset(48, 48), UDim2.new(1, -64, 0, 12)
		local body = Instance.new("ScrollingFrame")
		body.Name, body.Size, body.Position =
			"WindowBody", UDim2.new(1, -32, 1, -82), UDim2.fromOffset(16, 66)
		body.BackgroundTransparency, body.BorderSizePixel, body.ScrollBarThickness = 1, 0, 4
		body.AutomaticCanvasSize, body.CanvasSize, body.Parent =
			Enum.AutomaticSize.Y, UDim2.new(), frame
		heading.AutomaticSize = Enum.AutomaticSize.Y
		local function fitHeader()
			local top = math.max(66, heading.AbsoluteSize.Y + 24)
			body.Position, body.Size = UDim2.fromOffset(16, top), UDim2.new(1, -32, 1, -top - 16)
		end
		table.insert(
			connections,
			heading:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitHeader)
		)
		panel.Parent, panel.Position, panel.AnchorPoint = body, UDim2.new(), Vector2.zero
		panel.Size, panel.BackgroundTransparency, panel.BorderSizePixel =
			UDim2.new(1, -8, 0, 450), 1, 0
		for _, child in panel:GetChildren() do
			if child:IsA("UISizeConstraint") then
				child:Destroy()
			end
		end
		if panel:IsA("ScrollingFrame") then
			panel.ScrollingEnabled = false
			panel.AutomaticCanvasSize = Enum.AutomaticSize.None
			panel.CanvasSize = UDim2.new()
		end
		local function styleItem(p: any)
			if p:IsA("TextButton") then
				Theme.button(p)
				p.Size = UDim2.new(1, -8, 0, math.max(48, p.Size.Y.Offset))
				p.AutomaticSize = Enum.AutomaticSize.Y
			elseif p:IsA("TextLabel") then
				Theme.text(p, 16)
				p.TextColor3 = Theme.colors.muted
				p.AutomaticSize = Enum.AutomaticSize.Y
			elseif p:IsA("TextBox") then
				Theme.button(p)
				p.TextSize = 16
				p.Size = UDim2.new(1, -8, 0, 48)
			end
		end
		for _, p in panel:GetChildren() do
			styleItem(p)
		end
		table.insert(connections, panel.ChildAdded:Connect(styleItem))
		local layout = panel:FindFirstChildOfClass("UIListLayout")
		if layout then
			local function fit()
				panel.Size = UDim2.new(1, -8, 0, layout.AbsoluteContentSize.Y + 12)
			end
			table.insert(
				connections,
				layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fit)
			)
			fit()
		else
			-- Social owns its bounded layout and expiration timer.
			if panel:IsA("ScrollingFrame") then
				local function fit()
					panel.Size = UDim2.new(1, -8, 0, panel.CanvasSize.Y.Offset + 8)
				end
				table.insert(connections, panel:GetPropertyChangedSignal("CanvasSize"):Connect(fit))
			end
		end
		windows[name] = { frame = frame, close = close, panel = panel, service = service }
		if service then
			service.open(false)
		end
		return panel
	end
	local function update()
		if not running then
			return
		end
		local session = options.networking.store.view()
		local ready = session and session.status == "Ready"
		if not ready then
			assignmentCurrent = false
			lastCapture = nil
			lastFacts = nil
			feedback.reset()
		end
		local av = options.assignments.view()
		local data = ready
			and assignmentCurrent
			and av.snapshot
			and av.snapshot.revision == session.profileRevision
			and av.snapshot.state
		if data then
			sensory.production(data)
			sensory.balance(data.energyUnits)
			local signature = ""
			for _, row in data.creatures do
				signature ..= row.creatureInstanceId .. ":" .. tostring(row.displaySlotId) .. ":" .. tostring(
					row.productionSlotId
				) .. ":" .. tostring(row.speciesId) .. ":" .. tostring(row.rarityId) .. ";"
			end
			local displayRows: { any } = if data.displayCard then { data.displayCard } else {}
			for _, row in displayRows do
				signature ..= "display:" .. row.creatureInstanceId .. ":" .. row.displaySlotId .. ":" .. row.speciesId .. ":" .. row.speciesRarityId .. ":" .. table.concat(
					row.mutationIds,
					","
				) .. ":" .. table.concat(row.traitIds, ",")
			end
			if signature ~= lastRows then
				visuals.owned(displayRows)
				options.showcase.preview(displayRows)
				lastRows = signature
				local collectionPanel = windows.Collection.panel
				for _, child in collectionPanel:GetChildren() do
					if child.Name == "CreatureCard" then
						child:Destroy()
					end
				end
				for i, row in data.creatures do
					local facts = row
					if
						data.displayCard
						and data.displayCard.creatureInstanceId == row.creatureInstanceId
					then
						facts = table.clone(data.displayCard)
						facts.productionSlotId = row.productionSlotId
					end
					local card = Theme.card(collectionPanel, facts, false)
					card.LayoutOrder = 100 + i
				end
			end
			local panel = windows.Vault.panel
			local collectionPanel = windows.Collection.panel
			local capacityView = options.vault.view().snapshot
			local overflow = capacityView and capacityView.state.overflowHeldCount > 0
			for _, name in { "Resolve", "FirstPage", "NextPage" } do
				local control = collectionPanel:FindFirstChild(name)
				if control then
					control.Visible = overflow == true
				end
			end
			if not overflow and capacityView then
				collectionPanel.Message.Text =
					"Saved creatures. Open Vault to assign a display or produce Energy."
			end
			collectionPanel.OwnedNext.Visible = data.hasMore
			for i = 1, 2 do
				local row = data.creatures[i]
				local control = panel:FindFirstChild("Creature" .. i)
				if control then
					local portrait = control:FindFirstChild("CreaturePortrait")
					local identity = row
						and row.speciesId
						and row.creatureInstanceId
							.. ":"
							.. row.speciesId
							.. ":"
							.. row.rarityId
					if portrait and portrait:GetAttribute("Identity") ~= identity then
						portrait:Destroy()
						portrait = nil
					end
					if identity and not portrait then
						if portrait then
							portrait:Destroy()
						end
						portrait = Theme.viewport(control, row.speciesId, row.rarityId)
						portrait:SetAttribute("Identity", identity)
						portrait.Size, portrait.Position =
							UDim2.fromOffset(70, 70), UDim2.fromOffset(6, 5)
					end
					control.Size = UDim2.new(1, -8, 0, 84)
					local pad = control:FindFirstChildOfClass("UIPadding")
						or Instance.new("UIPadding")
					pad.PaddingLeft, pad.PaddingRight, pad.Parent =
						UDim.new(0, 86), UDim.new(0, 8), control
				end
			end
		else
			sensory.production(nil)
			options.showcase.preview({})
			visuals.clear()
			sensory.clear()
			local progression = options.progression.view().snapshot
			if ready and progression and progression.revision == session.profileRevision then
				sensory.balance(progression.state.energyUnits)
			else
				wallet.Text = "◆  —"
			end
			lastRows = ""
			for _, child in windows.Collection.panel:GetChildren() do
				if child.Name == "CreatureCard" then
					child:Destroy()
				end
			end
			for i = 1, 2 do
				local control = windows.Vault.panel:FindFirstChild("Creature" .. i)
				local portrait = control and control:FindFirstChild("CreaturePortrait")
				if portrait then
					portrait:Destroy()
				end
			end
		end
		local collection = options.networking.securedCollectionStore.view()
		local character = options.player.Character
		local body = character and character:FindFirstChild("HumanoidRootPart")
		local home = body and body.Position.Z > 95 and body.Position.Z < 165
		if nav.Home then
			nav.Home.Text = if home then "Explore" else "Home"
		end
		if not ready then
			objective.Text = "CONNECTING TO YOUR VAULT\nSaved progress is being checked."
		elseif
			lastCapture
			and (
				lastCapture.state == "TransportActive"
				or lastCapture.state == "FinalizationPending"
			)
		then
			objective.Text = "BRING IT TO SAFETY\nReturn to the green secure marker."
		elseif not data and av.snapshot then
			objective.Text = "UPDATING YOUR VAULT\nSaved collection and Energy are being refreshed."
		elseif
			(data and #data.creatures > 0) or (collection and #collection.creatureInstanceIds > 0)
		then
			objective.Text = if home
				then "BUILD YOUR VAULT STORY\nDisplay a find, produce Energy, pursue an upgrade."
				else "FIND YOUR NEXT CREATURE\nFollow the meadow path. Secure each capture at the green station."
		elseif home then
			objective.Text =
				"EXPLORE MOSSLINE RESERVE\nFollow the green gate. Travel unlocks after discovering its markers."
		else
			objective.Text = "FIND YOUR FIRST CREATURE\nFollow the path into Mossline Meadow."
		end
	end
	local function start()
		running = true
		playerGui = options.player:WaitForChild("PlayerGui")
		gui = Instance.new("ScreenGui")
		gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = "MonsterVaultGolden", false, 12
		gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
		gui.Parent = playerGui
		local objectivePanel = Instance.new("Frame")
		objectivePanel.Name = "ObjectivePanel"
		Theme.panel(objectivePanel)
		objectivePanel.Size, objectivePanel.Position, objectivePanel.Parent =
			UDim2.new(0.56, -20, 0, 76), UDim2.fromOffset(12, 12), gui
		local limit = Instance.new("UISizeConstraint")
		limit.MaxSize, limit.Parent = Vector2.new(330, 76), objectivePanel
		limit.MaxSize = Vector2.new(330, math.huge)
		objectivePanel.AutomaticSize = Enum.AutomaticSize.Y
		objective = text(objectivePanel, "Objective", "", 14, true)
		objective.Size, objective.Position = UDim2.new(1, -24, 1, -16), UDim2.fromOffset(12, 8)
		objective.Size, objective.AutomaticSize = UDim2.new(1, -24, 0, 60), Enum.AutomaticSize.Y
		local energyPanel = Instance.new("Frame")
		energyPanel.Name = "EnergyPanel"
		Theme.panel(energyPanel)
		energyPanel.AnchorPoint, energyPanel.Size, energyPanel.Position, energyPanel.Parent =
			Vector2.new(1, 0), UDim2.new(0.42, -20, 0, 60), UDim2.new(1, -12, 0, 12), gui
		energyPanel.AutomaticSize = Enum.AutomaticSize.Y
		local cap = Instance.new("UISizeConstraint")
		cap.MaxSize, cap.Parent = Vector2.new(210, math.huge), energyPanel
		wallet = text(energyPanel, "Energy", "◆  —", 24, true)
		wallet.TextColor3 = Theme.colors.energy
		wallet.Size, wallet.Position = UDim2.new(1, -24, 0, 48), UDim2.fromOffset(12, 6)
		wallet.AutomaticSize = Enum.AutomaticSize.Y
		brand = text(gui, "Brand", "M O N S T E R V A U L T", 24, true)
		brand.AnchorPoint = Vector2.new(0.5, 0)
		brand.Size, brand.Position = UDim2.fromOffset(380, 50), UDim2.new(0.5, 0, 0, 16)
		brand.TextXAlignment = Enum.TextXAlignment.Center
		local function responsive()
			local camera = workspace.CurrentCamera
			brand.Visible = current == nil and camera ~= nil and camera.ViewportSize.X > 800
			local captureGui = playerGui:FindFirstChild("MonsterVaultCapture")
			local capture = captureGui and captureGui:FindFirstChild("Panel")
			local reserveCaptureSpace = camera
				and camera.ViewportSize.Y < 500
				and capture
				and capture.Visible
			for _, item in hud do
				item.Visible = current == nil and not reserveCaptureSpace
			end
		end
		local camera = workspace.CurrentCamera
		if camera then
			table.insert(
				connections,
				camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
					if refreshHud then
						refreshHud()
					else
						responsive()
					end
				end)
			)
		end
		responsive()
		toast = text(gui, "RewardToast", "", 20, true)
		toast.AnchorPoint = Vector2.new(0.5, 0)
		toast.Size, toast.Position = UDim2.new(0.86, 0, 0, 84), UDim2.new(0.5, 0, 0, 100)
		toast.TextXAlignment = Enum.TextXAlignment.Center
		toast.Visible = false
		Theme.panel(toast)
		local toastLimit = Instance.new("UISizeConstraint")
		toastLimit.MaxSize, toastLimit.Parent = Vector2.new(560, 84), toast
		toast.AutomaticSize, toastLimit.MaxSize = Enum.AutomaticSize.Y, Vector2.new(560, math.huge)
		sensory = Sensory.new(options.player, preferences, function(value)
			wallet.Text = string.format("◆  %d", value)
		end)
		visuals = Visuals.new(sensory, options.worldObserver)
		preferenceBinding = Preferences.bind(game:GetService("GuiService"), preferences, function()
			sensory.preferencesChanged()
			if seasonal then
				seasonal.preferencesChanged()
			end
			local settingWindow = windows.Settings
			local control = settingWindow and settingWindow.panel:FindFirstChild("ReducedMotion")
			if control then
				control.Text = if preferences.reducedMotion
					then "Reduced Motion · ON"
					else "Reduced Motion · OFF"
			end
		end)
		local seasonalBanner = text(gui, "SeasonalBanner", Seasonal.label, 13, true)
		seasonalBanner.Size, seasonalBanner.Position =
			UDim2.fromOffset(330, 34), UDim2.fromOffset(12, 96)
		seasonalBanner.TextColor3, seasonalBanner.Visible = Seasonal.accent, false
		Theme.panel(seasonalBanner)
		local function fitSeasonalBanner()
			seasonalBanner.Position = UDim2.fromOffset(12, objectivePanel.AbsoluteSize.Y + 20)
			seasonalBanner.Size = UDim2.fromOffset(objectivePanel.AbsoluteSize.X, 34)
		end
		table.insert(
			connections,
			objectivePanel:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitSeasonalBanner)
		)
		fitSeasonalBanner()
		seasonal = Seasonal.new(preferences, function(value: boolean)
			seasonalBanner.Visible = value and current == nil
			sensory.seasonal(value)
		end)
		refreshHud = function()
			responsive()
			seasonalBanner.Visible = current == nil
				and objectivePanel.Visible
				and seasonal.isEnabled()
		end
		window("Vault", "MY VAULT", options.assignments)
		window("Collection", "COLLECTION", options.vault)
		local vaultPanel = windows.Vault.panel
		vaultPanel.ClaimProduction:SetAttribute("GoldenPrimary", true)
		Theme.button(vaultPanel.ClaimProduction, true)
		vaultPanel.ClaimProduction.LayoutOrder = 2
		vaultPanel.Message.LayoutOrder = 3
		local slots = Instance.new("Frame")
		slots.Name, slots.BackgroundTransparency, slots.Size, slots.LayoutOrder, slots.Parent =
			"SlotActions", 1, UDim2.new(1, -8, 0, 152), 8, vaultPanel
		local slotLayout = Instance.new("UIGridLayout")
		slotLayout.CellSize, slotLayout.CellPadding, slotLayout.SortOrder, slotLayout.Parent =
			UDim2.new(0.5, -4, 0, 48), UDim2.fromOffset(8, 8), Enum.SortOrder.LayoutOrder, slots
		slots.Size = UDim2.new(1, -8, 0, 160)
		for _, kind in { "production", "display" } do
			for i = 1, 3 do
				local control = vaultPanel:FindFirstChild(kind .. i)
				if control then
					control.Parent = slots
				end
			end
		end
		vaultPanel.FirstPage.LayoutOrder, vaultPanel.NextPage.LayoutOrder = 9, 10
		local collectionPanel = windows.Collection.panel
		local ownedFirst = button(
			collectionPanel,
			"OwnedFirst",
			"Recent collection",
			options.assignments.firstPage
		)
		local ownedNext =
			button(collectionPanel, "OwnedNext", "More creatures", options.assignments.nextPage)
		ownedFirst.LayoutOrder, ownedNext.LayoutOrder = 200, 201
		ownedFirst.Size, ownedNext.Size = UDim2.new(1, -8, 0, 48), UDim2.new(1, -8, 0, 48)
		window("Journey", "YOUR NEXT ASPIRATION", options.progression)
		window("Showcase", "SHOWCASE", options.showcase)
		local settings = window("Settings", "SENSORY PREFERENCES", nil)
		local layout = Instance.new("UIListLayout")
		layout.Padding, layout.Parent = UDim.new(0, 12), settings
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		local settingOrder = 0
		local function setting(name: string, key: string, onText: string, offText: string)
			local control: any = nil
			control = button(
				settings,
				name,
				if preferences[key] then onText else offText,
				function()
					if key == "reducedMotion" then
						preferenceBinding.toggleReduced()
					else
						preferences[key] = not preferences[key]
					end
					control.Text = if preferences[key] then onText else offText
					sensory.preferencesChanged()
					seasonal.preferencesChanged()
				end
			)
			control.Size = UDim2.new(1, -8, 0, 48)
			settingOrder += 1
			control.LayoutOrder = settingOrder
		end
		setting("ReducedMotion", "reducedMotion", "Reduced Motion · ON", "Reduced Motion · OFF")
		setting("LowEffects", "lowEffects", "Effects · LOW", "Effects · STANDARD")
		setting("Audio", "audio", "Audio · ON", "Audio · OFF")
		setting("EffectsAudio", "effectsAudio", "Sound effects · ON", "Sound effects · OFF")
		setting("AmbienceAudio", "ambienceAudio", "Ambience · ON", "Ambience · OFF")
		if game:GetService("RunService"):IsStudio() then
			local preview: any = nil
			preview = button(
				settings,
				"HalloweenPreview",
				"Halloween art preview · OFF",
				function()
					local nextValue = not seasonal.isEnabled()
					if seasonal.set(nextValue) then
						preview.Text = if nextValue
							then "Halloween art preview · ON"
							else "Halloween art preview · OFF"
					else
						notify("Seasonal presentation assets are unavailable.")
					end
				end
			)
			preview.Size = UDim2.new(1, -8, 0, 48)
			preview.LayoutOrder = 6
		end
		local partyButton = button(
			settings,
			"PartyDiagnostics",
			"Party / Challenge diagnostics",
			function()
				options.social.open(true)
			end
		)
		partyButton.Size = UDim2.new(1, -8, 0, 48)
		partyButton.LayoutOrder = 7
		local note = text(
			settings,
			"SessionPreferenceNote",
			"Visual preferences apply for this session. All capture and claim information remains available as text.",
			15
		)
		note.Size = UDim2.new(1, -8, 0, 90)
		note.LayoutOrder = 8
		local navigation = Instance.new("Frame")
		navigation.Name, navigation.Size, navigation.Position, navigation.AnchorPoint, navigation.Parent =
			"Navigation",
			UDim2.new(0.96, 0, 0, 48),
			UDim2.new(0.5, 0, 1, -12),
			Vector2.new(0.5, 1),
			gui
		navigation.BackgroundTransparency = 1
		hud = { objectivePanel, energyPanel, navigation }
		local navLimit = Instance.new("UISizeConstraint")
		navLimit.MaxSize, navLimit.Parent = Vector2.new(720, 48), navigation
		local grid = Instance.new("UIGridLayout")
		grid.SortOrder = Enum.SortOrder.LayoutOrder
		grid.CellSize, grid.CellPadding, grid.Parent =
			UDim2.new(1 / 6, -5, 1, 0), UDim2.fromOffset(5, 0), navigation
		local function fitNavigation()
			local navCamera = workspace.CurrentCamera
			local touch = game:GetService("UserInputService").TouchEnabled
			local short = navCamera and navCamera.ViewportSize.Y < 500
			local compact = navigation.AbsoluteSize.X < 520
				or (nav.Collection and nav.Collection.TextSize > 16)
				or game:GetService("GuiService").PreferredTextSize
					~= Enum.PreferredTextSize.Medium
			local columns = if compact then 3 else 6
			local cellWidth = math.max(1, navigation.AbsoluteSize.X / columns - 10)
			-- Native text measurement includes the platform preference. Grow the
			-- cells and capture clearance rather than shrinking accessible text.
			local measured = game:GetService("TextService"):GetTextSize(
				if nav.Collection then nav.Collection.Text else "Collection",
				if nav.Collection then nav.Collection.TextSize else 16,
				Enum.Font.GothamBold,
				Vector2.new(cellWidth, math.huge)
			)
			local cellHeight = math.max(if compact then 50 else 48, math.ceil(measured.Y) + 18)
			local navHeight = if compact then cellHeight * 2 + 8 else cellHeight
			navigation.Size = UDim2.new(0.96, 0, 0, navHeight)
			navLimit.MaxSize = Vector2.new(720, navHeight)
			grid.CellSize = if compact
				then UDim2.new(1 / 3, -4, 0, cellHeight)
				else UDim2.new(1 / 6, -5, 0, cellHeight)
			grid.CellPadding = UDim2.fromOffset(5, 6)
			-- Leave Roblox's movement/jump controls unobstructed. Short screens
			-- temporarily devote the upper space to capture's semantic feedback.
			navigation.Position = UDim2.new(0.5, 0, 1, if touch then -94 else -12)
			local captureGui = playerGui:FindFirstChild("MonsterVaultCapture")
			if captureGui then
				captureGui.Panel.Position = UDim2.new(
					0.5,
					0,
					1,
					if touch
						then (if short then -94 else -94 - navHeight - 14)
						else -12 - navHeight - 16
				)
			end
		end
		table.insert(
			connections,
			navigation:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitNavigation)
		)
		table.insert(
			connections,
			game:GetService("GuiService")
				:GetPropertyChangedSignal("PreferredTextSize")
				:Connect(fitNavigation)
		)
		fitNavigation()
		table.insert(
			connections,
			playerGui.ChildAdded:Connect(function(child: any)
				if child.Name == "MonsterVaultCapture" then
					fitNavigation()
					table.insert(
						connections,
						child.Panel:GetPropertyChangedSignal("Visible"):Connect(refreshHud)
					)
					refreshHud()
				end
			end)
		)
		for i, name in { "Vault", "Collection", "Journey", "Showcase", "Settings" } do
			nav[name] = button(navigation, name, name, function()
				open(if current == name then nil else name)
			end)
			nav[name].LayoutOrder = i
		end
		table.insert(
			connections,
			nav.Collection:GetPropertyChangedSignal("TextSize"):Connect(fitNavigation)
		)
		fitNavigation()
		nav.Home = button(navigation, "Home", "Home", function()
			local char = options.player.Character
			local body = char and char:FindFirstChild("HumanoidRootPart")
			local generation = options.player:GetAttribute("MonsterVaultCharacterGeneration")
			if body and generation then
				travelRequest =
					options.networking.gateway.send(Routes.commands.worldRequestFastTravel, {
						nodeId = if body.Position.Z > 95
							then "travel-node/starter"
							else "travel-node/home-hub",
						characterGeneration = generation,
					})
				notify("Travel requested · awaiting safe arrival")
			end
		end)
		nav.Home.LayoutOrder = 6
		-- A direct gamepad entry avoids depending on Roblox's optional UI
		-- navigation toggle after capture releases its selected control.
		local function menuBinding()
			local input = game:GetService("UserInputService")
			local key = input:GetStringForKeyCode(Enum.KeyCode.ButtonY):gsub("^Button", "")
			nav.Collection.Text = if input.PreferredInput == Enum.PreferredInput.Gamepad
				then "[" .. (if key == "" then "Y" else key) .. "] Collection"
				else "Collection"
			fitNavigation()
		end
		table.insert(
			connections,
			game:GetService("UserInputService")
				:GetPropertyChangedSignal("PreferredInput")
				:Connect(menuBinding)
		)
		menuBinding()
		options.assignments.observeClaim(
			function(amount: number, _revision: number, balance: number)
				if running then
					if amount > 0 then
						open(nil)
					end
					sensory.claim(amount, balance)
					notify(
						if amount > 0
							then "+" .. amount .. " ENERGY · SAVED"
							else "No whole Energy ready to claim yet."
					)
				end
			end
		)
		options.progression.observePurchase(function(state: any)
			if running then
				open(nil)
				notify(state.label .. " · UPGRADE SAVED\nYour next aspiration is ready to review.")
				sensory.play("Secured", 0.14)
			end
		end)
		unsubscribe = options.networking.subscribePresentation(
			function(outcome: string, _envelope: any)
				if outcome == "Party" then
					options.showcase.refreshView()
				end
				if outcome == "Result" and _envelope.correlationId == travelRequest then
					travelRequest = nil
					local code = _envelope.payload.code
					notify(
						if code == "REJECT_STATE_TRAVEL_UNDISCOVERED"
							then "Follow the path to discover Mossline first."
							else if code:sub(1, 3) == "OK_"
								then "Safe arrival confirmed"
								else "Travel unavailable · return to the travel terminal without a carried capture."
					)
				end
				if
					outcome == "Assignments"
					and options.assignments.view().snapshot == _envelope.payload
				then
					assignmentCurrent = true
				end
				update()
			end
		)
		table.insert(
			connections,
			game:GetService("UserInputService").InputBegan
				:Connect(function(input: any, processed: boolean)
					if
						input.KeyCode == Enum.KeyCode.ButtonY
						and not game:GetService("GuiService").MenuIsOpen
						and not game:GetService("UserInputService"):GetFocusedTextBox()
					then
						open(if current then nil else "Collection")
					elseif
						(not processed or input.KeyCode == Enum.KeyCode.ButtonB)
						and not game:GetService("GuiService").MenuIsOpen
						and current
						and (
							input.KeyCode == Enum.KeyCode.Escape
							or input.KeyCode == Enum.KeyCode.ButtonB
						)
					then
						open(nil)
					end
				end)
		)
		update()
	end
	return {
		id = "golden_presentation",
		dependencies = {
			"networking",
			"world_observer",
			"vault_assignments_client",
			"vault_client",
			"progression_client",
			"social",
			"showcase_client",
		},
		start = start,
		capture = function(state: any)
			lastCapture = state
			local id = state.creatureInstanceId or state.targetId
			local facts = id and options.worldObserver.store.view(id)
			if facts then
				lastFacts = { id = id, speciesId = facts.speciesId, rarityId = facts.rarityId }
			end
			if not running then
				return
			end
			local cue = feedback.capture(state)
			if cue then
				sensory.play(cue)
				local character = options.player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if root and cue ~= "Failure" then
					sensory.pulse(root.Position, Theme.colors.energy, cue == "Secured")
					if cue == "Containment" then
						for _, entry in options.worldObserver.store.present() do
							if entry.creatureInstanceId == id and entry.model.Parent then
								sensory.beam(
									entry.model:GetPivot().Position,
									root.Position,
									Theme.colors.energy
								)
								break
							end
						end
					end
					if cue == "Containment" or cue == "Secured" then
						sensory.seasonalAccent(root.Position)
					end
				end
				if cue == "Secured" then
					local definition = lastFacts
						and lastFacts.id == id
						and Theme.definition(lastFacts.speciesId, lastFacts.rarityId)
					local camera = workspace.CurrentCamera
					if not camera or camera.ViewportSize.Y >= 500 then
						notify(
							"SECURED · "
								.. (if definition then definition.label else "Your creature")
								.. " saved to Collection\nGive it a display or a production assignment in your Vault."
						)
					end
				end
			end
			visuals.carry(
				if lastFacts and lastFacts.id == state.creatureInstanceId then lastFacts else nil,
				options.player,
				state.state == "TransportActive"
			)
			update()
		end,
		stop = function(): { string }
			running = false
			toastTicket += 1
			if unsubscribe then
				unsubscribe()
			end
			options.assignments.observeClaim(nil)
			options.progression.observePurchase(nil)
			if preferenceBinding then
				preferenceBinding.stop()
			end
			for _, connection in connections do
				connection:Disconnect()
			end
			if visuals then
				visuals.stop()
			end
			if seasonal then
				seasonal.stop()
			end
			if sensory then
				sensory.stop()
			end
			feedback.reset()
			if playerGui then
				playerGui:SetAttribute("GoldenModalOpen", false)
				local captureGui = playerGui:FindFirstChild("MonsterVaultCapture")
				if captureGui then
					captureGui.Enabled = true
				end
			end
			if gui then
				gui:Destroy()
			end
			return {}
		end,
	}
end
return Golden
