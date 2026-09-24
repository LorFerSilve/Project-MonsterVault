--!strict

-- Internal entrypoint: the parent runner owns the per-test watchdog.
local processModuleName = "@lune/process"
local process = require(processModuleName) :: { args: { string }, exit: (number) -> () }
local Harness = require("./Harness")
local manifest = require("./manifest")

local suite: string? = nil
local testId: string? = nil
local index = 1
while index <= #process.args do
	local argument = process.args[index]
	if argument == "--" then
		index += 1
	elseif argument == "--suite" and process.args[index + 1] ~= nil then
		suite = process.args[index + 1]
		index += 2
	elseif argument == "--id" and process.args[index + 1] ~= nil then
		testId = process.args[index + 1]
		index += 2
	else
		error(`Unknown single-test argument: {argument}`)
	end
end

assert(suite ~= nil and testId ~= nil, "single-test runner requires --suite and --id")
local selected = Harness.select(manifest, suite)
for _, testCase in selected do
	if testCase.testId == testId then
		local ok, failure = pcall(function()
			local module = require(testCase.modulePath) :: any
			local run = module[testCase.exportName]
			assert(
				type(run) == "function",
				`{testId}: export {testCase.exportName} is not a function`
			)
			run()
			return true
		end)
		if not ok then
			print(tostring(failure))
			process.exit(1)
		end
		return
	end
end

error(`TestId {testId} is not registered in suite {suite}`)
