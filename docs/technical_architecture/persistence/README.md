# Player Data, Persistence, Session Ownership, and Recovery

> **Status:** Architecture Complete — TA-4  
> **Authority:** Player Profile persistence, DataStore session lease, schema/versioning, checkpoints, exact-once operation identity and recovery.

Authoritative specification:

- [04_player_data_persistence_session_ownership_schema_evolution_and_recovery.md](04_player_data_persistence_session_ownership_schema_evolution_and_recovery.md) — Architecture Complete.

Closure evidence:

- [../TA4_ROBLOX_PERSISTENCE_SNAPSHOT.md](../TA4_ROBLOX_PERSISTENCE_SNAPSHOT.md) — PASS;
- [../TA4_PERSISTENCE_SESSION_MATRIX.md](../TA4_PERSISTENCE_SESSION_MATRIX.md) — PASS;
- [../TA4_GDS_TRACEABILITY.md](../TA4_GDS_TRACEABILITY.md) — PASS;
- [../TA4_SCENARIO_VALIDATION.md](../TA4_SCENARIO_VALIDATION.md) — 180 / 180 PASS;
- [../TA4_DECISION_INDEX.md](../TA4_DECISION_INDEX.md) — accepted;
- [../TA4_CLOSURE_REPORT.md](../TA4_CLOSURE_REPORT.md) — PASS.

TA-4 locks a native standard-DataStore Player Profile aggregate, atomic metadata session lease, one-writer/revision discipline, P0/P1/P2 durability classes, durable-before-final-ack critical checkpoints, schema migrations, protected load/corruption handling, server operation IDs and recoverable multi-key transaction primitives.

The next dependency is **TA-5 — Stable IDs, Content Registries, Configuration Schemas, and Data-Driven Definitions**.
