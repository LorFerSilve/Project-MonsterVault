# IMP-8 — VS-1 Closure Evidence

**Status: OPEN.** The durable rejoin projection and additional trusted DEV checks are implemented. The locked [VS-1 matrix](../technical_architecture/TA17_VERTICAL_SLICE_ACCEPTANCE_MATRIX.md) is not closed: native gamepad input, L1/real-client performance and a correlated capture record from Studio still lack evidence. IMP-9 has not started.

## Implemented

- A Ready profile sends a private `securedCollection` snapshot on the existing reliable `Projection.Snapshot` route. It contains the latest durable `CreatureInstanceId` values once each, ordered by committed operation revision, capped at five IDs and 480 ID characters, with `hasMore` when older records exist. It includes no provisional capture, client-supplied ownership, or invented capture/custody identifier. A fresh client accepts it only against the matching Ready profile revision; duplicate, conflicting, malformed and stale snapshots cannot add ownership.
- Capture state diagnostics now correlate the original request ID with the server operation ID through transport and finalization. The allowlisted record contains no player, profile, payload or credential fields. The test runner prints each manifest seed ID beside the test result.
- A deterministic 1,000-case capture-history test covers identity/no reroll, owner authority, exact-once finalization, lost-result reconciliation and pre-write failures. Luau source files use LF in Git so StyLua is reproducible on Windows.
- Claim admission now validates the server-owned world target and spatial context before known-full capacity, as ordered by the TA-7 eligibility pipeline. A valid nearby claim remains blocked at capacity before any mutation; malformed, unknown or distant contexts receive their own rejection.

## VS-1 acceptance matrix

`PASS` means evidence exists at the stated layer; `OPEN` means the locked completion rule still needs the named trusted test. Earlier IMP-6 and IMP-7 evidence remains applicable and is linked below.

| Row | Evidence in this run and prior phases | State |
|---|---|---|
| VS1-01 | 110/110 fast tests; StyLua, Selene, Luau analysis, Rojo build, dependency/integrity checks and 28 Python checker tests pass locally; PR #45 `CI / static-build` passed for the prior commit. | PASS locally; new PR CI pending |
| VS1-02 | Single server/client entrypoints and integrity checker. | PASS |
| VS1-03 | `T15.persistence.load.failureProtected`; no default save or Ready on failed load. | PASS in fake adapter |
| VS1-04 | `T15.persistence.lease.freshStale` and loss/revision cases. | PASS in fake adapter |
| VS1-05 | `T15.network.session.helloAuthority`. | PASS |
| VS1-06 | Gateway/WireValidation hostile-envelope tests; DEV Studio rejected an extra owner field, NaN interaction ID and 300-character `Capture.SubmitAction` session ID with `REJECT_VALIDATION_PAYLOAD`. | PASS |
| VS1-07 | Claim authority, exact-distance and `T15.capture.claim.contextBeforeCapacity`; DEV Studio rejected a forged capture session, an `Instance` interaction ID and a spoofed `ownerUserId` field. After the validation-order fix, the real server rejected the current target at 34 studs as `OUTOFRANGE` and at 10 studs as `CAPACITYBLOCKED`, with no claim or profile mutation. This slice has no `ProximityPrompt`. | PASS |
| VS1-08 | Fixture materialization/stable retry tests; one stable DEV runtime target. | PASS |
| VS1-09 | Variant no-reroll and 1,000-case generated-history tests; IMP-6 DEV capture. | PASS |
| VS1-10 | Claim authority/generated-history tests; IMP-6 duplicate submit retained one custody. | PASS |
| VS1-11 | IMP-6 provisional capture had no owned profile record; current projection reads only committed profile ownership. | PASS |
| VS1-12 | Exact-once finalization and generated-history tests; IMP-6 server operation ID. | PASS |
| VS1-13 | Lost-result cut-point/release tests and generated-history corpus reconcile one durable apply. Trusted STG service fault test is unavailable. | PASS deterministic; STG pending for adapter readiness |
| VS1-14 | Before-write cut-point/release tests and generated-history corpus never fabricate ownership. Trusted STG service fault test is unavailable. | PASS deterministic; STG pending for adapter readiness |
| VS1-15 | New fresh-server owner-isolated integration test and DEV Stop/Play rejoin: profile revision 11, 10 unique owned records; latest ID `creature-95cdbff7-721d-4b6b-af73-694e51f78469` appears exactly once and first in the five-ID snapshot (`hasMore=true`). A repeated client snapshot is `Stale`. | PASS for latest captured ID |
| VS1-16 | IMP-7 timeout/resync tests pass. In DEV Play, the shipped `CaptureController` and `CaptureView` showed `Pending` with a disabled action, then `OutcomeUnknown` after a deliberately withheld result, and returned to actionable `Idle` only after a real correlated server capture resync. The server rejected the command at fixture capacity; this was controlled transport fault injection, not natural network latency or the full shipped gateway. | PASS for client UI/reconciliation |
| VS1-17 | IMP-7 keyboard/touch tests and DEV device views; gamepad binding source tests pass. DEV Play exposes `Gamepad1`, `PreferredInput=Gamepad` and the actual InputAction, but MCP `ButtonX` arrived as `Keyboard`; `VirtualInputManager:SendKeyEvent` lacks `RobloxScript` capability and the Controller Emulator widget is not exposed by this MCP. No physical controller is available. | OPEN native gamepad action |
| VS1-18 | DEV capture view was inspected: state meaning uses persistent static heading/body/button text; no animation or sound-only transition is required. | PASS for this static UI |
| VS1-19 | Three five-second solo Studio samples are below the 25 ms sustained server-frame hard guardrail. DEV `Players.MaxPlayers=60`, so L1 requires 30 players; [StudioTestService](https://create.roblox.com/docs/reference/engine/classes/StudioTestService) supports at most eight simulated clients. No L1 run or real-client frame/memory evidence; Studio memory was process-wide. | OPEN L0/L1 hard-guardrail proof |
| VS1-20 | Runtime StructuredDiagnostics test verifies request/operation correlation and allowlisted fields; the runner now prints manifest seed IDs. A capture correlation record was not produced in the full-capacity Studio runs. | OPEN trusted capture log |

## Connected Roblox Studio MCP evidence

DEV place `110304961224794`, universe `10766503968`: two Play sessions reached `Session.Ready` and returned to Edit without console errors. The fresh-server collection snapshot matched profile revision 11. Hostile extra-owner and NaN requests returned `REJECT_VALIDATION_PAYLOAD`; a forged session returned `REJECT_STATE_CAPTURE_REJECTED`; the world stayed `IdleAvailable` and the profile stayed at revision 11 with 10 creatures. Temporarily removing the local target tag disabled interaction and restoring it re-enabled interaction, without an ownership transition. This was a local stream-out simulation, not an engine streaming test. The first Play session appears to have stored the tenth DEV fixture creature through normal gameplay; no profile was cleared or directly edited.

On 2026-09-29, another DEV Play session used the connected Roblox Studio MCP to reject oversized capture, `Instance` interaction and spoofed owner payloads. The subsequent timeout fault test used the real client controller/view and a real server command/resync, while a temporary adapter withheld the fast result. The panel stayed blocked through `Pending` and `OutcomeUnknown`, then showed `Idle` with a retry message after the correlated authoritative snapshot (`revision=1`). Its temporary GUI and event listener were removed; a follow-up session resync still returned profile revision 11 and five recent secured IDs. A server-side character move to 2,200 studs caused actual client streaming-out (`0` creature models); returning to the fixture streamed the model back (`1`) and restored the nearby action. The character was returned to spawn and Studio was left in Edit. One inspection probe read a nonexistent Workspace property and logged a tool-script error; game scripts did not report a regression.

After the claim-admission fix synchronized to Studio, a further DEV Play session measured 34 studs between character and fixture and received `REJECT_STATE_CAPTURE_OUTOFRANGE`. At 10 studs the same server-owned target returned `REJECT_STATE_CAPTURE_CAPACITYBLOCKED`. The target stayed `IdleAvailable`; a following owner resync still showed profile revision 11 and the unchanged latest secured ID. Studio was returned to Edit.

| L0 Studio metric, three 5 s samples | 1 | 2 | 3 |
|---|---:|---:|---:|
| Client Heartbeat p95 | 19.00 ms | 18.41 ms | 18.44 ms |
| Client `RenderCPUFrameTime` | 6.90 ms | 6.61 ms | 6.80 ms |
| Server Heartbeat p95 | 18.02 ms | 18.01 ms | 18.00 ms |

`Stats:GetTotalMemoryUsageMb()` was about 1,755 MB for the Studio process and cannot establish the server/client memory budget. The server frame samples exceed the 16.67 ms target but not the 25 ms sustained hard guardrail. [TA-14](../technical_architecture/TA14_PERFORMANCE_SCALABILITY_BUDGET_MATRIX.md) requires real-client/device evidence for client frame and memory. The connected MCP cannot drive the Studio Controller Emulator widget or a usable `StudioTestService` multi-client session from its current context.

## Verification and remaining gate

- `lune run tests/runner.luau -- --suite fast`: **110/110 PASS**, including the claim-admission regression case.
- `stylua --check --output-format Summary src tests scripts`: **PASS** after LF normalization.
- `selene src tests scripts`: **0 errors, 0 warnings**.
- `luau-lsp analyze --platform roblox --settings=luau-lsp.json --sourcemap=sourcemap.json src tests scripts`: **0 diagnostics**; existing missing engine-definition warning.
- `rojo build default.project.json`, architecture/integrity checkers and 28 Python checker tests: **PASS**.
- PR #45 `CI / static-build`: **PASS**.

Complete native gamepad input, L1 plus real-client performance, and a trusted capture correlation log before changing this status to COMPLETE or starting IMP-9. A natural network timeout remains a useful follow-up check, but the current full-capacity DEV profile prevents a new capture. An isolated STG place is also needed before the persistence adapter can be called production-ready; only DEV is currently available.

Prior phase evidence: [IMP-6](IMP6_IMPLEMENTATION_EVIDENCE.md), [IMP-7](IMP7_IMPLEMENTATION_EVIDENCE.md).
