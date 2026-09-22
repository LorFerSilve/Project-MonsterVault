# TA-9 — World, Biomes, Spawn Scheduling, Streaming, and Encounter Scaling

> **Status:** Architecture Complete  
> **Owning TA phase:** TA-9 — World, Biomes, Spawn Scheduling, Streaming, and Encounter Scaling  
> **Authority:** Runtime world topology, world authoring index, biome/habitat/spawn-context representation, ordinary World Cycle synchronization, spawn scheduling, population budgets, encounter reservation/materialization, spatial indexing, StreamingEnabled integration, fast travel/recovery world validation, persistent world progression, world rewards, hazard detection/recovery integration, load-shedding and world observability  
> **Depends on:** TA-0 through TA-8 Architecture Complete; GDS-5, GDS-6, GDS-8, GDS-9, GDS-13, GDS-17

## 1. Purpose

TA-9 translates the Design Complete world contract into a server-authoritative Roblox architecture.

The contract is:

> **Static world structure is validated from typed content plus authored world metadata at server bootstrap. Ordinary encounter populations are session-local and created only by a centralized server scheduler using bounded area budgets. Every creature is generated through one stable spawn reservation that fixes content snapshot, Spawn Context, Species and TA-7 Variant Identity before materialization, so retries and streaming never reroll the same logical creature. Population scaling changes opportunity count within authored bounds but never creates per-player or spending-based rarity odds. Workspace streaming is enabled as a performance/presentation mechanism, never as authority. Persistent landmarks, objectives, mastery and world Energy rewards commit through exact-once Player Profile operations. Under load, MonsterVault reduces ordinary refill work before weakening fairness, acquisition stability or protected-variant guarantees.**

No gameplay Luau modules are implemented in TA-9. Gameplay implementation remains blocked until TA-17.

## 2. Domain Ownership

TA-9 owns:

- launch runtime representation of the Home Hub and field Biomes;
- Region, Habitat, Safe Outpost, utility-point and Spawn Context runtime views;
- validated World Authoring Index;
- ordinary World Cycle phase calculation;
- ordinary session-local spawn scheduling;
- encounter population reservations and accounting;
- server-side spawn placement eligibility;
- ordinary encounter lifetime integration;
- server-side spatial index for world scheduling;
- instance-streaming architecture and streaming-safe world assumptions;
- region/travel-node/recovery-anchor validation;
- Landmark Discovery and ordinary Field Objective technical completion;
- Region Mastery evaluation/orchestration;
- exact-once world reward operation identities;
- hazard-zone runtime detection and recovery handoff;
- world load-shedding/degradation order;
- world/spawn diagnostics and telemetry contracts.

TA-9 does not own:

- semantic player-facing world rules — GDS-9;
- claim/capture/transport/finalization state — TA-7;
- Access Unlock purchase transactions — TA-8;
- social allocation, parties or PvP — TA-10;
- server events/rifts/cross-server event coordination — TA-10;
- Marketplace entitlements — TA-11;
- final map/HUD/presentation/accessibility — TA-12;
- live configuration rollout infrastructure — TA-13;
- exact frame/memory/instance/query/network budgets — TA-14;
- final test/CI implementation — TA-15;
- concrete module/API/file names — TA-17.

## 3. Launch Place and World Boundary

TA-1 established one primary gameplay place per environment as the launch baseline.

TA-9 keeps the launch world in that primary place.

### PLACE-09-01

Home Hub, Starter Biome, both Mid Biomes and Advanced Biome are logical Regions inside one gameplay place at baseline.

### PLACE-09-02

Ordinary region progression never depends on TeleportService or a second place.

### PLACE-09-03

A future multi-place world requires architecture change control because encounter lifetime, transport, recovery and authority semantics would cross a new process boundary.

## 4. Static World Definition

TA-9 consumes TA-5 typed registries.

Conceptually:

- RegionDefinition;
- HabitatDefinition;
- LandmarkDefinition;
- TravelNodeDefinition;
- SafeOutpostDefinition;
- RecoveryAnchorDefinition;
- SecurePointDefinition;
- VaultAccessPointDefinition;
- HazardDefinition;
- SpawnContextDefinition;
- SpawnVolume/SpawnAnchorDefinition;
- FieldObjectiveDefinition;
- WorldCycleDefinition.

Each definition uses stable semantic IDs and validated references.

Exact schemas remain TA-17.

## 5. World Authoring Index

World geometry/placement is authored in Studio and linked to semantic definitions through TA-5-approved tags/attributes.

At server bootstrap, TA-9 builds one immutable **World Authoring Index**.

Conceptually it maps:

- RegionId -> authored region bounds/entry relationships;
- HabitatId -> region + spawn volumes + hazard relations;
- LandmarkId -> validated discovery volume;
- TravelNodeId -> destination/safe-arrival anchor;
- SecurePointId -> extraction location metadata;
- RecoveryAnchorId -> safe recovery transform;
- SpawnContextId -> eligible authored spawn volumes/anchors;
- HazardId -> server validation volume/category.

### AUTHOR-09-01

Workspace object names and hierarchy paths are not semantic IDs.

### AUTHOR-09-02

Unknown IDs, duplicate unique utilities, missing required outposts, impossible region references, overlapping prohibited safe/hazard roles or orphan Spawn Contexts fail bootstrap closed.

### AUTHOR-09-03

Hidden spawn weights, private reward tables and anti-abuse thresholds never live in replicated Attributes.

## 6. Bootstrap Order

World bootstrap follows TA-2 lifecycle ordering:

1. load/validate TA-5 registries;
2. discover tagged authored instances;
3. validate required IDs/attributes;
4. construct immutable World Authoring Index;
5. validate launch topology and utility invariants;
6. construct World Runtime Service;
7. construct spatial/population indexes;
8. construct ordinary World Cycle clock;
9. construct spawn scheduler;
10. only after dependencies report Ready may player world interactions and ordinary spawning begin.

No world service starts long-lived work during module import.

## 7. Runtime World State

TA-9 session state is server-local.

Conceptually:

- current ordinary World Cycle projection;
- scheduler state;
- active Habitat/area population counters;
- pending Spawn Reservations;
- active CreatureInstanceIds by population bucket;
- world objective instances;
- transient hazard occupancy state;
- transient spatial cells;
- diagnostics/backpressure state.

Ordinary encounter state is not written to player DataStores.

## 8. Region Access Authority

Persistent Access Unlocks remain TA-8 profile state.

### ACCESS-09-01

Any server action whose semantic target is inside a gated Region re-validates the player's current region entitlement/prerequisites as applicable.

### ACCESS-09-02

Client position, streamed geometry, local teleportation or visibility never grants region authority.

### ACCESS-09-03

If a character reaches a locked region through exploit, physics error or geometry escape, valuable interactions fail closed and the server may recover the player to a valid unlocked Recovery Anchor.

### ACCESS-09-04

Enforcement is state-protective, not punitive by default; impossible movement is recorded for diagnostics/security correlation.

## 9. Persistent World Progression Shape

TA-9 extends the TA-4 Player Profile conceptually with bounded world progression:

- discoveredLandmarks;
- discoveredTravelNodes;
- completed one-time Field Objectives;
- bounded repeatable-objective dedupe/progress state;
- per-region Core Species secured evidence;
- Region Mastery milestones;
- world reward operation/dedupe records shared with TA-4/8.

Exact serialization is TA-17.

### PROGRESS-09-01

Historical world progression is persistent; public encounter population is not.

### PROGRESS-09-02

Releasing or trading a creature does not revoke historical Region Mastery evidence already legitimately earned.

## 10. Landmark Discovery

Landmark Discovery is server-resolved.

A valid discovery requires:

- Persistence Ready and Active Character Presence;
- known LandmarkId from the World Authoring Index;
- server-observed character location inside the validated discovery volume;
- Region access valid;
- landmark not already finalized for that player.

### LANDMARK-09-01

Client Touched/proximity claims are hints only.

### LANDMARK-09-02

First-discovery persistence and any attached first-time Energy reward commit atomically as one stable P2 operation.

### LANDMARK-09-03

Duplicate trigger delivery returns the already-finalized result without a second reward.

## 11. Regional Collection Evidence

When TA-7 finalizes a Secured Creature whose world provenance qualifies for a Region's Core Species set, TA-9 world progression may attach the region-specific historical collection evidence to the same Player Profile commit.

### REGION-COLLECT-01

The evidence is keyed by RegionId + SpeciesId, not current ownership count.

### REGION-COLLECT-02

One species secured repeatedly in the same region contributes once to the distinct Core Species threshold.

### REGION-COLLECT-03

A creature from a non-qualifying Spawn Context cannot be relabeled by the client as regional evidence.

## 12. Field Objective Runtime

Ordinary Field Objectives have server-owned semantic definitions and explicit ObjectiveInstanceId when an instance identity is required.

Objective progress may be:

- P0 while purely session-local and non-valuable;
- checkpointed/P1 where loss is acceptable but should be minimized;
- P2 at final completion when it grants persistent completion, Energy or a progression prerequisite.

### OBJECTIVE-09-01

Presence alone is never sufficient unless the authored objective explicitly defines a bounded route/volume sequence requiring active traversal.

### OBJECTIVE-09-02

Repeatable objective rewards require a new valid ObjectiveInstanceId and a bounded dedupe history.

### OBJECTIVE-09-03

Objective generation does not become an event system; server-wide event cadence remains TA-10.

## 13. Region Mastery Finalization

Region Mastery is evaluated from authoritative persistent evidence:

- required Route Survey landmarks;
- distinct eligible regional Core Species secured evidence;
- required Field Objective completion.

### MASTERY-09-01

Mastery is server-derived; the client cannot submit a completion boolean.

### MASTERY-09-02

When prerequisites transition from incomplete to complete, Region Mastery finalizes as one idempotent P2 milestone operation, including any authorized one-time reward.

### MASTERY-09-03

Later content expansion never clears a finalized mastery record.

## 14. Ordinary World Cycle

The baseline World Cycle is deterministic across servers.

TA-9 defines a fixed cycle epoch plus versioned cycle definition.

Conceptually:

phaseOffset = max(0, serverUnixSeconds - cycleEpochUnixSeconds) modulo cycleDurationSeconds

The phase is selected from ordered phase ranges.

### CYCLE-09-01

Server wall time is the authority; the client clock is irrelevant.

### CYCLE-09-02

Joining a new server does not reset the cycle.

### CYCLE-09-03

A cycle-definition update is prospective/versioned. Existing Creature Instances keep their generated Spawn Context/identity.

### CYCLE-09-04

The ordinary World Cycle requires no cross-server MemoryStore coordinator at baseline.

## 15. Spawn Context Evaluation

A new ordinary encounter can be generated only from a validated Spawn Context.

The server evaluates:

- Region/Habitat;
- current ordinary World Cycle phase;
- static zone eligibility;
- content availability;
- authored population/lifetime envelope;
- future modifiers only when an upstream owner explicitly authorizes them.

### SPAWNCTX-09-01

Paid state, Energy balance, spend propensity, recent refusal, device tier and individual monetization history are prohibited inputs to collectible odds.

### SPAWNCTX-09-02

Player count/performance may affect how many ordinary opportunities exist, not the hidden Species/Variant distribution for a given context.

## 16. Central Spawn Scheduler

MonsterVault uses one server-owned ordinary spawn scheduler coordinator, partitioned by Habitat/area work queues.

There is no independent permanent loop per spawn point or per creature.

A scheduler pass:

1. selects a bounded subset of due population buckets;
2. reads current active/reserved count;
3. computes desired count within authored min/base/max envelope;
4. applies allowed load/backpressure reduction;
5. determines bounded deficit;
6. creates at most the allowed number of Spawn Reservations;
7. defers remaining refill work to later passes.

### SCHED-09-01

Scheduler work is staggered rather than synchronized across all habitats.

### SCHED-09-02

Exact cadence, per-pass work and time budget are TA-14/17 values.

### SCHED-09-03

No Heartbeat callback scans the whole world or all spawn anchors every frame.

## 17. Encounter Population Budget

Each population bucket belongs to one Region/Habitat/Spawn Context grouping with validated bounds.

Conceptually:

desiredPopulation = clamp(basePopulation + populationScale(activeEligiblePlayers), minPopulation, maxPopulation)

A performance/backpressure factor may reduce ordinary desired population toward the validated minimum.

### POP-09-01

Population can never grow above maxPopulation due to player joins or retries.

### POP-09-02

Pending Spawn Reservations count against the budget immediately, preventing oversubscription races.

### POP-09-03

Protected onboarding opportunities use their own reserved mechanism and do not depend on ordinary public deficit competition.

### POP-09-04

Population scaling never changes a player's personal rarity table.

## 18. Active Population Buckets

A field population bucket may be **Dormant** when no relevant ready players are near/inside its activation envelope.

Dormant areas need not maintain full ordinary population.

### ACTIVE-09-01

Activation is an optimization only; it does not change persistent access, World Cycle or content identity rules.

### ACTIVE-09-02

When an area becomes active, refill is bounded/staggered rather than burst-spawning the full deficit in one frame.

### ACTIVE-09-03

Deep/rare pockets may have deliberately lower ordinary populations within authored GDS-9 pacing semantics.

## 19. Spatial Index

TA-9 maintains server-side spatial buckets for scheduling queries that do not need physics-engine scans.

Static authored spawn/utility data is pre-indexed at bootstrap.

Dynamic relevant state may be indexed by coarse world cell:

- active Character Presence;
- active world creatures;
- reserved spawn placements;
- exceptional runtime hazards/objectives.

### SPATIAL-09-01

Cell size and update cadence are TA-14/17 performance parameters.

### SPATIAL-09-02

The spatial index is an optimization, not semantic authority; exact final validations may query current runtime state/physics.

## 20. Spawn Placement Validation

Spawn placement is server-owned.

Candidate placement comes from a validated Spawn Volume/Anchor tied to the selected Spawn Context.

Before materialization, the server can validate:

- candidate inside allowed authored volume;
- not inside Safe Outpost exclusion;
- required ground/clearance constraints;
- bounded overlap occupancy;
- no invalid region/hazard role combination;
- configured distance envelope from active players where required for readability/fairness.

Localized WorldRoot raycasts/overlap queries may be used.

### PLACE-09-01B

The scheduler never trusts a client-provided spawn position.

### PLACE-09-02B

A failed placement check does not reroll a previously selected Creature identity; it retries placement for the same Spawn Reservation within bounded rules.

## 21. Spawn Reservation

Before a logical creature becomes actionable, the scheduler creates one server-owned **Spawn Reservation**.

Conceptually it contains:

- SpawnReservationId;
- selected SpawnContextId;
- ContentSnapshotId/config epoch;
- RegionId/HabitatId;
- selected authored placement scope;
- server generation time;
- CreatureInstanceId;
- SpeciesId;
- complete TA-7 Variant Identity;
- encounter lifetime class;
- Protected Variant stability classification;
- reservation/runtime revision.

### RESERVE-09-01

Population capacity is reserved before materialization.

### RESERVE-09-02

Species and Variant Identity are generated once for the reservation.

### RESERVE-09-03

Materialization retries reuse the same reservation and identity.

### RESERVE-09-04

A new random outcome is allowed only after the prior reservation genuinely terminates and a later independent spawn operation begins.

## 22. Randomness Boundary

TA-7 owns server RNG and Variant generation.

TA-9 owns when a new Spawn Reservation is entitled to request generation.

Generation order:

1. resolve eligible Species weighted table for the Spawn Context snapshot;
2. select Species using server RNG;
3. allocate CreatureInstanceId;
4. invoke TA-7 Variant generation exactly once with the same context/snapshot;
5. store the complete logical identity in the reservation/runtime record;
6. materialize the Roblox projection.

### RNG-09-01

Projection failure, client stream-out, claim failure and ordinary travel never invoke Variant generation again for the same CreatureInstanceId.

## 23. Materialization and Runtime Registration

A reservation becomes an active World Creature through the TA-6 runtime lifecycle.

### MATERIALIZE-09-01

The authoritative runtime record is registered before/with projection activation so the Roblox Model never becomes the only source of truth.

### MATERIALIZE-09-02

If projection creation fails transiently, bounded retry uses the same logical creature.

### MATERIALIZE-09-03

If the reservation must be abandoned after bounded technical failure, cleanup releases its population slot and records the failure reason.

### MATERIALIZE-09-04

Technical materialization failure must not be intentionally exploited as a rarity reroll path.

## 24. Encounter Lifetime

Ordinary idle lifetime is measured from server-authoritative monotonic session time.

### LIFE-09-01

Unclaimed ordinary creatures may expire at their authored lifetime.

### LIFE-09-02

TA-7 acquisition states protect the creature from ordinary idle despawn.

### LIFE-09-03

A Protected Variant cannot idle-expire before its Rare Encounter Stability Window has elapsed.

### LIFE-09-04

Stream-out from every client does not itself terminate the server runtime record.

### LIFE-09-05

Termination frees population accounting exactly once.

## 25. Protected Variant Stability

Protected Variant stability is a scheduler/lifecycle invariant.

A protected encounter has a server-owned not-before-despawn boundary.

Load shedding may defer future ordinary spawning, but cannot shorten an already-active protected encounter below that boundary.

Active acquisition protection remains stronger where TA-7 requires it.

## 26. Streaming Baseline

TA-9 adopts **Workspace StreamingEnabled = true** for the gameplay place baseline.

Reasons:

- launch/future world scalability;
- client memory pressure;
- join-time scalability;
- avoiding an architecture that assumes the entire Workspace is always resident.

Exact streaming radii/integrity settings are TA-14/17 measured configuration.

### STREAM-09-01

Client Workspace visibility is never authority for access, ownership, spawn existence, rewards or claim state.

### STREAM-09-02

Client code must tolerate relevant world Instances streaming in and out.

### STREAM-09-03

Client startup code must not require a complete scan of Workspace to construct semantic world state.

## 27. Model Streaming Policy

Default policy:

- ordinary static environment: Default streaming behavior;
- self-contained interaction models that must appear atomically when present: Atomic where justified;
- globally Persistent models: exceptional and minimized;
- PersistentPerPlayer: allowed narrowly for a player-specific active interaction/custody projection when evidence shows it is necessary.

### MODEL-STREAM-09-01

Persistent streaming modes do not make a Model authoritative.

### MODEL-STREAM-09-02

An encounter remains logically alive even if its projection is absent on one client.

### MODEL-STREAM-09-03

TA-14 measures memory/network impact before widening Persistent use.

## 28. Fast Travel

Fast travel is an explicit server command.

Validation includes:

- active Player Session/Profile;
- valid Character Presence generation;
- destination TravelNodeId exists;
- destination node discovered;
- destination Region unlocked;
- no TA-7 Acquisition-In-Progress state;
- no conflicting recovery/transition operation;
- command freshness/rate limit.

On success:

1. resolve the server-owned safe destination transform;
2. optionally request target-area streaming for the player;
3. perform a controlled character relocation;
4. clear unsafe residual velocity/state as required;
5. confirm the authoritative resulting Region/anchor.

### TRAVEL-09-01

Streaming preparation is best-effort presentation/readiness support, not authorization.

### TRAVEL-09-02

Travel never resets Spawn Reservations, surviving Creature identity or World Cycle.

### TRAVEL-09-03

A timeout while preparing streaming never mints/refunds value or bypasses acquisition restrictions.

## 29. Safe Arrival and Recovery

TA-6 owns generic recovery lifecycle; TA-9 provides valid world anchors.

Recovery anchor selection:

1. reject locked/inactive/invalid anchors;
2. prefer current Region valid safe anchor when semantically allowed;
3. otherwise fall back through known unlocked safe hierarchy;
4. Home Hub safe arrival is the final baseline fallback after Persistence Ready.

### RECOVERY-09-01

Recovery never acts as Extraction Completion.

### RECOVERY-09-02

An anchor cannot be located inside a Hazard Zone or inaccessible Region.

### RECOVERY-09-03

Client-provided CFrame is never used as the recovery target.

## 30. Secure Point and Vault Access Validation

TA-9 world index resolves utility-point identity and geometry; TA-7/8 retain semantic transaction authority.

### UTILITY-09-01

A Secure Point interaction validates exact point identity, player location/presence and Region availability before TA-7 extraction logic.

### UTILITY-09-02

A Vault Access Point may expose already-secured Vault management but cannot convert provisional custody into ownership.

### UTILITY-09-03

Utility points inside streamed-out client geometry remain server-known; missing local projection cannot create or remove permission.

## 31. Hazard Runtime Architecture

Hazards are server-authored semantic volumes/categories.

Critical hazard consequence is not finalized from a client message or a single client-owned physics event.

TA-9 may combine:

- server-observed character transform;
- bounded spatial/overlap checks;
- server physics signals as hints;
- explicit hazard timers/state machines.

### HAZARD-09-01

Touched is never the sole authority for a valuable or progression-affecting consequence.

### HAZARD-09-02

Hazard state is idempotent per Character generation to avoid duplicate recovery from repeated contacts.

### HAZARD-09-03

Hazards route acquisition interruption to TA-7 rather than inventing a second ownership state machine.

### HAZARD-09-04

Secured collection/Energy/unlocks are never deleted by hazard recovery.

## 32. Streaming-Safe Client Projection

TA-12 will own presentation, but TA-9 requires the data boundary:

- replicated world metadata is disclosure-safe;
- authoritative server events/snapshots use semantic IDs;
- clients may cache streamable projections by stable ID;
- stream-out removes a projection, not semantic truth;
- late stream-in can reconstruct presentation from current replicated state.

No client-side hidden spawn table is required for correctness.

## 33. Load Shedding

When server world work exceeds the later TA-14 budget, degradation order is:

1. defer non-urgent scheduler buckets;
2. reduce refill toward authored minimum populations;
3. reduce optional AI/cosmetic update frequency;
4. defer non-critical diagnostics aggregation;
5. preserve active acquisition, protected stability, P2 progression and safety validation.

### SHED-09-01

Load shedding never increases rare odds to compensate for fewer spawns.

### SHED-09-02

Load shedding never force-despawns active acquisition.

### SHED-09-03

Load shedding never shortens an existing Protected Variant below minimum stability.

### SHED-09-04

Load shedding never disables access/security validation.

## 34. Server Population Changes

Player join/leave may alter desired ordinary population within authored bounds.

### SCALE-09-01

Scaling changes are gradual/staggered.

### SCALE-09-02

If desired count falls, ordinary idle encounters may age out naturally; the scheduler does not select valuable identities for immediate deletion based on rarity.

### SCALE-09-03

Protected/acquired encounters remain governed by stability/lifecycle rules.

## 35. Failure Semantics

### FAIL-09-01

Invalid world authoring prevents Ready rather than silently omitting required progression paths.

### FAIL-09-02

Scheduler exception does not corrupt persistent player value; the affected bucket can pause and report unhealthy.

### FAIL-09-03

Spawn reservation cleanup is idempotent.

### FAIL-09-04

A lost client world event is repaired by current authoritative state/snapshot, not replayed as a second value grant.

### FAIL-09-05

Persistent world progression failure returns unknown/pending/reconcile semantics under TA-4 rather than assuming failure and granting again.

## 36. No Baseline Cross-Server Spawn Coordinator

Ordinary session-local encounters do not require MemoryStoreService, MessagingService or a global rare-spawn ledger.

The deterministic World Cycle provides cross-server phase consistency without centralized encounter ownership.

TA-10 may introduce cross-server coordination only for explicitly designed event/live-content requirements.

## 37. Content and Config Evolution

TA-9 classifies:

- topology/semantic region relations: C1 / change-controlled;
- Species pools and Spawn Context definitions: C1 by default;
- approved spawn weights/density/lifetime/cycle timings: C2 candidates only after TA-13 defines safe overlay;
- player-facing invariant rules: C0.

### CONFIG-09-01

New config snapshots affect future Spawn Reservations prospectively.

### CONFIG-09-02

Existing World Creatures keep their pinned generation identity/context.

### CONFIG-09-03

Population target changes never retroactively delete secured value.

## 38. Security Boundary

The client may request:

- fast travel;
- world interaction;
- objective interaction;
- capture/claim commands owned downstream.

The server derives/validates:

- player/character identity;
- position/context;
- region entitlement;
- target semantic ID;
- target runtime existence/revision;
- distance/line-of-play constraints where relevant;
- current objective/acquisition state;
- operation freshness/rate limits.

Impossible requests are rejected before any valuable mutation.

## 39. Performance Principles

Before TA-14 exact budgets, TA-9 locks qualitative architecture:

- no global per-frame Workspace scans;
- no one-coroutine-per-spawn-point scheduler;
- no one-Heartbeat-per-creature lifetime timers;
- use monotonic deadlines and indexed due work;
- use static authoring indexes;
- use coarse spatial buckets for candidate reduction;
- use localized raycast/overlap checks only after candidate narrowing;
- batch/stagger scheduler work;
- allow dormancy for inactive areas;
- use instance streaming rather than globally Persistent map content;
- clean all runtime/reservation references idempotently.

## 40. Observability

World diagnostics must support at least:

- population count by Region/Habitat/Spawn Context;
- pending reservations;
- spawn attempts/success/placement failures;
- scheduler lag/backlog;
- ordinary vs Protected Variant lifetime outcomes;
- termination reasons;
- claim-protected despawn suppressions;
- area activation/dormancy;
- load-shedding level;
- fast-travel rejection reason;
- invalid region-entry/recovery cases;
- Landmark/Objective/Mastery P2 outcome;
- streaming-preparation timeout count;
- bootstrap authoring validation failures.

Logs use IDs/reason codes and avoid full player profiles.

## 41. Testability Hooks

TA-9 architecture requires injectable abstractions for:

- clock;
- server RNG consumed through TA-7;
- World Cycle definition;
- content snapshot;
- scheduler cadence/backpressure signal;
- spawn placement validator;
- spatial index;
- streaming-preparation adapter;
- profile transaction adapter.

This permits deterministic simulation without requiring live Studio timing for every case.

## 42. Downstream Handoffs

### TA-10

Consumes TA-9 Region/Habitat/Spawn Context/runtime population primitives for parties, server events, dynamic encounter overrides, shared allocation and any justified cross-server coordination.

### TA-11

May attach verified commercial convenience only within GDS-13 boundaries; cannot feed hidden spawn odds or bypass region authority.

### TA-12

Builds map/HUD/hazard/rare-cue and streaming-safe presentation from semantic world projections.

### TA-13

Owns live C2 rollout, spawn-weight/density/cycle epochs and analytics/experiment infrastructure.

### TA-14

Locks exact scheduler cadence, spatial cell size, population ceilings, streaming radii, query counts, instance/memory/server-time budgets and degradation thresholds.

### TA-15

Implements deterministic scheduler/property/fault/security/streaming tests and CI evidence.

### TA-16

Cross-validates TA-9 with events, trading, monetization, UI, live ops and performance.

### TA-17

Locks concrete modules, schemas, routes, tags/attributes, enum values and implementation order.

## 43. Critical Invariants

1. World access and valuable interactions are server-authoritative.
2. Ordinary public encounters are session-local.
3. The World Cycle does not reset per server/player join.
4. Population scaling changes count, not personalized odds.
5. A Spawn Reservation fixes one logical creature identity exactly once.
6. Materialization/streaming retries never reroll the creature.
7. Active acquisition blocks ordinary idle despawn.
8. Protected Variant minimum stability survives load shedding.
9. Streaming is never gameplay authority.
10. Persistent world progress/rewards are exact-once P2 at finalization.
11. Hazards cannot destroy secured value.
12. No baseline global/cross-server coordinator is required for ordinary spawns.

## 44. Open Questions

There are **zero TA-9-blocking open questions**.

Correctly downstream/tuneable:

- exact map dimensions and coordinates — content/TA-17;
- exact spawn counts, scheduler cadence and cell size — TA-14/17;
- exact StreamingMinRadius/StreamingTargetRadius/integrity mode — TA-14/17 measured settings;
- exact model StreamingMode assignments — TA-17 after content/performance validation;
- exact objective catalogs and Energy quantities — approved content/GDS bounds;
- live weight/density/cycle rollout — TA-13;
- event Spawn Context modifiers — TA-10;
- final client map/rare/hazard cues — TA-12.

## 45. Architecture-Complete Checklist

- [x] launch place/world boundary explicit;
- [x] static world definition and authoring index explicit;
- [x] region access authority explicit;
- [x] persistent world progression path explicit;
- [x] deterministic cross-server World Cycle explicit;
- [x] centralized bounded spawn scheduler explicit;
- [x] population scaling/fairness boundary explicit;
- [x] spawn placement and spatial index explicit;
- [x] stable Spawn Reservation/anti-reroll path explicit;
- [x] encounter lifetime and protected stability explicit;
- [x] StreamingEnabled architecture and streaming-safe client assumptions explicit;
- [x] fast travel/recovery/utility validation explicit;
- [x] hazard authority explicit;
- [x] load shedding/failure semantics explicit;
- [x] observability/testability explicit;
- [x] downstream ownership explicit;
- [x] no implementation-critical TA-9 questions remain.
