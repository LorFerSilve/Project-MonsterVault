# GDS-7 Decision Index

> **Phase:** GDS-7 — Vault/Base, Passive Production, Capacity, and Upgrades  
> **Status:** Accepted  
> **Purpose:** Phase-local record of strategic GDS-7 decisions and rationale. Detailed behavior remains authoritative in `vault/07_vault_base_passive_production_capacity_and_upgrades.md`.

## GDS7-D01 — Capacity Pressure Must Restrict Use, Never Destroy Ownership

**Status:** Accepted

### Context

MonsterVault needs collection-capacity progression, but a capacity system that deletes or silently converts creatures would contradict GDS-1 collection trust and GDS-4 ownership safety.

### Decision

Collection Capacity limits ordinary usable collection state, not basic ownership. GDS-4 `Overflow-Held` remains the baseline safety state. Effective capacity reduction invokes deterministic visible **Capacity Reconciliation** and never silently Releases, sells, merges, or deletes a Secured Creature.

### Rationale

Capacity can remain a meaningful progression/economy lever without making already-earned collectibles hostage to upgrades, entitlement expiry, or configuration changes.

### Alternatives Rejected

- auto-selling excess creatures;
- deleting newest/oldest creatures;
- allowing unlimited hidden storage that bypasses capacity;
- forcing immediate paid expansion to preserve ownership.

### Affected Specifications

GDS-4, GDS-5, GDS-7, GDS-8, GDS-13, Technical Architecture.

---

## GDS7-D02 — Passive Production Uses Exact-Instance Assignments and a Bounded Buffer

**Status:** Accepted

### Context

The Vault needs passive progression value without turning creature ownership into duplicated worker tokens or an unbounded idle economy.

### Decision

Passive Production requires a persistent one-slot/one-Creature-Instance **Production Assignment**. Valid elapsed production accrues into a bounded persistent **Production Buffer**. Buffer saturation pauses further accrual until value is claimed or capacity changes.

One Creature Instance cannot occupy multiple Production Slots, and Overflow-Held creatures cannot produce.

### Rationale

This preserves Creature Instance identity, gives assignment choices meaning, bounds idle accumulation, and creates clear technical exactness requirements without prescribing architecture.

### Alternatives Rejected

- species-count-based production that ignores instance identity;
- unlimited unclaimed production debt;
- allowing overflow as free worker storage;
- cloning one owned creature into multiple production slots.

### Affected Specifications

GDS-4, GDS-6, GDS-7, GDS-8, Technical Architecture.

---

## GDS7-D03 — Offline Production Is Allowed, but It Is Capped Elapsed-Time Accrual, Not Offline World Presence

**Status:** Accepted

### Context

GDS-2 deliberately leaves room for bounded offline progression while prohibiting assumed offline live-world claims. The product also targets flexible 3–25 minute sessions and should not pressure players to stay AFK-connected merely to preserve passive value.

### Decision

Finalized Production Assignments may continue generating while the player is absent, but only until the configured **Offline Production Window** or Production Buffer cap is reached.

Offline production:

- uses elapsed time rather than simulated world presence;
- creates no creature/event/world claims;
- does not reset through server hopping or device change;
- cannot replay the same elapsed interval;
- does not secretly use spending-based personalized rates;
- does not make baseline AFK connection inherently superior through a hidden online-only passive multiplier.

### Rationale

The model supports retention and flexible sessions while keeping value bounded, auditable, and implementation-feasible.

### Alternatives Rejected

- no offline production at all;
- unlimited offline accrual;
- persistent offline avatars/workers in live servers;
- server-hop reset of offline caps;
- hidden AFK-only full-rate production.

### Affected Specifications

GDS-2, GDS-7, GDS-8, GDS-11, GDS-13, GDS-16, Technical Architecture.

---

## GDS7-D04 — Production Claims and Vault Upgrades Are Exact-Once Finalized Outcomes

**Status:** Accepted

### Context

Claims and upgrades exchange persistent value and are vulnerable to retry, reconnect, double-submit, and uncertain-network-state duplication.

### Decision

A **Production Claim** transfers eligible Production Buffer value exactly once. A **Vault Upgrade** applies exactly once. Claim/upgrade retries must resolve to one finalized result, and player-facing cost/effect semantics are atomic: permanent cost cannot be lost without the intended finalized effect, and one finalized cost cannot grant repeated effects.

### Rationale

This extends GDS-2 Finalized Outcome semantics to the first persistent economy-adjacent subsystem before Technical Architecture chooses transaction mechanisms.

### Alternatives Rejected

- best-effort duplicate-prone claims;
- optimistic permanent cost removal before upgrade certainty;
- reconnect-based regranting;
- client-local upgrade authority.

### Affected Specifications

GDS-2, GDS-7, GDS-8, GDS-13, Technical Architecture.

---

## GDS7-D05 — Rarity and Mutation Prestige Do Not Automatically Become Production Power

**Status:** Accepted

### Context

GDS-6 explicitly separates rarity, Mutation, Trait, Availability, power, and price. Vault production could accidentally collapse those axes by assigning automatic income multipliers to every rare or visually prestigious creature.

### Decision

Species Rarity, Mutation Frequency, Compound-Mutated status, Protected Variant status, provenance, and Availability do not automatically multiply passive production.

A Species may have an authored Production Profile. Explicit Traits may create bounded situational production differences under GDS-8 balance authority. Any Mutation-specific mechanical hook requires explicit compatible authority rather than being inferred from prestige.

### Rationale

Rare variants remain desirable status/collection targets without becoming economically mandatory or converting the collection game into a single “highest rarity = best worker” ladder.

### Alternatives Rejected

- fixed production multipliers by Species Rarity tier;
- automatic Mutation/Compound income bonuses;
- hidden Legacy/Event-Limited production premiums;
- one universally dominant production Trait.

### Affected Specifications

GDS-6, GDS-7, GDS-8, GDS-13, GDS-16.

---

## GDS7-D06 — Baseline Visitors Are Read-Only

**Status:** Accepted

### Context

A visible personal Vault supports social status, but granting visitors management authority would introduce theft/griefing/value-transfer behavior before GDS-10/GDS-12 define those systems.

### Decision

Baseline visitors may inspect explicitly public display content but cannot move creatures, alter assignments, claim output, buy upgrades, unlock/release creatures, or otherwise mutate the owner's persistent state. Observation does not grant Species/Mutation/Variant Discovery.

### Rationale

This captures social flex/status value immediately while deferring cooperative permissions and ownership transfer to their correct phases.

### Alternatives Rejected

- visitor-accessible production claims;
- informal creature borrowing/dropping;
- discovery credit from viewing another player's collection;
- shared management by default.

### Affected Specifications

GDS-4, GDS-6, GDS-7, GDS-10, GDS-12, GDS-14.

---

## GDS7-D07 — Close GDS-7 Vault/Base Baseline

**Status:** Accepted

### Context

The GDS-7 authoritative specification now resolves Vault authority, Collection Capacity, overflow reconciliation, placement, production assignments, passive/offline accrual, Production Buffer/claims, upgrades, Secure Point integration, onboarding, visitors, failure/recovery, abuse constraints, presentation/accessibility obligations, and downstream boundaries. Scenario and cross-system validation pass.

### Decision

GDS-7 is formally closed as `Complete — PASS`.

Material changes to non-destructive capacity reconciliation, one-instance/one-production-assignment semantics, bounded offline production, Production Buffer saturation, exact-once claims/upgrades, post-finalization Vault ordering, baseline read-only visitors, or rarity-not-automatic-production-power require GDS-7 change control and revalidation.

### Evidence

- `vault/07_vault_base_passive_production_capacity_and_upgrades.md` — Design Complete;
- `GDS7_SCENARIO_VALIDATION.md` — 80 / 80 PASS;
- `GDS7_CROSS_VALIDATION.md` — PASS;
- `GDS7_CLOSURE_REPORT.md` — PASS.

### Consequence

The active dependency advances to **GDS-8 — Economy, Progression, Unlocks, and Pacing**. Technical Architecture and gameplay implementation remain blocked.
