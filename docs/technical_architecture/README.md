# MonsterVault Technical Architecture

> **Status:** Active — TA-0..15 Complete / TA-16 Next
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
- [`economy/08_vault_economy_progression_inventory_and_offline_accrual.md`](economy/08_vault_economy_progression_inventory_and_offline_accrual.md) is the authoritative TA-8 Vault/economy/offline-accrual contract.
- [`TA8_VAULT_ECONOMY_OFFLINE_MATRIX.md`](TA8_VAULT_ECONOMY_OFFLINE_MATRIX.md) locks capacity, numeric, production, wallet and purchase boundaries.
- [`world/09_world_biomes_spawn_scheduling_streaming_and_encounter_scaling.md`](world/09_world_biomes_spawn_scheduling_streaming_and_encounter_scaling.md) is the authoritative TA-9 world/spawn/streaming contract.
- [`TA9_WORLD_SPAWN_STREAMING_MATRIX.md`](TA9_WORLD_SPAWN_STREAMING_MATRIX.md) locks world authority, scheduling, streaming, progression and failure boundaries.
- [`social_events_trading/10_social_events_cross_server_coordination_and_trading.md`](social_events_trading/10_social_events_cross_server_coordination_and_trading.md) is the authoritative TA-10 social/event/trade architecture contract.
- [`TA10_SOCIAL_EVENT_TRADE_MATRIX.md`](TA10_SOCIAL_EVENT_TRADE_MATRIX.md) locks social state, event authority, cross-server coordination and trade transaction boundaries.
- [`commerce/11_monetization_marketplace_receipts_and_entitlements.md`](commerce/11_monetization_marketplace_receipts_and_entitlements.md) is the authoritative TA-11 commerce/receipt/entitlement contract.
- [`TA11_COMMERCE_RECEIPT_ENTITLEMENT_MATRIX.md`](TA11_COMMERCE_RECEIPT_ENTITLEMENT_MATRIX.md) locks product, receipt, entitlement, price and reversal boundaries.
- [`client/12_client_presentation_ui_input_camera_audio_and_accessibility.md`](client/12_client_presentation_ui_input_camera_audio_and_accessibility.md) is the authoritative TA-12 client/presentation/input/accessibility contract.
- [`TA12_CLIENT_PRESENTATION_INPUT_ACCESSIBILITY_MATRIX.md`](TA12_CLIENT_PRESENTATION_INPUT_ACCESSIBILITY_MATRIX.md) locks client state, input context, focus, safe-area, accessibility and authoritative-feedback boundaries.
- [`operations/13_analytics_telemetry_feature_flags_configuration_rollouts_and_live_operations.md`](operations/13_analytics_telemetry_feature_flags_configuration_rollouts_and_live_operations.md) is the authoritative TA-13 analytics/config/experiment/live-ops contract.
- [`TA13_ANALYTICS_CONFIG_LIVEOPS_MATRIX.md`](TA13_ANALYTICS_CONFIG_LIVEOPS_MATRIX.md) locks telemetry channels, C2 snapshots, flags, experiment and privileged-operation boundaries.
- [`performance/14_performance_network_memory_persistence_and_scalability_budgets.md`](performance/14_performance_network_memory_persistence_and_scalability_budgets.md) is the authoritative TA-14 budget/scalability contract.
- [`TA14_PERFORMANCE_SCALABILITY_BUDGET_MATRIX.md`](TA14_PERFORMANCE_SCALABILITY_BUDGET_MATRIX.md) locks the cross-system numeric performance, network, memory and service guardrails.
- [`verification/15_testing_diagnostics_security_validation_and_ci_architecture.md`](verification/15_testing_diagnostics_security_validation_and_ci_architecture.md) is the authoritative TA-15 verification/security/CI contract.
- [`TA15_VERIFICATION_QUALITY_GATE_MATRIX.md`](TA15_VERIFICATION_QUALITY_GATE_MATRIX.md) locks the required test classes, criticality and merge/release evidence.
- [`TA_ROADMAP.md`](TA_ROADMAP.md) defines the dependency-driven architecture sequence.
- `audit/` will contain the final TA-16 integration/readiness evidence.

## Current Gate

GDS-17 has recorded a formal **Design Complete — PASS** with zero implementation-critical design questions.

TA-0 through TA-15 are **Architecture Complete — PASS**.

TA-15 closed with 360 / 360 verification-architecture scenarios passing and deterministic/static/Studio/fault/security/performance evidence contracts, public-repository CI privilege separation, non-quarantinable C0 invariants and explicit merge/release quality gates.

The active dependency is:

> **TA-16 — Architecture Integration and Implementation-Readiness Audit**

TA-16 now owns the final cross-system architecture integration/readiness audit across TA-0..15. Gameplay implementation remains blocked until TA-17.
