# GDS-2 Lifecycle Scenario Validation

> **Phase:** GDS-2 — Global Game Rules and Session Model  
> **Status:** Complete  
> **Validation result:** PASS  
> **Date:** 2026-09-17

## 1. Purpose

Stress-test the GDS-2 global contract against compound lifecycle cases that commonly create contradictory persistence, reward, disconnect, or cross-server behavior.

This document validates the rules; it does not replace `global_rules/02_global_game_rules_and_session_model.md` as authority.

## 2. Validation Principles

A scenario passes only when it preserves all applicable invariants:

1. finalized persistent value is not silently lost through ordinary lifecycle events;
2. retry/reconnect does not duplicate value or erase finalized costs;
3. unfinalized transient activities have a downstream owner for interruption semantics;
4. persistent state uncertainty enters Protected Load Failure rather than fabricated blank play;
5. server/session boundaries do not silently redefine progression;
6. later GDS phases retain authority for their detailed mechanics.

## 3. Compound Scenario Matrix

| # | Scenario | Expected global result | Detailed owner | Result |
|---|---|---|---|---|
| 1 | First-time player joins an already-running server | Trusted state becomes ready before irreversible play; late join is normal | GDS-3 onboarding | PASS |
| 2 | Returning player joins a different public server | Existing persistent progression is preserved | GDS-2 | PASS |
| 3 | Player changes from mobile to desktop between sessions | Same persistent ownership/progression contract | GDS-2 | PASS |
| 4 | Data cannot be trusted during join | Protected Load Failure; no blank profile progression | TA implementation | PASS |
| 5 | Retry later succeeds after load failure | Enter play with trusted persistent state; failed attempt created no irreversible state | TA implementation | PASS |
| 6 | Player closes app immediately after a finalized persistent reward | Reward remains persistent | Owning subsystem + TA | PASS |
| 7 | Player closes app before capture/ownership finalizes | Exact outcome delegated to GDS-5; cannot be invented during implementation | GDS-5 | PASS |
| 8 | Player disconnects during a future trade | Exact rollback/commit behavior delegated to GDS-12; finalized transfer may not double-apply | GDS-12 | PASS |
| 9 | Server crashes after a durable purchase is finalized | Durable entitlement is not intentionally erased | GDS-13 + TA | PASS |
| 10 | Server crashes during unfinalized purchase handling | Must resolve under purchase/receipt authority; no duplicate entitlement beyond product semantics | GDS-13 + TA | PASS |
| 11 | Player resets avatar while carrying transient value | Persistent collection is safe; transient consequence delegated to owning mechanic | GDS-3/GDS-5 | PASS |
| 12 | Player repeatedly resets to optimize an activity | Activity must not yield duplicate rewards or erase finalized costs | Owning subsystem | PASS |
| 13 | Player dies/fails immediately after respawn | Recovery design must provide reasonable opportunity to regain control | GDS-3/GDS-9/GDS-10 | PASS |
| 14 | Player joins server after a finite session reward was consumed | No automatic retroactive entitlement | Owning event/world spec | PASS |
| 15 | Two players act on one finite creature/opportunity simultaneously | One coherent finalized outcome set; exact arbitration delegated | GDS-4/GDS-5 | PASS |
| 16 | Shared event intentionally awards many players | Multi-award is valid when the owning event defines it | GDS-11 | PASS |
| 17 | Player server-hops after claiming a one-time account reward | Claim remains consumed | Owning subsystem | PASS |
| 18 | Player server-hops during a persistent cooldown/effect | Timer does not reset implicitly; owning system declares elapsed-time semantic | Owning subsystem | PASS |
| 19 | Player joins a friend in a region they have not unlocked | Friend join does not bypass progression by default | GDS-9/GDS-10 | PASS |
| 20 | Player is AFK near an event | Presence alone grants no global entitlement | GDS-11 participation rules | PASS |
| 21 | Player remains offline for 24 hours | No live-world claim exists by default | GDS-2 | PASS |
| 22 | Later vault design grants offline production | Must be derived from persistent state and explicit elapsed-time rules | GDS-7/GDS-8 | PASS |
| 23 | A global seasonal window ends while player teleports/rejoins | Window remains ended; new server does not restart it | GDS-11 | PASS |
| 24 | Session-local rare spawn disappears when server closes | Allowed unless downstream spec has already finalized persistent player value | GDS-9/GDS-11 | PASS |
| 25 | Client retries a request after timeout and server had already finalized it | Player-facing outcome remains single-application | TA | PASS |
| 26 | Old client view conflicts with trusted persistent state after reconnect | Trusted persistent state wins; no duplication from stale view | TA | PASS |
| 27 | Player cleanly leaves vs loses network | Both retain the same finalized persistent-value guarantee | GDS-2 | PASS |
| 28 | Future prestige mechanic resets selected progress | Only valid if explicitly designed as player-understandable persistent reset | GDS-8 | PASS |
| 29 | Server session has been running for a long time | Late join still reaches safe meaningful play | GDS-3/GDS-9 | PASS |
| 30 | Player attempts irreversible action before state readiness | Action must be unavailable/non-finalizing | GDS-2 / TA | PASS |

## 4. Product-Contract Validation

### Persistent collection trust

GDS-1 requires a persistent visible collection and non-loss-dominant product identity. GDS-2 preserves that trust by separating server/avatar lifecycle from persistent ownership.

**Result:** PASS.

### Flexible session shape

GDS-1 explicitly allows healthy voluntary session endings and short sessions. GDS-2 therefore cannot require special clean logout rituals or punish ordinary leaving.

**Result:** PASS.

### Multiplayer/social play

The session model permits late joins, friend joins, shared server opportunities, and session-local world variation without assuming an MMO-scale globally shared world.

**Result:** PASS.

### Small-team feasibility

The design avoids requiring a continuously synchronized cross-server world as a baseline product capability. Later systems may add narrowly justified cross-server behavior.

**Result:** PASS.

## 5. Abuse Validation

| Abuse vector | Global safeguard | Result |
|---|---|---|
| reconnect reward duplication | finalized outcome applies once | PASS |
| reset to avoid finalized costs | reset cannot erase finalized costs | PASS |
| session hop to repeat one-time claims | persistent claims remain consumed | PASS |
| load failure causing blank-state overwrite | Protected Load Failure | PASS |
| AFK presence farming by default | presence is not entitlement | PASS |
| disconnect used as risk-free superior strategy | downstream transient rules must close the loophole | PASS |
| device/platform switching for different semantics | lifecycle semantics are cross-platform equal | PASS |

## 6. Authority Validation

No GDS-2 rule locks:

- capture ownership-transfer timing;
- event participation/reward formulas;
- trade atomicity UX;
- economy values;
- spawn tables;
- exact offline-production amounts;
- exact recovery spawn mechanics;
- persistence/networking implementation.

Those remain assigned to later GDS or Technical Architecture.

**Result:** PASS.

## 7. Open Findings

No scenario exposes an implementation-relevant ambiguity owned by GDS-2.

Several downstream phases now inherit explicit obligations, especially GDS-5, GDS-7/GDS-8, GDS-11, GDS-12, and GDS-13. These are dependency contracts, not unresolved GDS-2 questions.

## 8. Verdict

**PASS.**

The GDS-2 lifecycle model remains coherent under disconnects, resets, server transitions, persistence failures, late joins, timing boundaries, duplicate delivery, and server shutdown scenarios.