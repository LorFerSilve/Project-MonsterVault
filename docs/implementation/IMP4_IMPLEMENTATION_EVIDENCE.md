# IMP-4 — V1 Networking and Projection

> **Status:** Implementation complete; local and pull-request gates recorded below.
>
> **Base:** `main` after IMP-3.

## Delivered

- Three V1 transport roles wired to the Rojo `Command`, `Event`, and `UnreliableEvent` instances. Only the server's implicit `OnServerEvent` Player is treated as sender; responses use player-scoped `FireClient`.
- Static route registry for the locked public route IDs. `Session.ClientHello` and `Session.RequestResync` are active; later gameplay and cosmetic routes are reserved but have no executable schema/handler yet. Duplicate/late registration fails.
- Bounded envelope and payload validation, per-player global ingress and per-route token buckets, and a 128-entry, 120-second request replay window. Over-limit ingress is dropped before sending another result. A reused request ID with different route, payload, or expected revision is rejected. This network window is not a durable idempotency ledger.
- Server-owned handshake and `Command.Result`. Client capabilities are presentation hints only. A hello/resync observes ProfileSession readiness; it cannot create it. An unbound profile store projects Protected rather than Ready.
- Versioned session `Projection.Snapshot` and `Projection.Delta` contracts, server publisher, and client store. Stale revisions are ignored; a missing base triggers one `Session.RequestResync`. The client listener is bound before hello, and a five-second retry cadence covers load/listener races.
- Outbound unreliable cosmetic events require a registered route schema and stay under a conservative 768-byte validation bound. No cosmetic route is registered in IMP-4, so no persistent or consequential fact uses this transport.

The initial session projection includes only `status` and, when Ready, `profileRevision`. Domain data and domain-specific command schemas belong to their owning later phases. A client projection is disposable presentation state; server command admission still checks the server profile session.

## Local evidence

| Check | Result |
|---|---|
| StyLua check over src/tests/scripts | PASS |
| Selene over src/tests/scripts | PASS; 0 errors, 0 warnings |
| Rojo build and sourcemap | PASS |
| Strict luau-lsp analysis over src/tests/scripts | PASS; no type errors |
| Lune fast suite | PASS; 45/45 |
| Python checker regressions | PASS; 28/28 |
| Repository dependency and integrity scans | PASS |

The IMP-4 C0 tests cover malformed envelopes, spoofed readiness, unknown/wrong-direction routes, non-finite/oversized/cyclic payloads, rate and replay limits, immutable route binding, handshake authority, result correlation, stale/gapped projections, bounded client results, and resync.

## Pull-request CI evidence

Pending pull request and CI run.

## Engine and release boundary

The Roblox Studio MCP has no connected instance at this gate, so remote replication and live join/rejoin still require a DEV Studio playtest. `ProfileBinding.luau` remains unset without a verified DEV universe ID and API permissions. Thus profile readiness is protected by default. STG/PROD release and VS-1 remain gated by later domain implementation and engine verification.

## Follow-up

IMP-5 adds the first server-owned World Creature and streaming-safe entity projection. Its routes and projection schema must be registered through the owning contracts before use.
