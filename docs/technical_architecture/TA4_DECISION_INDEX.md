# TA-4 Decision Index

> **Phase:** TA-4 — Player Data, Persistence, Session Ownership, Schema Evolution, and Recovery  
> **Status:** Accepted

## TA4-D01 — Standard DataStoreService Is Durable Player Authority

**Decision:** Player profiles use standard Roblox DataStores. MemoryStore and OrderedDataStore are not profile truth.

---

## TA4-D02 — Use One Player Profile Aggregate Per User at Baseline

**Decision:** Related player-local persistent state stays in one aggregate/key while profile size and throughput remain safely within TA-14 budgets.

**Consequence:** Single-player transactions can remain atomically coherent under one UpdateAsync.

---

## TA4-D03 — Session Ownership Uses an Atomic DataStore Metadata Lease

**Decision:** Profile acquisition/read/write uses UpdateAsync with compact lease metadata. At most one server owns writable session authority.

**Consequence:** Fresh foreign locks are never force-stolen; stale locks may be reclaimed after expiry.

---

## TA4-D04 — Player Profile Writes Use UpdateAsync Through One Repository

**Decision:** Domains never call DataStore directly and the profile mutation primitive is not blind SetAsync.

**Consequence:** Lease metadata/revision validation and retry policy remain centralized.

---

## TA4-D05 — Load Failure Is Never Equivalent to Missing Profile

**Decision:** A failed DataStore request cannot create a writable default profile over unknown prior state.

**Consequence:** ProtectedLoadFailure preserves historical value.

---

## TA4-D06 — Persistent Mutations Use P0/P1/P2 Durability Classes

**Decision:**

- P0: session-only;
- P1: buffered durable;
- P2: durable-before-final-ack.

GDS Finalized Outcomes and critical player value are P2.

---

## TA4-D07 — Durable Profile Writes Are Revisioned and Serialized

**Decision:** One writer pipeline per profile key tracks a monotonic durable profileRevision and refuses unexpected lock/revision state.

---

## TA4-D08 — Schema Migrations Are Sequential, Pure, and Fail Closed

**Decision:** Profiles carry schemaVersion. Older supported versions migrate deterministically; newer-than-server versions are never downgraded.

---

## TA4-D09 — Server-Owned Operation IDs Provide Durable Exact-Once Identity

**Decision:** TA-3 client request IDs remain correlation keys. Persistent value mutations use server-owned operation IDs and bounded/dedicated durable ledgers as required.

---

## TA4-D10 — Cross-Profile Atomicity Requires a Durable Transaction Protocol

**Decision:** Roblox has no generic multi-key atomic DataStore transaction. Trade and similar flows may not use naive sequential participant saves.

**Consequence:** TA-10 must use a transaction journal/commit/recovery state machine.

---

## TA4-D11 — DataStore Version History Is Operational Recovery, Not Runtime Auto-Rollback

**Decision:** Corrupt/invalid profiles fail protected; operator-controlled version recovery is explicit and auditable.

---

## TA4-D12 — Native First-Party Persistence Repository Is the Baseline

**Decision:** TA-4 does not introduce a third-party profile/persistence library.

**Consequence:** Any future ProfileStore/ProfileService-equivalent dependency requires TA-1 supply-chain review and TA-4 semantic compatibility review.

---

## TA4-D13 — Critical Shutdown Saves Run in Parallel Across Players, Serialized Per Player

**Decision:** BindToClose drains player-value saves within the platform deadline while preserving one-writer semantics per profile.

---

## TA4-D14 — Close TA-4 and Advance to TA-5

**Decision:** TA-4 is Architecture Complete — PASS with 180/180 scenarios and zero blocking questions. TA-5 becomes NEXT; gameplay implementation remains blocked.
