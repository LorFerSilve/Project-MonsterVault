# TA-11 Scenario Validation

> **Phase:** TA-11 — Monetization, MarketplaceService, Receipt Processing, and Entitlements  
> **Status:** PASS  
> **Scenario count:** 240 / 240 PASS

TA-11 validates semantic product identity, platform binding, pass ownership, receipt processing, exact-once Commercial Finalization, retry/reconnect/crash behavior, reversal, pricing, security, platform semantics and cross-system commercial fairness.

## Product identity and catalog

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 1 | active ProductDefinition resolves unique production pass | one semantic product + matching binding | PASS |
| 2 | same platform ID bound to two products | bootstrap fails closed | PASS |
| 3 | display name changes | ProductDefinitionId unchanged | PASS |
| 4 | product moves DEV to PRODUCTION | different environment binding | PASS |
| 5 | DEV references production binding | validation rejects | PASS |
| 6 | material grant changes under sold binding | new binding/version required | PASS |
| 7 | Retired product receives delayed valid outcome | legacy mapping fulfills | PASS |
| 8 | Tombstone is queried | compatibility mapping resolves | PASS |
| 9 | unknown ProductDefinition requested | reject | PASS |
| 10 | client supplies alternate GrantDefinitionId | reject | PASS |
| 11 | client requests hidden grant mapping | no authority disclosure | PASS |
| 12 | platform kind mismatches definition | bootstrap fails | PASS |
| 13 | Hidden product | no normal prompt | PASS |
| 14 | Retired product | no new prompt; rights preserved | PASS |
| 15 | registry order changes | no semantic effect | PASS |

## Offer prompting and context

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 16 | idle player opens shop | eligible offers may display | PASS |
| 17 | during Capture Attempt | block prompt | PASS |
| 18 | during Transport Custody | block | PASS |
| 19 | during final trade review | block | PASS |
| 20 | during Trade Commit | block | PASS |
| 21 | during event personal capture resolution | block | PASS |
| 22 | during Recovery | block | PASS |
| 23 | during Protected Load Failure | block | PASS |
| 24 | external valid purchase | still reconcile | PASS |
| 25 | player closes offer | no gameplay penalty | PASS |
| 26 | player declines repeatedly | no forced modal loop | PASS |
| 27 | client requests forbidden product class | reject | PASS |
| 28 | eligibility changes before prompt | revalidate | PASS |
| 29 | purchase modal open | no provisional entitlement | PASS |
| 30 | prompt callback says success but truth unresolved | Pending/reconcile | PASS |

## Game Pass ownership and reconciliation

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 31 | owns pass before join | successful check activates | PASS |
| 32 | does not own | no entitlement | PASS |
| 33 | query errors for never-owned | do not grant | PASS |
| 34 | query errors for previously active | preserve as VerificationUnknown | PASS |
| 35 | successful false after active | deactivate safely | PASS |
| 36 | positive check repeats | idempotent | PASS |
| 37 | bought through prompt | event triggers refresh | PASS |
| 38 | bought outside experience | join discovers | PASS |
| 39 | prompt says not purchased | no grant | PASS |
| 40 | prompt says purchased but query errors | Pending | PASS |
| 41 | profile save fails after positive | retry same mutation | PASS |
| 42 | reconnect active owner | consistent and reverified | PASS |
| 43 | two refreshes race | TA-4 serialization | PASS |
| 44 | Retired pass remains owned | preserve | PASS |
| 45 | binding missing | protected failure | PASS |

## Starter exact-once

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 46 | first verified Starter ownership | grant once | PASS |
| 47 | ownership check repeats | no second Energy | PASS |
| 48 | reconnect after grant | no duplicate | PASS |
| 49 | two servers attempt Starter grant | lease/op identity dedupes | PASS |
| 50 | profile write response unknown | reconcile same operation | PASS |
| 51 | wallet has headroom | credit exact fixed Energy | PASS |
| 52 | wallet partially full | defer remainder | PASS |
| 53 | wallet fully capped | defer safely | PASS |
| 54 | pass later inactive | no Energy debt | PASS |
| 55 | Starter includes durable capacity | reconcile separately | PASS |
| 56 | Starter includes cosmetic | reconcile separately | PASS |
| 57 | grant tries Region Mastery | reject | PASS |
| 58 | grant tries Event Completion | reject | PASS |
| 59 | grant tries Trade Access | reject | PASS |
| 60 | contents materially edited | new binding required | PASS |

## Developer Product receipt ingress

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 61 | known receipt for Ready player | journal/apply/finalize | PASS |
| 62 | same PurchaseId twice | one identity | PASS |
| 63 | PromptProductPurchaseFinished true | no grant | PASS |
| 64 | prompt event false | no grant | PASS |
| 65 | player absent | NotProcessedYet | PASS |
| 66 | Protected Load Failure | NotProcessedYet | PASS |
| 67 | fresh foreign profile lease | no direct write | PASS |
| 68 | unknown ProductId | quarantine + NotProcessedYet | PASS |
| 69 | wrong environment binding | protected failure | PASS |
| 70 | malformed receipt facts | protected failure | PASS |
| 71 | PurchaseId reused with different ProductId | quarantine | PASS |
| 72 | PurchaseId reused with different PlayerId | quarantine | PASS |
| 73 | regional CurrencySpent differs | same grant | PASS |
| 74 | receipt arrives after Retired | legacy mapping | PASS |
| 75 | receipt arrives after catalog reload | same grant semantics | PASS |

## Receipt journal and profile apply

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 76 | journal RECEIVED created | persist immutable facts | PASS |
| 77 | journal create response unknown | read same PurchaseId | PASS |
| 78 | journal already FINALIZED | acknowledge without regrant | PASS |
| 79 | journal PROFILE_APPLY_PENDING | route to profile authority | PASS |
| 80 | profile already has PurchaseId marker | skip grant | PASS |
| 81 | marker absent | apply grant + marker atomically | PASS |
| 82 | two handlers queue same receipt | one grant | PASS |
| 83 | profile revision changes | revalidate in queue | PASS |
| 84 | grant includes capacity | coherent P2 mutation | PASS |
| 85 | authorized consumable grant | exact configured value once | PASS |
| 86 | grant hash mismatch | quarantine | PASS |
| 87 | profile apply succeeds | advance PROFILE_APPLIED | PASS |
| 88 | profile apply response unknown | re-read marker | PASS |
| 89 | journal finalization succeeds | FINALIZED | PASS |
| 90 | FINALIZED before profile apply | architecture violation | PASS |

## Receipt crash, retry and shutdown

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 91 | crash before journal | redelivery same PurchaseId | PASS |
| 92 | crash after journal create | continue same journal | PASS |
| 93 | crash before profile apply | no grant | PASS |
| 94 | profile UpdateAsync result unknown | reconcile marker | PASS |
| 95 | crash after apply before journal final | marker prevents duplicate | PASS |
| 96 | crash after FINALIZED before callback return | replay acknowledges | PASS |
| 97 | journal throttle | NotProcessedYet | PASS |
| 98 | profile throttle | NotProcessedYet | PASS |
| 99 | journal-final throttle | NotProcessedYet without regrant | PASS |
| 100 | shutdown before receipt work | retryable | PASS |
| 101 | shutdown after profile apply | later finalize | PASS |
| 102 | recovery sees live foreign lease | use owner/defer | PASS |
| 103 | stale lease legally reclaimable | acquire authority first | PASS |
| 104 | retry occurs days later | legacy mapping still resolves | PASS |
| 105 | terminal dedupe deleted too early | prohibited | PASS |

## Capacity, cosmetics and Energy integration

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 106 | capacity entitlement activates | bounded component added | PASS |
| 107 | capacity Purchase Pending | no temporary capacity | PASS |
| 108 | capacity removal creates over-cap | Overflow-Held | PASS |
| 109 | capacity removal selects overflow | deterministic TA-8 order | PASS |
| 110 | capacity removal would Release | prohibited | PASS |
| 111 | paid capacity grants Production Slot | reject | PASS |
| 112 | paid capacity grants Offline Window | reject | PASS |
| 113 | paid capacity grants rate multiplier | reject | PASS |
| 114 | cosmetic activates | presentation only | PASS |
| 115 | cosmetic changes Variant Identity | reject | PASS |
| 116 | cosmetic grants Discovery | reject | PASS |
| 117 | cosmetic removed | presentation only | PASS |
| 118 | Starter Energy exceeds wallet | Deferred Energy | PASS |
| 119 | commercial reversal creates negative Energy | prohibited | PASS |
| 120 | commerce races economy P2 | TA-4 serializes | PASS |

## Reversal, retirement and compatibility

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 121 | active pass becomes verified inactive | safe reconciliation | PASS |
| 122 | temporary query failure after active | no destructive reversal | PASS |
| 123 | Retired owner joins | keep/reconcile | PASS |
| 124 | Retired Developer Product receipt arrives | fulfill old grant | PASS |
| 125 | Tombstone mapping queried | compatibility only | PASS |
| 126 | old platform ID deleted from registry | architecture violation | PASS |
| 127 | capacity reversal overflows collection | ownership preserved | PASS |
| 128 | cosmetic reversal on traded creature | preserve CreatureInstance | PASS |
| 129 | Starter Energy after reversal | no debt | PASS |
| 130 | reversal attempts event-provenance removal | prohibited | PASS |
| 131 | reversal attempts trade-history removal | prohibited | PASS |
| 132 | price changes after purchase | grant unchanged | PASS |
| 133 | richer new SKU created | old SKU semantics unchanged | PASS |
| 134 | operator hides broken product | existing outcomes reconcile | PASS |
| 135 | reversal truth unknown | protected/non-destructive | PASS |

## Fairness and prohibited monetization

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 136 | paid Species luck configured | reject | PASS |
| 137 | paid Mutation luck configured | reject | PASS |
| 138 | paid Trait luck configured | reject | PASS |
| 139 | paid reroll configured | reject | PASS |
| 140 | paid capture success configured | reject | PASS |
| 141 | paid claim priority configured | reject | PASS |
| 142 | paid Event Contribution configured | reject | PASS |
| 143 | paid event time extension configured | reject | PASS |
| 144 | paid Trade Access configured | reject | PASS |
| 145 | paid Trade Cooldown bypass configured | reject | PASS |
| 146 | paid trade-confirmation bypass configured | reject | PASS |
| 147 | paid Production Slot configured | reject | PASS |
| 148 | repeatable Energy pack configured | reject baseline | PASS |
| 149 | random paid creature configured | reject | PASS |
| 150 | paid required world bypass configured | reject | PASS |

## Pricing and product information

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 151 | regional price differs | display runtime price; same grant | PASS |
| 152 | managed price changes after server start | refresh presentation | PASS |
| 153 | custom shop hard-codes old price | violation | PASS |
| 154 | GetProductInfo fails | no stale current-price claim | PASS |
| 155 | platform prompt opens | final price confirmation surface | PASS |
| 156 | receipt CurrencySpent differs | audit only | PASS |
| 157 | lower regional price paid | same grant | PASS |
| 158 | higher current price paid | same grant | PASS |
| 159 | price-test cohort differs | same grant | PASS |
| 160 | price optimization proposed | TA-13 governance | PASS |
| 161 | discount label lacks factual basis | do not display | PASS |
| 162 | client submits claimed price | ignored | PASS |
| 163 | client submits economic region | ignored | PASS |
| 164 | product-info cache expires | refresh presentation only | PASS |
| 165 | price changes after entitlement finalized | entitlement unchanged | PASS |

## Subscriptions, Robux and external capabilities

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 166 | subscription proposed at launch | disabled | PASS |
| 167 | subscription status unexpectedly active | no grant mapping | PASS |
| 168 | subscription prompt requested | reject/no active definition | PASS |
| 169 | future subscription approved only in TA code | insufficient without GDS | PASS |
| 170 | Robux requested as trade tender | reject | PASS |
| 171 | Robux requested as trade fee | reject | PASS |
| 172 | Robux transfer requested as event reward | reject | PASS |
| 173 | paid server-wide spawn boost | reject | PASS |
| 174 | paid server-wide event boost | reject | PASS |
| 175 | external pass purchase | reconcile | PASS |
| 176 | external Developer Product receipt | process | PASS |
| 177 | cross-game Developer Product dependency | not relied upon | PASS |
| 178 | avatar Marketplace purchase as gameplay authority | not baseline | PASS |
| 179 | paid access required for core game | conflicts GDS | PASS |
| 180 | platform adds new commerce API | adapter review required | PASS |

## Security, privacy and abuse

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 181 | client spoofs PurchaseId | ignored | PASS |
| 182 | client spoofs ProductId->grant mapping | ignored | PASS |
| 183 | client spoofs entitlement active | ignored | PASS |
| 184 | client requests larger capacity | ignored | PASS |
| 185 | client requests larger Starter Energy | ignored | PASS |
| 186 | client replays offer request | no grant | PASS |
| 187 | client inspects public product metadata | no hidden authority | PASS |
| 188 | receipt log contains payment credentials | prohibited | PASS |
| 189 | telemetry stores raw economic-location data unnecessarily | prohibited | PASS |
| 190 | commerce log stores full profile | prohibited | PASS |
| 191 | receipt invariant mismatch detected | quarantine | PASS |
| 192 | prompt spam | rate-limit/policy | PASS |
| 193 | purchase refusal changes spawn odds | prohibited | PASS |
| 194 | spend history changes rarity odds | prohibited | PASS |
| 195 | failed purchase triggers rare-loss rescue offer | prohibited | PASS |

## Lifecycle, observability and downstream integration

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 196 | server boots with valid registry | commerce adapter starts | PASS |
| 197 | registry invalid at bootstrap | commerce fails closed | PASS |
| 198 | player joins before profile Ready | no P2 commerce apply | PASS |
| 199 | player becomes Ready | pass reconciliation may run | PASS |
| 200 | player leaves during pass reconciliation | no detached unsafe write | PASS |
| 201 | player leaves during receipt processing | owner finishes bounded or receipt retryable | PASS |
| 202 | shutdown begins | stop new local commerce admission | PASS |
| 203 | metrics show repeated NotProcessedYet | surface reason | PASS |
| 204 | metrics show quarantined receipt | operator alert | PASS |
| 205 | TA-12 presents Pending state | uses TA-11 status | PASS |
| 206 | TA-13 reorders products | cannot enable prohibited product | PASS |
| 207 | TA-13 price experiment runs | grant invariant unchanged | PASS |
| 208 | TA-14 changes retry/budget | semantic ordering unchanged | PASS |
| 209 | TA-15 faults every receipt cut point | required | PASS |
| 210 | TA-17 names services/stores | must preserve invariants | PASS |

## Cross-system integrity

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 211 | paid player captures ordinary creature | same TA-7 rules | PASS |
| 212 | free player captures same context | same authority | PASS |
| 213 | paid player enters event | same eligibility | PASS |
| 214 | paid player joins Party | no value-authority gain | PASS |
| 215 | paid player trades | same atomicity | PASS |
| 216 | supporter status contests rare creature | no claim priority | PASS |
| 217 | capacity owner stores more creatures | no extra Production Slots | PASS |
| 218 | Starter Energy buys normal upgrade | normal prerequisites still apply | PASS |
| 219 | Starter Energy lacks active milestone | cannot fabricate milestone | PASS |
| 220 | event-themed cosmetic owned | no event provenance | PASS |
| 221 | paid capacity resolves Overflow | uses TA-8 rules | PASS |
| 222 | entitlement disappears during trade | revalidate safely without ownership corruption | PASS |
| 223 | purchase finalizes during capture | does not alter active capture odds/result | PASS |
| 224 | receipt retry occurs during event | no event-reward interaction | PASS |
| 225 | commerce outage occurs | core free gameplay remains functional | PASS |

## Platform/API semantics

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 226 | ProcessReceipt delivers receipt once | normal journal flow | PASS |
| 227 | ProcessReceipt redelivers same PurchaseId | dedupe | PASS |
| 228 | PromptProductPurchaseFinished precedes receipt | still no grant | PASS |
| 229 | pass ownership query returns positive | P2 reconcile | PASS |
| 230 | pass prompt completes outside expected UI | refresh ownership | PASS |
| 231 | runtime product info supplies current price | presentation may use it | PASS |
| 232 | regional pricing changes price only | grant invariant | PASS |
| 233 | price optimization cohort changes price | TA-13 governed | PASS |
| 234 | Developer Product bought from external Store surface | receipt path owns grant | PASS |
| 235 | cross-game sale path unavailable | no dependency | PASS |
| 236 | BindReceiptHandler API exists | no second competing grant path | PASS |
| 237 | subscription API exists | disabled by GDS | PASS |
| 238 | Robux transfer API exists | unused | PASS |
| 239 | platform API starts failing | commerce degrades protected | PASS |
| 240 | future API behavior changes materially | new snapshot/revalidation required | PASS |

## Verdict

**240 / 240 scenarios: PASS.**

No TA-11 product-identity, platform-binding, entitlement, receipt, retry, pricing, reversal, persistence, security, fairness or prohibited-commerce contradiction remains.
