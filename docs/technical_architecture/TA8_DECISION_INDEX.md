# TA-8 Decision Index

> **Phase:** TA-8 — Vault, Economy, Progression, Inventory, and Offline Accrual  
> **Status:** Accepted

## TA8-D01 — Collection, Vault, and Economy Live in the TA-4 Player Profile Aggregate

**Decision:** Secured collection placement, Vault upgrades/assignments, Production Buffer, Energy and progression state share the one-profile atomic authority.

---

## TA8-D02 — Energy Uses a Bounded Whole-Integer Wallet

**Decision:** Energy is stored as integer units with a hard TA-8 safety ceiling of 1,000,000,000,000 Energy.

---

## TA8-D03 — Production Uses Integer Fixed-Point Milli-Energy

**Decision:** Passive production is represented at 1/1000 Energy precision while player-facing Energy remains whole units.

---

## TA8-D04 — Passive Production Is Settled from Elapsed Time, Not Simulated Per Tick

**Decision:** Production accrues at explicit state/checkpoint/claim boundaries using validated elapsed seconds and assignment rates.

---

## TA8-D05 — TA-8 Uses Persisted Unix Boundaries and a Monotonic Live Server Clock

**Decision:** Cross-session state uses server-observed Unix timestamps; live elapsed timing uses a monotonic server clock abstraction. Client clocks are untrusted.

---

## TA8-D06 — Production Assignment Changes Are P2

**Decision:** Assignment changes settle prior accrual and persist the new assignment before final acknowledgment because they govern future/offline value.

---

## TA8-D07 — Offline Production Uses One Continuous Bounded Absence Window

**Decision:** A clean leave persists an offline boundary. Reconnect/server-hop does not restart the same absence window.

---

## TA8-D08 — Unclean Session Recovery Gets Only a Bounded Crash Allowance

**Decision:** When exact crash time is unknowable, settlement is capped by Offline Window plus a TA-14/17-bounded allowance tied to maximum uncheckpointed active time.

---

## TA8-D09 — Production Rate Changes Use Versioned Effective-Time Epochs

**Decision:** Offline/online settlement crossing a rate change is piecewise and prospective; historical settled output is never rewritten.

---

## TA8-D10 — Capacity Reconciliation Is Deterministic and Non-Destructive

**Decision:** Capacity decreases clear invalid roles and move deterministic exact instances into Overflow-Held. No automatic ordering uses rarity/spend/value.

---

## TA8-D11 — Production Claim Is One Atomic Buffer-to-Wallet P2 Operation

**Decision:** Whole Energy moves from fixed-point Production Buffer to Energy Wallet exactly once; untransferable remainder stays buffered.

---

## TA8-D12 — One-Time Wallet Overflow Uses Persistent Deferred Energy Grants

**Decision:** One-time/event/commercial reward value that cannot fit in the wallet is preserved in bounded deferred grant records; Production uses its own buffer remainder instead.

---

## TA8-D13 — Progression Purchases Use Server-Issued Quotes and Atomic Cost/Effect

**Decision:** Price/prerequisite/config context is server-issued. Changed/expired quotes re-confirm rather than silently charging a different amount.

---

## TA8-D14 — Commercial Capacity Is a Separate Additive Component

**Decision:** Paid capacity may affect bounded Collection/Display capacity only and cannot enter Production Slots, Buffer, Offline Window, rates or Capture Capability.

---

## TA8-D15 — Close TA-8 and Advance to TA-9

**Decision:** TA-8 is Architecture Complete — PASS with 220/220 scenarios and zero blocking questions. TA-9 becomes NEXT; gameplay implementation remains blocked.
