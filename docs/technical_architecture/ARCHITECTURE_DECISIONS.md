# Architecture Decisions

> **Status:** Active — TA-0..15 Complete / TA-16 Next
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


---

## AD-118 — Separate Semantic Product Identity from Platform IDs

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-11

### Decision

MonsterVault ProductDefinitionId is stable semantic commerce identity. Roblox Game Pass, Developer Product and other platform IDs are environment-specific external bindings and never replace semantic identity.

---

## AD-119 — Keep Sold Product Grant Meaning Immutable

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-11

### Decision

A material commercial grant change cannot silently reuse an already-sold platform binding when doing so would make delayed ownership/receipt outcomes ambiguous. Retired/Tombstone mappings remain resolvable.

---

## AD-120 — Use Game Pass Ownership for Baseline One-Time Account Products

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-11

### Decision

Baseline durable cosmetics/capacity/supporter products and the one-time Starter Value Bundle use Game Pass ownership where practical. A one-time account product is not implemented as a repeatable Developer Product protected only by UI.

---

## AD-121 — Reconcile Game Pass Entitlements from Current Platform Ownership

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-11

### Decision

Pass ownership is reconciled on trusted profile readiness and after purchase-prompt refresh. Prompt completion triggers reconciliation but is not a substitute for authoritative ownership state.

---

## AD-122 — Treat Ownership-Query Failure as Unknown, Not Revocation

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-11

### Decision

A failed pass-ownership query cannot grant a new entitlement and cannot destructively revoke a previously verified active entitlement. It yields VerificationUnknown and schedules bounded asynchronous in-session reconciliation; exact retry/backoff budgets are owned by TA-14. Product Hidden/Retired state may stop new prompting but never cancels reconciliation of already-owned or Pending outcomes. Exhaustion preserves unknown/Pending state and permits later safe reconciliation triggers.

---

## AD-123 — Make the Starter Historical Grant Separately Exact-Once

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-11

### Decision

Starter pass ownership may reconcile repeatedly while the historical deterministic Energy/one-time grant is protected by one stable account-level StarterProgramId finalized marker and TA-8 deferred-grant semantics. ProductDefinitionId, external binding and GrantSemanticVersion remain source/audit facts and cannot reset the account-level Starter finalization state. When multiple Starter source SKUs are owned before finalization, all configured ownership facts are reconciled first and an explicit unique StarterSourcePriority from the approved migration selects the source; query/registry order is never allowed to choose, and unproven compatibility/compensation enters protected reconciliation.

---

## AD-124 — Use Server Receipt Authority for Developer Products

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-11

### Decision

Developer Product Commercial Finalization is driven by one centralized server receipt path. PromptProductPurchaseFinished is never grant authority.

---

## AD-125 — Use PurchaseId as Developer Product Exact-Once Identity

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-11

### Decision

Every valid Developer Product receipt is journaled by PurchaseId with immutable player/product/grant facts. Duplicate delivery reuses the same identity.

---

## AD-126 — Route Receipt Apply Through TA-4 Profile Authority

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-11

### Decision

Commercial profile application routes through the active lease-owner writer queue or legally acquired TA-4 profile authority. Receipt recovery creates no external writer exception.

---

## AD-127 — Finalize Receipt Journal Only After Durable Profile Apply

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-11

### Decision

A receipt reaches FINALIZED only after its deterministic grant and PurchaseId marker are durably present in the Player Profile. Partial failure retries the same receipt identity.

---

## AD-128 — Make Commercial Capacity Reversal Non-Destructive

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-11

### Decision

Commercial capacity loss invokes TA-8 capacity reconciliation/Overflow-Held and never releases creatures, creates Energy debt or grants production capability.

---

## AD-129 — Separate Runtime Platform Price from Grant Semantics

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-11

### Decision

Custom commerce UI uses current platform price metadata rather than hard-coded transaction prices. Regional/managed/experimental price variation never changes deterministic MonsterVault grant semantics.

---

## AD-130 — Keep Subscriptions and Robux Transfers Disabled at Baseline

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-11

### Decision

Roblox platform support for subscriptions or Robux transfers does not authorize MonsterVault gameplay use. Baseline GDS-13/GDS-12 prohibit recurring commercial gameplay value and protected premium player tender.

---

## AD-131 — Close TA-11 and Advance to TA-12

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-11

### Decision

TA-11 is Architecture Complete — PASS with 240/240 scenarios and zero blocking questions.

### Consequence

TA-12 becomes NEXT. Gameplay implementation remains blocked until TA-17.


---

## AD-132 — Keep Client State Non-Authoritative

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-12

### Decision

Server-owned gameplay facts are read-only projections; local UI/navigation/camera state is disposable; user preferences alter presentation only.

---

## AD-133 — Use Unidirectional Client State Flow

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-12

### Decision

Authoritative projections feed a revision-aware client application store and view models; consequential semantic intents return to the server and final presentation follows authoritative outcome.

---

## AD-134 — Use InputAction/InputContext for Semantic Cross-Device Input

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-12

### Decision

TA-12 uses InputAction/InputContext/InputBinding as the baseline action architecture with touch, keyboard/mouse and gamepad parity.

---

## AD-135 — Avoid Production Dependency on Beta InputActionLabel

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-12

### Decision

InputAction.PreferredBinding feeds a MonsterVault glyph/text resolver; the beta InputActionLabel is not required for runtime correctness.

---

## AD-136 — Centralize Input Context, Modal and Focus Arbitration

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-12

### Decision

One client input/focus architecture uses fixed precedence PlatformMenuSuspended > SystemBlocked > Modal > CommittedGameplay > PanelNavigation > World, single-owner action dispatch and explicit sink behavior. Any context transition caused by physical input retains an Input Handoff Guard for the triggering gesture until release/completed/neutral. On entry, the guard also sinks that input against the newly enabled higher context, so a modal opened by press cannot consume the matching release as Confirm and requires a fresh gesture. On dismissal, the guard prevents the same gesture from reaching newly exposed lower contexts. This prevents entry and exit fallthrough while preserving predictable Back/Close and complete gamepad reachability.

---

## AD-137 — Enforce Presentation Priority

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-12

### Decision

Critical trust and committed gameplay presentation suppress or queue lower-priority social/commercial/informational UI without changing server obligations.

---

## AD-138 — Use Roblox Safe Areas and Responsive Reflow

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-12

### Decision

Critical/actionable UI uses CoreUISafeInsets by default and adapts through reflow/wrapping/scrolling rather than desktop-first shrink-only layouts.

---

## AD-139 — Treat Roblox Accessibility Preferences as Live Floors

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-12

### Decision

PreferredTextSize, PreferredTransparency and ReducedMotionEnabled are live inputs that MonsterVault preferences may strengthen but never weaken.

---

## AD-140 — Persist Custom Presentation Preferences as P1

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-12

### Decision

Custom contrast, shake, captions, volume categories, sensitivity and safe social/notification preferences are validated non-value-critical state; platform-safe defaults work before profile readiness.

---

## AD-141 — Never Finalize Consequential UI Optimistically

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-12

### Decision

Capture ownership, Energy/progression, Release, trade, event rewards and commercial entitlements present success only after authoritative outcomes. A consequential command timeout is an unknown outcome that enters reconciliation, never an implicit rejection; blind duplicate irreversible submission remains blocked until authoritative refresh or upstream-proven retry safety.

---

## AD-142 — Key Exact-Instance UI by Semantic IDs and Virtualize Large Lists

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-12

### Decision

CreatureInstanceId and other stable semantic IDs survive recycled GuiObjects; large collection/trade/Vault views render bounded subsets.

---

## AD-143 — Use One Bounded Local Camera Presentation Owner

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-12

### Decision

Baseline exploration keeps familiar Roblox camera behavior; temporary camera assistance is locally arbitrated and deterministically restored.

---

## AD-144 — Compose Reduced Motion Conservatively

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-12

### Decision

Effective Reduced Motion is true when Roblox or MonsterVault requests it and removes non-essential motion/shake without removing semantic feedback.

---

## AD-145 — Use Semantic Audio Categories and Caption Events

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-12

### Decision

Audio reinforces but never solely carries critical meaning; actionable sound/dialogue has visual/text equivalents and semantic caption events.

---

## AD-146 — Keep Localization Separate from Semantic Identity

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-12

### Decision

UI text is localization-key driven and expansion-tolerant; localized display strings never become gameplay identity or logic keys.

---

## AD-147 — Yield to Roblox Platform Safety UI

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-12

### Decision

Core play never requires chat/voice, supported filtering remains mandatory for uncontrolled text, and Roblox menu/report/settings paths remain accessible.

---

## AD-148 — Bind Commercial Presentation to TA-11 Truth

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-12

### Decision

Current platform price/content/Pending/reconciliation projections drive shop UI; commercial presentation cannot steal critical focus or fabricate entitlements.

---

## AD-149 — Close TA-12 and Advance to TA-13

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-12

### Decision

TA-12 is Architecture Complete — PASS with 300/300 scenarios and zero blocking questions. TA-13 becomes NEXT; gameplay implementation remains blocked until TA-17.

### Consequence

TA-13 becomes NEXT. Gameplay implementation remains blocked until TA-17.


---

## AD-150 — Keep Analytics Observational

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

Product analytics, dashboards, cohorts and alerts never mutate gameplay truth or replace durable transaction/persistence authority.

---

## AD-151 — Use a Versioned Semantic Telemetry Registry

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

Every event has stable identity, schema, owner, trigger, sampling/privacy policy and adapter mapping; breaking meaning is versioned.

---

## AD-152 — Emit Consequential Success After Authoritative Outcome

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

Capture, economy, progression, trade and commerce success telemetry originates after the owning server transition, not client intent.

---

## AD-153 — Make Analytics Failure Non-Blocking

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

Telemetry uses bounded best-effort delivery; gameplay does not wait for analytics and no profile writes exist solely for analytics delivery.

---

## AD-154 — Separate Analytics, Diagnostics, Security and Audit

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

Different trust/access/durability needs are not collapsed into one unrestricted event stream.

---

## AD-155 — Enforce Data Minimization and Low Cardinality

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

No raw chat/freeform personal data or sensitive-trait inference; Creator Analytics dimensions remain bounded and exclude runtime IDs.

---

## AD-156 — Use ConfigService as Baseline C2 Transport

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

Experience Configs provide read-only-in-game live values/flags; MonsterVault wraps them in validation and snapshots.

---

## AD-157 — Activate Config Atomically

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

Only allowlisted C2 values are materialized; the full candidate is validated, staged and swapped at safe boundaries.

---

## AD-158 — Pin Operations to Coherent Config Context

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

Transactions/encounters/events retain their starting snapshot when required; new snapshots affect future work prospectively.

---

## AD-159 — Keep C0/C1 Outside Live Flags

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

Flags may gate reachability but cannot redefine invariants/static identity or break persisted references.

---

## AD-160 — Fail Optional/Unsafe Features Closed

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

Missing/invalid config keeps optional new features disabled or uses a reviewed safe default; no cross-environment fallback.

---

## AD-161 — Make Rollback Prospective and Non-Destructive

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

Rollback returns future work to a validated revision and never silently removes legitimate finalized value.

---

## AD-162 — Allow Conservative Emergency Disable Hints Only

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

Cross-server messages may reduce new reachability/request refresh but cannot enable features, grant value or become durable positive truth.

---

## AD-163 — Separate Reviewed Experiment Semantics from Live Allocation

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

Experiment plans/treatments/invariants are reviewed; C2 controls only activate/deactivate and allocate inside the approved envelope.

---

## AD-164 — Match Assignment Unit to Blast Radius

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

Per-player assignment is limited to isolated semantics; shared/value-affecting opportunities use coherent server/occurrence context.

---

## AD-165 — Record Exposure Separately from Assignment

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

Exposure occurs only when treatment is reached; durable-value opportunities retain config/experiment provenance where needed.

---

## AD-166 — Do Not Use Platform Player Segments as Gameplay Value Authority

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

Payer/activity segments cannot determine hidden odds, priority, reward strength, pricing, safety or progression.

---

## AD-167 — Keep Production Live-Ops External and Least-Privilege

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

No baseline client/in-game arbitrary admin console; Creator Hub/Open Cloud tooling uses scoped credentials outside the experience.

---

## AD-168 — Audit Every Privileged Mutation

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

Config/flag/experiment publish and rollback record operator/action/revision/reason/result metadata; rollback appends history.

---

## AD-169 — Close TA-13 and Advance to TA-14

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-13

### Decision

TA-13 is Architecture Complete — PASS with 260/260 scenarios and zero blocking questions. TA-14 becomes NEXT; gameplay implementation remains blocked until TA-17.

### Consequence

TA-14 becomes NEXT. Gameplay implementation remains blocked until TA-17.


---

## AD-170 — Separate Platform Ceilings from MonsterVault Budgets

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

Roblox service/engine ceilings are external limits, not operating targets. MonsterVault locks lower targets, warning thresholds and hard guardrails so transient platform variation and burst demand retain headroom.


---

## AD-171 — Validate Representative Load Classes

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

TA-15 must validate L0 solo, L1 half occupancy, L2 full occupancy, L3 full plus burst, L4 dependency-recovery and L5 long-session conditions. A budget proven only in Studio or at solo load is not closed.


---

## AD-172 — Reserve Server Frame Headroom

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

MonsterVault targets <=6 ms p95 script-owned server CPU per frame, warns above 8 ms and performs staged load shedding above 10 ms sustained. The 16.67 ms 60 Hz frame remains a whole-server envelope rather than a MonsterVault script allowance.


---

## AD-173 — Use 30 FPS as the Client Correctness Floor

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

All core interaction and accessibility semantics must remain correct at 30 FPS. Reference mobile/tablet/console/desktop targets remain 60 FPS where supported, but no exact-once or input semantics depend on 60+ FPS.


---

## AD-174 — Measure Client Memory Relative to Warm Baselines

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

Server memory uses percentage guardrails; client memory uses real-device warm-baseline deltas plus OOM/crash hard failures because Roblox exposes no single portable client-memory ceiling valid across devices.


---

## AD-175 — Adopt Conservative Streaming Defaults

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

Baseline streaming uses StreamingMinRadius 64, StreamingTargetRadius 1024, PauseOutsideLoadedArea and Opportunistic stream-out. Persistent/PersistentPerPlayer is rare and capped rather than used to defeat streaming.


---

## AD-176 — Bound Runtime Growth

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

Active World Creatures, interactables, tasks, connections and caches have technical ceilings/cleanup owners. No collection may grow with session age without an explicit retention or eviction policy.


---

## AD-177 — Keep Application Remotes Far Below Platform Throttles

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

MonsterVault defines per-player message and byte budgets plus per-route rate limits. Platform remote throttles are emergency ceilings, not a target capacity model.


---

## AD-178 — Cap Unreliable Payloads at 768 Bytes

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

UnreliableRemoteEvent payloads are capped at 768 encoded bytes, below Roblox's 1000-byte drop ceiling. Durable/critical state never uses unreliable delivery.


---

## AD-179 — Protect Single-Profile Atomicity with Size Limits

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

Player Profile warns at 1 MiB and hard-stops growth at 1.5 MiB, with 2048 owned Creature records as a technical ceiling. Crossing those bounds triggers protected failure/change control rather than ad-hoc sharding or value deletion.


---

## AD-180 — Lock Persistence Timing Headroom

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

Healthy autosave and lease renewal target 90 seconds with jitter, lease reclaim requires the 300-second stale policy, and active-production crash recovery allows 180 seconds so it exceeds the healthy uncheckpointed interval.


---

## AD-181 — Reserve DataStore Capacity for Critical Work

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

P2/load/lease/recovery work owns a protected dynamic request reserve of max(30, 2 × connectedPlayers) budget units per relevant request class; background/P1 work pauses before consuming that reserve.


---

## AD-182 — Keep MemoryStore Optional and Transient

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

MemoryStore is not durable truth. If used, MonsterVault stays within small percentages of universe request/memory quotas, uses compact short-lived items and degrades coordination when the service is pressured.


---

## AD-183 — Keep Messaging Coarse and Non-Authoritative

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

MessagingService carries bounded invalidation/refresh/hint traffic only, with <=12 steady publishes/minute/server, <=4 baseline topics and <=512-byte encoded messages.


---

## AD-184 — Budget World Scheduling and Spatial Work

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

Ordinary world scheduling runs on a 250 ms cadence with <=2 ms p95 passes; the baseline spatial cell is 128 studs and ordinary pre-validation candidate sets are capped at 64 before exact validation.


---

## AD-185 — Virtualize Large Client Surfaces

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

Long collection/trade/Vault surfaces materialize at most 60 logical rows/cards plus 12 overscan; expensive sort/filter work is chunked, timers are centralized and notification/preferences work is bounded.


---

## AD-186 — Bound Analytics and Config Overhead

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

Telemetry queues/rates/memory and config/experiment compute are bounded. Product analytics samples/coalesces before gameplay waits, and config activation remains complete, validated and atomic.


---

## AD-187 — Coalesce Commerce Reconciliation

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

Product metadata is freshness-cached; ownership verification retries are bounded/coalesced and exhausted retries preserve Pending/VerificationUnknown instead of inventing entitlement truth.


---

## AD-188 — Use Ordered Pressure States and Hysteresis

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

Servers classify operational pressure as GREEN/YELLOW/ORANGE/RED-DRAIN. Pressure changes only optional fidelity/scheduling/admission, and recovery requires 30 seconds below lower thresholds to avoid catch-up oscillation.


---

## AD-189 — Make Performance Observable Without Cardinality Explosion

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

Compute, memory, network, service budgets, queues and degradation states are instrumented by stable low-cardinality dimensions. Runtime IDs are not exported merely to make performance dashboards easier.


---

## AD-190 — Require Review Before Relaxing Hard Budgets

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

Raising hard guardrails, reducing platform headroom, increasing streaming radii/profile maxima/remote envelopes or changing degradation order is material TA-14 change control and needs TA-15 evidence.


---

## AD-191 — Close TA-14 and Advance to TA-15

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-14

### Decision

TA-14 is Architecture Complete — PASS with 300/300 architecture scenarios and zero blocking questions. TA-15 becomes NEXT; gameplay implementation remains blocked until TA-17.

### Consequence

TA-15 becomes NEXT. Gameplay implementation remains blocked until TA-17.


---

## AD-192 — Test at the Cheapest Trustworthy Layer

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

Pure deterministic contracts are tested outside engine dependencies where possible, while Roblox engine/platform claims require Studio/staging evidence; mocks never substitute for required engine truth.


---

## AD-193 — Use Stable Test Identity and Traceability

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

Tests have semantic TestIds tied to TA/GDS requirements rather than volatile implementation filenames.


---

## AD-194 — Make C0 Invariants Non-Quarantinable

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

Ownership, P2 exact-once, persistence single-writer, transaction recovery, receipt idempotency, trade atomicity and authorization tests are mandatory and cannot be quarantined.


---

## AD-195 — Require Clean Static and Build Gates

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

StyLua, Selene, strict Luau analysis, Rojo build and architecture dependency checks must pass once implementation opens.


---

## AD-196 — Inject Time Randomness and Platform Dependencies

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

Critical logic receives clocks, RNG and platform adapters through explicit boundaries so verification is deterministic and failures reproducible.


---

## AD-197 — Use Deterministic Property Corpora

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

Affected critical property families run at least 1,000 generated cases in the fast suite and 10,000 in the extended suite, recording failing seeds/sequences.


---

## AD-198 — Do Not Use Statistical Randomness as Sole Correctness Oracle

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

Random systems require deterministic boundary/mapping/anti-reroll tests; fixed large statistical corpora are additional diagnostics.


---

## AD-199 — Use Roblox Studio as Authoritative Engine Test Runtime

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

Studio scripted testing, especially StudioTestService, is the baseline for engine/multiplayer integration behavior.


---

## AD-200 — Automate Cross-Device and Network Presentation Evidence

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

Studio device simulation, VirtualInput, Network Simulator and Player Emulator/pseudolocalization are used where applicable.


---

## AD-201 — Separate Untrusted and Privileged CI Lanes

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

Ordinary PR code runs on low-trust GitHub-hosted compute without secrets; engine/staging jobs require explicit trusted context and isolated compute.


---

## AD-202 — Do Not Run Arbitrary Public-Fork Code on Persistent Personal Runners

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

The public repository does not use a general long-lived self-hosted personal machine for untrusted PR execution.


---

## AD-203 — Require Hostile-Client Negative Testing

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

Every client-triggered authority surface has malformed, oversized, replay, rate, permission and context-abuse tests with bounded rejection-cost checks.


---

## AD-204 — Require Persistence Fault and Migration Evidence

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

Load/save/lease/migration/retry/shutdown paths support deterministic timeout, throttle, corruption, concurrency and crash injection.


---

## AD-205 — Test Exact-Once Transactions at Durable Cut Points

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

Capture, economy, event, trade and commerce transactions are tested before/after durable mutation and across duplicate/retry/reconnect/server-loss boundaries.


---

## AD-206 — Isolate Test Environments and Data

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

DEV/STAGING/PRODUCTION stores, bindings, credentials and synthetic data cannot silently overlap.


---

## AD-207 — Make TA-14 Hard Guardrails Release Gates

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

All applicable L0-L5 hard performance/memory/network/persistence/service guardrails require reproducible evidence before release.


---

## AD-208 — Require Real-Client Evidence for Client Performance

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

An empty or solo Studio run cannot by itself close client frame/memory support claims.


---

## AD-209 — Standardize Privacy-Minimized Test Evidence

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

Results include TestId, build, requirement, environment, seed/fault/device/load identity and relevant redacted diagnostics without unnecessary player data.


---

## AD-210 — Prohibit Retry-Until-Green

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

Original failures remain visible; C0 cannot quarantine, C1 remains release-required and C2 quarantine is limited to seven days with owner/issue/expiry.


---

## AD-211 — Require Complete Applicable C0/C1 Evidence Before Release

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

Static, deterministic, engine, adversarial, fault, performance, accessibility and staging gates cannot be silently skipped because automation is temporarily unavailable.


---

## AD-212 — Use Bounded Evidence Retention

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

Ordinary PR artifacts target 14 days and release-candidate evidence 90 days where current public-repository retention permits, with durable release summaries retained separately.


---

## AD-213 — Add Regression Tests for Fixed Critical Defects

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

Every fixed C0/C1 defect adds a lowest-trustworthy-layer regression test unless technically impossible.


---

## AD-214 — Close TA-15 and Advance to TA-16

**Date:** 2026-09-24  
**Status:** Accepted  
**Owning TA phase:** TA-15

### Decision

TA-15 is Architecture Complete — PASS with 360/360 verification-architecture scenarios and zero blocking questions. TA-16 becomes NEXT; gameplay implementation remains blocked until TA-17.

### Consequence

TA-16 becomes NEXT. Gameplay implementation remains blocked until TA-17.
