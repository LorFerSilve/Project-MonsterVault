# MonsterVault Game Design Specification

> **Status:** GDS-0 through GDS-3 Complete / GDS-4 Next  
> **Authority:** Player-facing gameplay behavior

This directory contains the authoritative Game Design Specification (GDS) for MonsterVault.

The purpose of the GDS is to define what the game does before implementation decisions are allowed to harden the design accidentally.

## Current Gate

Completed:

- **GDS-0 — Governance, Structure, and Concept Baseline: COMPLETE — PASS**
- **GDS-1 — Product Vision, Audience, and Success Criteria: COMPLETE — PASS**
- **GDS-2 — Global Game Rules and Session Model: COMPLETE — PASS**
- **GDS-3 — Player Character, Interaction, and Onboarding: COMPLETE — PASS**

The active dependency is now:

> **GDS-4 — Creatures, Collection, and Ownership**

Technical Architecture and gameplay implementation remain blocked.

## Governance

- [`00_design_authority.md`](00_design_authority.md) defines specification authority, statuses, completion rules, change control, and implementation gating.
- [`GDS_ROADMAP.md`](GDS_ROADMAP.md) defines the dependency-driven order in which the design is completed.
- [`DESIGN_DECISIONS.md`](DESIGN_DECISIONS.md) records accepted strategic design decisions and their rationale.
- [`GLOSSARY.md`](GLOSSARY.md) owns canonical gameplay terminology.
- [`SPECIFICATION_TEMPLATE.md`](SPECIFICATION_TEMPLATE.md) defines the required structure for subsystem specifications.
- [`STRUCTURE_AUDIT.md`](STRUCTURE_AUDIT.md) validates that all currently known top-level design concerns have an authoritative home.
- [`GDS0_CLOSURE_REPORT.md`](GDS0_CLOSURE_REPORT.md) records formal GDS-0 closure.

## GDS-1 Product Baseline

- [`01_game_overview.md`](01_game_overview.md) — Design Complete high-level product identity and core experience structure.
- [`product/`](product/) — authoritative audience, platform, positioning, session, success-gate, scope, and commercial product specifications.
- [`GDS1_CROSS_VALIDATION.md`](GDS1_CROSS_VALIDATION.md) — cross-phase authority and contradiction audit; PASS.
- [`GDS1_CLOSURE_REPORT.md`](GDS1_CLOSURE_REPORT.md) — formal GDS-1 closure; PASS.

The resulting product contract includes active creature collection, persistent visible vault progression, socially competitive but non-loss-dominant play, mobile-first cross-platform accessibility, flexible session lengths, trading as non-launch-critical, moderate non-coercive monetization, and retention-first product gates.

## GDS-2 Global Lifecycle Baseline

- [`global_rules/02_global_game_rules_and_session_model.md`](global_rules/02_global_game_rules_and_session_model.md) — authoritative global lifecycle/session specification; Design Complete.
- [`GDS2_SCENARIO_VALIDATION.md`](GDS2_SCENARIO_VALIDATION.md) — 30 compound lifecycle scenarios; PASS.
- [`GDS2_CROSS_VALIDATION.md`](GDS2_CROSS_VALIDATION.md) — product, authority, and contradiction audit; PASS.
- [`GDS2_CLOSURE_REPORT.md`](GDS2_CLOSURE_REPORT.md) — formal GDS-2 closure; PASS.

GDS-2 establishes disposable Server Sessions with session-independent persistent progression, protected persistent-state readiness, Recovery instead of global wipes, finalized-outcome single-application semantics, explicit transient interruption ownership, late-join support, and coherent offline/cross-server timing boundaries.

## GDS-3 Player Interaction and Onboarding Baseline

- [`player/03_player_character_interaction_and_onboarding.md`](player/03_player_character_interaction_and_onboarding.md) — authoritative player-control/onboarding specification; Design Complete.
- [`GDS3_SCENARIO_VALIDATION.md`](GDS3_SCENARIO_VALIDATION.md) — 40 compound interaction/onboarding scenarios; PASS.
- [`GDS3_CROSS_VALIDATION.md`](GDS3_CROSS_VALIDATION.md) — product/lifecycle/authority validation; PASS.
- [`GDS3_CLOSURE_REPORT.md`](GDS3_CLOSURE_REPORT.md) — formal GDS-3 closure; PASS.

GDS-3 establishes:

- third-person familiar baseline exploration;
- continuous movement/jump without a universal stamina tax;
- touch, keyboard/mouse, and controller capability parity;
- universal **Primary Interact** and downstream-tool **Primary Action** semantics;
- one deterministic **Active Context** at a time;
- modal input-focus/input-spillover protection;
- gameplay-first onboarding aligned to GDS-1 time-to-fun targets;
- persistent/resumable **Onboarding Milestones**;
- skippable/replayable **Guidance Layer** separated from real progression;
- onboarding availability despite ordinary multiplayer/server variation;
- **Safe Arrival** after Persistence Ready;
- concrete **Recovery** behavior using valid Recovery Anchors without automatic extraction;
- interaction-level accessibility invariants before final GDS-14 presentation work.

## Remaining Core Specifications

- `creatures/` — creature identity, acquisition, ownership, collection and behavior. **GDS-4 NEXT.**
- `capture/` — capture loop, contesting, transport, success/failure and anti-frustration rules.
- `rarity_mutations/` — rarity, mutations, variants, combinatorics and collection value.
- `vault/` — player vault/base, passive production, capacity and upgrades.
- `economy_progression/` — currencies, sources/sinks, unlocks, pacing and progression.
- `world/` — biomes, exploration, spawning, hazards and traversal progression.
- `social/` — cooperation, competition, interception/PvP boundaries, parties and social status.
- `events_liveops/` — server events, rotating content, seasonal/live content rules.
- `trading/` — trading, scarcity, value integrity and anti-abuse design.
- `monetization/` — monetization surfaces and fairness constraints.
- `presentation/` — UI/UX, feedback, visual/audio language, accessibility and onboarding presentation.
- `platform_safety/` — Roblox platform constraints, social safety and age-appropriate interaction design.
- `retention_analytics/` — retention loops, session goals, metrics hypotheses and experiment boundaries.
- `audit/` — final GDS-17 cross-system consistency and maturity audits.

## Rule

No subsystem is implementation-ready merely because its directory or specification exists. A subsystem becomes eligible for technical handoff only after its authoritative specification reaches `Design Complete`, and gameplay implementation remains blocked until the later Technical Architecture and implementation-lock gates are closed.
