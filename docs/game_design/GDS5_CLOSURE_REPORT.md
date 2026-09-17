# GDS-5 Closure Report

> **Phase:** GDS-5 — Capture, Contesting, Transport, and Extraction  
> **Status:** Complete  
> **Closure date:** 2026-09-17  
> **Result:** PASS

## 1. Purpose

This report formally closes GDS-5 after defining and validating MonsterVault's ordinary active acquisition loop from Capture Opportunity through Engagement Claim, Capture Attempt, Provisional Capture, Transport Custody, Extraction Completion, and Secured Ownership Finalization.

GDS-5 supplies the exact pre-ownership and ownership-boundary contract that downstream rarity, vault, economy, world, social, event, presentation, and Technical Architecture phases must preserve.

## 2. Closure Requirements

GDS-5 requires authoritative resolution of:

1. Capture Opportunity and player-specific Capture Eligibility;
2. capture initiation semantics;
3. ordinary simultaneous-player contesting;
4. Engagement Claim exclusivity and release;
5. capture challenge input/accessibility constraints;
6. success/failure/cancel/invalidation behavior;
7. Provisional Capture semantics;
8. baseline Transport Custody semantics and limit;
9. ordinary transport theft/interception boundary;
10. reset/Recovery behavior during acquisition;
11. disconnect/reconnect behavior during transport;
12. voluntary leave behavior;
13. server-originated shutdown behavior;
14. Secure Point semantics;
15. exact ordinary Secured Ownership Finalization trigger;
16. exact-once finite-opportunity ownership result;
17. capacity/overflow interaction;
18. onboarding-protected first capture;
19. anti-frustration/anti-grief/anti-exploit invariants;
20. downstream authority boundaries.

## 3. Evidence Matrix

| Requirement | Evidence | Result |
|---|---|---|
| Capture/contesting/transport/extraction authority | `capture/05_capture_contesting_transport_and_extraction.md` | PASS |
| Compound acquisition/lifecycle cases | `GDS5_SCENARIO_VALIDATION.md` | PASS |
| GDS-1 through GDS-4 compatibility | `GDS5_CROSS_VALIDATION.md` | PASS |
| Downstream authority boundaries | `GDS5_CROSS_VALIDATION.md` | PASS |
| Canonical terminology | `GLOSSARY.md` | PASS |
| Strategic rationale | `DESIGN_DECISIONS.md` | PASS |

## 4. Locked GDS-5 Decisions

GDS-5 closes the following player-facing decisions:

- ordinary capture begins only from a valid player-specific Capture Opportunity;
- a deliberate valid initiation creates one short-lived exclusive **Engagement Claim** for a normal single-award creature;
- the ordinary multiplayer contest is primarily the race to reach/validly engage before another active claim exists;
- active Engagement Claims cannot be overwritten merely by later proximity/input;
- claims are bounded and cannot be held indefinitely through idling or start/cancel cycling;
- capture uses GDS-3-compatible Primary Interact/Primary Action semantics and may not require device-exclusive precision or button mashing;
- Capture Failure creates no secured ownership and must have understandable retry/expiry consequences;
- **Capture Success creates a Provisional Capture**, not immediate Persistent Player State;
- the same specific creature instance remains attached through provisional transport and securisation;
- the baseline player may hold **one active Provisional Capture / Transport Custody at a time**;
- ordinary Transport Custody cannot be directly stolen by other-player proximity or ordinary baseline PvP;
- reset/avatar failure/Recovery does not count as extraction and ends ordinary transport custody through the interruption path;
- voluntary server leave forfeits unfinalized transport;
- unexpected client disconnect with valid Transport Custody deterministically enters bounded same-server **Transport Grace**; reconnect within grace resumes the same provisional custody, while grace expiry ends it without secured ownership;
- Transport Grace never converts an unfinalized provisional creature into cross-server ownership;
- during an orderly authoritative system/server-originated shutdown, a valid Provisional Capture is protected by exact-once **Protected Shutdown Finalization** when authoritative custody state remains available;
- abrupt process/platform failure that prevents shutdown execution/state verification cannot promise that protection because the creature remains unfinalized transient state;
- voluntary leave, reset, Recovery, and ordinary client disconnect cannot invoke Protected Shutdown Finalization;
- a **Secure Point** is the ordinary world-facing destination that can complete extraction;
- the exact ordinary ownership boundary is **validated Extraction Completion at an eligible Secure Point**;
- Extraction Completion emits `Secured Ownership Finalization(player, creature)` exactly once;
- after that event, GDS-4 secured persistent ownership applies immediately;
- known full capacity blocks new ordinary capture initiation;
- capacity becoming unavailable after valid initiation cannot delete the completed acquisition: finalization succeeds into GDS-4 **Overflow-Held** when necessary;
- unresolved overflow blocks further ordinary capture initiation so overflow cannot become unlimited storage;
- the first required capture uses an **Onboarding-Protected Opportunity** that unrelated players cannot permanently deny;
- ordinary single-award encounters may finalize for only one player; shared/multi-award variants require explicit later event authority.

## 5. Scenario Validation Result

`GDS5_SCENARIO_VALIDATION.md` evaluates 60 compound scenarios covering simultaneous engagement, active-claim overwrite attempts, idle/abandoned claims, accepted versus invalid attempts, failure/retry/expiry, Capture Success and provisional identity, single-custody transport, Secure Point finalization, duplicate delivery/idempotency, reset/Recovery, deterministic disconnect grace, voluntary leave, cross-server transitions, controlled server-originated shutdown protection, capacity-full and capacity-race behavior, Overflow-Held abuse prevention, onboarding protection, cross-device parity, modal input spillover, crowded multiplayer spaces, world hazard interruption, party/friend assumptions, event multi-award authority, and stale/desynchronized presentation.

All tested scenarios are coherent under the GDS-5 contract.

**Result:** PASS — 60 / 60.

## 6. Cross-System Validation Result

`GDS5_CROSS_VALIDATION.md` confirms that GDS-5:

- realizes the GDS-1 `Find it -> Catch it -> Bring it home` product loop;
- preserves non-loss-dominant competition and mobile-first time-to-fun;
- satisfies GDS-2 transient/finalized/interruption requirements;
- consumes GDS-3 input, onboarding, Recovery, modal-safety, and accessibility semantics;
- supplies GDS-4's intentionally deferred exact `Secured Ownership Finalization` trigger;
- preserves stable Creature Instance identity through capture/transport/finalization;
- integrates GDS-4 capacity/Overflow-Held semantics without enabling infinite overflow;
- leaves rarity, vault, economy, world, social, event, trading, monetization, presentation, analytics, and technical details with their owning phases.

**Result:** PASS.

## 7. Downstream Obligations Created by GDS-5

GDS-5 creates explicit dependencies:

- GDS-6 must define rarity/mutation/trait effects on capture challenge/difficulty while preserving stable instance identity across provisional transport/finalization;
- GDS-7 must integrate world-facing Secure Point/intake behavior and post-finalization placement without moving the ownership boundary;
- GDS-8 must define capture tools, costs, cooldowns, progression modifiers, and any future transport-capacity expansion consistently with accepted-attempt and exact-once semantics;
- GDS-9 must define encounter spawning/lifetime, routes, hazards, and Secure Point placement while preserving active-claim fairness and onboarding protection;
- GDS-10 must define body-blocking/collision/grief prevention and any optional interception/risk modes without silently allowing ordinary custody theft;
- GDS-11 must explicitly define any collaborative/multi-award event capture override;
- GDS-12 must treat normal Provisional Captures as not yet tradable secured value unless an explicit later feature is designed;
- GDS-13 cannot require payment to complete a valid baseline extraction or protect a race-condition finalization;
- GDS-14 must make available/claimed/attempt/provisional/transport/secure/finalized states clearly legible across supported devices;
- GDS-16 must instrument the acquisition funnel without experiments that covertly shift the ownership boundary;
- Technical Architecture must implement authoritative claims, validation, deterministic bounded grace, controlled-shutdown protection, exact-once finalization, and anti-duplication without weakening GDS-5 semantics.

These are downstream obligations, not GDS-5 open questions.

## 8. Open Questions

There are **zero GDS-5-blocking open questions**.

Numeric capture rates, rarity modifiers, challenge visuals/timing, tool/economy values, spawn tables, hazard rules, Secure Point placement, collision/PvP, event-specific shared capture, final UX/audio/accessibility presentation, and technical transaction mechanisms remain explicitly assigned downstream.

## 9. Change Control

Material changes to the following require reopening GDS-5 through explicit decision logging and relevant revalidation:

- Engagement Claim as ordinary single-attempt exclusivity;
- ordinary contesting-before-Provisional-Capture baseline;
- Capture Success creating Provisional Capture instead of immediate secured ownership;
- one active ordinary Transport Custody per player;
- ordinary Transport Custody not being directly stealable;
- reset/Recovery not counting as extraction;
- deterministic bounded same-session Transport Grace;
- controlled authoritative Protected Shutdown Finalization semantics;
- Extraction Completion as the normal Secured Ownership Finalization boundary;
- exact-once single-winner ordinary finalization;
- known-full-capacity initiation block and race-safe Overflow-Held finalization;
- unresolved-overflow new-capture block;
- Onboarding-Protected Opportunity requirement;
- cross-device capture-accessibility contract.

Numeric tuning and final visual presentation do not reopen GDS-5 while these semantics remain intact.

## 10. Formal Verdict

**GDS-5 PASS — COMPLETE.**

MonsterVault now has a complete ordinary acquisition contract spanning discovery eligibility, multiplayer claim fairness, capture challenge semantics, provisional custody, transport, extraction, deterministic interruption handling, capacity safety, onboarding protection, and the exact persistent ownership boundary.

The active dependency advances to:

> **GDS-6 — Rarity, Mutations, Traits, and Variant Value**

Technical Architecture and gameplay implementation remain blocked until the full GDS dependency chain and subsequent architecture gates are complete.