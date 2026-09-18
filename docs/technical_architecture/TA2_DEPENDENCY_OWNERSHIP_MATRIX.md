# TA-2 Dependency and Ownership Matrix

> **Phase:** TA-2 — Repository Layout, Module Boundaries, Dependency Direction, and Bootstrapping  
> **Status:** PASS  
> **Purpose:** Make permitted imports, mutation ownership, composition boundaries, and bootstrap responsibilities explicit before any source scaffold is created.

## 1. Layer Import Matrix

Legend:

- **YES** — baseline permitted;
- **CONTRACT** — permitted only through a public/narrow contract;
- **NO** — forbidden;
- **BOOT** — composition/bootstrap-only.

| Importer ↓ / Target → | shared | server domain same | server domain other | application | infrastructure | adapters | bootstrap | client |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| server bootstrap | YES | BOOT | BOOT | BOOT | BOOT | BOOT | — | NO |
| server application | YES | CONTRACT | CONTRACT | YES | CONTRACT | CONTRACT | NO | NO |
| server domain | YES | YES | CONTRACT | NO | CONTRACT* | CONTRACT* | NO | NO |
| server infrastructure | YES | NO | NO | NO | YES | CONTRACT | NO | NO |
| server adapter | YES | CONTRACT* | NO | NO | CONTRACT | YES | NO | NO |
| client bootstrap | YES | NO | NO | NO | NO | NO | — | YES |
| client controller | YES | NO | NO | NO | NO | client adapters/contracts | NO | YES |
| client feature | YES | NO | NO | NO | NO | client adapters/contracts | NO | YES |
| client presentation | YES | NO | NO | NO | NO | presentation adapters | NO | YES |
| shared | YES | NO | NO | NO | NO | NO | NO | NO |

`CONTRACT*` means domain code may depend on an abstract technical interface supplied by infrastructure/adapters, but must not import arbitrary concrete engine mechanisms directly.

## 2. Mutation Ownership Matrix

| State/value family | Authoritative mutation owner class | Non-owner access |
|---|---|---|
| Creature Instance ownership | server creature/capture/trade transaction owners | queries/projections only |
| Energy/progression | server economy/progression domain | queries/projections only |
| Vault capacity/production | server Vault domain | application coordination |
| World Spawn Context | server world/spawn owner | read projections/events |
| Party/social state | server social domain | explicit public commands/queries |
| Event runtime state | server event domain | explicit contribution/reward contracts |
| Trade session | server trading domain | exact public trade commands/queries |
| Commercial entitlement | server monetization/entitlement owner | read projection/client display |
| Player persistent profile | TA-4 persistence owner + domain-owned field contracts | no direct arbitrary writes |
| Client UI state | owning client presentation/controller | no server dependency on it |
| Input state | client input layer | semantic intent consumers |
| Analytics event delivery | TA-13 telemetry infrastructure | domains emit structured facts through contract |

## 3. Cross-Domain Orchestration Matrix

| Use case | Participating domains | Coordinator class |
|---|---|---|
| Secure capture | capture, creatures, capacity/persistence | server application use case |
| Production claim | Vault/production, Energy, persistence | server application/use-case boundary |
| Region progression purchase | progression, Energy, access, persistence | server application/use-case boundary |
| Event reward | events, Energy and/or capture opportunity, persistence | server application/event reward coordinator |
| Trade commit | trading, creatures, capacity, persistence | server application transaction coordinator |
| Commercial capacity grant | monetization, capacity, persistence | server application reconciliation coordinator |
| Protected load readiness | persistence, player/runtime domains | session/application coordinator |

No participant is permitted to mutate another participant's private state directly.

## 4. Roblox DataModel Ownership Matrix

| DataModel location | Filesystem/runtime owner | Rule |
|---|---|---|
| ReplicatedStorage/MonsterVault/Shared | `src/shared` | replicated public code/data only |
| ReplicatedStorage/MonsterVault/Remotes | TA-3 runtime/network owner | centrally governed, not feature-created ad hoc |
| ServerScriptService/MonsterVaultServer | `src/server` | authoritative non-replicated code |
| StarterPlayerScripts/MonsterVaultClient | `src/client` | client composition and presentation |
| ServerStorage/MonsterVault | TA-5/TA-9 if justified | server-only content/assets, not generic dumping ground |
| Workspace | TA-6/TA-9 runtime/world owners | world/runtime Instances, not code authority |
| StarterGui | TA-12 | UI templates/runtime strategy |
| SoundService/Lighting/etc. | TA-12/TA-9 as appropriate | controlled presentation/world adapters |

## 5. Bootstrap Ownership

| Lifecycle responsibility | Owner |
|---|---|
| Construct component graph | server/client composition root |
| Validate dependency/config graph | bootstrap |
| Create persistence/session substrate | TA-4 infrastructure under server bootstrap |
| Construct domain services | server bootstrap |
| Construct application coordinators | server bootstrap |
| Bind remotes | TA-3 networking owner after domain validation |
| Start background loops | owning domain/infrastructure after dependencies ready |
| Mark server ready | server bootstrap/session infrastructure |
| Construct client controllers | client bootstrap |
| Bind semantic input | client bootstrap/input layer |
| Subscribe to server projections | client networking/controller layer |
| Mark client ready | client bootstrap |
| Stop accepting new irreversible operations on shutdown | server bootstrap + owning transaction domains |
| Final persistence flush/reconciliation | TA-4/owning transaction domains |

## 6. Forbidden Structural Patterns

The following block Architecture Complete or implementation review:

- domain internal imports from another domain's internal folder;
- server code importing client code;
- shared code importing server/client;
- infrastructure importing gameplay domains;
- UI modules performing direct DataStore/platform mutation;
- arbitrary domain modules creating RemoteEvents;
- runtime feature auto-start on `require`;
- `_G` or global `shared` table as gameplay database;
- hidden service locator available to all modules;
- direct platform service calls scattered through domain leaf modules;
- multiple independent server entrypoints auto-starting feature systems;
- cyclic domain mutation authority;
- production modules depending on tests;
- mutable config used as player state;
- Workspace/ReplicatedStorage ValueObjects used as persistent authority by convenience.

## 7. Dependency Cycle Resolution

When a dependency cycle appears, resolve in this order:

1. check whether one direction violates ownership and remove it;
2. move multi-domain sequencing into `application`;
3. extract only genuinely shared type/contract to `shared`;
4. introduce a narrow query/command interface;
5. use a completed-fact event only when eventual notification is semantically safe;
6. reconsider domain ownership if none of the above is coherent.

Do **not** solve cycles with:

- lazy require hacks;
- global registries;
- string-based module lookup;
- duplicated state.

## 8. Verdict

**TA-2 DEPENDENCY AND OWNERSHIP MATRIX: PASS.**

The future module graph has explicit allowed directions, mutation owners, Roblox DataModel owners, and cycle-resolution rules.
