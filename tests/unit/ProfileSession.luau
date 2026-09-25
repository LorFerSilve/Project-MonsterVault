--!strict

local FakeClock = require("../fixtures/FakeClock")
local FakeProfileRepository = require("../fixtures/FakeProfileRepository")
local ProfileSchemaV1 = require("../../src/server/infrastructure/persistence/ProfileSchemaV1")
local SingleWriterQueue = require("../../src/server/infrastructure/persistence/SingleWriterQueue")
local RetryPolicy = require("../../src/server/infrastructure/persistence/RetryPolicy")
local ProfileSession = require("../../src/server/infrastructure/persistence/ProfileSession")

local function setup(repository: any, ...: any)
	local userId, lockId, clock = ...
	local fakeClock = clock or FakeClock.new(1_700_000_000, 0)
	local queue = SingleWriterQueue.new(fakeClock.monotonicClock.seconds, function(seconds)
		fakeClock.advance(seconds)
	end, 10)
	local retry = RetryPolicy.new(fakeClock.monotonicClock.seconds, function(seconds)
		fakeClock.advance(seconds)
	end, function()
		return 0.5
	end, 3)
	local session = ProfileSession.new({
		userId = userId or 42,
		lockId = lockId or "lock-a",
		jobId = "job-a",
		repository = repository,
		schema = ProfileSchemaV1,
		queue = queue,
		retry = retry,
		unixSeconds = fakeClock.wallClock.unixSeconds,
		monotonicSeconds = fakeClock.monotonicClock.seconds,
	})
	return session, fakeClock
end

local function newProfileLeaseAndRelease()
	local repository = FakeProfileRepository.new()
	local session = setup(repository)
	assert(session.acquire().status == "Ready", "successful missing key creates ready profile")
	local stored = repository.read("player/42")
	assert(
		stored.value.schemaVersion == 1 and stored.value.profileRevision == 1,
		"new profile revision"
	)
	assert(stored.metadata.mvLease.lockId == "lock-a", "lease is metadata, not gameplay profile")
	assert(session.renew().status == "Ready", "clean lease renewal succeeds")
	assert(
		repository.read("player/42").value.profileRevision == 1,
		"metadata-only renewal does not bump content revision"
	)
	assert(session.release(25).status == "Closed", "final save releases")
	assert(repository.read("player/42").metadata.mvLease == nil, "lease removed")
	assert(
		session.snapshot() == nil and session.state() == "Closed",
		"closed session has no working profile"
	)
end

local function failedLoadNeverCreatesDefault()
	local repository = FakeProfileRepository.new()
	repository.failNext({ status = "error", reason = "TRANSIENT", retryable = true })
	repository.failNext({ status = "error", reason = "TRANSIENT", retryable = true })
	repository.failNext({ status = "error", reason = "TRANSIENT", retryable = true })
	local session = setup(repository)
	assert(session.acquire().status == "ProtectedLoadFailure", "failed load is protected")
	assert(repository.read("player/42") == nil, "failed load never saves default")
	assert(session.snapshot() == nil, "no writable profile exposed")
end

local function freshAndStaleForeignLease()
	local repository = FakeProfileRepository.new()
	local profile = ProfileSchemaV1.default(1_699_999_000)
	profile.profileRevision = 7
	repository.seed("player/42", profile, {
		mvLease = { lockId = "foreign", jobId = "other", epoch = 3, expiresAt = 1_700_000_100 },
	})
	local blocked = setup(repository)
	assert(blocked.acquire().status == "SessionLocked", "fresh foreign lease blocks acquisition")
	assert(
		repository.read("player/42").metadata.mvLease.lockId == "foreign",
		"foreign lease preserved"
	)
	local stale = setup(repository, 42, "lock-b", FakeClock.new(1_700_000_101, 0))
	assert(stale.acquire().status == "Ready", "expired lease can be reclaimed")
	assert(repository.read("player/42").metadata.mvLease.epoch == 4, "takeover increments epoch")
	assert(
		repository.read("player/42").value.profileRevision == 7,
		"metadata-only takeover preserves content revision"
	)
end

local function schemaAndMetadataFailClosed()
	local repository = FakeProfileRepository.new()
	local newer = ProfileSchemaV1.default(1)
	newer.schemaVersion = 2
	repository.seed("player/42", newer, {})
	assert(
		setup(repository).acquire().status == "ProtectedLoadFailure",
		"newer schema cannot downgrade"
	)
	assert(
		repository.read("player/42").value.schemaVersion == 2,
		"unknown profile remains unchanged"
	)
	repository.seed("player/42", ProfileSchemaV1.default(1), { mvLease = { lockId = "bad" } })
	assert(
		setup(repository).acquire().status == "ProtectedLoadFailure",
		"malformed lease cannot be stolen"
	)
	assert(
		repository.read("player/42").metadata.mvLease.lockId == "bad",
		"malformed metadata preserved"
	)
end

local function checkpointIsDurableAndIdempotent()
	local repository = FakeProfileRepository.new()
	local session = setup(repository)
	assert(session.acquire().status == "Ready", "acquired")
	local outcome: any = session.checkpoint("op-1", function(candidate)
		candidate.economy.energy = 25
	end)
	assert(
		outcome.status == "Committed" and outcome.profileRevision == 2,
		"P2 only succeeds after write"
	)
	assert(repository.read("player/42").value.economy.energy == 25, "value is durable")
	local calls = repository.calls()
	assert(session.checkpoint("op-1", function()
		error("must not rerun")
	end).status == "AlreadyCommitted", "duplicate operation acknowledged from durable ledger")
	assert(repository.calls() == calls, "duplicate operation does not write")
end

local function uncertainCheckpointDoesNotAcknowledge()
	local repository = FakeProfileRepository.new()
	local session = setup(repository)
	assert(session.acquire().status == "Ready", "acquired")
	for _ = 1, 3 do
		repository.failNext({ status = "error", reason = "TRANSIENT", retryable = true })
	end
	local result = session.checkpoint("op-uncertain", function(candidate)
		candidate.economy.energy = 99
	end)
	assert(result.status == "OutcomeUnknown", "failed P2 never returns success")
	assert(
		session.state() == "PersistenceAtRisk",
		"uncertain persistence blocks more value operations"
	)
	assert(
		repository.read("player/42").value.economy.energy == nil,
		"failed fake calls did not write"
	)
	assert(session.snapshot().economy.energy == nil, "local profile did not finalize")
end

local function lostLockAndRevisionAreProtected()
	local repository = FakeProfileRepository.new()
	local session = setup(repository)
	assert(session.acquire().status == "Ready", "acquired")
	local entry = repository.read("player/42")
	entry.metadata.mvLease.lockId = "foreign"
	repository.seed("player/42", entry.value, entry.metadata)
	assert(session.checkpoint("op-lost", function(candidate)
		candidate.economy.energy = 1
	end).status == "OwnershipLost", "replaced lock ends authority")
	assert(
		repository.read("player/42").value.economy.energy == nil,
		"foreign profile not overwritten"
	)

	local other = FakeProfileRepository.new()
	local second = setup(other)
	assert(second.acquire().status == "Ready", "second acquired")
	local changed = other.read("player/42")
	changed.value.profileRevision += 1
	other.seed("player/42", changed.value, changed.metadata)
	assert(second.checkpoint("op-revision", function(candidate)
		candidate.economy.energy = 2
	end).status == "PersistenceAtRisk", "unexpected durable revision blocks overwrite")
	assert(other.read("player/42").value.economy.energy == nil, "newer revision preserved")
end

local function bufferedSettingsAndRiskRecovery()
	local repository = FakeProfileRepository.new()
	local session, clock = setup(repository)
	assert(session.acquire().status == "Ready", "acquired")
	assert(session.bufferSettings(function(settings)
		settings.audioMuted = true
	end).status == "Buffered", "safe P1 change buffered")
	assert(
		session.isDirty() and repository.read("player/42").value.settings.audioMuted == nil,
		"not durable yet"
	)
	clock.advance(280)
	for _ = 1, 3 do
		repository.failNext({ status = "error", reason = "TRANSIENT", retryable = true })
	end
	assert(
		session.renew().status == "PersistenceAtRisk",
		"renewal failure near expiry protects session"
	)
	assert(session.isDirty(), "failed autosave retains buffered change")
	assert(
		session.renew().status == "Ready",
		"successful renewal recovers while lease remains owned"
	)
	assert(repository.read("player/42").value.settings.audioMuted == true, "P1 eventually durable")
	assert(not session.isDirty(), "dirty marker clears only after success")
end

local function checkpointProtectsLedgerAndCallbackReplay()
	local repository = FakeProfileRepository.new()
	repository.setReplayTransform(true)
	local session = setup(repository)
	assert(session.acquire().status == "Ready", "acquired under callback replay")
	assert(session.checkpoint("op-1", function(candidate)
		candidate.economy.energy = 10
	end).status == "Committed", "one logical checkpoint despite transform replay")
	local revision = repository.read("player/42").value.profileRevision
	assert(session.checkpoint("op-2", function(candidate)
		candidate.recentOperations["op-1"] = nil
	end).status == "Rejected", "domain mutation cannot erase durable dedupe marker")
	assert(
		repository.read("player/42").value.profileRevision == revision,
		"rejected mutation never writes"
	)
end

local function releaseDuringCheckpointClosesAdmission()
	local repository = FakeProfileRepository.new()
	local session = setup(repository)
	assert(session.acquire().status == "Ready", "acquired")
	local releaseStatus
	local bufferedStatus
	repository.setBeforeTransform(function()
		repository.setBeforeTransform(nil)
		releaseStatus = session.release(25).status
		bufferedStatus = session.bufferSettings(function(settings)
			settings.audioMuted = true
		end).status
	end)
	assert(session.checkpoint("op-final", function(candidate)
		candidate.economy.energy = 5
	end).status == "Committed", "in-flight checkpoint resolves")
	assert(
		releaseStatus == "Busy" and bufferedStatus == "Closing",
		"release request blocks new mutation"
	)
	assert(session.release(25).status == "Closed", "final save follows in-flight checkpoint")
	assert(
		repository.read("player/42").value.economy.energy == 5,
		"committed value survives release"
	)
end

return {
	newProfileLeaseAndRelease = newProfileLeaseAndRelease,
	failedLoadNeverCreatesDefault = failedLoadNeverCreatesDefault,
	freshAndStaleForeignLease = freshAndStaleForeignLease,
	schemaAndMetadataFailClosed = schemaAndMetadataFailClosed,
	checkpointIsDurableAndIdempotent = checkpointIsDurableAndIdempotent,
	uncertainCheckpointDoesNotAcknowledge = uncertainCheckpointDoesNotAcknowledge,
	lostLockAndRevisionAreProtected = lostLockAndRevisionAreProtected,
	bufferedSettingsAndRiskRecovery = bufferedSettingsAndRiskRecovery,
	checkpointProtectsLedgerAndCallbackReplay = checkpointProtectsLedgerAndCallbackReplay,
	releaseDuringCheckpointClosesAdmission = releaseDuringCheckpointClosesAdmission,
}
