# MonsterVault Implementation Roadmap

> **Status:** IMP-8 COMPLETE with registered deferred validation; IMP-9 OPEN for DEV implementation
> **Locked by:** TA-17
> **Rule:** Dependency-driven; do not skip phases merely because later UI/content is easier to demo.

## IMP-1 — Contracts and Test Harness

Deliver:

- shared protocol/result/ID contracts;
- tests/runner.luau using Lune;
- deterministic test registration/manifest;
- clock/RNG interfaces and fakes;
- architecture dependency check script.

Gate:

- CI / static-build executes fast tests when runtime Luau appears;
- no gameplay behavior yet.

## IMP-2 — Composition and Diagnostics

Deliver:

- ServerMain/ServerComposition;
- ClientMain/ClientComposition;
- startup validation;
- structured diagnostics;
- shutdown coordinator;
- performance counters.

Gate:

- deterministic bootstrap order;
- duplicate registrations fail;
- no import-time feature startup.

## IMP-3 — Profile Session Foundation

Deliver:

- profile schema v1;
- DataStore repository interface + fake;
- Roblox DataStore adapter;
- lease/load/readiness states;
- migration/validation;
- single writer queue;
- checkpoint/retry/autosave/shutdown logic.

Gate:

- TA-4/15 persistence C0 suites.

## IMP-4 — V1 Networking and Projection

Deliver:

- Command/Event/UnreliableEvent gateways;
- route registry;
- envelope/schema/rate/replay validation;
- Session.ClientHello / RequestResync;
- Command.Result;
- ProjectionStore/Snapshot/Delta.

Gate:

- hostile-client negative tests;
- readiness cannot be client-granted.

## IMP-5 — Minimal Runtime World

Deliver:

- runtime entity lifecycle;
- one deterministic authored fixture creature;
- spatial/interaction registry;
- world scheduler minimal path;
- streaming-safe projection.

Gate:

- no per-entity heartbeat/task pattern;
- stale callbacks cannot resurrect destroyed runtime state.

## IMP-6 — Capture and Durable Ownership

Deliver:

- capture state machine;
- injected server RNG;
- stable Variant identity;
- provisional/custody states;
- secure finalization application use case;
- exact CreatureInstanceId profile record.

Gate:

- exact-once/fault/retry tests;
- no reroll;
- no client authority.

## IMP-7 — Capture Client Experience

Deliver:

- semantic cross-input capture controller;
- Pending/OutcomeUnknown reconciliation;
- minimal accessible capture UI;
- notification/focus integration.

Gate:

- device/input/accessibility C1 evidence.

## IMP-8 — VS-1 Closure

Run TA17_VERTICAL_SLICE_ACCEPTANCE_MATRIX.md.

VS-1 functional acceptance must be complete before broad feature expansion, with the sole registered performance timing exception [AD-249](../technical_architecture/ARCHITECTURE_DECISIONS.md#ad-249--defer-vs1-19-to-the-imp-10-completion-gate).

**Status (2026-10-01): COMPLETE with deferred validation.** All functional gates are closed, including owner-confirmed native gamepad parity and the trusted VS1-20 Studio capture log. **VS1-19 (C1) is DEFERRED — environment limitation**, not PASS. Its complete L0/L1 and supported real-client performance validation is mandatory **before IMP-10 COMPLETE**. See [IMP-8 evidence](IMP8_IMPLEMENTATION_EVIDENCE.md) and [the amended acceptance matrix](../technical_architecture/TA17_VERTICAL_SLICE_ACCEPTANCE_MATRIX.md).

## IMP-9 — Vault / Economy / Progression

**Status: OPEN for DEV implementation; capacity, reconciliation, Overflow-Held resolution, assignments, production/offline settlement, Energy/Production Claim and the minimal progression quote/purchase/unlock chain implemented and validated.** Upstream IMP-8 is formally complete under AD-249. [IMP-9 evidence](IMP9_IMPLEMENTATION_EVIDENCE.md) records the current implementation and remaining gates.

Collection capacity, assignments, production, offline settlement, Energy and progression transactions.

Completed first dependency: Vault-owned capacity status consumed by capture admission and P2 placement; invalid persisted capacity fails protected load, and capacity races preserve exact Overflow-Held ownership. Existing DEV fixture balance is retained.

Completed next dependency (AD-250): separately identifiable server-authorized capacity components; explicit versioned legacy/sequence migration before Ready; deterministic ownership-preserving P2 reconciliation; native owner-selected exact-instance Resolve Overflow with bounded projection and uncertain-write recovery. Commercial/temporary readers remain unbound in DEV and cannot grant capacity from persisted client-like claims; their real integrations belong to their owning later systems.

Completed current dependency (AD-251): server-owned Display/Production assignments, strict revision/ownership/role/slot validation, integer buffer and historical epochs, monotonic online settlement, bounded clean-offline/crash recovery and coherent save/leave/rejoin/uncertain-write recovery. Capacity loss settles before clearing roles; grants remain protected while unbound. Native UI/gateway/DEV DataStore/fresh Play server and negative/race evidence is linked from IMP-9 evidence.

Completed current dependency (AD-252): versioned server-owned integer Energy wallet, one bound reason-coded transaction primitive and exact-once Production Claim through the existing P2 writer. Settlement, whole-unit wallet transfer, buffer remainder and revision-bound claim receipt commit together. Duplicate/retry/reconnect, both uncertain-write cut points, client Class A resync, Busy/races, numeric ceilings, unbound grants and fresh-server save/rejoin are validated. Capacity, assignments, exact ownership and Overflow-Held semantics are preserved.

Completed current dependency (AD-253): one server quote per session with opaque GUID, 60-second monotonic expiry, price/config epoch, original profile revision, current tier and legitimate Species Discovery prerequisite. Explicit confirm purchases the existing +6 Collection Capacity tier for 25 DEV Energy. Debit, earned tier, permanent unlock receipt and operation marker commit together through P2. Stale/tampered/cross-session quotes, insufficient funds and invalid effects fail without mutation. Duplicate/retry/reconnect/unknown-result recovery survives quote expiry and audit eviction. Native quote/confirm GUI, real DEV before/after-write failures, claim/purchase races and a fresh shipped composition pass; exact ownership, Held state, roles, output and discovery are preserved.

Next dependency: bind the remaining TA-8 progression definitions/effects and audit the complete IMP-9 gate matrix: additional Vault slot/buffer/offline upgrades, Capture Capability and Access Unlock prerequisites. These have no enabled purchase definition in this DEV slice; world topology remains TA-9 ownership. The reusable transaction is closed for its one authored capacity target, not the entire progression catalog. IMP-9 cannot be COMPLETE, and IMP-10 cannot start, until its full gates pass. Actual one-time/event/commercial/temporary reward integrations and deferred grants remain protected until their owning systems bind authoritative sources. AD-249 / VS1-19 remains mandatory before IMP-10 COMPLETE.

## IMP-10 — World Scaling

Full biome/content registries, spawn scheduling, travel, mastery/hazards and TA-14 scaling.

Mandatory completion gate inherited from IMP-8 / AD-249:

- **VS1-19 (C1): DEFERRED — environment limitation** until the full TA-14/TA-15 controlled L0/L1 plus supported real-client frame/memory validation is executed and passes for the relevant World Scaling candidate build.
- L1 is **30 players at configured MaxPlayers=60**; the numeric guardrails, device measurements and repetition rules remain unchanged. Existing solo Studio samples are partial L0 evidence and cannot satisfy this gate.
- **IMP-10 cannot be COMPLETE and the roadmap cannot advance beyond IMP-10** while VS1-19 is deferred, missing, failed or incomplete. Production release remains separately subject to full TA-15/TA-14 gates.

## IMP-11 — Social and Events

Party/Ping/challenge/visitor plus global event occurrence/contribution/rewards and cross-server hints.

## IMP-12 — Trading

Trade session/revision/reservations, durable journal, transaction-fenced participant apply/recovery.

## IMP-13 — Commerce

Product definitions/bindings, Game Pass reconciliation, Developer Product receipt journal, Starter grant and commercial UI.

## IMP-14 — Live Ops / Analytics / Experimentation

Telemetry registry/adapters, C2 config snapshots, flags, experiment assignment/exposure and privileged audit boundary.

## IMP-15 — Release Hardening

Full TA-15 V0-V10 evidence, TA-14 L0-L5, security/fault sweeps, staging promotion, current policy/API revalidation and release checklist.

## Change rule

A phase may be split into smaller PRs. It may not bypass upstream gates or move authority to a more convenient layer.

AD-249 is an explicitly owner-authorized TA-17 amendment to validation timing, with a named gate, owner and hard deadline. It grants no general permission to defer other acceptance rows.
