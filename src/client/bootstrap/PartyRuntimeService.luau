--!strict

-- Temporary native diagnostic controls. PQL-3/PQL-8 own final presentation.
-- Incoming invitations update data only; opening this panel is player intent.
local RouteIds =
	require(game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts.RouteIds)
local PartyRuntimeService = {}
local FriendlyChallengeDefinition = require(
	game:GetService("ReplicatedStorage").MonsterVault.Shared.config.FriendlyChallengeDefinition
)

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
	local unsubscribeShowcase: any = nil
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
		local function label(text: string, height: number?)
			local item = Instance.new("TextLabel")
			item.Size, item.Position =
				globals.UDim2.new(1, -8, 0, height or 22), globals.UDim2.fromOffset(4, row)
			item.TextWrapped = height ~= nil
			item.BackgroundTransparency, item.TextSize, item.Text = 1, 14, text
			item.TextColor3, item.TextXAlignment =
				globals.Color3.new(1, 1, 1), Enum.TextXAlignment.Left
			item.Parent = panel
			row += (height or 22) + 2
		end
		local function button(text: string, action: () -> ())
			local item = Instance.new("TextButton")
			item.Size, item.Position =
				globals.UDim2.new(1, -8, 0, 24), globals.UDim2.fromOffset(4, row)
			item.Text, item.TextSize, item.Parent = text, 14, panel
			table.insert(controls, item.Activated:Connect(action))
			row += 26
		end
		local showcase = options.networking.showcaseStore.view()
		label("Showcase / Visitors (read-only)")
		button("Refresh Showcase", function()
			send(RouteIds.commands.sessionRequestResync, { domain = "showcase" })
		end)
		local permissions = if showcase.permissions then showcase.permissions.state else nil
		if permissions and permissions.permissionRevision > 0 then
			label("My visitor audience: " .. permissions.audience)
			for _, audience in { "Closed", "Party", "SameServer" } do
				if audience ~= permissions.audience then
					button("Set visitor audience: " .. audience, function()
						send(
							RouteIds.commands.socialShowcaseSetPolicy,
							{ audience = audience },
							permissions.permissionRevision
						)
					end)
				end
			end
			if permissions.audience ~= "Closed" then
				local target = Instance.new("TextBox")
				target.Name = "ShowcaseTargetUserId"
				target.Size, target.Position =
					globals.UDim2.new(1, -8, 0, 24), globals.UDim2.fromOffset(4, row)
				target.PlaceholderText, target.Text, target.TextSize, target.Parent =
					"Visitor UserId", "", 14, panel
				row += 26
				button("Allow this visitor for 60s", function()
					local userId = tonumber(target.Text)
					if userId and userId > 0 and userId % 1 == 0 then
						send(
							RouteIds.commands.socialShowcaseGrant,
							{ targetUserId = userId },
							permissions.permissionRevision
						)
					end
				end)
			end
			for _, grant in permissions.visitors do
				label("Allowed visitor: " .. tostring(grant.userId))
				button("Revoke visitor " .. tostring(grant.userId), function()
					send(
						RouteIds.commands.socialShowcaseRevoke,
						{ grantId = grant.id },
						permissions.permissionRevision
					)
				end)
			end
			for _, grant in permissions.incoming do
				button("Inspect owner " .. tostring(grant.userId) .. " (read-only)", function()
					send(
						RouteIds.commands.socialShowcaseOpen,
						{ ownerUserId = grant.userId, grantId = grant.id }
					)
				end)
			end
		end
		local visit = if showcase.visit then showcase.visit.state else nil
		if visit and visit.mode == "ReadOnly" then
			label(
				"READ-ONLY Showcase / "
					.. visit.ownerDisplayName
					.. " / "
					.. tostring(visit.ownerUserId),
				44
			)
			for _, creature in visit.creatures do
				label("Instance: " .. creature.creatureInstanceId, 40)
				label(
					"Species: " .. creature.speciesId .. " / Rarity: " .. creature.speciesRarityId,
					44
				)
				label(
					"Mutation: "
						.. table.concat(creature.mutationIds, ", ")
						.. " / Trait: "
						.. table.concat(creature.traitIds, ", "),
					54
				)
				label("Display: " .. creature.displaySlotId)
			end
			if #visit.creatures == 0 then
				label("No approved display card available")
			end
			if visit.hasMore then
				label("Additional display content omitted from this bounded view", 44)
			end
			button("Close visit and return", function()
				send(RouteIds.commands.socialShowcaseClose, { grantId = visit.grantId })
			end)
		else
			label("Showcase closed / " .. (if visit then visit.reason else "Unavailable"))
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
				then "Party/challenge/Showcase offers: Same server (disable)"
				else "Party/challenge/Showcase offers: None (enable)",
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
		local challenge = state.challenge
		if challenge then
			local knownDefinition = challenge.definitionId == FriendlyChallengeDefinition.id
				and challenge.definitionVersion == FriendlyChallengeDefinition.version
			label(
				(
					if knownDefinition
						then FriendlyChallengeDefinition.title
						else challenge.definitionId
				)
					.. " / "
					.. challenge.phase
			)
			label(
				if knownDefinition
					then "Rules: " .. FriendlyChallengeDefinition.rules
					else "Definition unavailable; cancel or decline.",
				128
			)
			label(
				"Challenge "
					.. string.sub(challenge.id, 1, 8)
					.. " / revision "
					.. tostring(challenge.revision)
			)
			label(
				"Opponent: "
					.. tostring(
						if challenge.fromUserId == options.player.UserId
							then challenge.toUserId
							else challenge.fromUserId
					)
			)
			label(string.format("Expires in %.1fs", math.max(0, challenge.expiresAt - clock())))
			if challenge.phase == "Offered" and challenge.toUserId == options.player.UserId then
				if knownDefinition then
					button("Accept Home Return", function()
						send(
							RouteIds.commands.socialChallengeRespond,
							{ challengeId = challenge.id, accept = true },
							challenge.revision
						)
					end)
				end
				button("Decline challenge", function()
					send(
						RouteIds.commands.socialChallengeRespond,
						{ challengeId = challenge.id, accept = false },
						challenge.revision
					)
				end)
			elseif challenge.phase == "Active" then
				label("Use ordinary Home Return; no reward or stake.")
			end
			if challenge.phase == "Offered" or challenge.phase == "Active" then
				button("Cancel challenge", function()
					send(
						RouteIds.commands.socialChallengeCancel,
						{ challengeId = challenge.id },
						challenge.revision
					)
				end)
			elseif challenge.phase == "Resolved" then
				label(
					"Winner: "
						.. tostring(challenge.winnerUserId)
						.. " / "
						.. tostring(challenge.elapsedMs)
						.. "ms"
				)
			else
				label("Reason: " .. tostring(challenge.reason))
			end
		else
			label("No challenge / " .. FriendlyChallengeDefinition.title)
			label("Rules: " .. FriendlyChallengeDefinition.rules, 128)
			local target = Instance.new("TextBox")
			target.Size, target.Position =
				globals.UDim2.new(1, -8, 0, 24), globals.UDim2.fromOffset(4, row)
			target.PlaceholderText, target.Text, target.TextSize, target.Parent =
				"Challenge target UserId", "", 14, panel
			row += 26
			button("Offer Home Return (my consent)", function()
				local userId = tonumber(target.Text)
				if userId and userId > 0 and userId % 1 == 0 then
					send(RouteIds.commands.socialChallengeRequest, {
						targetUserId = userId,
						definitionId = FriendlyChallengeDefinition.id,
						definitionVersion = FriendlyChallengeDefinition.version,
					})
				end
			end)
		end
		panel.CanvasSize = globals.UDim2.fromOffset(0, row)
		arm()
	end
	arm = function()
		local deadline = if running then options.networking.partyStore.nextDeadline() else nil
		local showcaseDeadline = if running
			then options.networking.showcaseStore.nextDeadline()
			else nil
		if showcaseDeadline then
			deadline = math.min(deadline or math.huge, showcaseDeadline)
		end
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
		unsubscribeShowcase = options.networking.subscribeShowcase(function()
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
		if unsubscribeShowcase then
			unsubscribeShowcase()
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
