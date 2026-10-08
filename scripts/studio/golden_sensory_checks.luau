--!strict
-- Isolated native client presentation evidence; claim values are fixtures, not
-- a purchase/claim or an owner profile. Run with ClientMain disabled, then restore.
return function(): any
	local globals: any = getfenv()
	local Instance, CFrame = globals.Instance, globals.CFrame
	local players, run = game:GetService("Players"), game:GetService("RunService")
	assert(run:IsStudio() and run:IsClient(), "native Studio client required")
	local player = players.LocalPlayer
	local root = workspace.MonsterVaultPresentation.VaultFoundry
	local original = root.EnergyAccumulator
	local originalCF = original:GetPivot()
	local originalReadout = original:FindFirstChild("OutputState", true).Text
	local template = original:Clone()
	local soundService = game:GetService("SoundService")
	local originalSounds = #soundService:GetChildren()
	local preferences = {
		reducedMotion = false,
		lowEffects = false,
		audio = false,
		effectsAudio = false,
		ambienceAudio = false,
	}
	local wallet = -1
	local sensory = require(player.PlayerScripts.MonsterVaultClient.presentation.GoldenSensory).new(
		player,
		preferences,
		function(value: number)
			wallet = value
		end
	)
	local models: { any } = {}
	local function frames(count: number)
		for _ = 1, count do
			run.RenderStepped:Wait()
		end
	end
	local evidence: any = { isolatedClient = true, claimAmountFixture = 27, checks = {} }
	local ok, failure = xpcall(function()
		local creature = game.ReplicatedStorage.MonsterVault.PresentationAssets.Mossbud:Clone()
		creature.Parent = workspace
		table.insert(models, creature)
		local base = CFrame.new(0, 0.2, -16)
		creature:PivotTo(base)
		assert(sensory.add(creature, base, "world"))
		frames(5)
		assert(creature:GetPivot() ~= base, "native idle pose")
		evidence.checks.idle = true
		sensory.react(creature, "Engage")
		frames(8)
		local pitch = (base:Inverse() * creature:GetPivot()):ToOrientation()
		assert(pitch > 0.03, "native engage reaction")
		evidence.checks.engageReaction = true
		preferences.lowEffects = true
		sensory.preferencesChanged()
		frames(2)
		assert(creature:GetPivot() == base, "low effects exact authored framing")
		evidence.checks.lowEffects = true
		preferences.lowEffects = false
		local state = {
			bufferMilli = 720000,
			bufferCapacityMilli = 1440000,
			creatures = { { productionSlotId = "production/1" } },
		}
		sensory.production(state)
		frames(2)
		local function lit(model: any): number
			local n = 0
			for _, bar in model.BufferGauge:GetChildren() do
				if bar.LocalTransparencyModifier < 1 then
					n += 1
				end
			end
			return n
		end
		assert(
			lit(original) == 4 and original:GetAttribute("PresentedBufferFraction") == 0.5,
			"half-full projected meter"
		)
		assert(
			original:FindFirstChild("OutputState", true).Text == "OUTPUT READY",
			"claim-ready semantic readout"
		)
		evidence.checks.projectedBuffer = true
		local bar, parent = original.BufferGauge.BufferSegment1, original.BufferGauge
		bar.Parent = nil
		bar.Parent = parent
		frames(2)
		assert(lit(original) == 4, "fragmented gauge restores current projection")
		evidence.checks.partialStream = true
		original.Parent = nil
		template.Parent = root
		frames(2)
		assert(
			lit(template) == 4
				and template:FindFirstChild("OutputState", true).Text == "OUTPUT READY",
			"whole model stream-in restores latest projection without another snapshot"
		)
		evidence.checks.modelStream = true
		local accepted = 0
		for _ = 1, 12 do
			local m = Instance.new("Model")
			m.Parent = workspace
			table.insert(models, m)
			if sensory.add(m, CFrame.identity, "world") then
				accepted += 1
			end
		end
		assert(accepted == 11, "four authored records and one creature leave eleven slots")
		evidence.checks.motionBound16 = true
		sensory.claim(27, 127)
		frames(2)
		assert(lit(template) == 8, "confirmed fixture claim activates the existing meter")
		evidence.checks.claimResponse = true
		sensory.production(nil)
		assert(
			template:FindFirstChild("OutputState", true).Text == "OPEN VAULT FOR OUTPUT",
			"missing or stale projection cannot imply an empty wallet or unassigned production"
		)
		evidence.checks.unknownOutput = true
		preferences.reducedMotion = true
		sensory.preferencesChanged()
		frames(2)
		assert(
			wallet == 127 and creature:GetPivot() == base,
			"reduced claim retains the confirmed total and static creature"
		)
		assert(
			#sensory.root:GetChildren() == 1,
			"reduced claim leaves only the rate-zero ground anchor"
		)
		evidence.checks.reducedMotion = true
	end, debug.traceback)
	sensory.stop()
	local restored = template:GetPivot() == originalCF
		and template:FindFirstChild("OutputState", true).Text == originalReadout
	local clean = not workspace:FindFirstChild("MonsterVaultLocalEffects")
		and #soundService:GetChildren() == originalSounds
	template:Destroy()
	original:PivotTo(originalCF)
	original.Parent = root
	for _, m in models do
		m:Destroy()
	end
	assert(ok, failure)
	assert(restored, "shutdown restores authored accumulator pose/readout")
	assert(clean, "shutdown leaves no local effects/sounds")
	evidence.checks.cleanup = true
	evidence.passed = true
	return evidence
end
