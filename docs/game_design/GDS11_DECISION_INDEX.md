# GDS-11 Decision Index

> **Phase:** GDS-11 — Server Events, Dynamic Encounters, and Live Content  
> **Status:** Accepted  
> **Purpose:** Phase-local record of strategic GDS-11 decisions and rationale. Detailed behavior remains authoritative in events_liveops/11_server_events_dynamic_encounters_and_live_content.md.

## GDS11-D01 — Event Timing Uses Shared Wall-Clock Occurrences, Not Per-Server Fresh Durations

**Status:** Accepted

### Context

Live events need predictable timing and server-hop safety. If every newly joined server restarted an event, players could extend windows indefinitely and reroll event state.

### Decision

Global Event Windows and Event Occurrences use wall-clock timing shared across ordinary servers.

A newly created server participates only for the remaining occurrence duration and may skip the event if too little meaningful time remains.

### Rationale

This preserves calendar meaning and prevents server hopping from becoming the optimal way to extend live content.

### Alternatives Rejected

- fresh event timer per server;
- fresh personal timer on join;
- reconnect-based event extension;
- server-hop reset of reward/cooldown timing.

### Affected Specifications

GDS-2, GDS-9, GDS-11, GDS-16, Technical Architecture.

---

## GDS11-D02 — Server Event State Is Session-Local; Finalized Personal Outcomes Are Persistent

**Status:** Accepted

### Context

MonsterVault does not assume a single persistent shared MMO world. Cross-server synchronization of all public event progress would add a much stronger world model than GDS-2 authorizes.

### Decision

Server Event Instance progress, Rift state and public event creature populations are session-scoped by baseline.

Finalized personal Event Participation Rewards, Event Completion Records and Secured Creatures remain persistent exact-once outcomes.

### Rationale

This keeps event state compatible with the disposable-server model while preserving player trust in already-earned value.

### Alternatives Rejected

- one mandatory cross-server global event-health pool;
- persisting every public Rift across all servers;
- resetting finalized rewards per server;
- auto-completing event state on server transition.

### Affected Specifications

GDS-2, GDS-4, GDS-8, GDS-11, Technical Architecture.

---

## GDS11-D03 — Event Spawn Modifiers Are Prospective Only

**Status:** Accepted

### Context

Events need to change what can appear without turning existing creatures into rerollable reward slots.

### Decision

Event Spawn Modifiers may change future Spawn Context eligibility/weights and event-specific Mutation context only when a new Creature Instance is generated.

They do not reroll surviving or owned Creature Instances.

### Rationale

Live variety remains possible while GDS-6 identity/scarcity integrity stays trustworthy.

### Alternatives Rejected

- upgrading existing creatures when event starts;
- downgrading them when event ends;
- rerolling after failed capture;
- spender-specific event rerolls.

### Affected Specifications

GDS-6, GDS-9, GDS-11, GDS-13, GDS-16.

---

## GDS11-D04 — Ordinary Event Creatures Remain Single-Award by Default

**Status:** Accepted

### Context

An event context alone should not make ordinary GDS-5 claim/custody semantics ambiguous.

### Decision

A public creature generated during an event remains one valid Engagement Claim, one Provisional Capture/Transport Custody and one ordinary Secured Ownership Finalization unless the Event Template explicitly declares the separate Event Multi-Award model.

### Rationale

Players can reason about event creatures using the same ordinary capture contract unless the game clearly communicates an exception.

### Alternatives Rejected

- implicit Party copies;
- automatic contributor copies of any event creature;
- event announcements creating shared ownership;
- event phase changing claim authority.

### Affected Specifications

GDS-4, GDS-5, GDS-10, GDS-11, Technical Architecture.

---

## GDS11-D05 — Multi-Award Events Create Distinct Personal Creature Instances, Never Copies of One Shared Target

**Status:** Accepted

### Context

GDS-5 explicitly reserves downstream authority for multi-participant event encounters, but duplicating one finite Creature Instance into several owners would violate stable identity and ownership semantics.

### Decision

An Event Multi-Award Encounter may grant each qualifying participant at most one distinct **Personal Event Capture Opportunity** for that reward identity.

The shared encounter target is not itself duplicated into collections.

Each personal opportunity receives its own stable Creature Instance identity, Variant Identity Finalization, lifetime and acquisition path.

### Rationale

Multiple players can receive creature opportunities without introducing multiple ownership claims over one instance.

### Alternatives Rejected

- cloning one exact shared Creature Instance into every participant;
- shared ownership;
- automatic secured creature delivery with no acquisition state;
- server-hop reissue of the same personal opportunity.

### Affected Specifications

GDS-4 through GDS-6, GDS-9 through GDS-12, Technical Architecture.

---

## GDS11-D06 — Event Rewards Require Personal Active Contribution and Finalize Exact-Once

**Status:** Accepted

### Context

Rewarding raw presence, Party status or last-hit behavior would enable AFK/alt-account farming and create social grief incentives.

### Decision

Reward-bearing Event Objectives require personal Event Contribution.

Qualifying players may receive bounded exact-once personal Energy/Event Completion outcomes. Party membership, proximity, spectating and last-hit status alone are insufficient.

### Rationale

The event remains cooperative without becoming passive reward minting or leader-controlled allocation.

### Alternatives Rejected

- all-server presence rewards;
- Party-wide automatic rewards;
- winner-takes-all last hit;
- server-hop repeat rewards;
- visitor/social status reward multipliers.

### Affected Specifications

GDS-8, GDS-10, GDS-11, GDS-16.

---

## GDS11-D07 — Event-Limited Content Is Optional Collection Content, Not Mainline Progression

**Status:** Accepted

### Context

A scheduled or seasonal event can be unavailable when a player starts playing. Requiring such content for baseline world progression would make ordinary progression calendar-dependent.

### Decision

Event-Limited creatures, variants and Event Completion Records cannot be mandatory prerequisites for the baseline Home Hub -> Starter -> Mid -> Advanced world progression graph.

### Rationale

Events create excitement and collection goals without converting absence from a calendar window into permanent progression lockout.

### Alternatives Rejected

- Event-Limited Species required for Region Mastery;
- event completion required for Advanced Biome;
- seasonal attendance required to preserve old Access Unlocks;
- paid event rerun as progression recovery.

### Affected Specifications

GDS-8, GDS-9, GDS-11, GDS-13, GDS-16.

---

## GDS11-D08 — Event End Uses Bounded Resolution Grace Instead of Hard Deletion

**Status:** Accepted

### Context

A strict wall-clock cutoff that instantly deletes a creature during an accepted Capture Attempt or valid Transport Custody would be technically simple but unfair and inconsistent with GDS-5.

### Decision

Occurrence end stops new event generation and participation, then uses bounded Event Resolution Grace for already-active valid acquisition/reward resolution.

Grace does not admit new participants, restart modifiers or extend through server hopping.

### Rationale

The event keeps a real end time without invalidating legitimate actions already in flight.

### Alternatives Rejected

- instant despawn of active capture;
- unlimited post-event continuation;
- fresh grace in each new server;
- auto-securing every event creature at event end.

### Affected Specifications

GDS-2, GDS-5, GDS-9, GDS-11.

---

## GDS11-D09 — No Baseline Event Multiplier to Passive Vault Production

**Status:** Accepted

### Context

Event production boosts would couple session/live calendar state to GDS-7 offline/passive accrual and could create AFK pressure, cross-server ambiguity and large economy spikes.

### Decision

GDS-11 authorizes bounded active Event Energy rewards but no baseline multiplier to Passive Production, Production Profiles, Production Buffer or Offline Production Window.

Any future production event requires GDS-7/GDS-8/GDS-11 change control.

### Rationale

Live events remain active-play opportunities without destabilizing the established passive economy model.

### Alternatives Rejected

- x2/x5 passive production weekends by default;
- Party visitor production multiplier;
- server-local production boosts;
- event-based offline-window extension.

### Affected Specifications

GDS-7, GDS-8, GDS-11, GDS-13, GDS-16.

---

## GDS11-D10 — Event Rotation, Disable and Hotfix Are Prospective and Preserve Legitimate Finalized Value

**Status:** Accepted

### Context

Live content must be removable or disabled when broken, but players need confidence that legitimate already-secured outcomes are not silently rewritten.

### Decision

Rotation/disable/hotfix may stop future activation, future event generation or future Availability.

By baseline it does not silently delete legitimate secured creatures, finalized Energy, Event Completion Records or historical provenance.

### Rationale

Operations can react to problems without undermining ownership trust.

### Alternatives Rejected

- deleting owned event creatures when season ends;
- rerolling owned variants after balance change;
- revoking Event Completion Records because template was disabled;
- changing historical acquisition provenance.

### Affected Specifications

GDS-2, GDS-4, GDS-6, GDS-8, GDS-11, Technical Architecture.

---

## GDS11-D11 — Server-Wide Event Centerpieces Must Provide Meaningful Participation Value Beyond One Instant First-Click Prize

**Status:** Accepted

### Context

Advertising a major event to the whole server and then making the only meaningful outcome one instant first-interact reward would amplify latency, device and spawn-position inequality.

### Decision

A major whole-server centerpiece must provide contribution-based personal value and/or use the Event Multi-Award model.

It may still contain public single-award creatures, but they cannot be the entire meaningful event reward structure.

### Rationale

Server-wide events feel cooperative and worth joining even when a player does not win a specific public claim race.

### Alternatives Rejected

- one announced Legendary as the sole event reward;
- last-hit winner-takes-all event;
- zero-value participation for non-claimants;
- paid priority to compensate for first-click design.

### Affected Specifications

GDS-1, GDS-5, GDS-10, GDS-11, GDS-14 through GDS-16.

---

## GDS11-D12 — Close GDS-11 Server Events, Dynamic Encounters, and Live Content

**Status:** Accepted

### Context

The authoritative GDS-11 specification resolves timing, occurrence identity, event lifecycle, contribution/rewards, Rifts, event modifiers, ordinary and multi-award event capture, Availability/rotation, server hopping, social/economy interaction, interruption, provenance, hotfix behavior and downstream boundaries. Scenario and cross-system validation pass.

### Decision

GDS-11 is formally closed as **Complete — PASS**.

Material changes to:

- shared wall-clock occurrence semantics;
- session-local Server Event Instance state;
- prospective-only Event Spawn Modifiers;
- exact-once event reward identity;
- personal contribution requirement;
- ordinary event capture remaining single-award by default;
- distinct personal instances in Event Multi-Award Encounters;
- Event Resolution Grace;
- no event mainline progression requirement;
- no baseline event Passive Production multiplier;
- server-hop no-reset/no-reissue rules;
- finalized-value preservation under rotation/hotfix

require GDS-11 change control and revalidation.

### Evidence

- events_liveops/11_server_events_dynamic_encounters_and_live_content.md — Design Complete;
- GDS11_SCENARIO_VALIDATION.md — 120 / 120 PASS;
- GDS11_CROSS_VALIDATION.md — PASS;
- GDS11_CLOSURE_REPORT.md — PASS.

### Consequence

The active dependency advances to **GDS-12 — Trading and Player Economy**. Technical Architecture and gameplay implementation remain blocked.
