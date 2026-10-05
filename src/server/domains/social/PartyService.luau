--!strict

-- P0 owner. Like CaptureService's admission, each transition is a non-yielding
-- critical section. The Party record and participant membership index change
-- together; no callbacks, persistence, network sends or queued waits run inside.
-- context, monotonicSeconds and newId are synchronous trusted adapters.
local PartyService = {}

function PartyService.new(options: {
	policy: any,
	context: (number) -> any,
	monotonicSeconds: () -> number,
	newId: () -> string,
})
	local policy = options.policy
	assert(policy.maxMembers == 4, "GDS-10 Party cap is four")
	for key, value in policy do
		assert(
			type(value) == "number" and value > 0 and value < 2 ^ 53,
			"invalid Party policy: " .. key
		)
	end
	local parties: { [string]: any } = {}
	local membership: { [number]: string } = {}
	local invites: { [string]: any } = {}
	local live: { [number]: any } = {}
	local dirty: { [number]: boolean } = {}
	local projectionSequence = 0
	local lastTime = 0
	local stopped = false
	local sync: (number) -> any

	local function count(values: any): number
		local n = 0
		for _ in values do
			n += 1
		end
		return n
	end
	local function now(): number?
		local at = options.monotonicSeconds()
		if type(at) ~= "number" or at ~= at or at < lastTime or at >= math.huge then
			return nil
		end
		lastTime = at
		return at
	end
	local function touch(userId: number)
		projectionSequence += 1
		if live[userId] then
			live[userId].revision = projectionSequence
			dirty[userId] = true
		end
	end
	local function cancelInvite(id: string)
		local invite = invites[id]
		if invite then
			invites[id] = nil
			touch(invite.targetId)
		end
	end
	local function cancelForUser(userId: number)
		for id, invite in invites do
			if invite.senderId == userId or invite.targetId == userId then
				cancelInvite(id)
			end
		end
	end
	local function changed(party: any)
		party.revision += 1
		for id, invite in invites do
			if invite.partyId == party.id then
				cancelInvite(id) -- consent to an older membership/leader revision is invalid.
			end
		end
		for userId in party.members do
			touch(userId)
		end
	end
	local function dissolve(party: any)
		changed(party)
		for userId in party.members do
			membership[userId] = nil
		end
		parties[party.id] = nil
		table.clear(party.members)
	end
	local function eligible(seat: any, userId: number): boolean
		local current = options.context(userId)
		return seat.player ~= nil
			and current ~= nil
			and current.ready == true
			and current.player == seat.player
			and current.session == seat.session
	end
	local function succeed(party: any)
		local chosen: number? = nil
		local sequence = math.huge
		for userId, seat in party.members do
			if eligible(seat, userId) and seat.sequence < sequence then
				chosen, sequence = userId, seat.sequence
			end
		end
		party.leaderId = chosen
		-- No available member owns management. End the Party instead of retaining
		-- a leaderless group of disconnected reservations indefinitely.
		if chosen == nil then
			dissolve(party)
		end
	end
	local function removeSeat(party: any, userId: number)
		party.members[userId] = nil
		membership[userId] = nil
		touch(userId)
		changed(party)
		if party.leaderId == userId then
			succeed(party)
		elseif next(party.members) == nil then
			dissolve(party)
		end
	end

	sync = function(userId: number): any
		local current = options.context(userId)
		local prior = live[userId]
		if
			prior
			and (
				current == nil
				or current.player ~= prior.player
				or current.session ~= prior.session
			)
		then
			cancelForUser(userId)
			local party = parties[membership[userId]]
			if party and party.members[userId].player ~= nil then
				removeSeat(party, userId) -- replacement without a trusted departure grants no grace.
			end
			live[userId], dirty[userId] = nil, nil
			prior = nil
		end
		if current == nil or current.player == nil or current.session == nil then
			return nil
		end
		if prior == nil then
			if count(live) >= policy.maxLiveUsers then
				return nil
			end
			prior = {
				player = current.player,
				session = current.session,
				allowInvites = false,
				ready = current.ready == true,
				senderAt = 0,
				recipientAt = 0,
			}
			live[userId] = prior
			touch(userId)
		elseif prior.ready ~= (current.ready == true) then
			prior.ready = current.ready == true
			if not prior.ready then
				cancelForUser(userId)
				local party = parties[membership[userId]]
				if party and party.members[userId].player ~= nil then
					removeSeat(party, userId)
				end
			end
			touch(userId)
		end
		return prior
	end
	local function reconcile(party: any)
		local ids = {}
		for userId in party.members do
			table.insert(ids, userId)
		end
		table.sort(ids)
		for _, userId in ids do
			local seat = party.members[userId]
			if seat and seat.player ~= nil then
				sync(userId)
			end
		end
	end
	local function expire(at: number)
		for id, invite in invites do
			if at >= invite.deadline then
				cancelInvite(id)
			end
		end
		for _, party in parties do
			for userId, seat in party.members do
				if seat.deadline and at >= seat.deadline then
					removeSeat(party, userId)
				end
			end
		end
	end
	local function actor(player: any): (any, number?)
		if stopped then
			return nil, nil
		end
		local at = now()
		if at == nil then
			return nil, nil
		end
		expire(at)
		local identity = sync(player.UserId)
		if identity == nil or identity.player ~= player or not identity.ready then
			return nil, at
		end
		return identity, at
	end
	local function partyFor(userId: number, partyId: string?, expected: number): any
		local party = parties[membership[userId]]
		if party == nil or (partyId ~= nil and party.id ~= partyId) then
			return nil
		end
		reconcile(party)
		local seat = party.members[userId]
		return if parties[party.id] == party
				and party.revision == expected
				and seat ~= nil
				and eligible(seat, userId)
			then party
			else nil
	end
	local function newId(): string
		local id = options.newId()
		assert(
			type(id) == "string"
				and #id > 0
				and #id <= 48
				and parties[id] == nil
				and invites[id] == nil,
			"invalid Party identity"
		)
		return id
	end

	local function create(player: any): string
		local identity = actor(player)
		if identity == nil then
			return "REJECT_STATE_PARTY_SESSION"
		end
		if membership[player.UserId] ~= nil then
			return "REJECT_STATE_PARTY_MEMBERSHIP"
		end
		if count(parties) >= policy.maxParties then
			return "REJECT_STATE_PARTY_BOUNDS"
		end
		local id = newId()
		parties[id] = {
			id = id,
			revision = 1,
			leaderId = player.UserId,
			sequence = 1,
			members = {
				[player.UserId] = { player = player, session = identity.session, sequence = 1 },
			},
		}
		membership[player.UserId] = id
		cancelForUser(player.UserId)
		touch(player.UserId)
		return "OK_PARTY_CREATED"
	end
	local function setInvitePolicy(player: any, allow: boolean): string
		local identity = actor(player)
		if identity == nil then
			return "REJECT_STATE_PARTY_SESSION"
		end
		identity.allowInvites = allow
		if not allow then
			for id, invite in invites do
				if invite.targetId == player.UserId then
					cancelInvite(id)
				end
			end
		end
		touch(player.UserId)
		return "OK_PARTY_INVITE_POLICY"
	end
	local function invite(player: any, targetId: number, expected: number): string
		local identity, at = actor(player)
		if identity == nil or at == nil then
			return "REJECT_STATE_PARTY_SESSION"
		end
		local party = partyFor(player.UserId, nil, expected)
		if party == nil then
			return "REJECT_STATE_PARTY_REVISION"
		end
		if party.leaderId ~= player.UserId then
			return "REJECT_PERMISSION_PARTY_LEADER"
		end
		local target = sync(targetId)
		if targetId == player.UserId or target == nil or not target.ready then
			return "REJECT_STATE_PARTY_TARGET"
		end
		if membership[targetId] then
			return "REJECT_STATE_PARTY_MEMBERSHIP"
		end
		if not target.allowInvites then
			return "REJECT_PERMISSION_PARTY_INVITES"
		end
		local outgoing, incoming = 0, 0
		for _, pending in invites do
			if pending.partyId == party.id then
				outgoing += 1
				if pending.targetId == targetId then
					return "REJECT_STATE_PARTY_DUPLICATE_INVITE"
				end
			end
			if pending.targetId == targetId then
				incoming += 1
			end
		end
		if outgoing >= policy.maxInvitesPerParty or incoming >= policy.maxIncomingInvites then
			return "REJECT_STATE_PARTY_INVITE_BOUNDS"
		end
		if at < identity.senderAt or at < target.recipientAt then
			return "REJECT_RATE_LIMIT"
		end
		local id = newId()
		invites[id] = {
			id = id,
			partyId = party.id,
			partyRevision = party.revision,
			senderId = player.UserId,
			targetId = targetId,
			sender = identity,
			target = target,
			deadline = at + policy.inviteSeconds,
		}
		identity.senderAt, target.recipientAt =
			at + policy.senderCooldownSeconds, at + policy.recipientCooldownSeconds
		touch(targetId)
		return "OK_PARTY_INVITED"
	end
	local function respond(
		player: any,
		invitationId: string,
		accept: boolean,
		expected: number
	): string
		local identity = actor(player)
		if identity == nil then
			return "REJECT_STATE_PARTY_SESSION"
		end
		local pending = invites[invitationId]
		if pending == nil or pending.targetId ~= player.UserId or pending.target ~= identity then
			return "REJECT_PERMISSION_PARTY_INVITE"
		end
		local party = parties[pending.partyId]
		if party then
			reconcile(party)
		end
		local sender = sync(pending.senderId)
		if
			invites[invitationId] ~= pending
			or party == nil
			or pending.sender ~= sender
			or sender == nil
			or not sender.ready
		then
			return "REJECT_STATE_PARTY_INVITE"
		end
		if party.revision ~= expected or pending.partyRevision ~= expected then
			return "REJECT_STATE_PARTY_REVISION"
		end
		if not accept then
			cancelInvite(invitationId)
			return "OK_PARTY_DECLINED"
		end
		if membership[player.UserId] then
			return "REJECT_STATE_PARTY_MEMBERSHIP"
		end
		if count(party.members) >= policy.maxMembers then
			return "REJECT_STATE_PARTY_FULL"
		end
		party.sequence += 1
		party.members[player.UserId] =
			{ player = player, session = identity.session, sequence = party.sequence }
		membership[player.UserId] = party.id
		cancelForUser(player.UserId)
		changed(party)
		return "OK_PARTY_JOINED"
	end
	local function leave(player: any, partyId: string, expected: number): string
		if actor(player) == nil then
			return "REJECT_STATE_PARTY_SESSION"
		end
		local reserved = parties[membership[player.UserId]]
		if reserved and reserved.id == partyId then
			reconcile(reserved)
			local seat = reserved.members[player.UserId]
			if seat and seat.deadline and reserved.revision == expected then
				removeSeat(reserved, player.UserId)
				return "OK_PARTY_LEFT"
			end
		end
		local party = partyFor(player.UserId, partyId, expected)
		if party == nil then
			return "REJECT_STATE_PARTY_REVISION"
		end
		removeSeat(party, player.UserId)
		return "OK_PARTY_LEFT"
	end
	local function remove(player: any, partyId: string, targetId: number, expected: number): string
		if actor(player) == nil then
			return "REJECT_STATE_PARTY_SESSION"
		end
		local party = partyFor(player.UserId, partyId, expected)
		if party == nil then
			return "REJECT_STATE_PARTY_REVISION"
		end
		if party.leaderId ~= player.UserId then
			return "REJECT_PERMISSION_PARTY_LEADER"
		end
		if targetId == player.UserId or party.members[targetId] == nil then
			return "REJECT_STATE_PARTY_MEMBER"
		end
		removeSeat(party, targetId)
		return "OK_PARTY_REMOVED"
	end
	local function disband(player: any, partyId: string, expected: number): string
		if actor(player) == nil then
			return "REJECT_STATE_PARTY_SESSION"
		end
		local party = partyFor(player.UserId, partyId, expected)
		if party == nil then
			return "REJECT_STATE_PARTY_REVISION"
		end
		if party.leaderId ~= player.UserId then
			return "REJECT_PERMISSION_PARTY_LEADER"
		end
		dissolve(party)
		return "OK_PARTY_DISBANDED"
	end
	local function disconnect(player: any, session: any, unexpected: boolean): boolean
		if stopped then
			return false
		end
		local prior = live[player.UserId]
		local current = options.context(player.UserId)
		if
			prior == nil
			or prior.player ~= player
			or prior.session ~= session
			or (current ~= nil and (current.player ~= player or current.session ~= session))
		then
			return false
		end
		local at = now()
		cancelForUser(player.UserId)
		local party = parties[membership[player.UserId]]
		if party then
			local seat = party.members[player.UserId]
			if unexpected and at ~= nil and prior.ready then
				seat.player, seat.session = nil, nil -- grace retains no Player/ProfileSession reference.
				seat.deadline = at + policy.rejoinSeconds
				changed(party)
				seat.disconnectRevision = party.revision
				if party.leaderId == player.UserId then
					succeed(party)
				end
			else
				removeSeat(party, player.UserId)
			end
		end
		live[player.UserId], dirty[player.UserId] = nil, nil
		return true
	end
	local function rejoin(player: any, partyId: string, expected: number): string
		local identity = actor(player)
		if identity == nil then
			return "REJECT_STATE_PARTY_SESSION"
		end
		local party = parties[membership[player.UserId]]
		if party == nil or party.id ~= partyId then
			return "REJECT_STATE_PARTY_REJOIN"
		end
		reconcile(party)
		local seat = party.members[player.UserId]
		if
			parties[party.id] ~= party
			or seat == nil
			or seat.player ~= nil
			or seat.deadline == nil
		then
			return "REJECT_STATE_PARTY_REJOIN"
		end
		if party.revision ~= expected then
			return "REJECT_STATE_PARTY_REVISION"
		end
		seat.player, seat.session, seat.deadline, seat.disconnectRevision =
			player, identity.session, nil, nil
		changed(party) -- original join sequence is retained; prior leadership is not restored.
		return "OK_PARTY_REJOINED"
	end
	local function snapshot(player: any): any
		if stopped then
			return nil
		end
		local at = now()
		if at == nil then
			return nil
		end
		expire(at)
		local identity = sync(player.UserId)
		if identity == nil or identity.player ~= player then
			return nil
		end
		local state: any = { allowInvites = identity.allowInvites, incoming = {} }
		local party = parties[membership[player.UserId]]
		if party then
			reconcile(party)
			local seat = party.members[player.UserId]
			if parties[party.id] == party and seat then
				if seat.player == player and seat.session == identity.session then
					local members = {}
					for userId, member in party.members do
						table.insert(members, { userId = userId, present = member.player ~= nil })
					end
					table.sort(members, function(a, b)
						return a.userId < b.userId
					end)
					state.party = {
						partyId = party.id,
						revision = party.revision,
						leaderUserId = party.leaderId,
						members = members,
					}
				elseif seat.deadline then
					state.rejoin = {
						partyId = party.id,
						revision = party.revision,
						expiresAt = seat.deadline,
					}
				end
			end
		end
		for id, pending in invites do
			if pending.targetId == player.UserId then
				local sender = sync(pending.senderId)
				if pending.target == identity and sender == pending.sender and sender.ready then
					table.insert(state.incoming, {
						invitationId = id,
						partyId = pending.partyId,
						partyRevision = pending.partyRevision,
						inviterUserId = pending.senderId,
						expiresAt = pending.deadline,
						status = "Pending",
					})
				end
			end
		end
		table.sort(state.incoming, function(a, b)
			return a.invitationId < b.invitationId
		end)
		return { domain = "party", revision = identity.revision, state = state }
	end

	return {
		create = create,
		invite = invite,
		respond = respond,
		leave = leave,
		remove = remove,
		disband = disband,
		rejoin = rejoin,
		setInvitePolicy = setInvitePolicy,
		disconnect = disconnect,
		sessionFor = function(player: any): any
			local identity = live[player.UserId]
			return if identity and identity.player == player then identity.session else nil
		end,
		snapshot = snapshot,
		observe = function(userId: number)
			if not stopped then
				sync(userId)
			end
		end,
		expire = function()
			local at = now()
			if not stopped and at ~= nil then
				expire(at)
			end
		end,
		nextDeadline = function(): number?
			local nextAt = math.huge
			for _, pending in invites do
				nextAt = math.min(nextAt, pending.deadline)
			end
			for _, party in parties do
				for _, seat in party.members do
					if seat.deadline then
						nextAt = math.min(nextAt, seat.deadline)
					end
				end
			end
			return if nextAt < math.huge then nextAt else nil
		end,
		takeChanges = function(): { number }
			local ids = {}
			for userId in dirty do
				table.insert(ids, userId)
			end
			table.clear(dirty)
			table.sort(ids)
			return ids
		end,
		counts = function(): any
			return {
				parties = count(parties),
				memberships = count(membership),
				invites = count(invites),
				liveUsers = count(live),
			}
		end,
		stop = function()
			stopped = true
			table.clear(parties)
			table.clear(membership)
			table.clear(invites)
			table.clear(live)
			table.clear(dirty)
		end,
	}
end

return PartyService
