# Golden Slice implementation and native evidence

Date: 2026-10-06. Base: `80b9e8b25973ac2c0dab7a5ea3bfddf35d9f98f5` (main after PR #75). Branch: `codex/golden-slice`.

**IMPLEMENTED, acceptance still open.** The permanent Starter/Home path, imported production kit, native UI and representative sensory feedback are integrated and inspected in Studio. Physical controller menu retest, actual increased platform text preference, missing historical before views and reference-device performance remain open. This is not Golden reference-quality closure, full PQL completion or release readiness.

## Representative path

Starter arrival/vista -> Field Station -> Common encounter -> engage/containment -> failure or custody -> safety/Secured -> Collection -> ordinary travel Home -> Vault display -> production/claim -> next capacity aspiration -> Read Only Showcase.

- Existing secure/travel/capture roots remain authoritative. Five native Humanoid traversal segments returned success; ordinary travel returned the actual Player to Home. [Traversal](evidence/golden/traversal_native.json).
- A normal shipped capture produced Failed, then a new exact instance reached TransportActive -> FinalizationPending -> Secured. The outcome was not forced. [Final lifecycle](evidence/golden/capture_result_final_native.json), [capture peak/history](evidence/golden/performance_native.json).
- The user physically pressed PS5 □ twice and moved with the stick to safety; they reported “secured, mossbud saved to collection…”. Actual native Gamepad1 ButtonX edges and custody were recorded. Native Secured was observed for `creature-19a75b30-df16-482a-a97b-9887e74a30f3-16`; the retained menu snapshot does not contain that final capture transition. Do not relabel it as a raw Secured trace. [Controller capture](evidence/golden/gamepad_capture_native.json), [failed menu entry](evidence/golden/gamepad_secured_native.json).
- The touchpad menu route failed in the human test. △/ButtonY now provides direct Collection entry and focus; a synthetic ButtonY event opened the modal. The tool identifies that event as Keyboard, so **physical △/navigation/○ retest remains open**.

## Permanent art and assets

Applied direction: stylized arcane-tech expedition. Mossline uses layered rock shoulders, clustered pine silhouettes, clear negative space, meadow banks, a readable path and engineered Field Station. Home uses a framed bridge arrival, cliff/shore masses, a ribbed foundry shell, two creature plinths, accumulator, conduits, aspiration relay and the reused Energy Core. Short accents use the central EnergyGreen palette; materials prioritize native Metal/SmoothPlastic/Fabric/Rock/Grass rather than unique PBR textures.

The source audit contains **14 new editable assets, 13 used at runtime**. Mossbud maps to the existing Common Species; Helion maps to `species/stability-orb-dev`, explicitly Legendary DEV. Prismfin is retained only as an offline Rare concept because the authored registry has no Rare Species. No new gameplay identity or rarity odds were introduced.

- [Asset manifest](GOLDEN_SLICE_ASSET_MANIFEST.md), [editable source audit](../../../assets/exported/golden_source_audit.json), [mesh IDs/materials/pivots](../../../assets/exported/golden_asset_manifest.json).
- Reproducible generators: `tools/blender/generate_golden_slice.py`, `generate_golden_launch_kit.py`; verification: `validate_golden_sources.py`.
- Blender MCP was unavailable in this environment. The approved Blender 5.2.2 CLI fallback was used; sources derive repository paths from `__file__`. Editable `.blend`, per-asset GLB and the two combined FBX import transports are retained.
- Source Common/Legendary rigs retain `GentleIdle` actions. Runtime uses shared cosmetic bob/yaw/rotor motion; imported Roblox Animator tracks are **not** claimed.
- Supplemental five-asset native import: 15 MeshParts, normalized bottom pivots/orientation, persisted asset IDs. All 699 BaseParts across prefabs/permanent world/seasonal template have known central material groups; 487 are MeshParts. Unmapped meshes, scripts and authority tags: zero. [Native mapping](evidence/golden/launch_import_native.json).
- Rojo delivers `golden_assets.rbxm` (210607 bytes), `golden_world.rbxm` (146637 bytes), `seasonal/halloween_2026/dressing.rbxm` (61643 bytes). Exact native deserialize/readback passed for part CFrame/size/appearance/collision/mesh IDs, model pivots/scale and GUI text; no script/tag authority was serialized. [Roundtrip](evidence/golden/serialization_roundtrip_native.json).
- The 58 functional authored BaseParts retain positions, sizes, tags and collision roles. The initial 64-entry audit also included Terrain, four original Core meshes and the local test crate; those originals are retained. Secure pads become visually transparent beneath the Field Station/arrival treatment; Home ground material and Lighting are intentionally presentation changes. User/local source assets are preserved under `ServerStorage.PreservedLocalAssets` and raw imports under `GoldenImportSources`.

## Native UI, feedback and authority

`GoldenTheme`, `RarityTokens`, `GoldenFeedback`, `GoldenSensory` and `GoldenCreatureVisuals` supply native panels, Gotham hierarchy, buttons, cards, currency, objectives, modals and notifications. Existing Collection/Vault/Journey controllers retain command ownership. Short phone layouts hide competing HUD during capture and keep movement/jump areas clear; modal content scrolls.

- Capture uses engage/containment pulses, beams, restrained audio and distinct failure/custody/Secured copy. Only authoritative Secured celebrates ownership. A custody model is a cosmetic carry presentation, not a saved creature. Model selection requires the approved intrinsic Species/rarity pair.
- Rarity has text plus shape/color redundancy: Common circle, Rare diamond, Legendary crown/gold halo. Rare assets/audio/tokens do not make a Common creature Rare. A current native protected DEV probe proved immutable lifetime/context, timeout/replacement and no value extraction. [Protected validation](evidence/golden/protected_final_native.json).
- Claim uses the existing matched current receipt: machine response, 3 or 5 short energy orbs, local beam, authoritative count-up and completion. Native ordinary claims included +1253 and +8; no economy change or Robux purchase. Replayed/historical, unrelated, stale and unconfirmed receipts do not celebrate. [Claim](evidence/golden/energy_claim_native.json), [performance/readbacks](evidence/golden/performance_native.json).
- Reduced Motion ON + LOW effects + audio OFF retained a native matched +311 claim, **2720 -> 3031**, with zero transient BaseParts and muted loops/stopped cues. [Reduced claim](evidence/golden/reduced_claim_final_native.json). `PresentationPreferences` combines platform and manual reduction so manual controls cannot defeat a platform preference.
- Eleven original generated WAVs and their source manifest are retained. Existing uploaded IDs are reused for reserve/machine ambience, creature, capture, failure, Secured, Rare/Legendary, Energy and UI. Two muted/mixed ambience loops plus six reusable one-shot sounds replace per-prop loops. No further uploads/videos were requested; the user's monthly quota is preserved.
- Collection uses only accepted owned readback facts. Missing facts show an ordinary Owned creature card without a blank portrait or fabricated Species/rarity. Approved display facts may enrich only the matching exact instance row.
- The owner display originally disappeared when the two-row management page changed. AD-269 binds one optional independent safe `displayCard`, reusing the existing Showcase filter and wire budget. It exposes exactly instance/Species/intrinsic rarity/Mutation/Trait/display slot; full profile/private provenance/signatures/commerce fields remain absent. Ready session/profile-revision fencing removes stale local displays. [Pagination](evidence/golden/display_paging_native.json).
- First-open ViewportFrames were blank despite populated native geometry. Parenting the viewport before building the scene and setting camera Focus fixed fresh Play startup; the current owner preview and phone screenshot show the actual portrait without a diagnostic helper.
- Showcase retains AD-268 owner consent, expiry, generation/replay/session fencing and no visitor writer. Native regression: **29 distinct cases**, one real client + three isolated peer adapters; this is not two-real-client evidence. Screenshot 13 is the current **owner preview** of the same Read Only card. [Native Showcase](evidence/golden/showcase_native.json).

## Seasonal and Lighting

Permanent baseline: afternoon ClockTime 15.5, restrained bloom/atmosphere/specular contrast, three non-shadowing warm foundry lights. The removable Halloween template contains 138 parts/83 meshes, three non-shadowing lights and one Rate-3 emitter, with pumpkins/lanterns/autumn clusters/opaque webs/ruin accents/reliquary.

Actual Studio preview ON/OFF toggling changed ClockTime to 18.4 and added spectral grading; OFF removed the client layer and restored the saved Lighting/Atmosphere properties exactly. Seasonal parts are noncolliding/nonqueryable, with zero scripts/gameplay tags. LOW disables decorative lights/motes; Reduced Motion suppresses motes. This is presentation only, with no event calendar, reward or commerce implementation. [Toggle isolation](evidence/golden/seasonal_toggle_native.json).

## Measured bounds

One shared render controller: at most 16 cosmetic motions, 10 observed wild creatures, one approved owner display, one custody presentation, eight transient effects, six one-shot sounds and two ambience loops. No per-prop Heartbeat or forever task. Native particles are brief 16/32 bursts with <=0.65-second lifetime; ordinary/strong claim uses 3/5 orbs with 1.2-second disposal.

[Six-view measurements](evidence/golden/performance_native.json) use 180 RenderStepped samples on the current **Studio workstation**, not a physical mobile/reference client. Rendering totals below exclude the separate shadow pass.

| Native view | p95 ms | Visible triangles | Draw calls | Memory MB, before -> after |
| --- | ---: | ---: | ---: | --- |
| Permanent Starter | 23.54 | 24358 | 28 | 2300.38 -> 2300.38 |
| Halloween Starter | 23.14 | 32674 | 43 | 2342.63 -> 2342.64 |
| Capture sample | 23.29 | 12402 | 21 | 2300.76 -> 2300.76 |
| Legendary DEV reveal | 22.18 | 15336 | 18 | 2374.81 -> 2374.81 |
| Vault idle | 23.51 | 27606 | 42 | 2337.95 -> 2337.95 |
| Energy claim | 23.20 | 20462 | 36 | 2333.02 -> 2338.38 |

The working <=450k-triangle/600-draw targets have headroom. **The 16.67 ms reference target is not proven**; these Studio samples exceed it. An earlier long-session physical-controller capture recorded p50 67.24/p95 101.05 ms around 2422 MB; the cause is not established and the artifact is retained. The Energy render query is an early receipt frame, not guaranteed maximum overdraw; the transient maximum is separately sampled. TA-14 device/memory/scale gates and VS1-19 remain open/deferred.

## Evidence and checks

- [15-image manifest](evidence/golden/screenshots.json), [gallery](evidence/golden/README.md). PNGs are native JPEG capture pixels converted only in format; no external renders, retouching or fake before images.
- Matched permanent/Halloween Starter and Home views are retained. Only Starter `01-before-spawn.jpg`/`studio_before.json` exist as historical before evidence; other requested before views were not captured.
- Mobile: A06 emulator landscape 705x338 and portrait 359x718, native Touch/Activated checks and scrolling cards. 1.5x declared font stress passed TextFits for six navigation controls at 24px in two rows and portrait Collection. **Actual platform PreferredTextSize stayed Medium**; Largest was unavailable to the user and is not claimed. [Font stress](evidence/golden/font_stress_final_native.json), [mobile integration](evidence/golden/integration_native.json).
- **339/339 fast**, **28/28 Python**, dependency/integrity, StyLua, Selene (zero errors/warnings), Rojo build/sourcemap pass. Configured Luau analysis exits 0 but warns that Roblox definitions are absent; it is not a clean engine-definition type proof. [Normal remote CI passed](https://github.com/LorFerSilve/Project-MonsterVault/actions/runs/37435060320/job/112174726070) for recorded head `59b9db503b215df10a7a11de926cfe744bf5c618`; [exact validation artifact](evidence/golden/ci_validated_native_package.json). Each subsequent head retains its own normal CI prerequisite.
- **109/109** exact source parity in final Edit mode. Normal ServerMain/ClientMain enabled; QA store seam/scope and helper scripts removed; HttpEnabled restored false. [Final parity](evidence/golden/source_parity_native.json).

## Next work phase

Resume the existing branch and Studio map; no production import is pending. Retest physical △ Collection entry, D-pad/✕ navigation and ○ close; validate the real platform text preference when available. Review representative visual quality and investigate the recorded long-session frame exception on the appropriate real-client/device owner. Keep the PR draft until applicable Golden acceptance is resolved; do not infer release/PQL closure from CI alone.

Broader biomes, display positions beyond the two authored plinths, a live Rare Species, imported Animator tracks, every future UI/social screen, physical two-client Showcase, Photo Mode and commercial cosmetics remain outside this representative delivery. Later IMP-11 Shared Objectives/events, trading and commerce were not started. The next remaining IMP-11 backend dependency stays TA-10 §8 contribution -> server-observed personal eligibility -> §9 owning-profile exact-once P2 Collaboration Rewards; it does not replace the immediate Golden acceptance work.
