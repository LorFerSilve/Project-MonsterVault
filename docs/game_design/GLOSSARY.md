# Game Design Glossary

> **Status:** Draft / Active  
> **Authority:** Canonical gameplay terminology

This glossary owns shared terms used across MonsterVault design specifications. Terms are intentionally conservative during the early design phase; subsystem documents may propose additions, but shared terms must be normalized here before `Design Complete`.

## Current Canonical Terms

### Creature
A collectible game entity that may be encountered, captured and owned by a player according to the authoritative creature and capture specifications.

### Species
A content-authored creature archetype. Species identity is distinct from an individual Creature Instance and is not itself player-owned.

### Creature Instance
A specific individual creature entity with stable identity. Once secured, a Creature Instance is persistent player-owned collection value and must remain distinguishable from other instances of the same Species.

### World Creature
A creature/encounter representation that is not yet part of any player's Secured Collection. GDS-5 defines when it is a valid Capture Opportunity and how it can progress toward securisation.

### Capture Opportunity
A World Creature that is currently valid for at least one player to pursue through the ordinary GDS-5 acquisition loop.

### Capture Eligibility
The current player-specific rule result indicating whether that player may begin a capture engagement against a particular Capture Opportunity.

### Engagement Claim
A short-lived, non-persistent, exclusive right for one player to perform the current ordinary capture attempt against a creature. It prevents contradictory simultaneous single-winner attempts but is not ownership.

### Capture Attempt
A bounded active interaction in which the valid claimant performs the capture mechanic and resolves to Success, Failure, Cancel, or Invalidation.

### Capture Challenge
The player-facing action structure inside a Capture Attempt. It must remain compatible with GDS-3 cross-device/accessibility constraints; exact visual implementation and numeric tuning remain downstream.

### Capture Success
The successful result of a Capture Attempt. Under GDS-5, Capture Success creates a Provisional Capture but does not yet create Persistent Player State.

### Capture Failure
A non-successful Capture Attempt result. It creates no secured ownership and may release the opportunity immediately or after a short explicit recovery/cooldown state.

### Acquisition-In-Progress
A transient creature-related opportunity for which acquisition/capture has begun but **Secured Ownership Finalization** has not yet occurred. Engagement Claim, Capture Attempt, Provisional Capture, and Transport Custody are all unsecured acquisition states.

### Provisional Capture
The state after Capture Success in which one player has exclusive temporary custody of the specific creature for transport/extraction. It is not yet a Secured Creature.

### Transport Custody
The temporary exclusive association between a player and their Provisional Capture while it is being brought to an eligible Secure Point. Baseline GDS-5 allows one ordinary active Transport Custody per player.

### Transport Grace
A short bounded same-server interruption window during which an unexpectedly disconnected player may recover an existing Provisional Capture without creating a second copy or turning it into cross-server ownership.

### Secure Point
A world-defined valid destination or interaction capable of completing ordinary extraction/security for a valid Provisional Capture. Exact placement and world fiction belong to GDS-7/GDS-9.

### Extraction Completion
The validated completion of the required return/secure step at an eligible Secure Point while Transport Custody remains valid.

### Secured Ownership Finalization
The GDS-5-owned irreversible transition event that changes one eligible creature from unsecured/provisional acquisition state into a specific player's persistent ownership. In the baseline ordinary loop it occurs at validated Extraction Completion. A narrowly scoped system-originated shutdown protection path may emit the same exact-once finalization for an already valid Provisional Capture.

### Opportunity Release
The transition ending an Engagement Claim or failed/abandoned acquisition state and returning the creature to ordinary availability if its encounter lifetime remains valid.

### Onboarding-Protected Opportunity
A first-session Capture Opportunity whose availability cannot be permanently consumed or monopolized by unrelated players before the onboarding player completes the required first capture milestone.

### Capture
The gameplay process through which a World Creature may become owned by a player. GDS-5 defines the ordinary sequence from eligibility through Extraction Completion and Secured Ownership Finalization.

### Secured Creature
A Creature Instance for which Secured Ownership Finalization has completed and whose ownership is part of Persistent Player State.

The baseline product does not permit unrestricted theft or ordinary involuntary loss of a Secured Creature. Any later bounded exception must receive explicit authority and remain consistent with GDS-1/GDS-4 change control.

### Collection Registry
The player's authoritative logical set of currently owned Secured Creature Instances, including stable identity and relevant collection-facing metadata. This is a gameplay semantic, not a prescribed persistence implementation.

### Active Creature
A Secured Creature currently assigned to a later gameplay-active role. `Active` changes use/placement, not ownership.

### Stored Creature
A Secured Creature retained in ordinary collection/vault storage and not currently assigned to an active role.

### Overflow-Held Creature
A Secured Creature retained safely when ordinary eligible placement/storage capacity is unavailable. It remains player-owned Persistent Player State but has restricted ordinary use until capacity is resolved.

### Released Creature
A former Secured Creature whose player intentionally completed an irreversible voluntary removal action. Release ends current ordinary ownership and is not caused by session lifecycle, Recovery, or capacity overflow.

### Duplicate
Two or more distinct Secured Creature Instances of the same Species. Duplicates remain individually identifiable and may later differ through provenance, mutations, traits, or other instance metadata.

### Provenance
Persistent collection-facing information describing a Creature Instance's origin/acquisition history where applicable. Provenance is historical metadata and does not itself define current ownership.

### Creature Lock
A persistent player-controlled protection flag that prevents voluntary destructive or later ownership-transfer actions until explicitly removed.

### Species Discovery
A persistent collection fact indicating that the player has legitimately secured at least one Creature Instance of a Species. Releasing the last currently owned instance does not erase historical Species Discovery.

### Vault
The player's persistent personal base/laboratory space used for creature storage, display, production and progression functions. Final detailed scope remains under GDS-7.

### Mutation
A variant property that changes a creature's presentation and/or value according to the rarity/mutation specification. Mutation does not imply a specific statistical benefit unless explicitly defined.

### Rarity
A classification expressing designed scarcity and collection value. Exact tiers and probability semantics remain under GDS-6.

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
