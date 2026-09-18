# TA-8 Vault, Economy, and Offline Accrual Matrix

> **Phase:** TA-8 — Vault, Economy, Progression, Inventory, and Offline Accrual  
> **Status:** PASS

## 1. Persistence Matrix

| State | Persistent authority | Durability |
|---|---|---|
| Secured Creature | Player Profile collection map | P2 |
| Overflow-Held flag | creature collection record | P2 |
| Production Assignment | Vault assignment relation | P2 |
| Display Assignment | Vault display relation | P1 baseline |
| Production Buffer | Vault production state | recomputable/P1 between checkpoints; P2 at claims/value boundaries |
| Energy Wallet | economy state | P2 for explicit mutation |
| Vault Upgrade level | economy/vault progression | P2 |
| Capture Capability | progression state | P2 |
| Access Unlock | progression state | P2 |
| Progression Quote | server session memory | P0 |
| offline recap | presentation | P0 |
| Deferred Energy Grant | economy state | P2 |

## 2. Numeric Matrix

| Value | Representation | TA-8 ceiling |
|---|---|---:|
| Energy wallet | whole integer Energy | 1,000,000,000,000 |
| production buffer | integer milli-Energy | 1,000,000,000,000,000 |
| production rate | integer milli-Energy/second | content-validated |
| Unix time | integer seconds | platform timestamp |
| upgrade levels | bounded integer | content schema |
| capacity/slots | bounded integer | TA-14/content |

All exact arithmetic/intermediates must remain below `2^53`.

## 3. Collection State Matrix

| Condition | Derived collection state | Production eligible? | Display eligible? |
|---|---|---:|---:|
| overflow flag true | Overflow-Held | NO | no new display |
| valid mutually-exclusive active role | Active | role-dependent | role-dependent |
| valid Production Assignment | Active/production role | YES | YES if display compatibility allows |
| no active role, ordinary capacity | Stored | YES to assign | YES |
| Released | not in current Collection Registry | NO | NO |

## 4. Capacity Component Matrix

| Capacity source | Collection Capacity | Display Capacity | Production Slots | Buffer | Offline Window |
|---|---:|---:|---:|---:|---:|
| base/free | YES | YES as authored | YES as authored | YES | YES |
| earned Vault upgrades | YES | YES | YES | YES | YES |
| commercial capacity entitlement | bounded YES | bounded YES | NO | NO | NO |
| future temporary capacity | only if explicitly authorized | explicit | NO unless GDS changed | NO | NO |

## 5. Capacity Reconciliation Matrix

| Situation | Required result |
|---|---|
| effective capacity increases | no creature identity change; overflow can be resolved explicitly |
| effective capacity decreases below used | deterministic non-destructive overflow reconciliation |
| production-assigned creature selected for overflow | settle first, remove assignment, then Overflow-Held |
| displayed creature selected for overflow | clear display ref, then Overflow-Held |
| Protected Variant selected for overflow | remains owned/locked; no deletion |
| no player priority list | stable automatic order |
| commercial capacity revoked | same reconciliation; no debt/deletion |

## 6. Production Settlement Matrix

| Boundary | Settle first? | Why |
|---|---:|---|
| assignment add/remove | YES | preserve old-rate elapsed value |
| Production Claim | YES | claim current authoritative amount |
| production rate epoch switch | YES/segment | prospective rates |
| production slot reduction | YES | preserve value before invalidation |
| buffer capacity change | YES | preserve earned value |
| clean player leave | YES | establish offline boundary |
| checkpoint | YES where production state checkpointed | prevent replay |
| shutdown | YES | preserve active elapsed value |
| display-only change | NO economic requirement | presentation only |

## 7. Offline Matrix

| Prior state | Eligible catch-up |
|---|---|
| clean leave | min(elapsed, Offline Production Window) |
| active stale lease / crash recovery | min(elapsed, Offline Window + bounded crash allowance) |
| clock regression | 0 + diagnostic |
| giant forward jump | bounded by window/allowance and buffer cap |
| no valid finalized assignments | 0 |
| buffer already saturated | 0 |
| rate epoch crossed | piecewise settlement |

## 8. Production Claim Matrix

| Wallet state | Buffer state | Result |
|---|---|---|
| headroom sufficient | >=1 whole Energy | transfer full whole amount |
| partial headroom | larger claimable buffer | transfer headroom only; remainder stays |
| wallet full | any buffer | no transfer; buffer unchanged |
| buffer < 1000 milli | fractional only | no whole Energy transfer |
| duplicate operation delivery | any | one atomic transfer maximum |

## 9. Progression Purchase Matrix

| Condition | Result |
|---|---|
| quote valid, prereqs met, balance enough | atomic cost + effect P2 |
| quote expired/config changed | no charge; require re-quote |
| insufficient Energy | no charge/effect |
| missing Milestone | no charge/effect |
| already-owned one-time unlock | no duplicate charge |
| duplicate operation | return/reconcile original result |
| price later reduced | completed historical purchase unchanged |
| price later increased | old unconfirmed quote cannot silently charge more |

## 10. Wallet Overflow Matrix

| Source | Wallet full behavior |
|---|---|
| Production Claim | remainder stays Production Buffer |
| one-time world/event reward | apply headroom + persistent Deferred Energy Grant remainder |
| commercial starter Energy | same deferred-grant mechanism |
| negative spend | never below zero |
| deferred reconciliation | deterministic oldest-operation first |

## 11. Production Value Inputs

| Input | Can affect rate? |
|---|---:|
| Species Production Profile | YES |
| explicit bounded Trait effect | YES |
| Species Rarity label alone | NO |
| Mutation presence alone | NO |
| Compound status alone | NO |
| Protected status alone | NO |
| provenance/Legacy alone | NO |
| spender status | NO |
| commercial capacity | NO |

## 12. Load Reconciliation Matrix

| Invalid/inconsistent state | Action |
|---|---|
| duplicate CreatureInstanceId | Protected Load Failure |
| unknown valuable semantic ID without safe tombstone/migration | Protected Load Failure |
| stale display ref | losslessly clear if ownership unaffected |
| invalid Production Slot ref | settle safely if possible; clear/refuse Ready if value uncertain |
| ordinary-use count above capacity | deterministic Overflow reconciliation |
| buffer above reduced cap | preserve as OverCapPreserved; no new accrual |
| negative Energy | invalid/protected handling |
| unknown rate epoch needed for unsettled value | Protected settlement failure |
| deferred grant duplicate op | dedupe/reconcile |

## Verdict

**TA-8 VAULT / ECONOMY / OFFLINE ACCRUAL MATRIX: PASS.**
