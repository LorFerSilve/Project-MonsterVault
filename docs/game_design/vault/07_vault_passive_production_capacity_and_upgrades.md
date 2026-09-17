# Vault/Base, Passive Production, Capacity, and Upgrades

> **Status:** Design Complete  
> **Owning GDS phase:** GDS-7 — Vault/Base, Passive Production, Capacity, and Upgrades  
> **Authority:** Personal Vault semantics, secured-creature intake and placement, production assignment, passive/offline production, pending-output buffering, capacity categories, overflow resolution integration, vault upgrades, display/visitor permissions, lifecycle/reassignment behavior, and vault-specific fairness/anti-abuse invariants  
> **Depends on:** `../00_design_authority.md`, `../01_game_overview.md`, `../global_rules/02_global_game_rules_and_session_model.md`, `../player/03_player_character_interaction_and_onboarding.md`, `../creatures/04_creatures_collection_and_ownership.md`, `../capture/05_capture_contesting_transport_and_extraction.md`, `../rarity_mutations/06_rarity_mutations_traits_and_variant_value.md`, `../GLOSSARY.md`

## 1. Purpose and Player Fantasy

The Vault is the persistent home of a player's secured collection. It must make collection progress visible and useful without turning MonsterVault into a game that rewards leaving the client running.

The player-facing contract is:

> **Creatures I bring home remain mine, I can organize and show them safely, deliberately assign some of them to useful vault roles, return later to bounded accumulated output, and expand my vault without risking creatures I already earned.**

GDS-7 turns `Make your vault legendary` into a concrete persistent layer while preserving the active exploration/capture loop as the product's primary acquisition identity.

## 2. Scope

GDS-7 owns:

- the Personal Vault as persistent player-owned base state;
- the post-GDS-5 secured-creature intake destination;
- vault-facing Stored, Production-Assigned, Display-Placed, and Overflow-Held semantics;
- production assignment and exclusivity;
- passive production eligibility;
- online versus offline elapsed-time production semantics;
- bounded offline accrual;
- persistent Pending Vault Output and claim/finalization behavior;
- production interruption/reassignment/checkpoint semantics;
- collection/vault, production-slot, output-buffer, and display capacity categories;
- capacity expansion semantics and overflow-resolution integration;
- persistent Vault Upgrades and prospective parameter changes;
- onboarding-facing first-vault-use requirements;
- variant/Trait integration boundaries;
- visitor inspection and non-owner permission boundaries;
- lifecycle/server/device consistency;
- anti-AFK, anti-double-production, anti-retroactive-upgrade, and anti-capacity-abuse invariants;
- downstream obligations for economy, world, social, live content, trading, monetization, presentation, analytics, and Technical Architecture.

## 3. Explicit Non-Goals

GDS-7 does **not** define:

- ownership creation, Release, Creature Lock, or one-owner semantics — GDS-4;
- capture, Transport Custody, Secure Point extraction, or the ownership-finalization trigger — GDS-5;
- Species Rarity, Mutation generation, Trait identity, Variant Signature, or Protected Variant classification — GDS-6;
- currencies, resource names, exact production rates, upgrade prices, income curves, sinks, biome unlock prices, or prestige — GDS-8;
- world topology, biome layout, public Secure Point placement, or spawn tables — GDS-9;
- friend/party rules, visit matchmaking, social bonuses, PvP, or grief systems — GDS-10;
- server-event production modifiers, seasonal schedules, event rewards, or live cadence — GDS-11;
- trade flow, transfer eligibility, or market behavior — GDS-12;
- paid capacity products, subscriptions, paid boosts, or purchase prices — GDS-13;
- final vault UI, art, room layout, animations, audio, building controls, or accessibility settings — GDS-14;
- platform policy implementation — GDS-15;
- telemetry implementation and retention experiments — GDS-16;
- persistence schemas, clocks, job scheduling, datastore transactions, distributed locking, server/client modules, or exact idempotency implementation — Technical Architecture.

## 4. Canonical Terminology

Shared terminology is normalized in `../GLOSSARY.md`.

### Personal Vault
The player's persistent collection/base context. Its durable state is independent of any one Roblox Server Session even if a current server renders a visitable physical representation.

### Vault Intake
The post-finalization placement step that makes a newly Secured Creature available to the owner's normal vault/collection roles. Vault Intake never creates ownership; GDS-5 Secured Ownership Finalization already did so.

### Vault-Eligible Creature
A Secured Creature that is not Released, not in a conflicting future transfer state, and not Overflow-Held for unavailable ordinary capacity.

### Production Assignment
The explicit association of one Vault-Eligible Creature with one eligible Production Slot.

### Production Slot
A finite vault role that allows one assigned eligible Creature Instance to generate passive output under the current production configuration.

### Production Checkpoint
The semantic act of finalizing accrued production up to a specific boundary before assignment, rate, ownership, capacity, or upgrade conditions change.

### Pending Vault Output
Persistent produced value that has accrued validly but has not yet been moved into the downstream spendable resource state. Exact resource types belong to GDS-8.

### Output Buffer
The finite capacity that limits Pending Vault Output. Once full, further passive production for the affected output stops prospectively until capacity becomes available.

### Offline Accrual Horizon
A finite tuneable maximum elapsed-time interval for which ordinary passive production may accrue while the player is not actively present. It prevents unbounded catch-up after arbitrarily long absence.

### Display Placement
A non-owning vault presentation assignment that exposes a Secured Creature for the owner's/visitors' inspection. Display does not itself generate production or transfer rights.

### Vault Capacity
The normal capacity available for vault/collection placement as consumed by GDS-4 ordinary secured collection semantics.

### Vault Upgrade
A persistent finalized improvement to an owned vault capability such as eligible capacity, Production Slots, Output Buffer capacity, display capacity, or an explicitly defined facility capability.

### Over-Capacity State
A safe restricted state in which currently owned creatures exceed currently valid ordinary capacity. Ownership remains intact; new ordinary acquisition/assignment is constrained until resolved.

## 5. Vault Persistence Model

### VA-01 — The Personal Vault is persistent player state
Vault ownership, durable upgrades, collection-facing placements, production assignments, display assignments, and valid Pending Vault Output survive ordinary reset, disconnect, reconnect, server change, device change, and controlled server lifecycle.

### VA-02 — The current rendered vault is not the authority
A missing, unloaded, delayed, or stale vault room/model does not mean durable vault state disappeared. Presentation must recover from persistent facts rather than rewriting them from the current scene.

### VA-03 — One owner has one logical vault state baseline
Different servers/devices may render the owner's vault, but they do not create independent economic copies of the same vault.

### VA-04 — Cross-server vault representation cannot duplicate production
The same Creature Instance cannot legitimately produce once per server representation or once per concurrently connected device. Production derives from one persistent assignment timeline.

### VA-05 — Vault state requires trusted persistence readiness
Consequential vault actions and production claims are unavailable before GDS-2 Persistence Ready. Protected Load Failure never fabricates an empty authoritative vault.

## 6. Post-Capture Vault Intake

### VI-01 — GDS-5 finalization precedes Vault Intake
A creature becomes owned only at GDS-5 Secured Ownership Finalization. Vault Intake consumes that result; it never moves the ownership boundary earlier or later.

### VI-02 — Normal valid capacity places the new creature safely
When ordinary eligible capacity exists, the newly secured instance becomes available in the Collection Registry/Vault as a normal secured placement, defaulting to Stored unless an explicit onboarding/system rule assigns another safe role.

### VI-03 — Capacity race uses GDS-4 Overflow-Held
If capacity becomes unavailable only after a legitimate acquisition began, finalization still succeeds and the instance becomes Overflow-Held under GDS-4 rather than being deleted.

### VI-04 — Intake does not auto-consume, auto-release, or auto-convert duplicates
A duplicate or low-rarity creature remains a distinct secured instance. Any future conversion/sink needs explicit GDS-8 or later authority.

### VI-05 — Protected Variant locking applies before destructive vault actions
A GDS-6 Protected Variant arrives with its required GDS-4 Creature Lock state. Intake/rearrangement cannot bypass that protection.

### VI-06 — Intake preserves exact instance identity
Species, Mutations, Traits, Variant Signature, provenance, lock state, and other persistent instance identity remain attached to the same Creature Instance.

## 7. Vault Placement and Role Model

A normal secured Creature Instance may participate in vault-facing states/roles without changing ownership:

```text
Secured Creature
    ├── Stored
    ├── Production-Assigned
    ├── Display-Placed (presentation association)
    └── Overflow-Held (restricted safety state)
```

Display Placement may coexist with Stored or Production-Assigned semantics because it is a presentation association, not a second economic copy. An instance may not occupy multiple Production Slots simultaneously.

### VP-01 — Stored is the default non-producing role
A Stored creature remains safely owned and selectable but produces no passive output merely because it exists in the collection.

### VP-02 — Production requires explicit assignment
Owning or displaying a creature alone does not generate passive resources. The owner deliberately assigns a Vault-Eligible Creature to an eligible Production Slot.

### VP-03 — One instance occupies at most one Production Slot
A Creature Instance cannot be assigned to two slots, two vaults, two servers, or two owners simultaneously for production.

### VP-04 — Overflow-Held creatures cannot produce
Overflow-Held is an integrity state, not free economic capacity. An Overflow-Held creature cannot occupy an ordinary Production Slot or create passive output until ordinary eligibility is restored.

### VP-05 — Released creatures cannot remain assigned
Finalized Release ends ownership and production eligibility. Accrued production must be checkpointed before the destructive outcome finalizes.

### VP-06 — Future transfer cannot create dual production
If GDS-12 later transfers ownership, production accrued before transfer finalization belongs to the previous owner's valid timeline and is checkpointed once; the same instance cannot keep producing for both owners.

### VP-07 — Creature Lock does not block ordinary safe assignment
Creature Lock protects destructive/transfer actions. It does not prevent safe storage, production assignment, or display unless a later explicit rule requires otherwise.

### VP-08 — Display Placement does not confer economic authority
Displaying an instance does not grant visitors production rights, ownership, collection credit, or the ability to modify/release/transfer it.

## 8. Passive Production Contract

### PP-01 — Passive production is assignment-based, not presence-based
Production comes from valid Production Assignments and elapsed time. Merely keeping the game open, standing AFK, or joining a server grants no additional baseline entitlement.

### PP-02 — Baseline online and offline elapsed time use the same production rule
While a valid Production Assignment exists, eligible elapsed time contributes under the same authored base production semantics whether the owner is actively connected or offline. Active gameplay/event bonuses may later modify future intervals only under their owning authority.

### PP-03 — Offline production is bounded
Ordinary offline accrual is limited by both:

- finite Output Buffer capacity; and
- a finite Offline Accrual Horizon.

Whichever bound is reached first stops further ordinary accrual for the affected output until a later valid interval begins under available capacity.

### PP-04 — No continuous offline live-world presence is required
Offline output is derived from persistent assignment state, authored production parameters, and eligible elapsed time. The design does not require the player's creature to remain simulated in a live server while the owner is offline.

### PP-05 — Production output enters Pending Vault Output
Valid passive production accumulates as persistent Pending Vault Output. It is not silently lost on ordinary disconnect/server change once checkpointed/persisted.

### PP-06 — Claiming output is exact-once
Moving Pending Vault Output into the GDS-8 spendable resource state happens once per amount. Reconnect, repeated input, duplicate delivery, or multi-device interaction cannot claim the same produced amount twice.

### PP-07 — A full Output Buffer stops production prospectively
When the relevant buffer is full, additional elapsed time does not accumulate hidden debt/backlog. Creating buffer space later does not retroactively backfill time during which the buffer was already full.

### PP-08 — Offline horizon overflow is not banked debt
Elapsed time beyond the Offline Accrual Horizon does not become a delayed future payout. Returning after a very long absence yields the bounded eligible amount, not unlimited catch-up.

### PP-09 — No negative passive production
Ordinary elapsed-time calculation never creates a negative production debt because clocks, sessions, or configurations changed. Technical clock handling belongs to TA.

### PP-10 — Production parameters must be inspectable enough for decisions
Before the player deliberately assigns/reassigns a creature where meaningful output differences exist, they must be able to understand the relevant output role/profile sufficiently to make a reasoned choice. Exact final UX belongs to GDS-14.

## 9. Production Checkpoint and Reassignment Semantics

### PC-01 — Reassignment checkpoints the old interval first
Before a creature leaves a Production Slot or a different creature takes that slot, valid elapsed production under the old assignment is finalized into Pending Vault Output up to the change boundary.

### PC-02 — New assignment applies only prospectively
The new creature/profile begins producing from the accepted reassignment boundary. It cannot reprice or regenerate elapsed time that belonged to the previous assignment.

### PC-03 — Server change does not reset assignment time
Changing servers/devices does not restart, duplicate, or erase the persistent assignment timeline.

### PC-04 — Removing a creature from production stops future accrual
Once the removal/reassignment outcome is finalized, later elapsed time does not accrue for the old slot assignment.

### PC-05 — Release/transfer checkpoints before ownership ends
Where an assigned creature is legitimately released or later transferred, accrued output is checkpointed exactly once before the ownership change finalizes. No post-transfer/release output accrues to the former owner.

### PC-06 — Parameter changes split elapsed time
When an upgrade, event modifier, Trait effect configuration, or other authorized production parameter changes, output before the effective boundary uses the old valid parameters and output after it uses the new valid parameters.

### PC-07 — No retroactive best-rate selection
The player cannot wait, purchase an upgrade, equip a better creature, or activate a modifier and then have the entire preceding elapsed interval recomputed at the newer/higher rate.

## 10. Traits, Rarity, Mutations, and Production

### RP-01 — Rarity is not an automatic production multiplier
Common/Legendary Species labels and Mutation Frequency Bands do not by themselves define a universal production-rate ladder.

### RP-02 — Mutations do not automatically increase output
A Mutation may be prestigious with zero economic effect. Any specific Mutation production effect must be explicitly authorized/balanced downstream.

### RP-03 — Traits may support bounded production specialization
GDS-6 Traits may influence production preference, output category, efficiency, or another bounded situational dimension when GDS-8/content defines the exact effect.

### RP-04 — Trait utility should create choices rather than one mandatory best creature
Production design should favor situational profiles, role fit, or tradeoffs instead of making one Trait universally dominant across all vault output.

### RP-05 — Owned identity remains stable when effects rebalance
Changing a Trait/Mutation downstream production effect does not reroll the Creature Instance's identity. Only the prospective effect changes under authorized balance control.

### RP-06 — Protected Variants remain protected in production
Production assignment, collection claiming, automation, or bulk vault actions cannot bypass Creature Lock for later destructive/transfer actions.

## 11. Capacity Model

GDS-7 distinguishes four baseline capacity concepts:

1. **Vault Capacity** — normal eligible secured-creature placement capacity;
2. **Production Slot Capacity** — number of simultaneous Production Assignments;
3. **Output Buffer Capacity** — maximum Pending Vault Output by relevant resource/buffer semantics;
4. **Display Capacity** — number/extent of persistent display placements supported by the current vault configuration.

These capacities are related but are not interchangeable.

### CP-01 — Vault Capacity never rewrites ownership
Capacity limits normal placement/use, not whether a legitimately secured creature exists.

### CP-02 — Production Slot Capacity limits simultaneous production
Owning more creatures than Production Slots creates assignment choice, not automatic parallel production from every owned creature.

### CP-03 — Display Capacity is non-economic by baseline
More display space increases visible/status expression but does not automatically create more production output.

### CP-04 — Output Buffer Capacity limits stored pending output, not past ownership
Reducing or filling the buffer does not remove creatures. It only constrains future passive accumulation.

### CP-05 — Known full Vault Capacity constrains new ordinary capture through GDS-5
GDS-7 consumes GDS-5's rule that known full capacity/unresolved overflow blocks normal new capture initiation.

### CP-06 — Overflow-Held cannot be used as extra production storage
Overflow does not provide Production Slots, display rights, or hidden output generation.

### CP-07 — Baseline earned Vault Upgrades are durable
Ordinary persistent progression upgrades, once validly finalized, do not expire or downgrade merely because the player disconnects, changes servers, or is inactive.

### CP-08 — Temporary/paid capacity expiry must preserve GDS-4 safety
If GDS-11/GDS-13 later authorizes temporary capacity, expiry cannot delete secured creatures and must provide a non-payment resolution path. The exact product is not authorized here.

### CP-09 — Over-capacity blocks expansion, not ownership access
While unresolved over-capacity exists, the game may block new ordinary acquisitions and new assignments, but the player retains access needed to inspect, choose, reorganize, unlock where valid, release voluntarily, or otherwise resolve the state.

### CP-10 — Permanent free progression must include a viable capacity path
Normal play must provide a non-payment route to maintain a functional collection/vault and resolve ordinary capacity pressure. Exact costs/progression cadence belong to GDS-8.

## 12. Vault Upgrade Model

Vault Upgrades are persistent capabilities that may include:

- Vault Capacity expansion;
- additional Production Slots;
- Output Buffer expansion;
- Display Capacity expansion;
- explicitly defined facility capabilities;
- bounded production-efficiency capabilities whose numeric effects belong to GDS-8.

### UP-01 — Upgrade purchase/earn action is explicit
A durable upgrade cannot be triggered by passive proximity, closing UI, repeated network delivery, or accidental modal spillover.

### UP-02 — Finalized upgrade applies once
Retry/reconnect cannot grant the same paid/earned upgrade twice or duplicate its derived capacity.

### UP-03 — Upgrades are prospective
An upgrade affects future capacity/output intervals from its finalization boundary. It does not retroactively multiply past production or create historical output that never fit the prior buffer/horizon.

### UP-04 — Baseline durable upgrades have no mandatory construction wait
The baseline semantic is that a finalized Vault Upgrade becomes usable once its owning progression/economy transaction finalizes. GDS-7 does not require arbitrary real-time construction timers.

### UP-05 — Upgrades do not mutate Creature Instance identity
Expanding or improving the vault does not reroll Species, Mutation, Trait, Variant Signature, provenance, or ownership.

### UP-06 — Upgrade categories are not automatically paid
GDS-7 defines capability surfaces, not monetization. Whether any convenience/capacity product exists belongs to GDS-13 and must preserve free viability.

### UP-07 — Upgrade rollback cannot silently delete value
If a future temporary entitlement disappears, existing secured creatures and already-finalized Pending Vault Output remain safely accounted for; new activity may be restricted until the state is valid.

## 13. Pending Output and Claim Semantics

### PO-01 — Pending Vault Output is persistent
Once accrued/checkpointed, pending output survives normal lifecycle like other finalized persistent state.

### PO-02 — Pending output is distinct from spendable economy balance
GDS-8 owns the spendable resource/currency semantics. GDS-7 owns the fact that valid pending production exists and can be claimed once.

### PO-03 — Claim is an explicit consequential action or clearly disclosed automatic transfer
The final UX may use manual claim or an explicitly designed automatic collection point, but either form must preserve exact-once transfer and clear player feedback. GDS-14 owns presentation.

### PO-04 — Partial claims are allowed if downstream resources require them
A claim can move all or a defined subset of pending output, provided the remaining amount stays persistent and exact-once accounting remains coherent.

### PO-05 — Buffer limits apply per authorized output semantics
GDS-8 may define one or multiple output/resource types. Buffer partitioning may therefore differ by type, but no type receives unlimited hidden storage merely because another buffer is full.

### PO-06 — Claiming does not require staying online afterward
Once the output claim finalizes, subsequent disconnect does not undo it or recreate the pending amount.

## 14. Offline Production Semantics

### OF-01 — Offline accrual begins from a valid persisted assignment state
Logging out with no Production Assignment creates no passive production merely because the player owns creatures.

### OF-02 — Clean logout is not required
An unexpected disconnect does not require a special save ritual. Production eligibility derives from the last authoritative persisted assignment/checkpoint state.

### OF-03 — Offline time follows wall-clock elapsed semantics
Offline production uses real elapsed time between authoritative boundaries, subject to the finite Offline Accrual Horizon and buffer capacity. It does not count only time spent in a particular server.

### OF-04 — Server hopping cannot refresh the Offline Accrual Horizon
Changing servers/rejoining does not repeatedly grant new offline windows for the same elapsed interval.

### OF-05 — Multiple devices cannot multiply offline accrual
Concurrent or alternating connections reference one production timeline and one set of assignments.

### OF-06 — AFK and offline do not create separate stacked rates
The baseline does not grant one rate for being online and another additive rate for offline accrual over the same elapsed interval.

### OF-07 — Long absence is bounded but non-punitive
After the horizon/buffer cap is reached, further time simply produces nothing until valid capacity/time conditions resume. The player does not incur debt, creature loss, or punishment.

### OF-08 — Offline production does not reserve live-world opportunities
Assigned creatures do not occupy public spawns, capture claims, event slots, or other players' world opportunities while the owner is offline.

## 15. Visitor and Social Vault Boundaries

### VS-01 — Visitors may inspect but not own
A visitor can be allowed to view the owner's vault, displayed creatures, and authorized public status information without gaining Species/Mutation/Variant Discovery, ownership, or transfer rights.

### VS-02 — Visitors cannot alter consequential owner state by baseline
Visitors cannot rearrange production assignments, claim output, spend upgrade resources, unlock/release creatures, alter provenance, or transfer ownership under baseline GDS-7.

### VS-03 — Visitor presence does not grant baseline production multiplier
Merely having more visitors/friends present does not automatically multiply passive output. GDS-10/GDS-11 may later define bounded explicit social bonuses.

### VS-04 — Displayed creatures remain protected secured state
Visitors cannot capture, damage permanently, steal, consume, or convert displayed creatures through ordinary interaction.

### VS-05 — Social representations may be session-local
A visitor's physical access/session representation may be temporary while the owner's durable vault state remains persistent.

### VS-06 — Visitor interaction cannot block the owner from core vault use
Crowding, visit sessions, or another player's stale UI cannot permanently lock the owner out of production/output/capacity management.

## 16. Onboarding Vault Contract

The first-session flow must remain compatible with GDS-1/GDS-3/GDS-5:

1. the first secured creature has guaranteed usable normal capacity;
2. Vault Intake is visible as the consequence of successful extraction;
3. the player can inspect the new specific Creature Instance without complex management overhead;
4. the player is introduced to Stored versus Production-Assigned meaning through a real, reversible assignment action;
5. the first production assignment cannot require payment;
6. the first meaningful vault/progression choice remains compatible with the roughly six-minute GDS-1 target;
7. guidance may be skipped/replayed without fabricating output or upgrades;
8. onboarding cannot leave the player in Overflow-Held or unusable zero-slot production state due to baseline configuration.

The first creature need not be rare/mutated, and GDS-7 does not fabricate a special high-value variant for onboarding.

## 17. Failure, Interruption, and Recovery

### Reset/avatar failure
Vault ownership, assignments, upgrades, and checkpointed Pending Vault Output persist. Reset does not duplicate output or change assignment time.

### Client disconnect
The server/client session ends, but the persistent assignment timeline continues into bounded offline accrual where eligible.

### Server change
The same vault state and assignment timeline continue. A new server does not start a second production clock.

### Server shutdown/crash
Already persisted/checkpointed vault state remains authoritative. Production does not depend on orderly shutdown being the only chance to save. Exact reconciliation belongs to TA.

### Persistence unavailable
Consequential vault actions are blocked under Protected Load Failure; a blank vault is not fabricated.

### Representation failure
If a creature/model/display fails to render, ownership/assignment facts remain intact and presentation is recoverable.

## 18. Abuse and Exploit Cases

### Multi-server production duplication
The same Creature Instance cannot produce independently in multiple server instances.

### Reassignment backdating
Switching to a higher-output creature cannot apply its rate to time accumulated before the switch.

### Upgrade backdating
Buying a stronger upgrade cannot multiply output from the hours before the upgrade finalized.

### Buffer backfill exploit
Expanding/emptying a full buffer does not retroactively pay for time during which production was capped.

### Offline-horizon refresh exploit
Rapid reconnect/server hopping cannot repeatedly reset the horizon for the same elapsed time.

### Release/transfer double-output
Output is checkpointed once before ownership ends; old and new owner cannot receive the same interval.

### Overflow farming
Overflow-Held creatures produce nothing and cannot be used as hidden extra Production Slots.

### AFK stacking
Leaving the client running does not stack a second entitlement on top of the same elapsed-time production interval.

### Duplicate claim delivery
Pending output can move to spendable state once only.

### Visitor griefing
Visitors cannot block or modify owner production/capacity/upgrade state by baseline.

## 19. Presentation and Accessibility Requirements

GDS-14 must provide clear player-facing treatment for at minimum:

- Stored versus Production-Assigned versus Overflow-Held;
- which Creature Instance occupies each Production Slot;
- current output role/profile where decision-relevant;
- Pending Vault Output and Output Buffer fullness;
- offline accrual cap/horizon status where relevant;
- why production stopped;
- capacity type currently full;
- upgrade effect before confirmation;
- Protected Variant/Creature Lock state;
- visitor versus owner permissions.

Critical distinctions cannot rely solely on color, audio, hover, tiny text, precision dragging, or free-form chat.

Core assignment/claim/upgrade flows must remain practical on touch, controller, and keyboard/mouse.

## 20. Tuneable Parameters

The following are tuneable without reopening GDS-7 when semantics remain intact:

- initial Vault Capacity;
- initial Production Slot Capacity;
- initial Output Buffer Capacity;
- initial Display Capacity;
- Offline Accrual Horizon duration;
- per-resource buffer sizes;
- authored production rates/output profiles defined with GDS-8;
- bounded Trait/Mutation production modifiers authorized downstream;
- upgrade step magnitudes;
- presentation timing/animation delays that do not change economic finalization.

Tuning must not violate exact-once output, prospective-only parameter changes, bounded offline accrual, overflow restrictions, or free viability.

## 21. Downstream Obligations

### GDS-8 — Economy, Progression, Unlocks, and Pacing
Must define output resources, base production rates, Trait/Species production profiles if used, upgrade costs, capacity progression cadence, sinks, inflation controls, and long-term pacing while preserving prospective-only/checkpoint semantics.

### GDS-9 — World, Biomes, Exploration, Spawning, and Hazards
Must integrate the Vault/Secure Point fiction and access path without moving the GDS-5 ownership boundary or requiring offline live-world presence.

### GDS-10 — Social Play
Must define visit discovery, parties/friends, visitor access, collaboration bonuses if any, and anti-grief rules without granting visitors owner authority.

### GDS-11 — Events / Live Content
May define prospective event production modifiers, temporary facility bonuses, or vault-facing event goals, but cannot retroactively reprice elapsed intervals or falsify provenance.

### GDS-12 — Trading
Must checkpoint assigned production before transfer finalization, preserve exact instance identity, and ensure the same interval/instance cannot produce for both owners.

### GDS-13 — Monetization
Must preserve a viable free capacity/progression path, cannot make payment the only overflow resolution, and cannot delete creatures/output when a temporary entitlement expires.

### GDS-14 — Presentation / Accessibility
Must make role, capacity, output, cap, assignment, upgrade, visitor permission, and protection states legible across supported devices.

### GDS-15 — Platform / Safety
Must review any future visitor/social/purchase surfaces where platform constraints affect vault interactions.

### GDS-16 — Retention / Analytics
May instrument assignment, production, claim, capacity, return, and upgrade funnels but cannot experimentally create hidden individualized output based on spending or covertly override bounded accrual/value-integrity rules.

### Technical Architecture
Must implement one persistent vault/assignment timeline, durable checkpoints, bounded elapsed-time accrual, buffer caps, exact-once claims, prospective configuration boundaries, cross-server/device concurrency control, and safe persistence without weakening these player-facing semantics.

## 22. Open Questions

There are **zero GDS-7-blocking open questions**.

Exact resource names, production rates, capacity numbers, upgrade prices, Trait effect values, visual vault layout, visit matchmaking, social bonuses, event modifiers, monetized products, UI presentation, and technical persistence/clock algorithms remain explicitly downstream/content/tuning-owned.

## 23. Change Control

Material changes to any of the following require reopening GDS-7 and relevant revalidation:

- Personal Vault as persistent session-independent state;
- post-finalization Vault Intake rather than a new ownership boundary;
- explicit Production Assignment requirement;
- one Creature Instance per Production Slot and no multi-server duplication;
- Overflow-Held creatures producing no passive output;
- passive production based on one elapsed-time assignment timeline;
- online/offline baseline using the same production semantics;
- bounded offline accrual through Output Buffer plus Offline Accrual Horizon;
- persistent Pending Vault Output and exact-once claim;
- Production Checkpoint before reassignment/ownership/parameter changes;
- prospective-only reassignment and upgrade effects;
- separate Vault, Production Slot, Output Buffer, and Display capacities;
- durable baseline earned upgrades;
- non-owner visitors lacking consequential owner authority;
- non-payment overflow/capacity resolution viability.

Numeric tuning and final presentation do not reopen GDS-7 while these semantics remain intact.

## 24. Design Complete Checklist

- [x] Personal Vault persistence/authority is defined;
- [x] GDS-5 intake integration is defined;
- [x] Stored/Production/Display/Overflow semantics are defined;
- [x] production assignment and exclusivity are defined;
- [x] passive/offline production semantics are defined;
- [x] bounded elapsed-time and buffer behavior are defined;
- [x] claim/checkpoint/reassignment semantics are defined;
- [x] rarity/Mutation/Trait boundaries are defined;
- [x] capacity categories and overflow integration are defined;
- [x] Vault Upgrade semantics are defined;
- [x] visitor/non-owner boundaries are defined;
- [x] onboarding behavior is defined;
- [x] lifecycle/failure semantics are defined;
- [x] anti-abuse requirements are defined;
- [x] downstream authority boundaries are explicit;
- [x] zero GDS-7-blocking open questions remain.

**GDS-7 specification result: DESIGN COMPLETE.**
