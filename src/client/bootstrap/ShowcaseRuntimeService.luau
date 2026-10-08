--!strict
-- Sole Showcase UI subscriber. Permissions are always current server readback.
local globals: any = getfenv()
local Instance, Enum, UDim2, UDim = globals.Instance, globals.Enum, globals.UDim2, globals.UDim
local Routes = require(game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts.RouteIds)
local Theme = require(script.Parent.Parent.presentation.GoldenTheme)
local Showcase = {}
function Showcase.new(options: any)
	local gui, panel: any = nil, nil
	local running, expanded = false, false
	local targetId: number? = nil
	local ownerFacts: any = nil
	local unsubscribe: any = nil
	local connections: { any } = {}
	local controls: { any } = {}
	local timer: any = nil
	local timerTicket = 0
	local render: () -> ()
	local function send(route: string, payload: any, revision: number?)
		options.networking.gateway.send(route, payload, revision)
	end
	local function displayName(id: number): string
		local player = game:GetService("Players"):GetPlayerByUserId(id)
		return if player then player.DisplayName else "Explorer left"
	end
	local function closeVisit()
		local view = options.networking.showcaseStore.view()
		local visit = view.visit and view.visit.state
		if visit and visit.mode == "ReadOnly" then
			send(Routes.commands.socialShowcaseClose, { grantId = visit.grantId })
		end
	end
	render = function()
		if not running or not panel then
			return
		end
		local gs = game:GetService("GuiService")
		local focused = gs.SelectedObject
			and gs.SelectedObject:IsDescendantOf(panel)
			and gs.SelectedObject.Name
		for _, c in controls do
			c:Disconnect()
		end
		table.clear(controls)
		for _, child in panel:GetChildren() do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
		local layout = panel:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout")
		layout.Padding, layout.SortOrder, layout.Parent =
			UDim.new(0, 10), Enum.SortOrder.LayoutOrder, panel
		local order = 0
		local function label(name: string, value: string, bold: boolean?)
			order += 1
			local p = Instance.new("TextLabel")
			p.Name, p.Text, p.Size, p.AutomaticSize =
				name, value, UDim2.new(1, -8, 0, 28), Enum.AutomaticSize.Y
			Theme.text(p, if bold then 18 else 16, bold)
			p.LayoutOrder, p.Parent = order, panel
		end
		local function button(name: string, value: string, action: () -> (), enabled: boolean?)
			order += 1
			local p = Instance.new("TextButton")
			p.Name, p.Text, p.Size, p.AutomaticSize =
				name, value, UDim2.new(1, -8, 0, 48), Enum.AutomaticSize.Y
			Theme.button(p)
			if enabled == false then
				Theme.enabled(p, false)
			end
			p.LayoutOrder, p.Parent = order, panel
			table.insert(controls, p.Activated:Connect(action))
		end
		local view = options.networking.showcaseStore.view()
		local permissions = view.permissions and view.permissions.state
		local visit = view.visit and view.visit.state
		if visit and visit.mode == "ReadOnly" then
			label("Owner", visit.ownerDisplayName .. " · SHOWCASE", true)
			label("ReadOnly", "READ ONLY · You can inspect this display.")
			for _, facts in visit.creatures do
				order += 1
				local card = Theme.card(panel, facts, true)
				card.LayoutOrder = order
			end
			if #visit.creatures == 0 then
				label("Empty", "No creature is currently approved for this display.")
			end
			if visit.hasMore then
				label("More", "One approved display is shown in this visit.")
			end
			button("Return", "Close visit and return", closeVisit)
		else
			label("Owner", options.player.DisplayName .. " · MY SHOWCASE", true)
			if visit and visit.reason ~= "None" then
				label(
					"VisitStatus",
					"Visit closed · "
						.. (
							if visit.reason == "Expired"
								then "Permission expired"
								else "Access is no longer active"
						)
				)
			end
			if ownerFacts then
				order += 1
				local card = Theme.card(panel, ownerFacts, true)
				card.LayoutOrder = order
				label("Preview", "Owner preview · Visitors see this approved display only.")
			else
				label(
					"Empty",
					"Give an owned creature a Display assignment in your Vault to showcase it."
				)
			end
		end
		if
			permissions
			and permissions.permissionRevision > 0
			and (not visit or visit.mode ~= "ReadOnly")
		then
			local partyView = options.networking.partyStore.view()
			if partyView then
				local allow = partyView.state.allowInvites
				button(
					"SocialOffers",
					if allow
						then "Social offers · Same server (disable)"
						else "Social offers · None (enable)",
					function()
						send(
							Routes.commands.socialPartySetInvitePolicy,
							{ allowInvites = not allow }
						)
					end
				)
				label(
					"OffersScope",
					"This preference covers Party, Challenge and Showcase offers. It never grants visitor access."
				)
			end
			label("Audience", "Visitor audience · " .. permissions.audience, true)
			label(
				"Consent",
				"Each visitor needs your explicit permission. Access lasts up to 60 seconds."
			)
			for _, audience in { "Closed", "Party", "SameServer" } do
				if audience ~= permissions.audience then
					button(
						"Audience" .. audience,
						if audience == "Closed"
							then "Close my visitor audience"
							elseif audience == "Party" then "Allow offers to my Party"
							else "Allow offers to this server",
						function()
							send(
								Routes.commands.socialShowcaseSetPolicy,
								{ audience = audience },
								permissions.permissionRevision
							)
						end
					)
				end
			end
			if permissions.audience ~= "Closed" then
				local players = {}
				for _, p in game:GetService("Players"):GetPlayers() do
					if p ~= options.player then
						table.insert(players, p)
					end
				end
				table.sort(players, function(a, b)
					return a.UserId < b.UserId
				end)
				local index = 1
				for i, p in players do
					if p.UserId == targetId then
						index = i
					end
				end
				targetId = players[index] and players[index].UserId
				button(
					"Visitor",
					if targetId
						then "Visitor · " .. displayName(targetId) .. "  ›"
						else "No other explorers in this server",
					function()
						if #players == 0 then
							return
						end
						local nextPlayer = players[index % #players + 1]
						targetId = nextPlayer.UserId
						render()
					end,
					#players > 0
				)
				button("Grant", "Allow this visitor · 60 seconds", function()
					if targetId then
						send(
							Routes.commands.socialShowcaseGrant,
							{ targetUserId = targetId },
							permissions.permissionRevision
						)
					end
				end, targetId ~= nil)
			end
			for _, grant in permissions.visitors do
				button(
					"Revoke" .. grant.id,
					"Revoke access · " .. displayName(grant.userId),
					function()
						send(
							Routes.commands.socialShowcaseRevoke,
							{ grantId = grant.id },
							permissions.permissionRevision
						)
					end
				)
			end
			for _, grant in permissions.incoming do
				button(
					"Inspect" .. grant.id,
					"Inspect " .. displayName(grant.userId) .. " · READ ONLY",
					function()
						send(
							Routes.commands.socialShowcaseOpen,
							{ ownerUserId = grant.userId, grantId = grant.id }
						)
					end
				)
			end
		elseif not visit or visit.mode ~= "ReadOnly" then
			label("Loading", "Checking current visitor permissions…")
		end
		button("Refresh", "Refresh permissions", function()
			send(Routes.commands.sessionRequestResync, { domain = "showcase" })
		end)
		if focused then
			local candidate = panel:FindFirstChild(focused)
			gs.SelectedObject = if candidate
					and candidate:IsA("GuiButton")
					and candidate.Selectable
				then candidate
				else panel.Refresh
		end
		timerTicket += 1
		if timer then
			pcall(globals.task.cancel, timer)
			timer = nil
		end
		local deadline = options.networking.showcaseStore.nextDeadline()
		if deadline then
			local ticket = timerTicket
			timer = globals.task.delay(
				math.max(0, deadline - workspace:GetServerTimeNow()),
				function()
					if running and timerTicket == ticket then
						render()
					end
				end
			)
		end
	end
	return {
		id = "showcase_client",
		dependencies = { "networking" },
		ui = function()
			return gui, panel
		end,
		refreshView = function()
			render()
		end,
		preview = function(rows: any)
			ownerFacts = nil
			for _, row in rows do
				if
					row.displaySlotId
					and row.speciesId
					and not row.overflowHeld
					and not row.productionSlotId
				then
					ownerFacts = row
					break
				end
			end
			render()
		end,
		open = function(value: boolean)
			if expanded and not value then
				closeVisit()
			end
			expanded = value
			if panel then
				panel.Visible = value
			end
			if value then
				send(Routes.commands.sessionRequestResync, { domain = "showcase" })
			end
		end,
		start = function()
			running = true
			gui = Instance.new("ScreenGui")
			gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = "MonsterVaultShowcase", false, 13
			gui.ScreenInsets, gui.Parent =
				Enum.ScreenInsets.CoreUISafeInsets, options.player:WaitForChild("PlayerGui")
			panel = Instance.new("Frame")
			panel.Name, panel.Size, panel.Visible, panel.Parent =
				"Panel", UDim2.fromScale(1, 0), false, gui
			panel.AutomaticSize = Enum.AutomaticSize.Y
			Theme.panel(panel)
			unsubscribe = options.networking.subscribeShowcase(render)
			local players = game:GetService("Players")
			table.insert(connections, players.PlayerAdded:Connect(render))
			table.insert(
				connections,
				players.PlayerRemoving:Connect(function()
					globals.task.defer(render)
				end)
			)
			render()
		end,
		stop = function(): { string }
			running = false
			timerTicket += 1
			if timer then
				pcall(globals.task.cancel, timer)
			end
			if unsubscribe then
				unsubscribe()
			end
			for _, c in connections do
				c:Disconnect()
			end
			for _, c in controls do
				c:Disconnect()
			end
			if gui then
				gui:Destroy()
			end
			return {}
		end,
	}
end
return Showcase
