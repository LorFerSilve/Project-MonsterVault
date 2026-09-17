# Monster Vault

> A data-driven multiplayer creature-collection and progression game built on Roblox.

## Project Status

**Pre-implementation specification — GDS-0 through GDS-5 complete / GDS-6 next.**

MonsterVault is intentionally **not in gameplay implementation yet**. The project follows a specification-first workflow modeled after Project StarForge:

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
- **GDS-6 — Rarity, Mutations, Traits, and Variant Value: NEXT**
- GDS-7 through GDS-16: Draft / dependency-ordered
- GDS-17: blocked until subsystem design is complete
- Technical Architecture: blocked by GDS-17
- Gameplay implementation: blocked by GDS and TA gates

GDS-5 closure evidence is recorded in [`GDS5_SCENARIO_VALIDATION.md`](docs/game_design/GDS5_SCENARIO_VALIDATION.md), [`GDS5_CROSS_VALIDATION.md`](docs/game_design/GDS5_CROSS_VALIDATION.md), and [`GDS5_CLOSURE_REPORT.md`](docs/game_design/GDS5_CLOSURE_REPORT.md).

## Product Contract

MonsterVault is formally defined at product level as a **social creature-collection and progression adventure** with the promise:

> **Find it. Catch it. Bring it home. Make your vault legendary.**

The high-level product contract includes:

- primary audience around ages **9–15**, with older collection/optimization players as a secondary audience;
- mobile-first interaction constraints with cross-platform gameplay parity;
- core progression that does not depend on unrestricted chat or voice;
- active exploration/capture instead of primarily menu/idle acquisition;
- persistent visible collection/vault progression;
- rarity and mutation/variant hunting;
- server-level social opportunities;
- socially competitive but **non-loss-dominant** play;
- no baseline requirement for unrestricted theft of secured persistent creatures;
- no direct-combat PvP requirement;
- normal sessions around **10–25 minutes**, while short 3–5 minute sessions remain meaningful;
- aggressive time-to-fun targets in the first minutes;
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
- late joining an already-running server is normal;
- offline progression is optional rather than assumed;
- persistent timers/global windows do not implicitly restart on server transition;
- lifecycle semantics are consistent across supported device classes.

## Player Interaction and Onboarding Contract

GDS-3 locks the player-control/onboarding baseline:

- third-person character-centric exploration;
- familiar continuous movement and jump without a universal stamina tax;
- equivalent baseline capability on touch, keyboard/mouse, and controller;
- universal **Primary Interact** plus downstream-tool **Primary Action** semantics;
- one deterministic visible **Active Context** at a time;
- gameplay-first onboarding with persistent **Onboarding Milestones**;
- **Safe Arrival** after trusted persistence readiness;
- reset/failure/stuck **Recovery** that does not automatically extract transient value;
- semantic accessibility constraints before final presentation work.

## Creature Collection and Ownership Contract

GDS-4 locks the persistent collectible model:

- **Species** is an authored archetype; player ownership concerns specific **Creature Instances**;
- every **Secured Creature** has stable persistent individual identity;
- one secured instance has one ordinary owner at a time;
- GDS-5 owns the exact **Secured Ownership Finalization** trigger; GDS-4 owns the persistent consequences after it;
- a player's **Collection Registry** tracks specific secured instances rather than only species counts;
- duplicates are valid distinct owned creatures and are not automatically merged/deleted;
- moving creatures among Active, Stored, display, or vault roles does not change ownership;
- full or reduced capacity cannot silently delete secured creatures;
- when ownership finalizes without ordinary eligible capacity, the creature is safely **Overflow-Held** with restricted use until capacity is resolved;
- voluntary permanent **Release** requires explicit intent;
- **Creature Lock** protects against voluntary destructive/future transfer actions;
- ordinary session lifecycle, death, capacity changes, or another player's proximity do not cause involuntary loss of secured creatures;
- **Species Discovery** persists historically even if the last current instance is later released;
- provenance/history can remain attached to individual instances;
- future trading must operate through explicit ownership-transfer authority rather than informal dropping/lending.

The authoritative GDS-4 specification is [`04_creatures_collection_and_ownership.md`](docs/game_design/creatures/04_creatures_collection_and_ownership.md).

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

The resulting contract includes:

- Capture Eligibility is player-specific and revalidated on initiation;
- a normal single-award creature has at most one bounded active **Engagement Claim**;
- ordinary contesting is the race to validly engage before another active claim exists;
- active claims cannot be overwritten by later proximity/input and cannot be held indefinitely through inactivity/cycling;
- Capture Challenges preserve touch/keyboard/controller capability parity and avoid precision-only/button-mash requirements;
- **Capture Success creates a Provisional Capture, not persistent ownership**;
- the same specific Creature Instance is preserved through transport and finalization;
- ordinary baseline transport permits one active **Transport Custody** per player;
- normal Transport Custody cannot be directly stolen merely through proximity or baseline PvP;
- reset/Recovery and voluntary server leave do not count as extraction;
- unexpected disconnect with valid custody enters bounded same-server **Transport Grace**; reconnect within grace resumes the same provisional custody and grace expiry ends it without ownership;
- an orderly authoritative server-originated shutdown performs exact-once **Protected Shutdown Finalization** for valid provisional custody while authoritative state remains available; abrupt unverifiable process failure cannot promise that exception;
- validated **Extraction Completion at an eligible Secure Point** is the ordinary `Secured Ownership Finalization` boundary;
- one finite ordinary creature finalizes for one player exactly once;
- known full capacity/unresolved overflow blocks new ordinary capture initiation;
- a late capacity race cannot delete a completed acquisition because GDS-4 Overflow-Held absorbs the integrity case;
- the first required capture uses an **Onboarding-Protected Opportunity** so unrelated players cannot deny the learning path.

The authoritative GDS-5 specification is [`05_capture_contesting_transport_and_extraction.md`](docs/game_design/capture/05_capture_contesting_transport_and_extraction.md).

## Working Core Loop

```text
Choose or notice a desirable goal
  -> explore
  -> discover a Capture Opportunity
  -> validly engage / establish an Engagement Claim
  -> resolve a Capture Attempt
  -> transport the Provisional Capture
  -> complete extraction at a Secure Point
  -> add the same Creature Instance to persistent collection
  -> improve capability / capacity / access / status
  -> pursue rarer content / events / regions
  -> repeat
```

The exact rarity tiers/mutations, capture modifiers, vault production, economy, world spawning/hazards, optional social interception/PvP, event-specific capture overrides, trading, monetization, presentation, and technical implementation remain subject to their owning later phases.

## Documentation Authority

Start at [`docs/README.md`](docs/README.md).

### Game Design Specification

[`docs/game_design/`](docs/game_design/) owns intended player-facing behavior.

Key documents include:

- [`00_design_authority.md`](docs/game_design/00_design_authority.md) — governance and Design Complete criteria;
- [`01_game_overview.md`](docs/game_design/01_game_overview.md) — product overview;
- [`product/`](docs/game_design/product/) — GDS-1 product contract;
- [`global_rules/`](docs/game_design/global_rules/) — GDS-2 lifecycle/session contract;
- [`player/`](docs/game_design/player/) — GDS-3 player interaction/onboarding contract;
- [`creatures/`](docs/game_design/creatures/) — GDS-4 creature/collection/ownership contract;
- [`capture/`](docs/game_design/capture/) — GDS-5 acquisition/contesting/transport/extraction contract;
- [`GDS_ROADMAP.md`](docs/game_design/GDS_ROADMAP.md) — dependency-driven phase sequence;
- [`DESIGN_DECISIONS.md`](docs/game_design/DESIGN_DECISIONS.md) — strategic design decisions;
- [`GLOSSARY.md`](docs/game_design/GLOSSARY.md) — canonical gameplay terminology;
- [`GDS5_SCENARIO_VALIDATION.md`](docs/game_design/GDS5_SCENARIO_VALIDATION.md) — compound GDS-5 validation;
- [`GDS5_CROSS_VALIDATION.md`](docs/game_design/GDS5_CROSS_VALIDATION.md) — authority/consistency audit;
- [`GDS5_CLOSURE_REPORT.md`](docs/game_design/GDS5_CLOSURE_REPORT.md) — formal GDS-5 closure evidence.

### Technical Architecture

[`docs/technical_architecture/`](docs/technical_architecture/) remains **blocked by GDS completion**.

Technical Architecture will later translate approved GDS behavior into concrete Roblox/Luau contracts for identity, persistence, networking, runtime lifecycle, player controls, capture/creature systems, economy, trading, UI, live operations, performance, testing and CI.

### Implementation

[`docs/implementation/`](docs/implementation/) remains intentionally **BLOCKED**.

Gameplay implementation opens only after the complete GDS and Technical Architecture gates are passed and the final architecture phase locks the implementation roadmap and exact vertical slice.

## Repository Structure

```text
Project-MonsterVault/
├── README.md
├── .gitignore
├── docs/
│   ├── README.md
│   ├── game_design/
│   │   ├── 00_design_authority.md
│   │   ├── 01_game_overview.md
│   │   ├── product/
│   │   ├── global_rules/
│   │   ├── player/
│   │   ├── creatures/
│   │   ├── capture/
│   │   ├── GDS_ROADMAP.md
│   │   ├── DESIGN_DECISIONS.md
│   │   ├── GDS5_SCENARIO_VALIDATION.md
│   │   ├── GDS5_CROSS_VALIDATION.md
│   │   ├── GDS5_CLOSURE_REPORT.md
│   │   ├── <remaining design domains>/
│   │   └── audit/
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

Proceed with **GDS-6 — Rarity, Mutations, Traits, and Variant Value**.

The first implementation vertical slice will be selected and locked only after the complete design and architecture dependency chain makes its requirements clear.

## License

No open-source license is currently granted. This repository is private and all rights are reserved unless explicitly stated otherwise.
