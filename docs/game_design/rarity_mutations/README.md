# Rarity, Mutations, Traits, and Variant Value

> **Status:** Design Complete  
> **Owning phase:** GDS-6 — Rarity, Mutations, Traits, and Variant Value

This domain is the authoritative home for MonsterVault's Species Rarity, Mutation, Trait, Variant Signature, Variant Discovery, probability-fairness, high-value-protection, availability, and variant-value semantics.

## Authoritative Specification

- [`06_rarity_mutations_traits_and_variant_value.md`](06_rarity_mutations_traits_and_variant_value.md) — **Design Complete**

## Closure Evidence

- [`../GDS6_SCENARIO_VALIDATION.md`](../GDS6_SCENARIO_VALIDATION.md) — **70 / 70 PASS**
- [`../GDS6_CROSS_VALIDATION.md`](../GDS6_CROSS_VALIDATION.md) — **PASS**
- [`../GDS6_CLOSURE_REPORT.md`](../GDS6_CLOSURE_REPORT.md) — **PASS**

## Locked Baseline

GDS-6 establishes:

- five Species Rarity tiers: `Common -> Uncommon -> Rare -> Epic -> Legendary`;
- explicit separation of rarity, Mutation, Trait, Availability, power, and price;
- Variant Identity Finalization no later than actionable Capture Opportunity;
- no same-instance rerolling through claim/capture/transport/reconnect/finalization retries;
- zero-to-two baseline Mutations with Compound Variants at two compatible Mutations;
- context-aware Mutation Frequency Bands: `Frequent -> Uncommon -> Rare -> Extreme`;
- Variant Signature as Species plus canonical Mutation set;
- historical Mutation Discovery and Variant Discovery;
- Traits as stable bounded-optimization instance characteristics rather than a second rarity ladder;
- automatic Creature Lock for Protected Variants;
- prospective-only probability modifiers and prohibition on hidden individualized spending-based odds;
- `Core`, `Rotating`, `Event-Limited`, and `Legacy` Availability Tags separate from rarity;
- stable owned-instance variant identity across ordinary balance/content changes.

Exact spawn percentages, Mutation catalogs, Trait effects, economy values, event schedules, market prices, presentation, and technical RNG/storage remain downstream authority.

## Next Dependency

**GDS-7 — Vault/Base, Passive Production, Capacity, and Upgrades.**

Technical Architecture and gameplay implementation remain blocked.
