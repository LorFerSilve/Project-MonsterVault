# Roblox System Context, Toolchain, and Development Environment

> **Status:** Architecture Complete — TA-1  
> **Authority:** Roblox execution context, environment topology, source-of-truth boundaries, Rojo/Rokit workflow, Luau tooling and reproducible developer environment.

Authoritative specification:

- [01_roblox_system_context_toolchain_and_development_environment.md](01_roblox_system_context_toolchain_and_development_environment.md) — Architecture Complete.

Closure evidence:

- [../TA1_TOOLCHAIN_SNAPSHOT.md](../TA1_TOOLCHAIN_SNAPSHOT.md) — PASS;
- [../TA1_GDS_TRACEABILITY.md](../TA1_GDS_TRACEABILITY.md) — PASS;
- [../TA1_SCENARIO_VALIDATION.md](../TA1_SCENARIO_VALIDATION.md) — 75 / 75 PASS;
- [../TA1_DECISION_INDEX.md](../TA1_DECISION_INDEX.md) — accepted decisions;
- [../TA1_CLOSURE_REPORT.md](../TA1_CLOSURE_REPORT.md) — PASS.

TA-1 selects a filesystem-first Rojo workflow, Rokit-pinned developer tools, strict first-party Luau, StyLua, Selene and luau-lsp, while keeping Roblox Studio as the authoritative runtime/editor environment. DEV/STAGING/PRODUCTION are separated conceptually, the launch topology defaults to one primary gameplay place, and no runtime package manager or third-party Luau framework is adopted until a concrete dependency is justified.

The next dependency is **TA-2 — Repository Layout, Module Boundaries, Dependency Direction, and Bootstrapping**.
