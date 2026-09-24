--!strict

local FakeClock = require("../fixtures/FakeClock")
local FakeRandomSource = require("../fixtures/FakeRandomSource")

local function expect(condition: boolean, message: string)
	assert(condition, message)
end

local function clockSourcesRemainSeparate()
	local fake = FakeClock.new(1_700_000_000, 12.5)
	expect(fake.wallClock.unixSeconds() == 1_700_000_000, "wall clock starts at injected value")
	expect(fake.monotonicClock.seconds() == 12.5, "monotonic clock starts at injected value")

	fake.advance(2.25)
	expect(fake.wallClock.unixSeconds() == 1_700_000_002.25, "wall clock advances")
	expect(fake.monotonicClock.seconds() == 14.75, "monotonic clock advances")

	-- Domain tests can inject a wall-clock regression without altering live elapsed time.
	fake.setWall(1_699_999_999)
	expect(fake.wallClock.unixSeconds() == 1_699_999_999, "wall regression is injectable")
	expect(fake.monotonicClock.seconds() == 14.75, "wall regression does not alter monotonic time")
end

local function clockRejectsInvalidAdvance()
	local fake = FakeClock.new(100, 10)
	expect(not pcall(fake.advance, -1), "negative advance is rejected")
	expect(not pcall(fake.setWall, 0 / 0), "NaN wall time is rejected")
	expect(fake.wallClock.unixSeconds() == 100, "invalid input preserves wall time")
	expect(fake.monotonicClock.seconds() == 10, "invalid input preserves monotonic time")
	fake.setWall(1e308)
	expect(not pcall(fake.advance, 1e308), "overflowing advance is rejected")
	expect(fake.wallClock.unixSeconds() == 1e308, "overflow does not partially advance wall time")
	expect(
		fake.monotonicClock.seconds() == 10,
		"overflow does not partially advance monotonic time"
	)
end

local function sequenceRandomIsCopyIsolatedAndBounded()
	local samples = { 0, 0.5, 1 }
	local fake = FakeRandomSource.fromSequence(samples)
	samples[1] = 0.75
	expect(fake.nextUnit() == 0, "sequence is isolated from caller mutation")
	expect(fake.nextUnit() == 0.5, "middle boundary is retained")
	expect(fake.nextUnit() == 1, "upper endpoint is available for boundary tests")
	expect(fake.draws() == 3, "exactly three draws were made")
	expect(fake.remaining() == 0, "sequence is exhausted")
	expect(not pcall(fake.nextUnit), "unexpected reroll fails")
	expect(fake.draws() == 3, "failed extra draw does not advance state")
end

local function sequenceRandomRejectsInvalidSamples()
	expect(not pcall(FakeRandomSource.fromSequence, { 0 / 0 }), "NaN sample is rejected")
	expect(not pcall(FakeRandomSource.fromSequence, { -0.1 }), "negative sample is rejected")
	expect(not pcall(FakeRandomSource.fromSequence, { 1.1 }), "sample above one is rejected")
end

local function seededRandomReplaysExactly()
	local first = FakeRandomSource.fromSeed(2307)
	local replay = FakeRandomSource.fromSeed(2307)
	for _ = 1, 32 do
		local sample = first.nextUnit()
		expect(sample > 0 and sample < 1, "seeded sample is within open unit interval")
		expect(sample == replay.nextUnit(), "seed replay reproduces each sample")
	end
	expect(first.draws() == 32, "first stream draw count")
	expect(replay.draws() == 32, "replay stream draw count")
	expect(not pcall(FakeRandomSource.fromSeed, 0), "zero seed is rejected")
	expect(not pcall(FakeRandomSource.fromSeed, 1.5), "fractional seed is rejected")
end

return {
	clockSourcesRemainSeparate = clockSourcesRemainSeparate,
	clockRejectsInvalidAdvance = clockRejectsInvalidAdvance,
	sequenceRandomIsCopyIsolatedAndBounded = sequenceRandomIsCopyIsolatedAndBounded,
	sequenceRandomRejectsInvalidSamples = sequenceRandomRejectsInvalidSamples,
	seededRandomReplaysExactly = seededRandomReplaysExactly,
}
