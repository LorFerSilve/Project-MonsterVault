# TA-3 Decision Index

> **Phase:** TA-3 — Networking, Server Authority, Remote Contracts, and Exploit Boundaries  
> **Status:** Accepted

## TA3-D01 — Use a Small Central Versioned Transport Surface

**Decision:** The baseline transport registry is conceptually `ReplicatedStorage/MonsterVault/Remotes/V1` with Command, Event and optional UnreliableEvent transports.

---

## TA3-D02 — Client Commands Express Intent Only

**Decision:** The client never submits authoritative ownership, currency, progression, rarity, event, trade, commercial or moderation results.

---

## TA3-D03 — Reliable RemoteEvents Are the Baseline Protocol

**Decision:** Client commands and server results/projections use asynchronous reliable RemoteEvents.

---

## TA3-D04 — UnreliableRemoteEvent Is Presentation-Only

**Decision:** Unreliable transport may carry only data whose loss, duplication or reordering cannot change gameplay correctness.

No baseline client-to-server unreliable gameplay input is authorized.

---

## TA3-D05 — No RemoteFunctions in the Baseline

**Decision:** MonsterVault uses asynchronous request/result events instead of yielding client/server calls.

Server `InvokeClient` is prohibited.

---

## TA3-D06 — Every Client Command Passes a Standard Validation Pipeline

**Decision:** Envelope -> protocol/route -> rate -> session readiness -> schema -> permission/context -> authoritative handler -> safe result/telemetry.

---

## TA3-D07 — Payloads Are Exact and Bounded

**Decision:** Strings, tables, numbers and IDs have route-specific bounds; arbitrary key bags and arbitrary Instance/path mutation are prohibited.

---

## TA3-D08 — Network Request Identity Is Not Durable Gameplay Identity

**Decision:** Client requestId is for correlation/session dedupe. Server-owned downstream operation IDs provide durable exact-once authority.

---

## TA3-D09 — Timeouts Produce Unknown Outcome, Not Assumed Failure

**Decision:** Irreversible operations reconcile against authoritative state. Any allowed automatic retry reuses the same requestId.

---

## TA3-D10 — Rate Limiting Is Hierarchical and Server-Enforced

**Decision:** Per-player global and per-route weighted budgets are mandatory. Exact numbers are TA-14 tuneables.

---

## TA3-D11 — Client Physics and Prompt Activations Are Untrusted Inputs

**Decision:** Position/timing/context-dependent critical actions are revalidated server-side even when triggered by Roblox interaction/physics systems.

---

## TA3-D12 — Server Is a Gatekeeper for Cross-Client Communication

**Decision:** No blind relay. Structured social/event/presentation forwarding validates sender, target, eligibility, safety and payload before delivery.

---

## TA3-D13 — Client Prediction Is Reversible Presentation Only

**Decision:** Ownership, currency, unlocks, trade commits, purchases and rewards are never client-predicted as authoritative facts.

---

## TA3-D14 — Close TA-3 and Advance to TA-4

**Decision:** TA-3 is Architecture Complete — PASS with 140/140 scenarios passing and zero blocking questions. TA-4 becomes NEXT; gameplay implementation remains blocked.
