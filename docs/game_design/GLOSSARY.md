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
A GDS-9 world-defined valid destination or interaction capable of completing ordinary extraction/security for a valid Provisional Capture. GDS-5 owns validated Extraction Completion and Secured Ownership Finalization; GDS-7 owns post-finalization Vault integration.

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
A GDS-9 world-defined interaction that enters the player's Vault context after trusted persistent state is available. A field Vault Access Point may manage already Secured Creatures but does not itself secure a Provisional Capture unless it is separately an eligible Secure Point and GDS-5 Extraction Completion succeeds.

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
The persistent bounded accumulator holding unclaimed Passive Production output before it is claimed into the GDS-8 Energy Wallet. When the applicable buffer is full, further passive accrual pauses.

### Offline Production Window
The maximum elapsed-time interval after Active Presence ends for which valid Production Assignments may continue generating Passive Production before the offline cap stops additional accrual.

### Production Claim
The player action that transfers currently eligible Production Buffer Energy into the Energy Wallet as one exact-once Finalized Outcome.

### Vault Upgrade
A persistent progression change that increases or changes an explicitly defined Vault capability such as Collection Capacity, Production Slot count, Production Buffer capacity, Offline Production Window, Display capacity, or approved Vault utility.

### Capacity Reconciliation
The non-destructive GDS-7 process used when effective Collection Capacity becomes lower than the number of ordinarily placed/usable secured creatures. Ownership remains intact; required assignments are ended safely and excess instances become Overflow-Held rather than deleted.

### Resolve Overflow
The owner action that selects one eligible Overflow-Held Creature and returns that exact instance to ordinary `Stored` use when free Collection Capacity is available.

### Visitor
A non-owner player allowed under the owner's GDS-10 Visitor Access Policy to enter a read-only view of another player's Vault. Visitors receive no management, ownership, economy or production authority, and observation alone grants no Species/Mutation/Variant Discovery.

### Energy
The canonical GDS-8 baseline non-premium soft progression currency. Energy is persistent, fungible, non-negative whole-unit player-facing value used for approved progression sinks. It is separate from premium currency and is not baseline player-to-player transferable.

### Energy Wallet
The player's persistent authoritative Energy balance. The wallet cannot finalize below zero and must use implementation-safe bounds without silently destroying claimable value.

### Economy Source
An authorized event that creates Energy from outside the player's existing Energy Wallet, such as a Production Claim, approved active objective/milestone reward, downstream event reward, onboarding reward, or exceptional remediation.

### Economy Sink
An authorized event that permanently removes Energy in exchange for a defined progression, access, utility, or approved presentation outcome.

### Progression Milestone
A persistent non-currency record proving completion of meaningful active gameplay or collection progression. It may gate later progression but is not a spendable resource and cannot be fabricated by passive Energy alone.

### Progression Gate
A defined requirement set that must be satisfied before a progression action becomes available. It may combine prior unlocks, Progression Milestones, collection/Vault state, and an Energy cost.

### Progression Purchase
An exact-once player-initiated transaction that spends Energy and grants one defined persistent progression effect. Cost and effect are atomic from the player's perspective.

### Capture Capability
The player's persistent ordinary capture-equipment progression capability. It may influence explicitly authorized challenge assistance or encounter requirements but does not override GDS-5 claim, ownership-finalization, capacity, or single-winner rules.

### Access Unlock
A persistent exact-once progression effect granting access to a defined content, region, or capability gate. GDS-9 owns baseline world-region topology and concrete region gating.

### Economy Band
A tuning segment representing a comparable stage of player progression for reward, cost, and pacing evaluation. It need not be exposed as a player-facing rank.

### Catch-Up Adjustment
A visible deterministic adjustment that reduces obsolete progression friction for eligible players without hidden spending-based personalization or fabricated discovery/active-completion history.

### Home Hub
The baseline safe GDS-9 world region containing the primary Vault Access Point, central Secure Point, Recovery Anchor, region-travel access and onboarding-safe route into the Starter Biome.

### Biome
A GDS-9 world region with an authored environment, Habitats, creature eligibility, progression role, routes and encounter characteristics. A Biome may require a persistent Access Unlock, but entering it does not itself grant completion or discovery history.

### Region Mastery
A persistent GDS-9 Progression Milestone proving meaningful active engagement with one Biome. Baseline Mastery combines Route Survey through Landmark Discovery, a threshold of distinct Core-Species Regional Collection, and at least one Field Objective; it cannot require extreme rare RNG or passive Energy alone.

### Landmark
An authored meaningful world location used for orientation, Route Survey or progression. A Landmark is stable world content rather than a randomly spawned opportunity.

### Landmark Discovery
The persistent exact-once record that the player legitimately reached an eligible Landmark. Re-entering the same Landmark does not recreate first-discovery progression or rewards.

### Field Objective
A bounded active GDS-9 task tied to exploration, traversal, world interaction or legitimate collection activity rather than raw presence time. Eligible objectives may grant bounded exact-once Energy rewards.

### Safe Outpost
A protected entry/utility area in a field Biome. Baseline field Safe Outposts provide a Secure Point and Recovery Anchor and may expose a permitted Vault Access Point; major environmental hazards do not overlap their immediate protected arrival area.

### Safe Route
A viable baseline non-premium path through an unlocked Biome using ordinary GDS-3 locomotion. Optional shortcuts/deep routes may require progression utility, but core region participation cannot depend on a paid traversal product.

### Travel Node
A GDS-9 world travel access point unlocked through legitimate region/outpost discovery. Ordinary travel between eligible nodes is quality-of-life and is unavailable while the player has Acquisition-In-Progress.

### Habitat
A sub-region inside a Biome with its own authored creature eligibility, terrain identity and encounter characteristics. Habitats may differ by Species pool, weights, density, traversal shape, hazard exposure and ordinary World Cycle eligibility.

### Deep Habitat
An optional or progression-relevant interior Habitat with a distinct creature/density/hazard profile. It remains part of its parent Biome and cannot bypass the parent region's Access Unlock.

### Spawn Context
The authored GDS-9 eligibility context used when generating a genuinely new World Creature. It may include Biome, Habitat, ordinary World Cycle phase, static zone tags and authorized Availability; it affects future instances only and cannot reroll a surviving Creature Instance.

### Encounter Population Budget
The bounded authored population limit controlling how many relevant public World Creature opportunities may exist in an area/session context. It may scale within defined limits for server population/performance but is never unbounded.

### Encounter Lifetime
The bounded idle lifetime of an ordinary unclaimed World Creature before it may expire and release population capacity. Idle lifetime expiry does not override a valid Engagement Claim, Capture Attempt, Provisional Capture or Transport Custody.

### Rare Encounter Stability Window
The minimum authored idle-opportunity period given to a publicly actionable Protected Variant so that an ordinary player has a meaningful chance to notice and pursue it before ordinary expiry.

### World Cycle
A deterministic repeating ordinary world-context phase sequence, such as Day/Dusk/Night, that may affect future Spawn Context eligibility. It is not a GDS-11 Server Event, does not reroll existing instances and must not intentionally reset as a private favorable phase through server hopping.

### Hazard
An authored environmental condition that creates traversal/capture risk without becoming direct player-versus-player combat. Hazards may cause temporary avatar failure/Recovery but cannot destroy or reroll finalized secured ownership, Energy, Access Unlocks, historical discovery or Vault progression.

### Party
An explicit consent-based temporary GDS-10 group of up to four players used for coordination and eligible cooperative gameplay. Party membership grants no ownership, wallet, Vault, capture, access or progression authority over another member.

### Party Leader
The Party member with transient grouping authority to invite eligible players, remove members and disband the Party. Leadership does not extend to another member's creatures, Energy, Vault, claims, custody or progression.

### Party Invite
A temporary request to join a Party. Joining requires explicit acceptance; ignoring, declining or expiry carries no gameplay penalty.

### Party Seat
One occupied membership slot in a Party. The baseline Party has a maximum of four simultaneous Party Seats.

### Social Ping
A bounded predefined GDS-10 coordination signal, such as a location, creature sighting, objective, return route or hazard warning. A Ping does not create claim, discovery, progression or hidden information authority.

### Shared Objective
An objective explicitly authored to allow more than one player to participate toward personal completion. Party membership alone does not complete a Shared Objective.

### Eligible Contribution
A meaningful objective-specific action performed by one player that qualifies that player for personal Shared Objective credit or a Collaboration Reward. Raw proximity, spectating and AFK Party presence are insufficient.

### Collaboration Reward
A bounded exact-once personal GDS-10 reward for an eligible Shared Objective participant. It is game-originated Economy value, not a transfer from another player's Energy Wallet.

### Friendly Challenge
An explicit opt-in, non-destructive session competition between consenting players. Baseline Friendly Challenges use no creature/Energy staking, direct-combat damage or involuntary persistent loss.

### Showcase
A read-only social presentation of legitimately owned or earned collection/progression state. Viewing a Showcase does not grant discovery, ownership or economy authority.

### Visitor Access Policy
The Vault owner's player-controlled GDS-10 rule determining the eligible audience for read-only visits, subject to later GDS-15 platform/safety constraints.

### Party Rejoin Grace
A short same-server reservation window after an unexpected disconnect during which a former Party member may recover their Party Seat. Absence during grace creates no objective/reward contribution.

### Live Content
Authored GDS-11 content whose availability, configuration or emphasis may change over calendar time without rewriting already finalized player ownership, progression or provenance.

### Global Event Window
A GDS-11 wall-clock availability interval shared across ordinary servers for a live-content program, season or Event Occurrence. Joining or changing servers does not restart it.

### Event Occurrence
One uniquely identifiable scheduled or authorized GDS-11 live-event occurrence with defined wall-clock start/end semantics and reward/participation identity. Multiple Server Event Instances may belong to the same Event Occurrence.

### Server Event
A time-bounded GDS-11 multiplayer encounter or world-state change presented within a Server Session under an Event Occurrence.

### Server Event Instance
The session-local realization of an Event Occurrence in one Server Session. Public progress, Rift state and event-created world opportunities are session-scoped unless a personal outcome is explicitly finalized.

### Event Template
The authored GDS-11 rule/content package from which Event Occurrences are created. It defines eligibility, phases, objectives, allowed modifiers, rewards and encounter modes.

### Event Phase
A player-facing lifecycle stage of a Server Event Instance such as Announced, Active, Resolving or Ended.

### Event Zone
A temporary GDS-11 world area/overlay used by an active Server Event Instance. It may host objectives, hazards or prospective Spawn Context changes but does not permanently rewrite world access.

### Rift
A dynamic Event Zone or event focal point that temporarily creates event-specific world activity. A Rift is not inherently a Creature Instance and does not itself become player-owned.

### Event Spawn Modifier
An explicitly GDS-11-authorized prospective modification to future Spawn Context eligibility/weights during the applicable event context. It never rerolls a surviving or owned Creature Instance.

### Event Objective
A GDS-11 personal or shared objective associated with an Event Occurrence and its participation/reward rules.

### Event Contribution
Objective-specific active participation by one player in a GDS-11 event. Raw presence, spectating, AFK time or Party membership alone are insufficient.

### Event Completion Record
A persistent exact-once historical fact that a player legitimately completed or qualified for a defined event outcome. It is not automatically a currency, creature or power bonus.

### Event Participation Reward
A bounded exact-once personal reward created by valid Event Contribution under an Event Occurrence.

### Event Multi-Award Encounter
An explicitly authored GDS-11 exception to ordinary single-award encounter allocation in which several eligible participants may each receive a distinct Personal Event Capture Opportunity. The shared event target itself is not duplicated as one Creature Instance.

### Personal Event Capture Opportunity
A separately instantiated event Capture Opportunity created for one qualified participant by an Event Multi-Award Encounter. It has its own Creature Instance identity, lifetime and acquisition path and is not automatic Secured Ownership.

### Event Resolution Grace
A bounded post-end period allowing already-active event acquisition/reward resolution to finish. It admits no new participation, does not restart event modifiers and cannot be extended by server hopping.

### Event Cooldown
A bounded GDS-11 period preventing immediate repeated activation/reward cycling for the same event context. A persistent/global cooldown cannot be reset by changing servers.

### Trading
The GDS-12 direct player-to-player ownership-transfer system for eligible Secured Creature Instances. Baseline trading is explicit, bilateral, same-server, creature-for-creature barter with no Energy transfer, gifting, auction house or offline listing.

### Trade Access Milestone
A non-paid persistent progression milestone authorizing baseline trading after required onboarding and Starter Region Mastery, subject to any stricter GDS-15 platform-safety eligibility.

### Trade Session
A temporary explicit two-player same-server negotiation context for one bilateral creature exchange.

### Trade Invite
A temporary request to open a Trade Session. It requires explicit acceptance and creates no ownership or reservation by itself.

### Trade Offer
The exact set of Creature Instances one participant currently proposes to transfer in an active Trade Session.

### Trade Revision
The semantic version of the complete bilateral Trade Offer. Any semantic offer change creates a new revision and invalidates prior Ready/Final Trade Confirmation state.

### Trade Reservation
A temporary authoritative reservation preventing an offered Creature Instance from simultaneously entering another ownership-changing/destructive action. Reservation is not ownership transfer.

### Trade Ready
A participant's explicit revision-specific statement that the current Trade Revision is ready for final review.

### Final Trade Confirmation
A participant's explicit confirmation of the exact immutable final Trade Revision after both sides are Ready.

### Trade Commit
The all-or-nothing authoritative operation that revalidates both players/offers/restrictions/capacity/concurrency and applies the exchange.

### Trade Ownership Finalization
The exact-once persistent GDS-12 ownership transition produced by a successful Trade Commit. Every included Creature Instance changes to its receiving owner atomically from the player's perspective.

### Trade Cooldown
A persistent wall-clock interval after successful Trade Ownership Finalization during which the received Creature Instance cannot be offered again.

### Trade Restriction
An authored transfer-eligibility rule. Baseline states are **Tradeable**, **Time-Locked**, and **Account-Bound**.

### Trade History Entry
Append-only provenance metadata recording that a legitimate player-to-player ownership transfer occurred without replacing original acquisition provenance.

### Commercial Offer
A GDS-13 player-facing proposal to exchange platform-paid value for a clearly identified MonsterVault Product Grant.

### Durable Entitlement
A successfully finalized paid account entitlement intended to remain available across sessions, such as an authorized cosmetic collection or bounded convenience expansion.

### Consumable Product Grant
A paid deterministic grant applied once rather than remaining as a reusable entitlement.

### Cosmetic Entitlement
A paid GDS-13 presentation/status entitlement that changes appearance or expression without changing Creature Instance identity, claim authority, rarity odds, progression milestones or ownership.

### Convenience Entitlement
A paid durable account capability reducing bounded friction without bypassing required active progression or finite-opportunity competition.

### Commercial Capacity Expansion
A bounded GDS-13 Convenience Entitlement increasing Collection Capacity and/or Display Capacity without increasing Production Slots, Production Buffer, Offline Production Window, spawn odds or capture priority.

### Starter Value Bundle
A one-time deterministic GDS-13 Commercial Offer containing clearly listed cosmetic value plus a small bounded Energy grant and/or approved convenience value.

### Paid Acceleration
A deterministic paid benefit reducing limited progression friction for content already obtainable through ordinary play. GDS-13 baseline only authorizes the small bounded starter form and never grants active Progression Milestones.

### Purchase Pending
A temporary commercial state in which a purchase was initiated but MonsterVault has not yet established verified Commercial Finalization.

### Commercial Finalization
The exact-once persistent GDS-13 result of a verified successful purchase. Retry/reconnect cannot duplicate the authorized grant.

### Commercial Reconciliation
The safe process used when a durable paid entitlement becomes unavailable/revoked under a legitimate downstream platform/account outcome. Reconciliation may remove future entitlement benefit but cannot silently delete Secured Creatures or create negative Energy/debt.

### Presentation Layer
The GDS-14 player-facing representation of authoritative game state. Presentation may communicate or animate state but is not itself the owner of gameplay state.

### HUD
The always-available or contextually visible in-play information surface used while ordinary world control remains active.

### Modal Screen
A presentation state that intentionally owns input focus and suppresses conflicting world actions until closed or resolved.

### Panel
A non-full-screen information surface that may coexist with world view when it does not create ambiguous input focus.

### Critical State Banner
A high-priority concise presentation of a state that materially changes what the player can safely do, such as Protected Load Failure, Acquisition-In-Progress, unresolved Overflow, Event Resolving or trade final review.

### Context Prompt
The GDS-14 visible presentation of the current GDS-3 Active Context and its Primary Interact action.

### Action Feedback
Immediate presentation confirming that an attempted action was accepted, rejected, pending, completed or changed state.

### Toast
A short non-modal informational message that does not require acknowledgment and may not obscure critical gameplay.

### Persistent Notice
A non-modal notice that remains accessible until its underlying unresolved state is resolved or safely dismissed.

### Confirmation Dialog
A modal review requiring deliberate acceptance before a consequential action.

### Destructive Confirmation
A stronger confirmation pattern used for irreversible/high-value ownership or transfer actions.

### Focus Target
The currently selected actionable UI element for keyboard/gamepad navigation.

### Input Glyph
The presentation symbol/text representing the current input binding for an action.

### Reduced Motion
A baseline GDS-14 accessibility setting reducing/substituting non-essential camera/UI motion while preserving semantic feedback.

### Readability Mode
A group of GDS-14 accessibility options improving text size, contrast, background support, icon labels and visual clarity without changing gameplay rules.

### Semantic Redundancy
Presentation of critical meaning through more than one understandable channel, such as text plus icon/shape or visual plus audio, so meaning does not depend on color or sound alone.

### Platform Eligibility
A GDS-15 Roblox-authoritative per-player result indicating whether a platform-regulated feature is currently permitted for that user/account/context.

### Policy-Gated Feature
A MonsterVault feature whose availability or behavior must respect Roblox-provided policy/eligibility information rather than a hard-coded local age/country rule.

### Communication Eligibility
The platform-authoritative result governing whether a player may participate in a given text/direct/social communication capability.

### Structured Communication
A predefined non-freeform message/action vocabulary such as Social Pings, where players select authored meanings instead of entering arbitrary public text.

### User-Generated Text
Text whose semantic content is chosen by a player and displayed to one or more other users.

### Filtered User Text
User-Generated Text that has successfully passed the appropriate Roblox-authoritative filtering flow for its intended audience.

### Safety Restriction
A MonsterVault experience-level limitation applied to unsafe/disruptive behavior, such as suppressing directed social requests, restricting trading/social interaction, kicking or banning from the experience.

### Safety Action
An experience-level moderation result that changes access/social capability without rewriting unrelated legitimate collection/economy history.

### Platform Report Flow
Roblox's built-in or platform-authoritative reporting capability for users/content/communication.

### Social Isolation
A safe fallback state in which optional directed social interaction is unavailable while solo/core gameplay remains functional.

### Content Maturity Target
The intended Roblox content-maturity envelope for MonsterVault launch content. GDS-15 targets a broad Minimal-to-Mild envelope and requires revalidation for materially higher-maturity content.

### Offline Progression
Any progression accrued while the player is not actively present in the experience. GDS-7 explicitly authorizes **bounded Vault Passive Production** from finalized Production Assignments, limited by the Offline Production Window and Production Buffer cap. GDS-8 defines the resulting Energy/economic effects. Other offline progression remains unauthorized unless an owning later specification defines it.

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
A calendar-based availability period intended to have the same temporal boundary across servers. GDS-11 specializes live-event use as **Global Event Window**; joining or changing servers does not restart either concept.

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
A GDS-9 world-defined safe location to which GDS-2/GDS-3 Recovery may return a Player Character. An anchor must be currently valid/unlocked and never counts as Extraction Completion by itself.

### Input Mode
The currently dominant control family: touch, keyboard/mouse, or gamepad. Changing Input Mode changes prompts/control presentation, not baseline gameplay capability or progression state.

### Server Authority
A technical principle, not a gameplay rule: security-sensitive state is ultimately validated by the server. Detailed technical contracts belong to Technical Architecture.

## Naming Rule

A term used as a formal state, resource, ownership concept, rarity, event type or progression stage must have one canonical meaning. Reusing the same label for unrelated mechanics is prohibited once the specification reaches `Design Complete`.
