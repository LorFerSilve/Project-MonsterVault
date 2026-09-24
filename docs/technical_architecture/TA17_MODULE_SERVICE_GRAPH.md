# TA-17 Module and Service Graph

> **Status:** PASS
> **Date:** 2026-09-24

## 1. Locked physical layers

```text
src/shared/{contracts,config,types,util}
src/server/{bootstrap,application,domains,infrastructure,adapters}
src/client/{bootstrap,networking,store,input,controllers,features,presentation}
```

No new first-party runtime root may be introduced without TA-2/TA-17 change control.

## 2. Server composition

Required baseline modules/services by final implementation:

### bootstrap

- `ServerMain.server.luau` — only executable server entrypoint;
- `ServerComposition.luau` — constructs dependency graph;
- `StartupValidator.luau` — validates config/registry/route uniqueness;
- `ShutdownCoordinator.luau` — closes admission and coordinates final drains.

### application

- `SessionCoordinator.luau`;
- `CaptureFinalizationUseCase.luau`;
- `ProductionClaimUseCase.luau`;
- `ProgressionPurchaseUseCase.luau`;
- `EventRewardUseCase.luau`;
- `TradeCommitUseCase.luau`;
- `CommerceReconciliationUseCase.luau`.

Application modules sequence domains; they do not own domain state.

### domains

Domain service namespaces:

- players;
- creatures;
- capture;
- vault;
- economy;
- progression;
- world;
- social;
- events;
- trading;
- monetization;
- safety.

Each domain exposes one narrow public API module and hides internals below its own namespace.

### infrastructure

- persistence;
- networking;
- telemetry;
- live_config;
- clock;
- rng;
- diagnostics;
- performance.

Infrastructure implements technical interfaces; it does not choose gameplay outcomes.

### adapters

Roblox-specific adapters for:

- DataStoreService;
- MemoryStoreService;
- MessagingService;
- MarketplaceService;
- AnalyticsService;
- ConfigService;
- Players/RunService/Workspace/input/platform APIs.

## 3. Client composition

### bootstrap

- `ClientMain.client.luau`;
- `ClientComposition.luau`.

### networking

- `ClientTransport.luau`;
- `ProjectionReceiver.luau`.

### store

- `ProjectionStore.luau`;
- revision-aware domain slices.

### input

- `InputRouter.luau`;
- `InputContextStack.luau`;
- `InputHandoffGuard.luau`.

### controllers

- session;
- world;
- capture;
- vault;
- social;
- events;
- trade;
- commerce.

### presentation

- modal/focus;
- notifications;
- UI view models;
- camera;
- audio/captions;
- accessibility/preferences.

## 4. Shared

Allowed:

- protocol/route/result enums;
- public IDs/types;
- pure validators/transforms that expose no secret authority;
- public immutable config;
- serializable projection types.

Forbidden:

- server secrets;
- DataStore adapters;
- authoritative reward/RNG resolution;
- purchase/trade commit logic;
- server-only anti-abuse thresholds whose disclosure materially increases exploitability.

## 5. Dependency graph

```text
ServerMain
  -> ServerComposition
      -> application coordinators
          -> domain public APIs
          -> technical interfaces
      -> infrastructure/adapters supplied to interfaces

domain -> shared
domain -> same-domain internals
domain -> other domain public contract ONLY when TA-2 explicitly allows
infrastructure -> shared + technical interfaces
infrastructure -X-> domain mutation internals

ClientMain
  -> ClientComposition
      -> ClientTransport
      -> ProjectionStore
      -> InputRouter
      -> controllers
      -> presentation

client -> shared
client -X-> server
shared -X-> server/client
```

Cross-domain mutations always move up to application orchestration rather than creating a dependency cycle.

## 6. First slice exact module minimum

VS-1 may not begin capture gameplay until these exist:

- shared protocol/route/result/domain-ID contracts;
- test runner;
- server/client composition roots;
- diagnostics/clock/RNG interfaces;
- persistence fake + Roblox repository interface;
- profile/session service;
- server transport gateway;
- client transport/projection store;
- runtime creature service;
- world fixture/spawn service;
- capture service;
- capture finalization use case;
- minimal capture client controller/presentation.

**Module/service graph result: PASS.**
