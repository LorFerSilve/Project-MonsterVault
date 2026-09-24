--!strict

local ResultCodes = require("../../src/shared/contracts/ResultCodes")

local function check(condition: boolean, message: string?)
	if not condition then
		error(message or "result code assertion failed", 2)
	end
end

local function run()
	check(ResultCodes.familyOf("OK_ACCEPTED") == "OK")
	check(ResultCodes.familyOf("REJECT_VALIDATION_INVALID_PAYLOAD") == "REJECT_VALIDATION")
	check(ResultCodes.familyOf("REJECT_PERMISSION_NOT_AUTHORIZED") == "REJECT_PERMISSION")
	check(ResultCodes.familyOf("REJECT_STATE_STALE_REVISION") == "REJECT_STATE")
	check(ResultCodes.familyOf("REJECT_RATE_LIMIT") == "REJECT_RATE_LIMIT")
	check(ResultCodes.familyOf("PENDING_OPERATION") == "PENDING")
	check(ResultCodes.familyOf("OUTCOME_UNKNOWN_OPERATION") == "OUTCOME_UNKNOWN")
	check(ResultCodes.familyOf("PROTECTED_LOAD_FAILURE") == "PROTECTED")
	check(ResultCodes.familyOf("UNAVAILABLE_SERVICE") == "UNAVAILABLE")

	check(ResultCodes.familyOf("OK_") == nil)
	check(ResultCodes.familyOf("OK_accepted") == "OK")
	check(ResultCodes.familyOf("REJECT_RATE_LIMIT_EXTRA") == nil)
	check(ResultCodes.familyOf("SERVER_INTERNAL_STACK_TRACE") == nil)
	check(ResultCodes.familyOf(12) == nil)
	check(ResultCodes.familyOf({}) == nil)
	check(table.isfrozen(ResultCodes))
	check(table.isfrozen(ResultCodes.prefixes))
end

return { run = run }
