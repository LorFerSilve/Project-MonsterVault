# Architecture Decisions

> **Status:** Active — TA-0..10 Complete / TA-11 Next
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


---

## AD-039 — Stable MonsterVault Semantic IDs Are Canonical

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-5

### Decision

Persistent and cross-system semantic references use MonsterVault-owned canonical IDs rather than display names, Studio paths, list indexes, or environment-specific Roblox asset/product IDs.

### Consequence

Content can be renamed, localized, visually updated or rebound to platform IDs without invalidating persistent meaning.

---

## AD-040 — Canonical Static IDs Are Immutable and Never Reused

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-5

### Decision

Shipped content IDs remain stable for the lifetime of persisted/historical references. Retired IDs are never assigned to unrelated content.

### Consequence

Content retirement uses Retired/Tombstone compatibility rather than deletion/reuse.

---

## AD-041 — Dynamic Entity IDs Are Server-Generated GUID-Style IDs

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-5

### Decision

CreatureInstanceId and comparable runtime identities are server-generated and never reused.

### Consequence

Clients cannot choose ownership/entity identity and transfers preserve the same instance identity.

---

## AD-042 — Content Registries Are Declarative, Typed, Validated, and Immutable Per Snapshot

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-5

### Decision

Canonical definitions are data rather than executable gameplay callbacks, and core registries fully validate before dependent systems start.

### Consequence

Duplicate IDs, broken references and invalid core configuration fail bootstrap closed.

---

## AD-043 — Public and Server-Private Content Definitions Are Separated

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-5

### Decision

Replicated definitions contain disclosure-safe fields only. Hidden probabilities, anti-abuse rules, unrevealed rewards and authoritative commercial grant mappings remain server-private.

### Consequence

Replicated content cannot become an accidental side channel for hidden authority state.

---

## AD-044 — Content Lifecycle Is Active / Retired / Tombstone

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-5

### Decision

Definitions with persistent/historical references remain resolvable after new generation/availability ends.

### Consequence

Referenced content cannot simply be deleted without migration/compatibility handling.

---

## AD-045 — Configuration Is Classified C0 / C1 / C2 / C3

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-5

### Decision

Semantic invariants and static build content are not arbitrary live tuneables. TA-13 may update only explicitly allowlisted C2 fields through validated versioned snapshots.

### Consequence

Live operations/experiments cannot silently redefine GDS/TA semantics.

---

## AD-046 — External Roblox IDs Are Environment Bindings

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-5

### Decision

Internal Product/Content IDs remain stable across DEV/STAGING/PRODUCTION while Roblox asset/product IDs map explicitly per environment.

### Consequence

Persisted entitlement/content semantics do not depend on environment-specific platform numbers.

---

## AD-047 — Tags and Attributes Are Authoring Metadata, Not Semantic Authority

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-5

### Decision

CollectionService tags declare structural roles and disclosure-safe attributes carry stable IDs. Replicated tags/attributes do not contain hidden odds/security/private grant state.

### Consequence

World authoring remains data-driven without moving canonical content authority into Workspace metadata.

---

## AD-048 — Content Snapshot Identity Preserves Prospective Configuration Semantics

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-5

### Decision

Validated content/config state has a ContentSnapshotId that downstream systems may pin where provenance, event fairness or anti-reroll semantics require it.

### Consequence

Later config changes affect future actions and never reroll existing generated identity.

---

## AD-049 — Close TA-5 and Advance to TA-6

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-5

### Decision

TA-5 is Architecture Complete — PASS with 180/180 scenarios and zero blocking questions.

### Consequence

TA-6 becomes NEXT. Gameplay implementation remains blocked until TA-17.


---

## AD-050 — Server Runtime Records Are Authoritative; Roblox Instances Are Projections

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-6

### Decision

Dynamic gameplay state lives in server-owned runtime records. Workspace Models/Parts are disposable projections and do not own semantic or persistent truth.

### Consequence

Streaming, local destruction or projection failure cannot independently create or erase gameplay ownership/state.

---

## AD-051 — Player Session and Character Presence Are Separate Lifecycles

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-6

### Decision

One Player Session may contain multiple Character generations. Character failure/reset/removal does not destroy the persistent profile/session.

### Consequence

Recovery and respawn become runtime transitions rather than persistence reloads or wipes.

---

## AD-052 — Dynamic Runtime Entities Use an Explicit Registry, Revision, and Lifecycle

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-6

### Decision

Runtime entities are server-registered by stable ID, carry a runtimeRevision, and transition through explicit creation/active/quiescing/terminal states.

### Consequence

Stale commands/timers/callbacks can be rejected deterministically.

---

## AD-053 — Character Presence Uses a Generation Identity

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-6

### Decision

Each replacement avatar increments a session-local character generation so work tied to a previous Character cannot mutate the new one.

---

## AD-054 — World Creature Identity Survives Acquisition Failure Until Genuine Termination

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-6

### Decision

A surviving World Creature keeps one CreatureInstanceId and Variant Identity through claim/capture interruption. Only genuine entity termination permits a later independent replacement.

---

## AD-055 — Active Acquisition Protects Against Ordinary Idle Despawn

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-6

### Decision

Engagement Claim, Capture Attempt, Provisional Capture and Transport Custody states are not ended by ordinary encounter-idle lifetime expiration.

### Consequence

TA-7 owns their resolution.

---

## AD-056 — Secured Ownership Preserves the Existing CreatureInstanceId

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-6

### Decision

When TA-7/TA-4 finalize ownership, the same creature instance transitions out of its public world role; an owned replacement identity is not minted.

---

## AD-057 — Streaming and Physics Ownership Are Not Gameplay Authority

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-6

### Decision

Client Workspace visibility and Roblox physics network ownership are presentation/simulation concerns only.

### Consequence

Client stream-out, Touched events and client-owned physics cannot finalize ownership/reward/state without server validation.

---

## AD-058 — Every Runtime Entity Has One Idempotent Cleanup Owner

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-6

### Decision

The lifecycle owner tracks and cleans connections, tasks/timers, projections, registry bindings and long-lived references.

### Consequence

Entity/player churn does not accumulate hidden listeners or stale runtime state.

---

## AD-059 — Close TA-6 and Advance to TA-7

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-6

### Decision

TA-6 is Architecture Complete — PASS with 190/190 scenarios and zero blocking questions.

### Consequence

TA-7 becomes NEXT. Gameplay implementation remains blocked until TA-17.


---

## AD-060 — Ordinary Capture Uses a Server-Owned Per-Creature State Machine

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-7

### Decision

Claim, attempt, provisional, transport and finalization transitions are serialized by CreatureInstanceId. The first currently eligible server-accepted BeginClaim transition wins.

### Consequence

Client timestamps, ping, party state and premium state cannot arbitrate finite ordinary claims.

---

## AD-061 — Variant Identity Is Generated Exactly Once Before Actionability

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-7

### Decision

Species Rarity, Mutation set, Traits, Variant Signature and generation snapshot are server-finalized before a creature becomes individually actionable.

### Consequence

Claim/capture/reconnect/transport/finalization retries cannot reroll one surviving Creature Instance.

---

## AD-062 — Production Randomness Is Server-Owned Behind an Injectable RNG Contract

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-7

### Decision

Production uses a server-owned first-party RNG abstraction backed by Roblox Random without client-selected seeds. Tests may inject deterministic seeded/fake generators.

### Consequence

Critical random outcomes remain authoritative while statistical and boundary tests are reproducible.

---

## AD-063 — Capture Success Creates Provisional Custody, Not Persistent Ownership

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-7

### Decision

Capture Success creates one Provisional Capture and one Transport Custody holder for the existing CreatureInstanceId. No Collection ownership is written at this stage.

---

## AD-064 — Provisional Capture Gets One Durable Ownership Finalization Operation ID

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-7

### Decision

The server generates the ownership finalization operation identity when Provisional Capture begins. Normal extraction, retry/reconciliation and protected orderly-shutdown finalization reuse that same logical operation.

---

## AD-065 — Secured Ownership Is an Atomic P2 Creature/Discovery/Protection Bundle

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-7

### Decision

The same CreatureInstanceId, immutable Variant Identity, provenance, placement/Overflow outcome, Protected auto-lock and Species/Mutation/Variant discoveries commit before the client is told the creature is Secured.

---

## AD-066 — Capacity Race After Valid Acquisition Resolves to Overflow-Held

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-7

### Decision

Known-full capacity blocks new ordinary capture initiation. If capacity becomes unavailable only after a valid loop was accepted, the final creature is retained via Overflow-Held rather than deleted.

---

## AD-067 — Transport Grace Is Same-Server, Bounded, and Non-Persistent

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-7

### Decision

Unexpected/ambiguous disconnect may suspend active Transport Custody briefly for same-server resume. Grace grants no ownership, cannot cross servers, and expiry ends the provisional state.

### Consequence

Current coarse Roblox PlayerExitReason signaling is handled conservatively without converting ambiguous disconnect into persistent value.

---

## AD-068 — Controlled Shutdown Protects Only Active Valid Transport Custody

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-7

### Decision

Orderly server drain can invoke the existing ownership finalization operation for active valid Transport Custody only. Idle, claimed, attempt-only, expired and disconnected-grace states are not auto-secured.

---

## AD-069 — Ordinary Capture Does Not Implicitly Grant Energy

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-7

### Decision

The baseline capture outcome is the Secured Creature plus explicitly authorized discovery/milestone changes. Any Energy/event reward must be owned elsewhere and remain exact-once.

---

## AD-070 — Close TA-7 and Advance to TA-8

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-7

### Decision

TA-7 is Architecture Complete — PASS with 200/200 scenarios and zero blocking questions.

### Consequence

TA-8 becomes NEXT. Gameplay implementation remains blocked until TA-17.


---

## AD-071 — Collection, Vault, and Economy Share the Player Profile Aggregate

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-8

### Decision

Secured collection placement, Vault assignments/upgrades, Production Buffer, Energy and progression state remain inside TA-4's atomic one-profile authority.

---

## AD-072 — Energy Uses a Bounded Exact Integer Representation

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-8

### Decision

Energy is stored as whole integer units with a hard safety ceiling of 1,000,000,000,000. Production uses fixed-point milli-Energy and all validated arithmetic remains below Luau's exact integer limit.

---

## AD-073 — Passive Production Uses Elapsed-Time Settlement

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-8

### Decision

Production is computed at explicit state/checkpoint/claim boundaries from authoritative elapsed time rather than per-frame simulation or per-unit DataStore writes.

---

## AD-074 — Production Assignment Changes Are P2

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-8

### Decision

Assignment/unassignment first settles prior accrued value, then persists the new assignment before final acknowledgement because assignment state governs future and offline value.

---

## AD-075 — Offline Production Uses Clean Boundaries and Bounded Crash Recovery

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-8

### Decision

Clean leave accrues at most one Offline Production Window. An unclean prior session may receive only Offline Window plus a bounded crash-recovery allowance tied to maximum uncheckpointed active time.

---

## AD-076 — Production Rate Changes Are Effective-Time Epochs

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-8

### Decision

Production tuning changes are versioned with effective timestamps so elapsed intervals crossing a change settle piecewise and never rewrite historical output.

---

## AD-077 — Capacity Reconciliation Is Deterministic and Non-Destructive

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-8

### Decision

Capacity decreases settle production, clear invalid role references and move deterministic exact Creature Instances into Overflow-Held. Automatic ordering does not use rarity, subjective value or spending.

---

## AD-078 — Production Claim Atomically Moves Buffer Value into Energy

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-8

### Decision

A Production Claim settles current output and atomically decreases fixed-point Production Buffer while increasing whole-unit Energy. Wallet-limit remainder stays in the buffer.

---

## AD-079 — One-Time Wallet Overflow Uses Deferred Energy Grants

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-8

### Decision

One-time/event/commercial Energy value that cannot fit in the wallet is preserved through bounded persistent Deferred Energy Grant records rather than silently lost.

---

## AD-080 — Progression Purchases Use Server Quotes and Atomic Cost/Effect

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-8

### Decision

Vault Upgrades, Capture Capability and Access Unlock purchases use server-issued price/prerequisite quotes and one P2 mutation that applies both exact cost and exact effect or neither.

---

## AD-081 — Commercial Capacity Is Isolated from Production Capability

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-8

### Decision

Paid capacity contributes only to bounded Collection/Display capacity. It cannot increase Production Slots, Production Buffer, Offline Window, production rate or Capture Capability.

---

## AD-082 — Close TA-8 and Advance to TA-9

**Date:** 2026-09-18  
**Status:** Accepted  
**Owning TA phase:** TA-8

### Decision

TA-8 is Architecture Complete — PASS with 220/220 scenarios and zero blocking questions.

### Consequence

TA-9 becomes NEXT. Gameplay implementation remains blocked until TA-17.


---

## AD-083 — Keep the Launch World in One Primary Gameplay Place

**Date:** 2026-09-22  
**Status:** Accepted  
**Owning TA phase:** TA-9

### Decision

Home Hub, Starter, both Mid Biomes and Advanced Biome are logical Regions inside the primary gameplay place at baseline. Ordinary region progression does not require a cross-place teleport boundary.

### Consequence

World/capture/transport/session semantics remain local to one server process unless a later architecture change explicitly introduces multi-place behavior.

---

## AD-084 — Build an Immutable Validated World Authoring Index

**Date:** 2026-09-22  
**Status:** Accepted  
**Owning TA phase:** TA-9

### Decision

Typed content registries plus disclosure-safe Studio tags/attributes are validated at bootstrap into one immutable server-side index of Regions, Habitats, Landmarks, utilities, hazards and spawn scopes.

### Consequence

Workspace names/paths are not semantic authority and invalid required authoring fails bootstrap closed.

---

## AD-085 — Use One Centralized Staggered Ordinary Spawn Scheduler

**Date:** 2026-09-22  
**Status:** Accepted  
**Owning TA phase:** TA-9

### Decision

Ordinary spawn work is coordinated through bounded Habitat/area queues rather than one permanent loop per spawn point or creature.

### Consequence

Scheduler work can be staggered, budgeted and load-shed deterministically.

---

## AD-086 — Population Scaling Changes Counts, Not Personalized Odds

**Date:** 2026-09-22  
**Status:** Accepted  
**Owning TA phase:** TA-9

### Decision

Player population and server performance may alter encounter counts within authored min/base/max bounds but never alter collectible odds by player, payer state, device or monetization behavior.

### Consequence

Performance/scaling cannot silently become a rarity-personalization system.

---

## AD-087 — Create a Stable Spawn Reservation Before Materialization

**Date:** 2026-09-22  
**Status:** Accepted  
**Owning TA phase:** TA-9

### Decision

One Spawn Reservation fixes Spawn Context/config snapshot, Species, CreatureInstanceId and complete TA-7 Variant Identity before Roblox projection materialization.

### Consequence

Placement, projection, streaming and claim retries cannot reroll the same logical creature.

---

## AD-088 — Derive Ordinary World Cycle from a Shared Time Epoch

**Date:** 2026-09-22  
**Status:** Accepted  
**Owning TA phase:** TA-9

### Decision

Ordinary World Cycle phase is calculated from server-observed time and a versioned epoch/cycle definition.

### Consequence

Joining or server hopping does not restart a favorable cycle and ordinary cycle operation needs no global coordinator.

---

## AD-089 — Keep Ordinary Encounter Populations Server-Session Local

**Date:** 2026-09-22  
**Status:** Accepted  
**Owning TA phase:** TA-9

### Decision

Ordinary public encounters, reservations and population counters live only in the current server session.

### Consequence

MemoryStoreService/MessagingService/global rare-spawn ownership is not a baseline TA-9 dependency; TA-10 may add cross-server coordination only for explicit event/social requirements.

---

## AD-090 — Enable Instance Streaming Without Making It Authority

**Date:** 2026-09-22  
**Status:** Accepted  
**Owning TA phase:** TA-9

### Decision

Workspace instance streaming is the baseline for the gameplay place. Client Workspace residency is presentation/performance state only.

### Consequence

Stream-in/out cannot grant or erase access, encounters, progression, rewards, claims or ownership.

---

## AD-091 — Restrict Persistent Model Streaming Modes

**Date:** 2026-09-22  
**Status:** Accepted  
**Owning TA phase:** TA-9

### Decision

Default streaming is preferred; Atomic is allowed for self-contained interaction models. Persistent and PersistentPerPlayer require narrow measured justification.

### Consequence

Streaming scalability is not undermined by globally pinning ordinary world content.

---

## AD-092 — Make Fast Travel a Server-Validated State Transition

**Date:** 2026-09-22  
**Status:** Accepted  
**Owning TA phase:** TA-9

### Decision

Fast travel validates node discovery, Region access, Character generation and absence of Acquisition-In-Progress. Stream preparation may assist presentation but does not authorize travel.

---

## AD-093 — Index Space Before Running Bounded Physics Queries

**Date:** 2026-09-22  
**Status:** Accepted  
**Owning TA phase:** TA-9

### Decision

Static authored data is indexed at bootstrap and relevant dynamic state uses coarse spatial buckets. Localized WorldRoot queries follow candidate narrowing.

### Consequence

TA-9 prohibits global per-frame Workspace scans as the ordinary scheduling architecture.

---

## AD-094 — Finalize Valuable World Progression as Exact-Once P2 State

**Date:** 2026-09-22  
**Status:** Accepted  
**Owning TA phase:** TA-9

### Decision

Landmark Discovery, final Field Objective completion, Region Mastery and attached one-time world rewards use stable operation identities and P2 Player Profile commits.

### Consequence

Reconnect, duplicate triggers and lost responses cannot duplicate persistent progression or Energy.

---

## AD-095 — Keep Hazard Consequences Server-Validated

**Date:** 2026-09-22  
**Status:** Accepted  
**Owning TA phase:** TA-9

### Decision

Client reports and physics/Touched signals may inform hazard handling but are not sole authority. Hazard recovery is revision/generation aware and delegates acquisition effects to TA-7.

### Consequence

Hazards cannot become a client-authoritative value/progression mutation path.

---

## AD-096 — Load Shedding Preserves Fairness and Valuable State

**Date:** 2026-09-22  
**Status:** Accepted  
**Owning TA phase:** TA-9

### Decision

Under pressure, MonsterVault defers ordinary scheduler work and reduces refill/optional updates before weakening access validation, P2 correctness, active acquisition protection or Protected Variant stability.

---

## AD-097 — Close TA-9 and Advance to TA-10

**Date:** 2026-09-22  
**Status:** Accepted  
**Owning TA phase:** TA-9

### Decision

TA-9 is Architecture Complete — PASS with 240/240 scenarios and zero blocking questions.

### Consequence

TA-10 becomes NEXT. Gameplay implementation remains blocked until TA-17.


---

## AD-098 — Parties Are Same-Server Transient State

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

Party membership, leadership, invites, Pings and rejoin grace remain bounded server-session state. Party affiliation transitions additionally serialize through a participant-scoped membership guard/index so independent Party queues cannot admit one player concurrently. Persistent outcomes created during social play remain in their owning Player Profile domains.

---

## AD-099 — Social Relationships Never Grant Cross-Player Value Authority

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

Friendship, Party membership, challenges and visitor status cannot mutate another player's ownership, Energy, progression, claims, custody or Vault state.

---

## AD-100 — Shared Social Rewards Are Personal Contribution-Gated P2 Outcomes

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

Shared Objective rewards require server-observed Eligible Contribution and finalize independently/exactly once for each player.

---

## AD-101 — Friendly Challenges Remain Explicit and Non-Destructive

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

Baseline Friendly Challenges are opt-in session competitions with no staking, direct combat, forced movement or persistent-value loss.

---

## AD-102 — EventOccurrence Is the Cross-Server Event Identity

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

EventOccurrenceId identifies one wall-clock occurrence across servers; ServerEventInstanceId identifies only one local realization.

---

## AD-103 — Event Windows and Persistent Cooldowns Use Authoritative Wall Clock

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

Scheduled event phase is derived from validated schedule/config plus server-observed time, so server join/restart cannot reset a live window. Authored persistent personal Event Cooldowns are stored in the Player Profile with server-wall-clock deadlines and reconciled before eligibility after reconnect/server hop; global cooldowns that must survive server changes use durable/config authority.

---

## AD-104 — Dynamic Occurrences Require Durable Authority Before Broadcast

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

A dynamically authorized global occurrence must be durably recorded before cross-server notification can make it authoritative.

---

## AD-105 — MessagingService Is Refresh/Notification, Not Durable Truth

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

MessagingService may accelerate occurrence/config propagation, but missed/duplicate/stale messages cannot decide ownership, rewards or occurrence history.

---

## AD-106 — MemoryStore Is Optional Ephemeral Coordination Only

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

MemoryStore may be used for short-lived cache/liveness/coordination after measured justification; TTL expiry/throttling cannot delete durable outcomes.

---

## AD-107 — Event Spawn Modifiers Are Prospective

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

Event modifiers affect future TA-9 Spawn Reservations only and never reroll existing World or Secured Creatures.

---

## AD-108 — Multi-Award Events Create Distinct Personal Creature Instances

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

Every qualified personal event capture opportunity gets its own CreatureInstanceId and Variant Identity. One shared CreatureInstanceId is never multi-owned.

---

## AD-109 — Baseline Trading Is Direct, Bilateral, and Same-Server

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

Both trade participants must be present and eligible in one server. Baseline trading has no offline listing, global market or cross-server negotiation.

---

## AD-110 — Trade Consent Binds One Exact Revision

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

Every semantic offer edit creates a new Trade Revision and clears Ready/Final Confirmation. Commit requires independent Final Confirmation of the same immutable revision.

---

## AD-111 — Trade Negotiation Uses Exact-Instance Runtime Reservations

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

Offered CreatureInstanceIds are reserved in server runtime during negotiation to prevent conflicting same-server mutations without generating DataStore writes for every edit.

---

## AD-112 — Trade Commit Uses a Durable Multi-Profile Transaction Journal

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

Cross-profile Trade Commit uses TA-4's durable transaction store with immutable intent, participant prepare fences, durable decision, idempotent apply and recovery. Participant writes continue to obey TA-4 lease ownership and its single-writer queue; sequential unrelated saves are prohibited.

---

## AD-113 — COMMIT_DECIDED Is Irreversible

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

Once both participants are durably prepared and the journal records COMMIT_DECIDED, recovery must finish that exact exchange; ordinary cancellation is no longer valid.

---

## AD-114 — Pending Trade Profiles Are Transaction-Blocked

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

A Player Profile with unresolved pendingTrade cannot expose normal gameplay/value mutations or become Ready until the durable journal resolves. A participant already marked APPLIED retains the matching transaction fence until both applies are acknowledged, FINALIZED_COMMIT is durable, and authorized reconciliation clears it.

---

## AD-115 — Participant Apply Moves the Same Creature Record

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

Trade apply transfers the same CreatureInstanceId, immutable Variant and original provenance, adds bounded transfer provenance/cooldown, re-locks Protected Variants and never transfers Energy, Production Buffer or Vault upgrades.

---

## AD-116 — Trade Recovery Does Not Depend on Client Connectivity

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

After a durable transaction decision, participant application can be recovered even if clients disconnect or the original server dies, but recovery never bypasses a live profile lease: it routes through the lease-owning writer queue or first acquires legal profile authority under TA-4 stale/expired-lease rules.

---

## AD-117 — Close TA-10 and Advance to TA-11

**Date:** 2026-09-23  
**Status:** Accepted  
**Owning TA phase:** TA-10

### Decision

TA-10 is Architecture Complete — PASS with 338/338 scenarios and zero blocking questions.

### Consequence

TA-11 becomes NEXT. Gameplay implementation remains blocked until TA-17.
