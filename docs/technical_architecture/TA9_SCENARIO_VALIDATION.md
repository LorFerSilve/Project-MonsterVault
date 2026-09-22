# TA-9 Scenario Validation

> **Phase:** TA-9 — World, Biomes, Spawn Scheduling, Streaming, and Encounter Scaling  
> **Status:** PASS  
> **Scenario count:** 240 / 240 PASS

TA-9 validation covers world bootstrap, progression, spawn generation, streaming, travel, hazards, performance degradation, failure recovery and exploit boundaries.

## Bootstrap and authoring

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 1 | server starts with valid Region/Habitat registries | World Authoring Index validates and reaches Ready | PASS |
| 2 | Region authored with unknown RegionId | bootstrap fails closed | PASS |
| 3 | Habitat references unknown Region | bootstrap fails closed | PASS |
| 4 | duplicate unique LandmarkId instances | bootstrap fails closed | PASS |
| 5 | field Biome has no required Safe Outpost | bootstrap fails closed | PASS |
| 6 | Safe Outpost has no Recovery Anchor | bootstrap fails closed | PASS |
| 7 | required Secure Point reference missing | bootstrap fails closed | PASS |
| 8 | Spawn Volume references unknown SpawnContextId | bootstrap fails closed | PASS |
| 9 | Spawn Context references unknown Species | TA-5/TA-9 content validation fails | PASS |
| 10 | Hazard role overlaps prohibited Safe Outpost volume | bootstrap fails closed | PASS |
| 11 | replicated attribute contains hidden spawn weight | architecture violation | PASS |
| 12 | Workspace object renamed but stable semantic attribute unchanged | semantic identity unaffected | PASS |
| 13 | world definition module has side effect on require | architecture violation | PASS |
| 14 | world service starts before registries validate | architecture violation | PASS |
| 15 | future Biome added with valid graph references | index extends without rewriting existing IDs | PASS |

## Region access and topology

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 16 | new player becomes Persistence Ready | Home Hub/Safe Arrival is available | PASS |
| 17 | Starter entry with no Energy purchase | allowed after onboarding prerequisite | PASS |
| 18 | Mid A access with Starter Mastery + unlock | allowed | PASS |
| 19 | Mid A access with Energy but no Starter Mastery | denied | PASS |
| 20 | Mid B unlock owned while Mid A not owned | Mid B may still be entered if its own prerequisites are satisfied | PASS |
| 21 | Advanced access missing Mid A Mastery | denied | PASS |
| 22 | Advanced access missing Mid B Mastery | denied | PASS |
| 23 | Advanced access has both Masteries + unlock | allowed | PASS |
| 24 | client locally moves into locked Region | valuable interactions remain denied | PASS |
| 25 | server observes character in locked Region via exploit/physics escape | recover to valid unlocked anchor when appropriate | PASS |
| 26 | client sends RegionId inconsistent with target runtime object | server derives target Region and rejects mismatch | PASS |
| 27 | existing Access Unlock price later changes | owned access remains valid | PASS |
| 28 | new Region added later | existing Access Unlocks remain owned | PASS |
| 29 | ordinary region transition attempts second-place teleport | not baseline TA-9 path | PASS |
| 30 | future multi-place proposal | requires architecture change control | PASS |

## Landmarks, objectives, and mastery

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 31 | player legitimately enters undiscovered Landmark volume | P2 Landmark Discovery may finalize | PASS |
| 32 | client claims Landmark without server position evidence | rejected | PASS |
| 33 | same Landmark trigger fires twice in one frame | one finalization/reward maximum | PASS |
| 34 | Landmark P2 succeeds but response is lost | retry reconciles same operation | PASS |
| 35 | player revisits Landmark next session | no duplicate first reward | PASS |
| 36 | qualifying Core Species secured in Region | historical regional Species evidence records | PASS |
| 37 | same Species secured again in same Region | distinct count unchanged | PASS |
| 38 | Species secured in non-qualifying context | does not count for that Region | PASS |
| 39 | player trades away qualifying creature later | historical evidence remains | PASS |
| 40 | one-time Field Objective completes | P2 completion/reward finalizes once | PASS |
| 41 | repeatable objective reuses old ObjectiveInstanceId | no duplicate reward | PASS |
| 42 | new valid repeatable ObjectiveInstanceId completes | may reward once | PASS |
| 43 | AFK presence inside objective area | no reward unless authored active conditions completed | PASS |
| 44 | all Mastery evidence becomes complete | one P2 Region Mastery finalizes | PASS |
| 45 | new Species/Landmark content added after Mastery | existing Mastery remains finalized | PASS |

## Ordinary World Cycle

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 46 | server boots halfway through cycle | derives current phase from epoch/time | PASS |
| 47 | second server boots same moment | derives coherent phase relationship | PASS |
| 48 | player joins during Night | join does not reset to Day | PASS |
| 49 | player server-hops | cycle does not intentionally restart | PASS |
| 50 | client clock is changed | server cycle unaffected | PASS |
| 51 | phase boundary passes | future Spawn Context eligibility updates | PASS |
| 52 | ordinary creature survives phase change | Species/Variant identity unchanged | PASS |
| 53 | active claim spans phase change | claim state unchanged | PASS |
| 54 | cycle duration C2 update becomes effective | new phase calculation uses versioned effective definition | PASS |
| 55 | old creature predates cycle update | keeps pinned generation context | PASS |
| 56 | wall-clock input regresses unexpectedly | diagnostic/protected handling; no client authority | PASS |
| 57 | event rift requested as cycle phase | routed to TA-10, not ordinary cycle | PASS |
| 58 | World Cycle display event lost to client | client reconciles current phase | PASS |
| 59 | server has no MemoryStore access | ordinary World Cycle still functions | PASS |
| 60 | player spending state changes | cycle and eligibility rules do not personalize | PASS |

## Scheduler and population budgets

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 61 | bucket count below desired by one | at most bounded refill creates reservation | PASS |
| 62 | bucket count equals desired | no refill | PASS |
| 63 | bucket count above desired but below max | no forced valuable deletion; natural expiry can reduce | PASS |
| 64 | bucket at max | no new reservation | PASS |
| 65 | two scheduler passes race on same deficit | pending reservation accounting prevents oversubscription | PASS |
| 66 | many habitats become due together | work is staggered | PASS |
| 67 | no eligible players near distant habitat | bucket may become Dormant | PASS |
| 68 | player approaches Dormant habitat | activation begins bounded refill | PASS |
| 69 | 20 players join at once | desired population stays within max | PASS |
| 70 | players leave | desired population may fall gradually | PASS |
| 71 | server backpressure rises | ordinary target may reduce toward minimum | PASS |
| 72 | server backpressure clears | refill can recover gradually | PASS |
| 73 | onboarding opportunity needed while public bucket full | reserved onboarding path remains available | PASS |
| 74 | one spawn point owns permanent Heartbeat loop | prohibited architecture | PASS |
| 75 | scheduler scans every Workspace descendant every frame | prohibited architecture | PASS |

## Spatial index and placement

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 76 | static spawn anchors load | indexed once at bootstrap | PASS |
| 77 | dynamic creature moves cells | spatial index updates at bounded cadence/transition | PASS |
| 78 | candidate placement outside authored Spawn Volume | rejected | PASS |
| 79 | candidate inside Safe Outpost exclusion | rejected | PASS |
| 80 | candidate overlaps blocked geometry | retry placement for same reservation | PASS |
| 81 | candidate lacks required ground support | retry/defer same reservation | PASS |
| 82 | candidate too near prohibited utility radius | rejected | PASS |
| 83 | client proposes exact spawn CFrame | ignored/rejected | PASS |
| 84 | localized occupancy check required | use bounded WorldRoot query after candidate narrowing | PASS |
| 85 | legacy Region3 scan proposed | prefer current WorldRoot query architecture | PASS |
| 86 | spatial index stale for one tick | final validation uses current runtime/physics where material | PASS |
| 87 | placement retry succeeds elsewhere in same scope | same creature identity materializes | PASS |
| 88 | placement retries exhaust | reservation terminates with reason and slot releases once | PASS |
| 89 | two reservations target same exclusive anchor | occupancy/reservation check prevents double placement | PASS |
| 90 | world cell size tuning changes | semantic Region/Habitat identity unaffected | PASS |

## Spawn reservation and randomness

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 91 | scheduler authorizes new spawn | creates one SpawnReservationId | PASS |
| 92 | reservation created | population slot is reserved immediately | PASS |
| 93 | Species weighted draw executes | server RNG only | PASS |
| 94 | client supplies random seed | ignored/rejected | PASS |
| 95 | Species selected | one CreatureInstanceId allocated | PASS |
| 96 | TA-7 Variant generation executes | exactly once for reservation | PASS |
| 97 | projection creation fails once | retry same Species/Variant | PASS |
| 98 | placement fails after Variant generation | retry placement same identity | PASS |
| 99 | client streams creature out then in | identity unchanged | PASS |
| 100 | claim fails and creature survives | identity unchanged | PASS |
| 101 | cycle changes after reservation | identity unchanged | PASS |
| 102 | spawn weights change after reservation | identity unchanged | PASS |
| 103 | reservation genuinely terminates | later refill may create independent new outcome | PASS |
| 104 | high spender enters habitat | same context distribution rules | PASS |
| 105 | device type changes | no collectible odds change | PASS |

## Materialization and runtime lifecycle

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 106 | reservation passes placement validation | TA-6 runtime entity enters registration/materialization | PASS |
| 107 | Roblox Model exists without registered runtime record | architecture violation | PASS |
| 108 | runtime record active but one client lacks Model | valid under streaming | PASS |
| 109 | projection creation transiently errors | bounded retry same runtime identity | PASS |
| 110 | runtime revision changes during async callback | stale callback rejected | PASS |
| 111 | projection is locally destroyed by exploiter | server semantic state unaffected | PASS |
| 112 | server projection is destroyed accidentally while record active | lifecycle can rematerialize or terminate explicitly | PASS |
| 113 | creature genuinely terminates | cleanup owner removes registry/projection/population references once | PASS |
| 114 | cleanup called twice | second call is idempotent | PASS |
| 115 | reservation cleanup and runtime cleanup race | one slot-release effect maximum | PASS |
| 116 | server shutdown with idle unclaimed encounter | session-local encounter disappears without grant | PASS |
| 117 | server shutdown with active transport custody | TA-7 narrow shutdown rule owns outcome | PASS |
| 118 | runtime model name changes | CreatureInstanceId authority unchanged | PASS |
| 119 | entity projection carries safe semantic ID attribute | allowed disclosure-safe projection | PASS |
| 120 | projection contains hidden weighted table | architecture violation | PASS |

## Lifetime and Protected Variants

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 121 | ordinary idle creature reaches lifetime deadline | may terminate | PASS |
| 122 | ordinary creature lifetime not yet reached | remains active absent other termination | PASS |
| 123 | lifetime reaches deadline during Engagement Claim | idle despawn suppressed | PASS |
| 124 | deadline during Capture Attempt | idle despawn suppressed | PASS |
| 125 | deadline during Provisional Capture | idle despawn suppressed | PASS |
| 126 | deadline during Transport Custody | idle despawn suppressed | PASS |
| 127 | claim releases and lifetime already expired | may terminate after TA-7 release resolution | PASS |
| 128 | Protected Variant before stability deadline | cannot idle-despawn | PASS |
| 129 | Protected Variant after stability deadline and idle | may follow authored lifetime policy | PASS |
| 130 | Protected Variant enters active claim | acquisition protection applies | PASS |
| 131 | all clients stream Protected Variant out | server stability deadline still applies | PASS |
| 132 | server load shedding activates | Protected minimum stability not shortened | PASS |
| 133 | player latency delays approach | stability window remains server-time based | PASS |
| 134 | technical projection retry occurs | does not restart/reroll identity; lifetime policy remains explicit | PASS |
| 135 | termination frees population count | exactly once | PASS |

## Streaming behavior

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 136 | Workspace StreamingEnabled active | supported baseline | PASS |
| 137 | client joins and distant Biome not resident | client still reaches Ready without full Workspace scan | PASS |
| 138 | static model streams in partially under Default | client code tolerates missing descendants | PASS |
| 139 | self-contained interaction model requires atomic presence | Atomic may be configured | PASS |
| 140 | large map model proposed Persistent globally | reject/minimize unless measured exceptional need | PASS |
| 141 | active player-specific projection needs persistence | PersistentPerPlayer may be used narrowly | PASS |
| 142 | Model is PersistentPerPlayer for claimant | authority still remains server runtime | PASS |
| 143 | creature streams out during no acquisition | logical encounter remains until lifecycle termination | PASS |
| 144 | creature streams out during acquisition | claim/capture state remains | PASS |
| 145 | server sends semantic event before model arrives | client holds/reconciles semantic state | PASS |
| 146 | model arrives before latest semantic event | client snapshot/revision reconciles | PASS |
| 147 | StreamingTargetRadius tuned lower | access/spawn semantics unchanged | PASS |
| 148 | StreamingMinRadius tuned higher | requires TA-14 resource validation | PASS |
| 149 | streaming integrity setting changes | semantic authority unchanged | PASS |
| 150 | client deletes streamed model locally | cannot create population vacancy server-side | PASS |

## Fast travel, recovery, and utilities

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 151 | fast travel to discovered unlocked node | allowed after server validation | PASS |
| 152 | fast travel to undiscovered node | rejected | PASS |
| 153 | fast travel to locked Region node | rejected | PASS |
| 154 | fast travel during Engagement Claim | rejected | PASS |
| 155 | fast travel during Capture Attempt | rejected | PASS |
| 156 | fast travel during Provisional Capture | rejected | PASS |
| 157 | fast travel during Transport Custody | rejected | PASS |
| 158 | client supplies arbitrary destination CFrame | ignored/rejected | PASS |
| 159 | destination remote area not resident | stream preparation may be requested | PASS |
| 160 | RequestStreamAroundAsync times out | no access/value bypass; travel pipeline handles readiness safely | PASS |
| 161 | fast travel away and back | surviving creature is not rerolled | PASS |
| 162 | Recovery requested after avatar failure | server selects valid unlocked safe anchor | PASS |
| 163 | preferred Recovery Anchor is locked/invalid | fallback to another valid anchor | PASS |
| 164 | Recovery Anchor overlaps hazard due bad authoring | bootstrap/runtime validation rejects it | PASS |
| 165 | Secure Point/Vault Access Point streamed out locally | server utility identity/permission remains authoritative | PASS |

## Hazards and character safety

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 166 | client reports hazard contact | server validates before consequence | PASS |
| 167 | Touched fires repeatedly | one hazard-state transition per character generation | PASS |
| 168 | server confirms severe hazard | ordinary recovery flow may begin | PASS |
| 169 | hazard interrupts Engagement Claim | TA-7 resolution owns acquisition effect | PASS |
| 170 | hazard interrupts Transport Custody | TA-7 interruption semantics apply | PASS |
| 171 | hazard affects secured Creature collection | no deletion/release/reroll | PASS |
| 172 | hazard affects Energy wallet | no arbitrary deduction | PASS |
| 173 | hazard affects Access Unlock | no revocation | PASS |
| 174 | hazard volume on required route has no telegraph content metadata | content validation/review failure | PASS |
| 175 | hazard exists inside Home Hub protected safe zone | invalid baseline authoring | PASS |
| 176 | hazard tries to recover into locked Region | anchor rejected | PASS |
| 177 | old hazard callback targets replaced Character | character generation check rejects it | PASS |
| 178 | hazard timer survives character cleanup | cleanup cancels/invalidates it | PASS |
| 179 | client network owns character physics | does not make local contact authoritative | PASS |
| 180 | hazard load shedding proposed to skip security checks | prohibited | PASS |

## Scaling and load shedding

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 181 | normal load | scheduler serves base authored population | PASS |
| 182 | moderate load | non-urgent bucket work may defer | PASS |
| 183 | higher load | ordinary populations may reduce toward minimum | PASS |
| 184 | load shedding active | rare odds remain unchanged | PASS |
| 185 | fewer total draws under load | no compensating rarity multiplier | PASS |
| 186 | active claim consumes resources | not force-despawned to recover budget | PASS |
| 187 | Protected Variant consumes resources | minimum stability retained | PASS |
| 188 | optional AI update expensive | update cadence may reduce | PASS |
| 189 | cosmetic server tween proposed for many objects | prefer client presentation/downstream | PASS |
| 190 | diagnostic aggregation expensive | batch/defer diagnostics | PASS |
| 191 | P2 Landmark transaction under load | correctness retained | PASS |
| 192 | region entitlement check under load | cannot be disabled | PASS |
| 193 | spatial query budget tight | defer spawn refill rather than trust client | PASS |
| 194 | load returns to normal | recovery is gradual, not burst-spawn | PASS |
| 195 | TA-14 later tightens budgets | TA-9 semantic invariants remain binding | PASS |

## Failure, retry, and reconciliation

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 196 | world bootstrap validation fails | server does not advertise Ready world | PASS |
| 197 | one scheduler bucket throws | bucket pauses/diagnoses without profile corruption | PASS |
| 198 | spawn reservation write in memory fails before identity complete | no actionable creature exists | PASS |
| 199 | projection fails after identity complete | same reservation retries | PASS |
| 200 | cleanup interrupted halfway | retry idempotently completes | PASS |
| 201 | client misses creature-spawn event | current server snapshot/projection reconciles | PASS |
| 202 | client receives stale runtime revision | discard stale update | PASS |
| 203 | Landmark P2 unknown write outcome | retry same operation ID | PASS |
| 204 | Field Objective P2 unknown outcome | reconcile same ObjectiveInstance/operation | PASS |
| 205 | Mastery P2 response lost | reconcile finalized milestone | PASS |
| 206 | Energy wallet full on world reward | TA-8 deferred grant preserves remainder | PASS |
| 207 | stream request throws/times out | semantic transaction not duplicated | PASS |
| 208 | server clock/config unavailable for World Cycle | fail protected rather than accept client time | PASS |
| 209 | required content snapshot unavailable for new spawn | do not invent fallback odds | PASS |
| 210 | orphan population slot detected | reconciliation/diagnostics repair without minting creature | PASS |

## Security and abuse guardrails

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 211 | client asks to spawn Legendary | rejected | PASS |
| 212 | client edits local RegionId attribute | server index/runtime unaffected | PASS |
| 213 | client fires Landmark remote from Home Hub | server position/context rejects | PASS |
| 214 | client replays old travel command | freshness/state validation rejects as needed | PASS |
| 215 | client floods travel route | TA-3 rate limiting applies | PASS |
| 216 | client floods objective interaction | TA-3 rate limiting + idempotency applies | PASS |
| 217 | client changes local World Cycle display | server spawn eligibility unaffected | PASS |
| 218 | client deletes hazard locally | server hazard definition/state unaffected | PASS |
| 219 | client teleports character locally to rare pocket | server interactions still validate region/context/distance | PASS |
| 220 | client tries fast travel to carry provisional capture | acquisition check rejects | PASS |
| 221 | player server-hops looking for cycle reset | cycle derives from shared epoch | PASS |
| 222 | player server-hops after Landmark reward | persistent dedupe prevents reward replay | PASS |
| 223 | spending cohort flag accidentally passed to spawn selector | schema/invariant test rejects it | PASS |
| 224 | premium entitlement attempts to increase population odds | prohibited by TA-9/GDS-13 | PASS |
| 225 | operator wants hidden manual rare grant through scheduler | must use explicit governed admin/content path, not spoof ordinary spawn | PASS |

## Content evolution and cross-system handoff

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 226 | spawn weight changes prospectively | future reservations use new snapshot | PASS |
| 227 | existing creature when weight changes | identity unchanged | PASS |
| 228 | Species retired from generation | new eligibility stops; existing instances remain resolvable | PASS |
| 229 | Biome gains new Species | existing Region Mastery remains | PASS |
| 230 | Biome gains new Landmark | existing Mastery remains | PASS |
| 231 | new Secure Point proposed beside rare pocket | requires route/transport review before content acceptance | PASS |
| 232 | new Travel Node trivializes transport | content review rejects/changes placement | PASS |
| 233 | event wants temporary spawn modifier | TA-10 occurrence authority required | PASS |
| 234 | party wants shared claim rules | TA-10 owns social allocation | PASS |
| 235 | trade transfers world-origin creature | TA-12 trade preserves CreatureInstanceId/provenance; TA-9 history not fabricated | PASS |
| 236 | commercial product wants region skip | not authorized by TA-9 baseline | PASS |
| 237 | UI wants minimap | TA-12 consumes semantic world projection | PASS |
| 238 | analytics wants spawn cohort metrics | TA-13 may observe but not become authority | PASS |
| 239 | performance team sets exact population/query numbers | TA-14 owns measured budgets | PASS |
| 240 | TA-17 starts implementation planning | must preserve all TA-9 locked invariants | PASS |

## Verdict

**240 / 240 scenarios: PASS.**

No TA-9 world-authoring, region-authority, spawn-scheduling, population-scaling, identity, streaming, travel, hazard, persistence, failure-recovery or exploit contradiction remains.
