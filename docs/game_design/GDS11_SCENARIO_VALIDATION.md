# GDS-11 Scenario Validation

> **Phase:** GDS-11 — Server Events, Dynamic Encounters, and Live Content  
> **Status:** PASS  
> **Purpose:** Compound validation of event timing, occurrence identity, session-local event state, contribution/reward rules, Event Spawn Modifiers, dynamic Rifts, ordinary event capture, Event Multi-Award Encounters, Availability/rotation, server hopping, lifecycle interruption, economy, social play, live disable/hotfix and downstream authority.

## Validation Method

Each scenario is tested against closed GDS-1 through GDS-10 plus events_liveops/11_server_events_dynamic_encounters_and_live_content.md.

A scenario passes only if:

- Global Event Window/Event Occurrence timing cannot be privately restarted;
- finalized ownership/progression/economy is never silently revoked by event lifecycle;
- event modifiers apply prospectively only;
- ordinary event-modified creatures remain single-award unless explicit multi-award authority applies;
- multi-award creature outcomes create distinct instances rather than duplicated ownership of one target;
- reward credit requires meaningful personal Event Contribution;
- exact-once reward identity survives retry/reconnect/server transition;
- Event-Limited content is not required for baseline progression;
- social/event play does not enable direct-combat PvP, body-blocking, value theft or paid claim priority;
- server hopping cannot become a guaranteed reward/variant reroll mechanism.

## Scenarios

| # | Scenario | Expected Result | Result |
|---:|---|---|---|
| 1 | Global Event Window opens | Same wall-clock availability semantics across servers | PASS |
| 2 | Player changes server during window | Window does not restart | PASS |
| 3 | New server starts halfway through occurrence | Uses remaining occurrence time only | PASS |
| 4 | New server starts near occurrence end | May skip instance if meaningful participation is no longer possible | PASS |
| 5 | Same Event Template runs tomorrow | New Event Occurrence identity | PASS |
| 6 | Same Event Template reruns next season | New occurrence; old history preserved | PASS |
| 7 | Two servers host same occurrence | Separate session-local Server Event Instance progress | PASS |
| 8 | One server completes objective first | Other server's progress is unaffected | PASS |
| 9 | One server has different Rift location | Allowed within authored bounds | PASS |
| 10 | One server has different public creature population | Allowed session-local variation | PASS |
| 11 | Event enters Announced phase | No contribution/reward yet | PASS |
| 12 | Event enters Active phase | Eligible participation begins | PASS |
| 13 | Event enters Resolving | No new participation/generation | PASS |
| 14 | Event enters Ended | No new event-specific participation | PASS |
| 15 | Resolution Grace starts | Only already-active resolution may continue | PASS |
| 16 | Player hops server during grace | Grace is not reset/extended | PASS |
| 17 | Player joins during announcement | May prepare; no participation credit | PASS |
| 18 | Player joins early Active | May participate if eligible | PASS |
| 19 | Player joins with enough remaining time | Can earn contribution normally | PASS |
| 20 | Player joins with seconds remaining | Must not be falsely presented as fully reward-eligible | PASS |
| 21 | Player joins during Resolving | No new event participation | PASS |
| 22 | Player joins after Ended | No event participation | PASS |
| 23 | Event occurs in locked Mid Biome | Locked player does not bypass Access Unlock | PASS |
| 24 | Party member has biome access but teammate does not | Teammate remains blocked | PASS |
| 25 | Event provides accessible equivalent in unlocked area | Allowed when explicitly authored | PASS |
| 26 | Premium player lacks region access | Premium state does not bypass GDS-9 access | PASS |
| 27 | Event asks for raw presence only | Invalid contribution model | PASS |
| 28 | Player actively performs event interactions | Eligible Event Contribution possible | PASS |
| 29 | Player completes event traversal segment | Eligible contribution possible | PASS |
| 30 | Player AFKs inside Rift | No contribution reward | PASS |
| 31 | Party member spectates | No contribution reward | PASS |
| 32 | Player joins Party just before event completes | No reward without personal contribution | PASS |
| 33 | Player contributes then Party Leader kicks them | Valid contribution not erased solely by kick | PASS |
| 34 | Player contributes then leaves Party | Contribution may remain valid within event rules | PASS |
| 35 | Player reconnects after reward finalized | No duplicate reward | PASS |
| 36 | Reward resolution callback repeats | Exact-once finalization | PASS |
| 37 | Player changes server after reward finalized | Cannot re-earn same occurrence reward identity | PASS |
| 38 | Shared server objective succeeds | Qualifying contributors may receive personal reward | PASS |
| 39 | Spectators are present at success | No reward without contribution | PASS |
| 40 | Last player performs final action | Does not automatically own all rewards | PASS |
| 41 | Four Party members contribute | Each evaluated independently | PASS |
| 42 | Only one Party member contributes | Only contributor qualifies | PASS |
| 43 | Server objective fails | No destruction of existing persistent value | PASS |
| 44 | Event reward grants Energy | Bounded personal game-originated Economy Source | PASS |
| 45 | Event reward attempts direct player-to-player Energy transfer | Invalid | PASS |
| 46 | Event reward retries | One finalized Energy reward maximum per identity | PASS |
| 47 | Party size increases | No automatic event reward multiplier | PASS |
| 48 | Player repeatedly joins/leaves event zone | No raw trigger farming | PASS |
| 49 | Same occurrence reward attempted on alt server | Exact-once account/occurrence semantics | PASS |
| 50 | Event completion proposed as Advanced Biome prerequisite | Invalid baseline progression dependency | PASS |
| 51 | Event Completion Record finalizes | Persistent exact-once historical fact | PASS |
| 52 | Event Completion Record is lost on reconnect | Invalid | PASS |
| 53 | Event Completion Record grants unrelated Landmark Discovery | Invalid unless upstream rule independently satisfied | PASS |
| 54 | Event Completion Record grants unrelated Species Discovery | Invalid | PASS |
| 55 | Event starts while ordinary World Creature exists | Existing creature identity unchanged | PASS |
| 56 | Event Spawn Modifier enables Event-Limited Species | Future new instances may use new pool | PASS |
| 57 | Event Spawn Modifier changes species weights | Future generation only | PASS |
| 58 | Event enables event Mutation context | Future instance generation only | PASS |
| 59 | Event starts and upgrades existing creature Mutation | Invalid | PASS |
| 60 | Event ends while event creature still exists | Existing creature retains identity | PASS |
| 61 | Event phase changes during active claim | Creature identity/claim do not reroll | PASS |
| 62 | Player fails event capture | Same surviving instance does not reroll | PASS |
| 63 | Player spends Energy after seeing event creature | No hidden reroll/odds change | PASS |
| 64 | Robux spender enters Rift | Same authored event probability context absent later commercial authority | PASS |
| 65 | Event uses friend count to boost rare odds | Invalid | PASS |
| 66 | Event uses Party size to boost Mutation odds | Invalid | PASS |
| 67 | Event changes World Cycle by restarting it | Invalid | PASS |
| 68 | Event layers modifier on current World Cycle | Allowed prospectively | PASS |
| 69 | Rift ignores ordinary cycle by explicit authored rule | Allowed for future event spawns | PASS |
| 70 | Event ends | Underlying ordinary World Cycle continues | PASS |
| 71 | Rift appears in eligible field location | Valid temporary Event Zone | PASS |
| 72 | Rift blocks only non-premium Safe Route | Invalid placement | PASS |
| 73 | Rift overlaps Recovery Anchor and traps players | Invalid | PASS |
| 74 | Rift hazard causes Recovery | Allowed temporary setback | PASS |
| 75 | Rift hazard deletes Secured Creature | Invalid | PASS |
| 76 | Rift hazard deducts arbitrary existing Energy | Invalid | PASS |
| 77 | Rift merely guarantees Legendary by standing nearby | Not implied; must be explicit deterministic reward | PASS |
| 78 | Rift expires while no active acquisition exists | Event-local state may end normally | PASS |
| 79 | Rift expires during accepted Capture Attempt | Explicit resolution/grace required | PASS |
| 80 | Rift expires during Transport Custody | Custody/extraction path remains valid | PASS |
| 81 | Public event creature appears | Ordinary GDS-5 claim semantics apply | PASS |
| 82 | Two players race to public event creature | One valid ordinary claimant | PASS |
| 83 | Party member tries to override teammate's claim | Prohibited | PASS |
| 84 | Public event creature is claimed | Party/event status does not duplicate it | PASS |
| 85 | Public event creature reaches Capture Success | One Provisional Capture | PASS |
| 86 | Event end occurs during transport | Valid custody persists through resolution | PASS |
| 87 | Server-wide announcement names rare spotlight | Announcement grants no claim/reservation | PASS |
| 88 | Announced rare vanishes almost instantly | Invalid stability/fairness | PASS |
| 89 | Whole-server centerpiece has only one immediate click-winner reward | Invalid baseline event design | PASS |
| 90 | Centerpiece has contribution-based personal reward plus public rare | Valid when rules are clear | PASS |
| 91 | Event Multi-Award Encounter begins | Must be explicitly authored/labeled | PASS |
| 92 | Shared target completes for three contributors | Up to three personal opportunities may be issued | PASS |
| 93 | Shared target is copied as one identical Creature Instance to all | Invalid | PASS |
| 94 | Each participant receives same Species | Allowed as distinct Creature Instances | PASS |
| 95 | Personal opportunities roll different legitimate Mutations | Allowed under same declared context | PASS |
| 96 | One player's rarer roll causes others to reroll | Invalid | PASS |
| 97 | Personal event opportunity is issued | Not yet Secured Ownership | PASS |
| 98 | Player completes capture/transport/extraction | Secures that distinct instance exactly once | PASS |
| 99 | Player disconnects before securing personal opportunity | No automatic ownership | PASS |
| 100 | Player hops server after personal opportunity issued | No second opportunity for same reward identity | PASS |
| 101 | Player tries retry/reconnect to reroll personal opportunity | Same issued opportunity identity cannot regenerate | PASS |
| 102 | Player has known incompatible capacity before personal reward | Must not be represented as already-earned usable capture opportunity | PASS |
| 103 | Personal opportunity remains active at occurrence end | Bounded Resolution Grace applies | PASS |
| 104 | Personal opportunity is still unfinalized after grace | May expire as transient opportunity | PASS |
| 105 | Event-Limited Species window ends | Existing owned instances remain | PASS |
| 106 | Event-Limited Species returns later | Old ownership/discovery/provenance preserved | PASS |
| 107 | Content becomes Legacy | Owned instance remains valid | PASS |
| 108 | New event Species added to mastered Biome | Prior Region Mastery remains | PASS |
| 109 | Season adds new completion tier | Must be new explicit record, not rewrite old completion | PASS |
| 110 | Event Template disabled for exploit | Stop new activation/generation prospectively | PASS |
| 111 | Disabled event had finalized legitimate Energy rewards | Rewards are not silently revoked by default | PASS |
| 112 | Disabled event had secured legitimate creatures | Owned creatures are not silently deleted/rerolled | PASS |
| 113 | Controlled server shutdown during valid Provisional Capture | GDS-5 Protected Shutdown Finalization applies | PASS |
| 114 | Server shuts down with unfinished shared objective | No blanket auto-completion | PASS |
| 115 | Protected Load Failure during event | Irreversible rewards/acquisition blocked | PASS |
| 116 | Event proposes x2 Passive Production | Not authorized by GDS-11 baseline | PASS |
| 117 | Event requires voice chat | Invalid baseline participation design | PASS |
| 118 | Event countdown is audio-only | Invalid accessibility design | PASS |
| 119 | Event introduces paid claim priority | Not authorized; violates GDS-11/GDS-10 boundaries | PASS |
| 120 | Event content rotates while player owns event creature | Ownership, Variant Identity and provenance remain stable | PASS |

## Cross-Cutting Results

### Timing/occurrence integrity

Global Event Windows and Event Occurrences use persistent wall-clock semantics; newly created servers cannot manufacture fresh private duration.

### Contribution/reward integrity

Event rewards require personal active contribution and finalize exact-once. Party membership, proximity, AFK presence and last-hit status are insufficient.

### Spawn/variant integrity

Event modifiers are prospective. Event start/end, reconnect, failure, spending and server changes do not reroll surviving or owned creatures.

### Capture integrity

Ordinary event creatures remain single-award. Multi-award exceptions issue separate personal Capture Opportunities with distinct Creature Instance identity rather than copying one target.

### Server-hop integrity

Server hopping can expose legitimately different session-local populations, but cannot reset event duration, exact-once rewards, personal cooldowns or guaranteed personal event opportunity identity.

### Live-content integrity

Rotation, Event-Limited/Legacy transitions, event disable/hotfix and seasonal reruns do not invalidate finalized ownership, mastery or provenance.

### Social/economy integrity

Events do not introduce direct-combat PvP, body-blocking, Energy transfer, Party reward multiplication or Passive Production multipliers by baseline.

## Verdict

**120 / 120 scenarios: PASS.**

No GDS-11-blocking scenario contradiction remains.
