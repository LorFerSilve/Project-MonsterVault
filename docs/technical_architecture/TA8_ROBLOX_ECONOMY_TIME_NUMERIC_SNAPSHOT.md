# TA-8 Roblox Economy, Time, Numeric, and Persistence Snapshot

> **Review date:** 2026-09-18  
> **Status:** PASS  
> **Purpose:** Record current Roblox/Luau platform behavior relevant to TA-8 timekeeping, exact numeric arithmetic, persistence retry semantics and DataStore throughput.

## 1. DateTime Wall Clock

Official source:

https://create.roblox.com/docs/reference/engine/datatypes/DateTime

Current behavior reviewed:

- `DateTime.now()` returns the current platform wall clock;
- `UnixTimestamp` exposes whole Unix seconds;
- `UnixTimestampMillis` exposes milliseconds.

TA-8 consequence:

> Persisted cross-session production boundaries use server-observed Unix timestamps. Client device clocks are never authoritative.

## 2. Workspace:GetServerTimeNow

Official source:

https://create.roblox.com/docs/reference/engine/classes/Workspace

Current behavior reviewed:

- `Workspace:GetServerTimeNow()` returns an estimated server Unix timestamp;
- the returned value is smoothed;
- it is monotonic and does not decrease;
- it is intended for synchronized timing.

TA-8 consequence:

> Live-session elapsed timing can use a monotonic server clock abstraction while persistent offline boundaries remain explicit Unix timestamps.

## 3. Luau Number Representation

Official source:

https://luau.org/syntax/

Current Luau behavior:

- Luau has one number type;
- it is a 64-bit IEEE-754 double;
- integers up to `2^53` are exactly representable.

TA-8 consequence:

> Energy and production persistence use bounded integers/fixed-point values whose validated worst-case arithmetic remains safely below `2^53`.

## 4. DataStore UpdateAsync

Official source:

https://create.roblox.com/docs/cloud-services/data-stores

Current behavior:

- `UpdateAsync()` receives current stored state and returns replacement state;
- its callback must not yield.

TA-8 consequence:

> Economy cost/effect and claim transfer mutations are expressed as pure atomic profile transforms under TA-4's one-writer queue.

## 5. Unknown Write Outcome

Official source:

https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits

Current Roblox documentation notes that a failed write response does not always prove the backend write did not happen.

TA-8 consequence:

> P2 economy operations must be idempotent and reconciled by stable operation identity. A transport/persistence error never means "run the economic effect again with a new identity."

## 6. DataStore Budgets and Throughput

Current Roblox documentation imposes:

- request-rate limits;
- read/write throughput limits;
- per-key and experience-level throttling;
- payload-size restrictions.

`UpdateAsync()` consumes both read and write budgets.

TA-8 consequence:

> Passive production is settled from elapsed time and persisted at meaningful checkpoints/transactions rather than writing every tick or every produced unit.

## 7. Profile Aggregate Fit

Roblox best-practice guidance favors avoiding unnecessary sharding when one logical record fits and remains within throughput limits.

TA-4 already chose one Player Profile aggregate baseline.

TA-8 consequence:

> Collection/Vault/Energy state remains within the Player Profile aggregate until measured size/throughput evidence requires a TA-4 change-control review.

## 8. Security Consequence

All time, price, wallet, assignment, rate, upgrade and offline-duration values received from clients are untrusted.

The client may display predicted production/wallet movement, but only server profile state can finalize value.

## Verdict

**TA-8 ROBLOX ECONOMY/TIME/NUMERIC PLATFORM SNAPSHOT: PASS.**
