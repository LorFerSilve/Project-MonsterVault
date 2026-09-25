# IMP-5 — Minimal Runtime World

> **Status:** COMPLETE — local and pull-request CI PASS (2026-09-25).
>
> **Base:** `main` after IMP-4.
> **Review:** [IMP-5 PR #42](https://github.com/LorFerSilve/Project-MonsterVault/pull/42).
> **Traceability:** GDS-4/5/9; TA-5/6/9/12/14/15/17.

## Delivered

- One Studio-authored fixture clearing with ground, player spawn, and a validated creature anchor. The place structure is reproducible from `default.project.json`.
- A server-owned creature record with one reserved/active population slot, a unique session-local `CreatureInstanceId`, fixed fixture species and rarity, monotonic lifetime, bounded materialization retries, and idempotent terminal cleanup. Technical retries keep the same reservation and identity.
- A central one-second scheduler with a generation guard. No per-creature Heartbeat or task is created; a callback after stop cannot spawn or revive a creature.
- A coarse server spatial bucket and exact server distance check for future interaction admission. The IMP-4 `Interaction.PrimaryInteract` route remains unavailable until its owning gameplay phase supplies the full trust and profile-readiness path.
- A disposable, `Atomic` Workspace model with a public, validated attribute set. A client observer rebuilds presentation from tagged models after stream-in and treats stream-out as loss of a local model reference, not as server-side termination. The cache rejects stale revisions and is bounded to 256 entries.
- The client entrypoint is emitted as one `LocalScript` under `StarterPlayerScripts`. Studio had shown that a `Script` with client `RunContext` there ran twice; the correction produced one client bootstrap in the playtest.

## Local verification

| Check | Result |
|---|---|
| StyLua check over changed Luau files | PASS |
| Selene over `src tests scripts` | PASS; 0 errors, 0 warnings |
| Rojo build and sourcemap | PASS |
| Strict luau-lsp analysis over `src tests scripts` | PASS; 0 type errors |
| Lune fast suite | PASS; 57/57 |
| Python checker regressions | PASS; 28/28 |
| Repository dependency and integrity checks | PASS |
| Studio MCP edit-mode source and fixture inspection | PASS |
| Studio single-client playtest | PASS; one server creature, one client bootstrap, no world error |
| Studio streaming round trip | PASS; at 5,000 studs the client streamed out the model while the server retained it; on return the client saw the same ID and revision 2 |

The new C0/C1 tests cover the single-slot budget, exact interaction distance, stale expiry, same-ID technical retry, failed-projection cleanup, exhausted retry cleanup, scheduler stop generation, stream-out/stream-in recovery, stale client revisions, public attribute validation, and bounded client cache.

## Pull-request CI evidence

`CI / static-build` passed for implementation commit `13d7165` on [GitHub Actions run 36136427865](https://github.com/LorFerSilve/Project-MonsterVault/actions/runs/36136427865). The final evidence/status update is checked on its own PR head before merging.

## Engine and release boundary

Studio verification used the open `project_monstervault` place in local Play mode. The fixture is a visible implementation placeholder, not final creature art. No capture, ownership, DataStore readiness, or production release is enabled. `ProfileBinding.luau` remains unset pending verified DEV environment/API permissions. Multi-client and live-server validation remain downstream TA-15 gates.

## Follow-up

IMP-6 owns capture state, injected server RNG, complete Variant identity, custody, and durable ownership finalization. It must extend the world runtime through explicit domain contracts without treating the model or client cache as authority.
