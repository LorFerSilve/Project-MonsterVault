# MonsterVault Game Design Specification

> **Status:** GDS-0 through GDS-6 Complete / GDS-7 Next  
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

The active dependency is now:

> **GDS-7 — Vault/Base, Passive Production, Capacity, and Upgrades**

Technical Architecture and gameplay implementation remain blocked.

## Governance

- [`00_design_authority.md`](00_design_authority.md) — authority, statuses, completion/change-control rules and gates.
- [`GDS_ROADMAP.md`](GDS_ROADMAP.md) — dependency-driven design sequence.
- [`DESIGN_DECISIONS.md`](DESIGN_DECISIONS.md) — accepted strategic decisions/rationale.
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

Authoritative specification:

- [`rarity_mutations/06_rarity_mutations_traits_and_variant_value.md`](rarity_mutations/06_rarity_mutations_traits_and_variant_value.md) — Design Complete.
- [`GDS6_SCENARIO_VALIDATION.md`](GDS6_SCENARIO_VALIDATION.md) — 70 compound rarity/variant scenarios; PASS.
- [`GDS6_CROSS_VALIDATION.md`](GDS6_CROSS_VALIDATION.md) — product/lifecycle/ownership/capture/authority validation; PASS.
- [`GDS6_CLOSURE_REPORT.md`](GDS6_CLOSURE_REPORT.md) — formal closure; PASS.

GDS-6 establishes:

- five Species Rarity tiers: `Common -> Uncommon -> Rare -> Epic -> Legendary`;
- separation of Species Rarity, Mutation, Trait, Availability, gameplay power, and economic/market price;
- Variant Identity Finalization no later than an individually actionable Capture Opportunity;
- no rerolling of the same surviving Creature Instance through claim/capture/transport/reconnect/finalization retries;
- zero-to-two baseline Mutations with two compatible Mutations forming a Compound Variant;
- context-aware Mutation Frequency Bands: `Frequent -> Uncommon -> Rare -> Extreme`;
- Mutation compatibility and non-color-only critical readability requirements;
- Traits as persistent bounded-optimization characteristics distinct from Mutations;
- Variant Signature as `Species + canonical Mutation set`;
- historical Mutation Discovery and Variant Discovery after legitimate securisation;
- automatic Creature Lock for Protected Variants including Legendary, Extreme-Mutated, Compound-Mutated, and explicitly protected event/legacy instances;
- prospective-only probability modifiers;
- prohibition on hidden individualized odds based on spending, purchase reluctance, inferred willingness to pay, or loss chasing;
- Availability Tags `Core`, `Rotating`, `Event-Limited`, and `Legacy` separate from rarity;
- stable owned-instance variant identity across ordinary balance/content changes;
- rarity/value labels that do not guarantee raw power, currency price, or future trading price.

## Remaining Core Specifications

- `vault/` — vault/base, passive production, placement, capacity and upgrades. **GDS-7 NEXT.**
- `economy_progression/` — currencies, capture tools/costs, sources/sinks, unlocks, pacing and progression.
- `world/` — biomes, exploration, creature spawning/lifetime, hazards, Secure Point placement and traversal.
- `social/` — cooperation, competition, collision/body-blocking, optional interception/PvP boundaries and social status.
- `events_liveops/` — events, rotating content, event-specific shared/multi-award capture and seasonal/live rules.
- `trading/` — secured-instance trading, scarcity/value integrity and anti-abuse design.
- `monetization/` — monetization surfaces/fairness constraints.
- `presentation/` — UI/UX, capture/rarity/event feedback, visual/audio language, accessibility and onboarding presentation.
- `platform_safety/` — Roblox platform constraints, social safety and age-appropriate interaction design.
- `retention_analytics/` — retention loops, acquisition/variant funnels, session goals, metrics hypotheses and experiment boundaries.
- `audit/` — final GDS-17 cross-system consistency/maturity audits.

## Rule

No subsystem is implementation-ready merely because its directory/specification exists. Gameplay implementation remains blocked until the complete GDS, Technical Architecture, architecture audit, and implementation-lock gates are closed.
