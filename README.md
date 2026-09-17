# Monster Vault

> A data-driven multiplayer creature-collection and progression game built on Roblox.

## Project Status

**Pre-implementation specification — GDS-0 through GDS-10 complete / GDS-11 next.**

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
- **GDS-11 — Server Events, Dynamic Encounters, and Live Content: NEXT**
- GDS-12 through GDS-16: Draft / dependency-ordered
- GDS-17: blocked until subsystem design is complete
- Technical Architecture: blocked by GDS-17
- Gameplay implementation: blocked by GDS and TA gates

GDS-10 closure evidence is recorded in [`GDS10_SCENARIO_VALIDATION.md`](docs/game_design/GDS10_SCENARIO_VALIDATION.md), [`GDS10_CROSS_VALIDATION.md`](docs/game_design/GDS10_CROSS_VALIDATION.md), [`GDS10_DECISION_INDEX.md`](docs/game_design/GDS10_DECISION_INDEX.md), and [`GDS10_CLOSURE_REPORT.md`](docs/game_design/GDS10_CLOSURE_REPORT.md).

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

Server events, dynamic encounters and live content now belong to GDS-11. Trading, monetization, final presentation, analytics, platform constraints, and technical implementation remain subject to their owning later phases.

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
- [`GDS10_SCENARIO_VALIDATION.md`](docs/game_design/GDS10_SCENARIO_VALIDATION.md) — 110 compound GDS-10 scenarios;
- [`GDS10_CROSS_VALIDATION.md`](docs/game_design/GDS10_CROSS_VALIDATION.md) — authority/consistency audit;
- [`GDS10_DECISION_INDEX.md`](docs/game_design/GDS10_DECISION_INDEX.md) — phase-local strategic decisions;
- [`GDS10_CLOSURE_REPORT.md`](docs/game_design/GDS10_CLOSURE_REPORT.md) — formal GDS-10 closure evidence.

### Technical Architecture

[`docs/technical_architecture/`](docs/technical_architecture/) remains **blocked by GDS completion**.

Technical Architecture will later translate approved GDS behavior into concrete Roblox/Luau contracts for identity, persistence, networking, runtime lifecycle, controls, creature/capture/variant/Vault/economy/world/social systems, trading, UI, live operations, performance, testing and CI.

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
│   │   ├── GDS_ROADMAP.md
│   │   ├── GLOSSARY.md
│   │   ├── GDS10_SCENARIO_VALIDATION.md
│   │   ├── GDS10_CROSS_VALIDATION.md
│   │   ├── GDS10_DECISION_INDEX.md
│   │   ├── GDS10_CLOSURE_REPORT.md
│   │   └── <remaining design domains>/
│   ├── technical_architecture/
│   ├── implementation/
│   └── history/
├── src/
├── tests/
├── assets/
└── scripts/
```

The source/test/tooling directories are reserved for later implementation. Their existence does **not** mean the implementation gate is open.

## Current Next Step

Proceed with **GDS-11 — Server Events, Dynamic Encounters, and Live Content**.

The first implementation vertical slice will be selected and locked only after the complete design and architecture dependency chain makes its requirements clear.

## License

No open-source license is currently granted. All rights are reserved unless explicitly stated otherwise.
