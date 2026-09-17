# GDS-7 Scenario Validation

> **Phase:** GDS-7 — Vault/Base, Passive Production, Capacity, and Upgrades  
> **Status:** PASS  
> **Purpose:** Compound validation of vault intake, placement, production, offline accrual, buffering, capacity, upgrades, lifecycle, visitors, and anti-abuse semantics.

## Validation Method

Each scenario is tested against the closed GDS-1 through GDS-6 contracts plus `vault/07_vault_passive_production_capacity_and_upgrades.md`.

A scenario passes only if:

- secured ownership and instance identity remain intact;
- GDS-5 ownership finalization is not moved into the vault;
- variant/Trait identity remains stable;
- production cannot be duplicated across assignments, servers, devices, retries, or ownership transitions;
- offline gains remain bounded and do not require live-server occupancy;
- capacity cannot silently destroy secured creatures;
- upgrades/reassignment apply prospectively rather than repricing past time;
- downstream economy/social/monetization/technical authority is not silently stolen.

## Scenarios

| # | Scenario | Expected Result | Result |
|---:|---|---|---|
| 1 | First secured onboarding creature completes extraction | GDS-5 finalizes ownership first; Vault Intake safely places the same instance | PASS |
| 2 | Normal secured creature enters vault with free capacity | Defaults to safe Stored state unless explicit onboarding rule assigns otherwise | PASS |
| 3 | Duplicate Species enters vault | Remains distinct Creature Instance; no auto-conversion | PASS |
| 4 | Legendary secured creature reaches intake | Same instance arrives with GDS-6 Protected Variant lock intact | PASS |
| 5 | Capacity becomes full after valid capture began | Finalization remains valid; creature becomes Overflow-Held if necessary | PASS |
| 6 | Player is knowingly full before new capture | GDS-5 initiation remains blocked; vault does not use overflow as normal storage | PASS |
| 7 | Overflow-Held creature exists | Ownership persists but creature cannot produce | PASS |
| 8 | Player increases valid capacity | Eligible Overflow-Held creature may return to normal placement without changing identity | PASS |
| 9 | Player voluntarily releases another creature to make room | Explicit GDS-4 release resolves capacity; no automatic release occurs | PASS |
| 10 | Player closes capacity UI | No creature is released/moved destructively from input spillover | PASS |
| 11 | Stored creature exists in collection | Generates no passive output merely for being owned | PASS |
| 12 | Player explicitly assigns Stored creature to Production Slot | Production starts prospectively from accepted assignment boundary | PASS |
| 13 | Same creature is assigned to second Production Slot | Rejected; one instance cannot occupy two Production Slots | PASS |
| 14 | Same account opens vault on another server/device | Second representation does not create second production timeline | PASS |
| 15 | Player displays a production-assigned creature | Display may coexist as presentation; no second economic copy is created | PASS |
| 16 | Visitor sees displayed creature | Visitor gains no ownership/discovery/production rights | PASS |
| 17 | Visitor attempts to claim owner's output | Rejected | PASS |
| 18 | Visitor attempts to rearrange Production Slots | Rejected by baseline permission model | PASS |
| 19 | Visitor attempts Release/unlock/transfer | Rejected | PASS |
| 20 | Visitor disconnects | Owner's persistent vault state unaffected | PASS |
| 21 | Owner resets avatar while production assigned | Assignment timeline and owned state persist | PASS |
| 22 | Owner unexpectedly disconnects | Assignment transitions into eligible bounded offline accrual | PASS |
| 23 | Owner changes server | Same assignment clock continues; no second start | PASS |
| 24 | Owner changes device | Same assignment clock continues | PASS |
| 25 | Vault model fails to load | Ownership/assignment facts remain authoritative and recoverable | PASS |
| 26 | Persistence is unavailable on join | Protected Load Failure; no blank vault/action processing | PASS |
| 27 | Player stays AFK online for one hour | Receives only normal assignment-based elapsed production, no separate AFK bonus | PASS |
| 28 | Player is offline for one hour | Same baseline production semantics apply to eligible elapsed time | PASS |
| 29 | Player alternates online/offline during same hour | Intervals compose once; no stacked rate for overlapping time | PASS |
| 30 | Player is offline beyond finite horizon | Accrual stops at horizon/buffer bound; no unlimited catch-up | PASS |
| 31 | Output Buffer fills before offline horizon | Further accrual stops when buffer fills | PASS |
| 32 | Player returns after buffer was full for days | Claiming space does not retroactively backfill capped days | PASS |
| 33 | Player enlarges buffer after it had been full | New capacity applies prospectively; old capped interval is not recreated | PASS |
| 34 | Player server-hops repeatedly while offline horizon state exists | Horizon cannot be refreshed for same elapsed interval | PASS |
| 35 | Two devices claim same pending output nearly simultaneously | Output transfers once only | PASS |
| 36 | Claim acknowledgement is lost after commit | Retry resolves to already-claimed outcome, not double payout | PASS |
| 37 | Disconnect occurs immediately after successful claim | Spendable result persists and pending amount is not restored | PASS |
| 38 | Pending output exists at normal disconnect | Pending amount persists | PASS |
| 39 | Player claims only one resource type/subset | Remainder remains persistently pending | PASS |
| 40 | One output buffer is full while another authorized buffer has room | No hidden unlimited spillover unless GDS-8 explicitly defines it | PASS |
| 41 | Player replaces Creature A with higher-output Creature B | A interval checkpoints first; B starts prospectively | PASS |
| 42 | Player repeatedly swaps A/B rapidly | No interval can be paid twice or repriced by whichever creature is best later | PASS |
| 43 | Player removes creature from slot | Valid accrued interval checkpoints; future production stops | PASS |
| 44 | Assigned creature is voluntarily released | Production checkpoints once before Release; no future accrual | PASS |
| 45 | Future trade transfers assigned creature | Old owner's interval checkpoints once; no dual-owner production | PASS |
| 46 | Future buyer later assigns traded creature | New production begins under buyer's later explicit assignment | PASS |
| 47 | Player unlocks a Protected Variant for reassignment | Safe reassignment allowed; lock still governs destructive/transfer actions | PASS |
| 48 | Locked creature is assigned to production | Allowed; assignment is non-destructive | PASS |
| 49 | Trait affects production category/efficiency | Allowed only as bounded downstream-configured effect; Trait identity unchanged | PASS |
| 50 | Legendary rarity is treated as automatic 10x output | Rejected; Species Rarity is not universal production multiplier | PASS |
| 51 | Extreme Mutation is treated as automatic output multiplier | Rejected unless specific downstream effect explicitly exists | PASS |
| 52 | Common Standard creature has useful production profile | Valid; rarity does not determine baseline usefulness | PASS |
| 53 | One Trait becomes universally dominant for every output | Violates situational optimization principle; balance must be corrected | PASS |
| 54 | Trait effect is rebalanced | Same creature/Trait identity remains; future production uses new effect after boundary | PASS |
| 55 | Player buys/earns production efficiency upgrade after 8 hours | Past 8 hours use old parameters; upgrade applies afterward | PASS |
| 56 | Player buys/earns extra Production Slot | New slot becomes usable after finalization; no historical output from before existence | PASS |
| 57 | Player buys/earns extra Vault Capacity | Capacity expands prospectively; no creature identity changes | PASS |
| 58 | Player buys/earns larger Output Buffer | Buffer expands prospectively; capped historical time is not backfilled | PASS |
| 59 | Duplicate upgrade request is delivered twice | Upgrade finalizes once | PASS |
| 60 | Upgrade UI is closed with same button near another control | Modal safety prevents accidental second consequential action | PASS |
| 61 | Durable earned upgrade survives server change | Persists | PASS |
| 62 | Durable earned upgrade survives long inactivity | Persists; no inactivity downgrade | PASS |
| 63 | Future temporary capacity entitlement expires | No secured creature deletion; safe restricted resolution required | PASS |
| 64 | Expired temporary capacity leaves player over capacity | New acquisition/assignment may be blocked, but ownership and resolution access remain | PASS |
| 65 | Payment is offered as only way out of over-capacity | Rejected; non-payment resolution path is required | PASS |
| 66 | Player starts with zero usable vault capacity | Invalid baseline; onboarding configuration must prevent it | PASS |
| 67 | Player starts with zero Production Slots | Invalid baseline onboarding if first production assignment is required | PASS |
| 68 | First vault tutorial assigns creature | Real reversible assignment; no fabricated production/upgrade | PASS |
| 69 | Player skips tutorial guidance | Does not grant pending output or upgrades | PASS |
| 70 | First production choice occurs in crowded/live server | Personal vault functionality remains available independent of public competition | PASS |
| 71 | Player stays offline while assigned creature "would" be in world | No live-world spawn/claim reservation is created | PASS |
| 72 | Offline assigned creature's public event ends | Ordinary base output remains based on persisted assignment; event modifier boundaries are prospective only | PASS |
| 73 | Event production boost starts mid-offline interval | Interval splits at effective boundary; earlier time not boosted retroactively | PASS |
| 74 | Event boost ends mid-offline interval | Later time stops receiving boost; previous eligible segment remains valid | PASS |
| 75 | Server clock anomaly would imply negative elapsed time | No negative production debt is created | PASS |
| 76 | Two servers both render same vault simultaneously | Visual duplication does not create duplicate ownership/output | PASS |
| 77 | Visitor crowds/interacts with production model | Cannot block owner claim or change assignment authority | PASS |
| 78 | Display Capacity fills | Additional display placement blocked/reorganized; production ownership unaffected | PASS |
| 79 | Production Slot Capacity fills | Additional production assignment blocked; Stored creatures remain owned | PASS |
| 80 | GDS-8 later defines multiple resource outputs | GDS-7 exact-once/checkpoint/buffer semantics apply per authorized output without becoming a new economy spec | PASS |

## Cross-Cutting Results

### Ownership and identity integrity
All vault states consume GDS-4 secured ownership. Intake, storage, production, display, capacity, and upgrades never recreate or reroll the Creature Instance.

### Production integrity
Each elapsed interval is attributable to one valid assignment/parameter state and cannot be paid twice or retroactively repriced.

### Offline fairness
Offline gains are real but bounded by both finite buffer and finite elapsed horizon, require no live-world simulation, and do not stack with an AFK/online duplicate entitlement.

### Capacity safety
Capacity pressure restricts use/acquisition rather than deleting secured creatures. Overflow remains non-producing and cannot become infinite economic storage.

### Upgrade integrity
Durable upgrades apply once and prospectively; no upgrade can manufacture historical production.

### Social safety
Visitors can inspect/flex but cannot mutate, claim, spend, unlock, release, transfer, or economically control the owner's vault by baseline.

## Verdict

**80 / 80 scenarios: PASS.**

No GDS-7-blocking scenario contradiction remains.
