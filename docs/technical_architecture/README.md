# MonsterVault Technical Architecture

> **Status:** Active — TA-0..7 Complete / TA-8 Next
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
- [`content/05_identity_content_registries_configuration_and_data_driven_content.md`](content/05_identity_content_registries_configuration_and_data_driven_content.md) is the authoritative TA-5 identity/content/configuration contract.
- [`TA5_IDENTITY_REGISTRY_MATRIX.md`](TA5_IDENTITY_REGISTRY_MATRIX.md) locks stable identity, registry ownership and lifecycle compatibility.
- [`runtime/06_runtime_entity_player_creature_and_world_lifecycle.md`](runtime/06_runtime_entity_player_creature_and_world_lifecycle.md) is the authoritative TA-6 runtime/entity-lifecycle contract.
- [`TA6_RUNTIME_LIFECYCLE_MATRIX.md`](TA6_RUNTIME_LIFECYCLE_MATRIX.md) locks runtime authority, projection and cleanup boundaries.
- [`capture/07_capture_creature_ownership_mutation_and_reward_resolution.md`](capture/07_capture_creature_ownership_mutation_and_reward_resolution.md) is the authoritative TA-7 capture/ownership/randomness contract.
- [`TA7_CAPTURE_VARIANT_FINALIZATION_MATRIX.md`](TA7_CAPTURE_VARIANT_FINALIZATION_MATRIX.md) locks claim, Variant and P2 finalization boundaries.
- [`TA_ROADMAP.md`](TA_ROADMAP.md) defines the dependency-driven architecture sequence.
- `audit/` will contain the final TA-16 integration/readiness evidence.

## Current Gate

GDS-17 has recorded a formal **Design Complete — PASS** with zero implementation-critical design questions.

TA-0 through TA-7 are **Architecture Complete — PASS**.

TA-7 closed with 200 / 200 capture/randomness/finalization scenarios passing and a complete anti-reroll, provisional-custody, exact-once ownership model.

The active dependency is:

> **TA-8 — Vault, Economy, Progression, Inventory, and Offline Accrual**

TA-8 now owns the persistent Collection/Vault/Energy/progression schemas and transactions consumed by TA-7 finalization. Gameplay implementation remains blocked until TA-17.
