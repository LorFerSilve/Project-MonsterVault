# MonsterVault Technical Architecture

> **Status:** Active — TA-0..1 Complete / TA-2 Next
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
- [`TA_ROADMAP.md`](TA_ROADMAP.md) defines the dependency-driven architecture sequence.
- `audit/` will contain the final TA-16 integration/readiness evidence.

## Current Gate

GDS-17 has recorded a formal **Design Complete — PASS** with zero implementation-critical design questions.

TA-0 is **Architecture Complete — PASS**.

TA-1 is **Architecture Complete — PASS** with 75 / 75 environment/toolchain scenarios passing.

The active dependency is:

> **TA-2 — Repository Layout, Module Boundaries, Dependency Direction, and Bootstrapping**

TA-2 will lock the concrete source/DataModel mapping and module/bootstrap structure using the TA-1 Rojo/Rokit/strict-Luau baseline. Gameplay implementation remains blocked until TA-17.
