--!strict

local RouteRegistry = {}

local function helloPayload(payload: any, expectedRevision: any): boolean
	if expectedRevision ~= nil or type(payload) ~= "table" then
		return false
	end
	for key, value in payload do
		if key ~= "touch" and key ~= "gamepad" and key ~= "reducedMotion" then
			return false
		end
		if type(value) ~= "boolean" then
			return false
		end
	end
	return true
end

local function resyncPayload(payload: any, expectedRevision: any): boolean
	if expectedRevision ~= nil or type(payload) ~= "table" then
		return false
	end
	for key, value in payload do
		if key ~= "domain" or value ~= "session" then
			return false
		end
	end
	return true
end

function RouteRegistry.new(RouteIds: any)
	local contracts: { [string]: any } = {}
	local handlers: { [string]: any } = {}
	local cosmeticSchemas: { [string]: any } = {}
	local sealed = false
	for routeId, class in RouteIds.commandClassById do
		contracts[routeId] = table.freeze({
			id = routeId,
			direction = "ClientToServer",
			class = class,
			requiresReady = class ~= "A",
			persistentValue = class == "C"
				or class == "D"
				or routeId == RouteIds.commands.settingsUpdatePreferences,
			retryAllowed = class == "A",
			schema = if routeId == RouteIds.commands.sessionClientHello
				then helloPayload
				else if routeId == RouteIds.commands.sessionRequestResync
					then resyncPayload
					else nil,
		})
	end

	local function bind(routeId: string, handler: (any, any) -> any)
		assert(not sealed, "route registry sealed")
		assert(contracts[routeId] ~= nil, "unknown command route")
		assert(contracts[routeId].schema ~= nil, "route schema reserved for later phase")
		assert(handlers[routeId] == nil, "duplicate route handler")
		assert(type(handler) == "function", "handler required")
		handlers[routeId] = handler
	end

	local function bindCosmetic(routeId: string, schema: (any) -> boolean)
		assert(not sealed, "route registry sealed")
		assert(RouteIds.isUnreliableEvent(routeId), "unknown cosmetic route")
		assert(cosmeticSchemas[routeId] == nil, "duplicate cosmetic schema")
		assert(type(schema) == "function", "cosmetic schema required")
		cosmeticSchemas[routeId] = schema
	end

	return {
		bind = bind,
		bindCosmetic = bindCosmetic,
		seal = function()
			sealed = true
		end,
		get = function(routeId: string)
			return contracts[routeId], handlers[routeId]
		end,
		cosmeticSchema = function(routeId: string)
			return cosmeticSchemas[routeId]
		end,
	}
end

return RouteRegistry
