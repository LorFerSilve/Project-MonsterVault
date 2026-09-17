# Game Design Specification Roadmap

> **Status:** Active  
> **Authority:** Dependency-driven game-design sequencing

This roadmap defines the order in which MonsterVault's authoritative Game Design Specification is developed. Later phases may depend on earlier rules, so phases are completed in dependency order rather than by convenience.

## GDS-0 — Governance, Structure, and Concept Baseline

**Status:** Complete — PASS

Established:

- design authority/precedence and one-authoritative-home-per-rule;
- `Draft -> Under Review -> Design Complete -> Implementation Locked` maturity model;
- objective Design Complete criteria and explicit open-question discipline;
- GDS -> Technical Architecture -> implementation gates;
- canonical glossary/template/decision logging;
- historical material de-authoritization;
- dependency-driven subsystem ownership and final GDS-17 audit.

Closure evidence:

- [`STRUCTURE_AUDIT.md`](STRUCTURE_AUDIT.md) — PASS;
- [`GDS0_CLOSURE_REPORT.md`](GDS0_CLOSURE_REPORT.md) — PASS.

## GDS-1 — Product Vision, Audience, and Success Criteria

**Status:** Complete — PASS

Established:

- social creature-collection/progression adventure identity;
- product promise: `Find it. Catch it. Bring it home. Make your vault legendary.`;
- primary audience approximately ages 9–15 with older collection/optimization players secondary;
- mobile-first cross-platform capability parity;
- active acquisition and visible persistent Vault differentiation;
- socially competitive but non-loss-dominant positioning;
- flexible 3–60 minute session support with a 10–25 minute normal target;
- fast first-action/capture/progression expectations;
- weeks-to-months long-term collection goals;
- moderate non-coercive monetization, deferred safe trading, live-content capability;
- retention-first product KPI hierarchy.

Closure evidence:

- [`01_game_overview.md`](01_game_overview.md) — Design Complete;
- [`product/`](product/) — authoritative GDS-1 specifications;
- [`GDS1_CROSS_VALIDATION.md`](GDS1_CROSS_VALIDATION.md) — PASS;
- [`GDS1_CLOSURE_REPORT.md`](GDS1_CLOSURE_REPORT.md) — PASS.

## GDS-2 — Global Game Rules and Session Model

**Status:** Complete — PASS

Established:

- disposable Server Sessions versus persistent player progression;
- persistence readiness and **Protected Load Failure**;
- Persistent Player State / Session-Scoped State boundaries;
- exact-once Finalized Outcomes;
- Recovery rather than global progression wipe;
- disconnect/reset/server-transition semantics;
- no baseline AFK/presence reward or offline live-world claims;
- explicit downstream authority for any offline progression;
- persistent timer/global-window continuity and abuse constraints.

Closure evidence:

- [`global_rules/02_global_game_rules_and_session_model.md`](global_rules/02_global_game_rules_and_session_model.md) — Design Complete;
- [`GDS2_SCENARIO_VALIDATION.md`](GDS2_SCENARIO_VALIDATION.md) — PASS;
- [`GDS2_CROSS_VALIDATION.md`](GDS2_CROSS_VALIDATION.md) — PASS;
- [`GDS2_CLOSURE_REPORT.md`](GDS2_CLOSURE_REPORT.md) — PASS.

## GDS-3 — Player Character, Interaction, and Onboarding

**Status:** Complete — PASS

Established:

- familiar third-person locomotion/jump with no universal stamina tax;
- touch/keyboard/gamepad capability parity;
- universal **Primary Interact** and downstream **Primary Action** semantics;
- deterministic single **Active Context** and modal input safety;
- gameplay-first persistent onboarding milestones;
- Safe Arrival / Recovery behavior;
- non-color/non-audio/non-pixel-precision interaction obligations.

Closure evidence:

- [`player/03_player_character_interaction_and_onboarding.md`](player/03_player_character_interaction_and_onboarding.md) — Design Complete;
- [`GDS3_SCENARIO_VALIDATION.md`](GDS3_SCENARIO_VALIDATION.md) — PASS;
- [`GDS3_CROSS_VALIDATION.md`](GDS3_CROSS_VALIDATION.md) — PASS;
- [`GDS3_CLOSURE_REPORT.md`](GDS3_CLOSURE_REPORT.md) — PASS.

## GDS-4 — Creatures, Collection, and Ownership

**Status:** Complete — PASS

Established:

- Species versus stable individual Creature Instance identity;
- one ordinary owner per Secured Creature;
- Collection Registry and duplicate preservation;
- Active / Stored / Overflow-Held / Released states;
- non-destructive capacity safety;
- explicit voluntary Release and persistent Creature Lock;
- historical Species Discovery and provenance;
- explicit authority requirement for future ownership transfer.

Closure evidence:

- [`creatures/04_creatures_collection_and_ownership.md`](creatures/04_creatures_collection_and_ownership.md) — Design Complete;
- [`GDS4_SCENARIO_VALIDATION.md`](GDS4_SCENARIO_VALIDATION.md) — PASS;
- [`GDS4_CROSS_VALIDATION.md`](GDS4_CROSS_VALIDATION.md) — PASS;
- [`GDS4_CLOSURE_REPORT.md`](GDS4_CLOSURE_REPORT.md) — PASS.

## GDS-5 — Capture, Contesting, Transport, and Extraction

**Status:** Complete — PASS

Established:

- Capture Eligibility and bounded ordinary Engagement Claims;
- cross-device Capture Challenge requirements;
- Capture Success -> Provisional Capture rather than immediate ownership;
- stable same-instance Transport Custody and no ordinary custody theft;
- deterministic reset/leave/disconnect/shutdown behavior;
- Secure Point / Extraction Completion as ordinary ownership-finalization boundary;
- exact-once single-winner finalization;
- known-full/unresolved-overflow capture gating and late-race safety;
- onboarding-protected first capture.

Closure evidence:

- [`capture/05_capture_contesting_transport_and_extraction.md`](capture/05_capture_contesting_transport_and_extraction.md) — Design Complete;
- [`GDS5_SCENARIO_VALIDATION.md`](GDS5_SCENARIO_VALIDATION.md) — 60 / 60 PASS;
- [`GDS5_CROSS_VALIDATION.md`](GDS5_CROSS_VALIDATION.md) — PASS;
- [`GDS5_CLOSURE_REPORT.md`](GDS5_CLOSURE_REPORT.md) — PASS.

## GDS-6 — Rarity, Mutations, Traits, and Variant Value

**Status:** Complete — PASS

Established:

- five Species Rarity tiers: Common, Uncommon, Rare, Epic, Legendary;
- separation of rarity, Mutation, Trait, Availability, gameplay power, currency value, and market value;
- Variant Identity Finalization no later than actionable Capture Opportunity;
- no same-instance reroll through capture/transport/reconnect/finalization;
- zero-to-two baseline Mutations and Compound Variants;
- Mutation Frequency bands and compatibility/readability rules;
- bounded situational Trait philosophy;
- Variant Signature / Mutation Discovery / Variant Discovery;
- Protected Variant auto-lock;
- prospective-only modifiers and no hidden spending-based odds;
- stable owned variant identity through normal balance/content changes.

Closure evidence:

- [`rarity_mutations/06_rarity_mutations_traits_and_variant_value.md`](rarity_mutations/06_rarity_mutations_traits_and_variant_value.md) — Design Complete;
- [`GDS6_SCENARIO_VALIDATION.md`](GDS6_SCENARIO_VALIDATION.md) — 70 / 70 PASS;
- [`GDS6_CROSS_VALIDATION.md`](GDS6_CROSS_VALIDATION.md) — PASS;
- [`GDS6_CLOSURE_REPORT.md`](GDS6_CLOSURE_REPORT.md) — PASS.

## GDS-7 — Vault/Base, Passive Production, Capacity, and Upgrades

**Status:** Complete — PASS

Established:

- persistent personal Vault context;
- Collection Capacity separated from Display/Production Slots;
- Overflow-Held / Resolve Overflow / non-destructive Capacity Reconciliation;
- exact-instance display and Production Assignments;
- bounded Passive Production and persistent Production Buffer;
- bounded Offline Production Window with no offline world/event claims;
- exact-once Production Claim and Vault Upgrade semantics;
- safe temporary-capacity expiry;
- post-Secured-Ownership-Finalization Vault ordering;
- read-only baseline visitors;
- no automatic rarity/Mutation/Compound production multiplier;
- viable non-premium functional Vault progression path.

Closure evidence:

- [`vault/07_vault_base_passive_production_capacity_and_upgrades.md`](vault/07_vault_base_passive_production_capacity_and_upgrades.md) — Design Complete;
- [`GDS7_SCENARIO_VALIDATION.md`](GDS7_SCENARIO_VALIDATION.md) — 80 / 80 PASS;
- [`GDS7_CROSS_VALIDATION.md`](GDS7_CROSS_VALIDATION.md) — PASS;
- [`GDS7_DECISION_INDEX.md`](GDS7_DECISION_INDEX.md) — accepted phase-local decisions;
- [`GDS7_CLOSURE_REPORT.md`](GDS7_CLOSURE_REPORT.md) — PASS.

## GDS-8 — Economy, Progression, Unlocks, and Pacing

**Status:** Complete — PASS

Established and formally validated:

- **Energy** as the single baseline non-premium soft progression currency;
- persistent non-negative whole-unit wallet semantics;
- no baseline direct Energy transfer between players;
- Production Claim as recurring passive source plus bounded meaningful active reward sources;
- no Energy from baseline Creature Release or ordinary repeated capture;
- Vault Upgrades, durable Capture Capability, Access Unlocks, and approved utility/presentation as sinks;
- no universal ordinary per-attempt capture Energy tax, maintenance ransom, or debt;
- Species-authored Production Profiles and bounded situational Trait effects;
- rarity/Mutation/Compound/provenance not automatic production multipliers;
- active non-spendable **Progression Milestones** for major gates that must resist passive-only completion;
- Energy-plus-Milestone Progression Gates;
- exact-once/atomic Progression Purchases with insufficient-funds and price-race safety;
- opening/foundation/growth/long-term pacing bands;
- production-compounding/source-sink guardrails and tuneable active/passive income mix;
- deterministic catch-up without fabricated history or hidden spending personalization;
- no arbitrary Energy wipe;
- completed purchases survive ordinary rebalance;
- no baseline prestige/rebirth wipe of permanent collection/progression;
- 90 compound economy/progression/lifecycle scenarios validated.

Closure evidence:

- [`economy_progression/08_economy_progression_unlocks_and_pacing.md`](economy_progression/08_economy_progression_unlocks_and_pacing.md) — Design Complete;
- [`GDS8_SCENARIO_VALIDATION.md`](GDS8_SCENARIO_VALIDATION.md) — 90 / 90 PASS;
- [`GDS8_CROSS_VALIDATION.md`](GDS8_CROSS_VALIDATION.md) — PASS;
- [`GDS8_DECISION_INDEX.md`](GDS8_DECISION_INDEX.md) — accepted phase-local decisions;
- [`GDS8_CLOSURE_REPORT.md`](GDS8_CLOSURE_REPORT.md) — PASS.

GDS-8 establishes the economy/progression contract consumed by world, social, events, trading, monetization, presentation, safety, analytics, and Technical Architecture phases. It does not authorize Technical Architecture or implementation.

## GDS-9 — World, Biomes, Exploration, Spawning, and Hazards

**Status:** NEXT — Draft

Defines:

- world/biome structure and progression topology;
- traversal and exploration loops;
- concrete GDS-8 Access Unlock placement and active Progression Milestones;
- creature spawn pools, contexts, densities and encounter lifetimes;
- Species Rarity / Mutation-generation contexts without violating GDS-6 pre-commit identity;
- hazards and special zones;
- Secure Point, Vault Access Point and Recovery Anchor placement;
- world/exploration Energy rewards under GDS-8 source rules;
- rare encounter visibility/readability;
- server-local world lifecycle and content-scalability expectations.

GDS-9 must preserve GDS-5 capture/finalization, GDS-6 rarity/variant integrity, GDS-7 Vault/access boundaries, and GDS-8 economy/progression gate semantics.

## GDS-10 — Social Play, Cooperation, Competition, and PvP Boundaries

**Status:** Draft

Defines parties/friends, intentional co-play, shared objectives, social status/flexing, expanded Vault visitor permissions if any, player competition, collision/body-blocking rules, optional interception/PvP boundaries, protection windows, grief prevention, collaboration rewards, alt-account concerns, and multiplayer fairness.

## GDS-11 — Server Events, Dynamic Encounters, and Live Content

**Status:** Draft

Defines server-wide events, rifts/rare spawns, announcements, participation rules, reward allocation, event-specific shared/multi-award capture overrides, variant probability modifiers, production/economy modifiers if any, Availability/event windows, provenance/protection, cadence, server-hopping implications, rotating/seasonal content, and live-ops extensibility.

## GDS-12 — Trading and Player Economy

**Status:** Draft

Defines trade eligibility, offer/accept flow, secured-instance ownership transfer, Production Assignment reconciliation, preservation of Mutation/Trait/Variant/provenance identity, value/scarcity philosophy, trade restrictions/cooldowns/rollback expectations, alternate-account abuse, safe UX, and whether Energy ever becomes transferable. Baseline direct Energy transfer remains prohibited until this phase explicitly changes it.

## GDS-13 — Monetization and Commercial Fairness

**Status:** Draft

Defines monetization philosophy, game passes/developer products/subscriptions if used, cosmetics, capacity/convenience, bounded progression/production acceleration if any, Energy interaction if any, server-wide boosts, starter offers, purchase presentation, non-pay-to-win boundaries, spending-pressure limits, probability/variant constraints, and exact-once commercial outcomes.

## GDS-14 — Presentation, UI/UX, Feedback, and Accessibility

**Status:** Draft

Defines information hierarchy, HUD/menus, collection/Vault/economy presentation, Energy/cost/gate/transaction feedback, rarity/mutation/trait/availability feedback, event/capture feedback, mobile/controller/keyboard expectations, audio/visual language, reduced-motion/readability needs, onboarding presentation, and accessibility requirements.

## GDS-15 — Roblox Platform, Social Safety, and Moderation Constraints

**Status:** Draft

Defines player-facing consequences of Roblox platform constraints, age-appropriate social mechanics, naming/text exposure, reporting/blocking expectations, UGC/content boundaries, randomized/paid probability/economy requirements where applicable, and safety constraints for multiplayer/commercial interactions.

## GDS-16 — Retention, Discovery, Analytics, and Experimentation Boundaries

**Status:** Draft

Defines first-session funnel, session goals, return loops, daily/weekly engagement philosophy, social invitation loops, discovery/Vault/variant progression promises, economy/source-sink hypotheses, catch-up/reward cadence governance, experimentable parameters, and guardrails preventing metric optimization from overriding player experience, fairness, ownership, scarcity, or value integrity.

## GDS-17 — Cross-System Consistency and Design-Complete Audit

**Status:** Blocked by GDS-9 through GDS-16

Performs the formal pre-architecture audit:

- ownership/authority audit;
- terminology/namespace audit;
- compound gameplay scenario audit;
- economy/progression/monetization audit;
- persistence/disconnect/recovery audit;
- multiplayer abuse/griefing audit;
- rarity/variant/value-integrity audit;
- Vault/capacity/offline-production integrity audit;
- trading/value-integrity audit;
- presentation/accessibility audit;
- Roblox platform/safety audit;
- specification maturity scan;
- unresolved-question sweep;
- final `Design Complete` promotion report.

## Current Project Gate

GDS-0 through GDS-8 are formally complete. The active dependency is:

> **GDS-9 — World, Biomes, Exploration, Spawning, and Hazards**

Technical Architecture must not begin until GDS-17 records a formal PASS with no implementation-critical open design questions.

The intended sequence is:

```text
GDS-0 governance — COMPLETE
  -> GDS-1 product vision — COMPLETE
  -> GDS-2 global rules/session model — COMPLETE
  -> GDS-3 player/interaction/onboarding — COMPLETE
  -> GDS-4 creatures/collection/ownership — COMPLETE
  -> GDS-5 capture/contesting/transport/extraction — COMPLETE
  -> GDS-6 rarity/mutations/traits/value — COMPLETE
  -> GDS-7 vault/base/passive production/capacity/upgrades — COMPLETE
  -> GDS-8 economy/progression/unlocks/pacing — COMPLETE
  -> GDS-9 world/biomes/exploration/spawning/hazards — NEXT
  -> GDS-10..16 remaining subsystem design
  -> GDS-17 cross-system audit
  -> DESIGN COMPLETE
  -> Technical Architecture
  -> Architecture audit + implementation locking
  -> Implementation
```
