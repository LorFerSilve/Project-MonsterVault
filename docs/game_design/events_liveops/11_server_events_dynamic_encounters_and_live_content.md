# Server Events, Dynamic Encounters, and Live Content

> **Status:** Design Complete  
> **Owning GDS phase:** GDS-11 — Server Events, Dynamic Encounters, and Live Content  
> **Authority:** Global/live availability windows, Event Occurrences, session-local Server Event Instances, event lifecycle/cadence, announcements, participation/contribution, event rewards, Event Spawn Modifiers, rifts/dynamic encounters, event-specific shared/multi-award capture overrides, event Availability, server-hopping rules, event interruption/late-join/shutdown semantics, rotating/seasonal content, event provenance, live-content expansion and event-specific abuse/fairness constraints  
> **Depends on:** ../00_design_authority.md, ../01_game_overview.md, ../global_rules/02_global_game_rules_and_session_model.md, ../player/03_player_character_interaction_and_onboarding.md, ../creatures/04_creatures_collection_and_ownership.md, ../capture/05_capture_contesting_transport_and_extraction.md, ../rarity_mutations/06_rarity_mutations_traits_and_variant_value.md, ../vault/07_vault_base_passive_production_capacity_and_upgrades.md, ../economy_progression/08_economy_progression_unlocks_and_pacing.md, ../world/09_world_biomes_exploration_spawning_and_hazards.md, ../social/10_social_play_cooperation_competition_and_pvp_boundaries.md, ../GLOSSARY.md

## 1. Purpose and Player Fantasy

MonsterVault needs live moments that make the world feel temporarily different and socially alive without teaching players that they must server-hop, pay, remain online indefinitely, or risk previously earned value in order to participate.

The player-facing event contract is:

> **I can notice that something unusual is happening, understand when and where it is available, join while there is still meaningful time, contribute through active play, earn clearly bounded personal outcomes, and encounter temporarily different creature opportunities without an event silently rerolling existing creatures, deleting secured value, restarting when I change servers, or making ordinary progression depend on limited-time luck.**

GDS-11 turns the stable GDS-1 through GDS-10 game into an extensible live world while preserving ownership, scarcity, progression and lifecycle trust.

## 2. Scope

GDS-11 owns:

- the distinction between Global Windows, Event Occurrences and session-local Server Event Instances;
- event lifecycle states and transition semantics;
- scheduled versus dynamically instantiated server events;
- event announcements, lead-in, late joins, resolution and cooldown;
- event participation and personal Eligible Contribution;
- event reward allocation and exact-once personal reward boundaries;
- server-wide cooperative objectives;
- dynamic rifts and Event Zones;
- event-created creature opportunities;
- event-specific shared/multi-award capture overrides;
- prospective event modifiers to Spawn Context;
- Event-Limited and Rotating Availability windows;
- event interaction with Species Rarity, Mutations, Traits and Protected Variants;
- event interaction with Party/social rules;
- event interaction with Energy and progression;
- event interaction with ordinary World Cycle, hazards and travel;
- server-hop fairness;
- disconnect, reset, Recovery, server-shutdown and event-end semantics;
- event provenance and historical completion records;
- seasonal/rotating content semantics;
- live-content disable/hotfix behavior from the player's perspective;
- abuse cases involving AFK participation, alt accounts, occurrence replay, server hopping, event sniping and reward duplication;
- downstream obligations for trading, monetization, presentation, platform safety, retention/analytics and Technical Architecture.

## 3. Explicit Non-Goals

GDS-11 does **not** define:

- player-to-player trading, gifting or event-asset market rules — GDS-12;
- paid event passes, Robux event boosts, commercial loot mechanics or premium event access — GDS-13;
- final event HUD, map presentation, VFX/audio language, countdown visuals or accessibility implementation — GDS-14;
- moderation, user-generated event naming, chat/voice policy or platform-age restrictions — GDS-15;
- retention campaign calendars, daily/weekly quest systems, battle-pass structure, notification strategy or experiment governance — GDS-16;
- networking, clocks, cross-server messaging, matchmaking, sharding, persistence schemas, seeded RNG implementation, event schedulers or anti-cheat implementation — Technical Architecture;
- direct-combat PvP or transport interception;
- rewriting ordinary GDS-5 capture rules outside an explicitly marked event encounter mode;
- a persistent shared MMO world across Roblox servers;
- a new baseline event currency;
- a baseline event multiplier to Vault Passive Production;
- making Event-Limited content mandatory for the ordinary GDS-9 progression graph.

## 4. Canonical Terminology

Shared terms remain authoritative in ../GLOSSARY.md.

### Live Content
Authored content whose availability, configuration or emphasis may change over calendar time without rewriting already finalized player history.

### Global Event Window
A wall-clock availability interval shared across servers for one live-content program, seasonal window or Event Occurrence. Joining another server does not restart it.

### Event Occurrence
One uniquely identifiable scheduled or authorized live-event occurrence with defined wall-clock start/end semantics and reward/participation identity. Multiple Server Event Instances may belong to the same Event Occurrence.

### Server Event Instance
The session-local realization of an Event Occurrence in one Server Session. Its public progress and event-created world opportunities are session-scoped unless a specific personal outcome is finalized.

### Event Template
The authored rules/content package from which one or more Event Occurrences may be created. It defines eligibility, phases, objective semantics, allowed modifiers, rewards and encounter modes.

### Event Phase
A player-facing lifecycle stage such as Announced, Active, Resolving or Ended.

### Event Zone
A temporary world area or overlay used by an active Server Event Instance. An Event Zone may alter future Spawn Context or host objectives/hazards but does not rewrite permanent world access.

### Rift
A dynamic Event Zone or event encounter focal point that temporarily creates event-specific world activity. A Rift is not inherently a Creature Instance and does not itself become player-owned.

### Event Spawn Modifier
An explicitly event-authorized prospective modification to future Spawn Context eligibility/weights during the applicable Event Occurrence/Zone.

### Event Objective
A GDS-11 objective associated with an Event Occurrence. It may be personal or shared and must define Eligible Contribution and reward eligibility.

### Event Contribution
Objective-specific active participation by one player. Raw presence, Party membership, spectating or AFK time alone is not contribution.

### Event Completion Record
A persistent exact-once historical fact that a player legitimately completed or qualified for a defined event outcome. It is not automatically a currency, creature or power bonus.

### Event Participation Reward
A bounded exact-once personal reward created by valid Event Contribution under the applicable occurrence rules.

### Event Multi-Award Encounter
An explicitly authored exception to ordinary single-award encounter semantics in which several eligible participants may each receive a **distinct personal Event Capture Opportunity**. The shared event target itself is not duplicated as one Creature Instance.

### Personal Event Capture Opportunity
A separately instantiated, player-eligible event Capture Opportunity created for one qualified participant by an Event Multi-Award Encounter. It has its own Creature Instance identity, lifetime and capture path and is never a duplicate ownership claim on the shared event target.

### Event Resolution Grace
A bounded post-end period in which already-created/active event opportunities or event resolution may finish according to declared rules. It does not create a new Event Occurrence or extend new participation.

### Event Cooldown
A bounded period preventing immediate repeated activation/reward cycling for the same event context. It may be server-local or personal only when explicitly defined, but changing servers cannot reset a personal/global cooldown intended to persist.

## 5. Event Design Principles

### EP-01 — Events are additive, not mandatory progression gates

Players can complete the ordinary GDS-9 world progression and core collection loop without Event-Limited captures, event completion or repeated live attendance.

Event content may provide collection/status variety and bounded rewards, but mainline Access Unlocks/Region Mastery cannot require Event-Limited Species, Event-Limited Mutations or one scheduled event.

### EP-02 — Events cannot rewrite finalized value

An event may create new opportunities or prospective modifiers but cannot:

- reroll an existing World Creature;
- change an owned creature's Species/Mutation/Trait identity;
- revoke Secured Ownership;
- delete a Secured Creature;
- remove Energy already finalized;
- revoke Access Unlocks;
- erase Landmark/Region Mastery;
- invalidate finalized Production Claims or Vault Upgrades.

### EP-03 — Event timing is wall-clock explicit

A Global Event Window/Event Occurrence has declared wall-clock timing semantics.

Changing servers, resetting the avatar, reconnecting or joining late does not create a fresh private duration.

### EP-04 — Social participation is useful but not coercive

Events may be shared/cooperative but do not require unrestricted chat/voice, direct-combat PvP, Party membership or player-to-player value transfer.

### EP-05 — High-value scarcity remains legitimate

Events may temporarily alter Availability or prospective spawn distributions, but they cannot guarantee that every player receives the same random rare variant unless the event explicitly defines a deterministic personal reward/opportunity.

### EP-06 — No hidden spender-specific event odds

Robux history, Energy spending, premium ownership, inferred willingness to pay, recent losses or commercial engagement cannot secretly change a player's event Species/Mutation/Trait odds under GDS-11.

GDS-13 must explicitly review any later commercial interaction.

## 6. Event Timing Model

### TM-01 — Global Event Windows do not restart per server

A live-content window is anchored to wall-clock boundaries that mean the same thing across ordinary servers.

A server created halfway through a 30-minute occurrence has only the remaining occurrence time; it does not receive a fresh 30 minutes.

### TM-02 — Event Occurrences have stable identity

Every reward-bearing Event Occurrence is distinguishable from prior/future occurrences of the same Event Template.

This identity is used conceptually for exact-once participation/reward and server-hop safety.

### TM-03 — Server Event Instances are session-local

One server's public progress, Rift health/progress, event-created public creatures and event-local world state do not imply a continuously shared cross-server world.

### TM-04 — Server-local variation is allowed inside the same occurrence

Different servers may have different eligible Rift positions, public creature populations or objective progress within authored bounds.

That variation cannot reset global timing or personal exact-once reward eligibility.

### TM-05 — Occurrence end stops new event generation

When the Event Occurrence ends:

- no new participation is admitted unless the template explicitly defines an earlier participation lock;
- no new Event Spawn Modifier generation occurs;
- no new event reward cycle starts;
- already-active resolution follows Event Resolution Grace rules.

### TM-06 — Event cadence is bounded

A Server Event Template must define enough cooldown/spacing that ordinary world play is not permanently replaced by nonstop urgent event prompts.

Exact cadence is tuneable/live-content data.

### TM-07 — Predictable scheduled content uses visible timing

When an Event Occurrence is intentionally scheduled rather than surprise/dynamic, players should be able to understand its availability window through GDS-14 presentation.

Exact notification surfaces belong downstream.

## 7. Event Lifecycle

Baseline lifecycle:

~~~text
Inactive
  -> Announced
  -> Active
  -> Resolving
  -> Ended
~~~

A dynamic low-friction event may omit a long Announced phase but cannot omit required fairness/readability.

### LC-01 — Announced

The event exists conceptually and can communicate:

- event type;
- location/eligible region where applicable;
- time until Active;
- participation prerequisites;
- meaningful reward category;
- whether the event is shared or ordinary single-award.

Announcement itself grants no contribution/reward/claim.

### LC-02 — Active

The event accepts eligible participation, applies authorized prospective modifiers and/or exposes objectives/encounters.

### LC-03 — Resolving

New participation/generation has stopped. The server resolves already-earned contribution, completion, reward and bounded active-acquisition outcomes.

### LC-04 — Ended

No new event-specific participation or generation is possible for that occurrence.

Already finalized persistent outcomes remain.

### LC-05 — Event Resolution Grace is not a fresh event

Grace exists only to avoid unfairly deleting an already-valid event acquisition/reward resolution at the exact wall-clock boundary.

Grace cannot:

- admit new participants;
- reset objectives;
- generate new event creatures;
- restart spawn modifiers;
- be extended by server hopping.

## 8. Event Categories

GDS-11 authorizes the following baseline semantic categories. Exact names/themes are content-authored.

### 8.1 Spawn Surge

Temporarily modifies future Spawn Context in eligible Habitats/Zones.

Examples:

- temporarily enable an Event-Limited Species pool;
- increase eligibility/relative weight of an authored Species set;
- enable an event-specific Mutation eligibility context;
- create Rift-specific creature pools.

Existing instances are unchanged.

### 8.2 Rift / Dynamic Encounter

Creates a temporary Event Zone or focal activity in one server.

A Rift may:

- expose event objectives;
- create future event creature opportunities;
- create event hazards;
- host a shared encounter;
- provide a visible server destination.

A Rift is not itself automatically an owned creature.

### 8.3 Shared Server Objective

Allows multiple eligible players in a Server Event Instance to contribute to one objective.

Reward credit remains personal and contribution-gated.

### 8.4 Event Multi-Award Encounter

An explicit cooperative exception in which multiple qualifying participants may each receive a **distinct Personal Event Capture Opportunity**.

This is the only GDS-11 baseline multi-award creature-acquisition override.

### 8.5 Event Objective Chain

A sequence of clearly bounded personal/shared event objectives within one Event Occurrence.

The chain cannot turn Event-Limited completion into a required mainline world gate.

## 9. Participation Eligibility

### PE-01 — Active Presence is required for live participation

A player must be actively present with trusted persistent state to create irreversible event rewards.

Protected Load Failure cannot be used to create persistent event outcomes.

### PE-02 — World access is not silently bypassed

If an event occurs in a locked Biome, ordinary Access Unlock requirements remain unless the event explicitly relocates/provides an accessible equivalent in an unlocked area.

Party membership does not bypass this rule.

### PE-03 — Events cannot make paid access the only baseline route

GDS-11 authorizes no premium-only participation gate.

### PE-04 — Late join is allowed when meaningful participation remains

A player joining during Active may participate if:

- the occurrence has not locked new participation;
- enough objective time/opportunity remains for the player to make meaningful contribution;
- required world/progression eligibility is satisfied.

Joining after contribution can no longer reasonably be earned must not misleadingly present the player as fully eligible for the main participation reward.

### PE-05 — Participation is personal

Being in a Party with an eligible participant does not create Event Contribution.

### PE-06 — No AFK presence eligibility

Remaining in the Event Zone without meaningful event-specific actions does not create completion/reward eligibility.

## 10. Event Contribution

### EC-01 — Event Contribution uses objective-specific active actions

Eligible Contribution may include:

- completing event interactions;
- traversing event route segments;
- resolving environmental event tasks;
- legitimately completing authored capture-related actions;
- contributing to shared objective steps;
- performing multiple distinct participation actions.

It cannot be raw elapsed presence alone.

### EC-02 — Contribution is legible

A reasonable player must be able to tell whether they are participating and whether they have met the minimum contribution threshold.

Exact UI is GDS-14.

### EC-03 — Contribution is not leader-owned

Party Leaders do not allocate or revoke another player's legitimate Event Contribution.

### EC-04 — Contribution does not copy collection history

A player contributing to a shared event does not gain Species/Mutation/Variant Discovery from another player's capture.

### EC-05 — Event contribution may be session-local until finalized

Partial unfinalized contribution to a Server Event Instance may be lost when that session ends unless the Event Template explicitly finalizes a persistent personal checkpoint.

GDS-11 baseline does not promise cross-server migration of unfinished shared-objective progress.

### EC-06 — Finalized event completion is exact-once

When an Event Completion Record or Event Participation Reward finalizes, reconnect/retry/server transition cannot duplicate it for the same player and Event Occurrence/reward identity.

## 11. Shared Server Objectives

### SO-01 — Server objective progress is session-local by baseline

One Server Event Instance may maintain shared server progress.

Another server participating in the same Event Occurrence may have separate progress.

### SO-02 — Shared progress does not imply shared rewards without contribution

A completed server objective may award all qualifying contributors, but spectators/AFK players do not receive the participation reward merely because the server succeeded.

### SO-03 — No last-hit ownership

For cooperative objectives, the final action that completes the objective does not automatically receive all rewards.

### SO-04 — Party size does not multiply server objective credit

Party membership may coordinate play but does not automatically multiply one action into several units of contribution.

### SO-05 — Kick/Party churn cannot erase earned event contribution

GDS-10 kick-at-finish protection remains applicable to otherwise-valid contribution.

### SO-06 — Shared objective failure is non-destructive

If the server fails to complete an Event Objective, players do not lose Secured Creatures, Energy, Access Unlocks or already-finalized unrelated progression.

## 12. Event Rewards

GDS-11 baseline authorizes three reward classes:

1. **Event Participation Reward** — bounded personal Energy;
2. **Event Completion Record** — persistent historical status/progression fact where authored;
3. **Personal Event Capture Opportunity** — only from an explicitly authored Event Multi-Award Encounter.

No new baseline event currency is created.

### RW-01 — Participation rewards are exact-once

A player can receive a given reward identity at most once per Event Occurrence unless the Event Template explicitly defines distinct repeatable reward instances.

### RW-02 — Energy rewards are bounded active-play Economy Sources

Event Energy does not transfer from another player.

Reward tuning must remain compatible with GDS-8 source/sink and active/passive income balance.

### RW-03 — No raw-presence reward

Joining the server, standing in an Event Zone or being online at event end is insufficient.

### RW-04 — Rewards do not scale automatically with Party size

Each player's reward follows personal eligibility/contribution.

### RW-05 — Reward retries are idempotent from the player's perspective

Duplicate resolution messages, reconnects and server callbacks cannot create duplicate finalized Energy or completion records.

### RW-06 — Event rewards cannot fabricate unrelated milestones

An Event Completion Record does not automatically grant Region Mastery, Landmark Discovery, Species Discovery or Access Unlock unless the owning upstream rule was independently satisfied.

### RW-07 — Mainline progression cannot require event attendance

Event Completion Records may support optional status/content but are not required for the baseline Home Hub -> Starter -> Mid -> Advanced progression graph.

## 13. Event Spawn Modifiers

### SM-01 — Event Spawn Modifiers are prospective only

An Event Spawn Modifier applies only when generating a genuinely new Creature Instance.

It cannot reroll a surviving World Creature or an owned creature.

### SM-02 — Event modifiers may alter eligible pools/relative weights

An event may temporarily:

- enable Event-Limited or Rotating Species;
- change relative Species weights within an eligible context;
- enable event-specific Mutation eligibility;
- change Mutation Frequency context within GDS-6 boundaries;
- activate Rift-specific Habitats/Event Zones.

### SM-03 — Variant Identity remains stable

Once a creature becomes individually actionable, its Species/Mutation/Trait identity follows GDS-6 and cannot change because:

- the event phase changes;
- the Global Event Window ends;
- the player fails capture;
- the player reconnects;
- the player changes server;
- another player joins;
- the player spends Energy/Robux.

### SM-04 — Event modifiers are context-level, not hidden per-player spend personalization

Eligible players in the same relevant Event Context face the same authored prospective event rules except where a transparent gameplay eligibility condition is explicitly defined.

### SM-05 — Existing ordinary opportunities are not forcibly upgraded

Starting an event does not transform already-existing ordinary World Creatures into event variants merely to refresh scarcity.

### SM-06 — Event end is prospective

When the modifier ends, existing event-created Creature Instances retain their identity until their normal/event-declared lifetime or acquisition resolution ends.

## 14. Event Availability and Live Content

### AV-01 — Availability is separate from rarity

Core / Rotating / Event-Limited / Legacy remain GDS-6 Availability concepts and do not create new rarity tiers.

### AV-02 — Event-Limited means obtainability is window-bounded

An Event-Limited creature/variant is ordinarily obtainable only under its authorized live window/context.

Already owned instances remain valid after the window.

### AV-03 — Event end does not delete owned content

When Event-Limited content becomes unavailable, existing Secured Creatures remain owned with stable identity/provenance.

### AV-04 — Returning content does not reroll history

A later rerun may make the content obtainable again, but prior ownership, discoveries and provenance remain.

### AV-05 — Legacy status does not invalidate value

Content that is no longer currently obtainable may be represented as Legacy under GDS-6 rules without changing its owned instance identity.

### AV-06 — Event content cannot retroactively revoke Region Mastery

Adding/removing event pools in a Biome does not change prior GDS-9 mastery history.

## 15. Dynamic Rifts and Event Zones

### RZ-01 — Rifts are temporary world overlays

A Rift may appear in an authored eligible location and create a temporary Event Zone.

It does not permanently alter the world progression graph.

### RZ-02 — Rift placement respects access and Safe Routes

A Rift cannot:

- block the only non-premium Safe Route;
- overlap a Recovery Anchor/Secure Point in a way that makes them unusable;
- require body-blockable PvP traversal;
- force an onboarding player into severe event hazard exposure.

### RZ-03 — Event hazards preserve GDS-9 value safety

Event Hazards may cause temporary Recovery/interruption but cannot delete Secured Creatures, steal Energy, revoke permanent unlocks or rewrite collection identity.

### RZ-04 — Rift expiry does not silently invalidate active acquisition

An accepted active Capture Attempt/Provisional Capture arising from an event must resolve under declared Event Resolution Grace/GDS-5 semantics rather than silently vanishing at the phase boundary.

### RZ-05 — Rifts do not guarantee rare variants by mere presence

A Rift may improve/alter prospective eligibility, but standing near it does not guarantee a Legendary/Extreme/Compound result unless the event explicitly defines such a deterministic reward.

## 16. Event-Modified Ordinary Capture

### OC-01 — Ordinary event creatures remain ordinary single-award by default

A World Creature generated under an Event Spawn Modifier still uses ordinary GDS-5 rules unless explicitly marked as part of an Event Multi-Award Encounter.

### OC-02 — One finite event creature means one ordinary winner

Party membership, Event Contribution or server objective participation does not copy a single public Event-Limited Creature Instance to several owners.

### OC-03 — Claims remain bounded and non-stealable

GDS-5/GDS-10 claim/custody rules remain intact for event-modified ordinary captures.

### OC-04 — Event announcements do not grant reservation

A server-wide creature/event announcement does not create a private Engagement Claim.

### OC-05 — Event end cannot revoke valid custody

If Capture Success already produced valid Transport Custody before the occurrence stops generation, Event Resolution Grace permits the acquisition to finish under GDS-5.

## 17. Event Multi-Award Encounter

This is a narrow explicit exception to ordinary single-award encounter allocation.

### MA-01 — The shared encounter target is not one owned Creature Instance

A Rift boss/objective/shared target may represent event fiction/progress, but it is not duplicated into several owners as the "same" creature.

### MA-02 — Eligible participants may each receive one distinct Personal Event Capture Opportunity

When the shared encounter succeeds, every qualifying participant may become eligible for at most one separately instantiated Personal Event Capture Opportunity for that reward identity.

Each personal opportunity has:

- a distinct Creature Instance identity;
- its own Variant Identity Finalization;
- its own bounded lifetime;
- its own capture/finalization path;
- one eligible recipient/claim domain;
- no shared ownership.

### MA-03 — Personal event opportunities are opportunities, not automatic ownership

Receiving the opportunity does not create a Secured Creature.

The player must still complete the defined event capture path.

By baseline, the event capture path preserves GDS-5 capture/transport/extraction semantics unless the Event Template explicitly defines a narrower presentation variation that does not change ownership finalization.

### MA-04 — Personal opportunity creation requires capture eligibility

The event cannot intentionally create an unusable creature reward when the player's known capacity/eligibility state blocks the defined capture path.

If eligibility is not satisfied, the event must communicate that the player is not currently eligible for that creature-opportunity reward before it is represented as earned.

### MA-05 — No one-instance duplication

Distinct participants' Personal Event Capture Opportunities are separate instances even when they share Species/visual theme.

### MA-06 — Variant generation is independent and prospective

Each personal instance is generated under the declared event context and is fixed no later than becoming actionable.

The game cannot reroll it because another participant received a better/worse result.

### MA-07 — Opportunity lifetime includes fair resolution time

A Personal Event Capture Opportunity receives a bounded Event Resolution Grace sufficient to attempt the declared capture path.

### MA-08 — Disconnect before finalization does not become automatic ownership

Unless a valid Provisional Capture has already reached the GDS-5 controlled-shutdown exception, an unfinalized personal opportunity remains transient.

An Event Completion Record/Participation Reward may persist even if the capture opportunity is lost.

### MA-09 — Server hopping cannot create a second personal opportunity for the same reward identity

Changing servers/rejoining cannot regenerate another Personal Event Capture Opportunity after the player's opportunity was already issued/consumed for that Event Occurrence reward identity.

### MA-10 — Multi-award is explicitly labeled

Players must be able to distinguish:

- ordinary single-award event creatures;
- shared server objectives;
- Event Multi-Award Encounters.

The game must not visually imply that a public single creature will be copied to everyone when it will not.

## 18. Rare Encounter Announcements

### RA-01 — Server-wide announcements are authored event behavior

Natural ordinary rare encounters are not automatically server-announced merely because they are rare.

An Event Template may define a Spotlight/Rift announcement.

### RA-02 — Announced opportunities receive meaningful stability

If an event announces a publicly actionable rare opportunity server-wide, its lifetime/lead-in must provide a genuine chance to travel/participate rather than disappearing almost immediately.

### RA-03 — Centerpiece event design cannot be only one instant first-click prize

If an event is promoted to the whole server as a major cooperative centerpiece, its only meaningful reward cannot be a single immediate first-interact winner.

It must also provide contribution-based personal value or use the Event Multi-Award model.

### RA-04 — Announcements do not reveal hidden Variant details beyond authorized readability

Event presentation may identify the event/category/known rarity context but cannot fabricate secret instance properties not otherwise finalized/perceivable.

## 19. Server Hopping

### SH-01 — Server hopping does not restart Global Windows

The occurrence clock remains unchanged.

### SH-02 — Server hopping does not reset personal exact-once rewards

A reward already finalized for an Event Occurrence/reward identity cannot be earned again simply by changing servers.

### SH-03 — Server hopping does not reset personal event cooldowns intended to persist

A player-scoped Event Cooldown follows its declared persistent wall-clock semantics.

### SH-04 — New servers may contain different session-local opportunities

Because MonsterVault is not one persistent shared MMO world, moving servers may expose a different session-local Event Instance or creature population.

This does not create entitlement to duplicate prior finalized rewards or the same consumed personal event opportunity.

### SH-05 — Event design cannot intentionally require hopping for baseline participation

The baseline event loop must be viable in one ordinary eligible server.

### SH-06 — Guaranteed high-value personal reward rerolls are prohibited

A player cannot repeatedly hop servers to regenerate a guaranteed Personal Event Capture Opportunity/variant roll for the same occurrence identity.

### SH-07 — Event occurrence state never gains fresh duration in a new server

A newly created server uses remaining occurrence time and may decline to instantiate an event if too little meaningful participation time remains.

## 20. World Cycle and Event Interaction

### WC-01 — Event state and ordinary World Cycle are distinct

Day/Dusk/Night remains GDS-9 ambient world context.

An event may layer an Event Spawn Modifier on top of it.

### WC-02 — Event start does not reset the World Cycle

Starting a Rift/Surge does not create a private favorable cycle reset.

### WC-03 — Combined eligibility is prospective

When both World Cycle and Event Context affect spawning, their combined rule applies only to new Creature Instances.

### WC-04 — Event content can declare cycle independence

A Rift-specific pool may ignore ordinary cycle eligibility if explicitly authored, but this does not change existing creatures or the underlying cycle.

## 21. Parties and Social Play

### PS-01 — Parties help coordinate, not duplicate contribution

Party Pings/waypoints may guide members to an event.

Every rewarded player still needs personal Eligible Contribution.

### PS-02 — Party membership does not reserve event creatures

Ordinary event-modified public creatures remain public until valid claim.

### PS-03 — Multi-award eligibility is per participant

One Party member's contribution cannot automatically create Personal Event Capture Opportunities for idle Party members.

### PS-04 — Party removal cannot erase valid contribution

GDS-10 kick-at-finish protection applies.

### PS-05 — Event competition cannot enable direct-combat PvP

No event creates player damage, knockback, Transport Custody theft or body-blocking by default.

### PS-06 — Event communication does not require unrestricted chat/voice

Structured event UI/world feedback and Social Pings must be sufficient for core participation.

## 22. Energy and Economy Interaction

### EE-01 — Event Energy rewards are bounded

Event reward quantities are tuneable but must remain compatible with GDS-8 economy bands and cannot make ordinary Vault production or field rewards irrelevant.

### EE-02 — No event Energy transfer

Rewards are game-originated personal sources.

### EE-03 — No arbitrary event Energy loss

Event failure cannot directly fine/deduct a player's existing Energy unless a future separately authorized explicit purchase/action is accepted by the player.

### EE-04 — No baseline event production multiplier

GDS-11 does **not** authorize Party/event/season multipliers to Passive Production, Production Profile, Production Buffer capacity or Offline Production Window.

A future proposal requires GDS-7/GDS-8/GDS-11 change control and revalidation.

### EE-05 — No event-only mainline progression ransom

Players do not need Event Energy/rewards to keep ordinary permanent collection/progression from being taken away.

### EE-06 — Repeatable event rewards require distinct authored reward instances

A recurring Event Template may reward each Event Occurrence separately, but one occurrence/reward identity cannot be replayed by reconnect/server hop.

## 23. Capture Difficulty and Event Modifiers

### CD-01 — Events may tune capture difficulty for new event opportunities

An Event Template may alter challenge timing/windows/steps within GDS-3/GDS-5 capability constraints.

### CD-02 — Event difficulty cannot change identity after engagement

A hard/easy capture result does not reroll Species/Mutation/Trait.

### CD-03 — Event difficulty does not create paid protection

GDS-11 authorizes no paid requirement to finish an already-valid event capture.

### CD-04 — Event challenge variation remains cross-device capable

Touch, keyboard/mouse and gamepad retain equivalent semantic capability.

## 24. Event End, Disconnect, Reset and Shutdown

### IR-01 — Event end stops new generation but does not erase finalized outcomes

Energy/completion/secured ownership already finalized remains.

### IR-02 — Active Capture Attempt receives explicit resolution

An event phase ending during a valid accepted attempt does not silently despawn the target without declared resolution.

### IR-03 — Valid Transport Custody follows GDS-5

Event end does not cancel valid custody. Extraction remains available through the declared resolution path.

### IR-04 — Avatar reset/Recovery does not count as event completion

Reset uses ordinary GDS-2/GDS-3/GDS-5 interruption behavior.

### IR-05 — Disconnect does not preserve raw participation

Unfinalized session-local contribution may be lost.

Finalized personal rewards/completion records remain exact-once persistent.

### IR-06 — Server shutdown does not auto-complete the event

A shutdown does not award all players event completion or all visible event creatures.

### IR-07 — Controlled shutdown preserves only already-valid GDS-5 provisional custody

Protected Shutdown Finalization remains the narrow GDS-5 exception.

### IR-08 — Event Resolution Grace is bounded by wall-clock semantics

Reconnect/server hop cannot reset/extend it.

## 25. Live Content Rotation and Seasons

### LS-01 — Event Templates are reusable without rewriting history

The same template may recur as new Event Occurrences with distinct occurrence identity.

### LS-02 — Seasonal themes may group occurrences

A Season may group content/Availability windows conceptually, but GDS-11 does not define a paid/free battle pass or mandatory daily retention loop.

### LS-03 — Rotation changes future availability only

Removing an Event Template/Species from rotation does not alter already-owned instances.

### LS-04 — Returning seasons preserve historical provenance

A creature acquired in a prior occurrence retains that occurrence/source provenance even if the same Species returns later.

### LS-05 — New live content is additive

Future Event Templates may introduce new event pools, Rifts/objectives and optional completion records without invalidating old ownership/mastery.

### LS-06 — Historical completion is never silently redefined

If a future season introduces a new completion tier, it is a new explicit record/milestone rather than changing what an old Event Completion Record meant.

## 26. Event Disable, Hotfix and Invalid Content

### HF-01 — New event activation may be disabled prospectively

If an event is broken/unsafe/exploitable, the live system may stop creating new Server Event Instances or new event opportunities.

### HF-02 — Disable does not revoke legitimate finalized value by default

Already finalized Energy, Event Completion Records and Secured Creatures are not silently deleted merely because the template is disabled.

### HF-03 — Active opportunities resolve safely when possible

A disable/hotfix should prefer stopping new generation while allowing valid active acquisition/reward resolution to complete within bounded safety rules.

### HF-04 — Contradictory/invalid state is not "fixed" by rerolling owned creatures

Technical remediation belongs downstream; GDS-11 does not authorize rewriting owned Variant Identity.

## 27. Provenance

### PV-01 — Event acquisitions record event-source provenance

When a Creature Instance is legitimately secured through event context, provenance can include the Event Template/Occurrence/source category needed to distinguish that acquisition history.

### PV-02 — Provenance is historical, not a hidden power multiplier

Event provenance does not automatically increase production/capture power.

### PV-03 — Event end does not strip provenance

A Rotating/Event-Limited creature remains historically event-acquired after the event.

### PV-04 — Multi-award personal instances preserve distinct identity

Two participants awarded the same Species through one event receive distinct Creature Instances and may receive different legitimate Variant Identities under the same declared context.

## 28. Abuse and Exploit Guardrails

GDS-11 must resist at minimum:

- server hopping to restart event duration;
- server hopping to repeat exact-once event rewards;
- server hopping to reroll one guaranteed personal event opportunity;
- reconnecting to duplicate Event Completion Records;
- Party churn to duplicate participation rewards;
- AFK/idle Event Zone reward leeching;
- alt-account reward credit without contribution;
- last-hit reward monopolization;
- event announcement spam;
- using Rifts to block Safe Routes/Secure Points/Recovery Anchors;
- Event Zone body-blocking/direct-combat griefing;
- claim cycling to reserve single-award event creatures indefinitely;
- event-end despawn during valid acquisition;
- post-claim variant rerolls;
- paid/spender-specific event odds;
- event attendance as required mainline progression;
- repeated reward minting from one occurrence;
- event start resetting World Cycle;
- production multiplier abuse;
- new-server full-duration resets;
- hotfixes deleting legitimate finalized value;
- duplicate copies of one shared event target masquerading as separate ownership.

## 29. Presentation and Feedback Requirements

GDS-14 must make the following player states understandable:

- event announced / time to start;
- event active / time remaining;
- event location/eligible region;
- participation prerequisites;
- whether objective is personal/shared;
- contribution state;
- whether minimum contribution has been met;
- single-award versus Event Multi-Award encounter type;
- public claim/custody state;
- event ending / Resolving;
- Event Resolution Grace when relevant;
- reward finalized;
- reward already claimed for occurrence;
- event Availability ending/ended;
- event opportunity blocked by player eligibility/capacity;
- no longer enough time for new meaningful participation.

Critical event meaning cannot rely solely on color, audio, tiny text or unrestricted chat.

## 30. Accessibility

Events must preserve GDS-3/GDS-14 obligations:

- semantic actions available across supported Input Modes;
- no mandatory voice/text chat;
- no color-only event state;
- no audio-only countdown/rare announcement;
- event capture mechanics not dependent on device-exclusive precision;
- reduced-motion alternatives for major Rift/event presentation where motion could obstruct play;
- readable time/state information through non-audio channels.

Exact implementation remains GDS-14.

## 31. Persistence Expectations

### Persistent

- finalized Event Participation Rewards already transferred to Energy;
- finalized Event Completion Records;
- Secured Creatures acquired through event capture;
- resulting Species/Mutation/Variant Discovery when GDS-4/GDS-6 conditions are met;
- event provenance on owned instances;
- explicitly persistent personal event cooldowns where authored.

### Session-scoped/transient by baseline

- Server Event Instance progress;
- Rift position/state;
- public event creature population;
- active Event Zone geometry/state;
- unfinalized Event Contribution;
- Social Pings;
- Personal Event Capture Opportunities before finalization;
- unclaimed public single-award opportunities.

## 32. Monetization Interactions

GDS-11 authorizes no commercial event mechanic.

GDS-13 must preserve at minimum:

- no paid restart/extension of Global Event Window;
- no paid duplicate Event Participation Reward;
- no hidden spender-specific event Species/Mutation odds;
- no payment required to suppress event spam/griefing;
- no premium-only baseline participation route;
- no payment required to complete an already-valid capture/transport;
- no paid claim priority;
- no paid conversion of another player's single-award event creature into the purchaser's ownership;
- any randomized paid interaction must undergo separate commercial/platform review and cannot be inferred from GDS-11.

## 33. Analytics and Experimentation Boundaries

Design-relevant event metrics include:

- announcement-to-arrival conversion;
- eligible participation rate;
- late-join rate;
- contribution-qualified rate;
- Shared Objective completion/failure;
- time to contribution threshold;
- Event Participation Reward distribution;
- event capture opportunity issue/attempt/secure rate;
- ordinary single-award event claim contention;
- multi-award opportunity issuance and loss/interruption;
- server-hop rate during active occurrence;
- duplicate reward/retry attempts;
- AFK/zero-contribution population;
- Rift/event-zone traffic;
- event-related Recovery/interruption;
- Event-Limited collection acquisition;
- event economy output relative to baseline active/passive Energy;
- participation by device/input class.

Experiments may tune:

- announcement lead time;
- active duration within authored bounds;
- cooldown/cadence;
- Event Zone locations from eligible authored sets;
- objective target values;
- contribution thresholds;
- Energy reward quantities;
- prospective event spawn weights;
- event creature lifetimes/stability;
- Event Resolution Grace duration;
- capture challenge numeric difficulty;
- recurrence frequency.

Experiments may **not**:

- reset occurrence timing per server/player;
- alter finalized owned Variant Identity;
- create hidden spender-specific event odds;
- silently switch single-award to multi-award semantics;
- make AFK presence reward-eligible;
- duplicate exact-once rewards;
- enable body-blocking/direct-combat PvP;
- turn Event-Limited content into a mandatory baseline progression gate;
- enable Passive Production multipliers without change control;
- revoke finalized value.

## 34. Tuneable Parameters

Tuneable without reopening GDS-11 while semantics remain intact:

- event announcement lead time;
- Event Occurrence duration;
- Event Cooldown/cadence;
- minimum remaining time for late-join participation;
- Event Resolution Grace duration;
- Rift location set;
- objective targets;
- Eligible Contribution thresholds;
- Energy reward amounts;
- event spawn weights/eligible pools;
- event creature Encounter Lifetime;
- Rare Encounter Stability within event;
- event hazard parameters;
- capture challenge numeric tuning;
- number of distinct Event Occurrences in a season.

Semantic/change-control decisions:

- wall-clock Global Window semantics;
- stable Event Occurrence identity;
- session-local Server Event Instances;
- prospective-only spawn modifiers;
- no reroll of existing/owned instances;
- exact-once reward semantics;
- personal contribution requirement;
- no AFK reward;
- no event mainline progression requirement;
- ordinary event captures remaining single-award by default;
- explicit Event Multi-Award Encounter model;
- distinct personal Creature Instances rather than copying one target;
- no baseline event production multiplier;
- no direct-combat PvP/interception;
- server hopping not resetting occurrence/reward/opportunity identity;
- non-destructive event end/hotfix behavior.

## 35. Dependencies and Downstream Obligations

### GDS-12 — Trading and Player Economy

Must preserve event provenance/Variant Identity when event creatures are later transferred and must not treat event participation state as implicit transfer authority.

### GDS-13 — Monetization

Must review all paid event interactions, probability disclosures, passes/boosts/entry products and commercial fairness against GDS-11 no-hidden-spender-odds/no-paid-claim-priority boundaries.

### GDS-14 — Presentation, UI/UX, Feedback, Accessibility

Must expose timing, event phase, location, contribution, encounter allocation, single/multi-award state, reward status, Availability and resolution grace accessibly.

### GDS-15 — Roblox Platform, Social Safety, Moderation

Must review event announcements, communication, age-appropriate urgency/FOMO, randomized/commercial intersections and reporting/blocking where social events create friction.

### GDS-16 — Retention, Discovery, Analytics

May define live cadence/return loops and experimentation governance without converting events into coercive mandatory attendance, hidden personalization or value instability.

### Technical Architecture

Must implement authoritative clocks/occurrence identity, session-local event state, cross-server-safe exact-once reward identity, prospective modifiers, event state replication, contribution validation, event-opportunity issuance, safe resolution/shutdown, rate limiting, live disable/hotfix and anti-abuse without changing GDS-11 semantics.

## 36. Edge-Case Matrix

| Situation | Required behavior |
|---|---|
| Server starts halfway through occurrence | Uses remaining wall-clock time; no fresh full duration |
| Server starts with too little meaningful time | May skip event instance rather than misleading players |
| Player joins during Announced | Can prepare; no contribution yet |
| Player joins early Active | May participate if eligible |
| Player joins seconds before participation lock | Must not be falsely presented as able to earn full reward |
| Player joins during Resolving | No new participation |
| Player changes server | Occurrence clock unchanged |
| Player earned reward then changes server | Cannot earn same reward identity again |
| Player received personal multi-award opportunity then hops | No second opportunity for same reward identity |
| New server has different public event creatures | Allowed session-local variation |
| Event starts while ordinary creature exists | Existing creature not rerolled |
| Event Spawn Modifier becomes active | Affects future instances only |
| Event ends while event creature remains idle | Existing instance may persist to declared lifetime/grace |
| Event ends during valid Capture Attempt | Explicit resolution; no silent disappearance |
| Event ends during valid Transport Custody | Custody/extraction remains valid through resolution path |
| Event ends before player reaches objective threshold | No completion reward |
| Shared objective succeeds | Every qualifying contributor may get personal reward |
| Spectator present at success | No reward without contribution |
| Party member contributed nothing | No reward from Party status |
| Contributor kicked immediately before completion | Valid contribution not erased solely by kick |
| Last hitter completes server objective | Does not receive all rewards merely for final action |
| Server objective fails | No destruction of existing persistent value |
| Public event creature claimed | Ordinary GDS-5 exclusivity applies |
| Party tries to copy single-award creature | Prohibited |
| Multi-award encounter succeeds for three contributors | Up to three distinct personal Capture Opportunities |
| Two personal opportunities yield same Species | Still distinct Creature Instances |
| One participant rolls rarer Mutation | Other participants' instances are not rerolled |
| Personal opportunity expires unfinalized | No automatic ownership |
| Player has known incompatible capacity for personal opportunity | Must be informed/not represented as earned usable creature opportunity |
| Event Rift appears on Safe Route | Invalid placement if it blocks only viable route |
| Event hazard causes Recovery | No secured-value loss |
| Event announcement of rare spotlight | Must allow meaningful stability/travel |
| Whole-server centerpiece has single instant first-click prize only | Invalid baseline event design |
| Player AFKs in Rift | No contribution reward |
| Alt accounts stand idle | No reward |
| Robux spender joins event | Same authored event odds absent later explicit commercial authority |
| Player spends Energy | Does not reroll event creature |
| Event restarts next scheduled occurrence | New occurrence identity; prior finalized history preserved |
| Season ends | Owned event creatures/provenance remain |
| Event-Limited Species later returns | Old instances unchanged; new opportunities prospective |
| Live event disabled for exploit | Stop new activation/generation prospectively |
| Hotfix occurs while valid custody exists | Prefer safe completion; do not reroll/delete secured value |
| Controlled server shutdown during valid event Provisional Capture | GDS-5 Protected Shutdown Finalization applies |
| Server shutdown while shared objective nearly complete | No blanket auto-completion |
| Protected Load Failure during event | Irreversible rewards/captures blocked until trusted state |
| Event UI uses only sound for countdown | Invalid accessibility design |
| Event requires voice chat coordination | Invalid baseline design |
| Event wants Passive Production x2 | Not authorized by GDS-11 baseline; requires change control |
| Event reward is direct player-to-player Energy | Invalid |
| Event completion proposed as required Advanced Biome gate | Invalid baseline progression dependency |

## 37. Open Questions

There are **zero GDS-11-blocking open questions**.

Exact event themes/names, concrete calendar schedule, seasonal art, Rift geometry, exact objective catalogs, numerical contribution thresholds, Energy reward quantities, spawn weights, Mutation context weights, event duration/cooldown, exact Event Resolution Grace, exact announcement UX, final accessibility presentation, commercial event products, trading implications and technical cross-server implementation are tuneable content or downstream authority rather than unresolved GDS-11 semantics.

## 38. Design-Complete Checklist

- [x] Global Window / Event Occurrence / Server Event Instance semantics are explicit.
- [x] Event lifecycle and wall-clock timing are deterministic.
- [x] Late join and participation lock behavior are defined.
- [x] Contribution and exact-once reward semantics are defined.
- [x] Shared server objective semantics are defined.
- [x] Event Spawn Modifiers are prospective and identity-safe.
- [x] Availability/rotation/Legacy behavior preserves owned history.
- [x] Rift/Event Zone world constraints are defined.
- [x] Ordinary event-modified capture remains single-award.
- [x] Event Multi-Award Encounter semantics are explicit.
- [x] Multi-award uses distinct Creature Instances, not copies of one target.
- [x] Event end/disconnect/reset/shutdown behavior is defined.
- [x] Server-hopping abuse is addressed.
- [x] Party/social compatibility is defined.
- [x] Event economy boundaries are defined.
- [x] No baseline Passive Production multiplier is authorized.
- [x] Event provenance/live-content expansion rules are defined.
- [x] Hotfix/disable behavior preserves finalized value.
- [x] Presentation/accessibility obligations are defined.
- [x] Monetization/trading/safety/analytics authority remains downstream.
- [x] No implementation-relevant open questions remain.
