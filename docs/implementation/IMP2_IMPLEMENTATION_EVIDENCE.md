# IMP-2 — Composition and Diagnostics

> **Status:** Implementation and local gate PASS; pull-request CI pending
>
> **Base:** imp/imp-1-contracts-test-harness (IMP-1 PR #38 is open)

## Delivered

- Exactly one server and one client executable bootstrap entrypoint, each delegating to its composition root.
- Explicit lifecycle plan with stable dependency ordering, duplicate/missing/cyclic registration rejection, no start on import, reverse stop, and rollback after partial startup failure.
- Server startup validation of the V1 route registry and command classes before service startup.
- Server shutdown coordinator that closes admission before draining, runs stops in reverse order, reports callback/deadline failures, and is idempotent. The current phase has no irreversible operations to admit.
- Versioned structured diagnostics with bounded, allowlisted fields and contained sink failures; bounded server bootstrap counters and timing aggregates.

No gameplay, remote handlers, player profiles, persistence mutations or client authority were added.

## Local evidence

| Check | Result |
|---|---|
| StyLua check over src/tests/scripts | PASS |
| Selene over src/tests/scripts | PASS; 0 errors, 0 warnings |
| Rojo build and sourcemap | PASS |
| Strict luau-lsp analysis over src/tests/scripts | PASS; no type errors |
| Lune fast suite | PASS; 21/21 |
| Python checker regressions | PASS; 28/28 |
| Repository dependency and integrity scans | PASS |

The 10 new fast tests cover deterministic lifecycle order, duplicate/missing/cyclic registration, startup rollback, reverse shutdown/deadline, diagnostic safety/sink failure, and bounded counters. The Luau analyzer still lacks Roblox engine definition files, so its success does not prove live engine behavior.

## Studio boundary

Roblox Studio MCP was reachable but `list_roblox_studios` returned no connected Studio instances during this phase. A Studio playtest and live server/client startup observation could not be performed. The Rojo build validates the DataModel artifact; it does not replace an engine playtest. No staging or production deployment is claimed.

## Follow-up

- IMP-3 adds the profile session foundation and real persistence drains behind this composition lifecycle.
- The shutdown coordinator checks the budget between callbacks; it cannot preempt a callback that yields indefinitely. Each future drain must enforce its own time bound.
- TA-17's upstream PR chain must merge before this stacked phase can merge into `main`.
