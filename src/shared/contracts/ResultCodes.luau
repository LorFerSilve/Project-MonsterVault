--!strict

-- Only public code families are fixed in IMP-1. Individual domain outcomes
-- will be named by their owning route/domain as those routes are implemented.
local prefixes: { [string]: string } = table.freeze({
	ok = "OK_",
	rejectValidation = "REJECT_VALIDATION_",
	rejectPermission = "REJECT_PERMISSION_",
	rejectState = "REJECT_STATE_",
	pending = "PENDING_",
	outcomeUnknown = "OUTCOME_UNKNOWN_",
	protected = "PROTECTED_",
	unavailable = "UNAVAILABLE_",
})

local ResultCodes = {
	prefixes = prefixes,
	rejectRateLimit = "REJECT_RATE_LIMIT",
}

export type Family =
	"OK"
	| "REJECT_VALIDATION"
	| "REJECT_PERMISSION"
	| "REJECT_STATE"
	| "REJECT_RATE_LIMIT"
	| "PENDING"
	| "OUTCOME_UNKNOWN"
	| "PROTECTED"
	| "UNAVAILABLE"

local function hasSuffix(value: string, prefix: string): boolean
	return #value > #prefix and string.sub(value, 1, #prefix) == prefix
end

-- Categorization is not an allowlist for route-specific result codes.
function ResultCodes.familyOf(value: unknown): Family?
	if type(value) ~= "string" then
		return nil
	end
	local code = value :: string
	if code == ResultCodes.rejectRateLimit then
		return "REJECT_RATE_LIMIT"
	end
	for key, prefix in prefixes do
		if hasSuffix(code, prefix) then
			if key == "ok" then
				return "OK"
			elseif key == "rejectValidation" then
				return "REJECT_VALIDATION"
			elseif key == "rejectPermission" then
				return "REJECT_PERMISSION"
			elseif key == "rejectState" then
				return "REJECT_STATE"
			elseif key == "pending" then
				return "PENDING"
			elseif key == "outcomeUnknown" then
				return "OUTCOME_UNKNOWN"
			elseif key == "protected" then
				return "PROTECTED"
			elseif key == "unavailable" then
				return "UNAVAILABLE"
			end
		end
	end
	return nil
end

return table.freeze(ResultCodes)
