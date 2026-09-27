--!strict

-- Verified against the connected DEV Studio place (GameId) on 2026-09-25;
-- the user explicitly authorized Studio DataStore testing for this place.
local binding: { environment: string?, declaredUniverseId: number? } = {
	environment = "DEV",
	declaredUniverseId = 10766503968,
}

return table.freeze(binding)
