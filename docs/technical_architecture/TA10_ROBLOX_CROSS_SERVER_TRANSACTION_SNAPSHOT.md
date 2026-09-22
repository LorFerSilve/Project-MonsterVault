# TA-10 Roblox Cross-Server, Persistence, Social, and Transaction Platform Snapshot

> **Review date:** 2026-09-23  
> **Status:** PASS  
> **Purpose:** Record current Roblox platform behavior relevant to TA-10 MessagingService, MemoryStoreService, persistent DataStore transactions, friendship queries and cross-server coordination.

## 1. MessagingService

Official source:

https://create.roblox.com/docs/reference/engine/classes/MessagingService

Current relevant API:

- `PublishAsync(topic, message)`;
- `SubscribeAsync(topic, callback)`;
- MessagingService is a server communication service and is not replicated to clients.

TA-10 consequence:

> MessagingService is used only as a low-latency cross-server notification/invalidation mechanism. EventOccurrence durability and player outcomes do not depend on one message being observed.

## 2. Cross-Server Messaging Use Case

Official source:

https://create.roblox.com/docs/cloud-services/cross-server-messaging

Roblox documents MessagingService for communication between separate live servers, including global announcements and live server information.

TA-10 consequence:

> A newly created/changed EventOccurrence may publish a refresh hint so servers react quickly, but servers still reconstruct authority from validated schedule/config or durable occurrence state.

## 3. MemoryStoreService

Official source:

https://create.roblox.com/docs/cloud-services/memory-stores

Memory Stores provide low-latency, high-throughput shared data across live servers.

Roblox explicitly positions them for frequent ephemeral data that does not require durable persistence.

Data structures include:

- hash maps;
- sorted maps;
- queues.

Items expire according to TTL/expiration semantics and service quotas apply.

TA-10 consequence:

> MemoryStore can accelerate short-lived event coordination/cache/liveness, but disappearance, expiry or throttling must not delete durable rewards, ownership, trade decisions or authoritative occurrence history.

## 4. MemoryStore Hash Maps

Official source:

https://create.roblox.com/docs/reference/engine/classes/MemoryStoreHashMap

Relevant methods include:

- `GetAsync`;
- `SetAsync`;
- `UpdateAsync`;
- `RemoveAsync`;
- `ListItemsAsync`.

Entries use explicit expiration.

TA-10 consequence:

> If TA-14/17 justifies an active-occurrence cache or liveness map, HashMap is the preferred unsorted key-addressed primitive. It remains a cache/coordination layer only.

## 5. Memory Store Scaling

Official sources:

https://create.roblox.com/docs/cloud-services/memory-stores/best-practices

https://create.roblox.com/docs/cloud-services/memory-stores/per-partition-limits

Current guidance:

- memory-store request quotas are experience-level;
- TTL should be as short as practical;
- unused items should be removed;
- hash maps distribute keys across partitions and generally scale better than sorted maps/queues when ordering is unnecessary;
- hot individual keys may still throttle;
- sharding may be necessary for high-throughput workloads.

TA-10 consequence:

> TA-10 avoids one globally hot mutable event-progress key and does not require MemoryStore for ordinary Party/trade correctness. Exact quotas/sharding are deferred to TA-14.

## 6. Standard DataStore UpdateAsync

Official source:

https://create.roblox.com/docs/cloud-services/data-stores

Current behavior:

- `UpdateAsync` reads the current value and computes a replacement value;
- its transform callback cannot yield;
- it is appropriate when writes depend on current value or multiple servers may contend for one key.

TA-10 consequence:

> Each Trade participant profile transition and transaction-journal transition is an idempotent per-key UpdateAsync transform.

## 7. DataStore Atomicity Boundary

Official source:

https://create.roblox.com/docs/cloud-services/data-stores/best-practices

Roblox guidance recommends keeping data that must change atomically in the same key and using one/few keys per player where practical.

TA-4 already established that standard DataStore offers no general all-keys transaction primitive.

TA-10 consequence:

> A two-player trade cannot be implemented as two unrelated sequential profile saves. The durable journal and transaction-fence protocol provides recoverable logical atomicity across the two profile keys.

## 8. DataStore Retry and Unknown Outcome

Official sources:

https://create.roblox.com/docs/cloud-services/data-stores/best-practices

https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits

Current guidance emphasizes:

- transient failures should be retried with bounded backoff/jitter;
- writes can have an unknown outcome from the caller's perspective;
- UpdateAsync consumes read and write budgets;
- request queues/throughput are finite.

TA-10 consequence:

> Every journal/participant mutation is idempotent and keyed by stable TradeTransactionId. A failed response never authorizes creating a second logical transaction.

## 9. DataStore Entry Size

Official source:

https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits

Current standard DataStore entry payload maximum is documented as 4,194,304 characters/bytes-equivalent serialized limit per key.

TA-10 consequence:

> Trade journal records are bounded by small offer caps and contain only the canonical creature/transaction facts required for deterministic recovery. Full logs/history are not copied indefinitely.

## 10. Friendship Query APIs

Official sources:

https://create.roblox.com/docs/reference/engine/classes/Players

https://create.roblox.com/docs/reference/engine/classes/Player

Current APIs include:

- `Players:GetFriendsAsync(userId)`;
- `Player:IsFriendsWithAsync(userId)`.

TA-10 consequence:

> Platform friendship can support invitation/visitor filtering, but the result is never Party membership, reward eligibility, Trade consent or ownership authority.

## 11. Platform APIs Not Used as Durable Trade Authority

TA-10 does not use:

- MessagingService message receipt as commit evidence;
- MemoryStore item existence as creature ownership;
- client UI state as consent truth;
- friendship as transfer permission;
- a queue/sorted-map item as a durable Trade Commit.

The transaction journal and Player Profile transforms remain the durable source.

## 12. Baseline Cross-Server Architecture Result

Scheduled Event Occurrences can function from shared wall-clock schedule/config with no live cross-server coordinator.

Dynamic globally authorized occurrences use durable occurrence state first, with MessagingService for fast refresh.

MemoryStore is optional and justified only where ephemeral acceleration is measured to be useful.

Baseline Parties and Trade negotiation remain same-server.

## Verdict

**TA-10 ROBLOX CROSS-SERVER / PERSISTENCE / SOCIAL / TRANSACTION PLATFORM SNAPSHOT: PASS.**
