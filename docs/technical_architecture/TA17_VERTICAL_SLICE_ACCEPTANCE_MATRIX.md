# TA-17 VS-1 Acceptance Matrix

> **Status:** LOCKED
> **Date:** 2026-09-24
> **Vertical slice:** VS-1 — Trusted Join -> One World Creature -> Capture -> Secure Ownership -> Rejoin
> **Amendments:** [AD-249](ARCHITECTURE_DECISIONS.md#ad-249--defer-vs1-19-to-the-imp-10-completion-gate) registered the original deferral; [AD-260](ARCHITECTURE_DECISIONS.md#ad-260--reclassify-vs1-19-as-a-scale-readiness-gate), accepted 2026-10-05, reclassifies VS1-19 as a future Scale Readiness Gate. IMP-8 remains COMPLETE with deferred validation; VS1-19 remains DEFERRED, not PASS.

## Scope

One deterministic DEV fixture Species/World Creature is sufficient.

The slice proves architecture seams; it is not a content-complete gameplay demo.

## End-to-end happy path

1. client/server bootstrap;
2. Player joins;
3. TA-4 profile is acquired/validated and Session.Ready is emitted;
4. one server-owned World Creature is materialized;
5. client receives projection and Interaction ID;
6. player sends Interaction.PrimaryInteract;
7. server validates context and starts capture session;
8. Variant identity is finalized once using injected/server RNG;
9. player sends Capture.SubmitAction;
10. server resolves Capture Success -> Provisional Capture / Transport Custody;
11. Secure Point finalization is server-authorized;
12. CaptureFinalizationUseCase creates one P2 ownership operation;
13. UpdateAsync checkpoint succeeds and profileRevision increments;
14. same CreatureInstanceId is projected as Secured;
15. client disconnects;
16. rejoin loads the same secured CreatureInstanceId exactly once.

## Mandatory acceptance

| ID | Requirement | Criticality |
|---|---|---|
| VS1-01 | repository format/lint/type/build gates pass | C0 |
| VS1-02 | one server and one client entrypoint only | C0 |
| VS1-03 | profile load failure cannot default-save/enter irreversible play | C0 |
| VS1-04 | foreign fresh lease blocks second writer | C0 |
| VS1-05 | ClientHello cannot grant readiness | C0 |
| VS1-06 | unknown/malformed/NaN/oversized capture command is no-op | C0 |
| VS1-07 | spoofed player/Instance/context cannot capture | C0 |
| VS1-08 | one World Creature has stable runtime/semantic IDs | C0 |
| VS1-09 | Variant identity cannot reroll on retry | C0 |
| VS1-10 | duplicate Capture.SubmitAction cannot duplicate state/reward | C0 |
| VS1-11 | Capture Success is not yet secured ownership | C0 |
| VS1-12 | Secure finalization creates one server OperationId | C0 |
| VS1-13 | crash/timeout after durable apply before client result reconciles to success exactly once | C0 |
| VS1-14 | persistence failure before apply never fabricates secured ownership | C0 |
| VS1-15 | reconnect projects same CreatureInstanceId once | C0 |
| VS1-16 | client timeout presents OutcomeUnknown/Pending until reconciliation | C1 |
| VS1-17 | touch/keyboard/gamepad semantic interaction paths remain equivalent | C1 |
| VS1-18 | Reduced Motion cannot remove critical capture state meaning | C1 |
| VS1-19 | Full L0/L1 and supported real-client performance validation has no TA-14 hard guardrail violation; historical L1 is 30 players at MaxPlayers=60. Under AD-260 this is a Scale Readiness Gate, not an IMP-10 functional-completion blocker. | C1 |
| VS1-20 | diagnostics identify requestId/operationId/test seed without leaking secrets | C1 |

## Required evidence

Fast CI:

- pure envelope/schema tests;
- profile state/migration/lease fake tests;
- deterministic RNG tests;
- capture state-machine/property tests;
- exact-once finalization cut-point tests.

Studio/trusted evidence:

- join/rejoin;
- replication/projection;
- input parity;
- prompt/interaction hostile cases;
- streaming absence/reappearance;
- client Pending/reconciliation.

Staging evidence before calling persistence adapter production-ready:

- isolated STG DataStore acquire/save/retry/reconnect;
- no PROD namespace access.

## Completion rule

IMP-8 / VS-1 functional closure requires all C0/C1 rows except the specifically registered VS1-19 deferral to be backed by TA-15 evidence at the appropriate layer. [IMP-8 evidence](../implementation/IMP8_IMPLEMENTATION_EVIDENCE.md) records the functional results and owner-confirmed native gamepad result. Under AD-249/AD-260, IMP-8 is COMPLETE with deferred validation and later DEV phases may advance when their own functional gates pass. This is not an all-rows-PASS or performance-readiness verdict.

## Registered deferred validation

| Gate | State | Reason | Owner / deadline |
|---|---|---|---|
| VS1-19 (C1) | **DEFERRED — environment limitation** | Connected Studio/MCP cannot run 30-player L1 or supported real-client frame/memory measurement. Existing three five-second solo samples remain partial L0 evidence. | **Scale Readiness / release-growth gate under AD-260; not required for IMP-10 functional completion** |

The full controlled L0/L1 and real-client validation, TA-14 numeric guardrails and TA-15 measurement/repetition rules remain unchanged. Under AD-260 the evidence is required when MonsterVault is preparing for or operating at concurrency beyond its validated envelope, not to close IMP-10 functionally. Until then, local bounded-performance/security checks remain mandatory and VS1-19 must continue to be reported as DEFERRED. STG persistence readiness and full L0-L5 release validation remain separate release gates.

**VS-1 acceptance contract: LOCKED.**
