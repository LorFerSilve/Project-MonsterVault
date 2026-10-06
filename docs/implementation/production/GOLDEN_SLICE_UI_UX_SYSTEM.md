# Golden Slice UI/UX System

> Status: REPRESENTATIVE NATIVE FOUNDATION IMPLEMENTED; BROADER ACCEPTANCE OPEN
> Date: 2026-10-06
> Authority: presentation implementation baseline only; GDS-14 and TA-12 remain authoritative
> Goal: replace one-off diagnostic styling with reusable native Roblox UI primitives

`GoldenTheme` implements the representative primitives. The library refresh adds
native gradient depth, one thin Kenney header accent and binding-specific input
icons alongside the existing action text. These are decorative resources, not
input/permission state. [Actual refreshed UI](evidence/refresh/README.md).
Physical controller menus and actual increased platform text preference remain
open in the acceptance matrix.

## 1. UX principles

### U-01 — Sparse by default

Normal world exploration should not look like a dashboard.

Keep persistent HUD limited to:

- Energy;
- current objective/guidance when relevant;
- local context;
- context-sensitive action;
- committed/time-critical state when active.

### U-02 — Server truth, client presentation

UI displays authoritative projections and sends semantic intent.

A button press may show Pending immediately but may not fabricate success.

### U-03 — Touch first, parity everywhere

Every primary action must work with:

- touch;
- keyboard/mouse;
- gamepad.

No core interaction may depend on hover or tiny precision targets.

### U-04 — Critical meaning is redundant

Use at least two of:

- text;
- icon/shape;
- color;
- sound;
- pattern/motion.

Color-only rarity/error/success is not acceptable.

### U-05 — Halloween is a skin layer

Halloween may change decorative tokens, background motifs and seasonal banners.

It may not change:

- hierarchy;
- control meaning;
- focus order;
- semantic success/error colors;
- readable text contrast.

## 2. Core UI tokens

Recommended implementation owner later: one shared ThemeTokens / component layer, not literal copies in every view.

### Permanent surfaces

| Token | Target |
| --- | --- |
| Surface/Base | RGB(15,20,27), high opacity |
| Surface/Raised | RGB(24,31,40) |
| Surface/Interactive | RGB(31,42,52) |
| Border/Subtle | RGB(65,78,91) |
| Text/Primary | RGB(246,250,248) |
| Text/Secondary | RGB(184,197,202) |
| Energy | RGB(76,255,110) |
| Focus | RGB(120,208,255) |

Semantic error/warning/success tokens should be separate from rarity and seasonal colors.

### Halloween decorative tokens

| Token | Target |
| --- | --- |
| Seasonal/Orange | RGB(255,138,52) |
| Seasonal/Gold | RGB(255,211,122) |
| Seasonal/Violet | RGB(167,107,255) |
| Seasonal/Dark | RGB(42,23,56) |

Use for borders, headers, motifs, decorative particles and event identity — not universal button semantics.

## 3. Spacing and sizing

Use an 8-pixel logical spacing rhythm with 4-pixel half-step where necessary.

Recommended increments:

4 / 8 / 12 / 16 / 24 / 32 / 48.

Minimum ordinary interactive height target: 48 px at baseline UI scale.

Do not make dense 28–32 px desktop buttons for primary mobile actions.

Respect:

- CoreUISafeInsets;
- platform text-size preference;
- wrapping;
- localization expansion.

## 4. Typography hierarchy

The exact Roblox-native font may be adjusted during Studio visual testing. Current Gotham use is acceptable as a baseline; consistency is more important than font novelty.

Initial logical sizes before PreferredTextSize composition:

| Role | Baseline |
| --- | ---: |
| micro metadata | 12–13 |
| secondary/body small | 14 |
| body | 16 |
| button / emphasized body | 17–18 |
| section heading | 20–22 |
| panel title | 24–28 |
| hero reward / rarity moment | 30–36, brief |

Rules:

- primary information must not live only in micro text;
- avoid all-caps paragraphs;
- use all-caps only for short tags/warnings where legible;
- number displays align consistently;
- long IDs never appear to ordinary players.

## 5. Shape language

Recommended:

- 8–12 px rounded card corners for normal panels;
- 12–16 px for hero/modal surfaces;
- 1–2 px subtle stroke;
- rare/Legendary frames may add outer shape treatment without changing content layout;
- buttons use a consistent pressed/selected/focus response.

Avoid mixing sharp sci-fi hexagons, bubbly pills and fantasy scrolls in one screen.

MonsterVault UI is compact arcane-tech, not medieval parchment.

## 6. Component inventory

### Panel

Supports:

- title;
- optional subtitle/status;
- content;
- actions;
- error/pending footer.

### PrimaryButton

Use for one obvious next action.

States:

- default;
- hover/mouse optional;
- gamepad focus;
- pressed;
- disabled;
- pending.

### SecondaryButton

Used for alternatives such as Close / Back / Not now.

### DestructiveButton

Visually distinct and always paired with confirmation for irreversible high-value actions.

### CreatureCard

Required fields vary by context, but design must support:

- Species;
- rarity label + shape;
- Mutation labels;
- Trait summary where relevant;
- exact-instance status;
- lock/held/display state;
- Showcase read-only state;
- optional cosmetic layer clearly separated from intrinsic facts.

### RarityBadge

Contains:

- text label;
- shape cue;
- rarity color.

Never color-only.

### EnergyChip

Contains:

- Energy icon;
- integer balance;
- Pending/claim update treatment.

Seasonal decoration must not make Energy look like event currency.

### ObjectiveChip

One current objective, concise.

Expandable details belong in a panel, not permanent HUD.

### Notification

Priority-aware.

Low-priority social/cosmetic notifications cannot obscure capture/custody/safety state.

### Modal

Owns focus explicitly.

Closing/cancel/error restores previous focus safely.

### Progress / Mastery bar

Use progress only when the denominator is authoritative and meaningful.

Do not invent percentage progress for qualitative requirements.

## 7. HUD zones

Recommended Golden Slice layout:

Top-left:
- region/context + concise objective.

Top-right:
- Energy + compact persistent status.

Bottom-center:
- context-sensitive Primary Interact / Primary Action.

Center:
- temporary crosshair/target/capture semantics only when relevant.

Lower/side notification area:
- bounded queued notifications.

Avoid permanent screen-edge bars on every side.

## 8. Capture UI

Current CaptureView is an engineering baseline, not final art.

Production capture presentation should preserve its good behaviors:

- safe-area insets;
- clear heading/body/action;
- gamepad focus respect;
- explicit canActivate state.

Upgrade:

- target/creature identity;
- semantic phase;
- minimal progress/buildup when authoritative;
- rarity/mutation facts only when allowed;
- stronger Pending/OutcomeUnknown presentation;
- tactile action button;
- secured/failure transition.

Do not cover the creature with a large modal during ordinary capture.

## 9. Collection / Vault UI

Collection is identity-rich; Vault is operational.

Collection card priority:

1. creature visual;
2. Species;
3. intrinsic rarity;
4. Mutation / Variant identity;
5. exact-instance state;
6. secondary Trait/provenance details.

Vault operational priority:

1. selected exact instance;
2. assignment/status;
3. output/claim state;
4. capacity/slot constraints;
5. available action.

Avoid showing every backend field in one panel.

## 10. Showcase

Showcase is deliberately read-only.

Production card should display:

- owner identity;
- creature presentation;
- Species;
- intrinsic rarity;
- Mutations;
- Traits when projected;
- display slot context;
- clear READ ONLY state;
- Close/Return.

Do not add fake ownership controls.

## 11. Motion

Default microinteraction targets:

- press: 80–140 ms;
- selection/focus: 100–180 ms;
- card/state transition: 120–220 ms;
- panel enter/exit: 180–320 ms;
- reward lock-in: 300–700 ms.

Reduced Motion:

- remove position sweeps and shake;
- prefer instant state + short opacity change;
- preserve focus and semantic confirmation;
- never hide completion because an animation was skipped.

Roblox platform Reduced Motion must be respected in addition to any MonsterVault preference.

## 12. Gamepad focus

Every interactive panel needs deterministic:

- first focus target;
- directional navigation;
- back/cancel route;
- restoration when modal closes.

Do not steal existing focus for low-priority notifications.

## 13. Mobile layout

At narrow widths:

- one primary content column;
- avoid side-by-side text-heavy cards;
- use bottom-sheet/modal patterns where useful;
- keep primary action thumb-reachable;
- creature visuals may shrink, but primary text/actions do not become microscopic.

## 14. Halloween skin

Allowed:

- seasonal top border;
- pumpkin/lantern motif in empty decorative corners;
- orange/violet gradient accent behind seasonal banner;
- seasonal icon frame;
- subtle fog/speckle background layer;
- Halloween title-card variant.

Not allowed:

- orange text on black for every screen;
- spiderwebs behind dense body text;
- changing green success into orange;
- changing red error into violet;
- using Legendary gold treatment for paid Halloween cosmetics.

## 15. UI performance

Prefer:

- reusable components;
- event-driven updates;
- bounded lists;
- virtualized/paged large collections later when needed;
- shared sprites/icons where useful;
- native gradients/strokes over large unique bitmaps.

Initial Golden targets are defined in GOLDEN_SLICE_PERFORMANCE_BUDGETS.md.

## 16. Acceptance examples

A primary screen is not production-ready until:

- it is understandable without dev knowledge;
- touch targets are practical;
- gamepad focus works;
- PreferredTextSize does not destroy layout;
- Reduced Motion keeps semantics;
- color is not the only meaning;
- Halloween on/off both remain coherent;
- server Pending/OutcomeUnknown remains honest.

## Applied foundation — 2026-10-06

Owner-feedback extension (2026-10-07): bounded native hover/press/gamepad-focus
scaling and 0.16s modal entry are integrated. Reduced Motion cancels active scales;
close/input/focus authority is immediate. Matched successful travel adds an arrival
cue; no unconfirmed receipt or projection readback becomes a reward celebration.
[Actual native input evidence](evidence/comfort/feedback_native.json).

Native implementation lives in `GoldenTheme`, `RarityTokens`, `GoldenFeedback`, `GoldenSensory`, `GoldenRuntimeService` and `ShowcaseRuntimeService`, over the existing controller/store commands. Representative HUD, Collection/Vault/Journey, capture/receipt notifications, sensory preferences and Read Only card are integrated. Typography uses Gotham/GothamBold, native auto-height text, scrolling modal content and 48px-or-larger primary touch controls. Larger navigation text gets two rows. Intrinsic rarity has both shape and text; paid/status cosmetics never choose this badge or authority.

See [native evidence](GOLDEN_SLICE_EVIDENCE.md) for phone input, the separate 1.5x text stress and Reduced Motion claim. Actual increased platform text preference and physical controller menu retest remain open; this foundation does not close PQL-3/PQL-8.
