# MonsterVault Game Design Specification

> **Status:** GDS-0 and GDS-1 Complete / GDS-2 Next  
> **Authority:** Player-facing gameplay behavior

This directory contains the authoritative Game Design Specification (GDS) for MonsterVault.

The purpose of the GDS is to define what the game does before implementation decisions are allowed to harden the design accidentally.

## Current Gate

Completed:

- **GDS-0 — Governance, Structure, and Concept Baseline: COMPLETE — PASS**
- **GDS-1 — Product Vision, Audience, and Success Criteria: COMPLETE — PASS**

The active dependency is now:

> **GDS-2 — Global Game Rules and Session Model**

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

The resulting high-level product contract includes:

- a social creature-collection/progression adventure identity;
- primary target audience around ages 9–15 with older collection/optimization players as a secondary audience;
- mobile-first interaction constraints with cross-platform gameplay parity;
- communication-independent core progression;
- active acquisition, visible vault progression, rarity/variant hunting, and server-level social moments;
- socially competitive but non-loss-dominant play;
- fast time-to-fun and flexible session lengths;
- weeks-to-months collection/progression aspirations;
- trading as desirable but non-launch-critical;
- moderate non-coercive monetization;
- retention-first product success gates.

## Remaining Core Specifications

- `global_rules/` — session model, player-state rules, failure/recovery, multiplayer invariants.
- `player/` — movement, interaction, onboarding, inventory-facing behavior.
- `creatures/` — creature identity, acquisition, ownership, collection and behavior.
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
