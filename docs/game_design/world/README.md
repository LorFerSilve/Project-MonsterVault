# World, Biomes, Exploration, Spawning, and Hazards

> **Status:** Design Complete — GDS-9 PASS  
> **Owning phase:** GDS-9

This directory is the authoritative home for MonsterVault's world structure, biome progression, traversal, creature encounter/spawn behavior from the player's perspective, hazards, special zones, exploration rewards, density/readability, world utility placement and long-term content expansion rules.

## Authoritative Specification

- [`09_world_biomes_exploration_spawning_and_hazards.md`](09_world_biomes_exploration_spawning_and_hazards.md) — Design Complete.

## Closure Evidence

- [`../GDS9_SCENARIO_VALIDATION.md`](../GDS9_SCENARIO_VALIDATION.md) — 100 / 100 PASS;
- [`../GDS9_CROSS_VALIDATION.md`](../GDS9_CROSS_VALIDATION.md) — PASS;
- [`../GDS9_DECISION_INDEX.md`](../GDS9_DECISION_INDEX.md) — accepted phase-local decisions;
- [`../GDS9_CLOSURE_REPORT.md`](../GDS9_CLOSURE_REPORT.md) — formal closure PASS.

## Locked Baseline

GDS-9 establishes:

- a compact `Home Hub -> Starter -> two parallel Mid Biomes -> Advanced` launch topology;
- persistent GDS-8 Access Unlocks combined with active Region Mastery;
- Region Mastery through Route Survey, distinct Core-Species collection and Field Objective completion;
- no mandatory Legendary/Extreme/Compound/Event-Limited/paid progression gate;
- Home Hub and field Safe Outpost placement for Secure Points, Vault Access and Recovery;
- discovery-based fast travel that is disabled during Acquisition-In-Progress;
- Habitat and Spawn Context semantics with bounded encounter populations;
- prospective generation with stable GDS-6 Creature/Variant identity;
- reliable ordinary encounter density without guaranteed rare outcomes;
- meaningful Rare Encounter Stability for Protected Variants;
- deterministic ordinary World Cycle context without server-hop reroll semantics;
- hazards that create temporary traversal risk but never destroy finalized player value;
- session-scoped public encounters versus persistent Access/Landmark/Mastery progression;
- additive future content expansion that preserves historical access, mastery, ownership and provenance.

The next dependency is **GDS-10 — Social Play, Cooperation, Competition, and PvP Boundaries**. Technical Architecture and gameplay implementation remain blocked.
