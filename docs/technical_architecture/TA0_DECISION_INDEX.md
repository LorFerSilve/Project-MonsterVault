# TA-0 Decision Index

> **Phase:** TA-0 — Architecture Governance, Constraints, and GDS Traceability  
> **Status:** Accepted

## TA0-D01 — GDS Semantics Outrank Architecture Convenience

**Decision:** TA translates approved gameplay behavior but cannot silently redefine it.

## TA0-D02 — Every Critical Technical Contract Has One Owner

**Decision:** Persistent state families, runtime transitions, remote handlers and transaction commits require one authoritative technical owner.

## TA0-D03 — Server Authority Covers Persistent/Competitive/Commercial Value

**Decision:** Client input is untrusted for ownership, currency, rare outcomes, progression, rewards, trade, purchases and moderation.

## TA0-D04 — GDS-to-TA-to-Test Traceability Is Mandatory

**Decision:** Critical requirements must trace from GDS source to TA technical contract to verification evidence and ultimately implementation component.

## TA0-D05 — Exact-Once GDS Outcomes Require Explicit Idempotency Identity

**Decision:** Retryable irreversible operations must define stable operation/reward/transaction identity downstream.

## TA0-D06 — Architecture Is Failure-Safe and Value-Preserving

**Decision:** On uncertainty/failure, preserve prior valid state and avoid duplication/deletion rather than guessing.

## TA0-D07 — Security, Performance, Testability, and Observability Are Closure Requirements

**Decision:** They are not post-implementation cleanup categories.

## TA0-D08 — Architecture Uses Explicit Dependency Direction

**Decision:** Hidden globals, cyclic domain authority and direct cross-domain internal mutation are prohibited.

## TA0-D09 — Material Cross-Phase Decisions Use Global ADRs

**Decision:** Global `AD-xxx` records complement phase-local `TAx-Dxx` decisions.

## TA0-D10 — Architecture Risk Families Have Named Owners

**Decision:** R1 through R12 are assigned to concrete TA phases; unowned implementation-critical risks block TA-17.

## TA0-D11 — Technical Conflicts Return to the Owning Layer

**Decision:** Upstream TA flaws reopen upstream TA; player-facing conflicts reopen the owning GDS.

## TA0-D12 — Close TA-0 and Advance to TA-1

**Decision:** TA-0 is Architecture Complete — PASS. TA-1 becomes NEXT; gameplay implementation remains blocked.
