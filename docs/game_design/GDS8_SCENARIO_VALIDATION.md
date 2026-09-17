# GDS-8 Scenario Validation

> **Phase:** GDS-8 — Economy, Progression, Unlocks, and Pacing  
> **Status:** PASS  
> **Purpose:** Compound validation of Energy, source/sink integrity, passive-production economics, active progression, Vault/capture/access upgrades, transaction exactness, pacing, catch-up, inflation, lifecycle, and downstream authority.

## Validation Method

Each scenario is tested against the closed GDS-1 through GDS-7 contracts plus `economy_progression/08_economy_progression_unlocks_and_pacing.md`.

A scenario passes only if:

- finalized ownership/Variant identity remains intact;
- Energy transactions cannot underflow, duplicate, or silently lose finalized value;
- passive production remains bounded and cannot replace active Progression Milestones;
- rarity/Mutation prestige does not automatically become production power or price;
- progression purchases remain exact-once and understandable;
- catch-up/rebalancing preserves legitimate completed progress;
- downstream systems do not receive authority before their phase.

## Scenarios

| # | Scenario | Expected Result | Result |
|---:|---|---|---|
| 1 | New player starts | One persistent Energy Wallet exists; balance is non-negative | PASS |
| 2 | Player changes server | Finalized Energy persists | PASS |
| 3 | Player resets avatar | Energy persists; no reward/loss from reset | PASS |
| 4 | Player switches device | Same Energy state persists | PASS |
| 5 | Wallet request tries to set negative balance | Invalid; negative finalized Energy prohibited | PASS |
| 6 | UI displays fractional Energy | Baseline player-facing currency remains whole units | PASS |
| 7 | System treats Energy as Robux | Invalid; balances remain separate | PASS |
| 8 | Player attempts to drop Energy for another player | Baseline direct transfer unavailable | PASS |
| 9 | High wallet balance is used to increase mutation odds | Prohibited; economy cannot modify hidden rarity odds | PASS |
| 10 | Low wallet balance is used to grant pity rarity odds | Prohibited unless later rarity authority explicitly defines a non-economic visible mechanic | PASS |
| 11 | Valid Production Claim occurs | Eligible buffer Energy enters wallet exactly once | PASS |
| 12 | Production Claim request retries | One transfer maximum | PASS |
| 13 | Claim response is lost then retried | Reconciles same finalized result; no duplicate | PASS |
| 14 | Player earns active objective Energy | Allowed when owning gameplay phase defines objective/reward | PASS |
| 15 | Player idles connected with no production assignment | No raw presence Energy source | PASS |
| 16 | Onboarding grants starter Energy | Allowed once; replay/reconnect cannot duplicate | PASS |
| 17 | Event later grants Energy | Allowed under GDS-11 with exact-once budgeted reward | PASS |
| 18 | Admin compensation corrects verified loss | Allowed as exceptional traceable remediation | PASS |
| 19 | Player Releases Common creature | Zero baseline Energy reward | PASS |
| 20 | Player Releases Legendary creature | Zero baseline Energy reward; rarity does not create sale value | PASS |
| 21 | Player repeatedly captures Common creatures | Secured capture alone does not mint repeated Energy | PASS |
| 22 | First-time discovery objective references capture | Bounded milestone Energy may be granted once | PASS |
| 23 | Player buys Collection Capacity upgrade | Energy spent once; capacity effect applies once | PASS |
| 24 | Player buys Production Slot upgrade | Energy spent once; slot effect applies once | PASS |
| 25 | Player buys Buffer upgrade | Energy spent once; buffer capability applies once | PASS |
| 26 | Player buys Offline Window upgrade | Energy spent once; window capability applies once | PASS |
| 27 | Player buys Display Capacity | Energy sink allowed; no production capacity implied | PASS |
| 28 | Player buys Capture Capability | Persistent upgrade allowed; GDS-5 authority preserved | PASS |
| 29 | Ordinary capture attempt starts | No universal mandatory per-attempt Energy tax | PASS |
| 30 | Player cannot afford an upgrade | No cost or partial effect | PASS |
| 31 | System proposes monthly Energy maintenance to keep creatures | Prohibited; ownership cannot depend on maintenance payment | PASS |
| 32 | Energy debt/loan proposed as baseline | Prohibited | PASS |
| 33 | Common Species has high authored Production Profile | Valid; rarity does not constrain it automatically | PASS |
| 34 | Legendary Species has medium Production Profile | Valid; Legendary does not require maximum output | PASS |
| 35 | Extreme Mutation assigned to production | No automatic income multiplier | PASS |
| 36 | Compound Variant assigned | No automatic Compound income multiplier | PASS |
| 37 | Event-Limited provenance assigned | No automatic availability/provenance multiplier | PASS |
| 38 | Trait explicitly grants situational production bonus | Allowed when bounded/authored/readable | PASS |
| 39 | One Trait becomes universally best for every Species/context | Violates bounded situational principle; rebalance required | PASS |
| 40 | Trait creates negative passive drain | Invalid baseline; eligible assignment cannot consume Energy merely by existing | PASS |
| 41 | Same assignment accrues online | Baseline elapsed production applies | PASS |
| 42 | Same assignment accrues offline within window | Same baseline production semantics apply | PASS |
| 43 | AFK-connected player receives hidden 2x passive rate | Prohibited | PASS |
| 44 | Active player completes objective while production runs | May earn separate active reward plus normal passive accrual | PASS |
| 45 | Offline absence exceeds configured window | Further offline accrual stops | PASS |
| 46 | Production Buffer fills first | Further accrual pauses regardless of remaining offline window | PASS |
| 47 | Player has enough Energy but no required active Milestone | Major Access Gate remains locked | PASS |
| 48 | Player has Milestone but insufficient Energy | Unlock does not finalize | PASS |
| 49 | Player has Milestone and sufficient Energy | Access purchase may finalize once | PASS |
| 50 | Offline Energy alone reaches access cost | Still cannot fabricate missing active Milestone | PASS |
| 51 | Paid acceleration proposed to fabricate Species Discovery | Not authorized by GDS-8 | PASS |
| 52 | Progression Milestone checked by multiple gates | Non-spendable proof remains present | PASS |
| 53 | Player buys region access | Unlock persists across sessions | PASS |
| 54 | Region access price changes later | Existing unlock remains owned | PASS |
| 55 | Access purchase does not grant discoveries from region | Correct; access is not completion history | PASS |
| 56 | Starting player tries protected first capture | Starting Capture Capability is sufficient; no pre-grind required | PASS |
| 57 | High Capture Capability player contests claimed creature | Upgrade cannot steal existing Engagement Claim | PASS |
| 58 | High Capture Capability player reaches Secure Point | Upgrade cannot bypass exact GDS-5 finalization rules | PASS |
| 59 | Upgrade request double-clicks | One cost + one effect maximum | PASS |
| 60 | Purchase request times out after authoritative commit | Reconnect/retry resolves same cost/effect | PASS |
| 61 | Cost deducted but effect absent in visible response | Reconciliation must restore coherent effect+cost outcome | PASS |
| 62 | Insufficient-funds request races with another purchase | At most affordable authoritative transactions finalize; wallet never negative | PASS |
| 63 | One-time unlock is purchased twice | Second request cannot charge again | PASS |
| 64 | Upgrade reaches max tier | Further purchase blocked/no charge | PASS |
| 65 | Price changes while confirmation modal is open | No silent higher charge; re-confirm or valid quote required | PASS |
| 66 | Price decreases while modal open | Transaction follows explicit quote/reconfirmation policy; no ambiguity | PASS |
| 67 | Pure production upgrade would repay itself in minutes | Balance violates compounding guardrail; retune required | PASS |
| 68 | Production expansion takes multiple normal sessions to repay | Consistent with reference guardrail | PASS |
| 69 | Early player waits 30 minutes for first progression choice | Violates opening pacing target; retune required | PASS |
| 70 | First meaningful choice appears around 4–8 minutes | Meets reference opening target | PASS |
| 71 | 15–90 minute player has several useful goals | Consistent with foundation band | PASS |
| 72 | 1.5–10 hour player has only one mandatory linear purchase | Weakens growth-band choice; design should provide parallel useful goals | PASS |
| 73 | Long-term player completes old progression | New content/presentation/events add uses rather than wiping Energy | PASS |
| 74 | Passive production supplies all recurring Energy and active play none | Violates active/passive relevance rule | PASS |
| 75 | Active rewards make Vault production economically irrelevant | Violates active/passive relevance rule | PASS |
| 76 | Initial tuning lands roughly 50–70% passive income | Valid reference balance | PASS |
| 77 | Player accumulates high balance after completing content | Not itself evidence of harmful inflation; evaluate time-to-goal/sinks | PASS |
| 78 | Season starts | Energy is not wiped | PASS |
| 79 | Capacity inflation is addressed by deleting creatures | Prohibited | PASS |
| 80 | Late content adds meaningful new Energy sinks | Valid inflation-control strategy | PASS |
| 81 | Returning player gets visible old-content cost reduction | Allowed deterministic catch-up | PASS |
| 82 | Returning player automatically receives unearned Variant Discovery | Prohibited catch-up | PASS |
| 83 | Catch-up price depends secretly on Robux spending propensity | Prohibited | PASS |
| 84 | Old upgrade price reduced globally | Future purchases use new price; prior ownership remains; no automatic refund obligation | PASS |
| 85 | Production Profile is nerfed globally | Future accrual changes; creature identity remains stable | PASS |
| 86 | Trait production magnitude is rebalanced | Trait identity remains; future effect changes under tuning authority | PASS |
| 87 | Duplication exploit generated illegitimate Energy | Integrity remediation may correct verified illegitimate value; legitimate progress not broadly wiped by default | PASS |
| 88 | Prestige proposal wipes creatures/upgrades for multiplier | Prohibited baseline; requires explicit change control | PASS |
| 89 | Wallet-safe maximum would be exceeded by Production Claim | Partial safe transfer; transferable remainder stays buffered where possible | PASS |
| 90 | Protected Load Failure occurs | Irreversible Energy spend/claim/progression actions are blocked | PASS |

## Cross-Cutting Results

### Economy integrity
Energy is persistent, non-negative, exact-once, and separate from premium currency and direct player transfer.

### Active/passive integrity
Vault production is economically important but bounded; active Progression Milestones prevent passive waiting from replacing the game.

### Collection/value integrity
Creature ownership, rarity, Mutation, provenance, and Release are not converted into an automatic liquidation/income ladder.

### Progression integrity
Vault, capture-capability, and access progression use durable exact-once outcomes with visible costs/prerequisites and no debt/maintenance ransom.

### Pacing/inflation integrity
Opening/foundation/growth/long-term bands, cost compounding guardrails, catch-up, and no-wipe rules produce a controllable live economy without arbitrary confiscation.

### Downstream compatibility
World objectives, events, trading, monetization, final presentation, platform compliance, analytics infrastructure, and technical transaction mechanisms remain delegated to their owning phases.

## Verdict

**90 / 90 scenarios: PASS.**

No GDS-8-blocking scenario contradiction remains.
