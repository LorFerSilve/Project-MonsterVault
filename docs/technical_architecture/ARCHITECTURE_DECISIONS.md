# Architecture Decisions

> **Status:** Active — TA-0..4 Complete / TA-5 Next
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


---

## AD-020 — Use a Small Central Versioned Remote Transport

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-3

### Decision

MonsterVault uses a centrally governed versioned Remote registry with:

- reliable client-to-server Command RemoteEvent;
- reliable server-to-client Event RemoteEvent;
- optional server-to-client UnreliableRemoteEvent for loss-tolerant presentation only.

### Consequence

Feature/domain code does not create independent RemoteEvent sprawl.

---

## AD-021 — Client Networking Carries Intent, Never Authoritative Outcomes

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-3

### Decision

Client requests cannot finalize ownership, currency, progression, rare outcomes, capture, event rewards, trade, commercial entitlements or moderation state.

### Consequence

Every sensitive request is revalidated and committed by the owning server-side contract.

---

## AD-022 — No RemoteFunctions in the Baseline Protocol

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-3

### Decision

MonsterVault uses asynchronous RemoteEvent request/result messaging rather than yielding RemoteFunction calls.

Server `InvokeClient` is prohibited for correctness.

### Consequence

Timeout/disconnect behavior is explicit and no authoritative server path waits on an untrusted client callback.

---

## AD-023 — Every Client Command Uses the Standard Validation Pipeline

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-3

### Decision

Commands pass envelope, protocol/route, rate, readiness, exact schema, semantic authorization, authoritative execution and safe result/telemetry stages.

### Consequence

Networking remains a thin trust gateway rather than a parallel gameplay-authority layer.

---

## AD-024 — Network Request IDs Are Correlation Keys, Not Durable Value IDs

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-3

### Decision

Client request IDs support async correlation and bounded session duplicate handling.

Durable exact-once outcomes use server-owned downstream operation identities.

### Consequence

Client-controlled identity cannot become the sole authority for persistent grants/transfers.

---

## AD-025 — Client Physics and Prompt Events Are Untrusted for Critical Outcomes

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-3

### Decision

Position/timing/context-sensitive interactions triggered through client network ownership, ProximityPrompt, ClickDetector or DragDetector are revalidated server-side.

### Consequence

Local movement/prompt manipulation cannot directly mint or transfer persistent value.

---

## AD-026 — UnreliableRemoteEvent Is Presentation-Only

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-3

### Decision

Loss/reordering-tolerant transport may carry transient visual data only. No baseline client-to-server unreliable gameplay stream is authorized.

### Consequence

Persistent/gameplay correctness never depends on unreliable delivery.

---

## AD-027 — Close TA-3 and Advance to TA-4

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-3

### Decision

TA-3 is Architecture Complete — PASS with 140/140 scenarios passing and zero blocking questions.

### Consequence

TA-4 becomes NEXT. Gameplay implementation remains blocked until TA-17.


---

## AD-028 — Standard DataStore Player Profile Aggregate Is Durable Player Authority

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-4

### Decision

MonsterVault uses one standard DataStore Player Profile aggregate per user at baseline.

Related player-local persistent state stays together while safely within measured size/throughput budgets.

### Consequence

Single-player transactions can remain coherent under one aggregate UpdateAsync, and premature sharding is avoided.

---

## AD-029 — Writable Player Sessions Use an Atomic DataStore Metadata Lease

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-4

### Decision

Profile acquisition, renewal and release use UpdateAsync plus compact key metadata so at most one server owns writable player-session authority.

### Consequence

Fresh foreign locks are respected; stale locks may be reclaimed only after expiration. Lock loss ends write authority.

---

## AD-030 — Load Failure Never Becomes Writable Default Data

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-4

### Decision

A DataStore failure is distinct from a genuinely missing player key.

### Consequence

MonsterVault never saves a default/blank profile over unknown historical player data after load failure.

---

## AD-031 — Persistent Mutations Use P0 / P1 / P2 Durability Classes

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-4

### Decision

- P0 is session-only;
- P1 is buffered durable;
- P2 is durable-before-final-ack.

GDS Finalized Outcomes and critical player value are P2.

### Consequence

A critical persistent result is not presented as durably final before its checkpoint succeeds.

---

## AD-032 — Player Profile Writes Are UpdateAsync, Revisioned, and Serialized

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-4

### Decision

All profile writes pass through one first-party persistence repository, one writer pipeline per profile key, the current session lease, and a monotonic profile revision.

### Consequence

Domains do not call DataStore directly and unexpected concurrency fails closed.

---

## AD-033 — Profile Schema Migrations Are Sequential, Pure, and Fail Closed

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-4

### Decision

Profiles carry a schemaVersion. Older supported profiles migrate deterministically; newer-than-server schemas are never downgraded.

### Consequence

Rollback servers cannot silently corrupt data created by newer code.

---

## AD-034 — Server-Owned Operation IDs Provide Durable Exact-Once Identity

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-4

### Decision

TA-3 client request IDs remain network correlation. Durable mutations use server-owned operation identities and bounded/dedicated dedupe records according to replay horizon.

### Consequence

Client-controlled IDs cannot be the sole authority for persistent value grants or transfers.

---

## AD-035 — Cross-Profile Atomicity Requires a Durable Transaction Journal

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-4

### Decision

MonsterVault does not pretend two sequential DataStore writes are an atomic multi-player transaction.

Cross-profile exact-once flows use a durable transaction record with idempotent participant application and recovery.

### Consequence

TA-10 must build Trade Commit on this primitive.

---

## AD-036 — DataStore Version History Is Operator Recovery, Not Runtime Auto-Rollback

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-4

### Decision

Invalid/corrupt current player state enters protected handling. Previous DataStore versions are inspected/reverted through controlled operations rather than selected automatically by runtime code.

---

## AD-037 — Native First-Party Persistence Repository Is the Baseline

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-4

### Decision

No third-party player-profile persistence library is adopted at baseline.

### Consequence

Any later ProfileStore/ProfileService-equivalent dependency requires TA-1 dependency/supply-chain review and TA-4 semantic compatibility review.

---

## AD-038 — Close TA-4 and Advance to TA-5

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-4

### Decision

TA-4 is Architecture Complete — PASS with 180/180 scenarios and zero blocking questions.

### Consequence

TA-5 becomes NEXT. Gameplay implementation remains blocked until TA-17.
