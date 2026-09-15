# MonsterVault Game Design Specification

> **Status:** GDS-0 Complete / GDS-1 Active  
> **Authority:** Player-facing gameplay behavior

This directory contains the authoritative Game Design Specification (GDS) for MonsterVault.

The purpose of the GDS is to define what the game does before implementation decisions are allowed to harden the design accidentally.

## Current Gate

**GDS-0 — Governance, Structure, and Concept Baseline: COMPLETE — PASS.**

Closure evidence:

- [`STRUCTURE_AUDIT.md`](STRUCTURE_AUDIT.md) — top-level domain and authority coverage PASS;
- [`GDS0_CLOSURE_REPORT.md`](GDS0_CLOSURE_REPORT.md) — formal governance closure PASS.

The active dependency is now **GDS-1 — Product Vision, Audience, and Success Criteria**.

Technical Architecture and gameplay implementation remain blocked.

## Governance

- [`00_design_authority.md`](00_design_authority.md) defines specification authority, statuses, completion rules, change control, and implementation gating.
- [`GDS_ROADMAP.md`](GDS_ROADMAP.md) defines the dependency-driven order in which the design is completed.
- [`DESIGN_DECISIONS.md`](DESIGN_DECISIONS.md) records accepted strategic design decisions and their rationale.
- [`GLOSSARY.md`](GLOSSARY.md) owns canonical gameplay terminology.
- [`SPECIFICATION_TEMPLATE.md`](SPECIFICATION_TEMPLATE.md) defines the required structure for subsystem specifications.
- [`STRUCTURE_AUDIT.md`](STRUCTURE_AUDIT.md) validates that all currently known top-level design concerns have an authoritative home.
- [`GDS0_CLOSURE_REPORT.md`](GDS0_CLOSURE_REPORT.md) records formal GDS-0 closure.

## Core Specifications

- [`01_game_overview.md`](01_game_overview.md) — current product vision and high-level loop; owned by GDS-1.
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
