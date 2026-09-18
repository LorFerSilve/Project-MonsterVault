# TA-6 — Runtime Entity, Player, Creature, and World Lifecycle

> **Status:** Architecture Complete  
> **Owning TA phase:** TA-6 — Runtime Entity, Player, Creature, and World Lifecycle  
> **Authority:** Authoritative runtime entity model, Player Session versus Character Presence, world-entity registry, Creature runtime lifecycle, persistent-to-runtime materialization, runtime-to-persistent transitions, Roblox Instance projection ownership, streaming tolerance, runtime cleanup/destruction, interaction target identity, lifecycle revisions, recovery projection, physics/network-ownership boundary, world-runtime containers, and lifecycle observability  
> **Depends on:** TA-0 through TA-5 Architecture Complete; GDS-2, GDS-3, GDS-4, GDS-5, GDS-6, GDS-9, GDS-10, GDS-11, GDS-14, GDS-17

## 1. Purpose

TA-6 defines what a live MonsterVault entity is inside one running Roblox server and how persistent concepts are projected into temporary Roblox runtime objects without making those objects the authoritative source of truth.

The runtime contract is:

> **Authoritative gameplay entities live as server-owned runtime records keyed by stable IDs. Roblox Instances are disposable projections of those records, not the owner of persistent truth. Player Session lifetime is separate from Character lifetime. Creature identity survives model destruction, streaming, Recovery, ownership transfer and re-materialization. World entities enter and leave through explicit lifecycle state machines, and every long-lived connection, task and Instance projection has one cleanup owner.**

TA-6 does not implement entity classes, spawn logic, capture mechanics, world scheduling or character scripts. Those implementation artifacts remain blocked until TA-17.

## 2. Runtime Entity Taxonomy

MonsterVault distinguishes these runtime categories.

### 2.1 Player Session Runtime

One server-local runtime object representing a connected player whose TA-4 profile/session is loading, ready, protected, leaving or closed.

It owns references to:

- Roblox Player identity;
- TA-4 profile session handle;
- readiness/protected state;
- current Character Presence if one exists;
- active runtime participation references;
- client projection/session version.

It does not become the persistent profile itself.

### 2.2 Character Presence

One temporary Roblox avatar life/presence belonging to a Player Session.

A character may be:

- absent;
- spawning;
- active;
- failed/dead;
- recovering;
- removing.

Character destruction does not destroy Player Session or persistent ownership.

### 2.3 World Runtime Entity

A server-owned session-local gameplay entity with:

- RuntimeEntityId;
- entity kind;
- lifecycle state;
- server-owned semantic data;
- optional Workspace projection;
- optional interaction target;
- lifecycle revision;
- cleanup owner.

Examples:

- World Creature;
- encounter marker/entity;
- world objective runtime entity;
- temporary event-world entity.

### 2.4 Persistent-Owned Runtime Projection

A temporary world/UI/runtime representation of persistent player-owned state.

Examples may later include:

- an Active Creature model;
- a Vault display creature;
- a carried/provisional visual representation;
- a showcase model.

The projection is not a second Creature Instance and does not own persistent identity.

### 2.5 Static World Authoring Entity

A source-authored world object such as:

- Landmark;
- Secure Point;
- Recovery Anchor;
- Travel Node;
- Spawn Point.

Its semantic identity comes from TA-5 registry IDs/tags/attributes.

Static authoring objects are validated and indexed into runtime lookup structures rather than treated as player-owned entities.

## 3. Runtime Identity

### RUNTIME-ID-01 — Every dynamic authoritative runtime entity has a server-generated stable runtime ID

TA-5's GUID-style identity baseline applies.

### RUNTIME-ID-02 — Roblox Instance identity is not semantic identity

Do not use:

- Instance name;
- debug ID;
- object reference;
- hierarchy path;
- array position;

as durable/cross-system identity.

### RUNTIME-ID-03 — Runtime IDs are never reused

Destroying a projection/entity does not free its ID for reuse.

### RUNTIME-ID-04 — Persistent CreatureInstanceId remains the creature identity

When a persistent Secured Creature is projected into the world, the projection references the existing CreatureInstanceId; it does not mint a replacement creature identity.

## 4. Authoritative Runtime Record versus Roblox Instance Projection

The canonical relationship is:

```text
Server Runtime Record
    |
    | owns semantic state / lifecycle
    v
Projection Adapter
    |
    | creates/updates/destroys
    v
Roblox Model / Parts / Attributes in Workspace
```

### PROJ-01 — Runtime record is authoritative

Destroying/streaming/removing the client-side Model does not itself alter server entity state.

### PROJ-02 — Projection may be absent

An entity may temporarily have no visible Workspace projection while:

- being constructed;
- waiting for asset/materialization;
- server-only resolving;
- streamed out on a client;
- transitioning to a non-world state;
- shutting down.

### PROJ-03 — Projection is one-to-one only when semantics require it

One authoritative creature entity normally has at most one live world creature projection.

Multiple presentation projections of a Secured Creature may exist only when an owning system explicitly defines them as read-only representations and they all reference the same persistent CreatureInstanceId.

### PROJ-04 — Cloning a model never clones ownership/value

A Roblox Model clone is only visual/runtime materialization.

## 5. Runtime Registry

The server owns a runtime entity registry.

Conceptually:

```text
RuntimeEntityId -> RuntimeEntityRecord
```

It supports narrow queries such as:

- resolve entity by ID;
- resolve interaction target;
- test lifecycle eligibility;
- enumerate by owning world subsystem when necessary;
- attach/detach projection.

### REG-RUN-01 — Registry is server-only authority

A client cache is a projection only.

### REG-RUN-02 — Registration precedes public interaction

An entity cannot be interactable before the server registry contains its authoritative record.

### REG-RUN-03 — Deregistration follows terminal lifecycle

No new command resolves an entity after it is terminal/deregistered.

### REG-RUN-04 — No arbitrary global mutable entity table

The registry is injected through the owning runtime/domain contracts under TA-2.

## 6. Generic Runtime Entity Lifecycle

All dynamic entities follow a conceptual lifecycle:

```text
Allocated
   ↓
Initializing
   ↓
Registered
   ↓
Materializing
   ↓
Active
   ↓
Quiescing
   ↓
Terminating
   ↓
Destroyed
```

Not every entity needs a visible Model during every state.

### LIFE-RUN-01 — Allocated

ID exists; entity is not public/interactable.

### LIFE-RUN-02 — Initializing

Server validates required content/context and constructs semantic state.

### LIFE-RUN-03 — Registered

Server registry owns the entity; commands may resolve it only when route/state allows.

### LIFE-RUN-04 — Materializing

Workspace projection is being created/bound.

### LIFE-RUN-05 — Active

The entity is eligible for its runtime role.

### LIFE-RUN-06 — Quiescing

New interactions are blocked while current owned work drains/resolves.

### LIFE-RUN-07 — Terminating

Entity has a terminal outcome and performs final cleanup/deregistration.

### LIFE-RUN-08 — Destroyed

Connections/tasks/projections are cleaned; identity is not reused.

## 7. Lifecycle Revision

Every mutable dynamic runtime entity has a monotonically increasing server-side `runtimeRevision`.

### REV-RUN-01 — Revision changes on semantically relevant lifecycle mutation

Examples:

- availability/claim lifecycle transition;
- projection replacement;
- ownership/provisional-state transition;
- terminal/despawn transition.

### REV-RUN-02 — Revision is not persistent profile revision

TA-4 profileRevision and TA-6 runtimeRevision solve different concurrency problems.

### REV-RUN-03 — Client revision is an expectation only

Clients may include expected runtime revision in TA-3 commands where appropriate; server compares against current authoritative revision.

## 8. Player Session Lifecycle

TA-6 consumes TA-4 persistence state and GDS-2 active-presence semantics.

Conceptual sequence:

```text
PlayerAdded
  ↓
SessionAllocated
  ↓
ProfileAcquiring
  ↓
ProfileReady
  ↓
SafeArrivalPending
  ↓
ActivePresence
  ├── CharacterFailure/Reset -> Recovery -> ActivePresence
  └── PlayerRemoving/Shutdown -> Leaving -> Closed

ProfileAcquiring failure -> ProtectedLoadFailure -> retry/leave
```

### PLAYER-01 — Player object is not the profile

Roblox `Player` is a platform/session object.

### PLAYER-02 — Active Presence requires trusted profile readiness

Character existence alone never authorizes irreversible gameplay.

### PLAYER-03 — PlayerRemoving starts session departure

It is not interpreted as a voluntary loss of persistent state.

### PLAYER-04 — Late join creates a fresh session runtime

It loads persistent state and joins the current server-local world; it does not reconstruct expired server opportunities.

## 9. Character Presence Lifecycle

Character lifetime is nested inside Player Session lifetime.

```text
Absent
  ↓
Spawning
  ↓
Alive/Controllable
  ↓
Failed / Reset / Invalid
  ↓
Removing
  ↓
RecoveryPending
  ↓
Spawning ...
```

### CHAR-01 — CharacterAdded/CharacterRemoving are lifecycle hooks, not persistence events

A character respawn does not reload/replace the Player Profile.

### CHAR-02 — Character model is not player ownership authority

Creature ownership, Energy, progression and other persistent values do not live on Character Instances.

### CHAR-03 — Character failure triggers GDS Recovery semantics

It does not erase secured creatures or finalized persistent outcomes.

### CHAR-04 — New irreversible interactions require a valid active Character Presence where the owning mechanic needs one

UI-only/read-only operations may remain available without an active character if later presentation architecture permits.

## 10. Character Generation / Spawn Boundary

TA-6 defines the technical handoff:

1. Player profile/session becomes trusted Ready;
2. safe spawn/recovery location is resolved from server-authoritative world state;
3. Roblox character is created/accepted;
4. Character Presence record binds the Character model;
5. runtime validation confirms humanoid/root/required structure;
6. movement/input-facing gameplay can become Active Presence.

### SPAWN-PLAYER-01 — No irreversible gameplay while Character Presence is half-constructed

### SPAWN-PLAYER-02 — Spawn/recovery target is server-chosen/validated

A client cannot choose arbitrary CFrame as a trusted recovery location.

### SPAWN-PLAYER-03 — Spawn failure remains recoverable

Do not corrupt persistence because an avatar/model failed to materialize.

## 11. Character Cleanup

On CharacterRemoving/failure:

- mark presence non-active before cleanup;
- invalidate interaction contexts tied to that character;
- release character-scoped event connections/tasks;
- remove character-owned temporary projections;
- hand active subsystem interruption to its owning TA;
- preserve Player Session and persistent profile.

### CLEAN-CHAR-01 — Old Character references cannot remain valid interaction authority

### CLEAN-CHAR-02 — Respawn creates a new Character Presence generation

Commands targeting an old character generation fail stale-state validation.

## 12. Character Generation ID

Each Character Presence receives a server-local `characterGeneration` or equivalent monotonic identity within the session.

### CGEN-01 — Character generation prevents stale async work from applying to a replacement avatar

### CGEN-02 — Generation is session-local, not persisted

### CGEN-03 — A command tied to old generation cannot affect current character state

Exact representation is TA-17.

## 13. World Creature Runtime Record

A World Creature record conceptually contains:

- CreatureInstanceId;
- SpeciesId;
- Variant Identity reference/data from TA-7;
- ContentSnapshotId/provenance input;
- SpawnContextId;
- server creation time;
- encounter lifetime/expiry policy;
- runtimeRevision;
- lifecycle state;
- claim/acquisition-state handle delegated to TA-7;
- projection handle;
- spatial/world context handle;
- Protected Variant stability metadata where applicable.

### WC-01 — Variant Identity is finalized before the creature becomes individually actionable

TA-7 owns generation, but TA-6 will not expose an actionable creature with unresolved/rerollable identity.

### WC-02 — World Creature has one stable CreatureInstanceId for its lifetime

Claim failure/release of the same surviving creature does not mint a new identity.

### WC-03 — Session-local world existence is not persistent ownership

A World Creature record may vanish when its server session ends unless TA-7 finalized it into persistent ownership.

## 14. World Creature Lifecycle

Structural lifecycle:

```text
Generated
  ↓
Registered
  ↓
Materializing
  ↓
IdleAvailable
  ↓
AcquisitionOwnedState (TA-7 controls substate)
  ├── returns to IdleAvailable for same surviving instance
  ├── SecuredOwnershipFinalized -> Persisted/WorldProjectionEnds
  └── terminal failure/despawn -> Terminating
IdleAvailable
  └── lifetime expiry -> Terminating
Terminating
  ↓
Destroyed
```

### WC-LIFE-01 — Idle lifetime may expire only while eligible to despawn

### WC-LIFE-02 — Active acquisition blocks ordinary idle despawn

Engagement Claim, Capture Attempt, Provisional Capture or Transport Custody lifetime is owned by TA-7/GDS-5.

### WC-LIFE-03 — Returning to idle preserves identity

### WC-LIFE-04 — Genuine destruction frees population capacity, not identity

A later replacement is a new CreatureInstanceId with independently generated outcome.

## 15. Secured Ownership Transition Handoff

TA-7 owns the capture transaction and TA-4 owns P2 durability.

TA-6 owns runtime projection consequences.

When Secured Ownership Finalization becomes durably committed:

1. world acquisition entity enters Quiescing/terminal transition;
2. no new public claim/interaction is accepted;
3. persistent CreatureInstanceId remains unchanged;
4. World Creature projection is removed/replaced as owning presentation requires;
5. runtime world registry releases the public encounter role;
6. a separate read-only/active owned projection may later be materialized from persistent state.

### SECURE-01 — No world-model destruction before ownership commit can accidentally create ownership

### SECURE-02 — No second CreatureInstanceId is minted for the owned version

### SECURE-03 — World population refill creates a different new creature, never a duplicate of the finalized instance

## 16. Persistent Creature Materialization

A Secured Creature can be materialized into runtime presentation/active roles from TA-4 state.

### OWNPROJ-01 — Materialization reads authoritative persistent identity

### OWNPROJ-02 — Destroying owned projection does not Release the creature

Release is a separate P2 transaction owned by downstream systems.

### OWNPROJ-03 — Re-materialization preserves CreatureInstanceId and Variant Identity

### OWNPROJ-04 — Multiple read-only projections may exist only where the GDS explicitly allows display/showcase semantics

They never create duplicate ownership.

## 17. Runtime Ownership versus Persistent Ownership

TA-6 uses these distinct concepts:

- **runtime owner/component owner** — subsystem responsible for an in-memory entity/projection;
- **network owner** — Roblox physics simulation owner;
- **persistent player owner** — account that owns a Secured Creature;
- **interaction/claim owner** — temporary acquisition authority from TA-7.

### OWNER-01 — These concepts must never be conflated

A client receiving network ownership of a physics assembly does not own the creature.

A subsystem owning cleanup does not own persistent value.

## 18. Roblox Workspace Runtime Containers

Conceptual runtime hierarchy:

```text
Workspace
└── MonsterVaultRuntime
    ├── Creatures
    ├── Encounters
    ├── PlayerOwnedProjections
    └── EffectsAnchors
```

Static authored world geometry/markers remain under TA-9-owned world hierarchy.

### WORK-01 — Runtime container hierarchy is organizational, not semantic identity

### WORK-02 — Source code never lives in spawned entity Models as authority

### WORK-03 — Client commands resolve stable IDs through server registry, not arbitrary Workspace paths

Exact folder/model names are TA-17.

## 19. ServerStorage Asset / Template Boundary

TA-6 permits server-only model templates/assets under a TA-9/TA-12 validated asset strategy.

### TEMPLATE-01 — Template clone is not an entity until authoritative runtime registration assigns it

### TEMPLATE-02 — Templates contain no persistent player state

### TEMPLATE-03 — Hidden server-only templates may protect implementation/content not needed by clients

Asset distribution strategy is refined in TA-9/TA-12/TA-14.

## 20. Interaction Target Binding

A runtime-interactable projection exposes a disclosure-safe stable target reference.

Conceptually:

- RuntimeEntityId / InteractionTargetId attribute;
- structural tag;
- server registry binding.

### INTARGET-01 — Client-visible target ID is not authorization

### INTARGET-02 — Server resolves current entity + runtimeRevision/context

### INTARGET-03 — Destroyed/stale target returns safe NotFound/InvalidState

### INTARGET-04 — Arbitrary client Instance references remain unnecessary

This reinforces TA-3.

## 21. Instance Streaming

TA-6 assumes Workspace content may stream in/out on clients.

### STREAM-01 — Client absence of a Workspace Instance does not mean server entity destruction

### STREAM-02 — Client controllers tolerate stream-out

They must release local presentation references and reacquire by stable ID/projection events as content streams back.

### STREAM-03 — Server gameplay truth never depends on whether a client has streamed an Instance

### STREAM-04 — Persistent streaming modes are exceptional

Roblox Persistent/PersistentPerPlayer models are reserved for a small justified set where client correctness truly requires constant presence.

They are not a blanket solution to streaming.

### STREAM-05 — Interactive streamed world objects require graceful local absence

Client UI cannot assume every server-known target is currently in the local DataModel.

TA-9/TA-12/TA-14 define concrete streaming strategy/budgets.

## 22. Atomic Model Projection

Where a creature/interactable Model must appear as one coherent visual unit, TA-9/TA-12 may select Atomic model streaming.

### ATOMIC-01 — Atomic streaming affects client projection only

It does not change entity state/ownership.

### ATOMIC-02 — ModelStreamingMode is presentation/performance configuration, not lifecycle authority

## 23. Physics / Network Ownership

TA-3 established client physics distrust.

TA-6 refines entity implications.

### PHYS-01 — Gameplay-critical world creature state is server-owned

### PHYS-02 — Unanchored creature/interaction physics cannot directly finalize value

### PHYS-03 — Server-owned or anchored interaction roots are preferred where feasible for critical contact points

### PHYS-04 — If clients simulate creature/character physics for responsiveness, authoritative gameplay validation remains server-side

### PHYS-05 — Touched alone never proves critical interaction

Server validates entity IDs, current lifecycle, spatial/context constraints and route state.

TA-9/TA-14 choose concrete physics ownership/performance tradeoffs.

## 24. Client Runtime Projection

The client may keep a projection cache:

```text
RuntimeEntityId -> presentation state/reference
```

### CLIENT-RUN-01 — Cache is disposable

Reconnect/snapshot/stream changes can rebuild it.

### CLIENT-RUN-02 — Cache never persists ownership truth

### CLIENT-RUN-03 — Projection events are revision-aware

Older events do not resurrect a terminated entity.

### CLIENT-RUN-04 — Local visual destruction is not a server command

## 25. Runtime State Projection

Server events may expose only presentation-safe state such as:

- entity ID;
- public content IDs;
- visible lifecycle/presentation state;
- public Variant cues when GDS requires them;
- current interaction availability category;
- runtimeRevision.

Hidden state remains server-only.

### STATEPROJ-01 — Projection fields are route/schema controlled

### STATEPROJ-02 — No raw server record replication

## 26. Entity Creation Transaction

Generic dynamic entity creation:

1. validate content/world context;
2. allocate RuntimeEntityId;
3. create complete server semantic record;
4. validate invariants;
5. register entity;
6. materialize projection;
7. attach disclosure-safe attributes/tags;
8. expose interaction/event projection;
9. mark Active.

### CREATE-01 — Failure before Active cleans partial resources

### CREATE-02 — Entity does not enter public population budget until the owning subsystem's defined registration/materialization boundary

TA-9 refines exact spawn-budget accounting.

## 27. Entity Destruction Transaction

Generic destruction:

1. mark Quiescing/Terminating;
2. reject new interactions;
3. cancel/hand off allowed in-flight work;
4. disconnect entity-scoped signals;
5. cancel entity-scoped tasks/timers;
6. remove interaction bindings;
7. destroy/detach projection;
8. deregister runtime entity;
9. publish terminal presentation event if needed;
10. release references.

### DESTROY-01 — Terminal transition is idempotent

Repeated cleanup calls must not duplicate rewards or error catastrophically.

### DESTROY-02 — Destroying projection and destroying entity are separate operations

### DESTROY-03 — Entity cleanup does not mutate persistent value unless an owning transaction explicitly says so

## 28. Cleanup Ownership

Every runtime object has exactly one cleanup owner.

That owner tracks:

- RBXScriptConnections;
- tasks/timers;
- child runtime objects;
- created Roblox Instances;
- registry bindings;
- projection subscriptions.

### CLEAN-01 — Connections are explicitly disconnected or safely destroyed with their owning object

### CLEAN-02 — Long-lived tables remove entity/player entries at terminal lifecycle

### CLEAN-03 — Cancellation tokens/generation checks protect delayed async work

### CLEAN-04 — No third-party cleanup framework is adopted in TA-6

TA-1 zero-runtime-package baseline remains.

## 29. Delayed Work and Stale Callbacks

### ASYNC-01 — Async work captures entity ID + expected generation/revision

### ASYNC-02 — Callback re-resolves authoritative entity before mutation

### ASYNC-03 — Callback against Destroyed/replaced entity becomes a no-op

### ASYNC-04 — Character-scoped callback checks characterGeneration

This prevents stale timers from affecting respawned players or replacement entities.

## 30. Timers

Runtime timers use server-controlled clock abstractions.

Examples:

- encounter idle lifetime;
- recovery delay;
- short interaction windows.

### TIMER-01 — Timer state belongs to the owning runtime entity/domain

### TIMER-02 — Client countdown is presentation only

### TIMER-03 — Expiry callback revalidates lifecycle before applying transition

TA-13/TA-14 refine clock/observability/performance.

## 31. World Static Runtime Index

At server bootstrap, TA-9 world authoring validation will build runtime indexes from TA-5 tags/attributes.

Conceptual:

```text
LandmarkId -> authored Instance
RecoveryAnchorId -> authored Instance
SpawnPointId -> authored Instance
SecurePointId -> authored Instance
TravelNodeId -> authored Instance
```

### STATIC-01 — Duplicate unique IDs fail validation

### STATIC-02 — Runtime lookup uses stable semantic IDs

### STATIC-03 — Static Instance destruction at runtime is handled as world integrity fault, not silent ID reassignment

## 32. Recovery Anchor Runtime Boundary

TA-6 provides structural behavior:

- current Character Presence becomes invalid/recovering;
- owning activity receives interruption notification;
- server resolves an eligible TA-9 Recovery Anchor;
- old character/projection lifecycle ends;
- new Character Presence materializes at validated recovery state.

### REC-01 — Recovery does not reload/reset persistent profile

### REC-02 — Recovery does not auto-secure Provisional Capture

### REC-03 — Recovery location cannot be client-authored

## 33. Server Shutdown

TA-2/TA-4 shutdown sequence applies.

TA-6 runtime shutdown:

1. stop generating/registering new dynamic world entities;
2. mark runtime registry draining;
3. hand in-flight acquisition/transactions to owning TAs;
4. terminate disposable world projections/entities;
5. preserve/flush only persistent outcomes through TA-4;
6. clean runtime connections/tasks;
7. allow Workspace/server process to end.

### SHUT-RUN-01 — Session-local World Creatures are not persisted just because shutdown begins

### SHUT-RUN-02 — Already finalized persistent Creature ownership remains protected by TA-4

## 34. Late Join

A late joining player:

- receives current authoritative session snapshot;
- sees currently surviving/streamed world entities according to Workspace streaming;
- receives no already-consumed finite outcome;
- may interact only with entities still Active/eligible.

### LATE-01 — Late join does not recreate expired World Creatures

### LATE-02 — Existing entity identity remains the same for all players

## 35. Runtime Population Ownership

TA-9 owns spawn scheduling/population budgets.

TA-6 provides lifecycle accounting hooks:

- registered;
- active;
- acquisition-protected;
- terminating;
- destroyed.

### POP-01 — Population accounting is based on authoritative runtime records, not client visibility

### POP-02 — Streamed-out entities still consume server population while alive

### POP-03 — Acquisition-protected entities cannot be reclaimed as idle capacity through despawn

## 36. Protected Variant Runtime Stability

GDS-9 requires a stability window.

TA-6 structural requirement:

### RARE-01 — Stability deadline is server-owned runtime metadata

### RARE-02 — Ordinary cleanup/lifetime logic cannot terminate before the applicable protected window unless an explicitly exceptional authoritative world condition permits it

### RARE-03 — Streaming out on one client does not shorten server lifetime

TA-9 sets exact time values/context.

## 37. Owned Projection States

For a Secured Creature projected into runtime:

```text
NotMaterialized
    ↓
Materializing
    ↓
Presented / ActiveRole / DisplayRole
    ↓
Dematerializing
    ↓
NotMaterialized
```

### OWN-LIFE-01 — Projection state is not collection ownership state

### OWN-LIFE-02 — Dematerialization never becomes Release

### OWN-LIFE-03 — Failed materialization leaves persistent creature intact

## 38. Event / Social Runtime Entities

TA-10 may create runtime entities for:

- Party session state;
- Event Instance;
- Event world overlay;
- Trade Session.

TA-6 generic requirements apply:

- stable server-generated runtime ID;
- explicit lifecycle;
- one owner;
- cleanup;
- revision;
- no persistent-value inference from projection existence.

TA-10 owns detailed state machines.

## 39. Error Containment

### ERR-RUN-01 — Projection failure does not corrupt semantic entity state

The server may retry materialization, hide interaction or terminate the opportunity according to owning rules.

### ERR-RUN-02 — Missing asset/model cannot fabricate a fallback semantic identity

### ERR-RUN-03 — Invalid runtime record fails closed before interaction

### ERR-RUN-04 — Cleanup error is logged and retried/best-effort without reviving terminal gameplay state

## 40. Observability

Runtime telemetry should support:

- entity kind;
- RuntimeEntityId correlation (sampled/hashed as privacy/volume requires);
- lifecycle state transition;
- runtimeRevision;
- creation/materialization latency;
- projection failures;
- lifetime/despawn reason;
- claim/acquisition-protected count;
- cleanup latency/leak indicators;
- stale command/callback rejection;
- Character generation/recovery reason;
- streaming-related client presentation misses where instrumented safely.

TA-13 defines final telemetry.

## 41. Performance Principles

### PERF-RUN-01 — Server record count is bounded by owning subsystem budgets

### PERF-RUN-02 — No one Heartbeat connection per entity by default

Prefer centralized schedulers/indexes where suitable.

### PERF-RUN-03 — Avoid expensive per-frame full-world scans

TA-9/TA-14 own spatial/scheduling design.

### PERF-RUN-04 — Projection detail may degrade without changing semantic state

LOD/streaming/visual simplification never changes ownership or outcome.

### PERF-RUN-05 — Pooling is projection-only if ever used

A pooled Model must be completely reset/rebound; semantic/runtime IDs are never pooled/reused.

TA-14 decides whether pooling is justified.

## 42. Testability

TA-15 must support deterministic lifecycle tests for:

- PlayerAdded before profile ready;
- ProtectedLoadFailure;
- CharacterAdded/Removing generations;
- reset/recovery;
- stale character callback;
- runtime entity create/active/destroy;
- projection materialization failure;
- stream-out/client missing model;
- stale runtimeRevision command;
- idle lifetime expiry;
- active acquisition protecting despawn;
- same creature returning to idle;
- secured transition preserving CreatureInstanceId;
- persistent projection destroy/re-materialize;
- duplicate cleanup;
- server shutdown with world entities;
- entity leak/connection cleanup.

## 43. Current Roblox Runtime Platform Snapshot

TA-6 reviewed official Roblox documentation current on 2026-09-18.

Confirmed platform facts include:

- Player exposes CharacterAdded and CharacterRemoving lifecycle events;
- Workspace instance streaming can stream Workspace descendants in/out independently of server entity truth;
- Atomic, Persistent and PersistentPerPlayer model streaming modes exist;
- Roblox explicitly says Persistent models are for rare cases and overuse can hurt performance;
- nearby clients may receive network ownership of unanchored assemblies;
- Roblox cannot verify client-side physics calculations for client-owned parts;
- Touched and other client-triggered interaction signals require server-side validation for critical outcomes;
- Roblox performance guidance emphasizes destroying/removing old characters/entities and disconnecting connections to avoid memory leaks.

Dated evidence is recorded in `TA6_ROBLOX_RUNTIME_LIFECYCLE_SNAPSHOT.md`.

## 44. Downstream Ownership

### TA-7

- detailed World Creature acquisition/capture substates;
- Variant Identity generation;
- claim ownership;
- Secured Ownership Finalization transaction.

### TA-8

- Active/Stored/Overflow owned-creature role projections;
- Vault runtime placement/materialization.

### TA-9

- runtime world hierarchy;
- spawn scheduler;
- spatial partition/indexing;
- StreamingEnabled strategy;
- encounter population/lifetime values;
- world physics/LOD.

### TA-10

- Party/Event/Trade runtime lifecycles.

### TA-12

- client projection cache/controllers;
- stream-in/out UI/feedback;
- character/camera/input presentation.

### TA-13

- runtime telemetry and live C2 config.

### TA-14

- runtime entity/Instance/connection/task/memory/frame budgets.

### TA-15

- lifecycle leak/fault/security tests.

### TA-17

- actual runtime entity interfaces/classes;
- exact Workspace container names;
- exact lifecycle API;
- cleanup helper implementation;
- character generation representation.

## 45. Open Questions

There are **zero TA-6-blocking open questions**.

Correctly downstream:

- exact creature capture substates — TA-7;
- exact Vault owned-projection roles — TA-8;
- spawn scheduler/spatial/streaming numbers — TA-9/TA-14;
- exact event/trade runtime entities — TA-10;
- client controllers — TA-12;
- implementation class names/APIs — TA-17.

## 46. Architecture-Complete Checklist

- [x] runtime entity taxonomy defined;
- [x] authoritative record vs Instance projection defined;
- [x] runtime registry defined;
- [x] generic entity lifecycle defined;
- [x] runtime revision defined;
- [x] Player Session lifecycle defined;
- [x] Character Presence/generation lifecycle defined;
- [x] character spawn/recovery/cleanup boundaries defined;
- [x] World Creature runtime record/lifecycle defined;
- [x] active acquisition blocks idle despawn structurally;
- [x] Secured Ownership transition runtime handoff defined;
- [x] persistent creature materialization defined;
- [x] runtime/network/persistent/claim ownership terms separated;
- [x] Workspace runtime container boundary defined;
- [x] interaction target binding defined;
- [x] client streaming tolerance defined;
- [x] physics/network ownership boundary defined;
- [x] client projection cache defined;
- [x] entity create/destroy transactions defined;
- [x] cleanup ownership and stale async protection defined;
- [x] timer/state revalidation defined;
- [x] static world runtime index defined;
- [x] Recovery lifecycle defined;
- [x] server-shutdown/late-join/population hooks defined;
- [x] Protected Variant stability runtime rule defined;
- [x] owned projection lifecycle defined;
- [x] error/observability/performance/testability defined;
- [x] current Roblox runtime/streaming behavior reviewed;
- [x] zero TA-6-blocking open questions.
