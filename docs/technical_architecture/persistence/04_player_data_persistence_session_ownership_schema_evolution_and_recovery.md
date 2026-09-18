# TA-4 — Player Data, Persistence, Session Ownership, Schema Evolution, and Recovery

> **Status:** Architecture Complete  
> **Owning TA phase:** TA-4 — Player Data, Persistence, Session Ownership, Schema Evolution, and Recovery  
> **Authority:** Persistent player-profile aggregate, DataStore topology, session ownership/lease semantics, load/readiness state machine, save/checkpoint classes, per-key serialization, UpdateAsync/revision discipline, schema versioning/migrations, corruption handling, recovery, durable operation identities, multi-key transaction primitives, shutdown behavior, environment isolation, persistence observability and operational recovery  
> **Depends on:** TA-0 Architecture Complete; TA-1 Architecture Complete; TA-2 Architecture Complete; TA-3 Architecture Complete; GDS-2, GDS-4, GDS-5, GDS-7, GDS-8, GDS-11, GDS-12, GDS-13, GDS-15, GDS-17

## 1. Purpose

TA-4 defines how MonsterVault protects persistent player value across joins, saves, disconnects, server crashes, retries, duplicate callbacks, schema upgrades and accidental concurrent sessions.

The persistence contract is:

> **A player's authoritative persistent state is loaded into exactly one server-owned session at a time, guarded by an atomic DataStore lease. Gameplay becomes persistence-ready only after the current schema is validated under that lease. Persistent mutations are serialized, revisioned and written with UpdateAsync; critical finalized value is durably checkpointed before it is presented as durably final. Load/save uncertainty fails closed rather than overwriting trusted history.**

TA-4 does not create DataStore code or actual profile schemas. Those implementation artifacts remain blocked until TA-17.

## 2. Platform Storage Choice

### DATA-01 — Standard DataStoreService is the durable player-data authority

MonsterVault uses Roblox standard DataStores for long-lived player state.

Reasons:

- persistence across sessions and servers;
- atomic per-key `UpdateAsync()`;
- key metadata;
- version history;
- current official Roblox support and operational tooling.

### DATA-02 — MemoryStore is not persistent authority

MemoryStore may later support ephemeral cross-server coordination/cache where TA-10 justifies it.

It does **not** own:

- player profile truth;
- session-lock truth;
- creature ownership;
- Energy;
- progression;
- commercial entitlement;
- durable exact-once results.

### DATA-03 — OrderedDataStore is not the profile store

OrderedDataStore may later support leaderboard projections if needed.

It does not replace the standard player profile aggregate.

## 3. Environment Isolation

TA-1 defines DEV, STAGING and PRODUCTION.

TA-4 locks the persistence consequence:

### ENV-DATA-01 — Each environment has an isolated durable data domain

Production player records are never the default target of local Studio/DEV testing.

Baseline isolation uses:

- separate Roblox experience/universe per DEV/STAGING/PRODUCTION where practical;
- environment-specific DataStore names/scopes as defense in depth;
- explicit environment identity in server configuration.

### ENV-DATA-02 — Studio must not casually point at production DataStores

Roblox Studio can access the same live DataStores when API access is enabled.

Therefore production access from ordinary Studio development is prohibited.

### ENV-DATA-03 — Environment identity is immutable for the server lifetime

A running server does not dynamically switch its persistence environment.

## 4. Player Profile Aggregate

The baseline durable player state is one **Player Profile Aggregate** per user.

Conceptual key:

```text
PlayerProfile:<UserId>
```

Exact store/key naming is locked at TA-17.

The aggregate owns all persistent player-local state that benefits from atomic consistency, such as:

- schema/version metadata;
- profile revision;
- creature collection/ownership records;
- Creature Locks and persistent creature restrictions;
- discovery records;
- Vault/capacity/production state;
- Energy;
- progression/unlocks/mastery records;
- persistent event outcomes;
- Trade Access and player-local trade history references;
- commercial durable entitlements/projections where appropriate;
- accessibility/settings that are intentionally persistent;
- bounded operation-deduplication metadata.

### AGG-01 — Related player state stays together while safely within one key

Roblox DataStore guidance favors keeping related state in one object when practical.

MonsterVault therefore avoids premature sharding.

### AGG-02 — The aggregate is not an unlimited dumping ground

TA-14 must monitor serialized profile size and throughput.

If measured growth approaches a safe fraction of platform limits, sharding requires a material TA-4 change because it changes atomicity/recovery semantics.

### AGG-03 — Cross-player state is not duplicated as authoritative truth

Examples:

- Trade Session itself is not permanently owned by both profiles as two independent truths;
- global Event Occurrence state is not stored independently in every profile as authority;
- platform receipt truth is not inferred solely from a profile projection.

Player records may contain references/history/finalized personal outcomes.

## 5. Persistent Profile Shape

Conceptual root:

```text
{
    schemaVersion,
    profileRevision,
    createdAt,
    lastSuccessfulSaveAt,

    collection = {...},
    discovery = {...},
    vault = {...},
    economy = {...},
    progression = {...},
    events = {...},
    trading = {...},
    commerce = {...},
    settings = {...},

    recentOperations = {...}
}
```

Exact domain field schemas are downstream TA-5/TA-8/TA-10/TA-11.

### SHAPE-01 — Session-lock data is not gameplay data

Session ownership lives in DataStore metadata rather than as player-facing profile state.

### SHAPE-02 — Runtime/transient state is excluded

Do not persist simply because state exists in memory.

Examples excluded by default:

- current Active Context;
- current capture input sequence;
- current UI modal;
- current Party transient state;
- live world spawn entity;
- current server-local event timer;
- temporary notification queue.

## 6. Profile Revision

Every successful durable profile write increments a monotonically increasing `profileRevision`.

### REV-01 — Revision represents durable aggregate version

It is not a gameplay level/version.

### REV-02 — Every save verifies expected durable revision

The server session tracks the last successfully persisted revision.

A write uses `UpdateAsync()` to confirm:

- this server still owns the session lease;
- stored revision matches the expected revision unless an explicitly supported recovery path applies.

### REV-03 — Unexpected revision means ownership/concurrency uncertainty

Do not blindly overwrite.

Transition the session into persistence-protected handling and investigate/reconcile.

## 7. Session Ownership Model

At most one live server may own a player's writable profile session.

Session ownership is represented by a **lease in DataStore key metadata**.

Conceptual metadata:

```text
{
    lockId = <random session GUID>,
    jobId = <server job identity>,
    lockEpoch = <monotonic/unique acquisition identity>
}
```

Exact compact field names are implementation details.

### LOCK-01 — Lock acquisition is atomic with profile read/update

The first player-profile access uses `UpdateAsync()`.

The callback checks current metadata and either:

- accepts an unlocked/stale lease and records this server's new lock identity; or
- recognizes its own valid lock; or
- returns nil/aborts when another fresh lock exists.

### LOCK-02 — A fresh foreign lease is never force-stolen

The joining server waits/retries within bounded policy or presents a protected session-locked state.

### LOCK-03 — A stale lease may be reclaimed

A lease becomes reclaimable only after the configured expiration policy proves it stale.

The exact duration is a TA-14/TA-17 numeric constant.

### LOCK-04 — Lease refresh and autosave are linked

The server periodically performs an `UpdateAsync()` save/renewal often enough that:

```text
renewal interval < lease expiration
```

and with a material safety margin.

### LOCK-05 — Metadata preservation is mandatory

Roblox requires metadata to be explicitly returned/preserved on writes.

All profile writes therefore flow through one persistence repository/wrapper that maintains lease metadata correctly.

## 8. Session Lock State Machine

Conceptual state:

```text
NoSession
  -> Acquiring
  -> OwnedLoading
  -> OwnedValidating
  -> Ready
  -> Saving/Checkpointing (substate)
  -> Releasing
  -> Closed

Failure branches:
  Acquiring -> SessionLocked
  OwnedLoading/Validating -> ProtectedLoadFailure
  Ready -> PersistenceAtRisk
  PersistenceAtRisk -> Ready           (successful renewal/recovery)
  PersistenceAtRisk -> OwnershipLost
  OwnershipLost -> Closed/Protected exit
```

### SES-01 — Gameplay readiness is server-authoritative

A client Hello or local loading completion does not make the session Ready.

### SES-02 — SessionLocked is not a blank profile

When a fresh foreign lease exists, do not load default data as writable truth.

### SES-03 — ProtectedLoadFailure is non-destructive

Load/migration/validation failure blocks irreversible persistent gameplay.

It must never save a blank/default profile over existing trusted data.

## 9. Lock Acquisition

Load/acquire sequence:

1. create a new random `lockId`;
2. call `UpdateAsync()` on the profile key;
3. inspect current value and key metadata;
4. if another fresh lock exists: abort update;
5. if unlocked/stale: claim lock metadata;
6. create default profile only if the key genuinely has no prior value;
7. migrate old schema inside the atomic transform where feasible;
8. validate structural invariants;
9. write migrated/normalized value + new lock metadata;
10. return authoritative profile and revision;
11. only then continue toward Ready.

### LOAD-01 — New profile creation is explicit

`nil`/missing key may create the current default schema.

A failed read is **not** equivalent to a missing key.

### LOAD-02 — Load errors cannot fall through to default-save

This prevents the classic "DataStore failed, default profile overwrote real profile" loss mode.

## 10. Lease Renewal

### LEASE-01 — Periodic save renews the lock

Normal staggered autosaves both:

- persist dirty buffered state;
- renew lease metadata.

### LEASE-02 — Clean sessions still renew

If no profile data changed, the server still performs lease-renewal writes often enough to preserve ownership.

### LEASE-03 — Renewals are staggered

Player/session autosaves do not all fire on one fixed global tick.

Each session receives a randomized/staggered schedule.

### LEASE-04 — Renewal failure has a safety margin

Transient failures may retry.

If successful lease confirmation cannot be obtained before a configured safety margin near expiry, the session enters `PersistenceAtRisk`.

New irreversible persistent operations are blocked until ownership is confirmed again.

## 11. Ownership Loss

If any `UpdateAsync()` observes that the stored lock identity no longer matches this session:

### LOST-01 — The server permanently relinquishes write authority

It does not attempt to overwrite/remove the foreign lease.

### LOST-02 — Irreversible gameplay immediately stops

No further persistent ownership/currency/progression/trade/commercial finalization may execute.

### LOST-03 — In-memory unsaved state is quarantined for diagnostics

It is not blindly written over the new owner's state.

### LOST-04 — Client receives a protected session outcome

Presentation wording is TA-12.

The player may be required to rejoin after the current safe state is resolved.

## 12. In-Memory Session Buffer

Once Ready, the owning server keeps a working profile in server memory.

### MEM-01 — Domains read/mutate the owned server working copy

Ordinary gameplay does not call DataStore for every read.

### MEM-02 — One session writer pipeline

All durable writes for one profile key are serialized through the persistence repository.

No two local coroutines independently race DataStore writes for the same profile.

### MEM-03 — Dirty tracking

Buffered changes mark appropriate state dirty.

Autosave writes a coherent aggregate snapshot.

### MEM-04 — In-memory state is not durable until checkpoint succeeds

The architecture distinguishes:

- locally accepted/pending mutation;
- durably finalized mutation.

For GDS-defined Finalized Outcomes, the client is not told that a durable finalization succeeded until the required durability boundary completes.

## 13. Persistence Classes

Persistent changes fall into three technical classes.

### Class P0 — Session-only

Never persisted.

Examples:

- UI state;
- active input;
- transient Party invite;
- live capture challenge input.

### Class P1 — Buffered durable

Loss of the latest few seconds due catastrophic server failure is tolerable and does not represent a GDS Finalized Outcome.

Examples may include:

- non-critical presentation preferences;
- low-value counters/telemetry-like player settings where product semantics allow;
- timestamps that can be recomputed safely.

They are persisted by autosave/final save.

### Class P2 — Durable-before-final-ack

Persistent value/authority where GDS semantics require exact persistent finalization.

Examples include:

- secured Creature ownership;
- explicit Release;
- Energy grant/spend tied to a committed gameplay transaction;
- progression/access purchase;
- production claim;
- finalized Event reward;
- Trade ownership finalization;
- commercial entitlement/grant/reconciliation.

### PCLASS-01 — P2 success means the durable write/checkpoint succeeded

If persistence is unavailable, the operation stays pending/rejected according to owning domain rules; it is not presented as durably final.

## 14. Save Pipeline

For a profile save/checkpoint:

1. enqueue on the profile's single writer pipeline;
2. snapshot/validate the current in-memory profile;
3. establish expected `profileRevision`;
4. call `UpdateAsync()`;
5. verify current lease identity;
6. verify current durable revision;
7. verify/apply operation idempotency rules when applicable;
8. return the intended coherent profile value;
9. preserve/renew lock metadata;
10. increment durable `profileRevision`;
11. on success update the server's persisted-revision marker;
12. only then acknowledge P2 durable finalization.

### SAVE-01 — `SetAsync()` is not the profile write primitive

Player profile mutation uses `UpdateAsync()`.

### SAVE-02 — Update transform is pure/non-yielding

No:

- network calls;
- task waits;
- platform API calls;
- non-deterministic side effects;

inside the transform callback.

## 15. Local Write Queue

Each owned profile session has one persistence operation queue.

### QUEUE-01 — Key operations are ordered

Load/acquire, checkpoint, autosave, lease renewal and release cannot race independently.

### QUEUE-02 — Irreversible checkpoints have priority over non-critical autosave

Exact policy is TA-14/TA-17, but a P2 commit is not trapped indefinitely behind cosmetic saves.

### QUEUE-03 — Shutdown closes admission

When shutdown begins, the queue stops accepting new ordinary persistent operations and drains/finalizes allowed critical work.

## 16. Retry Policy

All DataStore calls are failure-aware.

### RETRY-DATA-01 — Calls are wrapped and classified

Transient service/throttle/internal failures may retry.

Permanent/schema/authorization errors do not spin forever.

### RETRY-DATA-02 — Bounded exponential backoff + jitter

Exact delays/attempt caps are TA-14/TA-17 constants.

### RETRY-DATA-03 — Budget-aware scheduling

Non-critical operations respect DataStore request-budget/throughput pressure.

### RETRY-DATA-04 — Never infinite retry inside player leave/shutdown

Shutdown has a hard platform deadline.

If final save cannot complete, the server does not fabricate success.

## 17. Autosave Policy

### AUTO-01 — Periodic autosave is required

Roblox official guidance recommends keeping player state server-local and saving periodically in addition to leave/shutdown.

### AUTO-02 — Autosave interval is shorter than lease expiry

With a safety margin sufficient for retries/throttling.

### AUTO-03 — Autosaves are staggered per session/server

Avoid synchronized request spikes.

### AUTO-04 — P2 operations are not delayed solely to the next autosave

They checkpoint according to their durability contract.

## 18. Player Leave

On `PlayerRemoving`:

1. mark the session as leaving;
2. stop new player-originated P2 operations;
3. resolve/cancel allowed in-flight operations according to owning TA;
4. enqueue final coherent profile save;
5. `UpdateAsync()` verifies own lease;
6. save final state;
7. remove own lock metadata in the same successful update;
8. clear in-memory profile only after safe completion/timeout handling.

### LEAVE-01 — Unlock is coupled to final save

Do not release first and save later.

### LEAVE-02 — Failed final save does not pretend the lock was safely released

Lease expiry/recovery protects subsequent joins.

## 19. Server Shutdown

Roblox `BindToClose()` provides a bounded shutdown window.

TA-4 architecture:

1. mark server draining;
2. stop admission of new persistent-value operations;
3. stop/suspend background generators as owning phases require;
4. snapshot every owned player session;
5. execute final save+unlock operations in parallel across different player keys;
6. serialize operations per individual key;
7. prioritize player-value saves over non-critical telemetry;
8. wait only within the platform shutdown deadline.

### SHUT-01 — Parallel across players, serialized within a player

### SHUT-02 — Shutdown does not rely only on PlayerRemoving

### SHUT-03 — Crash safety relies on periodic checkpoints + lease expiry

`BindToClose()` cannot protect abrupt process failure.

## 20. Schema Versioning

Every profile has an integer `schemaVersion`.

### SCHEMA-01 — Version increases monotonically

No semantic reuse of an old version number.

### SCHEMA-02 — Code declares one current supported schema

### SCHEMA-03 — Older supported profiles migrate sequentially

Conceptual chain:

```text
v1 -> v2 -> v3 -> ... -> current
```

### SCHEMA-04 — Newer-than-server schema fails closed

An older rollback server must not downgrade/overwrite a profile written by newer code.

## 21. Migration Contract

Each migration is:

- pure;
- deterministic;
- non-yielding;
- side-effect-free;
- individually testable;
- aware only of stored data/config constants required for schema shape;
- able to fail before any destructive write is committed.

### MIG-01 — Migrations are applied under session acquisition/update authority

The profile cannot become Ready on a half-migrated in-memory copy.

### MIG-02 — Migration result is structurally validated before commit

### MIG-03 — Migration failure preserves previous stored version

No partial schema write.

### MIG-04 — Migration scripts remain available while old live versions may exist

TA-17/release process controls when migration code may be retired.

## 22. Default Reconciliation

When a stored profile is valid but lacks a newly introduced optional/default field:

### DEFAULT-01 — Defaults are reconciled explicitly

Do not assume missing and `false`/`0` mean the same thing.

### DEFAULT-02 — Defaults cannot fabricate earned value

New defaults must not grant:

- progression milestone;
- rare creature;
- event participation;
- paid entitlement;

unless the owning GDS/TA explicitly authorizes a migration grant.

## 23. Validation on Load

After migration, validate invariants such as:

- root type;
- schema version;
- non-negative/valid numeric fields where required;
- unique Creature Instance IDs;
- no duplicate ownership entries;
- capacity structures internally consistent;
- operation ledger shape bounded;
- domain enum/ID references structurally valid;
- impossible circular references absent.

Exact domain validation expands in TA-5/TA-8/TA-10/TA-11.

### VALID-LOAD-01 — Invalid data does not silently normalize away valuable state

If a repair is not provably lossless, enter Protected Load Failure.

## 24. Corruption Handling

### CORR-01 — No silent blank-profile replacement

### CORR-02 — No automatic destructive "fix all"

### CORR-03 — Classify repairability

- safe deterministic migration/default fill;
- safe derived-field recomputation;
- operator-required recovery;
- irrecoverable only after explicit operational review.

### CORR-04 — Preserve diagnostic evidence

Record:

- user/profile key identity;
- schema/version;
- DataStore version identifier where available;
- validation failure category;
- server build.

Do not log the entire private profile unnecessarily.

## 25. Version History and Operational Recovery

Roblox standard DataStores maintain previous versions.

TA-4 uses that as an operational recovery layer, not routine gameplay logic.

### REC-01 — Previous versions are recovery evidence

Operators can inspect/compare/revert through supported Roblox tooling/Open Cloud processes.

### REC-02 — Automatic runtime rollback is not baseline

The game does not silently choose an arbitrary older profile because current validation failed.

### REC-03 — Recovery actions are auditable

Manual restore/revert should record:

- operator/action;
- user/key;
- source version;
- reason;
- resulting version.

TA-13/TA-15/operations refine implementation.

## 26. Durable Operation Identity

TA-3 request IDs are not durable authority.

TA-4 introduces **server-owned Operation IDs** for exact-once persistent mutations.

Conceptually:

```text
operationId = globally unique server-generated ID
operationKind
subjectUserId
createdAt
result/finalized state
```

### OP-01 — Single-profile operation dedupe can live inside the profile

A bounded `recentOperations` structure may record recently finalized operation IDs/results.

### OP-02 — The operation ledger is bounded

Do not grow the player profile forever.

Exact retention/count is TA-14/TA-17.

### OP-03 — Long-lived/external replay sources may require dedicated durable operation keys

Examples:

- Marketplace receipt IDs;
- cross-profile Trade transaction IDs;
- long-lived Event reward IDs if required.

Owning TA-10/TA-11 define semantics using TA-4 primitives.

## 27. Single-Profile Atomicity

A transaction affecting only one Player Profile Aggregate can be durably atomic under one `UpdateAsync()`.

Examples conceptually:

- Energy spend + progression unlock;
- production claim + Energy grant;
- Release + collection removal/history update;
- capacity reconciliation within one player.

### ATOM-01 — Related fields commit in one aggregate update

Do not split one logical player transaction across independent keys without need.

## 28. Multi-Profile / Multi-Key Atomicity Boundary

Roblox standard DataStore does not provide a general multi-key transaction primitive.

Therefore:

### MULTI-01 — Sequential writes are not "atomic trade"

TA-10 may not implement trade as:

```text
save player A
then save player B
hope both work
```

### MULTI-02 — Cross-profile exact-once flows require a durable transaction protocol

TA-4 provides the pattern:

- globally unique transaction ID;
- durable transaction record/journal;
- participant/profile preconditions;
- prepare/reservation markers;
- commit decision;
- idempotent participant application;
- recovery/resume from any partial infrastructure step.

TA-10 defines the concrete Trade protocol.

### MULTI-03 — Transaction journal state is not player-facing ownership itself

It coordinates/recovers authoritative participant profile mutations.

## 29. Durable Transaction Store Primitive

TA-4 reserves a separate durable operation/transaction DataStore namespace for flows that cannot safely fit inside one player key.

Conceptual categories:

- cross-profile transaction record;
- externally replayed receipt processing record;
- global exact-once operation record where owner phase requires it.

### TXSTORE-01 — Use only when semantics require cross-key/long-lived dedupe

Do not create one transaction key for every trivial buffered setting change.

### TXSTORE-02 — Keys are stable and operation-derived

Exact naming/hash format is TA-5/TA-17.

## 30. Commercial Receipt Boundary

TA-11 owns MarketplaceService semantics.

TA-4 provides:

- durable player profile entitlement storage;
- server-owned receipt operation identity/deduplication primitive;
- safe checkpoint/reconciliation;
- profile/session locking.

### COM-01 — Client purchase UI never creates entitlement truth

### COM-02 — Receipt retry must be idempotent across servers/restarts

TA-11 selects the exact durable record pattern.

## 31. Trade Boundary

TA-10 owns trade.

TA-4 provides:

- per-profile session lock/revision;
- durable transaction journal primitive;
- idempotent participant mutation;
- recovery after server crash/retry.

### TRADE-DATA-01 — Trade Commit cannot rely on both players remaining connected after commit decision

The durable protocol must finish/recover from transaction state.

## 32. Event Reward Boundary

TA-10/TA-11? TA-10 owns event orchestration.

TA-4 provides:

- operation IDs;
- finalized reward markers;
- durable player outcome storage.

### EVENT-DATA-01 — Server hop/retry does not reissue the same finalized reward

Owning event architecture keys dedupe to stable Event Occurrence/reward identity.

## 33. Offline Production Boundary

TA-8 owns calculation.

TA-4 stores trusted inputs such as:

- last relevant production/checkpoint timestamp;
- Production Assignments;
- Production Buffer state.

### OFFLINE-01 — Client clock is never authoritative

### OFFLINE-02 — Persisted server timestamps are validated inputs

Exact time-source/clock abstraction is TA-8/TA-13.

## 34. Profile Size / Sharding Policy

Roblox standard DataStore entries have a finite per-key size.

TA-4 policy:

### SIZE-01 — Measure serialized profile size

TA-14 defines warning/hard architecture budgets well below the platform maximum.

### SIZE-02 — Compact stable records

Do not persist redundant presentation strings/derived data that can be reconstructed.

### SIZE-03 — Do not shard before evidence

Sharding adds:

- cross-key consistency;
- migration complexity;
- load/save fanout;
- more failure modes.

### SIZE-04 — Sharding trigger reopens TA-4

If required, the new shard topology must define:

- shard ownership;
- atomicity boundaries;
- migration;
- session lock relationship;
- partial-load behavior;
- backup/recovery.

## 35. DataStore Throughput Policy

### BUDGET-01 — Profile data is buffered in memory

Avoid DataStore call per ordinary read/change.

### BUDGET-02 — UpdateAsync is used intentionally

It consumes both read and write budgets.

### BUDGET-03 — Autosaves are staggered

### BUDGET-04 — Critical P2 operations may checkpoint immediately

TA-14 must model expected capture/economy/trade/commerce write rates.

### BUDGET-05 — Throttling is a recoverable infrastructure failure, not authorization

Never weaken validation to "save requests."

## 36. DataStore Key / Store Naming

Exact names are TA-17, but the namespace must encode:

- environment;
- logical store role;
- schema generation where operationally useful;
- user/operation identity.

Rules:

- deterministic;
- bounded;
- no user-supplied arbitrary key material;
- no plaintext secret;
- no display name dependence.

UserId is the stable player identity, not username/display name.

## 37. Privacy and Data Minimization

Persistent player profiles store only game-required data.

Avoid:

- unnecessary personal information;
- raw chat/user-generated text where not required;
- redundant platform age/region details;
- hidden tracking history that does not serve a defined analytics/operations need.

GDS-15/TA-13 remain authoritative for privacy/analytics policy.

## 38. Backup / Operator Safety

Operational tools can be dangerous.

### OPS-01 — Production write access is least-privilege

### OPS-02 — Manual edit/revert is change-controlled

### OPS-03 — Open Cloud tooling does not bypass schema/invariant awareness casually

### OPS-04 — Production recovery should validate the target version before restore

## 39. Observability

Persistence observability should include:

- load attempts/success/failure classes;
- session-lock contention;
- lease acquisition/renewal/loss;
- profile schema version;
- migration outcome;
- save/checkpoint latency;
- DataStore error/throttle category;
- profile serialized-size bucket;
- revision mismatch;
- P2 pending/commit result;
- operation duplicate/replay result;
- shutdown save success;
- Protected Load Failure count.

Do not log full player profiles.

TA-13 implements telemetry.

## 40. Testability

TA-15 must support deterministic tests for:

- first profile creation;
- successful load/lock;
- concurrent second-server lock attempt;
- stale-lock takeover;
- lock renewal;
- lease loss;
- DataStore transient failure;
- throttling;
- save revision conflict;
- blank-default overwrite prevention;
- migration success/failure;
- newer-schema fail-closed;
- P2 exact-once retry;
- duplicate operation ID;
- shutdown save deadline;
- multi-key transaction recovery primitives.

Infrastructure must be fakeable/injectable under TA-2.

## 41. Current Roblox Persistence Snapshot

TA-4 reviewed official Roblox guidance current on 2026-09-18.

Confirmed platform facts include:

- standard DataStores persist across sessions and servers;
- `UpdateAsync()` atomically reads current key state before update and is preferred where concurrent writes matter;
- `UpdateAsync()` transform callbacks cannot yield;
- custom key metadata is available and can participate in `UpdateAsync()`;
- metadata must be explicitly preserved on writes;
- Roblox's player-data/purchasing guidance describes session locking using a metadata LockId under `UpdateAsync()`;
- player state should be buffered server-side and saved periodically, on leave, shutdown and critical checkpoints;
- `BindToClose()` has a bounded server shutdown window;
- DataStore entries have finite size and throughput/request budgets;
- standard DataStores maintain previous versions for operational recovery;
- MemoryStore is temporary/TTL-based and is not a replacement for durable player persistence.

Dated evidence is recorded in `TA4_ROBLOX_PERSISTENCE_SNAPSHOT.md`.

## 42. Downstream Ownership

### TA-5

- stable ID formats;
- content/config IDs referenced by persisted profiles.

### TA-6/TA-7

- Creature/runtime/capture persistent projection fields;
- secure ownership P2 checkpoint integration.

### TA-8

- exact Vault/Energy/progression schema;
- offline accrual state;
- P2 mutation semantics.

### TA-10

- cross-profile Trade transaction journal/protocol;
- event reward exact-once keys;
- cross-server recovery.

### TA-11

- receipt processing and commercial entitlement transaction records.

### TA-12

- Loading/ProtectedLoadFailure/PersistenceAtRisk UI projections.

### TA-13

- persistence telemetry/config rollout/operational audit.

### TA-14

- autosave/lease/retry intervals;
- size/throughput/request budgets.

### TA-15

- persistence fault-injection/security/migration/recovery tests.

### TA-17

- actual DataStore names;
- exact metadata keys;
- exact schema source modules;
- repository/wrapper implementation contract;
- final numeric timing/version pins.

## 43. Open Questions

There are **zero TA-4-blocking open questions**.

Correctly downstream/tuneable:

- exact profile domain field schema — TA-5/8/10/11;
- exact lock expiry/renewal/autosave seconds — TA-14/TA-17;
- exact retry count/backoff numbers — TA-14/TA-17;
- exact recent-operation retention size — TA-14/TA-17;
- exact DataStore names/key string encoding — TA-17;
- concrete trade distributed-transaction state machine — TA-10;
- concrete Marketplace receipt record protocol — TA-11;
- operator tooling/CI implementation — TA-13/15/17.

## 44. Architecture-Complete Checklist

- [x] durable storage authority selected;
- [x] environment isolation defined;
- [x] one player-profile aggregate baseline defined;
- [x] profile revision discipline defined;
- [x] DataStore metadata lease/session locking defined;
- [x] lock acquisition/renewal/expiry/ownership-loss semantics defined;
- [x] load/readiness failure state machine defined;
- [x] in-memory buffering and one-writer queue defined;
- [x] P0/P1/P2 persistence classes defined;
- [x] durable-before-final-ack boundary defined;
- [x] UpdateAsync save pipeline defined;
- [x] retry/autosave/shutdown rules defined;
- [x] schema version/migration/default reconciliation defined;
- [x] corruption/version-history/operator recovery rules defined;
- [x] server-owned operation identities defined;
- [x] bounded profile operation ledger defined;
- [x] single-profile atomicity defined;
- [x] no multi-key atomic primitive limitation explicitly handled;
- [x] durable transaction-store primitive defined;
- [x] trade/commerce/event/offline-production handoffs defined;
- [x] profile size/sharding change-control policy defined;
- [x] throughput/privacy/observability/testability defined;
- [x] current Roblox platform persistence guidance reviewed;
- [x] zero TA-4-blocking open questions.
