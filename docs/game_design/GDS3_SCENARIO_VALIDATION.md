# GDS-3 Scenario Validation

> **Phase:** GDS-3 — Player Character, Interaction, and Onboarding  
> **Status:** Complete  
> **Validation result:** PASS  
> **Date:** 2026-09-17

## 1. Purpose

Stress-test the GDS-3 player-control, contextual-interaction, onboarding, and Recovery contract against compound situations that can expose ambiguity before downstream creature/capture/world systems are designed.

A scenario passes only when:

- the player-facing result is deterministic at GDS-3 level;
- GDS-1 time-to-fun/mobile-first constraints remain possible;
- GDS-2 lifecycle/persistence guarantees are preserved;
- GDS-3 does not invent behavior owned by a later phase;
- no interruption can silently duplicate or fabricate finalized progress.

## 2. Scenario Matrix

| # | Scenario | Expected result | Result |
|---:|---|---|---|
| 1 | Brand-new touch player loads normally | Persistence Ready -> Safe Arrival -> direct control -> progressive onboarding with touch-readable movement/camera/actions | PASS |
| 2 | Brand-new player uses keyboard/mouse | Same gameplay path; semantic controls mapped to keyboard/mouse without exclusive capability | PASS |
| 3 | Brand-new player uses controller | Same gameplay path; controller can reach movement, camera, jump, interact, Primary Action and required onboarding UI | PASS |
| 4 | Persistence fails before spawn | GDS-2 Protected Load Failure; irreversible gameplay/onboarding rewards never begin against blank state | PASS |
| 5 | Player joins a long-running server | Canonical onboarding begins from current server state; no dependency on server-start sequence | PASS |
| 6 | Nearby onboarding creature/opportunity is already consumed by another player | First-path availability obligation requires another valid learning opportunity/fallback from downstream GDS-5/GDS-9/GDS-10 | PASS |
| 7 | Several world interactables overlap | Exactly one Active Context is visibly selected; Primary Interact addresses only that context after revalidation | PASS |
| 8 | Selected context disappears at activation | Revalidation fails safely; no partial/contradictory consequence; context is reevaluated | PASS |
| 9 | Decorative object and progression-critical object overlap | Relevance/intent priority prevents decorative context from routinely stealing clearly intended core interaction | PASS |
| 10 | Player dismisses a hint while an interactable is underneath | Dismiss input cannot spill through into an irreversible world activation | PASS |
| 11 | Player skips Guidance Layer before first capture | Guidance disappears; real objective remains; no fabricated capture/reward/progression | PASS |
| 12 | Player completes movement milestone then disconnects | Persistent onboarding milestone remains complete; reconnect resumes later valid step | PASS |
| 13 | Player disconnects during unfinalized first capture | GDS-5 later owns transient capture result; GDS-3 resumes onboarding from the resulting valid milestone without duplicate reward | PASS |
| 14 | Player secures first creature then disconnects before next tutorial panel | Finalized result remains under GDS-2; onboarding resumes after secured milestone without regrant | PASS |
| 15 | Player resets during first-session onboarding | Reset enters Recovery; already completed milestones remain; no global progression loss or duplicate tutorial reward | PASS |
| 16 | Player resets while carrying future transient value | GDS-3 does not auto-secure/transport it; GDS-5/other owner defines consequence; Recovery proceeds | PASS |
| 17 | Player intentionally uses reset repeatedly for travel | GDS-3 forbids Recovery as globally superior extraction/fast-travel path; downstream systems must preserve constraint | PASS |
| 18 | Avatar falls out of world | Recovery to valid Recovery Anchor; persistent state unchanged; control restored | PASS |
| 19 | Recovery Anchor is inside unavoidable hazard | Anchor violates GDS-3/GDS-2 safe-recovery obligation; world design must choose valid alternative | PASS |
| 20 | Camera is temporarily obstructed by geometry | Camera/view must be recoverable; required interaction cannot remain indefinitely unreadable | PASS |
| 21 | Guided onboarding camera points at goal and player immediately looks away | Direct camera input wins; automation does not repeatedly fight player intent | PASS |
| 22 | Touch player cannot precision-aim at tiny object | Core contextual interaction must remain viable using accessible context selection/proximity; pixel-precision aim is not required | PASS |
| 23 | Player cannot distinguish red/green states | Critical selected/blocked/available interaction state includes non-color cues | PASS |
| 24 | Player plays without audio | All movement/interaction/onboarding/Recovery instructions remain understandable without sound | PASS |
| 25 | Player changes from mouse to controller mid-session | Input Mode/glyphs update; capabilities, Active Presence, persistent progress and onboarding state do not reset | PASS |
| 26 | Controller disconnects while prompt is visible | No automatic irreversible activation; player can resume after reconnect/alternate input | PASS |
| 27 | Mobile UI reflows/orientation changes | Required actions remain reachable/readable; semantic state is unaffected | PASS |
| 28 | Modal inventory/settings opens while world prompt is active | Modal owns input focus; conflicting world actions suppressed; close restores predictable control | PASS |
| 29 | Same button press closes a modal over an interactable | Input spillover protection prevents immediate world activation on the same press/release | PASS |
| 30 | Tool/equipment becomes active | Primary Action appears on all Input Modes; baseline locomotion/camera remain unless mechanic explicitly enters committed state | PASS |
| 31 | Tool interaction is interrupted by latency/target loss | Owning mechanic defines outcome; GDS-3 requires clear exit/rejection and restoration of control | PASS |
| 32 | Player mashes Primary Interact | Visible context is revalidated; GDS-3 does not permit hidden-target activation; downstream finalized outcomes remain single-application under GDS-2 | PASS |
| 33 | Many other players crowd onboarding area | Player avatars do not routinely steal context focus; required first-path opportunity cannot be permanently denied | PASS |
| 34 | Event is active when a new player arrives | Event may remain visible, but basic onboarding path/next action remains understandable and available | PASS |
| 35 | Player returns after completing onboarding | Forced basic tutorial does not replay; ordinary play begins, with optional help available | PASS |
| 36 | Player returns with partially completed onboarding | Resume earliest valid incomplete milestone with enough orientation, not full destructive restart | PASS |
| 37 | Player asks for help/replays guidance after completion | Guidance may replay; one-time rewards and finalized progression do not | PASS |
| 38 | Experienced player dismisses all optional hints | Core objectives and interaction prompts remain usable without instructional overlays | PASS |
| 39 | Player joins friend whose location has progression gating | Social join does not silently override progression/access authority; world/social phases decide valid placement/access | PASS |
| 40 | Player temporarily loses focus/input while an irreversible prompt is present | Loss/regain of focus alone does not finalize action; explicit activation remains required | PASS |

## 3. First-Session Funnel Validation

The GDS-3 sequence was checked against GDS-1's product-level targets:

| Product target | GDS-3 support | Result |
|---|---|---|
| Interactive control effectively immediately after readiness | Safe Arrival is intentionally short and hands control directly to the player | PASS |
| Meaningful visible goal within ~30–45 s | onboarding exposes one nearby desirable goal before secondary systems | PASS |
| First real capture attempt within ~60 s | movement/context teaching is deliberately minimal before GDS-5 capture handoff | PASS |
| First secured creature within ~3 min | GDS-3 avoids menu/tutorial blockers and creates availability obligation for first learning opportunity | PASS |
| First visible progression choice within ~6 min | onboarding sequence explicitly hands first secured result into GDS-7/GDS-8 consequence before advanced systems | PASS |
| Meaningful short sessions | returning players are not forced through repeated onboarding; control is immediate after readiness | PASS |

Exact measured performance remains a playtest/analytics question; the design contains no structural requirement that makes these targets impossible.

## 4. Cross-Device Validation

### Touch

PASS because:

- all baseline actions have discrete touch controls;
- no progression-critical hover/right-click/keyboard chord is required;
- contextual interaction reduces precision-targeting burden;
- drag-and-drop is not the sole inventory path;
- critical interaction is not dependent on rapid repeated tapping.

### Keyboard/mouse

PASS because:

- conventional movement/camera mappings are available;
- keyboard/mouse convenience does not create exclusive mechanics;
- contextual interaction and Primary Action remain semantically aligned with other devices.

### Gamepad

PASS because:

- movement, camera, jump, contextual interaction, Primary Action, back/cancel, and required UI access all have controller paths;
- pointer emulation is not allowed to be the sole practical path for baseline progression.

## 5. Lifecycle Validation

GDS-3 remains compatible with GDS-2 because:

- Safe Arrival begins only after Persistence Ready;
- Protected Load Failure remains outside irreversible gameplay;
- onboarding milestones never weaken finalized-outcome single-application semantics;
- reset/failure enter Recovery rather than implying persistence wipe;
- Recovery does not auto-secure transient value;
- reconnect resumes valid instructional state rather than manufacturing outcomes;
- Input Mode changes are presentation/control changes, not lifecycle resets.

## 6. Authority Validation

The scenarios intentionally stop at GDS-3 boundaries:

- creature ownership/finalization -> GDS-4/GDS-5;
- first-capture mechanics -> GDS-5;
- vault/progression consequences -> GDS-7/GDS-8;
- Recovery Anchor placement/hazards -> GDS-9;
- grief/contest protection -> GDS-10;
- events -> GDS-11;
- final HUD/settings/accessibility implementation -> GDS-14;
- telemetry implementation -> GDS-16/TA.

No scenario requires GDS-3 to invent those downstream rules.

## 7. Verdict

**PASS.**

All 40 compound scenarios have a deterministic GDS-3-level outcome or an explicit downstream owner constrained by GDS-3 invariants. No interaction, onboarding, Recovery, cross-device, or lifecycle scenario exposes a GDS-3-blocking ambiguity.