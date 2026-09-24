# TA-12 Roblox Client Presentation / Accessibility Platform Snapshot

> **Snapshot date:** 2026-09-24  
> **Status:** PASS  
> **Purpose:** Record current Roblox client/UI/input/accessibility platform behavior relied on by TA-12.  
> **Authority:** Supporting platform evidence only; TA-12 remains MonsterVault semantic architecture authority.

## 1. Primary Sources Reviewed

- Input Action System: https://create.roblox.com/docs/input/input-action-system
- InputAction API: https://create.roblox.com/docs/reference/engine/classes/InputAction
- UserInputService: https://create.roblox.com/docs/reference/engine/classes/UserInputService
- GuiService: https://create.roblox.com/docs/reference/engine/classes/GuiService
- GuiObject navigation: https://create.roblox.com/docs/reference/engine/classes/GuiObject
- UI position/size: https://create.roblox.com/docs/ui/position-and-size
- UI size modifiers: https://create.roblox.com/docs/ui/size-modifiers
- HUD safe areas: https://create.roblox.com/docs/tutorials/use-case-tutorials/ui/create-hud-meters
- Adaptive design: https://create.roblox.com/docs/production/publishing/adaptive-design
- Console guidelines: https://create.roblox.com/docs/production/publishing/console-guidelines
- Camera customization: https://create.roblox.com/docs/workspace/camera
- Accessibility guidance: https://create.roblox.com/docs/production/publishing/accessibility
- Localization: https://create.roblox.com/docs/production/localization
- Sound/audio: https://create.roblox.com/docs/sound
- Sound groups: https://create.roblox.com/docs/sound/groups
- Text input/filtering: https://create.roblox.com/docs/ui/text-input

## 2. Input Action System

Current Roblox documentation provides InputContext, InputAction and InputBinding as a cross-platform semantic input system.

InputContext supports enabling/disabling contextual action collections and priority/sink behavior. InputAction exposes PreferredBinding, which updates according to the current preferred device binding.

The documentation recommends a top-level context and cross-platform bindings.

### TA-12 consequence

MonsterVault uses semantic InputAction/InputContext as baseline instead of scattering raw key/gamepad/touch checks through UI/gameplay controllers.

## 3. InputActionLabel Beta Boundary

Current Input Action documentation describes InputActionLabel as a convenient binding-label GuiObject but marks it as beta.

### TA-12 consequence

InputActionLabel is not a production dependency. MonsterVault owns a small glyph/text resolver driven by InputAction.PreferredBinding.

The Input Action Manager editor tooling may assist authors but is not required at runtime.

## 4. UserInputService / Gamepad Navigation

Current APIs expose gamepad navigation support and UI selection behavior.

GuiObject supports Selectable, SelectionOrder and directional NextSelection properties. GuiService.SelectedObject represents current UI selection.

### TA-12 consequence

MonsterVault owns a semantic Focus Manager that integrates SelectedObject and explicit directional navigation where automatic navigation is ambiguous.

## 5. Safe Areas

Roblox ScreenGui/GuiService expose screen inset/safe-area support including CoreUISafeInsets, DeviceSafeInsets and TopbarSafeInsets.

Roblox guidance notes device cutouts, Core UI and mobile default-control occupied regions.

### TA-12 consequence

Critical/actionable UI uses CoreUISafeInsets by default. Noninteractive decorative surfaces may use DeviceSafeInsets only when they cannot collide with platform/control zones.

## 6. Preferred Text Size

GuiService.PreferredTextSize maps to the player's Roblox Text Size setting and changes live.

Current documentation notes:

- AutomaticSize responds to the preference;
- wrapped text can use additional lines;
- TextService sizing honors the preference;
- TextScaled does **not** receive PreferredTextSize scaling.

### TA-12 consequence

MonsterVault critical text does not rely on TextScaled-only layouts. Responsive text uses wrapping/automatic sizing/measurement and reflows around the player preference.

## 7. Preferred Transparency

GuiService.PreferredTransparency maps to the player's background-transparency preference. Current guidance recommends applying it so UI backgrounds become more opaque as the user asks for improved readability.

### TA-12 consequence

MonsterVault Readability/Contrast presentation may strengthen background opacity/contrast but never weaken the effective platform preference.

## 8. Reduced Motion

GuiService.ReducedMotionEnabled maps to the player's Roblox Reduce Motion toggle.

Current accessibility guidance recommends reducing/removing UI motion/tweens when enabled.

### TA-12 consequence

Roblox Reduced Motion is composed with the MonsterVault preference using safety-first OR semantics; it also disables non-essential camera shake.

## 9. Adaptive Layout / Mobile

Current Roblox design guidance emphasizes responsive layout, content-driven sizing, wrapping, readable small-screen typography and accessible touch targets. Mobile default controls occupy important bottom-corner zones.

### TA-12 consequence

MonsterVault uses reflow/collapse/scroll strategies rather than desktop-first uniform shrinking and reserves mobile control/thumb zones.

## 10. Console / TV

Current console guidelines require all interactive UI to be reachable using basic directional navigation/select/back and advise TV-safe placement for critical content.

### TA-12 consequence

Every core menu has a complete gamepad focus graph and critical content remains inside a television-safe region.

## 11. Camera

Each client owns Workspace.CurrentCamera. Roblox allows Scriptable camera control when the experience needs custom presentation.

### TA-12 consequence

MonsterVault keeps familiar Custom camera behavior for baseline exploration and uses one bounded local camera-presentation owner for temporary assists, with deterministic restoration.

## 12. Localization

Roblox provides localization tables, automatic translation support and source-content capture. UI text can expand substantially between languages.

### TA-12 consequence

MonsterVault presentation is localization-key based and layouts tolerate expansion; localized display strings are never semantic IDs.

## 13. Audio API Direction

Current Roblox sound documentation points to newer Audio objects for more robust audio functionality, while SoundGroup guidance states SoundGroup is discouraged for new architecture in favor of audio objects.

### TA-12 consequence

TA-12 defines semantic audio buses/categories without locking gameplay to SoundGroup. TA-17 selects the concrete current Audio object graph after platform revalidation.

## 14. Text Filtering

Current Roblox text-input guidance states that developers are responsible for filtering displayed text that they do not explicitly control, while supported chat paths provide filtering for normal chat behavior.

### TA-12 consequence

MonsterVault baseline structured communication avoids a custom freeform chat network. Any uncontrolled/user text displayed through future UI must use supported Roblox filtering/communication paths.

## 15. Platform Change Rule

Input/UI/accessibility APIs are evolving.

Any material platform change to InputAction rollout, preferred-accessibility settings, safe insets, gamepad navigation, camera or audio APIs requires revalidation before TA-17 implementation changes.
