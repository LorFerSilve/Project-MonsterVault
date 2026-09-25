# IMP-3 — Profile Session Foundation

> **Status:** Implementation complete; local and pull-request gates recorded below.
>
> **Base:** `main` after TA-9 through IMP-2 were incorporated.

## Delivered

- V1 Player Profile skeleton, structural/size validation, and an explicit migration boundary. No released pre-V1 schema exists, so unsupported older or newer versions enter protected load failure.
- Per-player `UpdateAsync` repository contract, deterministic fake, and Roblox adapter that preserves key metadata and UserIds. Environment-specific stores require an explicit universe binding; Studio is restricted to DEV.
- Atomic lease acquisition and stale-lease takeover, protected readiness states, monotonic content revisions, and a per-profile writer queue with critical priority.
- Bounded retries, staggered lease renewal/autosave, P1 settings buffering, P2 durable checkpoint with an operation marker before success, and final save plus lease release.
- Player departure and shutdown drains, including the race where departure occurs during acquisition or a checkpoint. Shutdown closes admission and reports failed drains.

## Local evidence

| Check | Result |
|---|---|
| StyLua check over src/tests/scripts | PASS |
| Selene over src/tests/scripts | PASS; 0 errors, 0 warnings |
| Rojo build and sourcemap | PASS |
| Strict luau-lsp analysis over src/tests/scripts | PASS; no type errors |
| Lune fast suite | PASS; 38/38 |
| Python checker regressions | PASS; 28/28 |
| Repository dependency and integrity scans | PASS |

The persistence C0 tests cover first load, failed load, current/stale leases, malformed schema and metadata, durable checkpoints and replay, operation identity protection, ownership/revision conflicts, autosave and recovery, queue/retry limits, multiple players, and leave/shutdown cutpoints. These tests use a fake repository and deterministic clocks; engine DataStore behavior still needs a connected DEV Studio environment.

## Pull-request CI evidence

Pending pull request and CI run.

## Runtime and release boundary

`ProfileBinding.luau` remains unset until a real DEV universe ID and its API permissions are verified. Thus the bootstrap does not open a DataStore by default. There is no connected Roblox Studio instance available for an engine playtest at this gate. The built Roblox place artifact and static analysis do not establish live DataStore behavior. STG/PROD and gameplay readiness remain gated by environment binding, engine tests and later phase verification. The in-profile recent-operation ledger is conservatively capped at 512 entries and rejects overflow; domain-specific longer-lived identities belong to later phases.

## Follow-up

IMP-4 connects validated networking and client projection to the server-owned readiness state. No client can grant its own persistence readiness.
