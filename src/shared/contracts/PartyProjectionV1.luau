--!strict

local PartyProjectionV1 = {}

local function integer(value: any, minimum: number): boolean
	return type(value) == "number" and value >= minimum and value < 2 ^ 53 and value % 1 == 0
end
local function id(value: any): boolean
	return type(value) == "string" and #value > 0 and #value <= 48
end
local function keys(value: any, allowed: any): boolean
	if type(value) ~= "table" then
		return false
	end
	for key in value do
		if not allowed[key] then
			return false
		end
	end
	return true
end
local function array(value: any, maximum: number): boolean
	if type(value) ~= "table" or #value > maximum then
		return false
	end
	local n = 0
	for key in value do
		if not integer(key, 1) or key > #value then
			return false
		end
		n += 1
	end
	return n == #value
end
local function remaining(value: any): boolean
	return type(value) == "number" and value >= 0 and value < 2 ^ 53
end

function PartyProjectionV1.validCreate(payload: any, expected: any): boolean
	return expected == nil and keys(payload, {})
end
function PartyProjectionV1.validInvite(payload: any, expected: any): boolean
	return integer(expected, 1)
		and keys(payload, { targetUserId = true })
		and integer(payload.targetUserId, 1)
end
function PartyProjectionV1.validRespond(payload: any, expected: any): boolean
	return integer(expected, 1)
		and keys(payload, { invitationId = true, accept = true })
		and id(payload.invitationId)
		and type(payload.accept) == "boolean"
end
function PartyProjectionV1.validParty(payload: any, expected: any): boolean
	return integer(expected, 1) and keys(payload, { partyId = true }) and id(payload.partyId)
end
function PartyProjectionV1.validRemove(payload: any, expected: any): boolean
	return integer(expected, 1)
		and keys(payload, { partyId = true, targetUserId = true })
		and id(payload.partyId)
		and integer(payload.targetUserId, 1)
end
function PartyProjectionV1.validInvitePolicy(payload: any, expected: any): boolean
	return expected == nil
		and keys(payload, { allowInvites = true })
		and type(payload.allowInvites) == "boolean"
end
function PartyProjectionV1.validSnapshot(payload: any): boolean
	if
		not keys(payload, { domain = true, revision = true, state = true })
		or payload.domain ~= "party"
		or not integer(payload.revision, 1)
	then
		return false
	end
	local state = payload.state
	if
		not keys(state, { allowInvites = true, party = true, incoming = true, rejoin = true })
		or type(state.allowInvites) ~= "boolean"
		or not array(state.incoming, 2)
	then
		return false
	end
	if state.party ~= nil then
		local party = state.party
		if
			state.rejoin ~= nil
			or not keys(
				party,
				{ partyId = true, revision = true, leaderUserId = true, members = true }
			)
			or not id(party.partyId)
			or not integer(party.revision, 1)
			or not integer(party.leaderUserId, 1)
			or not array(party.members, 4)
			or #party.members == 0
		then
			return false
		end
		local seen = {}
		local leaderPresent = false
		for _, member in party.members do
			if
				not keys(member, { userId = true, present = true })
				or not integer(member.userId, 1)
				or type(member.present) ~= "boolean"
				or seen[member.userId]
			then
				return false
			end
			seen[member.userId] = true
			if member.userId == party.leaderUserId then
				leaderPresent = member.present
			end
		end
		if not leaderPresent then
			return false
		end
	end
	if state.rejoin ~= nil then
		local rejoin = state.rejoin
		if
			not keys(rejoin, { partyId = true, revision = true, expiresAt = true })
			or not id(rejoin.partyId)
			or not integer(rejoin.revision, 1)
			or not remaining(rejoin.expiresAt)
		then
			return false
		end
	end
	local seen = {}
	for _, invite in state.incoming do
		if
			not keys(invite, {
				invitationId = true,
				partyId = true,
				partyRevision = true,
				inviterUserId = true,
				expiresAt = true,
				status = true,
			})
			or not id(invite.invitationId)
			or not id(invite.partyId)
			or not integer(invite.partyRevision, 1)
			or not integer(invite.inviterUserId, 1)
			or not remaining(invite.expiresAt)
			or invite.status ~= "Pending"
			or seen[invite.invitationId]
		then
			return false
		end
		seen[invite.invitationId] = true
	end
	return true
end

return table.freeze(PartyProjectionV1)
