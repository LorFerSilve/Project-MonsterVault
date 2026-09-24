# TA-17 Toolchain and Environment Lock

> **Status:** PASS
> **Date:** 2026-09-24

## Locked pins

| Component | Locked value |
|---|---|
| Roblox Studio | stable production channel |
| Rokit | 1.2.0 |
| Rojo | 7.7.0 |
| luau-lsp | 1.70.0 |
| StyLua | 2.5.2 |
| Selene | 0.31.0 |
| Lune | 0.10.5 |
| runtime package manager | none |
| third-party runtime Luau packages | none |

Repository files:

- `rokit.toml`;
- `.stylua.toml`;
- `selene.toml`;
- `.luaurc`;
- `luau-lsp.json`;
- `default.project.json`;
- `.github/workflows/ci.yml`.

## CI action pins

| Action | Immutable commit | Reviewed tag |
|---|---|---|
| actions/checkout | `3d3c42e5aac5ba805825da76410c181273ba90b1` | v7.0.1 |
| paradoxum-games/setup-rokit | `29e6ee09651a3711e3a287a1037671d7b74db6d0` | v3 |

The setup-rokit action is tooling-only, pinned to a commit and receives only the read-only GitHub token in the untrusted PR lane.

## Version review

2026-09-24 review confirms:

- Rokit 1.2.0 remains latest stable;
- Rojo 7.7.0 remains latest stable;
- StyLua 2.5.2 remains latest stable;
- Selene 0.31.0 remains latest stable;
- luau-lsp 1.70.0 supersedes TA-1's 1.69.0 reference and syncs upstream Luau 0.739;
- Lune 0.10.5 is adopted as dev/test-only runner.

Upstream references:

- https://github.com/rojo-rbx/rokit/releases
- https://github.com/rojo-rbx/rojo/releases
- https://github.com/JohnnyMorganz/luau-lsp/releases
- https://github.com/JohnnyMorganz/StyLua/releases
- https://github.com/Kampfkarren/selene/releases
- https://github.com/lune-org/lune/releases

## Environment tags

`DEV`, `STG`, `PROD`.

Actual Roblox universe/place IDs and commercial platform IDs are external deployment inputs. They are not invented in source and may not use fake production-looking placeholders.

**Toolchain/environment lock: PASS.**
