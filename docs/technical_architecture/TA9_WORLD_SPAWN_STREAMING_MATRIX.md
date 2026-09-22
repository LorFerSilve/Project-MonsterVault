# TA-9 World, Spawn, Streaming, and Encounter Scaling Matrix

> **Phase:** TA-9 — World, Biomes, Spawn Scheduling, Streaming, and Encounter Scaling  
> **Status:** PASS

## 1. Authority Matrix

| Concern | Authoritative owner | Not authority |
|---|---|---|
| Region topology | TA-5 registry + TA-9 validated World Authoring Index | Workspace names/paths |
| Region entitlement | TA-8 Player Profile | client position/UI |
| ordinary encounter population | TA-9 server runtime | client Workspace |
| creature logical identity | TA-6/7 runtime record + TA-9 Spawn Reservation | Roblox Model alone |
| Variant Identity | TA-7 server generation | client/random visual |
| world progression | Player Profile P2 state | client flags |
| hazard consequence | server world/hazard state | local Touched alone |
| fast-travel target | validated TravelNode/anchor | client CFrame |
| World Cycle | server time + versioned cycle definition | per-server join timer |

## 2. World-State Persistence Matrix

| State | Scope | Durability |
|---|---|---|
| Access Unlock | persistent Player Profile | P2 |
| Landmark Discovery | persistent Player Profile | P2 |
| discovered Travel Node | persistent Player Profile | P2 baseline |
| Region Core Species evidence | persistent Player Profile | P2 with securing outcome |
| one-time Field Objective completion | persistent Player Profile | P2 |
| Region Mastery | persistent Player Profile | P2 |
| ordinary public Creature | server session | P0 runtime |
| Spawn Reservation | server session | P0 runtime |
| population counters | server session | P0 runtime |
| ordinary World Cycle projection | derived from clock/config | recomputed |
| active hazard occupancy | Character generation/session | P0 |
| scheduler backlog | server session | P0 |

## 3. World Authoring Matrix

| Authored role | Required semantic reference | Bootstrap rule |
|---|---|---|
| Region | RegionId | known unique logical region |
| Habitat | HabitatId + RegionId | known parent Region |
| Landmark | LandmarkId + RegionId | known unique landmark |
| Safe Outpost | RegionId | required for each field Biome |
| Secure Point | SecurePointId + RegionId | at least required baseline utility |
| Recovery Anchor | RecoveryAnchorId + RegionId | safe/unlocked fallback graph valid |
| Travel Node | TravelNodeId + RegionId | destination anchor valid |
| Vault Access Point | VaultAccessPointId + RegionId | semantic role valid |
| Spawn Volume/Anchor | SpawnContextId + HabitatId | context/region references valid |
| Hazard | HazardId + category | cannot overlap prohibited Safe Outpost role |

Unknown required references fail bootstrap closed.

## 4. Spawn Scheduler Matrix

| Condition | Scheduler behavior |
|---|---|
| bucket below desired count | create bounded reservations |
| bucket at desired count | no refill |
| bucket at max count | no refill |
| many buckets due simultaneously | stagger/limit per pass |
| no relevant players near bucket | may become Dormant |
| dormant bucket becomes active | refill gradually |
| server backpressure rises | reduce ordinary refill toward minimum |
| scheduler error in one bucket | isolate/pause bucket; do not corrupt player value |
| pending reservation exists | counts against population immediately |
| player count changes | desired count changes only within min/max |

## 5. Population Fairness Matrix

| Input | May affect encounter count? | May affect Species/Variant odds? |
|---|---:|---:|
| active ready player count | YES, bounded | NO |
| server performance pressure | YES, downward only | NO |
| Region/Habitat | YES | YES via authored Spawn Context |
| World Cycle phase | YES | YES prospectively via Spawn Context |
| content availability | YES | YES prospectively |
| player Robux spend | NO | NO |
| Energy balance | NO | NO |
| purchase refusal | NO | NO |
| payer cohort | NO | NO |
| device tier | performance presentation only | NO |

## 6. Spawn Reservation Matrix

| Stage | Stable data |
|---|---|
| reservation creation | SpawnReservationId, context/snapshot, population slot |
| Species selection | one server-selected SpeciesId |
| instance allocation | one CreatureInstanceId |
| Variant generation | one TA-7 Variant Identity |
| placement retry | same reservation/identity |
| projection retry | same reservation/identity |
| client stream-out/in | same runtime identity |
| claim failure with surviving creature | same identity |
| genuine termination + later refill | new reservation may roll independently |

## 7. Placement Matrix

| Validation | Required behavior |
|---|---|
| candidate outside authored spawn scope | reject candidate |
| candidate inside Safe Outpost exclusion | reject |
| invalid ground/clearance | retry placement, same reservation |
| occupied placement | retry/defer, same reservation |
| client proposes spawn point | ignore/reject |
| local physics query needed | bounded WorldRoot query after candidate narrowing |
| placement retries exhausted | terminate reservation with reason; free slot once |

## 8. Encounter Lifetime Matrix

| Creature state | Ordinary lifetime may terminate it? |
|---|---:|
| idle ordinary | YES after authored lifetime |
| valid Engagement Claim | NO |
| active Capture Attempt | NO |
| Provisional Capture | NO |
| Transport Custody | NO |
| Protected Variant before stability deadline | NO |
| Protected Variant after deadline and idle | YES, per authored lifetime rules |
| streamed out on all clients | NO by itself |
| server shutdown, unclaimed | session ends; no ownership grant |

## 9. Streaming Matrix

| Situation | Required behavior |
|---|---|
| client has not streamed creature model | server creature may still exist |
| client streams model out | semantic/runtime state persists server-side |
| interaction model should appear whole | Atomic may be used |
| ordinary environment | Default streaming baseline |
| model globally Persistent | exceptional/minimized |
| player-specific critical projection | PersistentPerPlayer only if justified/measured |
| fast travel to remote area | may RequestStreamAroundAsync |
| stream preparation times out | no authority/value change |
| client startup | must not require full Workspace scan |

## 10. Travel / Recovery Matrix

| Condition | Fast travel | Recovery |
|---|---:|---:|
| destination unknown | reject | n/a |
| node undiscovered | reject | n/a |
| Region locked | reject | reject anchor |
| Acquisition-In-Progress | reject | TA-7 interruption semantics |
| valid unlocked destination | controlled relocation | valid safe anchor |
| client sends arbitrary CFrame | reject | reject |
| target area not yet streamed | prepare best-effort; authority unchanged | same |
| Recovery Anchor in hazard | invalid authoring/runtime choice | reject |

## 11. World Progression Matrix

| Outcome | Finalization |
|---|---|
| first Landmark Discovery | P2 exact-once |
| repeated Landmark entry | no duplicate reward |
| qualifying Core Species secured | attach historical region evidence |
| same Species secured again | no new distinct-species credit |
| one-time Field Objective | P2 exact-once |
| repeatable objective | unique ObjectiveInstanceId + dedupe |
| Region Mastery prerequisites complete | P2 exact-once milestone |
| content later expands | existing Mastery remains |
| server hop | persistent progress unchanged |

## 12. Hazard Matrix

| Situation | Result |
|---|---|
| hazard contact hint from client | insufficient alone |
| repeated Touched events | idempotent server hazard state |
| server confirms severe hazard | ordinary Recovery path |
| hazard during acquisition | TA-7 interruption logic |
| hazard on secured collection | no deletion/release/reroll |
| hazard on Energy/unlocks | no arbitrary loss |
| hazard overlaps Safe Outpost | bootstrap validation failure |
| locked-region Recovery request | choose valid unlocked anchor |

## 13. World Cycle Matrix

| Situation | Result |
|---|---|
| server starts | derive current phase from shared epoch/time |
| player joins | receives current phase; no reset |
| player server-hops | new server derives same timeline |
| phase changes | future Spawn Context eligibility changes |
| existing creature survives phase change | identity unchanged |
| cycle config changes | prospective/versioned |
| event storm/rift requested | TA-10, not ordinary cycle |

## 14. Degradation Matrix

| Pressure | Allowed response | Prohibited response |
|---|---|---|
| scheduler CPU pressure | defer buckets | weaken access validation |
| high ordinary instance count | lower refill toward min | kill active acquisition |
| client memory pressure | rely on streaming | make whole map Persistent |
| server query pressure | reduce query cadence/candidates | trust client position claim |
| protected rare under load | preserve stability | shorten below minimum |
| fewer ordinary spawns | fewer opportunities | increase rare odds to compensate |
| telemetry pressure | aggregate/defer | lose P2 correctness |

## 15. Cross-Server Matrix

| Concern | Baseline TA-9 strategy |
|---|---|
| ordinary encounter ownership | server-local |
| ordinary population counts | server-local |
| rare ordinary spawn global scarcity | none |
| World Cycle | deterministic time-derived |
| server-hop cycle reset | impossible by design |
| cross-server event occurrence | TA-10 |
| MemoryStore ordinary scheduler dependency | none |
| MessagingService ordinary scheduler dependency | none |

## 16. Failure / Retry Matrix

| Failure | Required handling |
|---|---|
| invalid authored world | fail bootstrap |
| placement transient failure | retry same reservation |
| projection creation failure | bounded retry same identity |
| reservation abandonment | idempotent cleanup/free slot |
| client misses spawn event | reconcile current state |
| Landmark P2 response lost | reconcile operation; no second reward |
| objective P2 unknown result | same operation identity |
| scheduler bucket exception | isolate + diagnostics |
| streaming timeout | no semantic rollback/reroll |
| stale runtime revision | reject stale callback/command |

## Verdict

**TA-9 WORLD / SPAWN / STREAMING / ENCOUNTER SCALING MATRIX: PASS.**
