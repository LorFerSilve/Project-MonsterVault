# TA-8 Scenario Validation

> **Phase:** TA-8 — Vault, Economy, Progression, Inventory, and Offline Accrual  
> **Status:** PASS

| # | Scenario | Expected result | Result |
|---:|---|---|---|
| 1 | Energy stored as fractional float | Invalid persistent representation | PASS |
| 2 | Energy negative | Reject/protected invalid state | PASS |
| 3 | Energy above 1e12 | Reject/clamp only through explicit safe remediation | PASS |
| 4 | Production buffer uses fixed-point integer | Valid | PASS |
| 5 | Production buffer exceeds fixed-point ceiling | Invalid | PASS |
| 6 | Intermediate production multiplication could exceed 2^53 | Content/config rejected | PASS |
| 7 | Client sends wallet value | Ignored | PASS |
| 8 | Client sends offline duration | Ignored | PASS |
| 9 | Client sends production rate | Ignored | PASS |
| 10 | Client sends upgrade level | Ignored | PASS |
| 11 | Client device clock is wrong | No authority | PASS |
| 12 | Server wall clock goes backwards relative to persisted cursor | Eligible elapsed clamps to zero | PASS |
| 13 | Server wall clock jumps far forward | Window/buffer/catchup caps bound value | PASS |
| 14 | Live session monotonic clock progresses | Valid elapsed basis | PASS |
| 15 | Production simulated every frame | Not required / architecture rejects as baseline | PASS |
| 16 | Production settled at claim boundary | Required | PASS |
| 17 | Production settled before assignment change | Required | PASS |
| 18 | Production settled before slot reduction | Required | PASS |
| 19 | Production settled before clean leave | Required | PASS |
| 20 | Same interval settled twice | Second settlement credits zero/new interval only | PASS |
| 21 | Settlement cursor not advanced with buffer write | Invalid replay risk | PASS |
| 22 | Cursor + buffer advance atomically | Required | PASS |
| 23 | No valid assignments | Zero production | PASS |
| 24 | One valid assignment | Rate contributes | PASS |
| 25 | Multiple valid assignments | Rates aggregate safely | PASS |
| 26 | Overflow-Held assigned creature | Invalid assignment/no production | PASS |
| 27 | Creature in conflicting active role | Production blocked | PASS |
| 28 | Creature Lock set | Production still allowed | PASS |
| 29 | Legendary Species only | No automatic rate multiplier | PASS |
| 30 | Extreme Mutation only | No automatic rate multiplier | PASS |
| 31 | Compound status only | No automatic rate multiplier | PASS |
| 32 | explicit bounded Trait production effect | Applied | PASS |
| 33 | spender status | Never rate input | PASS |
| 34 | paid Collection Capacity | Never rate input | PASS |
| 35 | commercial entitlement attempts Production Slot grant | Rejected by schema/GDS boundary | PASS |
| 36 | production rate epoch changes | Old elapsed uses old epoch; future uses new | PASS |
| 37 | offline interval crosses two rate epochs | Piecewise settlement | PASS |
| 38 | historical rate epoch missing | Protected settlement failure | PASS |
| 39 | rate config update rerolls creature identity | Prohibited | PASS |
| 40 | assignment add is only client-side drag state | No production authority | PASS |
| 41 | finalized assignment P2 succeeds | Persists across sessions | PASS |
| 42 | assignment P2 fails | Old assignment remains authority | PASS |
| 43 | disconnect immediately after acknowledged assignment | New assignment persists | PASS |
| 44 | same creature assigned to two Production Slots | Reject | PASS |
| 45 | two creatures assigned to one slot | Reject | PASS |
| 46 | unknown CreatureInstanceId assignment | Reject | PASS |
| 47 | assignment belongs to another player | Reject | PASS |
| 48 | assignment to locked creature | Allowed if otherwise valid | PASS |
| 49 | assignment to Overflow-Held | Reject | PASS |
| 50 | assignment changes after accrued production | Settle old value then mutate | PASS |
| 51 | unassignment erases buffer | Prohibited | PASS |
| 52 | slot upgrade adds slot | Existing assignments unchanged | PASS |
| 53 | slot count reduced | Settle then deterministic excess unassign | PASS |
| 54 | slot reduction deletes creatures | Prohibited | PASS |
| 55 | display ref changes | Ownership unchanged | PASS |
| 56 | same creature in two Display Slots | Reject | PASS |
| 57 | display-only change mints Energy | Prohibited | PASS |
| 58 | display capacity full | No collection overflow | PASS |
| 59 | displayed creature enters Overflow-Held | Clear display ref safely | PASS |
| 60 | production-assigned creature enters Overflow-Held | Settle, clear assignment, then overflow | PASS |
| 61 | base Collection Capacity calculated | Valid | PASS |
| 62 | earned capacity added | Valid | PASS |
| 63 | commercial Collection Capacity added | Valid bounded component | PASS |
| 64 | commercial capacity adds Production Slots | Prohibited | PASS |
| 65 | commercial capacity adds Offline Window | Prohibited | PASS |
| 66 | ordinary creature count <= capacity | No reconciliation | PASS |
| 67 | count exceeds capacity after entitlement loss | Non-destructive reconciliation | PASS |
| 68 | capacity reduction releases excess creature | Prohibited | PASS |
| 69 | capacity reduction sells excess creature | Prohibited | PASS |
| 70 | capacity reduction deletes Protected Variant | Prohibited | PASS |
| 71 | player priority list valid | Used first | PASS |
| 72 | priority list includes non-owned ID | Ignore/reject invalid entry safely | PASS |
| 73 | no priority list | Stable automatic order | PASS |
| 74 | auto order uses rarity/value | Prohibited | PASS |
| 75 | auto order uses acquisition sequence + ID tiebreak | Valid | PASS |
| 76 | active role retained where capacity allows | Valid | PASS |
| 77 | excess active role cannot fit | Safely end role then overflow | PASS |
| 78 | overflow exact instance keeps identity | Required | PASS |
| 79 | overflow keeps Creature Lock | Required | PASS |
| 80 | overflow keeps provenance/Variant | Required | PASS |
| 81 | unresolved Overflow exists | Ordinary new capture blocked downstream | PASS |
| 82 | free capacity opens | Player may resolve exact overflow instance | PASS |
| 83 | Resolve Overflow mints clone | Prohibited | PASS |
| 84 | Resolve Overflow rerolls Variant | Prohibited | PASS |
| 85 | Resolve Overflow automatically production-assigns | Prohibited baseline | PASS |
| 86 | Resolve Overflow P2 fails | Creature remains Overflow-Held | PASS |
| 87 | clean leave after active production | Settle to leave boundary | PASS |
| 88 | clean leave writes CleanOffline marker | Required | PASS |
| 89 | rejoin within Offline Window | Accrue elapsed absence | PASS |
| 90 | rejoin beyond Offline Window | Accrue only window | PASS |
| 91 | buffer fills before offline window | Stop at buffer cap | PASS |
| 92 | server hop immediately after clean leave | No window reset | PASS |
| 93 | device change | No window reset | PASS |
| 94 | offline recap reopened | No second production grant | PASS |
| 95 | offline production spawns creatures | Prohibited | PASS |
| 96 | offline production grants event participation | Prohibited | PASS |
| 97 | assignment was never durably finalized before leaving | No offline production from it | PASS |
| 98 | session crashes after checkpoint | Unclean recovery path | PASS |
| 99 | unclean recovery elapsed within window | Accrue bounded interval | PASS |
| 100 | unclean recovery elapsed beyond window | Window + crash allowance maximum | PASS |
| 101 | crash allowance treated as normal bonus | Prohibited | PASS |
| 102 | crash allowance unbounded | Prohibited | PASS |
| 103 | crash recovery telemetry marked | Required | PASS |
| 104 | server shutdown clean save succeeds | Clean offline boundary | PASS |
| 105 | shutdown save fails | Later stale-lease path uses bounded crash recovery | PASS |
| 106 | shutdown creates bonus interval | Prohibited | PASS |
| 107 | production buffer below 1000 milli | No whole Energy claim | PASS |
| 108 | buffer 1500 milli, wallet headroom large | Claim 1 Energy; 500 milli remains | PASS |
| 109 | buffer 5000 milli, wallet headroom 3 | Claim 3 Energy; 2000 milli remains | PASS |
| 110 | wallet at max | Claim transfers zero; buffer unchanged | PASS |
| 111 | duplicate Production Claim packet | No duplicate transfer | PASS |
| 112 | claim DataStore response lost after success | Reconcile same operation/current state | PASS |
| 113 | claim failure before commit | Buffer/value preserved | PASS |
| 114 | buffer decrement succeeds without wallet increment | Impossible atomic profile mutation | PASS |
| 115 | wallet increment succeeds without buffer decrement | Impossible atomic profile mutation | PASS |
| 116 | Production Claim mutates assigned creature | Prohibited | PASS |
| 117 | buffer capacity reduced below current value | Preserve OverCapPreserved | PASS |
| 118 | OverCapPreserved buffer continues accrual | No | PASS |
| 119 | claim lowers buffer below cap | New production may resume | PASS |
| 120 | capacity upgrade raises buffer cap | Existing value preserved | PASS |
| 121 | direct arbitrary profile.energy mutation in domain | Architecture violation | PASS |
| 122 | reason-coded Energy operation | Required | PASS |
| 123 | duplicate operation ID same semantics | Reconcile one result | PASS |
| 124 | same operation ID reused for different semantics | Reject integrity violation | PASS |
| 125 | spend greater than wallet | Fail with no partial spend | PASS |
| 126 | spend exactly wallet | Balance reaches zero | PASS |
| 127 | grant would exceed wallet max | Apply safe headroom + preserve remainder | PASS |
| 128 | Production grant remainder | Remains in Production Buffer | PASS |
| 129 | one-time reward remainder | Deferred Energy Grant | PASS |
| 130 | deferred commercial starter remainder | Deferred Energy Grant | PASS |
| 131 | deferred grant considered spendable before transfer | No | PASS |
| 132 | wallet headroom later opens | Reconcile deferred grants | PASS |
| 133 | multiple deferred grants | Deterministic oldest-operation first | PASS |
| 134 | deferred queue technical bound reached | New grant protected/fails rather than dropping old | PASS |
| 135 | duplicate deferred operation | Deduped | PASS |
| 136 | Release ordinary creature | No baseline Energy reward | PASS |
| 137 | Capture ordinary creature | No baseline Energy reward | PASS |
| 138 | world milestone explicit Energy reward | Allowed exact-once | PASS |
| 139 | Event explicit Energy reward | Allowed via TA-10 | PASS |
| 140 | starter bundle bounded Energy | Allowed via verified TA-11 source | PASS |
| 141 | player-to-player Energy transfer | Prohibited | PASS |
| 142 | progression quote price supplied by client | Rejected | PASS |
| 143 | server quote contains exact price | Valid | PASS |
| 144 | quote current + funds/prereqs valid | Purchase may commit | PASS |
| 145 | quote expired | No charge; re-quote | PASS |
| 146 | config price changes while quote open | No silent changed charge | PASS |
| 147 | quote target current level changed | Reject/re-quote | PASS |
| 148 | insufficient Energy | No effect/no spend | PASS |
| 149 | missing active Milestone | No effect/no spend | PASS |
| 150 | duplicate purchase request | One cost/effect maximum | PASS |
| 151 | purchase response lost | Reconcile operation | PASS |
| 152 | purchase cost deducted but effect absent | Prohibited atomicity violation | PASS |
| 153 | effect granted but cost absent | Prohibited atomicity violation | PASS |
| 154 | already-owned Access Unlock requested again | No duplicate charge | PASS |
| 155 | completed purchase price later drops | Completion remains; no automatic refund | PASS |
| 156 | completed purchase price later rises | Completion remains | PASS |
| 157 | catch-up uses explicit progression threshold | Allowed | PASS |
| 158 | catch-up uses spend propensity | Prohibited | PASS |
| 159 | catch-up fabricates Species Discovery | Prohibited | PASS |
| 160 | Vault Collection Capacity upgrade | Atomic Energy+level | PASS |
| 161 | Production Slot upgrade | Atomic Energy+level | PASS |
| 162 | Buffer capacity upgrade | Atomic Energy+level | PASS |
| 163 | Offline Window upgrade | Atomic Energy+level | PASS |
| 164 | Display upgrade | Atomic Energy+level | PASS |
| 165 | upgrade retries and adds two levels | Prohibited | PASS |
| 166 | upgrade capacity deletes creatures | Prohibited | PASS |
| 167 | non-premium path absent for core Vault | Prohibited | PASS |
| 168 | Capture Capability upgrade | Atomic persistent level | PASS |
| 169 | Capture Capability steals active claim | Prohibited | PASS |
| 170 | Capture Capability bypasses extraction | Prohibited | PASS |
| 171 | Capture Capability rerolls Variant | Prohibited | PASS |
| 172 | Access Unlock Energy-only despite required Milestone | Reject | PASS |
| 173 | Access Unlock with Milestone + funds | Exact-once P2 | PASS |
| 174 | Access Unlock backfills Landmark discovery | Prohibited | PASS |
| 175 | Access Unlock backfills Region Mastery | Prohibited | PASS |
| 176 | commercial capacity entitlement applies | Add bounded Collection/Display capacity | PASS |
| 177 | commercial capacity later revoked | Reconcile; no deletion/debt | PASS |
| 178 | commercial revocation changes Production Slots | Prohibited | PASS |
| 179 | paid Production multiplier | Prohibited baseline | PASS |
| 180 | paid Buffer capacity | Prohibited baseline | PASS |
| 181 | paid Offline Window | Prohibited baseline | PASS |
| 182 | paid Capture Capability | Prohibited GDS-13 baseline | PASS |
| 183 | paid claim priority | Prohibited | PASS |
| 184 | starter Energy grants active milestone | Prohibited | PASS |
| 185 | load profile with duplicate creature IDs | Protected Load Failure | PASS |
| 186 | load profile over collection capacity | Deterministic reconciliation | PASS |
| 187 | load stale display reference | Losslessly clear if safe | PASS |
| 188 | load invalid production reference with no value uncertainty | Losslessly clear/repair | PASS |
| 189 | load invalid production state where value cannot be proven | Protected failure | PASS |
| 190 | load unknown valuable content ID | Tombstone/migration or Protected Load Failure | PASS |
| 191 | load negative Energy | Protected invalid state | PASS |
| 192 | load buffer over new cap | Preserve OverCapPreserved | PASS |
| 193 | load clean offline cursor | Settle once | PASS |
| 194 | load same profile again through concurrent server | TA-4 lease blocks second owner | PASS |
| 195 | Energy operations race in two coroutines | TA-4 one-writer queue serializes | PASS |
| 196 | claim and purchase race for wallet | Serialized current-state revalidation | PASS |
| 197 | capture finalization and capacity purchase race | Serialized profile operations | PASS |
| 198 | two Access purchases spend same balance | At most one if funds insufficient after first | PASS |
| 199 | DataStore throttling occurs | No weakened validation; retry/pending | PASS |
| 200 | DataStore failure has unknown write outcome | Stable operation reconciliation | PASS |
| 201 | profile written every production second | Prohibited baseline throughput pattern | PASS |
| 202 | production calculated by one Heartbeat per creature | Prohibited baseline performance pattern | PASS |
| 203 | aggregated profile production rate | Preferred | PASS |
| 204 | collection exact instance lookup via map | Valid | PASS |
| 205 | display list treated as ownership source | Prohibited | PASS |
| 206 | client projected Energy differs locally | Server wallet unaffected | PASS |
| 207 | client predicted buffer differs locally | Server settlement corrects | PASS |
| 208 | player remains AFK online | Same baseline passive rate as active elapsed semantics | PASS |
| 209 | player stays connected to bypass offline window | Online accrual valid but no hidden multiplier | PASS |
| 210 | offline window restarts each reconnect | Prohibited | PASS |
| 211 | old production config applies retroactively after epoch switch | Prohibited | PASS |
| 212 | price experiment alters already confirmed transaction | Prohibited | PASS |
| 213 | economy reset wipes Energy seasonally | Prohibited baseline | PASS |
| 214 | prestige wipes collection/upgrades | Prohibited baseline | PASS |
| 215 | operator remediation needed after exploit | Reason-coded auditable operation | PASS |
| 216 | remediation silently deletes legitimate creatures | Prohibited baseline | PASS |
| 217 | audit ledger grows without bound | Prohibited | PASS |
| 218 | full private profile logged | Prohibited data minimization | PASS |
| 219 | exact offline recap shown twice | Informational only, no duplicate value | PASS |
| 220 | Collection/Vault/Energy/offline system preserves exact value across claim, leave, crash, capacity change and retry | Required integrated outcome | PASS |

## Verdict

**220 / 220 scenarios: PASS.**

No TA-8 collection-capacity, numeric, production, offline-accrual, Energy, progression-purchase, commercial-capacity or exact-once contradiction remains.
