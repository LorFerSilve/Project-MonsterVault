# Game Design Glossary

> **Status:** Draft / Active  
> **Authority:** Canonical gameplay terminology

This glossary owns shared terms used across MonsterVault design specifications. Terms are intentionally conservative during the design phase; subsystem documents may propose additions, but shared terms must be normalized here before `Design Complete`.

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
A world-defined valid destination or interaction capable of completing ordinary extraction/security for a valid Provisional Capture. GDS-7 defines post-finalization Vault integration; exact placement/world topology belongs to GDS-9.

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
A Secured Creature currently assigned to a gameplay-active role. `Active` changes use/placement, not ownership.

### Stored Creature
A Secured Creature retained in ordinary collection/Vault storage and not currently assigned to an active role.

### Overflow-Held Creature
A Secured Creature retained safely when ordinary eligible collection capacity is unavailable. It remains player-owned Persistent Player State but has restricted ordinary use until capacity is resolved.

### Released Creature
A former Secured Creature whose player intentionally completed an irreversible voluntary removal action. Release ends current ordinary ownership and is not caused by session lifecycle, Recovery, or capacity overflow.

### Duplicate
Two or more distinct Secured Creature Instances of the same Species. Duplicates remain individually identifiable and may differ through provenance, mutations, traits, or other instance metadata.

### Provenance
Persistent collection-facing information describing a Creature Instance's origin/acquisition history where applicable. Provenance is historical metadata and does not itself define current ownership.

### Creature Lock
A persistent player-controlled protection flag that prevents voluntary destructive or later ownership-transfer actions until explicitly removed.

### Species Discovery
A persistent collection fact indicating that the player has legitimately secured at least one Creature Instance of a Species. Releasing the last currently owned instance does not erase historical Species Discovery.

### Species Rarity
The GDS-6 authored scarcity/status classification of a Species. Baseline ordered tiers are **Common, Uncommon, Rare, Epic, Legendary**. Species Rarity is distinct from Mutation, Trait, Availability, gameplay power, currency value, and future market price.

### Mutation
A persistent GDS-6 instance-level variant property with a meaningful collectible/presentation identity. A Mutation may support a bounded downstream gameplay hook but does not automatically imply superior stats or power.

### Mutation Frequency Band
The context-aware scarcity class of a Mutation within an eligible generation context: **Frequent, Uncommon, Rare, Extreme**. The band does not encode one universal exact percentage.

### Standard Variant
A Creature Instance with zero Mutations.

### Single-Mutated Variant
A Creature Instance with exactly one Mutation.

### Compound-Mutated Variant
A Creature Instance with exactly two compatible Mutations. GDS-6 baseline permits at most two simultaneous Mutations.

### Trait
A persistent instance-level characteristic distinct from Mutation. Traits may support bounded situational optimization under downstream systems but are not a second Species Rarity ladder and do not override ownership/finalization.

### Variant Identity Finalization
The GDS-6 boundary at which an instance's Mutation/Trait identity is fixed. It occurs no later than that specific creature becoming an individually actionable Capture Opportunity and cannot be rerolled through claim, capture, transport, reconnect, or finalization retries.

### Variant Signature
The canonical baseline visual-variant identity formed by **Species + canonical Mutation set**. Mutation order does not create separate signatures. Traits and Provenance remain instance metadata but are not part of baseline Variant Signature completion.

### Mutation Discovery
A persistent historical player fact recorded after legitimate Secured Ownership Finalization of at least one creature carrying a specific Mutation.

### Variant Discovery
A persistent historical player fact recorded after legitimate Secured Ownership Finalization of a specific Variant Signature.

### Protected Variant
A high-value GDS-6 category that auto-applies GDS-4 Creature Lock on first securisation. It includes Legendary Species, Extreme-Mutated instances, Compound-Mutated instances, and explicitly protected event/legacy content.

### Availability Tag
A GDS-6 non-rarity label describing how creature/variant content is currently obtainable: **Core, Rotating, Event-Limited, Legacy**. Availability does not replace or extend the Species Rarity ladder.

### Variant Value
The multi-dimensional collectible/status significance of one Creature Instance, informed by Species Rarity, Mutation scarcity/count, Traits, Provenance, Availability, event/history context, and later market demand. Variant Value is not a guaranteed currency or trading price.

### Vault
The player's persistent personal base/laboratory context used to manage secured creatures, display collection value, assign creatures to bounded production, claim accrued output, and perform Vault progression actions. Baseline authority is owned by GDS-7.

### Vault Access Point
A player-facing world or menu-access interaction that enters the player's Vault context. Exact world placement belongs to GDS-9. Access does not itself change creature ownership.

### Collection Capacity
The maximum number of Secured Creature Instances that may occupy ordinary usable collection states rather than `Overflow-Held`. Collection Capacity is a logical use/storage limit and is separate from Display Slot and Production Slot counts.

### Storage Eligibility
Whether a Secured Creature can currently occupy an ordinary non-overflow collection state. Eligibility requires available Collection Capacity and compliance with any explicit restriction on ordinary use.

### Display Slot
A Vault presentation location that may show one eligible Secured Creature. Display capacity is separate from Collection Capacity and does not create additional owned copies.

### Production Slot
A Vault assignment location that may accept one eligible Secured Creature for passive production. Production Slot count is separate from Collection Capacity and Display Slot count.

### Production Assignment
The persistent association of one eligible Secured Creature Instance with one Production Slot. A creature can have at most one Production Assignment at a time and cannot simultaneously occupy another mutually exclusive active gameplay role.

### Production Profile
The authored production characteristics used by GDS-7/GDS-8 to determine how an eligible assigned creature contributes output. A Production Profile may depend on Species and explicitly authorized bounded Trait effects; Species Rarity or Mutation presence does not automatically multiply production.

### Passive Production
Accrual generated over elapsed time from valid persistent Production Assignments without requiring repeated player input.

### Production Buffer
The persistent bounded accumulator holding unclaimed Passive Production output before it is claimed into the owning GDS-8 resource/progression system. When the applicable buffer is full, further passive accrual pauses.

### Offline Production Window
The maximum elapsed-time interval after Active Presence ends for which valid Production Assignments may continue generating Passive Production before the offline cap stops additional accrual.

### Production Claim
The player action that transfers currently eligible Production Buffer value into the owning downstream resource/progression state as one exact-once Finalized Outcome.

### Vault Upgrade
A persistent progression change that increases or changes an explicitly defined Vault capability such as Collection Capacity, Production Slot count, Production Buffer capacity, Offline Production Window, Display capacity, or approved Vault utility.

### Capacity Reconciliation
The non-destructive GDS-7 process used when effective Collection Capacity becomes lower than the number of ordinarily placed/usable secured creatures. Ownership remains intact; required assignments are ended safely and excess instances become Overflow-Held rather than deleted.

### Resolve Overflow
The owner action that selects one eligible Overflow-Held Creature and returns that exact instance to ordinary `Stored` use when free Collection Capacity is available.

### Visitor
A non-owner player temporarily allowed to view or interact with explicitly public/read-only elements of another player's Vault. Baseline visitors receive no persistent management authority and observation alone grants no Species/Mutation/Variant Discovery.

### Biome
A world region with its own creature pool, environment, progression requirements and encounter characteristics.

### Server Event
A time-bounded multiplayer encounter or world-state change presented to multiple players within a server.

### Energy
The current working name for a primary non-premium progression resource. This name and its exact role remain provisional until GDS-8.

### Trading
An explicit player-to-player ownership transfer mechanism governed by the trading specification. Trading is strategically desirable but is not a launch-critical product requirement and is not considered guaranteed until GDS-12 reaches Design Complete.

### Offline Progression
Any progression accrued while the player is not actively present in the experience. GDS-7 explicitly authorizes **bounded Vault Passive Production** from finalized Production Assignments, limited by the Offline Production Window and Production Buffer cap. Other offline progression remains unauthorized unless an owning later specification defines it. GDS-8 owns exact resource/rate/economic effects.

### Core Product Loop
The recurring high-level structure through which players pursue a desirable target, explore/discover, attempt capture, secure/return acquired value, improve their collection/Vault/progression, and pursue a new higher-value goal. Detailed mechanics remain distributed across their owning GDS phases.

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
