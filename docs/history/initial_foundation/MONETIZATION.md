# Monetization Design

## Principles

Monetization should amplify a fun, proven game loop rather than substitute for one.

Primary rules:

- Avoid hard paywalls in the core capture loop.
- Avoid selling overwhelming competitive power.
- Prefer convenience, expression, status, and social/server-wide value.
- Keep purchases understandable before confirmation.
- Make all paid grants server-authoritative and idempotent.
- Do not design progression pain solely to sell the solution.

## Candidate Monetization Categories

### Storage Expansion

Players can purchase additional creature/storage capacity beyond the free progression path.

Potential product:

- +25 creature storage

This is a strong fit because collectors naturally value capacity, but the free baseline must remain viable.

### Cosmetic Capture Effects

Examples:

- Capture-device skins
- Capture animations
- Trails
- Vault visual effects
- Creature showcase effects

These provide status without destabilizing the economy.

### Vault Themes

Examples:

- Futuristic laboratory
- Ancient temple
- Frozen research station
- Void facility

Themes can be monetized individually or bundled.

### VIP

Potential benefits:

- Cosmetic nameplate/badge
- Exclusive vault theme or cosmetic set
- Additional convenience
- Small non-dominating quality-of-life benefits

VIP should not invalidate normal progression.

### Starter Pack

A one-time low-friction purchase may combine:

- Cosmetic item
- Modest amount of soft currency
- Temporary convenience boost
- Small storage expansion

It should feel useful without giving a permanent competitive monopoly.

### Server-Wide Boosts

Strong candidate because the purchaser creates value for the entire server.

Examples:

- 2× server mutation chance for a limited period
- Increased rare-spawn chance
- Special mutation storm
- Temporary event activation

Benefits:

- Creates social visibility for the purchaser.
- Encourages group activity.
- Avoids purely private pay-to-win framing.
- Can create memorable server moments.

These boosts require careful caps and stacking rules.

## Initial Working Price Ideas

These are placeholders only and must be validated against player behavior and current Roblox pricing context before release.

| Product | Working Price |
|---|---:|
| Starter Pack | 79 Robux |
| +25 Storage | 99 Robux |
| Extra Capture/Utility Slot | 149 Robux |
| VIP | 299 Robux |
| Cosmetic Vault Theme | 99–499 Robux |
| Capture Effect | 49–299 Robux |
| Limited Server Boost | 49–99 Robux |

No price is considered locked at this stage.

## Developer Product Safety

Repeatable purchases require strict receipt handling.

Requirements:

- Validate/process receipts on the server.
- Persist successful grants before acknowledging completion where appropriate.
- Design for retries.
- Ensure grants are idempotent.
- Never trust the client to report that payment succeeded.
- Separate purchase UI from authoritative entitlement/reward logic.

## Game Pass Safety

Permanent entitlements should be checked server-side and translated into explicit server-owned capabilities or profile flags where appropriate.

Do not let a client Boolean such as `HasVIP = true` become authoritative.

## Pay-to-Win Boundary

Potentially acceptable:

- More storage
- Cosmetic status
- Convenience
- Server-wide temporary boosts
- Small acceleration that does not invalidate normal play

High-risk:

- Direct purchase of the rarest collectible
- Guaranteed best mutations at scale
- Permanent large production multipliers
- Exclusive competitive mechanics unavailable to free players
- Purchasable advantages that dominate future trading value

## Monetization Timing

Monetization integration belongs after the core vertical slice is fun and stable enough to measure.

Recommended order:

1. Validate capture/return/upgrade loop.
2. Validate retention and collection desire.
3. Identify real friction and status desires.
4. Introduce monetization that serves those motivations.
5. Measure conversion without degrading retention.

## Future Considerations

Possible later systems:

- Season/pass structure
- Limited cosmetic collections
- Event bundles
- Gifting
- Premium showcase slots

These should only be added after the live game demonstrates sufficient retention and content cadence to support them.
