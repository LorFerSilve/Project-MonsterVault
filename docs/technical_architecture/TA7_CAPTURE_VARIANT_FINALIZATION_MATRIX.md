# TA-7 Capture, Variant, and Finalization Matrix

> **Phase:** TA-7 — Capture, Creature Ownership, Mutation, and Reward Resolution  
> **Status:** PASS

## 1. Acquisition State Matrix

| State | Claimable by another player? | Ordinary idle despawn? | Persistent ownership? | Finalization allowed? |
|---|---:|---:|---:|---:|
| IdleAvailable | YES | YES subject to TA-9 | NO | NO |
| Claimed | NO | NO ordinary despawn | NO | NO |
| AttemptActive | NO | NO | NO | NO |
| Releasing | NO during transition | NO until resolved | NO | NO |
| Provisional | NO | NO | NO | not yet |
| TransportActive | NO | NO | NO | Secure Point / controlled shutdown |
| TransportGrace | NO until expiry | NO while grace record survives | NO | NO |
| FinalizationPending | NO | NO | pending only | P2 in progress |
| Secured | NO public claim | n/a world role ends | YES | already finalized |
| WorldRoleTerminal | NO | n/a | as durable profile says | NO duplicate |

## 2. Claim Arbitration Matrix

| Condition | Outcome |
|---|---|
| two valid BeginClaim requests arrive | first accepted serialized server transition wins |
| client timestamp says it was first | ignored for authority |
| losing claim request | reject current-state; no attempt cost |
| active claimant disconnects before success | claim/attempt interruption rule |
| active claimant cancels | bounded release |
| repeated abort/reclaim griefing | rate/cooldown/telemetry hooks |
| premium/party/friend player arrives | no claim priority |

## 3. Variant Generation Matrix

| Input | Authority | Timing |
|---|---|---|
| CreatureInstanceId | server / TA-5 | before generation |
| SpeciesId | TA-9 spawn resolution | before TA-7 variant generation |
| Species Rarity | Species registry | definition lookup |
| Mutation eligibility/weights | server-private content | one-time before actionability |
| Mutation random draw | server RNG | one-time |
| Trait eligibility/weights | server-private content | one-time |
| Trait draw | server RNG | one-time |
| Variant Signature | deterministic canonicalization | after Mutation set |
| Protected reasons | derived from finalized identity/content markers | finalized at security |

## 4. Anti-Reroll Matrix

| Action | May regenerate Variant Identity? |
|---|---:|
| claim acquired | NO |
| claim released | NO |
| capture failed | NO |
| capture retried | NO |
| reset/recovery | NO |
| disconnect/grace/resume | NO |
| Capture Success | NO |
| transport | NO |
| Secure Point extraction | NO |
| finalization retry | NO |
| trade later | NO |
| genuine world entity destruction + new spawn | YES, new CreatureInstanceId |

## 5. Capture Result Matrix

| Result | Ownership | Claim/custody consequence |
|---|---|---|
| Success | still NO | create one Provisional Capture / Transport Custody |
| Failure | NO | release/encounter rule |
| Cancel | NO | release/encounter rule |
| Invalidation | NO | release/terminal rule |
| Secure extraction P2 success | YES | world role terminal |
| Controlled shutdown P2 success from active custody | YES | world role terminal |
| abrupt crash during provisional | NO guaranteed ownership | session state may be lost |

## 6. Disconnect Matrix

| Departure classification | TA-7 behavior |
|---|---|
| explicit trusted MonsterVault voluntary exit | end custody, no grace |
| CreatorKick / deliberate server removal | end custody |
| ambiguous Unknown | bounded same-server Transport Grace |
| grace expires | provisional ends without ownership |
| same UserId rejoins same server + profile Ready before expiry | may resume same custody |
| joins different server | no custody transfer |
| server shutdown while only grace-suspended | no Protected Shutdown Finalization |

## 7. Secure Finalization Bundle

One Player Profile P2 transaction includes, as applicable:

- exact CreatureInstanceId;
- SpeciesId;
- immutable Variant Identity;
- intended owner;
- provenance;
- Stored or Overflow-Held placement outcome;
- Protected Variant auto-lock;
- Species Discovery;
- Mutation Discoveries;
- Variant Discovery;
- capture-finalization operation result/idempotency marker;
- explicitly authorized attached milestone/event reward only.

Ordinary capture adds **no implicit Energy reward**.

## 8. Capacity Matrix

| Capacity state | Capture initiation | Finalization |
|---|---|---|
| known available | allowed if other eligibility passes | normal placement |
| known full | blocked | n/a |
| unresolved Overflow-Held already blocks ordinary acquisition | blocked | n/a |
| capacity available at start but lost before extraction | accepted loop preserved | Overflow-Held |
| race recovered before extraction | normal placement | normal |
| client claims capacity available | ignored; server profile state wins | server validates |

## 9. Randomness Matrix

| Random use | Allowed? | Rules |
|---|---:|---|
| Species spawn choice | TA-9 | server-private, downstream |
| Mutation/Trait generation | YES | one-time server RNG before actionability |
| capture success RNG | YES if challenge config authorizes | one sample per accepted logical attempt |
| retry same request/result | NO new draw | reconcile old outcome |
| client-side random success | NO | presentation only |
| spending-based odds | NO | prohibited |
| test seeded RNG | YES | deterministic fixtures/statistical validation |

## 10. Protected Variant Matrix

| Criterion | Auto-lock on first security? |
|---|---:|
| Legendary Species | YES |
| Extreme Mutation | YES |
| Compound Variant | YES |
| explicit event/legacy protection marker | YES |
| ordinary non-protected instance | NO unless player manually locks later |

## 11. Controlled Shutdown Matrix

| Runtime state when drain snapshot occurs | Protected finalization? |
|---|---:|
| IdleAvailable | NO |
| Claimed | NO |
| AttemptActive before Capture Success | NO |
| active Provisional / TransportActive | YES, using existing operation ID |
| TransportGrace / player disconnected | NO |
| already FinalizationPending | continue/reconcile same operation |
| already Secured | NO duplicate |

## Verdict

**TA-7 CAPTURE / VARIANT / FINALIZATION MATRIX: PASS.**
