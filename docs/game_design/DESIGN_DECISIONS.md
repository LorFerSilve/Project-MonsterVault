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

---

## DD-003 — Close GDS-0 Governance Baseline

**Date:** 2026-09-15  
**Status:** Accepted

### Context

The specification-first documentation hierarchy has been established and audited for top-level ownership coverage. GDS-0 requires a stable governance baseline before detailed product and subsystem design begins.

### Decision

GDS-0 is formally closed as `Complete — PASS`.

The following governance contracts are now baseline authority:

- one authoritative home per gameplay rule;
- explicit `Draft`, `Under Review`, `Design Complete`, and `Implementation Locked` statuses;
- objective Design Complete criteria;
- mandatory explicit open questions during Draft status;
- historical concept material is non-authoritative;
- GDS completion precedes Technical Architecture completion;
- Technical Architecture completion and contract locking precede gameplay implementation;
- material governance changes require explicit decision logging and relevant re-audit.

### Rationale

Detailed design work needs stable rules for ownership, maturity, precedence and handoff. Without closing this baseline, later phases could reinterpret the process while using it, weakening the value of formal design completion.

### Evidence

- `STRUCTURE_AUDIT.md` — PASS;
- `GDS0_CLOSURE_REPORT.md` — PASS.

### Affected Specifications

- `00_design_authority.md`;
- `GDS_ROADMAP.md`;
- all current and future GDS specifications;
- downstream Technical Architecture and implementation gates.

### Consequence

The active dependency advances to **GDS-1 — Product Vision, Audience, and Success Criteria**. This decision does not authorize Technical Architecture or gameplay implementation.
