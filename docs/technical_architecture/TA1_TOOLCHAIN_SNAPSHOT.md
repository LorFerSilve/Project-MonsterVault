# TA-1 Toolchain Snapshot

> **Review date:** 2026-09-18  
> **Status:** PASS  
> **Purpose:** Record the external tool/platform state used when TA-1 selected the MonsterVault development baseline.  
> **Note:** This is a dated evidence snapshot, not permission to float versions. TA-17 performs the final implementation-lock version review.

## 1. Roblox Studio / Script Sync

Official source:

https://create.roblox.com/docs/scripting/sync

Observed current guidance:

- Roblox Studio includes a built-in Script Sync workflow for external editors;
- Roblox explicitly positions Script Sync as a good fit when primarily synchronizing scripts while using Studio for the rest of the project;
- Roblox explicitly notes that third-party tools such as Rojo are a better fit when the filesystem is intended to be the broader source of truth.

TA-1 consequence:

> MonsterVault selects Rojo because the Git repository is intended to be authoritative for first-party Luau and project configuration.

## 2. Roblox Studio

Official source:

https://create.roblox.com/docs/studio

Observed current guidance:

- Studio remains the authoritative Roblox editor/runtime;
- it provides playtesting, device emulation, scripting and publishing;
- external editors do not replace Studio's runtime/debugging role.

TA-1 consequence:

> Stable Roblox Studio remains mandatory even with an external-editor workflow.

## 3. Luau Strict Type Checking

Official sources:

https://create.roblox.com/docs/luau/type-checking  
https://luau.org/types/

Observed current capability:

- Luau supports gradual type checking;
- `--!strict` is the strongest normal inference/type-checking mode;
- Studio surfaces type errors/warnings;
- strict typing is suitable for catching defects before runtime.

TA-1 consequence:

> First-party MonsterVault Luau defaults to strict type checking.

## 4. Rojo

Upstream source:

https://github.com/rojo-rbx/rojo/releases

Current stable release observed:

- **Rojo 7.7.0**
- release date shown by upstream: 2026-07-02.

Relevant 7.7.0 behavior:

- filesystem-first Studio synchronization;
- `rojo build`;
- sourcemap generation support;
- websocket-based `rojo serve`;
- Host/Origin validation for local serve security;
- syncback support exists but is not required by MonsterVault baseline.

TA-1 reference pin:

> `rojo-rbx/rojo@7.7.0`

## 5. Rokit

Upstream source:

https://github.com/rojo-rbx/rokit/releases

Current stable release observed:

- **Rokit 1.2.0**
- release date shown by upstream: 2025-09-30.

Relevant properties:

- stable 1.x toolchain manager;
- exact GitHub-release tool pins;
- production usage stated by upstream;
- native ARM64 support across major platforms from 1.1.x onward.

TA-1 reference:

> Rokit 1.2.0 is the baseline toolchain manager.

## 6. Luau Language Server

Upstream source:

https://github.com/JohnnyMorganz/luau-lsp/releases

Current stable release observed:

- **luau-lsp 1.69.0**
- release date: 2026-07-14.

Relevant behavior:

- Roblox/Luau language-server analysis;
- current sourcemap-aware Roblox require resolution;
- Studio-plugin integration support;
- synced to a recent Luau upstream release.

TA-1 reference pin:

> `JohnnyMorganz/luau-lsp@1.69.0`

## 7. StyLua

Upstream source:

https://github.com/JohnnyMorganz/StyLua/releases

Current stable release observed:

- **StyLua 2.5.2**
- release date: 2026-05-16.

Relevant behavior:

- current Luau syntax support;
- deterministic formatting;
- current support for recent Luau syntax such as `const`.

TA-1 reference pin:

> `JohnnyMorganz/StyLua@2.5.2`

## 8. Selene

Upstream source:

https://github.com/Kampfkarren/selene/releases

Current stable release observed:

- **Selene 0.31.0**
- release date: 2026-05-20.

Relevant behavior:

- Luau/Roblox static linting;
- recent parser updates including `const` support.

TA-1 reference pin:

> `Kampfkarren/selene@0.31.0`

## 9. Wally

Upstream sources:

https://wally.run/  
https://github.com/UpliftGames/wally/releases

Observed current stable release:

- Wally **0.3.2**.

TA-1 assessment:

- mature Roblox-specific package ecosystem;
- valid option if an approved third-party runtime package is introduced;
- unnecessary at baseline while MonsterVault has zero approved third-party runtime Luau packages.

Result:

> Not adopted at TA-1 baseline.

## 10. pesde

Upstream sources:

https://docs.pesde.dev/  
https://github.com/pesde-pkg/pesde/releases

Observed current stable release:

- pesde **0.7.3**.

Observed current documentation state:

- supports Roblox/Rojo projects;
- multi-target Luau package model;
- remains pre-1.0;
- some scripts-package functionality is documented as intended to change before 1.0;
- current installation documentation has its own version-management guidance.

Result:

> Not adopted at TA-1 baseline. Re-evaluate only if a concrete approved package dependency appears.

## 11. Supply-Chain Decision

MonsterVault intentionally avoids adopting a runtime package manager/framework before a concrete dependency exists.

Benefits:

- smaller trusted computing base;
- fewer supply-chain dependencies;
- fewer version-resolution problems;
- no framework architecture imposed before TA-2/TA-6 define actual module/runtime needs.

## 12. Reference Baseline

| Component | TA-1 reference |
|---|---|
| Roblox Studio | current stable channel |
| Git | current supported stable client |
| Rokit | 1.2.0 |
| Rojo | 7.7.0 |
| luau-lsp | 1.69.0 |
| StyLua | 2.5.2 |
| Selene | 0.31.0 |
| Runtime Luau package manager | none |
| Runtime third-party packages | none |

## 13. Final Lock Rule

These versions are validated TA-1 reference pins.

Before implementation opens, TA-17 must:

1. check whether newer stable versions exist;
2. review relevant changes/regressions;
3. either preserve these pins or intentionally update them;
4. record the exact final locked `rokit.toml` / related tool configuration.

## Verdict

**TA-1 TOOLCHAIN SNAPSHOT: PASS.**


## 14. TA-17 Final Implementation Lock (2026-09-24)

TA-17 revalidated the toolchain immediately before implementation opening.

Final pins:

- Rokit 1.2.0;
- Rojo 7.7.0;
- luau-lsp **1.70.0** (supersedes the TA-1 1.69.0 reference);
- StyLua 2.5.2;
- Selene 0.31.0;
- Lune 0.10.5 as dev/test-only runner;
- no runtime package manager;
- no third-party runtime Luau packages.

The executable lock is `rokit.toml`; TA17_TOOLCHAIN_ENVIRONMENT_LOCK.md records the final review.
