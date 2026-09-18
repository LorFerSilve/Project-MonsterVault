# TA-6 Roblox Runtime and Lifecycle Platform Snapshot

> **Review date:** 2026-09-18  
> **Status:** PASS  
> **Purpose:** Record current Roblox runtime, character, streaming, network-ownership, and cleanup behavior used to validate TA-6.

## 1. Player Character Lifecycle

Official source:

https://create.roblox.com/docs/reference/engine/classes/Player

Current platform behavior reviewed:

- Player exposes `CharacterAdded(character)`;
- Player exposes `CharacterRemoving(character)`;
- a Player may therefore outlive multiple Character models during one server session.

TA-6 consequence:

> Player Session and Character Presence are separate lifecycle objects. Character removal/reset/death never implies persistent profile or secured-ownership destruction.

## 2. Player Character Loading

Official source:

https://create.roblox.com/docs/reference/engine/classes/Players

Current platform behavior supports explicit character lifecycle control, including `Players.CharacterAutoLoads` and `Player:LoadCharacterAsync()`.

TA-6 consequence:

> MonsterVault treats safe arrival/recovery materialization as an explicit server lifecycle step after trusted persistence readiness rather than assuming Character existence grants gameplay readiness.

## 3. Workspace Instance Streaming

Official sources:

https://create.roblox.com/docs/workspace/streaming  
https://create.roblox.com/docs/reference/engine/classes/Workspace

Current platform behavior reviewed:

- Workspace descendants can stream into and out of clients when `StreamingEnabled` is enabled;
- streaming eligibility depends on position/device/performance and Workspace configuration;
- client absence of a Workspace descendant therefore does not imply server destruction;
- `StreamingMinRadius`, `StreamingTargetRadius`, and integrity behavior affect client availability.

TA-6 consequence:

> Authoritative server runtime records cannot be represented solely by whether a client currently has a Model/Part in its local DataModel.

## 4. Model Streaming Modes

Official sources:

https://create.roblox.com/docs/workspace/streaming  
https://create.roblox.com/docs/reference/engine/enums/ModelStreamingMode

Current modes include:

- Default;
- Atomic;
- Persistent;
- PersistentPerPlayer.

Current guidance states:

- Atomic models stream as a coherent model unit;
- Persistent models do not normally stream out;
- Persistent models are intended for rare cases;
- excessive Persistent use can negatively affect performance.

TA-6 consequence:

> Atomic/Persistent choices are presentation/streaming policy, never semantic entity authority. Persistent models are exceptional, not the default way to keep runtime entities "alive."

## 5. Network Ownership

Official source:

https://create.roblox.com/docs/physics/network-ownership

Current platform behavior:

- Roblox distributes physics simulation between server and clients;
- nearby clients may automatically gain network ownership over unanchored assemblies;
- anchored assemblies remain server-owned;
- server code can explicitly set network ownership where appropriate.

Security consequence:

- Roblox states that client-owned physics cannot be fully verified by the server;
- clients can manipulate client-owned unanchored assemblies.

TA-6 consequence:

> Network owner, runtime owner and persistent player owner are different concepts. Network ownership never grants gameplay/collection authority.

## 6. Physics Security / Touched

Official source:

https://create.roblox.com/docs/scripting/security/network-ownership

Current guidance warns that a client with network ownership can manipulate:

- assembly position/rotation;
- velocity;
- collisions;
- Touched behavior.

TA-6 consequence:

> Touched or raw physics state cannot alone finalize capture, reward, ownership, Secure Point delivery or another critical outcome.

## 7. Client/Server Boundary for World Interactions

Official source:

https://create.roblox.com/docs/scripting/security/client-server-boundary

Current guidance requires server validation for client-triggered world interaction, including:

- whether the player character exists;
- spatial/context validity;
- expected object class/location;
- rate limiting.

It also warns that unanchored interaction parents can be manipulated through network ownership.

TA-6 consequence:

> Interaction targets resolve through stable IDs and authoritative runtime records; critical interactables prefer server-controlled/anchored roots where practical.

## 8. Runtime Cleanup and Memory

Official source:

https://create.roblox.com/docs/performance-optimization/improve

Current performance guidance emphasizes:

- disconnecting event connections that are no longer needed;
- destroying runtime Instances/characters when their lifetime ends;
- removing entries from long-lived tables;
- avoiding resource accumulation across player joins/leaves.

TA-6 consequence:

> Every runtime entity/character projection has one cleanup owner that disconnects connections, cancels tasks, destroys/detaches Instances and deregisters long-lived table entries.

## 9. Instance Destruction Semantics

Roblox runtime cleanup uses `Instance:Destroy()` for Instance-owned resources and object removal.

TA-6 consequence:

> Projection destruction is explicit, but projection destruction remains distinct from semantic entity destruction and from persistent Release/ownership mutation.

## 10. Streaming and Client References

Roblox streaming documentation requires client code to tolerate instances appearing/disappearing based on streaming state.

TA-6 consequence:

- client runtime caches are disposable;
- presentation reacquires projections by stable IDs/events;
- stream-out cannot be interpreted as despawn, capture failure or lost ownership.

## 11. Platform Fit

The current platform supports TA-6's main decisions:

- Player Session != Character Presence;
- server entity record != Workspace Model;
- client Workspace visibility != entity lifetime;
- server validation remains required around physics/interactions;
- Persistent streaming is exceptional;
- cleanup/lifecycle ownership is necessary for memory/performance safety.

## Verdict

**TA-6 ROBLOX RUNTIME/LIFECYCLE PLATFORM SNAPSHOT: PASS.**
