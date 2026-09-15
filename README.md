# Monster Vault

> A data-driven multiplayer creature-collection and progression game built on Roblox.

## Project Status

**Pre-implementation specification — GDS-0 / GDS-1.**

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

## Current Product Direction

The working product direction is a multiplayer Roblox creature-collection/progression game centered on:

- exploring and discovering creatures;
- an active capture/secure/return loop;
- persistent creature collection and ownership;
- rarity, mutations and collectible status;
- a personal vault/laboratory;
- progression and biome unlocks;
- social competition and cooperation;
- server-wide dynamic events;
- eventual secure trading;
- sustainable monetization that does not invalidate earned progression;
- data-driven live-content expansion.

These are **design hypotheses and current baseline decisions**, not final implementation contracts. The authoritative GDS will refine, constrain or reject individual mechanics before development begins.

## Documentation Authority

Start at [`docs/README.md`](docs/README.md).

### Game Design Specification

[`docs/game_design/`](docs/game_design/) owns intended player-facing behavior.

Key documents:

- [`00_design_authority.md`](docs/game_design/00_design_authority.md) — governance, status model and definition of Design Complete;
- [`01_game_overview.md`](docs/game_design/01_game_overview.md) — current product vision and open product questions;
- [`GDS_ROADMAP.md`](docs/game_design/GDS_ROADMAP.md) — dependency-driven GDS-0 through GDS-17 sequence;
- [`DESIGN_DECISIONS.md`](docs/game_design/DESIGN_DECISIONS.md) — strategic design decisions and rationale;
- [`GLOSSARY.md`](docs/game_design/GLOSSARY.md) — canonical shared gameplay terminology;
- [`SPECIFICATION_TEMPLATE.md`](docs/game_design/SPECIFICATION_TEMPLATE.md) — required structure for subsystem specifications.

The current GDS domains cover global rules, player interaction/onboarding, creatures, capture, rarity/mutations, vault/base, economy/progression, world/biomes, social play, server events/live operations, trading, monetization, presentation/accessibility, Roblox platform safety, retention/discovery/analytics and final cross-system auditing.

### Technical Architecture

[`docs/technical_architecture/`](docs/technical_architecture/) is currently **blocked by GDS completion**.

Its roadmap is defined in [`TA_ROADMAP.md`](docs/technical_architecture/TA_ROADMAP.md). Technical Architecture will translate the approved GDS into concrete Roblox/Luau contracts for tooling, modules, networking, persistence, identity, runtime lifecycle, economy, trading, monetization, UI, live operations, performance, testing and CI.

### Implementation

[`docs/implementation/`](docs/implementation/) is intentionally **BLOCKED**.

Gameplay implementation opens only after:

1. GDS-17 records a formal Design Complete PASS;
2. the Technical Architecture is completed;
3. TA-16 records a formal architecture-integration PASS;
4. TA-17 locks the implementation roadmap, exact vertical slice, toolchain, dependency graph, validation requirements and change-control rules.

### Historical Baseline

The original repository-level concept documents are preserved under [`docs/history/initial_foundation/`](docs/history/initial_foundation/).

They remain useful design input, but do not override the current authoritative GDS/TA structure.

## Working Core Loop

The current high-level hypothesis is:

```text
Explore
  -> discover creature
  -> attempt capture
  -> secure / transport / return
  -> add to collection or vault
  -> gain progression value
  -> upgrade capacity / equipment / access
  -> reach rarer content
  -> discover mutations and high-status variants
  -> participate in social/server events
  -> repeat
```

The exact capture rules, ownership-transfer point, competition model, passive production, economy, rarity distribution, trading rules, monetization and even the final vertical-slice scope remain subject to their owning GDS phases.

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
│   │   ├── GDS_ROADMAP.md
│   │   ├── DESIGN_DECISIONS.md
│   │   ├── GLOSSARY.md
│   │   ├── SPECIFICATION_TEMPLATE.md
│   │   ├── <design domains>/
│   │   └── audit/
│   ├── technical_architecture/
│   │   ├── 00_architecture_authority.md
│   │   ├── TA_ROADMAP.md
│   │   ├── ARCHITECTURE_DECISIONS.md
│   │   └── audit/
│   ├── implementation/
│   └── history/
├── src/
│   ├── client/
│   ├── server/
│   └── shared/
├── tests/
├── assets/
└── scripts/
```

The source/test/tooling directories are reserved for later implementation. Their existence does **not** mean the implementation gate is open.

## Current Next Step

Complete **GDS-0**, then work through **GDS-1 — Product Vision, Audience, and Success Criteria** before specifying lower-level gameplay systems.

The first implementation vertical slice will be selected and locked only after the complete design and architecture dependency chain makes its requirements clear.

## License

No open-source license is currently granted. This repository is private and all rights are reserved unless explicitly stated otherwise.
