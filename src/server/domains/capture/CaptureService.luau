--!strict

local CaptureService = {}
local CLAIM_SECONDS = 20
local GRACE_SECONDS = 30
local TERMINAL_RECORD_LIMIT = 128
local RECENT_PROJECTION_LIMIT = 256

local function frozenCopy(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local copied = {}
	for key, child in value do
		copied[key] = frozenCopy(child)
	end
	return table.freeze(copied)
end

local function inRange(a: any, b: any, radius: number): boolean
	if type(a) ~= "table" or type(b) ~= "table" then
		return false
	end
	for _, position in { a, b } do
		for _, axis in { "x", "y", "z" } do
			if
				type(position[axis]) ~= "number"
				or position[axis] ~= position[axis]
				or math.abs(position[axis]) == math.huge
			then
				return false
			end
		end
	end
	local dx, dy, dz = a.x - b.x, a.y - b.y, a.z - b.z
	return dx * dx + dy * dy + dz * dz <= radius * radius
end

function CaptureService.new(options: {
	world: any,
	clock: () -> number,
	unixSeconds: () -> number,
	newId: () -> string,
	random: any,
	canInitiate: (any) -> boolean,
	captureChance: ((any) -> number?)?,
	finalize: (any, any) -> any,
	onChanged: ((number, any, string?) -> ())?,
	isPlayerConnected: ((number) -> boolean)?,
})
	local byCreature: { [string]: any } = {}
	local byUser: { [number]: string } = {}
	-- One small latest-state summary per user survives terminal cleanup and
	-- same-server reconnect. It never retains a profile or finalization payload.
	local projections: { [number]: any } = {}
	local recentUsers: { number } = {}
	local function connected(userId: number): boolean
		return options.isPlayerConnected ~= nil and options.isPlayerConnected(userId)
	end
	local function touchProjection(userId: number)
		for index = #recentUsers, 1, -1 do
			if recentUsers[index] == userId then
				table.remove(recentUsers, index)
				break
			end
		end
		-- Active custody/pending and connected players keep their revision.
		if byUser[userId] ~= nil or connected(userId) then
			return
		end
		table.insert(recentUsers, userId)
		if #recentUsers > RECENT_PROJECTION_LIMIT then
			local oldest = table.remove(recentUsers, 1)
			if oldest ~= nil and byUser[oldest] == nil and not connected(oldest) then
				projections[oldest] = nil
			end
		end
	end
	local function snapshot(userId: number): any
		if projections[userId] == nil then
			projections[userId] = table.freeze({ status = "Idle", revision = 1 })
		end
		touchProjection(userId)
		return table.clone(projections[userId])
	end
	local function project(record: any, status: string, profileRevision: number?)
		local prior = snapshot(record.userId)
		local state = {
			status = status,
			revision = prior.revision + 1,
			captureSessionId = record.captureSessionId,
			creatureInstanceId = record.creatureId,
			custodyId = record.custodyId,
			claimExpiresAt = if status == "Claimed" then record.claimExpiresAt else nil,
			profileRevision = if status == "Secured" then profileRevision else nil,
		}
		projections[record.userId] = table.freeze(state)
		touchProjection(record.userId)
		if options.onChanged ~= nil then
			options.onChanged(record.userId, table.clone(state), record.operationId)
		end
	end
	-- Keep only a bounded diagnostic history; terminal entries never retain
	-- profiles, immutable finalization payloads, or mutable custody records.
	local terminalStates: { [string]: any } = {}
	local terminalOrder: { any } = {}
	local function terminal(record: any, state: string, profileRevision: number?)
		record.state = state
		byCreature[record.creatureId] = nil
		if byUser[record.userId] == record.creatureId then
			byUser[record.userId] = nil
		end
		project(record, if state == "Invalidated" then "Interrupted" else state, profileRevision)
		local summary = { creatureId = record.creatureId, state = state }
		terminalStates[record.creatureId] = summary
		table.insert(terminalOrder, summary)
		if #terminalOrder > TERMINAL_RECORD_LIMIT then
			local oldest = table.remove(terminalOrder, 1)
			if terminalStates[oldest.creatureId] == oldest then
				terminalStates[oldest.creatureId] = nil
			end
		end
	end

	local function resume(userId: number, generation: number, profile: any): any
		local id = byUser[userId]
		local record = if id then byCreature[id] else nil
		if
			record == nil
			or record.state ~= "TransportGrace"
			or type(generation) ~= "number"
			or generation < 1
			or generation % 1 ~= 0
			or type(profile) ~= "table"
		then
			return { status = "Rejected" }
		end
		if options.clock() >= record.graceExpiresAt then
			options.world.retire(id)
			terminal(record, "Expired")
			return { status = "Expired" }
		end
		if not options.world.transition(id, "TransportGrace", "TransportActive") then
			return { status = "Unavailable" }
		end
		record.state = "TransportActive"
		record.generation = generation
		record.graceExpiresAt = nil
		project(record, "TransportActive")
		return {
			status = "TransportActive",
			custodyId = record.custodyId,
			captureSessionId = record.captureSessionId,
			creatureInstanceId = id,
		}
	end

	local function begin(
		userId: number,
		creatureId: string,
		position: any,
		generation: number,
		profile: any
	): any
		if
			type(userId) ~= "number"
			or userId < 1
			or userId % 1 ~= 0
			or type(generation) ~= "number"
			or generation < 1
			or generation % 1 ~= 0
		then
			return { status = "Rejected" }
		end
		local priorId = byUser[userId]
		if priorId ~= nil then
			local prior = byCreature[priorId]
			if prior ~= nil and prior.state == "TransportGrace" and priorId == creatureId then
				return resume(userId, generation, profile)
			end
			return { status = "Busy" }
		end
		local available, projection = options.world.interaction(creatureId, position)
		if available ~= "Available" then
			return { status = available }
		end
		if not options.canInitiate(profile) then
			return { status = "CapacityBlocked" }
		end
		local chance = if options.captureChance then options.captureChance(profile) else 0.8
		if type(chance) ~= "number" or chance ~= chance or chance < 0 or chance > 1 then
			return { status = "Unavailable" }
		end
		local identity = options.world.identity(creatureId)
		if identity == nil or identity.variantIdentity == nil then
			return { status = "Unavailable" }
		end
		local claimId = options.newId()
		if not options.world.transition(creatureId, "IdleAvailable", "Claimed") then
			return { status = "Busy" }
		end
		local record = {
			userId = userId,
			creatureId = creatureId,
			identity = identity,
			position = projection.position,
			generation = generation,
			captureSessionId = claimId,
			state = "Claimed",
			claimExpiresAt = options.clock() + CLAIM_SECONDS,
			sequence = 0,
			captureChance = chance, -- Server-owned capability fixed at admission.
		}
		byCreature[creatureId] = record
		terminalStates[creatureId] = nil
		byUser[userId] = creatureId
		project(record, "Claimed")
		return {
			status = "Claimed",
			captureSessionId = record.captureSessionId,
			creatureInstanceId = creatureId,
		}
	end

	local function submit(
		userId: number,
		captureSessionId: string,
		actionId: string,
		sequence: number,
		position: any,
		generation: number
	): any
		local id = byUser[userId]
		local record = if id then byCreature[id] else nil
		if
			record == nil
			or record.captureSessionId ~= captureSessionId
			or record.userId ~= userId
		then
			return { status = "Rejected" }
		end
		if record.state == "TransportActive" and sequence == 1 then
			return { status = "TransportActive", custodyId = record.custodyId }
		end
		if record.state ~= "Claimed" or sequence ~= 1 or actionId ~= "capture" then
			return { status = "Rejected" }
		end
		if
			options.clock() >= record.claimExpiresAt
			or generation ~= record.generation
			or not inRange(position, record.position, 12)
		then
			options.world.transition(id, "Claimed", "IdleAvailable")
			terminal(record, "Invalidated")
			return { status = "Invalidated" }
		end
		if not options.world.transition(id, "Claimed", "AttemptActive") then
			return { status = "Rejected" }
		end
		record.state = "AttemptActive"
		local roll = options.random.nextUnit()
		assert(
			type(roll) == "number" and roll == roll and roll >= 0 and roll < 1,
			"invalid capture RNG"
		)
		if roll >= record.captureChance then
			options.world.transition(id, "AttemptActive", "IdleAvailable")
			terminal(record, "Failed")
			return { status = "Failed" }
		end
		options.world.transition(id, "AttemptActive", "Provisional")
		record.state = "Provisional"
		record.custodyId = options.newId()
		record.operationId = options.newId()
		options.world.transition(id, "Provisional", "TransportActive")
		record.state = "TransportActive"
		project(record, "TransportActive")
		return { status = "TransportActive", custodyId = record.custodyId, creatureInstanceId = id }
	end

	local function reconcile(userId: number, session: any): any
		local id = byUser[userId]
		local record = if id then byCreature[id] else nil
		if
			record == nil
			or record.userId ~= userId
			or record.finalizing
			or record.state ~= "FinalizationPending"
			or record.finalizationPayload == nil
		then
			return { status = "Rejected" }
		end
		if
			session == nil
			or (session.state() ~= "Ready" and session.state() ~= "PersistenceAtRisk")
		then
			return { status = "Unavailable", creatureInstanceId = id }
		end
		record.finalizing = true
		-- Admission was validated once. Retries may outlive the old avatar or
		-- Player instance, and must never manufacture a new operation candidate.
		local ok, result = pcall(options.finalize, session, record.finalizationPayload)
		record.finalizing = false
		if not ok or type(result) ~= "table" or type(result.status) ~= "string" then
			return { status = "OutcomeUnknown", creatureInstanceId = id }
		end
		if result.status == "Secured" then
			options.world.transition(id, "FinalizationPending", "Secured")
			options.world.retire(id)
			terminal(record, "Secured", result.profileRevision)
		end
		local projected = table.clone(result)
		projected.creatureInstanceId = id
		return projected
	end

	local function secure(
		userId: number,
		position: any,
		securePosition: any,
		generation: number,
		session: any
	): any
		local id = byUser[userId]
		local record = if id then byCreature[id] else nil
		if record == nil or record.userId ~= userId or record.finalizing then
			return { status = "Rejected" }
		end
		if record.state == "FinalizationPending" then
			return reconcile(userId, session)
		end
		if
			record.state ~= "TransportActive"
			or generation ~= record.generation
			or not inRange(position, securePosition, 10)
		then
			return { status = "Rejected" }
		end
		if session == nil or session.state() ~= "Ready" then
			return { status = "Unavailable" }
		end
		local candidate = frozenCopy({
			ownerUserId = record.userId,
			operationId = record.operationId,
			creatureInstanceId = id,
			speciesId = record.identity.speciesId,
			variantIdentity = record.identity.variantIdentity,
			origin = {
				spawnContextId = record.identity.spawnContextId,
				contentSnapshotId = record.identity.contentSnapshotId,
			},
			securedAt = options.unixSeconds(),
		})
		if not options.world.transition(id, "TransportActive", "FinalizationPending") then
			return { status = "Rejected" }
		end
		record.finalizationPayload = candidate
		record.state = "FinalizationPending"
		project(record, "FinalizationPending")
		return reconcile(userId, session)
	end

	local function disconnect(userId: number)
		local id = byUser[userId]
		local record = if id then byCreature[id] else nil
		if record == nil then
			return
		end
		if record.state == "TransportActive" then
			if options.world.transition(id, "TransportActive", "TransportGrace") then
				record.state = "TransportGrace"
				record.graceExpiresAt = options.clock() + GRACE_SECONDS
				project(record, "Interrupted")
			end
		elseif
			record.state == "Claimed"
			or record.state == "AttemptActive"
			or record.state == "Provisional"
		then
			options.world.transition(id, record.state, "IdleAvailable")
			terminal(record, "Invalidated")
		end
	end

	local function interrupt(userId: number)
		local id = byUser[userId]
		local record = if id then byCreature[id] else nil
		if
			record == nil
			or record.state == "FinalizationPending"
			or record.state == "TransportGrace"
		then
			return
		end
		if record.state == "Claimed" or record.state == "AttemptActive" then
			options.world.transition(id, record.state, "IdleAvailable")
			terminal(record, "Interrupted")
		elseif record.state == "TransportActive" or record.state == "Provisional" then
			options.world.retire(id)
			terminal(record, "Interrupted")
		end
	end

	local function finalizeForShutdown(userId: number, session: any): any
		local id = byUser[userId]
		local record = if id then byCreature[id] else nil
		if record == nil or record.state ~= "TransportActive" then
			return { status = "Rejected" }
		end
		-- Only the trusted server drain path calls this method. It uses the same
		-- pre-existing operation ID and excludes grace/interrupt states.
		return secure(userId, record.position, record.position, record.generation, session)
	end

	local function tick()
		local now = options.clock()
		for id, record in byCreature do
			if record.state == "Claimed" and now >= record.claimExpiresAt then
				options.world.transition(id, "Claimed", "IdleAvailable")
				terminal(record, "Expired")
			elseif record.state == "TransportGrace" and now >= record.graceExpiresAt then
				options.world.retire(id)
				terminal(record, "Expired")
			end
		end
	end

	return {
		begin = begin,
		submit = submit,
		secure = secure,
		reconcile = reconcile,
		resume = resume,
		disconnect = disconnect,
		interrupt = interrupt,
		finalizeForShutdown = finalizeForShutdown,
		snapshot = snapshot,
		playerLeft = function(userId: number)
			if projections[userId] ~= nil then
				touchProjection(userId)
			end
		end,
		projectionCounts = function(): any
			local total = 0
			for _ in projections do
				total += 1
			end
			return { total = total, recent = #recentUsers }
		end,
		activeCustodies = function(): { any }
			local result = {}
			for userId, id in byUser do
				local record = byCreature[id]
				if record ~= nil and record.state == "TransportActive" then
					table.insert(result, { userId = userId, generation = record.generation })
				end
			end
			return result
		end,
		pendingFinalizations = function(): { number }
			local result = {}
			for userId, id in byUser do
				local record = byCreature[id]
				if record ~= nil and record.state == "FinalizationPending" then
					table.insert(result, userId)
				end
			end
			return result
		end,
		tick = tick,
		state = function(id: string): string?
			local record = byCreature[id]
			local summary = terminalStates[id]
			return if record then record.state elseif summary then summary.state else nil
		end,
		custody = function(userId: number): any
			local id = byUser[userId]
			local record = if id then byCreature[id] else nil
			return if record and record.state == "TransportActive" then record else nil
		end,
		recordCounts = function(): any
			local active = 0
			for _ in byCreature do
				active += 1
			end
			return { active = active, terminal = #terminalOrder }
		end,
	}
end

return CaptureService
