--!strict

local HttpService = game:GetService("HttpService")
local ClientComposition = require(script.Parent.ClientComposition)

local composition = ClientComposition.new({
	sink = function(record)
		print(HttpService:JSONEncode(record))
	end,
	unixSeconds = os.time,
})

composition.start()
