# MonsterVault Game Design Specification

> **Status:** GDS-0 through GDS-7 Complete / GDS-8 Next  
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

The active dependency is now:

> **GDS-8 — Economy, Progression, Unlocks, and Pacing**

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

Authoritative specification and closure evidence:

- [`vault/07_vault_base_passive_production_capacity_and_upgrades.md`](vault/07_vault_base_passive_production_capacity_and_upgrades.md) — Design Complete;
- [`GDS7_SCENARIO_VALIDATION.md`](GDS7_SCENARIO_VALIDATION.md) — 80 compound Vault/capacity/production scenarios; PASS;
- [`GDS7_CROSS_VALIDATION.md`](GDS7_CROSS_VALIDATION.md) — GDS-1 through GDS-6 and authority audit; PASS;
- [`GDS7_DECISION_INDEX.md`](GDS7_DECISION_INDEX.md) — phase-local strategic decisions;
- [`GDS7_CLOSURE_REPORT.md`](GDS7_CLOSURE_REPORT.md) — formal closure; PASS.

GDS-7 establishes:

- a persistent one-owner personal Vault/laboratory context;
- logical **Collection Capacity** separate from Display Slot and Production Slot counts;
- GDS-4 `Overflow-Held` as the single baseline capacity-safety state;
- deterministic non-destructive **Capacity Reconciliation** and exact-instance **Resolve Overflow**;
- display placement that references the same owned Creature Instance without cloning it;
- persistent one-slot/one-instance **Production Assignments**;
- no ordinary production from Overflow-Held creatures;
- **Production Profiles** that may use Species and explicitly bounded Traits but do not automatically scale from rarity, Mutation, Compound status, provenance, or Availability;
- elapsed-time **Passive Production** into a bounded persistent **Production Buffer**;
- bounded **Offline Production Window** semantics without offline live-world/event participation or server-hop reset;
- exact-once **Production Claims** and exact-once/atomic **Vault Upgrades**;
- safe temporary-capacity expiry through reconciliation rather than deletion or forced purchase;
- GDS-5 finalization before any Vault role/assignment begins;
- baseline read-only visitors with no persistent management authority or discovery credit;
- persistence/recovery/anti-replay rules across reset, disconnect, server change, retries, and shutdown;
- a viable non-premium path to functional core Vault capacity/use.

## Remaining Core Specifications

- `economy_progression/` — currencies, production-resource economics, capture tools/costs, sources/sinks, unlocks, pacing and progression. **GDS-8 NEXT.**
- `world/` — biomes, exploration, creature spawning/lifetime, hazards, Secure Point/Vault access placement and traversal.
- `social/` — cooperation, competition, collision/body-blocking, optional interception/PvP boundaries and expanded visitor/social permissions.
- `events_liveops/` — events, rotating content, event-specific shared/multi-award capture, production modifiers and seasonal/live rules.
- `trading/` — secured-instance trading, Production Assignment reconciliation, scarcity/value integrity and anti-abuse design.
- `monetization/` — monetization surfaces/fairness constraints including any capacity/convenience/production products.
- `presentation/` — UI/UX, Vault/capacity/production/capture/rarity/event feedback, visual/audio language, accessibility and onboarding presentation.
- `platform_safety/` — Roblox platform constraints, social safety and age-appropriate interaction design.
- `retention_analytics/` — retention loops, acquisition/Vault/variant funnels, session goals, metrics hypotheses and experiment boundaries.
- `audit/` — final GDS-17 cross-system consistency/maturity audits.

## Rule

No subsystem is implementation-ready merely because its directory/specification exists. Gameplay implementation remains blocked until the complete GDS, Technical Architecture, architecture audit, and implementation-lock gates are closed.
