# Design Authority

> **Status:** Active
> **Authority:** Project-wide game-design governance
> **Applies to:** All documentation under `docs/game_design/`

## 1. Purpose

This document defines how MonsterVault gameplay is specified, reviewed, changed, validated, and eventually handed to implementation.

The primary rule is simple: **gameplay behavior must not be invented during programming**.

## 2. Single Source of Truth

The authoritative Game Design Specification under `docs/game_design/` is the source of truth for intended player-facing behavior.

If implementation and specification ever disagree, the discrepancy must be resolved explicitly. Code does not silently redefine the game.

## 3. One Authoritative Home Per Rule

Every gameplay rule has exactly one authoritative owner. Other specifications may reference that rule and describe local consequences, but may not independently redefine it.

## 4. Status Model

### Draft

The system is being designed. Open questions are permitted but must be explicit.

### Under Review

A complete proposed behavior exists and is being checked for contradictions, omissions, exploits, UX problems, platform constraints, and cross-system effects.

### Design Complete

All implementation-relevant gameplay behavior is defined. An implementer should not need to invent intended behavior. Explicitly tuneable balancing values may remain adjustable.

### Implementation Locked

A later Technical Architecture handoff has converted the approved design into an implementation contract. Behavioral changes now require explicit change control.

## 5. Definition of Design Complete

A subsystem may be marked `Design Complete` only when all applicable areas are defined:

- purpose and player fantasy;
- player-facing behavior;
- participating entities and ownership;
- terminology;
- core rules and invariants;
- states and state transitions;
- inputs, outputs and rewards;
- multiplayer interactions;
- progression and economy interactions;
- failure, interruption and recovery;
- abuse/exploit considerations;
- relevant edge cases;
- UI and interaction feedback;
- visual/audio feedback;
- accessibility implications;
- persistence expectations;
- tuneable parameters;
- analytics/telemetry expectations where design-relevant;
- monetization interactions where applicable;
- explicit non-goals.

An unresolved question that can alter implementation behavior blocks `Design Complete`.

## 6. Fixed Rules vs Tuneable Parameters

Design documents distinguish semantic rules from balance values.

A fixed rule defines **what happens**. A tuneable parameter defines **how much, how often, how fast, or how valuable** within that rule.

Playtesting may adjust tuneable values without silently changing semantic rules.

## 7. No Hidden Uncertainty

Terms such as `maybe`, `perhaps`, `TBD`, `something like`, or ambiguous uses of `could`/`might` are not acceptable in `Design Complete` rules when they conceal unresolved behavior.

Designed optionality is allowed only when its governing condition or player choice is explicit.

## 8. Multiplayer and Abuse Cases Are First-Class Design

Because MonsterVault is a multiplayer Roblox game, specifications must consider relevant adversarial and social cases, including:

- simultaneous claims on a creature or reward;
- disconnects during capture, transport, events or trading;
- griefing and spawn camping;
- collusion and alternate-account abuse;
- duplication/value-transfer exploits;
- AFK/offline progression abuse;
- server hopping and event rerolling;
- pay-to-win pressure;
- harassment or unsafe social mechanics.

Technical mitigations belong to Technical Architecture, but the intended player-facing rule belongs to the GDS.

## 9. Presentation Is Part of Design

Important states must have understandable feedback through appropriate combinations of UI, world-space presentation, animation, VFX, audio, haptics, prompts, and accessibility alternatives.

## 10. Roblox Platform Constraints

The design must remain compatible with Roblox platform policies and intended audience expectations. Platform constraints that change player-facing behavior are design constraints, not implementation afterthoughts.

## 11. No Premature Implementation

Gameplay implementation is blocked until the GDS is formally complete and the Technical Architecture is subsequently completed and locked.

Prototype code must not be used to bypass unresolved design decisions.

## 12. Change Control

When an established rule changes:

1. update its authoritative specification;
2. identify affected cross-references and dependent systems;
3. record a strategic design decision when rationale or trade-offs matter;
4. rerun relevant cross-system validation;
5. only then update implementation contracts/code.

## 13. Scope Control

Specifications must state explicit non-goals when ambiguity could create scope growth. MonsterVault does not inherit features merely because another Roblox collection game contains them.

## 14. Final Principle

For every approved subsystem, a developer should be able to answer:

> "What should the player experience and what should happen in this situation?"

from the specification rather than by inventing an answer in code.
