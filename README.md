# Monster Vault

> A data-driven multiplayer creature-collection and progression game built on Roblox.

## Overview

Monster Vault is a multiplayer Roblox game centered around capturing creatures, discovering rare mutations, expanding a personal vault/laboratory, unlocking new regions, and interacting with other players through cooperative events, competition, and eventually trading.

The project is designed around a simple, immediately understandable core loop with long-term collection, progression, social play, and live-content extensibility.

## Core Gameplay Loop

1. Explore the world.
2. Find and capture creatures.
3. Return creatures to your vault.
4. Generate resources and improve your equipment.
5. Unlock new regions and higher-value creatures.
6. Discover rare mutations and variants.
7. Participate in server-wide events.
8. Trade, compete, and expand your collection.

## Core Pillars

- Creature collection
- Rarity and mutations
- Visible player progression
- Exploration and biome progression
- Social competition and cooperation
- Server-wide events
- Persistent progression
- Trading and player economy
- Data-driven live content

## Technical Direction

The game will use a server-authoritative architecture. Security-sensitive systems such as currency, inventory, creature ownership, captures, progression, purchases, and trading must be validated and executed on the server.

Source code is organized into three primary domains:

```text
src/
├── client/
├── server/
└── shared/
```

The project is intended to evolve toward a modular service architecture with systems such as `CreatureService`, `CaptureService`, `EconomyService`, `MutationService`, `DataService`, `EventService`, and `TradingService`.

## Documentation

Project design and engineering decisions live under [`docs/`](docs/):

- [`GAME_DESIGN.md`](docs/GAME_DESIGN.md)
- [`TECHNICAL_ARCHITECTURE.md`](docs/TECHNICAL_ARCHITECTURE.md)
- [`ROADMAP.md`](docs/ROADMAP.md)
- [`ECONOMY_DESIGN.md`](docs/ECONOMY_DESIGN.md)
- [`MONETIZATION.md`](docs/MONETIZATION.md)

## Project Status

**Pre-production / foundation.**

The immediate objective is to define and validate a small vertical slice before investing in large-scale content production.

### Initial Vertical Slice

- 1 playable map/biome
- 1 player vault/base
- 10 creatures
- 4 rarity tiers
- 3 mutation types
- Capture mechanic
- Passive resource generation
- Basic upgrades
- 1 server-wide rare event
- Persistent save system

## Repository Structure

```text
Project-MonsterVault/
├── README.md
├── .gitignore
├── docs/
├── src/
│   ├── client/
│   ├── server/
│   └── shared/
├── tests/
├── assets/
└── scripts/
```

## Development Principles

- Keep gameplay systems server-authoritative where trust matters.
- Prefer data-driven content over hard-coded creatures, mutations, and regions.
- Keep the first playable slice small and measurable.
- Build systems for maintainability rather than one-off content hacks.
- Separate client presentation from server-owned game state.
- Treat persistence, remote validation, and economy integrity as security-critical.

## License

No open-source license is currently granted. This repository is private and all rights are reserved unless explicitly stated otherwise.
