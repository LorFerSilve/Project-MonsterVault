--!strict

local StructuredDiagnostics = require("../../src/shared/util/StructuredDiagnostics")

local function emitsBoundedRecord()
	local records = {}
	local diagnostics = StructuredDiagnostics.new(function(record)
		table.insert(records, record)
	end, function()
		return 1_700_000_000
	end, "server")
	local fields = { component = "bootstrap", elapsedMs = 12 }
	assert(diagnostics.emit("info", "BOOTSTRAP_READY", fields), "record sent")
	fields.component = "changed"
	assert(records[1].fields.component == "bootstrap", "sink receives copied fields")
	assert(records[1].version == 1 and records[1].sequence == 1, "stable record envelope")
	assert(
		records[1].atUnixSeconds == 1_700_000_000 and records[1].environment == "server",
		"context"
	)
	assert(diagnostics.dropped() == 0, "nothing dropped")
end

local function rejectsUnsafeFields()
	local diagnostics = StructuredDiagnostics.new(function() end, function()
		return 1
	end, "client")
	assert(
		not pcall(diagnostics.emit, "info", "SAFE_CODE", { userId = "123" }),
		"unapproved identifier rejected"
	)
	assert(
		not pcall(diagnostics.emit, "info", "SAFE_CODE", { component = "line\nsecret" }),
		"control character rejected"
	)
	assert(not pcall(diagnostics.emit, "info", "SAFE_CODE", { elapsedMs = 0 / 0 }), "NaN rejected")
	assert(not pcall(diagnostics.emit, "info", "bad code", {}), "invalid code rejected")
end

local function sinkFailureIsContained()
	local diagnostics = StructuredDiagnostics.new(function()
		error("sink unavailable")
	end, function()
		return 1
	end, "server")
	assert(not diagnostics.emit("warn", "SINK_FAILED", {}), "sink failure reported")
	assert(diagnostics.dropped() == 1, "drop counter increments")
end

return {
	emitsBoundedRecord = emitsBoundedRecord,
	rejectsUnsafeFields = rejectsUnsafeFields,
	sinkFailureIsContained = sinkFailureIsContained,
}
