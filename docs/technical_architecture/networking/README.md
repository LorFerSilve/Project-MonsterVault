# Networking, Server Authority, and Remote Contracts

> **Status:** Architecture Complete — TA-3  
> **Authority:** Client/server trust boundary, Remote transport, validation, rate/replay behavior, client prediction, physics/prompt exploit boundaries and network observability.

Authoritative specification:

- [03_networking_server_authority_remote_contracts_and_exploit_boundaries.md](03_networking_server_authority_remote_contracts_and_exploit_boundaries.md) — Architecture Complete.

Closure evidence:

- [../TA3_ROBLOX_NETWORK_SECURITY_SNAPSHOT.md](../TA3_ROBLOX_NETWORK_SECURITY_SNAPSHOT.md) — PASS;
- [../TA3_REMOTE_CONTRACT_MATRIX.md](../TA3_REMOTE_CONTRACT_MATRIX.md) — PASS;
- [../TA3_GDS_TRACEABILITY.md](../TA3_GDS_TRACEABILITY.md) — PASS;
- [../TA3_SCENARIO_VALIDATION.md](../TA3_SCENARIO_VALIDATION.md) — 140 / 140 PASS;
- [../TA3_DECISION_INDEX.md](../TA3_DECISION_INDEX.md) — accepted;
- [../TA3_CLOSURE_REPORT.md](../TA3_CLOSURE_REPORT.md) — PASS.

TA-3 locks a centrally governed asynchronous RemoteEvent protocol, server-authoritative mutation, bounded per-route validation/rate limiting, request correlation, replay/retry semantics, loss-tolerant-only UnreliableRemoteEvents, no baseline RemoteFunctions, and explicit physics/prompt/client-prediction exploit boundaries.

The next dependency is **TA-4 — Player Data, Persistence, Session Ownership, Schema Evolution, and Recovery**.
