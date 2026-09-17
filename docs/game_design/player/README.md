# Player Character, Interaction, and Onboarding

> **Status:** Design Complete — GDS-3 PASS  
> **Owning phase:** GDS-3

This domain is the authoritative home for baseline player movement, camera behavior, cross-device interaction grammar, onboarding, basic equipment/inventory-facing behavior, and Safe Arrival/Recovery presentation semantics.

## Authoritative Specification

- [`03_player_character_interaction_and_onboarding.md`](03_player_character_interaction_and_onboarding.md) — **Design Complete**.

## GDS-3 Closure Evidence

- [`../GDS3_SCENARIO_VALIDATION.md`](../GDS3_SCENARIO_VALIDATION.md) — 40 compound interaction/onboarding scenarios; PASS.
- [`../GDS3_CROSS_VALIDATION.md`](../GDS3_CROSS_VALIDATION.md) — product/lifecycle/authority validation; PASS.
- [`../GDS3_CLOSURE_REPORT.md`](../GDS3_CLOSURE_REPORT.md) — formal GDS-3 closure; PASS.

## Locked Domain Contract

GDS-3 establishes:

- third-person character-centric baseline exploration camera;
- familiar continuous directional movement plus conventional jump;
- no universal stamina tax on ordinary movement;
- one universal **Primary Interact** semantic for contextual world interactions;
- one cross-device **Primary Action** semantic for active downstream tools/mechanics;
- one visibly selected **Active Context** at a time with activation-time revalidation;
- touch, keyboard/mouse, and controller baseline capability parity;
- deterministic modal input focus and protection against input spillover;
- gameplay-first progressive onboarding aligned to GDS-1 time-to-fun targets;
- persistent/resumable **Onboarding Milestones** without duplicate reward replay;
- skippable/replayable Guidance Layer separate from real progression;
- first-path onboarding availability despite normal multiplayer/server variation;
- **Safe Arrival** after GDS-2 Persistence Ready;
- **Recovery** to a valid Recovery Anchor after reset/failure/stuck states;
- Recovery that does not automatically secure transient value or act as a universal extraction shortcut;
- non-color-only, non-audio-only, non-pixel-precision interaction requirements.

## Downstream Boundary

This domain does not define creature ownership, capture mechanics, world topology/hazards, economy values, social/PvP rules, events, trading, monetization, final HUD/accessibility presentation, or technical implementation.

Those remain under GDS-4 through GDS-16 and Technical Architecture.
