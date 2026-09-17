# MonsterVault Game Design Specification

> **Status:** GDS-0 through GDS-5 Complete / GDS-6 Next  
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

The active dependency is now:

> **GDS-6 — Rarity, Mutations, Traits, and Variant Value**

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

Authoritative specification:

- [`capture/05_capture_contesting_transport_and_extraction.md`](capture/05_capture_contesting_transport_and_extraction.md) — Design Complete.
- [`GDS5_SCENARIO_VALIDATION.md`](GDS5_SCENARIO_VALIDATION.md) — 60 compound acquisition scenarios; PASS.
- [`GDS5_CROSS_VALIDATION.md`](GDS5_CROSS_VALIDATION.md) — product/lifecycle/ownership/authority validation; PASS.
- [`GDS5_CLOSURE_REPORT.md`](GDS5_CLOSURE_REPORT.md) — formal closure; PASS.

GDS-5 establishes:

- player-specific Capture Eligibility;
- one bounded exclusive ordinary Engagement Claim per single-award creature;
- ordinary social contesting before the active claim / Provisional Capture boundary;
- GDS-3-compatible capture challenge semantics;
- explicit Success/Failure/Cancel/Invalidation states;
- Capture Success creating **Provisional Capture** rather than persistent ownership;
- one baseline active **Transport Custody** per player;
- no ordinary direct stealing of valid Transport Custody;
- reset/Recovery and voluntary leave not counting as extraction;
- bounded same-server **Transport Grace** after unexpected disconnect;
- narrowly scoped authoritative **Protected Shutdown Finalization**;
- recognizable **Secure Point** semantics;
- validated **Extraction Completion** as the ordinary `Secured Ownership Finalization` boundary;
- exact-once single-winner finalization;
- capacity/Overflow-Held race safety without infinite-overflow capture abuse;
- **Onboarding-Protected Opportunity** for the first required capture;
- anti-grief, anti-reset, anti-hop, anti-duplication, and cross-device/accessibility constraints.

## Remaining Core Specifications

- `rarity_mutations/` — rarity, mutations, traits, variants, compound value, capture-difficulty interaction. **GDS-6 NEXT.**
- `vault/` — vault/base, passive production, placement, capacity and upgrades.
- `economy_progression/` — currencies, capture tools/costs, sources/sinks, unlocks, pacing and progression.
- `world/` — biomes, exploration, creature spawning/lifetime, hazards, Secure Point placement and traversal.
- `social/` — cooperation, competition, collision/body-blocking, optional interception/PvP boundaries and social status.
- `events_liveops/` — events, rotating content, event-specific shared/multi-award capture and seasonal/live rules.
- `trading/` — secured-instance trading, scarcity/value integrity and anti-abuse design.
- `monetization/` — monetization surfaces/fairness constraints.
- `presentation/` — UI/UX, capture/rarity/event feedback, visual/audio language, accessibility and onboarding presentation.
- `platform_safety/` — Roblox platform constraints, social safety and age-appropriate interaction design.
- `retention_analytics/` — retention loops, acquisition funnel, session goals, metrics hypotheses and experiment boundaries.
- `audit/` — final GDS-17 cross-system consistency/maturity audits.

## Rule

No subsystem is implementation-ready merely because its directory/specification exists. Gameplay implementation remains blocked until the complete GDS, Technical Architecture, architecture audit, and implementation-lock gates are closed.
