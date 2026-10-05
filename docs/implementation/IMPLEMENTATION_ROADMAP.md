# MonsterVault Implementation Roadmap

> **Status:** IMP-8 COMPLETE with registered deferred validation; IMP-9 COMPLETE; IMP-10 FUNCTIONALLY COMPLETE under AD-260; IMP-11 OPEN with Party, Social Ping, Friendly Challenge and Showcase/Visitor dependencies COMPLETE. Golden Playable Vertical Slice ready to begin on these stable dependencies; **Halloween 2026 is the owner-authorized launch theme**; VS1-19 remains DEFERRED to Scale Readiness
> **Locked by:** TA-17
> **Rule:** Dependency-driven; do not skip phases merely because later UI/content is easier to demo.

## Production-quality rule

Owner-authorized roadmap expansion (2026-10-04): a technically complete feature is not automatically release-ready. Player-facing work must converge on **functional + reliable + understandable + performant + visually coherent + appropriately polished** before release.

For visual/design work, Codex/Work must actively evaluate the connected **Blender MCP** pipeline for custom models, environment kits, landmarks, props, creatures, rigs/animations, VFX-support meshes, 3D UI/presentation assets and promotional scenes when that materially improves quality. Preserve editable `.blend` sources and Roblox-compatible exports. Use the **Roblox Studio MCP** for import/integration, material mapping, placement and final in-game visual validation. Prefer existing assets and Roblox-native UI/particles/primitives when they already meet the required quality; do not use Blender merely because it is available.

Once the relevant world/gameplay dependencies are stable, establish one **golden playable vertical slice** at near-production visual quality and use it as the quality bar for later content rollout. Do not postpone all visual validation until release hardening.

## Halloween 2026 launch-theme rule

Owner-authorized roadmap addition (2026-10-05): MonsterVault's first production release targets the **Halloween 2026 season** as its launch theme. The exact public date remains subject to normal implementation, PQL, scale, platform-policy and release gates.

Source of truth: [Halloween 2026 Launch Theme](HALLOWEEN_2026_LAUNCH_THEME.md).

From this point forward, release-facing work should follow **permanent production-quality MonsterVault base + removable/configurable Halloween seasonal layer**. The Golden Slice should establish both the reusable permanent art/UX/sensory bar and the first Halloween presentation treatment. The permanent game must remain coherent with the seasonal layer disabled.

Halloween presentation may proceed before later IMP-11 event authority exists. Actual timed event occurrence, spawn modifiers, objectives/contribution, rewards, persistent cooldowns and cross-server hints stay with their existing IMP-11/TA-10 owners. Seasonal commerce stays with IMP-13; production activation/config/analytics stays with IMP-14. Do not build one-off presentation code that becomes parallel event, economy or commerce authority.

Current launch priorities are:

1. permanent Golden Slice quality;
2. modular Halloween Starter Region + Home/Vault dressing;
3. Halloween-compatible creature/rarity/reveal and sensory examples;
4. seasonal launch UI/promotional identity;
5. Halloween as the preferred first production event when remaining IMP-11 event dependencies are ready;
6. deterministic seasonal commercial presentation when IMP-13 is ready;
7. live-ops scheduling/rollback/analytics when IMP-14 is ready.

A seasonal deadline never permits bypassing correctness, persistence, safety, accessibility, platform-policy or release gates.

## Golden Slice pre-production package

The first production-quality visual pass now has an implementation-facing baseline in [production/](production/README.md). Work should consume that package before creating production assets:

- [Visual Bible](production/GOLDEN_SLICE_VISUAL_BIBLE.md)
- [Asset Manifest](production/GOLDEN_SLICE_ASSET_MANIFEST.md)
- [Blender -> Roblox Asset Production Standard](production/BLENDER_ROBLOX_ASSET_PRODUCTION_STANDARD.md)
- [UI/UX System](production/GOLDEN_SLICE_UI_UX_SYSTEM.md)
- [Halloween Content Matrix](production/HALLOWEEN_2026_CONTENT_MATRIX.md)
- [Performance Budgets](production/GOLDEN_SLICE_PERFORMANCE_BUDGETS.md)
- [Acceptance Matrix](production/GOLDEN_SLICE_ACCEPTANCE_MATRIX.md)
- [Work Handoff](production/GOLDEN_SLICE_WORK_HANDOFF.md)

These are implementation-production standards subordinate to the approved GDS/TA. They intentionally do not mark PQL gates complete. The Golden Slice must earn those representative acceptance results through actual Studio/client evidence.

## IMP-1 — Contracts and Test Harness

Deliver:

- shared protocol/result/ID contracts;
- tests/runner.luau using Lune;
- deterministic test registration/manifest;
- clock/RNG interfaces and fakes;
- architecture dependency check script.

Gate:

- CI / static-build executes fast tests when runtime Luau appears;
- no gameplay behavior yet.

## IMP-2 — Composition and Diagnostics

Deliver:

- ServerMain/ServerComposition;
- ClientMain/ClientComposition;
- startup validation;
- structured diagnostics;
- shutdown coordinator;
- performance counters.

Gate:

- deterministic bootstrap order;
- duplicate registrations fail;
- no import-time feature startup.

## IMP-3 — Profile Session Foundation

Deliver:

- profile schema v1;
- DataStore repository interface + fake;
- Roblox DataStore adapter;
- lease/load/readiness states;
- migration/validation;
- single writer queue;
- checkpoint/retry/autosave/shutdown logic.

Gate:

- TA-4/15 persistence C0 suites.

## IMP-4 — V1 Networking and Projection

Deliver:

- Command/Event/UnreliableEvent gateways;
- route registry;
- envelope/schema/rate/replay validation;
- Session.ClientHello / RequestResync;
- Command.Result;
- ProjectionStore/Snapshot/Delta.

Gate:

- hostile-client negative tests;
- readiness cannot be client-granted.

## IMP-5 — Minimal Runtime World

Deliver:

- runtime entity lifecycle;
- one deterministic authored fixture creature;
- spatial/interaction registry;
- world scheduler minimal path;
- streaming-safe projection.

Gate:

- no per-entity heartbeat/task pattern;
- stale callbacks cannot resurrect destroyed runtime state.

## IMP-6 — Capture and Durable Ownership

Deliver:

- capture state machine;
- injected server RNG;
- stable Variant identity;
- provisional/custody states;
- secure finalization application use case;
- exact CreatureInstanceId profile record.

Gate:

- exact-once/fault/retry tests;
- no reroll;
- no client authority.

## IMP-7 — Capture Client Experience

Deliver:

- semantic cross-input capture controller;
- Pending/OutcomeUnknown reconciliation;
- minimal accessible capture UI;
- notification/focus integration.

Gate:

- device/input/accessibility C1 evidence.

## IMP-8 — VS-1 Closure

Run TA17_VERTICAL_SLICE_ACCEPTANCE_MATRIX.md.

VS-1 functional acceptance must be complete before broad feature expansion, with the sole registered performance timing exception [AD-249](../technical_architecture/ARCHITECTURE_DECISIONS.md#ad-249--defer-vs1-19-to-the-imp-10-completion-gate).

**Status (2026-10-01): COMPLETE with deferred validation.** All functional gates are closed, including owner-confirmed native gamepad parity and the trusted VS1-20 Studio capture log. **VS1-19 (C1) is DEFERRED — environment limitation**, not PASS. Under AD-260 it is a future **Scale Readiness Gate**, not an IMP-10 functional-completion blocker. See [IMP-8 evidence](IMP8_IMPLEMENTATION_EVIDENCE.md) and [the amended acceptance matrix](../technical_architecture/TA17_VERTICAL_SLICE_ACCEPTANCE_MATRIX.md).

## IMP-9 — Vault / Economy / Progression

**Status (2026-10-01): COMPLETE.** All phase-owned gates in the [full TA-8 / IMP-9 audit](IMP9_GATE_AUDIT.md) pass: capacity, reconciliation/Overflow-Held, assignments, production/offline settlement, Energy/exact-once Claim and the complete bounded DEV Vault/Capture/Access purchase catalog. Upstream IMP-8 is formally complete under AD-249. [IMP-9 evidence](IMP9_IMPLEMENTATION_EVIDENCE.md) records implementation, current native evidence and explicit downstream owner boundaries.

Collection capacity, assignments, production, offline settlement, Energy and progression transactions.

Completed first dependency: Vault-owned capacity status consumed by capture admission and P2 placement; invalid persisted capacity fails protected load, and capacity races preserve exact Overflow-Held ownership. Existing DEV fixture balance is retained.

Completed next dependency (AD-250): separately identifiable server-authorized capacity components; explicit versioned legacy/sequence migration before Ready; deterministic ownership-preserving P2 reconciliation; native owner-selected exact-instance Resolve Overflow with bounded projection and uncertain-write recovery. Commercial/temporary readers remain unbound in DEV and cannot grant capacity from persisted client-like claims; their real integrations belong to their owning later systems.

Completed current dependency (AD-251): server-owned Display/Production assignments, strict revision/ownership/role/slot validation, integer buffer and historical epochs, monotonic online settlement, bounded clean-offline/crash recovery and coherent save/leave/rejoin/uncertain-write recovery. Capacity loss settles before clearing roles; grants remain protected while unbound. Native UI/gateway/DEV DataStore/fresh Play server and negative/race evidence is linked from IMP-9 evidence.

Completed current dependency (AD-252): versioned server-owned integer Energy wallet, one bound reason-coded transaction primitive and exact-once Production Claim through the existing P2 writer. Settlement, whole-unit wallet transfer, buffer remainder and revision-bound claim receipt commit together. Duplicate/retry/reconnect, both uncertain-write cut points, client Class A resync, Busy/races, numeric ceilings, unbound grants and fresh-server save/rejoin are validated. Capacity, assignments, exact ownership and Overflow-Held semantics are preserved.

Completed current dependency (AD-253): one server quote per session with opaque GUID, 60-second monotonic expiry, price/config epoch, original profile revision, current tier and legitimate Species Discovery prerequisite. Explicit confirm purchases the existing +6 Collection Capacity tier for 25 DEV Energy. Debit, earned tier, permanent unlock receipt and operation marker commit together through P2. Stale/tampered/cross-session quotes, insufficient funds and invalid effects fail without mutation. Duplicate/retry/reconnect/unknown-result recovery survives quote expiry and audit eviction. Native quote/confirm GUI, real DEV before/after-write failures, claim/purchase races and a fresh shipped composition pass; exact ownership, Held state, roles, output and discovery are preserved.

Completed final dependency (AD-254): twelve immutable DEV definitions cover +6 capacity tiers, earned production/display slots, buffer and 4h/8h/12h offline upgrades, bounded persistent Capture Capability and GDS-9 Mid A/Mid B/Advanced access prerequisites. Every purchase reuses the existing server quote/P2 debit/effect/receipt chain. Production-affecting upgrades settle old capabilities first at a fixed boundary and reject clock regression. Access consumes an injected authoritative mastery owner; the shipped composition fails closed while that IMP-10 owner is unbound. Completed access survives save/rejoin and price/owner changes without creating discovery or world-completion proof.

The full gate matrix closes with 153 fast tests, 40 native Studio C0 checks, real DEV GUI/unknown-write/race purchases and a fresh shipped composition restoring all twelve receipts and unchanged ownership/Held state. Actual world mastery/gated actions, one-time/event/commercial/temporary reward integrations, deferred-grant transfer/replay and live config remain with their explicitly routed owners; unbound valuable state remains protected. These are enablement boundaries, not deferred phase-owned validation gates. No world geometry/content or later system was implemented. AD-249 / VS1-19 remains DEFERRED and is governed by superseding AD-260 as a future Scale Readiness Gate.

## IMP-10 — World Scaling

**Status: FUNCTIONALLY COMPLETE / COMPLETE for roadmap advancement under AD-260 (2026-10-05).** First dependency COMPLETE under AD-255: immutable server world/content registries, validated authored action index, actual active mastery evidence/P2 owner and TA-8 Mid A/Mid B/Advanced access binding. Existing clearing/IDs remain the DEV Starter binding; no new biome geometry or topology is inferred. Survey, bounded traversal and qualifying Secured provenance produce real history; client fields, bought access and passive value cannot create mastery. Actual capture/world actions fail closed; unknown writes recover via Class A world resync and the existing single writer.

[Evidence](IMP10_IMPLEMENTATION_EVIDENCE.md) includes 161 fast tests, 8 native C0 suites, 7 native authoring checks, real DEV cut points, native client tampering/readback and fresh Play save/rejoin. [Full phase gate matrix](IMP10_GATE_MATRIX.md) now closes all authored DEV functional gates; its current evidence supersedes these historical dependency counts. World/event/commercial/deferred rewards remain protected while unbound.

Second dependency COMPLETE under AD-256: [canonical authored DEV content and safe utilities](IMP10_AUTHORED_CONTENT_EVIDENCE.md). Five fixed roles, eight habitats/context anchors, distinct Mid pools/routes, complete active field recipes and safe outpost/utility bindings now validate before Ready. Capture uses exact validated Secure Points and actual target access; the Home Vault terminal delegates owner readback. Approved mastery epochs preserve Starter history and protect previously unbound Mid/Advanced value. All four mastery paths, three purchases, unknown-result recovery and fresh Play/rejoin passed in scoped native Studio probes; 163 fast tests, 9 native C0 suites and 19 authoring cases pass.

Third dependency COMPLETE under AD-257: [region-scoped spawn scheduling](IMP10_SPAWN_SCHEDULING_EVIDENCE.md). Shipped composition derives eight bounded habitat buckets from the authored index, with one central staggered scheduler, current Ready/presence/access activation, server weighted pools and stable reservation identity. Pending/custody count toward caps; retries and invalid placements are bounded; stale callbacks cannot resurrect entities. The proven Starter opportunity/history remains replenishable. Native regional capture/mastery/unlocks, true engine streaming out/in, eight-slot caps, pre-/post-write capture recovery and fresh Play/rejoin pass; 171 fast tests and eight native scheduler suites pass. Energy Core appearance/source geometry is unchanged.

Fourth dependency COMPLETE under AD-258: [ordinary World Cycle and prospective context binding](IMP10_WORLD_CYCLE_EVIDENCE.md). One absolute fixed-epoch/versioned server clock uses the existing scheduler; immutable habitat/context bindings keep all current DEV content phase-independent. New reservations pin current cycle context once; pending/live/captured/Secured identities, history and existing transactional state survive transitions unchanged. Exact boundaries, stale/yielded/duplicate fences, invalid-clock admission stop, actual regional captures/mastery/access, engine streaming during a transition and fresh Play/rejoin pass; 179 fast tests and eight native cycle C0 suites pass. Studio is Edit with 84-source parity and unchanged Energy Core/Lighting.

Fifth dependency COMPLETE under AD-259: [travel/discovery/safe arrival/recovery](IMP10_TRAVEL_RECOVERY_EVIDENCE.md). Existing authored hub ↔ field nodes require real discovery/access, Ready character presence and no acquisition. One bounded coordinator shares the world pulse; safe native arrival and generation-fenced recovery preserve history and never extract provisional custody. Existing P2/checkpoint recovery persists five bounded discovery facts without inferred grants. Native routes/masteries, corrupt/missing bindings, actual client duplicate/race/tampering, engine streaming, R6/R15 arrival, write cut points, fresh Play/respawn and three exact purchase retries pass; 187 fast tests and ten native C0 cases pass. Studio ends Edit with 85-source parity and preserved Energy Core/Lighting.

AD-259 follow-up COMPLETE (2026-10-04): [trusted-session presence and locked recovery](IMP10_SESSION_PRESENCE_EVIDENCE.md). The existing bounded presence record now fences readiness, travel and observation by its private ProfileSession and clears the old recovery region on replacement. Four new regressions and actual scoped native session replacement, missing-anchor/locked correction, provisional interruption and admitted P2 preservation pass; 191 fast tests, 14 native C0 cases and final Edit 85-source parity. Existing content, Energy Core and Lighting are preserved.

Sixth dependency COMPLETE (2026-10-05): [one authored DEV hazard and transport fairness](IMP10_HAZARD_TRANSPORT_EVIDENCE.md). A marked, phase-independent Starter corrosive volume reuses the world registry/index, shared pulse and private WorldTravelService presence record. Real server occupancy/segment observation latches exposure until existing TA-7 interruption and validated safe recovery; missing/corrupt anchors keep presence inactive. Provisional recovery never extracts, admitted P2 and Secured value/context survive, and recovery cannot manufacture field-node discovery. Baseline safe routes pass 315 native samples; native acquisition, travel races, death/respawn/rejoin, actual engine streaming/client tampering and prior locked-presence regressions pass. Current gates: 198 fast tests, 29 native C0 cases, 29 authoring cases, 28 Python tests and final Edit 85-source parity; Energy Core/Lighting preserved. Native primitives suffice for this DEV hazard; general world-art/PQL work remains separate.

Seventh dependency COMPLETE (2026-10-05): [one authorized bounded DEV world reward and objective dedupe](IMP10_WORLD_REWARD_EVIDENCE.md). The existing Starter Survey return route binds immutable source `world-reward/starter-return-dev-v1` and fixed 5 Energy. Completion, objective/history and the TA-8 wallet/receipt share the existing ProfileSession P2 operation; the client selects no reward fields. One permanent receipt dedupes after audit eviction and rejoin and preserves at most 5 unspendable Energy when the wallet is full. Existing world/progression reconciliation transfers only that remainder with its original grant reference. Both write cuts, concurrent/duplicate attempts, protected loads, stale presence/session/character, native client replay/tampering, true engine streaming, hazard/custody and real DEV rejoin pass. Current gates: 205 fast tests, 40 native C0 cases, 29 authoring cases, 28 Python tests and final Edit 85-source parity; 58 authored parts, Energy Core and Lighting preserved. Pre-binding completed objectives receive no backfill; other reward integrations remain protected.

Eighth dependency COMPLETE (2026-10-05): [protected DEV lifetime and capture fairness](IMP10_PROTECTED_LIFETIME_EVIDENCE.md). One optional Legendary member of the existing Starter-field pool binds a 300-second actionable stability window; no extra spawn slot or mastery requirement. Existing WorldService/TA-7 owners retain distinct claim/attempt/custody/grace/pending states, pinned identity/cycle context and original release boundary. Expired idle reclaims and stale/yielded despawn observations fail closed. Both real P2 write cuts, exact-once auto-lock/history, native client/streaming, recovery, shutdown and rejoin pass. Current gates: **213 fast, 52 native C0, 29 authoring, 28 Python, 85-source parity**, 315 safe-route samples and a bounded 400-pulse local diagnostic; authored world, Energy Core and Lighting preserved.

**IMP-10 is FUNCTIONALLY COMPLETE under AD-260.** No phase-owned functional gate remains. VS1-19 and full high-concurrency scale/release evidence stay DEFERRED, not PASS. Exact next dependency: **IMP-11 — TA-10 server-local Party identity/invite/membership -> revision/consent/session fencing -> bounded same-server rejoin/cleanup evidence**. No IMP-11 code, commerce or general sensory/PQL work is included.

Full biome/content registries, spawn scheduling, travel, mastery/hazards and TA-14 scaling.

Scale-readiness gate inherited from IMP-8 / AD-249 and rescheduled by AD-260:

- **VS1-19 (C1): DEFERRED — environment limitation** until full TA-14/TA-15 controlled L0/L1 plus supported real-client frame/memory validation can be executed.
- Historical L1 is **30 players at MaxPlayers=60**. This remains the evidence target if that server density is pursued; MaxPlayers may be launched lower and increased only within validated operating evidence.
- VS1-19 is **not required for IMP-10 functional completion or IMP-11 to begin**. It becomes mandatory before intentionally operating beyond the validated concurrency envelope or claiming corresponding production scale readiness.
- Local bounded performance/security checks, streaming tests and practical small-client validation remain required during normal development. Production release remains subject to the applicable TA-14/TA-15/release gates.

## IMP-11 — Social and Events

**Status (2026-10-05): OPEN. First four dependencies COMPLETE: TA-10 Party, §7 Social Ping, §10 Friendly Challenge and §12 representative read-only Showcase/Visitor.** [Party evidence](IMP11_PARTY_EVIDENCE.md), [Ping evidence](IMP11_SOCIAL_PING_EVIDENCE.md), [Friendly Challenge evidence](IMP11_FRIENDLY_CHALLENGE_EVIDENCE.md), [Showcase/Visitor evidence](IMP11_SHOWCASE_VISITOR_EVIDENCE.md) and [phase gate matrix](IMP11_GATE_MATRIX.md) distinguish passing slices from remaining phase/release obligations.

One P0 owner implements four seats, one Party per player, explicit creation/invite/accept/decline/leave/removal/disband, join-sequence succession and a 30-second same-server seat reservation. Membership and the participant index change together in the existing non-yielding admission pattern. Invites bind exact live Player/ProfileSession identities and one Party revision; revisions invalidate old consent. Returning sessions require explicit rejoin at the current revision and cannot seize leadership. A single deadline timer owns all invite/grace expiry; native callback tickets and shutdown cleanup fence stale work. Default invitation audience is None with explicit session-only SameServer opt-in. No personal value, capture/access authority or commercial status is granted.

AD-265 registers the missing Class B creation/removal/disband/rejoin/preference intents, required Party revision preconditions and Class A Party readback on the existing three remotes. The existing bounded replay window now binds non-Class-A entries to private ProfileSession identity. A collapsed native diagnostic panel exposes authoritative state without incoming-invite focus changes; PQL-3/PQL-8 own final presentation.

Validation: **236/236 fast** (23 new Party C0 cases), **29/29 focused native checks**, **28/28 Python**, static/build/dependency/integrity and configured Luau analysis, **91/91 final Edit source parity**. Real native wire/Player/ProfileSession/respawn/CreatorKick/shutdown and one actual deadline timer are proven. The timer peer is an adapter fixture; two real clients and physical same-live-server reconnect are not claimed. All 64 current authored/asset parts and Lighting are preserved. Existing IMP-10 evidence is retained, not rewritten or counted as rerun.

Second dependency COMPLETE (2026-10-05): [bounded Party ComeHere pings](IMP11_SOCIAL_PING_EVIDENCE.md). AD-266 binds the reserved Social.Ping route to current Party/revision and a server-observed accessible walkable sender position. Only active current identities receive the recipient-specific snapshot; reserved seats, replaced sessions, departed members and old Party revisions retain no ping authority. One slot per sender, two live pings per Party, a six-second lifetime and the existing gateway's one-request-per-three-seconds route bucket bound work. Party membership mutations revoke live pings. Existing Party deadline ownership and one client expiry timer avoid polling/per-ping tasks. The existing ProfileSession P1 settings owner buffers Social Ping suppression; only explicit false enables it, and mute changes no gameplay/Party authority. Minimal native disclosure/control stays diagnostic.

Current validation: **26/26 focused Ping, 262/262 full fast, 28/28 focused Ping native, 28/28 Python, 91/91 final Edit source parity** and normal static/build/dependency/integrity/configured analysis. Native evidence covers actual remotes/UI/expiry/rate/replay, current authored geometry, private ProfileSession replacement and real scoped DEV P1 release/acquire. All 64 current parts and Lighting are preserved; Studio ends in Edit. One real client is proven; full multiplayer/reconnect/platform safety and deferred scale/release evidence remain open. Completed Party/IMP-10 evidence is preserved as historical evidence.

Third dependency COMPLETE (2026-10-05): [Home Return (DEV) Friendly Challenge](IMP11_FRIENDLY_CHALLENGE_EVIDENCE.md). AD-267 binds one visible authored definition/version, bilateral explicit consent, current Challenge revision and cancellation to existing Class B/session/replay infrastructure. No Party is required. Both players need ordinary discovered Starter-to-Home return capability; passive server-confirmed travel completion freezes a temporary winner/time result. No gameplay eligibility, personal value, reward or paid priority changes. Reset/death/recovery/other travel/disconnect/replacement cancels without rejoin inheritance. One participant guard, 30 records and 20/30/6-second offer/active/terminal deadlines reuse the existing social timer. Compact full readback preserves consent/result/invitations inside the existing wire budget; only optional P0 ping presentation drops under overlapping backpressure.

Current validation: **32/32 focused Challenge, 294/294 full fast, 34/34 distinct focused Challenge native, 28/28 Python, 92/92 final Edit source parity**, normal static/build/dependency/integrity/configured analysis. Native evidence covers one actual client plus an explicit adapter peer, real ordinary Home Return/result, no profile/value mutation, actual reset and private ProfileSession replacement/replay, shared deadline expiry/rearm/client disposal and all-zero stop. The 64 current parts and eight Lighting properties are preserved; Studio ends in Edit. Completed Party/Ping/IMP-10 evidence is retained; broader two-real-client/platform/reconnect and scale/release obligations remain open.

Fourth dependency COMPLETE (2026-10-05): [Showcase/Visitor](IMP11_SHOWCASE_VISITOR_EVIDENCE.md). AD-268 binds default Closed/eligible Party/current-server policy plus explicit targeted grant and visitor open, owner revoke and close. Two 60-second grants per owner and one active view per visitor bind exact live Player/Ready ProfileSession identities. Only one existing eligible Display Assignment card's exact instance/Species/intrinsic rarity/Mutation/Trait/slot and current owner identity are disclosed; private owner state, provenance and commerce remain hidden. No writer/gameplay/value capability exists. One filtered cache per owner, profile lifecycle notifications and the existing social/client deadline owners provide event-driven refresh, immediate revoke and replacement/expiry/disconnect/shutdown cleanup.

Current validation: **32/32 focused Showcase, 326/326 full fast, 29/29 distinct Showcase native, 28/28 Python, 97/97 final Edit source parity**, normal static/build/dependency/integrity/configured analysis. One actual native Player/client plus three explicit adapter peers prove remotes/store/UI, ownership rejection, real profile/session notifications, timer expiry and settled native disconnect/all-zero stop. The 64 current parts and eight Lighting properties are preserved. Completed Party/Ping/Challenge/IMP-10 evidence is unchanged; broader real multiplayer/platform/reconnect and scale/release obligations remain open.

**Golden Playable Vertical Slice / first production-quality visual pass is ready to begin** on the stable world/capture/Collection/Vault/display and four social dependencies, under the existing incremental PQL rule and owner's 2026-10-05 scope. Remaining later IMP-11 co-op/events do not block that representative visual pass. PQL-1/2/3/4/8 and release completion are not claimed; no polished visual system is implemented by this slice.

Exact next remaining IMP-11 functional dependency: **TA-10 §8 Shared Objective contribution -> server-observed per-player eligibility -> §9 owning-profile exact-once P2 Collaboration Rewards**. Subsequent event work retains its own gates. IMP-11 remains OPEN; commerce/trading retain their later owners.

Party/Ping/challenge/visitor plus global event occurrence/contribution/rewards and cross-server hints.

## IMP-12 — Trading

Trade session/revision/reservations, durable journal, transaction-fenced participant apply/recovery.

## IMP-13 — Commerce

Implement the **GDS-13 Commercial Strategy v3** in dependency order. For the Halloween 2026 launch window, use the [launch-theme brief](HALLOWEEN_2026_LAUNCH_THEME.md) as the first seasonal commercial presentation target once the underlying commerce owners are ready; seasonal products remain deterministic, optional and non-pay-to-win.

Core commerce:
- deterministic cosmetic shop;
- bounded Collection/Display Capacity;
- one-time Starter Value Bundle;
- durable Supporter/Style Pass;
- seasonal cosmetic bundles;
- permanent bounded Offline Window Extension;
- capped 2× Return Overcharge with one immutable server-authored eligible return and exact-once receipt reconciliation.

Second-wave commerce after core purchase/reconciliation UX is stable:
- Vault Club subscription with deterministic recurring cosmetic/status value and bounded presentation convenience;
- Seasonal Collection Pass with free + premium deterministic reward tracks;
- Rewarded Video Ads at natural safe breaks with guaranteed non-random rewards and current platform eligibility checks;
- MonsterVault avatar/UGC items through supported Marketplace/in-experience commerce;
- Roblox Plus integration in a non-intrusive commercial context.

Commercial operations:
- Managed/Regional Pricing where supported, using runtime platform prices rather than hard-coded custom UI prices;
- Price Optimization only after sufficient real transaction volume/data quality exists.

Reuse TA-8 production/Energy and TA-11 commerce/receipt/entitlement owners. No baseline paid luck, capture power, persistent production-rate multiplier, 3× return boost, event reward multiplier, mainline access bypass, paid extra Daily Wheel spins or paid streak restoration.

## IMP-14 — Live Ops / Analytics / Experimentation

Halloween 2026 is the first launch-season configuration target: production seasonal presentation/event state should be activatable, reversible and observable through the proper TA-13/IMP-14 owners rather than hard-coded one-off runtime branches.

Telemetry registry/adapters, C2 config snapshots, flags, experiment assignment/exposure and privileged audit boundary. Bind the GDS-16 retention loops where their owning systems are ready: Return Brief, Next Aspirations, optional Daily Expeditions / Weekly Objectives, Seasonal Collection Pass progression, one activity-earned free Daily Activity Wheel, rotating genuine opportunities and the metrics/guardrails needed to tune them without login-streak pressure.

Measure retention and monetization together: pass activation/completion, shop funnel, subscription retention, rewarded-ad usage, UGC/store attachment, Return Overcharge conversion, payer/non-payer progression fairness, refund/regret/support signals and sensory/game-feel interaction where useful. Analytics remains observational and cannot grant value.

## Pre-release Production Quality Track

The following ten gates broaden the existing implementation roadmap without changing gameplay authority or bypassing upstream IMP dependencies. They may be delivered incrementally once their underlying systems are stable, but **all applicable PQL-1..PQL-10 gates must be complete before IMP-15 can close and production release can proceed**.

### PQL-1 — World Art & Map Polish

Turn functional regions into authored, attractive spaces with distinct biome identity, terrain composition, paths, landmarks, foliage/props, structures, environmental storytelling, lighting, atmosphere, readable traversal and strong points of interest. Important regions should be recognizable from screenshots alone. Use Blender MCP for modular environment kits, architecture, hero landmarks and props where custom modelling adds value; validate final appearance in Studio.

For the launch Golden Slice, the Starter Region and Home/Vault must establish a production-quality **permanent base plus modular Halloween 2026 dressing**. Seasonal props, atmosphere, lighting accents and environmental motion should improve composition without hiding unfinished permanent geometry, and must be removable without breaking traversal or gameplay.

Gate: the representative/golden region reads as an intentional production environment with the HUD hidden, remains production-quality with Halloween disabled, and the established quality bar is reproducible across later regions.

### PQL-2 — Creature & Asset Quality

Bring creatures, collectibles and gameplay props to a consistent visual standard: silhouettes, rarity readability, materials, animation-ready topology where needed, idle presentation, Vault/display presentation and performant geometry/LOD strategy where applicable. Use Blender MCP for creature/hero models, riggable meshes, machines and display assets.

The Golden Slice should include at least one Halloween-compatible hero creature, cosmetic creature treatment or Legendary reveal asset that exercises the same permanent creature/rarity pipeline rather than creating a seasonal parallel identity system.

Gate: no important gameplay object remains an engineering placeholder, common/rare/exceptional content is visually distinguishable without relying only on text, and seasonal treatment stays visually distinct from intrinsic rarity.

### PQL-3 — UI/UX & Presentation Polish

Polish HUD, navigation, Vault, collection, discovery, progression/mastery, travel, notifications, objectives, rewards, commerce surfaces, settings, mobile layouts, controller navigation and accessibility states. Establish consistent typography, spacing, hierarchy, iconography, panel language, rarity treatment, interaction/loading/error/empty states and restrained motion. Keep actual interface behavior Roblox-native; use Blender MCP only for visual assets or 3D presentation where it clearly improves the result.

Halloween launch accents may affect decorative framing, banners, icons, ambient motifs and presentation surfaces, but the permanent information hierarchy, accessibility and navigation must remain correct with the theme disabled.

Gate: every primary gameplay loop is understandable and fully usable without developer/debug knowledge across supported inputs in both seasonal and off-season presentation.

### PQL-4 — Animation, VFX, SFX & Sensory Game Feel

Implement the GDS-14 **Sensory / Game-Feel Strategy v1** across the golden slice and then production rollout:

- complete capture feedback arc;
- layered rare/exceptional reveal;
- Vault machinery ASMR/ambient mechanical character;
- hero Energy Claim transfer/count-up moment;
- progression unlock payoff;
- collection lock-in/completion feedback;
- tactile UI response;
- material-specific interaction audio;
- layered rarity audio language;
- distinct biome ambient soundscapes;
- creature personality/idle audio;
- beams/trails for high-value motion;
- optional bounded haptics;
- environmental micro-animation;
- satisfying but non-deceptive Daily Wheel animation;
- Photo/Showcase Mode;
- satisfying idle Vault motion/audio.

Use Roblox-native particles/beams/trails/audio/haptics where sufficient; use Blender MCP for rigs, animated props, creatures, mechanical assets, custom effect geometry and showcase assets when custom work materially improves quality. All sensory systems obey Reduced Motion/audio/haptic controls and bounded performance budgets.

For the Halloween launch slice, extend the permanent sensory language with restrained spooky ambience, seasonal environmental motion, reveal layers and stingers where appropriate. Seasonal effects must not fabricate rarity or authoritative event state and must remain removable.

Gate: capture, reward, progression, collection and Vault interactions feel intentionally satisfying and recognizable, including the representative Halloween launch treatment, while state remains legible with motion/audio/haptics reduced or disabled.

### PQL-5 — Onboarding & First-Session Experience

Polish the gameplay-first path from spawn to first goal, exploration, encounter, capture, reward, Vault interaction, progression and next objective. Prefer contextual teaching over tutorial walls; include recovery from mistakes and clear cross-input guidance.

Gate: a new player with no outside explanation can understand what MonsterVault is, what to do next, how capture works, why creatures matter and what progression to pursue.

### PQL-6 — Retention & Progression Presentation

Make existing progression motivating and legible through mastery/discovery presentation, region and collection completion, rarity, upgrades, quests/objectives, milestones, achievements, unlock previews and meaningful reward moments. Implement the approved Retention Strategy v2 presentation: concise Return Brief, Next Aspirations, optional Daily Expeditions and Weekly Objectives, plus the activity-earned free Daily Activity Wheel, with no login streak, attendance-only reward, paid extra spins or missed-day punishment. Do not invent grind solely to increase session time.

Gate: players can identify what they just achieved, what is worth doing now and what longer-term aspiration should bring them back.

### PQL-7 — Live Events & Seasonal Content

Exercise the live-ops architecture through polished player-facing events: seasonal creatures/content, temporary world states or spawn changes, event objectives/community goals, limited rewards, countdown/status UI and update messaging. Reuse existing systems instead of creating event-only parallel frameworks. Use Blender MCP for event-specific props, decorations, landmarks, creatures and reward models when useful.

**Halloween 2026 is the preferred first representative production event** if the launch window remains applicable when the remaining IMP-11/IMP-14 owners are ready. Visual Halloween dressing may exist earlier, but authoritative occurrence/spawn/reward semantics must use the proper event/live-ops path.

Gate: the Halloween representative event, or a later equivalent if the calendar window is no longer applicable, can run through the production live-ops/config path with correct start/end/recovery behavior and leaves the permanent world coherent after deactivation.

### PQL-8 — Social Presentation & Multiplayer Polish

Ensure other players improve the experience through readable player presence, cooperative moments, ping/party/challenge/visitor presentation, creature showcasing/inspection and trading presentation when the underlying systems exist. Avoid adding social mechanics that do not support MonsterVault's actual loop.

Gate: multiplayer feels intentionally social rather than like isolated single-player sessions sharing one server.

### PQL-9 — Commerce Presentation

Integrate **Commercial Strategy v3** into MonsterVault's visual language: cosmetic shop, Starter Value Bundle, Supporter/Style Pass, bounded Collection/Display Capacity, Offline Window Extension, capped 2× Return Overcharge, seasonal cosmetic bundles, Vault Club subscription, Seasonal Collection Pass, Rewarded Video placements, MonsterVault avatar/UGC commerce and Roblox Plus surfaces where eligible.

For the Halloween 2026 launch presentation, prioritize coherent deterministic seasonal cosmetics such as Vault themes, creature presentation cosmetics, profile frames/nameplates, capture/reveal cosmetic treatment and eligible avatar/UGC items. Intrinsic rarity and gameplay authority remain visually and mechanically distinct from purchased seasonal treatment.

Prices shown in custom UI must reflect the current platform price/Managed Pricing. Subscription renewal/value, rewarded-ad reward, pass-track value and UGC ownership are explicit. Avoid intrusive spam, deceptive scarcity, confusing currencies, paid streak repair, paid random Daily Wheel spins and pay-to-win shortcuts. Blender MCP may produce high-quality 3D product/UGC/reward previews where appropriate.

Gate: the full applicable commerce portfolio is coherent with the game, receipt/entitlement/subscription/ad behavior is reliable, current platform eligibility/policy is respected, and presentation does not degrade the core experience.

### PQL-10 — Launch & Promotional Polish

Finish loading/title/menu/startup transitions, reconnect/recovery messaging, update/event banners and final visual consistency. For the targeted first release, the launch identity should deliberately communicate the Halloween 2026 theme while still showing the real permanent MonsterVault visual language underneath. Prepare production-quality Roblox icon, thumbnails, screenshots, key art, store copy, update artwork and trailer/promotional scenes where applicable. Promotional imagery must represent the actual game honestly. Blender MCP may be used to stage/render hero assets and poses; Roblox Studio remains the final authority for in-game appearance.

Gate: no obvious placeholder/debug presentation remains, core screenshots represent actual polished gameplay, and map/creatures/UI/VFX/animation/audio/progression/social/commerce/event presentation pass a final consistency audit.

## IMP-15 — Release Hardening

Begins only after the underlying implementation dependencies and applicable PQL-1..PQL-10 production-quality gates are satisfied. Release hardening is for verification and launch readiness, **not** for creating major missing art/UI/game-feel systems.

Full TA-15 V0-V10 evidence, TA-14 L0-L5, security/fault sweeps, staging promotion, current policy/API revalidation and release checklist.

## Change rule

A phase may be split into smaller PRs. It may not bypass upstream gates or move authority to a more convenient layer.

AD-249 registered the original VS1-19 deferral; AD-260 supersedes its IMP-10 deadline and reclassifies it as a Scale Readiness Gate. Neither decision grants permission to silently defer unrelated functional correctness, security or release gates.
