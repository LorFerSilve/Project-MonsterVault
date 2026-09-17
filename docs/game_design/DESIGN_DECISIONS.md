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

---

## DD-010 — Server Sessions Are Disposable; Persistent Progress Is Session-Independent

**Date:** 2026-09-17  
**Status:** Accepted

### Context

MonsterVault needs server-local world opportunities while the player's collection and progression must remain trustworthy across ordinary Roblox server churn.

### Decision

A Server Session is a temporary runtime context, not the owner of long-term player progression. Finalized Persistent Player State survives ordinary avatar failure, reset, disconnect, reconnect, server change, device change, and server shutdown.

### Rationale

This preserves collection trust and supports flexible session lengths without requiring an MMO-scale shared world.

### Alternatives Rejected

- tying long-term progression to one server lifetime;
- treating every server join as a fresh progression instance;
- requiring a special clean logout/save ritual.

### Affected Specifications

GDS-2 and all persistent downstream systems.

---

## DD-011 — Protected Persistence Readiness Before Irreversible Play

**Date:** 2026-09-17  
**Status:** Accepted

### Context

Entering play with missing/untrusted persistent state risks blank-profile overwrite, contradictory ownership, purchase loss, and severe player-trust failures.

### Decision

Irreversible gameplay is blocked until trusted persistent state is ready. If trusted state cannot be established, the player enters **Protected Load Failure** with retry/reconnect/leave paths. A fabricated blank fallback profile must not silently become authoritative.

### Rationale

Temporary inability to enter irreversible play is preferable to corrupting or overwriting established persistent progress.

### Alternatives Rejected

- letting the player progress on an empty temporary profile and merging later by default;
- treating persistence failure as a new-player state;
- relying on clean disconnect to repair uncertain state.

### Affected Specifications

GDS-2, GDS-3, GDS-12, GDS-13, and Technical Architecture.

---

## DD-012 — Disconnect/Reset Are Interruptions, Not Default Persistent Punishments

**Date:** 2026-09-17  
**Status:** Accepted

### Context

Mobile networks, client crashes, Roblox server restarts, and voluntary short sessions are normal conditions. Making these lifecycle events globally punitive would conflict with GDS-1's persistent collection and healthy session-end contract.

### Decision

Ordinary disconnect, avatar failure, reset, and server shutdown do not themselves erase finalized secured persistent value. Failure invokes Recovery rather than a global progression wipe. Unfinalized transient activities must define their own deterministic interruption behavior in their owning subsystem.

Reset/reconnect must not become a superior strategy for duplicating rewards, avoiding finalized costs, or rerolling finalized outcomes.

### Rationale

The rule protects player trust without removing all risk from future transient gameplay mechanics.

### Affected Specifications

GDS-2 through GDS-13 where interruption can occur.

---

## DD-013 — No Baseline Offline Live-World Presence or Mandatory Offline Progression

**Date:** 2026-09-17  
**Status:** Accepted

### Context

The product may later benefit from bounded vault/offline progression, but simulating offline players as continuously present in live servers would complicate fairness, claims, and architecture unnecessarily.

### Decision

Offline players hold no live-world creature/event/contest claims by default. Offline progression is not guaranteed by GDS-2. If GDS-7/GDS-8 later introduce it, it must derive from persistent state plus explicit elapsed-time semantics and bounded rules.

### Rationale

This leaves room for commercially/retentively useful offline systems without making live-world simulation a baseline requirement.

### Affected Specifications

GDS-7, GDS-8, GDS-11, GDS-16, Technical Architecture.

---

## DD-014 — Cross-Server Time and Outcome Continuity

**Date:** 2026-09-17  
**Status:** Accepted

### Context

Server transitions create abuse risk when they reset timers, repeat one-time rewards, or restart calendar windows.

### Decision

Finalized persistent outcomes are single-application across retries/reconnects. Persistent timed effects must explicitly declare elapsed-time semantics and do not implicitly restart on server change. Global calendar windows do not restart per server. MonsterVault does not assume a single continuously shared cross-server world.

### Rationale

This preserves fairness/value integrity while allowing session-local world variation and small-team feasibility.

### Affected Specifications

GDS-2, GDS-7/GDS-8, GDS-9, GDS-11, GDS-12, GDS-13, Technical Architecture.

---

## DD-015 — Close GDS-2 Global Lifecycle Baseline

**Date:** 2026-09-17  
**Status:** Accepted

### Context

The GDS-2 global rules specification now resolves the complete universal session/lifecycle contract and has passed compound-scenario and cross-system validation.

### Decision

GDS-2 is formally closed as `Complete — PASS`.

Material changes to persistence permanence, Protected Load Failure, disconnect neutrality, Recovery-versus-wipe philosophy, cross-server timer/global-window semantics, baseline offline live-world claims, or session/persistence ownership require GDS-2 change control and revalidation.

### Evidence

- `global_rules/02_global_game_rules_and_session_model.md` — Design Complete;
- `GDS2_SCENARIO_VALIDATION.md` — PASS;
- `GDS2_CROSS_VALIDATION.md` — PASS;
- `GDS2_CLOSURE_REPORT.md` — PASS.

### Consequence

The active dependency advances to **GDS-3 — Player Character, Interaction, and Onboarding**. Technical Architecture and gameplay implementation remain blocked.

---

## DD-016 — Familiar Third-Person Baseline with Cross-Device Capability Parity

**Date:** 2026-09-17  
**Status:** Accepted

### Context

MonsterVault needs immediate comprehension for a broad 9–15 primary audience while preserving mobile-first constraints and full controller/desktop participation.

### Decision

Baseline exploration uses a third-person character-centric camera, familiar continuous directional movement, and conventional jump. Ordinary locomotion is not taxed by a universal stamina resource and the core loop does not universally depend on precision platforming.

Touch, keyboard/mouse, and gamepad expose equivalent baseline gameplay capabilities. Device-specific convenience may differ, but core progression cannot be device-exclusive.

### Rationale

This minimizes onboarding cost and preserves GDS-1's mobile-first, cross-platform, low-friction product contract.

### Alternatives Rejected

- first-person-only core exploration;
- click-to-move as the primary universal locomotion model;
- stamina-gating ordinary traversal;
- desktop-only precision controls for core progression.

### Affected Specifications

GDS-3, GDS-5, GDS-9, GDS-14, Technical Architecture.

---

## DD-017 — Universal Contextual Interaction Grammar

**Date:** 2026-09-17  
**Status:** Accepted

### Context

Creature capture, vault use, world objects, events, social systems and future mechanics will create many interactable entities. Independent button vocabularies would increase cognitive load and become especially poor on touch/controller.

### Decision

MonsterVault uses one universal **Primary Interact** semantic for contextual world interactions and one **Primary Action** semantic for the active tool/mechanic where applicable.

Exactly one **Active Context** is immediately actionable at a time. The visible target is revalidated on activation. Prompts communicate an action verb/outcome plus current-device input. Modal input focus prevents the same press from closing UI and accidentally activating an exposed consequential world action.

### Rationale

A small stable interaction vocabulary scales to future systems while remaining teachable and cross-device compatible.

### Alternatives Rejected

- unique mandatory keys for each interactable class;
- ambiguous multi-target activation from one prompt;
- precision-cursor selection as the universal interaction requirement.

### Affected Specifications

GDS-3 through GDS-14, Technical Architecture.

---

## DD-018 — Gameplay-First Onboarding with Persistent Knowledge Milestones

**Date:** 2026-09-17  
**Status:** Accepted

### Context

GDS-1 requires meaningful action within seconds and the core capture/progression promise within the opening minutes. A front-loaded tutorial would directly undermine that target.

### Decision

First-session onboarding follows a progressive `show -> do -> confirm` structure embedded in real gameplay: gain control, notice one desirable goal, move/interact, enter the first real capture mechanic, secure a first result, see visible vault/collection impact, and encounter a first progression choice.

Completed **Onboarding Milestones** persist across ordinary disconnect/server changes. Non-essential **Guidance Layer** presentation may be skipped or replayed, but skipping guidance never fabricates real progression or rewards.

A new player must have access to a valid first learning path even in an already-running/crowded server.

### Rationale

This protects time-to-fun, avoids repeated tutorial friction, and prevents disconnect/replay from becoming a reward duplication path.

### Alternatives Rejected

- long mandatory tutorial instance before core gameplay;
- full tutorial restart on every disconnect;
- granting tutorial rewards merely for skipping instructional prompts.

### Affected Specifications

GDS-3, GDS-4, GDS-5, GDS-7, GDS-8, GDS-9, GDS-10, GDS-14, GDS-16.

---

## DD-019 — Safe Arrival and Recovery Are Control-Restoration States, Not Extraction Mechanics

**Date:** 2026-09-17  
**Status:** Accepted

### Context

GDS-2 defines Persistence Ready and Recovery semantically but leaves concrete player entry/re-entry behavior to GDS-3. Reset/stuck recovery also creates exploit risk if it transports unfinalized value safely.

### Decision

After Persistence Ready, **Safe Arrival** establishes the Player Character, camera, orientation and direct control before ordinary exposure.

Failure/reset/stuck conditions use **Recovery** to a valid **Recovery Anchor**, restoring ordinary camera/control while preserving finalized persistent progression. Recovery does not inherently secure transient value, waive finalized costs, or function as a generally superior fast-travel/extraction path.

### Rationale

Players need reliable recovery without converting lifecycle tooling into an economy/capture exploit.

### Affected Specifications

GDS-2, GDS-3, GDS-5, GDS-9, GDS-10, Technical Architecture.

---

## DD-020 — Interaction Accessibility Is a Semantic Requirement

**Date:** 2026-09-17  
**Status:** Accepted

### Context

Deferring every accessibility question to visual polish would allow downstream mechanics to hard-code inaccessible interaction assumptions before GDS-14.

### Decision

GDS-3 locks semantic accessibility constraints before presentation design:

- no progression-critical action depends solely on color or audio;
- core interaction does not require pixel-precision aim, high-frequency repeated tapping, free-form chat, or drag-and-drop as the only path;
- touch/controller have discrete practical controls for required actions;
- camera guidance yields to meaningful player input;
- modal/controller interaction remains possible for required onboarding flows.

GDS-14 retains authority over final HUD, settings, remapping, typography, reduced-motion behavior, visual/audio language, and the complete accessibility feature set.

### Rationale

Accessibility-critical semantic constraints must exist before downstream mechanics are considered Design Complete.

### Affected Specifications

GDS-3, GDS-5, GDS-12, GDS-13, GDS-14, Technical Architecture.

---

## DD-021 — Close GDS-3 Player Interaction and Onboarding Baseline

**Date:** 2026-09-17  
**Status:** Accepted

### Context

The GDS-3 player specification now resolves movement, camera, semantic controls, contextual interaction, onboarding, Safe Arrival/Recovery, input focus, basic equipment/inventory-facing behavior and interaction-accessibility requirements and has passed scenario/cross-system validation.

### Decision

GDS-3 is formally closed as `Complete — PASS`.

Material changes to third-person baseline exploration, baseline locomotion philosophy, Primary Interact/Primary Action semantics, single Active Context behavior, cross-device capability parity, gameplay-first onboarding, persistent onboarding milestones, Guidance Layer/progression separation, first-path availability, Safe Arrival, Recovery semantics, or interaction-level accessibility invariants require GDS-3 change control and revalidation.

### Evidence

- `player/03_player_character_interaction_and_onboarding.md` — Design Complete;
- `GDS3_SCENARIO_VALIDATION.md` — PASS;
- `GDS3_CROSS_VALIDATION.md` — PASS;
- `GDS3_CLOSURE_REPORT.md` — PASS.

### Consequence

The active dependency advances to **GDS-4 — Creatures, Collection, and Ownership**. Technical Architecture and gameplay implementation remain blocked.
