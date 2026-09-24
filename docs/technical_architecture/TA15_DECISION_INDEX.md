# TA-15 Decision Index

> **Status:** Accepted  
> **Date:** 2026-09-24  
> **Owning phase:** TA-15

| ID | Decision |
|---|---|
| AD-192 | Test contracts at the cheapest trustworthy layer; mocks never replace required engine/platform evidence. |
| AD-193 | Give tests stable semantic IDs and TA/GDS traceability independent of implementation filenames. |
| AD-194 | Classify ownership/value/persistence/security invariants as C0: mandatory and non-quarantinable. |
| AD-195 | Require clean formatting, lint, strict type analysis and deterministic Rojo build gates. |
| AD-196 | Inject clock, RNG and platform adapters so critical logic is deterministic and reproducible. |
| AD-197 | Require 1,000-case fast and 10,000-case extended deterministic property corpora for affected critical property families. |
| AD-198 | Verify random systems through injected boundary/mapping tests; statistical tests are reproducible diagnostics, not sole truth. |
| AD-199 | Use Roblox Studio scripted testing as authoritative engine-integration runtime. |
| AD-200 | Use Studio device, virtual input, network and player-emulation facilities for client/accessibility/network evidence. |
| AD-201 | Separate untrusted PR compute from privileged engine/staging compute. |
| AD-202 | Prohibit arbitrary public-fork PR code on persistent self-hosted personal runners. |
| AD-203 | Require hostile-client negative tests for every client-triggered authority surface. |
| AD-204 | Require deterministic persistence faults, migrations, lease/concurrency and shutdown recovery tests. |
| AD-205 | Test every exact-once transaction at durable crash/retry cut points. |
| AD-206 | Keep DEV/STAGING/PRODUCTION test data and credentials strongly isolated. |
| AD-207 | Make all TA-14 L0-L5 hard guardrails release-verifiable. |
| AD-208 | Do not treat an empty/solo Studio run as sufficient real-client performance evidence. |
| AD-209 | Emit structured, privacy-minimized evidence with build/seed/fault/device/load identity. |
| AD-210 | Prohibit retry-until-green; C0 cannot quarantine and C2 quarantine expires after seven days. |
| AD-211 | Require all applicable C0/C1 engine/security/fault/performance/staging evidence before release. |
| AD-212 | Target 14-day ordinary PR evidence and 90-day release evidence within public-repo retention limits. |
| AD-213 | Every fixed C0/C1 defect adds a durable regression test unless technically impossible. |
| AD-214 | Close TA-15 and advance the dependency chain to TA-16. |

**Decision index result: ACCEPTED.**
