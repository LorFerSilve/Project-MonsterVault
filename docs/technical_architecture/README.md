# MonsterVault Technical Architecture

> **Status:** Active — TA-0 Next
> **Authority:** Technical implementation contracts after GDS completion

This directory contains the Technical Architecture layer that now becomes active after the GDS-17 Design Complete PASS.

The TA is deliberately not allowed to redefine gameplay. It translates the approved Game Design Specification into concrete Roblox/Luau architecture, ownership, networking, persistence, security, performance, testing and delivery contracts.

## Governance

- [`00_architecture_authority.md`](00_architecture_authority.md) defines architecture authority and status rules.
- [`TA_ROADMAP.md`](TA_ROADMAP.md) defines the dependency-driven architecture sequence.
- [`ARCHITECTURE_DECISIONS.md`](ARCHITECTURE_DECISIONS.md) will record accepted architecture decisions and rationale.
- `audit/` will contain the final architecture integration/readiness evidence.

## Current Gate

GDS-17 has recorded a formal **Design Complete — PASS** with zero implementation-critical design questions.

The active dependency is:

> **TA-0 — Architecture Governance, Constraints, and GDS Traceability**

Early notes about Roblox services, Rojo, Luau tooling, persistence libraries or module patterns remain hypotheses until their owning TA phase is formally closed. Gameplay implementation remains blocked until TA-17.
