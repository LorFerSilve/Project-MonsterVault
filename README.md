# Monster Vault

> A data-driven multiplayer creature-collection and progression game built on Roblox.

## Project Status

**Pre-implementation specification — GDS-0 through GDS-5 complete / GDS-6 next.**

MonsterVault is intentionally **not in gameplay implementation yet**. The project follows a specification-first workflow:

```text
Game Design Specification (GDS)
  -> cross-system design audit
  -> Technical Architecture (TA)
  -> architecture integration audit
  -> implementation roadmap + contract locking
  -> gameplay implementation
```

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

MonsterVault is a **social creature-collection and progression adventure** with the promise:

> **Find it. Catch it. Bring it home. Make your vault legendary.**

The product is mobile-first with cross-platform gameplay parity, active world acquisition, persistent visible collection/vault progression, rarity/variant hunting, server-level social opportunities, non-loss-dominant competition, flexible short/normal/extended sessions, moderate non-coercive monetization, deferred safe trading, and live-content extensibility.

## Global Lifecycle Contract — GDS-2

- server sessions are temporary runtime contexts, not owners of long-term progression;
- irreversible gameplay waits for trusted persistent state;
- Protected Load Failure replaces unsafe blank-profile play;
- Finalized Outcomes apply once;
- Recovery does not imply a persistent wipe;
- secured progress survives ordinary avatar/session/device lifecycle;
- cross-server/offline timing semantics are explicit rather than assumed.

## Player Interaction and Onboarding Contract — GDS-3

- third-person familiar movement/camera baseline;
- equivalent touch, keyboard/mouse, and controller capabilities;
- universal **Primary Interact** and **Primary Action** semantics;
- one deterministic visible **Active Context** at a time;
- gameplay-first persistent onboarding;
- Safe Arrival and non-extractive Recovery;
- semantic accessibility constraints before final presentation work.

## Creature Collection and Ownership Contract — GDS-4

- player ownership concerns specific persistent **Creature Instances**, not fungible Species counts;
- one Secured Creature has one ordinary owner at a time;
- duplicates remain individually addressable;
- the Collection Registry tracks specific secured instances;
- capacity changes cannot silently delete secured creatures;
- race-condition over-capacity finalization uses restricted **Overflow-Held** safety;
- Release is explicit and protected by **Creature Lock**;
- Species Discovery is historical;
- Provenance belongs to the instance;
- future ownership transfer requires explicit transaction authority.

## Capture, Contesting, Transport, and Extraction Contract — GDS-5

The ordinary acquisition loop is now locked as:

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

Key consequences:

- ordinary single-award capture uses one bounded active **Engagement Claim**;
- contesting is primarily the race to validly engage before another active claim;
- Capture Success is **provisional**, not immediate persistent ownership;
- the same specific Creature Instance is preserved through transport/finalization;
- baseline ordinary transport permits one active Provisional Capture per player;
- other players cannot directly steal normal Transport Custody merely by proximity/input;
- reset/Recovery and voluntary leave do not count as extraction;
- unexpected disconnect may receive bounded same-server **Transport Grace**;
- authoritative server-originated shutdown may use exact-once **Protected Shutdown Finalization** for an already valid Provisional Capture;
- ordinary persistent ownership begins exactly at validated **Extraction Completion**;
- known full capacity/unresolved overflow blocks ordinary new capture initiation;
- if capacity becomes unavailable after a valid attempt begins, finalization remains safe through GDS-4 Overflow-Held;
- onboarding uses an **Onboarding-Protected Opportunity** so other players cannot deny the learner's first required capture;
- normal finite creatures finalize for one player exactly once.

The authoritative specification is [`05_capture_contesting_transport_and_extraction.md`](docs/game_design/capture/05_capture_contesting_transport_and_extraction.md).

## Working Core Loop

```text
Choose or notice a desirable goal
  -> explore
  -> discover a Capture Opportunity
  -> establish/earn an Engagement Claim
  -> resolve a Capture Attempt
  -> transport the Provisional Capture
  -> complete extraction at a Secure Point
  -> add the same Creature Instance to persistent collection
  -> improve capability / capacity / access / status
  -> pursue rarer content / events / regions
  -> repeat
```

Rarity tiers, mutation generation, exact capture modifiers, vault production, economy, world spawning/hazards, optional social interception, event overrides, trading, monetization, presentation, and implementation remain subject to later owning phases.

## Documentation Authority

Start at [`docs/README.md`](docs/README.md).

Key game-design documents include:

- [`docs/game_design/00_design_authority.md`](docs/game_design/00_design_authority.md);
- [`docs/game_design/01_game_overview.md`](docs/game_design/01_game_overview.md);
- [`docs/game_design/GDS_ROADMAP.md`](docs/game_design/GDS_ROADMAP.md);
- [`docs/game_design/DESIGN_DECISIONS.md`](docs/game_design/DESIGN_DECISIONS.md);
- [`docs/game_design/GLOSSARY.md`](docs/game_design/GLOSSARY.md);
- [`docs/game_design/product/`](docs/game_design/product/);
- [`docs/game_design/global_rules/`](docs/game_design/global_rules/);
- [`docs/game_design/player/`](docs/game_design/player/);
- [`docs/game_design/creatures/`](docs/game_design/creatures/);
- [`docs/game_design/capture/`](docs/game_design/capture/);
- [`docs/game_design/GDS5_SCENARIO_VALIDATION.md`](docs/game_design/GDS5_SCENARIO_VALIDATION.md);
- [`docs/game_design/GDS5_CROSS_VALIDATION.md`](docs/game_design/GDS5_CROSS_VALIDATION.md);
- [`docs/game_design/GDS5_CLOSURE_REPORT.md`](docs/game_design/GDS5_CLOSURE_REPORT.md).

### Technical Architecture

[`docs/technical_architecture/`](docs/technical_architecture/) remains **blocked by GDS completion**.

### Implementation

[`docs/implementation/`](docs/implementation/) remains intentionally **BLOCKED**.

Source/test/tooling directories may exist as scaffolding; their existence does not open the gameplay implementation gate.

## Current Next Step

Proceed with **GDS-6 — Rarity, Mutations, Traits, and Variant Value**.

The first implementation vertical slice will be selected and locked only after the complete design and architecture dependency chain makes its requirements clear.

## License

No open-source license is currently granted. This repository is private and all rights are reserved unless explicitly stated otherwise.
