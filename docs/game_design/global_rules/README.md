# Global Rules

> **Status:** Design Complete  
> **Owning phase:** GDS-2 — Global Game Rules and Session Model

This directory is the authoritative home for project-wide gameplay invariants that must not be redefined independently by individual systems.

## Authoritative Specification

- [`02_global_game_rules_and_session_model.md`](02_global_game_rules_and_session_model.md) — **Design Complete**.

It defines:

- server-session and player-readiness lifecycle;
- join, late-join, leave, disconnect, reconnect, and server-shutdown semantics;
- Recovery after avatar failure/reset;
- session-scoped versus persistent player state;
- progression permanence across normal lifecycle transitions;
- Protected Load Failure when trusted persistent state is unavailable;
- finalized-outcome single-application semantics;
- generic finite-opportunity consistency requirements;
- offline and cross-server baseline behavior;
- persistent-timer and Global Window continuity;
- cross-platform lifecycle parity;
- universal anti-abuse constraints for reset/reconnect/server transitions.

## Validation Evidence

- [`../GDS2_SCENARIO_VALIDATION.md`](../GDS2_SCENARIO_VALIDATION.md) — 30 compound lifecycle scenarios; PASS.
- [`../GDS2_CROSS_VALIDATION.md`](../GDS2_CROSS_VALIDATION.md) — product/authority/contradiction audit; PASS.
- [`../GDS2_CLOSURE_REPORT.md`](../GDS2_CLOSURE_REPORT.md) — formal GDS-2 closure; PASS.

## Authority Boundary

This domain owns universal semantics only. Exact capture interruption, creature ownership transitions, economy values, offline-production amounts, world spawn rules, event server-hopping behavior, trade commit/rollback, monetization products, UI details, and technical persistence/networking mechanisms remain with their later GDS or Technical Architecture owners.
