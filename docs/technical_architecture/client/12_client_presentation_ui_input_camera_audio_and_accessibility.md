# TA-12 — Client Presentation, UI State, Input, Camera, Audio, and Accessibility

> **Status:** Architecture Complete  
> **Owning TA phase:** TA-12 — Client Presentation, UI State, Input, Camera, Audio, and Accessibility  
> **Authority:** disposable client state projection, UI layering and state binding, semantic input/action routing, device switching, focus/modal ownership, HUD/panel/notification presentation, confirmation flows, safe-area/responsive layout, camera presentation ownership, motion/VFX policy, audio/caption routing, accessibility preference composition and persistence, localization plumbing, authoritative outcome feedback, reconnect/reconciliation presentation  
> **Depends on:** TA-0 through TA-11 Architecture Complete; GDS-3, GDS-14, GDS-15, GDS-16, GDS-17

## 1. Purpose

TA-12 translates GDS-14 into a client architecture that makes authoritative gameplay understandable and operable across touch, keyboard/mouse and gamepad without creating a second gameplay authority.

The client architecture contract is:

> **The client owns presentation, focus, local navigation, input interpretation and reversible view state. The server owns gameplay truth. Authoritative projections flow one way into revision-aware client state; player actions flow back as semantic intent. Consequential UI never invents success. Input is action-based rather than device-specific, modal/focus ownership is explicit, low-priority presentation yields to committed/safety states, Roblox accessibility preferences are respected immediately, and all core actions remain reachable without hover, drag, chat, voice or one specific device.**

TA-12 introduces no gameplay implementation modules. Concrete module names, ScreenGui hierarchy, InputAction instances, localization tables, assets and test harness files remain TA-17 implementation artifacts.

## 2. Domain Ownership

TA-12 owns:

- disposable client application state and presentation projections;
- server-projection-to-view binding;
- local-only view/navigation state;
- semantic input actions and input contexts;
- touch/keyboard/mouse/gamepad parity;
- dynamic input glyph resolution;
- world interaction prompt presentation;
- UI root/layer ordering;
- primary modal ownership and focus stack;
- confirmation severity rendering;
- responsive/safe-area layout policy;
- collection/list virtualization presentation contract;
- notification priority, suppression, aggregation and persistence;
- Pending/success/failure/rejection presentation;
- local countdown/timer display from authoritative timestamps;
- camera presentation ownership/arbitration;
- Reduced Motion, shake and VFX presentation policy;
- audio category routing and non-audio equivalents;
- captions/subtitles;
- composition of Roblox accessibility preferences with MonsterVault settings;
- persistence/reconciliation of non-authoritative presentation preferences;
- localization and text-expansion plumbing;
- client-side performance/degradation rules;
- UI security/privacy boundaries.

TA-12 does not own:

- server gameplay authority or validation — TA-3 and domain TAs;
- persistent-value transaction semantics — TA-4/7/8/10/11;
- platform communication/moderation eligibility policy — GDS-15 plus TA-13/15/17 integration;
- analytics experiments/live configuration — TA-13;
- exact device/network/UI/memory budgets — TA-14;
- security/fault/automated UI harnesses — TA-15;
- cross-system readiness audit — TA-16;
- concrete implementation file/module/instance names — TA-17.

## 3. Client Trust Boundary

Client state is partitioned into three classes.

### 3.1 Authoritative Projection

Read-only presentation of server-owned facts such as:

- trusted profile readiness;
- Energy/capacity;
- exact owned Creature Instances;
- Capture/Transport state;
- progression/mastery;
- event occurrence/phase/contribution/reward state;
- Party/trade state;
- commercial entitlement/Purchase Pending state.

### 3.2 Local Presentation State

Disposable client-only state such as:

- open panel/tab;
- scroll position;
- local sort/filter;
- current focus target;
- hover/selection highlight;
- notification animation position;
- camera interpolation state;
- local caption timing;
- temporary input-family/glyph state.

### 3.3 User Preference State

Non-gameplay settings such as:

- MonsterVault readability/contrast preference;
- camera shake preference;
- caption preference;
- audio category levels;
- control sensitivity;
- Social Ping suppression;
- safe notification-intensity preference.

### CLIENT-12-01

Local Presentation State never becomes evidence that a server mutation succeeded.

### CLIENT-12-02

User Preference State may alter presentation/input sensitivity but never gameplay odds, authority, rewards or eligibility.

### CLIENT-12-03

Client caches are disposable; reconnect/resync can reconstruct authoritative presentation from server projections.

## 4. Unidirectional Client Data Flow

Baseline flow:

```text
server authoritative state
  -> typed projection route
  -> projection adapter
  -> revision-aware client application store
  -> derived view model
  -> UI / HUD / prompt / camera / audio / caption presentation

physical input
  -> InputBinding / InputAction
  -> semantic action router
  -> local UI navigation OR validated command intent
  -> server command
  -> authoritative outcome/projection
  -> client presentation
```

### FLOW-12-01

UI components do not call DataStore/Marketplace/domain authority directly.

### FLOW-12-02

A consequential button submits semantic intent and enters Pending only where the owning server contract supports Pending.

### FLOW-12-03

Success presentation follows authoritative acknowledgment/projection, not button activation.

## 5. Projection Revisions and Resynchronization

Each projected domain uses its upstream revision/version contract.

### PROJ-12-01

Stale revisions are ignored.

### PROJ-12-02

A projection that requires a missing predecessor/base state triggers domain resynchronization/snapshot refresh rather than speculative merge.

### PROJ-12-03

Reconnect clears disposable assumptions and rebuilds from current authoritative projections.

### PROJ-12-04

UI identity uses semantic/runtime IDs such as CreatureInstanceId, EventOccurrenceId, TradeSessionId and ProductDefinitionId rather than Roblox Instance paths or display names.

## 6. Local Optimism Boundary

Allowed optimism is presentation-only and reversible:

- button pressed state;
- opening/closing safe panels;
- filter/sort;
- hover/focus;
- local camera interpolation;
- interpolated countdown display;
- predicted progress animation that is visibly subordinate to authoritative state.

Forbidden optimism includes presenting as finalized:

- capture ownership;
- Energy spend/grant;
- progression purchase;
- Release;
- trade commit;
- event reward;
- commercial entitlement/purchase;
- capacity reconciliation.

### OPT-12-01

If an authoritative rejection arrives, local presentation converges to server truth without replaying or compensating value locally.

## 7. UI Root and Layer Model

TA-12 defines semantic presentation layers, not exact ScreenGui instance names.

Lowest to highest priority:

1. **World HUD Layer** — ordinary Energy/region/objective/context.
2. **Context / Committed-State Layer** — capture, custody, extraction, event/action state.
3. **Panel Layer** — collection, Vault, progression, social, event/shop panels.
4. **Notification Layer** — queued Toasts and transient notices.
5. **Modal Layer** — one primary consequential modal flow.
6. **Critical Trust Layer** — Protected Load Failure, unresolved system-blocking transaction state.
7. **Platform/Core UI** — Roblox-owned system UI remains accessible and unobstructed.

### LAYER-12-01

Lower-priority MonsterVault layers cannot obscure or steal focus from higher-priority semantic state.

### LAYER-12-02

Critical Trust presentation cannot be covered by commercial/social Toasts.

### LAYER-12-03

Roblox report/settings/menu paths are not visually or input-wise trapped behind MonsterVault UI.

## 8. Presentation Priority Arbiter

One client arbiter evaluates GDS-14 priority:

1. safety/trust;
2. committed gameplay;
3. time-critical opportunity;
4. immediate interaction;
5. persistent progression;
6. social/commercial/informational.

The arbiter determines:

- notification eligibility;
- modal opening permission;
- focus stealing;
- camera assist eligibility;
- whether low-priority audio/animation is suppressed;
- whether a commercial/social prompt is queued or discarded.

### PRIORITY-12-01

Priority affects presentation only; it cannot suppress a server-owned obligation or transaction.

## 9. Semantic Input Baseline

TA-12 selects Roblox **InputAction / InputContext / InputBinding** as the baseline semantic input architecture.

An InputAction represents intent such as:

- PrimaryInteract;
- PrimaryAction;
- Back;
- Confirm;
- OpenCollection;
- OpenVault;
- OpenMap/Event;
- Navigate;
- CameraLook;
- Zoom;
- UI tab/section actions where justified.

### INPUT-12-01

Gameplay/UI logic subscribes to semantic actions, not raw KeyCodes as its primary contract.

### INPUT-12-02

Each core semantic action has supported touch, keyboard/mouse and gamepad bindings.

### INPUT-12-03

Roblox-reserved/system inputs are not overridden.

### INPUT-12-04

The beta InputActionLabel is not a production dependency. MonsterVault resolves its own glyph/text presentation from InputAction.PreferredBinding and a stable glyph registry.

### INPUT-12-05

ContextActionService is not a second parallel gameplay input architecture. If TA-17 requires a narrow compatibility adapter, it must feed the same semantic action interface.

## 10. Input Context Stack

Baseline contexts use one explicit precedence order, highest first:

1. **PlatformMenuSuspended** — Roblox/Core UI owns interaction; MonsterVault semantic actions are suspended/sunk.
2. **SystemBlockedContext** — Critical Trust/recovery UI owns input; all irreversible gameplay/commercial/trade actions are sunk.
3. **ModalContext** — the one primary modal owns Confirm/Back/navigation and any shared PrimaryAction/PrimaryInteract binding.
4. **CommittedGameplayContext** — capture/custody/trade-specific actions own conflicting gameplay bindings while no higher context is active.
5. **PanelNavigationContext** — a safe non-modal panel owns its UI navigation/Confirm/Back and any shared action bindings while focused.
6. **WorldContext** — ordinary PrimaryInteract/PrimaryAction/navigation receives only actions not owned or sunk above.

Dispatch is **single-owner per semantic action event**: scan active contexts from highest to lowest; the first context that either handles or explicitly sinks the action terminates dispatch. The same semantic action event is never fanned out to multiple contexts.

Sink policy:

- PlatformMenuSuspended sinks all MonsterVault gameplay/UI actions until platform ownership ends.
- SystemBlockedContext sinks all gameplay/value actions and exposes only explicitly safe recovery/system/accessibility actions.
- ModalContext sinks Confirm, Back, navigation, PrimaryAction, PrimaryInteract and any physical binding participating in the modal flow.
- CommittedGameplayContext sinks ordinary world/panel aliases that could conflict with the committed operation; unrelated panel opening is suppressed where GDS-14 requires dominance.
- PanelNavigationContext sinks its navigation/Confirm/Back/shared action bindings while focused. Movement/camera may pass only when the panel is explicitly non-modal, the bindings are distinct, and no consequential action can be triggered underneath.
- WorldContext is the fallback and never receives an action already handled/sunk above.

### INPUTCTX-12-01

Only contexts valid for the current authoritative/presentation mode are enabled.

### INPUTCTX-12-02

Opening/enabling a higher context, including `ModalContext`, activates an **Input Handoff Guard** for the physical input(s) that caused the transition. Those inputs remain sunk against both the newly enabled context and every lower context until they reach completed/released/neutral. The modal may prepare visual focus immediately, but Confirm, PrimaryAction, PrimaryInteract or another consequential action cannot consume the opening gesture; a subsequent fresh gesture is required.

### INPUTCTX-12-03

The precedence and sink table above is architecture authority; TA-17 may choose concrete InputContext priority numbers but may not reorder the semantic precedence.

### INPUTCTX-12-04

Closing/dismissing a higher context does not immediately expose lower contexts to the same physical gesture. The outgoing context or a short-lived **Input Handoff Guard** continues to sink every binding that participated in dismissal until that keyboard/gamepad/touch/pointer input has reached its completed/released/neutral state. Only a subsequent fresh gesture may reach the newly exposed lower context.

### INPUTCTX-12-05

If several physical inputs map to the same semantic action, neutralization is tracked for the actual input(s) that caused the transition; unrelated already-neutral controls do not delay restoration.

## 11. Input Family and Glyph Switching

Input glyphs are derived from current preferred bindings/input family.

### GLYPH-12-01

Changing between keyboard/mouse, touch and gamepad updates glyph presentation without changing semantic capability.

### GLYPH-12-02

A glyph is paired with semantic action text for critical/context prompts.

### GLYPH-12-03

Device switching does not close safe panels, reset trade review, restart confirmation or clear authoritative Pending state.

### GLYPH-12-04

If a preferred binding cannot be represented by a known glyph, localized textual binding fallback is used instead of a blank prompt.

## 12. Active Context Prompt

The prompt view binds to the GDS-3 Active Context projection/candidate outcome.

Conceptual prompt view model:

- target semantic/runtime ID;
- expected runtimeRevision/context revision;
- semantic action key;
- localized action label;
- preferred binding/glyph;
- eligibility/rejection reason;
- priority;
- target world anchor if present.

### PROMPT-12-01

Prompt changes follow Active Context policy rather than per-frame nearest-object flicker.

### PROMPT-12-02

Prompt visibility does not authorize the server action.

### PROMPT-12-03

Stream-out/missing local target hides/degrades local anchoring but does not fabricate entity destruction.

## 13. Modal and Focus Ownership

There is exactly one primary modal focus owner.

A client Focus Manager tracks:

- active modal/panel owner;
- previously selected semantic control key;
- deterministic fallback target;
- current GuiService.SelectedObject integration;
- input context before/after modal;
- platform-menu suspension.

### FOCUS-12-01

Every actionable core gamepad control is Selectable/reachable.

### FOCUS-12-02

Explicit directional selection links are authored where automatic navigation is ambiguous.

### FOCUS-12-03

Closing a modal restores the previous valid control or a deterministic safe fallback.

### FOCUS-12-04

A destroyed/virtualized prior control does not receive focus; restore by semantic key/fallback.

### FOCUS-12-05

Back never implicitly confirms Buy, Release, Trade, Unlock or another consequential action.

### FOCUS-12-06

Focus/context activation or restoration around modal entry/dismissal is subject to INPUTCTX-12-02 and INPUTCTX-12-04. Visual focus may be prepared immediately, but the opening or dismissal input remains guarded through completed/released/neutral; newly focused or newly exposed consequential actions remain non-triggerable until then, and modal confirmation after entry requires a fresh gesture.

## 14. Confirmation Severity Architecture

TA-12 implements GDS-14 levels as reusable semantic components:

- Level 0 — immediate reversible;
- Level 1 — standard confirmation;
- Level 2 — strong exact-target confirmation;
- Level 3 — blocking trust state, not a confirm dialog.

A confirmation view model includes:

- semantic operation type;
- exact target/value identifiers;
- localized consequence;
- persistence/irreversibility label;
- distinguishing high-value facts;
- current authoritative revision/quote/trade revision;
- safe cancel/back action;
- confirm eligibility.

### CONFIRM-12-01

Level 2 confirmation cannot be satisfied by generic Back/Close.

### CONFIRM-12-02

If the underlying revision/quote/target changes, confirmation invalidates and returns to review.

## 15. Safe Areas and Responsive Layout

Interactive and critical UI uses Roblox safe-area semantics.

### SAFE-12-01

Critical/modal/actionable layout stays inside CoreUISafeInsets by default.

### SAFE-12-02

Decorative/noninteractive presentation may use DeviceSafeInsets when it cannot collide with CoreGui/mobile control zones.

### SAFE-12-03

HUD avoids default mobile thumbstick/jump/action regions and preserves world visibility.

### SAFE-12-04

Console/TV layout keeps critical controls/text inside a television-safe content region.

### SAFE-12-05

Layout responds to viewport class/aspect ratio/content size rather than device-name branching alone.

Responsive strategies include:

- content-driven AutomaticSize;
- wrapping;
- collapsible/split layouts;
- scrollable overflow;
- minimum interaction sizes;
- semantic reflow instead of merely shrinking everything.

## 16. Text Size and Layout Scaling

Roblox PreferredTextSize is a first-class input.

### TEXTSIZE-12-01

Core/critical text must honor PreferredTextSize changes during the session.

### TEXTSIZE-12-02

Critical text avoids relying on TextScaled alone because TextScaled does not automatically honor PreferredTextSize.

### TEXTSIZE-12-03

AutomaticSize, TextWrapped, text measurement and bounded size constraints are used so larger text does not hide actions or truncate meaning.

### TEXTSIZE-12-04

A MonsterVault larger/readability mode may further increase readability but cannot reduce below the effective Roblox preference.

## 17. Collection and Large-List Presentation

Collection/Trade/Vault lists use stable semantic item keys.

### LIST-12-01

Creature cards are keyed by CreatureInstanceId; Species/group presentation never replaces exact-instance identity when the action targets an instance.

### LIST-12-02

Large scrolling sets use bounded rendering/virtualization or recycling where needed; UI object identity is never gameplay identity.

### LIST-12-03

Virtualization preserves keyboard/gamepad navigation through semantic item order and restores focus after recycling.

### LIST-12-04

Filter/sort are local presentation operations unless a downstream scale limit explicitly requires server pagination.

## 18. Notification Architecture

Notification classes:

- Critical;
- CommittedState;
- TimeSensitive;
- Progression;
- Social;
- InformationalCommercial.

A Notification Coordinator owns:

- priority queue;
- coalescing key;
- dedupe window;
- relevance predicate;
- expiry;
- persistent-state handoff;
- accessibility intensity policy.

### NOTIFY-12-01

Low-priority Toasts queue during committed/critical state and show later only if still relevant.

### NOTIFY-12-02

Repeated equivalent notices aggregate/suppress.

### NOTIFY-12-03

Required action is represented by underlying persistent state, never only a disappearing Toast.

### NOTIFY-12-04

Notification-intensity preference may reduce non-essential presentation but cannot hide Critical/Committed safety state.

## 19. Authoritative Feedback and Error Presentation

Every consequential command has presentation states appropriate to its domain, conceptually:

`Idle -> Submitting -> Pending? -> Confirmed | Rejected | ReconciliationRequired`

### FEEDBACK-12-01

Submitting is local request progress, not semantic success.

### FEEDBACK-12-02

Rejected commands restore/retain authoritative state and show actionable semantic reason.

### FEEDBACK-12-03

Retry controls are exposed only where the upstream operation is safe/idempotent or uses a new server-issued quote/revision.

### FEEDBACK-12-04

Trade/purchase uncertain outcomes remain visible as persistent Pending/Reconciliation state.

### FEEDBACK-12-05

A transport/request timeout for a consequential command is **not** a rejection. It transitions the presentation from Submitting/Pending to a non-success **ReconciliationRequired / OutcomeUnknown** state, triggers the owning domain's authoritative refresh/reconciliation path required by TA-3, and prevents a blind second irreversible attempt while the first outcome is unknown.

### FEEDBACK-12-06

After reconciliation, presentation moves to Confirmed, Rejected/NotApplied, or remains Pending/Unknown according to authoritative state. A retry control appears only if the upstream domain proves retry/idempotency safety and preserves the required operation/quote/revision identity.

## 20. Authoritative Time Presentation

Client countdowns derive from server-provided absolute boundaries and the synchronized server-time reference.

### TIME-12-01

Client device wall clock is not authoritative.

### TIME-12-02

Countdown interpolation is presentation-only and clamps at terminal boundaries until authoritative state arrives.

### TIME-12-03

Reconnect/server hop reconstructs Event/Trade Cooldown/commercial timing from current authoritative state rather than continuing a stale local timer.

## 21. Camera Ownership and Arbitration

Baseline exploration retains Roblox's familiar Custom camera behavior.

Temporary MonsterVault camera assistance is mediated by one Camera Presentation Controller with a local ownership token/stack.

Camera request classes:

- onboarding attention cue;
- capture framing;
- event framing;
- inspection/showcase;
- recovery transition;
- modal/presentation preview.

### CAMERA-12-01

Only one MonsterVault camera assist owns Scriptable/custom override at a time.

### CAMERA-12-02

Player camera input cancels/yields bounded assistance where GDS-14 requires player control.

### CAMERA-12-03

Every temporary camera override has deterministic release/restoration on completion, cancel, character replacement, modal close, error and shutdown of its owning client state.

### CAMERA-12-04

Server messages may identify a semantic target/cue but do not stream authoritative camera CFrames as gameplay truth.

### CAMERA-12-05

Camera state never determines server interaction eligibility.

## 22. Reduced Motion, Camera Shake and VFX

Effective Reduced Motion is true if either:

- Roblox GuiService.ReducedMotionEnabled is true; or
- the player's MonsterVault Reduced Motion preference requests it.

### MOTION-12-01

Reduced Motion replaces non-essential tween/parallax/zoom/shake with snap/fade/static alternatives while preserving result semantics.

### MOTION-12-02

Effective Reduced Motion disables non-essential camera shake.

### MOTION-12-03

A separate camera-shake setting may reduce/disable shake even when Reduced Motion is false.

### MOTION-12-04

Critical feedback never depends on rapid flashing/full-screen motion.

### MOTION-12-05

VFX degradation cannot hide hazard, prompt, focus or target semantics.

## 23. Audio and Caption Architecture

TA-12 defines semantic audio categories:

- Master multiplier;
- Music;
- Effects;
- Voice/Dialogue where used;
- UI/Notification where useful.

The client uses an Audio Mixer abstraction. TA-17 binds it to the current Roblox audio object API; new architecture does not require legacy SoundGroup as its semantic contract.

### AUDIO-12-01

Audio is reinforcement; critical outcomes always have visual/text equivalents.

### AUDIO-12-02

Instructional authored dialogue has subtitle/text equivalent.

### AUDIO-12-03

Actionable non-dialogue sound cues can emit semantic caption events independent of whether the audio asset successfully plays.

### AUDIO-12-04

Caption text originates from localization keys/semantic events, not speech-to-text at runtime.

### AUDIO-12-05

Roblox/platform master volume remains outside MonsterVault authority.

## 24. Roblox Accessibility Preference Composition

TA-12 consumes current local platform preferences:

- GuiService.PreferredTextSize;
- GuiService.PreferredTransparency;
- GuiService.ReducedMotionEnabled.

### A11Y-12-01

Platform PreferredTextSize is respected immediately and on change.

### A11Y-12-02

PreferredTransparency is used to make readability backgrounds at least as opaque/readable as the player's platform preference. MonsterVault contrast/readability mode may strengthen, never weaken, that preference.

### A11Y-12-03

Roblox ReducedMotionEnabled cannot be overridden off by a MonsterVault setting.

### A11Y-12-04

Accessibility preference application is available before trusted gameplay profile readiness because the Roblox preferences are local read-only inputs.

## 25. MonsterVault Presentation Preferences

Persistable non-authoritative preferences include:

- additional readability/contrast mode;
- MonsterVault Reduced Motion;
- camera shake;
- captions;
- music/effects/dialogue/UI category levels;
- control sensitivity;
- Social Ping suppression;
- non-essential notification intensity.

### PREF-12-01

Preferences are bounded/validated and cannot encode gameplay state.

### PREF-12-02

Session-local application may be immediate/optimistic because it changes presentation only.

### PREF-12-03

Cross-session persistence is P1/non-value-critical through TA-4-compatible profile/settings storage. Save failure does not block gameplay or revert safety/accessibility system preferences.

### PREF-12-04

Before persisted preferences load, safe defaults plus Roblox platform preferences apply. Later reconciliation updates only presentation.

### PREF-12-05

Critical notices, safety states and required confirmations cannot be disabled by preference.

## 26. Localization and Text Plumbing

All player-facing semantic copy is localization-key driven.

### LOC-12-01

Gameplay logic does not branch on localized display strings.

### LOC-12-02

Layouts tolerate text expansion using responsive sizing/wrapping/scrolling.

### LOC-12-03

Numbers, prices and timers are formatted through locale-aware presentation helpers.

### LOC-12-04

Missing localization falls back to source text/key-safe presentation without hiding the action.

### LOC-12-05

User-authored/uncontrolled text is displayed only through Roblox-supported filtering/communication paths; MonsterVault does not reconstruct unfiltered source text.

## 27. Social / Platform Safety Presentation

### SAFETY-12-01

Core flow works when chat/voice are absent.

### SAFETY-12-02

Structured Pings, Party state and Trade UI carry required coordination vocabulary.

### SAFETY-12-03

Roblox reporting/settings/menu capability remains reachable; MonsterVault does not replace or obscure platform safety UI.

### SAFETY-12-04

When platform/CoreGui menu owns interaction, MonsterVault suspends conflicting gameplay input contexts.

### SAFETY-12-05

Known blocking/restriction state suppresses directed invite/Ping/trade affordances without altering finalized gameplay value.

## 28. Commercial Presentation Integration

TA-12 consumes TA-11 product/price/Pending/reconciliation projections.

### COMMERCE-UI-12-01

Displayed custom price comes from current runtime platform product metadata.

### COMMERCE-UI-12-02

Product contents, durable/one-time semantics and free route are visible before purchase.

### COMMERCE-UI-12-03

Purchase Pending, success, failure and reconciliation are distinct states.

### COMMERCE-UI-12-04

Commercial prompts cannot seize focus during higher-priority capture/custody/trade/recovery/trust state.

### COMMERCE-UI-12-05

Commercial cosmetics are visually distinguished from intrinsic Species/Mutation/Variant identity.

## 29. Load, Reconnect and Reconciliation Presentation

### RECON-12-01

Materially delayed trusted profile readiness has a non-success loading presentation.

### RECON-12-02

Protected Load Failure is Level 3 Critical Trust UI and exposes only safe actions.

### RECON-12-03

Reconnect rebuilds authoritative state without replaying old celebratory animations as if value were newly granted.

### RECON-12-04

Capacity reconciliation explicitly states that Overflow-Held preserves ownership.

### RECON-12-05

Unresolved trade/purchase state persists until authoritative reconciliation; closing a panel does not erase the obligation.

## 30. Performance and Degradation Principles

Before TA-14 locks numbers:

- no one RenderStepped/Heartbeat loop per ordinary UI widget;
- centralized update clocks for timers where practical;
- no full collection re-render for unrelated single-item mutation;
- large lists virtualize/recycle;
- expensive world-space UI is distance/relevance bounded;
- low-priority animation/VFX may degrade first;
- authoritative semantic state never degrades;
- UI assets load asynchronously with semantic text fallback;
- missing cosmetic art does not hide identity/action facts.

## 31. Security and Privacy

### SECUI-12-01

Client UI never exposes server-private odds, hidden Variant rolls, receipt internals or moderation internals.

### SECUI-12-02

Remote/command payloads are built from stable semantic IDs and server-issued revisions/quotes where required; arbitrary client Instance paths are not authority.

### SECUI-12-03

Clipboard/external-link/freeform-text features are not introduced as core gameplay dependencies.

### SECUI-12-04

Logs/analytics from client presentation avoid private chat contents, full profiles and unnecessary accessibility-sensitive detail; TA-13 owns exact analytics schemas.

## 32. Testability Hooks

TA-12 requires deterministic injectable/simulatable inputs for:

- viewport size/aspect/safe insets;
- PreferredTextSize/PreferredTransparency/ReducedMotion;
- input family/preferred bindings;
- gamepad focus transitions;
- localization expansion;
- authoritative projection revisions/out-of-order delivery;
- Pending/rejection/reconciliation states;
- platform-menu open/close;
- camera owner transitions;
- caption/audio event routing;
- collection size/virtualization;
- reconnect/profile readiness.

## 33. Downstream Handoffs

### TA-13

Owns analytics event schemas, UI experiments, feature flags/live rollout, notification/offer experiments and admin tooling without weakening semantic clarity/accessibility.

### TA-14

Locks UI update, viewport/device, network projection, collection virtualization, memory, timer, audio/VFX and input latency budgets.

### TA-15

Defines automated UI/input/focus/accessibility/fault/security validation and regression gates.

### TA-16

Audits client/server authority, accessibility, commerce, social safety, performance and recovery integration.

### TA-17

Locks concrete client modules, ScreenGui hierarchy, InputContext/InputAction instances, localization tables, assets, settings schema and implementation sequence.

## 34. Critical Invariants

1. Client presentation never becomes gameplay/value authority.
2. Consequential success follows authoritative outcome, not click/tap.
3. Stale projection revisions cannot overwrite newer client state.
4. Local presentation state is disposable and reconnect-resynchronizable.
5. One primary consequential modal owns focus.
6. Modal input cannot fall through into world actions.
7. Core actions have touch/keyboard-mouse/gamepad semantic parity.
8. Dynamic glyph changes never change capability or transaction state.
9. Critical/actionable UI respects safe areas and remains reachable.
10. PreferredTextSize/PreferredTransparency/ReducedMotion are respected as live platform preferences.
11. Accessibility preferences cannot hide critical/safety state.
12. Reduced Motion preserves semantics and disables non-essential shake/motion.
13. Camera assistance is local, bounded and always restores control.
14. Audio is never the sole carrier of gameplay-critical meaning.
15. Low-priority notifications/commercial prompts yield to critical/committed state.
16. Reconnect restores authoritative state without duplicate-success implication.
17. UI virtualization never replaces semantic exact-instance identity.
18. Localization strings never become gameplay keys/authority.
19. Platform reporting/settings/menu paths remain accessible.
20. Gameplay implementation remains blocked until TA-17.

## 35. Open Questions

There are **zero TA-12-blocking open questions**.

Correctly downstream/tuneable:

- exact UI dimensions/target sizes/breakpoints — TA-14/17;
- exact InputAction names/bindings and concrete instances — TA-17;
- exact font/theme/icon assets — content/TA-17;
- exact Audio API object graph — TA-17 after current-platform revalidation;
- exact notification durations/queue caps — TA-14/17;
- exact settings-save debounce/retry cadence — TA-14/17;
- analytics/experiment events — TA-13;
- automated accessibility/device matrix — TA-15.

## 36. Architecture-Complete Checklist

- [x] disposable client authority boundary explicit;
- [x] unidirectional projection/intent flow explicit;
- [x] revision/resync behavior explicit;
- [x] semantic InputAction/InputContext architecture explicit;
- [x] cross-device parity/glyph switching explicit;
- [x] modal/focus/gamepad navigation explicit;
- [x] safe-area/responsive/text-scale behavior explicit;
- [x] notification/confirmation/error architecture explicit;
- [x] authoritative Pending/reconciliation presentation explicit;
- [x] camera ownership/restore behavior explicit;
- [x] Reduced Motion/VFX/audio/caption architecture explicit;
- [x] Roblox accessibility preference composition explicit;
- [x] MonsterVault preference persistence explicit;
- [x] localization/text-filtering boundary explicit;
- [x] social/platform/commercial UI boundaries explicit;
- [x] reconnect/load/reconciliation presentation explicit;
- [x] performance/security/testability explicit;
- [x] zero implementation-critical TA-12 questions.
