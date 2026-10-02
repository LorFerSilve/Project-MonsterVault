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
- `WorldActionUseCase.luau` — AD-255 bounded spatial world evidence through the existing P2 writer;
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

AD-255 binds `domains/world/{WorldRegistry,WorldDefinitions,WorldProgressionService}` to the existing `WorldService`. Bootstrap validates registries during composition construction, builds the immutable authored spatial index and starts world before profiles; capture depends on both. ProfileRuntimeService prepares/validates World V1, injects the actual mastery reader into progression and exposes WorldActionUseCase for P2/recovery. CaptureFinalizationUseCase receives a same-commit secured-evidence callback. Networking dispatches existing interaction IDs and Class A world resync through WorldRuntimeService. No domain imports another domain; current fixture spawn/variant/production behavior is retained.

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

AD-253 binds progression.ProgressionService through application.ProgressionPurchaseUseCase, injecting EnergyService, VaultService and the existing server boundary. ProgressionProjection builds bounded owner readback; bootstrap composes these services. Client ProgressionController/ProgressionRuntimeService consume ProgressionProjectionV1 through the existing gateway and require explicit confirmation. Cross-domain imports/mutations remain in application orchestration; no new runtime root, package or transport is added.

AD-254 injects VaultProductionService into that same application transaction to settle old capabilities before a tier effect. CaptureRuntimeService receives the progression server chance reader through bootstrap injection; CaptureService fixes it at admission. Access prerequisites consume an optional injected TA-9 mastery reader, never a cross-domain import or client field. Shipped bootstrap leaves that later owner unbound and fails new access closed. Numeric selected catalog pages retain the existing protocol/package graph. See the [full IMP-9 audit](../implementation/IMP9_GATE_AUDIT.md).

AD-256 adds domains/world/WorldAuthoringIndex to the existing world owner. WorldRuntime snapshots canonical definitions/native tags, exposes validated extraction destinations to CaptureRuntime and consumes the injected WorldActionUseCase access reader. NetworkingRuntime binds/unbinds existing owner Vault readback to the validated terminal. Domains gain no cross-domain import or transport/runtime root. The retained bounded encounter owner remains the ordinary spawn owner until region-scoped scheduling.

AD-257 adds the pure same-domain SpawnPlan builder and extends the existing WorldService reservation/lifecycle owner to eight bounded authored buckets. WorldRuntime alone binds native placement, current Players/Ready/access presence, injected clock/RNG and one central pulse; capture still controls custody and exact P2 retirement. No new wire route, domain import or persistence owner is introduced. The reused DEV projection reads the shared native MaterialPalette; Energy Core values remain unchanged. Ordinary World Cycle and later world action owners remain open.

AD-258 adds the pure same-domain WorldCycle sampler. WorldRegistry validates/freeze-copies its definition/bindings; WorldRuntime injects absolute Unix time and publishes bounded readback on its existing pulse. WorldService samples the injected context evaluator only for new reservations and pins its immutable result. Existing lifecycle/capture/P2/profile ownership stays intact; no additional scheduler, wire route, cross-domain import or persisted schema is added. See [cycle evidence](../implementation/IMP10_WORLD_CYCLE_EVIDENCE.md).

AD-259 adds same-domain WorldTravelService: a bounded P0 presence/transition owner invoked by WorldRuntime's existing pulse. WorldRuntime resolves native authored source/arrival/recovery geometry and access through the existing WorldActionUseCase/WorldProgression owner. CaptureRuntime injects its private character generation, acquisition predicate and recovery interruption, retaining TA-7 ownership; no cross-domain domain import or extra loop is added. WorldActionUseCase writes bounded discovery facts through existing P2 and owner resync. Networking binds the reserved travel route; native prompts delegate to the same policy. See [travel evidence](../implementation/IMP10_TRAVEL_RECOVERY_EVIDENCE.md).
