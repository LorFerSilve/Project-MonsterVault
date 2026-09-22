# TA-9 Decision Index

> **Phase:** TA-9 — World, Biomes, Spawn Scheduling, Streaming, and Encounter Scaling  
> **Status:** Accepted

## TA9-D01 — Launch World Remains One Primary Gameplay Place

**Decision:** Home Hub, Starter, both Mid Biomes and Advanced Biome are logical Regions in the primary gameplay place at baseline. Ordinary progression does not require TeleportService or a second place.

---

## TA9-D02 — Build an Immutable Validated World Authoring Index

**Decision:** TA-5 registries plus disclosure-safe Studio tags/attributes are validated at bootstrap into one immutable server-side World Authoring Index. Unknown, conflicting or incomplete required world references fail bootstrap closed.

---

## TA9-D03 — Ordinary Spawning Uses One Centralized Staggered Scheduler

**Decision:** Spawn work is coordinated by one server-owned scheduler partitioned into bounded Habitat/area queues. MonsterVault does not run one permanent loop per spawn point or per creature.

---

## TA9-D04 — Population Scaling Changes Opportunity Count, Not Personalized Odds

**Decision:** Active population and server pressure may adjust encounter counts within authored min/base/max envelopes. They cannot alter Species/Variant odds per player, payer status, device or monetization behavior.

---

## TA9-D05 — A Spawn Reservation Fixes Creature Identity Before Materialization

**Decision:** Each authorized ordinary spawn creates one reservation that pins Spawn Context/config snapshot, Species, CreatureInstanceId and complete TA-7 Variant Identity before Roblox projection materialization. Placement/projection retries reuse that identity.

---

## TA9-D06 — Ordinary World Cycle Is Derived from a Shared Time Epoch

**Decision:** Baseline cycle phase is calculated from server-observed time plus a versioned epoch/cycle definition. Joining or server hopping does not reset the cycle.

---

## TA9-D07 — Ordinary Encounter Populations Are Server-Session Local

**Decision:** Public ordinary encounters, reservations and population counters are local to one server session. Baseline ordinary spawning requires no MemoryStoreService, MessagingService or global rare-spawn ledger.

---

## TA9-D08 — Instance Streaming Is Enabled but Never Authoritative

**Decision:** Workspace instance streaming is the baseline world-performance model. Client Workspace residency cannot grant/revoke access, encounter existence, progression, rewards or ownership.

---

## TA9-D09 — Persistent Streaming Modes Are Exceptional

**Decision:** Default streaming is preferred for ordinary content; Atomic may be used for self-contained interaction models. Persistent and PersistentPerPlayer require a narrow, measured justification and never become semantic authority.

---

## TA9-D10 — Fast Travel Is a Server-Validated State Transition

**Decision:** Fast travel validates node discovery, Region access, current Character generation and absence of Acquisition-In-Progress. RequestStreamAroundAsync may prepare presentation but never authorizes the transition.

---

## TA9-D11 — Scheduling Uses Static/Coarse Spatial Indexing Before Physics Queries

**Decision:** Static world data is indexed at bootstrap and relevant runtime entities use coarse spatial buckets. Localized WorldRoot queries are used only after candidate narrowing; global per-frame Workspace scans are prohibited.

---

## TA9-D12 — Persistent World Progression and Rewards Are Exact-Once P2 Outcomes

**Decision:** First Landmark Discovery, final Field Objective completion, Region Mastery and attached one-time Energy rewards use stable operation identities and Player Profile P2 finalization.

---

## TA9-D13 — Hazard Consequences Are Server-Validated

**Decision:** Client reports and Touched/physics signals may be inputs, but are not sole authority for meaningful hazard consequences. Recovery is idempotent per Character generation and cannot destroy secured value.

---

## TA9-D14 — Load Shedding Preserves Fairness and Valuable State

**Decision:** Under pressure, MonsterVault defers scheduler work and reduces ordinary refill/optional updates before weakening access validation, P2 correctness, active acquisition protection or Protected Variant stability.

---

## TA9-D15 — Close TA-9 and Advance to TA-10

**Decision:** TA-9 is Architecture Complete — PASS with 240/240 scenarios and zero blocking questions. TA-10 becomes NEXT; gameplay implementation remains blocked until TA-17.
