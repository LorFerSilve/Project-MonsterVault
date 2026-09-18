# TA-1 Decision Index

> **Phase:** TA-1 — Roblox System Context, Toolchain, and Development Environment  
> **Status:** Accepted

## TA1-D01 — Roblox Studio Stable Is the Authoritative Engine Runtime

**Decision:** Studio stable remains mandatory for engine execution, playtesting, device emulation and publishing. External editors supplement it.

---

## TA1-D02 — Git/Filesystem Is Authoritative for First-Party Luau and Project Configuration

**Decision:** Rojo-owned source is maintained in Git/filesystem, not independently edited as a second source of truth in Studio.

---

## TA1-D03 — Rojo Is the Primary Filesystem/Studio Synchronization Tool

**Decision:** MonsterVault uses Rojo rather than built-in Script Sync as the primary project workflow because the repository is intended to be the broader source of truth.

**Reference version:** 7.7.0 at TA-1 review.

---

## TA1-D04 — Rokit Manages Pinned Developer CLI Tools

**Decision:** Supported external tools are version-pinned through Rokit rather than relying on arbitrary global installations.

**Reference version:** Rokit 1.2.0.

---

## TA1-D05 — First-Party Luau Defaults to Strict Type Checking

**Decision:** New first-party source uses `.luau` and strict type checking. `--!nocheck` is exceptional and scoped.

---

## TA1-D06 — StyLua, Selene, and luau-lsp Form the Reference Static-Tooling Baseline

**Decision:** Reference pins at review time:

- StyLua 2.5.2;
- Selene 0.31.0;
- luau-lsp 1.69.0.

TA-17 may refresh these after regression review.

---

## TA1-D07 — No Runtime Package Manager at Baseline

**Decision:** Because MonsterVault has zero approved third-party runtime Luau packages, neither Wally nor pesde is adopted yet.

The first approved external dependency triggers an explicit dependency/package-tool review.

---

## TA1-D08 — DEV, STAGING, and PRODUCTION Are Distinct Environment Classes

**Decision:** Local development and staging must not use production player persistence by default. Exact persistence namespaces are owned by TA-4.

---

## TA1-D09 — Launch Defaults to One Primary Gameplay Place

**Decision:** MonsterVault begins with one primary gameplay place per environment. TA-9 may justify a multi-place topology if evidence requires it.

---

## TA1-D10 — Secrets and Credentials Never Enter Git

**Decision:** Tokens, API keys and publish credentials are external to versioned source. TA-15/TA-17 lock the CI/release secret mechanism.

---

## TA1-D11 — Generated Place/Sourcemap/Cache Artifacts Are Not Canonical Source by Default

**Decision:** Generated build artifacts and transient tooling output do not replace source files as authority.

---

## TA1-D12 — Close TA-1 and Advance to TA-2

**Decision:** TA-1 is Architecture Complete — PASS with zero blocking questions. TA-2 becomes NEXT while gameplay implementation remains blocked.
