# IMP-10 travel, discovery, safe arrival and recovery

Date: 2026-10-02 (Europe/Brussels). Decision: AD-259. Base: merged PR #58, `853e42dfc345f24dd0c41d0efafd28598f46c30f`.

**Selected dependency PASS. IMP-10 remains OPEN.** [Native evidence](evidence/IMP10_STUDIO_TRAVEL_RECOVERY_2026-10-02.json) and the [full matrix](IMP10_GATE_MATRIX.md) retain every downstream gate.

## Contract and implementation

GDS-9 RA-01..03/TR-01..04 and TA-6/9 §§28–30 permit Home Hub ↔ an unlocked, actually discovered field outpost. The five existing authored nodes/anchors and fixed topology are reused. No direct field-to-field fast-travel edge, biome, cost, hazard or reward is invented.

`World.RequestFastTravel` uses the existing Class C route and its existing `nodeId` selector plus a positive integer `characterGeneration` freshness hint. It rejects extra fields and expectedRevision. The native server resolves the actual alive character/private generation, Ready session, source node, destination binding, receipt/mastery access, persistent discovery, current cycle context and capture acquisition before movement. The existing gateway caches exact duplicates; the small world-domain owner serializes transitions and bounds repeated intents to one per monotonic second. Native prompts resolve the same server-owned targets. Client attributes and projections never authorize an action.

Safe arrival verifies immutable node/outpost/region/recovery bindings, five bounded collidable-ground samples, anchor-relative floor height and bounded headroom. Native R15/R6 standing height determines the root transform; no client CFrame is accepted. Relocation uses PivotTo, zeroes residual velocities and verifies the resulting region/anchor. Missing, moved, forged or obstructed bindings reject without a fallback travel or mutation.

One bounded per-player presence record runs in the existing world pulse. New/replaced avatars become actionable after safe placement. Invalid positions and corrupt/locked regions deactivate presence; authored connectors outside region volumes remain walkable. Recovery prefers an eligible known region anchor and falls back to validated Home Hub. Missing anchors keep presence inactive until a valid binding returns. Session/character/generation, busy and shutdown fences prevent stale continuations; failed travel schedules recovery rather than replaying the request.

TA-7 supplies a read-only acquisition predicate covering engagement, attempt, provisional/transport, grace and pending finalization. Recovery interrupts provisional custody before relocation, including suspended grace, and cannot extract it. An already admitted P2 candidate survives interruption unchanged. The pre-existing trusted shutdown-finalization policy remains separate and unchanged.

World schema 1 gains at most five `travelNodes` facts `{operationId, revision, contentSnapshotId}`. Preparation adds an empty map to valid legacy state without deriving discovery from mastery, ownership or purchases. Known IDs, bounds, proof shapes and explicitly approved epochs validate before Ready/save. Only actual server-observed presence at an accessible authored node creates a fact through the existing P2 writer; unknown results reconcile the same candidate/operation through Class A. Discovery grants no objective, mastery or Energy. Owner readback adds sorted discovered node IDs and the public generation hint, excluding private proofs.

## Validation

| Check | Result |
| --- | --- |
| Fast suite | **187/187 PASS**, including eight new grouped cases; capture/persistence/Energy/progression/assignment/Overflow-Held/cycle/scheduler regressions retained |
| Native Studio C0 | **10/10 PASS**: presence placement, bounded spam, invalid context, interrupted relocation, yielded races/replaced character/shutdown, missing anchors, protected epochs, P2 cut points/rejoin, acquisition/grace and original pending-finalization preservation |
| Actual travel/discovery | Starter and real Mid A/B/Advanced mastery/capture/purchase routes; all five discoveries persist. Hub roundtrips succeed; field-to-field, locked, unknown, undiscovered, wrong-generation and extra-authority requests reject |
| Duplicate/race | Exact gateway duplicate returns cached success without relocation, including after a later roundtrip; 25 native repeated intents are bounded. Two real client remote intents produce **one** success and one route rejection, with no progress write |
| Arrival/recovery | Corrupt current region, missing/moved arrival anchor, forged metadata and collidable obstruction fail closed. Missing Home recovery keeps capture/presence inactive; restoration recovers once. Actual provisional capture aborts on invalid-position recovery, never becoming ownership; stale avatar intent rejects. Native R6 standing height **4.1** and default-avatar recovery pass |
| Cycle context | Actual travel at **300**, Night transition at **600**, invalid cycle blocks travel/discovery without history changes, fresh Play at **1200** remains Dusk/cycle 1. Existing encounters/caps/Starter fallback survive |
| Engine streaming/client authority | Genuine projection eviction via temporary ReplicationFocus, keeping the authoritative character on valid ground; travel/return while client content is absent; same server identity restored. Separate local projection-loss test passes. Actual client position/unlock/discovery/generation/identity tampering rejects; private owner is absent |
| DEV persistence | Real UpdateAsync failures before write (**3 cuts**) and lost result after write (**1 cut**) restore the same discovery after departure; duplicates do not repeat it. Scoped save/fresh Play compares exact world/collection/progression, four original captures, five nodes, wallet **320**, all masteries and **three** exact purchase retries. Actual LoadCharacterAsync safely replaces the avatar and fences the old generation |
| Static/build | StyLua/Selene, **28 Python CI tests**, architecture/integrity, Rojo build/sourcemap and zero Luau type errors pass; existing CLI Roblox-definition warning remains |
| Shipped composition/final Edit | Ordinary bootstrap restored; native server/client readiness, owner world readback, 85-source parity, 54 authored parts, StreamingEnabled and MaxPlayers=60 verified; temporary probes removed |
| Assets | Validated Energy Core palette, mesh data/transforms/pivots/scales and Blender/GLB sources retained; Lighting 14.5 / 3 / 0 retained |

Reproduce with `scripts/studio/imp10_travel_recovery.luau` and `imp10_travel_client.luau`, alongside the existing world/regional probes. Temporarily disable ordinary bootstrap scripts only for isolated DEV compositions; restore them before the final normal boot and Edit checks. Probes use real native players/characters, authored instances, shipped services and scoped DEV DataStores. Clocks/RNG and cut points are injected. Native C0 fixtures supplement actual flows; solo evidence is not a performance gate.

The tests exposed the narrower transport-only custody reader, which was replaced at the travel boundary by the acquisition predicate. Probe positions were corrected to avoid legitimately entering the extraction radius, and scheduler waits account for staggered replenishment. Final checks pass on the corrected implementation.

## Remaining gates

Next: **hazards/locked-presence correction and transport fairness**. No hazard or reward implementation begins here. Protected lifetimes, concrete authorized world rewards and the full security/scaling audit remain open.

**VS1-19 / AD-249 remains DEFERRED — environment limitation. Full controlled L0/L1, L1 30 players at MaxPlayers=60, required repetitions and supported real-client frame/memory must pass before IMP-10 COMPLETE. IMP-11 cannot start.**
