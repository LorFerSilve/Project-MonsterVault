# Technical Architecture Roadmap

> **Status:** Active — TA-3 Next
> **Authority:** Dependency-driven technical architecture sequencing

This roadmap defines how the Design Complete MonsterVault GDS is translated into implementation-ready Roblox/Luau contracts.

## TA-0 — Architecture Governance, Constraints, and GDS Traceability

**Status:** Architecture Complete — PASS

Established and formally validated:

- GDS semantic authority over technical convenience;
- Draft / Under Review / Architecture Complete / Implementation Locked maturity model;
- GDS -> TA -> verification -> implementation traceability contract;
- one technical owner per persistent field family, runtime transition, remote handler and transaction commit;
- server authority for ownership/currency/rare outcomes/progression/rewards/trading/purchases/moderation;
- explicit trust-boundary model;
- explicit transaction/idempotency requirements for exact-once outcomes;
- versioned persistence and safe load-failure principles;
- prospective/auditable configuration and server-side randomness authority;
- value-preserving failure semantics;
- security/performance/testability/observability as architecture closure requirements;
- Architecture Decision Record and change-control protocol;
- 12 architecture risk families with named owners;
- design-conflict protocol returning player-facing conflicts to owning GDS;
- 60 / 60 governance scenarios PASS;
- complete high-level mapping of GDS-0 through GDS-17 into TA-0 through TA-17.

Closure evidence:

- [governance/00_architecture_governance_constraints_and_gds_traceability.md](governance/00_architecture_governance_constraints_and_gds_traceability.md) — Architecture Complete;
- [TA0_GDS_TRACEABILITY_MATRIX.md](TA0_GDS_TRACEABILITY_MATRIX.md) — PASS;
- [TA0_ARCHITECTURE_RISK_REGISTER.md](TA0_ARCHITECTURE_RISK_REGISTER.md) — all risk families owned;
- [TA0_SCENARIO_VALIDATION.md](TA0_SCENARIO_VALIDATION.md) — 60 / 60 PASS;
- [TA0_DECISION_INDEX.md](TA0_DECISION_INDEX.md) — accepted;
- [TA0_CLOSURE_REPORT.md](TA0_CLOSURE_REPORT.md) — PASS.

## TA-1 — Roblox System Context, Toolchain, and Development Environment

**Status:** Architecture Complete — PASS

Established and formally validated:

- Roblox Studio stable as authoritative engine execution/playtest/publish environment;
- DEV / STAGING / PRODUCTION environment classes;
- one primary gameplay place per environment as launch baseline;
- Git/filesystem as source of truth for first-party Luau/project configuration;
- Rojo as primary filesystem-to-Studio sync/build workflow;
- Roblox Script Sync retained as non-primary alternative rather than competing authority;
- Rokit as pinned CLI toolchain manager;
- strict first-party Luau baseline;
- luau-lsp, StyLua and Selene as reference editor/static tooling;
- current reference versions recorded in a dated toolchain snapshot;
- no runtime package manager and no third-party runtime Luau package at baseline;
- explicit trigger/review process for any future dependency;
- UTF-8/LF/version-control and generated-artifact conventions;
- no secrets/credentials in Git;
- reproducible developer setup and environment-health expectations;
- supply-chain and local Rojo-server security boundaries;
- 75 / 75 TA-1 scenarios PASS;
- zero TA-1-blocking questions.

Closure evidence:

- [environment/01_roblox_system_context_toolchain_and_development_environment.md](environment/01_roblox_system_context_toolchain_and_development_environment.md) — Architecture Complete;
- [TA1_TOOLCHAIN_SNAPSHOT.md](TA1_TOOLCHAIN_SNAPSHOT.md) — PASS;
- [TA1_GDS_TRACEABILITY.md](TA1_GDS_TRACEABILITY.md) — PASS;
- [TA1_SCENARIO_VALIDATION.md](TA1_SCENARIO_VALIDATION.md) — 75 / 75 PASS;
- [TA1_DECISION_INDEX.md](TA1_DECISION_INDEX.md) — accepted;
- [TA1_CLOSURE_REPORT.md](TA1_CLOSURE_REPORT.md) — PASS.

## TA-2 — Repository Layout, Module Boundaries, Dependency Direction, and Bootstrapping

**Status:** Architecture Complete — PASS

Established and formally validated:

- modular-monolith runtime architecture;
- future `src/server`, `src/client`, and `src/shared` source roots;
- Rojo mapping into ServerScriptService, StarterPlayerScripts and ReplicatedStorage;
- server/client/shared authority boundaries;
- server bootstrap/application/domain/infrastructure/adapter layers;
- domain public/internal encapsulation;
- application-level cross-domain orchestration;
- one-directional import/dependency rules;
- shared-as-disclosed security rule;
- public/private configuration and utility placement rules;
- no long-lived side effects during module import;
- explicit Construct -> Validate -> Start -> Ready -> Stop/Shutdown lifecycle;
- deterministic server/client/player/shutdown bootstrap ordering;
- explicit constructor injection and no global service locator;
- cyclic dependency prevention/resolution policy;
- command/query/completed-fact event structural convention;
- one ordinary server and client bootstrap entrypoint;
- tests/scripts/assets structural boundaries;
- centralized platform-service ownership;
- 110 / 110 TA-2 scenarios PASS;
- zero TA-2-blocking questions.

Closure evidence:

- [structure/02_repository_layout_module_boundaries_dependency_direction_and_bootstrapping.md](structure/02_repository_layout_module_boundaries_dependency_direction_and_bootstrapping.md) — Architecture Complete;
- [TA2_DEPENDENCY_OWNERSHIP_MATRIX.md](TA2_DEPENDENCY_OWNERSHIP_MATRIX.md) — PASS;
- [TA2_GDS_TRACEABILITY.md](TA2_GDS_TRACEABILITY.md) — PASS;
- [TA2_SCENARIO_VALIDATION.md](TA2_SCENARIO_VALIDATION.md) — 110 / 110 PASS;
- [TA2_DECISION_INDEX.md](TA2_DECISION_INDEX.md) — accepted;
- [TA2_CLOSURE_REPORT.md](TA2_CLOSURE_REPORT.md) — PASS.

## TA-3 — Networking, Server Authority, Remote Contracts, and Exploit Boundaries

**Status:** NEXT — Draft

Defines RemoteEvent/RemoteFunction ownership, request/response/event contracts, validation, rate limiting, replay/idempotency strategy, trust boundaries, client prediction/presentation boundaries and exploit-resistant state mutation.

## TA-4 — Player Data, Persistence, Session Ownership, Schema Evolution, and Recovery

**Status:** Blocked

Defines player profile model, DataStore strategy, session locking/ownership, autosave/shutdown behavior, retries, versioned schemas, migrations, corruption/recovery policy, offline progression inputs and observability.

## TA-5 — Identity, Content Registries, Configuration, and Data-Driven Content

**Status:** Blocked

Defines stable IDs for species, creature instances, mutations, items, regions, events and products; data schemas; configuration ownership; content registry/loading; compatibility and validation.

## TA-6 — Runtime Entity, Player, Creature, and World Lifecycle

**Status:** Blocked

Defines runtime representation, spawning/despawning, ownership/projection, server/client replication expectations, lifecycle state machines and transitions between persistent and active world state.

## TA-7 — Capture, Creature Ownership, Mutation, and Reward Resolution

**Status:** Blocked

Defines authoritative capture transactions, simultaneous claims, random-outcome authority, mutation generation, ownership commitment, disconnect/retry behavior, anti-reroll rules and reward resolution.

## TA-8 — Vault, Economy, Progression, Inventory, and Offline Accrual

**Status:** Blocked

Defines authoritative currency/resource mutation, vault state, passive production, capacity, upgrades, inventory semantics, progression transactions, offline accrual computation and economic integrity controls.

## TA-9 — World, Biomes, Spawn Scheduling, Streaming, and Encounter Scaling

**Status:** Blocked

Defines place/world topology, biome representation, spawn scheduling, spatial partitioning, StreamingEnabled implications, server performance envelopes, rare encounter authority and world-content scalability.

## TA-10 — Social Systems, Server Events, Cross-Server Coordination, and Trading

**Status:** Blocked

Defines parties/social state where required, event orchestration, MessagingService/MemoryStore/cross-server needs if justified, safe trading transactions, lock/commit semantics, duplicate prevention and cross-server failure behavior.

## TA-11 — Monetization, MarketplaceService, Receipt Processing, and Entitlements

**Status:** Blocked

Defines game-pass/product/subscription entitlements if approved, receipt processing, idempotent grants, retry/recovery, purchase-state projection, analytics hooks and separation between premium and earned state.

## TA-12 — Client Presentation, UI State, Input, Camera, Audio, and Accessibility

**Status:** Blocked

Defines client-side state projection, UI architecture, input abstraction, mobile/controller/keyboard support, camera ownership, feedback/event presentation, accessibility settings and presentation-only prediction.

## TA-13 — Analytics, Telemetry, Feature Flags, Configuration Rollouts, and Live Operations

**Status:** Blocked

Defines analytics event contracts, metrics hygiene, feature/config flags, safe rollout/rollback, admin/live-ops boundaries, experiment assignment where justified and operational auditability.

## TA-14 — Performance, Network, Memory, Persistence, and Scalability Budgets

**Status:** Blocked

Defines measurable server/client frame, memory, instance, network, remote-rate, DataStore, MemoryStore and content budgets across representative device/server scenarios, with degradation strategies.

## TA-15 — Testing, Diagnostics, Security Validation, and CI Architecture

**Status:** Blocked

Defines Luau/static checks, unit/integration/scenario tests, Studio/headless automation possibilities, security tests, persistence fault cases, deterministic/randomness validation, CI gates and evidence requirements.

## TA-16 — Architecture Integration and Implementation-Readiness Audit

**Status:** Blocked

Cross-validates authority, dependency direction, networking, persistence, transactions, security, performance, monetization, trading, live-ops, failure recovery and GDS traceability. Must end with zero implementation-critical architecture questions.

## TA-17 — Implementation Roadmap, Vertical Slice, Contract Locking, and Change Control

**Status:** Blocked

Final pre-code phase. Locks:

- exact toolchain and dependency baseline;
- repository/source layout;
- module/service dependency graph;
- GDS-to-TA-to-implementation traceability;
- implementation dependency order;
- first end-to-end vertical-slice acceptance matrix;
- test/CI requirements;
- performance reference scenarios;
- implementation-lock/change-control rules;
- branch/PR/release workflow.

## Implementation Gate

Gameplay implementation begins only after TA-17 is formally complete.

```text
GDS-17 PASS / Design Complete
  -> TA-0..15 architecture
  -> TA-16 integration audit PASS
  -> TA-17 implementation roadmap + contract locking
  -> IMPLEMENTATION OPEN
```


## Current Architecture Gate

GDS-17 is **Complete — PASS** and the Game Design Specification is **Design Complete**.

TA-0 through TA-2 are **Architecture Complete — PASS**.

The active dependency is:

> **TA-3 — Networking, Server Authority, Remote Contracts, and Exploit Boundaries**

TA-4 through TA-17 remain blocked by dependency order. Gameplay implementation remains blocked until TA-17 is formally complete.
