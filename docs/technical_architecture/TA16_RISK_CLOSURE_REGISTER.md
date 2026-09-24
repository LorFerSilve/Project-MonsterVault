# TA-16 Architecture Risk Closure Register

> **Status:** PASS  
> **Date:** 2026-09-24  
> **Purpose:** Close the TA-0 R1..R12 risk families at the architecture layer before TA-17.

## Closure Semantics

**Closed at architecture layer** means:

- ownership is explicit;
- safe/fail-closed behavior is defined;
- implementation may proceed without inventing architecture;
- TA-15 defines evidence that must later prove the implementation.

It does **not** mean runtime correctness has already been executed/proven before implementation exists.

| ID | Risk family | Primary closure | Supporting closure | TA-15 evidence path | TA-16 status |
|---|---|---|---|---|---|
| R1 | Persistence/data loss | TA-4 session lease, load/migrate/validate, writer queue, recovery | TA-8/10/11 transaction integration | persistence fault/migration/shutdown suites | CLOSED |
| R2 | Duplication/idempotency | TA-4 durable operation identity/dedupe | TA-7/8/10/11 exact-once transaction contracts | duplicate/retry/cut-point suites | CLOSED |
| R3 | Client/remote exploitation | TA-3 trust/envelope/schema/rate/replay authorization | TA-6/7/10/11/12 | hostile-client/prompt/physics suites | CLOSED |
| R4 | Race/concurrency | domain-owned serialized transitions + TA-4 writer authority | TA-7 claim, TA-8 wallet/capacity, TA-10 trade/event, TA-11 commerce | concurrent/conflicting state-machine tests | CLOSED |
| R5 | Cross-server consistency | TA-10 occurrence/message/transaction architecture | TA-4/9/13/14 | duplicate/miss/reorder/outage service tests | CLOSED |
| R6 | Purchase/entitlement recovery | TA-11 ownership reconciliation/PurchaseId journal | TA-4/8 | receipt/pass retry/crash suites | CLOSED |
| R7 | Performance/scalability | TA-14 numeric budgets and degradation states | TA-3..13 bounded architecture | L0-L5 performance/load evidence | CLOSED |
| R8 | Roblox API/policy drift | TA-1 dated tool/platform baseline | TA-11/12/13/14/15 dated snapshots | TA-17 revalidation + staging/engine evidence | CLOSED |
| R9 | Configuration/live-ops safety | TA-13 C2 validation/snapshots/rollback/audit | TA-5/9/10 | config/experiment/operator failure suites | CLOSED |
| R10 | Analytics/experiment integrity | TA-13 semantic telemetry/assignment/exposure/invariants | TA-14 bounded overhead | deterministic assignment + invariant/security tests | CLOSED |
| R11 | Dependency/module coupling | TA-2 permitted dependency/ownership/bootstrap matrix | all domain TAs preserve public-contract/application boundaries | static dependency/cycle checks | CLOSED |
| R12 | Test/observability gaps | TA-15 verification taxonomy/criticality/diagnostics/CI | TA-13 observability + TA-14 metrics | mandatory quality-gate matrix | CLOSED |

## Residual Implementation Risk

The implementation will still be capable of containing bugs.

TA-16 therefore distinguishes:

- **architecture risk closure** — complete;
- **implementation verification** — required by TA-15 after implementation exists;
- **release acceptance** — cannot pass on architecture documentation alone.

Unowned architecture-risk families: **0**.

Architecture-risk families still Open/Transferred: **0**.

**TA-16 risk closure result: PASS.**
