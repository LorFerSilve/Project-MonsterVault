# Game Design

## Product Goal

Build a highly accessible multiplayer Roblox collection/progression game with strong retention, social interaction, replayability, and monetization potential without making the core experience depend on pay-to-win mechanics.

## Player Fantasy

The player is a creature hunter and vault/laboratory owner. They explore dangerous regions, capture unusual creatures, discover rare mutations, improve their equipment and base, and build a collection that carries status within the server and broader community.

## Core Loop

```text
Explore -> Discover -> Capture -> Return -> Generate Resources -> Upgrade -> Unlock -> Repeat
```

The loop must produce a meaningful reward within the first minute of play and expose the next goal immediately.

## Core Pillars

### 1. Collection
Creatures must be desirable as collectibles rather than merely resource generators. Visual identity, rarity, mutations, provenance, and event exclusivity should create ownership value.

### 2. Progression
Players improve capture equipment, storage, vault capacity, movement, access to biomes, and collection quality. Progression should be visible to both the player and other players.

### 3. Rarity and Mutations
Creatures may appear with rarity tiers and mutation modifiers. Mutations can alter appearance, value, production, status, or utility. The system should support combinatorial variety without requiring bespoke code per creature.

Initial rarity target:

- Common
- Uncommon
- Rare
- Epic

Long-term extension candidates:

- Legendary
- Mythic
- Ancient
- Celestial
- Secret

Initial mutations:

- Golden
- Crystal
- Radioactive

### 4. Social Play
The world should create reasons for players to notice and react to each other. Server-wide rare spawns, timed rifts, races for creatures, cooperative encounters, showcases, and eventually trading should create natural social moments.

### 5. Live Content
New creatures, mutations, biomes, events, and balance values should be data-driven so weekly or frequent content additions do not require invasive code changes.

## Initial Vertical Slice

The first playable milestone deliberately excludes broad content scope.

- 1 biome
- 1 player vault/base
- 10 creatures
- 4 rarity tiers
- 3 mutations
- Capture mechanic
- Creature transport/return loop
- Passive resource generation
- 3 meaningful upgrades
- 1 server-wide event
- Persistent player data
- Basic onboarding and UI feedback

## First-Session Experience

Target sequence:

1. Spawn near the player's vault.
2. Immediately see a capturable creature.
3. Receive a clear capture prompt.
4. Capture the creature within roughly 30 seconds.
5. Return it to the vault.
6. See resource generation begin.
7. Spend the first reward on an obvious upgrade.
8. Receive a visible objective pointing toward another creature or region goal.

The first session should avoid menus, lore dumps, or complex systems before the player experiences the core reward loop.

## Server Events

Initial concept:

**Rare Rift Event**

- Server-wide warning.
- Limited-duration spawn/location.
- Players converge on the same objective.
- Event contains a higher-than-normal chance of rare or mutated creatures.
- Event generates urgency and visible social activity.

Future events may include world bosses, mutation storms, meteor impacts, biome invasions, and cooperative capture encounters.

## Trading

Trading is intentionally deferred until ownership, persistence, economy integrity, duplicate prevention, and auditability are mature. When introduced, all trade state and validation must be server-authoritative.

## Non-Goals for the MVP

- Large open world
- Complex combat system
- PvP combat meta
- Dozens of biomes
- Hundreds of creatures
- Full trading economy
- Guilds/clans
- Competitive ranked systems
- Extensive narrative campaign

## Success Criteria for the Vertical Slice

The slice is successful if players can understand the loop without explanation, complete multiple capture-return-upgrade cycles, identify a next goal, and express interest in collecting rarer or mutated creatures.
