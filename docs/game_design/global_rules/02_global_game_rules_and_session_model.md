# Global Game Rules and Session Model

> **Status:** Design Complete  
> **Owning GDS phase:** GDS-2 — Global Game Rules and Session Model  
> **Authority:** Project-wide session lifecycle, player lifecycle, persistence permanence, offline/cross-server semantics, global time/state categories, and universal fairness invariants  
> **Depends on:** `../00_design_authority.md`, `../01_game_overview.md`, `../product/session_shape_and_experience_promise.md`, `../product/scope_and_commercial_boundaries.md`, `../GLOSSARY.md`

## 1. Purpose and Player Fantasy

MonsterVault is a persistent collection/progression experience played through temporary Roblox server sessions. The global-rules layer exists so later systems never need to invent what a session transition, disconnect, reset, server shutdown, persistence failure, or cross-server move means to a player.

The intended player-facing contract is:

> **My session may end, but progress that the game has already told me is mine does not silently disappear because a server, device, connection, or avatar lifecycle changed.**

This contract supports the GDS-1 product promise by making collection ownership trustworthy while preserving room for session-local discovery, events, competition, and future subsystem-specific risk.

## 2. Scope

This specification owns:

- the baseline Roblox server-session model;
- join, late-join, leave, disconnect, reconnect, and server-shutdown semantics;
- the global player lifecycle from protected loading through active play and recovery;
- the distinction between session-scoped state and persistent player state;
- progression permanence across death/reset/disconnect/server changes;
- behavior when persistent state is unavailable or inconsistent;
- baseline offline behavior;
- cross-server expectations;
- global time categories and timer continuity rules;
- universal fairness, retry, idempotence, and anti-abuse principles;
- global rules for irreversible outcomes and finite opportunities;
- required player-facing feedback for loading, recovery, and interrupted transitions.

## 3. Explicit Non-Goals

GDS-2 does **not** define:

- exact server population limits or matchmaking architecture;
- avatar movement, camera, controls, spawn coordinates, tutorial flow, or inventory UX — GDS-3;
- creature identity, creature ownership categories, or collection capacity — GDS-4;
- capture success, claim windows, transport/extraction, contesting, or the exact secure-ownership transfer point — GDS-5;
- rarity or mutation rules — GDS-6;
- vault production or offline-production values — GDS-7;
- currencies, progression costs, prestige/reset systems, or economy formulas — GDS-8;
- biome topology, world spawn tables, hazards, or traversal — GDS-9;
- parties, PvP, stealing, cooperation, or grief-prevention mechanics — GDS-10;
- event cadence, event participation, reward allocation, or server-hopping rules specific to events — GDS-11;
- trading semantics — GDS-12;
- monetization products and prices — GDS-13;
- detailed UI/UX and accessibility settings — GDS-14;
- moderation/platform-safety policy — GDS-15;
- retention loops or analytics implementation — GDS-16;
- persistence technology, DataStore layout, locking, networking, clocks, retry algorithms, or server authority implementation — Technical Architecture.

## 4. Terminology

Shared terms are normalized in `../GLOSSARY.md`. GDS-2 uses the following canonical meanings.

### Server Session
A single running Roblox game-server instance and the session-scoped world state hosted by that instance. A server session is temporary and must never be treated as the sole home of persistent player progression.

### Active Presence
The period in which a player is connected, their persistent state is ready for safe use, and the player is allowed to perform irreversible gameplay actions.

### Session-Scoped State
State whose lifetime is intentionally bounded to a server session or a specific session-local opportunity. It may disappear when that server ends unless an owning downstream specification explicitly promotes an outcome into persistent state.

### Persistent Player State
Player-owned progression that is intended to survive avatar failure, disconnect, server change, device change, and future play sessions.

### Finalized Outcome
A gameplay result that the owning specification has declared complete and no longer provisional. If that outcome is persistent, a retry, reconnect, or duplicate message must not create a second copy or reverse it accidentally.

### Transient Opportunity
A world or session opportunity that has not yet produced a finalized persistent outcome. Its interruption behavior is owned by the subsystem that created it.

### Recovery
A temporary non-punitive lifecycle state used to return the player to valid active play after avatar failure, reset, invalid position, or comparable interruption.

### Protected Load Failure
A state in which trusted persistent player state is not available. The player may retry, reconnect, or leave, but must not be allowed to create irreversible progression against a blank or untrusted fallback profile.

### Global Window
A calendar-based availability period intended to mean the same thing across servers, such as a future seasonal or live-event window. Exact event use is owned by GDS-11.

## 5. Participating Entities and Ownership

The global rules concern:

- the player/account as the owner of persistent progression;
- the player's current avatar/presence as temporary session participation;
- the server session as owner of session-scoped world state;
- subsystem-owned transient opportunities;
- subsystem-owned finalized persistent outcomes;
- future global windows that may span multiple server sessions.

A server session may host and mutate gameplay, but it does not own the player's persistent identity. Avatar existence is likewise not equivalent to persistent ownership.

## 6. Core Rules and Invariants

### GR-01 — Sessions are disposable runtime containers
A server session may start and end without implying a reset of persistent player progression.

### GR-02 — Persistent progression is session-independent
Once an owning subsystem has finalized a value as persistent player state, that value survives ordinary avatar failure, player reset, disconnect, reconnect, server transition, device transition, and server shutdown unless a later authoritative design explicitly defines a player-chosen persistent reset mechanic.

### GR-03 — Session transitions are not progression wipes
Joining a new server never means "new character", "new save", or "fresh economy" by default.

### GR-04 — Clean leaving is not required for correctness
A player must not need to press a special save/logout action to protect finalized persistent progress. Unexpected disconnect and platform shutdown are normal lifecycle events.

### GR-05 — No irreversible play before trusted state is ready
A player may receive loading/retry presentation before persistent state is ready, but must not perform irreversible progression, purchases, trades, ownership transfers, or other state-producing actions while the game cannot safely establish their authoritative persistent state.

### GR-06 — Blank fallback state may not silently overwrite trusted progression
When persistent state cannot be established, the design outcome is Protected Load Failure, not "start from zero and save later".

### GR-07 — Finalized persistent outcomes are single-application outcomes
Reconnects, repeated requests, duplicate callbacks, retries, or server transitions must not duplicate a finalized persistent reward or apply the same irreversible cost more than once. Technical enforcement belongs to TA.

### GR-08 — One finite opportunity cannot finalize contradictory winners
When a downstream mechanic represents a single finite claim, it must resolve to one authoritative set of outcomes. Exact tie-breaking and contest rules belong to the owning subsystem.

### GR-09 — Ordinary disconnect is neutral
Disconnecting is not itself a punishment mechanic. A player does not lose secured persistent value merely because the connection or server ended.

### GR-10 — Transient interruption must be explicitly owned
If a player disconnects during an unfinalized capture, transport, event, trade, hazard, or other transient opportunity, the owning subsystem must define a deterministic interruption result before that subsystem can become Design Complete.

### GR-11 — Failure is a short interruption, not a global progression reset
Avatar death, reset, invalid position, or equivalent failure may interrupt current activity and invoke Recovery, but does not wipe persistent collection/progression by default.

### GR-12 — Player reset cannot be a superior economic strategy
Using reset/rejoin/disconnect deliberately must not create extra rewards, erase already-finalized costs, duplicate finite opportunities, or produce a systematically better outcome than resolving the activity normally.

### GR-13 — Platform failure should not create punitive permanent loss
Server crashes, forced shutdowns, client crashes, and network failures must be treated as interruption cases, not as intentional player forfeiture of secured persistent value.

### GR-14 — No mandatory periodic global wipe
MonsterVault has no baseline season wipe, server wipe, death wipe, or periodic full progression reset. A future optional prestige/reset mechanic, if accepted by GDS-8, must be explicit and player-understandable rather than an implicit consequence of session lifecycle.

### GR-15 — Presence alone does not imply reward entitlement
Being connected, AFK, late-joined, or merely present near an activity does not by itself guarantee rewards. Each rewarding subsystem defines participation eligibility.

### GR-16 — Cross-platform lifecycle semantics are equal
Mobile, tablet, console, and desktop players follow the same persistence, reward-finalization, failure, disconnect, and server-transition semantics. Input differences may change interaction presentation, not ownership guarantees.

### GR-17 — Late joining is a normal state
A player may join an already-running server. The design must return them to meaningful active play without requiring that they witnessed server startup. They are not automatically entitled to already-consumed finite rewards.

### GR-18 — Server age must not invalidate ordinary joining
A late join may encounter different currently available opportunities, but the player must still be able to orient, recover their persistent state, and pursue meaningful gameplay.

### GR-19 — Session-local state may legitimately end with the session
World spawns, temporary scene state, session-local counters, and unfinalized opportunities may disappear when their owning server ends unless a downstream specification explicitly defines persistence.

### GR-20 — Persistent effects must declare elapsed-time semantics
Any persistent timed effect must declare whether it advances by wall-clock elapsed time, active-play time, or another explicit semantic. Rejoining or server hopping must not implicitly reset its timer.

### GR-21 — Global windows do not restart per server
If GDS-11 or another later authority defines a Global Window, joining a new server does not create a fresh personal copy of that calendar window.

### GR-22 — No baseline persistent shared MMO world
MonsterVault does not assume one continuously shared cross-server world state. Servers may have distinct session-local world opportunities. Cross-server coordination, if introduced later, must be explicitly specified.

### GR-23 — Offline presence grants no live-world claim by default
A player who is offline does not occupy a creature, world slot, event position, contest claim, or live server opportunity merely because they previously interacted with it.

### GR-24 — Offline progression is optional, not assumed
GDS-2 does not guarantee offline earnings. If later GDS phases add offline progression, it must derive from persistent state and explicit elapsed-time rules rather than pretending the player remained actively present in a live server.

### GR-25 — Failure recovery must avoid immediate unavoidable repeat failure
Recovery must return the player to a valid state where they have a reasonable opportunity to regain control and understand what happened. Exact spawn/protection mechanics belong to GDS-3/GDS-9/GDS-10.

### GR-26 — A player must understand whether an outcome is secure or still at risk
If a downstream mechanic can be interrupted before value becomes persistent, presentation must distinguish provisional/transient value from finalized persistent value.

### GR-27 — Purchases and paid entitlements cannot rely on session survival
Once a future monetization system considers a purchase/entitlement successfully granted, disconnect or server shutdown must not be designed to erase that entitlement. Detailed commercial semantics remain GDS-13/TA authority.

### GR-28 — Social joining cannot bypass progression authority by default
Joining a friend, private server, or different server does not automatically bypass normal progression/access requirements unless an owning social/world specification intentionally defines such behavior.

## 7. States and State Transitions

### 7.1 Connection and readiness lifecycle

```text
Connecting
   ↓
Persistent State Loading
   ├── success → Persistence Ready
   │              ↓
   │          Spawn / Recovery
   │              ↓
   │          Active Presence
   │              ↓
   │     Leave / Disconnect / Shutdown
   │              ↓
   │          Session Exit
   │
   └── failure → Protected Load Failure
                  ├── retry → Persistent State Loading
                  └── leave/reconnect → Session Exit
```

The game may show non-destructive loading presentation before `Persistence Ready`, but irreversible gameplay is blocked until readiness.

### 7.2 Active-play interruption lifecycle

```text
Active Presence
   ↓
Failure / Reset / Invalid Runtime State
   ↓
Recovery
   ↓
Active Presence
```

A downstream subsystem may define local transient consequences, but the global recovery transition never implies a full persistent wipe.

### 7.3 Server transition lifecycle

```text
Active Presence in Server A
   ↓
Session Exit
   ↓
Connect to Server B
   ↓
Persistent State Loading
   ↓
Persistence Ready
   ↓
Active Presence in Server B
```

Persistent player state crosses the transition; ordinary session-scoped world state does not.

## 8. Player Actions and Inputs

At the global layer, players may:

- join an available server;
- join an already-running server;
- leave at any time allowed by the platform;
- reconnect after disconnect;
- move between servers through platform/social flows;
- use a future player-reset action if enabled by downstream player design;
- retry after Protected Load Failure.

No player action is required to "save" finalized persistent progress.

## 9. Outputs, Rewards, Costs, and Consequences

GDS-2 does not define economy amounts. It defines how outcomes behave globally:

- a finalized persistent reward remains part of persistent player state;
- a finalized persistent cost remains paid after retry/reconnect;
- an unfinalized transient opportunity follows the interruption rule of its owning subsystem;
- recovery itself grants no default reward and charges no default persistent penalty;
- reconnecting does not create a duplicate copy of previously finalized outcomes;
- Protected Load Failure creates no irreversible progression.

## 10. Multiplayer Semantics

### 10.1 Simultaneous actions
When multiple players interact with one finite opportunity, the owning subsystem must define deterministic eligibility and finalization. The global invariant is that one finite result cannot be finalized inconsistently for multiple players unless the opportunity was explicitly designed as shared/multi-award.

### 10.2 Late joins
Late joiners enter the current server state. They may participate in still-open opportunities if the owning subsystem permits it, but do not receive retroactive finite rewards solely for joining late.

### 10.3 Player departures
A departing player stops being actively present. Session-local world participation may end immediately or after a subsystem-defined bounded grace rule, but persistent secured value is not forfeited merely because the player left.

### 10.4 Server transitions
A new server may expose different session-local opportunities. However, switching servers may not duplicate one-time persistent claims, erase finalized costs, restart persistent timers, or regrant already-finalized account rewards.

### 10.5 Private/friend servers
Unless a later specification says otherwise, private/friend server context changes who the player is with, not the semantic value of persistent progression.

## 11. Progression and Economy Interactions

GDS-2 establishes the following progression constraints:

- persistent collection/progression survives ordinary session lifecycle;
- progression systems must explicitly classify outputs as transient/session-scoped or persistent/finalized;
- a server transition does not reset progression prerequisites;
- future prestige/reset behavior must be intentionally owned by GDS-8, not inferred from death/session changes;
- future offline gains must be bounded by GDS-7/GDS-8 and cannot rely on continuous live-server occupancy;
- economy systems must treat retry/reconnect as possible duplicate-delivery paths and preserve single-application semantics.

## 12. Failure, Interruption, and Recovery

### 12.1 Avatar failure
Avatar failure may create a short gameplay interruption. It does not globally destroy secured creatures, currencies, unlocks, purchases, or long-term progression.

### 12.2 Player reset
Reset follows the same persistent-progression guarantees as other recovery paths. Downstream systems may define local consequences when reset occurs during a risk-bearing transient activity, but the consequence must be explicit and non-duplicative.

### 12.3 Network disconnect/client crash
The player stops being actively present. Finalized persistent outcomes remain valid. Unfinalized transient activity resolves under its owning subsystem's disconnect rule.

### 12.4 Server shutdown/crash
The session-local world ends. Secured persistent progress is not intentionally forfeited. Systems must not depend on orderly server shutdown as the only point at which persistent outcomes become valid.

### 12.5 Persistence unavailable
Enter Protected Load Failure. The player must receive a clear retry/reconnect path. The game must not create a trusted-looking empty profile that can later overwrite established progression.

### 12.6 Invalid position/stuck state
The player may be recovered to a valid play state. Recovery must not become a shortcut to duplicate rewards or evade finalized costs.

## 13. Abuse and Exploit Cases

### Disconnect/rejoin farming
Repeating disconnect/rejoin may not duplicate finalized rewards, reset paid costs, or renew persistent timers.

### Server-hop farming
Different servers may legitimately contain different session-local opportunities, but later systems must explicitly address server hopping when it would undermine scarcity, event fairness, cooldowns, or one-time reward semantics.

### Reset abuse
Reset may not become the optimal way to teleport value home, escape a finalized cost, reroll a result, or duplicate a claim unless a downstream mechanic intentionally defines that behavior.

### AFK farming
GDS-2 creates no reward merely for connection time. Passive production, if accepted, must be explicitly designed by its owning phase.

### Alternate accounts/collusion
GDS-2 does not prohibit multiple accounts at the platform level, but no global rule grants extra entitlement simply because multiple presences cooperate. Detailed abuse constraints belong to affected subsystems.

### Replay/duplicate delivery
The player-facing outcome of a finalized transaction is "happened once". Technical idempotency mechanisms belong to TA.

## 14. Presentation and Feedback

The player must receive understandable feedback for globally important lifecycle states:

- loading persistent state;
- ready to play;
- retryable persistence/load failure;
- recovery after avatar failure/reset;
- interruption of a transient activity when the owning subsystem makes that relevant;
- whether valuable state is provisional versus finalized/secured when that distinction matters;
- server transition or event/global-window timing when relevant.

The presentation must avoid implying that a temporary loading problem erased the player's collection.

## 15. Accessibility

Global lifecycle communication must not depend on one channel only.

At minimum:

- critical loading/recovery/error states require clear visual text/icon treatment;
- audio may reinforce but not exclusively communicate persistence safety or failure;
- recovery cannot require precision input merely to regain control;
- important provisional-versus-secured distinctions must remain understandable without relying solely on color;
- controller/touch/keyboard players must have equivalent retry/leave/recovery access.

Detailed accessibility presentation belongs to GDS-14.

## 16. Persistence Expectations

### Must persist when owned by the player
Once later owning specifications classify these as persistent and finalize them, they must survive normal session lifecycle:

- secured collection ownership;
- persistent progression/unlocks;
- persistent currencies/resources;
- durable vault/base state;
- durable cosmetics/status entitlements;
- completed one-time rewards/claims;
- future trading outcomes after finalization;
- confirmed monetization entitlements.

### Does not persist by default
Unless a later specification explicitly says otherwise:

- current server population;
- session-local world spawns;
- local world positions;
- transient opportunity state;
- unclaimed session rewards;
- temporary server-only counters;
- temporary environmental state.

### Persistence failure rule
The design prefers temporary inability to enter irreversible play over risking silent rollback, blank-state overwrite, or contradictory ownership.

## 17. Monetization Interactions

GDS-2 sets only universal lifecycle constraints:

- a confirmed durable entitlement must not be intentionally lost due to disconnect, death, reset, or server shutdown;
- purchase retry/rejoin must not intentionally grant duplicates beyond what the purchased product actually defines;
- a persistence failure state must not be used to pressure the player into repurchasing missing value;
- paid convenience may not create a separate persistence/failure contract for paying users.

Exact products, consumables, receipts, prices, and entitlement behavior remain GDS-13/TA authority.

## 18. Analytics and Experimentation Boundaries

Design-relevant outcomes that should eventually be observable include:

- successful transition from connect to Active Presence;
- Protected Load Failure frequency;
- session exits by voluntary leave, disconnect, shutdown, or failure where distinguishable;
- recovery frequency;
- repeated disconnect/rejoin around high-value activities;
- cross-server transition frequency;
- player-visible persistence inconsistencies or rollback reports;
- time from ready state to meaningful play.

Experiments may tune presentation and recovery pacing, but may not A/B test away the semantic guarantees that secured persistent value survives ordinary lifecycle events.

## 19. Tuneable Parameters

GDS-2 intentionally minimizes global numeric tuning. Values that may later be tuned without changing these semantics include:

- visual retry/recovery delay before control returns;
- load/retry presentation timing;
- subsystem-specific reconnect grace windows, only where the owning subsystem explicitly defines one;
- subsystem-specific transient timeout lengths.

Changing whether persistent value survives a lifecycle event is **not** a tuneable parameter; it is a semantic design change.

## 20. Dependencies and Cross-References

- `../00_design_authority.md` — authority, Design Complete criteria, multiplayer/abuse obligations.
- `../01_game_overview.md` — persistent collection product identity and non-loss-dominant contract.
- `../product/session_shape_and_experience_promise.md` — flexible session length and healthy stopping principle.
- `../product/scope_and_commercial_boundaries.md` — reliable persistence as launch-critical capability and no MMO-scale shared world requirement.
- GDS-3 — player controls, spawn/recovery presentation, onboarding.
- GDS-4/GDS-5 — exact creature/capture ownership finalization and interruption.
- GDS-7/GDS-8 — passive/offline production and economy/progression.
- GDS-9/GDS-10/GDS-11 — world, social, and event-specific late-join/server-hop rules.
- GDS-12 — trading finalization/interruption.
- GDS-13 — purchase/entitlement semantics.
- GDS-14/GDS-15 — detailed presentation/accessibility/platform constraints.
- GDS-16 — analytics instrumentation/experimentation policy.
- Technical Architecture — all concrete persistence, concurrency, retry, clock, server, networking, and durability mechanisms.

## 21. Edge-Case Matrix

| Scenario | Required GDS-2 outcome | Detailed owner |
|---|---|---|
| Player joins an old/already-running server | Load persistent state, then enter meaningful active play | GDS-3/GDS-9 |
| Persistent profile cannot be trusted | Protected Load Failure; no irreversible play | GDS-2 / TA implementation |
| Player disconnects after a persistent reward finalized | Reward remains; no duplicate on reconnect | Owning subsystem + TA |
| Player disconnects before an opportunity finalizes | Deterministic subsystem interruption rule | Owning subsystem |
| Server shuts down unexpectedly | No intentional loss of finalized persistent value | All persistent subsystems |
| Player resets avatar | Recovery; no global persistent wipe | GDS-3 + active subsystem |
| Player repeatedly resets during an activity | Cannot duplicate reward/erase finalized cost | Owning subsystem |
| Player server-hops after a one-time claim | Claim remains consumed | Owning subsystem |
| Player server-hops during a persistent timer | Timer semantics continue as declared | Owning subsystem |
| Two players claim one finite object simultaneously | One coherent outcome set; no contradictory finalization | GDS-4/GDS-5/GDS-11 |
| Late join after finite reward already consumed | No automatic retroactive reward | Owning subsystem |
| Player changes device | Same persistent state and lifecycle semantics | GDS-2 |
| Player is AFK | No default reward entitlement | Owning subsystem |
| Player was offline for hours/days | No live-world claim; offline gains only if later specified | GDS-7/GDS-8 |
| Global event window ends while player changes server | Window does not restart | GDS-11 |
| Client shows stale transient state after reconnect | Persistent truth wins; no duplicate value | TA + owning subsystem |
| Confirmed durable purchase followed by crash | Entitlement is not intentionally lost | GDS-13/TA |
| Recovery point is unsafe | Must return player to a reasonable controllable state | GDS-3/GDS-9/GDS-10 |
| Friend joins a progressed player's server | Does not bypass progression by default | GDS-9/GDS-10 |
| Clean leave vs crash | Same persistent safety guarantee | GDS-2 |

## 22. Open Questions

**None.**

Questions about exact mechanics are intentionally delegated to their owning downstream GDS phases and do not alter the GDS-2 global semantics.

## 23. Design-Complete Checklist

- [x] Purpose and scope are explicit.
- [x] Core rules are deterministic.
- [x] Connection, readiness, recovery, and server-transition states are defined.
- [x] Multiplayer join/leave/late-join behavior is defined at the global layer.
- [x] Failure/recovery is defined without forcing downstream mechanics.
- [x] Disconnect/reset/server-hop abuse invariants are addressed.
- [x] Presentation/accessibility requirements are defined where globally relevant.
- [x] Persistence permanence and Protected Load Failure semantics are defined.
- [x] Economy/monetization lifecycle constraints are consistent with GDS-1.
- [x] Edge cases are covered.
- [x] Cross-references preserve one authoritative owner per detailed rule.
- [x] No implementation-relevant GDS-2 open questions remain.

## 24. GDS-2 Design Verdict

The global lifecycle contract is **Design Complete**.

MonsterVault treats server sessions as temporary runtime contexts, persistent player progression as session-independent, disconnect/reset/shutdown as ordinary interruption rather than implicit punishment, and persistence uncertainty as a protected no-risk state rather than an opportunity to fabricate or overwrite player data.

Downstream systems may now define their own detailed mechanics while preserving these invariants.