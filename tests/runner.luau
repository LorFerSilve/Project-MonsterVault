--!strict

-- Each test runs in a separate Lune process. A blocked pure-Luau loop cannot
-- starve the parent's watchdog, and no test can mutate another test's fixtures.
local processModuleName = "@lune/process"
local taskModuleName = "@lune/task"
local dateTimeModuleName = "@lune/datetime"
local process = require(processModuleName) :: any
local task = require(taskModuleName) :: any
local DateTime = require(dateTimeModuleName) :: any
local Harness = require("./Harness")
local manifest = require("./manifest")

local suite = "fast"
local index = 1
while index <= #process.args do
	local argument = process.args[index]
	if argument == "--" then
		index += 1
	elseif argument == "--suite" and process.args[index + 1] ~= nil then
		suite = process.args[index + 1]
		index += 2
	else
		error(
			`Unknown runner argument: {argument}. Usage: lune run tests/runner.luau -- --suite fast`
		)
	end
end

local selected = Harness.select(manifest, suite)
local failed = 0
for _, testCase in selected do
	local startedMs = DateTime.now().unixTimestampMillis
	local child = process.create("lune", {
		"run",
		"tests/run_one.luau",
		"--",
		"--suite",
		suite,
		"--id",
		testCase.testId,
	}, { cwd = process.cwd })
	local timedOut = false
	local watchdog = task.delay(testCase.timeoutMs / 1000, function()
		timedOut = true
		pcall(function()
			child:kill()
		end)
	end)
	local status = child:status()
	if not timedOut then
		task.cancel(watchdog)
	end
	local elapsedMs = DateTime.now().unixTimestampMillis - startedMs
	local stdout = child.stdout:read() or ""
	local stderr = child.stderr:read() or ""

	if timedOut or elapsedMs > testCase.timeoutMs then
		failed += 1
		print(`FAIL {testCase.testId}: timeout after {elapsedMs}ms (limit {testCase.timeoutMs}ms)`)
	elseif not status.ok then
		failed += 1
		print(`FAIL {testCase.testId}: child exited with code {status.code}`)
	else
		print(`PASS {testCase.testId} ({elapsedMs}ms)`)
	end
	if stdout ~= "" then
		print(stdout)
	end
	if stderr ~= "" then
		print(stderr)
	end
end

print(`{#selected - failed}/{#selected} {suite} tests passed`)
if failed > 0 then
	process.exit(1)
end
process.exit(0)
