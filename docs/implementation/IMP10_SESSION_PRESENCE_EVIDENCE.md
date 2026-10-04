# IMP-10 trusted-session presence and locked recovery

Date: 2026-10-04 (Europe/Brussels). Base: merged PR #59, `4681325070e98b2949bada1b55dd36fd6fe2bc44`. AD-259 implementation follow-up; no contract amendment.

**Selected correction PASS. IMP-10 remains OPEN.** [Native evidence](evidence/IMP10_STUDIO_SESSION_PRESENCE_2026-10-04.json) and [phase matrix](IMP10_GATE_MATRIX.md).

## Selection and ownership

Travel/discovery/safe arrival/recovery already shipped in PR #59. The next phase gate covers hazards, locked-presence correction and transport fairness. Inspection found a smaller prerequisite: the completed presence record retained character/generation and last region without its trusted ProfileSession. Replacing a Ready session on the same avatar could reuse arrival readiness, travel eligibility and an old recovery region. A yielded context read could also observe a node for the replacement session before safe arrival. Both new regressions failed against the original implementation.

WorldTravelService already owns this bounded P0 presence record and the shared world pulse. The correction records its existing private session identity, checks it for readiness/travel/discovery observation, and clears the previous recovery region when the session changes. The existing native recovery owner establishes safe Home arrival before activating the replacement. A missing anchor keeps presence inactive at the existing retry cadence. A temporary loss of trust followed by Ready on the same session preserves its established arrival.

No new route, client authority, profile schema, state owner, geometry, hazard definition or scheduler is introduced. Existing WorldRuntimeService geometry/access/anchor checks, TA-7 acquisition interruption and ProfileSession P2/checkpoint/reconciliation remain the owners. Same-session character replacement still uses the existing regional recovery policy.

## Validation

| Check | Result |
| --- | --- |
| Narrow regressions | Four new cases cover replacement readiness/region, missing anchors, yielded travel and yielded presence observation; original readiness and observation failures reproduced before the fix |
| Fast regression gate | **191/191 PASS**; existing destination/discovery/tampering/replay/cycle, capture, persistence and progression cases retained |
| Native Studio C0 | **14/14 PASS**: ten coordinator cases on the native VM plus four actual character/runtime cases |
| Actual locked correction | Before the pulse, capture, extraction and fast travel reject locked presence. The pulse returns to the known unlocked Starter anchor once without persistent value change |
| Actual trusted-session replacement | Release/reacquire the same scoped DEV profile while retaining the avatar and world coordinator. Persisted world/collection/progression/wallet survive; readiness and travel reject before placement. Missing Home anchor keeps the replacement inactive; restoration places at Home once and exact world/collection survive save |
| Actual transport correction | Provisional capture entering a locked Secure Point cannot extract. Recovery interrupts custody through TA-7, changes the private generation and preserves the profile |
| Actual admitted P2 | A real DEV pre-write cut retains FinalizationPending while trust is unavailable. Existing reconciliation commits the original capture context once; later locked correction and duplicate resync preserve the finalized outcome |
| Local static/build | StyLua, Selene 0 errors/warnings, **28 Python CI tests**, dependency/integrity, Rojo build/sourcemap and zero strict analysis errors; existing CLI missing Roblox-definition warning remains |
| Shipped composition / final Edit | Normal server/client BOOTSTRAP_READY, native arrival and existing GUI pass. **85/85** source fingerprints and lengths match; no duplicate paths or temporary probes. Both ordinary boot scripts restored; Studio is Edit |
| Existing content | All 54 authored parts retained. Energy Core mesh IDs/materials/colors/transforms/sizes and Lighting 14.5 / 3 / 0 match the initial snapshot. Local untracked Blender experiments remain untouched |

Reproduce actual cases with `scripts/studio/imp10_presence_recovery.luau`, using the existing scoped world/spawn probes. The world probe exposes its existing coordinator only for injection of an actual replacement Ready session. Native coordinator cases reuse `tests/unit/WorldTravel.luau` with Studio module bindings. Disable ordinary bootstrap only during isolated probes, then restore it and remove the temporary modules. Probe expectations use the existing Interrupted projection, allow absent empty collection maps, establish discovery before exact-profile comparisons and use the actual replacement owner's monotonic release deadline.

Current-main revalidation (2026-10-05, Europe/Brussels): reused the existing PR #60 correction and integrated current `main` (`29b85ec785e176f6c7a31e740f9ddae29896e44d`), preserving its production-quality roadmap. The unchanged main implementation reproduces the unsafe replacement-readiness and yielded-observation failures; all four focused regressions pass with the correction. The full 191 fast tests, 28 Python tests and static/build gates pass again, with the existing missing Roblox-definition warning retained.

Direct Studio MCP revalidation passes all ten native coordinator cases and all four actual scoped DEV flows: locked correction, same-avatar session replacement/missing anchor/save, provisional interruption without extraction, and original admitted P2 exact-once recovery. A fresh ordinary server/client boot reports BOOTSTRAP_READY and restores the existing GUI. Final Edit checks match 85/85 sources with no duplicate paths or temporary probes; all 54 authored parts, Energy Core mesh properties and Lighting exactly match the initial snapshot. The JSON evidence records this revalidation separately from the original run. No hazard, transport convenience, art or later phase is implemented.

## Remaining dependency

Next: **one authored hazard -> server observation -> existing acquisition interruption/recovery -> safe-route and transport-fairness evidence**. Hazard mechanics/content, protected lifetimes, authorized world rewards and full scaling/security/performance remain open.

**VS1-19 / AD-249 remains DEFERRED — environment limitation. Controlled L1 requires 30 players at MaxPlayers=60, required repetitions and supported real-client frame/memory evidence. IMP-10 cannot be COMPLETE and IMP-11 cannot start.**
