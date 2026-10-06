--!strict
-- One render owner for bounded creature/machine motion and confirmed count-up.
local globals: any = getfenv()
local Instance, Enum, CFrame, Vector3 =
	globals.Instance, globals.Enum, globals.CFrame, globals.Vector3
local Audio = require(game:GetService("ReplicatedStorage").MonsterVault.Shared.config.GoldenAudio)
local Feedback = require(script.Parent.GoldenFeedback)
local Theme = require(script.Parent.GoldenTheme)
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
	local seasonal = false
	local services = {
		tween = game:GetService("TweenService"),
		debris = game:GetService("Debris"),
		run = game:GetService("RunService"),
	}
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
			add(item, item:GetPivot(), "accumulator")
		elseif item.Name == "EnergyRotor" then
			add(item, item:GetPivot(), "machine")
		end
	end
	local addedConnection = workspace.DescendantAdded:Connect(foundryItem)
	local removedConnection = workspace.DescendantRemoving:Connect(function(item: any)
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
		for model, record in animated do
			if model.Parent then
				local base = if type(record.base) == "function" then record.base() else record.base
				if base then
					if record.role == "machine" then
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
					else
						model:PivotTo(
							base
								* (
									if preferences.reducedMotion
										then CFrame.identity
										else CFrame.new(
											0,
											0.06 * math.sin(t * 1.7 + record.offset),
											0
										) * CFrame.Angles(
											0,
											0.035 * math.sin(t * 0.6 + record.offset),
											0
										)
								)
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
			local character = player.Character
			local p = character and character:FindFirstChild("HumanoidRootPart")
			local home = p and p.Position.Z > 95 and p.Position.Z < 165
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
			if state then
				bufferPositive, claimReady = state.bufferMilli > 0, state.bufferMilli >= 1000
				for _, row in state.creatures do
					producing = producing or row.productionSlotId ~= nil
				end
			end
			if accumulator and accumulator.Parent then
				local readout = accumulator:FindFirstChild("OutputState", true)
				if readout then
					readout.Text = if claimReady
						then "OUTPUT READY"
						elseif bufferPositive then "OUTPUT BUFFERED"
						elseif producing then "PRODUCING ENERGY"
						else "ASSIGN A PRODUCER"
				end
			end
		end,
		play = play,
		pulse = pulse,
		beam = beam,
		add = add,
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
			clearTransient()
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
