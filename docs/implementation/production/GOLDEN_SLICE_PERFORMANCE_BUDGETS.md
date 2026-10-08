# Golden Slice Performance Budgets

> Status: WORKING BUDGETS + SIX STUDIO MEASUREMENTS; REAL-DEVICE GATES OPEN
> Date: 2026-10-06
> Authority: TA-14 remains authoritative for actual performance gates
> Purpose: stop production art from creating avoidable performance debt before real-device measurement

Latest [current-map ON/OFF measurements](evidence/harvest/performance_native.json):
120 frames/view, Starter/Vault p95 about 68ms with either layer setting. OFF
has 480 Heartbeats per 120 RenderStepped events and Heartbeat p95 about 18ms;
this does not establish a throttle or geometry cause. Opaque counts are
173,346/41 and 46,889/51 OFF; 186,078/54 and 49,395/59 ON. Both frame targets
fail in these workstation samples. Memory about 2.84-2.97GB is not a stability
proof. Current world is 1,012 parts; seasonal template 177 parts / 29,982 mesh
triangles, three non-shadowing lights and one Rate-3 emitter. Eight cached
accumulator segments reuse the one <=16-record motion owner. Real devices,
long-session/cadence diagnosis, TA-14 and VS1-19 remain open.

[Follow-up fresh-session diagnostic](evidence/harvest/cadence_diagnostic_native.json):
Starter/Vault sampled after the MCP command returned have p95 21.77/23.34ms;
same-session Starter inside a pending command is 23.42ms. All are 120:120
Heartbeat/RenderStepped with unchanged runtime/settings. This does not prove
MCP caused the older 68ms cadence or establish a performance fix. Fresh samples
still exceed 16.67ms; supported-device and long-session gates remain open.

Latest [reclaimed-reserve measurements](evidence/reclaimed/performance_native.json):
120 frames/view, Starter p95 18.00ms and Vault 18.08ms on this Studio workstation,
with 222,362/53 and 39,993/48 opaque triangles/draws. Permanent delivery has
1,004 BaseParts / 651 MeshParts / 325,963 repeated triangles and three lights.
The supplementary shell/ruins/rover are included. Short-view memory is about
2,848MB and nearly unchanged within each sample; long-term stability is unproven.
These results do not pass the reference 16.67ms or physical-device gates, resolve
the older 68/101ms cadence, or close VS1-19. No runtime loop/emitter/light was
added by this larger composition. Existing bounded movement/door effects remain.

Measured implementation: [six-view evidence and exceptions](GOLDEN_SLICE_EVIDENCE.md#measured-bounds), [raw native statistics](evidence/golden/performance_native.json). All sampled visible triangle/draw counts are below the working scene targets. Fresh Studio p95 is 22-24ms and an earlier long-session p95 is 101ms; no TA-14 reference-device performance pass is claimed.

Latest [library-refresh samples](evidence/refresh/performance_native.json): Starter
p95 68.17ms, Vault 68.21ms, 120 native frames each. Opaque rendering is 98,710/39
and 41,768/55 triangles/draws respectively (UI and shadow passes are separate).
The permanent art now has 565 parts / 426 MeshParts / 164,226 mesh triangles,
three local lights and zero local shadow lights. Render-count budgets have
headroom, but both frame targets fail in these Studio samples. The cadence's
cause is unresolved; do not infer a real-device pass or a proven throttle cause.

## 1. Important distinction

Numbers in this document are **MonsterVault working targets**, not Roblox platform limits.

Real evidence supersedes these targets.

TA-14 release gates remain authoritative, including:

- low-end reference client p95 frame <= 33.33 ms;
- reference mobile/tablet/console/desktop target p95 <= 16.67 ms;
- no reproducible supported-device OOM;
- no deterministic >500 ms MonsterVault UI/main-thread stall;
- client memory stability against measured warm baseline;
- no per-entity Heartbeat/task architecture.

Roblox Creator Hub guidance also favors:

- designing for performance early;
- reusing meshes/textures;
- native materials when sufficient;
- controlling transparency overdraw;
- event-driven code;
- profiling on a low-end baseline device.

## 2. Golden scene rendering targets

Before reference-device evidence exists, use these conservative targets for representative Golden views.

| Metric | Target | Warning / investigate | Do not accept without measured justification |
| --- | ---: | ---: | ---: |
| visible scene triangles | <=450k | >650k | >850k |
| draw calls | <=600 | >800 | >900 |
| shadow-casting local lights visible | <=4 | >6 | >8 |
| total local accent lights visible | <=12 | >16 | >24 |
| continuous high-opacity particle systems in view | <=12 | >18 | >24 |

These are scene-composition targets, not engine ceilings.

The point is to preserve headroom for players, creatures, UI, event content and lower-end devices.

## 3. Mesh budgets

Working targets:

| Asset | Triangle target |
| --- | ---: |
| tiny repeated seasonal prop | <=500 |
| small prop | 500–1,500 |
| medium prop | 1,500–3,500 |
| modular architecture piece | 1,500–5,000 |
| hero machine / landmark | 4,000–10,000 |
| Common production creature | 4,000–8,000 |
| Legendary / hero creature | 6,000–12,000 |

A higher count is not automatically wrong. It requires visible silhouette/deformation benefit and actual profiling.

## 4. Reuse

For environment construction:

- reuse imported mesh content;
- rotate/scale/recombine repeated modules;
- use native terrain/parts for broad simple surfaces;
- avoid exporting the entire map as one giant unique mesh;
- avoid importing duplicate copies of the same mesh under new asset IDs;
- prefer packages/reusable asset workflow when appropriate.

Repeated pumpkins, rocks, lanterns and foliage should use small shared families rather than dozens of unique meshes.

## 5. Textures and PBR

Default hierarchy:

1. native Roblox material;
2. native material + color;
3. reused texture;
4. reused PBR set;
5. unique PBR only when hero value justifies it.

Image targets:

- minor icon/prop: 128–256 px where sufficient;
- ordinary prominent UI/prop: <=512 px;
- hero creature/landmark texture set: 512 default;
- 1024 exception when the expected screen/world size demonstrates visible benefit.

Avoid 2K/4K production textures in the Golden Slice unless profiling and visual evidence demonstrate a real need.

## 6. Transparency

Partial transparency is expensive when layered.

Rules:

- opaque is the default;
- invisible helper/query parts use Transparency 1;
- fog cards/webs/ghost planes are spatially limited;
- avoid many intersecting transparent planes;
- particle textures should have tightly cropped alpha where possible;
- do not place dense webs/fog directly across the whole camera path.

Halloween atmosphere should rely on Lighting/Atmosphere plus selective VFX rather than transparent geometry carpets.

## 7. Particles and VFX

Initial local targets:

Ordinary capture:

- <=120 simultaneously visible short-lived particles near the effect;
- <=6 emitters active during the main beat.

Legendary reveal:

- <=300 simultaneous particles in short burst;
- <=10 active emitters;
- effect returns near baseline quickly after reveal.

Ambient Halloween:

- <=100 visible seasonal motes/bats/wisps in an ordinary local view;
- share controllers/emitters where practical;
- no emitter per decorative pumpkin.

The semantic effect must survive a reduced-effects quality mode.

## 8. Lighting

Prefer one coherent environment lighting solution.

Use local lights where they provide actual focal/readability value.

For lantern clusters:

- emissive/Neon appearance may provide most visual read;
- do not give every candle a shadow-casting PointLight;
- share or omit lights when visually redundant.

Energy Core lighting must not overexpose UI/creature presentation.

## 9. UI budget

Golden exploration HUD target:

- <=150 active GuiObjects.

Complex open panel target:

- <=450 active GuiObjects.

Warning:

- >600 active GuiObjects for one ordinary primary panel requires inspection/reuse/virtualization plan.

Rules:

- no unbounded notification history;
- no full Collection rendering when most entries are off-screen;
- avoid recreating entire UI trees every frame;
- transitions are event-driven.

## 10. Audio budget

Local listener target:

- 1 primary biome ambient bed;
- <=3 supporting ambient layers;
- <=6 nearby persistent machine/creature loops at meaningful audible gain;
- transient SFX are pooled/bounded by natural lifetime.

Do not run an audible loop on every decorative prop.

Distance rolloff and category mixing must keep the Vault from becoming a wall of noise.

## 11. Animation budget

Use Animator/TweenService/shared controllers.

Avoid:

- one Heartbeat callback per prop;
- one coroutine forever per lantern;
- one task loop per bat;
- updating static seasonal props every frame.

Decorative loops should be:

- grouped;
- animation-track driven;
- tweened with bounded lifecycle;
- or static at lower quality.

## 12. Streaming and persistence

The current project has StreamingEnabled.

Golden visual work must validate:

- Starter/Home art streams without losing gameplay anchors;
- decorative models do not become gameplay truth;
- streamed-out visual layers recover correctly;
- no client visual object is mistaken for persistence.

Do not mark VS1-19 or full scale PASS from Golden art testing.

## 13. Measurement protocol for Work

For each major visual milestone:

1. record representative camera location;
2. record Render Stats / frame behavior in Studio/client where available;
3. note triangle/draw-call changes;
4. compare Halloween ON and OFF;
5. profile capture/reveal peak;
6. profile Vault + Energy Claim peak;
7. record obvious memory regressions;
8. reduce/merge/reuse before adding more effects.

Actual low-end/reference-device validation remains a later TA-14/15 gate.

## 14. Quality fallback order

If performance is poor, reduce in this order before harming gameplay clarity:

1. seasonal ambient particles;
2. decorative local lights/shadows;
3. background micro-animation;
4. texture resolution on non-hero assets;
5. repeated decorative mesh density;
6. rare reveal excess layers;
7. secondary foliage density.

Preserve:

- interaction readability;
- safe routes;
- creature silhouette;
- capture semantic feedback;
- UI clarity;
- authoritative state visibility.
