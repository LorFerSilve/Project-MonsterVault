# IMP-10 protected DEV lifetime and capture fairness

Date: 2026-10-05. Base: `e151e0a5f40be230711d0f54b341089a6d40f0a7` (main after PRs #64–67). **Protected content lifetimes PASS; IMP-10 FUNCTIONALLY COMPLETE under AD-260.** [Gate matrix](IMP10_GATE_MATRIX.md); [native artifact](evidence/IMP10_STUDIO_PROTECTED_LIFETIME_2026-10-05.json).

## Contract and root blocker

GDS-6 §12 classifies Legendary Species as Protected Variants; Rare alone does not qualify. GDS-9 §22 EL-02/05 and TA-9 §§21–25 require an immutable reservation, a minimum Rare Encounter Stability Window beginning when publicly actionable, stronger TA-7 acquisition protection, streaming-independent existence and exact-once slot release. GDS-9 §23 keeps ordinary unclaimed P0 populations server-local. TA-7 §§17/20 and TA-4 own classification/auto-lock and original-candidate P2 reconciliation.

The existing scheduler already protected non-idle acquisition states, but SpawnPlan rejected every non-Common pool member, VariantIdentity emitted no protected classification, and WorldService had only a reservation-time ordinary expiry. Also, a yielded projection/activity observation could retire a newer claim revision. After an expired claim was released, interaction admission could allow another claim before the staggered cleanup tick. Both fences now sit in the existing world owner.

## One authored DEV binding

`species/stability-orb-dev` is an optional **Legendary** member of existing `spawn-context/starter-field`, weighted **1 against 100/100 Common entries**. It occupies that habitat's existing single slot, with **300 seconds of actionable stability**. The guaranteed Common onboarding encounter, geometry, four mastery recipes, capture chance and existing progression remain intact. No new region, spawn slot, transport edge or valuable client input is introduced.

Content advances to `content-snapshot/imp10-world-dev-v3`; approved earlier spawn/mastery/travel epochs remain readable. The immutable registry validates the only protected binding; SpawnPlan rejects other unbound classes. Species rarity and lifetime come from the server pool binding, never projection attributes or a client amount/ID. Reservation chooses identity/variant/context once and retries reuse it. Legendary classification reaches the existing initial Creature Lock in the same ownership P2.

## Lifecycle and owners

| Boundary | Existing owner and invariant |
| --- | --- |
| Reserved → IdleAvailable | WorldService reserves one slot first; successful activation starts the 300-second minimum, including after retries/yields. Effective idle expiry is the later of ordinary expiry and the stability boundary |
| IdleAvailable | Phase/context replan, absent players and client streaming do not shorten the window or reroll identity. Missing/corrupt authoritative server binding is a fail-closed exceptional cleanup, not client visibility |
| Claimed / AttemptActive | Existing TA-7 claim/attempt owner protects against idle expiry; first valid claim wins. Claim timeout remains 20 seconds |
| Failed / abandoned claim | Returns the same surviving opportunity to IdleAvailable without renewing its original boundary. Past that boundary a new claim is rejected immediately, then the bounded scheduler retires it |
| Provisional / TransportActive | Existing TA-7 custody consumes the original slot and identity. Recovery/hazard/death/session correction interrupts; it never secures ownership |
| TransportGrace | Existing disconnect grace remains 30 seconds, same custody/operation on valid same-server resume; expiry retires without granting value |
| FinalizationPending | Existing admitted P2 candidate survives avatar/session correction and idle/cycle expiry. Before-write retry and lost-result reconciliation preserve its exact operation and payload |
| Secured / legitimate cleanup | Original P2 auto-locks the Legendary creature and writes normal discovery/regional history once; consumes the P0 opportunity. Duplicate/stale callbacks cannot retire a replacement generation |
| Shutdown / rejoin | Existing trusted ProvisionalShutdown handles only eligible active custody; unclaimed P0 records do not migrate. Real profile rejoin retains one secured record and cannot resurrect the consumed world ID |

No second lifetime coordinator, wallet, persistence route or per-creature loop exists. Existing WorldRuntime pulse, WorldCycle, CaptureService, ProfileSession queue/P2, WorldTravel/session/generation fences and recovery policy remain owners. One native BillboardGui on the existing palette-mapped orb provides a diagnostic Legendary cue and actual availability state. Existing projection contract/store retains lifetime class, activation time and idle boundary without collapsing acquisition states or granting authority. Native Roblox primitives suffice; custom Blender modelling would not improve this diagnostic slice.

## Proven validation

- **213/213 fast:** eight new relevant cases cover binding/classification, actionable-time boundary, normal/protected expiry, cycle/replan, client projection tampering, yielded observation vs legitimate claim, timeout/failure/generation/disconnect release, finite multi-player claim, custody/grace/pending, both P2 cuts/transform replay/rejoin/auto-lock and distinct presentation states. Existing regression suite remains green.
- **52/52 native C0:** 32 pure engine cases, four protected-runtime suites, four existing presence suites, eight hazard suites and four world-reward suites. Actual authored Legendary selection, 20-second claim timeout, stable cycle context, real RemoteEvent rejection, real engine stream-out/in with the existing client observer, private-session replacement, corrupt binding, hazard recovery, pending P2, both real DEV DataStore fault cuts, trusted shutdown and fresh profile/runtime rejoin pass.
- **29/29 authoring; 315/315 safe-route samples:** legitimate ground/ordinary traversal still reaches all fields, the onboarding encounter and optional Starter field without crossing the hazard. Existing all-region scheduler/mastery/access run retains 525 Energy after two Mid purchases and 325 after Advanced, including exactly one original 5-Energy world reward.
- **28/28 Python**, formatting, lint, integrity/dependency checks, Rojo build/sourcemap and repository-configured Luau analysis pass. Roblox API definitions are absent from local LSP; this is not a complete API type-check claim. Native compilation/runtime evidence supplements it.
- **Local bounded sanity:** 400 manually dispatched native world pulses take **58.3 ms aggregate**, retain one callback, two-bucket work limit, no paused/multiple-slot habitat and no durable revision change. That run has two active opportunities; the separate scheduler/capacity regressions exercise the eight-slot envelope. No controlled L0/L1, frame/memory or high-concurrency claim follows.
- **Clean shipped boot / final Edit:** server and client BOOTSTRAP_READY; CleanOffline profile load; ordinary projection accepted by the real observer. Seven temporary probe/test roots removed, normal boot scripts restored; **85/85 source parity**, all **58 authored parts**, all five MeshParts including Energy Core, and recorded Lighting properties unchanged.

## Files and closure

Production changes: `WorldDefinitions`, `WorldRegistry`, `SpawnPlan`, `WorldService`, `VariantIdentity`, `WorldRuntimeService`, `WorldProjectionV1` and `WorldProjectionStore`. Tests: `SpawnScheduling`, `CapturePersistence`, `WorldProjection`, manifest. Native probe: `imp10_protected_lifetimes`; existing `imp10_world_rewards` exposes/reuses its scoped shipped-owner harness with optional deterministic RNG/pulse timing. Gate matrix, roadmap/status entry points and this evidence/artifact are updated.

All authored DEV functional IMP-10 gates and local correctness/security/performance checks are satisfied. **AD-260 permits functional COMPLETE and roadmap advancement. VS1-19 / AD-249 and full high-concurrency scale/release evidence remain DEFERRED, not PASS.** Future protected content still requires its own authored binding; event/commerce/Extreme/Compound content, shops/passes/subscriptions/ads, Daily Wheel, PQL-4 and IMP-11 implementation are outside this slice. No locked contract needed amendment.

Exact next dependency: **IMP-11 — TA-10 server-local Party identity/invite/membership authority → revision/consent/session fencing and bounded same-server rejoin/cleanup evidence**, before broader Ping/challenge/visitor/event work. This slice stops at that phase boundary.
