# IMP-10 — Ordinary World Cycle and prospective context binding

Date: 2026-10-02 (Europe/Brussels). Decision: AD-258. Base: merged PR #57, `0561997ba2af86f4a819a76a33a95fa4b9f0be0d`.

**Selected dependency PASS; IMP-10 OPEN.** [Native evidence](evidence/IMP10_STUDIO_WORLD_CYCLE_2026-10-02.json) records native cycle C0 checks, actual authored capture/access/mastery, phase transitions during engine streaming, fresh Play/rejoin and final source/asset checks. [Full gate matrix](IMP10_GATE_MATRIX.md) retains the remaining phase-owned gates.

## Contract and implementation

GDS-9 §19 WC-01..03 and TA-9 §§14–16/21 require an absolute fixed-epoch, versioned server cycle and prospective evaluation. GDS9_CLOSURE_REPORT leaves timings to downstream content tuning. The explicit **DEV** definition is `world-cycle/ordinary-dev-v1`, epoch Unix **0**, ordered **Day / Dusk / Night**, **300 seconds each**, total **900 seconds**. These are tunable DEV content values, not a new gameplay or rarity rule. Existing eight authored habitats and contexts explicitly accept all three phases; species pools/weights and approved historical epochs remain unchanged. Lighting stays at the existing settings.

- `WorldRegistry` validates and freezes the cycle and habitat/context bindings before Ready. Unknown fields/IDs, missing/sparse/duplicate bindings, inconsistent versions, invalid duration/epoch/order and context phases outside a habitat reject. `SpawnPlan` also requires the protected Starter fallback to accept every ordinary phase.
- The pure `WorldCycle` owner samples injected absolute server Unix time (shipped `os.time`); half-open ordered intervals implement `max(0, now - epoch) % duration`. New servers/rejoins calculate the same absolute phase. Snapshot tables are immutable. Throwing, non-finite or regressing clocks return unavailable until a valid non-regressing sample resumes admission.
- Existing `WorldRuntimeService` owns this single cycle and its existing central pulse. No second scheduler, per-entity loop, player reset, MemoryStore or DataStore cycle record is introduced. The lifecycle monotonic clock remains separate. Public root attributes expose phase/definition/index/boundaries/availability and sorted bounded phase-eligible context IDs; access is still checked separately. Clients cannot access the server definition or influence it through attributes/requests.
- `WorldService` evaluates cycle eligibility **before allocating a new reservation**. The immutable result is pinned in server-only `identity().cycleContext`. Placement retries reuse this context, ID, species, epoch and variant. A phase transition does not reevaluate pending/live/acquiring records. New work samples current time instead of retaining a previous callback's phase; generation/ticket/reentrancy/cadence fences remain, with a post-evaluation stop fence and no successor scheduling after stale shutdown.
- Existing capture admission, ownership P2, historical origin, regional proof, mastery, access receipts, Energy, production, assignment, capacity and Held/Overflow remain with their existing owners. Cycle state is P0; it never writes player profiles. Secured provenance still stores its existing context/content snapshot, without a fabricated historical phase or migration. Commercial/event/temporary/world grants and unbound protected lifetime classes remain protected.

## Validation

| Check | Result |
| --- | --- |
| Full fast suite | **179/179 PASS**, including eight new grouped C0 cycle tests and existing regional/capture/economy/progression/persistence regressions |
| Native Studio cycle C0 | **8/8 PASS**: malformed/missing/sparse bindings, immutable definitions, negative/pre-epoch time, exact 300/600/900 boundaries, large jumps/no server reset, current phase-independent content, test-only restricted future eligibility, pinned placement retry, all capture custody states, invalid/throwing/regressing clock recovery and yielded stop fence |
| Actual capture across boundary | Native Day Starter claim/attempt at 299 → Dusk at **300** during provisional custody → unchanged original identity/profile → exact P2 origin/ownership/active return/mastery → one fresh Dusk replacement. Old submit cannot repeat the grant |
| Actual post-transition captures/access | Production claim funds **720**; two Mid unlocks leave **520**; scheduled Mid A/B captures occur in Dusk, Advanced in Night after the real prerequisites/purchase; all four mastery paths pass, final wallet **320** |
| Native transitions/fail-closed clock | **899.999 is Night; 900 is next-cycle Day**. Live identities/profile stay unchanged. Old/duplicate pulse tickets are inert. NaN clock exposes unavailable, preserves live entities and blocks a genuinely retired slot's replacement; 901 resumes a fresh current-context reservation |
| Existing scheduling/authority bounds | Locked Mid A remains dormant; real access activates authored pools. Eight-slot/two-per-region caps, Starter fallback, actual Destroy/despawn/refill and invalid/restored anchor checks pass through the reused regional probe |
| Engine streaming during transition | **Actual stream-out/in observed**, Day→Dusk at 1200 while the client projection is absent; same server identity and population, pinned Day provenance, new Dusk public readback. Separate local projection-loss simulation also restores identity |
| Native client tampering | Local phase/eligibility attributes never affect server state; forged phase/index/eligibility/time and species/rarity/context/position payloads reject `REJECT_VALIDATION_PAYLOAD`; server owner is absent from client DataModel |
| Save and fresh Play/rejoin | Real scoped DEV save owns four originals with wallet **320**. Fresh shipped ProfileRuntimeService compares exact collection/progression, restores all four masteries/access, and **three** historic purchase retries return AlreadyCommitted. New world identities are distinct; injected absolute time 1200 still yields cycle index **1**, Dusk, without reset |
| Static/build | StyLua/Selene, **28 Python CI tests**, architecture/integrity, Rojo build/sourcemap and **zero Luau type errors** PASS. Existing CLI missing Roblox-definition warning remains |
| Shipped composition/final Edit | Native server/client BOOTSTRAP_READY; latest console has no script errors. **84/84 source parity**, 54 authored parts/bindings, StreamingEnabled, MaxPlayers=60, probes cleaned, Studio Edit |
| Asset/material preservation | Energy Core's four native colors/materials, mesh/texture IDs, geometry/transforms, five model pivots/scales and Blender/GLB sources unchanged. Lighting ClockTime **14.5**, Brightness **3**, Exposure **0** unchanged |

Native probes use real engine characters, authored content, existing scheduling/capture/transaction owners and isolated DEV stores. Only timing/RNG are injected; persistence wall time remains separate from manually advanced world lifecycle/cycle time. A first client assertion incorrectly expected unchanged replicated eligibility to overwrite a local spoof; the probe was corrected and the entire streaming flow passed again. Authority was independently verified on the server. Phase-specific content predicates exist only in labeled unit fixtures; no authored DEV content acquired new gating or bonuses.

## Remaining gates

Next dependency: **travel/discovery/safe arrival/recovery authority** over the existing authored destinations. No travel, hazard, correction or reward action begins in AD-258. Protected content lifetimes and the full TA-14/15 scaling/security/performance audit remain open.

**VS1-19 / AD-249 remains DEFERRED — environment limitation. Full controlled L0/L1, L1 30 players at MaxPlayers=60, required repetitions and supported real-client frame/memory must actually pass before IMP-10 COMPLETE. IMP-11 cannot start.** Solo Studio and deterministic fixtures do not replace this gate.
