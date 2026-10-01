# IMP-9 Implementation Evidence

> **Status:** OPEN — capacity policy/components, non-destructive reconciliation and explicit Overflow-Held resolution PASS; phase incomplete
>
> **Date:** 2026-10-01
>
> **Contracts:** GDS-4, GDS-5, GDS-7; TA-2, TA-4, TA-7, TA-8, TA-15, TA-17

IMP-8 remains COMPLETE under AD-249. VS1-19 remains DEFERRED for environment limitation, mandatory before IMP-10 COMPLETE. The capacity-policy foundation was merged in PR #48 as `a1e3489d4e067d69f36ed292fd394f1701b12776`; all 55 authored scripts matched the open Studio project before the current dependency.

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
| Authorized additive capacity policy, deterministic reconciliation and Resolve Overflow | PASS — current dependency below | TA-8 sections 21–24; content-bounded verified source boundary, protected migration, deterministic P2 preservation and native exact-instance resolution. Actual external grant integrations remain with their later owners. |
| Display/production assignments, settlement and offline accrual | OPEN | TA-8 assignment, elapsed-time, epoch, buffer and clock gates remain required. |
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

## Authorized capacity, reconciliation and explicit resolution — current evidence

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

Next: canonical Display/Production assignment validation and coherent production settlement (integer buffer, rate epochs, clocks and online/offline accrual), followed by Energy/claim and progression transactions. IMP-9 remains OPEN until those TA-8 gates pass; IMP-10 has not started. The external VS1-19 gate and its before-IMP-10-COMPLETE deadline are unchanged.
