# TA-10 Social, Event, Cross-Server, and Trade Transaction Matrix

> **Phase:** TA-10 — Social Systems, Server Events, Cross-Server Coordination, and Trading  
> **Status:** PASS

## 1. Social State Matrix

| State | Scope | Durability |
|---|---|---|
| Party | server session | P0 |
| Party Invite | server session | P0 |
| Party leadership | server session | P0 |
| Party rejoin grace | same-server bounded runtime | P0 |
| Social Ping | transient recipient projection | P0 |
| Shared Objective contribution | objective/server runtime | P0/P1 until finalization |
| Collaboration Reward | Player Profile | P2 |
| Friendly Challenge | server session | P0 |
| Visitor Access Policy | player preference/profile as later locked | P1/P2 depending schema |
| Showcase projection | derived/read-only | P0 |

## 2. Party Mutation Matrix

| Situation | Required result |
|---|---|
| valid invite accepted | add exact player if seat available |
| fifth member attempts join | reject |
| simultaneous final-seat accepts | one winner maximum |
| leader leaves | deterministic longest-present successor |
| last member leaves | disband |
| unexpected disconnect | optional same-server seat grace |
| grace expires | seat released |
| reconnect to another server | no Party restoration |
| Party member enters locked Region | own access rules still apply |
| Party leader requests forced travel | prohibited |

## 3. Contribution / Reward Matrix

| Condition | Credit/reward |
|---|---|
| Party membership only | none |
| AFK proximity | none |
| objective-specific server-observed contribution | eligible when threshold met |
| qualifying player removed before finish | eligibility preserved if participation window says valid |
| duplicate completion callback | one personal finalization |
| larger Party | no implicit reward multiplier |
| Energy reward wallet full | TA-8 deferred grant preserves remainder |
| alt account with zero meaningful action | no contribution reward |

## 4. Friendly Challenge Matrix

| Property | Baseline |
|---|---|
| explicit acceptance | required |
| persistent stake | none |
| Energy wager | prohibited |
| creature wager | prohibited |
| player damage/knockback | prohibited |
| forced movement | prohibited |
| baseline permanent power reward | none |
| unequal capability | normalize/limit/disclose |

## 5. Event Identity Matrix

| Identity | Scope |
|---|---|
| EventTemplateId | static content |
| EventOccurrenceId | global wall-clock occurrence |
| ServerEventInstanceId | one server realization |
| ObjectiveInstanceId | event objective instance |
| RewardOperationId | one player's exact persistent reward |
| PersonalEventOpportunityId | one qualified player's event capture opportunity |
| CreatureInstanceId | one actual creature instance |

## 6. Event Authority Matrix

| Concern | Authority |
|---|---|
| scheduled occurrence | validated schedule/config + server wall clock |
| dynamic occurrence | durable occurrence record |
| fast server refresh | MessagingService hint |
| optional active cache | MemoryStore ephemeral entry |
| server public progress | Server Event Instance runtime |
| personal contribution | server-observed participant state |
| personal completion/reward | Player Profile P2 |
| event creature identity | TA-9 reservation + TA-7 generation |
| event provenance | pinned occurrence/template snapshot |

## 7. Cross-Server Service Matrix

| Service | Allowed TA-10 role | Not allowed |
|---|---|---|
| MessagingService | occurrence/config refresh hints, announcements | ownership/reward/commit truth |
| MemoryStore HashMap | short-lived cache/liveness/coordination | durable value/history |
| MemoryStore Queue | only if later measured ordered ephemeral work needs it | trade commit ledger |
| MemoryStore SortedMap | only if later ordered ephemeral coordination needs it | global market/price feed |
| DataStore | durable occurrence/journal/profile outcomes | per-frame runtime state |

## 8. Event Lifecycle Matrix

| Time/state | New participation? | New event spawns? | Existing outcomes |
|---|---:|---:|---|
| Announced | no | no unless explicitly prewarm non-actionable | none |
| Active | yes | yes per template |
| Resolving | template-specific bounded | normally stops or narrows | resolve active objective |
| Grace | no | no new ordinary event reservations | finish already-created/active outcomes |
| Ended | no | no | persistent finalized history remains |

## 9. Event Spawn Matrix

| Situation | Result |
|---|---|
| occurrence starts | future eligible Spawn Reservations may consume modifier |
| existing ordinary creature | unchanged |
| existing event creature | unchanged/pinned |
| event config changes | future reservations use prospective snapshot |
| player spends Robux | no hidden odds change |
| server-hop | same occurrence window identity |
| event ends | future event generation stops |
| active Protected Variant at end | bounded pinned resolution/lifetime rules |

## 10. Event Reward Matrix

| Condition | Result |
|---|---|
| meaningful contribution + reward eligibility | personal P2 operation |
| presence only | no reward |
| Party member did contribution for teammate | no copied credit |
| duplicate server resolution | dedupe by occurrence/reward/UserId |
| player server-hops after reward | no duplicate |
| wallet full | deferred grant as TA-8 |
| Event Completion + reward semantically one | atomic same-profile P2 bundle |

## 11. Multi-Award Matrix

| Stage | Required result |
|---|---|
| shared event target resolves | freeze eligible participant set |
| participant qualifies | one stable PersonalEventOpportunityId |
| opportunity generated | distinct CreatureInstanceId |
| several players qualify | several distinct instances, never one multi-owned instance |
| repeated resolution callback | no second opportunity for same player/slot |
| server-hop after qualification | no reissue |
| personal capture fails | ordinary personal opportunity rules; no shared-target ownership |

## 12. Trade Negotiation Matrix

| Situation | Result |
|---|---|
| invite not accepted | no session |
| both players same server and eligible | may negotiate |
| one player already trading | reject second session |
| semantic offer edit | increment revision, clear Ready + confirmations |
| both Ready same revision | enter final review |
| one final confirms | wait |
| offer changes | prior confirmations invalid |
| both final confirm same unchanged revision | precommit revalidation may begin |
| disconnect before durable commit | cancel/no ownership change |

## 12A. Persistent Event Cooldown Matrix

| Cooldown case | Authority / behavior |
|---|---|
| explicitly server-local cooldown | P0 runtime only when GDS scope permits |
| persistent personal cooldown | TA-4 Player Profile state keyed by stable cooldown definition/scope |
| persistent personal deadline | server-observed Unix wall clock |
| player changes server | reconcile persisted deadline before eligibility |
| client clock changes | no effect |
| value-sensitive cooldown starts | P2; coherently coupled to guarded outcome or same stable operation identity |
| cooldown write result unknown | reconcile same profile operation; do not reopen eligibility |
| cooldown expires | idempotent server-time reconciliation; no reward replay |
| global/shared cooldown | durable/config occurrence/global-window authority |

## 13. Offer Eligibility Matrix

| Creature/state | Offerable? |
|---|---:|
| exact owned Secured creature | YES if all checks pass |
| another player's creature | NO |
| Provisional Capture | NO |
| Creature Locked | NO |
| Production-assigned | NO until unassigned |
| displayed only | YES; display clears on successful transfer |
| Overflow-Held sender creature | YES if otherwise valid |
| Trade Cooldown active | NO |
| Time-Locked active | NO |
| Account-Bound | NO |
| Protected Variant deliberately unlocked | YES if otherwise valid |

## 14. Trade Journal Matrix

| Journal state | Ownership semantics | Allowed recovery |
|---|---|---|
| PREPARING | no committed transfer | complete prepare or decide abort |
| ABORT_DECIDED | no transfer | clear participant fences |
| COMMIT_DECIDED | committed intent must finish | idempotently apply both participants |
| APPLYING | same committed intent | continue missing apply |
| FINALIZED_ABORT | original ownership | terminal |
| FINALIZED_COMMIT | exchanged ownership | terminal |
| QUARANTINED | protected/invariant failure | operator/recovery tooling only |

## 15. Participant Prepare Matrix

| Check | Failure behavior |
|---|---|
| exact outgoing ownership mismatch | abort |
| profile revision/precondition mismatch | abort |
| conflicting transaction fence | abort |
| lock/restriction/cooldown invalid | abort |
| incoming net capacity invalid | abort |
| journal hash mismatch | protected failure |
| repeat same prepare | idempotent success |
| prepared profile receives ordinary P2 mutation | blocked until resolution |

## 16. Participant Apply Matrix

| Mutation | Required behavior |
|---|---|
| outgoing creature | remove exact instance |
| incoming creature | import exact same instance record |
| Variant Identity | unchanged |
| original provenance | unchanged |
| trade provenance | append bounded transfer history |
| incoming role | Stored safe state |
| Protected Variant | re-lock for receiver |
| Trade Cooldown | apply persistent server-time deadline |
| Display sender ref | clear |
| Production assignment | must already be absent |
| Energy | unchanged |
| Vault upgrades/buffer | unchanged |
| collection Discovery | may finalize from legitimate new ownership |
| active source-bound progression | not fabricated |

## 17. Partial Infrastructure Matrix

| Situation | Gameplay exposure |
|---|---|
| A prepared, B not prepared | both original ownership; A transaction-blocked |
| both prepared, no decision | original ownership; both blocked |
| COMMIT_DECIDED, neither applied | committed intent pending; both blocked |
| A applied, B pending | partial backend state hidden behind transaction resolution |
| both applied, journal not finalized | ownership committed; journal recovery finalizes |
| profile loads with pendingTrade | resolve journal before Ready |
| two recovery workers target same participant | only the current TA-4 lease-owner writer queue, or a worker that has legally acquired profile authority under stale/expired-lease rules, may perform the retry; duplicate authorized attempts remain idempotent |

## 18. Trade Capacity Matrix

| Situation | Result |
|---|---|
| receiver has free capacity | may pass |
| receiver full but outgoing frees enough | net exchange may pass |
| receiver net result exceeds capacity | abort before commit |
| trade would create new receiver Overflow-Held | prohibited |
| sender transfers existing Overflow-Held | allowed if other checks pass |
| capacity changes before prepare | revalidation/abort |
| capacity change after COMMIT_DECIDED | conflicting profile mutation was fenced |

## 19. Disconnect / Shutdown Matrix

| Point of failure | Result |
|---|---|
| invite/negotiation | cancel |
| Ready only | cancel |
| one final confirmation | cancel |
| precommit before journal decision | abort/no-op |
| PREPARING | recover to abort or valid prepare/decision |
| after COMMIT_DECIDED | finish commit |
| after one participant apply | finish other participant |
| after FINALIZED_COMMIT | reconnect shows committed state |

## 20. Security / Abuse Matrix

| Attempt | Result |
|---|---|
| client chooses Party membership | reject |
| client claims event contribution | server derives |
| client chooses occurrence ID | reject/derive |
| client asks for duplicate multi-award | dedupe |
| client chooses TradeTransactionId | reject |
| client edits incoming creature data | ignored; journal canonical record |
| client changes cooldown deadline | ignored |
| Party leader spends teammate Energy | impossible |
| social activity changes rare odds | prohibited |
| trade count mints reward | prohibited |
| Energy offered in trade | schema invalid |
| cross-server marketplace/listing | not baseline |

## Verdict

**TA-10 SOCIAL / EVENT / CROSS-SERVER / TRADE TRANSACTION MATRIX: PASS.**
