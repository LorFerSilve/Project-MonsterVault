# Vault, Passive Production, Capacity, and Upgrades

> **Status:** Design Complete  
> **Owning phase:** GDS-7

Authoritative GDS-7 home for the player's persistent Personal Vault/Base, secured-creature intake and placement, explicit Production Assignments, bounded passive/offline production, Pending Vault Output, capacity, durable Vault Upgrades, display/visitor permissions, and vault-specific lifecycle/value-integrity rules.

## Authority

The authoritative specification is:

- [`07_vault_passive_production_capacity_and_upgrades.md`](07_vault_passive_production_capacity_and_upgrades.md)

Formal closure evidence:

- [`../GDS7_SCENARIO_VALIDATION.md`](../GDS7_SCENARIO_VALIDATION.md) — 80 / 80 PASS;
- [`../GDS7_CROSS_VALIDATION.md`](../GDS7_CROSS_VALIDATION.md) — PASS;
- [`../GDS7_CLOSURE_REPORT.md`](../GDS7_CLOSURE_REPORT.md) — PASS.

## Key Boundary

GDS-7 begins only after GDS-5 Secured Ownership Finalization. The Vault does not create ownership and does not reroll GDS-6 identity.

GDS-8 remains authoritative for exact resource types, production rates, prices, upgrade costs, sinks, progression curves, and economy pacing. GDS-10 remains authoritative for social visit discovery/bonuses; GDS-13 for monetized capacity/convenience; GDS-14 for final vault UI/art/accessibility; Technical Architecture for persistence, clocks, concurrency, and idempotency implementation.
