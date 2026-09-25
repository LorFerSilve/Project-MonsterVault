--!strict

local HttpService = game:GetService("HttpService")
local ServerComposition = require(script.Parent.ServerComposition)

local composition = ServerComposition.new({
	sink = function(record)
		print(HttpService:JSONEncode(record))
	end,
	unixSeconds = os.time,
	monotonicSeconds = os.clock,
})

composition.start()
game:BindToClose(function()
	composition.shutdown(25)
end)
