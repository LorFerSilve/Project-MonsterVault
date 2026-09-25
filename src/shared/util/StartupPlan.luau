--!strict

-- Pure lifecycle planning. Importing a feature module never starts it.
export type Service = {
	id: string,
	dependencies: { string },
	start: () -> (),
	stop: () -> (),
}

local StartupPlan = {}

function StartupPlan.prepare(services: { Service }): { Service }
	local byId: { [string]: Service } = {}
	local ids = {}
	for _, service in services do
		assert(
			type(service.id) == "string" and string.match(service.id, "^[%w_]+$"),
			"invalid service id"
		)
		assert(byId[service.id] == nil, "duplicate service registration: " .. service.id)
		assert(type(service.dependencies) == "table", "missing dependencies: " .. service.id)
		assert(
			type(service.start) == "function" and type(service.stop) == "function",
			"missing lifecycle: " .. service.id
		)
		byId[service.id] = service
		table.insert(ids, service.id)
	end
	table.sort(ids)

	local state: { [string]: number } = {}
	local ordered = {}
	local function visit(id: string)
		assert(byId[id] ~= nil, "missing service dependency: " .. id)
		assert(state[id] ~= 1, "service dependency cycle: " .. id)
		if state[id] == 2 then
			return
		end
		state[id] = 1
		local service = byId[id]
		local seen = {}
		local dependencies = table.clone(service.dependencies)
		table.sort(dependencies)
		for _, dependency in dependencies do
			assert(type(dependency) == "string" and dependency ~= "", "invalid dependency: " .. id)
			assert(not seen[dependency], "duplicate dependency: " .. id .. " -> " .. dependency)
			seen[dependency] = true
			visit(dependency)
		end
		state[id] = 2
		table.insert(ordered, service)
	end
	for _, id in ids do
		visit(id)
	end
	return ordered
end

function StartupPlan.start(ordered: { Service }): () -> { string }
	local started = {}
	for _, service in ordered do
		local ok, failure = pcall(service.start :: () -> any)
		if not ok then
			-- A failed start may have acquired resources before throwing.
			pcall(service.stop)
			for index = #started, 1, -1 do
				pcall(started[index].stop)
			end
			error("service start failed: " .. service.id .. ": " .. tostring(failure), 2)
		end
		table.insert(started, service)
	end

	local stopped = false
	return function(): { string }
		if stopped then
			return {}
		end
		stopped = true
		local failures = {}
		for index = #started, 1, -1 do
			local service = started[index]
			local ok, failure = pcall(service.stop :: () -> any)
			if not ok then
				table.insert(failures, service.id .. ": " .. tostring(failure))
			end
		end
		return failures
	end
end

return StartupPlan
