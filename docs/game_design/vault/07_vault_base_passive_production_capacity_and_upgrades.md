# Vault/Base, Passive Production, Capacity, and Upgrades

> **Status:** Design Complete  
> **Owning GDS phase:** GDS-7 — Vault/Base, Passive Production, Capacity, and Upgrades  
> **Authority:** Personal Vault semantics, secured-creature storage/placement, production assignment, bounded passive/offline production, production claiming, collection-capacity interaction, vault upgrade semantics, visitor permissions, Secure Point integration, and vault-facing progression boundaries  
> **Depends on:** `../00_design_authority.md`, `../01_game_overview.md`, `../global_rules/02_global_game_rules_and_session_model.md`, `../player/03_player_character_interaction_and_onboarding.md`, `../creatures/04_creatures_collection_and_ownership.md`, `../capture/05_capture_contesting_transport_and_extraction.md`, `../rarity_mutations/06_rarity_mutations_traits_and_variant_value.md`, `../GLOSSARY.md`

## 1. Purpose and Player Fantasy

The Vault is the persistent home for the collection promised by MonsterVault's product fantasy. It must turn a list of owned creatures into something visible, legible, useful, and progressively more impressive without making ownership fragile or forcing the player into always-online idle play.

The player-facing contract is:

> **When I bring a creature home, my Vault safely preserves it, lets me decide how to store, display, or assign it, creates bounded passive value from deliberate assignments, and grows with my progression without deleting or silently rewriting anything I already own.**

The Vault serves four product functions:

1. **home and identity** — a persistent personal base/laboratory that makes collection progress visible;
2. **collection management** — safe storage, placement, capacity resolution, and protected high-value handling;
3. **bounded production** — assigned secured creatures can contribute passive output under explicit caps and rules;
4. **progression surface** — upgrades increase usable capacity, production flexibility, display/status expression, and convenience while remaining subordinate to GDS-8 economy/pacing.

## 2. Scope

GDS-7 owns:

- the canonical meaning of the personal Vault/Base;
- player access to their Vault and visitor access semantics;
- collection-capacity semantics consumed by GDS-4/GDS-5;
- storage eligibility and overflow resolution;
- display placement semantics;
- Production Slot and Production Assignment semantics;
- passive production lifecycle;
- bounded offline production and elapsed-time behavior;
- Production Buffer and production-claim semantics;
- production interruption/reassignment behavior;
- vault upgrade categories and non-destructive upgrade behavior;
- capacity reduction/reconciliation semantics;
- Secure Point integration after GDS-5 extraction;
- onboarding-facing first-Vault interactions;
- rarity/Mutation/Trait/Variant handling inside the Vault;
- visitor permissions and anti-grief boundaries;
- persistence and exact-once requirements for claims/upgrades;
- vault-facing presentation/accessibility requirements;
- downstream obligations for GDS-8 through GDS-16 and Technical Architecture.

## 3. Explicit Non-Goals

GDS-7 does **not** define:

- Creature Instance identity, ownership, Release, Creature Lock, or Collection Registry semantics — GDS-4;
- Capture Opportunity, Engagement Claim, Provisional Capture, Transport Custody, extraction, or Secured Ownership Finalization — GDS-5;
- Species Rarity, Mutation/Trait identity, Variant Signature, Variant Discovery, or Protected Variant criteria — GDS-6;
- exact currencies, prices, upgrade costs, resource exchange rates, sell values, income curves, or progression pacing — GDS-8;
- world topology, biome placement, exact Vault entrance/Secure Point world locations, traversal, or spawn rules — GDS-9;
- party ownership, cooperative bases, PvP, theft, visitor social rewards, or broader social permissions — GDS-10;
- live-event production modifiers, event schedules, or seasonal base decorations — GDS-11;
- trading or ownership transfer — GDS-12;
- paid capacity products, subscriptions, premium production boosts, or purchase pricing — GDS-13;
- final UI art, camera choreography, VFX/audio style, or accessibility settings implementation — GDS-14;
- Roblox policy implementation or moderation systems — GDS-15;
- final retention incentives, daily-streak systems, analytics infrastructure, or experimentation platform — GDS-16;
- persistence schema, clocks/timestamp storage, server reconciliation algorithms, DataStore layout, networking, anti-tamper code, or instance architecture — Technical Architecture.

## 4. Canonical Terminology

Shared terms are normalized in `../GLOSSARY.md`.

### Vault
The player's persistent personal base/laboratory context used to manage secured creatures, display collection value, assign creatures to bounded production, claim accrued output, and perform Vault progression actions.

### Vault Access Point
A player-facing world or menu-access interaction that enters the player's Vault context. Exact world placement is owned by GDS-9. Access never changes creature ownership by itself.

### Collection Capacity
The maximum number of Secured Creature Instances that can occupy ordinary usable collection states rather than `Overflow-Held`. It is a logical ownership-usage capacity, not merely the count of visible pedestals.

### Storage Eligibility
Whether a Secured Creature can currently occupy an ordinary non-overflow collection state. Eligibility requires sufficient Collection Capacity and no rule that explicitly restricts the instance from ordinary use.

### Display Slot
A Vault presentation location that may show one eligible Secured Creature. Display capacity is separate from Collection Capacity.

### Production Slot
A Vault assignment location that may accept one eligible Secured Creature for passive production. Production Slot count is separate from Collection Capacity and Display Slot count.

### Production Assignment
The persistent association of one eligible Secured Creature Instance with one Production Slot. A creature can have at most one Production Assignment at a time and cannot simultaneously occupy another mutually exclusive active gameplay role.

### Production Profile
The authored production characteristics used by GDS-7/GDS-8 to determine how an eligible assigned creature contributes output. A Production Profile may depend on Species and explicitly authorized bounded Trait effects; Species Rarity or Mutation presence does not automatically multiply production.

### Passive Production
Accrual generated over elapsed time from valid persistent Production Assignments without requiring repeated player input.

### Production Buffer
The persistent bounded accumulator holding unclaimed passive production output before it is claimed into the owning GDS-8 resource/progression system.

### Offline Production Window
The maximum elapsed-time interval after Active Presence ends for which valid Production Assignments may continue generating Passive Production before the offline cap stops additional accrual.

### Production Claim
The player action that transfers currently claimable Production Buffer value into the owning downstream resource/progression state as one exact-once finalized outcome.

### Vault Upgrade
A persistent progression change that increases or changes an explicitly defined Vault capability such as Collection Capacity, Production Slot count, Production Buffer capacity, Offline Production Window, Display capacity, or approved Vault utility.

### Capacity Reconciliation
The non-destructive process used when effective Collection Capacity becomes lower than the number of ordinarily placed/usable secured creatures. Ownership remains intact; affected instances are deterministically moved to safe restricted state rather than deleted.

### Visitor
A non-owner player temporarily allowed to view or interact with explicitly public/read-only elements of another player's Vault. Baseline visitors receive no management authority.

## 5. Participating Entities and Ownership

### VA-01 — The Vault belongs to one player
Baseline GDS-7 defines one personal Vault authority per player profile. The Vault's persistent upgrade state, assignments, display choices, and production buffer belong to that player.

Shared/guild/co-owned bases are outside the baseline and require later explicit GDS authority.

### VA-02 — Creature ownership remains GDS-4 authority
Placing, storing, displaying, assigning, unassigning, or visiting never transfers ownership. A creature remains the same Secured Creature Instance with the same owner unless a later explicit ownership-transfer system performs a valid transfer.

### VA-03 — Only Secured Creatures participate in ordinary Vault roles
Acquisition-In-Progress, Provisional Capture, and Transport Custody are not eligible for storage, display, production, upgrades, or visitor presentation as owned creatures.

### VA-04 — Overflow-Held creatures remain owned but restricted
An Overflow-Held Creature remains in the Collection Registry but cannot receive a new Production Assignment, become newly displayed, or enter another ordinary active-use role until capacity is resolved.

### VA-05 — Protected Variant semantics remain intact
Protected Variants keep their Creature Lock and stable Species/Mutation/Trait/Variant/provenance identity in every Vault role.

## 6. Collection Capacity and Storage Rules

### CC-01 — Collection Capacity is logical, persistent usable capacity
Collection Capacity controls how many secured instances may occupy ordinary usable collection states. It is not equal to visible Display Slots or Production Slots.

### CC-02 — Capacity never deletes owned creatures
Increasing, decreasing, losing, migrating, or failing to load capacity cannot silently Release, convert, merge, sell, or delete a Secured Creature.

### CC-03 — Overflow-Held is the only baseline capacity safety state
When ordinary capacity is unavailable, GDS-4 `Overflow-Held` is used to preserve ownership with restricted ordinary use. GDS-7 does not create a second hidden overflow inventory.

### CC-04 — Known unresolved overflow blocks ordinary new capture initiation
GDS-5 remains authoritative: unresolved Overflow-Held state or known full ordinary capacity blocks new ordinary capture initiation. GDS-7 must make the resolution path visible and actionable.

### CC-05 — Capacity race after valid capture remains safe
If capacity becomes unavailable after a valid Capture Attempt begins, GDS-5 may still finalize ownership and GDS-4 may place the newly secured creature into Overflow-Held. GDS-7 cannot retroactively invalidate the completed acquisition.

### CC-06 — Free capacity can resolve overflow explicitly
When ordinary capacity becomes available, the owner may choose an eligible Overflow-Held Creature and perform **Resolve Overflow**, moving that same instance into `Stored` ordinary use.

Resolution is exact-instance selection; it does not reroll identity or convert duplicates.

### CC-07 — Capacity resolution does not require destructive action
The player must never be forced to Release a creature solely because capacity changed. Release may be offered as a separate deliberate choice under GDS-4, but increasing capacity or selecting which creature becomes ordinarily usable must remain available where progression permits.

### CC-08 — Reduced capacity triggers Capacity Reconciliation
If effective Collection Capacity falls below the number of currently ordinary-usable owned creatures, the system performs non-destructive reconciliation:

1. ownership is preserved;
2. required active/production assignments beyond the new limits are ended safely;
3. affected creatures move to Stored where capacity permits;
4. excess creatures become Overflow-Held;
5. Protected Variants receive no special deletion/selection exception because no creature is deleted.

The selection order must be deterministic and visible. Player-selected prioritization may be supported, but absence of input cannot create nondeterministic loss.

### CC-09 — Capacity changes are finalized persistent outcomes
A purchased/earned Vault Upgrade that changes capacity applies once. Retry/reconnect cannot duplicate a capacity increase.

## 7. Vault Placement and Display

### DP-01 — Display is presentation, not ownership
A Display Slot references one eligible Secured Creature Instance. Removing it from display returns it to its prior valid collection role without changing ownership.

### DP-02 — Display capacity is independent
A player may own more creatures than can be displayed. Lack of display space never causes overflow by itself.

### DP-03 — One instance cannot occupy multiple physical display slots
A single Creature Instance cannot appear as multiple simultaneously owned display copies merely because the UI/world has multiple pedestals.

### DP-04 — Duplicate Species may be displayed separately
Distinct Creature Instances of the same Species may occupy different Display Slots if each is individually eligible.

### DP-05 — Display preserves exact variant identity
World/collection presentation must preserve the displayed instance's Species, Mutations, relevant Traits, provenance markers, and protection state. A display representation may be simplified for performance but cannot imply a different collectible identity.

### DP-06 — Visitor-visible displays are read-only by default
Visitors may inspect approved public display information but cannot move, Release, unlock, trade, assign, or claim anything from the owner's collection.

## 8. Production Assignment Model

### PA-01 — Production requires deliberate assignment
Passive Production occurs only from eligible Secured Creatures deliberately assigned to Production Slots or from an explicit onboarding default that the player is immediately shown and can change.

### PA-02 — One slot, one instance
Each Production Slot references at most one Creature Instance. One Creature Instance may occupy at most one Production Slot.

### PA-03 — Production Assignment is persistent
A finalized assignment survives ordinary reset, disconnect, reconnect, server change, and future sessions until changed, invalidated by capacity reconciliation, or removed through an owning rule.

### PA-04 — Production uses the same owned instance
Assignment never clones the creature. Display/production representations are views of the same Collection Registry identity.

### PA-05 — Overflow-Held is ineligible
An Overflow-Held Creature cannot start or retain an ordinary Production Assignment. If capacity reconciliation makes an assigned creature Overflow-Held, that assignment ends before further production accrues.

### PA-06 — Creature Lock does not block benign assignment
Creature Lock blocks destructive/future transfer actions under GDS-4 but does not by itself block benign Vault display or production assignment.

### PA-07 — Mutually exclusive active roles must be respected
If a creature is assigned to a later gameplay-active role that is defined as mutually exclusive with Vault production, it cannot simultaneously produce. GDS-7 establishes the single-assignment invariant; owning later systems define their role compatibility.

### PA-08 — Assignment changes preserve accrued output
Changing or removing an assignment does not erase already accrued valid Production Buffer value. Accrual is finalized up to the assignment-change boundary under the previous valid state, then future accrual uses the new state.

## 9. Production Profile and Value Boundaries

### PP-01 — Species may define production role without equating rarity to power
Production Profile may differ by Species or authored role. Species Rarity alone is not a direct production multiplier and does not guarantee higher output.

### PP-02 — Traits may create bounded situational production differences
A Trait may affect production only where its authored effect is explicit, legible, and bounded. Traits must not create one universally dominant mandatory Trait across all production goals.

### PP-03 — Mutations are not automatic production multipliers
Mutation presence, Mutation Frequency Band, Compound status, or Protected Variant status does not automatically increase production. A later explicit mechanical hook requires GDS-6 change compatibility and GDS-8 balancing authority.

### PP-04 — Provenance and Availability do not fabricate output
Legacy/Event-Limited provenance may increase status/desirability but cannot silently create hidden production advantages unless an owning later rule explicitly authorizes a bounded effect.

### PP-05 — Production Profile changes must not rewrite identity
Balance changes may alter future/current production effects under GDS-8 change control, but the Creature Instance's Species, Mutation, Trait, Variant Signature, provenance, and ownership remain unchanged.

## 10. Passive Production Lifecycle

### PR-01 — Production is elapsed-time accrual
Valid Production Assignments generate output as a function of elapsed time and authored/tuned production parameters. The GDS does not require per-frame or per-tick simulation while the player is absent.

### PR-02 — Accrual requires a valid finalized assignment interval
Only elapsed time during which the same instance has a valid Production Assignment contributes to its production.

### PR-03 — Production accumulates into a bounded Production Buffer
Unclaimed passive output goes into the player's persistent Production Buffer until the relevant buffer cap is reached.

### PR-04 — Buffer saturation pauses additional accrual
When the applicable Production Buffer is full, further passive production pauses rather than overflowing into hidden debt, negative time, duplicate queues, or unbounded pending rewards.

### PR-05 — Production never consumes or destroys the assigned creature by default
Baseline Passive Production does not age out, sacrifice, damage, Release, or transfer the assigned creature.

### PR-06 — Production cannot create new Creature Instances
Passive Production yields downstream resources/progression value, not additional owned creature copies unless a later explicit system defines a separate authorized creature-generation mechanic.

### PR-07 — Production does not run before trusted persistence is ready
During Protected Load Failure or before GDS-2 Persistence Ready, the player cannot perform irreversible assignment, upgrade, or claim actions.

### PR-08 — Reconnect does not double-count elapsed time
The same elapsed interval contributes at most once to production accrual. Retry/reconnect/server transition may recompute the same authoritative interval but cannot duplicate it.

### PR-09 — Active and offline accrual share one continuous timeline
Ordinary passive production may continue while the player is actively present and, subject to the Offline Production Window, after leaving. Session boundaries do not restart rates, caps, or elapsed-time accounting.

### PR-10 — Staying connected is not required to preserve baseline passive value
The baseline system must not make AFK connection strictly superior solely because offline elapsed time uses a different hidden multiplier. Deliberate active-play bonuses may later exist under GDS-8/GDS-16, but ordinary passive accrual semantics remain transparent.

## 11. Offline Production

### OP-01 — Offline production is explicitly authorized but bounded
GDS-7 accepts bounded offline production for valid persistent Production Assignments. It is not a live-world simulation and creates no world claims, creature spawns, visitor presence, or event participation.

### OP-02 — Offline Production Window limits elapsed time
After Active Presence ends, passive production continues only up to the configured Offline Production Window or until the Production Buffer fills, whichever occurs first.

### OP-03 — Offline cap does not restart through server hopping
Reconnect, device change, or joining a different server does not create a fresh offline interval for the same absence period.

### OP-04 — Last finalized assignment state governs absence
Only Production Assignments finalized before the end of Active Presence can produce while absent. Unconfirmed client-side drag/drop state does not count.

### OP-05 — Offline production is not event participation
Server Events, world spawns, contest rewards, live captures, and other active-session opportunities do not progress merely because a Vault Assignment exists offline.

### OP-06 — Offline production produces no individualized hidden rate changes
Rates/caps cannot secretly change based on spending history, purchase reluctance, loss-chasing signals, or inferred willingness to pay.

### OP-07 — Offline recap is informational, not a second reward
On return, the game may summarize elapsed production. Closing/reopening the recap cannot claim the same output twice.

### OP-08 — Clock anomalies cannot create unlimited value
Player-facing semantics require bounded accrual by authoritative elapsed time and caps. Technical detection/clock sources belong to Technical Architecture.

## 12. Production Claim Semantics

### PC-01 — Claim transfers buffered value exactly once
A Production Claim transfers the currently eligible claim amount from Production Buffer into the owning GDS-8 resource/progression state as one finalized outcome.

### PC-02 — Claim is idempotent across retries
Repeated network/client requests for the same claim outcome cannot duplicate the reward.

### PC-03 — Partial claim may exist only if explicit
Baseline UX should claim the full currently eligible buffer. If later resource caps require partial claim, the unclaimed remainder stays in the Production Buffer rather than disappearing.

### PC-04 — Claim failure preserves value
If a claim cannot safely finalize, the Production Buffer remains unchanged until the outcome is known. The system must not both remove buffer value and fail to grant the downstream result.

### PC-05 — Visitors cannot claim
Only the Vault owner may claim that Vault's Production Buffer.

### PC-06 — Claim does not mutate assigned creature identity
Claiming output does not reroll Traits, Mutations, provenance, Species, or ownership.

## 13. Vault Upgrades

### UP-01 — Upgrade categories are semantic capabilities
Baseline Vault Upgrade categories may include:

- **Collection Capacity** — number of ordinarily usable secured instances;
- **Production Capacity** — number of Production Slots;
- **Production Buffer Capacity** — maximum unclaimed passive output;
- **Offline Production Window** — maximum eligible offline elapsed time;
- **Display Capacity** — number of visible display placements;
- **Vault Utility/Presentation Unlocks** — approved convenience/status features that do not silently redefine other systems.

Exact level counts, costs, and pacing belong to GDS-8.

### UP-02 — Upgrade application is exact-once
A finalized upgrade applies once and persists. Retry/reconnect cannot grant multiple levels from one cost/payment.

### UP-03 — Upgrade purchase and effect are atomic at player-facing level
The player must not permanently lose the required cost without receiving the finalized upgrade, nor receive the upgrade multiple times for one finalized cost.

### UP-04 — Upgrades do not retroactively invalidate secured ownership
Changes to Vault capacity/slot rules preserve all already-owned creatures. If effective capacity falls, Capacity Reconciliation handles the result non-destructively.

### UP-05 — Upgrade trees cannot require sacrificing protected creatures by default
Creature sacrifice/consumption is not part of baseline Vault upgrades. Any future destructive upgrade mechanic requires explicit GDS-4/GDS-7 change control and protected-variant safeguards.

### UP-06 — Upgrade progression must retain a viable non-premium path
GDS-13 may later monetize bounded convenience/capacity, but baseline GDS-7 requires ordinary play to retain a functional route to sufficient Collection Capacity and core Vault use.

### UP-07 — Temporary capacity is permitted only with safe expiry semantics
If a later system grants temporary capacity, expiration invokes Capacity Reconciliation; it cannot delete or forcibly monetize the affected collection.

## 14. Secure Point and Acquisition Integration

### SP-01 — Secure Point finalization happens before Vault assignment
At validated GDS-5 Extraction Completion, the creature first becomes a Secured Creature through Secured Ownership Finalization. Only afterward may Vault storage/display/production rules apply.

### SP-02 — Extraction never auto-consumes the creature into production
A newly secured creature is not silently sacrificed, sold, converted, or permanently assigned merely because the Secure Point is located at/near the Vault.

### SP-03 — Eligible new creatures default safely
After finalization:

- if ordinary capacity is available, the same instance enters a safe ordinary collection state, normally `Stored` unless an explicit onboarding step assigns it;
- if ordinary capacity is unavailable due to a valid late race, GDS-4 `Overflow-Held` applies;
- Protected Variant Creature Lock remains applied where required by GDS-6.

### SP-04 — Secure Point topology is downstream
The Vault may contain or be adjacent to an eligible Secure Point, but exact world geography, travel distance, and Secure Point distribution belong to GDS-9.

## 15. Onboarding and First Vault Experience

### OB-01 — First Vault visit follows the first secured creature quickly
The onboarding path should demonstrate the home/collection payoff without delaying the first capture. Exact timing is tuned under GDS-3/GDS-16, but the first secured creature should produce a visible Vault consequence.

### OB-02 — The onboarding player learns storage before optimization
The first Vault interaction demonstrates where the secured creature is, that it persists, and how assignment works before exposing complex production optimization.

### OB-03 — Introductory production assignment is reversible
If onboarding guides the player to assign their first eligible creature, the assignment is a real persistent state but may be changed later without destroying the creature.

### OB-04 — First production claim is a real finalized outcome
Onboarding may guide a claim but cannot use fake resource state that later disappears. Any reward applies through the same exact-once Production Claim semantics.

### OB-05 — Guidance Layer does not override state
Skipping/replaying guidance does not duplicate upgrades, assignments, creatures, or production claims.

## 16. Visitor and Multiplayer Semantics

### VS-01 — Owner authority is exclusive by default
Only the owner may manage Collection Capacity resolution, placements, Production Assignments, claims, upgrades, Creature Locks, or Release-related navigation.

### VS-02 — Visitors are read-only unless later authority says otherwise
Baseline visitors may inspect approved displayed creatures and public Vault presentation. They cannot remove, move, claim, unlock, rename through unapproved systems, or otherwise alter persistent owner state.

### VS-03 — Visitor count does not multiply production
Production accrual depends on the owner's valid assignments and configured rules, not on the number of visitors currently present.

### VS-04 — Visitors cannot block owner management
A visitor standing near a pedestal/terminal cannot reserve or monopolize the owner's interaction indefinitely. Owner management retains priority.

### VS-05 — Leaving a visited Vault changes no ownership
Visitor disconnect/server transition simply ends the visit. No creature or output follows the visitor.

### VS-06 — Public status presentation does not grant discovery
Seeing another player's rare/Mutated creature in a Vault does not grant the visitor Species/Mutation/Variant Discovery that GDS-4/GDS-6 require from legitimate securisation.

### VS-07 — Future cooperative interactions require explicit authority
Helping, boosting, gifting, guest production, parties, or shared bases belong to GDS-10/GDS-11/GDS-12 and are not implied by visitation.

## 17. Failure, Interruption, and Recovery

### FR-01 — Ordinary avatar reset does not reset the Vault
Reset/Recovery changes runtime presence but does not erase assignments, upgrades, buffer value, capacity, display state, or secured ownership.

### FR-02 — Disconnect preserves finalized Vault state
Finalized assignment/upgrade/claim outcomes survive ordinary disconnect/reconnect under GDS-2.

### FR-03 — In-flight unfinalized management action resolves deterministically
If a placement/assignment/upgrade/claim action is interrupted before finalization, the player later sees either the prior state or the finalized new state — never a contradictory hybrid that duplicates value.

### FR-04 — Protected Load Failure blocks management
When trusted Persistent Player State is unavailable, the player cannot enter irreversible Vault management using fabricated fallback state.

### FR-05 — Server shutdown does not grant bonus production
A server-originated shutdown ends Active Presence but does not create an extra reward interval. Offline accrual continues only under the ordinary Offline Production Window.

### FR-06 — Buffer/cap state survives server change
Joining another server does not reset Production Buffer capacity, offline timers, assignment timestamps, or upgrade levels.

## 18. Abuse and Exploit Cases

### AB-01 — No assignment cloning
The same Creature Instance cannot be simultaneously assigned to multiple Production Slots through rapid requests, multiple devices, server hopping, or visitor contexts.

### AB-02 — No elapsed-time replay
The same elapsed interval cannot be claimed as production more than once.

### AB-03 — No buffer duplication through retry
Repeated claim requests cannot duplicate output.

### AB-04 — No capacity duplication through retry
Repeated upgrade requests cannot duplicate capacity/slots from one finalized cost/payment.

### AB-05 — No overflow-as-free-production
Overflow-Held creatures cannot produce until ordinary capacity is resolved.

### AB-06 — No visitor extraction
Visitors cannot claim or transfer owner production/creatures.

### AB-07 — No AFK-only superiority by hidden passive rule
The system must not secretly require continuous connection to receive the baseline passive rate when bounded offline production is part of the approved design.

### AB-08 — No server-hop offline-window reset
Changing servers cannot reset the offline cap or create overlapping production intervals.

### AB-09 — No pay-history personalized production
Production rates, caps, or upgrade outcomes cannot secretly personalize based on spending behavior or inferred willingness to pay.

### AB-10 — No rarity-display exploitation into mechanical promise
A Legendary/Extreme/Compound display may signal prestige but cannot imply guaranteed superior passive output unless an explicit production rule says so.

## 19. Presentation and Feedback

The Vault must clearly communicate:

- current Collection Capacity: used / available / overflow state;
- which specific creatures are Stored, Active/Production-assigned, displayed, or Overflow-Held;
- which Production Slot references which exact Creature Instance;
- current Production Buffer amount/cap and whether production is active, paused, or buffer-capped;
- Offline Production Window and return recap where used;
- what a Vault Upgrade changes before the player commits its cost;
- Protected Variant / Creature Lock state before destructive navigation;
- visitor versus owner permissions;
- why an assignment or capture is blocked due to capacity/overflow;
- success/failure/uncertain-finalization feedback for claims/upgrades.

Presentation must never represent one instance as several owned copies merely for visual decoration without clearly distinguishing decorative/non-owned representations.

## 20. Accessibility

Vault management must preserve GDS-3/GDS-14 accessibility direction:

- essential capacity/production states may not rely on color alone;
- touch, keyboard/mouse, and gamepad must expose equivalent management actions;
- drag-and-drop may be offered but cannot be the only way to assign/move creatures;
- critical text/values must remain readable on mobile-size screens;
- timed precision input is not required for claiming or ordinary management;
- production-full/overflow/locked states need text/icon/shape redundancy;
- visitor/owner permission differences must be understandable without relying only on audio;
- reduced-motion presentation may simplify celebratory Vault effects without hiding outcome state.

## 21. Persistence Expectations

The following are Persistent Player State where applicable:

- Vault upgrade levels/capabilities;
- effective Collection Capacity inputs owned by the Vault system;
- Production Slot unlock state;
- finalized Production Assignments by exact Creature Instance identity;
- display placement choices where treated as persistent presentation;
- Production Buffer value and cap state;
- timestamps/semantic boundaries required to calculate bounded elapsed production;
- Offline Production Window capability;
- owner-facing Vault customization/unlocks when later defined.

Creature ownership, Species/Mutation/Trait identity, Variant Signature, provenance, Creature Lock, and discovery remain persisted under GDS-4/GDS-6 authority rather than being duplicated as separate Vault-owned identity.

## 22. Monetization Interactions

GDS-7 authorizes no paid product by itself.

GDS-13 may later consider capacity/convenience or bounded acceleration only if:

- ordinary non-premium play retains viable core Vault use;
- paid capacity expiration, if any, remains non-destructive;
- payment does not fabricate Creature Instances, provenance, Variant Discovery, or reroll already-finalized variants;
- hidden spending-based production personalization is prohibited;
- paid convenience does not make protected high-value creatures unsafe;
- purchase retries remain exact-once;
- any production boost is transparent and bounded under economy/fairness review.

## 23. Analytics and Experimentation Boundaries

Useful GDS-7 design metrics include:

- time from first securisation to first Vault visit;
- first assignment completion;
- first production claim;
- Production Buffer saturation frequency;
- fraction of elapsed offline window commonly used;
- Overflow-Held incidence and median time to resolution;
- Collection Capacity pressure by progression band;
- Production Slot utilization;
- reassignment frequency;
- Vault Upgrade choice distribution;
- visitor/view interaction rates;
- blocked-action reasons.

Experiments may tune numeric rates, caps, presentation, or ordering within approved semantic boundaries. Experiments may not:

- delete/convert owned creatures;
- change ownership semantics;
- permit overflow production;
- duplicate claims;
- covertly personalize production from spending behavior;
- turn Mutation/Rarity into hidden guaranteed power;
- change offline-window semantics per-player without explicit governed authority.

## 24. Tuneable Parameters

The following are tuneable without reopening GDS-7 when semantic rules remain intact:

- starting Collection Capacity;
- capacity per Vault Upgrade step;
- starting/max Production Slot count;
- Production Profile numeric rates;
- Production Buffer caps;
- Offline Production Window duration;
- claim presentation cadence;
- display slot counts;
- upgrade level counts;
- upgrade unlock thresholds owned by GDS-8;
- deterministic capacity-reconciliation ordering policy, provided it remains non-destructive and visible;
- onboarding timing/prompt density.

## 25. Dependencies and Cross-References

- **GDS-1:** visible persistent Vault, active collection identity, flexible sessions, non-loss-dominant product promise.
- **GDS-2:** Persistent Player State, Active Presence, Finalized Outcome, Protected Load Failure, offline elapsed-time rules, cross-server continuity.
- **GDS-3:** Primary Interact, onboarding, input parity, Safe Arrival/Recovery, accessibility semantics.
- **GDS-4:** Collection Registry, Active/Stored/Overflow-Held, Creature Lock, Release, stable ownership/capacity safety.
- **GDS-5:** Secure Point, Extraction Completion, capacity gating, Secured Ownership Finalization.
- **GDS-6:** Species Rarity, Mutation/Trait identity, Variant Signature/Discovery, Protected Variant, stable identity/value fairness.
- **GDS-8:** exact resources, costs, rates, progression unlocks, economic balance and pacing.
- **GDS-9:** world topology, Vault entrance/Secure Point geography.
- **GDS-10:** parties, visitor social interactions, cooperative/competitive base rules.
- **GDS-11:** event production modifiers/seasonal content if any.
- **GDS-12:** future secured-instance ownership transfer.
- **GDS-13:** paid capacity/convenience/boost products.
- **GDS-14:** final UI/UX/art/audio/accessibility presentation.
- **GDS-15:** platform/social safety constraints.
- **GDS-16:** retention/analytics/experiment governance.
- **Technical Architecture:** persistence, timekeeping, exact-once operations, networking, reconciliation, data models, concurrency, anti-tamper.

## 26. Edge-Case Matrix

| Edge case | Required behavior |
|---|---|
| New acquisition finalizes while last capacity slot disappeared after attempt start | Creature remains owned and becomes Overflow-Held |
| Player logs in with more ordinary creatures than current capacity | Capacity Reconciliation; no deletion |
| Capacity upgrade request retries | One upgrade outcome |
| Production claim request retries | One resource-transfer outcome |
| Player disconnects while assignment change is in flight | Prior or finalized new assignment; never duplicate slot occupancy |
| Player changes server while Production Buffer is partially full | Same buffer/cap state continues |
| Player remains offline longer than cap | Production stops at offline window/buffer cap |
| Player opens return recap twice | Same accrued buffer shown; no duplicate reward |
| Buffer is full before disconnect | No additional offline accrual until claimed |
| Assigned creature becomes overflow through capacity reduction | Assignment ends safely before further production |
| Protected Variant is assigned | Allowed; lock stays intact |
| Same creature assignment is submitted to two slots concurrently | At most one assignment survives |
| Visitor tries to claim owner's production | Rejected |
| Visitor sees undiscovered rare variant | No discovery credit |
| Mutation generation rates change while creature is assigned | Owned identity unchanged; production effect only if explicitly rebalanced downstream |
| Player releases an assigned creature through valid GDS-4 flow | Assignment must be removed before/with release; no ghost production afterward |
| Future trade transfers an assigned creature | GDS-12 must clear/reconcile assignment before ownership transfer finalizes |
| Protected Load Failure occurs | No irreversible Vault management on blank fallback state |
| Server shutdown occurs during normal passive accrual | No bonus interval; bounded offline semantics continue |
| Temporary capacity entitlement expires | Non-destructive Capacity Reconciliation |

## 27. Open Questions

There are **zero GDS-7-blocking open questions**.

Exact currencies, upgrade prices, production-rate numbers, starting capacities, offline-window duration, Species production tables, Trait effect values, unlock pacing, active-play bonuses, paid products, world placement, visitor social rewards, final UI/art, and technical persistence/timekeeping are explicitly owned downstream or are tuneable content parameters.

## 28. Design-Complete Checklist

- [x] Purpose and scope are explicit.
- [x] Vault ownership/authority is explicit.
- [x] Collection Capacity and Overflow-Held interaction are deterministic.
- [x] Display and Production Assignment semantics are defined.
- [x] Passive and bounded offline production are defined.
- [x] Production Buffer and exact-once claim semantics are defined.
- [x] Vault Upgrade categories and non-destructive behavior are defined.
- [x] Secure Point/finalization integration is defined.
- [x] Multiplayer visitor behavior is defined.
- [x] Failure/recovery and lifecycle behavior are defined.
- [x] Abuse cases are addressed.
- [x] Rarity/Mutation/Trait boundaries are preserved.
- [x] Presentation/accessibility obligations are defined.
- [x] Persistence expectations are defined.
- [x] Economy/monetization boundaries are consistent.
- [x] Edge cases are covered.
- [x] Cross-references preserve one authoritative owner per rule.
- [x] No implementation-relevant open questions remain.

**GDS-7 authoritative subsystem status: DESIGN COMPLETE.**
