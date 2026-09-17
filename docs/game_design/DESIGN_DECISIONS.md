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

---

## DD-022 — Secured Creatures Are Stable Individual Instances

**Date:** 2026-09-17  
**Status:** Accepted

### Context

MonsterVault's differentiation depends on players caring about which specific creatures they own. Representing collection ownership only as Species counts would weaken provenance, variants, trading, display, locking, and long-term attachment.

### Decision

Species is an authored archetype, while ownership concerns specific **Creature Instances**. Every **Secured Creature** preserves stable individual identity across ordinary avatar/session/device lifecycle and collection-placement changes.

Duplicates of the same Species are valid distinct instances and are not automatically merged, converted, or deleted.

### Rationale

Instance-level identity makes the collection genuinely collectible and provides a coherent foundation for later mutations, provenance, display, trading, and value integrity.

### Alternatives Rejected

- storing player ownership only as Species quantities;
- silently replacing individual instances after reconnect;
- automatic duplicate conversion at acquisition.

### Affected Specifications

GDS-4, GDS-5, GDS-6, GDS-7, GDS-11, GDS-12, Technical Architecture.

---

## DD-023 — Capacity Pressure Must Never Silently Destroy Secured Ownership

**Date:** 2026-09-17  
**Status:** Accepted

### Context

Collection/storage capacity is commercially and progression-relevant, but capacity changes create severe trust risks if already-owned creatures can disappear when slots are full or entitlements change.

### Decision

Full, reduced, or expired ordinary capacity does not silently delete a Secured Creature. If **Secured Ownership Finalization** occurs when ordinary eligible placement capacity is unavailable, the creature becomes **Overflow-Held**: persistent and safely owned, but restricted from normal active/storage functions until capacity is resolved.

Overflow is a safety state, not intended unlimited storage. A non-payment resolution path must always exist.

### Rationale

This preserves ownership trust while keeping capacity meaningful and monetizable within later fairness constraints.

### Alternatives Rejected

- deleting the newest secured creature when full;
- deleting excess creatures when paid capacity expires;
- making payment the only way to recover a valid over-capacity collection;
- treating overflow as unrestricted permanent free storage.

### Affected Specifications

GDS-4, GDS-5, GDS-7, GDS-8, GDS-13, Technical Architecture.

---

## DD-024 — Voluntary Release Is Explicit and Protected by Creature Lock

**Date:** 2026-09-17  
**Status:** Accepted

### Context

Finite collection capacity may eventually require players to remove or transfer creatures, but accidental permanent loss would directly undermine collection attachment.

### Decision

Permanent voluntary removal uses an explicit **Release** action targeting a specific Creature Instance and requiring clear confirmation. **Creature Lock** is a persistent player-controlled protection flag that blocks voluntary destructive and future ownership-transfer actions until explicitly removed.

Ordinary session lifecycle, capacity overflow, movement, UI dismissal, or Recovery cannot trigger Release.

### Rationale

This creates a deliberate capacity-management path while protecting valuable collection assets against accidental input and future bulk/trade mistakes.

### Affected Specifications

GDS-4, GDS-6, GDS-8, GDS-12, GDS-14, Technical Architecture.

---

## DD-025 — Species Discovery Is Historical; Provenance Belongs to the Instance

**Date:** 2026-09-17  
**Status:** Accepted

### Context

Collection completion needs stable long-term meaning even if players later release or trade creatures, while individual creatures need persistent history that can support status and future value discovery.

### Decision

Legitimately securing a Species records persistent **Species Discovery**. Releasing the last currently owned instance does not erase that historical discovery. Baseline Species completion is discovery-based unless a later specialized objective explicitly states simultaneous-ownership requirements.

Where recorded, **Provenance** remains instance history distinct from current ownership and is not rewritten by routine storage, server changes, or future ownership transfer.

### Rationale

Players retain credit for genuine discovery while individual instances can carry meaningful collectible history over time.

### Affected Specifications

GDS-4, GDS-6, GDS-8, GDS-11, GDS-12, GDS-14, GDS-16.

---

## DD-026 — Ownership Transfer Requires Explicit Transaction Authority

**Date:** 2026-09-17  
**Status:** Accepted

### Context

Stable collectible value is incompatible with ambiguous informal ownership transfer. Dropping, lending, gifting, shared ownership, or visual proximity could otherwise create contradictory claims or duplication pressure.

### Decision

A Secured Creature has one ordinary owner at a time. Player-to-player transfer does not exist implicitly through dropping, lending, display access, or world interaction. Any future transfer must be defined by GDS-12 or another explicit authority and must preserve stable instance identity, one-owner semantics, Creature Lock, provenance, and Finalized Outcome integrity.

### Rationale

This keeps the collection model safe before trading is proven and creates a clear contract for later atomic transfer design.

### Affected Specifications

GDS-4, GDS-10, GDS-12, Technical Architecture.

---

## DD-027 — Close GDS-4 Creature Collection and Ownership Baseline

**Date:** 2026-09-17  
**Status:** Accepted

### Context

The GDS-4 specification now resolves Creature Instance identity, ownership, collection states, duplicates, capacity/overflow, voluntary loss protection, discovery/completion, provenance, and future-transfer prerequisites and has passed scenario/cross-system validation.

### Decision

GDS-4 is formally closed as `Complete — PASS`.

Material changes to instance-level ownership, one-owner semantics, secured persistence, duplicate preservation, Overflow-Held safety, voluntary Release, Creature Lock, baseline no-involuntary-loss rules, Species Discovery persistence, provenance continuity, or explicit transfer authority require GDS-4 change control and revalidation.

### Evidence

- `creatures/04_creatures_collection_and_ownership.md` — Design Complete;
- `GDS4_SCENARIO_VALIDATION.md` — PASS;
- `GDS4_CROSS_VALIDATION.md` — PASS;
- `GDS4_CLOSURE_REPORT.md` — PASS.

### Consequence

The active dependency advances to **GDS-5 — Capture, Contesting, Transport, and Extraction**. Technical Architecture and gameplay implementation remain blocked.

---

## DD-028 — Ordinary Capture Uses a Bounded Exclusive Engagement Claim

**Date:** 2026-09-17  
**Status:** Accepted

### Context

Visible shared creatures create natural multiplayer races, but allowing several players to run contradictory single-winner capture attempts simultaneously would waste resources, create ownership ambiguity, and reward network races instead of understandable gameplay.

### Decision

A normal single-award Capture Opportunity supports at most one active ordinary **Engagement Claim**. The valid claimant receives temporary exclusive attempt authority; later players cannot overwrite that claim merely through proximity/input.

Engagement Claims are transient, bounded, and not ownership. They end on success, failure/cancel where defined, invalidation, excessive separation/inactivity, or other explicit release condition. Repeated start/cancel behavior cannot reserve a public creature indefinitely.

### Rationale

This retains visible social racing while giving an active attempt deterministic semantics and preventing contradictory spending/winners.

### Alternatives Rejected

- fully simultaneous independent attempts against one ordinary finite creature;
- permanent first-touch reservation;
- proximity-based claim stealing during an accepted attempt.

### Affected Specifications

GDS-5, GDS-8, GDS-9, GDS-10, GDS-11, GDS-14, Technical Architecture.

---

## DD-029 — Capture Success Is Provisional; Extraction Finalizes Ownership

**Date:** 2026-09-17  
**Status:** Accepted

### Context

The product promise explicitly includes both `Catch it` and `Bring it home`. If Capture Success immediately created persistent ownership, transport would lose its ownership significance; if ownership remained ambiguous indefinitely, players could not trust their collection.

### Decision

**Capture Success creates a Provisional Capture**, not a GDS-4 Secured Creature. The same specific creature instance enters temporary **Transport Custody**.

The baseline ordinary ownership boundary is validated **Extraction Completion at an eligible Secure Point**. That event emits `Secured Ownership Finalization(player, creature)` exactly once; from that moment the creature is Persistent Player State under GDS-4.

### Rationale

This makes `Bring it home` mechanically meaningful while preserving a crisp, auditable boundary between transient acquisition and permanent ownership.

### Alternatives Rejected

- persistent ownership immediately on capture success;
- ownership only after an arbitrary post-capture timer;
- ambiguous ownership based on visual following/proximity.

### Affected Specifications

GDS-2, GDS-4, GDS-5, GDS-7, GDS-9, GDS-10, GDS-14, Technical Architecture.

---

## DD-030 — Baseline Transport Is Single-Custody and Not Directly Stealable

**Date:** 2026-09-17  
**Status:** Accepted

### Context

Transport should create a readable return cadence and social visibility without making the product loss-dominant or forcing direct-combat PvP.

### Decision

A player may ordinarily hold **one active Provisional Capture / Transport Custody at a time**. They must resolve that transport before beginning another normal capture.

Once Capture Success creates valid Transport Custody, unrelated players cannot directly steal or transfer that custody merely through proximity, interaction, or baseline PvP. Future optional interception/risk modes require explicit GDS-10/GDS-11 design and change control.

### Rationale

Single-custody keeps the capture-return loop legible and prevents hoarding, while no ordinary direct theft preserves GDS-1's non-loss-dominant positioning.

### Alternatives Rejected

- unlimited provisional transport inventory;
- ordinary proximity-based stealing from carriers;
- mandatory combat defense of every captured creature.

### Affected Specifications

GDS-5, GDS-8, GDS-9, GDS-10, GDS-11, GDS-14.

---

## DD-031 — Acquisition Interruption Has Explicit State-Specific Semantics

**Date:** 2026-09-17  
**Status:** Accepted

### Context

GDS-2 requires transient systems to define disconnect/reset/shutdown behavior. Capture is especially sensitive because players can be between success and persistent ownership.

### Decision

Reset/avatar failure/Recovery never counts as extraction and ends ordinary Transport Custody through the interruption path. Voluntary server leave forfeits unfinalized transport.

Unexpected client disconnect during valid transport may receive a bounded same-server **Transport Grace**; it does not create cross-server ownership. If grace expires, the provisional state ends without securisation.

A narrowly scoped authoritative **Protected Shutdown Finalization** may secure an already valid Provisional Capture when the server itself is being terminated. This exception cannot be invoked by ordinary leave/reset/disconnect and remains exact-once.

### Rationale

The model prevents reset/rejoin exploits while giving uncontrollable server termination a player-trust protection path.

### Alternatives Rejected

- treating reset as automatic extraction;
- persisting every provisional capture across arbitrary server hops;
- always deleting valid post-capture custody on server shutdown;
- auto-securing on every disconnect.

### Affected Specifications

GDS-2, GDS-3, GDS-5, GDS-9, Technical Architecture.

---

## DD-032 — Capacity Safety and Onboarding Protection Constrain Capture Eligibility

**Date:** 2026-09-17  
**Status:** Accepted

### Context

GDS-4 guarantees that capacity pressure cannot delete already-secured creatures, but allowing players knowingly at full capacity to capture indefinitely would turn Overflow-Held into free unlimited storage. GDS-3 also requires a first capture path that other players cannot permanently deny.

### Decision

Known full ordinary capacity or unresolved Overflow-Held state blocks new ordinary capture initiation. If capacity becomes unavailable only after a valid attempt began, Extraction Completion still finalizes safely and GDS-4 may use Overflow-Held.

The first required capture uses an **Onboarding-Protected Opportunity**: personal, reserved, replenishing, or functionally equivalent protection so unrelated players cannot permanently consume the learner's only path. Protection does not fabricate success; the player still completes a real Capture Attempt and extraction.

### Rationale

This preserves both capacity integrity and first-session reliability without weakening the core loop.

### Alternatives Rejected

- unlimited capture into overflow;
- deleting the acquired creature when capacity races occur;
- requiring new players to win an open-server race for their only tutorial creature;
- auto-granting the first creature for skipping guidance.

### Affected Specifications

GDS-3, GDS-4, GDS-5, GDS-7, GDS-8, GDS-9, GDS-13, GDS-14.

---

## DD-033 — Close GDS-5 Capture, Contesting, Transport, and Extraction Baseline

**Date:** 2026-09-17  
**Status:** Accepted

### Context

GDS-5 now resolves ordinary capture eligibility, claim fairness, capture attempts, provisional custody, transport, extraction, lifecycle interruption, capacity interaction, onboarding protection, and the exact persistent ownership boundary and has passed scenario/cross-system validation.

### Decision

GDS-5 is formally closed as `Complete — PASS`.

Material changes to Engagement Claim exclusivity, contesting-before-Provisional-Capture, Capture Success being provisional, single active Transport Custody, ordinary custody no-theft, Recovery/leave/disconnect/shutdown semantics, Extraction Completion as the ownership-finalization boundary, capacity/Overflow capture gating, onboarding protection, or exact-once single-winner finalization require GDS-5 change control and revalidation.

### Evidence

- `capture/05_capture_contesting_transport_and_extraction.md` — Design Complete;
- `GDS5_SCENARIO_VALIDATION.md` — 60 / 60 PASS;
- `GDS5_CROSS_VALIDATION.md` — PASS;
- `GDS5_CLOSURE_REPORT.md` — PASS.

### Consequence

The active dependency advances to **GDS-6 — Rarity, Mutations, Traits, and Variant Value**. Technical Architecture and gameplay implementation remain blocked.

---

## DD-034 — Rarity, Variant, Trait, Availability, Power, and Price Are Separate Axes

**Date:** 2026-09-17  
**Status:** Accepted

### Context

MonsterVault needs rarity hunting and social status without turning every collectible property into one misleading power/value score.

### Decision

Species Rarity uses five ordered baseline tiers: **Common, Uncommon, Rare, Epic, Legendary**. Species Rarity is separate from Mutation, Trait, Availability Tag, downstream gameplay power, currency value, and future trading price.

Mutation Frequency uses its own context-aware `Frequent -> Uncommon -> Rare -> Extreme` bands. Availability uses `Core`, `Rotating`, `Event-Limited`, and `Legacy` rather than adding pseudo-rarity tiers.

### Rationale

Separating the axes keeps collection desire legible, avoids automatic pay-to-win implications, and lets later economy/trading systems discover value without redefining collectible identity.

### Alternatives Rejected

- one universal rarity/power/value score;
- treating Event-Limited as a higher rarity tier;
- guaranteeing market price from rarity labels.

### Affected Specifications

GDS-6 through GDS-16, Technical Architecture.

---

## DD-035 — Variant Identity Finalizes Before Actionable Capture and Cannot Be Retry-Rerolled

**Date:** 2026-09-17  
**Status:** Accepted

### Context

If mutation/trait identity were rolled after a player commits, players could reroll outcomes through claim cycling, capture failure, disconnect, transport, or message retries, undermining scarcity integrity.

### Decision

A Creature Instance's Mutation/Trait identity becomes fixed no later than that instance becoming an individually actionable **Capture Opportunity**.

The same surviving instance cannot reroll through claim release/reclaim, Capture Failure/retry, Capture Success, Provisional Capture, Transport Custody, reconnect, Extraction Completion, or duplicate finalization delivery. A genuinely new Creature Instance may independently generate a new identity.

Baseline instances carry zero, one, or at most two compatible Mutations; two form a Compound Variant.

### Rationale

This turns variants into stable properties of creatures rather than exploitable reward rolls and preserves GDS-4/GDS-5 instance continuity.

### Alternatives Rejected

- rolling mutation only after successful capture;
- rerolling on every Capture Attempt;
- rerolling at Secure Point;
- unlimited mutation stacking.

### Affected Specifications

GDS-4, GDS-5, GDS-6, GDS-9, GDS-11, Technical Architecture.

---

## DD-036 — Variant Discovery Is Historical and High-Value Variants Auto-Protect

**Date:** 2026-09-17  
**Status:** Accepted

### Context

Variant hunting needs durable completion credit and stronger protection against accidental loss without exploding completion into every possible Trait permutation.

### Decision

A **Variant Signature** is `Species + canonical Mutation set`; mutation order does not create separate signatures and Traits are excluded from baseline visual-variant completion.

Legitimate Secured Ownership Finalization records Mutation Discovery and Variant Discovery historically. Later release/trade does not erase that credit.

A newly secured instance automatically receives GDS-4 Creature Lock when it is a **Protected Variant**: Legendary Species, Extreme Mutation, Compound Variant, or explicitly protected event/legacy content.

### Rationale

The model supports long-term collection goals and protects high-value creatures while keeping completion finite and understandable.

### Alternatives Rejected

- requiring every Trait permutation for completion;
- granting discovery from previews/inspection only;
- leaving extreme/compound variants unlocked by default.

### Affected Specifications

GDS-4, GDS-6, GDS-11, GDS-12, GDS-14, GDS-16.

---

## DD-037 — Probability Modifiers Are Prospective and Hidden Spending-Based Odds Are Prohibited

**Date:** 2026-09-17  
**Status:** Accepted

### Context

Live events, progression, experimentation, or future monetization may want probability modifiers. Without strict boundaries, these could reroll committed encounters or personalize scarcity manipulatively.

### Decision

Probability modifiers affect only future, not-yet-finalized Creature Instances. They never reroll an already actionable/committed instance.

MonsterVault may not secretly personalize rarity/mutation odds from a player's spending history, purchase reluctance, inferred willingness to pay, or loss-chasing behavior.

Any future paid randomized/probability mechanic requires explicit GDS-13 and GDS-15 review plus clear odds/fairness integration; GDS-6 authorizes no such product by itself.

### Rationale

Scarcity must remain auditable and trustworthy rather than becoming invisible individualized monetization pressure.

### Alternatives Rejected

- post-engagement paid rerolls of the same finite creature;
- hidden “whale odds”;
- covert loss-chasing odds;
- paid provenance fabrication.

### Affected Specifications

GDS-6, GDS-9, GDS-11, GDS-13, GDS-15, GDS-16, Technical Architecture.

---

## DD-038 — Owned Variant Identity Is Stable Across Live Balancing

**Date:** 2026-09-17  
**Status:** Accepted

### Context

A live collection game must rebalance generation rates and downstream effects without making existing collections feel mutable or deceptive.

### Decision

Owned instances retain Species, Mutations, Traits, Variant Signature, and provenance through ordinary content/balance updates. Future generation rates and downstream mechanical effects may change prospectively under their owning phases.

Species Rarity reclassification is exceptional and requires explicit consistent content change control. Moving content to Legacy changes availability, not historical variant identity.

### Rationale

This preserves collectible trust while retaining normal live-service balancing flexibility.

### Alternatives Rejected

- rerolling owned variants after balance updates;
- per-player rarity reclassification;
- silently deleting now-invalid historical compound variants;
- using Legacy status to rewrite historical rarity.

### Affected Specifications

GDS-6, GDS-7, GDS-8, GDS-11, GDS-12, GDS-14, Technical Architecture.

---

## DD-039 — Close GDS-6 Rarity, Mutations, Traits, and Variant Value Baseline

**Date:** 2026-09-17  
**Status:** Accepted

### Context

GDS-6 now resolves rarity taxonomy, stable variant generation, Mutation/Compound semantics, Trait boundaries, discovery, high-value protection, probability fairness, availability, balancing, and downstream value-integrity obligations and has passed scenario/cross-system validation.

### Decision

GDS-6 is formally closed as `Complete — PASS`.

Material changes to the five-tier Species Rarity ladder, variant identity timing/stability, maximum-two Mutation baseline, Mutation Frequency semantics, Variant Signature/discovery rules, Protected Variant auto-lock, prospective-only modifiers, no hidden individualized spending-based odds, Availability separation, or owned-identity stability require GDS-6 change control and revalidation.

### Evidence

- `rarity_mutations/06_rarity_mutations_traits_and_variant_value.md` — Design Complete;
- `GDS6_SCENARIO_VALIDATION.md` — 70 / 70 PASS;
- `GDS6_CROSS_VALIDATION.md` — PASS;
- `GDS6_CLOSURE_REPORT.md` — PASS.

### Consequence

The active dependency advances to **GDS-7 — Vault/Base, Passive Production, Capacity, and Upgrades**. Technical Architecture and gameplay implementation remain blocked.
