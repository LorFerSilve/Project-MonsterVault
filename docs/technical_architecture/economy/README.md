# Vault, Economy, Progression, Inventory, and Offline Accrual

> **Status:** Architecture Complete — TA-8  
> **Authority:** Collection/Vault persistent state, capacity/overflow, production/offline settlement, Energy transactions and progression purchases.

Authoritative specification:

- [08_vault_economy_progression_inventory_and_offline_accrual.md](08_vault_economy_progression_inventory_and_offline_accrual.md) — Architecture Complete.

Closure evidence:

- [../TA8_ROBLOX_ECONOMY_TIME_NUMERIC_SNAPSHOT.md](../TA8_ROBLOX_ECONOMY_TIME_NUMERIC_SNAPSHOT.md) — PASS;
- [../TA8_VAULT_ECONOMY_OFFLINE_MATRIX.md](../TA8_VAULT_ECONOMY_OFFLINE_MATRIX.md) — PASS;
- [../TA8_GDS_TRACEABILITY.md](../TA8_GDS_TRACEABILITY.md) — PASS;
- [../TA8_SCENARIO_VALIDATION.md](../TA8_SCENARIO_VALIDATION.md) — 220 / 220 PASS;
- [../TA8_DECISION_INDEX.md](../TA8_DECISION_INDEX.md) — accepted;
- [../TA8_CLOSURE_REPORT.md](../TA8_CLOSURE_REPORT.md) — PASS.

TA-8 locks bounded integer Energy, fixed-point Production Buffer, elapsed-time online/offline settlement, clean/crash recovery clock semantics, P2 assignments/claims/purchases, deterministic non-destructive capacity reconciliation, Overflow-Held resolution, versioned production epochs, deferred Energy overflow and commercial-capacity separation.

The next dependency is **TA-9 — World, Biomes, Spawn Scheduling, Streaming, and Encounter Scaling**.
