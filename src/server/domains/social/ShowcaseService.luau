--!strict

-- Bounded P0 permission references. No profile writer or gameplay capability.
local ShowcaseService = {}
local function count(t: any): number
	local n = 0
	for _ in t do
		n += 1
	end
	return n
end
function ShowcaseService.new(options: {
	policy: any,
	contract: any,
	wire: any,
	context: (number) -> any,
	eligible: (any, any, string) -> boolean,
	presentation: (any, any) -> any,
	monotonicSeconds: () -> number,
	presentationSeconds: () -> number,
	newId: () -> string,
})
	local live, grants, dirty = {}, {}, {}
	local stopped, serial, lastAt = false, 0, 0
	local policy = options.policy
	local observe: (number) -> any
	local function nextRevision(): number
		serial += 1
		return serial
	end
	local function touch(userId: number)
		if live[userId] then
			live[userId].revision = nextRevision()
		end
		dirty[userId] = true
	end
	local function time(): number?
		local at = options.monotonicSeconds()
		if type(at) ~= "number" or at ~= at or at < 0 or at >= math.huge then
			return nil
		end
		lastAt = math.max(lastAt, at)
		return lastAt
	end
	local function current(r: any): boolean
		local c = options.context(r.player.UserId)
		return not stopped
			and live[r.player.UserId] == r
			and c ~= nil
			and c.ready == true
			and c.player == r.player
			and c.session == r.session
	end
	local function remove(g: any, reason: string)
		if grants[g.id] ~= g then
			return
		end
		grants[g.id] = nil
		g.owner.outgoing[g.id], g.visitor.incoming[g.id] = nil, nil
		g.owner.permissionRevision = nextRevision()
		if g.visitor.visit == g then
			g.visitor.visit, g.visitor.reason = nil, reason
		end
		touch(g.owner.player.UserId)
		touch(g.visitor.player.UserId)
	end
	local function detach(r: any, reason: string)
		for _, g in table.clone(r.outgoing) do
			remove(g, reason)
		end
		for _, g in table.clone(r.incoming) do
			remove(g, reason)
		end
		live[r.player.UserId] = nil
		touch(r.player.UserId)
	end
	observe = function(userId: number): any
		if stopped then
			return nil
		end
		local c, prior = options.context(userId), live[userId]
		if
			prior
			and (
				c == nil
				or c.ready ~= true
				or c.player ~= prior.player
				or c.session ~= prior.session
			)
		then
			detach(prior, "SessionChanged")
			prior = nil
		end
		if c == nil or c.ready ~= true or c.player == nil or c.session == nil then
			return nil
		end
		if prior == nil then
			if count(live) >= policy.maxLiveUsers then
				return nil
			end
			prior = {
				player = c.player,
				session = c.session,
				audience = "Closed",
				permissionRevision = nextRevision(),
				revision = nextRevision(),
				outgoing = {},
				incoming = {},
				visit = nil,
				reason = "None",
				presentation = nil,
				presentationVersion = 0,
			}
			live[userId] = prior
			dirty[userId] = true
		end
		return prior
	end
	local function forPlayer(player: any): any
		if player == nil or type(player.UserId) ~= "number" then
			return nil
		end
		local r = observe(player.UserId)
		return if r and r.player == player then r else nil
	end
	local function valid(g: any): boolean
		local at = time()
		if stopped or grants[g.id] ~= g then
			return false
		end
		observe(g.owner.player.UserId)
		observe(g.visitor.player.UserId)
		if grants[g.id] ~= g then
			return false
		end
		if at == nil or at >= g.deadline then
			remove(g, "Expired")
			return false
		end
		if not current(g.owner) or not current(g.visitor) then
			remove(g, "SessionChanged")
			return false
		end
		local eligible = g.owner.audience ~= "Closed"
			and options.eligible(g.owner.player, g.visitor.player, g.owner.audience)
		if not eligible or not current(g.owner) or not current(g.visitor) or grants[g.id] ~= g then
			remove(g, "PolicyChanged")
			return false
		end
		return true
	end
	local function refreshAudience(userId: number)
		local r = observe(userId)
		if r then
			for _, g in table.clone(r.outgoing) do
				valid(g)
			end
			for _, g in table.clone(r.incoming) do
				valid(g)
			end
		end
	end
	local function setPolicy(player: any, audience: string, expected: number): string
		local r = forPlayer(player)
		if not r then
			return "REJECT_STATE_SHOWCASE_SESSION"
		end
		if not options.contract.validPolicyName(audience) then
			return "REJECT_VALIDATION_PAYLOAD"
		end
		if expected ~= r.permissionRevision then
			return "REJECT_STATE_SHOWCASE_REVISION"
		end
		if r.audience ~= audience then
			r.audience, r.permissionRevision = audience, nextRevision()
			-- A policy change always requires fresh targeted consent, even when widening.
			for _, g in table.clone(r.outgoing) do
				remove(g, "PolicyChanged")
			end
			touch(player.UserId)
		end
		return "OK_SHOWCASE_POLICY"
	end
	local function grant(player: any, targetUserId: number, expected: number): string
		local r, at = forPlayer(player), time()
		if not r or at == nil then
			return "REJECT_STATE_SHOWCASE_SESSION"
		end
		refreshAudience(player.UserId)
		if expected ~= r.permissionRevision then
			return "REJECT_STATE_SHOWCASE_REVISION"
		end
		if targetUserId == player.UserId then
			return "REJECT_PERMISSION_SHOWCASE_SELF"
		end
		local target = observe(targetUserId)
		if not target then
			return "REJECT_STATE_SHOWCASE_TARGET"
		end
		if r.audience == "Closed" or not options.eligible(player, target.player, r.audience) then
			return "REJECT_PERMISSION_SHOWCASE_AUDIENCE"
		end
		if not current(r) or not current(target) then
			return "REJECT_STATE_SHOWCASE_SESSION"
		end
		for _, g in r.outgoing do
			if g.visitor == target then
				return "OK_SHOWCASE_ALREADY_GRANTED"
			end
		end
		if
			count(r.outgoing) >= policy.maxVisitors
			or count(target.incoming) >= policy.maxIncoming
		then
			return "REJECT_STATE_SHOWCASE_BOUND"
		end
		local shown = options.presentationSeconds()
		if type(shown) ~= "number" or shown ~= shown or shown < 0 or shown >= math.huge then
			return "REJECT_STATE_SHOWCASE_SESSION"
		end
		local id = options.newId()
		assert(
			type(id) == "string" and #id > 0 and #id <= 48 and grants[id] == nil,
			"Showcase GUID"
		)
		local g = {
			id = id,
			owner = r,
			visitor = target,
			deadline = at + policy.grantSeconds,
			expiresAt = shown + policy.grantSeconds,
		}
		grants[id], r.outgoing[id], target.incoming[id] = g, g, g
		r.permissionRevision = nextRevision()
		touch(player.UserId)
		touch(targetUserId)
		return "OK_SHOWCASE_GRANTED"
	end
	local function revoke(player: any, id: string, expected: number): string
		local r = forPlayer(player)
		if not r then
			return "REJECT_STATE_SHOWCASE_SESSION"
		end
		if expected ~= r.permissionRevision then
			return "REJECT_STATE_SHOWCASE_REVISION"
		end
		local g = grants[id]
		if g == nil or g.owner ~= r then
			return "REJECT_PERMISSION_SHOWCASE_OWNER"
		end
		remove(g, "Revoked")
		return "OK_SHOWCASE_REVOKED"
	end
	local function open(player: any, ownerUserId: number, id: string): string
		local r, g = forPlayer(player), grants[id]
		if not r then
			return "REJECT_STATE_SHOWCASE_SESSION"
		end
		if g == nil or g.visitor ~= r or g.owner.player.UserId ~= ownerUserId or not valid(g) then
			return "REJECT_PERMISSION_SHOWCASE_VISITOR"
		end
		if r.visit ~= nil and r.visit ~= g then
			return "REJECT_STATE_SHOWCASE_BUSY"
		end
		if r.visit == nil then
			r.visit, r.reason = g, "None"
			touch(player.UserId)
		end
		return "OK_SHOWCASE_READ_ONLY"
	end
	local function close(player: any, id: string): string
		local r = forPlayer(player)
		if not r then
			return "REJECT_STATE_SHOWCASE_SESSION"
		end
		if r.visit == nil or r.visit.id ~= id then
			return "REJECT_PERMISSION_SHOWCASE_VISITOR"
		end
		remove(r.visit, "Left") -- leaving consumes the permission; another visit needs a new grant.
		return "OK_SHOWCASE_CLOSED"
	end
	local function snapshot(player: any): any
		local r = forPlayer(player)
		if r then
			refreshAudience(player.UserId)
		end
		local state = {
			audience = if r then r.audience else "Closed",
			permissionRevision = if r then r.permissionRevision else 0,
			visitors = {},
			incoming = {},
		} :: any
		if r then
			for _, pair in
				{ { r.outgoing, state.visitors, true }, { r.incoming, state.incoming, false } }
			do
				for _, g in pair[1] do
					table.insert(pair[2], {
						id = g.id,
						userId = if pair[3] then g.visitor.player.UserId else g.owner.player.UserId,
						expiresAt = g.expiresAt,
					})
				end
				table.sort(pair[2], function(a, b)
					return a.id < b.id
				end)
			end
		end
		return {
			domain = "showcase",
			revision = if r then r.revision else nextRevision(),
			state = state,
		}
	end
	local function viewSnapshot(player: any): any
		local r = forPlayer(player)
		local g = if r then r.visit else nil
		local state = { mode = "Closed", reason = if r then r.reason else "Unavailable" } :: any
		if g and valid(g) then
			local owner, version = g.owner, g.owner.presentationVersion
			if owner.presentation == nil then
				local p = options.presentation(owner.player, owner.session)
				-- A yielded/delayed read cannot restore a removed grant or cache old content.
				if
					current(owner)
					and version == owner.presentationVersion
					and valid(g)
					and r.visit == g
				then
					owner.presentation = p
				end
			end
			if owner.presentation ~= nil and valid(g) and r.visit == g then
				local name = owner.player.DisplayName
				state = {
					mode = "ReadOnly",
					ownerUserId = owner.player.UserId,
					ownerDisplayName = if type(name) == "string"
							and #name > 0
							and #name <= 64
						then name
						else tostring(owner.player.UserId),
					grantId = g.id,
					expiresAt = g.expiresAt,
					creatures = {},
					hasMore = owner.presentation.hasMore,
				}
				local row = owner.presentation.creatures[1]
				if row and options.contract.validCreature(row) then
					state.creatures = { options.wire.copy(row) }
					if
						not options.wire.payload({
							domain = "showcaseView",
							revision = r.revision,
							state = state,
						})
					then
						state.creatures, state.hasMore = {}, true -- no partial intrinsic identity.
					end
				elseif row then
					state.hasMore = true
				end
			else
				state.reason = if r then r.reason else "Unavailable"
			end
		elseif r then
			state.reason = r.reason
		end
		return {
			domain = "showcaseView",
			revision = if r then r.revision else nextRevision(),
			state = state,
		}
	end
	return {
		setPolicy = setPolicy,
		grant = grant,
		revoke = revoke,
		open = open,
		close = close,
		snapshot = snapshot,
		viewSnapshot = viewSnapshot,
		observe = observe,
		refreshAudience = refreshAudience,
		profileChanged = function(userId: number, session: any)
			local c = options.context(userId)
			if stopped or c == nil or c.session ~= session then
				return
			end
			local r = observe(userId)
			if r then
				r.presentation, r.presentationVersion = nil, r.presentationVersion + 1
				for _, g in r.outgoing do
					if g.visitor.visit == g then
						touch(g.visitor.player.UserId)
					end
				end
			end
		end,
		disconnect = function(player: any, session: any): boolean
			local r = live[player.UserId]
			if r == nil or r.player ~= player or r.session ~= session then
				return false
			end
			detach(r, "Disconnected")
			return true
		end,
		sessionFor = function(player: any): any
			local r = live[player.UserId]
			return if r and r.player == player then r.session else nil
		end,
		expire = function()
			if not stopped then
				for _, g in table.clone(grants) do
					valid(g)
				end
			end
		end,
		nextDeadline = function(): number?
			local at = math.huge
			for _, g in grants do
				at = math.min(at, g.deadline)
			end
			return if at < math.huge then at else nil
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
			local visits = 0
			for _, r in live do
				if r.visit then
					visits += 1
				end
			end
			return { liveUsers = count(live), grants = count(grants), visits = visits }
		end,
		stop = function()
			stopped = true
			table.clear(grants)
			table.clear(live)
			table.clear(dirty)
		end,
	}
end
return ShowcaseService
