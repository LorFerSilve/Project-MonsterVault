# TA-16 Implementation Readiness Matrix

> **Status:** PASS FOR TA-17  
> **Date:** 2026-09-24  
> **Purpose:** Determine whether each implementation concern has enough architecture to be concretely locked in TA-17.

| Implementation concern | Architecture source | TA-16 readiness | TA-17 lock still required |
|---|---|---|---|
| semantic authority | GDS-17 / TA-0 | READY | preserve traceability/change control |
| environment topology | TA-1 | READY | final pins/config/environment identifiers |
| source roots/layers | TA-2 | READY | exact modules/files/dependency graph |
| bootstrap lifecycle | TA-2 | READY | exact composition roots/start order implementation |
| networking transport | TA-3 | READY | route registry/names/schemas/instances |
| rate/replay/security | TA-3/14/15 | READY | concrete limiter constants/config/tests |
| profile/session persistence | TA-4 | READY | store/key/schema field names/repository APIs |
| migrations/recovery | TA-4/15 | READY | fixture/runner implementation |
| semantic IDs/registries | TA-5 | READY | concrete registry files/schema types |
| runtime entity lifecycle | TA-6 | READY | concrete runtime record/module APIs |
| capture/finalization | TA-7 | READY | use-case/module implementation order |
| RNG abstraction | TA-7/15 | READY | concrete interface/seed test adapters |
| Vault/economy/progression | TA-8 | READY | concrete domain schemas/modules/config |
| world/spawn/streaming | TA-9/14 | READY | map authoring bindings/scheduler modules |
| social/events | TA-10 | READY | concrete services/remotes/topics |
| trade transaction | TA-10 | READY | journal stores/schema/coordinator modules |
| monetization/receipts | TA-11 | READY | product bindings/receipt stores/adapters |
| client store/presentation | TA-12 | READY | controllers/views/input action instances |
| accessibility | TA-12/15 | READY | concrete settings/UI test fixtures |
| telemetry | TA-13 | READY | event registry/adapters/queue modules |
| C2 config/experiments | TA-13 | READY | config definitions/operator workflow |
| performance budgets | TA-14 | READY | instrumentation/benchmark configuration |
| verification/CI | TA-15 | READY | runners/workflow YAML/action SHAs/checks |
| security validation | TA-3/15 | READY | concrete test corpus/harness |
| first vertical slice | all | ARCHITECTURALLY READY | select exact slice and acceptance matrix |
| implementation sequence | all | ARCHITECTURALLY READY | lock dependency order |
| release/change control | TA-0/15 | READY | exact branches/rulesets/release workflow |

## Readiness Rule

`READY` does not mean the concrete implementation artifact already exists. It means TA-17 can create/lock that artifact without inventing a missing semantic, authority, safety or failure rule.

Architecture concerns requiring redesign before TA-17: **0**.

Implementation concerns lacking an owner: **0**.

## Suggested TA-17 Selection Principle

TA-16 does not select the vertical slice, but TA-17 must select a slice that crosses the highest-risk foundational boundaries early:

- bootstrap/composition;
- session/profile readiness;
- networking;
- one runtime world entity;
- capture intent and deterministic outcome path;
- one durable exact-once ownership/economy result;
- authoritative client projection;
- verification/CI evidence.

The exact player-facing slice and acceptance criteria remain TA-17 decisions.

**TA-16 IMPLEMENTATION READINESS: PASS FOR TA-17.**
