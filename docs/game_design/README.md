# MonsterVault Game Design Specification

> **Status:** GDS-0 through GDS-8 Complete / GDS-9 Next  
> **Authority:** Player-facing gameplay behavior

This directory contains the authoritative Game Design Specification (GDS) for MonsterVault.

The purpose of the GDS is to define what the game does before implementation decisions are allowed to harden the design accidentally.

## Current Gate

Completed:

- **GDS-0 — Governance, Structure, and Concept Baseline: COMPLETE — PASS**
- **GDS-1 — Product Vision, Audience, and Success Criteria: COMPLETE — PASS**
- **GDS-2 — Global Game Rules and Session Model: COMPLETE — PASS**
- **GDS-3 — Player Character, Interaction, and Onboarding: COMPLETE — PASS**
- **GDS-4 — Creatures, Collection, and Ownership: COMPLETE — PASS**
- **GDS-5 — Capture, Contesting, Transport, and Extraction: COMPLETE — PASS**
- **GDS-6 — Rarity, Mutations, Traits, and Variant Value: COMPLETE — PASS**
- **GDS-7 — Vault/Base, Passive Production, Capacity, and Upgrades: COMPLETE — PASS**
- **GDS-8 — Economy, Progression, Unlocks, and Pacing: COMPLETE — PASS**

The active dependency is now:

> **GDS-9 — World, Biomes, Exploration, Spawning, and Hazards**

Technical Architecture and gameplay implementation remain blocked.

## Governance

- [`00_design_authority.md`](00_design_authority.md) — authority, statuses, completion/change-control rules and gates.
- [`GDS_ROADMAP.md`](GDS_ROADMAP.md) — dependency-driven design sequence.
- [`DESIGN_DECISIONS.md`](DESIGN_DECISIONS.md) — project-wide accepted strategic decisions/rationale.
- [`GLOSSARY.md`](GLOSSARY.md) — canonical gameplay terminology.
- [`SPECIFICATION_TEMPLATE.md`](SPECIFICATION_TEMPLATE.md) — subsystem specification structure.
- [`STRUCTURE_AUDIT.md`](STRUCTURE_AUDIT.md) — top-level authority coverage audit.

## Completed Design Baselines

### GDS-1 — Product

Defines MonsterVault as a mobile-first, cross-platform social creature-collection/progression adventure with active acquisition, persistent visible collection, non-loss-dominant competition, flexible sessions, fast time-to-fun, moderate monetization, deferred safe trading, and live-content extensibility.

### GDS-2 — Global lifecycle

Defines disposable Server Sessions, protected persistence readiness, Finalized Outcome semantics, Recovery, interruption ownership, cross-server/offline timing, and persistence guarantees.

### GDS-3 — Player interaction/onboarding

Defines third-person familiar locomotion, Primary Interact / Primary Action, one Active Context, cross-device parity, gameplay-first persistent onboarding, Safe Arrival/Recovery, modal safety, and semantic accessibility constraints.

### GDS-4 — Creatures, collection, ownership

Defines Species versus Creature Instance identity, one-owner secured persistence, Collection Registry, duplicate preservation, Active/Stored/Overflow-Held/Released states, capacity safety, Creature Lock/Release, Species Discovery, provenance, and explicit transfer authority.

### GDS-5 — Capture, contesting, transport, extraction

Defines player-specific Capture Eligibility, bounded ordinary Engagement Claims, Provisional Capture, one baseline Transport Custody, interruption handling, Secure Points, exact Secured Ownership Finalization at validated Extraction Completion, capacity-race safety, onboarding protection, and exact-once single-winner semantics.

### GDS-6 — Rarity, mutations, traits, variant value

Defines five Species Rarity tiers, stable pre-commit Mutation/Trait identity, zero-to-two compatible Mutations, Compound Variants, context-aware Mutation Frequency, Variant Signature/Discovery, Protected Variants, prospective-only probability modifiers, Availability separation, and stable owned-instance identity.

### GDS-7 — Vault/Base, passive production, capacity, upgrades

Defines persistent personal Vault authority, Collection Capacity/Overflow-Held reconciliation, exact-instance display/Production Assignments, bounded Passive/Offline Production, Production Buffer/Claim, exact-once Vault Upgrades, read-only visitors, safe capacity expiry, and rarity-not-automatic-production-power.

### GDS-8 — Economy, progression, unlocks, pacing

Authoritative specification and closure evidence:

- [`economy_progression/08_economy_progression_unlocks_and_pacing.md`](economy_progression/08_economy_progression_unlocks_and_pacing.md) — Design Complete;
- [`GDS8_SCENARIO_VALIDATION.md`](GDS8_SCENARIO_VALIDATION.md) — 90 compound economy/progression scenarios; PASS;
- [`GDS8_CROSS_VALIDATION.md`](GDS8_CROSS_VALIDATION.md) — GDS-1 through GDS-7 and authority audit; PASS;
- [`GDS8_DECISION_INDEX.md`](GDS8_DECISION_INDEX.md) — phase-local strategic decisions;
- [`GDS8_CLOSURE_REPORT.md`](GDS8_CLOSURE_REPORT.md) — formal closure; PASS.

GDS-8 establishes:

- **Energy** as the single baseline non-premium soft progression currency;
- persistent non-negative Energy Wallet semantics and no baseline direct player-to-player transfer;
- Production Claim plus bounded meaningful active reward source categories;
- no baseline Energy from Creature Release or ordinary repeated capture;
- Vault Upgrades, durable Capture Capability, Access Unlocks, and approved utility/presentation as core sinks;
- no universal ordinary per-attempt capture Energy tax, ownership maintenance tax, debt, or arbitrary currency wipe;
- Species Production Profiles and bounded situational Trait production effects;
- no automatic rarity/Mutation/Compound/provenance production multipliers;
- non-spendable active **Progression Milestones** and combined Energy/Milestone Progression Gates;
- exact-once/atomic persistent Progression Purchases with insufficient-funds and price-race safety;
- opening/foundation/growth/long-term pacing bands and tuneable active/passive income mix;
- production-compounding and inflation-control guardrails;
- deterministic catch-up without fabricated history or hidden spending personalization;
- completed progression that remains completed through ordinary rebalancing;
- no baseline prestige/rebirth wipe of permanent collection/progression.

## Remaining Core Specifications

- `world/` — world structure, biomes, exploration, creature spawning/lifetime, hazards, concrete Access Unlock topology, Secure Point/Vault Access/Recovery Anchor placement and world Energy/Milestone rewards. **GDS-9 NEXT.**
- `social/` — cooperation, competition, collision/body-blocking, optional interception/PvP boundaries, expanded visitor/social permissions and social reward integrity.
- `events_liveops/` — events, rotating content, event-specific shared/multi-award capture, variant/production/economy modifiers and seasonal/live rules.
- `trading/` — secured-instance trading, Production Assignment reconciliation, scarcity/value integrity, anti-abuse design and explicit Energy-transfer decision.
- `monetization/` — monetization surfaces/fairness constraints including any Energy/capacity/convenience/production products.
- `presentation/` — UI/UX, Energy/gate/transaction/Vault/capture/rarity/event feedback, visual/audio language, accessibility and onboarding presentation.
- `platform_safety/` — Roblox platform constraints, commercial/randomized constraints, social safety and age-appropriate interaction design.
- `retention_analytics/` — retention loops, acquisition/Vault/variant/economy funnels, session goals, catch-up/reward cadence, metrics hypotheses and experiment boundaries.
- `audit/` — final GDS-17 cross-system consistency/maturity audits.

## Rule

No subsystem is implementation-ready merely because its directory/specification exists. Gameplay implementation remains blocked until the complete GDS, Technical Architecture, architecture audit, and implementation-lock gates are closed.
