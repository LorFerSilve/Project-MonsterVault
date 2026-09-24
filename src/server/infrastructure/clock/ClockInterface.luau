--!strict

-- Persisted cross-session boundaries use server-observed Unix seconds (TA-8 CLOCK-01).
-- Live elapsed-time decisions use a separate monotonic server source (TA-8 CLOCK-02).
-- Providers are injected; this module performs no platform calls at import time.
export type WallClock = {
	unixSeconds: () -> number,
}

export type MonotonicClock = {
	seconds: () -> number,
}

return {}
