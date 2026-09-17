# Economy, Progression, Unlocks, and Pacing

> **Status:** Design Complete — GDS-8 PASS  
> **Owning phase:** GDS-8

This directory is the authoritative home for MonsterVault's baseline soft-currency economy, progression purchases, active progression requirements, Vault/capture/access upgrade economics, pacing, catch-up, inflation controls, and long-term progression position.

## Authoritative Specification

- [`08_economy_progression_unlocks_and_pacing.md`](08_economy_progression_unlocks_and_pacing.md) — complete GDS-8 behavior contract.

## Validation and Closure

- [`../GDS8_SCENARIO_VALIDATION.md`](../GDS8_SCENARIO_VALIDATION.md) — 90 / 90 PASS;
- [`../GDS8_CROSS_VALIDATION.md`](../GDS8_CROSS_VALIDATION.md) — PASS;
- [`../GDS8_DECISION_INDEX.md`](../GDS8_DECISION_INDEX.md) — accepted strategic decisions;
- [`../GDS8_CLOSURE_REPORT.md`](../GDS8_CLOSURE_REPORT.md) — GDS-8 PASS — COMPLETE.

## Core Contract

GDS-8 establishes:

- **Energy** as the single baseline non-premium soft progression currency;
- persistent non-negative whole-unit wallet semantics;
- no baseline direct player-to-player Energy transfer;
- bounded Production Claim plus meaningful active reward sources;
- zero baseline Energy from Creature Release or ordinary repeated capture;
- Vault Upgrades, durable Capture Capability, Access Unlocks, and approved utility as core sinks;
- no universal per-attempt ordinary capture tax, ownership maintenance tax, or debt;
- Species Production Profiles with bounded authored Trait effects;
- no automatic rarity/Mutation/Compound/provenance production multipliers;
- non-spendable active **Progression Milestones** for gates that must resist passive-only completion;
- exact-once/atomic persistent purchases;
- opening/foundation/growth/long-term pacing bands;
- source/sink and production-compounding guardrails;
- deterministic catch-up without fabricated history;
- no arbitrary Energy wipe;
- no baseline prestige/rebirth reset of permanent collection/progression.

The next active dependency is **GDS-9 — World, Biomes, Exploration, Spawning, and Hazards**.
