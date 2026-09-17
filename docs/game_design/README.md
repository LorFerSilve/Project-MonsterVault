# MonsterVault Game Design Specification

> **Status:** GDS-0 through GDS-4 Complete / GDS-5 Next  
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

The active dependency is now:

> **GDS-5 — Capture, Contesting, Transport, and Extraction**

Technical Architecture and gameplay implementation remain blocked.

## Governance

- [`00_design_authority.md`](00_design_authority.md) defines specification authority, statuses, completion rules, change control, and implementation gating.
- [`GDS_ROADMAP.md`](GDS_ROADMAP.md) defines the dependency-driven order in which the design is completed.
- [`DESIGN_DECISIONS.md`](DESIGN_DECISIONS.md) records accepted strategic design decisions and their rationale.
- [`GLOSSARY.md`](GLOSSARY.md) owns canonical gameplay terminology.
- [`SPECIFICATION_TEMPLATE.md`](SPECIFICATION_TEMPLATE.md) defines the required structure for subsystem specifications.
- [`STRUCTURE_AUDIT.md`](STRUCTURE_AUDIT.md) validates that all currently known top-level design concerns have an authoritative home.
- [`GDS0_CLOSURE_REPORT.md`](GDS0_CLOSURE_REPORT.md) records formal GDS-0 closure.

## Completed Design Baselines

### GDS-1 — Product

- [`01_game_overview.md`](01_game_overview.md) — Design Complete product identity/core experience.
- [`product/`](product/) — audience, platform, positioning, session, success-gate, scope, and commercial specifications.
- [`GDS1_CROSS_VALIDATION.md`](GDS1_CROSS_VALIDATION.md) — PASS.
- [`GDS1_CLOSURE_REPORT.md`](GDS1_CLOSURE_REPORT.md) — PASS.

GDS-1 establishes active creature collection, persistent visible vault progression, socially competitive but non-loss-dominant play, mobile-first cross-platform accessibility, flexible session lengths, trading as non-launch-critical, moderate non-coercive monetization, and retention-first product gates.

### GDS-2 — Global lifecycle

- [`global_rules/02_global_game_rules_and_session_model.md`](global_rules/02_global_game_rules_and_session_model.md) — Design Complete.
- [`GDS2_SCENARIO_VALIDATION.md`](GDS2_SCENARIO_VALIDATION.md) — 30 compound lifecycle scenarios; PASS.
- [`GDS2_CROSS_VALIDATION.md`](GDS2_CROSS_VALIDATION.md) — PASS.
- [`GDS2_CLOSURE_REPORT.md`](GDS2_CLOSURE_REPORT.md) — PASS.

GDS-2 establishes disposable Server Sessions with session-independent persistent progression, protected persistent-state readiness, Recovery instead of global wipes, finalized-outcome single-application semantics, explicit transient interruption ownership, late-join support, and coherent offline/cross-server timing boundaries.

### GDS-3 — Player interaction/onboarding

- [`player/03_player_character_interaction_and_onboarding.md`](player/03_player_character_interaction_and_onboarding.md) — Design Complete.
- [`GDS3_SCENARIO_VALIDATION.md`](GDS3_SCENARIO_VALIDATION.md) — 40 compound interaction/onboarding scenarios; PASS.
- [`GDS3_CROSS_VALIDATION.md`](GDS3_CROSS_VALIDATION.md) — PASS.
- [`GDS3_CLOSURE_REPORT.md`](GDS3_CLOSURE_REPORT.md) — PASS.

GDS-3 establishes third-person familiar locomotion, cross-device interaction parity, Primary Interact/Primary Action semantics, deterministic Active Context selection, gameplay-first persistent onboarding, Safe Arrival/Recovery behavior, modal-input safety, and interaction-level accessibility constraints.

### GDS-4 — Creatures, collection, ownership

- [`creatures/04_creatures_collection_and_ownership.md`](creatures/04_creatures_collection_and_ownership.md) — Design Complete.
- [`GDS4_SCENARIO_VALIDATION.md`](GDS4_SCENARIO_VALIDATION.md) — 50 compound ownership/capacity/lifecycle scenarios; PASS.
- [`GDS4_CROSS_VALIDATION.md`](GDS4_CROSS_VALIDATION.md) — PASS.
- [`GDS4_CLOSURE_REPORT.md`](GDS4_CLOSURE_REPORT.md) — PASS.

GDS-4 establishes:

- Species versus individual Creature Instance identity;
- stable persistent identity and one-owner semantics for Secured Creatures;
- GDS-5-owned **Secured Ownership Finalization** as the boundary into persistent collection ownership;
- a logical persistent **Collection Registry**;
- Active, Stored, Overflow-Held, and Released collection-facing states;
- valid distinct duplicate instances;
- non-destructive full-capacity and capacity-reduction behavior;
- **Overflow-Held** as a restricted safety state rather than infinite normal storage;
- explicit voluntary Release plus persistent **Creature Lock** protection;
- no baseline involuntary loss of Secured Creatures;
- persistent Species Discovery and discovery-based baseline Species completion;
- stable provenance/history hooks;
- explicit later authority for player-to-player ownership transfer.

## Remaining Core Specifications

- `capture/` — capture loop, contesting, transport, extraction, ownership-finalization trigger, success/failure and anti-frustration rules. **GDS-5 NEXT.**
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
