# TA-2 Decision Index

> **Phase:** TA-2 — Repository Layout, Module Boundaries, Dependency Direction, and Bootstrapping  
> **Status:** Accepted

## TA2-D01 — Use a Modular Monolith

**Decision:** MonsterVault remains one Roblox runtime/deployable with strongly owned in-process modules/domains rather than premature microservice-style decomposition.

---

## TA2-D02 — Lock Three First-Party Runtime Source Roots

**Decision:**

- `src/server`;
- `src/client`;
- `src/shared`.

They map respectively to ServerScriptService, StarterPlayerScripts and ReplicatedStorage under MonsterVault-owned roots.

---

## TA2-D03 — Shared Is Public/Hostile-Client-Visible

**Decision:** Anything in `shared` is assumed inspectable by clients and may not contain server secrets, hidden authority logic or private random/anti-abuse state.

---

## TA2-D04 — Server Uses Bootstrap, Application, Domain, Infrastructure, and Adapter Boundaries

**Decision:** Bootstrap composes; application coordinates cross-domain use cases; domains own gameplay rules/state; infrastructure supplies mechanisms; adapters translate platform boundaries.

---

## TA2-D05 — Cross-Domain Private-State Mutation Is Forbidden

**Decision:** Domains interact through narrow public contracts or application-level orchestration, never deep imports into another domain's internals.

---

## TA2-D06 — Modules Have No Runtime Side Effects on Require

**Decision:** Long-lived connections, loops, remotes and irreversible actions begin only through explicit lifecycle/bootstrap calls.

---

## TA2-D07 — Runtime Components Use an Explicit Lifecycle

**Decision:** Conceptual lifecycle is Construct -> Validate -> Start -> Ready -> Stop/Shutdown.

Exact API names are locked later.

---

## TA2-D08 — Use Explicit Construction Injection, Not a Global Service Locator

**Decision:** Dependencies are visible at composition time. `_G`, mutable global `shared`, or arbitrary service-location are prohibited.

---

## TA2-D09 — One Ordinary Server and Client Bootstrap Entrypoint

**Decision:** Feature modules do not auto-start as independent scripts. Entrypoints delegate to composition roots.

---

## TA2-D10 — Platform Services Are Centralized by Technical Concern

**Decision:** DataStore, Marketplace, cross-server, telemetry and other platform APIs are accessed through their owning infrastructure/adapters, not scattered through feature code.

---

## TA2-D11 — Actual Source Scaffold Is Deferred to TA-17

**Decision:** TA-2 locks the exact target layout and mapping architecturally but does not create gameplay/source scaffolding while implementation is blocked.

---

## TA2-D12 — Close TA-2 and Advance to TA-3

**Decision:** TA-2 is Architecture Complete — PASS with zero blocking questions and 110/110 scenarios passing. TA-3 becomes NEXT; implementation remains blocked.
