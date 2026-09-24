--!strict

-- Only a server-owned provider may implement this contract in production.
-- A draw is a finite uniform sample in [0, 1]; callers own eligibility checks
-- and persist a logical outcome before a retry can occur (TA-7 RNG-01/02).
export type RandomSource = {
	nextUnit: () -> number,
}

return {}
