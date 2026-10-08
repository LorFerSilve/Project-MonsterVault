--!strict
local globals: any = getfenv()
local Instance, Enum, Vector3, CFrame, UDim2 =
	globals.Instance, globals.Enum, globals.Vector3, globals.CFrame, globals.UDim2
local shared = game:GetService("ReplicatedStorage").MonsterVault.Shared
local Fixture = require(shared.config.VaultProductionFixture)
local Layout = require(shared.config.GoldenWorldLayout)
local Theme = require(script.Parent.GoldenTheme)
local Visuals = {}
function Visuals.new(sensory: any, observer: any)
	local library = game:GetService("ReplicatedStorage").MonsterVault.PresentationAssets
	local records: { [any]: any } = {}
	local owned: { any } = {}
	local wildCount = 0
	local carry: any = nil
	local function forget(source: any)
		local record = records[source]
		if not record then
			return
		end
		sensory.remove(record.visual)
		if record.visual.Parent then
			record.visual:PivotTo(record.base())
			for _, p in record.visual:GetDescendants() do
				if p:IsA("BasePart") then
					p.LocalTransparencyModifier = 0
				end
			end
		end
		if record.legacy and record.legacy.Parent then
			record.legacy.Enabled = true
		end
		record.gui:Destroy()
		records[source], wildCount = nil, wildCount - 1
	end
	local unsubscribe = observer.subscribePresentation(function(source: any, facts: any)
		if not facts then
			forget(source)
			return
		end
		local definition = Theme.definition(facts.speciesId, facts.rarityId)
		local record = records[source]
		if record and record.id ~= facts.creatureInstanceId then
			forget(source)
			record = nil
		end
		if not record then
			local visual, body = source:FindFirstChild("CreatureVisual"), source.PrimaryPart
			if not definition or not visual or not body or wildCount >= 10 then
				return
			end
			local function base(): any
				return source:GetPivot() * CFrame.new(0, -2.8, 0)
			end
			if
				not sensory.add(
					visual,
					base,
					if facts.rarityId == "rarity/legendary" then "legendary" else "world"
				)
			then
				return
			end
			local gui = Instance.new("BillboardGui")
			gui.Name, gui.Adornee, gui.Size, gui.MaxDistance =
				"CreatureIdentity", body, UDim2.fromOffset(220, 70), 45
			gui.StudsOffset, gui.Parent = Vector3.new(0, 3.6, 0), source
			local label = Instance.new("TextLabel")
			Theme.text(label, 15, true)
			label.TextXAlignment, label.Size, label.Parent =
				Enum.TextXAlignment.Center, UDim2.new(1, 0, 0, 24), gui
			local badge = Theme.rarityBadge(gui, facts.rarityId)
			badge.Position, badge.Size = UDim2.fromOffset(30, 25), UDim2.fromOffset(180, 22)
			local status = Instance.new("TextLabel")
			Theme.text(status, 12)
			status.TextXAlignment, status.TextColor3 =
				Enum.TextXAlignment.Center, Theme.colors.muted
			status.Position, status.Size, status.Parent =
				UDim2.fromOffset(0, 48), UDim2.new(1, 0, 0, 18), gui
			local legacy = source:FindFirstChild("ProtectedEncounterCue")
			if legacy then
				legacy.Enabled = false
			end
			record = {
				id = facts.creatureInstanceId,
				visual = visual,
				base = base,
				gui = gui,
				label = label,
				status = status,
				legacy = legacy,
			}
			records[source], wildCount = record, wildCount + 1
		end
		local visible = facts.availability == "IdleAvailable"
			or facts.availability == "Claimed"
			or facts.availability == "AttemptActive"
		for _, p in record.visual:GetDescendants() do
			if p:IsA("BasePart") then
				p.LocalTransparencyModifier = if visible then 0 else 1
			end
		end
		record.gui.Enabled = visible
		record.label.Text = definition.label
		record.status.Text = if facts.lifetimeClass == "ProtectedVariant"
			then "DEV · Protected encounter"
			else ""
	end)
	local function clearOwned()
		for _, model in owned do
			sensory.remove(model)
			model:Destroy()
		end
		table.clear(owned)
	end
	local function clearCarry()
		if carry then
			sensory.remove(carry)
			carry:Destroy()
			carry = nil
		end
	end
	return {
		captureReaction = function(id: string?, cue: string)
			for _, record in records do
				if record.id == id then
					sensory.react(record.visual, cue)
					return
				end
			end
		end,
		owned = function(rows: any)
			clearOwned()
			for _, row in rows do
				if row.displaySlotId and not row.overflowHeld and not row.productionSlotId then
					local slot = table.find(Fixture.displaySlotIds, row.displaySlotId)
					local rarityId = row.speciesRarityId or row.rarityId
					local definition = Theme.definition(row.speciesId, rarityId)
					if slot and slot <= 2 and definition then
						local model = library[definition.asset]:Clone()
						model.Name = "OwnedDisplay_" .. row.creatureInstanceId
						model:SetAttribute("PresentedCreatureInstanceId", row.creatureInstanceId)
						model:SetAttribute("PresentedSpeciesId", row.speciesId)
						model:SetAttribute("PresentedRarityId", rarityId)
						model:SetAttribute(
							"PresentedMutationIds",
							table.concat(row.mutationIds, ",")
						)
						model:SetAttribute("PresentedTraitIds", table.concat(row.traitIds, ","))
						model:SetAttribute("PresentedDisplaySlotId", row.displaySlotId)
						model.Parent = sensory.root
						local position = Layout.displays[slot]
						local cf = CFrame.new(position[1], position[2] + 1.02, position[3])
							* CFrame.Angles(0, math.rad(155), 0)
						model:PivotTo(cf)
						if sensory.add(model, cf, "display") then
							table.insert(owned, model)
						else
							model:Destroy()
						end
					end
				end
			end
		end,
		carry = function(facts: any, player: any, enabled: boolean)
			clearCarry()
			if not enabled or not facts then
				return
			end
			local definition = Theme.definition(facts.speciesId, facts.rarityId)
			if not definition then
				return
			end
			carry = library[definition.asset]:Clone()
			carry:ScaleTo(0.45)
			carry.Name = "ProvisionalCustodyPresentation"
			carry.Parent = sensory.root
			if
				not sensory.add(carry, function()
					local char = player.Character
					local root = char and char:FindFirstChild("HumanoidRootPart")
					return root and root.CFrame * CFrame.new(2.4, -0.6, 0)
				end, "custody")
			then
				carry:Destroy()
				carry = nil
			end
		end,
		clear = function()
			clearOwned()
			clearCarry()
		end,
		stop = function()
			unsubscribe()
			for source in records do
				forget(source)
			end
			clearOwned()
			clearCarry()
		end,
	}
end
return Visuals
