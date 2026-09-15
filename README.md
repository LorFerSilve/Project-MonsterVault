# Monster Vault

> A data-driven multiplayer creature-collection and progression game built on Roblox.

## Project Status

**Pre-implementation specification — GDS-0 and GDS-1 complete / GDS-2 next.**

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
- **GDS-2 — Global Game Rules and Session Model: NEXT**
- GDS-3 through GDS-16: Draft / dependency-ordered
- GDS-17: blocked until subsystem design is complete
- Technical Architecture: blocked by GDS-17
- Gameplay implementation: blocked by GDS and TA gates

GDS-1 closure evidence is recorded in [`GDS1_CROSS_VALIDATION.md`](docs/game_design/GDS1_CROSS_VALIDATION.md) and [`GDS1_CLOSURE_REPORT.md`](docs/game_design/GDS1_CLOSURE_REPORT.md).

## Product Contract

MonsterVault is now formally defined at product level as a **social creature-collection and progression adventure** with the promise:

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

Detailed gameplay rules remain intentionally owned by later GDS phases.

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

The exact capture rules, ownership-transfer point, economy, rarity probabilities, transport rules, social contesting, event structure, trading design, and monetization products remain subject to their owning GDS phases.

## Documentation Authority

Start at [`docs/README.md`](docs/README.md).

### Game Design Specification

[`docs/game_design/`](docs/game_design/) owns intended player-facing behavior.

Key documents:

- [`00_design_authority.md`](docs/game_design/00_design_authority.md) — governance, status model and definition of Design Complete;
- [`01_game_overview.md`](docs/game_design/01_game_overview.md) — Design Complete high-level product overview;
- [`product/`](docs/game_design/product/) — GDS-1 audience, positioning, session, scope and success specifications;
- [`GDS_ROADMAP.md`](docs/game_design/GDS_ROADMAP.md) — dependency-driven GDS-0 through GDS-17 sequence;
- [`DESIGN_DECISIONS.md`](docs/game_design/DESIGN_DECISIONS.md) — strategic design decisions and rationale;
- [`GLOSSARY.md`](docs/game_design/GLOSSARY.md) — canonical shared gameplay terminology;
- [`SPECIFICATION_TEMPLATE.md`](docs/game_design/SPECIFICATION_TEMPLATE.md) — required structure for subsystem specifications;
- [`STRUCTURE_AUDIT.md`](docs/game_design/STRUCTURE_AUDIT.md) — GDS-0 domain/authority completeness audit;
- [`GDS0_CLOSURE_REPORT.md`](docs/game_design/GDS0_CLOSURE_REPORT.md) — formal GDS-0 closure evidence;
- [`GDS1_CROSS_VALIDATION.md`](docs/game_design/GDS1_CROSS_VALIDATION.md) — formal GDS-1 cross-validation;
- [`GDS1_CLOSURE_REPORT.md`](docs/game_design/GDS1_CLOSURE_REPORT.md) — formal GDS-1 closure evidence.

### Technical Architecture

[`docs/technical_architecture/`](docs/technical_architecture/) is currently **blocked by GDS completion**.

Technical Architecture will eventually translate the approved GDS into concrete Roblox/Luau contracts for tooling, modules, networking, persistence, identity, runtime lifecycle, economy, trading, monetization, UI, live operations, performance, testing and CI.

### Implementation

[`docs/implementation/`](docs/implementation/) remains intentionally **BLOCKED**.

Gameplay implementation opens only after the complete GDS and Technical Architecture gates are passed and TA-17 locks the implementation roadmap and exact vertical slice.

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
│   │   ├── GDS_ROADMAP.md
│   │   ├── DESIGN_DECISIONS.md
│   │   ├── GDS1_CROSS_VALIDATION.md
│   │   ├── GDS1_CLOSURE_REPORT.md
│   │   ├── <design domains>/
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

Proceed with **GDS-2 — Global Game Rules and Session Model**.

The first implementation vertical slice will be selected and locked only after the complete design and architecture dependency chain makes its requirements clear.

## License

No open-source license is currently granted. This repository is private and all rights are reserved unless explicitly stated otherwise.
