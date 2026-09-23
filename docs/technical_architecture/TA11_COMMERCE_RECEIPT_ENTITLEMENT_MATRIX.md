# TA-11 Commerce / Receipt / Entitlement Matrix

> **Phase:** TA-11  
> **Status:** PASS

## Product Kind

| Product class | Platform baseline | Repeatable | Baseline authorized |
|---|---|---:|---:|
| durable cosmetic/status | Game Pass | NO | YES |
| Commercial Capacity | Game Pass | NO | YES |
| Starter Value Bundle | Game Pass | NO | YES |
| Supporter/Style pass | Game Pass | NO | YES |
| deterministic repeatable consumable | Developer Product | YES | only after explicit GDS authorization |
| subscription | Subscription | recurring | NO |
| randomized paid item | any | varies | NO |
| Robux transfer | transfer API | n/a | NO |

## Authority

| Fact | Authority |
|---|---|
| ProductDefinitionId | TA-5 registry |
| platform ID/type | server-private environment binding |
| pass ownership | MarketplaceService ownership query |
| Developer Product purchase | server receipt callback |
| exact-once receipt identity | PurchaseId |
| grant contents | immutable server GrantDefinition |
| entitlement projection | TA-4 Player Profile |
| custom UI price | runtime MarketplaceService product info |
| prompt modal state | presentation only |

## Game Pass Reconciliation

| Result | Prior state | Outcome |
|---|---|---|
| owns true | inactive | activate P2 |
| owns true | active | idempotent refresh |
| owns false | active | deactivate + safe reconciliation |
| owns false | absent | remain absent |
| API failure | active | VerificationUnknown; preserve |
| API failure | absent | do not grant |
| prompt-finished | any | trigger ownership refresh |

## Receipt Processing

| Condition | Decision |
|---|---|
| known receipt + Ready profile | journal/apply/finalize |
| unknown ProductId | quarantine + NotProcessedYet |
| player absent | NotProcessedYet |
| Protected Load Failure | NotProcessedYet |
| fresh foreign lease | no direct UpdateAsync |
| duplicate FINALIZED PurchaseId | PurchaseGranted; no regrant |
| same PurchaseId observed later/on another server | compare stable receipt-derived identity only; firstSeenAt remains set-on-create journal metadata |
| duplicate PROFILE_APPLIED | finalize journal; no regrant |
| immutable fact mismatch | quarantine |
| DataStore throttle | NotProcessedYet |
| PromptProductPurchaseFinished only | no grant |

## Receipt Journal

| State | Meaning | Next |
|---|---|---|
| RECEIVED | immutable facts accepted | PROFILE_APPLY_PENDING |
| PROFILE_APPLY_PENDING | grant not proven | PROFILE_APPLIED / QUARANTINED |
| PROFILE_APPLIED | grant + profile marker durable | FINALIZED |
| FINALIZED | exact purchase complete | terminal acknowledgement |
| QUARANTINED | invariant contradiction | protected recovery |

## Profile Authority

| Profile state | Commerce write |
|---|---|
| Ready local lease | TA-4 writer queue |
| PersistenceAtRisk | defer protected |
| ProtectedLoadFailure | prohibited |
| fresh foreign lease | no external direct write |
| stale/expired lease | only after legal TA-4 acquisition |
| OwnershipLost | prohibited |

## Commercial Capacity

| Change | Result |
|---|---|
| activate | bounded Collection/Display capacity |
| pending | no temporary capacity |
| removal creates over-cap | deterministic Overflow-Held |
| tries Production Slot/Buffer/rate/Offline Window | reject |

## Pricing

| Situation | Result |
|---|---|
| regional price differs | same grant |
| price experiment differs | same grant; TA-13 governance |
| hard-coded stale price | violation |
| product-info failure | no stale current-price claim |
| CurrencySpent differs | audit only |

## Prohibited

Paid luck/reroll/capture success/claim priority, production acceleration, Event Contribution/timing, Trade Access/safety/cooldown bypass, world progression bypass, randomized paid acquisition, baseline subscriptions and Robux trade tender are prohibited.
