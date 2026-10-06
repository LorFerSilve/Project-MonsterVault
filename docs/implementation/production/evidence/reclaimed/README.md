# Larger central reserve and radioactive Vault — 2026-10-07

Applied to PR #76 (`codex/golden-slice`), after the owner rejected the unchanged
small central area and plain Vault exterior. This is a visual revision with
native integration evidence; final Golden visual acceptance remains open.

## Actual composition

- Starter is now **176 x 256 studs**, 45,056 square studs: **77.8% larger than
  the previous 176 x 144 pass**, and 2.75 times the initial 128 x 128 footprint.
  Its southern edge remains Z=80, preserving the Home bridge connection and
  disjoint adjacent region volumes. The utility/habitat/hazard points stay put.
- The actual central Field Station is rebuilt from 26 x 24 to **56 x 36**,
  with an **88 x 52** open court, two canopy wings, wider approach, segmented
  paving, low planting pockets, benches and an unobstructed central route.
  The Common creature stays in the grass outside the court. The small inner
  rock ring is removed, rather than hiding the same layout in a larger plate.
- A northern earth trail forms a larger exploration loop through grouped
  oak/pine canopies, understory, four grassy shoulders and a complete new coast.
  One reclaimed survey ruin is set along that loop; another and a retired rover
  occupy outer pockets. Sealed Energy cells are scenery without hazard/reward
  or inspection authority. Wider clearings retain negative space.
- The imported Blender **ContainmentShell** covers front, sides and rear:
  faceted open portal, angled buttresses, weathered armor, vents, restrained
  Energy lines, roof reactor and geometric containment mark. Native sloped
  roof shoulders, two cooling towers, foundation skirts and a supported header
  strengthen its skyline. Coplanar collision carriers are invisible; imported
  armor owns the visible appearance. The room remains 76 x 68 with a 20-stud
  open entrance and the existing display/production/claim systems.

## Asset import and reproduction

The owner imported `assets/exported/radioactive_vault_import.fbx` with upload
enabled. All **21 persistent MeshParts** were normalized from the source
geometry metadata, mapped through `MaterialPalette`, installed in the prefab
library and placed in real context. [Native IDs/material groups/pivots](radioactive_native_manifest.json).
No additional asset import or audio upload is pending for this pass.

The three editable sources and GLBs already prepared in the prior commit are
reused: ContainmentShell **7,664 triangles**, SurveyRover **2,676**, RelayRuins
**2,168**. Their 3/3 source/topology/export audit remains
`assets/exported/radioactive_source_audit.json`. Blender MCP was unavailable;
the approved Blender CLI fallback prepared these sources. No replacement model
or backend was needed in this integration pass. `TrailEarth` is centrally mapped
to native Ground RGB(106,113,82); the four original Energy Core groups are retained.

Reproduce in Edit, with the completed prefab library and source config:

1. `tools/roblox/build_golden_world.luau` (`Builder.run()`);
2. `tools/roblox/refresh_golden_world.luau`;
3. `tools/roblox/finish_golden_comfort.luau`;
4. `tools/roblox/expand_golden_reserve.luau`;
5. `tools/roblox/export_refresh_package.luau`, with `GoldenWorldLayout.world`.

The fourth pass is idempotent: repeated instance counts match and the relocated
ruin does not drift. The normal Rojo project delivers the serialized result;
these build scripts and the temporary local HTTP bridge are development tools,
not shipped runtime scripts.

## Native evidence

[World/library readback](native_package.json) proves exact native serialization:
world **1,004 BaseParts / 651 MeshParts / 325,963 repeated mesh triangles**,
**378,158 bytes**; library **32 prefabs / 101 MeshParts / 45,531 unique source
triangles**, **445,522 bytes**. All 1,004 world parts have known palette groups.
Local lights remain three, with no added shadow lights or animation loops.

The 58 functional parts retain all IDs/tags/collision flags. The same six
source-backed ground/region overrides are whitelisted; **52 other records are
unchanged**. Relative to the prior pass, only Starter ground/bounds depth and
center changed. No capture, profile, Energy, ownership, production, progression,
social, paid-status or Showcase protocol changed. Art has zero scripts or
authority tags. [Exact Edit source parity: 111/111](source_parity.json).

Actual Studio Play validation:

- [14/14 ordinary Humanoid route legs](traversal_native.json) around the new
  northern loop, beginning and ending at the existing Field Station. Setup
  used trusted Studio avatar placement; route legs were actual locomotion.
- [6/6 physics checks](physics_native.json): rover and tree block movement;
  the portal and interior spine are clear; front wing and side buttress block
  movement. Static proxies preserve the shell's open interior.
- [Both presentation doors open](doors_native.json) to X=-15/+15 for the actual
  avatar at Z=116. They retain the prior shared controller and no access policy.
- [29/29 existing native authoring cases](authoring_summary.json), 315 baseline
  grounded route samples and 315 hazard-free samples. Those baseline raycasts
  filter functional geometry; the new art route is proven by the actual walk.
- [Runtime console](console_native.txt): normal bootstrap/settlement messages,
  no runtime error in this Play session. No new capture/claim receipt or physical
  controller proof is substituted for earlier evidence.

During work the owner accidentally closed Studio. The reopened matching place
retained the mapped library and prior composition. The last interrupted art pass
was reapplied and then exported/read back. Studio is left in **Edit**, normal
server/client scripts enabled and HttpEnabled restored to false. User-local files
and original/imported source models are preserved.

## Visual views and performance

Six final native, unmodified JPEGs are retained with camera/hash metadata in
[screenshots.json](screenshots.json):

| View | Screenshot |
| --- | --- |
| Larger central area + northern reserve | [starter_overview.jpg](starter_overview.jpg) |
| Field Station at player camera height | [starter_court.jpg](starter_court.jpg) |
| Reclaimed survey trail / lush nature | [northern_survey.jpg](northern_survey.jpg) |
| Rear/side armor and stepped reactor skyline | [vault_exterior.jpg](vault_exterior.jpg) |
| Front portal / Energy containment identity | [vault_entry.jpg](vault_entry.jpg) |
| Preserved roomier Vault interior | [vault_interior.jpg](vault_interior.jpg) |

Inspection corrected narrow original composition, the old interior rocky seam,
concrete-looking forest trail, insufficient canopy clusters, unsupported header,
and visible/coplanar physics carriers. The three supplemental assets were judged
in Studio and used in Play, rather than accepted from Blender export alone.

[120 actual client frames/view](performance_native.json): Starter **18.00 ms
p95**, **222,362 opaque triangles / 53 draws**; Vault **18.08 ms p95**,
**39,993 / 48**. Short-sample memory was about **2,848 MB** and nearly unchanged
within each view. Render counts fit working scene targets; **16.67 ms reference
performance, long-term memory stability, real devices and VS1-19 remain open**.

## Automated checks and remaining work

[Validation](validation.json): **13/13 focused Golden, 339/339 full fast,
28/28 Python**; integrity/dependency/style/lint/Rojo checks pass. Configured
Luau analysis exits zero with missing Roblox-definition warnings; no clean
engine type-analysis claim. Exact head CI is recorded after push.

Golden final visual acceptance remains open after the owner's rejection of the
earlier map. Physical controller menu/select/close, actual increased platform
text preference, refreshed seasonal treatment and reference-device performance
remain separate acceptance work. Farther biomes still have placeholder content;
the bigger northern loop adds no new Species/encounters/objectives. No events,
trading or commerce was started. PR #76 remains draft pending Golden acceptance.

Next: review this larger central area and actual radioactive exterior in Play,
then continue focused sensory/animation and manual/device acceptance from the
existing matrix, before broader PQL rollout or later IMP-11 backend work.
