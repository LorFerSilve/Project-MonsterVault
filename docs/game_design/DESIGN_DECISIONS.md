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
**Status:** Accepted — confirmed and refined by GDS-1

### Context

The initial concept exploration prioritized discoverability, retention, social play, monetization potential and feasibility for a small development effort.

### Decision

MonsterVault is designed around a social creature-collection/progression loop in which players discover and capture creatures, return them to a personal vault/laboratory, derive progression value from their collection, discover rare mutations/variants, unlock additional regions, participate in server-wide events, and later interact through trading and competition/cooperation.

GDS-1 refines this into the product promise:

> **Find it. Catch it. Bring it home. Make your vault legendary.**

### Rationale

The loop supports simple onboarding, visible progression, collection status, live-content extensibility and multiple non-destructive monetization surfaces.

### Affected Specifications

GDS-1 and all downstream gameplay domains.

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

Detailed design work needs stable rules for ownership, maturity, precedence and handoff.

### Evidence

- `STRUCTURE_AUDIT.md` — PASS;
- `GDS0_CLOSURE_REPORT.md` — PASS.

### Consequence

The active dependency advanced to GDS-1.

---

## DD-004 — Primary Audience and Mobile-First Cross-Platform Strategy

**Date:** 2026-09-15  
**Status:** Accepted

### Context

MonsterVault requires a broad Roblox audience while collection, progression, events, and future trading still need enough depth to retain older players. Current Roblox age-based account structure also makes the 9–15 audience strategically important.

### Decision

The primary target audience is approximately **ages 9–15**, with older teens/young adults as a secondary collection/optimization audience.

The experience uses a **mobile-first interaction constraint with cross-platform gameplay parity**. Core progression may not depend on unrestricted text chat, voice chat, keyboard-only input, tiny touch targets, or universal precision aiming.

### Rationale

This maximizes accessibility and audience reach without forcing the product to become simplistic or child-exclusive.

### Alternatives Rejected

- designing primarily for very young players (5–8);
- designing primarily for desktop/high-precision controls;
- making social communication a prerequisite for progress.

### Affected Specifications

GDS-1, GDS-3, GDS-10, GDS-14, GDS-15.

---

## DD-005 — Active Collection Positioning and Non-Loss-Dominant Competition

**Date:** 2026-09-15  
**Status:** Accepted

### Context

The project needs a recognizable hook without becoming another passive pet simulator or direct steal-game clone. Permanent loss of earned high-value collectibles can create strong moments but also undermines collection attachment and broad-audience trust when it becomes the default loop.

### Decision

MonsterVault is positioned as a **social creature-collection and progression adventure** centered on active world acquisition, a visible vault, rare variants, and shared server opportunities.

Competition is allowed, but the baseline product is **not loss-dominant**. Unrestricted theft of already-secured persistent creatures is not part of the core product contract. Competition may occur before secure ownership, through races/events, or through explicitly bounded optional risk mechanics.

Direct combat PvP is not a core product requirement.

### Rationale

This preserves social tension and viral moments while protecting the emotional value of collection ownership.

### Alternatives Rejected

- generic idle/pet-simulator positioning;
- making permanent player theft the defining mechanic;
- combat-first PvP positioning.

### Affected Specifications

GDS-4, GDS-5, GDS-6, GDS-7, GDS-10, GDS-11, GDS-12.

---

## DD-006 — Fast Time-to-Fun and Flexible Session Shape

**Date:** 2026-09-15  
**Status:** Accepted

### Context

Roblox users can leave an experience with very little friction, so the product must demonstrate its core promise quickly while still supporting long-term collection depth.

### Decision

MonsterVault targets:

- meaningful visible action within roughly 30–45 seconds;
- first real capture attempt within roughly 60 seconds;
- first secured creature within roughly 3 minutes;
- first visible progression choice within roughly 6 minutes;
- a normal session of roughly 10–25 minutes;
- meaningful 3–5 minute short sessions and optional 30–60 minute extended sessions.

The opening experience may not be dominated by tutorials, claim screens, stores, or complex menus.

### Rationale

The player should experience the product promise before being asked to understand secondary systems.

### Affected Specifications

GDS-3, GDS-5, GDS-7, GDS-8, GDS-11, GDS-14, GDS-16.

---

## DD-007 — Retention-First Product KPI Hierarchy

**Date:** 2026-09-15  
**Status:** Accepted

### Context

The project's goal is popularity and sustainable revenue, but optimizing monetization or raw playtime before players genuinely enjoy and revisit the game can create misleading success signals.

### Decision

Product health is evaluated in this order:

1. comprehension/satisfaction;
2. retention;
3. meaningful engagement;
4. intentional social value;
5. acquisition/discovery conversion;
6. monetization.

MonsterVault uses absolute internal first-session targets plus current Roblox similar-experience benchmarks for public D1/D7/session/play-through evaluation. Large-scale content or paid acquisition should not be justified by revenue alone when retention is weak.

### Rationale

This aligns product investment with durable player behavior instead of short-lived conversion.

### Affected Specifications

GDS-13 and GDS-16, plus later production/analytics architecture.

---

## DD-008 — Moderate Monetization, Deferred Trading, and Live-Content Product Model

**Date:** 2026-09-15  
**Status:** Accepted

### Context

Collection games offer strong monetization and trading potential, but these systems amplify value-integrity, fairness, support, and player-trust risks.

### Decision

MonsterVault targets **moderate, visible-but-non-coercive monetization**. Cosmetics, status, viable capacity convenience, bounded acceleration, starter value, and server-wide value are acceptable high-level directions; exact products remain GDS-13 authority.

Trading is strategically desirable but **not launch-critical** and ships only if GDS-12 can define safe value transfer.

The product is intended to support frequent small live-content additions. A roughly weekly small-update/event capability is a production aspiration, not a mandatory release promise.

### Rationale

The strategy preserves commercial upside while preventing trading or monetization from becoming prerequisites for validating the core product.

### Affected Specifications

GDS-11, GDS-12, GDS-13, GDS-16.

---

## DD-009 — Close GDS-1 Product Vision Baseline

**Date:** 2026-09-15  
**Status:** Accepted

### Context

The GDS-1 product specifications now resolve all high-level audience, positioning, session, commercial, scope, and success-gate questions and have passed cross-validation.

### Decision

GDS-1 is formally closed as `Complete — PASS`.

Material changes to target audience, product fantasy/category, competitive-loss intensity, session promise, platform priority, monetization intensity, trading launch position, product KPI hierarchy, or high-level non-goals require GDS-1 change control and revalidation.

### Evidence

- `01_game_overview.md` — Design Complete;
- `product/` GDS-1 specifications — Design Complete;
- `GDS1_CROSS_VALIDATION.md` — PASS;
- `GDS1_CLOSURE_REPORT.md` — PASS.

### Consequence

The active dependency advances to **GDS-2 — Global Game Rules and Session Model**. Technical Architecture and gameplay implementation remain blocked.
