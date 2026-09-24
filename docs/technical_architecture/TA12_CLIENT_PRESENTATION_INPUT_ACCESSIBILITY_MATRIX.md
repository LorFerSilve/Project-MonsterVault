# TA-12 Client Presentation / Input / Accessibility Matrix

> **Phase:** TA-12  
> **Status:** PASS

## 1. State Ownership

| State | Owner | Client persistence |
|---|---|---|
| Energy/ownership/progression | server domain TA | projection only |
| capture/custody/event/trade/commercial state | server domain TA | projection only |
| open panel/tab/filter/scroll | client presentation | disposable |
| focus/hover/selection highlight | client presentation | disposable |
| camera interpolation | client presentation | disposable |
| accessibility/presentation preference | user preference + validated persistence | P1 where persisted |
| Roblox PreferredTextSize/Transparency/ReducedMotion | Roblox client setting | local platform authority |

## 2. UI Layer Priority

| Layer | Priority | May steal focus from higher layer? |
|---|---:|---:|
| World HUD | low | NO |
| Context / Committed State | medium-high | NO |
| Panel | medium | NO |
| Notification | classified | NO |
| Modal | high | only when allowed by arbiter |
| Critical Trust | highest MonsterVault | n/a |
| Roblox/Core UI | platform-owned | MonsterVault must yield |

## 3. Input Contexts

| Precedence | Context | Owns / sinks |
|---:|---|---|
| 1 highest | PlatformMenuSuspended | sinks all MonsterVault semantic actions while Roblox/Core UI owns interaction |
| 2 | SystemBlocked | owns safe recovery/system/accessibility actions; sinks all gameplay/value actions |
| 3 | Modal | owns Confirm/Back/navigation and shared PrimaryAction/PrimaryInteract bindings; sinks lower-context copies |
| 4 | CommittedGameplay | owns capture/custody/trade-specific actions; sinks conflicting ordinary world/panel actions |
| 5 | PanelNavigation | owns panel navigation/Confirm/Back/shared actions while focused; only explicitly non-conflicting movement/camera may pass |
| 6 fallback | World | receives only actions not handled/sunk above |

For each semantic action event, the first active context in this order that handles or sinks it terminates dispatch. Any context transition caused by physical input installs an Input Handoff Guard for the triggering input until release/completed/neutral. On modal entry, that input is sunk against the newly enabled Modal context as well as every lower context, so opening focus may appear but Confirm/PrimaryAction cannot fire until a fresh gesture. On dismissal, the same rule prevents the closing gesture from reaching newly exposed lower contexts.

## 4. Cross-Device Action Contract

| Capability | Touch | Keyboard/mouse | Gamepad |
|---|---:|---:|---:|
| Primary Interact | YES | YES | YES |
| Primary Action | YES | YES | YES |
| Back/Cancel | YES | YES | YES |
| Confirm | YES | YES | YES |
| Collection/Vault navigation | YES | YES | YES |
| Trade review/confirmation | YES | YES | YES |
| Accessibility/settings | YES | YES | YES |

No core action requires hover, right-click, drag, keyboard chord or pointer emulation.

## 5. Focus Matrix

| Event | Focus result |
|---|---|
| modal opens | deterministic first/remembered valid control may be prepared immediately; opening input remains guarded through neutral and cannot confirm |
| nested strong confirmation | confirmation owns primary focus |
| modal closes | prepare prior valid target/fallback, but lower actions remain sunk until dismissal gesture reaches release/neutral |
| focused virtualized item removed | nearest deterministic semantic fallback |
| device switches to gamepad | select current/first valid control |
| device switches away from gamepad | state preserved; visual selection may relax |
| Roblox menu opens | MonsterVault input suspended |
| Roblox menu closes | restore current safe context |

## 6. Safe Area Matrix

| Surface | Baseline inset |
|---|---|
| critical trust UI | CoreUISafeInsets |
| modal/confirmation | CoreUISafeInsets |
| actionable HUD controls | CoreUISafeInsets |
| normal HUD info | CoreUISafeInsets / carefully validated DeviceSafeInsets |
| decorative noninteractive edge art | DeviceSafeInsets permitted |
| TV/console critical content | additional TV-safe constraint |

## 7. Accessibility Composition

| Preference | Effective policy |
|---|---|
| Roblox PreferredTextSize | always honored |
| MonsterVault larger/readability text | may increase, never reduce below platform preference |
| Roblox PreferredTransparency | minimum readability/opacity requirement |
| MonsterVault enhanced contrast | may strengthen |
| Roblox ReducedMotionEnabled | forces effective Reduced Motion |
| MonsterVault Reduced Motion | can also force effective Reduced Motion |
| camera shake off | disables shake independently |
| captions on | semantic caption events shown |
| lower notification intensity | only non-essential notifications reduced |

## 8. Consequential Feedback

| Operation | Local click may show success? | Authority |
|---|---:|---|
| filter/sort | YES, reversible presentation | client |
| capture success/ownership | NO | TA-7/server |
| Energy purchase | NO | TA-8/server |
| Release | NO | TA-4/ownership server |
| trade commit | NO | TA-10/server |
| event reward | NO | TA-10/server |
| entitlement/purchase | NO | TA-11/platform+server |

## 8A. Consequential Timeout Matrix

| Condition | Presentation / action |
|---|---|
| request acknowledged success | wait for/apply authoritative confirmed projection |
| explicit authoritative rejection | Rejected with actionable semantic reason |
| transport/request timeout | OutcomeUnknown / ReconciliationRequired; never treat as rejection |
| unknown outcome | trigger authoritative domain refresh/reconciliation and block blind duplicate irreversible submit |
| reconciliation proves applied | Confirmed/current authoritative state |
| reconciliation proves not applied | Rejected/NotApplied; safe retry only under upstream identity rules |
| reconciliation remains unknown | persistent Pending/Unknown state |

## 9. Notification Matrix

| Class | Can queue? | Can user suppress? |
|---|---:|---:|
| Critical | persistent | NO |
| CommittedState | persistent/current | NO |
| TimeSensitive | bounded | not if required |
| Progression | YES | presentation intensity only |
| Social | YES | YES where safe |
| InformationalCommercial | YES/drop if stale | YES |

## 10. Camera Matrix

| Request | May override camera? | Reduced Motion behavior |
|---|---:|---|
| ordinary exploration | NO; Roblox Custom | unchanged |
| onboarding cue | bounded | snap/static highlight |
| capture framing | bounded | reduced movement |
| event framing | bounded | reduced movement |
| inspection/showcase | user-invoked | reduced transition |
| system trust state | no decorative camera motion | static |

## 11. Text / Localization Matrix

| Risk | Required architecture |
|---|---|
| large PreferredTextSize | reflow/wrap/AutomaticSize |
| TextScaled-only critical text | prohibited unless compensated |
| long localization | responsive growth/scroll |
| localized display name used as ID | prohibited |
| missing translation | source/fallback text |
| user-controlled text | supported filtering path |

## 12. Reconnect / Reconciliation

| Condition | Presentation |
|---|---|
| delayed profile readiness | loading/not-ready |
| Protected Load Failure | Critical Trust layer |
| reconnect after finalized reward | current state; no duplicate celebration implication |
| Purchase Pending | persistent Pending/reconciliation |
| unresolved trade commit | persistent blocking/reconciliation |
| capacity loss creates Overflow | ownership-preserving explanation |
