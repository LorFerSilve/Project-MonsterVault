# Design Decisions

> **Status:** Active
> **Authority:** Strategic game-design decisions and rationale

This log records accepted design decisions that materially constrain MonsterVault's direction. It is not a substitute for subsystem specifications: the owning specification remains authoritative for detailed behavior.

## Decision Format

Each decision records:

- ID;
- date;
- status (`Proposed`, `Accepted`, `Superseded`, `Rejected`);
- context;
- decision;
- rationale;
- alternatives considered;
- affected specifications;
- consequences and follow-up.

---

## DD-001 — Specification-First Development

**Date:** 2026-09-15  
**Status:** Accepted

### Context

MonsterVault is intended as a commercially viable Roblox game with interconnected collection, economy, progression, social, live-ops, trading and monetization systems. Ad-hoc implementation would create high risk of contradictory rules and expensive rework.

### Decision

The project uses a formal pre-implementation pipeline:

`Game Design Specification -> Technical Architecture -> Implementation Lock -> Implementation`.

Gameplay implementation is prohibited until the design and architecture gates are formally closed.

### Rationale

This preserves product coherence, makes cross-system dependencies explicit, and prevents implementation choices from accidentally becoming game-design decisions.

### Affected Specifications

All GDS and TA documents.

---

## DD-002 — Core Product Direction

**Date:** 2026-09-15  
**Status:** Accepted as current baseline; subject to GDS review

### Context

The initial concept exploration prioritized discoverability, retention, social play, monetization potential and feasibility for a small development effort.

### Decision

MonsterVault begins design around a social creature-collection/progression loop in which players discover and capture creatures, return them to a personal vault/laboratory, derive progression value from their collection, discover rare mutations/variants, unlock additional regions, participate in server-wide events, and later interact through trading and competition/cooperation.

### Rationale

The loop supports simple onboarding, visible progression, collection status, live-content extensibility and multiple non-destructive monetization surfaces.

### Important Note

This is the **baseline direction**, not a final implementation contract. GDS-1 through GDS-17 must still validate, refine, constrain or reject individual mechanics.
