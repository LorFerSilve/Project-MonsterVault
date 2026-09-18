# Trading and Player Economy

> **Status:** Design Complete
> **Owning phase:** GDS-12
> **Authority:** Trade Access, direct bilateral creature barter, exact-instance offers, Trade Revision/Ready/final confirmation, atomic ownership transfer, capacity/Vault reconciliation, Trade Cooldowns/Restrictions, discovery/provenance effects, Energy-transfer decision, and trade abuse/fairness boundaries.

Authoritative specification:

- [12_trading_and_player_economy.md](12_trading_and_player_economy.md) — Design Complete.

Closure evidence:

- [../GDS12_SCENARIO_VALIDATION.md](../GDS12_SCENARIO_VALIDATION.md) — 140 / 140 PASS;
- [../GDS12_CROSS_VALIDATION.md](../GDS12_CROSS_VALIDATION.md) — PASS;
- [../GDS12_DECISION_INDEX.md](../GDS12_DECISION_INDEX.md) — accepted decisions;
- [../GDS12_CLOSURE_REPORT.md](../GDS12_CLOSURE_REPORT.md) — PASS.

GDS-12 authorizes direct same-server creature-for-creature barter after a non-paid Trade Access Milestone. Energy remains non-transferable; baseline gifting, auctions, marketplaces, offline listings and trade fees are not authorized.

Every semantic offer change creates a new Trade Revision and clears consent state. A trade finalizes only after independent Ready plus independent Final Trade Confirmation for the same exact revision, followed by one atomic exact-once Trade Commit.

The next dependency is **GDS-13 — Monetization and Commercial Fairness**.
