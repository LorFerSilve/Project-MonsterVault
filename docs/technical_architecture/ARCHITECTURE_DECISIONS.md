# Architecture Decisions

> **Status:** Active — TA-0 Complete / TA-1 Next
> **Authority:** Accepted technical architecture decisions and rationale

This log records material architecture decisions. GDS-17 has formally promoted the Game Design Specification to Design Complete, so architecture decision-making may now begin under TA-0.

## Decision Format

Each architecture decision records:

- AD ID;
- date;
- status (`Proposed`, `Accepted`, `Superseded`, `Rejected`);
- owning TA phase;
- GDS requirements/constraints satisfied;
- context;
- decision;
- alternatives considered;
- security/performance/maintainability consequences;
- affected contracts;
- migration/change-control implications.

## Current State

TA-0 governance decisions are accepted below. Toolchain, source-layout, persistence-library, networking-pattern and other implementation-specific choices remain unlocked until their owning downstream TA phases.

---

## AD-001 — GDS Semantics Are Upstream Architecture Authority

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-0

### Decision

Technical Architecture may translate approved gameplay rules into implementation contracts but may not silently change player-facing semantics.

A required player-facing semantic change returns to the owning GDS through change control.

### Consequence

Architecture feasibility is never used as an undocumented design override.

---

## AD-002 — Security-Sensitive Value Is Server-Authoritative

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-0

### Decision

The client is untrusted for final ownership, Energy, rare/variant outcomes, progression, event rewards, trade results, purchases and moderation state.

### Consequence

TA-3 and all domain phases must design explicit server-side validation/commit ownership.

---

## AD-003 — Critical Architecture Requires GDS-to-TA-to-Verification Traceability

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-0

### Decision

Critical technical contracts must identify their GDS provenance and downstream verification evidence.

### Consequence

Traceability gaps block Architecture Complete and TA-17 implementation lock.

---

## AD-004 — Irreversible Retryable Operations Require Explicit Idempotency Identity

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-0

### Decision

Capture finalization, production claims, progression purchases, event rewards, trade commits, purchase grants and equivalent exact-once outcomes require stable operation/reward/transaction identity in their owning phases.

### Consequence

Retries/callback duplication cannot rely on client behavior or best-effort timing for correctness.

---

## AD-005 — Security, Performance, Failure Recovery, Testability, and Observability Are Architecture Closure Gates

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-0

### Decision

These concerns must be addressed during architecture, not postponed as implementation cleanup.

### Consequence

A phase with unresolved critical behavior in any applicable category cannot close.

---

## AD-006 — Implementation Remains Blocked Until TA-17

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-0

### Decision

TA-0 opens TA-1 only. Gameplay implementation remains blocked until TA-0..15 are Architecture Complete, TA-16 passes, and TA-17 locks implementation contracts/roadmap.

### Consequence

Architecture work does not authorize gameplay scripting before the final gate.

