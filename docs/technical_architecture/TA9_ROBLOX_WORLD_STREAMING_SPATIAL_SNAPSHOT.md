# TA-9 Roblox World, Streaming, Spatial Query, and Security Snapshot

> **Review date:** 2026-09-22  
> **Status:** PASS  
> **Purpose:** Record current Roblox platform behavior relevant to TA-9 instance streaming, model streaming, target-area preparation, world spatial queries, server/client trust and scheduler performance.

## 1. Workspace Instance Streaming

Official source:

https://create.roblox.com/docs/reference/engine/classes/Workspace

Current behavior reviewed:

- Workspace.StreamingEnabled controls in-experience instance streaming;
- StreamingEnabled is configured on Workspace rather than dynamically by ordinary gameplay scripts;
- Workspace exposes StreamingMinRadius, StreamingTargetRadius and StreamingIntegrityMode;
- current Creator Hub guidance identifies instance streaming as an important client-memory/load-time mechanism for larger worlds.

TA-9 consequence:

> MonsterVault enables instance streaming for the primary gameplay place and treats client Workspace residency as transient presentation state. Exact radii and integrity configuration are measured and locked by TA-14/17.

## 2. Streaming Radius Semantics

Official source:

https://create.roblox.com/docs/reference/engine/classes/Workspace

Current behavior reviewed:

- StreamingMinRadius controls the high-priority streamed area around a player's replication focus;
- StreamingTargetRadius controls the target maximum streamed distance;
- the engine may retain previously streamed content beyond the target when memory permits;
- increasing minimum radius consumes more client memory/server bandwidth.

TA-9 consequence:

> Streaming radius values are performance configuration, not semantic range gates. World access, spawn existence and interaction permission never derive from whether an Instance happens to be streamed.

## 3. ModelStreamingMode

Official source:

https://create.roblox.com/docs/reference/engine/enums/ModelStreamingMode

Current enum includes:

- Default;
- Atomic;
- Persistent;
- PersistentPerPlayer.

Model documentation also exposes AddPersistentPlayer/RemovePersistentPlayer for PersistentPerPlayer models.

TA-9 consequence:

> Default is the ordinary baseline. Atomic is permitted for self-contained interaction models. Persistent/PersistentPerPlayer are exceptional tools with measured memory/network cost and never confer gameplay authority.

## 4. Player RequestStreamAroundAsync

Official source:

https://create.roblox.com/docs/reference/engine/classes/Player

Current behavior reviewed:

- Player:RequestStreamAroundAsync(position, timeOut) requests streaming around a world position;
- the call yields while the engine attempts the request;
- a timeout bounds the attempt.

TA-9 consequence:

> Fast-travel/recovery presentation may pre-request the destination area, but this request is best-effort readiness support only. Authorization and world-state mutation complete from server-owned state.

## 5. WorldRoot Spatial Queries

Official source:

https://create.roblox.com/docs/reference/engine/classes/WorldRoot

Current relevant APIs include:

- GetPartBoundsInBox;
- GetPartBoundsInRadius;
- GetPartsInPart;
- Raycast;
- Spherecast;
- Shapecast.

The legacy Region3-family search methods are documented as deprecated.

TA-9 consequence:

> TA-9 uses pre-indexed candidates first and only then bounded localized WorldRoot queries for placement/hazard/geometry validation. It does not build new architecture around deprecated Region3 searches or full-world per-frame scans.

## 6. High-Frequency Script Cost

Official source:

https://create.roblox.com/docs/performance-optimization/improve

Current Creator Hub guidance identifies expensive work attached to high-frequency RunService events as a common performance problem.

TA-9 consequence:

> Ordinary spawn scheduling is staggered and deadline/queue based. MonsterVault does not create one Heartbeat loop per spawn point or one per creature.

## 7. Instance Streaming Performance Guidance

Official sources:

https://create.roblox.com/docs/performance-optimization/improve

https://create.roblox.com/docs/workspace/streaming

Current guidance:

- instance streaming can reduce client memory use and join-time pressure;
- excessive Persistent streaming reduces those benefits;
- client scripts must tolerate relevant world content not being resident yet.

TA-9 consequence:

> Streaming safety is an architectural requirement from the beginning rather than a late optimization retrofit.

## 8. Client/Server Security Boundary

Official sources:

https://create.roblox.com/docs/scripting/security/client-server-boundary

https://create.roblox.com/docs/scripting/security/security-tactics

Current Roblox security guidance:

- client-triggered actions must be validated server-side;
- context/permission validation is required for actions affecting state/progression/other players;
- the client must be treated as untrusted.

TA-9 consequence:

> Client position claims, spawn targets, travel destinations, landmark completion, objective completion and region eligibility are never accepted without server reconstruction/validation.

## 9. Replicated Information Is Discoverable

Official source:

https://create.roblox.com/docs/scripting/security/access-control

Current guidance emphasizes that information replicated to clients should not be treated as confidential.

TA-9 consequence:

> Hidden spawn weights, private reward tables, anti-abuse thresholds and private event logic remain server-side. Replicated tags/attributes are disclosure-safe identifiers/presentation metadata only.

## 10. Streaming and Remote Timing

Official source:

https://create.roblox.com/docs/reference/engine/classes/RemoteFunction/InvokeClient

Roblox documents that, with instance streaming, server-created BaseParts/Models are not guaranteed to already exist on a client when a remote interaction returns.

TA-9 consequence:

> Protocol success and Workspace projection arrival are separate. Clients reconcile semantic server state independently from the exact frame in which the corresponding model streams in.

## 11. Platform Assumptions Not Locked in TA-9

TA-9 intentionally does not hard-code as semantic rules:

- current default StreamingMinRadius;
- current default StreamingTargetRadius;
- one specific StreamingIntegrityMode;
- one universal ModelStreamingMode for all content;
- one spatial-query frequency;
- one population count formula.

These are measurable TA-14/17 configuration choices and may evolve with platform guidance without changing TA-9's authority/fairness contracts.

## Verdict

**TA-9 ROBLOX WORLD / STREAMING / SPATIAL / SECURITY PLATFORM SNAPSHOT: PASS.**
