--!strict
-- Platform preferences are presentation input, never profile or event truth.
local Preferences = {}
function Preferences.reduced(platform: boolean, manual: boolean): boolean
	return platform or manual
end
function Preferences.bind(guiService: any, state: any, changed: () -> ())
	local manual = false
	local function sync()
		state.reducedMotion = Preferences.reduced(guiService.ReducedMotionEnabled, manual)
		changed()
	end
	local connection = guiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(sync)
	sync()
	return {
		toggleReduced = function()
			manual = not manual
			sync()
		end,
		stop = function()
			connection:Disconnect()
		end,
	}
end
return Preferences
