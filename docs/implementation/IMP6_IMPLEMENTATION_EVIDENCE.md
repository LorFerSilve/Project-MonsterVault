# IMP-6 — Capture and Durable Ownership

> **Status:** COMPLETE — local and DEV Studio gates PASS (2026-09-27); pull-request CI pending publication.
>
> **Base:** `main` after IMP-5.
> **Review:** Pending publication.
> **Traceability:** GDS-4/5/6; TA-3/4/6/7/12/14/15/17.

## Delivered

- The minimal fixture now supports server-validated interaction, claim, one capture action, Provisional Capture / Transport Custody, and Secure Point extraction. Its one-action challenge and fixture success/variant configuration are development placeholders; the accessible client capture experience belongs to IMP-7.
- Injected server RNG fixes the creature's Variant identity before it becomes actionable. Materialization, claim, capture, reconnect, and finalization retries preserve the same creature and Variant identity. Client requests cannot supply ownership, RNG outcomes, or a finalization operation.
- One server-owned finalization operation is minted at provisional capture. Extraction validates the current character generation, trusted profile readiness, and server distance, then freezes the complete owner/creature/operation/Variant/origin/`securedAt` payload. Retries reconcile that admitted payload without requiring the old avatar or re-running spatial admission.
- The P2 finalization use case persists the exact `CreatureInstanceId`, `ownerUserId`, operation, unchanged Variant identity and provenance together with discovery and required Creature Lock. Known-full capacity blocks new capture; a late capacity race keeps the exact creature in Overflow-Held. Owner validation rejects a finalization against another player's profile.
- Unexpected disconnect suspends custody in bounded, same-server Transport Grace. A ready rejoin rebinds the existing custody to the new character; expiry grants no ownership. Avatar failure/reset releases claims and interrupts active transport. A pending finalization survives either interruption until its outcome can be reconciled.
- Controlled shutdown drains admitted pending work and protects only live, matching active custody through its existing operation. Claims, invalid characters and suspended grace cannot create shutdown ownership. Stopped schedulers, queued touches and stale callbacks cannot restart capture work.
- Pending profile checkpoints remain reconcilable during close/release, including a lost result or a failure before the write. The profile coordinator retries an uncertain close without detaching the owned session prematurely. Rejoin sees the committed exact instance rather than a duplicate or a silently discarded candidate. Terminal runtime records are removed; diagnostic capture history is bounded to 128 entries.
- The DEV profile binding is explicit for universe `10766503968`, namespace `MV_DEV_PlayerProfile_v1`, and place `110304961224794`. Studio source installation and DEV DataStore verification used the user's authorized connected project.

## Local verification

| Check | Result |
|---|---|
| StyLua over `src tests scripts` | PASS |
| Selene over `src tests scripts` | PASS; 0 errors, 0 warnings |
| Rojo build and sourcemap | PASS; `build/MonsterVault-IMP6.rbxlx` |
| Strict luau-lsp analysis over `src tests scripts` | PASS; 0 type errors; unchanged missing engine-definition warning |
| Lune fast suite | PASS; 81/81 |
| Python checker regressions | PASS; 28/28 |
| Repository dependency and integrity checks | PASS |
| Connected DEV Studio source installation and playtest | PASS; trusted profile ready, authoritative capture/extraction and persistent rejoin |
| Repository/Studio script source parity | PASS; 45/45 scripts match by normalized UTF-8 length and Adler-32 |

The deterministic tests cover single-winner claim authority, stale/forged sessions, invalid spatial input, no reroll, immutable pending candidates, lost-response and pre-write recovery, owner isolation, legacy-profile compatibility, exact-once close/rejoin, capacity overflow, grace resume/expiry, reset without extraction, shutdown eligibility, bounded records and stale runtime callback cleanup. Runtime lifecycle and fault tests execute the actual `CaptureRuntimeService` source with deterministic Roblox/event mocks.

## Engine evidence

Verification used the connected `project_monstervault` DEV place in Studio Play mode with real profile persistence.

- The player received `Session.Ready`. A malformed request with an extra owner field, a NaN payload, and a forged `captureSessionId` were rejected. Duplicate accepted capture requests returned stable custody. Provisional capture had no owned DataStore record.
- Normal player movement to the Secure Point committed profile revision `3` with creature `creature-a5584cfe-3c9b-4b3b-a082-d9f9356e3fb0`, operation `c1060fc2-9b25-40c1-8eba-4eda50d18691`, and owner `1925180832`.
- Stop Play followed by a new Play join recovered that same creature and operation with collection count `2`; no duplicate was minted.
- A subsequent provisional capture was retired after Humanoid death. It gained no ownership and the profile revision remained `3`.
- The final pass secured `creature-aef9c943-27cc-4999-a564-0245cfa7d546` through ordinary movement, using operation `9f4d99e1-5bd5-4794-92e0-7ae677e4e4a2`, owner `1925180832`, and the same luminous/steady fixture Variant. `Capture.StateChanged` reported `Secured` with the exact creature ID and profile revision `4`.
- A fresh Play join returned `Session.Ready` at revision `4`, with the same final creature ID/operation and collection count `3`. Final server/client bootstrap ran once, the console completed `SHUTDOWN_COMPLETE`, and Studio was left in Edit mode.

## Pull-request CI evidence

Publication and remote `CI / static-build` evidence are pending. The final implementation commit, pull request and checked head/run will be recorded after publication; local PASS does not assert remote CI success.

## Engine and release boundary

This completes the IMP-6 backend fixture gate. It does not close the complete VS-1 acceptance matrix or enable production release. Grace, orderly shutdown, uncertain writes and close/rejoin fault branches have deterministic domain/persistence tests and tests against actual runtime source; their complete live-server fault matrix remains a downstream verification obligation. Abrupt server crash has no guaranteed provisional finalization. Multi-client/STG, device/input/accessibility parity and the full VS-1 evidence remain for IMP-7/IMP-8 and the applicable TA-15 gates.

## Follow-up

Proceed with **IMP-7 — Capture Client Experience**: semantic cross-input control, accessible capture UI, Pending/OutcomeUnknown reconciliation and notification/focus integration. IMP-8 then runs the complete locked VS-1 acceptance matrix before broader feature expansion.
