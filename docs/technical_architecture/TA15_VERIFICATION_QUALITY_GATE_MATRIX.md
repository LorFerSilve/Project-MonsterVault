# TA-15 Verification and Quality Gate Matrix

> **Status:** PASS  
> **Date:** 2026-09-24

| Domain | Verification obligation | PR / fast lane | Trusted engine/staging | Release requirement |
|---|---|---|---|---|
| Repository/spec | status, IDs, links, architecture gates | required | n/a | required |
| Formatting | StyLua check | required | n/a | required |
| Lint | Selene zero errors/no new unreviewed warnings | required | n/a | required |
| Types | strict Luau analysis | required | n/a | required |
| Build | deterministic Rojo build/source map | required | n/a | required |
| Dependency graph | no forbidden import/cycle/authority bypass | required | spot engine validation | required |
| Pure domain unit | deterministic logic/invariants | required when affected | n/a | required |
| Stateful/property | >=1,000 fast cases | required when affected | >=10,000 extended | required for affected C0 |
| Randomness | injected RNG boundaries + deterministic mapping | required | fixed large corpus diagnostic | required |
| Runtime lifecycle | create/activate/quiesce/destroy/stale callback | partial pure | Studio | required |
| Networking | schemas/revisions/rates/replay | pure validator suite | hostile-client Studio | required |
| Prompt/detector | server context validation | pure policy | Studio hostile trigger | required |
| Physics ownership | authoritative validation | pure rule | Studio/network simulation | required |
| Player profile | migration/revision/lease logic | fake adapter | staging DataStore | required |
| Persistence faults | timeout/throttle/crash/duplicate/ownership loss | deterministic adapter | staging service | required C0 |
| Capture | exact CreatureInstanceId / no reroll | unit/property | engine/reconnect | required C0 |
| Economy/Vault | exact-once claim/purchase/capacity/value | unit/property | engine/persistence | required C0 |
| Trade | revision/reservation/journal/all cut points | unit/state machine | multiplayer/staging | required C0 |
| Commerce receipt | PurchaseId zero-or-one grant | deterministic adapter | staging platform adapter | required C0 |
| Game Pass | positive/negative/unknown/retry | deterministic adapter | staging platform adapter | required C0 |
| Config | full-candidate validate/atomic activate/rollback | unit/property | staging ConfigService | required |
| Experiment | assignment/exposure/invariant guardrail | deterministic unit | staging optional | required |
| MemoryStore | duplicate/miss/expire/throttle | fake adapter | staging if adopted | required if used |
| Messaging | duplicate/miss/reorder/coalesce | fake adapter | staging | required if used |
| UI state | revision/Pending/OutcomeUnknown | unit/view model | Studio | required |
| Input/focus | context precedence/handoff/focus restoration | unit policy | VirtualInput | required |
| Device/safe area | responsive layout | n/a | Device Simulator | required |
| Accessibility | text/transparency/reduced motion/captions | policy/unit | Studio device/input | required |
| Localization | keys + expansion tolerance | static | Player Emulator/pseudolocalize | required |
| Server performance | TA-14 frame/script/scheduler | microbench where pure | L0-L5 | hard guards required |
| Client performance | frame/memory/stall | n/a | real client + Studio diagnostics | hard guards required |
| Network performance | bytes/rates/payload/frequency | serializer checks | L0-L5/net simulation | required |
| Long session | leak/task/cache growth | n/a | L5 >=60 min | required |
| Security abuse | malformed/oversized/permission/spam | validator fuzz | hostile Studio | required |
| Diagnostics | result schema/seed/cut point/build identity | required | profiler/log artifacts | required |
| Flake policy | original failures visible/no retry-until-green | required | required | required |
| CI security | no secrets on untrusted PR, read-only token | required | privileged lane isolated | required |
| Release | no unresolved C0/C1 | n/a | complete evidence | hard block |

## Critical invariants

The following may never be represented only by line coverage or UI snapshots:

- ownership;
- P2 exact-once outcomes;
- persistence lease/single-writer;
- transaction journals/recovery;
- receipt idempotency;
- trade atomicity;
- security authorization;
- durable value preservation.

They require positive, negative and fault-path evidence.

**Quality gate matrix result: PASS.**
