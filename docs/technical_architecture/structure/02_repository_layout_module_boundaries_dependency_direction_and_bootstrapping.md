# TA-2 — Repository Layout, Module Boundaries, Dependency Direction, and Bootstrapping

> **Status:** Architecture Complete  
> **Owning TA phase:** TA-2 — Repository Layout, Module Boundaries, Dependency Direction, and Bootstrapping  
> **Authority:** Future repository/source layout, Rojo DataModel mapping, server/client/shared code boundaries, module/domain ownership, dependency direction, composition roots, startup/shutdown ordering, side-effect policy, cross-domain interaction rules, configuration/content placement boundaries and implementation scaffold contract  
> **Depends on:** TA-0 Architecture Complete; TA-1 Architecture Complete; GDS-2, GDS-3, GDS-4 through GDS-16 as routed by TA-0 traceability

## 1. Purpose

TA-2 defines the structural skeleton into which all later MonsterVault technical contracts will fit.

It answers:

- where future source code belongs;
- what becomes visible to client versus server;
- which folders are architectural boundaries rather than organizational decoration;
- how domain modules may depend on each other;
- where Roblox engine/platform integration belongs;
- how startup and shutdown are composed;
- how cyclic dependencies and hidden global state are prevented;
- how Rojo will map source roots into the Roblox DataModel.

TA-2 still does **not** authorize gameplay implementation.

The structural contract is:

> **MonsterVault uses three first-party runtime roots — server, client, and shared — with thin entrypoints, explicit composition roots, domain-owned internals, infrastructure isolated behind contracts, no side effects during module import, and a dependency graph that always points toward stable contracts rather than sideways into another subsystem's internals.**

## 2. Architectural Shape

MonsterVault uses a **modular monolith** inside one Roblox experience/server process.

This means:

- one deployable Roblox game runtime;
- multiple explicitly owned technical domains;
- no microservice-style network boundary inside one game server unless Roblox platform services actually require one;
- domain separation through Luau module contracts, not separate deployables;
- one server process composes the authoritative runtime;
- one client process composes presentation/input/runtime projection.

### STR-01 — Modular monolith is the baseline

The architecture favors clear ownership and low operational complexity over premature distribution.

### STR-02 — Domain boundaries are logical authority boundaries

Being in one Roblox server does not permit direct mutation of another domain's private state.

## 3. Future Repository Layout

The implementation-lock target layout is:

```text
Project-MonsterVault/
├── README.md
├── docs/
├── src/
│   ├── server/
│   │   ├── bootstrap/
│   │   ├── application/
│   │   ├── domains/
│   │   │   ├── player/
│   │   │   ├── creatures/
│   │   │   ├── capture/
│   │   │   ├── vault/
│   │   │   ├── economy/
│   │   │   ├── world/
│   │   │   ├── social/
│   │   │   ├── events/
│   │   │   ├── trading/
│   │   │   ├── monetization/
│   │   │   └── safety/
│   │   ├── infrastructure/
│   │   │   ├── persistence/
│   │   │   ├── networking/
│   │   │   ├── platform/
│   │   │   ├── telemetry/
│   │   │   ├── cross_server/
│   │   │   └── clock_random/
│   │   └── adapters/
│   ├── client/
│   │   ├── bootstrap/
│   │   ├── controllers/
│   │   ├── features/
│   │   ├── presentation/
│   │   ├── input/
│   │   └── adapters/
│   └── shared/
│       ├── contracts/
│       ├── types/
│       ├── ids/
│       ├── config/
│       └── util/
├── tests/
│   ├── unit/
│   ├── integration/
│   ├── scenarios/
│   └── fixtures/
├── scripts/
├── assets/
└── tooling/config files
```

These directories describe the **implementation target**. TA-2 records them architecturally; TA-17 creates/locks the actual implementation scaffold and exact files.

## 4. Rojo DataModel Mapping

The future canonical mapping is:

```text
src/shared
    -> ReplicatedStorage/MonsterVault/Shared

src/server
    -> ServerScriptService/MonsterVaultServer

src/client
    -> StarterPlayer/StarterPlayerScripts/MonsterVaultClient
```

Reserved engine-owned/runtime locations:

```text
ReplicatedStorage/MonsterVault/Remotes
    -> owned by TA-3 networking bootstrap/runtime contract

ServerStorage/MonsterVault
    -> optional server-only assets/content only when TA-5/TA-9 justify it

Workspace
    -> world/runtime Instances owned by TA-6/TA-9, not source-code authority

StarterGui
    -> UI template/runtime ownership decided by TA-12
```

### MAP-01 — Three source roots are stable

Later phases may add subfolders but should not introduce parallel first-party roots that bypass server/client/shared authority.

### MAP-02 — Remotes are not hand-owned by feature folders

Remote instances/contracts are centrally governed by TA-3.

### MAP-03 — World Instances are not mixed with server source

Runtime/world content may be represented through Studio/Rojo/content registries later, but server logic does not live inside Workspace objects as an architectural pattern.

## 5. Server Root Responsibilities

`src/server` contains code that must never be exposed as replicated first-party source.

It owns:

- authoritative domain state transitions;
- persistence orchestration;
- transaction commits;
- secure random resolution;
- progression/economy mutation;
- capture/ownership decisions;
- event reward authority;
- trade commit authority;
- purchase entitlement reconciliation;
- moderation/safety enforcement;
- platform adapters requiring server trust.

### SRV-01 — Server-only means non-replicated

Security-sensitive implementation details do not live in `shared`.

### SRV-02 — Server domain code does not depend on client code

This dependency is always forbidden.

## 6. Client Root Responsibilities

`src/client` owns:

- input interpretation;
- UI/presentation;
- camera/audio/feedback;
- local presentation state;
- client-side projections/caches;
- reversible cosmetic prediction;
- accessibility behavior;
- client-side request initiation;
- local controller lifecycle.

It does not own persistent truth.

### CLI-01 — Client code never becomes fallback authority

If server data is absent/stale, the client presents uncertainty/loading/error; it does not invent ownership/reward state.

### CLI-02 — Client domains are presentation/features, not authoritative mirrors

The client may organize feature code around capture/Vault/trading/etc., but those modules represent client behavior/projection only.

## 7. Shared Root Responsibilities

`src/shared` is replicated to clients.

Therefore it may contain only information safe for clients to inspect.

Allowed categories:

- public structural types;
- request/response/event payload types;
- stable public IDs;
- public enums/constants;
- pure deterministic utility functions;
- public immutable configuration explicitly intended for both sides;
- presentation-safe data transformations.

Not allowed:

- server secrets;
- authoritative reward-selection logic whose disclosure materially enables abuse;
- persistence credentials/config;
- hidden anti-cheat thresholds;
- privileged moderation policy internals;
- server-only random seeds;
- private purchase/receipt state;
- server transaction internals.

### SHR-01 — Replication equals disclosure

Anything under `shared` is assumed inspectable by a hostile client.

### SHR-02 — Shared code cannot mutate server-owned state

Pure shared helpers may compute values, but authoritative mutation remains server-owned.

## 8. Layer Responsibilities Inside Server

The server is split into four structural layers.

### 8.1 bootstrap/

Contains the composition root and lifecycle orchestration.

Responsibilities:

- construct dependencies;
- validate configuration;
- order startup;
- bind lifecycle/shutdown hooks;
- expose no domain business logic.

### 8.2 application/

Contains cross-domain use-case orchestration where one player action legitimately spans multiple owners.

Examples conceptually:

- secure-capture finalization coordinating capture + creature ownership + capacity + persistence;
- trade commit coordinating trading + ownership + capacity + persistence;
- commercial reconciliation coordinating monetization + entitlement + capacity/economy.

Application orchestration may call public domain contracts.

It must not reach into domain internals.

### 8.3 domains/

Contains authoritative gameplay-domain logic/state transitions.

Each domain owns:

- its state machine/rules;
- its public interface;
- its private implementation;
- domain-specific validation;
- domain events/results exposed to orchestration.

### 8.4 infrastructure/

Contains reusable technical mechanisms:

- persistence;
- networking;
- platform APIs;
- telemetry;
- cross-server primitives;
- clock/random providers.

Infrastructure must not import gameplay domains.

### 8.5 adapters/

Contains translation between external/engine representations and internal contracts where needed.

Examples:

- Roblox Player/Instance adaptation;
- MarketplaceService receipt payload adaptation;
- platform policy result translation.

## 9. Dependency Direction

The permitted server dependency flow is:

```text
bootstrap
    ↓
application
    ↓
domain public contracts
    ↓
domain internals

bootstrap/application
    ↓
infrastructure interfaces/adapters

domain internals
    ↓
shared pure types/ids/util

infrastructure
    ↓
shared pure types/ids/util
```

Forbidden:

```text
domain A internals -> domain B internals
infrastructure -> gameplay domain
server -> client
shared -> server
shared -> client
domain -> bootstrap
domain -> concrete UI
```

### DEP-01 — Sideways dependencies use public contracts

A domain may consume another domain only through an explicitly defined public contract or an application-level orchestration boundary.

### DEP-02 — Infrastructure points inward only through interfaces

Persistence/network/platform implementations do not own gameplay decisions.

### DEP-03 — Shared is the lowest reusable layer

Shared cannot import server/client roots.

## 10. Domain Public Boundary

Every server domain will expose one intentional public module surface.

Conceptual pattern:

```text
domains/<domain>/
├── public contract
└── internal/
    ├── state/rules
    ├── validators
    └── helpers
```

The exact filenames are implementation-lock details.

### DOM-01 — Consumers import the public boundary, not internals

Deep imports into another domain's `internal` subtree are forbidden.

### DOM-02 — Public surfaces remain narrow

Do not export internal tables/state simply to make integration easy.

### DOM-03 — Domain state is private by default

Read access is through queries/snapshots/contracts; mutation access is through domain commands/use cases.

## 11. Application Orchestration

Some GDS operations cross multiple domains.

TA-2 establishes the application layer specifically to prevent cyclic domain ownership.

### APP-01 — Cross-domain transaction coordinators live above domains

Example conceptual ownership:

- Capture domain decides Capture Success/eligibility.
- Creature domain owns Creature Instance/ownership.
- Vault/capacity domain owns capacity.
- Application use case coordinates finalization.
- Persistence infrastructure provides durable commit primitives later.

No domain becomes a god-service just because it participates in many use cases.

### APP-02 — Application logic cannot redefine domain invariants

It sequences/coordinates them.

## 12. Infrastructure Boundary

### INF-01 — Infrastructure is mechanism, not policy

Examples:

- DataStore retry utility may retry.
- It may not decide that a failed purchase should grant Energy.

### INF-02 — Infrastructure is replaceable behind contracts

The architecture should allow testing/fakes where practical.

### INF-03 — Roblox service access is centralized by concern

Do not scatter direct `DataStoreService`, `MarketplaceService`, `MessagingService`, or telemetry service calls through arbitrary domains.

Owning TA phases define adapters/interfaces.

## 13. Client Structure

### 13.1 bootstrap/

Composition/lifecycle only.

### 13.2 controllers/

Coordinates client feature state and server projections.

Examples conceptually:

- session/load controller;
- interaction controller;
- capture presentation controller;
- trade presentation controller.

### 13.3 features/

Feature-local non-authoritative client behavior.

### 13.4 presentation/

HUD, screens, modals, notifications, view models/presenters.

### 13.5 input/

Cross-device semantic input mapping.

### 13.6 adapters/

Roblox/client engine adaptation where needed.

### CLD-01 — Presentation cannot import server code

Only shared contracts/types and client modules.

### CLD-02 — UI does not call remotes arbitrarily

Network access is mediated through TA-3-defined client networking contracts/controllers.

### CLD-03 — Input produces semantic intent

Input modules should produce actions such as PrimaryInteract rather than owning gameplay outcomes.

## 14. Shared Contracts versus Network Contracts

TA-2 reserves `shared/contracts` for public contract definitions.

TA-3 decides exact networking schemas and generated/manual remote contract organization.

### CON-01 — Shared payload types are not authorization

A valid type shape may still be unauthorized or malicious.

### CON-02 — Contracts avoid leaking hidden policy

If a client does not need a server-private field, it does not appear in a shared contract.

## 15. Configuration Boundary

TA-5 will own content/config schemas.

TA-2 sets placement rules:

- public replicated config -> `shared/config`;
- server-private config -> server-owned TA-5-defined location;
- environment/deployment config -> tooling/release configuration, not gameplay source;
- secrets -> never in source.

### CFG-01 — Public config must be safe to disclose

### CFG-02 — Config does not contain mutable runtime player state

### CFG-03 — Domain code consumes validated config through owning contracts

## 16. Utility Policy

### UTIL-01 — Shared util is for genuinely domain-agnostic pure helpers

Examples:

- immutable table helpers;
- math/string helpers with broad reuse;
- serialization-neutral helpers.

### UTIL-02 — No junk-drawer util layer

A helper used by one domain belongs in that domain.

### UTIL-03 — Utility code cannot become hidden policy

If a helper encodes rarity/economy/trade rules, it belongs to the owning domain.

## 17. No Side Effects on Require

### MOD-01 — Requiring a ModuleScript must not start gameplay systems

Module import may:

- define types/functions/classes;
- build immutable constants;
- validate purely local static definitions where deterministic.

It may not:

- connect long-lived engine events;
- create remote endpoints;
- mutate player state;
- start loops;
- write DataStores;
- award value;
- publish cross-server messages.

### MOD-02 — Lifecycle side effects are explicit

Side effects occur through bootstrap-owned lifecycle calls.

This makes:

- dependency ordering visible;
- tests deterministic;
- duplicate startup detectable;
- shutdown possible.

## 18. Standard Lifecycle Contract

Long-lived runtime components use a conceptual lifecycle:

```text
Construct
    ↓
Validate
    ↓
Start
    ↓
Ready
    ↓
Stop / Shutdown
```

Exact Luau API names are finalized by TA-17.

### LIFE-01 — Construction does not perform irreversible work

### LIFE-02 — Validation happens before exposure

Network endpoints or gameplay interactions do not become available before their dependencies validate.

### LIFE-03 — Start is idempotency-aware

Duplicate bootstrap calls must not silently register duplicate listeners/loops.

### LIFE-04 — Stop/Shutdown is explicit where cleanup/save/drain matters

## 19. Server Bootstrap Ordering

The conceptual server startup sequence is:

```text
1. establish environment/runtime identity
2. load and validate static configuration/registries
3. construct infrastructure adapters
4. construct domain services
5. construct application coordinators
6. validate dependency graph
7. start persistence/session infrastructure
8. start authoritative domains
9. bind networking/public request endpoints
10. start cross-server/live-ops/background loops
11. mark server runtime Ready
```

### BOOT-S01 — Networking binds after authority exists

Clients cannot call half-constructed domain handlers.

### BOOT-S02 — Background loops start after dependencies are valid

### BOOT-S03 — Fatal bootstrap failure fails closed

Do not expose partially initialized authoritative gameplay.

Exact degraded-mode behavior is owned by later phases.

## 20. Player Session Bootstrap

TA-4 will own the exact session lifecycle.

TA-2 structural ordering is:

```text
Player joins
    ↓
server session coordinator begins load
    ↓
trusted persistent state established
    ↓
domain projections/session state constructed
    ↓
player becomes gameplay-ready
    ↓
client receives authoritative readiness/projection
```

This preserves GDS-2 Protected Load Failure.

## 21. Client Bootstrap Ordering

Conceptual client sequence:

```text
1. establish local runtime/input/device context
2. load shared public contracts/config
3. construct client adapters/controllers
4. construct presentation/input systems
5. connect to TA-3 client networking layer
6. subscribe to authoritative projections/events
7. await server/player readiness where required
8. enable gameplay-facing controls/presentation
9. mark client Ready
```

### BOOT-C01 — UI shell may exist before gameplay readiness

But irreversible actions remain unavailable until server authority allows them.

### BOOT-C02 — Client readiness is not server gameplay readiness

These states remain distinct.

## 22. Shutdown Ordering

Server shutdown conceptually reverses risk:

```text
1. stop accepting new irreversible operations where needed
2. stop/suspend background generation
3. allow bounded in-flight resolution per owning contracts
4. finalize/flush persistence obligations
5. stop cross-server/network infrastructure
6. release resources
```

TA-4/TA-7/TA-10/TA-11 define exact transaction-specific behavior.

## 23. Roblox Event Connection Ownership

### EVT-01 — Every long-lived connection has an owning component

### EVT-02 — Connections are created during Start, not import

### EVT-03 — Connections are cleaned up when lifecycle requires it

### EVT-04 — One global engine event should not acquire many hidden duplicate listeners when one dispatcher/owner is appropriate

TA-14 later validates performance impact.

## 24. Dependency Injection / Construction Policy

MonsterVault uses **explicit constructor/composition injection**, not a magical global dependency container.

### DI-01 — Dependencies are visible at construction

### DI-02 — No arbitrary service locator accessible everywhere

### DI-03 — No implicit global singleton registry for gameplay mutation

A small bootstrap registry may hold constructed components for startup bookkeeping, but domains do not fetch arbitrary dependencies from it during normal operation.

## 25. Global State Policy

Forbidden baseline patterns:

- `_G` gameplay state;
- `shared` global table gameplay state;
- mutable module singleton state used as undeclared cross-domain database;
- Workspace attributes as authoritative persistent player storage;
- ReplicatedStorage values as server truth merely because everyone can read them.

Module-local state is allowed when it is owned, lifecycle-bound and not an undeclared global dependency.

## 26. Circular Dependency Prevention

### CYC-01 — Domain cycles are architectural defects

Examples prohibited:

```text
Capture internal -> Vault internal
Vault internal -> Capture internal
```

Resolution options:

- move orchestration to application layer;
- extract a lower-level pure contract/type;
- redefine ownership;
- introduce a narrow interface/event.

### CYC-02 — Type-only/shared contracts do not justify runtime cycles

### CYC-03 — TA-15 will enforce feasible dependency checks

## 27. Domain Event Policy

TA-2 permits in-process domain events for decoupled notification, subject to later detailed design.

Rules:

- event producer owns the event meaning;
- events describe something that happened, not commands disguised as broadcasts;
- critical atomic transactions do not rely on eventually handled fire-and-forget events for correctness;
- subscribers cannot mutate producer internals;
- ordering/delivery semantics are explicit where correctness depends on them.

Exact event bus/mechanism is not selected yet.

## 28. Command / Query Boundary

TA-2 recommends explicit semantic separation:

- **commands** request a state change from the owning domain;
- **queries** read/provide projections/snapshots;
- **events** communicate completed facts.

This is a structural convention, not a requirement to implement a formal CQRS framework.

### CQ-01 — Queries do not mutate state

### CQ-02 — Commands do not expose writable internal tables

## 29. File Naming Policy

Future implementation source follows consistent intent-revealing naming.

Baseline:

- `.luau` for first-party Luau;
- PascalCase for public module/type-style files where appropriate;
- lowercase directory names for architectural folders;
- explicit `.server.luau` / `.client.luau` only for entrypoint/runtime Script mapping when needed;
- no duplicated vague names such as `Manager2`, `NewService`, `Utils2`.

Exact naming lint is TA-15/TA-17.

## 30. Entrypoints

The target has exactly one ordinary first-party server bootstrap entrypoint and one ordinary first-party client bootstrap entrypoint for the primary place.

Their job is only to call the composition root.

### ENTRY-01 — Feature modules are not independent auto-start Scripts

### ENTRY-02 — Additional Scripts require explicit architectural ownership

Examples may later include isolated Studio/test/bootstrap contexts, but not arbitrary feature startup.

## 31. Test Layout

TA-15 owns exact testing technology.

TA-2 locks logical test placement:

- `tests/unit` — isolated modules/pure domain logic;
- `tests/integration` — multi-module/domain/infrastructure contracts;
- `tests/scenarios` — end-to-end architecture/GDS scenario behavior;
- `tests/fixtures` — deterministic input/config fixtures.

### TEST-STRUCT-01 — Production modules do not depend on test modules

### TEST-STRUCT-02 — Test doubles implement explicit contracts

## 32. Scripts Directory

`scripts/` is reserved for developer/CI/release tooling, not Roblox runtime gameplay.

Examples later:

- build/check orchestration;
- sourcemap generation;
- validation/report scripts.

### SCRIPT-01 — scripts/ does not become a second runtime codebase

## 33. Assets Directory

`assets/` is reserved for source-controlled asset metadata/source files where appropriate.

TA-9/TA-12 define exact asset/world/UI ownership.

Large/generated Roblox asset binaries require deliberate strategy.

## 34. Platform Service Access Map

Direct Roblox service usage is constrained structurally.

| Platform concern | Intended technical owner |
|---|---|
| DataStoreService | TA-4 persistence infrastructure |
| MemoryStoreService | TA-10 cross-server infrastructure where justified |
| MessagingService | TA-10 cross-server infrastructure where justified |
| MarketplaceService | TA-11 monetization adapter |
| TeleportService | TA-9/TA-10 if multi-place/cross-server needs justify |
| TextChatService / filtering/policy APIs | TA-15-informed platform adapters owned by TA-10/TA-12/TA-13 as appropriate |
| AnalyticsService / telemetry APIs | TA-13 |
| Players lifecycle | server/client bootstrap + TA-4/TA-6 session/runtime owners |
| RunService loops | owning domain/infrastructure, lifecycle-managed |
| CollectionService/tags | TA-5/TA-6/TA-9 if selected |

### PLAT-01 — No arbitrary platform-service calls from UI/domain leaf modules

## 35. Security Consequences

The layout reduces exploit surface by:

- keeping authority code server-only;
- treating shared as disclosed;
- centralizing networking;
- centralizing platform adapters;
- preventing UI from mutating domains directly;
- making startup/remote binding explicit;
- eliminating hidden globals/service locators.

TA-3 performs the detailed network/exploit architecture.

## 36. Performance Consequences

Positive effects:

- one bootstrap avoids duplicated loops/listeners;
- centralized platform access helps budget calls;
- domain ownership reduces accidental redundant work;
- shared code remains small/public.

Risks:

- overly centralized application coordinators could become bottlenecks/god modules;
- excessive domain-event fanout could add overhead;
- deep abstraction could inflate allocations/call stacks.

TA-14 validates concrete budgets.

## 37. Testability Consequences

The no-side-effect-import and explicit-construction rules allow:

- isolated module tests;
- fake infrastructure;
- deterministic clocks/random providers;
- controlled lifecycle;
- integration tests without automatic engine hooks.

## 38. TA-3 Handoff

TA-3 receives:

- one server composition root;
- one client composition root;
- server/client/shared mapping;
- centralized networking infrastructure location;
- shared public-contract location;
- public domain boundaries;
- no direct UI-to-domain remote sprawl.

TA-3 must define:

- exact remote registry;
- payload contracts;
- server handler ownership;
- request/event direction;
- validation/rate/replay rules.

## 39. TA-4 Handoff

TA-4 receives:

- persistence infrastructure location;
- session bootstrap position before gameplay-ready;
- domain-owned persistent state with centralized persistence mechanism;
- no arbitrary DataStore calls from domains.

## 40. TA-5/TA-6 Handoff

TA-5 receives:

- shared public config/ID roots;
- server-private config placement requirement.

TA-6 receives:

- runtime domain structure;
- lifecycle contract;
- Workspace/runtime projection boundary.

## 41. Open Questions

There are **zero TA-2-blocking open questions**.

Correctly deferred:

- exact remote names/payloads — TA-3;
- exact persistent schema/repository abstractions — TA-4;
- exact ID/config schema — TA-5;
- exact runtime entity implementation pattern — TA-6;
- exact event bus implementation — owning later phase if justified;
- exact test framework/dependency checker — TA-15;
- actual source scaffold/default.project.json creation — TA-17 Implementation Lock.

## 42. Architecture-Complete Checklist

- [x] modular-monolith shape selected;
- [x] future repository layout defined;
- [x] server/client/shared Rojo mapping defined;
- [x] server/client/shared authority boundaries defined;
- [x] server layer responsibilities defined;
- [x] domain/public/internal rules defined;
- [x] application orchestration boundary defined;
- [x] infrastructure/adapters boundary defined;
- [x] dependency direction defined;
- [x] shared disclosure policy defined;
- [x] configuration/util placement policy defined;
- [x] no-side-effects-on-require rule defined;
- [x] component lifecycle defined;
- [x] server/client/player/shutdown bootstrap ordering defined;
- [x] dependency-injection/global-state policy defined;
- [x] circular-dependency policy defined;
- [x] command/query/event convention defined;
- [x] entrypoint policy defined;
- [x] tests/scripts/assets boundaries defined;
- [x] platform-service access ownership mapped;
- [x] security/performance/testability consequences reviewed;
- [x] TA-3/4/5/6 handoffs defined;
- [x] zero TA-2-blocking open questions.
