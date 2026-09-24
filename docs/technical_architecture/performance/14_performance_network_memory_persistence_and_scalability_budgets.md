# Performance, Network, Memory, Persistence, and Scalability Budgets

> **Status:** Architecture Complete — PASS  
> **Owning TA phase:** TA-14  
> **Date:** 2026-09-24  
> **Authority:** Cross-system numeric budgets, headroom, saturation behavior, degradation order, reference load classes and performance observability  
> **Depends on:** TA-0 through TA-13

## 1. Purpose

TA-0 through TA-13 define what MonsterVault must do and which subsystem owns every consequential state transition. TA-14 defines how much compute, memory, network, persistent-service capacity and cross-server capacity those contracts are allowed to consume.

The central rule is:

> **Performance pressure may reduce optional work, fidelity, freshness or population toward already-approved minima, but it may never weaken authority, exact-once behavior, value preservation, validation, accessibility-critical meaning, safety checks or durable recovery.**

TA-14 therefore separates:

1. **Roblox platform ceilings** — external service/engine limits that MonsterVault does not control;
2. **MonsterVault targets** — normal operating objectives;
3. **warning thresholds** — observability and early-degradation thresholds;
4. **hard architecture guardrails** — values beyond which new optional work is rejected/deferred or a release is blocked.

MonsterVault intentionally does not design to consume Roblox ceilings.

## 2. Scope

TA-14 owns numeric architecture budgets for:

- server frame/heartbeat work;
- client frame behavior and local response;
- server memory and client-memory stability;
- runtime entity, Instance, connection and task growth;
- streaming and join-time configuration;
- RemoteEvent/UnreliableRemoteEvent payload and rate envelopes;
- DataStore profile size, request scheduling, lease/autosave/retry and throughput headroom;
- MemoryStore and MessagingService use;
- world scheduling, spatial queries and encounter scaling;
- collection/storage technical maxima required to keep one-profile atomicity viable;
- trade/event/commerce recovery work;
- UI virtualization, timers, notifications and preference persistence;
- telemetry/config/experiment overhead;
- reference occupancy/load scenarios;
- load shedding and performance observability.

TA-14 does **not** redefine:

- player-facing gameplay semantics from the GDS;
- persistent authority from TA-4/7/8/10/11;
- networking trust from TA-3;
- spawn/reward/rarity semantics from TA-7/9/10;
- client accessibility meaning from TA-12;
- analytics/config authority from TA-13;
- executable performance/fault/security test harnesses — TA-15;
- concrete module/file/service names and final implementation constants where a measured device/content result must select among an allowed TA-14 range — TA-17.

## 3. Budget Vocabulary

Every budget is classified as one of:

| Level | Meaning | Required behavior |
|---|---|---|
| Target | Expected steady-state operating envelope | no degradation required |
| Warning | Sustained pressure is visible and actionable | shed/defer low-priority work and emit bounded diagnostics |
| Hard guardrail | Architecture envelope exceeded | stop admitting optional work; preserve correctness; release cannot ship while reproducible |
| Platform ceiling | External Roblox limit | MonsterVault must retain material headroom below it |

A **sustained** runtime threshold means the metric remains above the threshold for at least 10 seconds unless a domain-specific table states otherwise. One isolated spike is recorded but does not by itself rewrite gameplay state.

## 4. Reference Load Classes

All TA-15 validation must include:

- **L0 — Solo:** 1 player;
- **L1 — Half occupancy:** ceil(0.5 × configured MaxPlayers);
- **L2 — Full occupancy:** configured MaxPlayers;
- **L3 — Full + burst:** L2 plus bounded simultaneous capture/social/event/UI/telemetry activity;
- **L4 — Recovery:** L2 while persistence/network/cross-server dependencies are throttled or retrying;
- **L5 — Long session:** at least 60 minutes of representative traversal, collection UI, event and social activity for leak detection.

No budget is considered validated only from Studio. Client frame/memory gates require real Roblox client/device evidence.

## 5. Server Compute Budget

Roblox server heartbeat is capped at 60 Hz, so the full server frame has a 16.67 ms envelope.

MonsterVault budgets the frame as follows:

| Metric | Target | Warning | Hard guardrail |
|---|---:|---:|---:|
| Server frame p95 | <= 16.67 ms | > 16.67 ms | > 25 ms sustained |
| MonsterVault script-owned CPU p95 / frame | <= 6 ms | > 8 ms | > 10 ms sustained |
| One scheduled bulk-work pass | <= 2 ms p95 | > 3 ms | > 4 ms |
| One cooperative chunk before yield/split | <= 1 ms | > 1.5 ms | > 2 ms |
| Full-world scans in per-frame callbacks | 0 | 0 | 0 |

Rules:

- critical validation/P2 work is not skipped to recover frame time;
- scheduler work is indexed and deadline-driven;
- non-urgent work may be deferred across frames;
- optional AI/cosmetic frequency is reduced before authoritative work;
- one subsystem may not silently consume unused budget of another without observability attribution.

## 6. Client Frame and Responsiveness Budget

Client correctness cannot require a frame rate above 30 FPS.

Reference gates:

| Class | Gate |
|---|---|
| Minimum supported / low-end mobile reference | p95 frame <= 33.33 ms (>=30 FPS) |
| Reference mobile/tablet | target p95 <= 16.67 ms |
| Reference console | target p95 <= 16.67 ms |
| Reference desktop | target p95 <= 16.67 ms |
| Any supported device | no reproducible OOM or deterministic >500 ms UI/main-thread stall from MonsterVault work |

Presentation response:

- local button/input acknowledgement must occur by the next rendered frame when the client is responsive;
- a consequential command immediately enters Pending locally; success is never fabricated;
- under the TA-15 controlled reference network, non-cloud authoritative command accept/reject should return p95 <= 250 ms;
- cloud-backed operations may exceed 250 ms but must remain explicitly Pending/OutcomeUnknown rather than freezing the UI.

## 7. Server Memory Budget

Roblox recommends keeping server memory below 50% of the memory available to the server.

MonsterVault uses:

| Metric | Target | Warning | Hard action |
|---|---:|---:|---|
| Total server memory | <=40% | >45% | >=50%: stop optional admission/load-shed |
| Unbounded server-local collections | 0 | 0 | 0 |
| Runtime records without lifecycle owner | 0 | 0 | 0 |
| Connections/tasks without cleanup owner | 0 | 0 | 0 |

At >=45%:

1. stop optional prewarming/caches from growing;
2. shrink disposable caches;
3. reduce optional world population toward authored minima;
4. reduce cosmetic/diagnostic work;
5. preserve active acquisition, P2 work, safety and recovery.

## 8. Client Memory Stability Budget

Roblox does not expose one portable memory ceiling that is valid across all supported client devices, so TA-14 uses absolute failure gates plus measured warm-baseline deltas.

For each reference device:

- record **Mwarm** after five minutes of representative play;
- during a 30-minute traversal/UI/event loop, total client memory must stay <= max(Mwarm + 128 MiB, 1.15 × Mwarm) after initial content discovery has stabilized;
- after returning to the starting content set and allowing normal cleanup, memory must return to <= max(Mwarm + 64 MiB, 1.08 × Mwarm);
- a reproducible out-of-memory crash on a supported device is a hard failure;
- a production client-crash regression reaching 2% requires release-blocking investigation until MonsterVault contribution is excluded or corrected.

Asset/content memory is measured separately from Luau heap/Instances so content regressions are attributable.

## 9. Runtime Entity and Instance Budgets

Architecture maxima:

- <=256 simultaneously Active ordinary World Creature runtime entities server-wide;
- <=512 simultaneously Active MonsterVault runtime interactable records server-wide, excluding player/character engine objects;
- <=16 Persistent/PersistentPerPlayer streamed models visible to one client without explicit TA change; target <=8;
- ordinary runtime entities use one cleanup owner;
- no one-task-per-spawn-anchor or one-Heartbeat-per-creature pattern;
- no cache may grow directly with session duration without an eviction/retention bound.

If authored content requires more than these ceilings, TA-14 must be reopened with TA-15 evidence before TA-17 may lock implementation.

## 10. Streaming and Join Configuration

Baseline Workspace streaming architecture:

- StreamingEnabled: enabled;
- StreamingMinRadius: **64**;
- StreamingTargetRadius: **1024**;
- StreamingIntegrityMode: **PauseOutsideLoadedArea**;
- StreamOutBehavior: **Opportunistic**;
- Persistent models: rare exception only.

Controlled-reference target:

- p95 click-to-interactive <=10 seconds on the TA-15 reference network/device matrix;
- gameplay readiness may wait for trusted TA-4 profile state, but loading presentation must remain responsive;
- streaming absence is never authority.

Any increase to streaming radii is a budget change and requires memory/network evidence.

## 11. Custom Network Budget

The engine's own physics/avatar replication is measured separately. These values govern MonsterVault application remotes.

### 11.1 Client -> server

Per player:

- normal steady application commands: <=8 messages/second rolling 10 seconds;
- burst bucket: <=16 accepted ingress messages over 2 seconds before route/global throttling;
- steady encoded application payload: <=4 KiB/s rolling 10 seconds;
- hard optional-work guardrail: 8 KiB/s rolling 10 seconds.

Per-route limits remain stricter where semantic frequency is lower.

### 11.2 Server -> client

Per recipient:

- steady MonsterVault application payload: <=16 KiB/s rolling 10 seconds;
- hard optional-work guardrail: 32 KiB/s rolling 10 seconds;
- ordinary reliable event payload: <=4 KiB;
- bounded snapshot chunk: <=16 KiB;
- recurring ordinary projection updates: <=10 Hz;
- explicitly loss-tolerant active-interaction presentation: <=20 Hz.

### 11.3 Unreliable transport

Roblox drops UnreliableRemoteEvent payloads larger than 1000 bytes. MonsterVault locks a stricter maximum:

- <=768 encoded bytes per UnreliableRemoteEvent payload;
- no critical state, exact-once result, entitlement, ownership, trade decision or durable value uses unreliable transport;
- no design may rely on the platform's approximate 500 requests/second/client throttle as an operating budget.

## 12. DataStore Profile Size and Collection Maximum

Roblox permits 4,194,304 characters per standard DataStore value. MonsterVault leaves substantial headroom:

| Metric | Warning | Hard architecture guardrail |
|---|---:|---:|
| Serialized Player Profile | 1 MiB | 1.5 MiB |
| Owned Creature records | 1536 | 2048 |
| Recent profile-local operation markers | 384 | 512 |
| Deferred Energy/value grants | 96 | 128 |

Both the byte-size and record-count guardrails apply.

At a hard guardrail:

- existing durable value is not deleted;
- a new value-creating operation that cannot be represented safely fails protected/Pending before final acknowledgement;
- profile sharding is **not** introduced ad hoc;
- exceeding the limit requires material TA-4/TA-14 change control because sharding changes atomicity and recovery.

Derived/display-only strings and reconstructable indexes are not persisted merely for convenience.

## 13. DataStore Scheduling and Headroom

Healthy-session defaults:

- autosave target: every **90 seconds**, staggered with **±15 seconds** jitter;
- lease renewal: no less often than every **90 seconds**, preferably piggybacked on a valid profile checkpoint;
- healthy maximum intended uncheckpointed active interval: **120 seconds**;
- lease stale/reclaim threshold: **300 seconds**;
- active-production crash-recovery allowance: **180 seconds**, satisfying the TA-8 requirement that it exceed the healthy uncheckpointed interval.

Request headroom:

- routine/background work targets <=25% of currently available standard write capacity in steady state;
- short recovery bursts may reach 40%, but not by starving critical work;
- non-critical P1/background work pauses when the corresponding request budget is below **Rcritical = max(30, 2 × connectedPlayers)**;
- P2/load/lease/recovery work owns the protected reserve;
- UpdateAsync is budgeted as consuming both read and write request budgets.

Per-key internal throughput guardrails:

- warning at 1 MiB/minute writes;
- hard at 2 MiB/minute writes;
- warning at 4 MiB/minute reads;
- hard at 8 MiB/minute reads.

These remain below Roblox's current 4 MB/minute write and 25 MB/minute read per-key ceilings.

## 14. Retry and Backoff Budget

Default DataStore/cloud retry schedule for retryable operations:

- attempts: maximum 6 for critical in-session operations;
- delays before retries: 0.5 s, 1 s, 2 s, 4 s, 8 s, 8 s;
- jitter: ±20%;
- background/non-critical operations: maximum 4 attempts before deferral to a later safe trigger;
- player-leave/BindToClose paths never retry beyond the actual shutdown deadline.

Retry exhaustion does not convert unknown into rejection or success.

## 15. MemoryStore Budget

MemoryStore remains optional and transient. No TA-14 use case authorizes durable truth in MemoryStore.

If enabled:

- steady request use <=10% of the current universe request-unit quota;
- warning >20%;
- >=30% attributable to MonsterVault coordination triggers load shedding/reduced refresh;
- stored MemoryStore bytes <=25% of current universe memory quota;
- one MonsterVault item value <=8 KiB;
- default coordination TTL <=15 minutes;
- longer TTL requires an explicit use-case review;
- queues/maps are cleaned explicitly and rely on TTL as a safety net;
- no value grant or trade finality depends on MemoryStore availability.

TA-10 may remain with **zero MemoryStore use at baseline** if measured need does not justify it.

## 16. MessagingService Budget

MessagingService is a coarse invalidation/refresh/hint channel only.

Internal budgets:

- <=12 publishes/minute/server steady state;
- <=6 publishes in any 10-second burst;
- <=4 baseline subscribed MonsterVault topics/server;
- encoded message <=512 bytes;
- topic name <=48 characters;
- callback MonsterVault CPU <=1 ms p95;
- incoming messages coalesce by semantic revision where possible.

These budgets are intentionally far below current platform ceilings. Messages cannot grant value or become durable positive truth.

## 17. World Scheduler and Spatial Budget

Baseline numeric parameters:

- ordinary spawn/scheduler cadence: **250 ms**;
- scheduler pass p95 CPU: <=2 ms;
- one deferred bucket may slip one cadence under warning pressure;
- spatial cell edge: **128 studs** baseline;
- dynamic spatial-index refresh: <=5 Hz per moving indexed entity where exact current physics is not required;
- pre-validation spatial candidate set: <=64 candidates per ordinary player command/query;
- exact final validation remains authoritative even if optimization indexes are stale;
- no global Workspace scan in Heartbeat/RenderStepped.

The 128-stud cell size is a starting architecture constant. TA-15 may justify 64–256 studs for a concrete map; any change must preserve candidate/query budgets.

## 18. Encounter Population and Load Shedding

The TA-9 authored min/base/max population remains gameplay authority. TA-14 adds a technical ceiling of **256 active ordinary World Creatures/server**.

When compute/memory/network pressure crosses warning thresholds, degrade in this order:

1. defer non-urgent scheduler buckets;
2. stop refill above authored minimums;
3. reduce optional AI/cosmetic update cadence;
4. reduce non-critical world-space UI/VFX/audio;
5. defer diagnostic aggregation/analytics sampling;
6. reject/defer optional new sessions/features if hard pressure remains.

Never degrade:

- active acquisition ownership/claim correctness;
- Protected Variant stability;
- P2 progression/economy/trade/commerce finalization;
- moderation/safety validation;
- load/recovery/lease integrity;
- accessibility-critical semantic feedback.

## 19. Economy and Vault Scalability

- exact-instance collection operations must use indexed CreatureInstanceId lookup;
- UI never materializes the full 2048-record technical maximum at once;
- production remains elapsed-time settlement, not per-creature per-frame simulation;
- Production Assignments are settled in bounded batches;
- deferred grants are bounded by section 12;
- production crash allowance is 180 seconds;
- no collection-size-dependent full scan may run inside a frame-critical callback.

The player-facing Offline Production Window duration remains approved content/progression policy; TA-14 only guarantees that its settlement cost is O(number of active assignments), bounded and chunkable, rather than O(elapsed seconds).

## 20. Trading / Event / Social Budgets

- one Trade Session has exactly two participants;
- Trade Offer technical cap: **12 Creature Instances per side**;
- offer mutation produces one revision and invalidates ready state without duplicating full-history logs;
- party/social transient lists are bounded by their semantic membership, not session age;
- event contribution accounting stores compact aggregates, not raw action histories;
- trade journal compaction may occur only after both participant recovery obligations are provably complete;
- transaction recovery work is rate-limited/backgrounded and never bypasses TA-4 profile lease ownership;
- same-server social refresh uses event-driven state, not global polling.

The Trade Cooldown's player-facing duration remains content policy; TA-14 only budgets one compact current restriction/provenance representation per affected Creature Instance.

## 21. Commerce Budgets

Game Pass/Product metadata and ownership work is coalesced:

- no per-frame or periodic per-product polling;
- successful product-info/price metadata cache target TTL: 5 minutes;
- VerificationUnknown ownership reconciliation: at most 5 immediate in-session retries at 1, 2, 4, 8 and 16 seconds, with ±20% jitter;
- retries coalesce per player/product;
- exhausted retry preserves Pending/Unknown for a later safe trigger;
- Developer Product receipt path performs bounded local validation/journal lookup before yielding to persistent work;
- no full receipt-store scan.

Commerce correctness is never exchanged for lower request volume.

## 22. Client UI / Presentation Budgets

Collection/trade/Vault list presentation:

- at most **60** visible/recycled logical cards/rows plus **12** overscan rows materialized for one virtualized list surface;
- sort/filter work >4 ms is chunked/yielded;
- an unrelated single-item change must not rebuild the complete list;
- ordinary countdown/timer presentation updates <=4 Hz;
- active short capture/presentation timers may update <=10 Hz locally;
- world-space optional presentation is relevance/distance bounded.

Notifications:

- low/normal transient queue <=8;
- high-priority transient queue <=2;
- critical unresolved/Pending/reconciliation state is not represented solely by a droppable queue entry;
- repeated low-priority messages coalesce.

Preferences:

- settings persistence debounce: 2 seconds;
- no more than one dedicated preference persistence trigger per 30 seconds/player;
- prefer piggybacking normal P1 profile checkpointing.

## 23. Telemetry / Config / Experiment Budget

Server-local product telemetry:

- queue <=512 events **and** <=256 KiB encoded, whichever is reached first;
- one encoded analytics event <=2 KiB;
- steady product-analytics generation target <=2 events/player/minute;
- short per-player burst <=10 events/minute;
- sampling/coalescing drops low-priority product analytics before diagnostics needed for safety/correctness investigation;
- gameplay never waits for analytics delivery.

Config:

- no per-frame ConfigService/Experience Config evaluation;
- active immutable snapshot reads are O(1) server-local;
- external/current-config refresh check no more often than every 30 seconds/server unless a platform callback supplies change notification;
- full candidate validation <=2 ms p95 CPU or is chunked before activation;
- activation remains atomic.

Experiment assignment:

- deterministic assignment calculation <=0.25 ms p95;
- assignment is cached in the coherent operation/server context where appropriate;
- no persisted write exists solely to remember a non-value-critical analytics assignment.

## 24. Join / Reconnect / Recovery Budget

Under TA-15 controlled reference conditions:

- p95 click-to-interactive target <=10 s;
- trusted profile readiness p95 target <=8 s when DataStore is healthy;
- reconnect/projection resync does not resend unbounded history;
- authoritative snapshots are chunked under section 11;
- recovery work is prioritized above cosmetics/analytics and below safety/lease integrity where those conflict.

A platform/cloud outage may exceed these targets without changing truth. The UI must present ProtectedLoadFailure/Pending/OutcomeUnknown according to upstream contracts.

## 25. Complexity Rules

Forbidden implementation shapes:

- O(players²) per-frame loops;
- O(world instances) per-frame scans;
- O(collection size) work on unrelated collection mutation;
- one coroutine/connection/Heartbeat owner per ordinary spawn anchor or list row;
- unbounded append-only in-memory histories;
- retry loops without caps;
- DataStore write per analytics event;
- DataStore write per UI setting toggle;
- cross-server message per local micro-state change.

Allowed heavy work must be event-driven, indexed, batched, amortized or chunked.

## 26. Performance Observability Contract

TA-13 telemetry/diagnostics must expose bounded measurements for at least:

- server frame time and MonsterVault script CPU;
- server memory percentage and major tagged categories;
- client frame time/crash rate/reference memory deltas;
- active runtime entities/creatures/interactables;
- custom remote messages/s and bytes/s by route class;
- rejected/throttled remote counts;
- serialized profile bytes and creature count;
- DataStore request-budget reserve, retries, throttles, latency and per-key bytes;
- MemoryStore request/memory percentage if used;
- Messaging publishes/receives and coalescing;
- scheduler duration/deferred buckets/candidate counts;
- client virtualized row count and expensive UI work;
- analytics queue length/drops;
- config validation duration/revision;
- degradation state/reason/duration.

High-cardinality runtime IDs are not added merely for performance dashboards.

## 27. Degradation State Machine

Each server maintains a non-authoritative operational pressure level:

- **GREEN** — all target budgets;
- **YELLOW** — one or more warning thresholds sustained;
- **ORANGE** — hard guardrail approached/exceeded but correctness intact;
- **RED / DRAIN** — server cannot safely admit new optional work or maintain ordinary fidelity.

This state may alter optional scheduling/fidelity/admission only. It cannot become gameplay authority and is not persisted as player truth.

Recovery uses hysteresis:

- a level may improve only after all metrics for the lower level remain below their warning threshold for 30 seconds;
- optional work resumes gradually, not in one catch-up spike.

## 28. Security and Abuse Interaction

Attackers must not be able to turn budget protections into authority bypasses.

Therefore:

- rate limiting occurs after cheap envelope validation and before expensive domain work;
- expensive rejection paths are bounded too;
- invalid payloads do not allocate unbounded tables/logs;
- throttled clients do not gain alternate less-validated routes;
- load shedding never disables ownership, price, capacity, trade, receipt or permission validation;
- observability uses aggregation rather than attacker-controlled high-cardinality dimensions.

## 29. Change Control

A change is material and requires TA-14 review when it:

- raises a hard budget;
- lowers platform headroom;
- changes streaming radii/integrity behavior;
- raises profile or collection maxima;
- adds MemoryStore as gameplay-critical dependency;
- raises remote rate/payload envelopes;
- alters autosave/lease timing;
- changes degradation order;
- creates a new per-frame/global scan;
- makes correctness depend on a performance optimization.

TA-15 evidence may recommend tighter budgets without GDS change if player-facing semantics remain unchanged.

## 30. TA-15 Verification Obligations

TA-15 must create executable/static/fault/performance gates that prove:

- L0–L5 load classes;
- server/client frame targets;
- memory stability and cleanup;
- streaming/join behavior;
- network rate/payload enforcement;
- profile-size guardrails and sharding refusal;
- DataStore throttling/retry/lease behavior;
- MemoryStore/Messaging failures;
- scheduler/spatial load shedding;
- 2048-record collection virtualization;
- trade/receipt/recovery cut points;
- analytics/config overload behavior;
- abuse paths under throttling;
- no semantic/value loss under every degradation state.

## 31. Downstream

### TA-15

Owns executable/static/fault/security/performance validation and CI release gates.

### TA-16

Audits all TA-0..15 contracts together and verifies no cross-system budget contradiction.

### TA-17

Locks concrete implementation module graph, configuration constants within TA-14 ranges, deployment workflow and implementation sequencing.

## 32. Open Questions

**Zero TA-14 implementation-blocking architecture questions remain.**

Content-tunable values that do not change TA-14 scalability invariants remain downstream content/TA-17 choices, including exact authored spawn minima/base populations, exact player-facing Offline Production Window tiers and Trade Cooldown duration.

## 33. Architecture-Complete Checklist

- [x] platform ceilings separated from internal budgets;
- [x] reference load classes locked;
- [x] server/client compute budgets locked;
- [x] server/client memory policy locked;
- [x] runtime entity/instance budgets locked;
- [x] streaming configuration locked;
- [x] remote rate/payload budgets locked;
- [x] profile size/collection maxima locked;
- [x] autosave/lease/retry budgets locked;
- [x] DataStore throughput/headroom policy locked;
- [x] MemoryStore/Messaging budgets locked;
- [x] world scheduler/spatial/load-shedding budgets locked;
- [x] economy/trade/commerce scalability bounds locked;
- [x] client virtualization/timer/notification budgets locked;
- [x] telemetry/config/experiment overhead locked;
- [x] observability and degradation state machine locked;
- [x] security interaction locked;
- [x] TA-15 verification obligations explicit;
- [x] zero TA-14-blocking questions.

**TA-14 architecture contract: PASS.**
