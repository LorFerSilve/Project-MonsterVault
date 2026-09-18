# TA-1 — Roblox System Context, Toolchain, and Development Environment

> **Status:** Architecture Complete  
> **Owning TA phase:** TA-1 — Roblox System Context, Toolchain, and Development Environment  
> **Authority:** Roblox execution context, experience/environment topology, filesystem/Studio source-of-truth boundaries, editor workflow, Rojo synchronization/build model, toolchain/version management, Luau language policy, formatting/linting/type-checking baseline, dependency acquisition policy, secrets/environment handling, developer setup and reproducibility  
> **Depends on:** TA-0 Architecture Complete; GDS-1, GDS-2, GDS-3, GDS-14, GDS-15, GDS-17

## 1. Purpose

TA-1 defines the technical environment in which all later MonsterVault architecture and implementation will be authored, synchronized, reviewed, tested and eventually deployed.

The environment contract is:

> **MonsterVault uses Roblox Studio as the authoritative execution/editor environment for the Roblox engine, while Git-backed filesystem source is authoritative for first-party Luau and project configuration. Rojo provides deterministic synchronization/building, Rokit pins external development tools, first-party Luau uses strict type checking, and no gameplay/runtime dependency is introduced without explicit dependency review and reproducible pinning.**

TA-1 does not open gameplay implementation.

## 2. Roblox System Context

MonsterVault is a Roblox experience.

Baseline technical context:

- Roblox Studio is required for authoritative engine execution, device emulation, place testing and publishing;
- production gameplay executes in Roblox client/server runtime;
- server-side code is authoritative for security-sensitive state as established by TA-0;
- local external-editor tooling supplements Studio but does not replace Studio's runtime;
- Roblox cloud/platform services are external dependencies and are isolated behind owning TA contracts;
- exact service usage is deferred to the relevant TA phase.

## 3. Environment Topology

Three environment classes are required.

### DEV — Local Development

Purpose:

- author code/configuration;
- synchronize with a local Studio session;
- run local playtests;
- inspect logs and debugging output;
- execute static checks/formatting/linting.

Rules:

- disposable/local test state only;
- no intentional access to production player persistence;
- no production secrets committed locally;
- no publishing directly to production as part of ordinary iteration.

### STAGING — Private Pre-Production Roblox Environment

Purpose:

- multiplayer integration testing;
- platform-service validation;
- cross-device testing;
- persistence/recovery testing against non-production data;
- pre-release acceptance.

Rules:

- separate Roblox experience/universe or otherwise strongly isolated data domain from production;
- separate persistence/store namespace from production;
- not publicly discoverable as the production game;
- may mirror production configuration only through controlled promotion.

### PRODUCTION — Live MonsterVault

Purpose:

- public/live approved experience.

Rules:

- production IDs/secrets/configuration are not used casually in local development;
- publishing follows the later TA-17 release/change-control workflow;
- no experimental developer command may bypass normal authority or safety controls.

## 4. Launch Place Topology

The baseline architecture assumes:

- **one Roblox experience** for MonsterVault;
- **one primary gameplay place per environment** at launch;
- Home Hub and launch biomes exist within that primary gameplay place unless TA-9 produces evidence that a multi-place split is required.

### SYS-01 — Single-place is the default, not an irreversible promise

TA-9 may propose a multi-place topology for performance/content-scale reasons.

A change must preserve GDS lifecycle/travel/persistence semantics and be revalidated against TA-4/TA-9/TA-10.

### SYS-02 — No multi-place complexity without demonstrated need

Teleport-based topology is not introduced merely for organizational convenience.

## 5. Source-of-Truth Boundary

### SRC-01 — Git/filesystem is authoritative for first-party code

The authoritative source for:

- first-party `.luau` files;
- project configuration;
- Rojo project files;
- static data/config files under source control;
- tool configuration;
- documentation;
- tests/scripts once implementation opens;

is the Git repository.

### SRC-02 — Roblox Studio is authoritative for engine execution

Studio is authoritative for:

- actual Roblox engine behavior;
- playtest runtime;
- device emulation;
- Studio-only authoring workflows;
- publishing.

### SRC-03 — Studio copies of Rojo-owned code are projections

A Script/ModuleScript synchronized from the filesystem is not edited as an independent source of truth in Studio.

### SRC-04 — Full world/asset serialization is deferred

TA-2 and TA-9 define exactly which non-code Instances/assets are filesystem-managed through Rojo versus Studio/cloud authored.

TA-1 intentionally does not force the entire 3D world into text serialization.

## 6. Synchronization Strategy

### SYNC-01 — Rojo is the primary project synchronization/build tool

MonsterVault uses a filesystem-first Rojo workflow.

Reference architecture:

```text
Git working tree
    ↓
Rojo project mapping
    ↓
rojo serve / Studio plugin
    ↓
Roblox Studio DataModel
```

For deterministic build artifacts:

```text
Git working tree
    ↓
rojo build
    ↓
generated .rbxl/.rbxlx artifact
```

### SYNC-02 — Roblox Script Sync is not the primary project contract

Roblox Script Sync remains a valid platform feature, but MonsterVault chooses Rojo because the repository is intended to be the broader filesystem source of truth rather than synchronizing only selected scripts.

### SYNC-03 — Generated place artifacts are not canonical source

Generated `.rbxl` / `.rbxlx` build outputs are build artifacts unless a later TA phase explicitly establishes a reviewed exception.

### SYNC-04 — Local Rojo server exposure is restricted

`rojo serve` is local-development infrastructure.

Do not expose it to untrusted networks by default.

If remote/network-accessible serving is ever required, its Host/Origin security and allowed-host configuration must be explicitly reviewed.

## 7. Rojo Baseline

TA-1 reference baseline on **2026-09-18**:

- Rojo **7.7.0**.

Reasons:

- current stable release at TA-1 review;
- supports filesystem-first project synchronization;
- supports source maps used by Luau language tooling;
- includes improved websocket-based sync;
- current release includes host/origin validation for its local server.

TA-17 may refresh the exact pin to a newer stable release after regression validation.

No floating `latest` version is accepted for implementation lock.

## 8. Toolchain Version Manager

### TOOL-01 — Rokit is the baseline toolchain manager

Reference baseline:

- Rokit **1.2.0**.

Rokit owns pinned command-line developer tools that it supports.

The repository will eventually contain a reviewed `rokit.toml` during implementation-lock preparation.

TA-1 records the architecture/tool choices; it does not yet add executable implementation scaffolding.

### TOOL-02 — Tool versions are explicit

Developer machines and CI must not rely on arbitrary globally installed versions.

### TOOL-03 — Toolchain updates are intentional

A tool upgrade requires:

- changelog/release review;
- compatibility check;
- local/static-check validation;
- PR review;
- version-pin update.

## 9. Reference Developer Tool Baseline

Reference versions current at TA-1 review:

| Tool | Reference version | Role |
|---|---:|---|
| Roblox Studio | current stable production channel | authoritative Roblox editor/runtime |
| Rokit | 1.2.0 | toolchain manager |
| Rojo | 7.7.0 | filesystem/Studio sync and builds |
| Luau Language Server | 1.69.0 | editor type/LSP support |
| StyLua | 2.5.2 | Luau formatting |
| Selene | 0.31.0 | Luau static linting |

These are architecture reference pins, not yet TA-17 Implementation Locked pins.

## 10. Editor Policy

### ED-01 — Editor is not architecture authority

VS Code is the reference editor because it integrates well with Rojo/Luau tooling, but source files remain editor-independent.

A contributor may use another editor if it preserves:

- formatting;
- type/lint results;
- encoding;
- source files;
- build/sync behavior.

### ED-02 — Reference VS Code capabilities

Recommended integration:

- Rojo extension;
- Luau Language Server extension;
- StyLua formatting integration;
- Selene diagnostics where supported;
- Git/GitHub integration.

### ED-03 — Studio debugger remains available

External-editor workflows do not remove the need to test/debug inside Studio.

## 11. Luau Language Baseline

### LUAU-01 — First-party runtime language is Luau

New first-party Roblox source uses `.luau`.

Legacy/external `.lua` may exist only when required by tooling/vendor content and must not silently establish a second language standard.

### LUAU-02 — Strict type checking is the default

First-party code should use strict Luau type checking.

The intended default is equivalent to:

```text
--!strict
```

or project-level strict configuration where supported.

### LUAU-03 — `--!nocheck` is exceptional

New first-party production code may not use `--!nocheck` casually.

An exception requires:

- narrow scope;
- documented reason;
- issue/technical debt reference where material;
- no bypass of security/value validation.

### LUAU-04 — `any` is not a default escape hatch

Broad `any` usage at public/domain boundaries requires justification.

### LUAU-05 — Type safety complements runtime validation

Type checking does not replace server-side validation of untrusted client/platform input.

## 12. Formatting Baseline

### FMT-01 — StyLua is authoritative formatting

Reference pin:

- StyLua **2.5.2**.

Formatting is deterministic and should be automated rather than manually debated in review.

### FMT-02 — Formatting-only changes preserve semantics

The formatting configuration may evolve under change control, but code review should not mix large formatting churn with semantic changes without need.

## 13. Linting Baseline

### LINT-01 — Selene is the baseline external linter

Reference pin:

- Selene **0.31.0**.

### LINT-02 — Roblox-aware linting

The final Selene configuration must use appropriate Roblox standard library definitions/configuration.

### LINT-03 — Lint suppression is scoped

Global disablement of useful rules requires architecture/test justification.

## 14. Luau LSP Baseline

### LSP-01 — Luau Language Server is the reference external LSP

Reference pin:

- luau-lsp **1.69.0**.

### LSP-02 — Rojo sourcemap integration is required

Cross-file/Roblox DataModel-aware analysis must use a current sourcemap generated from the active Rojo project mapping.

### LSP-03 — Roblox API definitions stay current

Editor/type tooling must use compatible Roblox API definitions rather than a stale hand-maintained copy.

## 15. Roblox Studio Versioning

Roblox Studio is continuously updated and is not pinned like a normal CLI binary.

### STUDIO-01 — Stable production channel is the baseline

Architecture and CI assumptions target released/stable Roblox behavior.

### STUDIO-02 — Beta-only features are not required without explicit approval

A beta feature may be explored, but a required production architecture dependency on beta-only behavior must be an accepted architecture decision with rollback strategy.

### STUDIO-03 — Engine/API drift is expected

TA-1/TA-15/launch readiness must revalidate tooling/API assumptions after material Studio/platform updates.

## 16. Package and Runtime Dependency Strategy

### DEP-01 — Baseline first-party core has zero required third-party runtime Luau packages

TA-1 does not adopt a framework/package ecosystem simply because one exists.

Examples not automatically adopted:

- Knit;
- Promise libraries;
- Janitor/Maid libraries;
- React/Roact;
- third-party networking frameworks;
- third-party persistence frameworks.

### DEP-02 — No package manager is required while runtime dependency count is zero

MonsterVault therefore does not commit to Wally or pesde at TA-1 baseline.

This is a deliberate dependency strategy, not an unresolved question.

### DEP-03 — First approved external Luau dependency triggers dependency-tool review

Before introducing a third-party runtime/development Luau package:

1. justify the dependency;
2. review maintenance/activity;
3. review license;
4. review security/trust impact;
5. pin an exact compatible version;
6. choose/validate the package manager needed;
7. commit its lockfile;
8. map it into Rojo/source maps;
9. define upgrade/removal strategy.

### DEP-04 — No ad-hoc copied library source

Third-party code is not copied into the repository without provenance/license/version documentation.

### DEP-05 — No runtime network package download

Production gameplay does not fetch arbitrary executable Luau code from external package registries at runtime.

## 17. Evaluation of Wally and pesde

TA-1 records current options without adopting either.

### Wally

Strengths:

- mature Roblox-specific registry/workflow;
- current stable release available;
- common Rojo ecosystem integration.

Tradeoffs:

- another dependency surface;
- unnecessary while no runtime package is required.

### pesde

Strengths:

- modern Luau multi-target package manager;
- Roblox/Rojo support.

Tradeoffs at review date:

- still pre-1.0;
- current documentation warns that some script-package functionality is planned to change before 1.0;
- installation/version-management guidance is still evolving.

### Decision

**No package manager at baseline.**

This minimizes supply-chain and tooling surface until there is a concrete approved package need.

## 18. Repository / Git Workflow Baseline

### GIT-01 — GitHub `main` is the reviewed integration branch

Architecture/implementation changes use branches and pull requests.

### GIT-02 — Direct semantic work on `main` is not the normal workflow

Use branch -> review/validation -> merge.

### GIT-03 — Generated/transient artifacts are ignored

Examples:

- local Rojo build output;
- temporary Studio place copies;
- editor caches;
- logs;
- local tool caches;
- generated sourcemaps unless a later phase deliberately versions one.

### GIT-04 — Source text baseline

Project-authored text source uses:

- UTF-8;
- LF line endings in Git;
- final newline;
- deterministic formatter where applicable.

### GIT-05 — Binary assets require deliberate ownership

Large/binary authored assets are not casually mixed into code review without source/provenance strategy.

TA-2/TA-9 refine this.

## 19. Branch and Release Environment Separation

A Git branch is not itself a Roblox environment.

Rules:

- feature branch != staging;
- merge to `main` != automatic production publish;
- Studio local testing != production validation;
- staging publish != production persistence;
- production publish requires later TA-17 release contract.

## 20. Secrets and Credentials

### SECENV-01 — Secrets are never committed

Examples:

- API keys;
- cloud tokens;
- publish credentials;
- personal access tokens;
- service credentials.

### SECENV-02 — Local secrets use external/local secret storage

Exact mechanism is owned by TA-15/TA-17 where CI/publishing is defined.

### SECENV-03 — Repository examples use placeholders

Documentation/config templates never contain live secrets.

### SECENV-04 — Studio API access is environment-specific

Local Studio access to Roblox API services must never be configured such that production player data becomes the default development target.

TA-4 locks exact persistence isolation.

## 21. Reproducible Developer Setup

A fresh developer machine must be able to become architecture-compatible from documented steps.

Target sequence once implementation scaffolding is opened:

```text
1. Install Roblox Studio stable
2. Install Git
3. Install Rokit
4. Clone Project-MonsterVault
5. Run rokit install
6. Install/configure Rojo Studio plugin
7. Open reference editor
8. Install recommended editor extensions
9. Generate/update Rojo sourcemap as required
10. Run formatting/lint/type checks
11. Start rojo serve
12. Open local Studio development place
13. Connect Rojo plugin
14. Run local playtest
```

TA-1 defines the sequence; TA-17 locks exact executable commands/config files.

## 22. Onboarding/Environment Verification

A developer environment is considered healthy when it can prove:

- correct pinned CLI tool versions;
- Rojo CLI runs;
- Studio Rojo plugin connects locally;
- project mapping builds successfully;
- filesystem edit reaches Studio;
- generated sourcemap reflects project mapping;
- Luau LSP resolves project modules;
- StyLua check passes;
- Selene check passes;
- strict type analysis can run;
- no production secret/data is required.

Exact check commands become TA-15/TA-17 artifacts.

## 23. CI Boundary

TA-1 defines the local toolchain assumptions CI must eventually reproduce.

TA-15 owns the actual GitHub Actions/CI architecture.

CI should not introduce a different unpinned toolchain from developer environments.

## 24. Roblox Collaboration Boundary

Team Create/Studio collaboration may be used for Studio-authored world/assets where appropriate.

For Rojo-owned source:

- Git/PR is the authoritative collaboration workflow;
- simultaneous independent Studio edits to Rojo-owned source are avoided;
- conflicts resolve in the Git/filesystem source, not by maintaining two authoritative copies.

## 25. Supply-Chain Governance

Every externally downloaded executable/tool should have:

- named upstream source;
- explicit version;
- known license where relevant;
- reviewed release provenance;
- update path.

Runtime dependencies receive stricter review than development-only tooling.

## 26. Toolchain Snapshot Sources

TA-1 reviewed current documentation/releases on 2026-09-18:

- Roblox Creator Hub — Script Sync / external tooling;
- Roblox Creator Hub — Luau type checking;
- Rojo releases — 7.7.0;
- Rokit releases — 1.2.0;
- luau-lsp releases — 1.69.0;
- StyLua releases — 2.5.2;
- Selene releases — 0.31.0;
- Wally current registry/release documentation;
- pesde current documentation/release state.

The detailed dated snapshot is recorded in `TA1_TOOLCHAIN_SNAPSHOT.md`.

## 27. Downstream Ownership

### TA-2

Locks:

- exact source tree;
- Rojo project mapping;
- packages/config folder locations;
- module boundaries;
- bootstrap graph.

### TA-3

Locks networking/remotes/trust contracts.

### TA-4

Locks persistence environments and dev/staging/prod store isolation.

### TA-12

Locks client UI/editor-facing architecture.

### TA-14

Locks performance budgets.

### TA-15

Locks static-check/test/CI commands and automation.

### TA-17

Locks final exact tool versions/configuration artifacts and implementation bootstrap.

## 28. Open Questions

There are **zero TA-1-blocking open questions**.

The following are deliberate downstream decisions, not TA-1 gaps:

- exact `default.project.json` layout — TA-2;
- exact source directories/module names — TA-2;
- persistence library/strategy — TA-4;
- whether a package manager becomes necessary — triggered only by an approved dependency and reviewed under TA-1/owning phase change control;
- exact CI commands — TA-15;
- final pinned versions at implementation open — TA-17 regression-validated lock.

## 29. Architecture-Complete Checklist

- [x] Roblox execution context defined.
- [x] DEV/STAGING/PRODUCTION environment classes defined.
- [x] single-primary-place baseline defined.
- [x] source-of-truth boundary defined.
- [x] Rojo selected as primary sync/build tool.
- [x] Script Sync disposition defined.
- [x] Rojo local-server security boundary defined.
- [x] Rokit selected for CLI toolchain pinning.
- [x] reference editor policy defined.
- [x] strict Luau baseline defined.
- [x] formatting/lint/LSP tools selected.
- [x] current reference versions recorded.
- [x] Studio stable/beta policy defined.
- [x] zero-runtime-package baseline defined.
- [x] dependency approval/package-manager trigger defined.
- [x] Git/source encoding workflow defined.
- [x] secret/credential boundary defined.
- [x] reproducible developer setup defined.
- [x] collaboration boundary defined.
- [x] downstream ownership mapped.
- [x] zero TA-1-blocking open questions.
