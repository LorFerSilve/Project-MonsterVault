# IMP-10 — Region-scoped ordinary spawn scheduling

Date: 2026-10-02 (Europe/Brussels). Decision: AD-257. Base: PR #56 merged after green exact-head CI, `6dff14ced92c8f683fc1c2231e0d81bbbee94626`.

**Selected dependency PASS; IMP-10 OPEN.** [Native evidence](evidence/IMP10_STUDIO_SPAWN_SCHEDULING_2026-10-02.json) records the final scoped DEV flows, real engine eviction/restoration, P2 fault cuts, fresh Play/rejoin and source/asset checks. [Full gate matrix](IMP10_GATE_MATRIX.md) keeps the remaining phase gates open.

## Implemented chain

- `SpawnPlan` derives eight immutable server-only buckets from the existing eight authored context anchors/habitats and registered Common pools. Equal DEV species weights are explicit definitions; no client field, wallet, paid state or device input selects content. The existing VariantIdentity generator runs once per reservation; retries reuse species, rarity, context, epoch, variant and CreatureInstanceId.
- The existing WorldService owns one central round-robin coordinator: two buckets per one-second pass, one live encounter or reservation per habitat, at most two per field region and eight total. Pending work and acquisition occupy the same slot. Reservations try at most three times, two seconds apart; ordinary refill waits five seconds. One generated namespace plus a monotonic allocation sequence replaces an unbounded retired-ID history in the shipped regional path.
- Current alive, Ready, server-observed presence and the existing mastery/receipt access owner activate ordinary regional opportunities. A locked or unknown region cannot activate a bucket. Dormant regions do not create new reservations and refill gradually on return; already-live idle encounters keep their bounded 180-second lifetime. Density does not alter odds.
- Immutable region/habitat/anchor transforms, tags and metadata are rechecked. Five native ground rays and a bounded overlap query validate each fixed placement. Missing/moved content, unsafe placement or deleted server projections fail closed; invalid live bindings retire idle encounters. A failing bucket is isolated. There is no invented relocation/topology or per-entity Heartbeat/task loop.
- The scheduler preserves the proven Starter Orb opportunity, its historical context/epoch, geometry and variant rules. It remains separately replenishable alongside the ordinary Starter field pool. Explicit server-only fixture composition remains available to prior probes; shipped composition uses the regional plan.
- Idle cleanup never expires claimed, attempted, provisional, transported or FinalizationPending acquisitions. Existing capture/P2 retirement frees a slot exactly once; replacement gets a fresh identity only after retirement. Generation, revision, record identity, cadence and pulse-ticket checks suppress duplicate, reentrant, yielded and stale callbacks, including shutdown.
- Encounter population stays P0, never in player DataStores. Existing ownership, regional proof, mastery, Energy, access receipts, Held/Overflow, production and assignment owners are reused. New pool members receive no invented production rates. World/commercial/event/temporary rewards and future protected lifetime classes remain unbound and protected.
- The reused DEV creature body uses the central `FixtureCreature` palette entry (Neon, RGB 77/205/255) on construction. The four Energy Core palette groups, imported meshes, transforms, pivots, scales and Blender/GLB sources are unchanged.

## Validation

| Check | Result |
| --- | --- |
| Full fast suite | **171/171 PASS**; eight new grouped scheduler cases plus all existing capture/economy/progression/persistence regressions |
| Native Studio C0 | **8/8 PASS**: authored pools/bounds, dormancy/caps/staggering, duplicate tickets, retry identity/fault isolation, protected capture states, deleted projections, yielded stop races, invalid clock/RNG/selection, 400-pass bounds/fresh-session identities |
| Native region/access flow | Locked Mid A has no opportunities; ordinary Starter selects Companion; actual Starter capture/return/mastery → production claim 720 → independent Mid unlocks → actual scheduled Pebble/Leaf captures and active returns → Mid masteries → Advanced purchase/capture/mastery |
| Capture/replenishment | Actual provisional transport retains its occupied bucket; P2 ownership/provenance and mastery use the original reservation identity; old submit cannot grant again; one fresh replacement after retirement |
| Native caps/lifecycle | All eight authored habitats populated after visits; maximum two per region. Actual model Destroy, idle TTL, moved live anchor and restored binding produce bounded retirement/refill; duplicate pulses never fork the delay chain |
| Native P2 fault cuts | Real DEV repository pre-write failure and lost-after-write result both observed Pending. The original slot/identity survives beyond idle TTL; existing central capture reconciliation and Class A readback recover exactly once; no second grant or early replacement; saved ownership and wallet zero |
| Native streaming/client boundary | **Actual engine stream-out and stream-in observed**, same server identity/population. Native observer also survives explicit local projection removal/restoration; forged species/rarity/context/position payload rejects `REJECT_VALIDATION_PAYLOAD`; local metadata cannot change server identity or wallet |
| Fresh Play/rejoin | Shipped ProfileRuntimeService restores all four masteries, exact collection/progression, wallet **320**, and **three** historical purchase retries return AlreadyCommitted. Restored access activates two Advanced habitats plus protected Starter with new runtime identities |
| Shipped bootstrap | Server/client BOOTSTRAP_READY, clean shutdown/fresh starts; final console has no script/gateway errors |
| Static/build | StyLua, Selene, 28 Python CI tests, architecture/integrity, Rojo build/sourcemap and zero Luau type errors PASS. Existing CLI warning about missing Roblox definition files remains |
| Final Studio | **Edit; 83/83 source parity; 54 authored parts and semantic bindings retained; transient probes removed; StreamingEnabled; MaxPlayers=60** |
| Energy Core preservation | Four native materials/colors and mesh/texture IDs, geometry, transforms, five model pivots/scales and source assets unchanged; visually checked under existing Studio Lighting |

Native probes reuse the real capture/progression/P2 composition with isolated DEV scopes and actual engine characters, authored ground and models. Only clock/RNG/scheduler timing is injected. World time is advanced independently of persistence wall time, avoiding fabricated future saves. Engine eviction is genuine streaming evidence; the separate local-loss simulation is labeled explicitly. Solo Studio and bounded C0 workload are not 30-player or supported real-client performance evidence.

## Remaining gates

Next dependency: **ordinary World Cycle clock and prospective context binding** under GDS-9/TA-9. Current DEV contexts are phase-independent; this slice invents no phase eligibility or rare/protected lifetimes. Travel discovery/relocation/safe arrival/recovery, hazard/correction fairness, authorized bounded rewards and full security/scaling remain open. No next system starts in this change.

**VS1-19 / AD-249 remains DEFERRED — environment limitation. Full controlled L0/L1, L1 30 players at MaxPlayers=60, required repetitions and supported real-client frame/memory must actually pass before IMP-10 COMPLETE. IMP-11 cannot start.**
