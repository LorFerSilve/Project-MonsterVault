# TA-13 Scenario Validation

> **Phase:** TA-13  
> **Status:** PASS  
> **Validation type:** architecture contract / edge-case review

## Telemetry authority and schema

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 1 | client sends CaptureSuccess before server finalization | discard as success authority; only server post-finalization success counts | PASS |
| 2 | same event ID reused with changed meaning | reject semantic reuse; version/new identity required | PASS |
| 3 | compatible optional field added | accept under schema compatibility policy | PASS |
| 4 | unknown event ID | reject telemetry only; gameplay unaffected | PASS |
| 5 | event definition owner missing | registry validation fails | PASS |
| 6 | attempt and success semantics ambiguous | split/name result semantics before approval | PASS |
| 7 | client timestamp conflicts with server | server observation ordering wins | PASS |
| 8 | ContentSnapshot changes | carry relevant provenance | PASS |
| 9 | ConfigSnapshot changes after outcome | reference snapshot governing the outcome | PASS |
| 10 | NaN/infinite value | schema reject | PASS |
| 11 | wrong field type | schema reject | PASS |
| 12 | deprecated event emitted | flag/reject per registry lifecycle | PASS |
| 13 | two domains claim same event ID | uniqueness validation fails | PASS |
| 14 | server logs Release success after rejection | prohibited; log rejection category | PASS |
| 15 | capture attempt aborts | attempt/abort allowed; no secured success | PASS |
| 16 | trade UI confirms locally | no completion until TA-10 durable outcome | PASS |
| 17 | purchase prompt closes | no grant-success from prompt alone | PASS |
| 18 | event shown in UI | presentation does not create occurrence authority | PASS |
| 19 | dashboard says player owns item | ignored for gameplay truth | PASS |
| 20 | telemetry subsystem unavailable | domain correctness continues | PASS |

## Delivery retry and dedup

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 21 | AnalyticsService call succeeds | mark local observation delivered | PASS |
| 22 | transient adapter failure | bounded retry immutable observation | PASS |
| 23 | retry budget exhausted | drop + quality diagnostic | PASS |
| 24 | queue full | shed low-priority telemetry; never block gameplay | PASS |
| 25 | hover telemetry floods | sampling/drop contains | PASS |
| 26 | shutdown with queued noncritical events | best effort only | PASS |
| 27 | same callback twice same observation | local dedup | PASS |
| 28 | recovery sees finalized trade | do not blindly replay original success | PASS |
| 29 | recovery itself matters | emit distinct recovery diagnostic | PASS |
| 30 | retry would require profile write | do not add write solely for analytics | PASS |
| 31 | adapter lacks idempotency key | document best-effort duplicate risk | PASS |
| 32 | wallet succeeds analytics fails | wallet remains successful | PASS |
| 33 | analytics succeeds then crash | no domain rollback | PASS |
| 34 | sampled out | mark intentional sampling | PASS |
| 35 | schema rejection | distinguish invalid observation | PASS |
| 36 | sustained throttling | bounded degradation/drop | PASS |
| 37 | duplicate observer subscriptions | TA-15 catches; one coordinator owner | PASS |
| 38 | telemetry listener errors | isolated from transaction | PASS |
| 39 | diagnostic counter hits bound | aggregate/saturate | PASS |
| 40 | independent events reorder | do not infer transactional order unless contract says so | PASS |

## Privacy cardinality and sampling

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 41 | CreatureInstanceId custom field | reject for Creator Analytics | PASS |
| 42 | PurchaseId custom field | reject for product dimensions | PASS |
| 43 | raw chat as retention field | prohibited | PASS |
| 44 | email cohort field | prohibited | PASS |
| 45 | precise home location | prohibited | PASS |
| 46 | exact birth date | prohibited | PASS |
| 47 | sensitive-trait inference | prohibited | PASS |
| 48 | payer status for rarity treatment | prohibited | PASS |
| 49 | input family dimension | allowed bounded | PASS |
| 50 | progression band dimension | allowed bounded | PASS |
| 51 | freeform stack trace custom field | restricted diagnostics instead | PASS |
| 52 | dynamic per-species event-name explosion | collapse to semantic event + bounded dimension | PASS |
| 53 | sampling by purchase refusal | prohibited | PASS |
| 54 | deterministic sampling by event class | allowed when declared | PASS |
| 55 | severe persistence failure sampling | retain high-priority/unsampled policy | PASS |
| 56 | UserId duplicated into custom field | reject unnecessary duplication | PASS |
| 57 | platform country aggregate | analysis only; no hidden value treatment | PASS |
| 58 | device cohort performs worse | diagnose parity; do not lower value | PASS |
| 59 | analytics export for vulnerability targeting | prohibited | PASS |
| 60 | raw profile dump into analytics | prohibited | PASS |

## Roblox analytics adapter

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 61 | onboarding milestone | map onboarding/funnel | PASS |
| 62 | Energy source finalizes | economy event after mutation | PASS |
| 63 | Energy sink rejected | no successful sink event | PASS |
| 64 | progression milestone finalizes | progression adapter | PASS |
| 65 | feature adoption metric | registered custom event | PASS |
| 66 | journey graph justified | journey adapter | PASS |
| 67 | platform method deprecated | adapter changes only | PASS |
| 68 | event-name limit tightens | registry budget adapts | PASS |
| 69 | custom-field limit tightens | adapter mapping adapts | PASS |
| 70 | charts delayed | runtime unchanged | PASS |
| 71 | Studio lacks production analytics | use fixtures; no authority | PASS |
| 72 | client direct analytics success | not authority | PASS |
| 73 | platform Top payer segment | not gameplay assignment authority | PASS |
| 74 | segment lookup fails | no gameplay downgrade | PASS |
| 75 | platform groups values as Other | architecture not dependent on exact high-cardinality values | PASS |
| 76 | external vendor added | same registry/privacy contract | PASS |
| 77 | two adapters enabled | central controlled fan-out | PASS |
| 78 | external vendor down | gameplay/first-party independence | PASS |
| 79 | attempt/success mapped same | validation rejects ambiguity | PASS |
| 80 | rate budget exceeded | TA-14 degradation priorities | PASS |

## Config classification and snapshots

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 81 | live overlay sets Energy transferable | reject C0 mutation | PASS |
| 82 | live overlay replaces Species identity | reject C1 mutation | PASS |
| 83 | event cadence within approved range | accept C2 candidate | PASS |
| 84 | unknown key | reject candidate | PASS |
| 85 | wrong type | reject candidate | PASS |
| 86 | out-of-range number | reject candidate | PASS |
| 87 | unknown semantic reference | reject candidate | PASS |
| 88 | PROD config uses DEV binding | environment reject | PASS |
| 89 | dependent key pair incomplete | full-snapshot reject | PASS |
| 90 | candidate fully valid | stage immutable snapshot | PASS |
| 91 | activation mid-transaction | transaction stays pinned | PASS |
| 92 | next transaction after activation | uses new snapshot | PASS |
| 93 | C0/C1 registry | remains immutable | PASS |
| 94 | ContentSnapshot incompatible | reject candidate | PASS |
| 95 | ConfigService unavailable startup | safe default/disable optional live feature | PASS |
| 96 | refresh fails with last-known-good | keep active | PASS |
| 97 | same revision twice | idempotent no-op | PASS |
| 98 | revision decreases unexpectedly | reject unless audited rollback | PASS |
| 99 | snapshot ID collision/mismatch | detect/reject | PASS |
| 100 | domain mutates snapshot | architecture/test failure | PASS |

## Rollout flags rollback and kill switch

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 101 | new optional flag missing | OFF | PASS |
| 102 | flag false with persisted objects | objects remain resolvable | PASS |
| 103 | flag true prerequisite false | unavailable + diagnostic | PASS |
| 104 | client says flag true server false | server wins | PASS |
| 105 | flag bypasses entitlement | prohibited | PASS |
| 106 | flag bypasses trade validation | prohibited | PASS |
| 107 | servers receive rollout at different times | each uses coherent local snapshot | PASS |
| 108 | propagation delayed | no simultaneous-switch assumption | PASS |
| 109 | rollback published | activate known validated prior revision prospectively | PASS |
| 110 | rollback after reward | preserve reward | PASS |
| 111 | rollback after Creature acquired | preserve Creature/Variant | PASS |
| 112 | rollback during trade | TA-10 journal decides | PASS |
| 113 | rollback during event capture | active opportunity resolves pinned | PASS |
| 114 | disable message before config | stop new entry conservatively | PASS |
| 115 | enable message without config | ignore as positive authority | PASS |
| 116 | duplicate disable | idempotent | PASS |
| 117 | stale disable | cannot grant; revision/log handling | PASS |
| 118 | message missed | eventual config refresh converges | PASS |
| 119 | operator requests restart | external privileged action | PASS |
| 120 | restart after disable | new servers boot validated current config/defaults | PASS |

## Experiment definition and assignment

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 121 | no hypothesis | cannot activate | PASS |
| 122 | no primary metric | cannot activate | PASS |
| 123 | no guardrails | cannot activate | PASS |
| 124 | no invariants | cannot activate | PASS |
| 125 | live config invents treatment | reject outside envelope | PASS |
| 126 | Class A wording per-player | allowed with parity | PASS |
| 127 | Class B shared event cadence per-player | reject contamination | PASS |
| 128 | Class C shared spawn gives hidden player odds | prohibited | PASS |
| 129 | Class C server-level prospective treatment | allowed with checks | PASS |
| 130 | seed changes mid-flow | prohibited | PASS |
| 131 | reconnect same stable flow | preserve interpretability | PASS |
| 132 | new revision later | new prospective assignment | PASS |
| 133 | payer status for value | prohibited | PASS |
| 134 | purchase refusal for odds | prohibited | PASS |
| 135 | device gets weaker rewards | prohibited | PASS |
| 136 | explicit DEV cohort | allowed | PASS |
| 137 | policy-ineligible user | exclude/fallback | PASS |
| 138 | disabled before treatment reached | no exposure | PASS |
| 139 | permanent whale/churn label | prohibited | PASS |
| 140 | two experiments collide same key | compatibility validation rejects | PASS |

## Exposure provenance and guardrails

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 141 | assigned but UI never opened | no exposure | PASS |
| 142 | treated UI rendered | record exposure | PASS |
| 143 | event treatment affects opportunity | record exposure/context | PASS |
| 144 | Class C opportunity becomes owned | retain durable provenance | PASS |
| 145 | exposure analytics fails | outcome remains valid | PASS |
| 146 | required durable provenance write fails | owning transaction rules decide; analytics cannot fake | PASS |
| 147 | metric improves persistence failures spike | stop/rollback | PASS |
| 148 | retention improves reports spike | stop/rollback | PASS |
| 149 | revenue improves fairness diverges | stop/review | PASS |
| 150 | session time rises via forced waiting | not success | PASS |
| 151 | attendance rises misleading complaints spike | guardrail wins | PASS |
| 152 | trade volume rises safety complaints | stop | PASS |
| 153 | accessibility failures rise | stop/review | PASS |
| 154 | variant acquisition divergence unintended | stop/investigate | PASS |
| 155 | duplication exploit appears | immediate conservative stop | PASS |
| 156 | ownership loss appears | immediate stop | PASS |
| 157 | experiment stopped | future exposures disabled | PASS |
| 158 | valid finalized treatment reward | preserved | PASS |
| 159 | guardrail alert transport fails | no direct gameplay mutation | PASS |
| 160 | weak uncertain signal | result record retains uncertainty | PASS |

## Privileged live ops and audit

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 161 | client calls admin remote | no baseline authority | PASS |
| 162 | Open Cloud key in LocalScript | prohibited | PASS |
| 163 | API key in repository | prohibited | PASS |
| 164 | environment-scoped credential | allowed | PASS |
| 165 | overbroad scopes | least-privilege review fails | PASS |
| 166 | publish lacks reason/change record | workflow rejects | PASS |
| 167 | publish validation fails | audit failure; no activation assumption | PASS |
| 168 | publish succeeds | record before/after/result | PASS |
| 169 | rollback | append linked operation | PASS |
| 170 | Creator Hub edit | revision history + change process | PASS |
| 171 | arbitrary inventory mutation | outside TA-13 baseline | PASS |
| 172 | enable unreviewed feature | reject | PASS |
| 173 | attempt C0 mutation | reject | PASS |
| 174 | stolen credential publishes malformed config | runtime validation keeps safe state | PASS |
| 175 | stolen credential sends disable | may conservatively outage; cannot grant/rewrite | PASS |
| 176 | stolen credential sends enable hint | ignored without validated config | PASS |
| 177 | platform omits operator metadata | deployment process supplies principal/change record | PASS |
| 178 | audit system unavailable | risky unaudited production mutation fails safe | PASS |
| 179 | audit record includes token | redact/prohibit | PASS |
| 180 | concurrent publishes race | revision precondition/change workflow detects conflict | PASS |

## Cross-server events and emergency controls

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 181 | schedule updates before occurrence | new occurrence uses validated schedule | PASS |
| 182 | schedule changes during active occurrence | existing TA-10 occurrence timing preserved | PASS |
| 183 | server hop after update | does not reset duration | PASS |
| 184 | event disabled for exploit | stop new instances/opportunities | PASS |
| 185 | active valid capture at disable | resolve owning rules | PASS |
| 186 | reward already committed | preserve/idempotent finalize | PASS |
| 187 | refresh hint duplicate | safe | PASS |
| 188 | hint out of order | revision check | PASS |
| 189 | MessagingService unavailable | durable config/event authority remains | PASS |
| 190 | universe message enables reward | prohibited | PASS |
| 191 | universe message requests refresh | allowed hint | PASS |
| 192 | MemoryStore cache expires | no durable config/history loss | PASS |
| 193 | server starts invalid live config | safe default/feature off | PASS |
| 194 | server starts during event window | TA-10 derives phase/occurrence | PASS |
| 195 | servers activate revision seconds apart | local operations coherent; telemetry labels snapshot | PASS |
| 196 | shared contention experiment | server/occurrence assignment | PASS |
| 197 | announcement wording experiment | safe Class A/B | PASS |
| 198 | disable then rollback | no double-revocation | PASS |
| 199 | restart after critical exploit | external operator may restart after durable disable | PASS |
| 200 | restart endpoint unavailable | incident remains operational; no gameplay rewrite | PASS |

## Failure recovery and security

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 201 | forged huge telemetry field | schema bounds/reject | PASS |
| 202 | client spoofs TreatmentId | server assignment wins | PASS |
| 203 | client spoofs ConfigSnapshotId | ignore/reject | PASS |
| 204 | client floods telemetry intent | rate-limit/sanitize | PASS |
| 205 | config contains executable data | declarative schema reject | PASS |
| 206 | config NaN/infinite | reject | PASS |
| 207 | cross-environment repo selected | environment reject | PASS |
| 208 | Config refresh throws | last-known-good | PASS |
| 209 | domain activation callback errors | candidate not partially activated | PASS |
| 210 | domain reads config each frame | architecture violation | PASS |
| 211 | operator account revoked | privileged calls fail safely | PASS |
| 212 | external vendor exfiltration risk | security/privacy review required | PASS |
| 213 | moderation text enters product analytics | channel/schema reject | PASS |
| 214 | correlation ID enters Creator field | reject | PASS |
| 215 | analytics amplification | central budget | PASS |
| 216 | feature dependency cycle | reject | PASS |
| 217 | experiment dependency cycle | reject | PASS |
| 218 | rollback revision missing | no partial synthetic rollback | PASS |
| 219 | audit action replay | idempotency/conflict handling | PASS |
| 220 | privileged message malformed | ignore + security diagnostic | PASS |

## Upstream integration

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 221 | Protected Load Failure | analytics may observe; config cannot enable irreversible play | PASS |
| 222 | profile lease unavailable | live ops cannot bypass TA-4 | PASS |
| 223 | Variant finalized | cannot reroll | PASS |
| 224 | capture claim across config change | pin semantics | PASS |
| 225 | Production claim spans change | TA-8 coherent rate/snapshot | PASS |
| 226 | Energy price changes | completed purchase not repriced | PASS |
| 227 | spawn weights change | future reservations only | PASS |
| 228 | event active | TA-10 identity/timing preserved | PASS |
| 229 | trade confirmed | cannot alter offer semantics mid-commit | PASS |
| 230 | Game Pass entitlement active | flag cannot fabricate revocation | PASS |
| 231 | Developer Product retry | analytics not receipt dedup authority | PASS |
| 232 | regional price differs | grant unchanged | PASS |
| 233 | modal experiment | TA-12 input/focus invariants | PASS |
| 234 | Reduced Motion enabled | experiment cannot override accessibility floor | PASS |
| 235 | gamepad cohort worse | diagnose without weaker rewards | PASS |
| 236 | Social Ping experiment | spam/safety invariants | PASS |
| 237 | event reward experiment | C2 range + exact-once | PASS |
| 238 | shop layout experiment | truthful/noncoercive | PASS |
| 239 | feature disables content | persisted IDs resolvable | PASS |
| 240 | analytics globally unavailable | all domain correctness intact | PASS |

## Downstream performance testing readiness

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 241 | TA-14 queue size | bounded/nonblocking | PASS |
| 242 | TA-14 refresh cadence | platform-safe convergence | PASS |
| 243 | TA-14 message budget | preserve emergency refresh | PASS |
| 244 | TA-14 telemetry degradation | drop lower priority first | PASS |
| 245 | TA-15 registry uniqueness test | required | PASS |
| 246 | TA-15 forbidden-field test | required | PASS |
| 247 | TA-15 Analytics failure injection | gameplay passes | PASS |
| 248 | TA-15 Config failure injection | safe fallback passes | PASS |
| 249 | TA-15 atomic swap test | no mixed state | PASS |
| 250 | TA-15 stale-revision test | safe reject | PASS |
| 251 | TA-15 assignment test | stable declared unit | PASS |
| 252 | TA-15 shared-context test | no mixed contention | PASS |
| 253 | TA-15 rollback test | no finalized-value loss | PASS |
| 254 | TA-15 privilege test | client cannot mutate | PASS |
| 255 | TA-16 cross-audit | zero critical collisions | PASS |
| 256 | TA-17 module names | cannot change authority | PASS |
| 257 | TA-17 config key layout | preserve owner/class/snapshot | PASS |
| 258 | TA-17 operator tool | preserve least privilege/audit | PASS |
| 259 | Config API still Beta | choose revalidated/manual adapter without semantic change | PASS |
| 260 | analytics limits change | update adapter budget; semantics unchanged | PASS |

## Result

**260 / 260 PASS.**

No TA-13-blocking scenario failure remains. Numeric runtime budgets are deferred to TA-14 and executable validation to TA-15.
