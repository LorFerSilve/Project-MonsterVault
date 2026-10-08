# Golden Slice library refresh — 2026-10-06

**Integrated in Studio and source-backed; Golden acceptance remains open.**
Continuation of `codex/golden-slice`, PR #76. This refresh replaces representative
permanent art using the downloaded CC0 packs. Existing capture, creatures, Energy,
social permissions, seasonal layer and progression authority remain with their
existing owners.

## Applied refresh

- Starter: oak/pine silhouettes, shrubs, grounded rock shoulders, fern/grass/flower
  clusters and textured Field Station bays, supplies and terminal. The route,
  encounter clearing and secure area keep their existing functional anchors.
- Home/Vault: modular wall/window bays, supports, cable headers, vents, maintenance
  crates and console. The original Energy Core, accumulator, two display plinths,
  functional shell and Energy routes are retained.
- UI: native panel depth, a restrained Kenney header accent and binding-specific
  keyboard/PlayStation/Xbox icons alongside existing text. Layout, inputs, focus,
  rarity badges and interaction remain native. Capture guidance now describes
  the player action instead of the server implementation.
- No new audio uploads, live Rare Species, commerce, visitor writer or IMP-11
  backend successor. No additional decorative Heartbeat connections or polling.

## Asset delivery and reproduction

Fifteen adapted models have fifteen editable `.blend` sources, fifteen GLBs and
one combined source/FBX import transport. The imported 32 meshes have persistent
Roblox IDs. All material groups use `MaterialPalette.luau`; alpha foliage is double
sided, and native glass is explicitly translucent. Sixteen atlas paths share
fifteen unique <=512px color/alpha images. Full PBR maps stay in source inputs.

- [Selected source licenses](../../../../../assets/source/cc0-refresh/README.md)
- [Blender/export manifest](../../../../../assets/exported/refresh/refresh_manifest.json)
- [Persistent mesh and atlas IDs](../../../../../assets/exported/refresh/native_asset_manifest.json)
- [Blender/GLB audit](source_audit.json): 15/15, 32 mesh objects, 11,501 unique triangles;
  finite vertices, no zero-area triangles, UVs, applied transforms, bounds, packed
  images and matching GLB topology. Actual vertex/triangle/UV hashes are separate
  from the manifest's material/bounds metadata stamp.
- [Native package/readback](native_package.json): library 377,056 bytes; world
  300,158 bytes. Exact recursive roundtrip covers mesh IDs, transforms/pivots,
  appearance, SurfaceAppearance maps, collision, model scale and labels. Numeric
  CFrame components avoid a false signed-zero string difference.
- [Exact Edit source parity](source_parity.json): 110/110.

Normal Rojo delivery uses the updated `golden_assets.rbxm` and `golden_world.rbxm`;
**no manual import is pending**. A deliberate regeneration runs the Blender
adapter (default selected repository source), then ordinary Studio FBX Import
with upload enabled, followed by `finish_golden_import.luau` with the refresh
manifest, `extend=true` and the persisted atlas map. Keep the raw import preserved.

To rebuild composition, run the existing `build_golden_world.luau` builder first,
then `refresh_golden_world.luau` over its permanent root. The latter can also refresh
its dressing on an already refreshed root without accumulating those decorations.
For an edit audit, capture the functional `MonsterVaultWorld` BaseParts before
the design pass in `ServerStorage.RefreshAnchorSnapshot` (sorted name, numeric
CFrame/size, collision/touch/query, tags); `export_refresh_package.luau` compares
that snapshot and validates serialization before its optional local write callback.
The HTTP bridge is development-only and is removed after exporting. No runtime
HTTP dependency or art-package script is introduced.

## Actual Studio inspection

The imported hierarchy was normalized from the FBX transport's large import
scale to manifest stud dimensions and ground pivots. Palette mapping and clones
were inspected under the existing permanent Lighting. Visual iteration corrected
floating reserve ridges, rear-facing Vault bays and a title overlapping an Energy
stripe. The permanent layer was inspected with Halloween OFF.

Play inspection covered the Common encounter/prompt, owned Collection portraits,
ordinary Home travel, Vault controls, an existing exact owned Mossbud on Display1
and the approved owner-preview Showcase card explicitly marked **READ ONLY**.
The temporary display assignment was removed through the normal owner UI and
confirmed `Stored` after a fresh Play start. No creature was released to make
room: the current Collection was full, so this pass does **not** claim a new
capture/Secured or Energy Claim proof. Earlier Golden evidence remains the source
for those lifecycle effects and the permission regression.

The 58 gameplay anchor CFrames, sizes, collision/touch/query and tags compare
exactly before/after. Decorative scripts: zero. Native world mapping: 565 checked
parts, zero unknown groups, 357 atlas instances, three local lights.

| Image | Native view |
| --- | --- |
| [01](01-before-starter.jpg) / [03](03-starter-refreshed.jpg) | matched Starter before/after |
| [02](02-before-vault.jpg) / [04](04-vault-refreshed.jpg) | matched Vault before/after |
| [05](05-common-hud.jpg) | Play Common/HUD |
| [06](06-collection.jpg) | settled owned Collection portraits |
| [07](07-home-arrival.jpg) | authoritative ordinary Home arrival |
| [08](08-showcase-read-only.jpg) | approved owner preview, Read Only card |
| [09](09-creature-display.jpg) | actual owned creature on the Vault plinth |

JPEGs are the unmodified native Studio captures, not Blender concept renders.

## Performance and acceptance

[Raw native statistics](performance_native.json), 120 RenderStepped frames per
view, Studio workstation. Separate shadow passes are excluded from render counts.

| View | p50 / p95 ms | Opaque triangles / draws | UI triangles / draws | Memory MB before → after |
| --- | --- | --- | --- | --- |
| Starter | 66.63 / 68.17 | 98,710 / 39 | 142 / 3 | 2014.27 → 2004.07 |
| Vault | 66.89 / 68.21 | 41,768 / 55 | 374 / 9 | 2033.38 → 2022.56 |

Whole permanent art: 565 parts, 426 MeshParts, 164,226 mesh triangles. Rendering
counts stay below working 450k/600-draw targets. **Frame performance does not pass**
the 16.67ms reference or 33.33ms low-end target. The near-15fps cadence may involve
Studio/background behavior, but the cause is unproven. Physical-device and
long-session investigation remain open; VS1-19 is not closed.

Local regression: 339/339 fast, 28/28 Python, Selene zero errors/warnings,
StyLua, dependency/integrity and Rojo build. Configured Luau analysis exits zero
with missing Roblox definitions; this is not a clean engine-definition type pass.
Normal remote CI remains required for each pushed head.

PQL-1/2/3/4/8 broader rollout remains open. Physical controller menu/select/close
and increased platform text preference still need their previous manual checks.
PR #76 stays draft until applicable Golden acceptance is resolved. The next work
phase is representative visual review and the recorded acceptance/performance
checks, not Shared Objectives, events, trading or commerce.
