# Repository Structure, Module Boundaries, and Bootstrapping

> **Status:** Architecture Complete — TA-2  
> **Authority:** Source/DataModel mapping, module boundaries, dependency direction, composition roots and lifecycle/bootstrap structure.

Authoritative specification:

- [02_repository_layout_module_boundaries_dependency_direction_and_bootstrapping.md](02_repository_layout_module_boundaries_dependency_direction_and_bootstrapping.md) — Architecture Complete.

Closure evidence:

- [../TA2_DEPENDENCY_OWNERSHIP_MATRIX.md](../TA2_DEPENDENCY_OWNERSHIP_MATRIX.md) — PASS;
- [../TA2_GDS_TRACEABILITY.md](../TA2_GDS_TRACEABILITY.md) — PASS;
- [../TA2_SCENARIO_VALIDATION.md](../TA2_SCENARIO_VALIDATION.md) — 110 / 110 PASS;
- [../TA2_DECISION_INDEX.md](../TA2_DECISION_INDEX.md) — accepted;
- [../TA2_CLOSURE_REPORT.md](../TA2_CLOSURE_REPORT.md) — PASS.

TA-2 locks the future server/client/shared Rojo roots, modular-monolith organization, server bootstrap/application/domain/infrastructure/adapter layers, explicit construction/lifecycle, public domain contracts and one-directional dependency rules. It intentionally does not create the implementation scaffold before TA-17.

The next dependency is **TA-3 — Networking, Server Authority, Remote Contracts, and Exploit Boundaries**.
