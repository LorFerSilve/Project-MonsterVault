# Game Design Glossary

> **Status:** Draft / Active  
> **Authority:** Canonical gameplay terminology

This glossary owns shared terms used across MonsterVault design specifications. Terms are intentionally conservative during the early design phase; subsystem documents may propose additions, but shared terms must be normalized here before `Design Complete`.

## Current Canonical Terms

### Creature
A collectible game entity that may be encountered, captured and owned by a player according to the authoritative creature and capture specifications.

### Species
A content-defined creature archetype. Species identity is distinct from an individual owned creature instance.

### Creature Instance
A specific owned or world-present creature with its own persistent identity and applicable generated properties such as mutations or traits.

### Capture
The gameplay process through which a world creature may become owned by a player. Exact ownership-transfer timing is owned by the capture specification.

### Secured Creature
A creature instance that has crossed the future GDS-5/GDS-4-defined boundary into the player's protected persistent collection state.

GDS-1 establishes only the product-level consequence: **unrestricted theft of a secured persistent creature is not part of MonsterVault's baseline product identity**. The exact event that makes a creature secured, and any explicitly bounded exceptions/risk modes, remain owned by GDS-4/GDS-5/GDS-10.

### Vault
The player's persistent personal base/laboratory space used for creature storage, display, production and progression functions. Final detailed scope remains under GDS-7.

### Mutation
A variant property that changes a creature's presentation and/or value according to the rarity/mutation specification. Mutation does not imply a specific statistical benefit unless explicitly defined.

### Rarity
A classification expressing designed scarcity and collection value. Exact tiers and probability semantics remain under design.

### Biome
A world region with its own creature pool, environment, progression requirements and encounter characteristics.

### Server Event
A time-bounded multiplayer encounter or world-state change presented to multiple players within a server.

### Energy
The current working name for a primary non-premium progression resource. This name and its exact role remain provisional until GDS-8.

### Trading
An explicit player-to-player ownership transfer mechanism governed by the trading specification. Trading is strategically desirable but is not a launch-critical product requirement and is not considered guaranteed until GDS-12 reaches Design Complete.

### Offline Progression
Any progression accrued while the player is not actively present in the experience. Exact availability, caps and anti-abuse rules remain under design.

### Core Product Loop
The recurring high-level structure through which players pursue a desirable target, explore/discover, attempt capture, secure/return acquired value, improve their collection/vault/progression, and pursue a new higher-value goal. Detailed mechanics remain distributed across their owning GDS phases.

### Product Promise
The GDS-1 high-level statement describing the intended player fantasy and market promise:

> **Find it. Catch it. Bring it home. Make your vault legendary.**

### Server Authority
A technical principle, not a gameplay rule: security-sensitive state is ultimately validated by the server. Detailed technical contracts belong to Technical Architecture.

## Naming Rule

A term used as a formal state, resource, ownership concept, rarity, event type or progression stage must have one canonical meaning. Reusing the same label for unrelated mechanics is prohibited once the specification reaches `Design Complete`.
