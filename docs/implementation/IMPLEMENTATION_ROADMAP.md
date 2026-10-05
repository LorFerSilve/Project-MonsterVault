# MonsterVault Implementation Roadmap

> **Status:** IMP-8 COMPLETE with registered deferred validation; IMP-9 COMPLETE; IMP-10 OPEN for its next DEV dependency
> **Locked by:** TA-17
> **Rule:** Dependency-driven; do not skip phases merely because later UI/content is easier to demo.

## Production-quality rule

Owner-authorized roadmap expansion (2026-10-04): a technically complete feature is not automatically release-ready. Player-facing work must converge on **functional + reliable + understandable + performant + visually coherent + appropriately polished** before release.

For visual/design work, Codex/Work must actively evaluate the connected **Blender MCP** pipeline for custom models, environment kits, landmarks, props, creatures, rigs/animations, VFX-support meshes, 3D UI/presentation assets and promotional scenes when that materially improves quality. Preserve editable `.blend` sources and Roblox-compatible exports. Use the **Roblox Studio MCP** for import/integration, material mapping, placement and final in-game visual validation. Prefer existing assets and Roblox-native UI/particles/primitives when they already meet the required quality; do not use Blender merely because it is available.

Once the relevant world/gameplay dependencies are stable, establish one **golden playable vertical slice** at near-production visual quality and use it as the quality bar for later content rollout. Do not postpone all visual validation until release hardening.

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

**Status (2026-10-01): COMPLETE with deferred validation.** All functional gates are closed, including owner-confirmed native gamepad parity and the trusted VS1-20 Studio capture log. **VS1-19 (C1) is DEFERRED — environment limitation**, not PASS. Its complete L0/L1 and supported real-client performance validation is mandatory **before IMP-10 COMPLETE**. See [IMP-8 evidence](IMP8_IMPLEMENTATION_EVIDENCE.md) and [the amended acceptance matrix](../technical_architecture/TA17_VERTICAL_SLICE_ACCEPTANCE_MATRIX.md).

## IMP-9 — Vault / Economy / Progression

**Status (2026-10-01): COMPLETE.** All phase-owned gates in the [full TA-8 / IMP-9 audit](IMP9_GATE_AUDIT.md) pass: capacity, reconciliation/Overflow-Held, assignments, production/offline settlement, Energy/exact-once Claim and the complete bounded DEV Vault/Capture/Access purchase catalog. Upstream IMP-8 is formally complete under AD-249. [IMP-9 evidence](IMP9_IMPLEMENTATION_EVIDENCE.md) records implementation, current native evidence and explicit downstream owner boundaries.

Collection capacity, assignments, production, offline settlement, Energy and progression transactions.

Completed first dependency: Vault-owned capacity status consumed by capture admission and P2 placement; invalid persisted capacity fails protected load, and capacity races preserve exact Overflow-Held ownership. Existing DEV fixture balance is retained.

Completed next dependency (AD-250): separately identifiable server-authorized capacity components; explicit versioned legacy/sequence migration before Ready; deterministic ownership-preserving P2 reconciliation; native owner-selected exact-instance Resolve Overflow with bounded projection and uncertain-write recovery. Commercial/temporary readers remain unbound in DEV and cannot grant capacity from persisted client-like claims; their real integrations belong to their owning later systems.

Completed current dependency (AD-251): server-owned Display/Production assignments, strict revision/ownership/role/slot validation, integer buffer and historical epochs, monotonic online settlement, bounded clean-offline/crash recovery and coherent save/leave/rejoin/uncertain-write recovery. Capacity loss settles before clearing roles; grants remain protected while unbound. Native UI/gateway/DEV DataStore/fresh Play server and negative/race evidence is linked from IMP-9 evidence.

Completed current dependency (AD-252): versioned server-owned integer Energy wallet, one bound reason-coded transaction primitive and exact-once Production Claim through the existing P2 writer. Settlement, whole-unit wallet transfer, buffer remainder and revision-bound claim receipt commit together. Duplicate/retry/reconnect, both uncertain-write cut points, client Class A resync, Busy/races, numeric ceilings, unbound grants and fresh-server save/rejoin are validated. Capacity, assignments, exact ownership and Overflow-Held semantics are preserved.

Completed current dependency (AD-253): one server quote per session with opaque GUID, 60-second monotonic expiry, price/config epoch, original profile revision, current tier and legitimate Species Discovery prerequisite. Explicit confirm purchases the existing +6 Collection Capacity tier for 25 DEV Energy. Debit, earned tier, permanent unlock receipt and operation marker commit together through P2. Stale/tampered/cross-session quotes, insufficient funds and invalid effects fail without mutation. Duplicate/retry/reconnect/unknown-result recovery survives quote expiry and audit eviction. Native quote/confirm GUI, real DEV before/after-write failures, claim/purchase races and a fresh shipped composition pass; exact ownership, Held state, roles, output and discovery are preserved.

Completed final dependency (AD-254): twelve immutable DEV definitions cover +6 capacity tiers, earned production/display slots, buffer and 4h/8h/12h offline upgrades, bounded persistent Capture Capability and GDS-9 Mid A/Mid B/Advanced access prerequisites. Every purchase reuses the existing server quote/P2 debit/effect/receipt chain. Production-affecting upgrades settle old capabilities first at a fixed boundary and reject clock regression. Access consumes an injected authoritative mastery owner; the shipped composition fails closed while that IMP-10 owner is unbound. Completed access survives save/rejoin and price/owner changes without creating discovery or world-completion proof.

The full gate matrix closes with 153 fast tests, 40 native Studio C0 checks, real DEV GUI/unknown-write/race purchases and a fresh shipped composition restoring all twelve receipts and unchanged ownership/Held state. Actual world mastery/gated actions, one-time/event/commercial/temporary reward integrations, deferred-grant transfer/replay and live config remain with their explicitly routed owners; unbound valuable state remains protected. These are enablement boundaries, not deferred phase-owned validation gates. No world geometry/content or later system was implemented. AD-249 / VS1-19 remains mandatory before IMP-10 COMPLETE.

## IMP-10 — World Scaling

**Status: OPEN.** First dependency COMPLETE under AD-255: immutable server world/content registries, validated authored action index, actual active mastery evidence/P2 owner and TA-8 Mid A/Mid B/Advanced access binding. Existing clearing/IDs remain the DEV Starter binding; no new biome geometry or topology is inferred. Survey, bounded traversal and qualifying Secured provenance produce real history; client fields, bought access and passive value cannot create mastery. Actual capture/world actions fail closed; unknown writes recover via Class A world resync and the existing single writer.

[Evidence](IMP10_IMPLEMENTATION_EVIDENCE.md) includes 161 fast tests, 8 native C0 suites, 7 native authoring checks, real DEV cut points, native client tampering/readback and fresh Play save/rejoin. [Full phase gate matrix](IMP10_GATE_MATRIX.md) remains OPEN for unimplemented phase-owned work. World/event/commercial/deferred rewards remain protected while unbound.

Second dependency COMPLETE under AD-256: [canonical authored DEV content and safe utilities](IMP10_AUTHORED_CONTENT_EVIDENCE.md). Five fixed roles, eight habitats/context anchors, distinct Mid pools/routes, complete active field recipes and safe outpost/utility bindings now validate before Ready. Capture uses exact validated Secure Points and actual target access; the Home Vault terminal delegates owner readback. Approved mastery epochs preserve Starter history and protect previously unbound Mid/Advanced value. All four mastery paths, three purchases, unknown-result recovery and fresh Play/rejoin passed in scoped native Studio probes; 163 fast tests, 9 native C0 suites and 19 authoring cases pass.

Third dependency COMPLETE under AD-257: [region-scoped spawn scheduling](IMP10_SPAWN_SCHEDULING_EVIDENCE.md). Shipped composition derives eight bounded habitat buckets from the authored index, with one central staggered scheduler, current Ready/presence/access activation, server weighted pools and stable reservation identity. Pending/custody count toward caps; retries and invalid placements are bounded; stale callbacks cannot resurrect entities. The proven Starter opportunity/history remains replenishable. Native regional capture/mastery/unlocks, true engine streaming out/in, eight-slot caps, pre-/post-write capture recovery and fresh Play/rejoin pass; 171 fast tests and eight native scheduler suites pass. Energy Core appearance/source geometry is unchanged.

Fourth dependency COMPLETE under AD-258: [ordinary World Cycle and prospective context binding](IMP10_WORLD_CYCLE_EVIDENCE.md). One absolute fixed-epoch/versioned server clock uses the existing scheduler; immutable habitat/context bindings keep all current DEV content phase-independent. New reservations pin current cycle context once; pending/live/captured/Secured identities, history and existing transactional state survive transitions unchanged. Exact boundaries, stale/yielded/duplicate fences, invalid-clock admission stop, actual regional captures/mastery/access, engine streaming during a transition and fresh Play/rejoin pass; 179 fast tests and eight native cycle C0 suites pass. Studio is Edit with 84-source parity and unchanged Energy Core/Lighting.

Fifth dependency COMPLETE under AD-259: [travel/discovery/safe arrival/recovery](IMP10_TRAVEL_RECOVERY_EVIDENCE.md). Existing authored hub ↔ field nodes require real discovery/access, Ready character presence and no acquisition. One bounded coordinator shares the world pulse; safe native arrival and generation-fenced recovery preserve history and never extract provisional custody. Existing P2/checkpoint recovery persists five bounded discovery facts without inferred grants. Native routes/masteries, corrupt/missing bindings, actual client duplicate/race/tampering, engine streaming, R6/R15 arrival, write cut points, fresh Play/respawn and three exact purchase retries pass; 187 fast tests and ten native C0 cases pass. Studio ends Edit with 85-source parity and preserved Energy Core/Lighting.

AD-259 follow-up COMPLETE (2026-10-04): [trusted-session presence and locked recovery](IMP10_SESSION_PRESENCE_EVIDENCE.md). The existing bounded presence record now fences readiness, travel and observation by its private ProfileSession and clears the old recovery region on replacement. Four new regressions and actual scoped native session replacement, missing-anchor/locked correction, provisional interruption and admitted P2 preservation pass; 191 fast tests, 14 native C0 cases and final Edit 85-source parity. Existing content, Energy Core and Lighting are preserved.

Sixth dependency COMPLETE (2026-10-05): [one authored DEV hazard and transport fairness](IMP10_HAZARD_TRANSPORT_EVIDENCE.md). A marked, phase-independent Starter corrosive volume reuses the world registry/index, shared pulse and private WorldTravelService presence record. Real server occupancy/segment observation latches exposure until existing TA-7 interruption and validated safe recovery; missing/corrupt anchors keep presence inactive. Provisional recovery never extracts, admitted P2 and Secured value/context survive, and recovery cannot manufacture field-node discovery. Baseline safe routes pass 315 native samples; native acquisition, travel races, death/respawn/rejoin, actual engine streaming/client tampering and prior locked-presence regressions pass. Current gates: 198 fast tests, 29 native C0 cases, 29 authoring cases, 28 Python tests and final Edit 85-source parity; Energy Core/Lighting preserved. Native primitives suffice for this DEV hazard; general world-art/PQL work remains separate.

Seventh dependency COMPLETE (2026-10-05): [one authorized bounded DEV world reward and objective dedupe](IMP10_WORLD_REWARD_EVIDENCE.md). The existing Starter Survey return route binds immutable source `world-reward/starter-return-dev-v1` and fixed 5 Energy. Completion, objective/history and the TA-8 wallet/receipt share the existing ProfileSession P2 operation; the client selects no reward fields. One permanent receipt dedupes after audit eviction and rejoin and preserves at most 5 unspendable Energy when the wallet is full. Existing world/progression reconciliation transfers only that remainder with its original grant reference. Both write cuts, concurrent/duplicate attempts, protected loads, stale presence/session/character, native client replay/tampering, true engine streaming, hazard/custody and real DEV rejoin pass. Current gates: 205 fast tests, 40 native C0 cases, 29 authoring cases, 28 Python tests and final Edit 85-source parity; 58 authored parts, Energy Core and Lighting preserved. Pre-binding completed objectives receive no backfill; other reward integrations remain protected.

Next dependency: **one approved protected content/lifetime binding -> existing spawn and TA-7 acquisition lifetime owner -> capture-fairness and fault/rejoin evidence**. Full security/scaling/performance gates remain open. IMP-10 remains OPEN and VS1-19 / AD-249 is still mandatory before COMPLETE.

Full biome/content registries, spawn scheduling, travel, mastery/hazards and TA-14 scaling.

Mandatory completion gate inherited from IMP-8 / AD-249:

- **VS1-19 (C1): DEFERRED — environment limitation** until the full TA-14/TA-15 controlled L0/L1 plus supported real-client frame/memory validation is executed and passes for the relevant World Scaling candidate build.
- L1 is **30 players at configured MaxPlayers=60**; the numeric guardrails, device measurements and repetition rules remain unchanged. Existing solo Studio samples are partial L0 evidence and cannot satisfy this gate.
- **IMP-10 cannot be COMPLETE and the roadmap cannot advance beyond IMP-10** while VS1-19 is deferred, missing, failed or incomplete. Production release remains separately subject to full TA-15/TA-14 gates.

## IMP-11 — Social and Events

Party/Ping/challenge/visitor plus global event occurrence/contribution/rewards and cross-server hints.

## IMP-12 — Trading

Trade session/revision/reservations, durable journal, transaction-fenced participant apply/recovery.

## IMP-13 — Commerce

Product definitions/bindings, Game Pass reconciliation, Developer Product receipt journal, Starter grant and commercial UI.

## IMP-14 — Live Ops / Analytics / Experimentation

Telemetry registry/adapters, C2 config snapshots, flags, experiment assignment/exposure and privileged audit boundary.

## Pre-release Production Quality Track

The following ten gates broaden the existing implementation roadmap without changing gameplay authority or bypassing upstream IMP dependencies. They may be delivered incrementally once their underlying systems are stable, but **all applicable PQL-1..PQL-10 gates must be complete before IMP-15 can close and production release can proceed**.

### PQL-1 — World Art & Map Polish

Turn functional regions into authored, attractive spaces with distinct biome identity, terrain composition, paths, landmarks, foliage/props, structures, environmental storytelling, lighting, atmosphere, readable traversal and strong points of interest. Important regions should be recognizable from screenshots alone. Use Blender MCP for modular environment kits, architecture, hero landmarks and props where custom modelling adds value; validate final appearance in Studio.

Gate: the representative/golden region reads as an intentional production environment with the HUD hidden, and the established quality bar is reproducible across later regions.

### PQL-2 — Creature & Asset Quality

Bring creatures, collectibles and gameplay props to a consistent visual standard: silhouettes, rarity readability, materials, animation-ready topology where needed, idle presentation, Vault/display presentation and performant geometry/LOD strategy where applicable. Use Blender MCP for creature/hero models, riggable meshes, machines and display assets.

Gate: no important gameplay object remains an engineering placeholder, and common/rare/exceptional content is visually distinguishable without relying only on text.

### PQL-3 — UI/UX & Presentation Polish

Polish HUD, navigation, Vault, collection, discovery, progression/mastery, travel, notifications, objectives, rewards, commerce surfaces, settings, mobile layouts, controller navigation and accessibility states. Establish consistent typography, spacing, hierarchy, iconography, panel language, rarity treatment, interaction/loading/error/empty states and restrained motion. Keep actual interface behavior Roblox-native; use Blender MCP only for visual assets or 3D presentation where it clearly improves the result.

Gate: every primary gameplay loop is understandable and fully usable without developer/debug knowledge across supported inputs.

### PQL-4 — Animation, VFX, SFX & Game Feel

Add coherent feedback for movement/interactions, creature states, capture, spawn/despawn, discoveries, rarity, rewards, unlocks, travel, hazards, world transitions and UI actions. Use Roblox-native particles/beams/trails/audio where sufficient; use Blender MCP for rigs, animated props, custom effect geometry and animation-support assets when required.

Gate: repeated core actions remain responsive, legible and satisfying without obscuring gameplay state.

### PQL-5 — Onboarding & First-Session Experience

Polish the gameplay-first path from spawn to first goal, exploration, encounter, capture, reward, Vault interaction, progression and next objective. Prefer contextual teaching over tutorial walls; include recovery from mistakes and clear cross-input guidance.

Gate: a new player with no outside explanation can understand what MonsterVault is, what to do next, how capture works, why creatures matter and what progression to pursue.

### PQL-6 — Retention & Progression Presentation

Make existing progression motivating and legible through mastery/discovery presentation, region and collection completion, rarity, upgrades, quests/objectives, milestones, achievements, unlock previews and meaningful reward moments. Do not invent grind solely to increase session time.

Gate: players can identify what they just achieved and have clear short-, medium- and longer-term goals.

### PQL-7 — Live Events & Seasonal Content

Exercise the live-ops architecture through polished player-facing events: seasonal creatures/content, temporary world states or spawn changes, event objectives/community goals, limited rewards, countdown/status UI and update messaging. Reuse existing systems instead of creating event-only parallel frameworks. Use Blender MCP for event-specific props, decorations, landmarks, creatures and reward models when useful.

Gate: at least one representative event can run through the production live-ops/config path with correct start/end/recovery behavior.

### PQL-8 — Social Presentation & Multiplayer Polish

Ensure other players improve the experience through readable player presence, cooperative moments, ping/party/challenge/visitor presentation, creature showcasing/inspection and trading presentation when the underlying systems exist. Avoid adding social mechanics that do not support MonsterVault's actual loop.

Gate: multiplayer feels intentionally social rather than like isolated single-player sessions sharing one server.

### PQL-9 — Commerce Presentation

Integrate passes/products/entitlements into MonsterVault's visual language with clear previews, value communication, ownership state and purchase confirmation/recovery. Avoid intrusive spam, deceptive scarcity, confusing currencies and pay-to-win shortcuts that undermine collection/progression. Blender MCP may produce high-quality 3D product/reward previews where appropriate.

Gate: commerce is coherent with the game, receipt/entitlement behavior is reliable, and presentation does not degrade the core player experience.

### PQL-10 — Launch & Promotional Polish

Finish loading/title/menu/startup transitions, reconnect/recovery messaging, update/event banners and final visual consistency. Prepare production-quality Roblox icon, thumbnails, screenshots, key art, store copy, update artwork and trailer/promotional scenes where applicable. Promotional imagery must represent the actual game honestly. Blender MCP may be used to stage/render hero assets and poses; Roblox Studio remains the final authority for in-game appearance.

Gate: no obvious placeholder/debug presentation remains, core screenshots represent actual polished gameplay, and map/creatures/UI/VFX/animation/audio/progression/social/commerce/event presentation pass a final consistency audit.

## IMP-15 — Release Hardening

Begins only after the underlying implementation dependencies and applicable PQL-1..PQL-10 production-quality gates are satisfied. Release hardening is for verification and launch readiness, **not** for creating major missing art/UI/game-feel systems.

Full TA-15 V0-V10 evidence, TA-14 L0-L5, security/fault sweeps, staging promotion, current policy/API revalidation and release checklist.

## Change rule

A phase may be split into smaller PRs. It may not bypass upstream gates or move authority to a more convenient layer.

AD-249 is an explicitly owner-authorized TA-17 amendment to validation timing, with a named gate, owner and hard deadline. It grants no general permission to defer other acceptance rows.
