# MonsterVault Game Design Specification

> **Status:** Active / Draft specification phase
> **Authority:** Player-facing gameplay behavior

This directory contains the authoritative Game Design Specification (GDS) for MonsterVault.

The purpose of the GDS is to define what the game does before implementation decisions are allowed to harden the design accidentally.

## Governance

- [`00_design_authority.md`](00_design_authority.md) defines specification authority, statuses, completion rules, and change control.
- [`GDS_ROADMAP.md`](GDS_ROADMAP.md) defines the dependency-driven order in which the design is completed.
- [`DESIGN_DECISIONS.md`](DESIGN_DECISIONS.md) records accepted strategic design decisions and their rationale.
- [`GLOSSARY.md`](GLOSSARY.md) owns canonical gameplay terminology.
- [`SPECIFICATION_TEMPLATE.md`](SPECIFICATION_TEMPLATE.md) defines the required structure for subsystem specifications.

## Core Specifications

- [`01_game_overview.md`](01_game_overview.md) — current product vision and high-level loop.
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
- `audit/` — final cross-system consistency and maturity audits.

## Rule

No subsystem is implementation-ready merely because its README exists. A subsystem becomes implementation-ready only after its authoritative specification reaches `Design Complete` and the later Technical Architecture phase derives and locks an implementation contract from it.
