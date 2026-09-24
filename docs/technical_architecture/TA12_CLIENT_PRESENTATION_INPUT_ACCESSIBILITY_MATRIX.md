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

| Context | Purpose | World input |
|---|---|---|
| SystemBlocked | recovery/safe actions | sunk |
| Modal | confirm/cancel/navigation | sunk |
| CommittedGameplay | capture/trade-specific actions | restricted |
| World | ordinary semantic actions | active |
| PanelNavigation | UI navigation | suppressed/restricted as configured |
| PlatformMenuSuspended | Roblox menu owns interaction | suspended |

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
| modal opens | deterministic first/remembered valid control |
| nested strong confirmation | confirmation owns primary focus |
| modal closes | prior valid semantic target or fallback |
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
