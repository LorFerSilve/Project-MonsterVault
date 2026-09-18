# TA-7 Roblox Capture, Randomness, and Exit-Signal Snapshot

> **Review date:** 2026-09-18  
> **Status:** PASS  
> **Purpose:** Record current Roblox platform behavior relevant to server-owned capture resolution, randomness, client trust, physics, prompts, and disconnect classification.

## 1. Random datatype

Official source:

https://create.roblox.com/docs/reference/engine/datatypes/Random

Current behavior reviewed:

- `Random.new()` creates a pseudorandom generator;
- without a provided seed, Roblox uses an internal entropy source;
- an explicit integer seed can be supplied for reproducible sequences;
- `NextInteger()` and `NextNumber()` provide uniform pseudorandom draws;
- `Clone()` copies generator state.

TA-7 consequence:

> Production capture/variant outcome generation uses a server-owned RNG abstraction backed by Roblox Random with no client-chosen seed. Deterministic seeded/fake generators are reserved for tests and explicitly controlled simulation.

## 2. Server authority / client trust

Official sources:

https://create.roblox.com/docs/scripting/security/security-tactics  
https://create.roblox.com/docs/scripting/security/client-server-boundary

Current Roblox security guidance states that clients can:

- fabricate remote arguments;
- fire remotes at arbitrary rates;
- manipulate local DataModel state;
- control their own character/nearby network-owned physics;
- trigger client-facing interactions outside intended local constraints.

The guidance states critical logic, progression and rewards must be server-validated/server-authoritative.

TA-7 consequence:

> Client capture input is evidence of intent/action only. Capture Success, Mutation/Trait outcome, Provisional Capture, Secure Point completion and ownership finalization are server decisions.

## 3. ProximityPrompt / interaction triggers

Official source:

https://create.roblox.com/docs/scripting/security/client-server-boundary

Current guidance documents that:

- prompt events can be triggered unexpectedly by exploiters;
- prompt properties such as Enabled/range can be changed locally;
- hold timing can be manipulated;
- critical actions require server-side character/distance/state/rate checks.

TA-7 consequence:

> Secure Point and capture interactions never finalize from prompt/click/touch occurrence alone.

## 4. Physics network ownership

Official source:

https://create.roblox.com/docs/scripting/security/network-ownership

Current guidance states clients with network ownership can manipulate unanchored assembly physics.

TA-7 consequence:

> Carrier/creature physics, Touched and apparent proximity are not sufficient ownership/extraction evidence. Server capture/custody/context state remains authoritative.

## 5. PlayerRemoving exit reason

Official sources:

https://create.roblox.com/docs/reference/engine/classes/Players  
https://create.roblox.com/docs/reference/engine/enums/PlayerExitReason

Current behavior reviewed:

- `Players.PlayerRemoving(player, reason)` supplies `Enum.PlayerExitReason`;
- currently documented enum values are:
  - Unknown;
  - PlatformKick;
  - CreatorKick.

The enum does not currently expose a trusted distinct value that proves "user intentionally chose Leave Experience" versus "connection disappeared" for every ordinary exit.

TA-7 consequence:

> MonsterVault can end custody immediately for explicit server-known voluntary-exit flows or server kick paths, but an ambiguous Unknown exit is treated conservatively as an unexpected disconnect for bounded same-server Transport Grace. Grace itself grants no ownership and never crosses servers.

## 6. Remote transport fit

Official source:

https://create.roblox.com/docs/scripting/events/remote

Roblox RemoteEvents provide asynchronous one-way client/server messaging.

TA-7 consequence:

> Capture commands/results fit TA-3's reliable asynchronous request/result model; no synchronous client callback is required for capture correctness.

## 7. Platform Fit

The current Roblox platform supports TA-7's architecture:

- server-owned RNG;
- server-owned critical outcome logic;
- bounded client input validation;
- server-side prompt/physics revalidation;
- explicit PlayerRemoving lifecycle;
- conservative disconnect handling where exit reason is ambiguous.

## Verdict

**TA-7 ROBLOX CAPTURE/RANDOMNESS PLATFORM SNAPSHOT: PASS.**
