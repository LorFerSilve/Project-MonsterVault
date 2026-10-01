# TA-17 GDS / TA / Implementation Traceability

> **Status:** PASS
> **Date:** 2026-09-24

## Phase routing

| Authority | Implementation destination |
|---|---|
| GDS-0..17 | all implementation phases preserve semantic authority; changes route back to owner |
| TA-0 | change control, traceability, implementation gate |
| TA-1 | rokit.toml, Rojo/Studio workflow, environment separation |
| TA-2 | physical source roots, dependency graph, composition roots |
| TA-3 | V1 remotes/routes/envelopes, NetworkingGateway, rate/replay/schema checks |
| TA-4 | IMP-3 profile/session repository, schema v1, lease/writer/recovery |
| TA-5 | shared/server semantic registries and immutable IDs |
| TA-6 | IMP-5 runtime entity/lifecycle/cleanup |
| TA-7 | IMP-6 capture/RNG/Variant/finalization |
| TA-8 | IMP-9 Vault/economy/progression |
| TA-9 | IMP-5 minimal world then IMP-10 scaling |
| TA-10 | IMP-11 social/events and IMP-12 trading |
| TA-11 | IMP-13 commerce/receipts/entitlements |
| TA-12 | IMP-4 projection foundation + IMP-7 client UX + later feature UI |
| TA-13 | IMP-14 telemetry/config/experiments/live ops |
| TA-14 | instrumentation from IMP-2 onward; hardening in every phase; deferred VS1-19 mandatory before IMP-10 COMPLETE under AD-249; full L0-L5 IMP-15 |
| TA-15 | tests/CI from IMP-1 onward; C0/C1 evidence gates |
| TA-16 | no reopened blocker; readiness constraints carried into TA-17 |
| TA-17 | exact implementation contract and dependency order |

## VS-1 traceability

| VS-1 component | GDS | TA | Implementation phase |
|---|---|---|---|
| trusted join / Protected Load Failure | GDS-2 | TA-4/12/15 | IMP-3/4/7 |
| one World Creature | GDS-4/5/9 | TA-5/6/9 | IMP-5 |
| interaction intent | GDS-3/5 | TA-3/6/12 | IMP-4/5/7 |
| capture state | GDS-5 | TA-6/7 | IMP-6 |
| Variant identity | GDS-6 | TA-5/7 | IMP-6 |
| provisional/custody | GDS-5 | TA-6/7 | IMP-6 |
| secure ownership finalization | GDS-4/5 | TA-4/7 | IMP-6 |
| exact CreatureInstanceId persistence | GDS-4 | TA-4/5/7 | IMP-3/6 |
| client authoritative projection | GDS-14 | TA-3/12 | IMP-4/7 |
| reconnect reconciliation | GDS-2/4 | TA-4/12 | IMP-3/4/7 |
| security/fault evidence | GDS-15 | TA-3/15 | IMP-1..8 |
| performance evidence | GDS-1/14/16 | TA-14/15/17 | IMP-2..8 partial L0; VS1-19 DEFERRED to before IMP-10 COMPLETE (AD-249) |

## Accepted change-control routing

| Decision / gate | Evidence and current state | Completion dependency |
|---|---|---|
| AD-249 / VS1-19 (C1) | [Accepted decision](ARCHITECTURE_DECISIONS.md#ad-249--defer-vs1-19-to-the-imp-10-completion-gate); **DEFERRED — environment limitation**. [IMP-8 evidence](../implementation/IMP8_IMPLEMENTATION_EVIDENCE.md) retains three solo Studio samples and measurement limits. No L1/real-client PASS is claimed. | IMP-8 COMPLETE with deferred validation permits IMP-9 OPEN; full 30-player L1 at MaxPlayers=60 plus supported real-client frame/memory evidence is mandatory **before IMP-10 COMPLETE**. |

This timing change preserves the TA-14 numeric and TA-15 evidence contracts. All other IMP-8 dependencies are closed; [the roadmap](../implementation/IMPLEMENTATION_ROADMAP.md) carries the hard gate into IMP-10's definition of done.

## Traceability rule

IMP-9 dependency traceability (earlier rows retain their original handoff scope):

| Contract | Implementation / evidence | Remaining dependency |
|---|---|---|
| GDS-4/5/7; TA-4/7/8 | VaultService capacity policy, CaptureFinalizationUseCase injection and protected V1 load validation; T15.vault.capacity.instanceAccounting / protectedLoad / captureAuthority; [IMP-9 evidence](../implementation/IMP9_IMPLEMENTATION_EVIDENCE.md). | Foundation PASS; IMP-9 stays OPEN for assignments, settlement, Energy and progression before IMP-10. |
| GDS-4/7/8; TA-4/7/8 | AD-250 explicit capacity migration, authorized components, deterministic non-destructive reconciliation and exact-instance P2 resolution; registered T15.vault components/reconcile/resolution/projection/client tests and native Studio DEV rejoin evidence. | Selected capacity/resolution dependency PASS. Bind actual production settlement before using production-bearing profiles; external source verification/grants remain with their owning systems. |
| GDS-7/14; TA-3/12/15/17 | AD-250 Vault.ResolveOverflow Class C allowlist/schema, bounded owner-only VaultProjectionV1, native selectable resolution UI, existing Command/Event rate/replay/Ready gates. Real mouse clicks traverse the shipped gateway and persist exactly once. | Existing wire generation/remotes remain V1. Full phase/release performance gates are unchanged. |
| GDS-7/8; TA-4/8/15/17 | AD-251/252 assignment/production settlement and Energy/Production Claim; epoch/clock/uncertain-write tests, native GUI, DEV DataStore and fresh-server evidence. | Selected dependencies PASS; external grants remain protected until their owners bind authority. |
| GDS-8; TA-3/4/8/12/15/17 | AD-253 opaque server quote, strict PurchaseUnlock, atomic signed Energy debit/earned tier/permanent receipt, active Discovery gate and explicit confirmation/readback; eight T15.progression.purchase C0 tests, real DEV cut points, mouse confirmation and fresh shipped composition in [IMP-9 evidence](../implementation/IMP9_IMPLEMENTATION_EVIDENCE.md). | Minimal capacity target PASS. Remaining Vault/Capture Capability/Access definitions and full TA-8 gate audit remain open; IMP-10 has not started. |
| GDS-5/7/8/9; TA-3/4/7/8/9/12/15/17 | AD-254 remaining Vault tiers, settlement-before-effect, persistent bounded Capture Capability and Access mastery/prior-unlock consumer; six additional T15.progression.catalog C0 suites, forty current native C0 checks, real DEV GUI/cut points/rejoin and [full gate audit](../implementation/IMP9_GATE_AUDIT.md). | IMP-9 COMPLETE. IMP-10 may OPEN; actual mastery/world actions belong there. External grants/deferred transfer stay protected until their respective owners bind. VS1-19 remains mandatory before IMP-10 COMPLETE. |

Every implementation PR names:

- implementation phase;
- affected GDS/TA contracts;
- C0/C1 tests added/updated;
- any public protocol/schema/config changes.

Orphan implementation behavior is prohibited.

**TA-17 implementation traceability: PASS.**
