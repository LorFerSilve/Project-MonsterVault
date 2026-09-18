# TA-7 Closure Report

> **Phase:** TA-7 — Capture, Creature Ownership, Mutation, and Reward Resolution  
> **Status:** Architecture Complete  
> **Closure date:** 2026-09-18  
> **Result:** PASS

## 1. Closure Scope

TA-7 closes authoritative creature acquisition and Variant/ownership resolution before Vault/economy architecture begins.

It defines:

- per-creature capture state machine;
- simultaneous claim arbitration;
- claim/attempt/custody identities;
- eligibility and attempt acceptance;
- server-owned Capture Challenge result authority;
- server RNG abstraction;
- weighted selection rules;
- one-time Variant Identity generation;
- Mutation/Trait compatibility and canonicalization;
- Protected Variant classification;
- Provisional Capture and Transport Custody;
- disconnect Transport Grace;
- Roblox exit-signal ambiguity handling;
- Secure Point validation;
- stable ownership finalization operation identity;
- P2 exact-once creature/discovery/protection commit;
- capacity race -> Overflow-Held;
- reward boundaries;
- claim griefing controls;
- controlled-shutdown finalization;
- onboarding/event/server-hop boundaries;
- exploit/statistical/observability contracts.

## 2. Evidence

| Evidence | Result |
|---|---|
| capture/07_capture_creature_ownership_mutation_and_reward_resolution.md | Architecture Complete |
| TA7_ROBLOX_CAPTURE_RANDOMNESS_SNAPSHOT.md | PASS |
| TA7_CAPTURE_VARIANT_FINALIZATION_MATRIX.md | PASS |
| TA7_GDS_TRACEABILITY.md | PASS |
| TA7_SCENARIO_VALIDATION.md | 200 / 200 PASS |
| TA7_DECISION_INDEX.md | Accepted |
| Blocking TA-7 questions | 0 |
| Unresolved upstream conflicts | 0 |

## 3. Claim/Attempt Result

Ordinary single-award claims are serialized on the server.

The first currently eligible server-accepted transition wins; client timing/premium/party state cannot override it.

Capture Challenge inputs are client intent only. Terminal Success/Failure/Cancel/Invalidation is server-owned.

**PASS.**

## 4. Variant / RNG Result

One server-side generation pipeline fixes Variant Identity before individual actionability.

Production randomness is server-owned; tests can inject deterministic RNG.

Same-instance claim/capture/reconnect/transport/finalization retries never reroll Variant Identity.

**PASS.**

## 5. Provisional / Transport Result

Capture Success creates no persistent ownership.

It creates one Provisional Capture, one Transport Custody holder, and one durable ownership finalization operation identity.

Recovery/reset ends ordinary custody without extraction.

Unexpected disconnect may receive bounded same-server grace; grace itself grants no ownership.

**PASS.**

## 6. Ownership Result

Normal extraction is a TA-4 P2 durable-before-final-ack commit.

The same CreatureInstanceId becomes persistent ownership.

The atomic player-profile bundle includes applicable:

- placement/Overflow-Held;
- Protected Variant auto-lock;
- Species Discovery;
- Mutation Discovery;
- Variant Discovery;
- provenance;
- finalization idempotency.

**PASS.**

## 7. Capacity / Reward Result

Known-full capacity blocks new ordinary acquisition.

A later capacity race never deletes a successfully acquired creature; it finalizes Overflow-Held.

Ordinary capture creates no implicit Energy reward.

**PASS.**

## 8. Shutdown Result

Orderly server drain:

- stops new capture admission;
- snapshots active valid Transport Custody;
- uses the existing finalization operation;
- requires actual P2 durability.

Idle/claimed/attempt-only or disconnected grace states are not auto-secured.

Abrupt crash has no guaranteed provisional finalization.

**PASS.**

## 9. Platform Review Result

Current Roblox documentation supports:

- server-owned critical reward/progression logic;
- server validation of remote/prompt/physics interactions;
- server-useable pseudorandom Random generators;
- PlayerRemoving with PlayerExitReason;
- the current coarse exit-reason enum requiring conservative handling where disconnect intent is ambiguous.

**PASS.**

## 10. Open Questions

There are **zero TA-7-blocking open questions**.

Correctly downstream:

- exact capacity/Overflow/Capture Capability representation — TA-8;
- Species spawn scheduling/Secure Point indexing — TA-9;
- event multi-award capture overrides — TA-10;
- exact capture UI/minigame/input — TA-12;
- telemetry/live tuneables — TA-13;
- timing/performance budgets — TA-14;
- statistical/concurrency/fault tests — TA-15;
- implementation APIs/modules/routes — TA-17.

## 11. Gate Transition

**TA-7 — ARCHITECTURE COMPLETE — PASS.**

The active dependency advances to:

> **TA-8 — Vault, Economy, Progression, Inventory, and Offline Accrual**

TA-9 through TA-17 remain dependency-blocked.

Gameplay implementation remains **BLOCKED** until TA-17.

## 12. Final Verdict

MonsterVault now has an exploit-resistant, anti-reroll, exact-once creature acquisition architecture that preserves one Creature Instance from world generation through capture and transport into durable secured ownership.
