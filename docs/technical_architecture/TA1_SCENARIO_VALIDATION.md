# TA-1 Scenario Validation

> **Phase:** TA-1 — Roblox System Context, Toolchain, and Development Environment  
> **Status:** PASS

| # | Scenario | Required behavior | Result |
|---:|---|---|---|
| 1 | Fresh developer installs Studio stable | Supported baseline | PASS |
| 2 | Developer uses Studio beta feature | May explore; cannot become required without approval | PASS |
| 3 | Studio auto-updates | Revalidate material breakage; no fake binary pin | PASS |
| 4 | Developer edits first-party Luau in external editor | Filesystem/Git remains source of truth | PASS |
| 5 | Developer edits same Rojo-owned script independently in Studio | Avoid conflicting authority; filesystem version wins/reconcile | PASS |
| 6 | Developer uses built-in Script Sync | Not primary MonsterVault project workflow | PASS |
| 7 | Developer uses Rojo | Primary sync/build workflow | PASS |
| 8 | Rojo plugin connects to localhost serve | Valid | PASS |
| 9 | Rojo serve exposed publicly without review | Invalid | PASS |
| 10 | Generated rbxl committed as canonical code source | Invalid baseline | PASS |
| 11 | Rojo build generates local place artifact | Valid build artifact | PASS |
| 12 | Rojo project mapping changes | Reviewed architecture/config change | PASS |
| 13 | Rojo sourcemap missing | Environment health check fails | PASS |
| 14 | luau-lsp cannot resolve DataModel modules | Fix sourcemap/project config | PASS |
| 15 | Developer uses VS Code | Reference workflow | PASS |
| 16 | Developer uses another capable editor | Allowed if contracts/checks preserved | PASS |
| 17 | Editor autoformats differently from StyLua | StyLua is authoritative | PASS |
| 18 | Developer disables all linting globally | Invalid without justified change | PASS |
| 19 | New first-party file uses .lua | Prefer .luau; exception must be justified | PASS |
| 20 | New production file uses --!nocheck | Invalid casual baseline | PASS |
| 21 | New code uses --!strict | Correct baseline | PASS |
| 22 | Strict types accept input | Runtime trust validation still required | PASS |
| 23 | Client type says request is safe | Does not replace server validation | PASS |
| 24 | StyLua 2.5.2 formats current Luau syntax | Supported reference | PASS |
| 25 | Selene 0.31.0 lints project source | Supported reference | PASS |
| 26 | luau-lsp 1.69.0 used with sourcemap | Supported reference | PASS |
| 27 | Different global Rojo shadows pinned version | Rokit/project tool pin should win | PASS |
| 28 | Developer has no Rokit | Environment not reproducible | PASS |
| 29 | Tool version floats to latest on every machine | Invalid | PASS |
| 30 | Tool upgrade proposed | Release review + PR + validation required | PASS |
| 31 | Rojo newer version exists at TA-17 | May intentionally refresh after regression review | PASS |
| 32 | Studio stable introduces breaking API change | Owning TA phase revalidates; GDS unchanged unless semantics affected | PASS |
| 33 | Beta API is only way to implement design | Architecture decision/conflict review required | PASS |
| 34 | Local DEV uses production player datastore | Invalid baseline | PASS |
| 35 | STAGING uses isolated persistence | Required | PASS |
| 36 | Production config accidentally used locally | Environment boundary violation | PASS |
| 37 | Feature branch assumed to equal staging | Incorrect; Git branch != Roblox environment | PASS |
| 38 | Merge to main auto-publishes production before TA-17 | Invalid | PASS |
| 39 | Staging publish automatically changes production | Invalid | PASS |
| 40 | Team Create used for world art | Potentially valid | PASS |
| 41 | Team Create becomes second authority for Rojo code | Invalid | PASS |
| 42 | No external runtime packages exist | No package manager needed | PASS |
| 43 | Team wants Knit because popular | Not sufficient justification | PASS |
| 44 | Team wants Promise library with real need | Requires dependency review before adoption | PASS |
| 45 | Third-party package copied manually | Invalid without provenance/license/version | PASS |
| 46 | Wally adopted with no package need | Unnecessary baseline complexity | PASS |
| 47 | pesde adopted with no package need | Unnecessary baseline complexity | PASS |
| 48 | First approved dependency appears later | Trigger package-tool review/change control | PASS |
| 49 | Third-party package version unpinned | Invalid | PASS |
| 50 | Runtime downloads executable Luau from registry | Prohibited | PASS |
| 51 | Package license incompatible/unknown | Do not adopt until resolved | PASS |
| 52 | Dependency abandoned/security concern | Upgrade/replace/remove review | PASS |
| 53 | API token committed in config | Prohibited | PASS |
| 54 | GitHub token in documentation example | Must use placeholder | PASS |
| 55 | Local secret stored outside repository | Valid | PASS |
| 56 | CI secret strategy undefined at TA-1 | Acceptable downstream TA-15/17 | PASS |
| 57 | Source file encoded UTF-8/LF | Correct | PASS |
| 58 | Generated cache/log committed | Invalid baseline | PASS |
| 59 | Large binary asset added without ownership strategy | Requires TA-2/9 review | PASS |
| 60 | Home Hub and biomes in one place | Baseline valid | PASS |
| 61 | TA-9 proves multi-place topology needed | May reopen/refine topology with lifecycle validation | PASS |
| 62 | Multi-place split added for code organization only | Reject unnecessary complexity | PASS |
| 63 | Local Studio debugger needed | Supported; external editor does not replace it | PASS |
| 64 | External editor debugger expected to control Studio | Not baseline assumption | PASS |
| 65 | Developer setup requires undocumented manual binaries | Reproducibility failure | PASS |
| 66 | Fresh clone can install pinned CLI tools | Required target | PASS |
| 67 | Fresh clone can build/sync project mapping | Required target once TA-2 exists | PASS |
| 68 | Static analysis differs between developer and CI | Invalid target; TA-15 must reproduce pins | PASS |
| 69 | CI uses floating latest tools | Invalid | PASS |
| 70 | Production gameplay code starts during TA-1 | Implementation gate violation | PASS |
| 71 | Tooling config documentation created during TA-1 | Allowed architecture work | PASS |
| 72 | Executable gameplay services created during TA-1 | Not authorized | PASS |
| 73 | TA-2 asks where source tree maps to DataModel | TA-2 owns exact mapping | PASS |
| 74 | TA-4 asks how dev/staging/prod stores separate | TA-4 owns exact namespace/keys | PASS |
| 75 | TA-17 asks for final pinned tool files | TA-17 locks exact implementation configs | PASS |

## Verdict

**75 / 75 scenarios: PASS.**

No TA-1 environment/toolchain contradiction remains.
