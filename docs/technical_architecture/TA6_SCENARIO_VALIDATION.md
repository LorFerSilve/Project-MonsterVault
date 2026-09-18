# TA-6 Scenario Validation

> **Phase:** TA-6 — Runtime Entity, Player, Creature, and World Lifecycle  
> **Status:** PASS  
> **Purpose:** Validate runtime identity, player/character separation, creature lifecycle, projection semantics, streaming, physics trust, cleanup, stale async protection, late join, shutdown and persistent/runtime transitions.

| # | Scenario | Expected result | Result |
|---:|---|---|---|
| 1 | Player joins before profile is ready | Player Session exists but no irreversible Active Presence | PASS |
| 2 | Character appears before profile readiness | Character does not authorize irreversible gameplay | PASS |
| 3 | Profile becomes Ready | Safe-arrival/character runtime may progress | PASS |
| 4 | Profile load enters ProtectedLoadFailure | Character/presentation cannot create persistent outcomes | PASS |
| 5 | Player Session closes | Runtime references are cleaned | PASS |
| 6 | Player reconnects | New Player Session runtime is created | PASS |
| 7 | Player changes server | Persistent profile reloads; old runtime entities do not transfer | PASS |
| 8 | Late join enters old running server | Receives current surviving world state only | PASS |
| 9 | Late join after creature despawn | Creature is not recreated merely for joiner | PASS |
| 10 | Late join after finite reward consumed | No runtime resurrection of reward | PASS |
| 11 | Player object is treated as persistent profile | Invalid architecture | PASS |
| 12 | Character Model stores authoritative Energy | Invalid | PASS |
| 13 | Character Model stores authoritative Creature ownership | Invalid | PASS |
| 14 | Player Session references TA-4 profile handle | Valid | PASS |
| 15 | CharacterAdded fires | New Character Presence generation begins | PASS |
| 16 | CharacterRemoving fires | Current generation invalidates | PASS |
| 17 | Character dies | Persistent profile remains | PASS |
| 18 | Character resets | Persistent profile remains | PASS |
| 19 | Character disappears due runtime failure | Recovery path, not profile loss | PASS |
| 20 | New character after reset | New characterGeneration | PASS |
| 21 | Old character callback fires after respawn | Rejected/no-op by generation check | PASS |
| 22 | Client command targets stale character generation | Reject stale state | PASS |
| 23 | Recovery spawn CFrame supplied by client | Not authoritative | PASS |
| 24 | Server resolves Recovery Anchor | Valid | PASS |
| 25 | Recovery occurs during provisional capture | Owning TA-7 interruption rule applies; no auto-secure | PASS |
| 26 | Recovery reloads player profile from scratch unnecessarily | Invalid baseline | PASS |
| 27 | Recovery wipes secured creatures | Prohibited | PASS |
| 28 | Recovery awards default reward | Prohibited | PASS |
| 29 | Character materialization fails | Retry/recovery without persistence corruption | PASS |
| 30 | Half-constructed character receives capture input | Reject until active valid presence | PASS |
| 31 | Runtime entity ID generated server-side | Valid | PASS |
| 32 | Client chooses RuntimeEntityId | No authority | PASS |
| 33 | Runtime ID reused after destruction | Prohibited | PASS |
| 34 | Workspace Model name used as runtime identity | Prohibited | PASS |
| 35 | Instance hierarchy path used as persistent identity | Prohibited | PASS |
| 36 | Runtime registry maps ID to authoritative record | Valid | PASS |
| 37 | Client cache maps same ID to local projection | Valid projection only | PASS |
| 38 | Client cache treated as authority | Invalid | PASS |
| 39 | Entity registered after semantic initialization | Correct | PASS |
| 40 | Entity becomes interactable before registry registration | Invalid | PASS |
| 41 | Entity becomes interactable before required identity is final | Invalid | PASS |
| 42 | Entity destroyed but registry entry remains interactable | Invalid | PASS |
| 43 | Entity terminal cleanup deregisters it | Correct | PASS |
| 44 | Repeated deregistration call | Idempotent/safe | PASS |
| 45 | Runtime record exists without Model during materialization | Valid transitional state | PASS |
| 46 | Model exists without registered authoritative entity | Not interactable/invalid if exposed | PASS |
| 47 | Model cloned | Does not clone semantic ownership | PASS |
| 48 | Model clone accidentally shares same active target binding | Validation must reject duplicate authority | PASS |
| 49 | Roblox Model destroyed locally on client | Server entity unchanged | PASS |
| 50 | Server projection destroyed intentionally | Semantic entity transition handled separately | PASS |
| 51 | Secured creature display Model destroyed | Ownership unchanged | PASS |
| 52 | Active creature display re-materialized | Same CreatureInstanceId | PASS |
| 53 | Re-materialization generates new variant | Prohibited | PASS |
| 54 | Release transaction completes | Persistent ownership change belongs downstream, not projection destruction | PASS |
| 55 | Display unassign occurs | Projection state changes; ownership remains | PASS |
| 56 | Two read-only showcase projections reference one creature | Allowed only where GDS permits; no duplication | PASS |
| 57 | Showcase projection creates second collection entry | Prohibited | PASS |
| 58 | World Creature generated | Server assigns CreatureInstanceId | PASS |
| 59 | Same Species creates second World Creature | New distinct CreatureInstanceId | PASS |
| 60 | World Creature becomes individually actionable before Variant Identity final | Prohibited | PASS |
| 61 | World Creature actionable after complete identity | Valid | PASS |
| 62 | Idle World Creature expires | May terminate/despawn | PASS |
| 63 | Protected Variant idle stability window still active | Ordinary expiry cannot terminate | PASS |
| 64 | Protected Variant streams out for one player | Server stability window unchanged | PASS |
| 65 | Idle creature genuinely despawns | Runtime ID ends permanently | PASS |
| 66 | Population later creates replacement | New CreatureInstanceId/new generation | PASS |
| 67 | Claim begins before idle expiry | Ordinary despawn blocked | PASS |
| 68 | Idle timer fires during valid claim | Revalidate state; no despawn | PASS |
| 69 | Capture Attempt active | Ordinary idle lifetime does not reclaim entity | PASS |
| 70 | Provisional Capture active | Ordinary idle lifetime does not reclaim entity | PASS |
| 71 | Transport Custody active | Ordinary idle lifetime does not reclaim entity | PASS |
| 72 | Claim fails and same creature survives | Returns with same CreatureInstanceId | PASS |
| 73 | Claim fails and same creature survives | Variant Identity unchanged | PASS |
| 74 | Claim failure creates new creature to reroll | Prohibited | PASS |
| 75 | Creature is truly terminated by owning rule | Later replacement independent | PASS |
| 76 | Secured Ownership Finalization commits | Public world role quiesces/ends | PASS |
| 77 | Secured finalization generates new owned CreatureInstanceId | Prohibited | PASS |
| 78 | Secured finalization preserves original instance | Required | PASS |
| 79 | World Model destroyed before durable ownership finalization | Cannot fabricate final ownership | PASS |
| 80 | P2 ownership commit succeeds after response loss | Persistent state survives; runtime reconciles | PASS |
| 81 | World population refills after secure finalization | Refill is different creature | PASS |
| 82 | Server shutdown with idle World Creature | Session-local opportunity ends | PASS |
| 83 | Server shutdown after P2 secure commit | Ownership survives through TA-4 | PASS |
| 84 | Session-local World Creature is persisted automatically on shutdown | Prohibited | PASS |
| 85 | Runtime component owns cleanup for creature | Valid | PASS |
| 86 | Roblox network owner considered creature owner | Prohibited conflation | PASS |
| 87 | Temporary claim holder considered secured owner | Prohibited until finalization | PASS |
| 88 | Projection owner considered persistent owner | Prohibited | PASS |
| 89 | Client gains physics network ownership of creature assembly | No gameplay ownership consequence | PASS |
| 90 | Client teleports owned physics assembly near Secure Point | Server validates semantic/spatial state | PASS |
| 91 | Touched fires from client-owned physics | Not sufficient for critical finalization | PASS |
| 92 | Critical interactable anchored/server-controlled | Preferred where feasible | PASS |
| 93 | Client position differs due latency | Server uses tolerant owning validation | PASS |
| 94 | Physics visual prediction differs | Presentation reconciles; semantic state server-owned | PASS |
| 95 | Runtime entity Model streams out | Client drops local reference | PASS |
| 96 | Runtime entity remains server Active while streamed out | Correct | PASS |
| 97 | Model streams back in | Client reacquires same identity/projection | PASS |
| 98 | Client interprets stream-out as despawn | Invalid | PASS |
| 99 | Client interprets stream-out as capture failure | Invalid | PASS |
| 100 | Client interprets stream-out as lost ownership | Invalid | PASS |
| 101 | Far creature never streams to a client | Server lifecycle unaffected | PASS |
| 102 | Persistent model used for every creature to avoid streaming | Invalid baseline/performance risk | PASS |
| 103 | Small critical model deliberately Persistent after TA-9 review | Potentially valid exceptional case | PASS |
| 104 | Atomic model streaming used for coherent creature visual | Valid presentation strategy | PASS |
| 105 | Atomic streaming changes creature lifecycle | Prohibited | PASS |
| 106 | StreamingTargetRadius changed | No semantic identity effect | PASS |
| 107 | Client has no target Model due streaming | No arbitrary Instance command fallback | PASS |
| 108 | Client command uses stable interaction target ID | Valid input shape | PASS |
| 109 | Server resolves target ID to current record | Required | PASS |
| 110 | Target ID is well-formed but unknown | Reject NotFound | PASS |
| 111 | Target exists but terminating | Reject InvalidState | PASS |
| 112 | Target runtimeRevision stale | Reject/reconcile | PASS |
| 113 | Target kind mismatches route | Reject | PASS |
| 114 | Client sends arbitrary Workspace Instance | Baseline avoids/rejects | PASS |
| 115 | Target Model renamed | Stable target ID unaffected | PASS |
| 116 | Model reparented legitimately | Server registry identity unaffected | PASS |
| 117 | Static Landmark found by stable LandmarkId | Valid | PASS |
| 118 | Duplicate unique LandmarkId in world | Bootstrap validation fails | PASS |
| 119 | Static world object disappears unexpectedly | World integrity fault, not silent ID remap | PASS |
| 120 | Spawn point structural tag exists | TA-9 runtime index may consume | PASS |
| 121 | Spawn point has unknown SpawnContextId | TA-5/9 validation fails | PASS |
| 122 | World attribute contains hidden odds | Prohibited replicated disclosure | PASS |
| 123 | Runtime projection attribute contains public RuntimeEntityId | Valid as disclosure-safe reference | PASS |
| 124 | Attribute presence considered authorization | Invalid | PASS |
| 125 | Generic entity creation allocates ID after context validation | Valid | PASS |
| 126 | Creation fails during initialization | Clean partial resources | PASS |
| 127 | Projection materialization fails | Entity not exposed half-valid | PASS |
| 128 | Materialization retry creates second semantic entity | Prohibited | PASS |
| 129 | Projection retry reuses same semantic runtime record | Valid | PASS |
| 130 | Entity active then begins terminal transition | New interactions blocked | PASS |
| 131 | In-flight owning transaction still resolving | Quiescing permits bounded handoff | PASS |
| 132 | Terminal transition called twice | Idempotent | PASS |
| 133 | Destroy projection before disconnecting custom external connection | Cleanup owner still disconnects tracked connection | PASS |
| 134 | Long-lived table retains destroyed entity | Memory leak; invalid | PASS |
| 135 | Entity timer remains after destroy | Must cancel/invalidate | PASS |
| 136 | Delayed callback captures only raw Model reference | Insufficient; must revalidate ID/generation/revision | PASS |
| 137 | Delayed callback captures entity ID + expected revision | Valid pattern | PASS |
| 138 | Delayed callback fires after new entity occupies similar location | No effect on replacement | PASS |
| 139 | Old runtime ID ever maps to replacement | Prohibited | PASS |
| 140 | Character-scoped timer fires after new respawn | No-op via characterGeneration | PASS |
| 141 | Timer expiry trusts prior state without recheck | Invalid | PASS |
| 142 | Timer expiry re-resolves entity/state | Correct | PASS |
| 143 | Client countdown expires early | No authoritative transition | PASS |
| 144 | Server timer expires | Owning state transition may execute | PASS |
| 145 | RuntimeRevision changes on lifecycle transition | Valid | PASS |
| 146 | runtimeRevision reused as profileRevision | Invalid conflation | PASS |
| 147 | Client chooses next runtimeRevision | No authority | PASS |
| 148 | Projection event arrives stale | Client ignores/reconciles by revision | PASS |
| 149 | Terminal event followed by older Active projection event | Older event cannot resurrect entity | PASS |
| 150 | Reconnect rebuilds client projection cache | Valid | PASS |
| 151 | Client cache persists across server transition as truth | Invalid | PASS |
| 152 | Initial session snapshot references current world projections safely | Valid | PASS |
| 153 | Client receives raw server runtime record including secrets | Prohibited | PASS |
| 154 | Public Species/Variant cue fields projected | Valid when GDS permits | PASS |
| 155 | Hidden random weights projected | Prohibited | PASS |
| 156 | Server has one Heartbeat listener per hundreds of entities | Architecture flags performance risk | PASS |
| 157 | Centralized scheduler owns many expiries | Preferred pattern where suitable | PASS |
| 158 | Full Workspace scanned every frame for creatures | Prohibited performance pattern | PASS |
| 159 | Runtime registry/index supplies entity lookup | Valid | PASS |
| 160 | Streamed-out entity removed from server population count | Invalid | PASS |
| 161 | Destroyed entity still consumes population count | Invalid after terminal cleanup | PASS |
| 162 | Acquisition-protected creature counted as alive | Correct | PASS |
| 163 | Population scheduler kills claim-active creature to free slot | Prohibited | PASS |
| 164 | LOD lowers visual fidelity | Semantic state unchanged | PASS |
| 165 | Model pooling introduced for projections | Allowed only with complete reset/rebinding and TA-14 evidence | PASS |
| 166 | Pooled Model reuses old CreatureInstanceId accidentally | Prohibited | PASS |
| 167 | Semantic entity IDs pooled | Prohibited | PASS |
| 168 | Cleanup uses third-party package during TA-6 | Not baseline; TA-1 dependency gate applies | PASS |
| 169 | First-party cleanup owner tracks connections/tasks | Valid | PASS |
| 170 | Error in one projection cleanup revives entity | Prohibited | PASS |
| 171 | Projection asset missing | No fallback random Species identity | PASS |
| 172 | Projection asset missing for secured creature | Ownership remains; presentation error only | PASS |
| 173 | Runtime record invariant invalid before Active | Fail closed | PASS |
| 174 | World server begins shutdown | Stop new dynamic generation | PASS |
| 175 | Shutdown lets idle world entities vanish | Valid session-local end | PASS |
| 176 | Shutdown invents secure ownership for provisional creature | Prohibited | PASS |
| 177 | Shutdown deletes already secured creature from profile | Prohibited | PASS |
| 178 | Event world overlay uses TA-6 generic lifecycle | Valid for TA-10 refinement | PASS |
| 179 | Trade Session uses server runtime ID/lifecycle | Valid for TA-10 refinement | PASS |
| 180 | Party runtime state projected as persistent ownership | Invalid | PASS |
| 181 | Test constructs runtime entity without Roblox Model | Supported for unit testing | PASS |
| 182 | Test forces projection materialization failure | Required downstream test | PASS |
| 183 | Test simulates client stream-out | Semantic entity stays alive | PASS |
| 184 | Test simulates stale callback | No mutation | PASS |
| 185 | Test simulates duplicate terminal cleanup | No duplicate effect | PASS |
| 186 | Test simulates Character reset during async action | Old generation invalidates work | PASS |
| 187 | TA-7 refines acquisition substate without replacing TA-6 entity identity | Correct | PASS |
| 188 | TA-9 refines spawn/streaming budgets without making client visibility authoritative | Correct | PASS |
| 189 | TA-17 writes runtime code before final contract lock | Still prohibited now | PASS |
| 190 | Player/character/entity/projection lifecycle remains coherent across reset, streaming, capture and shutdown | Required integrated outcome | PASS |

## Verdict

**190 / 190 scenarios: PASS.**

No TA-6 runtime-identity, lifecycle, projection, streaming, physics, cleanup or persistent-transition contradiction remains.
