--!strict

-- Fill only after the DEV universe ID and Studio API permissions are verified.
-- An absent binding keeps live DataStore access disabled; no environment is
-- inferred from a place name, branch or Studio session.
local binding: { environment: string?, declaredUniverseId: number? } = {
	environment = nil,
	declaredUniverseId = nil,
}

return table.freeze(binding)
