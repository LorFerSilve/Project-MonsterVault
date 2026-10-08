--!strict
-- A removable Studio/staging art preview. No dates, remotes or event entitlement.
local globals: any = getfenv()
local Instance, Color3 = globals.Instance, globals.Color3
local Seasonal = {}
Seasonal.label = "SPECTRAL HARVEST · ART PREVIEW"
Seasonal.accent = Color3.fromRGB(255, 138, 52)
function Seasonal.new(preferences: any, changed: (boolean) -> ())
	local lighting = game:GetService("Lighting")
	local running, enabled = true, false
	local root: any = nil
	local grading: any = nil
	local saved: any = nil
	local function quality()
		if not root then
			return
		end
		for _, item in root:GetDescendants() do
			if item:IsA("ParticleEmitter") then
				item.Enabled = not preferences.lowEffects and not preferences.reducedMotion
				if not item.Enabled then
					item:Clear()
				end
			elseif item:IsA("PointLight") then
				item.Enabled = not preferences.lowEffects
			end
		end
	end
	local function off()
		if root then
			root:Destroy()
			root = nil
		end
		if grading then
			grading:Destroy()
			grading = nil
		end
		if saved then
			for object, properties in saved do
				if object.Parent then
					for key, value in properties do
						(object :: any)[key] = value
					end
				end
			end
			saved = nil
		end
	end
	local function set(value: boolean): boolean
		if not running or not game:GetService("RunService"):IsStudio() then
			return false
		end
		if value == enabled then
			return true
		end
		if value then
			local assets = game:GetService("ReplicatedStorage").MonsterVault
				:FindFirstChild("SeasonalAssets")
			local prefab = assets and assets:FindFirstChild("Halloween2026")
			if not prefab then
				return false
			end
			root = Instance.new("Folder")
			root.Name = "MonsterVaultSeasonal"
			local scene = prefab:Clone()
			scene.Parent = root
			root.Parent = workspace
			saved = {
				[lighting] = {
					ClockTime = lighting.ClockTime,
					Ambient = lighting.Ambient,
					OutdoorAmbient = lighting.OutdoorAmbient,
					ExposureCompensation = lighting.ExposureCompensation,
				},
			}
			lighting.ClockTime = 18.4
			lighting.Ambient, lighting.OutdoorAmbient =
				Color3.fromRGB(104, 107, 143), Color3.fromRGB(136, 138, 163)
			lighting.ExposureCompensation = 0.38
			local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
			if atmosphere then
				saved[atmosphere] = {
					Density = atmosphere.Density,
					Color = atmosphere.Color,
					Decay = atmosphere.Decay,
					Haze = atmosphere.Haze,
				}
				atmosphere.Density, atmosphere.Haze = 0.34, 1.65
				atmosphere.Color, atmosphere.Decay =
					Color3.fromRGB(184, 174, 209), Color3.fromRGB(103, 101, 133)
			end
			grading = Instance.new("ColorCorrectionEffect")
			grading.Name, grading.TintColor, grading.Contrast, grading.Saturation =
				"MVHalloweenGrading", Color3.fromRGB(240, 231, 255), 0.025, -0.035
			grading.Parent = lighting
			enabled = true
			quality()
		else
			off()
			enabled = false
		end
		changed(enabled)
		return true
	end
	return {
		set = set,
		isEnabled = function(): boolean
			return enabled
		end,
		preferencesChanged = quality,
		stop = function()
			if not running then
				return
			end
			running = false
			off()
			if enabled then
				enabled = false
				changed(false)
			end
		end,
	}
end
return Seasonal
