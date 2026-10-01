# IMP-9 Implementation Evidence

> **Status:** OPEN — first dependency implemented and validated; phase incomplete
>
> **Date:** 2026-10-01
>
> **Contracts:** GDS-4, GDS-5, GDS-7; TA-2, TA-4, TA-7, TA-8, TA-15, TA-17

PR #47 was squash-merged to main as `2ee3f8b0492c978e30ee6de2bb93ef2f292a8e83`. The local checkout was fast-forwarded to that main; all 53 existing authored Studio scripts matched before IMP-9 edits. IMP-8 remains COMPLETE under AD-249. VS1-19 remains DEFERRED for environment limitation, mandatory before IMP-10 COMPLETE.

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
| Authorized additive capacity sources and deterministic reconciliation | OPEN — next dependency | TA-8 sections 21–24; validated content bounds, survivor ordering, non-destructive P2 reconciliation and explicit exact-instance Resolve Overflow. |
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

Next: replace the DEV scalar with separately authorized, content-bounded capacity components and implement deterministic, non-destructive P2 reconciliation plus owner-selected Overflow-Held resolution before opening assignment/production dependencies.
