# MonsterVault Game Design Specification

> **Status:** GDS-0 through GDS-11 Complete / GDS-12 Next  
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
- **GDS-9 — World, Biomes, Exploration, Spawning, and Hazards: COMPLETE — PASS**
- **GDS-10 — Social Play, Cooperation, Competition, and PvP Boundaries: COMPLETE — PASS**
- **GDS-11 — Server Events, Dynamic Encounters, and Live Content: COMPLETE — PASS**

The active dependency is now:

> **GDS-12 — Trading and Player Economy**

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

Defines Energy as the single baseline non-premium soft progression currency, bounded source/sink categories, active Progression Milestones, exact-once purchases, durable Vault/capture/access progression, pacing, catch-up, inflation controls and no baseline prestige wipe.

### GDS-9 — World, biomes, exploration, spawning, hazards

Authoritative specification and closure evidence:

- [`world/09_world_biomes_exploration_spawning_and_hazards.md`](world/09_world_biomes_exploration_spawning_and_hazards.md) — Design Complete;
- [`GDS9_SCENARIO_VALIDATION.md`](GDS9_SCENARIO_VALIDATION.md) — 100 compound world/spawn/lifecycle scenarios; PASS;
- [`GDS9_CROSS_VALIDATION.md`](GDS9_CROSS_VALIDATION.md) — GDS-1 through GDS-8 and authority audit; PASS;
- [`GDS9_DECISION_INDEX.md`](GDS9_DECISION_INDEX.md) — phase-local strategic decisions;
- [`GDS9_CLOSURE_REPORT.md`](GDS9_CLOSURE_REPORT.md) — formal closure; PASS.

GDS-9 establishes:

- a compact **Home Hub -> Starter -> two parallel Mid Biomes -> Advanced** launch world graph;
- free Starter access, persistent Mid/Advanced Access Unlocks and active **Region Mastery**;
- Route Survey + distinct Core-Species collection + Field Objective mastery categories;
- no mandatory Legendary/Extreme/Compound/Event-Limited/specific rare/paid progression gate;
- persistent exact-once Landmark Discovery and bounded active world Energy rewards;
- Home Hub/Safe Outpost placement for Secure Points, Vault Access and Recovery;
- baseline non-premium Safe Routes and discovery-based travel nodes;
- fast travel blocked throughout Acquisition-In-Progress;
- Habitat and Spawn Context semantics with bounded encounter populations;
- prospective encounter generation and stable Species/Mutation/Trait identity;
- no hidden spending-based spawn odds;
- ordinary encounter-density targets without guaranteeing rare outcomes per session;
- bounded Encounter Lifetimes that do not interrupt valid active acquisition;
- non-trivial stability/readability requirements for actionable Protected Variants;
- deterministic ordinary World Cycle context without private server-hop reset behavior;
- environmental hazards that may cause Recovery but cannot destroy finalized player value;
- session-scoped public encounters versus persistent Access/Landmark/Mastery/reward progress;
- additive content expansion that preserves prior access, mastery, ownership and provenance.

### GDS-10 — Social play, cooperation, competition, PvP boundaries

Authoritative specification and closure evidence:

- [social/10_social_play_cooperation_competition_and_pvp_boundaries.md](social/10_social_play_cooperation_competition_and_pvp_boundaries.md) — Design Complete;
- [GDS10_SCENARIO_VALIDATION.md](GDS10_SCENARIO_VALIDATION.md) — 110 compound social/multiplayer scenarios; PASS;
- [GDS10_CROSS_VALIDATION.md](GDS10_CROSS_VALIDATION.md) — GDS-1 through GDS-9 and authority audit; PASS;
- [GDS10_DECISION_INDEX.md](GDS10_DECISION_INDEX.md) — phase-local strategic decisions;
- [GDS10_CLOSURE_REPORT.md](GDS10_CLOSURE_REPORT.md) — formal closure; PASS.

GDS-10 establishes:

- explicit consent-based Parties with up to four players and narrow leader authority;
- no shared ownership, wallet, Vault authority, claim, custody, access or progression merely from Party/friend status;
- structured rate-limited Social Pings without claim/discovery authority;
- personal Landmark/Region Mastery/access semantics during cooperation;
- Shared Objectives requiring meaningful Eligible Contribution per credited player;
- bounded exact-once personal Collaboration Rewards and no Party Energy transfer;
- ordinary capture remaining one claim, one custody and one winner;
- no custody handoff, teammate extraction or observer discovery;
- public pre-claim competition and explicit non-destructive Friendly Challenges;
- no wagering/staking, direct-combat PvP, transport interception, creature theft or player-caused Energy loss;
- non-obstructive player collision and anti-body-blocking requirements;
- owner-controlled read-only Vault visitor access and truthful Showcases;
- social coordination that does not depend on unrestricted chat/voice;
- transient social state versus persistent exact-once personal outcomes;
- alternate-account, AFK reward and social scarcity-manipulation guardrails.

### GDS-11 — Server events, dynamic encounters, live content

Authoritative specification and closure evidence:

- [events_liveops/11_server_events_dynamic_encounters_and_live_content.md](events_liveops/11_server_events_dynamic_encounters_and_live_content.md) — Design Complete;
- [GDS11_SCENARIO_VALIDATION.md](GDS11_SCENARIO_VALIDATION.md) — 120 compound event/live-content scenarios; PASS;
- [GDS11_CROSS_VALIDATION.md](GDS11_CROSS_VALIDATION.md) — GDS-1 through GDS-10 and authority audit; PASS;
- [GDS11_DECISION_INDEX.md](GDS11_DECISION_INDEX.md) — phase-local strategic decisions;
- [GDS11_CLOSURE_REPORT.md](GDS11_CLOSURE_REPORT.md) — formal closure; PASS.

GDS-11 establishes:

- shared wall-clock Event Occurrences that do not restart per server;
- session-local Server Event Instances and Rift/shared-objective state;
- explicit event lifecycle with late-join and bounded Resolution Grace semantics;
- contribution-gated exact-once Event Participation Rewards and Completion Records;
- prospective Event Spawn Modifiers that never reroll existing/owned Creature Instances;
- Event-Limited/Rotating/Legacy Availability that preserves owned history;
- dynamic Rifts/Event Zones compatible with Safe Routes, Recovery and hazard safety;
- ordinary event creatures remaining single-award by default;
- explicit Event Multi-Award Encounters that create distinct Personal Event Capture Opportunities / Creature Instances;
- no copying of one shared event target into several owners;
- server-hop rules preventing duration resets, reward replay and guaranteed personal-opportunity rerolls;
- event/world-cycle composition without resetting the ordinary World Cycle;
- social/Party event rules preserving personal contribution and no direct-combat/body-blocking authority;
- bounded active Event Energy rewards and no baseline Passive Production multiplier;
- additive seasonal/rotating content, provenance preservation and safe prospective disable/hotfix behavior.

## Remaining Core Specifications

- `trading/` — GDS-12 secured-instance trading, Production Assignment reconciliation, scarcity/value integrity, anti-abuse design and explicit Energy-transfer decision. **GDS-12 NEXT.**
- `monetization/` — monetization surfaces/fairness constraints including any Energy/capacity/convenience/production products.
- `presentation/` — UI/UX, Energy/gate/transaction/Vault/capture/rarity/event/world feedback, visual/audio language, accessibility and onboarding presentation.
- `platform_safety/` — Roblox platform constraints, commercial/randomized constraints, social safety and age-appropriate interaction design.
- `retention_analytics/` — retention loops, acquisition/Vault/variant/economy/world funnels, session goals, catch-up/reward cadence, metrics hypotheses and experiment boundaries.
- `audit/` — final GDS-17 cross-system consistency/maturity audits.

## Rule

No subsystem is implementation-ready merely because its directory/specification exists. Gameplay implementation remains blocked until the complete GDS, Technical Architecture, architecture audit, and implementation-lock gates are closed.
