# GDS-8 Decision Index

> **Phase:** GDS-8 — Economy, Progression, Unlocks, and Pacing  
> **Status:** Accepted  
> **Purpose:** Phase-local record of strategic GDS-8 decisions and rationale. Detailed behavior remains authoritative in `economy_progression/08_economy_progression_unlocks_and_pacing.md`.

## GDS8-D01 — Energy Is the Single Baseline Soft Progression Currency

**Status:** Accepted

### Context

The project needs one understandable progression economy before trading, monetization, and live-content systems add complexity.

### Decision

**Energy** becomes the canonical baseline non-premium soft currency. It is persistent, non-negative, whole-unit player-facing value, separate from premium currency, and not baseline player-to-player transferable.

Progression Milestones are non-spendable proofs rather than a second currency.

### Rationale

One baseline currency minimizes cognitive load and balance fragmentation while still allowing active progression requirements that passive production cannot satisfy.

### Alternatives Rejected

- several launch soft currencies;
- premium-adjacent Energy;
- direct player-to-player Energy transfer before GDS-12;
- treating milestones as another spendable wallet.

### Affected Specifications

GDS-7 through GDS-16, Technical Architecture.

---

## GDS8-D02 — Passive Energy Cannot Replace Active Progression

**Status:** Accepted

### Context

GDS-7 deliberately allows bounded passive/offline production. Without active progression gates, the optimal strategy could become waiting offline rather than exploring/capturing.

### Decision

Major progression may require persistent **Progression Milestones** earned through active gameplay in addition to Energy. Passive production can fund costs but cannot fabricate Species Discovery, capture/world milestones, or other active proofs.

### Rationale

This preserves the product's active collection/adventure identity while retaining the retention/convenience value of the Vault.

### Alternatives Rejected

- Energy-only progression for every major gate;
- offline-generated milestone credit;
- raw connected-time milestones;
- paid fabrication of active history under GDS-8.

### Affected Specifications

GDS-1, GDS-3, GDS-7, GDS-8, GDS-9, GDS-11, GDS-13, GDS-16.

---

## GDS8-D03 — Ordinary Capture Uses Durable Capability, Not a Universal Per-Attempt Tax

**Status:** Accepted

### Context

A recurring currency charge on every ordinary capture could add friction to the core loop, punish experimentation/failure, and undermine first-session time-to-fun.

### Decision

Baseline capture progression is through persistent **Capture Capability** upgrades. Ordinary capture does not require a mandatory Energy payment for every attempt.

Starting capability supports the protected first capture without prior Energy grinding.

### Rationale

Durable progression creates clear sinks while keeping `find -> catch -> bring home` immediate and understandable.

### Alternatives Rejected

- Energy entry fee on every capture attempt;
- consumable-only capture progression;
- pre-capture onboarding grind;
- capability that bypasses claim/finalization authority.

### Affected Specifications

GDS-3, GDS-5, GDS-8, GDS-9, GDS-14.

---

## GDS8-D04 — Release and Repeated Capture Do Not Form a Baseline Minting Loop

**Status:** Accepted

### Context

If every secured creature could immediately be sold/released for Energy, optimal play could collapse into farming common creatures for liquidation and would change GDS-4 Release into an economy mechanic.

### Decision

Baseline GDS-4 **Release grants zero Energy**. Ordinary repeated Secured Ownership Finalization also does not automatically mint Energy.

First-time/milestone/objective rewards may reference legitimate capture outcomes when explicitly defined.

### Rationale

This protects collection attachment, prevents liquidation farming from dominating exploration, and preserves future authority for any deliberate salvage/sale mechanic.

### Alternatives Rejected

- fixed sale value by Species Rarity;
- Mutation/Legendary liquidation premiums;
- Energy reward on every capture;
- automatic duplicate conversion to currency.

### Affected Specifications

GDS-4, GDS-5, GDS-6, GDS-8, GDS-12.

---

## GDS8-D05 — Rarity/Mutation Prestige Is Economically Separate from Production Power

**Status:** Accepted

### Context

The historical concept draft proposed automatic rarity/mutation production multipliers, but closed GDS-6/GDS-7 authority now explicitly separates prestige/scarcity from power and production.

### Decision

Species may have authored Production Profiles and explicit Traits may provide bounded situational effects. Species Rarity, Mutation Frequency, Compound status, Protected Variant status, Availability, and Provenance do **not** automatically multiply Energy output.

### Rationale

Rare variants can remain desirable collection/status targets without becoming mandatory economic workers or creating pay-to-win-like scarcity pressure.

### Alternatives Rejected

- `base × rarityModifier × mutationModifier` as universal production formula;
- fixed Legendary income multiplier;
- automatic Compound/Extreme income bonus;
- hidden Event-Limited/Legacy production premium.

### Affected Specifications

GDS-6, GDS-7, GDS-8, GDS-13, GDS-16.

---

## GDS8-D06 — Persistent Economy Transactions Are Exact-Once and Atomic

**Status:** Accepted

### Context

Production Claims, upgrades, and access purchases exchange persistent value and can be retried or interrupted by normal network/server lifecycle.

### Decision

Every persistent Energy spend/progression purchase is an exact-once Finalized Outcome. From the player's perspective, cost and effect are atomic: one finalized cost yields one intended finalized effect; retry/reconnect cannot duplicate either.

Insufficient funds cause no partial deduction, already-owned one-time unlocks cannot be charged again, and changed prices cannot silently increase a confirmed charge.

### Rationale

Economy trust depends on transaction certainty, especially on mobile networks and across server transitions.

### Alternatives Rejected

- best-effort duplicate-prone spending;
- permanent deduction before effect certainty;
- duplicate charge for already-owned unlocks;
- silent higher price at commit.

### Affected Specifications

GDS-2, GDS-7, GDS-8, GDS-11, GDS-13, Technical Architecture.

---

## GDS8-D07 — Long-Term Progression Is Additive; No Baseline Prestige Wipe

**Status:** Accepted

### Context

Rebirth/prestige loops can extend numerical progression, but wiping collection/upgrades/access conflicts with MonsterVault's persistent collection promise and non-loss-dominant positioning.

### Decision

The baseline game has no prestige/rebirth system that wipes Energy, Vault upgrades, Access Unlocks, discoveries, or Secured Creatures for a multiplier.

Long-term progression expands through collection/variants, Vault/capability growth, world access, live content, presentation/status, and later social/trading systems.

### Rationale

This preserves attachment to earned value and avoids using destructive resets as an inflation/content substitute.

### Alternatives Rejected

- periodic rebirth that wipes creatures;
- seasonal reset of permanent Energy/upgrades;
- mandatory prestige to reach later regions;
- forced collection liquidation for permanent multipliers.

### Affected Specifications

GDS-1, GDS-4, GDS-7, GDS-8, GDS-11, GDS-16.

---

## GDS8-D08 — Catch-Up Compresses Obsolete Friction Without Fabricating History

**Status:** Accepted

### Context

A live game will accumulate old progression. New/returning players may need faster access to current content without invalidating existing players' history.

### Decision

Catch-up may visibly reduce old Energy costs, increase fixed old-content rewards, or streamline obsolete prerequisites for deterministic eligible cohorts. It cannot grant unearned Species/Mutation/Variant Discovery, event history, or active world milestones.

Catch-up cannot secretly depend on spending propensity.

### Rationale

Content aging remains manageable while collection/history integrity stays intact.

### Alternatives Rejected

- full automatic completion of old content;
- hidden spender-specific discounts;
- deleting veteran progress to reduce the gap;
- mandatory retroactive refund liability on every future price cut.

### Affected Specifications

GDS-8, GDS-9, GDS-11, GDS-13, GDS-16.

---

## GDS8-D09 — Close GDS-8 Economy, Progression, Unlocks, and Pacing Baseline

**Status:** Accepted

### Context

The GDS-8 authoritative specification now resolves baseline currency, source/sink categories, active/passive progression relationship, Vault/capture/access economics, transaction exactness, pacing, inflation, catch-up, rebalance rules, prestige position, and downstream authority. Scenario and cross-system validation pass.

### Decision

GDS-8 is formally closed as `Complete — PASS`.

Material changes to single-baseline-Energy semantics, non-transferability, Release/no-per-capture minting, active Milestone gating, no universal per-attempt capture tax, rarity-not-automatic-production-power, exact-once/atomic transactions, no arbitrary Energy wipe, or no-baseline-prestige-reset require GDS-8 change control and revalidation.

### Evidence

- `economy_progression/08_economy_progression_unlocks_and_pacing.md` — Design Complete;
- `GDS8_SCENARIO_VALIDATION.md` — 90 / 90 PASS;
- `GDS8_CROSS_VALIDATION.md` — PASS;
- `GDS8_CLOSURE_REPORT.md` — PASS.

### Consequence

The active dependency advances to **GDS-9 — World, Biomes, Exploration, Spawning, and Hazards**. Technical Architecture and gameplay implementation remain blocked.
