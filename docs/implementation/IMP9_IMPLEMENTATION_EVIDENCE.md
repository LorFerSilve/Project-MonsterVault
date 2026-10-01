# IMP-9 Implementation Evidence

> **Status:** OPEN — capacity, reconciliation, Overflow-Held resolution, assignments and production/offline settlement PASS; Energy/claim and progression remain open
>
> **Date:** 2026-10-01
>
> **Contracts:** GDS-4, GDS-5, GDS-7, GDS-8; TA-2, TA-4, TA-7, TA-8, TA-12, TA-14, TA-15, TA-17

IMP-8 remains COMPLETE under AD-249. VS1-19 remains DEFERRED for environment limitation, mandatory before IMP-10 COMPLETE. Capacity/reconciliation PR #49 was verified merged as `0d8708edc712b288f9066f1b974c1bd9574c9016`; all 60 authored scripts matched the open Studio project before the assignment/settlement dependency. Earlier capacity evidence below retains its original scope and source identities.

## Capacity-policy foundation — historical PR #48 evidence

PR #47 was squash-merged to main as `2ee3f8b0492c978e30ee6de2bb93ef2f292a8e83`. Its local/Studio transition was verified before the foundation below.

The first concrete dependency was Vault ownership of the capacity policy already consumed by capture. Previously, CaptureFinalizationUseCase owned the base capacity and silently treated an invalid persisted override as the base. VaultService now supplies one capacity status to both admission and P2 finalization. Capture remains responsible for its lifecycle; ProfileSession remains the only durable writer.

The existing DEV base of 10 moves unchanged into an immutable, named VaultCapacityFixture snapshot. The optional existing `progression.collectionCapacity` scalar remains compatible with valid DEV fixture profiles; invalid, fractional, negative or inexact values fail protected load and cannot silently enable capture. This scalar is **not** the final TA-8 additive capacity/upgrade/entitlement model. GDS-8 launch tuning, earned upgrades and commercial capacity are not claimed implemented.

Ordinary use counts each non-overflow CreatureInstanceId once, regardless of display/production references. Any unresolved Overflow-Held record blocks ordinary initiation. A capacity race after valid admission still finalizes the exact instance as Overflow-Held, preserving identity, lock, provenance and exact-once ownership. Capture adds no Energy.

| Gate / dependency | Status | Evidence |
|---|---|---|
| Vault authority for existing capture capacity | PASS | One injected Vault policy supplies admission and placement; no networking or persistence authority moves. |
| Instance accounting and full/overflow admission | PASS | T15.vault.capacity.instanceAccounting; existing capture capacity and context-before-capacity tests. |
| Invalid persisted capacity | PASS | T15.vault.capacity.protectedLoad; protected load preserves the stored profile. |
| P2 capacity race, duplicate and identity preservation | PASS | T15.vault.capacity.captureAuthority; existing capture fault suite; native Studio scenario below. |
| Full collection through shipped gateway | PASS | Scripted real-client Command RemoteEvent receives REJECT_STATE_CAPTURE_CAPACITYBLOCKED from the live server. |
| Authorized additive capacity policy, deterministic reconciliation and Resolve Overflow | PASS — PR #49 evidence below | TA-8 sections 21–24; content-bounded verified source boundary, protected migration, deterministic P2 preservation and native exact-instance resolution. Actual external grant integrations remain with their later owners. |
| Display/production assignments, settlement and offline accrual | PASS — AD-251 evidence below | Canonical assignments, integer buffer, immutable epoch history, server clocks, bounded offline/crash settlement and uncertain-write recovery. |
| Energy, claims, quotes and progression transactions | OPEN | TA-8 exact-once atomic wallet/effect, overflow and prospective config gates remain required. |

These PASS rows close the selected policy dependency, not IMP-9 as a whole. IMP-10 cannot start until the remaining IMP-9 gates pass.

The [raw Studio evidence](evidence/IMP9_STUDIO_CAPACITY_2026-10-01.json) records the actual place/universe, Studio version, source SHA-256 identities, operation/request IDs and results:

- the shared Studio probe in [imp8_capture_diagnostics.luau](../../scripts/studio/imp8_capture_diagnostics.luau), invoked with `true`, reuses its native character/world/capture/cleanup harness;
- a unique DEV DataStore scope isolates the capacity-race fixture from normal player progress;
- capacity changes to zero **after** a valid capture is provisional; native secure-point finalization saves one exact Overflow-Held creature;
- revision advances 1 → 3 for the capacity checkpoint and capture finalization; duplicate submit adds no extra capture;
- releasing/reacquiring the real DEV profile restores that exact ID once, the same Variant signature and the overflow restriction;
- the normal DEV profile remains revision 11 with 10 ordinary creatures; temporary modules/world and character movements are cleaned up;
- final Studio Edit state matches all 55 authored scripts in the candidate source, with the four authored world objects retained.

The capacity-race scenario is native server gameplay with an isolated owner event sink. The separate full-collection check traverses the real client/server gateway. MCP E down/up and GUI click returned Success but produced no command in this run; no new physical-input PASS is claimed. The existing owner-confirmed IMP-8 native gamepad evidence is unchanged. Studio also reported the existing avatar-animation asset permission warning; no runtime script failure occurred.

Validation: **113/113 fast Lune tests**, including three new registered capacity tests; **28/28 Python checker tests**; StyLua, Selene (0 errors/0 warnings), repository integrity, architecture dependencies, Rojo build/sourcemap and luau-lsp analysis. Luau analysis retains the pre-existing missing Roblox engine-definition warning; native Studio execution provides the affected engine validation.

This is a local implementation change under TA-17: the valid V1 profile shape and public wire generation/routes remain compatible; only an internal application construction API now requires the Vault authority. No new package, remote, gameplay reward, upgrade tier, capacity purchase or live-config integration is introduced.

## Authorized capacity, reconciliation and explicit resolution — historical PR #49 evidence

The selected dependency is complete under [AD-250](../technical_architecture/ARCHITECTURE_DECISIONS.md#ad-250--register-imp-9-capacity-migration-and-explicit-overflow-resolution). The raw [Studio evidence](evidence/IMP9_STUDIO_RECONCILIATION_2026-10-01.json) identifies this candidate's sources, real DEV scopes, exact creatures/operations, native UI input, client/server envelopes and durable results. Historical PR #48 evidence above is retained with its original scope/hashes.

VaultService now exposes separately identifiable base, earned, commercial and temporary components, each content-bounded and with a total at most TA-14's 2048 owned records. Earned levels must match the server-authored upgrade registry. Commercial/temporary values require server-bound verified readers and matching authored source definitions; the current DEV composition has neither integration, so nonempty persisted claims protect the profile instead of granting capacity or dropping data. The unchanged base is 10; the immutable DEV earned +6 fixture follows GDS-8 PE-08. No purchase, price, production benefit, grant system or external product binding is introduced.

Load preparation runs on the staged lease-acquisition UpdateAsync candidate before Ready. The explicit capacity-domain version-1 migration preserves a valid legacy DEV base and imports original acquisition sequence only from the durable operation ledger. New captures save securedSequence at their existing P2 finalization. Unknown IDs/levels, malformed priority, conflicts and unavailable acquisition order needed for a capacity drop produce ProtectedLoadFailure without overwrite. Changed migration/reconciliation advances the aggregate revision once; repeated preparation, UpdateAsync transform replay and rejoin are idempotent.

Survivors follow valid pinned order, existing production roles in stable slot order, original secured sequence and exact ID lexical tie-break. Excess creatures stay owned as Overflow-Held with identity, lock, provenance and progress intact. Affected display/production references are cleared, with production settlement required first. Production-bearing profiles remain protected while the actual settlement dependency is unbound; the settlement-callback test uses a staged fixture and proves buffer preservation/order, not implemented live production.

VaultCapacityUseCase uses the existing ProfileSession single-writer P2 checkpoint. It retains the same server operation across an unknown result. Explicit Resolve Overflow checks the authenticated owner's exact instance, free ordinary capacity and expected revision, changes only overflowHeld to false, and adds no role or Energy. Capacity gains never auto-resolve. Duplicates return the stored outcome without another value mutation. The existing V1 transports carry a strict Class C route and bounded sorted Vault pages (five IDs / 480 ID bytes); protected-session Class A resync can reconcile pending writes before publishing Ready and the matching owner-only snapshot. Client intent stays pending without inferring durable success from a result/timeout alone.

| Current gate | Status | Evidence |
|---|---|---|
| Authorized component bounds / unknown source protection | PASS | T15.vault.components.authorizedSources; server-only binding, immutable definitions, no wallet/production changes. |
| Deterministic lossless survivor order / settlement-before-invalidation | PASS | T15.vault.reconcile.deterministicLossless; identity/lock/provenance/buffer preserved; repeated preparation unchanged. |
| Protected load / explicit idempotent migration | PASS | T15.vault.reconcile.protectedLoad and idempotentMigration; actual DEV unknown upgrade load rejects without overwrite. |
| Exact-instance P2 resolution / stale, foreign, full, duplicate | PASS | T15.vault.resolution.exactOnce; native real-client foreign/forged commands reject and duplicates return AlreadyStored/cached success. |
| Unknown result before/after write | PASS | T15.vault.resolution.uncertainWrites; unchanged pending candidate/operation, one eventual revision and no inferred success. |
| Bounded owner projection / client authoritative readback | PASS | T15.vault.projection.boundedPages and T15.vault.client.authoritativeReadback; worst-length ID pages fit WireValidation. |
| Native UI -> gateway -> real DEV UpdateAsync -> rejoin | PASS | Real mouse clicks selected an exact held ID then activated Move selected to Stored. Revision 5 -> 6 once; capacity drop -> 7; rejoin preserves all three exact ids and placement. |
| Existing native capture path | PASS | Current candidate re-executed imp8_capture_diagnostics(true): real character/capture/secure-point Overflow-Held race, release/reacquire and exact-once regression. |

The initial native harness hit Roblox's DataStore scope-length limit during its final invalid-data fixture. The scope was shortened, the isolated lease released and the full probe rerun successfully. This was a probe defect; no gameplay contract or normal-profile progress was changed. Normal DEV progress is identical across the successful run: ten ordinary creatures, no overflow, revision 12. The one-time load migration advanced the previous revision 11 to 12 and backfilled sequences from original operation revisions. Studio ends in Edit with all 60 authored scripts matching the candidate, all four authored world objects present and temporary probes/remotes removed. The existing avatar-animation asset-permission warning remains; no current runtime script/gateway diagnostic failure occurred.

Validation: **121/121 fast Lune tests**, including eight new registered C0 dependency tests; **28/28 Python checker tests**; StyLua, Selene (0 errors/0 warnings), repository integrity, architecture dependencies, Rojo build/sourcemap and luau-lsp with zero type errors. Luau analysis retains the pre-existing missing Roblox engine-definition warning; native Studio validates the engine paths. Protocol V1 and profile schema generation 1 remain explicit under AD-250, with a versioned capacity-domain migration and no new runtime package/remote.

The final structure check also found two obsolete same-name VaultService/VaultCapacityFixture ModuleScripts retained from the foundation. Only copies exactly matching the inspected old baseline Source were removed. The tested new instances were retained; the final 60-script source check rejects duplicate names and matches every file by normalized byte length and Adler-32, with SHA-256 source identities in the raw artifact.

PR #49 completed the capacity dependency. The assignment/settlement dependency that followed is recorded below. The external VS1-19 gate and its before-IMP-10-COMPLETE deadline are unchanged.

## Display/Production assignments and production/offline settlement — current evidence

The selected dependency is complete under [AD-251](../technical_architecture/ARCHITECTURE_DECISIONS.md#ad-251--register-imp-9-assignments-and-production-settlement). The [raw native Studio evidence](evidence/IMP9_STUDIO_PRODUCTION_2026-10-01.json) records all 67 runtime source identities, exact instance/operation/request IDs, real gateway envelopes, isolated DEV DataStore results, fresh-server rejoin and final Edit parity. The reusable probes are [imp9_production_settlement.luau](../../scripts/studio/imp9_production_settlement.luau) and [imp9_production_client.luau](../../scripts/studio/imp9_production_client.luau).

Assignments use the existing ProfileSession single writer and P2 checkpoints. Both strict Class C routes require an expected revision and server-authored slot ID; the only optional intent is the exact CreatureInstanceId (omission clears the slot). The authenticated owner's ordinary Stored/Active creature can occupy one Display and one Production slot simultaneously. Duplicate slots of the same kind, foreign IDs, Overflow-Held creatures, incompatible roles and unknown rates are rejected. Lock alone does not prohibit these non-transfer roles. No client timestamp, rate, capacity or owner assertion is accepted. Unknown results retain one server operation until Class A resync confirms durable state. The native minimal manager uses Roblox GUI controls and bounded owner-only assignment pages (two IDs, at most 300 cumulative ID/slot characters); a result or timeout alone never assigns a creature on the client.

VaultProductionService owns deterministic integer milli-output arithmetic. An immutable, named DEV fixture supplies two Production and three Display slots, a 1,440,000 milli-output buffer, a 7,200-second offline window and the fixture species' 100 milli-output/second rate. These values are a development snapshot, not launch balance or a live-config/commercial integration. Every retained epoch identifies its effective time, content snapshot, rates and capabilities. Settlement segments across the retained history before changing assignments/capabilities; missing history/rates fail protected load. Capability loss stops affected slots without resurrecting them on a later expansion. A buffer reduction preserves already saved over-cap output and pauses accrual until headroom exists.

The server samples Unix time at acquisition and anchors online progress to the existing monotonic clock. Settlement advances the cursor and buffer together on the staged durable candidate, preserving fractional elapsed time across checkpoints. Clean leave freezes its original boundary, saves CleanOffline and releases the lease. Fresh acquisition settles offline exactly once before Ready. An Active marker bounds crash recovery to the eligible offline window plus TA-14's 180 seconds; clock regression grants zero, retains the cursor and records diagnostics. Huge elapsed intervals saturate safely before multiplication. No Energy wallet/reward is issued by this dependency.

ProfileSession now retains the exact renewal/save/unlock candidate across a lost result, acknowledges an already stored identical candidate under the lease fence, and renews lease metadata using retry time while preserving the original value/leave cursor. Release first reconciles an uncertain renewal and then writes the original clean leave boundary. These changes close the root cause that previously could turn a successful save with a lost response into a revision mismatch or resettle the leave interval. Capacity reconciliation invokes real production settlement before role invalidation and rereads the settled assignment maps, avoiding stale references after a map replacement. Identity, provenance, lock and buffer survive a capacity drop. Nonempty commercial/temporary production or Display-capacity claims and unbound role authority protect the profile instead of granting effects or deleting progress.

| Current gate | Status | Evidence |
|---|---|---|
| Canonical server assignments / ownership / Overflow-Held / revision | PASS | T15.vault.assignment.authority; real client foreign, duplicate, held, stale and forged clock/rate/owner commands receive distinct rejection codes. |
| Continuous integer timeline / assignment boundaries | PASS | T15.vault.production.continuousTimeline; old assignment settles before replacement/removal, repeated boundaries grant zero, fractional elapsed time survives checkpoints. |
| Epoch history / prospective capabilities / over-cap preservation | PASS | T15.vault.production.epochCapabilities; multi-epoch rates/windows/caps, lost slots remain cleared on later growth, existing output is never truncated. |
| Clean offline / bounded crash / huge intervals | PASS | T15.vault.production.offlineCrashBounds; 7,200-second clean window, 7,380-second crash bound and safe online saturation. |
| Clock authority / regression / wall-clock manipulation | PASS | T15.vault.production.clockAuthority; online progress follows the server monotonic clock, regression adds zero and preserves the cursor. |
| Protected persisted grants / roles / unavailable history | PASS | T15.vault.production.protectedLoad; real DEV DataStore commercial-grant and missing-epoch loads return ProtectedLoadFailure with the stored profile unchanged. |
| Assignment lost response before/after write / transform replay | PASS | T15.vault.assignment.uncertainWrites; the real adapter fault probe retains OutcomeUnknown and reconciles exactly one revision. |
| Renewal, clean leave and unlock lost results / delayed retry | PASS | T15.vault.production.uncertainSaveLeave; original cursor/candidate persists, successful unknown unlock reconciles once, a 200-second delayed renewal refreshes the lease without extra value. |
| Capacity loss settlement / concurrent writers | PASS | T15.vault.production.capacityRace; real nested writer receives Busy, all exact owned creatures become Held at zero capacity, both assignments clear after settlement with output preserved. |
| Bounded projection / authoritative client readback | PASS | T15.vault.assignment.authoritativeReadback; worst-length pages fit WireValidation, stale/gap/ack-only responses cannot infer assignment. |
| Native UI -> gateway -> DEV save/leave -> fresh Play server -> offline readback | PASS | Real mouse assignment revision 4 -> 5 -> 6; renewal/clean release -> 8; fresh-server offline load -> 9. Saved buffer 900 + exactly 19,800 offline milli-output = 20,700; recap 198 eligible seconds. The client restores the exact ID in production/1 and display/1. |

All ten new registered C0 tests also passed on native Studio ModuleScripts using the existing test modules. The full native probe was rerun after correcting its UI-hide prefix length; the final client has exactly one isolated assignment screen and the restored output/roles were visually inspected. The isolated scope preserves the normal player's collection and economy byte-for-value: ten original creatures remain unchanged. Temporary modules/remotes were removed, the fixture lease was released and Studio ends in Edit. All 67 authored scripts match local normalized byte length/Adler-32, SHA-256 identities are recorded, duplicate paths are absent and all four authored world objects remain. The existing avatar-animation permission warning remains; no runtime script or gateway failure occurred.

Validation: **131/131 fast Lune tests**, including the ten new registered tests; **28/28 Python checker tests**; StyLua, Selene (0 errors/0 warnings), architecture dependencies, Rojo build/sourcemap and luau-lsp with zero type errors. Luau analysis retains the existing missing Roblox engine-definition warning; native Studio validates the engine paths. Repository integrity is checked with the final evidence/contract updates. Protocol V1 and profile schema generation 1 remain explicit under AD-251; production has its own version-1 initialization and no new runtime transport/package.

**Next dependency:** Energy wallet/transaction primitive and exact-once Production Claim, then progression quotes/purchases/unlocks. These have not started. **IMP-9 remains OPEN** until the full TA-8 economy/progression gates pass; **IMP-10 has not started**. This dependency does not close the deferred VS1-19 performance gate.
