# Game Design Specification Roadmap

> **Status:** Active  
> **Authority:** Dependency-driven game-design sequencing

This roadmap defines the order in which MonsterVault's authoritative Game Design Specification is developed. Later phases may depend on earlier rules, so phases are completed in dependency order rather than by convenience.

## GDS-0 — Governance, Structure, and Concept Baseline

**Status:** Complete — PASS

Established governance, authority, status model, glossary/decision discipline, dependency ordering, history de-authoritization, and GDS -> TA -> implementation gates.

Closure evidence: `STRUCTURE_AUDIT.md`, `GDS0_CLOSURE_REPORT.md`.

## GDS-1 — Product Vision, Audience, and Success Criteria

**Status:** Complete — PASS

Established the social creature-collection/progression adventure product identity, product promise, audience/platform strategy, non-loss-dominant competition position, session/time-to-fun contract, long-term progression direction, monetization/trading/live-content boundaries, and success criteria.

Closure evidence: `01_game_overview.md`, `product/`, `GDS1_CROSS_VALIDATION.md`, `GDS1_CLOSURE_REPORT.md`.

## GDS-2 — Global Game Rules and Session Model

**Status:** Complete — PASS

Established Server Sessions as disposable runtime contexts, persistent-state readiness, Protected Load Failure, Finalized Outcome semantics, Recovery, interruption ownership, offline/cross-server/time boundaries, and exact-once lifecycle invariants.

Closure evidence: `global_rules/02_global_game_rules_and_session_model.md`, `GDS2_SCENARIO_VALIDATION.md`, `GDS2_CROSS_VALIDATION.md`, `GDS2_CLOSURE_REPORT.md`.

## GDS-3 — Player Character, Interaction, and Onboarding

**Status:** Complete — PASS

Established third-person familiar locomotion, cross-device capability parity, Primary Interact / Primary Action semantics, deterministic Active Context, gameplay-first onboarding, persistent Onboarding Milestones, Safe Arrival/Recovery behavior, modal input safety, and semantic accessibility constraints.

Closure evidence: `player/03_player_character_interaction_and_onboarding.md`, `GDS3_SCENARIO_VALIDATION.md`, `GDS3_CROSS_VALIDATION.md`, `GDS3_CLOSURE_REPORT.md`.

## GDS-4 — Creatures, Collection, and Ownership

**Status:** Complete — PASS

Established Species versus Creature Instance identity, one-owner secured persistence, Collection Registry, duplicate preservation, Active/Stored/Overflow-Held/Released states, capacity safety, Creature Lock/Release, Species Discovery, provenance, and explicit transfer authority.

Closure evidence: `creatures/04_creatures_collection_and_ownership.md`, `GDS4_SCENARIO_VALIDATION.md`, `GDS4_CROSS_VALIDATION.md`, `GDS4_CLOSURE_REPORT.md`.

## GDS-5 — Capture, Contesting, Transport, and Extraction

**Status:** Complete — PASS

Established and formally validated:

- player-specific Capture Eligibility and explicit valid initiation;
- one bounded exclusive ordinary **Engagement Claim** per single-award creature;
- ordinary contesting as the race to validly engage before an active claim;
- cross-device Capture Challenge constraints;
- explicit Success / Failure / Cancel / Invalidation semantics;
- **Capture Success -> Provisional Capture**, not immediate ownership;
- stable same-instance identity through provisional transport and finalization;
- one baseline active **Transport Custody** per player;
- no ordinary direct theft of valid Transport Custody;
- reset/Recovery and voluntary leave do not count as extraction;
- bounded same-server **Transport Grace** for unexpected disconnect;
- narrowly scoped exact-once **Protected Shutdown Finalization** for authoritative server-originated termination;
- explicit **Secure Point** semantics;
- validated **Extraction Completion** as the ordinary `Secured Ownership Finalization` boundary;
- exact-once single-winner finalization for normal finite creatures;
- known-full-capacity / unresolved-overflow initiation blocks;
- race-safe finalization into GDS-4 Overflow-Held when capacity changes after valid initiation;
- **Onboarding-Protected Opportunity** so unrelated players cannot deny the first required capture;
- anti-grief, anti-monopoly, anti-reset, anti-hop, and anti-duplication constraints;
- 60 compound acquisition scenarios validated.

Closure evidence:

- [`capture/05_capture_contesting_transport_and_extraction.md`](capture/05_capture_contesting_transport_and_extraction.md) — Design Complete;
- [`GDS5_SCENARIO_VALIDATION.md`](GDS5_SCENARIO_VALIDATION.md) — 60 / 60 PASS;
- [`GDS5_CROSS_VALIDATION.md`](GDS5_CROSS_VALIDATION.md) — PASS;
- [`GDS5_CLOSURE_REPORT.md`](GDS5_CLOSURE_REPORT.md) — PASS.

GDS-5 establishes the active acquisition and exact ownership-boundary contract consumed by rarity, vault, economy, world, social, event, presentation, and architecture phases. It does not authorize Technical Architecture or implementation.

## GDS-6 — Rarity, Mutations, Traits, and Variant Value

**Status:** NEXT — Draft

Defines rarity tiers, mutation generation, compound mutations, visual readability, gameplay/economic impact, uniqueness, duplicate handling, discovery presentation, probability transparency, capture-difficulty interaction, and balancing boundaries.

GDS-6 must attach rarity/variant value to stable GDS-4 Creature Instances and preserve those properties through the GDS-5 provisional capture/transport/finalization lifecycle.

## GDS-7 — Vault/Base, Passive Production, Capacity, and Upgrades

**Status:** Draft

Defines the personal vault/laboratory, creature placement, passive production, storage/capacity, base upgrades, offline production, presentation/status display, visitor interaction, Secure Point integration, and progression dependencies.

## GDS-8 — Economy, Progression, Unlocks, and Pacing

**Status:** Draft

Defines currencies, sources/sinks, capture tools/costs, upgrade economy, biome unlocks, equipment progression, pacing bands, catch-up behavior, capacity progression, prestige/reset position if any, inflation controls, and long-term goals.

## GDS-9 — World, Biomes, Exploration, Spawning, and Hazards

**Status:** Draft

Defines world structure, biome progression, traversal, creature spawn logic, encounter lifetime, hazards, special zones, rare encounters, Secure Point placement, exploration rewards, density/readability, and content scalability.

## GDS-10 — Social Play, Cooperation, Competition, and PvP Boundaries

**Status:** Draft

Defines parties/friends, intentional co-play, shared objectives, status/flexing, collision/body-blocking boundaries, competition, optional interception/risk modes, grief prevention, collaboration rewards, and multiplayer fairness.

## GDS-11 — Server Events, Dynamic Encounters, and Live Content

**Status:** Draft

Defines server-wide events, rifts/rare spawns, announcements, participation rules, event-specific shared/multi-award capture overrides, reward allocation, cadence, server hopping, rotating/seasonal content, and live-ops extensibility.

## GDS-12 — Trading and Player Economy

**Status:** Draft

Defines trade eligibility, offer/accept flow, secured-instance transfer semantics, scarcity/value philosophy, restrictions, cooldowns, rollback expectations from the player perspective, alternate-account abuse boundaries, and safe trading UX.

## GDS-13 — Monetization and Commercial Fairness

**Status:** Draft

Defines monetization philosophy, passes/products/subscriptions if used, cosmetics, capacity/convenience, boosts, starter offers, purchase presentation, non-pay-to-win boundaries, spending-pressure limits, and interactions with progression/trading.

## GDS-14 — Presentation, UI/UX, Feedback, and Accessibility

**Status:** Draft

Defines information hierarchy, HUD, menus, collection/rarity/capture/event feedback, mobile/controller/keyboard expectations, audio/visual language, reduced-motion/readability, onboarding presentation, and accessibility requirements.

## GDS-15 — Roblox Platform, Social Safety, and Moderation Constraints

**Status:** Draft

Defines player-facing consequences of Roblox platform constraints, age-appropriate social mechanics, naming/text exposure, reporting/blocking expectations, UGC/content boundaries, and multiplayer safety constraints.

## GDS-16 — Retention, Discovery, Analytics, and Experimentation Boundaries

**Status:** Draft

Defines first-session funnel, return loops, daily/weekly engagement philosophy, social invitation loops, discovery promises, analytics hypotheses, experimentable parameters, and guardrails preventing metric optimization from overriding fairness/player experience.

## GDS-17 — Cross-System Consistency and Design-Complete Audit

**Status:** Blocked by GDS-6 through GDS-16

Performs the formal pre-architecture ownership, terminology, compound-scenario, economy, persistence, abuse/griefing, trading, accessibility, platform/safety, maturity, and unresolved-question audits before final `Design Complete` promotion.

## Current Project Gate

GDS-0 through GDS-5 are formally complete. The active dependency is **GDS-6 — Rarity, Mutations, Traits, and Variant Value**.

Technical Architecture must not begin until GDS-17 records a formal PASS with no implementation-critical open design questions.

```text
GDS-0 governance — COMPLETE
  -> GDS-1 product vision — COMPLETE
  -> GDS-2 global rules/session model — COMPLETE
  -> GDS-3 player/interaction/onboarding — COMPLETE
  -> GDS-4 creatures/collection/ownership — COMPLETE
  -> GDS-5 capture/contesting/transport/extraction — COMPLETE
  -> GDS-6..16 subsystem design — GDS-6 NEXT
  -> GDS-17 cross-system audit
  -> DESIGN COMPLETE
  -> Technical Architecture
  -> Architecture audit + implementation locking
  -> Implementation
```
