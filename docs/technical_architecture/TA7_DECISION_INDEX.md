# TA-7 Decision Index

> **Phase:** TA-7 — Capture, Creature Ownership, Mutation, and Reward Resolution  
> **Status:** Accepted

## TA7-D01 — Ordinary Capture Uses a Server-Owned Per-Creature State Machine

**Decision:** Claim, attempt, provisional, transport and finalization state transitions are serialized by CreatureInstanceId and never selected by the client.

---

## TA7-D02 — First Accepted Eligible Server Transition Wins an Ordinary Claim

**Decision:** Simultaneous BeginClaim requests are resolved by the authoritative non-yielding per-creature state owner. Client timestamps, ping, party or premium status provide no priority.

---

## TA7-D03 — Production Randomness Is Server-Owned and Test Randomness Is Injectable

**Decision:** Roblox Random is wrapped behind a first-party server RNG contract. Production does not accept a client seed; tests can inject deterministic seeded/fake draws.

---

## TA7-D04 — Variant Identity Is Generated Exactly Once Before Individual Actionability

**Decision:** Species Rarity, Mutation set, Traits, Variant Signature and generation snapshot are finalized before the creature can be individually captured.

**Consequence:** Claim/capture/reconnect/transport/finalization cannot reroll the same surviving Creature Instance.

---

## TA7-D05 — Mutation Generation Is Bounded to 0–2 Compatible Canonical Mutations

**Decision:** Compound variants use compatible distinct Mutations and canonical order-independent signatures.

---

## TA7-D06 — Capture-Result Randomness and Variant Randomness Are Separate

**Decision:** A new accepted Capture Attempt may have its own success/failure RNG when configured, but it can never modify already-finalized Variant Identity.

---

## TA7-D07 — Capture Success Creates Provisional Custody, Not Ownership

**Decision:** Persistent Collection state is unchanged at Capture Success. One server runtime custody record carries the same CreatureInstanceId toward extraction.

---

## TA7-D08 — Provisional Capture Receives One Server-Owned Ownership Finalization Operation ID

**Decision:** The operation ID is created with Provisional Capture and is reused for normal extraction, retry/reconciliation, and controlled shutdown protection.

---

## TA7-D09 — Secured Ownership Is a P2 Atomic Profile Bundle

**Decision:** The exact Creature, provenance, placement/Overflow outcome, Protected auto-lock, Species/Mutation/Variant discoveries and idempotency result commit together before "Secured" is acknowledged.

---

## TA7-D10 — Capacity Races Resolve to Overflow-Held, Never Deletion

**Decision:** Known full capacity blocks initiation; later capacity loss cannot invalidate a legitimately accepted acquisition after success.

---

## TA7-D11 — Transport Grace Is Server-Local and Grants No Ownership

**Decision:** Unexpected disconnect can suspend active custody for bounded same-server resume. Grace cannot cross servers and expiry ends provisional state.

---

## TA7-D12 — Ambiguous PlayerExitReason.Unknown Uses Conservative Disconnect Grace

**Decision:** Current Roblox exit signaling cannot always prove voluntary leave versus network loss. Explicit trusted voluntary exits end custody; ambiguous Unknown gets bounded grace only.

---

## TA7-D13 — Controlled Shutdown Finalizes Only Active Valid Transport Custody

**Decision:** Server drain state may invoke the existing finalization operation for active custody, but never for idle/claimed/attempt-only or disconnected grace state.

---

## TA7-D14 — Ordinary Capture Has No Implicit Energy Reward

**Decision:** The baseline outcome is the Secured Creature and authorized discovery/milestone effects. Any Energy/event reward must come from an explicit owning system and remain exact-once.

---

## TA7-D15 — Close TA-7 and Advance to TA-8

**Decision:** TA-7 is Architecture Complete — PASS with 200/200 scenarios and zero blocking questions. TA-8 becomes NEXT; gameplay implementation remains blocked.
