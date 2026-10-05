--!strict

-- Temporary native diagnostic controls. PQL-3/PQL-8 own final presentation.
-- Incoming invitations update data only; opening this panel is player intent.
local RouteIds =
	require(game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts.RouteIds)
local PartyRuntimeService = {}

function PartyRuntimeService.new(options: {
	networking: any,
	player: any,
	scheduler: any?,
	presentationSeconds: (() -> number)?,
})
	local globals = getfenv() :: any
	local Instance, Enum = globals.Instance, globals.Enum
	local gui: any = nil
	local panel: any = nil
	local unsubscribe: any = nil
	local controls: { any } = {}
	local connections = {}
	local scheduler = options.scheduler or globals.task
	local clock = options.presentationSeconds
		or function(): number
			return game:GetService("Workspace"):GetServerTimeNow()
		end
	local running = false
	local timer: any = nil
	local scheduledAt: number? = nil
	local ticket = 0
	local arm: () -> ()
	local function send(route: string, payload: any, expected: number?)
		options.networking.gateway.send(route, payload, expected)
	end
	local function clear()
		for _, connection in controls do
			connection:Disconnect()
		end
		table.clear(controls)
		for _, child in panel:GetChildren() do
			child:Destroy()
		end
	end
	local function render()
		if panel == nil then
			return
		end
		clear()
		local row = 0
		local function label(text: string)
			local item = Instance.new("TextLabel")
			item.Size, item.Position =
				globals.UDim2.new(1, -8, 0, 22), globals.UDim2.fromOffset(4, row)
			item.BackgroundTransparency, item.TextSize, item.Text = 1, 14, text
			item.TextColor3, item.TextXAlignment =
				globals.Color3.new(1, 1, 1), Enum.TextXAlignment.Left
			item.Parent = panel
			row += 24
		end
		local function button(text: string, action: () -> ())
			local item = Instance.new("TextButton")
			item.Size, item.Position =
				globals.UDim2.new(1, -8, 0, 24), globals.UDim2.fromOffset(4, row)
			item.Text, item.TextSize, item.Parent = text, 14, panel
			table.insert(controls, item.Activated:Connect(action))
			row += 26
		end
		local snapshot = options.networking.partyStore.view()
		button("Refresh Party", function()
			send(RouteIds.commands.sessionRequestResync, { domain = "party" })
		end)
		if snapshot == nil then
			label("Party state unavailable")
			return
		end
		local state = snapshot.state
		button(
			if state.pingsMuted ~= false
				then "Party pings: muted (enable)"
				else "Party pings: on (mute)",
			function()
				send(
					RouteIds.commands.settingsUpdatePreferences,
					{ socialPingsMuted = state.pingsMuted == false }
				)
			end
		)
		button(
			if state.allowInvites
				then "Invites: Same server (disable)"
				else "Invites: None (enable)",
			function()
				send(
					RouteIds.commands.socialPartySetInvitePolicy,
					{ allowInvites = not state.allowInvites }
				)
			end
		)
		local party = state.party
		if party then
			button("ComeHere: ping my current location", function()
				send(
					RouteIds.commands.socialPing,
					{ partyId = party.partyId, pingKind = "ComeHere" },
					party.revision
				)
			end)
			label(
				"Party "
					.. string.sub(party.partyId, 1, 8)
					.. " / revision "
					.. tostring(party.revision)
			)
			for _, member in party.members do
				label(
					tostring(member.userId)
						.. (if member.userId == party.leaderUserId then " (leader)" else "")
						.. (if member.present then "" else " (away)")
				)
				if
					party.leaderUserId == options.player.UserId
					and member.userId ~= options.player.UserId
				then
					button("Remove " .. tostring(member.userId), function()
						send(
							RouteIds.commands.socialPartyRemove,
							{ partyId = party.partyId, targetUserId = member.userId },
							party.revision
						)
					end)
				end
			end
			button("Leave Party", function()
				send(
					RouteIds.commands.socialPartyLeave,
					{ partyId = party.partyId },
					party.revision
				)
			end)
			if party.leaderUserId == options.player.UserId then
				local target = Instance.new("TextBox")
				target.Size, target.Position =
					globals.UDim2.new(1, -8, 0, 24), globals.UDim2.fromOffset(4, row)
				target.PlaceholderText, target.Text, target.TextSize, target.Parent =
					"Target UserId (number)", "", 14, panel
				row += 26
				button("Invite target", function()
					local userId = tonumber(target.Text)
					if userId and userId > 0 and userId % 1 == 0 then
						send(
							RouteIds.commands.socialPartyInvite,
							{ targetUserId = userId },
							party.revision
						)
					end
				end)
				button("Disband Party", function()
					send(
						RouteIds.commands.socialPartyDisband,
						{ partyId = party.partyId },
						party.revision
					)
				end)
			end
		elseif state.rejoin then
			local rejoin = state.rejoin
			label("Reserved seat / " .. tostring(rejoin.expiresAt) .. " server deadline")
			button("Rejoin Party", function()
				send(
					RouteIds.commands.socialPartyRejoin,
					{ partyId = rejoin.partyId },
					rejoin.revision
				)
			end)
			button("Release reserved seat", function()
				send(
					RouteIds.commands.socialPartyLeave,
					{ partyId = rejoin.partyId },
					rejoin.revision
				)
			end)
		else
			label("No Party")
			button("Create Party", function()
				send(RouteIds.commands.socialPartyCreate, {})
			end)
		end
		for _, invite in state.incoming do
			label(
				"Invite from "
					.. tostring(invite.inviterUserId)
					.. " / "
					.. tostring(invite.expiresAt)
					.. " server deadline (Pending)"
			)
			button("Accept " .. string.sub(invite.invitationId, 1, 8), function()
				send(
					RouteIds.commands.socialPartyRespond,
					{ invitationId = invite.invitationId, accept = true },
					invite.partyRevision
				)
			end)
			button("Decline " .. string.sub(invite.invitationId, 1, 8), function()
				send(
					RouteIds.commands.socialPartyRespond,
					{ invitationId = invite.invitationId, accept = false },
					invite.partyRevision
				)
			end)
		end
		for _, ping in state.pings or {} do
			label(
				string.format(
					"ComeHere / %d / %.1fs",
					ping.senderUserId,
					math.max(0, ping.expiresAt - clock())
				)
			)
			label(
				string.format(
					"Waypoint: %.1f, %.1f, %.1f",
					ping.position.x,
					ping.position.y,
					ping.position.z
				)
			)
		end
		panel.CanvasSize = globals.UDim2.fromOffset(0, row)
		arm()
	end
	arm = function()
		local deadline = if running then options.networking.partyStore.nextDeadline() else nil
		if deadline == scheduledAt then
			return
		end
		ticket += 1
		if timer ~= nil then
			pcall(scheduler.cancel, timer)
		end
		timer, scheduledAt = nil, deadline
		if deadline == nil then
			return
		end
		local expected = ticket
		timer = scheduler.delay(math.max(0, deadline - clock()), function()
			if not running or expected ~= ticket then
				return
			end
			timer, scheduledAt = nil, nil
			ticket += 1
			render()
		end)
	end
	local function start()
		running = true
		gui = Instance.new("ScreenGui")
		gui.Name, gui.ResetOnSpawn = "MonsterVaultPartyDiagnostic", false
		local toggle = Instance.new("TextButton")
		toggle.Size, toggle.Position, toggle.Text =
			globals.UDim2.fromOffset(130, 28), globals.UDim2.fromOffset(8, 128), "Party diagnostics"
		toggle.Parent = gui
		panel = Instance.new("ScrollingFrame")
		panel.Size, panel.Position, panel.Visible =
			globals.UDim2.new(0, 280, 0.6, 0), globals.UDim2.fromOffset(8, 158), false
		panel.BackgroundColor3, panel.ScrollBarThickness = globals.Color3.fromRGB(30, 35, 45), 6
		panel.Parent = gui
		table.insert(
			connections,
			toggle.Activated:Connect(function()
				panel.Visible = not panel.Visible
				if panel.Visible then
					send(RouteIds.commands.sessionRequestResync, { domain = "party" })
				end
			end)
		)
		unsubscribe = options.networking.subscribeParty(function()
			render()
		end)
		render()
		gui.Parent = options.player:WaitForChild("PlayerGui")
	end
	local function stop(): { string }
		running, ticket = false, ticket + 1
		if timer ~= nil then
			pcall(scheduler.cancel, timer)
		end
		timer, scheduledAt = nil, nil
		if unsubscribe then
			unsubscribe()
		end
		for _, connection in controls do
			connection:Disconnect()
		end
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(controls)
		table.clear(connections)
		if gui then
			gui:Destroy()
		end
		gui, panel = nil, nil
		return {}
	end
	return { id = "social", dependencies = { "networking" }, start = start, stop = stop }
end

return PartyRuntimeService
