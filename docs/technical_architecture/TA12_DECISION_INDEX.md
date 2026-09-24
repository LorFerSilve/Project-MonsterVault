# TA-12 Decision Index

> **Phase:** TA-12 — Client Presentation, UI State, Input, Camera, Audio, and Accessibility  
> **Status:** Accepted

## TA12-D01 — Client State Is Projection, Presentation, or Preference — Never Gameplay Authority

**Decision:** Server-owned gameplay facts enter the client as read-only projections; local UI state is disposable; preferences can alter presentation only.

## TA12-D02 — Use Unidirectional Projection-to-View and Intent-to-Server Flow

**Decision:** Authoritative projections feed revision-aware client state and derived view models. Consequential actions submit semantic intent and wait for authoritative result.

## TA12-D03 — Use InputAction/InputContext as the Baseline Semantic Input Architecture

**Decision:** Core actions bind through Roblox InputAction/InputContext/InputBinding with touch, keyboard/mouse and gamepad parity instead of scattered raw-device checks.

## TA12-D04 — Do Not Depend on Beta InputActionLabel

**Decision:** MonsterVault resolves action glyph/text from InputAction.PreferredBinding through its own stable glyph registry; InputActionLabel beta is optional tooling only.

## TA12-D05 — Centralize Input Context, Modal and Focus Arbitration

**Decision:** One context/focus architecture uses fixed precedence PlatformMenuSuspended > SystemBlocked > Modal > CommittedGameplay > PanelNavigation > World, with single-owner dispatch and explicit sink rules. Modal/context dismissal keeps the triggering physical gesture sunk until release/completed/neutral before lower contexts become triggerable; predictable Back/Close and complete gamepad navigation remain mandatory.

## TA12-D06 — Prioritize Critical and Committed Presentation over Social/Commercial Noise

**Decision:** A presentation arbiter enforces GDS-14 information priority and queues/suppresses lower-priority Toasts/prompts without changing server obligations.

## TA12-D07 — Use Roblox Safe Areas and Responsive Reflow

**Decision:** Critical/actionable UI uses CoreUISafeInsets by default; layouts reflow/wrap/scroll across viewport classes instead of desktop-first shrink-only design.

## TA12-D08 — Treat Roblox Accessibility Preferences as Live First-Class Inputs

**Decision:** PreferredTextSize, PreferredTransparency and ReducedMotionEnabled are consumed immediately and cannot be weakened by MonsterVault settings.

## TA12-D09 — Persist MonsterVault Presentation Preferences as Non-Value-Critical State

**Decision:** Custom contrast, shake, captions, category volumes, sensitivity and safe notification/social preferences may persist as validated P1 settings while safe platform defaults remain available before profile readiness.

## TA12-D10 — Consequential UI Never Presents Final Success Optimistically

**Decision:** Capture ownership, Energy/progression, Release, trade, event reward and commercial entitlement success follow authoritative server/platform outcomes. A consequential command timeout is OutcomeUnknown/ReconciliationRequired, never a rejection; it triggers authoritative refresh and blocks blind duplicate irreversible submission until the owning domain resolves or proves retry safety.

## TA12-D11 — Key Exact-Instance UI by Semantic IDs and Virtualize Large Lists

**Decision:** Collection/trade/Vault UI uses CreatureInstanceId and other semantic IDs independent of recycled GuiObjects; large lists render bounded views.

## TA12-D12 — Use One Bounded Local Camera Presentation Owner

**Decision:** Baseline exploration retains Roblox Custom camera; temporary assists use one local owner with deterministic release on input, cancel, respawn and failure.

## TA12-D13 — Compose Reduced Motion Conservatively

**Decision:** Effective Reduced Motion is enabled if either Roblox or MonsterVault requests it, disables non-essential camera shake/motion and preserves all semantic feedback.

## TA12-D14 — Define Semantic Audio Categories and Captions Independent of Audio Playback Success

**Decision:** Audio is reinforcement only. Important sounds/dialogue have visual/text equivalents and semantic caption events; TA-17 selects the concrete current Audio object graph.

## TA12-D15 — Keep Localization Text Separate from Semantic Identity

**Decision:** Player-facing text is localization-key driven and expansion-tolerant; localized strings never become gameplay IDs or branching keys.

## TA12-D16 — Yield to Roblox Platform Safety UI

**Decision:** Roblox menu/report/settings paths remain reachable, gameplay contexts suspend while platform UI owns interaction, and core play never requires chat or voice.

## TA12-D17 — Keep Commercial Presentation Bound to TA-11 Truth

**Decision:** Shop price/content/Pending/reconciliation are projections of current platform/server state; commercial UI cannot steal critical focus or fabricate entitlement.

## TA12-D18 — Close TA-12 and Advance to TA-13

**Decision:** TA-12 is Architecture Complete — PASS with 300/300 scenarios and zero blocking questions. TA-13 becomes NEXT; gameplay implementation remains blocked until TA-17.
