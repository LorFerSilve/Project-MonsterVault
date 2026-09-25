--!strict

local RouteIds =
	require(game:GetService("ReplicatedStorage").MonsterVault.Shared.contracts.RouteIds)
local StartupPlan =
	require(game:GetService("ReplicatedStorage").MonsterVault.Shared.util.StartupPlan)

local StartupValidator = {}

local function checkRoutes(
	groups: { [string]: { [string]: string } },
	classes: { [string]: string }
)
	local seen = {}
	local commandSet = {}
	for groupName, routes in groups do
		assert(
			groupName == "commands" or groupName == "events" or groupName == "unreliableEvents",
			"unknown route group"
		)
		for _, routeId in routes do
			assert(
				type(routeId) == "string" and string.match(routeId, "^[A-Z][%w]+%.[A-Z][%w]+$"),
				"invalid route ID"
			)
			assert(not seen[routeId], "duplicate route ID: " .. routeId)
			seen[routeId] = true
			if groupName == "commands" then
				commandSet[routeId] = true
			end
		end
	end
	for routeId in commandSet do
		local class = classes[routeId]
		assert(
			class == "A" or class == "B" or class == "C" or class == "D",
			"missing command class: " .. routeId
		)
	end
	for routeId in classes do
		assert(commandSet[routeId], "class for unknown command: " .. routeId)
	end
end

function StartupValidator.validate(
	services: { StartupPlan.Service },
	routeGroups: { [string]: { [string]: string } }?,
	commandClasses: { [string]: string }?
)
	checkRoutes(routeGroups or {
		commands = RouteIds.commands,
		events = RouteIds.events,
		unreliableEvents = RouteIds.unreliableEvents,
	}, commandClasses or RouteIds.commandClassById)
	return StartupPlan.prepare(services)
end

return StartupValidator
