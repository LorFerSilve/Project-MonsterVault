# Architecture Decisions

> **Status:** Active — TA-0..2 Complete / TA-3 Next
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



---

## AD-007 — Rojo Is the Primary Filesystem-to-Studio Synchronization Tool

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-1

### Decision

MonsterVault uses a filesystem-first Rojo workflow for first-party Luau and project configuration. Roblox Studio remains authoritative for engine execution.

### Consequence

Rojo-owned source is edited/reviewed through Git rather than maintained as an independent Studio source copy.

---

## AD-008 — Rokit Pins the Developer CLI Toolchain

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-1

### Decision

Supported CLI tooling uses explicit Rokit-managed versions rather than arbitrary global installations.

### Reference baseline

- Rojo 7.7.0;
- luau-lsp 1.69.0;
- StyLua 2.5.2;
- Selene 0.31.0.

TA-17 performs the final regression-validated version lock.

---

## AD-009 — First-Party Luau Defaults to Strict Type Checking

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-1

### Decision

New first-party MonsterVault source uses `.luau` and strict type checking by default.

`--!nocheck` and broad `any` usage are exceptions, not baseline patterns.

### Consequence

Type safety becomes part of the architecture quality baseline while runtime validation remains mandatory at trust boundaries.

---

## AD-010 — No Runtime Package Manager or Third-Party Luau Framework at Baseline

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-1

### Decision

Because MonsterVault currently has zero approved third-party runtime Luau packages, neither Wally nor pesde is adopted at baseline.

### Consequence

The first approved dependency triggers explicit package-manager, provenance, license, version-pin and lockfile review.

---

## AD-011 — DEV, STAGING, and PRODUCTION Are Distinct Environment Classes

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-1

### Decision

Local development, private pre-production validation and public production are separate environment classes.

Local development must not use production player persistence by default.

### Consequence

TA-4 must define concrete data/store isolation and TA-17 must define release promotion.

---

## AD-012 — Launch Defaults to One Primary Gameplay Place

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-1

### Decision

MonsterVault defaults to one primary gameplay place per environment at launch.

### Consequence

TA-9 may propose a multi-place topology only with technical evidence and lifecycle revalidation.


---

## AD-013 — Use a Modular-Monolith Runtime Architecture

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-2

### Decision

MonsterVault remains one Roblox runtime/deployable with explicit in-process domain ownership rather than premature microservice-style decomposition.

### Consequence

Cross-domain boundaries are enforced by module contracts and application orchestration, not by separate deployables.

---

## AD-014 — Lock Server, Client, and Shared as the Three First-Party Runtime Source Roots

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-2

### Decision

The future Rojo source roots are:

- `src/server` -> `ServerScriptService/MonsterVaultServer`;
- `src/client` -> `StarterPlayer/StarterPlayerScripts/MonsterVaultClient`;
- `src/shared` -> `ReplicatedStorage/MonsterVault/Shared`.

### Consequence

Later phases may add substructure but may not create parallel authority roots without TA-2 change control.

---

## AD-015 — Cross-Domain Operations Use Public Contracts and Application Orchestration

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-2

### Decision

A domain may not directly mutate another domain's private state.

Multi-domain operations are coordinated above domains through explicit application/use-case contracts.

### Consequence

Capture finalization, trade commit, production/economy claims and commercial reconciliation avoid circular ownership.

---

## AD-016 — Module Import Has No Long-Lived Runtime Side Effects

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-2

### Decision

Requiring a module does not create remotes, bind long-lived engine events, start loops or mutate persistent/gameplay state.

### Consequence

Lifecycle effects are explicit, testable and bootstrap-owned.

---

## AD-017 — Runtime Components Use Explicit Construction and Lifecycle

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-2

### Decision

The conceptual lifecycle is:

`Construct -> Validate -> Start -> Ready -> Stop/Shutdown`.

Dependencies are passed explicitly at composition time rather than retrieved from a global service locator.

### Consequence

Startup order, failure behavior and duplicate initialization become visible and testable.

---

## AD-018 — Platform Services Are Centralized by Technical Concern

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-2

### Decision

DataStore, Marketplace, cross-server, telemetry and other platform APIs are accessed through their owning infrastructure/adapters rather than scattered across feature/domain leaf modules.

### Consequence

TA-3 onward can define trust, retry, quota and test behavior centrally.

---

## AD-019 — Actual Source Scaffold Remains Deferred Until TA-17

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-2

### Decision

TA-2 locks the exact structural target but does not create gameplay/source scaffold files before the implementation gate.

### Consequence

The architecture remains specification-only until TA-17 explicitly opens implementation.
