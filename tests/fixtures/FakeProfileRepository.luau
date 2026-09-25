--!strict

local FakeProfileRepository = {}

local function copy(value: any, seen: { [any]: any }?): any
	if type(value) ~= "table" then
		return value
	end
	local memo = seen or {}
	if memo[value] then
		return memo[value]
	end
	local result = {}
	memo[value] = result
	for key, child in value do
		result[copy(key, memo)] = copy(child, memo)
	end
	return result
end

function FakeProfileRepository.new()
	local entries = {}
	local failures = {}
	local callCount = 0
	local replayTransform = false
	local beforeTransform: (() -> ())? = nil

	local function update(key: string, transform: (any, { [string]: any }) -> any)
		callCount += 1
		if #failures > 0 then
			return table.remove(failures, 1)
		end
		local entry = entries[key] or { value = nil, metadata = {} }
		if beforeTransform then
			beforeTransform()
		end
		local decision = transform(copy(entry.value), copy(entry.metadata))
		if replayTransform then
			decision = transform(copy(entry.value), copy(entry.metadata))
		end
		if decision.kind == "abort" then
			return { status = "aborted", reason = decision.reason }
		end
		assert(decision.kind == "write", "invalid repository decision")
		entries[key] = { value = copy(decision.value), metadata = copy(decision.metadata) }
		return {
			status = "ok",
			value = copy(entries[key].value),
			metadata = copy(entries[key].metadata),
		}
	end

	return {
		update = update,
		seed = function(key: string, value: any, metadata: { [string]: any }?)
			entries[key] = { value = copy(value), metadata = copy(metadata or {}) }
		end,
		read = function(key: string)
			return copy(entries[key])
		end,
		failNext = function(result: any)
			table.insert(failures, result)
		end,
		setReplayTransform = function(value: boolean)
			replayTransform = value
		end,
		setBeforeTransform = function(callback: (() -> ())?)
			beforeTransform = callback
		end,
		calls = function(): number
			return callCount
		end,
	}
end

return FakeProfileRepository
