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

**Status:** Complete — PASS

Established and formally validated:

- third-person character-centric baseline exploration camera;
- familiar continuous directional locomotion plus conventional jump;
- no universal stamina tax on ordinary movement;
- no universal precision-platforming requirement for core progression;
- semantic touch/keyboard/gamepad control parity;
- universal **Primary Interact** contextual action;
- universal downstream-tool **Primary Action** semantic;
- exactly one visible **Active Context** with deterministic priority and activation-time revalidation;
- explicit modal input focus and protection against input spillover;
- basic equipment/inventory-facing access constraints;
- gameplay-first `show -> do -> confirm` onboarding;
- onboarding sequencing aligned to GDS-1 time-to-fun targets;
- persistent/resumable **Onboarding Milestones**;
- skippable/replayable **Guidance Layer** separated from real progression;
- onboarding-path availability despite normal multiplayer/server variation;
- **Safe Arrival** after GDS-2 Persistence Ready;
- concrete reset/failure/stuck **Recovery** behavior using valid Recovery Anchors;
- Recovery that cannot automatically secure transient value or become a universal extraction shortcut;
- non-color-only, non-audio-only, non-pixel-precision interaction constraints;
- 40 compound interaction/onboarding scenarios validated.

Closure evidence:

- [`player/03_player_character_interaction_and_onboarding.md`](player/03_player_character_interaction_and_onboarding.md) — Design Complete;
- [`GDS3_SCENARIO_VALIDATION.md`](GDS3_SCENARIO_VALIDATION.md) — PASS;
- [`GDS3_CROSS_VALIDATION.md`](GDS3_CROSS_VALIDATION.md) — PASS;
- [`GDS3_CLOSURE_REPORT.md`](GDS3_CLOSURE_REPORT.md) — PASS.

GDS-3 creates input/onboarding contracts for downstream systems but does not authorize Technical Architecture or implementation.

## GDS-4 — Creatures, Collection, and Ownership

**Status:** Complete — PASS

Established and formally validated:

- Species as authored archetypes distinct from owned Creature Instances;
- stable persistent identity for every Secured Creature;
- one ordinary owner per secured instance;
- **Acquisition-In-Progress** versus **Secured Creature** semantic boundary;
- GDS-5-owned **Secured Ownership Finalization** trigger with GDS-4-owned post-finalization consequences;
- persistent logical **Collection Registry**;
- Active, Stored, Overflow-Held, and Released collection-facing states;
- valid distinct duplicate instances without automatic conversion/deletion;
- non-destructive full-capacity and capacity-reduction behavior;
- **Overflow-Held** safety state when ownership finalizes without ordinary eligible capacity;
- onboarding-compatible initial usable collection capacity;
- explicit voluntary **Release** semantics;
- persistent player-controlled **Creature Lock** protection;
- no baseline involuntary loss of Secured Creatures through ordinary lifecycle/other players/capacity changes;
- persistent **Species Discovery** and discovery-based baseline Species completion;
- stable collectible **Provenance** semantics;
- explicit-authority requirement for future ownership transfer;
- 50 compound creature/ownership/capacity scenarios validated.

Closure evidence:

- [`creatures/04_creatures_collection_and_ownership.md`](creatures/04_creatures_collection_and_ownership.md) — Design Complete;
- [`GDS4_SCENARIO_VALIDATION.md`](GDS4_SCENARIO_VALIDATION.md) — PASS;
- [`GDS4_CROSS_VALIDATION.md`](GDS4_CROSS_VALIDATION.md) — PASS;
- [`GDS4_CLOSURE_REPORT.md`](GDS4_CLOSURE_REPORT.md) — PASS.

GDS-4 establishes the persistent collectible contract consumed by capture, rarity, vault, economy, live-content, and future trading phases. It does not authorize Technical Architecture or implementation.

## GDS-5 — Capture, Contesting, Transport, and Extraction

**Status:** Complete — PASS

Established and formally validated:

- player-specific Capture Eligibility and explicit valid initiation;
- one bounded exclusive ordinary **Engagement Claim** per single-award creature;
- ordinary social contesting as the race to validly engage before another active claim exists;
- claim release on success/failure/cancel/invalidation/inactivity instead of indefinite reservation;
- GDS-3-compatible cross-device Capture Challenge constraints;
- explicit Success / Failure / Cancel / Invalidation semantics;
- **Capture Success -> Provisional Capture** rather than immediate persistent ownership;
- stable same-instance identity through provisional transport and finalization;
- one baseline active **Transport Custody** per player;
- no ordinary direct theft of valid Transport Custody;
- reset/Recovery and voluntary leave do not count as extraction;
- bounded same-server **Transport Grace** for unexpected client disconnect;
- narrowly scoped exact-once **Protected Shutdown Finalization** for authoritative server-originated shutdown;
- explicit **Secure Point** semantics;
- validated **Extraction Completion** as the ordinary `Secured Ownership Finalization` boundary;
- exact-once single-winner finalization for normal finite creatures;
- known-full-capacity and unresolved-overflow initiation blocks;
- race-safe finalization into GDS-4 Overflow-Held when capacity changes after a valid attempt begins;
- **Onboarding-Protected Opportunity** so unrelated players cannot permanently deny the first required capture;
- anti-grief, anti-monopoly, anti-reset, anti-hop, and anti-duplication constraints;
- 60 compound acquisition/contesting/transport/lifecycle scenarios validated.

Closure evidence:

- [`capture/05_capture_contesting_transport_and_extraction.md`](capture/05_capture_contesting_transport_and_extraction.md) — Design Complete;
- [`GDS5_SCENARIO_VALIDATION.md`](GDS5_SCENARIO_VALIDATION.md) — 60 / 60 PASS;
- [`GDS5_CROSS_VALIDATION.md`](GDS5_CROSS_VALIDATION.md) — PASS;
- [`GDS5_CLOSURE_REPORT.md`](GDS5_CLOSURE_REPORT.md) — PASS.

GDS-5 establishes the active acquisition and exact ownership-boundary contract consumed by rarity, vault, economy, world, social, event, presentation, analytics, and Technical Architecture phases. It does not authorize Technical Architecture or implementation.

## GDS-6 — Rarity, Mutations, Traits, and Variant Value

**Status:** Complete — PASS

Established and formally validated:

- five ordered Species Rarity tiers: **Common, Uncommon, Rare, Epic, Legendary**;
- explicit separation of Species Rarity, Mutation, Trait, Availability Tag, gameplay power, currency value, and future market price;
- Variant Identity Finalization no later than an individually actionable Capture Opportunity;
- stable same-instance Mutation/Trait identity through claim release/reclaim, Capture Failure/retry, Provisional Capture, Transport Custody, reconnect, Extraction Completion, and duplicate finalization delivery;
- baseline zero-to-two Mutation count;
- **Standard**, **Single-Mutated**, and **Compound-Mutated** Variant classes;
- authored Mutation compatibility and order-independent canonical Mutation sets;
- context-aware Mutation Frequency Bands: **Frequent, Uncommon, Rare, Extreme**;
- meaningful mutation readability with non-color-only critical identification;
- Traits as stable instance characteristics supporting bounded situational optimization rather than universal supremacy;
- **Variant Signature = Species + canonical Mutation set**;
- historical **Mutation Discovery** and **Variant Discovery** on legitimate securisation;
- automatic Creature Lock for **Protected Variants** including Legendary, Extreme-Mutated, Compound-Mutated, and explicitly protected event/legacy instances;
- prospective-only probability modifiers;
- prohibition on hidden individualized odds based on spending, purchase reluctance, inferred willingness to pay, or loss-chasing behavior;
- Availability Tags **Core, Rotating, Event-Limited, Legacy** separate from rarity;
- stable owned-instance identity across ordinary balance/content changes;
- rarity/variant value that does not guarantee raw power or economic/market price;
- 70 compound rarity/variant/probability/lifecycle scenarios validated.

Closure evidence:

- [`rarity_mutations/06_rarity_mutations_traits_and_variant_value.md`](rarity_mutations/06_rarity_mutations_traits_and_variant_value.md) — Design Complete;
- [`GDS6_SCENARIO_VALIDATION.md`](GDS6_SCENARIO_VALIDATION.md) — 70 / 70 PASS;
- [`GDS6_CROSS_VALIDATION.md`](GDS6_CROSS_VALIDATION.md) — PASS;
- [`GDS6_CLOSURE_REPORT.md`](GDS6_CLOSURE_REPORT.md) — PASS.

GDS-6 establishes the collectible scarcity/value-integrity contract consumed by vault, economy, world, events, trading, monetization, presentation, analytics, safety, and Technical Architecture phases. It does not authorize Technical Architecture or implementation.

## GDS-7 — Vault/Base, Passive Production, Capacity, and Upgrades

**Status:** NEXT — Draft

Defines the personal vault/laboratory, creature placement, passive production, storage/capacity, base upgrades, offline production, presentation/status display, visitor interaction, Secure Point integration, and progression dependencies.

GDS-7 must preserve GDS-4 instance ownership/capacity safety, GDS-5 post-extraction finalization, and GDS-6 stable Mutation/Trait/Variant identity while defining how creatures can be stored, displayed, assigned, and used for bounded production.

## GDS-8 — Economy, Progression, Unlocks, and Pacing

**Status:** Draft

Defines currencies, resource sources/sinks, capture-tool/cost progression, upgrade economy, biome unlocks, equipment progression, rarity/trait economic inputs, pacing bands, catch-up behavior, prestige/reset position if any, economy inflation controls at the design level, and long-term goals.

## GDS-9 — World, Biomes, Exploration, Spawning, and Hazards

**Status:** Draft

Defines world structure, biome progression, traversal, creature spawn logic from the player perspective, Species Rarity/Mutation generation contexts, encounter lifetime, hazards, special zones, rare encounters, Secure Point placement, exploration rewards, density/readability, and content scalability.

## GDS-10 — Social Play, Cooperation, Competition, and PvP Boundaries

**Status:** Draft

Defines parties/friends, intentional co-play, shared objectives, social status/flexing, player competition, collision/body-blocking rules, optional interception/PvP boundaries, protection windows, grief prevention, collaboration rewards, and multiplayer fairness.

## GDS-11 — Server Events, Dynamic Encounters, and Live Content

**Status:** Draft

Defines server-wide events, rifts/rare spawns, announcements, participation rules, reward allocation, event-specific shared/multi-award capture overrides, variant probability modifiers, Availability Tags/event windows, event protection/provenance, cadence, server hopping implications, rotating/seasonal content, and live-ops extensibility.

## GDS-12 — Trading and Player Economy

**Status:** Draft

Defines trade eligibility, offer/accept flow, secured-instance transfer semantics, preservation of Mutation/Trait/Variant/provenance identity, value/scarcity philosophy, trade restrictions, cooldowns, rollback expectations from the player perspective, alternate-account abuse boundaries, and safe trading UX.

## GDS-13 — Monetization and Commercial Fairness

**Status:** Draft

Defines monetization philosophy, game passes/developer products/subscriptions if used, cosmetics, capacity/convenience, server-wide boosts, starter offers, purchase presentation, non-pay-to-win boundaries, spending pressure limits, probability/variant monetization constraints, and interactions with progression/trading.

## GDS-14 — Presentation, UI/UX, Feedback, and Accessibility

**Status:** Draft

Defines information hierarchy, HUD, menus, collection presentation, rarity/mutation/trait/availability feedback, event feedback, capture feedback, mobile/controller/keyboard expectations, audio/visual language, reduced-motion/readability needs, onboarding presentation, and accessibility requirements.

## GDS-15 — Roblox Platform, Social Safety, and Moderation Constraints

**Status:** Draft

Defines player-facing consequences of Roblox platform constraints, age-appropriate social mechanics, naming/text exposure, reporting/blocking expectations where relevant, UGC/content boundaries, randomized/paid probability constraints where applicable, and design constraints required for safe multiplayer interactions.

## GDS-16 — Retention, Discovery, Analytics, and Experimentation Boundaries

**Status:** Draft

Defines intended first-session funnel, session goals, return loops, daily/weekly engagement philosophy, social invitation loops, discovery/variant-hunting promises, analytics hypotheses, scarcity experiment governance, experimentable parameters and guardrails that prevent metric optimization from overriding player experience, fairness, or value integrity.

## GDS-17 — Cross-System Consistency and Design-Complete Audit

**Status:** Blocked by GDS-7 through GDS-16

Performs the formal pre-architecture audit:

- ownership/authority audit;
- terminology/namespace audit;
- compound gameplay scenario audit;
- economy/progression/monetization audit;
- persistence/disconnect/recovery scenario audit;
- multiplayer abuse/griefing audit;
- rarity/variant/value-integrity audit;
- trading/value-integrity audit;
- presentation/accessibility audit;
- Roblox platform/safety audit;
- specification maturity scan;
- unresolved-question sweep;
- final `Design Complete` promotion report.

## Current Project Gate

GDS-0 through GDS-6 are formally complete. The active dependency is **GDS-7 — Vault/Base, Passive Production, Capacity, and Upgrades**.

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
  -> GDS-7..16 subsystem design — GDS-7 NEXT
  -> GDS-17 cross-system audit
  -> DESIGN COMPLETE
  -> Technical Architecture
  -> Architecture audit + implementation locking
  -> Implementation
```
