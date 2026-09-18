# TA-6 Decision Index

> **Phase:** TA-6 — Runtime Entity, Player, Creature, and World Lifecycle  
> **Status:** Accepted

## TA6-D01 — Server Runtime Records Are Authoritative; Roblox Instances Are Projections

**Decision:** Dynamic gameplay entities live in server-owned runtime records. Workspace Models/Parts represent those records but do not own semantic or persistent state.

---

## TA6-D02 — Player Session and Character Presence Are Separate Lifecycles

**Decision:** A Player Session can outlive multiple avatar Character generations. Character failure/reset/removal never implies profile destruction.

---

## TA6-D03 — Runtime Entities Use a Server Registry and Explicit Lifecycle

**Decision:** Dynamic entities move through Allocated -> Initializing -> Registered -> Materializing -> Active -> Quiescing -> Terminating -> Destroyed and have a server-side runtimeRevision.

---

## TA6-D04 — Character Presence Has a Generation Identity

**Decision:** Every replacement Character invalidates older generation-scoped work so stale callbacks/commands cannot affect a new avatar.

---

## TA6-D05 — World Creature Identity Remains Stable Across Its Session Lifetime

**Decision:** A surviving World Creature retains CreatureInstanceId and Variant Identity through failed/released acquisition. Genuine destruction creates room for a new independent instance rather than rerolling the old one.

---

## TA6-D06 — Active Acquisition Protects World Creatures from Ordinary Idle Despawn

**Decision:** Engagement Claim, Capture Attempt, Provisional Capture and Transport Custody lifecycles cannot be terminated merely by the ordinary idle encounter timer.

---

## TA6-D07 — Secured Ownership Reuses the Existing CreatureInstanceId

**Decision:** Durable ownership finalization ends the public world role without minting a second owned creature identity.

---

## TA6-D08 — Owned Creature Projection Destruction Never Equals Release

**Decision:** Active/display/showcase models are disposable projections of persistent Creature state. Their materialization or destruction does not itself change collection ownership.

---

## TA6-D09 — Streaming State Is Presentation State, Not Entity State

**Decision:** Client stream-in/out of Workspace content never creates, destroys, secures or loses authoritative entities.

---

## TA6-D10 — Physics Network Ownership Is Distinct from Gameplay Ownership

**Decision:** A client simulating unanchored physics gains no creature, claim, reward or persistent authority. Critical interactions are server-validated.

---

## TA6-D11 — Every Runtime Entity Has Exactly One Cleanup Owner

**Decision:** Entity lifecycle owners clean connections, tasks/timers, projections, registry bindings and long-lived references. Cleanup is idempotent.

---

## TA6-D12 — Delayed Work Revalidates Entity/Character Generation

**Decision:** Async callbacks re-resolve authoritative state by ID/revision/generation and become no-ops when stale.

---

## TA6-D13 — Runtime Population Accounting Uses Server Records

**Decision:** Client visibility/streaming does not affect server population counts. Acquisition-protected entities remain alive until their owning lifecycle resolves.

---

## TA6-D14 — Close TA-6 and Advance to TA-7

**Decision:** TA-6 is Architecture Complete — PASS with 190/190 scenarios and zero blocking questions. TA-7 becomes NEXT; gameplay implementation remains blocked.
