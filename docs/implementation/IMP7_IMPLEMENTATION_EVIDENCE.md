# IMP-7 — Capture Client Experience

**Gate:** COMPLETE — local and connected DEV Studio validation. **Next:** IMP-8 VS-1 closure. This does not promote the game to STG or PROD.

## Implemented slice

- One server-authoritative capture projection, on the existing `Capture.StateChanged` route and `Session.RequestResync` domain. It carries per-player revisions and exact capture, creature and custody IDs. Only confirmed persistence can project `Secured`; capture resync can recover missed claim, transport, pending-finalization and terminal events without granting ownership from client data.
- Server capture projections retain exact revisions for connected players and active custody while bounding recent disconnected terminal summaries to 256 players. A quick same-server reconnect can recover a recent outcome without keeping unbounded capture history.
- One semantic capture action through Roblox InputAction/InputBinding: keyboard E, gamepad X and a touch/pointer button. The action keeps a held press from becoming a second command when the capture state changes. Menu, text-box and window focus block actions. Input and display bindings are disposed on stop.
- One compact safe-area panel. It shows persistent text for loading, available target, claim, transport, saving, failure, expired and secured outcomes. Static colors, no motion or sound-only feedback. The controller keeps `Pending` and `OutcomeUnknown` honest; delayed commands reuse their original request ID inside the replay window and resync while uncertain. Unsolicited server transitions also resync at a bounded cadence while capture is active.
- Capture-specific rejection results also trigger authoritative reconciliation: expiry and invalidation may have changed server state even when the transition event was lost. The client keeps the action blocked until it receives the capture projection.
- World model availability now accepts the server's capture lifecycle values. Streaming loss removes a local target reference but never invents a terminal capture state. No new economy, content, modal, camera or generic notification framework was added.

## Verification

- `lune run tests/runner.luau -- --suite fast`: **105/105 PASS**. Added tests exercise revision validation, lost events including invalidation and expiry results, replay identity, unavailable/at-risk response handling, bounded resync and server projection retention, streamed-out targets, held inputs, focus/menu guards, adapter cleanup and runtime server correlation.
- `stylua --check --output-format Summary src tests scripts`, `selene src tests scripts`, `luau-lsp analyze --platform roblox --settings=luau-lsp.json --sourcemap=sourcemap.json src tests scripts`, architecture and integrity checks, 28 Python checker tests, and Rojo build: PASS. Luau analysis has the existing missing engine-definition warning and zero diagnostics.
- Connected DEV Studio place `110304961224794`: keyboard E separately claimed, captured and extracted a fixture creature; the UI changed from `Claimed` to `TransportActive` to durable `Secured`. Holding the first E did not submit the capture. A focused text box blocked E. After Stop Play, the DEV DataStore contained five owned creatures at profile revision 6. All 50 local source scripts matched Studio by normalized UTF-8 size and Adler-32. The Studio VirtualInput tool cannot send Escape to the CoreGui menu, so menu suppression is covered by native-action source tests.
- Device Simulator: iPhone 17 Pro touch input via the UI button registered as `Touch` and drove claim and failure feedback. A Samsung Galaxy A16 landscape viewport at 685×338 kept heading, body and button readable with 30/26/26 px expanded test text; all three `TextFits` values were true and the 420×170 panel stayed in Core UI safe insets. An iPad Pro M5 13-inch viewport at 1375×1032 kept a 420×124 panel readable. Xbox simulator at 1919×1079 showed gamepad `[X]`, selected the button and kept the panel readable. A real gamepad button press was not supplied by the Studio VirtualInput tool; full physical controller parity is still a VS-1/IMP-8 test, rather than a claim from the simulator label alone.

The panel uses `AutomaticSize`, wrapped labels and `CoreUISafeInsets`; Roblox's PreferredTextSize system expands wrapped/automatic text. The preference itself remained Medium during this run. No reduced-motion transition is required because the view uses no animation.

## Scope and next gate

This is the thin capture UI over the IMP-6 backend. The complete TA-17 vertical-slice matrix, multi-client/STG and physical-controller checks remain in **IMP-8**. Production release stays closed.
