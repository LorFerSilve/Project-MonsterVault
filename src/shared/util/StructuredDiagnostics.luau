--!strict

-- Restrictive, structured diagnostics shared by both runtimes. Free-form data,
-- secrets, stack traces and player identifiers are not accepted as fields.
local allowedFields = table.freeze({
	component = true,
	requestId = true,
	operationId = true,
	seedId = true,
	detailCode = true,
	elapsedMs = true,
	count = true,
})

local StructuredDiagnostics = {}

function StructuredDiagnostics.new(
	sink: (any) -> (),
	unixSeconds: () -> number,
	environment: string
)
	assert(
		type(sink) == "function" and type(unixSeconds) == "function",
		"diagnostic dependencies required"
	)
	assert(environment == "server" or environment == "client", "invalid diagnostic environment")
	local sequence = 0
	local dropped = 0

	local function emit(severity: string, code: string, fields: any?)
		assert(severity == "info" or severity == "warn" or severity == "error", "invalid severity")
		assert(
			type(code) == "string" and string.match(code, "^[A-Z][A-Z0-9_]+$"),
			"invalid diagnostic code"
		)
		local safeFields = {}
		local givenFields: { [string]: any } = fields or {}
		for key, value in givenFields do
			assert(allowedFields[key] == true, "diagnostic field forbidden: " .. key)
			if type(value) == "string" then
				assert(
					#value <= 96 and string.match(value, "^[%w_:%.%-]*$") ~= nil,
					"invalid diagnostic field: " .. key
				)
			else
				assert(
					type(value) == "number" and value == value and math.abs(value) < math.huge,
					"invalid diagnostic field: " .. key
				)
			end
			safeFields[key] = value
		end
		local timestamp = unixSeconds()
		assert(
			type(timestamp) == "number"
				and timestamp == timestamp
				and math.abs(timestamp) < math.huge,
			"invalid diagnostic clock"
		)
		sequence += 1
		local record = {
			version = 1,
			environment = environment,
			sequence = sequence,
			atUnixSeconds = timestamp,
			severity = severity,
			code = code,
			fields = safeFields,
		}
		local ok = pcall(sink, record)
		if not ok then
			dropped += 1
		end
		return ok
	end

	return {
		emit = emit,
		dropped = function(): number
			return dropped
		end,
	}
end

return StructuredDiagnostics
