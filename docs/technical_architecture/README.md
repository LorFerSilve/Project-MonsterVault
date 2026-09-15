# MonsterVault Technical Architecture

> **Status:** Blocked by Game Design Specification
> **Authority:** Technical implementation contracts after GDS completion

This directory will contain MonsterVault's authoritative Technical Architecture (TA).

The TA is deliberately not allowed to redefine gameplay. It translates the approved Game Design Specification into concrete Roblox/Luau architecture, ownership, networking, persistence, security, performance, testing and delivery contracts.

## Governance

- [`00_architecture_authority.md`](00_architecture_authority.md) defines architecture authority and status rules.
- [`TA_ROADMAP.md`](TA_ROADMAP.md) defines the dependency-driven architecture sequence.
- [`ARCHITECTURE_DECISIONS.md`](ARCHITECTURE_DECISIONS.md) will record accepted architecture decisions and rationale.
- `audit/` will contain the final architecture integration/readiness evidence.

## Current Rule

No Technical Architecture phase may be promoted while GDS-17 has not recorded a formal Design Complete PASS.

Early notes about Roblox services, Rojo, Luau tooling, persistence libraries or module patterns are hypotheses only until their owning TA phase is active.
