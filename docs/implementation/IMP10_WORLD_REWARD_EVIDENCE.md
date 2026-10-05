# IMP-10 bounded world reward and objective dedupe evidence

Date: 2026-10-05. **IMP-10 OPEN.** Base: `29427009f847d14f925599b75404859bb15383be` (current main). This closes only **Authorized bounded world rewards and objective dedupe** for one authored DEV source. [Gate matrix](IMP10_GATE_MATRIX.md); [native artifact](evidence/IMP10_STUDIO_WORLD_REWARD_2026-10-05.json).

## Blocker and implemented binding

The existing world owner already persisted the active Starter objective, but had no authorized Energy source/amount binding. Its completion counter could not authorize a wallet transaction or a durable grant receipt. Candidate admission also needed to recheck the private session/character/generation after the initial spatial check.

The existing Survey action now binds `field-objective/fixture-return-route`: **entry → clearing → entry**. The immutable registry binds exactly `world-reward/starter-return-dev-v1`, **5 whole Energy**, completion progress 3 and reward epoch `content-snapshot/world-reward-starter-dev-v1`. Registry negatives reject other IDs, objectives, amounts, epochs and unknown fields. This is fixed DEV tuning, not launch balance. No new action, geometry, remote, clock or scheduler is needed.

WorldRuntimeService checks the actual authored binding, server root/health, access and existing private presence owner. The admitted ProfileSession, avatar and generation are pinned; the same callback runs again inside candidate admission. Client-supplied amount/source/completion/operation/eligibility/position fields have no accepted schema. Streaming cannot remove the server-known binding.

## Existing transaction and durable dedupe

WorldActionUseCase detects the existing incomplete → complete transition and calls the existing reason-coded `EnergyService.apply`. `world-objective-reward` is bound only to the immutable DEV source. The existing ProfileSession checkpoint writes objective progress/history, wallet delta, audit and receipt together under the **same server operation ID/revision**. Existing SingleWriterQueue and candidate reconciliation handle Busy, retries and unknown results; there is no second wallet or writer.

One permanent `economy.worldRewardReceipt` records objective/source/epoch, original operation/revision, initial units and remaining units. It is bounded to **one receipt / at most 5 remaining units**. The existing irreversible objective counter and receipt prevent replay after request/session replacement, rejoin and eviction from the 32-entry Energy audit. Profiles with already-completed pre-binding objectives load normally and receive no retroactive reward. Invalid receipts fail protected load instead of creating or dropping value.

TA-8 §§26–30 require overflow preservation for a one-time reward. Wallet headroom receives the available units; the remainder stays unspendable in the same bounded receipt. Existing world/progression reconciliation uses `world-objective-transfer` through the same Energy primitive and P2 writer, retaining the original grant operation reference. Each transfer is revision-fenced and updates only the remaining amount and last transfer stamp; it never creates another grant. The existing native wallet line exposes the bounded pending amount. Full/partial headroom and both transfer write cuts are tested through release/rejoin.

Collection, discovery, mastery, purchased access/capabilities, assignments and production keep their existing owners. Completing the route alone does not create qualifying Secured evidence or mastery. Travel, passive presence, cycle transitions and hazard recovery cannot complete the active Survey or grant a new reward. Recovery preserves admitted P2 work and cannot extract provisional custody.

## Validation

| Check | Proven result |
| --- | --- |
| Focused cases | Seven new relevant C0 cases: exact-once/rejoin, unknown write cuts including unacknowledged lost-write lease takeover/old-writer fencing, race/context fence, headroom, transfer cuts, bindings/protected loads, audit eviction/legacy completion |
| Full regression | **205/205 fast PASS**, including existing production claims/purchases, capture, world/cycle/travel and persistence |
| Native C0 | **40/40 PASS**: 17 existing coordinator + 4 prior presence + 8 prior hazard + 7 reward primitive cases + 4 actual reward runtime suites; counts are entrypoints, not nested fault subcases |
| Actual authored reward | Real client RemoteEvent Survey sequence through shipped World/Capture/Networking owners and **ProfileRuntimeService** gives 0/0/5 Energy; duplicate request IDs and fresh repeated actions add zero; cycle boundary adds zero |
| Actual fault/rejoin | Fresh scoped real DEV UpdateAsync profiles; three before-write failures or successful write with lost result reconcile the accepted candidate after departure; original receipt and 5 Energy survive new shipped profile/runtime instances |
| Actual stale presence/custody | Actual LoadCharacterAsync and a distinct real Ready profile session at the coordinator boundary invalidate pre-admission completion; locked region rejects; provisional hazard recovery interrupts through TA-7 and grants neither completion nor extraction |
| Actual deferred value | Trusted legacy fixture with 2 wallet units of headroom admits 2/defers 3. Valid authored capture and a real 25-Energy capacity purchase open headroom; existing progression readback transfers 3 once, preserving purchase/collection and original grant reference across rejoin |
| Actual client/streaming | Strict forged reward fields and invented reward route reject; actual engine stream-out/in via temporary ReplicationFocus preserves partial objective and server bindings. Local metadata/generation edits grant no authority. Real repeated completion still adds zero |
| Existing mastery/economy | Supplemental native Starter Survey/capture, 720-unit production claim and two 100-unit access purchases yield **525**, including exactly one 5-unit world reward; mastery and receipts remain valid |
| Authoring/fairness | **29/29 authoring PASS**; **315/315** native ground/hazard-clear samples. Same legitimate authored route, discovery/access/progression and custody requirements; no convenience teleport |
| Static/build | StyLua PASS; Selene 0 errors/warnings; **28/28 Python PASS**; dependency/integrity, Rojo build/sourcemap PASS; strict analysis exit 0 with existing missing Roblox-definition warning, not a complete Roblox API type pass |
| Shipped boot/final Edit | Ordinary server/client BOOTSTRAP_READY and CleanOffline settlement; actual normal progression readback/pending label. All 12 temporary modules removed, boots restored, **85/85 source parity** and Studio in Edit |
| Preservation | All **58 authored parts**, five pre-existing MeshParts (four Energy Core + local crate) and recorded Lighting exactly match before/after snapshots |

Reproduce the actual reward suites using `scripts/studio/imp10_world_rewards.luau` and `imp10_reward_client.luau`, with ordinary boots temporarily disabled. The helper uses actual shipped profile owners and unique DEV DataStore scopes; only fault boundaries, shared-pulse timing and capture RNG are test injections. Native pure cases reuse the existing unit modules; prior presence/hazard cases reuse their existing scoped probes. Remove probes, restore boots and return to Edit afterward. Previous probes' expected wallet balances now include the fixed 5-unit reward; older dated evidence remains historical.

## Remaining gates and exact next dependency

**Next:** one approved protected content/lifetime binding → existing spawn and TA-7 acquisition lifetime owner → capture-fairness and fault/rejoin evidence.

Protected content lifetime classes and the full TA-14/15 World Scaling/security/performance audit remain OPEN. **VS1-19 / AD-249 remains deferred and mandatory:** full controlled L0/L1, **L1 30 players at MaxPlayers=60**, supported real-client frame/memory measurements and required repetitions. Solo native probes do not satisfy it. Event/commerce/daily/repeatable rewards, general achievement systems, PQL and IMP-11 are outside this slice. IMP-10 is not COMPLETE.
