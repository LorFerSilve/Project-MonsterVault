# Blender -> Roblox Asset Production Standard

> Status: PRE-PRODUCTION STANDARD
> Date: 2026-10-06
> Applies to: Golden Slice and subsequent production 3D assets
> Existing authority: AGENTS.md and src/shared/config/MaterialPalette.luau remain binding

## 1. Definition of done

A 3D asset is not production-ready because:

- the Blender file exists;
- a generator exits successfully;
- GLB/FBX export succeeds;
- Studio accepts the import.

Production-ready means the asset has:

1. editable source;
2. reproducible export;
3. correct scale/pivot/orientation;
4. bounded geometry/material usage;
5. complete Roblox appearance mapping;
6. appropriate collision/interaction setup;
7. actual placement in its gameplay context;
8. Studio visual validation under current Lighting;
9. Play validation when animation/collision/runtime behavior matters;
10. no regression to gameplay anchors/authority.

Studio is the final runtime visual authority.

## 2. Units and axes

Baseline project convention:

- 1 Blender unit = 1 Roblox stud for authored game assets unless a documented exception exists;
- Blender scene is Z-up;
- root/source pivot is floor center for grounded props and buildings unless the asset's use requires another semantic pivot;
- creature root/pivot must support world spawn, animation and display placement;
- apply location/rotation/scale before final export unless the pipeline explicitly requires preserved rig transforms.

The existing Energy Core generator records asset_units = stud and is the reference convention.

## 3. Source hierarchy

Each asset should have one semantic root.

Recommended source naming:

MV_<Domain>_<AssetName>

Child mesh naming:

<AssetName>_<PartRole>_<MaterialGroup>

Examples:

VaultRelay_Base_DarkMetal  
VaultRelay_Trim_SecondaryMetal  
VaultRelay_Core_EnergyGreen

Material groups should be stable semantic groups, not mesh-instance IDs.

Do not encode changing gameplay IDs into mesh names unless the model is truly tied to that one authored identity.

## 4. File naming

Editable source:

<asset_name>.blend

Generator:

generate_<asset_name>.py

Preferred export:

<asset_name>.glb

Use FBX when the current Studio import/rigging path materially benefits from FBX and document why.

Do not generate multiple indistinguishable export copies with suffixes such as final2, final_new or fixed_latest.

Use version control for history.

## 5. Folder convention

Existing top-level convention remains:

- assets/blender
- assets/exported
- tools/blender

New production assets may use domain subfolders:

- environment
- vault
- creatures
- seasonal/halloween_2026

Do not relocate the existing Energy Core solely for organizational symmetry.

## 6. Transform discipline

Before final export:

- no unintended negative scale;
- transforms applied where safe;
- mesh normals correct;
- no hidden duplicate geometry;
- no disconnected accidental pieces;
- no zero-area faces;
- no unnecessary internal faces;
- no giant coordinates far from the semantic root;
- pivot intentionally tested.

For modular environment pieces, snapping dimensions should use a small documented grid family such as 2/4/8-stud increments where practical.

Organic rocks/foliage can break the grid visually while their placement pivots remain predictable.

## 7. Topology

Prefer:

- clean silhouettes;
- quads during authoring where useful;
- predictable triangulation on export;
- bevels that materially affect silhouette/highlights;
- geometry where it improves shape rather than microscopic surface detail.

Avoid:

- dense subdivisions on flat surfaces;
- hidden underside geometry that never contributes;
- highly tessellated cylinders for small props;
- permanent double-sided geometry when correct normals solve the problem.

The existing Energy Core generator triangulates ngons and keeps bevels restrained; use that spirit rather than copying its exact topology to every asset.

## 8. Geometry working targets

These are MonsterVault authoring targets, not Roblox platform hard limits.

| Asset class | Working target |
| --- | ---: |
| tiny repeated prop | <= 500 triangles |
| small prop | 500–1,500 |
| medium prop | 1,500–3,500 |
| modular architecture piece | 1,500–5,000 |
| hero machine / landmark | 4,000–10,000 |
| Common production creature | 4,000–8,000 |
| hero / Legendary creature | 6,000–12,000 |
| unusually large hero set | exception; profile in Studio before acceptance |

Repeated props should trend toward the lower end.

Silhouette quality may justify a measured exception. Hidden detail does not.

## 9. Materials and textures

Native Roblox materials are the default.

Use the central MaterialPalette mapping when the visual can be expressed with:

- Metal;
- SmoothPlastic;
- Neon;
- other reusable native materials.

PBR / SurfaceAppearance is justified when it materially improves:

- a hero creature;
- major landmark;
- high-value Vault machine;
- repeated environment kit where texture reuse amortizes cost.

Texture targets:

- small/minor UI or prop images: <=256 px where sufficient;
- ordinary hero texture sets: 512 px default;
- 1024 px only for assets that visibly need it at expected screen size;
- avoid unique large textures on repeated filler props.

Reuse texture sets and trim-sheet-like strategies where possible.

Do not use texture resolution to hide weak geometry/art direction.

## 10. Material mapping contract

Every exported visual mesh must resolve to a known material group.

Current central groups:

- DarkMetal -> Metal / RGB(50,63,76)
- SecondaryMetal -> Metal / RGB(153,172,187)
- PanelPlastic -> SmoothPlastic / RGB(19,25,33)
- EnergyGreen -> Neon / RGB(76,255,110)
- FixtureCreature -> Neon / RGB(77,205,255), current DEV reference

New repeated groups must be registered centrally.

Unmapped gray meshes are a build defect, not acceptable placeholder output.

## 11. Rigging and animation

Rig only when it improves the actual asset use.

For creatures:

- root is stable and documented;
- bone names are semantic;
- idle animation does not move the root unpredictably;
- display pose works without requiring gameplay animation;
- capture/reveal presentation can temporarily override local animation without changing authoritative state;
- deformation is checked in Studio.

Do not add a complex skeleton to a static prop.

## 12. Collision and query behavior

Visual mesh and gameplay collision are separate concerns.

Prefer simple collision proxies for:

- architecture;
- rocks;
- large decorative shapes.

Do not rely on detailed render geometry as collision if a simpler proxy preserves gameplay.

Seasonal decoration must not:

- block safe routes;
- obstruct secure/recovery anchors;
- alter travel eligibility;
- create unintended climb/exploit routes around progression boundaries.

Collision must be validated in Play for traversable production geometry.

## 13. Import settings

Studio Importer currently supports FBX, glTF and OBJ; FBX/glTF preserve richer hierarchy/rig/PBR data.

During import:

- confirm Scale Unit;
- confirm World Up/Forward;
- inspect object hierarchy;
- preserve semantic pivots;
- review importer warnings;
- avoid merging meshes when reuse/material/pivot semantics benefit from separate objects;
- do not upload repeated iteration junk as permanent assets if local testing is sufficient.

Where reusable assets are appropriate, consider package/reuse workflow rather than duplicate imports.

## 14. Reuse and instancing

A modular kit should reuse the same imported mesh/content where possible.

Do not export an entire environment as one giant unique map mesh.

Reasons:

- weaker reuse;
- larger update blast radius;
- harder collision/streaming;
- duplicate mesh content can increase memory/draw cost;
- difficult seasonal removal.

Build environments from reusable modules plus native terrain/parts.

## 15. Seasonal authoring

Halloween assets are a separate presentation layer.

Requirements:

- clearly named seasonal collection/folder;
- removable without deleting permanent geometry;
- no gameplay authority in mesh metadata;
- collision off by default for small decoration;
- seasonal hero props may have deliberate collision only after traversal validation;
- permanent material groups remain usable after seasonal disable.

## 16. Studio validation checklist per asset

Before marking ready:

- [ ] imported with expected dimensions;
- [ ] pivot behaves correctly;
- [ ] no missing/reversed faces;
- [ ] every mesh has known material mapping;
- [ ] intended colors appear under current Lighting;
- [ ] no accidental gray/default materials;
- [ ] no severe z-fighting;
- [ ] transparent surfaces do not create obvious overdraw artifacts;
- [ ] collision/query/touch flags are intentional;
- [ ] placement does not obscure prompts/anchors;
- [ ] streaming out/in does not corrupt runtime use;
- [ ] Play test performed if animated/collidable/interactable;
- [ ] Studio left in Edit mode after evidence capture.

## 17. Evidence

For hero assets, evidence should record:

- source path;
- generator path if applicable;
- export path;
- approximate triangle count;
- materials/groups;
- dimensions;
- pivot convention;
- Studio destination;
- before/after screenshot references;
- validation date;
- known exception/budget notes.

## 18. Failure policy

If Blender/MCP/CLI export succeeds but Studio appearance fails, the asset is NOT done.

If Studio integration is unavailable, Work may prepare source/export and report BLOCKED VISUAL VALIDATION, but may not claim production-ready status.
