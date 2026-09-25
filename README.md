# Monster Vault

> A data-driven multiplayer creature-collection and progression game built on Roblox.

## Project Status

**Game Design Specification — DESIGN COMPLETE / Technical Architecture TA-0..17 COMPLETE / IMPLEMENTATION OPEN — IMP-1 and IMP-2 complete; IMP-3 next.**

MonsterVault has completed the specification and Technical Architecture gates. **Implementation is now OPEN under the TA-17 locked contracts**; production release remains gated by TA-15 verification and the implementation roadmap.

```text
Game Design Specification (GDS)
  -> cross-system design audit
  -> Technical Architecture (TA)
  -> architecture integration audit
  -> implementation roadmap + contract locking
  -> gameplay implementation
```

No gameplay system should be implemented merely because an idea appears promising. Player-facing behavior is first specified and cross-validated; only then is the technical contract designed and locked.

### Current gate state

- **GDS-0 — Governance, Structure, and Concept Baseline: COMPLETE — PASS**
- **GDS-1 — Product Vision, Audience, and Success Criteria: COMPLETE — PASS**
- **GDS-2 — Global Game Rules and Session Model: COMPLETE — PASS**
- **GDS-3 — Player Character, Interaction, and Onboarding: COMPLETE — PASS**
- **GDS-4 — Creatures, Collection, and Ownership: COMPLETE — PASS**
- **GDS-5 — Capture, Contesting, Transport, and Extraction: COMPLETE — PASS**
- **GDS-6 — Rarity, Mutations, Traits, and Variant Value: COMPLETE — PASS**
- **GDS-7 — Vault/Base, Passive Production, Capacity, and Upgrades: COMPLETE — PASS**
- **GDS-8 — Economy, Progression, Unlocks, and Pacing: COMPLETE — PASS**
- **GDS-9 — World, Biomes, Exploration, Spawning, and Hazards: COMPLETE — PASS**
- **GDS-10 — Social Play, Cooperation, Competition, and PvP Boundaries: COMPLETE — PASS**
- **GDS-11 — Server Events, Dynamic Encounters, and Live Content: COMPLETE — PASS**
- **GDS-12 — Trading and Player Economy: COMPLETE — PASS**
- **GDS-13 — Monetization and Commercial Fairness: COMPLETE — PASS**
- **GDS-14 — Presentation, UI/UX, Feedback, and Accessibility: COMPLETE — PASS**
- **GDS-15 — Roblox Platform, Social Safety, and Moderation Constraints: COMPLETE — PASS**
- **GDS-16 — Retention, Discovery, Analytics, and Experimentation Boundaries: COMPLETE — PASS**
- **GDS-17 — Cross-System Consistency and Design-Complete Audit: COMPLETE — PASS**
- **GAME DESIGN SPECIFICATION: DESIGN COMPLETE**
- **TA-0 — Architecture Governance, Constraints, and GDS Traceability: ARCHITECTURE COMPLETE — PASS**
- **TA-1 — Roblox System Context, Toolchain, and Development Environment: ARCHITECTURE COMPLETE — PASS**
- **TA-2 — Repository Layout, Module Boundaries, Dependency Direction, and Bootstrapping: ARCHITECTURE COMPLETE — PASS**
- **TA-3 — Networking, Server Authority, Remote Contracts, and Exploit Boundaries: ARCHITECTURE COMPLETE — PASS**
- **TA-4 — Player Data, Persistence, Session Ownership, Schema Evolution, and Recovery: ARCHITECTURE COMPLETE — PASS**
- **TA-5 — Identity, Content Registries, Configuration, and Data-Driven Content: ARCHITECTURE COMPLETE — PASS**
- **TA-6 — Runtime Entity, Player, Creature, and World Lifecycle: ARCHITECTURE COMPLETE — PASS**
- **TA-7 — Capture, Creature Ownership, Mutation, and Reward Resolution: ARCHITECTURE COMPLETE — PASS**
- **TA-8 — Vault, Economy, Progression, Inventory, and Offline Accrual: ARCHITECTURE COMPLETE — PASS**
- **TA-9 — World, Biomes, Spawn Scheduling, Streaming, and Encounter Scaling: ARCHITECTURE COMPLETE — PASS**
- **TA-10 — Social Systems, Server Events, Cross-Server Coordination, and Trading: ARCHITECTURE COMPLETE — PASS**
- **TA-11 — Monetization, MarketplaceService, Receipt Processing, and Entitlements: ARCHITECTURE COMPLETE — PASS**
- **TA-12 — Client Presentation, UI State, Input, Camera, Audio, and Accessibility: ARCHITECTURE COMPLETE — PASS**
- **TA-13 — Analytics, Telemetry, Feature Flags, Configuration Rollouts, and Live Operations: ARCHITECTURE COMPLETE — PASS**
- **TA-14 — Performance, Network, Memory, Persistence, and Scalability Budgets: ARCHITECTURE COMPLETE — PASS**
- **TA-15 — Testing, Diagnostics, Security Validation, and CI Architecture: ARCHITECTURE COMPLETE — PASS**
- **TA-16 — Architecture Integration and Implementation-Readiness Audit: INTEGRATION COMPLETE — PASS**
- **TA-17 — Implementation Roadmap, Vertical Slice, Contract Locking, and Change Control: IMPLEMENTATION LOCKED — PASS**
- **Gameplay implementation: OPEN — IMP-1 and IMP-2 complete; IMP-3 Profile Session Foundation next**
- Production release: blocked until applicable TA-15/TA-14/staging/release gates pass

GDS-17 final evidence is recorded in [`17_cross_system_consistency_and_design_complete_audit.md`](docs/game_design/audit/17_cross_system_consistency_and_design_complete_audit.md), [`GDS17_AUTHORITY_NAMESPACE_AUDIT.md`](docs/game_design/GDS17_AUTHORITY_NAMESPACE_AUDIT.md), [`GDS17_MATURITY_OPEN_QUESTION_AUDIT.md`](docs/game_design/GDS17_MATURITY_OPEN_QUESTION_AUDIT.md), [`GDS17_COMPOUND_SCENARIO_VALIDATION.md`](docs/game_design/GDS17_COMPOUND_SCENARIO_VALIDATION.md), [`GDS17_DECISION_INDEX.md`](docs/game_design/GDS17_DECISION_INDEX.md), and [`GDS17_CLOSURE_REPORT.md`](docs/game_design/GDS17_CLOSURE_REPORT.md).

## Product Contract

MonsterVault is formally defined at product level as a **social creature-collection and progression adventure** with the promise:

> **Find it. Catch it. Bring it home. Make your vault legendary.**

The high-level product contract includes:

- primary audience around ages **9–15**, with older collection/optimization players as a secondary audience;
- mobile-first interaction constraints with cross-platform gameplay parity;
- core progression that does not depend on unrestricted chat or voice;
- active exploration/capture instead of primarily menu/idle acquisition;
- persistent visible collection/Vault progression;
- rarity and mutation/variant hunting;
- server-level social opportunities;
- socially competitive but **non-loss-dominant** play;
- no baseline requirement for unrestricted theft of secured persistent creatures;
- no direct-combat PvP requirement;
- normal sessions around **10–25 minutes**, while short 3–5 minute sessions remain meaningful;
- weeks-to-months long-term collection/progression aspirations;
- trading as desirable but not launch-critical;
- moderate, non-coercive monetization;
- live-content extensibility;
- retention-first product success gates.

## Global Lifecycle Contract

GDS-2 locks the project-wide session/persistence baseline:

- Roblox server sessions are temporary runtime contexts, not the owner of long-term player progression;
- finalized persistent progress survives ordinary avatar failure, reset, disconnect, reconnect, server changes, device changes, and server shutdown;
- irreversible gameplay is blocked until trusted persistent state is ready;
- inability to establish trusted state enters **Protected Load Failure** instead of unsafe blank-profile play;
- finalized persistent outcomes apply once across retries/reconnects;
- failure/reset invokes Recovery rather than a global persistent wipe;
- offline progression is optional unless explicitly authorized downstream;
- persistent timers/global windows do not implicitly restart on server transition;
- lifecycle semantics are consistent across supported device classes.

## Player Interaction and Onboarding Contract

GDS-3 locks:

- third-person character-centric exploration;
- familiar movement/jump without a universal stamina tax;
- equivalent baseline capability on touch, keyboard/mouse, and controller;
- universal **Primary Interact** and downstream **Primary Action** semantics;
- one deterministic visible **Active Context**;
- gameplay-first onboarding with persistent **Onboarding Milestones**;
- **Safe Arrival** after trusted persistence readiness;
- reset/failure/stuck **Recovery** that does not automatically secure transient value;
- semantic accessibility constraints before final presentation work.

## Creature Collection and Ownership Contract

GDS-4 locks:

- **Species** as authored archetype versus individually persistent **Creature Instances**;
- one ordinary owner per Secured Creature;
- stable Collection Registry identity and duplicate preservation;
- Active, Stored, Overflow-Held, and Released collection-facing states;
- non-destructive capacity safety through **Overflow-Held**;
- explicit voluntary Release;
- persistent **Creature Lock** protection;
- historical **Species Discovery** and provenance;
- explicit authority for any future ownership transfer.

## Capture, Contesting, Transport, and Extraction Contract

GDS-5 locks the ordinary active acquisition loop:

```text
Capture Opportunity
  -> Engagement Claim
  -> Capture Attempt
  -> Capture Success
  -> Provisional Capture / Transport Custody
  -> Secure Point / Extraction Completion
  -> Secured Ownership Finalization
  -> GDS-4 Secured Creature
```

The resulting contract includes bounded claim fairness, one ordinary Transport Custody, no ordinary custody theft, deterministic reset/leave/disconnect/shutdown behavior, exact-once single-winner finalization, known-full/unresolved-overflow capture gating, late capacity-race safety, and onboarding-protected first acquisition.

## Rarity, Mutations, Traits, and Variant Value Contract

GDS-6 locks the collectible scarcity/value layer:

- Species Rarity tiers: **Common, Uncommon, Rare, Epic, Legendary**;
- rarity, Mutation, Trait, Availability, gameplay power, currency value, and market price are separate axes;
- Mutation/Trait identity is finalized no later than an actionable Capture Opportunity and cannot reroll through retries/reconnect/finalization;
- baseline instances carry zero, one, or at most two compatible Mutations;
- Mutation Frequency uses `Frequent`, `Uncommon`, `Rare`, and `Extreme` bands;
- Variant Signature is `Species + canonical Mutation set`;
- Mutation/Variant Discovery is historical after legitimate securisation;
- Protected Variants auto-apply Creature Lock when required;
- probability modifiers are prospective only;
- hidden individualized spending/loss-chasing odds are prohibited;
- owned instance identity remains stable across ordinary balancing/content changes.

## Vault/Base, Passive Production, Capacity, and Upgrades Contract

GDS-7 turns the secured collection into a persistent home/progression surface while preserving GDS-4 through GDS-6 integrity:

- one player owns one baseline persistent personal **Vault** context;
- **Collection Capacity** limits ordinary usable collection state and is separate from **Display Slots** and **Production Slots**;
- capacity pressure never deletes, sells, merges, Releases, or silently converts a Secured Creature;
- GDS-4 **Overflow-Held** remains the single baseline capacity-safety state;
- free capacity supports exact-instance **Resolve Overflow**;
- effective capacity reductions use deterministic non-destructive **Capacity Reconciliation**;
- display references the same Creature Instance and cannot create duplicate owned copies;
- **Production Assignment** is persistent, one-slot/one-instance, and Overflow-Held creatures cannot produce;
- Species may have authored **Production Profiles** and Traits may have explicit bounded situational effects, but Species Rarity, Mutation frequency, Compound status, provenance, and Availability are not automatic production multipliers;
- valid assignments generate elapsed-time **Passive Production** into a bounded persistent **Production Buffer**;
- buffer saturation pauses further accrual;
- bounded offline production is explicitly allowed only up to the **Offline Production Window** or buffer cap;
- offline production creates no live-world/event participation and cannot reset through server hopping or replay the same elapsed interval;
- **Production Claims** are exact-once/idempotent and uncertain failures preserve buffered value;
- **Vault Upgrades** are exact-once persistent outcomes with atomic player-facing cost/effect semantics;
- temporary capacity expiry is safe through reconciliation rather than deletion or forced purchase;
- baseline visitors are read-only and cannot mutate owner state or gain discovery merely by viewing;
- Protected Load Failure blocks irreversible Vault management;
- core Vault use retains a viable non-premium progression path.

The authoritative GDS-7 specification is [`07_vault_base_passive_production_capacity_and_upgrades.md`](docs/game_design/vault/07_vault_base_passive_production_capacity_and_upgrades.md).

## Economy, Progression, Unlocks, and Pacing Contract

GDS-8 turns Vault output into a controlled progression economy without allowing passive waiting or monetization pressure to replace the active collection game:

- **Energy** is the single baseline persistent non-premium soft currency;
- Energy is non-negative, player-facing whole-unit value and is not baseline player-to-player transferable;
- GDS-7 **Production Claim** is the recurring passive Energy source, while active gameplay may grant bounded objective/milestone rewards;
- ordinary Release and repeated capture do not automatically mint Energy;
- Energy sinks include Vault Upgrades, durable **Capture Capability**, Access Unlocks, approved exploration/utility upgrades, and later optional presentation sinks;
- no mandatory Energy maintenance tax, debt, or universal per-capture Energy fee exists;
- Species may have authored Production Profiles and bounded Traits may affect production, but Species Rarity, Mutation prestige, Compound status, Availability, and Provenance are not automatic income multipliers;
- major progression may require persistent active **Progression Milestones** in addition to Energy, preventing offline production from completing the whole progression ladder;
- persistent progression purchases are exact-once and atomic: finalized cost and effect remain coherent through retries/reconnects;
- reference pacing keeps the first meaningful progression choice in the opening minutes and preserves parallel goals through later bands;
- passive Vault production should remain economically meaningful without making active play irrelevant; the initial tuning target is approximately 50–70% passive versus 30–50% active recurring Energy income;
- catch-up may visibly compress obsolete Energy friction but cannot fabricate discovery/event/world history;
- arbitrary seasonal/currency wipes are prohibited;
- baseline progression has **no prestige/rebirth reset** that wipes Energy, Vault upgrades, access, discoveries, or Secured Creatures;
- hidden spending-propensity-based prices/rewards are prohibited;
- paid Energy or paid progression acceleration remains unauthorized until GDS-13 evaluates it.

The authoritative GDS-8 specification is [`08_economy_progression_unlocks_and_pacing.md`](docs/game_design/economy_progression/08_economy_progression_unlocks_and_pacing.md).

## World, Biomes, Exploration, Spawning, and Hazards Contract

GDS-9 turns the capture/collection/progression contracts into a concrete explorable world while preserving scarcity, lifecycle and ownership integrity:

- launch topology is **Home Hub -> Starter Biome -> two parallel Mid Biomes -> Advanced Biome**;
- Starter access is free; each Mid branch requires Starter **Region Mastery** plus its own persistent Energy Access Unlock; Advanced requires both Mid Masteries plus an Energy Access Unlock;
- Region Mastery combines Landmark-based Route Survey, a distinct Core-Species collection threshold and an active Field Objective;
- mandatory progression cannot require Legendary, Extreme Mutation, Compound Variant, Event-Limited content, one specific low-probability spawn or a paid product;
- Home Hub and field **Safe Outposts** provide predictable Secure Point / Recovery infrastructure;
- every unlocked Biome has a baseline non-premium **Safe Route**;
- discovered travel nodes provide quality-of-life, but fast travel is disabled throughout **Acquisition-In-Progress** so capture/transport cannot be bypassed;
- Biomes contain materially distinct **Habitats** with authored **Spawn Contexts**;
- encounter populations are bounded and ordinary active search targets roughly **20–45 seconds** to a viable ordinary opportunity on normal routes;
- rarity labels do not hard-code universal spawn percentages; Species/Mutation/Trait generation remains prospective and a surviving instance never rerolls from claim cycling, retries, time-phase changes or spending state;
- hidden Energy/Robux/spending-propensity-based spawn odds are prohibited;
- encounter lifetimes may refresh idle populations but cannot arbitrarily despawn a valid active claim/capture/transport;
- publicly actionable Protected Variants receive a meaningful **Rare Encounter Stability Window** and recognizable collectible identity;
- a deterministic ordinary **World Cycle** may influence future spawn eligibility but is not a GDS-11 Server Event and cannot be privately restarted through server hopping;
- environmental **Hazards** may cause temporary Recovery but cannot delete/reroll secured creatures, deduct arbitrary Energy or revoke persistent progress;
- public encounters are session-scoped, while Access Unlocks, Landmark Discoveries, Region Mastery and finalized objective rewards are persistent;
- future Biomes/Species/spawn balancing extend the world prospectively without revoking historical access/mastery or rewriting owned Creature identity/provenance.

The authoritative GDS-9 specification is [`09_world_biomes_exploration_spawning_and_hazards.md`](docs/game_design/world/09_world_biomes_exploration_spawning_and_hazards.md).

## Social Play, Cooperation, Competition, and PvP Contract

GDS-10 adds intentional multiplayer cooperation and social competition without turning ordinary collection into destructive PvP:

- baseline **Parties** are explicit consent-based groups of up to four players;
- Party/friend status grants no shared ownership, Energy Wallet, Vault authority, access, claim, custody or progression;
- structured rate-limited **Social Pings** provide baseline coordination without requiring unrestricted chat or voice;
- personal Landmark Discovery, Regional Collection, Region Mastery and Access Unlock requirements remain personal;
- explicitly authored **Shared Objectives** may credit several players, but each player must provide meaningful **Eligible Contribution**;
- eligible participants may receive bounded exact-once personal **Collaboration Rewards**; there is no Party wallet or direct Energy transfer;
- ordinary creature acquisition remains **one valid Engagement Claim -> one Transport Custody -> one ordinary owner**;
- teammates cannot hand off custody, extract for the carrier, duplicate a creature or gain discovery from observation;
- public competition is valid before a claim, while **Friendly Challenges** are explicit opt-in and non-destructive;
- baseline challenges use no creature/Energy wagering and are not a repeatable Energy-farming loop;
- ordinary play has no direct-combat PvP, transport interception, secured-creature theft or player-caused Energy loss;
- player collision is semantically non-obstructive so players cannot body-block Safe Routes, Secure Points, Recovery Anchors or intended interactions;
- Vault socialization remains owner-controlled and read-only through Visitor Access Policy / Showcase semantics;
- Party size, friend count, visitors and social activity do not modify hidden rarity/Mutation/spawn odds or Passive Production;
- Party/invite/Ping/challenge state is transient while legitimate finalized personal rewards/progression remain exact-once persistent outcomes.

The authoritative GDS-10 specification is [\`10_social_play_cooperation_competition_and_pvp_boundaries.md\`](docs/game_design/social/10_social_play_cooperation_competition_and_pvp_boundaries.md).

## Server Events, Dynamic Encounters, and Live Content Contract

GDS-11 adds live world variation without allowing event timing or server transitions to rewrite ownership/scarcity:

- **Global Event Windows / Event Occurrences** use shared wall-clock timing and do not restart when a player joins another server;
- each server hosts its own session-local **Server Event Instance**, Rift state, shared-objective progress and public event creature population;
- event lifecycle is explicit: **Announced -> Active -> Resolving -> Ended**;
- late join is allowed only while meaningful contribution remains possible;
- event rewards require personal active **Event Contribution**; AFK presence, Party membership and last-hit status alone are insufficient;
- Event Participation Rewards and Event Completion Records finalize exact-once;
- **Event Spawn Modifiers** apply only to genuinely new Creature Instances and never reroll surviving/owned creatures;
- Event-Limited / Rotating / Legacy Availability changes future obtainability without invalidating owned instances or provenance;
- Rifts/Event Zones cannot block required Safe Routes, Secure Points or Recovery Anchors;
- ordinary event creatures remain **single-award** under GDS-5 by default;
- explicit **Event Multi-Award Encounters** may issue multiple participants separate **Personal Event Capture Opportunities**, each backed by a distinct Creature Instance rather than copied ownership of one target;
- event end stops new generation but provides bounded **Event Resolution Grace** for legitimate active acquisition/reward resolution;
- server hopping cannot restart event duration, replay exact-once rewards or reroll a guaranteed personal event opportunity;
- events layer on the ordinary World Cycle rather than resetting it;
- no baseline event direct-combat PvP, interception, body-blocking or paid claim priority is authorized;
- event Energy rewards are bounded active-play Economy Sources;
- GDS-11 authorizes **no baseline event multiplier to Vault Passive Production, Production Buffer or Offline Production Window**;
- seasonal rotation, disable and hotfix behavior are prospective and preserve legitimate finalized value.

The authoritative GDS-11 specification is [\`11_server_events_dynamic_encounters_and_live_content.md\`](docs/game_design/events_liveops/11_server_events_dynamic_encounters_and_live_content.md).

## Trading and Player Economy Contract

GDS-12 authorizes safe direct creature exchange without turning Energy into transferable market tender:

- baseline **Trade Access** is earned non-premium after onboarding and Starter Region Mastery;
- trading is direct, same-server and bilateral between exactly two eligible players;
- each side must offer at least one eligible **Secured Creature**; baseline zero-sided gifting is not authorized;
- **Energy remains non-transferable** and cannot appear in Trade Offers;
- no creature-for-Energy market, trade tax, auction house, public order book, offline listing or asynchronous escrow exists at baseline;
- offers operate on exact Creature Instances, not Species counts;
- **Creature Lock** blocks transfer; Protected Variants require deliberate unlock and arrive re-locked for the receiver;
- Production-assigned/active-role creatures cannot be offered until safely removed from those roles;
- eligible Overflow-Held creatures may be traded out, but the receiver's complete net post-trade state must fit ordinary Collection Capacity;
- each semantic offer change creates a new **Trade Revision** and clears prior Ready/Final Confirmation state;
- both players independently become Ready and then explicitly confirm the same immutable final revision;
- **Trade Commit** is all-or-nothing and exact-once: the complete agreed ownership swap succeeds or nothing transfers;
- Species, Mutation, Trait, Variant Signature and original provenance remain unchanged;
- trade history is appended rather than rewriting acquisition origin;
- receiving a creature may create Species/Mutation/Variant Discovery, but cannot fabricate Region Mastery, Event Completion or other source-bound active milestones;
- received creatures enter persistent wall-clock **Trade Cooldown**;
- explicit Tradeable / Time-Locked / Account-Bound restrictions govern transfer eligibility;
- MonsterVault does not certify one trade as objectively fair through a hidden official value formula;
- trade volume creates no Energy, progression, rarity or spawn advantage.

The authoritative GDS-12 specification is [`12_trading_and_player_economy.md`](docs/game_design/trading/12_trading_and_player_economy.md).
## Monetization and Commercial Fairness Contract

GDS-13 defines a moderate commercial model that monetizes presentation and bounded convenience without selling collectible luck or system safety:

- deterministic **cosmetics/status** are the primary paid product class;
- bounded paid **Collection Capacity / Display Capacity** convenience is allowed, but not Production Slots, Production Buffer, Offline Production Window or production multipliers;
- there is no unlimited direct Robux-to-Energy exchange; only a one-time bounded Starter Value Bundle may include a small deterministic Energy grant;
- payment cannot buy Species/Mutation/Trait luck, rerolls, capture success, easier capture, claim priority or paid-only baseline Species/Mutations;
- no paid random Creature Instance, variant roll, loot box, gacha, egg, crate or randomized cosmetic container is authorized at baseline;
- Region Mastery, world access, ordinary event access/contribution and Trade Access remain gameplay-earned;
- payment cannot bypass Creature Lock, Trade Cooldown, Account-Bound/Time-Locked rules or trade safety;
- no baseline recurring subscription or paid server-wide gameplay boost is authorized;
- product price, contents and durable/one-time semantics must be explicit;
- fake discounts, fake countdowns, loss-chasing paid rescue and repeated modal nagging are prohibited;
- commercial prompts cannot interrupt Acquisition-In-Progress, final trade review, event capture resolution, Recovery or Protected Load Failure;
- **Commercial Finalization** is exact-once across retries/reconnects;
- loss/reversal of paid capacity uses safe GDS-7 reconciliation and cannot delete Secured Creatures or create Energy debt;
- non-paying players retain viable collection, Vault, world, event and trading progression.

The authoritative GDS-13 specification is [`13_monetization_and_commercial_fairness.md`](docs/game_design/monetization/13_monetization_and_commercial_fairness.md).
## Presentation, UI/UX, Feedback, and Accessibility Contract

GDS-14 defines how every closed gameplay system is communicated without allowing the UI to redefine gameplay truth:

- presentation follows a strict priority hierarchy: **safety/trust → committed state → time-sensitive opportunity → immediate interaction → progression → social/commercial**;
- one consequential modal owns input focus at a time, with deterministic Back/Close and focus restoration;
- Context Prompts communicate both action meaning and the current-device input glyph;
- grouped collection views must preserve exact-instance inspection for ownership-sensitive actions;
- Species Rarity, Mutation, Trait, Availability, provenance and commercial cosmetics remain separate presentation dimensions;
- Capture Success is shown as **Provisional Capture / Transport Custody**, not secured ownership; Extraction Completion gets the persistent ownership confirmation;
- Collection Capacity, Display Slots, Production Slots, Production Buffer and Offline Production Window are never collapsed into one ambiguous metric;
- Progression Gates show each missing Energy, milestone and prerequisite separately;
- event UI distinguishes server progress from personal contribution eligibility and single-award from Multi-Award encounters;
- trade offer changes visibly reset Ready/confirmation state and final review is immutable;
- commercial UI must expose truthful price/content/state and cannot interrupt critical gameplay;
- critical meaning never depends on color alone, audio alone, hover, drag-and-drop or precision pointer control;
- **Reduced Motion**, readability/contrast support and non-audio equivalents are baseline free accessibility features;
- touch, keyboard/mouse and gamepad retain semantic parity;
- onboarding remains show → do → confirm and never becomes store-first;
- reconnect/reconciliation presentation follows authoritative current state rather than replaying finalization as though it happened again.

The authoritative GDS-14 specification is [`14_presentation_ui_ux_feedback_and_accessibility.md`](docs/game_design/presentation/14_presentation_ui_ux_feedback_and_accessibility.md).
## Roblox Platform, Social Safety, and Moderation Contract

GDS-15 makes Roblox safety/policy a live external boundary while keeping the core game robust when optional communication or commerce differs per user:

- policy-gated features use **Roblox-authoritative per-user eligibility**, not hard-coded mutable age/country rules;
- core onboarding, capture, Vault, world progression, events and structured trading do not require unrestricted text chat or voice;
- MonsterVault does not provide a parallel unfiltered custom chat system;
- launch baseline has no custom public freeform creature names, Vault names, Party names, signs, bios or trade notes;
- any future user-visible freeform text must successfully pass the appropriate Roblox filtering path; filter failure never displays raw text;
- structured Social Pings remain authored, rate-limited, duplicate-suppressed and freely muteable;
- platform reporting remains accessible and blocking/restrictions suppress new directed contact where applicable;
- experience-level moderation may restrict social access, kick or ban, but does not silently confiscate unrelated legitimate Secured Creatures, Energy or provenance;
- MonsterVault does not solicit unnecessary personal information or require Discord/external contact/payment;
- launch content targets a broad **Minimal-to-Mild** maturity envelope; materially higher-maturity content reopens GDS-15;
- no playable value-bearing wagering exists;
- no baseline paid-random item mechanic exists, including premium-currency workarounds;
- commercial entitlements remain outside GDS-12 Trade Offers, avoiding baseline paid-item-trading complexity;
- Roblox policy changes may narrow optional features, but more permissive platform capability never auto-authorizes new risky mechanics;
- a current official Roblox policy review is mandatory again before implementation lock/launch.

The authoritative GDS-15 specification is [`15_roblox_platform_social_safety_and_moderation_constraints.md`](docs/game_design/platform_safety/15_roblox_platform_social_safety_and_moderation_constraints.md).
## Retention, Discovery, Analytics, and Experimentation Contract

GDS-16 defines how MonsterVault learns from player behavior without turning analytics into hidden gameplay authority:

- GDS-1's success hierarchy remains binding: **comprehension/satisfaction → retention → meaningful engagement → social value → discovery/acquisition → monetization**;
- first-session and returning-player funnels measure whether the core product promise is actually understood and reached;
- a non-blocking **Return Brief** may surface existing Production Buffer, current events, unresolved Overflow and useful next goals;
- optional **Next Aspirations** guide already-valid progression/collection goals but never grant rewards, eligibility or hidden odds;
- there is **no baseline daily login reward, login streak, absence punishment or mandatory daily/weekly checklist**;
- raw session time is not treated as healthy engagement when driven by AFK, waiting, confusion or forced timers;
- notifications/reminders, if used later, must be factual, policy-aware, frequency-bounded and non-guilt/non-loss-chasing;
- Discovery Packaging may be A/B tested only while truthfully representing the shipped experience;
- analytics may segment cohorts for diagnosis, including device, progression and payer/non-payer, but that segmentation cannot secretly personalize collectible odds or claim/capture power;
- product analytics minimizes data and does not require raw chat content, unnecessary PII or sensitive-trait inference;
- every decision-grade experiment requires a hypothesis, owner, primary metric, guardrails, stable treatment exposure and stop/rollback conditions;
- public/shared value experiments require coherent server/event rules rather than contradictory per-player hidden rules;
- persistent-value experiments are prospective and auditable; valid Finalized Outcomes survive rollback;
- ownership, Creature Lock, exact-once persistence, trade atomicity, platform safety, accessibility and commercial fairness are **Experiment Invariants**;
- if the core loop remains weak after substantive iteration, the response is redesign rather than larger rewards, stronger FOMO, more notifications or more monetization pressure.

The authoritative GDS-16 specification is [`16_retention_discovery_analytics_and_experimentation_boundaries.md`](docs/game_design/retention_analytics/16_retention_discovery_analytics_and_experimentation_boundaries.md).
## Working Core Loop

```text
Choose or notice a desirable goal
  -> choose an unlocked region / route / habitat
  -> explore and discover a Capture Opportunity
  -> recognize Species / possible variant desirability
  -> validly engage and resolve Capture Attempt
  -> transport the same Provisional Capture through the world
  -> complete extraction at an eligible Secure Point
  -> secure the same Creature Instance
  -> store / display / deliberately assign eligible creatures in the Vault
  -> accrue and claim bounded Energy production
  -> spend Energy on deliberate Vault / capture / access progression
  -> satisfy active Progression Milestones / Region Mastery for major gates
  -> unlock broader world choices and pursue rarer creatures, variants, events and long-term goals
  -> repeat
```

GDS-17 passed the final cross-system audit and the complete Game Design Specification is **Design Complete**. TA-0..17 have subsequently passed their architecture/integration/implementation-lock gates, so implementation is now open under the locked contracts.

## Documentation Authority

Start at [`docs/README.md`](docs/README.md).

### Game Design Specification

[`docs/game_design/`](docs/game_design/) owns intended player-facing behavior.

Key documents include:

- [`00_design_authority.md`](docs/game_design/00_design_authority.md) — governance and Design Complete criteria;
- [`GDS_ROADMAP.md`](docs/game_design/GDS_ROADMAP.md) — dependency-driven phase sequence;
- [`DESIGN_DECISIONS.md`](docs/game_design/DESIGN_DECISIONS.md) — project-wide strategic decisions;
- [`GLOSSARY.md`](docs/game_design/GLOSSARY.md) — canonical gameplay terminology;
- [`product/`](docs/game_design/product/) — GDS-1 product contract;
- [`global_rules/`](docs/game_design/global_rules/) — GDS-2 lifecycle/session contract;
- [`player/`](docs/game_design/player/) — GDS-3 interaction/onboarding contract;
- [`creatures/`](docs/game_design/creatures/) — GDS-4 ownership contract;
- [`capture/`](docs/game_design/capture/) — GDS-5 acquisition contract;
- [`rarity_mutations/`](docs/game_design/rarity_mutations/) — GDS-6 rarity/variant contract;
- [`vault/`](docs/game_design/vault/) — GDS-7 Vault/capacity/production contract;
- [`economy_progression/`](docs/game_design/economy_progression/) — GDS-8 economy/progression contract;
- [`world/`](docs/game_design/world/) — GDS-9 world/exploration/spawning/hazard contract;
- [`social/`](docs/game_design/social/) — GDS-10 social/cooperation/competition/PvP-boundary contract;
- [`events_liveops/`](docs/game_design/events_liveops/) — GDS-11 server-event/dynamic-encounter/live-content contract;
- [`trading/`](docs/game_design/trading/) — GDS-12 trading/player-economy contract;
- [`monetization/`](docs/game_design/monetization/) — GDS-13 monetization/commercial-fairness contract;
- [`presentation/`](docs/game_design/presentation/) — GDS-14 presentation/UI/UX/feedback/accessibility contract;
- [`platform_safety/`](docs/game_design/platform_safety/) — GDS-15 Roblox platform/social-safety/moderation contract;
- [`retention_analytics/`](docs/game_design/retention_analytics/) — GDS-16 retention/discovery/analytics/experimentation contract;
- [`audit/17_cross_system_consistency_and_design_complete_audit.md`](docs/game_design/audit/17_cross_system_consistency_and_design_complete_audit.md) — GDS-17 final integrated audit;
- [`GDS17_AUTHORITY_NAMESPACE_AUDIT.md`](docs/game_design/GDS17_AUTHORITY_NAMESPACE_AUDIT.md) — authority/namespace PASS;
- [`GDS17_MATURITY_OPEN_QUESTION_AUDIT.md`](docs/game_design/GDS17_MATURITY_OPEN_QUESTION_AUDIT.md) — maturity/open-question PASS;
- [`GDS17_COMPOUND_SCENARIO_VALIDATION.md`](docs/game_design/GDS17_COMPOUND_SCENARIO_VALIDATION.md) — 200 compound final scenarios;
- [`GDS17_DECISION_INDEX.md`](docs/game_design/GDS17_DECISION_INDEX.md) — Design Complete promotion decisions;
- [`GDS17_CLOSURE_REPORT.md`](docs/game_design/GDS17_CLOSURE_REPORT.md) — formal final GDS closure evidence.

### Technical Architecture

[`docs/technical_architecture/`](docs/technical_architecture/) is **COMPLETE — TA-17 IMPLEMENTATION LOCKED / IMPLEMENTATION OPEN**.

TA-0 established governance/traceability, TA-1 locked the Roblox environment/toolchain, TA-2 locked structural boundaries, TA-3 locked networking trust, TA-4 locked persistence/session durability, TA-5 locked identity/content registries, TA-6 locked runtime lifecycle, TA-7 locked capture/ownership resolution, TA-8 locked collection/Vault/economy semantics, and TA-9 locked world/spawn/streaming authority. TA-10 locked transient social coordination, global event occurrence/cooldown semantics, cross-server notification/durability boundaries, exact-once event rewards and recoverable multi-profile creature trading. TA-11 locked commercial product identity, MarketplaceService ownership/receipt authority, exact-once grants, entitlement reconciliation and runtime price boundaries. TA-12 locked revision-aware client projection, semantic cross-device input, modal/focus safety, responsive/safe-area UI, accessibility preferences, authoritative feedback, camera/audio/caption and localization boundaries. TA-13 locked non-authoritative versioned telemetry, privacy/cardinality rules, ConfigService-backed validated C2 snapshots, feature rollout/rollback, experiment assignment/exposure/provenance, emergency disable semantics and external least-privilege live-operations audit. TA-14 locked measurable compute, memory, streaming, network, persistence, cross-server, world, client and live-ops budgets with conservative load shedding. TA-15 locked deterministic/static/engine/fault/security/performance verification, public-repository CI trust boundaries and merge/release evidence gates. TA-16 completed the cross-system authority/dependency/risk/readiness audit with zero implementation-critical architecture questions. TA-17 has now locked the toolchain, source/module graph, V1 runtime namespaces, CI/change-control contract, implementation sequence and VS-1 vertical slice; IMP-1 and IMP-2 are complete; IMP-3 is the active implementation dependency.

TA-0 closure evidence:

- [`governance/00_architecture_governance_constraints_and_gds_traceability.md`](docs/technical_architecture/governance/00_architecture_governance_constraints_and_gds_traceability.md);
- [`TA0_GDS_TRACEABILITY_MATRIX.md`](docs/technical_architecture/TA0_GDS_TRACEABILITY_MATRIX.md);
- [`TA0_ARCHITECTURE_RISK_REGISTER.md`](docs/technical_architecture/TA0_ARCHITECTURE_RISK_REGISTER.md);
- [`TA0_SCENARIO_VALIDATION.md`](docs/technical_architecture/TA0_SCENARIO_VALIDATION.md) — 60 / 60 PASS;
- [`TA0_DECISION_INDEX.md`](docs/technical_architecture/TA0_DECISION_INDEX.md);
- [`TA0_CLOSURE_REPORT.md`](docs/technical_architecture/TA0_CLOSURE_REPORT.md) — PASS.
TA-1 closure evidence:

- [`environment/01_roblox_system_context_toolchain_and_development_environment.md`](docs/technical_architecture/environment/01_roblox_system_context_toolchain_and_development_environment.md);
- [`TA1_TOOLCHAIN_SNAPSHOT.md`](docs/technical_architecture/TA1_TOOLCHAIN_SNAPSHOT.md);
- [`TA1_GDS_TRACEABILITY.md`](docs/technical_architecture/TA1_GDS_TRACEABILITY.md);
- [`TA1_SCENARIO_VALIDATION.md`](docs/technical_architecture/TA1_SCENARIO_VALIDATION.md) — 75 / 75 PASS;
- [`TA1_DECISION_INDEX.md`](docs/technical_architecture/TA1_DECISION_INDEX.md);
- [`TA1_CLOSURE_REPORT.md`](docs/technical_architecture/TA1_CLOSURE_REPORT.md) — PASS.
TA-2 closure evidence:

- [`structure/02_repository_layout_module_boundaries_dependency_direction_and_bootstrapping.md`](docs/technical_architecture/structure/02_repository_layout_module_boundaries_dependency_direction_and_bootstrapping.md);
- [`TA2_DEPENDENCY_OWNERSHIP_MATRIX.md`](docs/technical_architecture/TA2_DEPENDENCY_OWNERSHIP_MATRIX.md);
- [`TA2_GDS_TRACEABILITY.md`](docs/technical_architecture/TA2_GDS_TRACEABILITY.md);
- [`TA2_SCENARIO_VALIDATION.md`](docs/technical_architecture/TA2_SCENARIO_VALIDATION.md) — 110 / 110 PASS;
- [`TA2_DECISION_INDEX.md`](docs/technical_architecture/TA2_DECISION_INDEX.md);
- [`TA2_CLOSURE_REPORT.md`](docs/technical_architecture/TA2_CLOSURE_REPORT.md) — PASS.
TA-3 closure evidence:

- [`networking/03_networking_server_authority_remote_contracts_and_exploit_boundaries.md`](docs/technical_architecture/networking/03_networking_server_authority_remote_contracts_and_exploit_boundaries.md);
- [`TA3_ROBLOX_NETWORK_SECURITY_SNAPSHOT.md`](docs/technical_architecture/TA3_ROBLOX_NETWORK_SECURITY_SNAPSHOT.md);
- [`TA3_REMOTE_CONTRACT_MATRIX.md`](docs/technical_architecture/TA3_REMOTE_CONTRACT_MATRIX.md);
- [`TA3_GDS_TRACEABILITY.md`](docs/technical_architecture/TA3_GDS_TRACEABILITY.md);
- [`TA3_SCENARIO_VALIDATION.md`](docs/technical_architecture/TA3_SCENARIO_VALIDATION.md) — 140 / 140 PASS;
- [`TA3_DECISION_INDEX.md`](docs/technical_architecture/TA3_DECISION_INDEX.md);
- [`TA3_CLOSURE_REPORT.md`](docs/technical_architecture/TA3_CLOSURE_REPORT.md) — PASS.
TA-4 closure evidence:

- [`persistence/04_player_data_persistence_session_ownership_schema_evolution_and_recovery.md`](docs/technical_architecture/persistence/04_player_data_persistence_session_ownership_schema_evolution_and_recovery.md);
- [`TA4_ROBLOX_PERSISTENCE_SNAPSHOT.md`](docs/technical_architecture/TA4_ROBLOX_PERSISTENCE_SNAPSHOT.md);
- [`TA4_PERSISTENCE_SESSION_MATRIX.md`](docs/technical_architecture/TA4_PERSISTENCE_SESSION_MATRIX.md);
- [`TA4_GDS_TRACEABILITY.md`](docs/technical_architecture/TA4_GDS_TRACEABILITY.md);
- [`TA4_SCENARIO_VALIDATION.md`](docs/technical_architecture/TA4_SCENARIO_VALIDATION.md) — 180 / 180 PASS;
- [`TA4_DECISION_INDEX.md`](docs/technical_architecture/TA4_DECISION_INDEX.md);
- [`TA4_CLOSURE_REPORT.md`](docs/technical_architecture/TA4_CLOSURE_REPORT.md) — PASS.
TA-5 closure evidence:

- [`content/05_identity_content_registries_configuration_and_data_driven_content.md`](docs/technical_architecture/content/05_identity_content_registries_configuration_and_data_driven_content.md);
- [`TA5_ROBLOX_CONTENT_AUTHORING_SNAPSHOT.md`](docs/technical_architecture/TA5_ROBLOX_CONTENT_AUTHORING_SNAPSHOT.md);
- [`TA5_IDENTITY_REGISTRY_MATRIX.md`](docs/technical_architecture/TA5_IDENTITY_REGISTRY_MATRIX.md);
- [`TA5_GDS_TRACEABILITY.md`](docs/technical_architecture/TA5_GDS_TRACEABILITY.md);
- [`TA5_SCENARIO_VALIDATION.md`](docs/technical_architecture/TA5_SCENARIO_VALIDATION.md) — 180 / 180 PASS;
- [`TA5_DECISION_INDEX.md`](docs/technical_architecture/TA5_DECISION_INDEX.md);
- [`TA5_CLOSURE_REPORT.md`](docs/technical_architecture/TA5_CLOSURE_REPORT.md) — PASS.
TA-6 closure evidence:

- [`runtime/06_runtime_entity_player_creature_and_world_lifecycle.md`](docs/technical_architecture/runtime/06_runtime_entity_player_creature_and_world_lifecycle.md);
- [`TA6_ROBLOX_RUNTIME_LIFECYCLE_SNAPSHOT.md`](docs/technical_architecture/TA6_ROBLOX_RUNTIME_LIFECYCLE_SNAPSHOT.md);
- [`TA6_RUNTIME_LIFECYCLE_MATRIX.md`](docs/technical_architecture/TA6_RUNTIME_LIFECYCLE_MATRIX.md);
- [`TA6_GDS_TRACEABILITY.md`](docs/technical_architecture/TA6_GDS_TRACEABILITY.md);
- [`TA6_SCENARIO_VALIDATION.md`](docs/technical_architecture/TA6_SCENARIO_VALIDATION.md) — 190 / 190 PASS;
- [`TA6_DECISION_INDEX.md`](docs/technical_architecture/TA6_DECISION_INDEX.md);
- [`TA6_CLOSURE_REPORT.md`](docs/technical_architecture/TA6_CLOSURE_REPORT.md) — PASS.
TA-7 closure evidence:

- [`capture/07_capture_creature_ownership_mutation_and_reward_resolution.md`](docs/technical_architecture/capture/07_capture_creature_ownership_mutation_and_reward_resolution.md);
- [`TA7_ROBLOX_CAPTURE_RANDOMNESS_SNAPSHOT.md`](docs/technical_architecture/TA7_ROBLOX_CAPTURE_RANDOMNESS_SNAPSHOT.md);
- [`TA7_CAPTURE_VARIANT_FINALIZATION_MATRIX.md`](docs/technical_architecture/TA7_CAPTURE_VARIANT_FINALIZATION_MATRIX.md);
- [`TA7_GDS_TRACEABILITY.md`](docs/technical_architecture/TA7_GDS_TRACEABILITY.md);
- [`TA7_SCENARIO_VALIDATION.md`](docs/technical_architecture/TA7_SCENARIO_VALIDATION.md) — 200 / 200 PASS;
- [`TA7_DECISION_INDEX.md`](docs/technical_architecture/TA7_DECISION_INDEX.md);
- [`TA7_CLOSURE_REPORT.md`](docs/technical_architecture/TA7_CLOSURE_REPORT.md) — PASS.
TA-8 closure evidence:

- [`economy/08_vault_economy_progression_inventory_and_offline_accrual.md`](docs/technical_architecture/economy/08_vault_economy_progression_inventory_and_offline_accrual.md);
- [`TA8_ROBLOX_ECONOMY_TIME_NUMERIC_SNAPSHOT.md`](docs/technical_architecture/TA8_ROBLOX_ECONOMY_TIME_NUMERIC_SNAPSHOT.md);
- [`TA8_VAULT_ECONOMY_OFFLINE_MATRIX.md`](docs/technical_architecture/TA8_VAULT_ECONOMY_OFFLINE_MATRIX.md);
- [`TA8_GDS_TRACEABILITY.md`](docs/technical_architecture/TA8_GDS_TRACEABILITY.md);
- [`TA8_SCENARIO_VALIDATION.md`](docs/technical_architecture/TA8_SCENARIO_VALIDATION.md) — 220 / 220 PASS;
- [`TA8_DECISION_INDEX.md`](docs/technical_architecture/TA8_DECISION_INDEX.md);
- [`TA8_CLOSURE_REPORT.md`](docs/technical_architecture/TA8_CLOSURE_REPORT.md) — PASS.
TA-9 closure evidence:

- [`world/09_world_biomes_spawn_scheduling_streaming_and_encounter_scaling.md`](docs/technical_architecture/world/09_world_biomes_spawn_scheduling_streaming_and_encounter_scaling.md);
- [`TA9_ROBLOX_WORLD_STREAMING_SPATIAL_SNAPSHOT.md`](docs/technical_architecture/TA9_ROBLOX_WORLD_STREAMING_SPATIAL_SNAPSHOT.md);
- [`TA9_WORLD_SPAWN_STREAMING_MATRIX.md`](docs/technical_architecture/TA9_WORLD_SPAWN_STREAMING_MATRIX.md);
- [`TA9_GDS_TRACEABILITY.md`](docs/technical_architecture/TA9_GDS_TRACEABILITY.md);
- [`TA9_SCENARIO_VALIDATION.md`](docs/technical_architecture/TA9_SCENARIO_VALIDATION.md) — 240 / 240 PASS;
- [`TA9_DECISION_INDEX.md`](docs/technical_architecture/TA9_DECISION_INDEX.md);
- [`TA9_CLOSURE_REPORT.md`](docs/technical_architecture/TA9_CLOSURE_REPORT.md) — PASS.
TA-10 closure evidence:

- [`social_events_trading/10_social_events_cross_server_coordination_and_trading.md`](docs/technical_architecture/social_events_trading/10_social_events_cross_server_coordination_and_trading.md);
- [`TA10_ROBLOX_CROSS_SERVER_TRANSACTION_SNAPSHOT.md`](docs/technical_architecture/TA10_ROBLOX_CROSS_SERVER_TRANSACTION_SNAPSHOT.md);
- [`TA10_SOCIAL_EVENT_TRADE_MATRIX.md`](docs/technical_architecture/TA10_SOCIAL_EVENT_TRADE_MATRIX.md);
- [`TA10_GDS_TRACEABILITY.md`](docs/technical_architecture/TA10_GDS_TRACEABILITY.md);
- [`TA10_SCENARIO_VALIDATION.md`](docs/technical_architecture/TA10_SCENARIO_VALIDATION.md) — 338 / 338 PASS;
- [`TA10_DECISION_INDEX.md`](docs/technical_architecture/TA10_DECISION_INDEX.md);
- [`TA10_CLOSURE_REPORT.md`](docs/technical_architecture/TA10_CLOSURE_REPORT.md) — PASS.
TA-11 closure evidence:

- [`commerce/11_monetization_marketplace_receipts_and_entitlements.md`](docs/technical_architecture/commerce/11_monetization_marketplace_receipts_and_entitlements.md);
- [`TA11_ROBLOX_COMMERCE_PLATFORM_SNAPSHOT.md`](docs/technical_architecture/TA11_ROBLOX_COMMERCE_PLATFORM_SNAPSHOT.md);
- [`TA11_COMMERCE_RECEIPT_ENTITLEMENT_MATRIX.md`](docs/technical_architecture/TA11_COMMERCE_RECEIPT_ENTITLEMENT_MATRIX.md);
- [`TA11_GDS_TRACEABILITY.md`](docs/technical_architecture/TA11_GDS_TRACEABILITY.md);
- [`TA11_SCENARIO_VALIDATION.md`](docs/technical_architecture/TA11_SCENARIO_VALIDATION.md) — 240 / 240 PASS;
- [`TA11_DECISION_INDEX.md`](docs/technical_architecture/TA11_DECISION_INDEX.md);
- [`TA11_CLOSURE_REPORT.md`](docs/technical_architecture/TA11_CLOSURE_REPORT.md) — PASS.
TA-12 closure evidence:

- [`client/12_client_presentation_ui_input_camera_audio_and_accessibility.md`](docs/technical_architecture/client/12_client_presentation_ui_input_camera_audio_and_accessibility.md);
- [`TA12_ROBLOX_CLIENT_ACCESSIBILITY_PLATFORM_SNAPSHOT.md`](docs/technical_architecture/TA12_ROBLOX_CLIENT_ACCESSIBILITY_PLATFORM_SNAPSHOT.md);
- [`TA12_CLIENT_PRESENTATION_INPUT_ACCESSIBILITY_MATRIX.md`](docs/technical_architecture/TA12_CLIENT_PRESENTATION_INPUT_ACCESSIBILITY_MATRIX.md);
- [`TA12_GDS_TRACEABILITY.md`](docs/technical_architecture/TA12_GDS_TRACEABILITY.md);
- [`TA12_SCENARIO_VALIDATION.md`](docs/technical_architecture/TA12_SCENARIO_VALIDATION.md) — 300 / 300 PASS;
- [`TA12_DECISION_INDEX.md`](docs/technical_architecture/TA12_DECISION_INDEX.md);
- [`TA12_CLOSURE_REPORT.md`](docs/technical_architecture/TA12_CLOSURE_REPORT.md) — PASS.
TA-13 closure evidence:

- [`operations/13_analytics_telemetry_feature_flags_configuration_rollouts_and_live_operations.md`](docs/technical_architecture/operations/13_analytics_telemetry_feature_flags_configuration_rollouts_and_live_operations.md);
- [`TA13_ROBLOX_ANALYTICS_CONFIG_LIVEOPS_PLATFORM_SNAPSHOT.md`](docs/technical_architecture/TA13_ROBLOX_ANALYTICS_CONFIG_LIVEOPS_PLATFORM_SNAPSHOT.md);
- [`TA13_ANALYTICS_CONFIG_LIVEOPS_MATRIX.md`](docs/technical_architecture/TA13_ANALYTICS_CONFIG_LIVEOPS_MATRIX.md);
- [`TA13_GDS_TRACEABILITY.md`](docs/technical_architecture/TA13_GDS_TRACEABILITY.md);
- [`TA13_SCENARIO_VALIDATION.md`](docs/technical_architecture/TA13_SCENARIO_VALIDATION.md) — 260 / 260 PASS;
- [`TA13_DECISION_INDEX.md`](docs/technical_architecture/TA13_DECISION_INDEX.md);
- [`TA13_CLOSURE_REPORT.md`](docs/technical_architecture/TA13_CLOSURE_REPORT.md) — PASS.
TA-14 closure evidence:

- [`performance/14_performance_network_memory_persistence_and_scalability_budgets.md`](docs/technical_architecture/performance/14_performance_network_memory_persistence_and_scalability_budgets.md);
- [`TA14_ROBLOX_PERFORMANCE_SCALABILITY_PLATFORM_SNAPSHOT.md`](docs/technical_architecture/TA14_ROBLOX_PERFORMANCE_SCALABILITY_PLATFORM_SNAPSHOT.md);
- [`TA14_PERFORMANCE_SCALABILITY_BUDGET_MATRIX.md`](docs/technical_architecture/TA14_PERFORMANCE_SCALABILITY_BUDGET_MATRIX.md);
- [`TA14_GDS_TRACEABILITY.md`](docs/technical_architecture/TA14_GDS_TRACEABILITY.md);
- [`TA14_SCENARIO_VALIDATION.md`](docs/technical_architecture/TA14_SCENARIO_VALIDATION.md) — 300 / 300 PASS;
- [`TA14_DECISION_INDEX.md`](docs/technical_architecture/TA14_DECISION_INDEX.md);
- [`TA14_CLOSURE_REPORT.md`](docs/technical_architecture/TA14_CLOSURE_REPORT.md) — PASS.

TA-15 closure evidence:

- [`verification/15_testing_diagnostics_security_validation_and_ci_architecture.md`](docs/technical_architecture/verification/15_testing_diagnostics_security_validation_and_ci_architecture.md);
- [`TA15_ROBLOX_TESTING_SECURITY_CI_PLATFORM_SNAPSHOT.md`](docs/technical_architecture/TA15_ROBLOX_TESTING_SECURITY_CI_PLATFORM_SNAPSHOT.md);
- [`TA15_VERIFICATION_QUALITY_GATE_MATRIX.md`](docs/technical_architecture/TA15_VERIFICATION_QUALITY_GATE_MATRIX.md);
- [`TA15_GDS_TRACEABILITY.md`](docs/technical_architecture/TA15_GDS_TRACEABILITY.md);
- [`TA15_SCENARIO_VALIDATION.md`](docs/technical_architecture/TA15_SCENARIO_VALIDATION.md) — 360 / 360 PASS;
- [`TA15_DECISION_INDEX.md`](docs/technical_architecture/TA15_DECISION_INDEX.md);
- [`TA15_CLOSURE_REPORT.md`](docs/technical_architecture/TA15_CLOSURE_REPORT.md) — PASS.

TA-16 closure evidence:

- [`audit/16_architecture_integration_and_implementation_readiness_audit.md`](docs/technical_architecture/audit/16_architecture_integration_and_implementation_readiness_audit.md);
- [`TA16_AUTHORITY_DEPENDENCY_AUDIT.md`](docs/technical_architecture/TA16_AUTHORITY_DEPENDENCY_AUDIT.md);
- [`TA16_RISK_CLOSURE_REGISTER.md`](docs/technical_architecture/TA16_RISK_CLOSURE_REGISTER.md);
- [`TA16_IMPLEMENTATION_READINESS_MATRIX.md`](docs/technical_architecture/TA16_IMPLEMENTATION_READINESS_MATRIX.md);
- [`TA16_MATURITY_OPEN_QUESTION_AUDIT.md`](docs/technical_architecture/TA16_MATURITY_OPEN_QUESTION_AUDIT.md);
- [`TA16_COMPOUND_SCENARIO_VALIDATION.md`](docs/technical_architecture/TA16_COMPOUND_SCENARIO_VALIDATION.md) — 240 / 240 PASS;
- [`TA16_DECISION_INDEX.md`](docs/technical_architecture/TA16_DECISION_INDEX.md);
- [`TA16_CLOSURE_REPORT.md`](docs/technical_architecture/TA16_CLOSURE_REPORT.md) — PASS.

TA-17 closure evidence:

- [`implementation/17_implementation_roadmap_vertical_slice_contract_locking_and_change_control.md`](docs/technical_architecture/implementation/17_implementation_roadmap_vertical_slice_contract_locking_and_change_control.md);
- [`TA17_TOOLCHAIN_ENVIRONMENT_LOCK.md`](docs/technical_architecture/TA17_TOOLCHAIN_ENVIRONMENT_LOCK.md);
- [`TA17_MODULE_SERVICE_GRAPH.md`](docs/technical_architecture/TA17_MODULE_SERVICE_GRAPH.md);
- [`TA17_RUNTIME_NAMESPACE_CONTRACT.md`](docs/technical_architecture/TA17_RUNTIME_NAMESPACE_CONTRACT.md);
- [`TA17_VERTICAL_SLICE_ACCEPTANCE_MATRIX.md`](docs/technical_architecture/TA17_VERTICAL_SLICE_ACCEPTANCE_MATRIX.md);
- [`TA17_IMPLEMENTATION_TRACEABILITY.md`](docs/technical_architecture/TA17_IMPLEMENTATION_TRACEABILITY.md);
- [`TA17_CI_RELEASE_CHANGE_CONTROL.md`](docs/technical_architecture/TA17_CI_RELEASE_CHANGE_CONTROL.md);
- [`TA17_SCENARIO_VALIDATION.md`](docs/technical_architecture/TA17_SCENARIO_VALIDATION.md) — 180 / 180 PASS;
- [`TA17_DECISION_INDEX.md`](docs/technical_architecture/TA17_DECISION_INDEX.md);
- [`TA17_CLOSURE_REPORT.md`](docs/technical_architecture/TA17_CLOSURE_REPORT.md) — IMPLEMENTATION OPEN.

### Implementation

[`docs/implementation/`](docs/implementation/) is **OPEN** under the TA-17 implementation lock.

The active dependency is **IMP-3 — Profile Session Foundation**. Production release remains gated by the downstream implementation phases and TA-15/TA-14 evidence.

## Repository Structure

```text
Project-MonsterVault/
├── README.md
├── docs/
│   ├── README.md
│   ├── game_design/
│   │   ├── 00_design_authority.md
│   │   ├── product/
│   │   ├── global_rules/
│   │   ├── player/
│   │   ├── creatures/
│   │   ├── capture/
│   │   ├── rarity_mutations/
│   │   ├── vault/
│   │   ├── economy_progression/
│   │   ├── world/
│   │   ├── social/
│   │   ├── events_liveops/
│   │   ├── trading/
│   │   ├── monetization/
│   │   ├── presentation/
│   │   ├── platform_safety/
│   │   ├── retention_analytics/
│   │   ├── GDS_ROADMAP.md
│   │   ├── GLOSSARY.md
│   │   ├── audit/
│   │   ├── GDS17_AUTHORITY_NAMESPACE_AUDIT.md
│   │   ├── GDS17_MATURITY_OPEN_QUESTION_AUDIT.md
│   │   ├── GDS17_COMPOUND_SCENARIO_VALIDATION.md
│   │   ├── GDS17_DECISION_INDEX.md
│   │   └── GDS17_CLOSURE_REPORT.md
│   ├── technical_architecture/
│   ├── implementation/
│   └── history/
├── src/                         # TA-17 locked runtime roots; scaffold created
│   ├── server/                  # -> ServerScriptService/MonsterVaultServer
│   ├── client/                  # -> StarterPlayerScripts/MonsterVaultClient
│   └── shared/                  # -> ReplicatedStorage/MonsterVault/Shared
├── tests/                       # unit / integration / scenarios / fixtures
├── assets/
└── scripts/                     # developer/CI/release tooling only
```

TA-17 created the non-gameplay source/test scaffold and locked the implementation graph. IMP-1 added the contracts and test harness, and IMP-2 added composition and diagnostics; runtime modules continue dependency-by-dependency with IMP-3.

## Current Next Step

Proceed with **IMP-3 — Profile Session Foundation**.

The first implementation vertical slice is locked as **VS-1 — Trusted Join → One World Creature → Capture → Secure Ownership → Rejoin**.

## License

No open-source license is currently granted. All rights are reserved unless explicitly stated otherwise.
