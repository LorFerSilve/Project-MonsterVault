--!strict

export type TestCase = {
	testId: string,
	requirements: { string },
	verificationClass: string,
	criticality: string,
	environment: string,
	seedId: string,
	expectedInvariant: string,
	owner: string,
	timeoutMs: number,
	artifactPolicy: string,
	suite: string,
	modulePath: string,
	exportName: string,
}

local Harness = {}

local function requireText(value: unknown, field: string, testId: string)
	assert(type(value) == "string" and value ~= "", `{testId}: {field} must be nonempty text`)
end

function Harness.select(manifest: { TestCase }, suite: string): { TestCase }
	requireText(suite, "suite", "runner")
	assert(#manifest > 0, "test manifest is empty")

	local seen = {}
	local selected = {}
	for index, definition in manifest do
		assert(type(definition) == "table", `manifest entry {index} must be a table`)
		local testId = definition.testId
		requireText(testId, "testId", `manifest entry {index}`)
		assert(
			string.match(testId, "^T%d+%.[%w_]+%.[%w_]+%.[%w_]+$") ~= nil,
			`{testId}: invalid TestId`
		)
		assert(not seen[testId], `{testId}: duplicate TestId`)
		seen[testId] = true

		for _, field in
			{
				"verificationClass",
				"criticality",
				"environment",
				"seedId",
				"expectedInvariant",
				"owner",
				"artifactPolicy",
				"suite",
				"modulePath",
				"exportName",
			}
		do
			requireText(definition[field], field, testId)
		end
		local classNumber = tonumber(string.match(definition.verificationClass, "^V(%d+)$"))
		assert(classNumber ~= nil and classNumber <= 10, `{testId}: unknown verification class`)
		assert(
			definition.criticality == "C0"
				or definition.criticality == "C1"
				or definition.criticality == "C2",
			`{testId}: unknown criticality`
		)
		assert(
			type(definition.requirements) == "table" and #definition.requirements > 0,
			`{testId}: requirements must be a nonempty list`
		)
		for _, requirement in definition.requirements do
			requireText(requirement, "requirement", testId)
		end
		assert(
			type(definition.timeoutMs) == "number"
				and definition.timeoutMs > 0
				and definition.timeoutMs < math.huge
				and definition.timeoutMs % 1 == 0,
			`{testId}: timeoutMs must be a positive finite integer`
		)
		assert(
			string.sub(definition.modulePath, 1, 2) == "./"
				and string.find(definition.modulePath, "..", 1, true) == nil,
			`{testId}: modulePath must stay under tests`
		)
		if definition.suite == suite then
			table.insert(selected, definition)
		end
	end

	assert(#selected > 0, `no tests registered for suite {suite}`)
	table.sort(selected, function(left, right)
		return left.testId < right.testId
	end)
	return selected
end

return Harness
