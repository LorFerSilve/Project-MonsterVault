--!strict

local Harness = require("../Harness")

local function fixture(testId: string, suite: string)
	return {
		testId = testId,
		requirements = { "TA-15", "TA-17" },
		verificationClass = "V2",
		criticality = "C1",
		environment = "Lune",
		seedId = "fixture:manifest-v1",
		expectedInvariant = "Manifest registration remains deterministic",
		owner = "IMP-1",
		timeoutMs = 1000,
		artifactPolicy = "CI stdout",
		suite = suite,
		modulePath = "./unit/HarnessTests",
		exportName = "selectsInStableOrder",
	}
end

local HarnessTests = {}

function HarnessTests.rejectsDuplicateIds()
	local first = fixture("T15.harness.manifest.duplicateIdsRejected", "fast")
	local second = fixture("T15.harness.manifest.duplicateIdsRejected", "other")
	local ok = pcall(Harness.select, { first, second }, "fast")
	assert(not ok, "duplicate TestIds must fail even when registered in a different suite")
end

function HarnessTests.rejectsIncompleteMetadata()
	local testCase = fixture("T15.harness.manifest.incompleteMetadataRejected", "fast")
	testCase.requirements = {}
	local ok = pcall(Harness.select, { testCase }, "fast")
	assert(not ok, "tests without requirement traceability must fail registration")
	testCase.requirements = { "TA-15" }
	testCase.verificationClass = "V99"
	ok = pcall(Harness.select, { testCase }, "fast")
	assert(not ok, "unknown verification classes must fail registration")
	testCase.verificationClass = "V2"
	testCase.criticality = "C9"
	ok = pcall(Harness.select, { testCase }, "fast")
	assert(not ok, "unknown criticality must fail registration")
end

function HarnessTests.selectsInStableOrder()
	local later = fixture("T15.harness.manifest.zeta", "fast")
	local otherSuite = fixture("T15.harness.manifest.middle", "extended")
	local earlier = fixture("T15.harness.manifest.alpha", "fast")
	local selected = Harness.select({ later, otherSuite, earlier }, "fast")
	assert(#selected == 2, "suite selection must be exact")
	assert(
		selected[1].testId == earlier.testId and selected[2].testId == later.testId,
		"selected tests must run in TestId order"
	)
	local ok = pcall(Harness.select, { later }, "missing")
	assert(not ok, "an empty selected suite must fail instead of passing without tests")
end

return HarnessTests
