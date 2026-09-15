# Economy Design

## Objective

The economy should reinforce the capture-and-collection loop, create meaningful progression choices, and remain controllable as content and monetization expand.

The initial economy should stay intentionally simple. Complexity such as player-to-player pricing, multiple premium-adjacent currencies, or speculative trading should not be introduced before the core loop is validated.

## Initial Currency Model

### Soft Currency: Energy

Working name: **Energy**.

Primary sources:

- Passive production from creatures placed in the vault
- Selected gameplay objectives
- Server-event participation
- Future quest/achievement rewards

Primary sinks:

- Capture equipment upgrades
- Vault/storage upgrades
- Movement or exploration upgrades
- Region unlocks when appropriate
- Utility upgrades

The economy must always contain recurring or scaling sinks so production growth does not make currency meaningless.

## Creature Economic Value

A creature has several distinct notions of value:

- **Collection value** — rarity/status to the player
- **Production value** — passive Energy generation
- **Progression value** — whether it enables or accelerates goals
- **Future trade value** — only relevant when secure trading exists

These should not be collapsed into one number unless the design benefits from doing so.

## Production Model

Conceptually:

```text
productionRate = baseCreatureProduction
               × rarityModifier
               × mutationModifier
               × progressionModifiers
```

Exact coefficients must be configuration-driven and tested against progression targets.

## Upgrade Cost Curves

Upgrade prices should generally increase faster than linear production gains so progression remains meaningful.

Candidate model:

```text
cost(level) = baseCost × growthFactor^(level - 1)
```

This is a starting point, not a locked balance formula. Different upgrade categories may require different curves.

## Sources and Sinks

All currency-changing actions should include a semantic reason code internally.

Example source reasons:

- `CreatureProduction`
- `EventReward`
- `QuestReward`
- `Compensation`

Example sink reasons:

- `EquipmentUpgrade`
- `VaultUpgrade`
- `RegionUnlock`

This makes debugging and future analytics materially easier.

## Economy Integrity Rules

- Clients never authoritatively set balances.
- Negative purchases must be impossible.
- Integer/precision semantics must be explicitly defined.
- Rewards should be idempotent when retries are possible.
- High-value grants should have a traceable reason.
- Economy APIs should reject invalid or non-finite values.
- Overflow/upper-bound behavior must be considered before large-number progression is introduced.

## Offline Progression

Offline earnings are a potential retention feature, but they can distort active-play incentives.

If introduced, use a bounded model such as:

```text
offlineReward = min(elapsedTime, offlineCap) × eligibleProductionRate × offlineEfficiency
```

Important constraints:

- Hard time cap
- Reduced efficiency relative to active play if necessary
- Server-calculated elapsed time
- No client-supplied timestamps
- Explicit protection against clock manipulation and duplicate claims

Offline progression is **not required for the initial vertical slice**.

## Inflation Controls

Potential controls as the game scales:

- Upgrade curves
- Capacity expansion costs
- Region unlock costs
- Cosmetic soft-currency sinks
- Limited reroll/crafting sinks if later introduced
- Controlled event reward budgets

Avoid arbitrary currency wipes or aggressive sink changes that invalidate player effort.

## Trading Implications

Trading changes the economy from a mostly closed progression system into a player economy. Before enabling it, the project must define:

- Unique creature-instance identity
- Ownership-transfer invariants
- Duplication prevention
- Trade atomicity
- Trade cancellation behavior
- Item locking during transactions
- Audit/logging strategy
- Scam-resistant confirmation UX

Trading should not directly support arbitrary soft-currency transfer in the first version unless there is a strong design reason and adequate abuse protection.

## Balance Workflow

Balance values should live in configuration and be evaluated against target milestones such as:

- Time to first upgrade
- Time to first storage constraint
- Time to first region unlock
- Expected production after 10/30/60 minutes
- Value gap between rarity tiers
- Expected mutation acquisition frequency

Do not tune purely from intuition; use playtest telemetry once available.
