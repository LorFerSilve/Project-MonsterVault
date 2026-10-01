# IMP-9 / TA-8 Gate Audit

> **Status:** COMPLETE — all phase-owned gates PASS
>
> **Date:** 2026-10-01
>
> **Candidate:** AD-254; source identities in [native Studio evidence](evidence/IMP9_STUDIO_PROGRESSION_COMPLETION_2026-10-01.json)

This audit covers the complete IMP-9 foundation and all TA-8 sections. PASS means an implemented phase-owned guarantee with evidence, or a tested fail-closed boundary for an owner explicitly assigned to a later phase by TA-17. It does not claim that a later world, event, commerce or live-ops system is implemented. No validation-timing exception is introduced.

## Phase-owned gate matrix

| Gate | Contract and closure criterion | Status | Evidence |
|---|---|---|---|
| IMP9-01 | TA-8 §§1–8, 41–44: one server-owned aggregate; versioned migration/validation before Ready; TA-4 lease and single writer | PASS | ProfileSession C0; Vault/Production/Energy/Progression protected-load suites; fresh shipped composition |
| IMP9-02 | §§9–20: exact owned instance references; independent canonical production/display assignments; role/slot/ownership/Held checks | PASS | VaultProduction canonicalAssignments, protectedLoads, uncertainAssignmentWrites; native repetitions |
| IMP9-03 | §§21–23: separately authorized capacity components; deterministic capacity loss settles before invalidation; no deletion/reroll/unlock | PASS | VaultReconciliation authorizedComponents/deterministicReconciliation; capacitySettlementAndRaces; AD-250/251 Studio evidence |
| IMP9-04 | §24: exact owner-selected P2 Resolve Overflow; preserve identity/locks/provenance; no automatic assignment or resolution | PASS | resolutionExactlyOnce/uncertainResults/clientIntentOnly; previous native owner GUI and current native regressions |
| IMP9-05 | §§11–17, 42, 48–49: fixed-point production, historical rate/capability epochs and persisted cursor; no tick writes or server-hop replay | PASS | continuousTimeline/epochAndCapabilityChanges/monotonicAuthority/uncertainSavesAndLeave; fresh DEV rejoin |
| IMP9-06 | §§15–17, 39–40: clean offline bound; 180-second unclean allowance; safe regression/huge jump/epoch failure | PASS | boundedOfflineAndCrash/monotonicAuthority/protectedLoads; prospective upgrade boundary test |
| IMP9-07 | §29: saturation and OverCapPreserved; no retrospective buffer loss; fractional remainder remains claimable | PASS | Production epoch tests; ProductionClaim numericRemainders; upgraded buffer saturation boundary |
| IMP9-08 | §§25–27, 45–46: bounded integer Energy; one authorized reason-coded primitive; no debt, unauthorized source or paid production advantage | PASS | ProductionClaim protectedLoadsAndPrimitive/numericRemainders/boundedAudit; distinct bound Vault/Capture/Access sinks |
| IMP9-09 | §28: exact-once whole-unit claim, headroom clamp, atomic wallet/buffer decrement; duplicates cannot consume later output | PASS | All eight ProductionClaim exports; AD-252 real GUI, unknown-result and rejoin evidence; current native regressions |
| IMP9-10 | §§31–32: server quotes bind definition/config, expected tier/revision, prerequisite reference and 60-second monotonic expiry; explicit confirmation | PASS | ProgressionPurchase staleTamperAndIsolation/authoritativeReadback/catalogNavigationAndHostility; real Review/Confirm GUI |
| IMP9-11 | §§31–32, 44, 47: atomic debit/effect/receipt; no partial debit on insufficient funds or invalid effects/prerequisites | PASS | rejectionNoMutation/catalogFaultsAndRejections/accessProofGates; real DEV insufficient/tampering/proof rejection |
| IMP9-12 | §§31–33: monotonic collection, production/display slot, buffer and 2h→4h→8h→12h offline ladders; one operation advances one tier | PASS | catalogRoundTrip/vaultEffectBoundaries; twelve real DEV purchases; effective counts/caps after fresh shipped rejoin |
| IMP9-13 | §§13–17, 33: settle against old production capabilities at one fixed purchase boundary before applying the new level; clock regression rejects expansion | PASS | vaultEffectBoundaries; saturated old buffer grants no retroactive headroom; native production regressions |
| IMP9-14 | §34; GDS-5/8: persistent Capture Capability has a bounded server challenge effect; no attempt tax, reroll, capacity bypass or ownership shortcut | PASS | captureCapabilityEffect: RNG 0.82 fails at baseline 0.80 and becomes provisional at level-1 0.85; duplicate submit consumes no extra draw; Held/capacity remains binding |
| IMP9-15 | §35; GDS-9 §§4–6: stable independent Mid A/B access, Starter mastery prerequisite; Advanced needs both Mid access facts and both active masteries | PASS | accessProofGates; native Before/After unknown-result Access purchases with injected trusted test owner; no discovery/world progress mutation |
| IMP9-16 | §§31–35, 44, 47: duplicate/retry/race/expiry/unknown-result handling through existing P2 candidate; durable receipt survives audit eviction and repricing | PASS | uncertainCutPoints/duplicateRaceAndClaim/unknownDisconnectAndTakeover/protectedLoadsAndAuditEviction/catalogFaultsAndRejections; real races and both write cut points |
| IMP9-17 | §§34–35, 41–42, 49: wallet, all earned tiers, capability and every Access fact persist through save/rejoin; owner/price changes cannot revoke completed access | PASS | catalogRoundTrip; fresh shipped ProfileRuntimeService restores wallet 1505 and all twelve receipts, capability 1, three access facts, exact Held ownership; twelve retries return AlreadyCommitted |
| IMP9-18 | §§27, 30, 37, 41, 50–51: unbound commercial/event/temporary/deferred grants stay protected, never inferred/spendable or silently overwritten | PASS (guard) | authorizedComponents/protectedLoadsAndPrimitive/protectedLoads; AD-252 real protected DEV loads; malformed/valuable progression fails protected load |
| IMP9-19 | §§36, 38, 50–51; TA-3/12: no release refund/trade minting, client price/effect/clock/proof authority, cross-owner quote use or unbounded projections | PASS | reserved owner routes fail closed; hostile ingress; signed sink validation; single selected page passes existing 4 KiB validator; native forged payload/missing revision rejected |
| IMP9-20 | §§45, 52–54: bounded audit/registries/assignments/epochs; deterministic test and evidence coverage; trusted source parity | PASS | 153/153 Lune; 40/40 native Studio C0; 28/28 Python checker tests; static/build/type/dependency/integrity checks; 76/76 authored source parity |

## Explicit downstream owner boundaries

| TA-8 coverage | Implemented IMP-9 boundary | Downstream enablement owner |
|---|---|---|
| §§27, 30, 37: one-time/event/commercial rewards and deferred remainder transfer/replay | Production remainder stays in the buffer. Unbound valuable grants/queues return ProtectedLoadFailure without overwriting value. No external grant or deferred transfer is enabled. | IMP-10 active/world rewards, IMP-11 event rewards, IMP-13 verified commerce; each must bind a legitimate source and prove its deferred headroom/queue/replay gates before enabling grants. |
| §35: world mastery proof and gated world actions | Purchase consumer and persistent access facts are complete. Injected server-only tests prove all gates/effects. Shipped runtime rejects missing mastery authority; purchases do not manufacture route/species/objective/mastery evidence or travel. | IMP-10 TA-9 world registries, finalized mastery owner and server checks on each gated action; exact schema/binding must be registered there. |
| §§19, 36, 38: additional utility, release/trade/commercial operations | No speculative utility effect, refund, trading mint or paid production definition. Unimplemented owner routes remain reserved and unavailable. | Owning creature/world/trading/commerce implementation; not an enabled IMP-9 purchase. |
| §§45, 53: analytics/live config | Compact reason-coded profile audits and diagnostics exist. Named immutable DEV definitions are not launch balance or a live ConfigService binding. | IMP-14 telemetry/config/experiments; retain compatible historical definitions/epochs. |
| §§55–56: platform/release review | Current repository/runtime API paths are tested in Studio. No staging/production promotion is claimed. | IMP-15 release hardening and fresh platform/policy checks. |

These are TA-17 ownership boundaries, not deferred IMP-9 validation rows. The selected progression foundation is closed. IMP-10 may be OPEN for its next dependency; this change starts no world implementation.

**VS1-19 remains DEFERRED under AD-249.** Full controlled L0/L1 (30 players at MaxPlayers=60) and supported real-client frame/memory evidence are mandatory before **IMP-10 COMPLETE**. Solo Studio tests do not satisfy that gate.
