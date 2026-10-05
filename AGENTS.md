# Project-MonsterVault

## Blender for visual production

Standing user agreement: the connected Blender pipeline is available across
visual design, map design and UI design whenever Blender is suitable for the
visual output. Its use is not limited to environmental props.

- Use Blender for game models, map modules, buildings, terrain meshes, props and
  other 3D visuals. UI visuals can also use Blender-generated models, icons,
  illustrations or renders when appropriate.
- When the connected **Blender MCP** is available, Codex/Work should actively use
  it as the preferred interactive production path for visual/design work where
  custom modelling, rigging, animation or render output materially improves the
  game. Keep the local Blender CLI / Python `bpy` workflow reproducible as the
  source-backed fallback rather than creating an MCP-only asset process.
- Use the connected **Roblox Studio MCP** for final import/integration, placement,
  material mapping and visual validation where available. A visual asset is not
  production-ready merely because it looks correct in Blender or exports cleanly.
- Generate assets through the local Blender CLI and Python `bpy` API; keep the
  workflow reproducible and determine repository paths from `__file__`.
- Keep editable `.blend` sources in `assets/blender`, exports in
  `assets/exported` and generators in `tools/blender`. Reuse existing folders.
- Implement Roblox UI layout, text, controls, responsive behavior and interaction
  with native Roblox UI. Blender supplies visual assets for that interface.
- Every resulting 3D asset follows the material agreement below. Verify its
  appearance in Studio; Blender shader settings alone do not guarantee Roblox
  appearance.

## 3D asset materials

Standing user agreement: every newly added 3D asset includes a complete,
deterministic Roblox-native appearance mapping before it is considered ready.
Imported or spawned assets must display their intended colors immediately.

- Reuse and extend one central material palette. Reuse an existing group when
  its appearance fits; register any genuinely new groups with explicit Roblox
  `Material` and `Color` values as part of adding the asset.
- Identify material groups through stable exported mesh names or material
  metadata/attributes. Avoid maintaining lists of individual mesh instances.
- Apply the mapping in Edit mode to the asset/prefab and preserve it when the
  asset is cloned or spawned. Reuse the same deterministic pass for any required
  initialization; no per-frame appearance updates.
- Check that every mesh has a known group. Report unmapped meshes and fix the
  mapping before declaring the asset ready; do not silently leave gray parts.
- Verify the result visually in the connected Studio under its current Lighting
  and leave Studio in Edit mode. Appearance-only changes preserve geometry,
  scale, pivots, positioning and existing mesh structure.
- Use native materials first. Add lights only when visually necessary; textures
  or PBR require a demonstrated need. Preserve the Blender/GLB source assets.

Existing palette:

| Group | Roblox Material | Appearance |
| --- | --- | --- |
| `DarkMetal` | `Metal` | Dark blue-gray metal |
| `SecondaryMetal` | `Metal` | Lighter metal |
| `PanelPlastic` | `SmoothPlastic` | Dark panel/plastic |
| `EnergyGreen` | `Neon` | Bright green energy |

The shared palette is in
[`src/shared/config/MaterialPalette.luau`](src/shared/config/MaterialPalette.luau).
The working reference pass is in
[`tools/roblox/energy_core_appearance.luau`](tools/roblox/energy_core_appearance.luau).
When another asset needs the palette, share these definitions rather than
creating diverging per-asset copies; keep the existing Energy Core appearance.

## Golden Slice production baseline

Before substantial visual-production work, read the implementation pre-production package in
[`docs/implementation/production/`](docs/implementation/production/README.md).

For the first Golden Playable Vertical Slice, the required execution baseline is:

- permanent production-quality MonsterVault base first;
- removable/configurable Halloween 2026 launch layer second;
- use the Visual Bible and Asset Manifest to avoid ad-hoc art direction;
- use the Blender -> Roblox standard for every custom hero asset;
- use the UI/UX system instead of creating unrelated per-screen styles;
- treat the production performance budgets as authoring guardrails until measured TA-14 evidence exists;
- update the Golden Slice acceptance matrix with actual Studio evidence rather than claiming quality from code/export success.
- read the Golden Slice Code Integration Map before changing gameplay-facing services; extend existing controller/store/projection seams instead of building duplicate authority;
- follow the Golden Slice Executable Task Plan as the default implementation order, beginning with the Studio truth audit and permanent environment before seasonal decoration.

Current authored content note: the repository currently has Common Species and one protected Legendary DEV Species, but no authored Rare/Epic Species. Visual production must not silently alter authoritative rarity to fill a presentation checklist.
