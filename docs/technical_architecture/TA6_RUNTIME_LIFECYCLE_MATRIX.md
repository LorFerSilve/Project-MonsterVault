# TA-6 Runtime Lifecycle and Projection Matrix

> **Phase:** TA-6 — Runtime Entity, Player, Creature, and World Lifecycle  
> **Status:** PASS  
> **Purpose:** Make authoritative runtime states, projections, ownership concepts and terminal behavior explicit before capture/runtime implementation.

## 1. Authority Matrix

| Concept | Authoritative owner | Roblox Instance role | Persistent? |
|---|---|---|---:|
| Player Session | server session/runtime coordinator | Player is platform handle | NO |
| Player Profile | TA-4 persistence | never stored on Character as authority | YES |
| Character Presence | server runtime/player domain | Character Model projection | NO |
| World Creature | server creature/world runtime | Workspace Model projection | NO unless secured |
| Secured Creature | TA-4 profile + creature domain | optional owned projection | YES |
| Capture/claim state | TA-7 | optional visual markers | transient until finalization |
| Runtime Event/Encounter | owning server domain | optional world projection | usually session-local |
| Static Landmark/Anchor | TA-9 world registry | authored Workspace Instance | content/static |
| Client entity cache | client controller | local refs/projections | NO |

## 2. Ownership Terminology Matrix

| Ownership term | Meaning | Can create persistent creature ownership? |
|---|---|---:|
| persistent player owner | account owning Secured Creature | YES, only through authoritative transaction |
| runtime component owner | subsystem responsible for state/cleanup | NO |
| Roblox network owner | simulator of unanchored physics | NO |
| claim/acquisition owner | temporary TA-7 authority | NO until finalization |
| projection owner | component that created/modelled Instance | NO |

## 3. Generic Runtime Lifecycle

| State | Registered? | Interactable? | Projection required? | New work? |
|---|---:|---:|---:|---:|
| Allocated | NO | NO | NO | NO |
| Initializing | NO | NO | NO | internal only |
| Registered | YES | route-defined | NO | limited |
| Materializing | YES | NO baseline | pending | NO irreversible |
| Active | YES | YES by domain | usually | YES |
| Quiescing | YES | NO new | optional | drain only |
| Terminating | YES until cleanup | NO | being removed | NO |
| Destroyed | NO | NO | NO | NO |

## 4. Player Session / Character Matrix

| Player session | Character | Irreversible gameplay? | Notes |
|---|---|---:|---|
| profile acquiring | absent/present loading shell | NO | trusted profile not ready |
| ProtectedLoadFailure | any presentation shell | NO | no irreversible state |
| Ready + Character spawning | incomplete | NO | safe arrival pending |
| Ready + Character alive | valid | YES subject to domain rules | Active Presence |
| Ready + Character failed | invalid/removing | NO character-dependent actions | Recovery |
| Ready + no Character | absent | read-only/session ops only as authorized | no movement interaction |
| Leaving | removing | NO new P2 | bounded resolution only |

## 5. World Creature Lifecycle Matrix

| State | Idle despawn allowed? | Capture interaction? | Identity changes? | Projection |
|---|---:|---:|---:|---|
| Generated/Initializing | NO | NO | fixed before actionable | optional |
| IdleAvailable | YES subject lifetime/stability | YES | NO | expected |
| Engagement/Acquisition active | NO ordinary idle despawn | TA-7 owns | NO | expected/owning |
| returns to IdleAvailable | YES after owning resolution | YES | NO reroll | same/re-materialized projection |
| Secured finalization pending | NO | no competing new acquisition | NO | quiescing |
| Secured durable | world role ends | NO public claim | same CreatureInstanceId | world projection removed/replaced |
| Terminating | NO | NO | NO | destroy |
| Destroyed | n/a | NO | ID never reused | none |

## 6. Projection Matrix

| Semantic entity | Projection may disappear? | Meaning of disappearance |
|---|---:|---|
| World Creature on one client due streaming | YES | no semantic change |
| World Creature server projection destroyed by lifecycle | YES | entity terminating/terminated according to server state |
| Secured Creature display Model | YES | ownership unchanged |
| Character Model | YES | Character Presence ends/recovery; Player Session persists |
| Landmark client-side due streaming | YES | Landmark semantic definition still exists |
| Event cosmetic VFX | YES | no reward/progression consequence |

## 7. Interaction Target Validation

For a client target command:

1. stable target/runtime ID format valid;
2. entity exists in server runtime registry;
3. entity kind matches route;
4. entity is in eligible lifecycle state;
5. expected runtimeRevision matches if route uses one;
6. Player Session is Ready;
7. Character Presence exists if mechanic requires it;
8. spatial/context checks pass;
9. owning domain authorization passes.

## 8. Character Generation Matrix

| Event | Generation behavior |
|---|---|
| initial character | generation N |
| CharacterRemoving | N becomes invalid |
| reset/death/recovery | old N stays invalid |
| new CharacterAdded | generation N+1 |
| delayed callback from N after N+1 exists | no-op/reject |
| client command referencing stale generation | reject stale state |

## 9. Cleanup Matrix

| Resource | Cleanup owner action |
|---|---|
| RBXScriptConnection | Disconnect or owner Instance destruction |
| entity timer/task | cancel/token invalidate |
| runtime registry entry | deregister terminal entity |
| Workspace projection | Destroy/detach |
| client projection cache | remove on stream/terminal/revision |
| player table entry | remove at session close |
| Character-scoped object | destroy at Character removal |
| population slot | release only after authoritative entity termination |

## 10. Streaming Matrix

| Situation | Correct behavior |
|---|---|
| client streams creature out | remove local visual ref only |
| server entity remains Active | continues server lifecycle/population |
| client streams same creature back | reacquire same Runtime/Creature ID |
| client never receives far creature Model | no effect on server opportunity |
| model marked Persistent | only for justified small exceptional set |
| Model Atomic | coherent visual streaming only |
| streaming config changes | never changes ownership/state semantics |

## 11. Runtime Error Matrix

| Failure | Outcome |
|---|---|
| model clone/materialization fails before Active | clean partial resources; no public interaction |
| model disappears unexpectedly | entity owner diagnoses/re-materializes/terminates safely |
| runtime record invalid | fail closed, no interaction |
| stale timer fires after entity destroyed | no-op after re-resolve/generation check |
| cleanup invoked twice | idempotent terminal cleanup |
| server shutdown | no new world generation; session-local entities end; persistent outcomes stay in TA-4 |

## Verdict

**TA-6 RUNTIME LIFECYCLE / PROJECTION MATRIX: PASS.**
