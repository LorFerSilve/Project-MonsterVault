# TA-8 — Vault, Economy, Progression, Inventory, and Offline Accrual

> **Status:** Architecture Complete  
> **Owning TA phase:** TA-8 — Vault, Economy, Progression, Inventory, and Offline Accrual  
> **Authority:** Persistent Collection/Vault schema, Collection Capacity, Overflow-Held reconciliation, Display/Production assignments, Energy wallet representation and transactions, Production Buffer, elapsed-time production, offline accrual, production claims, Vault/Capture/Access progression purchases, price/config quotes, deferred Energy overflow handling, commercial capacity integration, economy auditability, clock/numeric safety and exact-once semantics  
> **Depends on:** TA-0 through TA-7 Architecture Complete; GDS-4, GDS-7, GDS-8, GDS-13, GDS-17

## 1. Purpose

TA-8 defines how MonsterVault represents and mutates the player's persistent collection-management and progression economy without turning passive production into a continuously simulated server process.

The contract is:

> **The Player Profile is the atomic authority for secured collection placement, Vault upgrades, production assignments, bounded Production Buffer, Energy, progression purchases and access/capability unlocks. Energy and production arithmetic use exact bounded integers. Production settles over authoritative elapsed time at explicit state boundaries rather than per frame. Offline production is bounded by the last finalized assignment state, Offline Production Window, Production Buffer capacity and authoritative clock validation. Every value-moving claim or purchase is an idempotent P2 transaction; capacity changes never delete creatures; and config/price changes apply prospectively without silently changing an already confirmed transaction.**

No gameplay/economy Luau modules are implemented in TA-8. Implementation remains blocked until TA-17.

## 2. Domain Ownership

TA-8 owns:

- Collection Registry storage shape consumed by Vault/economy;
- logical collection placement state;
- Collection Capacity calculation;
- Capacity Reconciliation;
- Overflow-Held resolution;
- Display Slot references;
- Production Slot references;
- production assignment persistence;
- Production Profile evaluation boundary;
- Production Buffer representation;
- active/offline elapsed-time settlement;
- Energy numeric representation;
- Energy grant/spend/claim transaction primitive;
- deferred Energy overflow handling;
- Vault Upgrade purchase semantics;
- Capture Capability progression purchase semantics;
- Access Unlock purchase semantics;
- deterministic catch-up pricing inputs;
- reason-coded economy audit trail.

TA-8 does not own:

- Creature identity/Variant generation — TA-5/7;
- capture state — TA-7;
- world region topology — TA-9;
- event reward allocation — TA-10;
- commercial receipt verification — TA-11;
- UI — TA-12;
- live rollout infrastructure — TA-13;
- final performance/request budgets — TA-14.

## 3. Player Profile Domain Shape

Conceptually, TA-8 extends the TA-4 Player Profile aggregate with:

```text
profile
├── collection
│   ├── creaturesById[CreatureInstanceId]
│   ├── discoveries
│   └── capacityPriority
├── vault
│   ├── earnedUpgradeLevels
│   ├── productionAssignments[ProductionSlotId] -> CreatureInstanceId
│   ├── displayAssignments[DisplaySlotId] -> CreatureInstanceId
│   ├── productionBufferMilli
│   ├── productionCursorUnixSeconds
│   ├── productionRateEpochId
│   ├── lastPresenceBoundary
│   └── reconciliation metadata
├── economy
│   ├── energyUnits
│   ├── deferredEnergyGrants
│   ├── progressionPurchases/unlocks
│   ├── captureCapabilityLevel
│   └── bounded recent audit records
└── TA-4 operation/idempotency state
```

Exact field names and serialization are TA-17.

## 4. Single Source of Truth Rules

### PROFILE-08-01

Creature ownership exists only in `collection.creaturesById`.

### PROFILE-08-02

Production assignments exist canonically only in the Vault assignment relation.

A creature's "Active/Production" collection state is derived from the canonical assignment/active-role relation rather than separately storing contradictory truth.

### PROFILE-08-03

Display assignment is a presentation relation and does not become collection ownership or production authority.

### PROFILE-08-04

Energy exists only in the authoritative profile wallet, never on a Character, GUI, Tool or replicated client object.

## 5. Collection State Representation

The persistent collection-facing state is derived as:

1. `Overflow-Held` when the creature is marked overflow-restricted;
2. `Active` when an authorized mutually exclusive active-role relation exists;
3. otherwise `Stored`.

### COLL-01

A creature cannot simultaneously be Overflow-Held and production-assigned.

### COLL-02

A creature may be displayed while Stored or while another non-conflicting role allows it, because Display is presentation rather than ownership.

### COLL-03

One CreatureInstanceId appears at most once in the owning profile's collection map.

## 6. Creature Record

TA-8 consumes the TA-7 finalization payload.

A secured record contains at minimum semantic references for:

- CreatureInstanceId;
- SpeciesId;
- immutable Variant Identity;
- provenance;
- Creature Lock;
- acquisition/finalization ordering metadata;
- overflow restriction flag;
- later trade/history extensions.

TA-8 never stores display names/assets as semantic identity.

## 7. Numeric Representation

Luau uses IEEE-754 double precision numbers with exact integer representation up to `2^53`.

TA-8 therefore uses integers for persistent economy arithmetic.

### NUM-01 — Energy is whole integer units

```text
0 <= energyUnits <= 1_000_000_000_000
```

The TA-8 hard wallet ceiling is **1 trillion Energy units**.

This is an implementation safety ceiling, not a normal balance target.

### NUM-02 — Production uses fixed-point milli-Energy

```text
PRODUCTION_SCALE = 1_000
productionBufferMilli = Energy × 1_000
```

The player-facing wallet remains whole Energy.

### NUM-03 — Fixed-point ceiling

```text
0 <= productionBufferMilli <= 1_000_000_000_000_000
```

This remains below `2^53`.

### NUM-04 — Intermediate arithmetic must remain exact

Content/config validation rejects production rates/windows whose worst-case integer multiplication could exceed safe exact-integer range.

### NUM-05 — No NaN/infinity/fractional wallet state

Persistent economy validation rejects them.

## 8. Why Fixed-Point Production

Production rates may need sub-Energy precision.

Using fixed-point integers avoids:

- cumulative floating-point drift;
- different rounding across repeated settlement boundaries;
- one session earning more merely because it settled more often;
- fractional Energy appearing in the player wallet.

A Production Claim transfers only complete whole Energy units.

Any fractional milli-Energy remainder stays in the Production Buffer.

## 9. Clock Model

TA-8 uses two clock concerns.

### CLOCK-01 — Persisted wall-clock boundaries

Cross-session timestamps use server-observed Unix seconds compatible with Roblox `DateTime.now().UnixTimestamp`.

They are never provided by the client.

### CLOCK-02 — Monotonic in-session elapsed time

Within a live server, elapsed intervals use a monotonic server clock abstraction, with `Workspace:GetServerTimeNow()` as the Roblox reference primitive.

### CLOCK-03 — Client device time is never authoritative

### CLOCK-04 — Clock regression clamps to zero

If a persisted/current wall-clock comparison yields negative elapsed time, TA-8 accrues zero for that interval, records diagnostics and advances safely only after a valid boundary.

### CLOCK-05 — Large forward jumps are bounded

Offline Production Window, buffer cap and crash-recovery allowance bound value even if wall-clock anomalies occur.

## 10. Production Settlement Principle

Passive Production is **settled**, not simulated per frame.

A settlement computes production from the last finalized production cursor to a server-authoritative boundary.

Settlement is required before any mutation that changes:

- assignment membership;
- production rate inputs;
- Production Slot availability;
- Production Buffer capacity;
- Offline Production Window semantics;
- a creature becoming Overflow-Held;
- Production Claim;
- clean leave/shutdown checkpoint where value must be preserved.

## 11. Settlement Formula

For one interval:

```text
eligibleSeconds = bounded authoritative elapsed seconds
rateMilliPerSecond = sum(valid assignment production rates)
rawMilli = exactIntegerMultiply(rateMilliPerSecond, eligibleSeconds)
creditMilli = min(rawMilli, remainingBufferCapacityMilli)
newBufferMilli = oldBufferMilli + creditMilli
newCursor = settlement boundary
```

When a rate/config epoch changes inside an interval, settlement is segmented by epoch.

### SETTLE-01

The same elapsed second cannot be credited twice.

### SETTLE-02

Buffer saturation stops further accrual.

### SETTLE-03

Settlement does not itself move value into Energy.

## 12. Production Rate Resolution

For each valid Production Assignment:

1. resolve the exact owned creature;
2. verify not Overflow-Held;
3. verify slot is unlocked/valid;
4. verify no mutually exclusive active role;
5. resolve Species Production Profile;
6. apply only explicitly authored bounded Trait effects;
7. exclude automatic Rarity/Mutation/Compound/Provenance multipliers;
8. return an integer milli-Energy-per-second contribution.

### RATE-01

Protected/Legendary status alone does not alter rate.

### RATE-02

Commercial status cannot alter production rate under GDS-13 baseline.

## 13. Rate Epochs and Prospective Balance

Production-rate configuration may change prospectively.

TA-8 therefore requires a versioned **Production Rate Epoch**:

```text
{
  epochId,
  effectiveUnixSeconds,
  content/config snapshot reference,
  validated production definitions
}
```

### EPOCH-01

A rate update never rewrites already settled history.

### EPOCH-02

Offline settlement crossing an epoch boundary is segmented so old seconds use the old rate and future seconds use the new rate.

### EPOCH-03

TA-13 must retain enough rate-epoch history to cover at least the maximum Offline Production Window plus crash-recovery allowance.

### EPOCH-04

If required historical rate data is unavailable, TA-8 fails value-sensitive settlement protected rather than inventing a rate.

## 14. Online Accrual

During Active Presence:

- production may accrue continuously in concept;
- no per-frame persistence is required;
- the in-memory session advances settlement at meaningful boundaries/checkpoints;
- client HUD values may interpolate/predict for presentation only;
- server settlement remains authoritative.

### ONLINE-01

AFK connected time gives no hidden multiplier.

### ONLINE-02

A reconnect cannot replay an already settled interval.

## 15. Clean Leave Offline Boundary

On a clean player departure:

1. stop new Vault/economy commands;
2. settle online production to server leave time;
3. persist the resulting Production Buffer;
4. persist production cursor = leave time;
5. persist `presenceBoundary = CleanOffline`;
6. TA-4 final save/unlock commits coherently.

The next load computes offline production from that clean boundary.

## 16. Offline Accrual

On profile load after a clean leave:

```text
rawOfflineSeconds = max(0, nowUnix - productionCursorUnixSeconds)
eligibleOfflineSeconds = min(rawOfflineSeconds, offlineWindowSeconds)
```

Then settlement also stops when the Production Buffer reaches capacity.

### OFFLINE-01

The offline window is one continuous absence interval.

### OFFLINE-02

Server hopping/rejoining does not reset already consumed offline seconds.

### OFFLINE-03

Only finalized assignments present at the persisted boundary produce offline.

### OFFLINE-04

Offline accrual creates no world/event participation.

## 17. Unclean Session / Crash Recovery Accrual

A server crash cannot reliably persist the exact moment Active Presence ended.

TA-8 therefore uses bounded value-preserving recovery.

At each successful TA-4 checkpoint, TA-8 persists:

- current settled Production Buffer;
- production cursor;
- assignment state;
- marker that the session was active at checkpoint time.

If a later server reclaims a stale lease and sees an **unclean active marker**:

```text
eligibleCatchupSeconds =
  min(
    max(0, nowUnix - productionCursorUnixSeconds),
    offlineWindowSeconds + crashRecoveryAllowanceSeconds
  )
```

The crash recovery allowance must be at least the maximum supported uncheckpointed active-production interval locked by TA-14/TA-17.

### CRASH-PROD-01

The allowance is a bounded integrity concession for unknown crash timing, not a normal bonus.

### CRASH-PROD-02

It cannot exceed validated numeric/value caps.

### CRASH-PROD-03

Telemetry distinguishes clean-offline accrual from crash-recovery accrual.

## 18. Assignment Changes Are P2

Because a finalized Production Assignment determines future persistent value and offline accrual, assignment/unassignment is durable-before-final-ack.

An assignment change transaction:

1. settle production under the old assignment state to the authoritative change boundary;
2. validate target slot/creature/role/capacity;
3. mutate assignment relation;
4. set new production cursor/rate epoch boundary;
5. persist buffer + assignment atomically in the Player Profile;
6. acknowledge after P2 success.

### ASSIGN-01

A disconnect immediately after a successful UI assignment cannot revert to an old assignment while still claiming offline production from the new one.

## 19. Production Slot Rules

### PSLOT-01

Each unlocked Production Slot references zero or one CreatureInstanceId.

### PSLOT-02

One CreatureInstanceId may appear in at most one Production Slot.

### PSLOT-03

Overflow-Held is ineligible.

### PSLOT-04

Creature Lock does not block production assignment.

### PSLOT-05

If effective Production Slot count decreases, production is settled first, invalidated excess assignments end deterministically, and no accrued buffer is erased.

## 20. Display Assignment Rules

Display references are persistent presentation choices but do not create economic output.

### DISPLAY-01

Each Display Slot references zero or one eligible secured creature.

### DISPLAY-02

One creature cannot occupy multiple Display Slots.

### DISPLAY-03

Overflow-Held cannot be newly displayed.

### DISPLAY-04

Display state does not count as a Production Assignment and cannot mint Energy.

### DISPLAY-05

Display changes are P1 by default because loss of the latest display choice after catastrophic failure does not destroy value.

A change requiring commercial entitlement reconciliation may be committed with its owning P2 commercial transaction.

## 21. Collection Capacity

Effective Collection Capacity is a deterministic sum of authorized components:

```text
effectiveCollectionCapacity =
    baseCapacity
  + earnedVaultCapacity
  + activeCommercialCapacityEntitlement
  + explicitly authorized temporary capacity
```

Each component is separately identifiable.

### CAP-08-01

Production Slot count and Display Slot count are independent of Collection Capacity.

### CAP-08-02

GDS-13 commercial capacity never increases Production Slots/Buffer/Offline Window.

## 22. Ordinary Capacity Use

An owned creature consumes one ordinary Collection Capacity unit if it is not Overflow-Held.

The exact active/storage/display representation does not consume an extra copy of capacity.

### CAP-08-03

One creature displayed and production-assigned still consumes one collection unit, not three.

## 23. Capacity Reconciliation

Whenever effective Collection Capacity decreases below ordinary-use count:

1. settle production before assignment invalidation;
2. compute target ordinary capacity;
3. validate any player-authored capacity priority list;
4. choose ordinary-use survivors deterministically;
5. clear Display/Production/active-role references for creatures that must overflow;
6. move excess exact Creature Instances to Overflow-Held;
7. preserve ownership, Variant Identity, Creature Lock and provenance;
8. persist the reconciliation coherently.

### CAP-REC-01 — Deterministic selection

Default order for retaining ordinary use:

1. valid player-pinned capacity priority, in explicit order;
2. remaining currently active-role creatures in stable role order;
3. remaining creatures by original secured-acquisition sequence;
4. CreatureInstanceId lexical order as final tie-break.

No rarity, Mutation frequency, monetization spend or subjective "value" enters automatic ordering.

### CAP-REC-02

The exact selection is auditable/presentable.

### CAP-REC-03

Capacity reconciliation never invokes Release.

## 24. Resolve Overflow

When free ordinary capacity exists, the owner may select one exact Overflow-Held Creature.

The P2 operation:

1. settles any production state needed for consistency;
2. validates free capacity;
3. validates exact ownership and current Overflow-Held state;
4. moves that same instance to Stored;
5. preserves all identity/protection/provenance;
6. checkpoints before final acknowledgement.

### OVERFLOW-01

Resolve Overflow never automatically assigns production/display.

## 25. Energy Wallet

Energy is:

- persistent;
- whole-unit;
- non-negative;
- non-transferable player-to-player under GDS-12;
- not premium currency;
- bounded by TA-8 numeric ceiling.

### ENERGY-01

Only server-domain operations mutate Energy.

### ENERGY-02

Client-projected wallet values are read-only presentation.

### ENERGY-03

Energy cannot underflow or exceed max.

## 26. Energy Transaction Primitive

All Energy mutation goes through one profile-domain primitive conceptually:

```text
applyEnergyOperation({
  operationId,
  reasonCode,
  deltaUnits,
  sourceOrSinkId,
  quote/config context,
  attachedEffect?
})
```

Validation includes:

- TA-4 lease/write authority;
- operation not already applied;
- safe integer delta;
- sufficient funds for negative delta;
- wallet max for positive delta;
- owning-system eligibility;
- current expected progression state.

### ENERGY-TX-01

No domain directly performs `profile.energy += x`.

### ENERGY-TX-02

Every P2 wallet mutation has a reason code and stable operation identity.

## 27. Energy Source Classification

Authorized source categories include:

- Production Claim;
- approved active progression reward;
- world milestone/objective reward;
- approved Event reward;
- bounded one-time Starter Value commercial grant under TA-11.

Ordinary repeated capture and Release mint no baseline Energy.

## 28. Production Claim

Before claim:

1. settle production to authoritative claim boundary;
2. compute complete whole Energy in buffer;
3. compute wallet headroom.

```text
wholeAvailable = floor(productionBufferMilli / 1000)
walletHeadroom = MAX_ENERGY_UNITS - energyUnits
transferUnits = min(wholeAvailable, walletHeadroom)
```

If `transferUnits > 0`, one P2 operation atomically:

- adds transferUnits to Energy;
- subtracts `transferUnits * 1000` from Production Buffer;
- records operation/audit result.

Fractional milli-Energy remains.

### CLAIM-08-01

Wallet full with no headroom leaves buffer unchanged.

### CLAIM-08-02

Partial claim due wallet ceiling leaves untransferred value in buffer.

### CLAIM-08-03

Lost/repeated network responses cannot duplicate the same buffer value because buffer decrement and Energy increment are atomic in one profile operation.

## 29. Production Buffer

Production Buffer capacity is persistent progression-derived.

### BUFFER-01

`productionBufferMilli <= effectiveBufferCapacityMilli` under normal state.

### BUFFER-02

If buffer capacity is reduced below existing buffered value, existing accrued value is **not deleted**.

The buffer enters `OverCapPreserved` reconciliation state:

- no further production accrues;
- existing value remains claimable;
- claims reduce it toward current cap;
- new accrual resumes only when at/below effective cap.

This avoids retrospective loss.

### BUFFER-03

Paid systems cannot increase buffer capacity at baseline.

## 30. Deferred Energy Grants

GDS-8 requires one-time rewards not to disappear when the wallet ceiling prevents full transfer.

TA-8 therefore defines a bounded persistent **Deferred Energy Grant** record:

```text
{
  operationId,
  reasonCode,
  remainingUnits,
  createdUnixSeconds,
  sourceReference
}
```

### DEFER-01

Production does not use this queue because Production Buffer already preserves remainder.

### DEFER-02

One-time/event/commercial grants may place the untransferred remainder here atomically with the applied portion.

### DEFER-03

Deferred grant value is not spendable until transferred into wallet.

### DEFER-04

When wallet headroom appears, reconciliation applies deferred grants deterministically oldest-operation first, preserving each original operation identity.

### DEFER-05

Queue size/value are bounded; overflow of the technical queue fails the new grant protected instead of dropping existing value.

Exact bound is TA-14/TA-17.

## 31. Progression Purchase Transaction

Vault Upgrades, Capture Capability upgrades and Energy-priced Access Unlocks use a common P2 transaction shape:

1. server creates/validates a Progression Quote;
2. player explicitly confirms;
3. validate quote is current/unexpired;
4. validate current level/not already owned;
5. validate required active Progression Milestones;
6. validate Energy balance;
7. generate stable server operation ID;
8. atomically deduct exact Energy and apply exact effect in one profile mutation;
9. record reason/audit/idempotency;
10. acknowledge only after durable success.

### PURCHASE-01

No partial spend/effect.

### PURCHASE-02

Already-owned one-time effect cannot be charged again.

## 32. Progression Quote

A server-issued quote contains conceptually:

- quoteId;
- target DefinitionId;
- expected current level/state;
- Energy price;
- required milestones snapshot/reference;
- configSnapshotId / price epoch;
- expiry time.

### QUOTE-01

Client cannot author price.

### QUOTE-02

If price/config changes before commit, the quote is rejected for re-confirmation rather than silently charging a different price.

### QUOTE-03

A previously completed purchase remains completed after future price changes.

## 33. Vault Upgrades

Earned Vault Upgrade levels are persistent IDs/levels.

Authorized categories:

- Collection Capacity;
- Production Slots;
- Production Buffer capacity;
- Offline Production Window;
- Display Capacity;
- approved utility/presentation.

### UPGRADE-01

Upgrade levels must be monotonic where content defines a level ladder.

### UPGRADE-02

One operation can increase one intended level/effect only once.

### UPGRADE-03

No upgrade can delete/replace owned creatures.

### UPGRADE-04

Non-premium progression remains a functional path.

## 34. Capture Capability

Capture Capability is persistent progression state.

### CAPABILITY-01

Upgrade purchase is atomic Energy + capability effect.

### CAPABILITY-02

Capability never changes existing creature identity/ownership.

### CAPABILITY-03

Higher capability cannot bypass TA-7 claims, capacity, extraction or Variant finalization.

## 35. Access Unlocks

Access Unlocks are persistent exact-once facts keyed by stable Access Definition IDs.

### ACCESS-01

A purchase may require Energy plus active Milestones.

### ACCESS-02

Energy alone cannot fabricate missing Milestones.

### ACCESS-03

Unlocked access remains owned through future price changes.

### ACCESS-04

Purchase never backfills discovery/world completion history.

## 36. Catch-Up Pricing

Catch-up eligibility is evaluated from explicit persistent/non-secret inputs authorized by GDS-8/GDS-16.

The resulting quote records the exact adjusted price.

### CATCHUP-01

Spending propensity/purchase reluctance is not an input.

### CATCHUP-02

Historical buyers do not receive automatic price-difference refunds unless an explicit compensation operation is created.

## 37. Release Economy Boundary

Baseline voluntary Creature Release:

- is a P2 ownership mutation under GDS-4;
- grants no automatic Energy;
- requires exact-instance confirmation and Creature Lock validation;
- must first settle/remove any Production Assignment or other incompatible role;
- cannot delete buffered production already accrued to the player's Vault.

Any future Release reward requires explicit GDS-8 change control and a reason-coded atomic operation.

## 38. Commercial Capacity Integration

TA-11 owns receipt/entitlement verification.

TA-8 consumes a durable **Commercial Capacity Entitlement** projection.

### COMM-CAP-01

Commercial Collection/Display Capacity is a separate additive component.

### COMM-CAP-02

It cannot affect:

- Production Slots;
- Production Buffer;
- Offline Window;
- production rates;
- Capture Capability;
- claim priority.

### COMM-CAP-03

Entitlement grant/removal invokes capacity calculation/reconciliation atomically with the commercial operation where required.

## 39. Commercial Capacity Removal

If a legitimate TA-11 entitlement reconciliation removes capacity:

1. recompute effective capacity;
2. settle production;
3. run non-destructive Capacity Reconciliation;
4. move excess creatures to Overflow-Held;
5. clear invalid production/display relations;
6. preserve all ownership/value;
7. never create Energy debt.

## 40. Starter Energy Commercial Grant

GDS-13 allows one bounded Starter Value Bundle Energy grant.

TA-8 requirement:

- grant comes through TA-11 verified Commercial Finalization;
- uses normal Energy transaction/deferred-overflow rules;
- exact amount comes from validated product definition;
- one-time product identity prevents repeated grant;
- it cannot grant active Progression Milestones.

## 41. Load-Time Reconciliation Order

After TA-4 schema migration/structural validation, TA-8 load proceeds:

1. validate numeric ranges;
2. validate CreatureInstanceId uniqueness/references;
3. validate upgrade IDs/levels;
4. calculate effective capacities;
5. validate/reconcile collection capacity non-destructively;
6. validate display/production slot references;
7. clear impossible derived references only through lossless reconciliation;
8. resolve required historical Production Rate Epochs;
9. settle clean-offline or crash-recovery production;
10. reconcile buffer over-cap state;
11. reconcile deferred Energy into wallet where headroom exists;
12. expose profile Ready only after invariant validation.

### LOAD-08-01

Unknown valuable Creature references do not get silently deleted.

### LOAD-08-02

If safe reconciliation cannot be proven, enter TA-4 Protected Load Failure.

## 42. Production Checkpoint State

To make elapsed-time replay impossible, persisted production state records enough to identify the consumed timeline:

- Production Buffer milli-units;
- production cursor Unix seconds;
- finalized assignment relation;
- Production Rate Epoch context;
- presence boundary type;
- applicable upgrade levels.

### CURSOR-01

A successful settlement advances the cursor exactly once with the same profile mutation that stores the accrued buffer/assignment change.

## 43. Durability Classification

| State / operation | Durability |
|---|---|
| Energy wallet | P2 for explicit grant/spend; included in checkpoints |
| Secured Creature / Overflow state | P2 |
| Production Assignment change | P2 |
| Production Buffer derived accrual | recomputable/P1 between checkpoints; P2 when part of claim/assignment/purchase boundary |
| Production Claim | P2 |
| Vault Upgrade | P2 |
| Capture Capability purchase | P2 |
| Access Unlock | P2 |
| Resolve Overflow | P2 |
| Display assignment | P1 baseline |
| offline recap presentation | P0 |
| Progression Quote | P0/session-local |

## 44. Transaction Ordering

All TA-8 P2 operations use the TA-4 one-writer queue.

### TX-08-01

Two purchases on the same profile cannot both spend the same Energy.

### TX-08-02

Production Claim and purchase cannot race independently.

### TX-08-03

Capture finalization and capacity upgrade are serialized through the same profile mutation pipeline.

### TX-08-04

A transaction revalidates current profile revision/state when it executes, not only when the client clicked.

## 45. Economy Audit Records

TA-8 defines compact bounded recent audit records for value mutations:

- operationId;
- timestamp;
- reasonCode;
- amount delta;
- resulting wallet;
- target progression/effect ID where relevant;
- config/quote reference;
- result class.

These records support diagnostics and exploit remediation but are not an unbounded accounting database.

TA-13/14 define retention/telemetry limits.

## 46. Reason Codes

Reason categories are stable semantic codes such as:

- `production-claim`;
- `world-milestone-reward`;
- `event-reward`;
- `starter-commercial-grant`;
- `vault-upgrade-purchase`;
- `capture-capability-purchase`;
- `access-unlock-purchase`;
- `operator-remediation`.

Display/localization text is separate.

## 47. Failure Semantics

### DataStore failure during Production Claim

No final client success until P2 commit succeeds. Buffer/wallet remain/reconcile from authoritative operation state.

### Purchase persistence failure

No durable cost without durable effect.

### Assignment persistence failure

Old finalized assignment remains authority.

### Clock anomaly

Bound elapsed; never negative/unlimited production.

### Missing config epoch

Protected settlement failure rather than invented value.

### Capacity reconciliation failure

Ownership remains protected; irreversible capture/purchase actions can be blocked until consistency is restored.

## 48. Server Shutdown

Orderly shutdown:

1. stop new ordinary economy/Vault commands;
2. settle production to shutdown boundary;
3. include production state in TA-4 final profile save;
4. finalize only already-admitted P2 operations according to their owners;
5. persist clean offline boundary when safe;
6. if clean final save fails, later stale-lease recovery uses crash-recovery accrual semantics.

### SHUT-08-01

Shutdown creates no bonus production/reward.

## 49. Server Hop

A server transition:

- saves/settles old session;
- new server loads one profile under TA-4 lease;
- does not reset Production Buffer;
- does not reset Offline Production Window;
- does not duplicate deferred grants;
- does not create a second Energy wallet.

## 50. Security Boundaries

Assume a hostile client can send:

- arbitrary Energy values;
- arbitrary rates;
- arbitrary "time offline";
- arbitrary upgrade levels;
- forged assignment targets;
- duplicate claim/purchase requests;
- stale quote IDs;
- forged capacity entitlement state.

TA-8 trusts none of them.

Server derives all value from:

- current owned profile;
- TA-5 content definitions;
- server clock;
- verified TA-11 entitlements;
- stable operation IDs;
- server-side prerequisite state.

## 51. Exploit Cases

### EXP-08-01 — Clock spoofing

Client device time is ignored.

### EXP-08-02 — Server-hop production replay

Persisted cursor prevents replay.

### EXP-08-03 — Assignment spam

Per-profile writer queue + P2 assignments serialize and settle once.

### EXP-08-04 — Wallet overflow

Safe headroom/deferred-grant behavior prevents wrap/loss.

### EXP-08-05 — Double-spend

Atomic cost/effect transaction.

### EXP-08-06 — Overflow farming

Unresolved Overflow-Held blocks ordinary new TA-7 acquisition.

### EXP-08-07 — Paid production advantage

Prohibited by product/economy schema: paid capacity component never feeds production capability.

## 52. Performance Principles

### PERF-08-01

Do not run one per-creature Heartbeat production loop.

### PERF-08-02

Production rate can be aggregated per profile from current assignments and recomputed only when assignment/rate context changes.

### PERF-08-03

Offline accrual complexity is proportional to assignment count and crossed config epochs, both bounded.

### PERF-08-04

DataStore is not written every production tick.

### PERF-08-05

Profile collection map supports exact-instance lookup without repeated full-list scans.

TA-14 locks concrete maximum counts.

## 53. Observability

TA-13 telemetry should expose privacy-safe metrics for:

- Energy source/sink amounts by reason;
- rejected insufficient-funds operations;
- duplicate/idempotent operations;
- Production Buffer fill/saturation;
- production claim size/cadence;
- online versus offline accrual;
- crash-recovery accrual usage;
- clock anomaly clamps;
- config-epoch settlement failures;
- assignment changes;
- capacity reconciliation;
- Overflow-Held counts/duration;
- deferred Energy queue/value;
- progression quote expiration/requote;
- upgrade/access/capability purchase completion;
- wallet ceiling proximity.

## 54. Testability

TA-15 must support deterministic tests for:

- exact integer/fixed-point math;
- safe integer boundary;
- buffer saturation;
- partial wallet-headroom claim;
- fractional milli remainder;
- clean offline interval;
- offline-window cap;
- server-hop no reset;
- clock regression;
- huge forward clock jump;
- unclean-session crash allowance;
- rate epoch crossing;
- assignment change settlement boundary;
- duplicate assignment rejection;
- capacity reduction reconciliation;
- commercial capacity loss;
- Overflow-Held resolve;
- concurrent purchase/claim serialization;
- duplicate P2 operation ID;
- price change after quote;
- missing milestone purchase rejection;
- deferred Energy grant/replay;
- load-time invalid references/protected failure.

## 55. Current Roblox Platform Snapshot

TA-8 reviewed current Roblox/Luau documentation on 2026-09-18.

Relevant current facts:

- `DateTime.now()` exposes current Unix timestamps suitable for persisted wall-clock boundaries;
- `Workspace:GetServerTimeNow()` returns a smoothed monotonic estimate of server Unix time, useful for synchronized/live interval timing;
- Luau's sole number type is a 64-bit IEEE-754 double and integers up to `2^53` are exactly representable;
- `UpdateAsync()` transforms cannot yield and are intended to update from current durable state;
- failed DataStore writes can have uncertain backend outcome, reinforcing idempotent reconciliation instead of "retry means new transaction";
- DataStore requests and payloads are limited/throttled, reinforcing settlement/checkpoint architecture instead of per-tick persistence.

Dated references are recorded in `TA8_ROBLOX_ECONOMY_TIME_NUMERIC_SNAPSHOT.md`.

## 56. Downstream Ownership

### TA-9

- concrete region Access Unlock definitions;
- world active reward inputs.

### TA-10

- event Energy rewards;
- trade integration with collection/assignment state.

### TA-11

- product receipt/entitlement verification;
- commercial capacity/starter Energy operation source.

### TA-12

- Vault/collection/economy UI;
- offline recap;
- quote/confirmation presentation;
- Overflow-Held resolution UX.

### TA-13

- rate/config epochs;
- catch-up/config rollout;
- economy telemetry/remediation audit.

### TA-14

- max collection/slot counts;
- offline-window limits;
- crash allowance/checkpoint cadence;
- deferred queue/audit retention;
- DataStore throughput budgets.

### TA-15

- arithmetic/property/fault/concurrency tests.

### TA-17

- exact profile field names;
- exact fixed-point helper API;
- exact operation/quote ID formats;
- concrete repositories/services/modules/remotes.

## 57. Open Questions

There are **zero TA-8-blocking open questions**.

Correctly downstream/tuneable:

- exact starting capacities/upgrade sizes/prices — content/TA-13;
- exact Production Profiles/Trait modifiers — content;
- exact Offline Production Window tiers — content/TA-14;
- exact checkpoint/crash allowance seconds — TA-14/TA-17;
- exact collection maximum — TA-14;
- exact event rewards — TA-10;
- exact paid capacity quantities/product IDs — TA-11;
- concrete UI — TA-12;
- concrete module names/schema keys — TA-17.

## 58. Architecture-Complete Checklist

- [x] Player Profile collection/Vault/economy authority defined;
- [x] Collection state canonicalization defined;
- [x] safe integer/fixed-point representation defined;
- [x] wallet hard safety ceiling defined;
- [x] wall-clock + monotonic clock model defined;
- [x] production settlement algorithm defined;
- [x] online/offline continuous timeline defined;
- [x] clean leave and crash recovery defined;
- [x] versioned Production Rate Epoch behavior defined;
- [x] P2 Production Assignment defined;
- [x] Production Buffer saturation/over-cap preservation defined;
- [x] exact-once Production Claim defined;
- [x] wallet overflow/deferred grant handling defined;
- [x] Collection Capacity calculation defined;
- [x] deterministic Capacity Reconciliation defined;
- [x] Overflow-Held resolve defined;
- [x] Display/Production slot authority defined;
- [x] Energy transaction primitive/reason codes defined;
- [x] Progression Quote defined;
- [x] Vault/Capture/Access purchases defined;
- [x] commercial capacity/starter grant integration defined;
- [x] load/server-hop/shutdown behavior defined;
- [x] security/performance/observability/testability defined;
- [x] current Roblox/Luau time/numeric/persistence behavior reviewed;
- [x] zero TA-8-blocking questions.
