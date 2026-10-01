# IMP-8 — VS-1 Closure Evidence

**Status: COMPLETE — with deferred validation (2026-10-01, AD-249).** The durable rejoin projection, trusted DEV functional checks and VS1-20 correlated capture record are complete. The project owner confirms native gamepad parity is proven. VS1-19 is **DEFERRED — environment limitation**, never PASS, and remains a mandatory C1 hard gate before **IMP-10 COMPLETE**. The formally amended [VS-1 matrix](../technical_architecture/TA17_VERTICAL_SLICE_ACCEPTANCE_MATRIX.md) permits **IMP-9 OPEN** for DEV implementation.

## Implemented

- A Ready profile sends a private `securedCollection` snapshot on the existing reliable `Projection.Snapshot` route. It contains the latest durable `CreatureInstanceId` values once each, ordered by committed operation revision, capped at five IDs and 480 ID characters, with `hasMore` when older records exist. It includes no provisional capture, client-supplied ownership, or invented capture/custody identifier. A fresh client accepts it only against the matching Ready profile revision; duplicate, conflicting, malformed and stale snapshots cannot add ownership.
- Capture state diagnostics retain the original submit request ID with the server operation ID through transport grace, finalization and reconciliation. This diagnostic lineage does not reuse a completed request as a delayed wire correlation. The small operation map is cleared on terminal outcomes and shutdown. The allowlisted record contains no player, profile, payload or credential fields. The test runner prints each manifest seed ID beside the test result.
- A deterministic 1,000-case capture-history test covers identity/no reroll, owner authority, exact-once finalization, lost-result reconciliation and pre-write failures. Luau source files use LF in Git so StyLua is reproducible on Windows.
- Claim admission now validates the server-owned world target and spatial context before known-full capacity, as ordered by the TA-7 eligibility pipeline. A valid nearby claim remains blocked at capacity before any mutation; malformed, unknown or distant contexts receive their own rejection.

## VS-1 acceptance matrix

`PASS` means evidence exists at the stated layer. `DEFERRED` means required validation is still missing and is explicitly routed by [AD-249](../technical_architecture/ARCHITECTURE_DECISIONS.md#ad-249--defer-vs1-19-to-the-imp-10-completion-gate) to IMP-10's completion gate. Earlier IMP-6 and IMP-7 evidence remains applicable and is linked below. The historical Studio JSON retains the original run's results; the closure record below supersedes its gate statuses without altering its measurements.

| Row | Evidence in this run and prior phases | State |
|---|---|---|
| VS1-01 | 110/110 fast tests; StyLua, Selene, Luau analysis, Rojo build, dependency/integrity checks and 28 Python checker tests pass locally on 2026-10-01. Luau analysis retains the existing missing engine-definition warning. Publication must verify `CI / static-build` on the resulting PR head. | PASS locally; remote result tracked in the PR |
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
| VS1-17 | IMP-7 keyboard/touch tests and DEV device views; gamepad binding source tests pass. On 2026-10-01 the project owner explicitly confirmed the native gamepad gate is now proven. This is owner-confirmed trusted native evidence; no new MCP controller run, device model or measurement is invented. Earlier MCP `ButtonX` arrived as Keyboard and remains a historical tooling limitation. | PASS — native gamepad result confirmed by project owner |
| VS1-18 | DEV capture view was inspected: state meaning uses persistent static heading/body/button text; no animation or sound-only transition is required. | PASS for this static UI |
| VS1-19 | Three five-second solo Studio samples are below the 25 ms sustained server-frame hard guardrail. DEV `Players.MaxPlayers=60`, so L1 requires 30 players. No L1 run or supported real-client frame/memory evidence; Studio memory was process-wide. The current Studio/MCP environment cannot execute the required test. AD-249 retains the full TA-14/TA-15 validation and moves its deadline to before IMP-10 COMPLETE. | **DEFERRED — environment limitation; mandatory C1 hard gate before IMP-10 COMPLETE** |
| VS1-20 | The strengthened runtime regression test and [trusted Studio capture probe](evidence/IMP8_STUDIO_2026-10-01.json) retain the original submit request and one server operation through `TransportActive`, `FinalizationPending` and `Secured`; the allowlisted seed record is logged. Native DEV UpdateAsync and re-acquire project the same exact creature once in an isolated test scope. | PASS for diagnostics; direct runtime invocation, not the shipped command gateway |

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

### 2026-10-01 Studio closure work

Studio was the primary source for this run: place `110304961224794`, universe `10766503968`, Studio `0.741.19.7411056`. The inspected capture/profile modules matched the repository before changes. No phase-evidence objects were present in the DataModel; the roadmap and acceptance evidence are stored here.

The strengthened existing regression test first failed because `FinalizationPending` and `Secured` lost the originating request ID. A trusted Studio server probe reproduced those exact failures. `CaptureRuntimeService` was edited directly through the Roblox MCP, then its source was saved to the repository. The final Edit-mode source matched exactly.

The [reusable probe](../../scripts/studio/imp8_capture_diagnostics.luau) uses the existing World/Capture/ProfileSession/DataStore modules, real server Player/character context and native DEV UpdateAsync. Its DataStore scope is `IMP8Diagnostics20261001`, separate from the ordinary player scope; it does not clear collections or raise capacity. Capture RNG is an injected `0.1` fixture, world RNG seed is `8`, and the logged seed ID is `fixture:imp8-diagnostics-v1`. The invocation is a temporary server ModuleScript during Play. Commands call the runtime directly and owner envelopes use a captured event sink; this is diagnostics evidence, not full-gateway, touch, load or STG evidence.

The final run passed in 2.20 seconds: profile revision `3 -> 4`, duplicate submit caused one apply, and fresh lease acquisition projected `creature-1e61a6da-f485-4ef5-ba6d-31322cb70e01` exactly once. All three operation-bearing state records contain request `imp8-submit-e45b98b0-375e-4410-ab78-1fcfd86a1239` and operation `a61276ef-b504-454d-8561-71192e87b143`. [Raw failure/pass records and source hashes](evidence/IMP8_STUDIO_2026-10-01.json) are retained. The ordinary DEV profile remained at revision 11 with 10 creatures. Probe objects were removed, probe leases released, the character restored, and no game error records appeared in the final Play console. Studio was left in Edit.

During that earlier run, the native input audit observed MCP `ButtonX` as `UserInputType.Keyboard`, despite `Gamepad1`, `PreferredInput=Gamepad` and the shipped native action/bindings being present. That probe did not prove VS1-17; the subsequent project-owner confirmation supplies its trusted native result. `MaxPlayers` remains 60, so VS1-19 needs 30 players for L1 plus supported real-client frame/memory measurements. Existing solo Studio samples were not repeated because they cannot resolve the environment limitation.

### Formal closure and registered deferral

The project owner explicitly requested the TA-17 timing amendment and confirmed on 2026-10-01: "de native gamepad-gate is inmiddels ook bewezen". No separate native-input artifact was supplied with this confirmation; its provenance is the owner's trusted test result, not the earlier MCP keyboard audit. No other IMP-8 functional dependency remains open.

[AD-249](../technical_architecture/ARCHITECTURE_DECISIONS.md#ad-249--defer-vs1-19-to-the-imp-10-completion-gate) formally reopens and relocks the owning TA-17 scheduling contract. [The closure record](evidence/IMP8_CLOSURE_2026-10-01.json), acceptance matrix, roadmap and traceability all register **VS1-19 (C1): DEFERRED — environment limitation; owner IMP-10; deadline before IMP-10 COMPLETE**. Required scope remains the complete controlled L0/L1 validation, 30-player L1 at MaxPlayers=60 and supported real-client frame/memory measurement under unchanged TA-14/TA-15 guardrails, build/device identification and repetition rules. IMP-10 cannot be COMPLETE or permit subsequent phase advancement until that evidence actually passes.

The table above retains the three existing L0 Studio samples: server Heartbeat p95 18.02/18.01/18.00 ms, client Heartbeat p95 19.00/18.41/18.44 ms and RenderCPUFrameTime 6.90/6.61/6.80 ms. They are partial Studio evidence only. The approximately 1,755 MB process-wide memory reading cannot establish either real-client or server memory compliance. No L1, real-client performance, or production-readiness PASS is claimed.

**Closure verdict: IMP-8 COMPLETE with deferred validation; IMP-9 OPEN for DEV implementation.** The full performance gate is transferred, not waived. The final connected Studio inspection was in Edit mode and the capture source matched the tested repository source. No gameplay change was needed for the scheduling amendment.

- `lune run tests/runner.luau -- --suite fast`: **110/110 PASS**, including the claim-admission regression case.
- `stylua --check --output-format Summary src tests scripts`: **PASS** after LF normalization.
- `selene src tests scripts`: **0 errors, 0 warnings**.
- `luau-lsp analyze --platform roblox --settings=luau-lsp.json --sourcemap=sourcemap.json src tests scripts`: **0 diagnostics**; existing missing engine-definition warning.
- `rojo build default.project.json`, architecture/integrity checkers and 28 Python checker tests: **PASS**.
- PR #45 `CI / static-build`: **PASS**.

The next implementation dependency is **IMP-9 — Vault / Economy / Progression (OPEN)**. The required external performance test environment must be available and VS1-19 must pass **before IMP-10 COMPLETE**. A natural network timeout remains a useful follow-up check for the shipped gateway; the ordinary DEV profile is full. An isolated STG place is still needed before the persistence adapter can be called production-ready; the scoped DEV probe and AD-249 do not substitute for STG or release evidence.

Prior phase evidence: [IMP-6](IMP6_IMPLEMENTATION_EVIDENCE.md), [IMP-7](IMP7_IMPLEMENTATION_EVIDENCE.md).
