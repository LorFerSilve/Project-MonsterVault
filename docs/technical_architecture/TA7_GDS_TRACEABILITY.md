# TA-7 GDS and Upstream TA Traceability

> **Phase:** TA-7 — Capture, Creature Ownership, Mutation, and Reward Resolution  
> **Status:** PASS

## 1. Traceability

| Source | Requirement consumed | TA-7 technical response | Result |
|---|---|---|---|
| TA-0 authority | rewards/ownership/random results server-owned | capture + variant + finalization authority server-only | PASS |
| TA-0 exact-once | finalized outcomes once | ownershipFinalizationOperationId + P2 idempotency | PASS |
| TA-2 application orchestration | cross-domain transaction above domains | capture coordinator sequences runtime/capacity/persistence | PASS |
| TA-3 intent-only networking | client cannot submit success | challenge input only; server terminal result | PASS |
| TA-3 retry | request ID not durable authority | stable capture operation ID | PASS |
| TA-3 physics/prompts | server context validation | claim/Secure Point validate target, state, spatial context | PASS |
| TA-4 P2 | ownership durable-before-final-ack | Secured emitted after profile commit | PASS |
| TA-4 operation IDs | server-owned durable identity | one finalization op generated at Provisional transition | PASS |
| TA-5 content snapshot | probabilities one coherent snapshot | Variant/capture resolution pin validated snapshot | PASS |
| TA-5 stable IDs | semantic identity stable | Species/Mutation/Trait/Creature IDs preserved | PASS |
| TA-6 entity lifecycle | one stable World Creature | TA-7 mutates acquisition substate only | PASS |
| TA-6 idle despawn protection | acquisition blocks despawn | claim/attempt/provisional/custody own lifecycle | PASS |
| GDS-4 one secured owner | one creature one owner | one intended owner in P2 commit | PASS |
| GDS-4 same Creature Instance | secured identity stable | no new CreatureInstanceId on finalization | PASS |
| GDS-4 overflow race safety | value retained | capacity race -> Overflow-Held | PASS |
| GDS-4 Creature Lock | high-value protection | Protected auto-lock in same P2 commit | PASS |
| GDS-5 single ordinary claim | one active claim | serialized per-creature arbitration | PASS |
| GDS-5 claim != ownership | transient claim only | no profile mutation at claim | PASS |
| GDS-5 capture success provisional | no ownership yet | Provisional + custody runtime only | PASS |
| GDS-5 one custody/player | baseline singular | eligibility checks existing active custody | PASS |
| GDS-5 Recovery not extraction | reset interrupts | no ownership on recovery | PASS |
| GDS-5 disconnect grace | bounded same-session resume | server-local grace, same-server only | PASS |
| GDS-5 voluntary leave | custody ends | explicit trusted voluntary-exit path ends custody | PASS |
| GDS-5 controlled shutdown | valid custody can secure once | server drain snapshot + same P2 op | PASS |
| GDS-5 abrupt crash | no guaranteed finalization | runtime provisional not persisted | PASS |
| GDS-5 capacity recheck | no race deletion | start block + final Overflow-Held fallback | PASS |
| GDS-6 variant before actionability | anti-reroll | one-time Variant generation before public actionable state | PASS |
| GDS-6 0–2 mutations | baseline limit | generator enforces max two | PASS |
| GDS-6 compatibility | authored compatible compounds | private registry compatibility filter | PASS |
| GDS-6 order-independent signature | A+B == B+A | canonical sorted Mutation set | PASS |
| GDS-6 Trait persistence | same instance traits | immutable Variant Identity | PASS |
| GDS-6 no post-claim reroll | same survivor unchanged | generator cannot re-enter for existing instance | PASS |
| GDS-6 no spending odds | fairness | commercial state excluded from RNG inputs | PASS |
| GDS-6 discovery on security | persistent discovery | same P2 bundle | PASS |
| GDS-6 Protected criteria | auto-lock | exact criteria applied at first security | PASS |
| GDS-8 no baseline capture Energy | no implicit payout | ordinary outcome is creature/discovery only | PASS |
| GDS-8 capture capability | progression can affect challenge | validated TA-8 input, no ownership bypass | PASS |
| GDS-9 prospective spawn context | future instances only | one-time generation snapshot | PASS |
| GDS-9 claim protects lifetime | no idle despawn | TA-7 owns acquisition state | PASS |
| GDS-11 personal multi-award | distinct instances | TA-10 allocates distinct opportunities; TA-7 resolves separately | PASS |
| GDS-13 no paid luck/priority | commercial fairness | premium state absent from odds/arbitration | PASS |
| GDS-14 provisional vs secured feedback | truthful state | distinct projection states | PASS |
| GDS-17 zero semantic gaps | no mechanics invented | TA-7 implements closed semantics | PASS |

## 2. Downstream Routing

| TA-7 contract | Refining owner |
|---|---|
| capacity/Overflow/Capture Capability schema | TA-8 |
| species spawn selection/Secure Point index | TA-9 |
| event multi-award overrides/rewards | TA-10 |
| capture UI/input/reveal feedback | TA-12 |
| telemetry/live tuneables | TA-13 |
| timing/rate/perf budgets | TA-14 |
| concurrency/statistical/fault tests | TA-15 |
| concrete APIs/modules/remotes | TA-17 |

## 3. Critical Invariants

### T7-TR-01

One surviving CreatureInstanceId gets one Variant Identity; capture retries never reroll it.

### T7-TR-02

Claim, Capture Success and Provisional Capture are not persistent ownership.

### T7-TR-03

Secured Ownership is emitted only after exact-once P2 durability succeeds.

### T7-TR-04

The persistent creature is the same CreatureInstanceId that existed in the world.

### T7-TR-05

No client-provided success/random/custody/extraction field is authoritative.

### T7-TR-06

Capacity race after valid initiation cannot delete the creature; Overflow-Held protects it.

### T7-TR-07

Protected Variant auto-lock commits atomically with first security.

### T7-TR-08

Controlled shutdown protection cannot be player-spoofed and does not apply to pre-success attempts or disconnected grace.

## 4. Gaps

Unmapped relevant GDS capture/variant requirements: **0**.

Unmapped TA-0..6 authority/persistence/identity/runtime obligations: **0**.

Downstream technical dependencies without an owner: **0**.

## Verdict

**TA-7 GDS / UPSTREAM TA TRACEABILITY: PASS.**
