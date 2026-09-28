# IMP-8 — VS-1 Closure Evidence

**Status: OPEN.** This run implemented the missing durable rejoin projection and expanded verification. The locked [VS-1 matrix](../technical_architecture/TA17_VERTICAL_SLICE_ACCEPTANCE_MATRIX.md) is not closed: native gamepad input, L1 and real-client performance, and a trusted runtime timeout/reconciliation case still lack evidence. IMP-9 has not started.

## Implemented

- A Ready profile sends a private `securedCollection` snapshot on the existing reliable `Projection.Snapshot` route. It contains the latest durable `CreatureInstanceId` values once each, ordered by committed operation revision, capped at five IDs and 480 ID characters, with `hasMore` when older records exist. It includes no provisional capture, client-supplied ownership, or invented capture/custody identifier. A fresh client accepts it only against the matching Ready profile revision; duplicate, conflicting, malformed and stale snapshots cannot add ownership.
- Capture state diagnostics now correlate the original request ID with the server operation ID through transport and finalization. The allowlisted record contains no player, profile, payload or credential fields. The test runner prints each manifest seed ID beside the test result.
- A deterministic 1,000-case capture-history test covers identity/no reroll, owner authority, exact-once finalization, lost-result reconciliation and pre-write failures. Luau source files use LF in Git so StyLua is reproducible on Windows.

## VS-1 acceptance matrix

`PASS` means evidence exists at the stated layer; `OPEN` means the locked completion rule still needs the named trusted test. Earlier IMP-6 and IMP-7 evidence remains applicable and is linked below.

| Row | Evidence in this run and prior phases | State |
|---|---|---|
| VS1-01 | 109/109 fast tests; StyLua, Selene, Luau analysis, Rojo build, dependency/integrity checks and 28 Python checker tests pass locally. | PASS locally; PR CI pending |
| VS1-02 | Single server/client entrypoints and integrity checker. | PASS |
| VS1-03 | `T15.persistence.load.failureProtected`; no default save or Ready on failed load. | PASS in fake adapter |
| VS1-04 | `T15.persistence.lease.freshStale` and loss/revision cases. | PASS in fake adapter |
| VS1-05 | `T15.network.session.helloAuthority`. | PASS |
| VS1-06 | Gateway/WireValidation hostile-envelope tests; DEV Studio rejected extra owner field and NaN interaction ID. Oversized capture-specific Studio payload has not been injected. | OPEN trusted hostile matrix |
| VS1-07 | Claim authority and generated-history tests; DEV Studio rejected a forged capture session. Hostile prompt/Instance trigger is not separately evidenced. | OPEN trusted hostile prompt |
| VS1-08 | Fixture materialization/stable retry tests; one stable DEV runtime target. | PASS |
| VS1-09 | Variant no-reroll and 1,000-case generated-history tests; IMP-6 DEV capture. | PASS |
| VS1-10 | Claim authority/generated-history tests; IMP-6 duplicate submit retained one custody. | PASS |
| VS1-11 | IMP-6 provisional capture had no owned profile record; current projection reads only committed profile ownership. | PASS |
| VS1-12 | Exact-once finalization and generated-history tests; IMP-6 server operation ID. | PASS |
| VS1-13 | Lost-result cut-point/release tests and generated-history corpus reconcile one durable apply. Trusted STG service fault test is unavailable. | PASS deterministic; STG pending for adapter readiness |
| VS1-14 | Before-write cut-point/release tests and generated-history corpus never fabricate ownership. Trusted STG service fault test is unavailable. | PASS deterministic; STG pending for adapter readiness |
| VS1-15 | New fresh-server owner-isolated integration test and DEV Stop/Play rejoin: profile revision 11, 10 unique owned records; latest ID `creature-95cdbff7-721d-4b6b-af73-694e51f78469` appears exactly once and first in the five-ID snapshot (`hasMore=true`). A repeated client snapshot is `Stale`. | PASS for latest captured ID |
| VS1-16 | IMP-7 timeout/OutcomeUnknown/resync tests pass. A live Pending timeout was not exercised: DEV profile is at fixture capacity 10/10, and current network simulation did not yield a deterministic timeout. | OPEN trusted runtime case |
| VS1-17 | IMP-7 keyboard/touch tests and DEV device views; gamepad binding source tests pass. MCP `ButtonX` arrived as `Keyboard` and did not activate the gamepad InputAction; no physical controller is available and the Studio Controller Emulator widget is not exposed by this MCP. | OPEN native gamepad action |
| VS1-18 | DEV capture view was inspected: state meaning uses persistent static heading/body/button text; no animation or sound-only transition is required. | PASS for this static UI |
| VS1-19 | Three five-second solo Studio samples are below the 25 ms sustained server-frame hard guardrail. No L1 half-occupancy run or real-client frame/memory evidence; Studio memory was process-wide. | OPEN L0/L1 hard-guardrail proof |
| VS1-20 | Runtime StructuredDiagnostics test verifies request/operation correlation and allowlisted fields; the runner now prints manifest seed IDs. A capture correlation record was not produced in the final full-capacity Studio run. | PASS local; trusted log pending |

## Connected Roblox Studio MCP evidence

DEV place `110304961224794`, universe `10766503968`: two Play sessions reached `Session.Ready` and returned to Edit without console errors. The fresh-server collection snapshot matched profile revision 11. Hostile extra-owner and NaN requests returned `REJECT_VALIDATION_PAYLOAD`; a forged session returned `REJECT_STATE_CAPTURE_REJECTED`; the world stayed `IdleAvailable` and the profile stayed at revision 11 with 10 creatures. Temporarily removing the local target tag disabled interaction and restoring it re-enabled interaction, without an ownership transition. This was a local stream-out simulation, not an engine streaming test. The first Play session appears to have stored the tenth DEV fixture creature through normal gameplay; no profile was cleared or directly edited.

| L0 Studio metric, three 5 s samples | 1 | 2 | 3 |
|---|---:|---:|---:|
| Client Heartbeat p95 | 19.00 ms | 18.41 ms | 18.44 ms |
| Client `RenderCPUFrameTime` | 6.90 ms | 6.61 ms | 6.80 ms |
| Server Heartbeat p95 | 18.02 ms | 18.01 ms | 18.00 ms |

`Stats:GetTotalMemoryUsageMb()` was about 1,755 MB for the Studio process and cannot establish the server/client memory budget. The server frame samples exceed the 16.67 ms target but not the 25 ms sustained hard guardrail. [TA-14](../technical_architecture/TA14_PERFORMANCE_SCALABILITY_BUDGET_MATRIX.md) requires real-client/device evidence for client frame and memory. The connected MCP cannot drive the Studio Controller Emulator widget or a usable `StudioTestService` multi-client session from its current context.

## Verification and remaining gate

- `lune run tests/runner.luau -- --suite fast`: **109/109 PASS**, including four new VS-1 cases.
- `stylua --check --output-format Summary src tests scripts`: **PASS** after LF normalization.
- `selene src tests scripts`: **0 errors, 0 warnings**.
- `luau-lsp analyze --platform roblox --settings=luau-lsp.json --sourcemap=sourcemap.json src tests scripts`: **0 diagnostics**; existing missing engine-definition warning.
- `rojo build default.project.json`, architecture/integrity checkers and 28 Python checker tests: **PASS**.

Complete the remaining trusted hostile/timeout/input and L1 plus real-client performance evidence before changing this status to COMPLETE or starting IMP-9. An isolated STG place is also needed before the persistence adapter can be called production-ready; only DEV is currently available.

Prior phase evidence: [IMP-6](IMP6_IMPLEMENTATION_EVIDENCE.md), [IMP-7](IMP7_IMPLEMENTATION_EVIDENCE.md).
