# TA-2 Scenario Validation

> **Phase:** TA-2 — Repository Layout, Module Boundaries, Dependency Direction, and Bootstrapping  
> **Status:** PASS  
> **Purpose:** Validate structural ownership, imports, bootstrap lifecycle, Rojo mapping, cross-domain orchestration, shared disclosure and testability before source scaffolding is created.

| # | Scenario | Expected structural result | Result |
|---:|---|---|---|
| 1 | Server domain imports client module | Forbidden | PASS |
| 2 | Client imports server module | Impossible/forbidden | PASS |
| 3 | Shared module imports server domain | Forbidden | PASS |
| 4 | Shared module imports client presentation | Forbidden | PASS |
| 5 | Server domain imports same-domain internal helper | Allowed | PASS |
| 6 | Server domain deep-imports another domain internal helper | Forbidden | PASS |
| 7 | Server domain calls another domain public query | Allowed through contract | PASS |
| 8 | Server domain directly mutates another domain table | Forbidden | PASS |
| 9 | Cross-domain transaction needs three domains | Application coordinator owns orchestration | PASS |
| 10 | Capture domain starts owning Vault capacity | Reject ownership drift | PASS |
| 11 | Trading directly edits creature owner field | Reject; use ownership contract/coordinator | PASS |
| 12 | UI grants commercial entitlement | Forbidden | PASS |
| 13 | Marketplace adapter grants gameplay value itself | Forbidden; mechanism only | PASS |
| 14 | Persistence adapter decides game reward | Forbidden | PASS |
| 15 | Infrastructure imports economy domain | Forbidden baseline | PASS |
| 16 | Application layer imports two domain public contracts | Allowed | PASS |
| 17 | Application layer reads domain internals | Forbidden | PASS |
| 18 | Bootstrap constructs domain services | Allowed | PASS |
| 19 | Domain imports bootstrap | Forbidden | PASS |
| 20 | Module require connects Players.PlayerAdded | Forbidden side effect | PASS |
| 21 | Start lifecycle connects PlayerAdded | Valid when owned | PASS |
| 22 | Module require creates RemoteEvent | Forbidden | PASS |
| 23 | TA-3 networking bootstrap creates governed remotes | Valid | PASS |
| 24 | Module require starts while true loop | Forbidden | PASS |
| 25 | Start begins owned background loop | Valid | PASS |
| 26 | Duplicate Start registers duplicate listeners | Must be prevented/detected | PASS |
| 27 | Construct writes DataStore | Forbidden | PASS |
| 28 | Validate awards Energy | Forbidden | PASS |
| 29 | Startup validates config before remotes bind | Required | PASS |
| 30 | Remote endpoints bind before domains exist | Invalid bootstrap order | PASS |
| 31 | Server fails fatal validation | Fail closed rather than partial gameplay | PASS |
| 32 | Client boots before server profile ready | UI may load; irreversible controls wait | PASS |
| 33 | Client Ready assumed to mean profile Ready | Invalid conflation | PASS |
| 34 | Player profile load fails | Session does not become gameplay-ready | PASS |
| 35 | Shared contains secret RNG seed | Invalid disclosure | PASS |
| 36 | Shared contains public Species ID type | Valid | PASS |
| 37 | Shared contains hidden anti-cheat threshold | Invalid | PASS |
| 38 | Shared contains pure vector/math helper | Valid | PASS |
| 39 | Shared util contains trade policy | Misplaced; move to owning domain | PASS |
| 40 | One-domain helper placed in global util | Reject junk-drawer abstraction | PASS |
| 41 | Client feature stores UI-only selection | Valid client state | PASS |
| 42 | Client feature stores authoritative Energy balance as writable truth | Invalid | PASS |
| 43 | Server sends projected Energy balance | Client may display projection | PASS |
| 44 | Presentation mutates projection locally to pretend purchase succeeded | Invalid irreversible prediction | PASS |
| 45 | Input maps touch tap to PrimaryInteract | Valid semantic intent | PASS |
| 46 | Input module resolves capture ownership | Invalid | PASS |
| 47 | Workspace ValueObject used as persistent ownership truth | Invalid | PASS |
| 48 | ReplicatedStorage ValueObject treated as server database | Invalid | PASS |
| 49 | _G stores service registry | Forbidden | PASS |
| 50 | global shared table stores player profiles | Forbidden | PASS |
| 51 | Bootstrap has local constructed component registry | Allowed for composition bookkeeping | PASS |
| 52 | Domain uses registry as runtime service locator | Forbidden | PASS |
| 53 | Constructor receives explicit dependency | Preferred | PASS |
| 54 | Capture and Vault form cyclic requires | Invalid | PASS |
| 55 | Cycle resolved by lazy require hack | Invalid | PASS |
| 56 | Cycle resolved by application orchestrator | Valid | PASS |
| 57 | Cycle resolved by genuinely shared pure type | Valid if no policy leakage | PASS |
| 58 | Duplicate state copied into both domains to break cycle | Invalid | PASS |
| 59 | Domain emits completed-fact event | Potentially valid | PASS |
| 60 | Critical atomic ownership commit relies only on fire-and-forget event | Invalid | PASS |
| 61 | Event subscriber mutates producer private state | Forbidden | PASS |
| 62 | Query function mutates domain state | Invalid command/query semantics | PASS |
| 63 | Command returns direct writable internal table | Invalid encapsulation | PASS |
| 64 | Public query returns immutable/snapshot data | Valid | PASS |
| 65 | One server bootstrap entrypoint | Required baseline | PASS |
| 66 | Feature adds independent auto-start server Script | Reject unless explicit architecture need | PASS |
| 67 | One client bootstrap entrypoint | Required baseline | PASS |
| 68 | Feature GUI has independent hidden initialization authority | Invalid baseline | PASS |
| 69 | src/shared maps to ReplicatedStorage/MonsterVault/Shared | Correct | PASS |
| 70 | src/server maps to ServerScriptService/MonsterVaultServer | Correct | PASS |
| 71 | src/client maps to StarterPlayerScripts/MonsterVaultClient | Correct | PASS |
| 72 | Feature creates remote in its own replicated folder | Invalid; TA-3 central owner | PASS |
| 73 | Server logic is placed in Workspace model Script | Not baseline architecture | PASS |
| 74 | World asset Instance exists in Workspace | Valid under TA-6/9 | PASS |
| 75 | UI template strategy under StarterGui | Deferred to TA-12 | PASS |
| 76 | Server-only content uses ServerStorage after TA-5/9 justification | Valid | PASS |
| 77 | Public config exposes harmless display constant | Valid | PASS |
| 78 | Public config exposes private anti-abuse parameter | Invalid | PASS |
| 79 | Runtime player state written into config table | Invalid | PASS |
| 80 | DataStoreService called directly from arbitrary domain leaf | Invalid | PASS |
| 81 | MarketplaceService called directly from UI | Invalid | PASS |
| 82 | MessagingService called from feature leaf | Invalid; TA-10 infra owner | PASS |
| 83 | Telemetry API called everywhere with ad-hoc payload | Invalid; TA-13 contract | PASS |
| 84 | RunService loop has named owner/lifecycle | Valid | PASS |
| 85 | Same heartbeat concern registered redundantly across modules | Architecture/performance concern | PASS |
| 86 | Shutdown accepts new trade commit indefinitely | Invalid; owning shutdown contract must gate | PASS |
| 87 | Shutdown first blocks appropriate new irreversible operations | Valid conceptual ordering | PASS |
| 88 | Shutdown deletes in-flight finalized outcome | Invalid | PASS |
| 89 | tests/unit imports production pure domain module | Valid | PASS |
| 90 | production module imports tests fixture | Forbidden | PASS |
| 91 | integration test uses fake persistence contract | Supported architecture | PASS |
| 92 | random provider injectable/controlable for tests | Supported downstream | PASS |
| 93 | scripts/ contains developer build helper | Valid later | PASS |
| 94 | scripts/ contains Roblox gameplay runtime | Invalid | PASS |
| 95 | generated sourcemap treated as source authority | Invalid baseline | PASS |
| 96 | actual default.project.json created during TA-2 | Not necessary; TA-17 locks scaffold | PASS |
| 97 | TA-3 adds networking submodules within approved roots | Valid | PASS |
| 98 | TA-4 invents parallel source root for persistence | Invalid without TA-2 change control | PASS |
| 99 | TA-9 needs multi-place topology | May refine mapping with TA-1/2/9 revalidation | PASS |
| 100 | TA-15 adds dependency graph check | Expected enforcement | PASS |
| 101 | Client controller talks to networking adapter | Valid | PASS |
| 102 | Client presentation creates arbitrary remote request | Invalid | PASS |
| 103 | Client feature imports shared request type | Valid | PASS |
| 104 | Shared request type assumed to authorize request | Invalid security assumption | PASS |
| 105 | Server application orchestrator becomes giant home for domain policy | Invalid; policy stays in domains | PASS |
| 106 | Domain service becomes god-service for unrelated domains | Invalid | PASS |
| 107 | Infrastructure adapter replaceable with fake | Desired testability | PASS |
| 108 | Platform adapter leaks raw Roblox object through every domain | Avoid; use controlled translation where useful | PASS |
| 109 | Domain legitimately needs Player object identity | Adapter/contract may expose narrow necessary identity | PASS |
| 110 | Repository structure changes after TA-2 | Material changes require TA-2 change control | PASS |

## Verdict

**110 / 110 scenarios: PASS.**

The TA-2 structural architecture preserves authority, dependency direction, startup determinism, client/server trust separation, and downstream phase ownership.
