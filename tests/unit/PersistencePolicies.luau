--!strict

local ProfileSchemaV1 = require("../../src/server/infrastructure/persistence/ProfileSchemaV1")
local SingleWriterQueue = require("../../src/server/infrastructure/persistence/SingleWriterQueue")
local RetryPolicy = require("../../src/server/infrastructure/persistence/RetryPolicy")

local function schemaValidation()
	local profile = ProfileSchemaV1.default(100)
	assert(ProfileSchemaV1.validate(profile), "default profile valid")
	assert(ProfileSchemaV1.migrate(profile) ~= nil, "V1 profile can load")
	profile.schemaVersion = 2
	assert(ProfileSchemaV1.migrate(profile) == nil, "newer schema rejected")
	profile.schemaVersion = 0
	assert(ProfileSchemaV1.migrate(profile) == nil, "unknown legacy schema rejected")
	profile.schemaVersion = 1
	profile.economy.energy = 0 / 0
	assert(not ProfileSchemaV1.validate(profile), "non-finite nested value rejected")
	profile.economy.energy = nil
	profile.collection.ids = { [2] = "gap" }
	assert(not ProfileSchemaV1.validate(profile), "sparse array rejected")
	profile.collection.ids = nil
	local large = string.rep("a", 4096)
	for index = 1, 70 do
		profile.collection["entry" .. tostring(index)] = large
	end
	assert(
		not ProfileSchemaV1.validate(profile),
		"oversized serialized profile rejected before write"
	)
	table.clear(profile.collection)
	profile.unknown = true
	assert(not ProfileSchemaV1.validate(profile), "unknown root field rejected")
end

local function queueAndRetryAreBounded()
	local now = 0
	local queue = SingleWriterQueue.new(function()
		return now
	end, function(seconds)
		now += seconds
	end, 0.1)
	local nestedStatus
	local outer = queue.run("critical", function()
		nestedStatus = queue.run("routine", function()
			return "must not execute"
		end).status
		return "done"
	end)
	assert(outer.status == "ok" and outer.value == "done", "outer writer completes")
	assert(nestedStatus == "timeout", "second writer never overlaps active writer")
	assert(queue.pendingCount() == 0, "queue drains after timeout")
	queue.close()
	assert(queue.run("critical", function()
		return true
	end).status == "closed", "closed queue rejects writes")

	local waits = {}
	local retry = RetryPolicy.new(function()
		return now
	end, function(seconds)
		now += seconds
		table.insert(waits, seconds)
	end, function()
		return 0.5
	end, 3)
	local calls = 0
	local result = retry.run(function()
		calls += 1
		return if calls < 3 then { status = "error", retryable = true } else { status = "ok" }
	end, now + 10)
	assert(result.status == "ok" and calls == 3, "bounded retry reaches later success")
	assert(
		#waits == 2 and waits[1] == 1 and waits[2] == 2,
		"exponential backoff is deterministic under injected jitter"
	)
	assert(retry.run(function()
		error("must not run after deadline")
	end, now).reason == "RETRY_DEADLINE", "deadline stops retries")
end

return { schemaValidation = schemaValidation, queueAndRetryAreBounded = queueAndRetryAreBounded }
