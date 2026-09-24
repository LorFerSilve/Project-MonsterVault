# TA-14 Roblox Performance and Scalability Platform Snapshot

> **Status:** PASS  
> **Snapshot date:** 2026-09-24  
> **Purpose:** Record current Roblox platform behavior/limits that constrain TA-14 without treating platform ceilings as MonsterVault operating targets.

## 1. Performance / Frame / Memory

Authoritative reference: Roblox Creator Hub — Performance Optimization / Identify Performance Issues.

Observed platform guidance:

- server Heartbeat is capped at 60 FPS; a frame exceeding 16.67 ms indicates the server cannot sustain 60 Hz;
- default client frame target is 60 FPS, but device performance varies and client measurements should be taken in the Roblox client rather than inferred from Studio;
- Roblox recommends keeping server memory below 50%;
- server memory is described as 6.25 GiB + 100 MiB × largest number of connected players seen by that server;
- client crash-rate increases above roughly 2–3% warrant investigation, and a crash on a device the experience intends to support is itself actionable;
- client memory is device/content dependent rather than governed by one portable experience-level ceiling.

References:

- https://create.roblox.com/docs/performance-optimization/identify
- https://create.roblox.com/docs/performance-optimization

TA-14 consequence: MonsterVault uses stricter internal frame/memory warning and hard-action thresholds and validates clients on representative devices.

## 2. DataStoreService

Authoritative reference: Roblox Creator Hub — Data Store Error Codes and Limits.

Current limits relevant to MonsterVault:

- one standard data value: maximum 4,194,304 characters;
- UpdateAsync consumes both read and write request budgets;
- standard experience read budget: 300 + 40 × concurrent users requests/minute;
- standard experience write budget: 300 + 20 × concurrent users requests/minute;
- list budget: 300 + 2 × concurrent users requests/minute;
- remove budget: 300 + 40 × concurrent users requests/minute;
- each throttling queue holds 30 requests before later requests can be dropped;
- per-key read throughput: 25 MB/minute;
- per-key write throughput: 4 MB/minute;
- Open Cloud and game-server DataStore traffic share the experience budgets.

Reference:

- https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits

TA-14 consequence: the Player Profile hard guardrail is 1.5 MiB, routine traffic leaves material request headroom, and no architecture depends on queued throttled calls being retained indefinitely.

## 3. MemoryStoreService

Authoritative reference: Roblox Creator Hub — Memory Stores.

Current relevant quotas:

- universe memory quota: 64 KB + 1.2 KB × current users;
- request-unit quota: 1000 + 120 × concurrent users per minute;
- one sorted map or queue may contain up to 1,000,000 items / 100 MB;
- item value maximum: 32 KB;
- data-structure request ceiling is documented at 100,000 request units/minute, with additional partition behavior;
- expiration may be at most 3,888,000 seconds;
- Roblox recommends short expirations, explicit cleanup, staggering and exponential backoff.

References:

- https://create.roblox.com/docs/cloud-services/memory-stores
- https://create.roblox.com/docs/cloud-services/memory-stores/best-practices
- https://create.roblox.com/docs/cloud-services/memory-stores/per-partition-limits

TA-14 consequence: MemoryStore is optional/transient, MonsterVault stays at a small fraction of the universe quota, and durable/value authority never depends on it.

## 4. Remote Transport

Authoritative references: Roblox Creator Hub — Remote Events and Callbacks / UnreliableRemoteEvent.

Current behavior relevant to TA-14:

- RemoteEvents are reliable one-way application transport;
- UnreliableRemoteEvents are intended for continuously changing/non-critical state where order/reliability are unnecessary;
- RemoteEvents and UnreliableRemoteEvents have an approximate shared throttle of 500 requests/second per client per remote type;
- UnreliableRemoteEvent payloads over 1000 bytes are dropped.

References:

- https://create.roblox.com/docs/scripting/events/remote
- https://create.roblox.com/docs/reference/engine/classes/UnreliableRemoteEvent

TA-14 consequence: MonsterVault uses much lower application-level request rates and a 768-byte unreliable payload ceiling.

## 5. Instance Streaming

Authoritative reference: Roblox Creator Hub — Instance Streaming.

Current recommended baseline:

- StreamingMinRadius default/recommendation: 64;
- StreamingTargetRadius default/recommendation: 1024;
- StreamingIntegrityMode recommendation: PauseOutsideLoadedArea;
- StreamOutBehavior recommendation: Opportunistic;
- Persistent/PersistentPerPlayer are for rare cases and overuse can hurt performance;
- streaming improves memory, join-time and server/client synchronization scaling.

Reference:

- https://create.roblox.com/docs/workspace/streaming

TA-14 consequence: MonsterVault adopts the current 64/1024/PauseOutsideLoadedArea/Opportunistic baseline and budgets Persistent use explicitly.

## 6. MessagingService

Authoritative reference: Roblox Creator Hub Messaging usage guide.

Current shared Engine/Open Cloud limits:

- publishes/server/minute: 600 + 240 × players in that server;
- receives/topic/minute: 40 + 80 × server count;
- receives/game/minute: 400 + 200 × server count;
- subscriptions/server: 20 + 8 × players;
- subscription requests/server/minute: 240;
- topic length: 80 characters;
- message length: 1024 characters.

Reference:

- https://create.roblox.com/docs/cloud/guides/usage-messaging

TA-14 consequence: coarse MonsterVault invalidation traffic is intentionally capped orders of magnitude below the platform maximum.

## 7. Snapshot Boundary

These values are a **dated platform snapshot**, not eternal MonsterVault truth.

TA-15/TA-17 must revalidate the platform documentation before implementation locking. If Roblox changes a ceiling/recommendation:

- stricter platform limits override this snapshot immediately;
- looser platform limits do **not** automatically relax MonsterVault budgets;
- relaxing a MonsterVault hard guardrail requires TA-14 change control and evidence.

**Platform snapshot result: PASS.**
