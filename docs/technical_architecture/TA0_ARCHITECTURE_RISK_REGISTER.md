# TA-0 Architecture Risk Register

> **Phase:** TA-0 — Architecture Governance, Constraints, and GDS Traceability  
> **Status:** Active / Seeded  
> **Purpose:** Seed the architecture risk taxonomy and assign each risk family to the TA phase responsible for resolving or bounding it before implementation opens.

| ID | Risk family | Primary owner | Supporting phases | Required closure evidence |
|---|---|---|---|---|
| R1 | Persistence/data loss | TA-4 | TA-8, TA-10, TA-11, TA-15 | session ownership, recovery, migration, fault tests |
| R2 | Duplication/idempotency | TA-4 | TA-7, TA-8, TA-10, TA-11, TA-15 | operation IDs, retry rules, duplicate tests |
| R3 | Client/remote exploitation | TA-3 | TA-7..12, TA-15 | trust boundaries, validation, abuse tests |
| R4 | Race/concurrency | owning transaction phase | TA-3, TA-4, TA-15 | lock/commit semantics, conflicting-operation tests |
| R5 | Cross-server consistency | TA-10 | TA-4, TA-9, TA-13, TA-15 | occurrence/message/cache model, failure tests |
| R6 | Purchase/entitlement recovery | TA-11 | TA-4, TA-15 | receipt idempotency/reconciliation tests |
| R7 | Performance/scalability | TA-14 | TA-3..13, TA-15 | numeric budgets, representative load scenarios |
| R8 | Roblox API/policy drift | TA-1 | TA-11, TA-12, TA-13, TA-15 | current API/policy review, compatibility plan |
| R9 | Configuration/live-ops safety | TA-13 | TA-5, TA-9, TA-10, TA-15 | versioning, validation, rollout/rollback, kill switch |
| R10 | Analytics/experiment integrity | TA-13 | TA-4, TA-15 | exposure identity, dedupe, invariant checks |
| R11 | Dependency/module coupling | TA-2 | all domain TA phases | dependency graph, cycle checks, ownership boundaries |
| R12 | Test/observability gaps | TA-15 | all phases | deterministic tests, diagnostics, CI evidence |

## Governance

- A risk is **Open** until its primary TA phase defines the required architecture contract.
- A risk may be **Transferred** only to a named downstream phase with explicit rationale.
- A risk is **Bounded** when architecture defines safe limits/fallbacks and verification evidence.
- A risk is **Closed** when the relevant TA phase and TA-16 integration audit accept the evidence.
- TA-17 may not open implementation with an unowned implementation-critical risk.

## Initial Result

All architecture risk families have an explicit owner.

Unowned implementation-critical risk classes: **0**.
