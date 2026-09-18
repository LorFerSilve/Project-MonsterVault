# Technical Architecture Roadmap

> **Status:** Active — TA-7 Next
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

**Status:** Architecture Complete — PASS

Established and formally validated:

- centrally governed versioned Remote registry;
- reliable client-to-server Command and server-to-client Event transports;
- optional server-to-client UnreliableEvent restricted to loss-tolerant presentation;
- no baseline RemoteFunction and no server InvokeClient correctness path;
- protocol/envelope and request/result correlation contracts;
- server-authoritative command pipeline;
- exact bounded client payload schemas;
- static route registration and direction ownership;
- hierarchical global/per-route rate limiting;
- request replay/duplicate and retry semantics;
- client timeout as unknown/reconcile rather than assumed failure;
- server-owned durable operation identity boundary;
- authoritative snapshots/projections and session handshake;
- audience-scoped server-to-client delivery;
- server-gated cross-player relay;
- client physics/network-ownership distrust for critical actions;
- ProximityPrompt/ClickDetector/DragDetector validation boundary;
- reversible presentation-only client prediction;
- structured exploit/error/observability/privacy rules;
- current Roblox networking/security guidance reviewed;
- 140 / 140 TA-3 scenarios PASS;
- zero TA-3-blocking questions.

Closure evidence:

- [networking/03_networking_server_authority_remote_contracts_and_exploit_boundaries.md](networking/03_networking_server_authority_remote_contracts_and_exploit_boundaries.md) — Architecture Complete;
- [TA3_ROBLOX_NETWORK_SECURITY_SNAPSHOT.md](TA3_ROBLOX_NETWORK_SECURITY_SNAPSHOT.md) — PASS;
- [TA3_REMOTE_CONTRACT_MATRIX.md](TA3_REMOTE_CONTRACT_MATRIX.md) — PASS;
- [TA3_GDS_TRACEABILITY.md](TA3_GDS_TRACEABILITY.md) — PASS;
- [TA3_SCENARIO_VALIDATION.md](TA3_SCENARIO_VALIDATION.md) — 140 / 140 PASS;
- [TA3_DECISION_INDEX.md](TA3_DECISION_INDEX.md) — accepted;
- [TA3_CLOSURE_REPORT.md](TA3_CLOSURE_REPORT.md) — PASS.

## TA-4 — Player Data, Persistence, Session Ownership, Schema Evolution, and Recovery

**Status:** Architecture Complete — PASS

Established and formally validated:

- standard DataStoreService as durable player-data authority;
- isolated DEV / STAGING / PRODUCTION persistence domains;
- one Player Profile Aggregate per user at baseline;
- monotonic durable profile revision discipline;
- atomic DataStore metadata session lease through UpdateAsync;
- fresh-lock respect, stale-lock recovery and ownership-loss fail-closed behavior;
- trusted load/migrate/validate state machine before gameplay readiness;
- no blank/default overwrite after load failure;
- one server-local working profile and one writer queue per player;
- P0 session-only, P1 buffered-durable and P2 durable-before-final-ack classes;
- UpdateAsync checkpoint/save/revision pipeline;
- staggered autosave and lease renewal;
- leave and BindToClose final-save/unlock ordering;
- bounded retry/backoff/budget awareness;
- monotonic schemaVersion and pure sequential migration rules;
- newer-than-server schema downgrade prevention;
- corruption classification and controlled DataStore-version recovery;
- server-owned operation identities and bounded/dedicated dedupe records;
- single-profile atomicity;
- explicit no-general-multi-key-transaction boundary;
- durable transaction-journal primitive for TA-10/TA-11;
- profile-size/sharding change-control policy;
- native first-party persistence repository baseline;
- 180 / 180 TA-4 scenarios PASS;
- zero TA-4-blocking questions.

Closure evidence:

- [persistence/04_player_data_persistence_session_ownership_schema_evolution_and_recovery.md](persistence/04_player_data_persistence_session_ownership_schema_evolution_and_recovery.md) — Architecture Complete;
- [TA4_ROBLOX_PERSISTENCE_SNAPSHOT.md](TA4_ROBLOX_PERSISTENCE_SNAPSHOT.md) — PASS;
- [TA4_PERSISTENCE_SESSION_MATRIX.md](TA4_PERSISTENCE_SESSION_MATRIX.md) — PASS;
- [TA4_GDS_TRACEABILITY.md](TA4_GDS_TRACEABILITY.md) — PASS;
- [TA4_SCENARIO_VALIDATION.md](TA4_SCENARIO_VALIDATION.md) — 180 / 180 PASS;
- [TA4_DECISION_INDEX.md](TA4_DECISION_INDEX.md) — accepted;
- [TA4_CLOSURE_REPORT.md](TA4_CLOSURE_REPORT.md) — PASS.

## TA-5 — Identity, Content Registries, Configuration, and Data-Driven Content

**Status:** Architecture Complete — PASS

Established and formally validated:

- stable MonsterVault-owned semantic ID classes;
- lowercase namespaced static ID grammar with opaque semantics;
- immutable/non-reusable shipped IDs;
- server-generated GUID-style runtime identities;
- CreatureInstanceId separated from SpeciesId/Variant definition identity;
- typed declarative content registries;
- public/server-private definition split;
- future source layout for shared/public and server/private config;
- schema/version ownership and bootstrap validation;
- hard referential integrity and cycle checks;
- Active / Retired / Tombstone content lifecycle;
- availability separated from identity;
- controlled legacy alias/migration behavior;
- ContentSnapshotId for provenance/config correlation;
- C0/C1/C2/C3 configuration classes;
- allowlisted versioned live C2 overlay boundary for TA-13;
- environment-specific external Roblox ID bindings;
- asset/product semantic identity separation;
- EventTemplateId separated from dynamic EventOccurrenceId;
- CollectionService tag/attribute authoring boundary;
- weighted-definition generic validation with no paid-state odds input;
- persistent/network compatibility and no dangling ID policy;
- read-only dependency-injected registry access;
- current Roblox tag/attribute/GUID authoring behavior reviewed;
- 180 / 180 TA-5 scenarios PASS;
- zero TA-5-blocking questions.

Closure evidence:

- [content/05_identity_content_registries_configuration_and_data_driven_content.md](content/05_identity_content_registries_configuration_and_data_driven_content.md) — Architecture Complete;
- [TA5_ROBLOX_CONTENT_AUTHORING_SNAPSHOT.md](TA5_ROBLOX_CONTENT_AUTHORING_SNAPSHOT.md) — PASS;
- [TA5_IDENTITY_REGISTRY_MATRIX.md](TA5_IDENTITY_REGISTRY_MATRIX.md) — PASS;
- [TA5_GDS_TRACEABILITY.md](TA5_GDS_TRACEABILITY.md) — PASS;
- [TA5_SCENARIO_VALIDATION.md](TA5_SCENARIO_VALIDATION.md) — 180 / 180 PASS;
- [TA5_DECISION_INDEX.md](TA5_DECISION_INDEX.md) — accepted;
- [TA5_CLOSURE_REPORT.md](TA5_CLOSURE_REPORT.md) — PASS.

## TA-6 — Runtime Entity, Player, Creature, and World Lifecycle

**Status:** Architecture Complete — PASS

Established and formally validated:

- server-authoritative runtime records separated from Roblox Instance projections;
- explicit runtime entity taxonomy and injected server registry;
- generic Allocated -> Initializing -> Registered -> Materializing -> Active -> Quiescing -> Terminating -> Destroyed lifecycle;
- monotonic runtimeRevision for stale-command/callback rejection;
- Player Session separated from Character Presence;
- session-local character generation identity;
- trusted-profile-before-Active-Presence rule;
- server-owned safe-arrival/recovery boundary;
- stable World Creature runtime record using CreatureInstanceId;
- Variant Identity complete before individual actionability;
- active acquisition protected from ordinary idle despawn;
- failed/released acquisition preserving the same surviving creature identity;
- Secured Ownership transition preserving CreatureInstanceId;
- persistent owned projections separated from collection ownership;
- runtime/network/persistent/claim ownership concepts separated;
- Workspace runtime container and stable interaction-target boundary;
- client streaming tolerance and exceptional Persistent-model policy;
- physics network ownership/Touched distrust for critical outcomes;
- revision-aware disposable client projection cache;
- explicit entity create/destroy transactions;
- one idempotent cleanup owner per runtime entity;
- stale async/timer/character-generation protection;
- static world runtime index handoff;
- recovery/shutdown/late-join/population hooks;
- Protected Variant server-lifetime stability handling;
- current Roblox character/streaming/network-ownership/cleanup behavior reviewed;
- 190 / 190 TA-6 scenarios PASS;
- zero TA-6-blocking questions.

Closure evidence:

- [runtime/06_runtime_entity_player_creature_and_world_lifecycle.md](runtime/06_runtime_entity_player_creature_and_world_lifecycle.md) — Architecture Complete;
- [TA6_ROBLOX_RUNTIME_LIFECYCLE_SNAPSHOT.md](TA6_ROBLOX_RUNTIME_LIFECYCLE_SNAPSHOT.md) — PASS;
- [TA6_RUNTIME_LIFECYCLE_MATRIX.md](TA6_RUNTIME_LIFECYCLE_MATRIX.md) — PASS;
- [TA6_GDS_TRACEABILITY.md](TA6_GDS_TRACEABILITY.md) — PASS;
- [TA6_SCENARIO_VALIDATION.md](TA6_SCENARIO_VALIDATION.md) — 190 / 190 PASS;
- [TA6_DECISION_INDEX.md](TA6_DECISION_INDEX.md) — accepted;
- [TA6_CLOSURE_REPORT.md](TA6_CLOSURE_REPORT.md) — PASS.

## TA-7 — Capture, Creature Ownership, Mutation, and Reward Resolution

**Status:** NEXT — Draft

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

TA-0 through TA-6 are **Architecture Complete — PASS**.

The active dependency is:

> **TA-7 — Capture, Creature Ownership, Mutation, and Reward Resolution**

TA-8 through TA-17 remain blocked by dependency order. Gameplay implementation remains blocked until TA-17 is formally complete.
