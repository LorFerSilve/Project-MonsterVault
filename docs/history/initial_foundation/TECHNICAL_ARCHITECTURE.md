# Technical Architecture

## Architectural Goals

Monster Vault should be secure, maintainable, data-driven, testable where practical, and easy to extend with new creatures, mutations, regions, events, and economy content.

## Trust Boundary

The server is authoritative for all state that affects progression or value.

The client may request actions and render presentation, but it must never be trusted to decide outcomes involving:

- Currency balances
- Creature ownership
- Capture success
- Inventory contents
- Upgrade ownership
- Reward calculation
- Mutation assignment
- Purchases
- Trading
- Persistent progression

Every remote request must be validated server-side for type, range, ownership, game state, rate, and contextual legitimacy.

## Source Layout

```text
src/
├── client/
├── server/
└── shared/
```

### `src/client`

Client-only presentation and input logic:

- UI controllers
- Camera effects
- Input handling
- Local visual/audio feedback
- Non-authoritative interpolation and cosmetic effects

### `src/server`

Authoritative gameplay and persistence:

- Creature spawning and lifecycle
- Capture validation
- Player economy
- Inventory and ownership
- Progression
- Persistence
- Server events
- Monetization receipt handling
- Trading when introduced

### `src/shared`

Definitions safely shared by both environments:

- Typed data contracts
- Configuration schemas
- Creature definitions
- Mutation definitions
- Constants
- Utility modules without privileged state

## Planned Service Boundaries

The initial service architecture is expected to evolve around:

- `DataService` — persistent profile lifecycle and save coordination
- `CreatureService` — creature definitions, spawning, identity, and world lifecycle
- `CaptureService` — capture requests, validation, outcomes, and rewards
- `InventoryService` — authoritative ownership and capacity rules
- `EconomyService` — currency sources/sinks and balance mutations
- `MutationService` — mutation generation and modifiers
- `ProgressionService` — upgrades, unlocks, and biome access
- `EventService` — server-wide timed/dynamic events
- `MonetizationService` — game-pass/developer-product integration and receipt validation
- `TradingService` — deferred until economy/persistence integrity is proven

Services should expose narrow APIs rather than allowing unrelated modules to mutate internal state directly.

## Data-Driven Content

Creatures, mutations, regions, and balance values should be represented as validated configuration data.

Example conceptual creature record:

```luau
{
    Id = "forest_slime",
    DisplayName = "Forest Slime",
    Rarity = "Common",
    BaseValue = 10,
    BaseProduction = 2,
    Biome = "Forest",
}
```

Runtime systems should operate on these definitions instead of embedding content-specific conditionals throughout gameplay code.

## Persistence Principles

Persistent data must be treated as a transactional/value-bearing system.

Requirements:

- Server-only persistence access
- Schema versioning
- Migration support
- Defensive defaults
- Session ownership/locking strategy
- Retry/backoff for transient failures
- No client-provided authoritative save payloads
- Idempotent handling for monetized rewards

The exact persistence library/tooling will be selected before implementation rather than assumed here.

## Networking Principles

Remote interfaces should be explicit and minimal.

For each remote action:

1. Validate argument types.
2. Validate argument bounds.
3. Validate player ownership/access.
4. Validate spatial/contextual state where relevant.
5. Enforce rate limits/cooldowns.
6. Compute the authoritative result on the server.
7. Return only the data required by the client.

Never expose a generic remote that lets the client choose arbitrary currency, item, creature, reward, or mutation values.

## Economy Integrity

Economy mutations should flow through a centralized service so sources and sinks can be reasoned about and audited.

Prefer APIs conceptually similar to:

```luau
EconomyService:AddCurrency(player, amount, reason)
EconomyService:SpendCurrency(player, amount, reason)
```

rather than direct table mutations from arbitrary systems.

## Testing Strategy

Prioritize deterministic logic for automated tests:

- Rarity rolls
- Mutation selection
- Upgrade cost curves
- Economy calculations
- Schema validation
- Inventory capacity rules
- Reward calculation
- Trade validation when implemented

Roblox-engine integration behavior should be tested separately from pure domain logic where possible.

## Security Requirements

- Assume exploiters can invoke remotes manually.
- Assume client memory and LocalScripts are fully observable/modifiable.
- Never place secrets or privileged logic on the client.
- Validate developer-product receipts server-side and idempotently.
- Prevent duplicate grants during retries/rejoins.
- Rate-limit high-value remote actions.
- Log suspicious state transitions during development.

## Performance Considerations

- Avoid per-frame server work per creature unless strictly necessary.
- Prefer event-driven state changes over polling.
- Pool or spatially cull expensive world entities when creature counts scale.
- Keep replicated state minimal.
- Avoid broadcasting private inventory/economy state to unrelated clients.
- Profile before introducing complex optimization layers.

## Tooling

The exact development toolchain will be locked before implementation. Likely candidates include Roblox Studio, Luau, Rojo, a Luau language server, formatting/linting, and automated checks in CI. Dependencies should only be added when they solve a concrete project need.
