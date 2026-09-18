# MonsterVault Technical Architecture

> **Status:** Active — TA-0..4 Complete / TA-5 Next
> **Authority:** Technical implementation contracts after GDS completion

This directory contains the Technical Architecture layer that now becomes active after the GDS-17 Design Complete PASS.

The TA is deliberately not allowed to redefine gameplay. It translates the approved Game Design Specification into concrete Roblox/Luau architecture, ownership, networking, persistence, security, performance, testing and delivery contracts.

## Governance

- [`00_architecture_authority.md`](00_architecture_authority.md) defines project-wide architecture authority and status rules.
- [`governance/00_architecture_governance_constraints_and_gds_traceability.md`](governance/00_architecture_governance_constraints_and_gds_traceability.md) is the authoritative TA-0 governance contract.
- [`TA0_GDS_TRACEABILITY_MATRIX.md`](TA0_GDS_TRACEABILITY_MATRIX.md) maps the Design Complete GDS into downstream TA ownership.
- [`TA0_ARCHITECTURE_RISK_REGISTER.md`](TA0_ARCHITECTURE_RISK_REGISTER.md) owns the architecture risk taxonomy.
- [`ARCHITECTURE_DECISIONS.md`](ARCHITECTURE_DECISIONS.md) records accepted architecture decisions and rationale.
- [`environment/01_roblox_system_context_toolchain_and_development_environment.md`](environment/01_roblox_system_context_toolchain_and_development_environment.md) is the authoritative TA-1 environment/toolchain contract.
- [`TA1_TOOLCHAIN_SNAPSHOT.md`](TA1_TOOLCHAIN_SNAPSHOT.md) records the dated reference toolchain.
- [`structure/02_repository_layout_module_boundaries_dependency_direction_and_bootstrapping.md`](structure/02_repository_layout_module_boundaries_dependency_direction_and_bootstrapping.md) is the authoritative TA-2 structure/bootstrap contract.
- [`TA2_DEPENDENCY_OWNERSHIP_MATRIX.md`](TA2_DEPENDENCY_OWNERSHIP_MATRIX.md) defines permitted dependency and mutation ownership boundaries.
- [`networking/03_networking_server_authority_remote_contracts_and_exploit_boundaries.md`](networking/03_networking_server_authority_remote_contracts_and_exploit_boundaries.md) is the authoritative TA-3 networking/trust-boundary contract.
- [`TA3_REMOTE_CONTRACT_MATRIX.md`](TA3_REMOTE_CONTRACT_MATRIX.md) locks transport/envelope/validation responsibilities.
- [`persistence/04_player_data_persistence_session_ownership_schema_evolution_and_recovery.md`](persistence/04_player_data_persistence_session_ownership_schema_evolution_and_recovery.md) is the authoritative TA-4 persistence/session/recovery contract.
- [`TA4_PERSISTENCE_SESSION_MATRIX.md`](TA4_PERSISTENCE_SESSION_MATRIX.md) locks persistence state, durability and transaction boundaries.
- [`TA_ROADMAP.md`](TA_ROADMAP.md) defines the dependency-driven architecture sequence.
- `audit/` will contain the final TA-16 integration/readiness evidence.

## Current Gate

GDS-17 has recorded a formal **Design Complete — PASS** with zero implementation-critical design questions.

TA-0 through TA-4 are **Architecture Complete — PASS**.

TA-4 closed with 180 / 180 persistence/recovery scenarios passing, atomic session ownership, P2 durability boundaries and a complete persistence/session/transaction matrix.

The active dependency is:

> **TA-5 — Identity, Content Registries, Configuration, and Data-Driven Content**

TA-5 now owns stable identifiers and validated content/config registries referenced by persistent state and later runtime systems. Gameplay implementation remains blocked until TA-17.
