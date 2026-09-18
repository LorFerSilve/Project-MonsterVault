# MonsterVault Technical Architecture

> **Status:** Active — TA-0..2 Complete / TA-3 Next
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
- [`TA_ROADMAP.md`](TA_ROADMAP.md) defines the dependency-driven architecture sequence.
- `audit/` will contain the final TA-16 integration/readiness evidence.

## Current Gate

GDS-17 has recorded a formal **Design Complete — PASS** with zero implementation-critical design questions.

TA-0 through TA-2 are **Architecture Complete — PASS**.

TA-2 closed with 110 / 110 structural scenarios passing and a complete dependency/ownership matrix.

The active dependency is:

> **TA-3 — Networking, Server Authority, Remote Contracts, and Exploit Boundaries**

TA-3 will define the centrally governed networking layer inside the TA-2 server/client/shared roots. Gameplay implementation remains blocked until TA-17.
