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
| TA-14 | instrumentation from IMP-2 onward; hardening in every phase; full L0-L5 IMP-15 |
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
| performance evidence | GDS-1/14/16 | TA-14/15 | IMP-2..8 |

## Traceability rule

Every implementation PR names:

- implementation phase;
- affected GDS/TA contracts;
- C0/C1 tests added/updated;
- any public protocol/schema/config changes.

Orphan implementation behavior is prohibited.

**TA-17 implementation traceability: PASS.**
