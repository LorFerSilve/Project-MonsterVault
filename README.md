# Monster Vault

> A data-driven multiplayer creature-collection and progression game built on Roblox.

## Project Status

**Game Design Specification — DESIGN COMPLETE / Technical Architecture TA-0..2 complete / TA-3 next.**

MonsterVault is intentionally **not in gameplay implementation yet**. The project follows a specification-first workflow:

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
- **TA-3 — Networking, Server Authority, Remote Contracts, and Exploit Boundaries: NEXT**
- Gameplay implementation: blocked by TA and implementation-lock gates

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

GDS-17 has passed the final cross-system audit. The complete Game Design Specification is **Design Complete** with zero implementation-critical open design questions. Technical Architecture is now open at TA-0; gameplay implementation remains blocked.

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

[`docs/technical_architecture/`](docs/technical_architecture/) is **ACTIVE — TA-0..2 COMPLETE / TA-3 NEXT**.

TA-0 established architecture governance and traceability. TA-1 locked the Roblox environment/toolchain baseline. TA-2 has now locked the future server/client/shared Rojo mapping, modular-monolith module boundaries, application/domain/infrastructure dependency direction and explicit bootstrap lifecycle. TA-3 now owns networking, remote contracts and exploit boundaries.

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
### Implementation

[`docs/implementation/`](docs/implementation/) remains intentionally **BLOCKED**.

Gameplay implementation opens only after the complete GDS and Technical Architecture gates are passed and the final architecture phase locks the implementation roadmap and exact vertical slice.

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
├── src/                         # TA-2 locked future runtime roots; created at TA-17
│   ├── server/                  # -> ServerScriptService/MonsterVaultServer
│   ├── client/                  # -> StarterPlayerScripts/MonsterVaultClient
│   └── shared/                  # -> ReplicatedStorage/MonsterVault/Shared
├── tests/                       # unit / integration / scenarios / fixtures
├── assets/
└── scripts/                     # developer/CI/release tooling only
```

TA-2 has locked this as the future implementation structure, but the source scaffold remains intentionally uncreated until TA-17 opens implementation.

## Current Next Step

Proceed with **TA-3 — Networking, Server Authority, Remote Contracts, and Exploit Boundaries**.

The first implementation vertical slice will be selected and locked only after the complete design and architecture dependency chain makes its requirements clear.

## License

No open-source license is currently granted. All rights are reserved unless explicitly stated otherwise.
