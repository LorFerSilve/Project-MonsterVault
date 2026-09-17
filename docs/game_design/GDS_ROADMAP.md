# Game Design Specification Roadmap

> **Status:** Active  
> **Authority:** Dependency-driven game-design sequencing

This roadmap defines the order in which MonsterVault's authoritative Game Design Specification is developed. Later phases may depend on earlier rules, so phases are completed in dependency order rather than by convenience.

## GDS-0 — Governance, Structure, and Concept Baseline

**Status:** Complete — PASS

Established and formally validated:

- project-wide design authority and precedence;
- `Draft -> Under Review -> Design Complete -> Implementation Locked` maturity model;
- objective Design Complete criteria;
- one-authoritative-home-per-rule discipline;
- canonical glossary and subsystem template;
- strategic design-decision logging;
- dependency-driven GDS hierarchy;
- historical baseline preservation and de-authoritization;
- explicit GDS -> TA -> implementation gates;
- top-level domain ownership for all currently known design concerns;
- final GDS-17 cross-system audit authority.

Closure evidence:

- [`STRUCTURE_AUDIT.md`](STRUCTURE_AUDIT.md) — PASS;
- [`GDS0_CLOSURE_REPORT.md`](GDS0_CLOSURE_REPORT.md) — PASS.

## GDS-1 — Product Vision, Audience, and Success Criteria

**Status:** Complete — PASS

Established and formally validated:

- social creature-collection/progression adventure identity;
- product promise: `Find it. Catch it. Bring it home. Make your vault legendary.`;
- primary audience approximately ages 9–15, with older collection/optimization players as a secondary audience;
- mobile-first interaction constraint with cross-platform gameplay parity;
- communication-independent core progression;
- colorful/energetic/playful tone;
- active acquisition and visible-vault differentiation;
- socially competitive but non-loss-dominant product position;
- no baseline requirement for unrestricted theft of secured collections or direct-combat PvP;
- 10–25 minute normal-session target with meaningful short and extended sessions;
- fast time-to-fun targets for first action, capture and progression;
- weeks-to-months long-term collection/progression horizon;
- trading desirable but non-launch-critical;
- moderate, non-coercive monetization direction;
- live-content-capable product model;
- absolute first-session validation targets plus benchmark-relative public product gates;
- explicit pivot and production-scale criteria;
- high-level non-goals and small-team scope constraints.

Closure evidence:

- [`01_game_overview.md`](01_game_overview.md) — Design Complete;
- [`product/`](product/) — authoritative GDS-1 product specifications;
- [`GDS1_CROSS_VALIDATION.md`](GDS1_CROSS_VALIDATION.md) — PASS;
- [`GDS1_CLOSURE_REPORT.md`](GDS1_CLOSURE_REPORT.md) — PASS.

GDS-1 completion constrains later design but does not authorize Technical Architecture or implementation.

## GDS-2 — Global Game Rules and Session Model

**Status:** Complete — PASS

Established and formally validated:

- Server Sessions as disposable runtime contexts rather than owners of long-term player progression;
- join/readiness, late-join, leave, disconnect, reconnect, server-transition and shutdown semantics;
- protected readiness before irreversible gameplay;
- **Protected Load Failure** instead of blank/untrusted fallback progression;
- Session-Scoped State versus Persistent Player State;
- persistence permanence across ordinary avatar/session/device lifecycle;
- Finalized Outcome single-application semantics across retries/reconnects;
- coherent finite-opportunity finalization requirements;
- Recovery instead of a default persistent wipe on avatar failure/reset;
- ordinary disconnect neutrality for secured persistent value;
- mandatory explicit interruption behavior for downstream transient activities;
- no baseline periodic/death/server progression wipe;
- no default AFK/presence reward entitlement;
- no baseline offline live-world claims;
- offline progression as optional downstream design rather than an assumed global mechanic;
- no baseline continuously synchronized MMO-scale cross-server world;
- persistent-timer elapsed-time declaration and cross-server continuity;
- Global Window continuity across servers;
- cross-platform lifecycle parity;
- abuse constraints for reset/rejoin/server hopping;
- 30 compound lifecycle scenarios validated.

Closure evidence:

- [`global_rules/02_global_game_rules_and_session_model.md`](global_rules/02_global_game_rules_and_session_model.md) — Design Complete;
- [`GDS2_SCENARIO_VALIDATION.md`](GDS2_SCENARIO_VALIDATION.md) — PASS;
- [`GDS2_CROSS_VALIDATION.md`](GDS2_CROSS_VALIDATION.md) — PASS;
- [`GDS2_CLOSURE_REPORT.md`](GDS2_CLOSURE_REPORT.md) — PASS.

GDS-2 creates explicit downstream contracts but does not authorize Technical Architecture or implementation.

## GDS-3 — Player Character, Interaction, and Onboarding

**Status:** NEXT — Draft

Defines movement, camera expectations, interaction model, first-session onboarding, tools/equipment-facing rules, basic inventory-facing behavior, accessibility implications, and interruption/recovery rules.

GDS-3 must consume the GDS-2 readiness/recovery contract and define how players concretely enter safe meaningful play after persistence readiness, spawn, reset, and Recovery.

## GDS-4 — Creatures, Collection, and Ownership

**Status:** Draft

Defines creature identity, species/content taxonomy, encounter ownership, collection semantics, active vs stored creatures, duplicates, capacity, display/status value, loss rules, and collection completion behavior.

## GDS-5 — Capture, Contesting, Transport, and Extraction

**Status:** Draft

Defines the primary active gameplay loop: discovering a creature, attempting capture, capture difficulty, failure, contesting, transport/return, interception boundaries, disconnect behavior, ownership transfer point, anti-frustration rules, and multiplayer race conditions from the player's perspective.

## GDS-6 — Rarity, Mutations, Traits, and Variant Value

**Status:** Draft

Defines rarity tiers, mutation generation, compound mutations, visual readability, gameplay/economic impact, uniqueness, duplicate handling, discovery presentation, probability transparency, and balancing boundaries.

## GDS-7 — Vault/Base, Passive Production, Capacity, and Upgrades

**Status:** Draft

Defines the personal vault/laboratory, creature placement, passive production, storage/capacity, base upgrades, offline production, presentation/status display, visitor interaction, and progression dependencies.

## GDS-8 — Economy, Progression, Unlocks, and Pacing

**Status:** Draft

Defines currencies, resource sources/sinks, upgrade economy, biome unlocks, equipment progression, pacing bands, catch-up behavior, prestige/reset position if any, economy inflation controls at the design level, and long-term goals.

## GDS-9 — World, Biomes, Exploration, Spawning, and Hazards

**Status:** Draft

Defines world structure, biome progression, traversal, creature spawn logic from the player perspective, hazards, special zones, rare encounters, exploration rewards, density/readability, and content scalability.

## GDS-10 — Social Play, Cooperation, Competition, and PvP Boundaries

**Status:** Draft

Defines parties/friends, intentional co-play, shared objectives, social status/flexing, player competition, interception or stealing rules, protection windows, grief prevention, collaboration rewards, and multiplayer fairness.

## GDS-11 — Server Events, Dynamic Encounters, and Live Content

**Status:** Draft

Defines server-wide events, rifts/rare spawns, announcements, participation rules, reward allocation, event cadence, server hopping implications, rotating/seasonal content, and live-ops extensibility.

## GDS-12 — Trading and Player Economy

**Status:** Draft

Defines trade eligibility, offer/accept flow, item/creature transfer semantics, value/scarcity philosophy, trade restrictions, cooldowns, rollback expectations from the player perspective, alternate-account abuse boundaries, and safe trading UX.

## GDS-13 — Monetization and Commercial Fairness

**Status:** Draft

Defines monetization philosophy, game passes/developer products/subscriptions if used, cosmetics, capacity/convenience, server-wide boosts, starter offers, purchase presentation, non-pay-to-win boundaries, spending pressure limits, and interactions with progression/trading.

## GDS-14 — Presentation, UI/UX, Feedback, and Accessibility

**Status:** Draft

Defines information hierarchy, HUD, menus, collection presentation, rarity feedback, event feedback, capture feedback, mobile/controller/keyboard expectations, audio/visual language, reduced-motion/readability needs, onboarding presentation, and accessibility requirements.

## GDS-15 — Roblox Platform, Social Safety, and Moderation Constraints

**Status:** Draft

Defines player-facing consequences of Roblox platform constraints, age-appropriate social mechanics, naming/text exposure, reporting/blocking expectations where relevant, UGC/content boundaries, and design constraints required for safe multiplayer interactions.

## GDS-16 — Retention, Discovery, Analytics, and Experimentation Boundaries

**Status:** Draft

Defines intended first-session funnel, session goals, return loops, daily/weekly engagement philosophy, social invitation loops, discovery promises, analytics hypotheses, experimentable parameters and guardrails that prevent metric optimization from overriding player experience or fairness.

## GDS-17 — Cross-System Consistency and Design-Complete Audit

**Status:** Blocked by GDS-3 through GDS-16

Performs the formal pre-architecture audit:

- ownership/authority audit;
- terminology/namespace audit;
- compound gameplay scenario audit;
- economy/progression/monetization audit;
- persistence/disconnect/recovery scenario audit;
- multiplayer abuse/griefing audit;
- trading/value-integrity audit;
- presentation/accessibility audit;
- Roblox platform/safety audit;
- specification maturity scan;
- unresolved-question sweep;
- final `Design Complete` promotion report.

## Current Project Gate

GDS-0, GDS-1, and GDS-2 are formally complete. The active dependency is **GDS-3 — Player Character, Interaction, and Onboarding**.

Technical Architecture must not begin until GDS-17 records a formal PASS with no implementation-critical open design questions.

The intended sequence is:

```text
GDS-0 governance — COMPLETE
  -> GDS-1 product vision — COMPLETE
  -> GDS-2 global rules/session model — COMPLETE
  -> GDS-3..16 subsystem design — GDS-3 NEXT
  -> GDS-17 cross-system audit
  -> DESIGN COMPLETE
  -> Technical Architecture
  -> Architecture audit + implementation locking
  -> Implementation
```
