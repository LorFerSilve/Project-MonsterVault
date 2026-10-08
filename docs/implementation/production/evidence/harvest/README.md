# Golden continuation — creature motion and Spectral Harvest

Date: 2026-10-08. Branch: `codex/golden-slice`, continuing `8cb23df8` on draft
[PR #76](https://github.com/LorFerSilve/Project-MonsterVault/pull/76).
The [reclaimed reserve / radioactive Vault](../reclaimed/README.md) is reused;
this pass does not claim another map enlargement or final owner art acceptance.

## Implemented

- Common and protected Legendary presentation gain bounded breathing, glancing,
  nodding and reaction poses in the existing shared controller. Gameplay roots,
  capture range, intrinsic rarity and ownership remain unchanged. Reduced Motion
  and LOW effects restore static framing. These are cosmetic model poses, not
  imported Animator tracks.
- The existing accumulator has eight native EnergyGreen buffer segments driven
  by accepted owner production readback. Streamed children/model replacements
  restore the latest projection without polling. An absent projection says
  `OPEN VAULT FOR OUTPUT`; it cannot imply empty production. Confirmed claims
  briefly activate the meter, and shutdown restores authored pose/readout.
- Halloween dressing is recomposed around the enlarged court, northern ruins
  and Vault: 19 pumpkins, 12 lanterns, six physical hangers, four candle trays,
  two opaque-thread webs, nine autumn clusters and the northern reliquary.
  Floating/obsolete blockout placements were removed. Existing editable Blender
  sources, persistent mesh IDs, palette and audio are reused; no import/upload
  is pending. The layer is an explicit art preview, default OFF, without event,
  spawn, reward, calendar or commerce authority.
- LOW disables all three seasonal lights and the emitter. Reduced Motion clears
  already-live motes immediately. OFF removes the layer and its grading.

## Native validation and actual gameplay

[Motion probe](motion_native.json): **11/11** checks pass using native models and
RunService: idle, engage, low effects, projected meter, fragmented stream-in,
model replacement, 16-record bound, claim response, unknown output, reduction
and cleanup. The isolated probe uses **fixture +27 -> 127**, not a real profile
claim. It was removed and normal ClientMain restored before ordinary Play.

[Ordinary Play trace](capture_native.json) separately proves:

- actual server-saved Energy claim **+524**, wallet **2 -> 526**;
- ordinary reviewed/confirmed first capacity upgrade **25 Energy**, wallet
  **526 -> 501**, Collection capacity **10 -> 16**;
- a normal capture of exact instance
  `creature-5429a7f5-7116-428f-a799-b0c07074a7ea-3`:
  `Claimed (6) -> TransportActive (7) -> FinalizationPending (8) -> Secured (9)`,
  final profile revision **323**, followed by Collection **11/16**, Overflow 0;
- real creature reaction while its gameplay root remains stable.

These are legitimate DEV gameplay transactions. No creature was deleted, no
profile was injected, and the capture outcome was not forced. Repeated claim
receipt observations in the trace are readbacks, not repeated grants. The early
reaction listener omitted the status field; only `play.states` is the complete
successful lifecycle trace. Fresh normal Play visibly retained **11/16** and
[wallet 501](rejoin_native.json); the Collection screenshot below is its readback.

The reopened Studio contained a moved `StarterBounds` at **(208,7,80)**. Its
prior frame/size/tags were preserved as `ServerStorage.GoldenRecoveredStarterBounds`.
Only its position was restored to the current source layout **(0,10,-48)**;
[final Edit record](final_edit_native.json) retains the recovery note. Existing
six approved layout changes and all other 52 functional anchors still match
the source-backed whitelist. The native package check now compares tag sets
in sorted order, so a Studio reopen cannot cause a false failure from tag order.

[Authoring checks](authoring_native.json): **29/29**, including **315 grounded +
315 hazard-free route samples** and ordinary locomotion. [Final parity](parity_native.json):
**111/111** exact sources. Normal ServerMain/ClientMain enabled; temporary probes
removed; HttpEnabled restored false; Studio left **Edit**, seasonal preview OFF.

## Delivery and performance

| Native package | BaseParts | MeshParts | Repeated mesh triangles | Bytes |
| --- | ---: | ---: | ---: | ---: |
| Permanent world | 1,012 | 651 | 325,963 | 396,776 |
| Existing prefab library, unchanged | 101 | 101 | 45,531 | 445,522 |
| Removable Halloween template | 177 | 116 | 29,982 | 63,659 |

[Permanent/library readback](package_native.json) and [seasonal readback](seasonal_native.json)
are exact. Materials are completely mapped; seasonal scripts/tags/colliders/
touch/query writers: **zero**. Seasonal bounds: <=180 parts, <=35k repeated mesh
triangles, three non-shadowing lights, one Rate-3 emitter with lifetime <=3s.
The shared controller remains <=16 motions, with eight cached gauge segments.
No per-prop Heartbeat, new polling owner or duplicated profile snapshot was added.
The library's new native serialization emitted 445,576 bytes with identical
readback; its existing 445,522-byte delivery file was retained unchanged.

[Actual 120-frame samples](performance_native.json), HUD enabled:

| View | p95 ms | Opaque triangles / draws |
| --- | ---: | ---: |
| Starter, Halloween ON | 67.90 | 186,078 / 54 |
| Starter, OFF | 68.03 | 173,346 / 41 |
| Vault, ON | 68.07 | 49,395 / 59 |
| Vault, OFF | 68.07 | 46,889 / 51 |

**Both 16.67ms and 33.33ms frame targets fail in these workstation samples.**
OFF samples observed 480 Heartbeats per 120 RenderStepped events, Heartbeat p95
about 18ms. Similar ON/OFF cadence does not establish the cause. The earlier
18ms/68ms/101ms evidence remains historical; real-device cost, render cadence
and long-term memory stability need investigation. Short samples here use about
2.84-2.97GB and do not prove memory stability. No TA-14 or VS1-19 closure.

## Native screenshots

Original Studio MCP JPEG bytes, without image edits. [Camera/method record](screenshot_views.json)
and [SHA-256 inventory](screenshot_hashes.json). Each ON/OFF pair uses the same
camera coordinates in separate Play sessions; streamed dressing, avatar and
viewport size may differ. Owner artistic acceptance remains open.

| View | Permanent OFF | Halloween ON |
| --- | --- | --- |
| Field Station / court | [OFF](harvest_starter_off.jpg) | [ON](harvest_starter_on.jpg) |
| Northern ruins / reliquary | [OFF](harvest_northern_off.jpg) | [ON](harvest_northern_on.jpg) |
| Radioactive Vault exterior | [OFF](harvest_vault_off.jpg) | [ON](harvest_vault_on.jpg) |
| Vault interior | [OFF](harvest_interior_off.jpg) | [ON](harvest_interior_on.jpg) |

[Capture engage](harvest_capture_engage.jpg),
[successful Custody / carry feedback](harvest_capture_outcome.jpg),
[actual saved +524 claim](harvest_claim_saved.jpg),
[Collection 11/16 after fresh Play](harvest_collection_rejoin.jpg).
The engage image belongs to an earlier attempt; these are still frames, not an
uninterrupted video. Secured is proven by the native trace, not by relabeling the
Custody image as ownership.

## Reproduction and remaining acceptance

After the [existing permanent reproduction](../reclaimed/README.md#asset-import-and-reproduction),
run `tools/roblox/finish_golden_motion.luau` in Edit, then
`tools/roblox/build_halloween_2026.luau`. Use the strict native exporters
`export_refresh_package.luau` with current `GoldenWorldLayout.world` and
`export_halloween_2026.luau`. Serialized world/template deliver through Rojo.

Local automated validation: **341/341 fast**, **15/15 focused Golden**,
**28/28 Python**, dependency/integrity, formatting, zero Selene errors/warnings,
Rojo build/sourcemap. Configured Luau analysis exits 0 with missing Roblox
definitions warnings; it is not a clean engine-definition type proof.
[Validation record](validation.json) records the commands; remote CI remains
mandatory on the pushed head.

Golden owner art review, physical controller menu/select/close, actual increased
platform text preference, reference devices and long-session performance remain
open. Broader PQL-1/2/3/4/8 and IMP-11 later gates remain open. Next practical
priority is render-cadence/performance diagnosis and those remaining Golden
checks; later backend dependency remains TA-10 §8 Shared Objectives -> observed
personal eligibility -> §9 owning-profile exact-once Collaboration Rewards.
