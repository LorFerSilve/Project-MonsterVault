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
Any progression accrued while the player is not actively present in the experience. GDS-2 establishes that offline progression is **not guaranteed by default**; if later accepted, its exact availability, caps, elapsed-time semantics, and anti-abuse rules are owned by GDS-7/GDS-8.

### Core Product Loop
The recurring high-level structure through which players pursue a desirable target, explore/discover, attempt capture, secure/return acquired value, improve their collection/vault/progression, and pursue a new higher-value goal. Detailed mechanics remain distributed across their owning GDS phases.

### Product Promise
The GDS-1 high-level statement describing the intended player fantasy and market promise:

> **Find it. Catch it. Bring it home. Make your vault legendary.**

### Server Session
A single running Roblox game-server instance and its session-scoped world state. A Server Session is temporary and is not the authoritative lifetime of Persistent Player State.

### Active Presence
The period in which a player is connected, trusted persistent state is ready for safe use, and irreversible gameplay actions are permitted.

### Session-Scoped State
State intentionally bounded to a Server Session or session-local opportunity. It may disappear when that session ends unless an owning specification explicitly finalizes an outcome into Persistent Player State.

### Persistent Player State
Player-owned progression intended to survive ordinary avatar failure, reset, disconnect, reconnect, server change, device change, and future play sessions.

### Finalized Outcome
A gameplay result that its owning specification considers complete rather than provisional. A finalized persistent outcome must not be duplicated or silently reversed merely because of retry, reconnect, or server transition.

### Transient Opportunity
A world/session opportunity that has not yet produced a Finalized Outcome. Its interruption behavior is owned by the subsystem that created it.

### Recovery
A temporary non-punitive lifecycle state that returns the player to valid active play after avatar failure, reset, invalid position, or comparable interruption. Recovery does not imply a global persistent progression wipe.

### Protected Load Failure
The GDS-2 state entered when trusted Persistent Player State cannot be established. Irreversible gameplay is blocked; the player may retry, reconnect, or leave. A blank fallback profile must not silently replace trusted progression.

### Global Window
A calendar-based availability period intended to have the same temporal boundary across servers. Joining or changing servers does not restart it. Exact live-event use belongs to GDS-11.

### Player Character
The controllable in-world avatar through which the player moves, explores and performs world interactions during Active Presence. The Player Character is temporary runtime presence and is not identical to Persistent Player State.

### Primary Interact
The universal GDS-3 semantic action used to activate the currently selected contextual world interaction. The concrete effect belongs to the owning subsystem.

### Primary Action
The GDS-3 semantic action used by the currently active gameplay tool or downstream mechanic. It must remain available across supported Input Modes; GDS-3 does not define the mechanic-specific effect.

### Context Candidate
A nearby or currently targeted world interaction that is valid enough to be considered for Primary Interact.

### Active Context
The single Context Candidate currently selected and visibly presented as the target of Primary Interact.

### Interaction Prompt
The player-facing indication that an Active Context exists, including a concise action label and current-device control/glyph.

### Safe Arrival
The short GDS-3 entry/recovery state after GDS-2 Persistence Ready used to establish a valid Player Character, camera, orientation, and direct control before ordinary exposed play.

### Onboarding Milestone
A persistent player-specific record that a required introductory learning/progression step has been demonstrated or completed. Reconnect/replay must not duplicate finalized milestone rewards.

### Guidance Layer
Non-essential instructional prompts, highlights, arrows, hints, or reminders that teach the player without themselves granting gameplay progress or Finalized Outcomes.

### Recovery Anchor
A world-defined valid location to which GDS-2/GDS-3 Recovery may return a Player Character. Exact placement and world semantics are owned by GDS-9.

### Input Mode
The currently dominant control family: touch, keyboard/mouse, or gamepad. Changing Input Mode changes prompts/control presentation, not baseline gameplay capability or progression state.

### Server Authority
A technical principle, not a gameplay rule: security-sensitive state is ultimately validated by the server. Detailed technical contracts belong to Technical Architecture.

## Naming Rule

A term used as a formal state, resource, ownership concept, rarity, event type or progression stage must have one canonical meaning. Reusing the same label for unrelated mechanics is prohibited once the specification reaches `Design Complete`.
