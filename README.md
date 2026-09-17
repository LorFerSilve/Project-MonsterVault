# Monster Vault

> A data-driven multiplayer creature-collection and progression game built on Roblox.

## Project Status

**Pre-implementation specification — GDS-0 through GDS-3 complete / GDS-4 next.**

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
- **GDS-4 — Creatures, Collection, and Ownership: NEXT**
- GDS-5 through GDS-16: Draft / dependency-ordered
- GDS-17: blocked until subsystem design is complete
- Technical Architecture: blocked by GDS-17
- Gameplay implementation: blocked by GDS and TA gates

GDS-3 closure evidence is recorded in [`GDS3_SCENARIO_VALIDATION.md`](docs/game_design/GDS3_SCENARIO_VALIDATION.md), [`GDS3_CROSS_VALIDATION.md`](docs/game_design/GDS3_CROSS_VALIDATION.md), and [`GDS3_CLOSURE_REPORT.md`](docs/game_design/GDS3_CLOSURE_REPORT.md).

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
- ordinary disconnect is neutral for secured persistent value;
- failure/reset invokes Recovery rather than a global persistent wipe;
- late joining an already-running server is normal;
- offline progression is optional rather than assumed;
- persistent timers/global windows do not implicitly restart on server transition;
- lifecycle semantics are consistent across supported device classes.

The authoritative global-rules specification is [`02_global_game_rules_and_session_model.md`](docs/game_design/global_rules/02_global_game_rules_and_session_model.md).

## Player Interaction and Onboarding Contract

GDS-3 now locks the project-wide player-control/onboarding baseline:

- baseline exploration is third-person and character-centric;
- ordinary locomotion uses familiar continuous movement plus conventional jump;
- basic movement has no universal stamina tax;
- touch, keyboard/mouse, and controller expose equivalent core capabilities;
- contextual world interactions use one **Primary Interact** semantic;
- active tools/mechanics use a cross-device **Primary Action** semantic where applicable;
- only one visible **Active Context** is immediately actionable at a time;
- context is revalidated on activation and modal input cannot spill into accidental world actions;
- first-session onboarding is gameplay-first and progressive, aligned to GDS-1 time-to-fun targets;
- **Onboarding Milestones** persist/resume across normal disconnect/server changes;
- the **Guidance Layer** may be skipped/replayed without fabricating progression or duplicating rewards;
- a valid first learning path must remain available despite normal multiplayer/server variation;
- **Safe Arrival** bridges Persistence Ready into direct ordinary play;
- reset/failure/stuck states use **Recovery** to a valid Recovery Anchor;
- Recovery does not automatically secure transient value or act as a universal extraction shortcut;
- progression-critical interaction cannot depend solely on color, audio, precision aim, rapid tapping, free-form chat, or drag-and-drop-only input.

The authoritative GDS-3 specification is [`03_player_character_interaction_and_onboarding.md`](docs/game_design/player/03_player_character_interaction_and_onboarding.md).

## Working Core Loop

```text
Choose or notice a desirable goal
  -> explore
  -> discover a creature/opportunity
  -> attempt capture
  -> secure / return acquired value
  -> add to collection / vault progression
  -> improve capability / capacity / access / status
  -> pursue rarer content / events / regions
  -> repeat
```

The exact creature ownership model, capture rules, ownership-transfer point, economy, rarity probabilities, transport rules, social contesting, event structure, trading design, and monetization products remain subject to their owning later GDS phases.

## Documentation Authority

Start at [`docs/README.md`](docs/README.md).

### Game Design Specification

[`docs/game_design/`](docs/game_design/) owns intended player-facing behavior.

Key documents:

- [`00_design_authority.md`](docs/game_design/00_design_authority.md) — governance, status model and definition of Design Complete;
- [`01_game_overview.md`](docs/game_design/01_game_overview.md) — Design Complete high-level product overview;
- [`product/`](docs/game_design/product/) — GDS-1 audience, positioning, session, scope and success specifications;
- [`global_rules/`](docs/game_design/global_rules/) — GDS-2 global session/lifecycle rules;
- [`player/`](docs/game_design/player/) — GDS-3 player interaction/onboarding rules;
- [`GDS_ROADMAP.md`](docs/game_design/GDS_ROADMAP.md) — dependency-driven GDS-0 through GDS-17 sequence;
- [`DESIGN_DECISIONS.md`](docs/game_design/DESIGN_DECISIONS.md) — strategic design decisions and rationale;
- [`GLOSSARY.md`](docs/game_design/GLOSSARY.md) — canonical shared gameplay terminology;
- [`GDS3_SCENARIO_VALIDATION.md`](docs/game_design/GDS3_SCENARIO_VALIDATION.md) — compound interaction/onboarding validation;
- [`GDS3_CROSS_VALIDATION.md`](docs/game_design/GDS3_CROSS_VALIDATION.md) — formal GDS-3 cross-validation;
- [`GDS3_CLOSURE_REPORT.md`](docs/game_design/GDS3_CLOSURE_REPORT.md) — formal GDS-3 closure evidence.

### Technical Architecture

[`docs/technical_architecture/`](docs/technical_architecture/) is currently **blocked by GDS completion**.

Technical Architecture will eventually translate the approved GDS into concrete Roblox/Luau contracts for tooling, modules, networking, persistence, identity, runtime lifecycle, player controls, creature/capture systems, economy, trading, monetization, UI, live operations, performance, testing and CI.

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
│   │   ├── GDS_ROADMAP.md
│   │   ├── DESIGN_DECISIONS.md
│   │   ├── GDS3_SCENARIO_VALIDATION.md
│   │   ├── GDS3_CROSS_VALIDATION.md
│   │   ├── GDS3_CLOSURE_REPORT.md
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

Proceed with **GDS-4 — Creatures, Collection, and Ownership**.

The first implementation vertical slice will be selected and locked only after the complete design and architecture dependency chain makes its requirements clear.

## License

No open-source license is currently granted. This repository is private and all rights are reserved unless explicitly stated otherwise.
