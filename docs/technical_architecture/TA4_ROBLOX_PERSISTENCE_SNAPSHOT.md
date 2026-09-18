# TA-4 Roblox Persistence Platform Snapshot

> **Review date:** 2026-09-18  
> **Status:** PASS  
> **Purpose:** Record the current Roblox DataStore/MemoryStore/shutdown behavior used when TA-4 locked the persistence architecture.  
> **Note:** This is dated platform evidence. TA-15/TA-17 and launch readiness must re-check current Roblox limits/API behavior if the platform changes.

## 1. Standard DataStores

Official source:

https://create.roblox.com/docs/cloud-services/data-stores

Current platform behavior reviewed:

- DataStoreService persists long-lived experience data across sessions and servers;
- standard DataStores support metadata and versioning;
- values are stored per key;
- DataStore operations are server-side cloud operations;
- Studio access to a live experience's DataStores can affect the same live data and should not be casually enabled for production.

TA-4 consequence:

> Standard DataStoreService is the durable Player Profile authority. DEV/STAGING/PRODUCTION are isolated and ordinary Studio development must not point at production player data.

## 2. UpdateAsync vs SetAsync

Official sources:

https://create.roblox.com/docs/cloud-services/data-stores  
https://create.roblox.com/docs/cloud-services/data-stores/best-practices

Current official guidance:

- `SetAsync()` can overwrite another server's newer value if two servers write the same key;
- `UpdateAsync()` reads the current key state before applying a transform and is preferred for concurrent-safe updates;
- returning nil from the transform cancels the write;
- the transform callback cannot yield;
- `UpdateAsync()` consumes both read and write request budgets.

TA-4 consequence:

> The Player Profile write primitive is `UpdateAsync()`, not blind `SetAsync()`.

## 3. Session Locking

Official player-data/purchasing guidance:

https://create.roblox.com/docs/cloud-services/data-stores/player-data-purchasing

Current Roblox guidance describes session locking by:

- storing player data server-locally during the active session;
- acquiring a lock atomically when the profile key is read;
- storing a LockId in DataStore key metadata;
- making profile access pass through `UpdateAsync()`;
- refusing access when an unrecognized fresh LockId exists;
- allowing a stale/expired lock to be reclaimed;
- renewing the lock through periodic DataStore access;
- releasing the lock with the final save.

TA-4 consequence:

> MonsterVault uses the same fundamental atomic metadata-lease model, while integrating it with TA-0/TA-3 server-authority, revision, migration and protected-failure contracts.

## 4. Metadata

Official source:

https://create.roblox.com/docs/cloud-services/data-stores

Current behavior:

- standard DataStore keys can carry user-defined metadata;
- `UpdateAsync()` exposes DataStoreKeyInfo to the transform;
- writes must explicitly return/preserve metadata or prior metadata can be lost.

Current documented metadata limits:

- metadata key name: up to 50 characters;
- individual value: up to 250 characters;
- total key/value metadata size: 300 characters.

TA-4 consequence:

> Session metadata remains deliberately compact and all Player Profile writes go through one repository that preserves/renews the lease metadata.

## 5. Data Limits

Official source:

https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits

Current documented per-entry maximum:

- **4,194,304 characters** of serialized key value.

Current DataStore names/keys/scopes also have bounded lengths.

TA-4 consequence:

- one player aggregate remains preferred while measured size is comfortably below a TA-14 safety budget;
- profile size is observable;
- sharding is not adopted prematurely and would require TA-4 revalidation.

## 6. Request / Throughput Limits

Official source:

https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits

Current platform behavior includes:

- experience-level request budgets;
- per-key/data-store throughput limits;
- throttling/error queues;
- `UpdateAsync()` consuming both read and write budgets;
- Open Cloud and in-experience traffic sharing relevant limits;
- per-key throughput accounting over recent time windows.

TA-4 consequence:

- data is buffered server-locally;
- autosaves are staggered;
- ordinary reads do not hit DataStore repeatedly;
- P2 critical checkpoints are budgeted explicitly by TA-14.

## 7. Player Data Buffering / Autosave

Official source:

https://create.roblox.com/docs/cloud-services/data-stores/best-practices

Current official guidance recommends:

- load player data at session start;
- keep an in-memory server-local copy;
- mutate that local copy instead of making a cloud request for every change;
- save periodically;
- save when the player leaves;
- save during server shutdown;
- save at critical checkpoints such as purchase processing;
- keep periodic save interval shorter than session-lock expiry;
- stagger recurring saves.

TA-4 consequence:

> MonsterVault uses an in-memory working profile, periodic lease-renewing autosave, final save/unlock and immediate P2 checkpoints where GDS requires durable finalization.

## 8. BindToClose

Official source:

https://create.roblox.com/docs/reference/engine/classes/DataModel#BindToClose

Current documented behavior:

- `game:BindToClose()` callbacks run when the server shuts down;
- multiple callbacks run in parallel;
- the server waits **30 seconds** for bound functions before shutdown completes;
- Roblox explicitly recommends using BindToClose with DataStore saving.

TA-4 consequence:

- shutdown persistence has a hard bounded deadline;
- saves run in parallel across different player keys;
- operations remain serialized within each player's key;
- periodic checkpoints remain necessary because abrupt crashes may bypass graceful shutdown.

## 9. Version History

Official sources:

https://create.roblox.com/docs/cloud-services/data-stores/versioning-listing-and-caching  
https://create.roblox.com/docs/cloud-services/data-stores/data-stores-manager

Current behavior reviewed:

- standard DataStore writes generate historical versions;
- previous versions are available for a bounded retention window;
- Creator Hub Data Stores Manager can inspect key metadata/version history and compare/revert versions;
- revert creates a new current version rather than mutating history invisibly.

TA-4 consequence:

> Version history is an operational recovery tool, not an automatic gameplay rollback algorithm.

## 10. GetAsync Caching

Official source:

https://create.roblox.com/docs/cloud-services/data-stores

Current documentation warns that values obtained through `GetAsync()` can be affected by caching/staleness.

TA-4 consequence:

> Player session acquisition does not rely on a plain cached `GetAsync()` as authoritative lock/load. It uses `UpdateAsync()` to read/claim ownership atomically.

## 11. MemoryStore

Official sources:

https://create.roblox.com/docs/cloud-services/memory-stores  
https://create.roblox.com/docs/cloud-services/data-stores-vs-memory-stores

Current platform behavior:

- MemoryStore is high-throughput, low-latency and cross-server;
- records are temporary and TTL-based;
- MemoryStore items can expire and are subject to memory/request quotas;
- Roblox recommends DataStores for data that must persist between sessions.

TA-4 consequence:

> MemoryStore may later accelerate ephemeral cross-server coordination but is not Player Profile or session-lock authority.

## 12. Current Platform Fit

The official platform model supports TA-4's decisions:

- DataStore Player Profile aggregate;
- atomic `UpdateAsync()` lease + write;
- compact metadata session lock;
- in-memory buffering;
- periodic staggered autosave;
- critical checkpoints;
- graceful leave/shutdown save;
- explicit failure/retry;
- bounded profile size;
- operational version recovery;
- MemoryStore only for non-durable coordination.

## Verdict

**TA-4 ROBLOX PERSISTENCE PLATFORM SNAPSHOT: PASS.**
