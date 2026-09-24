# IMP-1 — Contracts and Test Harness

> **Status:** Implementation and local gate PASS; pull-request CI pending
>
> **Base:** codex/ta17-implementation-roadmap-contract-lock (TA-17 PR #37 is open)

## Delivered

- Shared V1 envelope types, protocol version, centrally allowlisted command/event route IDs and command classes, public result-code families, and canonical static content ID grammar/kind checking.
- Separate server wall and monotonic clock interfaces, a server random-source interface, and deterministic clock, fixed-sequence and seeded random test fakes.
- Explicit TA-15 test manifest with stable TestIds and traceability metadata. The Lune runner isolates each test in a child process and enforces its declared timeout, including test-module loading.
- Static TA-2/TA-17 dependency and repository-integrity checks with regression tests. The public PR CI job runs these checks and the fast Lune suite.

No gameplay behavior, remote handler, persistent-state mutation or client authority was added.

## Local evidence

| Check | Result |
|---|---|
| StyLua check over src/tests/scripts | PASS |
| Selene over src/tests/scripts | PASS; 0 errors, 0 warnings |
| Rojo build and sourcemap | PASS |
| Strict luau-lsp analysis over src/tests/scripts | PASS; no type errors |
| Lune fast suite | PASS; 11/11 |
| Dependency and integrity checker regressions | PASS; 28/28 |
| Repository dependency and integrity scans | PASS |

The local Luau analyzer notes that Roblox definition files were not supplied. IMP-1 contains no engine API implementation; this warning does not constitute engine validation.

## Studio and Rojo evidence

Roblox Studio MCP listed the intended project_monstervault instance in Edit mode. Rojo 7.7.0 served the repository, and MCP inspection found the new shared ModuleScripts in ReplicatedStorage.MonsterVault.Shared. A read-only source check matched the live ProtocolV1 ModuleScript's 752-character source to the 752-byte repository file.

Studio Output contains untimestamped Rojo plugin permission/disconnection warnings; their currentness cannot be established from the output API. No playtest was run because IMP-1 adds no engine/gameplay behavior. No staging or production platform test is claimed.

## Contract boundaries and follow-up

- Route-specific payload schemas, hostile envelope validation and network authorization belong to IMP-4.
- Server/client composition and diagnostics are the next roadmap dependency, IMP-2.
- TA-5 says exact runtime GUID formatting is locked at TA-17, while the TA-17 runtime contract states only server-generated GUID identity. IMP-1 does not generate runtime IDs or invent a format. Clarify TA-5/TA-17 before a concrete runtime ID generator is added.
- Luau's tested primitive-intersection brand pattern did not distinguish ID kinds under the pinned analyzer. Public wire IDs remain strings; the static content ID validator checks grammar and kind at runtime. A future nominal helper must preserve canonical string serialization.
