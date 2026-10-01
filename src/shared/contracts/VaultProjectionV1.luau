--!strict

-- Bounded owner-only Vault projection and the exact-instance Class C command.
local VaultProjectionV1 = {}
local function integer(value: any, max: number): boolean
	return type(value) == "number" and value >= 0 and value <= max and value % 1 == 0
end
local function id(value: any): boolean
	return type(value) == "string" and #value > 0 and #value <= 128
end

function VaultProjectionV1.validResolve(payload: any, expectedRevision: any): boolean
	if
		type(payload) ~= "table"
		or not id(payload.creatureInstanceId)
		or not integer(expectedRevision, 9_007_199_254_740_991)
		or expectedRevision < 1
	then
		return false
	end
	for key in payload do
		if key ~= "creatureInstanceId" then
			return false
		end
	end
	return true
end

function VaultProjectionV1.validSnapshot(payload: any): boolean
	if
		type(payload) ~= "table"
		or payload.domain ~= "vault"
		or not integer(payload.revision, 9_007_199_254_740_991)
		or payload.revision < 1
		or type(payload.state) ~= "table"
	then
		return false
	end
	for key in payload do
		if key ~= "domain" and key ~= "revision" and key ~= "state" then
			return false
		end
	end
	local state = payload.state
	for _, key in { "capacity", "ordinaryUsed", "overflowHeldCount" } do
		if not integer(state[key], 2048) then
			return false
		end
	end
	if
		state.ordinaryUsed > state.capacity
		or state.ordinaryUsed + state.overflowHeldCount > 2048
		or type(state.components) ~= "table"
		or type(state.hasMore) ~= "boolean"
		or type(state.overflowCreatureInstanceIds) ~= "table"
		or #state.overflowCreatureInstanceIds > 5
	then
		return false
	end
	local sum = 0
	for _, key in { "base", "earned", "commercial", "temporary" } do
		if not integer(state.components[key], 2048) then
			return false
		end
		sum += state.components[key]
	end
	for key in state.components do
		if key ~= "base" and key ~= "earned" and key ~= "commercial" and key ~= "temporary" then
			return false
		end
	end
	if sum ~= state.capacity then
		return false
	end
	local chars, previous = 0, ""
	for index, value in state.overflowCreatureInstanceIds do
		if
			not integer(index, #state.overflowCreatureInstanceIds)
			or index < 1
			or not id(value)
			or value <= previous
		then
			return false
		end
		chars += #value
		previous = value
	end
	if
		chars > 480
		or #state.overflowCreatureInstanceIds > state.overflowHeldCount
		or (state.hasMore and #state.overflowCreatureInstanceIds == 0)
	then
		return false
	end
	for key in state do
		if
			key ~= "capacity"
			and key ~= "ordinaryUsed"
			and key ~= "overflowHeldCount"
			and key ~= "components"
			and key ~= "overflowCreatureInstanceIds"
			and key ~= "hasMore"
		then
			return false
		end
	end
	return true
end

return table.freeze(VaultProjectionV1)
