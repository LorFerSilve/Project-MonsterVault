# IMP-10 authored DEV hazard and transport fairness

Date: 2026-10-05 (Europe/Brussels). Base: current main, `b3dedff974431da7c933d354d584877b6d89fefe`. Existing GDS-9 / TA-7 / TA-9 implementation; no contract amendment.

**Hazards and transport fairness PASS for authored DEV. IMP-10 remains OPEN.** [Native evidence](evidence/IMP10_STUDIO_HAZARD_TRANSPORT_2026-10-05.json) and [phase matrix](IMP10_GATE_MATRIX.md).

## Selection and root blocker

The completed AD-259 travel and trusted-session presence owner could correct invalid or locked presence, but no authored hazard was bound and real hazard occupancy never reached TA-7. A second fairness fault became visible when exercising recovery: placement at a field recovery anchor could immediately discover its nearby, previously unvisited travel node. Recovery must restore safe presence without manufacturing exploration.

This slice binds one optional Starter corrosive patch to the existing registry, authored index and world pulse. It expands the current WorldTravelService record rather than introducing a hazard service. Missing-arrival interruption, recovery discovery and crossing regressions failed before their respective corrections. No additional hazard category, travel connection, reward, profile schema or client route is introduced.

## Authored mechanic and authority

`hazard/starter-corrosive-dev-v1` occupies a 16 x 40 x 16 volume centered at (44, 10, 36) in the unused Starter corner. It is outside the first-capture route, all required encounter/utility radii and existing connectors. The vertical volume covers the Starter region bounds, so jumping within that region does not turn the patch into a safe surface. Its Recovery consequence remains explicitly phase-independent in Day, Dusk and Night, using the existing World Cycle binding.

Four native Roblox Parts provide one invisible server volume, a green footprint and a physical dark cross. The enabled native warning reads: "CORROSIVE PATCH / Entry causes recovery. / Carried capture is interrupted." Every part uses the existing central EnergyGreen or PanelPlastic palette; the Edit asset and cloned runtime are deterministically mapped. Native primitives are sufficient for this DEV mechanic, so no custom mesh or Blender asset is required.

WorldAuthoringIndex validates the single fixed ID, region, bounded axis-aligned geometry, safe/encounter separation, full marker footprint, cross and exact warning. WorldRuntimeService reads the real server character root and immutable authored binding. It checks the live marker/binding before admission and recovery. Missing, moved, hidden or corrupt server authoring fails closed; client streaming and local visual edits do not remove the server volume.

WorldTravelService retains the existing private ProfileSession/character/generation fences. One bounded three-axis segment check against the single authored box also rejects a crossing between observed safe endpoints. An observation during valuable-action admission is latched immediately: returning before the next pulse cannot cancel it. Authorized travel/recovery starts a fresh segment, so relocation does not count as crossing a hazard.

The existing shared pulse interrupts active/provisional acquisition through the existing TA-7 capture lifecycle before looking for an arrival anchor. Interruption is idempotent for the private presence identity. Failed interruption or unavailable/corrupt arrival keeps presence inactive at the existing one-second retry cadence; walking out does not escape a latched consequence. Successful existing recovery advances the character generation and places at a validated known unlocked-region anchor or safe Home fallback.

Admitted FinalizationPending work retains its original candidate and existing P2 reconciliation. Recovery neither extracts provisional custody nor deletes, rerolls or grants durable collection, discovery, mastery, purchases, history or Energy. Same-session duplicates, replacement sessions, stale avatars/generations, death/respawn and yielded travel/interruption retain the existing fences.

## Safe route and transport fairness

GDS-9 RA-01..03, TR-01..04 and HZ-01..06 remain the authority. The native authoring probe checks **315 grounded, hazard-free samples**, including the unchanged five connectors, field routes and protected first capture, plus the optional Starter route. Actual Humanoid walking reaches and exits the marked hazard; an actual provisional creature can still be carried along the safe baseline route and extracted only at the existing validated Secure Point.

Existing fast travel still requires actual discovery, unlocked access, safe source presence and no acquisition. Locked/unknown destinations and client-forged source/state are rejected. Hazard recovery adds no transport edge, pays no reward and preserves the same scheduled opportunity and World Cycle/context identity.

Recovery at a field node suppresses discovery observation until the server sees a valid departure and return to that authored location. The occupancy check uses the immutable node location even when its live binding is unavailable, so deleting/restoring a node cannot simulate departure. Home remains the existing baseline arrival. Existing discovered facts are retained. Native fresh-profile recovery proves that the field node is not granted, fast travel remains rejected, and only actual departure/return creates the usual P2 discovery fact.

## Validation

| Check | Result |
| --- | --- |
| Focused hazard coordinator cases | Seven relevant new cases: unavailable-arrival interruption/latching, yielded interruption and session/shutdown fences, interruption failure, travel race, recovery discovery, swept crossing and bounded cycle-independent registry |
| Full fast suite | **198/198 PASS**, including existing capture, access, cycle, persistence, economy and travel cases |
| Native C0 | **29/29 PASS**: 17 coordinator cases, four prior actual presence/recovery cases and eight actual hazard runtime cases |
| Native authoring | **29/29 PASS**: existing 19 cases plus ten hazard binding/geometry/visual negatives; **315/315** ground and hazard-clear samples |
| Actual acquisition/P2 | Active and provisional interruption without extraction; missing/corrupt anchor recovery; original admitted candidate reconciles once after a real DEV before-write cut; previously Secured value/history survive later exposure |
| Actual presence/world | Native walk entry; duplicate observations; Day-to-Dusk transition; same opportunity/context; real death/respawn with transport grace; fresh scoped DataStore/profile-runtime rejoin preserves durable world/collection/progression/economy |
| Actual fast crossing | Safe endpoints across the box reject admission before pulse; returning to the prior safe endpoint remains blocked; pulse interrupts custody and recovers without value change |
| Actual streaming/client | Engine eviction/restoration via temporary ReplicationFocus; real character remains valid. Client hides marker/forges metadata and generation; actual strict remotes reject forged payload, stale generation and unsafe context. Server recovery occurs once with unchanged profile |
| Static/build gate | StyLua PASS; Selene 0 errors/warnings; **28/28 Python PASS**; dependency/integrity PASS; Rojo build/sourcemap PASS; strict analysis exit 0 with the existing missing Roblox-definition warning |
| Shipped composition | Ordinary server/client BOOTSTRAP_READY and CleanOffline settlement; safe Home arrival with generation 3; ordinary boots restored |
| Final Edit / preservation | **85/85** source fingerprints/lengths match, no mismatches; all seven temporary probes removed. All original **54** authored parts retained, **58** after the four hazard parts. All five pre-existing MeshParts (four Energy Core parts plus the local crate) and recorded Lighting exactly match the initial snapshot |

Reproduce with `scripts/studio/imp10_hazard_recovery.luau` and `scripts/studio/imp10_hazard_client.luau`, beside the existing scoped world/spawn probes with ordinary boots temporarily disabled. Native coordinator cases reuse `tests/unit/WorldTravel.luau`; authoring cases reuse the existing authoring probe. Runtime scopes use real server profiles, characters, geometry and DEV UpdateAsync rather than client-injected authority. Restore ordinary boots/remove temporary modules and return Studio to Edit after validation.

The physical footprint/cross was visually verified in native Studio under unchanged Lighting. The MCP capture did not render world GUI text pixels, including unrelated native GUI probes; the enabled warning, exact text, native bounds and client replication were verified. This is DEV mechanic evidence, not production readability/accessibility or general world-art completion. Sampling/sweeping the trusted server root is one conservative observation path, not a new continuous movement or anti-cheat framework. Solo probes do not prove the full platform workload.

## Remaining dependency

Next: **authorized bounded world reward source/amount bindings -> existing TA-8 Energy / ProfileSession P2 operation and objective dedupe -> fault/rejoin evidence**.

Protected content lifetime classes and the full TA-14/15 World Scaling/security/performance audit remain open. **VS1-19 / AD-249 remains DEFERRED — environment limitation**: controlled L0/L1, **L1 30 players at MaxPlayers=60**, supported real-client frame/memory evidence and required repetitions are mandatory before IMP-10 COMPLETE. No subsequent phase or general PQL art work starts in this slice.
