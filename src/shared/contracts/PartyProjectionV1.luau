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
function PartyProjectionV1.validPing(payload: any, expected: any): boolean
	return integer(expected, 1)
		and keys(payload, { partyId = true, pingKind = true })
		and id(payload.partyId)
		and payload.pingKind == "ComeHere"
end
function PartyProjectionV1.validPingPreference(payload: any, expected: any): boolean
	return expected == nil
		and keys(payload, { socialPingsMuted = true })
		and type(payload.socialPingsMuted) == "boolean"
end
function PartyProjectionV1.validChallengeRequest(payload: any, expected: any): boolean
	return expected == nil
		and keys(payload, { targetUserId = true, definitionId = true, definitionVersion = true })
		and integer(payload.targetUserId, 1)
		and id(payload.definitionId)
		and integer(payload.definitionVersion, 1)
end
function PartyProjectionV1.validChallengeRespond(payload: any, expected: any): boolean
	return integer(expected, 1)
		and keys(payload, { challengeId = true, accept = true })
		and id(payload.challengeId)
		and type(payload.accept) == "boolean"
end
function PartyProjectionV1.validChallengeCancel(payload: any, expected: any): boolean
	return integer(expected, 1)
		and keys(payload, { challengeId = true })
		and id(payload.challengeId)
end
local function validChallenge(c: any): boolean
	if
		not keys(c, {
			id = true,
			revision = true,
			definitionId = true,
			definitionVersion = true,
			fromUserId = true,
			toUserId = true,
			phase = true,
			expiresAt = true,
			winnerUserId = true,
			elapsedMs = true,
			reason = true,
		})
		or not id(c.id)
		or not integer(c.revision, 1)
		or not id(c.definitionId)
		or not integer(c.definitionVersion, 1)
		or not integer(c.fromUserId, 1)
		or not integer(c.toUserId, 1)
		or c.fromUserId == c.toUserId
		or not remaining(c.expiresAt)
	then
		return false
	end
	if
		not ({
			Offered = true,
			Active = true,
			Declined = true,
			Cancelled = true,
			Expired = true,
			Resolved = true,
		} :: any)[c.phase]
	then
		return false
	end
	local live = c.phase == "Offered" or c.phase == "Active"
	if c.phase == "Resolved" then
		return c.reason == nil
			and integer(c.elapsedMs, 0)
			and (c.winnerUserId == c.fromUserId or c.winnerUserId == c.toUserId)
	end
	if c.winnerUserId ~= nil or c.elapsedMs ~= nil then
		return false
	end
	if live then
		return c.reason == nil
	end
	return c.reason == "Declined"
		or c.reason == "Cancelled"
		or c.reason == "Ignored"
		or c.reason == "TimedOut"
		or c.reason == "Interrupted"
		or c.reason == "Unavailable"
		or c.reason == "DefinitionChanged"
		or c.reason == "AudienceRestricted"
end
function PartyProjectionV1.validWaypoint(value: any): boolean
	if not keys(value, { x = true, y = true, z = true }) then
		return false
	end
	for _, axis in { "x", "y", "z" } do
		local coordinate = value[axis]
		if
			type(coordinate) ~= "number"
			or coordinate ~= coordinate
			or math.abs(coordinate) > 100_000
		then
			return false
		end
	end
	return true
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
		not keys(state, {
			allowInvites = true,
			party = true,
			incoming = true,
			rejoin = true,
			pingsMuted = true,
			pings = true,
			challenge = true,
		})
		or type(state.allowInvites) ~= "boolean"
		or not array(state.incoming, 2)
	then
		return false
	end
	if state.challenge ~= nil and not validChallenge(state.challenge) then
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
	-- Additive V1 fields: old Party snapshots remain safe with suppression on.
	if state.pings ~= nil or state.pingsMuted ~= nil then
		if type(state.pingsMuted) ~= "boolean" or not array(state.pings, 2) then
			return false
		end
		if #state.pings > 0 and (state.party == nil or state.pingsMuted) then
			return false
		end
		for _, ping in state.pings do
			if
				not keys(ping, {
					id = true,
					senderUserId = true,
					kind = true,
					position = true,
					expiresAt = true,
				})
				or not id(ping.id)
				or seen[ping.id]
				or ping.kind ~= "ComeHere"
				or not integer(ping.senderUserId, 1)
				or not remaining(ping.expiresAt)
				or not PartyProjectionV1.validWaypoint(ping.position)
			then
				return false
			end
			local present = false
			for _, member in state.party.members do
				if member.userId == ping.senderUserId and member.present then
					present = true
				end
			end
			if not present then
				return false
			end
			seen[ping.id] = true
		end
	end
	seen = {}
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
