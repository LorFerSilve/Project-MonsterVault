# TA-3 Roblox Networking and Security Snapshot

> **Review date:** 2026-09-18  
> **Status:** PASS  
> **Purpose:** Record the current Roblox networking/security platform guidance used to validate TA-3.  
> **Note:** This is dated external-platform evidence. TA-15/TA-17 and launch readiness must re-check current Roblox behavior if the platform changes.

## 1. Remote Events and Callbacks

Official source:

https://create.roblox.com/docs/scripting/events/remote

Observed current platform model:

- `RemoteEvent` provides asynchronous, one-way communication across the client/server boundary;
- `UnreliableRemoteEvent` provides one-way communication where ordering/reliability can be sacrificed for non-critical continuously changing data;
- `RemoteFunction` provides two-way request/response communication and yields while waiting;
- clients do not directly communicate with other clients; server relay is required.

TA-3 consequence:

- reliable RemoteEvents are the baseline command/result/event transport;
- UnreliableRemoteEvents are limited to semantically loss-tolerant presentation data;
- RemoteFunctions are unnecessary for the baseline asynchronous protocol;
- all client-to-client-style social communication remains server-gated.

## 2. Securing the Client-Server Boundary

Official source:

https://create.roblox.com/docs/scripting/security/client-server-boundary

Current guidance explicitly requires server-side validation of all client input, including:

- context/permission;
- type/structure;
- values/ranges;
- rate/frequency;
- expected Instance class/location when Instances are accepted.

The documentation also warns against remotes that allow clients to choose arbitrary DataModel paths/Instances for deletion or modification.

TA-3 consequence:

> Every MonsterVault route has a bounded schema plus server-owned context/permission validation; client-provided arbitrary Instance/path mutation is prohibited.

## 3. Never Trust the Client / Server Authority

Official source:

https://create.roblox.com/docs/scripting/security/security-tactics

Current official guidance states that an exploiter can control local code/state and fire or invoke client-accessible remotes with arbitrary arguments/frequency.

It recommends server authority for:

- simulation/game rules;
- progression;
- critical decisions;
- validation of client requests.

TA-3 consequence:

> Client messages express intent only. Final ownership, currency, progression, capture, trade, event, commercial and safety outcomes remain server-authoritative.

## 4. Replicated Confidentiality

Official source:

https://create.roblox.com/docs/scripting/security/access-control

Current official guidance warns that exploiters can inspect replicated content and decompile replicated LocalScripts/ModuleScripts.

TA-3 consequence:

- route names and shared schemas are assumed public;
- no security-by-obscurity;
- hidden/server-sensitive logic stays server-only;
- client does not receive unnecessary hidden state.

## 5. Physics / Network Ownership

Official source:

https://create.roblox.com/docs/scripting/security/network-ownership

Current platform behavior allows clients to receive network ownership of unanchored assemblies/characters for simulation responsiveness.

Security consequence:

- client physics/position cannot be treated as absolute trustworthy proof;
- critical position-dependent actions need server-side validation/tolerance;
- persistent value cannot be awarded merely because client-controlled physics claims a condition occurred.

TA-3 consequence:

> Capture/interaction/extraction/world systems must validate position/context against server-owned state and later TA-6/TA-9 physics rules.

## 6. ProximityPrompt / ClickDetector / DragDetector

Official source:

https://create.roblox.com/docs/scripting/security/client-server-boundary

Current guidance treats these as client-triggerable security boundaries as well.

Notable guidance includes:

- local properties such as Enabled/distance presentation are not sufficient authorization;
- only some prompt events have built-in server distance checks;
- clients can manipulate timing/interaction conditions;
- rate limiting and server-side context checks remain necessary.

TA-3 consequence:

> MonsterVault maps these interactions into the same server-authoritative validation model as remote commands.

## 7. RemoteFunction

Official API source:

https://create.roblox.com/docs/reference/engine/classes/RemoteFunction

Current API model:

- `InvokeServer` and `InvokeClient` are yielding calls;
- callbacks return values synchronously to the caller.

TA-3 consequence:

> Baseline MonsterVault avoids RemoteFunctions. In particular, the server never makes correctness depend on `InvokeClient`.

## 8. Network Performance

Official source:

https://create.roblox.com/docs/performance-optimization/improve

Current guidance identifies these common networking problems:

- excessive remote traffic;
- sending data every frame unnecessarily;
- sending on raw input without throttling;
- sending more data than necessary;
- creating/replicating large instance hierarchies.

Recommended direction includes:

- lower-frequency necessary data only;
- send state changes rather than redundant full state;
- create purely visual effects locally when the server does not need the visual instances.

TA-3 consequence:

- bounded per-route traffic;
- change/event-driven projections;
- no per-frame reliable remote baseline;
- cosmetic local effects where possible;
- numeric budgets deferred to TA-14.

## 9. Network Measurement

Official source:

https://create.roblox.com/docs/performance-optimization/microprofiler/network

Roblox MicroProfiler can inspect network send/receive behavior and packet activity.

TA-3 consequence:

> Route/result observability and TA-14/TA-15 representative network profiling are required downstream.

## 10. Data Ping / Reliable Remote Behavior

Official source:

https://create.roblox.com/docs/performance-optimization/identify

Current guidance describes data ping in terms comparable to reliable RemoteEvent round trips and notes that excessive replication queueing increases latency.

TA-3 consequence:

- asynchronous request/result patterns should be latency-tolerant;
- timeout cannot be interpreted as authoritative failure for irreversible operations;
- traffic volume/frequency is a first-class performance concern.

## 11. Snapshot Conclusions

The current Roblox platform guidance strongly supports TA-3's core decisions:

- never trust the client;
- validate every client-triggered action server-side;
- keep persistent/competitive/commercial value server-authoritative;
- treat replicated code/data as inspectable;
- rate-limit client-triggered work;
- keep payloads bounded;
- revalidate prompt/physics interactions;
- use reliable RemoteEvents for important async messages;
- use UnreliableRemoteEvents only for loss-tolerant data;
- avoid synchronous client dependency;
- measure and budget network traffic.

## Verdict

**TA-3 ROBLOX NETWORKING/SECURITY SNAPSHOT: PASS.**
