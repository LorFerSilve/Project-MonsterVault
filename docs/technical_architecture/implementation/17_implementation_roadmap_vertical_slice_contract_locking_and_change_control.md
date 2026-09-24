# TA-17 — Implementation Roadmap, Vertical Slice, Contract Locking, and Change Control

> **Status:** Implementation Locked — PASS
> **Date:** 2026-09-24
> **Authority:** Final toolchain, repository, module/service graph, runtime namespace, vertical slice, implementation order, verification, branch/release and change-control lock
> **Depends on:** GDS-17 PASS; TA-0..15 Architecture Complete; TA-16 Architecture Integration Complete — PASS

## 1. Purpose

TA-17 is the final pre-code dependency.

It converts the complete architecture into one concrete implementation handoff so later implementation work does not invent:

- source roots/layers;
- service ownership;
- transport/store/topic naming;
- toolchain versions;
- CI trust behavior;
- first vertical slice;
- dependency order;
- acceptance gates;
- change-control rules.

TA-17 may add non-gameplay repository/tooling scaffolding. Gameplay implementation opens only after TA-17 closes and the project gate is explicitly changed.

## 2. Final Toolchain

Implementation-locked pins:

| Tool | Pin | Role |
|---|---:|---|
| Roblox Studio | stable production channel | authoritative engine/runtime |
| Rokit | 1.2.0 | developer/CI tool manager |
| Rojo | 7.7.0 | filesystem <-> DataModel sync/build |
| luau-lsp | 1.70.0 | strict Roblox-aware analysis |
| StyLua | 2.5.2 | formatting |
| Selene | 0.31.0 | Roblox-aware lint |
| Lune | 0.10.5 | dev/test-only deterministic Luau runner |

No Wally/Pesde/runtime package manager is adopted at baseline.

No third-party runtime Luau package is approved.

Lune is tooling only; production code must not require Lune libraries.

## 3. Repository Lock

Authoritative roots remain:

```text
src/server
src/client
src/shared
tests/unit
tests/integration
tests/scenarios
tests/fixtures
scripts/ci
scripts/test
```

Rojo mapping is locked in `default.project.json`.

- filesystem is authoritative for first-party code;
- Studio is authoritative for engine behavior/world authoring;
- generated rbxl/rbxlx/sourcemap/test artifacts are not canonical source;
- local Rojo binds to 127.0.0.1 by default;
- Workspace streaming properties are locked to TA-14 baseline in project configuration.

## 4. Roblox DataModel Lock

```text
ReplicatedStorage
└─ MonsterVault
   ├─ Shared                  <- src/shared
   └─ Remotes
      └─ V1
         ├─ Command           RemoteEvent C2S
         ├─ Event             RemoteEvent S2C
         └─ UnreliableEvent   UnreliableRemoteEvent S2C only

ServerScriptService
└─ MonsterVaultServer         <- src/server

StarterPlayer
└─ StarterPlayerScripts
   └─ MonsterVaultClient      <- src/client

ServerStorage
└─ MonsterVault               <- server-only authored/runtime content boundary
```

Protocol generation is **V1 / protocolVersion = 1**.

Breaking remote-envelope/schema changes require V2 rather than silently changing V1 meaning.

## 5. Module / Service Lock

TA17_MODULE_SERVICE_GRAPH.md is authoritative.

Implementation uses:

- thin server/client composition roots;
- application coordinators for multi-domain transactions;
- domain services for semantic validation/mutation;
- infrastructure behind narrow interfaces;
- Roblox adapters at the edge;
- shared for public/pure contracts only.

No service locator, global gameplay database, feature-created remote or sideways domain-internal import is permitted.

## 6. Runtime Namespace Lock

TA17_RUNTIME_NAMESPACE_CONTRACT.md locks:

- remote route IDs and envelopes;
- DataStore names/key formats;
- MemoryStore/Messaging names;
- protocol/profile schema generations;
- operation/transaction identity rules;
- environment tags.

Unknown external Roblox universe/place/product IDs are not fabricated. They remain environment deployment inputs and cannot be source-code constants.

## 7. First Vertical Slice

The first end-to-end slice is:

> **VS-1 — Trusted Join -> One World Creature -> Capture -> Secure Ownership -> Rejoin**

The slice intentionally crosses the highest-risk foundations before broader feature work:

1. tool/test contract;
2. server/client composition;
3. profile readiness/lease;
4. V1 network handshake;
5. one authored world creature/runtime record;
6. capture intent/state machine;
7. server-owned deterministic Variant identity;
8. Provisional Capture / Transport Custody;
9. Secure Point finalization;
10. P2 durable ownership checkpoint;
11. authoritative client projection;
12. disconnect/rejoin reconciliation.

VS-1 does not include trading, commerce, global events or broad economy.

TA17_VERTICAL_SLICE_ACCEPTANCE_MATRIX.md is the acceptance authority.

## 8. Implementation Dependency Order

docs/implementation/IMPLEMENTATION_ROADMAP.md is authoritative.

Implementation advances only when the current phase's acceptance evidence is complete. Later domains may prepare documentation/fixtures, but may not bypass foundational dependencies.

## 9. Test / CI Lock

Baseline public-PR check:

> **CI / static-build**

It uses:

- GitHub-hosted Ubuntu 24.04;
- contents:read only;
- no repository/staging/production secrets;
- checkout pinned to immutable commit;
- setup-rokit pinned to immutable commit;
- Rokit 1.2.0 and rokit.toml;
- format/lint/build/sourcemap;
- luau-lsp analyze once Luau exists;
- Lune fast suite once runtime Luau exists.

The workflow deliberately fails if runtime Luau exists while `tests/runner.luau` is missing.

Trusted Studio/staging/performance gates remain TA-15 release requirements and cannot be replaced by the public PR lane.

## 10. Performance Reference Lock

All implementations inherit TA-14.

VS-1 must establish instrumentation for:

- server frame/script CPU;
- active runtime entities;
- remote message/byte rates;
- serialized profile size;
- DataStore retries/budget/latency;
- client frame/memory where measurable.

VS-1 acceptance requires no hard guardrail violation under L0 and L1 controlled tests.

Full release requires TA-15 L0-L5 evidence.

## 11. Environment Lock

Logical environment identifiers:

- `DEV`
- `STG`
- `PROD`

These tags are immutable for a server lifetime.

Roblox universe/place IDs are deployment configuration, not hard-coded source constants.

Until real external IDs are configured:

- DEV local implementation may proceed;
- STG/PROD publish automation remains disabled;
- no placeholder numeric IDs are permitted.

## 12. Branch / PR Lock

Baseline:

- `main` is the integration branch;
- implementation work occurs on short-lived branches;
- no ordinary direct feature push to main;
- PR required for implementation changes;
- `CI / static-build` required once the TA-17 workflow lands;
- later C0/C1 required checks are added as their harnesses become executable;
- untrusted fork code never receives staging/production secrets or persistent self-hosted compute.

Recommended branch forms:

- `imp/<phase>-<scope>`
- `fix/<scope>`
- `docs/<scope>`

TA-17 does not require one approval at baseline because the repository currently has a single-maintainer workflow; review requirements may be increased without changing gameplay architecture.

## 13. Merge / Release Lock

Implementation PRs use squash merge by default so one reviewed unit maps to one mainline change.

Release candidates require:

- all applicable C0/C1 TA-15 evidence;
- no hard TA-14 budget violation;
- staging validation for affected external adapters;
- current Roblox policy/API revalidation for affected sensitive systems;
- no unresolved critical defect.

Publishing credentials are environment-scoped and never available to ordinary PRs.

## 14. Change Control

### Implementation-local change

May proceed normally when it preserves:

- GDS semantics;
- TA authority;
- module/dependency direction;
- protocol compatibility;
- persistence schema compatibility;
- performance/security gates.

### Material architecture change

Requires reopening the owning TA when it changes:

- durable authority;
- transaction/failure semantics;
- remote trust model;
- profile/store topology;
- runtime lifecycle;
- performance hard guardrail;
- CI/security trust boundary.

### Player-facing semantic change

Returns to the owning GDS phase before architecture/implementation changes.

### Protocol/schema change

- backward-compatible addition may remain V1/schema v1 if old readers remain valid;
- breaking protocol change -> protocol generation increment;
- persistent structural change -> explicit schema migration/version increment;
- never reinterpret old durable values under a new incompatible meaning.

## 15. Implementation Definition of Done

A feature/phase is done only when:

- code follows locked graph;
- strict analysis/lint/format/build pass;
- deterministic tests exist at required layer;
- negative/fault tests exist where TA-15 requires;
- no new secrets/generated artifacts are committed;
- traceability references are updated;
- docs/config are updated when public contract changes;
- performance/security evidence is attached where required.

## 16. Architecture Reopen Rule

Implementation pressure is not permission to weaken the architecture.

If the locked design cannot be implemented safely or efficiently:

1. stop the affected implementation;
2. document the concrete conflict/evidence;
3. reopen the owning TA/GDS contract;
4. update decision/traceability;
5. only then resume implementation.

## 17. Gate Verdict

All TA-17 lock categories are concrete:

- toolchain: LOCKED;
- repository/Rojo scaffold: LOCKED;
- module/service graph: LOCKED;
- runtime namespaces: LOCKED;
- first vertical slice: LOCKED;
- implementation order: LOCKED;
- CI/verification baseline: LOCKED;
- branch/release workflow: LOCKED;
- change control: LOCKED.

**TA-17 IMPLEMENTATION CONTRACT: PASS.**
