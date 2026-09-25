--!strict

local WireValidation = {}

local ENVELOPE_KEYS = table.freeze({
	protocolVersion = true,
	routeId = true,
	requestId = true,
	expectedRevision = true,
	payload = true,
})

local function finiteInteger(value: any, minimum: number): boolean
	return type(value) == "number"
		and value == value
		and math.abs(value) < math.huge
		and value % 1 == 0
		and value >= minimum
end

function WireValidation.envelope(value: any): (boolean, string?)
	if type(value) ~= "table" then
		return false, "ENVELOPE"
	end
	local count = 0
	for key in value do
		count += 1
		if count > 5 or not ENVELOPE_KEYS[key] then
			return false, "ENVELOPE"
		end
	end
	if value.protocolVersion ~= 1 then
		return false, "PROTOCOL"
	end
	if type(value.routeId) ~= "string" or #value.routeId > 64 or #value.routeId < 3 then
		return false, "ROUTE"
	end
	if
		type(value.requestId) ~= "string"
		or #value.requestId < 1
		or #value.requestId > 64
		or string.match(value.requestId, "^[%w_%-]+$") == nil
	then
		return false, "REQUEST_ID"
	end
	if value.expectedRevision ~= nil and not finiteInteger(value.expectedRevision, 0) then
		return false, "REVISION"
	end
	if type(value.payload) ~= "table" then
		return false, "PAYLOAD"
	end
	return true, nil
end

local function bounded(value: any, depth: number, seen: { [any]: boolean }, budget: any): boolean
	if depth > 5 or budget.nodes >= 128 then
		return false
	end
	budget.nodes += 1
	local kind = type(value)
	if kind == "string" then
		budget.bytes += 6 * #value + 2
		return #value <= 256 and budget.bytes <= budget.limit
	elseif kind == "number" then
		budget.bytes += 32
		return value == value and math.abs(value) < math.huge and budget.bytes <= budget.limit
	elseif kind == "boolean" then
		budget.bytes += 5
		return budget.bytes <= budget.limit
	elseif kind ~= "table" or seen[value] then
		return false
	end
	seen[value] = true
	local entries = 0
	local numeric = 0
	local highest = 0
	local stringKeys = 0
	for key, child in value do
		entries += 1
		if entries > 32 then
			return false
		end
		if type(key) == "string" then
			if #key > 64 then
				return false
			end
			stringKeys += 1
			budget.bytes += 6 * #key + 4
		elseif finiteInteger(key, 1) then
			numeric += 1
			highest = math.max(highest, key)
			budget.bytes += 36
		else
			return false
		end
		if budget.bytes > budget.limit or not bounded(child, depth + 1, seen, budget) then
			return false
		end
	end
	seen[value] = nil
	return numeric == 0 or (stringKeys == 0 and highest == numeric)
end

function WireValidation.payload(value: any, limit: number?): boolean
	return type(value) == "table"
		and bounded(value, 0, {}, { nodes = 0, bytes = 2, limit = limit or 4096 })
end

function WireValidation.equal(left: any, right: any): boolean
	if type(left) ~= type(right) then
		return false
	end
	if type(left) ~= "table" then
		return left == right
	end
	for key, child in left do
		if not WireValidation.equal(child, right[key]) then
			return false
		end
	end
	for key in right do
		if left[key] == nil then
			return false
		end
	end
	return true
end

function WireValidation.copy(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local result = {}
	for key, child in value do
		result[key] = WireValidation.copy(child)
	end
	return result
end

return table.freeze(WireValidation)
