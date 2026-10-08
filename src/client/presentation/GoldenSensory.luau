--!strict
-- One render owner for bounded creature/machine motion and confirmed count-up.
local globals: any = getfenv()
local Instance, Enum, CFrame, Vector3 =
	globals.Instance, globals.Enum, globals.CFrame, globals.Vector3
local Audio = require(game:GetService("ReplicatedStorage").MonsterVault.Shared.config.GoldenAudio)
local Feedback = require(script.Parent.GoldenFeedback)
local Theme = require(script.Parent.GoldenTheme)
local Layout =
	require(game:GetService("ReplicatedStorage").MonsterVault.Shared.config.GoldenWorldLayout)
local Sensory = {}
function Sensory.new(player: any, preferences: any, wallet: (number) -> ())
	local root = Instance.new("Folder")
	root.Name, root.Parent = "MonsterVaultLocalEffects", workspace
	local animated: { [any]: any } = {}
	local transient: { any } = {}
	local sounds: { any } = {}
	local running = true
	local count = 0
	local balanceAnimation: any = nil
	local powerUntil = 0
	local producing, bufferPositive, claimReady = false, false, false
	local bufferFraction = 0
	local productionKnown = false
	local seasonal = false
	local services = {
		tween = game:GetService("TweenService"),
		debris = game:GetService("Debris"),
		run = game:GetService("RunService"),
	}
	-- One local movement emitter, driven by actual avatar state/distance. No
	-- movement authority, per-character loop, polling task or permanent emission.
	local dustAnchor = Instance.new("Part")
	dustAnchor.Name, dustAnchor.Size, dustAnchor.Transparency =
		"AvatarGroundFeedback", Vector3.one * 0.1, 1
	dustAnchor.Anchored, dustAnchor.CanCollide, dustAnchor.CanQuery, dustAnchor.CanTouch, dustAnchor.CastShadow =
		true, false, false, false, false
	dustAnchor.Parent = root
	local dust = Instance.new("ParticleEmitter")
	dust.Name, dust.Texture, dust.Rate =
		"GroundDust", "rbxasset://textures/particles/smoke_main.dds", 0
	dust.Color = globals.ColorSequence.new(globals.Color3.fromRGB(156, 171, 137))
	dust.Lifetime, dust.Speed, dust.SpreadAngle =
		globals.NumberRange.new(0.18, 0.35),
		globals.NumberRange.new(0.4, 1.2),
		globals.Vector2.new(70, 70)
	dust.Size = globals.NumberSequence.new({
		globals.NumberSequenceKeypoint.new(0, 0.2),
		globals.NumberSequenceKeypoint.new(1, 0.6),
	})
	dust.Transparency = globals.NumberSequence.new({
		globals.NumberSequenceKeypoint.new(0, 0.62),
		globals.NumberSequenceKeypoint.new(1, 1),
	})
	dust.Parent = dustAnchor
	local characterConnections: { any } = {}
	local humanoid: any = nil
	local characterRoot: any = nil
	local walked, nextStep, nextImpact = 0, 0, 0
	local lastPosition: any = nil
	local function groundCue(amount: number)
		if characterRoot and not preferences.reducedMotion and not preferences.lowEffects then
			dustAnchor.Position = characterRoot.Position - Vector3.new(0, 2.8, 0)
			dust:Emit(amount)
		end
	end
	local function characterChanged(character: any)
		for _, connection in characterConnections do
			connection:Disconnect()
		end
		table.clear(characterConnections)
		humanoid, characterRoot, lastPosition, walked = nil, nil, nil, 0
		dust:Clear()
		local function added(item: any)
			if not running or player.Character ~= character then
				return
			end
			if item.Name == "HumanoidRootPart" then
				characterRoot = item
			elseif item:IsA("Humanoid") and not humanoid then
				humanoid = item
				table.insert(
					characterConnections,
					item.StateChanged:Connect(function(_old: any, state: any)
						if player.Character ~= character or humanoid ~= item then
							return
						end
						local t = os.clock()
						if
							t >= nextImpact
							and (
								state == Enum.HumanoidStateType.Landed
								or state == Enum.HumanoidStateType.Jumping
							)
						then
							nextImpact = t + 0.16
							groundCue(if state == Enum.HumanoidStateType.Landed then 10 else 5)
						end
					end)
				)
			end
		end
		table.insert(characterConnections, character.ChildAdded:Connect(added))
		for _, item in character:GetChildren() do
			added(item)
		end
	end
	local characterConnection = player.CharacterAdded:Connect(characterChanged)
	if player.Character then
		characterChanged(player.Character)
	end
	local reserve, machine = Instance.new("Sound"), Instance.new("Sound")
	for _, entry in { { reserve, "Reserve" }, { machine, "Machine" } } do
		entry[1].Name, entry[1].SoundId, entry[1].Looped, entry[1].Volume =
			"MV_GS_" .. entry[2], (Audio :: any)[entry[2]], true, 0
		entry[1].Parent = game:GetService("SoundService")
		entry[1]:Play()
	end
	local spectralPitch = Instance.new("PitchShiftSoundEffect")
	spectralPitch.Name, spectralPitch.Octave, spectralPitch.Enabled, spectralPitch.Parent =
		"SpectralHarvestBed", 0.94, false, reserve
	for i = 1, 6 do
		local sound = Instance.new("Sound")
		sound.Name = "GoldenCue" .. i
		sound.Parent = game:GetService("SoundService")
		sounds[i] = sound
	end
	local nextSound = 1
	local function play(key: string, volume: number?)
		if not running or not preferences.audio or not preferences.effectsAudio then
			return
		end
		local id = (Audio :: any)[key]
		if not id then
			return
		end
		local sound = sounds[nextSound]
		nextSound = nextSound % #sounds + 1
		sound:Stop()
		sound.SoundId = id
		sound.Volume = volume or 0.18
		sound:Play()
	end
	local function clearTransient()
		for _, p in transient do
			p:Destroy()
		end
		table.clear(transient)
	end
	local function pulse(position: any, color: any, strong: boolean?)
		if not running or preferences.reducedMotion or preferences.lowEffects then
			return
		end
		if #transient >= 8 then
			clearTransient()
		end
		local part = Instance.new("Part")
		part.Name, part.Shape, part.Size, part.Position =
			"GoldenPulse", Enum.PartType.Ball, Vector3.new(0.4, 0.4, 0.4), position
		part.Material, part.Color, part.Transparency = Enum.Material.Neon, color, 0.48
		part.Anchored, part.CanCollide, part.CanQuery, part.CanTouch, part.CastShadow =
			true, false, false, false, false
		part.Parent = root
		table.insert(transient, part)
		services.tween
			:Create(
				part,
				globals.TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Size = Vector3.one * (if strong then 8 else 5), Transparency = 1 }
			)
			:Play()
		local emitter = Instance.new("ParticleEmitter")
		emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		emitter.Color = globals.ColorSequence.new(color)
		emitter.Rate, emitter.Lifetime, emitter.Speed =
			0, globals.NumberRange.new(0.3, 0.65), globals.NumberRange.new(2, 5)
		emitter.SpreadAngle, emitter.Size =
			globals.Vector2.new(180, 180), globals.NumberSequence.new(0.12)
		emitter.LightEmission = 0.6
		emitter.Parent = part
		emitter:Emit(if strong then 32 else 16)
		services.debris:AddItem(part, 1)
	end
	local function beam(a: any, b: any, color: any)
		if preferences.reducedMotion or preferences.lowEffects or not running then
			return
		end
		if #transient >= 6 then
			clearTransient()
		end
		local anchors = {}
		for _, position in { a, b } do
			local p = Instance.new("Part")
			p.Name = "GoldenBeamAnchor"
			p.Size = Vector3.one * 0.1
			p.Position = position
			p.Transparency = 1
			p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch = true, false, false, false
			p.Parent = root
			local attach = Instance.new("Attachment")
			attach.Parent = p
			table.insert(anchors, attach)
			table.insert(transient, p)
			services.debris:AddItem(p, 0.85)
		end
		local v = Instance.new("Beam")
		v.Attachment0, v.Attachment1 = anchors[1], anchors[2]
		v.Color, v.Width0, v.Width1 = globals.ColorSequence.new(color), 0.16, 0.08
		v.CurveSize0, v.CurveSize1, v.FaceCamera, v.LightEmission = 1.6, -1.6, true, 0.6
		v.Parent = anchors[1]
		services.debris:AddItem(v, 0.75)
	end
	local function seasonalAccent(position: any)
		if not seasonal or not running or preferences.reducedMotion or preferences.lowEffects then
			return
		end
		if #transient >= 8 then
			return
		end
		local anchor = Instance.new("Part")
		anchor.Name, anchor.Size, anchor.Position, anchor.Transparency =
			"SeasonalSparkAccent", Vector3.one * 0.1, position, 1
		anchor.Anchored, anchor.CanCollide, anchor.CanTouch, anchor.CanQuery, anchor.CastShadow =
			true, false, false, false, false
		anchor.Parent = root
		table.insert(transient, anchor)
		local sparks = Instance.new("ParticleEmitter")
		sparks.Texture, sparks.Color =
			"rbxasset://textures/particles/sparkles_main.dds",
			globals.ColorSequence.new(globals.Color3.fromRGB(167, 107, 255))
		sparks.Rate, sparks.Lifetime, sparks.Speed, sparks.LightEmission =
			0, globals.NumberRange.new(0.4, 0.8), globals.NumberRange.new(0.5, 1.2), 0.4
		sparks.Size, sparks.Parent = globals.NumberSequence.new(0.08), anchor
		sparks:Emit(12)
		services.debris:AddItem(anchor, 1)
	end
	local function transfer(a: any, b: any, strong: boolean)
		if preferences.reducedMotion or preferences.lowEffects or not running then
			return
		end
		for i = 1, (if strong then 5 else 3) do
			if #transient >= 8 then
				break
			end
			local orb = Instance.new("Part")
			orb.Name, orb.Shape, orb.Size, orb.Position =
				"ClaimEnergy",
				Enum.PartType.Ball,
				Vector3.one * 0.24,
				a + Vector3.new(0, i * 0.08, 0)
			orb.Color, orb.Material = Theme.colors.energy, Enum.Material.Neon
			orb.Anchored, orb.CanCollide, orb.CanTouch, orb.CanQuery, orb.CastShadow =
				true, false, false, false, false
			orb.Parent = root
			table.insert(transient, orb)
			services.tween
				:Create(
					orb,
					globals.TweenInfo.new(
						0.6,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.InOut,
						0,
						false,
						(i - 1) * 0.08
					),
					{ Position = b }
				)
				:Play()
			services.debris:AddItem(orb, 1.2)
		end
	end
	local accumulator: any = nil
	local function outputState()
		if not accumulator or not accumulator.Parent then
			return
		end
		local readout = accumulator:FindFirstChild("OutputState", true)
		if readout then
			readout.Text = if not productionKnown
				then "OPEN VAULT FOR OUTPUT"
				elseif claimReady then "OUTPUT READY"
				elseif bufferPositive then "OUTPUT BUFFERED"
				elseif producing then "PRODUCING ENERGY"
				else "ASSIGN A PRODUCER"
		end
		accumulator:SetAttribute("PresentedBufferFraction", bufferFraction)
		local record = animated[accumulator]
		if record then
			for _, bar in record.gauge or {} do
				bar.LocalTransparencyModifier = if (bar:GetAttribute("BufferStep") or 9) / 8
						<= bufferFraction
					then 0
					else 1
			end
		end
	end
	local function add(model: any, base: any, role: string): boolean
		if count >= 16 or animated[model] then
			return false
		end
		animated[model] = { base = base, role = role, offset = count * 0.71 }
		count += 1
		return true
	end
	-- Streaming can deliver Home after this controller starts in the Reserve.
	-- Register only these two authored idles; never poll for missing props.
	local function foundryItem(item: any)
		-- DescendantAdded may deliver streamed children after their Model.
		if
			(item:IsA("BasePart") and item:GetAttribute("BufferStep"))
			or (item:IsA("TextLabel") and item.Name == "OutputState")
		then
			local owner = item:FindFirstAncestor("EnergyAccumulator")
			local record = owner and animated[owner]
			if record and record.role == "accumulator" then
				if
					item:IsA("BasePart")
					and #record.gauge < 8
					and not table.find(record.gauge, item)
				then
					table.insert(record.gauge, item)
				elseif item:IsA("TextLabel") and record.originalReadout == nil then
					record.originalReadout = item.Text
				end
				outputState()
			end
			return
		end
		local parent = item.Parent
		if not parent or parent.Name ~= "VaultFoundry" or not item:IsA("Model") then
			return
		end
		local rootModel = parent.Parent
		if not rootModel or rootModel.Name ~= "MonsterVaultPresentation" then
			return
		end
		if item.Name == "EnergyAccumulator" then
			accumulator = item
			if add(item, item:GetPivot(), "accumulator") then
				local gauge = {}
				for _, bar in item:GetDescendants() do
					if bar:IsA("BasePart") and bar:GetAttribute("BufferStep") then
						table.insert(gauge, bar)
					end
				end
				animated[item].gauge = gauge
				local readout = item:FindFirstChild("OutputState", true)
				animated[item].originalReadout = readout and readout.Text
			end
			outputState() -- Restore the latest projection after stream-in.
		elseif item.Name == "EnergyRotor" then
			add(item, item:GetPivot(), "machine")
		elseif item.Name == "EntryDoorLeft" or item.Name == "EntryDoorRight" then
			add(item, item:GetPivot(), "door")
		end
	end
	local addedConnection = workspace.DescendantAdded:Connect(foundryItem)
	local removedConnection = workspace.DescendantRemoving:Connect(function(item: any)
		if item:IsA("BasePart") and item:GetAttribute("BufferStep") then
			local record = accumulator and animated[accumulator]
			local index = record and table.find(record.gauge, item)
			if index then
				table.remove(record.gauge, index)
			end
		end
		if animated[item] then
			animated[item] = nil
			count -= 1
		end
		if item == accumulator then
			accumulator = nil
		end
	end)
	local authored = workspace:FindFirstChild("MonsterVaultPresentation")
	if authored then
		for _, item in authored:GetDescendants() do
			foundryItem(item)
		end
	end
	local nextAmbient = 0
	local renderConnection = services.run.RenderStepped:Connect(function(deltaTime: number)
		local t = os.clock()
		local p = characterRoot
		if p and p.Parent ~= player.Character then
			p = nil
		end
		if p and p.Parent then
			local distance = if lastPosition then (p.Position - lastPosition).Magnitude else 0
			lastPosition = p.Position
			if
				humanoid
				and humanoid.MoveDirection.Magnitude > 0.1
				and humanoid.FloorMaterial ~= Enum.Material.Air
				and distance < 4
			then
				walked += distance
				if walked >= 3 and t >= nextStep then
					walked, nextStep = 0, t + 0.14
					groundCue(3)
				end
			else
				walked = 0
			end
		end
		for model, record in animated do
			if model.Parent then
				local base = if type(record.base) == "function" then record.base() else record.base
				if base then
					if record.role == "door" then
						local target = if p
								and (p.Position - Vector3.new(0, p.Position.Y, 108)).Magnitude
									< 18
							then 1
							else 0
						record.open = if preferences.reducedMotion
							then target
							else (record.open or 0) + (target - (record.open or 0)) * math.min(
								1,
								deltaTime * 9
							)
						model:PivotTo(
							base
								* CFrame.new(
									(model:GetAttribute("OpenOffsetX") or 0) * record.open,
									0,
									0
								)
						)
					elseif record.role == "machine" then
						if not preferences.reducedMotion then
							record.angle = (record.angle or 0)
								+ math.min(deltaTime, 0.1)
									* (if t < powerUntil then 2.1 elseif producing then 0.24 else 0)
						end
						model:PivotTo(
							base
								* (
									if preferences.reducedMotion
										then CFrame.identity
										else CFrame.Angles(0, record.angle or 0, 0)
								)
						)
					elseif record.role == "accumulator" then
						model:PivotTo(
							base
								* (
									if preferences.reducedMotion or not bufferPositive
										then CFrame.identity
										else CFrame.new(0, 0.025 * math.sin(t * 2.1), 0)
								)
						)
						for _, bar in record.gauge or {} do
							local step = bar:GetAttribute("BufferStep") or 9
							local lit = step / 8 <= bufferFraction or t < powerUntil
							bar.LocalTransparencyModifier = if not lit
								then 1
								elseif preferences.reducedMotion or preferences.lowEffects then 0
								else 0.12 + 0.12 * math.sin(t * 3 - step * 0.6)
						end
					else
						local reaction = 0
						if record.reaction then
							local progress = math.clamp(
								(t - record.reaction.started) / record.reaction.duration,
								0,
								1
							)
							reaction = math.sin(progress * math.pi) * record.reaction.tilt
							if progress >= 1 then
								record.reaction = nil
							end
						end
						local lift, pitch, yaw, roll = Feedback.pose(
							record.role,
							t,
							record.offset,
							reaction,
							preferences.reducedMotion or preferences.lowEffects
						)
						model:PivotTo(
							base * CFrame.new(0, lift, 0) * CFrame.Angles(pitch, yaw, roll)
						)
					end
				end
			end
		end
		if balanceAnimation then
			local alpha = math.clamp(
				(t - balanceAnimation.started) / math.max(0.01, balanceAnimation.duration),
				0,
				1
			)
			wallet(
				math.floor(
					balanceAnimation.from
						+ (balanceAnimation.to - balanceAnimation.from) * (1 - (1 - alpha) ^ 3)
				)
			)
			if alpha >= 1 then
				wallet(balanceAnimation.to)
				balanceAnimation = nil
			end
		end
		if t >= nextAmbient then
			nextAmbient = t + 0.1
			local homeBounds = Layout.world.HomeHubBounds
			local home = p
				and math.abs(p.Position.X - homeBounds.position[1]) < homeBounds.size[1] / 2
				and math.abs(p.Position.Z - homeBounds.position[3]) < homeBounds.size[3] / 2
			for model, record in animated do
				if
					p
					and model.Parent
					and not record.revealed
					and (record.role == "world" or record.role == "legendary")
					and (model:GetPivot().Position - p.Position).Magnitude < 22
				then
					record.revealed = true
					local key = if record.role == "legendary" then "Legendary" else "Creature"
					play(key, if key == "Creature" then 0.08 else 0.14)
					if key ~= "Creature" then
						pulse(
							model:GetPivot().Position + Vector3.new(0, 2, 0),
							Theme.colors.legendary,
							true
						)
						seasonalAccent(model:GetPivot().Position + Vector3.new(0, 2, 0))
					end
				end
			end
			reserve.Volume = if preferences.audio
					and preferences.ambienceAudio
					and not home
				then 0.08
				else 0
			machine.Volume = if preferences.audio
					and preferences.ambienceAudio
					and home
				then 0.07
				else 0
		end
	end)
	return {
		balance = function(value: number)
			if balanceAnimation and balanceAnimation.to ~= value then
				balanceAnimation = nil
			end
			if not balanceAnimation then
				wallet(value)
			end
		end,
		seasonal = function(value: boolean)
			seasonal = value
			spectralPitch.Enabled = value
			reserve.PlaybackSpeed = if value then 0.96 else 1
		end,
		seasonalAccent = seasonalAccent,
		production = function(state: any)
			producing, bufferPositive, claimReady = false, false, false
			bufferFraction = 0
			productionKnown = state ~= nil
			if state then
				bufferPositive, claimReady = state.bufferMilli > 0, state.bufferMilli >= 1000
				bufferFraction =
					math.clamp(state.bufferMilli / math.max(1, state.bufferCapacityMilli), 0, 1)
				for _, row in state.creatures do
					producing = producing or row.productionSlotId ~= nil
				end
			end
			outputState()
		end,
		play = play,
		pulse = pulse,
		beam = beam,
		arrival = function()
			play("UI", 0.12)
			if characterRoot then
				pulse(characterRoot.Position - Vector3.new(0, 1.5, 0), Theme.colors.energy)
			end
		end,
		add = add,
		react = function(model: any, cue: string)
			local record = animated[model]
			if
				record
				and (cue == "Engage" or cue == "Failure")
				and not preferences.reducedMotion
				and not preferences.lowEffects
			then
				record.reaction = {
					started = os.clock(),
					duration = if cue == "Failure" then 0.28 else 0.42,
					tilt = if cue == "Failure" then -0.15 else 0.1,
				}
			end
		end,
		root = root,
		remove = function(model: any)
			if animated[model] then
				animated[model] = nil
				count -= 1
			end
		end,
		claim = function(amount: number, balance: number)
			local arc = Feedback.claim(amount, balance, preferences.reducedMotion)
			arc.started = os.clock()
			balanceAnimation = if arc.duration > 0 then arc else nil
			if not balanceAnimation then
				wallet(balance)
			end
			if amount > 0 then
				clearTransient()
				powerUntil = os.clock() + arc.duration
				play("Energy", 0.22)
				local character = player.Character
				local destination = character and character:FindFirstChild("HumanoidRootPart")
				if accumulator and accumulator.Parent and destination then
					pulse(
						accumulator:GetPivot().Position + Vector3.new(0, 2, 0),
						Theme.colors.energy,
						arc.strong
					)
					beam(
						accumulator:GetPivot().Position + Vector3.new(0, 2, 0),
						destination.Position,
						Theme.colors.energy
					)
					transfer(
						accumulator:GetPivot().Position + Vector3.new(0, 2, 0),
						destination.Position,
						arc.strong
					)
				end
			end
		end,
		isCounting = function(): boolean
			return balanceAnimation ~= nil
		end,
		preferencesChanged = function()
			if preferences.reducedMotion or preferences.lowEffects then
				dust:Clear()
			end
			if preferences.reducedMotion then
				for _, record in animated do
					record.reaction = nil
				end
			end
			if preferences.reducedMotion and balanceAnimation then
				wallet(balanceAnimation.to)
				balanceAnimation = nil
			end
			if not preferences.audio or not preferences.effectsAudio then
				for _, sound in sounds do
					sound:Stop()
				end
			end
			if not preferences.audio or not preferences.ambienceAudio then
				reserve.Volume, machine.Volume = 0, 0
			end
			if preferences.reducedMotion or preferences.lowEffects then
				clearTransient()
			end
		end,
		clear = function()
			clearTransient()
			balanceAnimation = nil
		end,
		stop = function()
			running = false
			renderConnection:Disconnect()
			addedConnection:Disconnect()
			removedConnection:Disconnect()
			characterConnection:Disconnect()
			for _, connection in characterConnections do
				connection:Disconnect()
			end
			table.clear(characterConnections)
			clearTransient()
			for model, record in animated do
				if model.Parent then
					local base = if type(record.base) == "function"
						then record.base()
						else record.base
					if base then
						model:PivotTo(base)
					end
					for _, bar in record.gauge or {} do
						bar.LocalTransparencyModifier = 0
					end
					if record.role == "accumulator" then
						model:SetAttribute("PresentedBufferFraction", nil)
						local readout = model:FindFirstChild("OutputState", true)
						if readout then
							readout.Text = record.originalReadout or "ASSIGN A PRODUCER"
						end
					end
				end
			end
			table.clear(animated)
			for _, sound in sounds do
				sound:Destroy()
			end
			reserve:Destroy()
			machine:Destroy()
			root:Destroy()
		end,
	}
end
return Sensory
