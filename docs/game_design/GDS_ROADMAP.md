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
- historical baseline preservation/de-authoritization;
- explicit GDS -> TA -> implementation gates;
- top-level domain ownership and final GDS-17 audit authority.

Closure evidence: `STRUCTURE_AUDIT.md`, `GDS0_CLOSURE_REPORT.md`.

## GDS-1 — Product Vision, Audience, and Success Criteria

**Status:** Complete — PASS

Established the social creature-collection/progression adventure identity, product promise, primary/secondary audience, mobile-first cross-platform parity, active-acquisition differentiation, non-loss-dominant competition, flexible session shape, fast time-to-fun, long-term collection horizon, moderate monetization direction, deferred safe trading, live-content capability, and retention-first success gates.

Closure evidence: `01_game_overview.md`, `product/`, `GDS1_CROSS_VALIDATION.md`, `GDS1_CLOSURE_REPORT.md`.

## GDS-2 — Global Game Rules and Session Model

**Status:** Complete — PASS

Established disposable Server Sessions, protected persistence readiness, `Protected Load Failure`, Persistent Player State versus Session-Scoped State, exact-once Finalized Outcomes, Recovery rather than global wipes, disconnect neutrality for secured value, explicit downstream interruption ownership, optional rather than assumed offline progression, cross-server timer/global-window continuity, and lifecycle abuse constraints.

Closure evidence: `global_rules/02_global_game_rules_and_session_model.md`, `GDS2_SCENARIO_VALIDATION.md`, `GDS2_CROSS_VALIDATION.md`, `GDS2_CLOSURE_REPORT.md`.

## GDS-3 — Player Character, Interaction, and Onboarding

**Status:** Complete — PASS

Established third-person familiar locomotion, cross-device capability parity, universal `Primary Interact` and downstream `Primary Action`, one visible deterministic `Active Context`, modal safety, gameplay-first persistent onboarding, `Safe Arrival`, `Recovery`, accessibility-level interaction invariants, and 40 compound scenario validations.

Closure evidence: `player/03_player_character_interaction_and_onboarding.md`, `GDS3_SCENARIO_VALIDATION.md`, `GDS3_CROSS_VALIDATION.md`, `GDS3_CLOSURE_REPORT.md`.

## GDS-4 — Creatures, Collection, and Ownership

**Status:** Complete — PASS

Established Species versus stable Creature Instance identity, one-owner secured persistence, Collection Registry, Active/Stored/Overflow-Held/Released states, duplicate preservation, non-destructive capacity safety, Creature Lock, voluntary Release, historical Species Discovery, provenance, and explicit future transfer authority.

Closure evidence: `creatures/04_creatures_collection_and_ownership.md`, `GDS4_SCENARIO_VALIDATION.md`, `GDS4_CROSS_VALIDATION.md`, `GDS4_CLOSURE_REPORT.md`.

## GDS-5 — Capture, Contesting, Transport, and Extraction

**Status:** Complete — PASS

Established player-specific Capture Eligibility, bounded exclusive Engagement Claims, Capture Attempt outcomes, `Capture Success -> Provisional Capture`, one baseline Transport Custody, no ordinary custody theft, bounded disconnect Transport Grace, protected server-shutdown finalization, Secure Points, exact Secured Ownership Finalization at validated Extraction Completion, capacity-race safety, onboarding-protected opportunity, and exact-once single-winner acquisition semantics.

Closure evidence: `capture/05_capture_contesting_transport_and_extraction.md`, `GDS5_SCENARIO_VALIDATION.md` (60/60 PASS), `GDS5_CROSS_VALIDATION.md`, `GDS5_CLOSURE_REPORT.md`.

## GDS-6 — Rarity, Mutations, Traits, and Variant Value

**Status:** Complete — PASS

Established:

- Species Rarity tiers `Common -> Uncommon -> Rare -> Epic -> Legendary`;
- separation of rarity, Mutation, Trait, Availability, gameplay power and market/economic price;
- Variant Identity Finalization no later than actionable Capture Opportunity;
- stable same-instance identity through capture/transport/reconnect/finalization retries;
- zero-to-two compatible Mutations with Standard, Single-Mutated and Compound-Mutated variants;
- context-aware Mutation Frequency Bands `Frequent -> Uncommon -> Rare -> Extreme`;
- Variant Signature, Mutation/Variant Discovery and Protected Variant auto-lock;
- prospective-only probability modifiers and prohibition on hidden spending-based odds;
- stable owned-instance identity across ordinary balancing/content changes.

Closure evidence: `rarity_mutations/06_rarity_mutations_traits_and_variant_value.md`, `GDS6_SCENARIO_VALIDATION.md` (70/70 PASS), `GDS6_CROSS_VALIDATION.md`, `GDS6_CLOSURE_REPORT.md`.

## GDS-7 — Vault/Base, Passive Production, Capacity, and Upgrades

**Status:** Complete — PASS

Established and formally validated:

- one-owner persistent personal Vault/laboratory context;
- Collection Capacity as logical ordinary-use capacity, separate from Display Slots and Production Slots;
- GDS-4 `Overflow-Held` as the single baseline capacity-safety state;
- exact-instance `Resolve Overflow` when free capacity becomes available;
- deterministic non-destructive **Capacity Reconciliation** when effective capacity falls;
- display placement referencing the same owned Creature Instance without cloning it;
- persistent one-slot/one-instance **Production Assignments**;
- Overflow-Held creatures being ineligible for ordinary passive production;
- Production Profiles that may use Species and explicitly bounded situational Trait effects while rarity, Mutation, Compound status, provenance and Availability are not automatic production multipliers;
- elapsed-time **Passive Production** into a bounded persistent **Production Buffer**;
- bounded **Offline Production Window** behavior with no offline world/event claims, no server-hop reset and no elapsed-time replay;
- baseline passive semantics that do not secretly require AFK connection to preserve ordinary production value;
- exact-once/idempotent **Production Claim** semantics;
- exact-once, atomic player-facing **Vault Upgrade** semantics;
- upgrade categories covering Collection Capacity, Production Slots, Production Buffer, Offline Production Window, Display Capacity and approved utility/presentation unlocks;
- safe temporary-capacity expiry through reconciliation rather than deletion/forced purchase;
- GDS-5 Secured Ownership Finalization occurring before any Vault assignment/use;
- onboarding-safe first Vault/production interactions;
- baseline read-only visitors with no management authority or discovery credit;
- reset/disconnect/server-transition/shutdown persistence and Protected Load Failure gating;
- 80 compound Vault/capacity/production/lifecycle scenarios validated.

Closure evidence:

- [`vault/07_vault_base_passive_production_capacity_and_upgrades.md`](vault/07_vault_base_passive_production_capacity_and_upgrades.md) — Design Complete;
- [`GDS7_SCENARIO_VALIDATION.md`](GDS7_SCENARIO_VALIDATION.md) — 80 / 80 PASS;
- [`GDS7_CROSS_VALIDATION.md`](GDS7_CROSS_VALIDATION.md) — PASS;
- [`GDS7_DECISION_INDEX.md`](GDS7_DECISION_INDEX.md) — accepted phase-local decisions;
- [`GDS7_CLOSURE_REPORT.md`](GDS7_CLOSURE_REPORT.md) — PASS.

GDS-7 establishes the persistent home/capacity/passive-production contract consumed by economy, world, social, events, trading, monetization, presentation, analytics and Technical Architecture phases. It does not authorize implementation.

## GDS-8 — Economy, Progression, Unlocks, and Pacing

**Status:** NEXT — Draft

Defines currencies, passive-production resource economics, resource sources/sinks, capture-tool/cost progression, Vault Upgrade economics, biome unlocks, equipment progression, rarity/trait economic inputs, pacing bands, catch-up behavior, prestige/reset position if any, economy inflation controls at the design level, and long-term goals.

GDS-8 must consume GDS-7's Production Buffer/Claim and Vault Upgrade semantics without changing exact-once outcomes, capacity safety, or bounded offline-production rules.

## GDS-9 — World, Biomes, Exploration, Spawning, and Hazards

**Status:** Draft

Defines world structure, biome progression, traversal, creature spawn logic from the player perspective, Species Rarity/Mutation generation contexts, encounter lifetime, hazards, special zones, rare encounters, Vault Access Point/Secure Point placement, exploration rewards, density/readability, and content scalability.

## GDS-10 — Social Play, Cooperation, Competition, and PvP Boundaries

**Status:** Draft

Defines parties/friends, intentional co-play, shared objectives, social status/flexing, expanded Vault visitation permissions if any, player competition, collision/body-blocking rules, optional interception/PvP boundaries, protection windows, grief prevention, collaboration rewards, and multiplayer fairness.

## GDS-11 — Server Events, Dynamic Encounters, and Live Content

**Status:** Draft

Defines server-wide events, rifts/rare spawns, announcements, participation rules, reward allocation, event-specific shared/multi-award capture overrides, variant probability modifiers, any production modifiers, Availability Tags/event windows, event protection/provenance, cadence, server hopping implications, rotating/seasonal content, and live-ops extensibility.

## GDS-12 — Trading and Player Economy

**Status:** Draft

Defines trade eligibility, offer/accept flow, secured-instance transfer semantics, Production Assignment reconciliation before transfer, preservation of Mutation/Trait/Variant/provenance identity, value/scarcity philosophy, trade restrictions, cooldowns, rollback expectations, alternate-account abuse boundaries, and safe trading UX.

## GDS-13 — Monetization and Commercial Fairness

**Status:** Draft

Defines monetization philosophy, game passes/developer products/subscriptions if used, cosmetics, capacity/convenience, bounded production/progression acceleration if any, server-wide boosts, starter offers, purchase presentation, non-pay-to-win boundaries, spending pressure limits, probability/variant monetization constraints, and interactions with progression/trading.

## GDS-14 — Presentation, UI/UX, Feedback, and Accessibility

**Status:** Draft

Defines information hierarchy, HUD, menus, collection/Vault presentation, capacity/overflow/production feedback, rarity/mutation/trait/availability feedback, event/capture feedback, mobile/controller/keyboard expectations, audio/visual language, reduced-motion/readability needs, onboarding presentation, and accessibility requirements.

## GDS-15 — Roblox Platform, Social Safety, and Moderation Constraints

**Status:** Draft

Defines player-facing consequences of Roblox platform constraints, age-appropriate social mechanics, naming/text exposure, reporting/blocking expectations where relevant, UGC/content boundaries, randomized/paid probability constraints where applicable, and design constraints required for safe multiplayer interactions.

## GDS-16 — Retention, Discovery, Analytics, and Experimentation Boundaries

**Status:** Draft

Defines intended first-session funnel, session goals, return loops, daily/weekly engagement philosophy, social invitation loops, acquisition/Vault/variant-hunting promises, analytics hypotheses, scarcity/economy experiment governance, experimentable parameters, and guardrails preventing metric optimization from overriding player experience, fairness or value integrity.

## GDS-17 — Cross-System Consistency and Design-Complete Audit

**Status:** Blocked by GDS-8 through GDS-16

Performs the formal pre-architecture audit:

- ownership/authority audit;
- terminology/namespace audit;
- compound gameplay scenario audit;
- economy/progression/monetization audit;
- persistence/disconnect/recovery scenario audit;
- multiplayer abuse/griefing audit;
- rarity/variant/value-integrity audit;
- Vault/capacity/offline-production integrity audit;
- trading/value-integrity audit;
- presentation/accessibility audit;
- Roblox platform/safety audit;
- specification maturity scan;
- unresolved-question scan;
- final `Design Complete` verdict.

Only a PASS at GDS-17 opens the Technical Architecture sequence. Gameplay implementation remains blocked until the subsequent architecture and implementation-lock gates also pass.
