# TA-14 Performance and Scalability Budget Matrix

> **Status:** PASS  
> **Date:** 2026-09-24  
> **Authority:** Compact review matrix for the numeric TA-14 contract

| Domain | Target | Warning | Hard guardrail / degradation |
|---|---|---|---|
| Server frame | p95 <=16.67 ms | sustained >16.67 ms | >25 ms sustained blocks healthy-state claim |
| MV server script CPU | p95 <=6 ms/frame | >8 ms | >10 ms sustained -> load shed |
| Scheduler pass | <=2 ms p95 | >3 ms | >4 ms -> split/defer |
| Cooperative chunk | <=1 ms | >1.5 ms | >2 ms -> mandatory split |
| Low-end supported client | >=30 FPS p95 | frame >33.33 ms | reproducible long stall/OOM fails |
| Reference client tiers | target >=60 FPS p95 | >16.67 ms | must still preserve >=30 FPS correctness floor |
| Server memory | <=40% | >45% | >=50% -> stop optional admission/growth |
| Client memory | stable vs Mwarm | >15% or +128 MiB sustained | OOM/support-device crash fails |
| Active ordinary World Creatures | <= authored limits and <=256 | near 256 under pressure | no refill above safe authored minimum |
| Runtime interactables | <=512 | growth trend | prevent optional creation |
| Persistent streamed models/client | target <=8 | 9–16 | >16 requires TA change |
| StreamingMinRadius | 64 | n/a | increase requires measured review |
| StreamingTargetRadius | 1024 | n/a | increase requires measured review |
| C2S app rate/player | <=8 msg/s | burst pressure | >16/2 s throttled by global/route budget |
| C2S app bytes/player | <=4 KiB/s | >4 KiB/s | >8 KiB/s optional work rejected |
| S2C app bytes/player | <=16 KiB/s | >16 KiB/s | >32 KiB/s optional fidelity reduced |
| Reliable ordinary payload | <=4 KiB | n/a | larger must use bounded snapshot/chunk path |
| Snapshot chunk | <=16 KiB | n/a | split |
| Unreliable payload | <=768 B | n/a | reject/split; platform drops >1000 B |
| Ordinary projection frequency | <=10 Hz | n/a | no higher without review |
| Loss-tolerant active presentation | <=20 Hz | n/a | no higher without review |
| Profile serialized size | <1 MiB | >=1 MiB | 1.5 MiB hard |
| Owned Creature records | <1536 | >=1536 | 2048 hard |
| Recent operation markers | <384 | >=384 | 512 hard |
| Deferred grants | <96 | >=96 | 128 hard; new grant fails protected |
| Autosave | 90 s ±15 s | >120 s healthy gap | investigate / prioritize checkpoint |
| Lease refresh | <=90 s | missed interval | lease owner enters protected state |
| Lease stale threshold | 300 s | n/a | reclaim only after TA-4 rules prove stale |
| Crash production allowance | 180 s | n/a | must remain >= healthy max checkpoint gap |
| DataStore routine write share | <=25% | >25% | >40% pause background |
| DataStore reserve | >=max(30,2P) budget units | approaching reserve | P1/background paused |
| Profile-key write throughput | <1 MiB/min | >=1 MiB/min | 2 MiB/min hard |
| Profile-key read throughput | <4 MiB/min | >=4 MiB/min | 8 MiB/min hard |
| Critical retry attempts | <=6 | repeated failures | preserve unknown after cap |
| MemoryStore requests | <=10% universe quota | >20% | >=30% load shed |
| MemoryStore memory | <=25% universe quota | >25% | refuse optional growth |
| MemoryStore item | <=8 KiB | n/a | reject/split |
| MemoryStore TTL | <=15 min default | longer reviewed | durable truth prohibited |
| Messaging publish | <=12/min/server | burst >6/10s | coalesce/defer |
| Messaging topics | <=4 baseline | n/a | additional topic reviewed |
| Messaging message | <=512 B encoded | n/a | split/coalesce |
| World scheduler cadence | 250 ms | one slip | defer non-urgent buckets |
| Spatial cell | 128 studs baseline | profiled candidate pressure | TA-15 may justify 64–256 |
| Spatial candidate prefilter | <=64 | >64 | narrow/chunk before expensive validation |
| Trade offer | <=12 creatures/side | n/a | reject >12 with clear reason |
| Virtualized UI rows | <=60 + 12 overscan | >72 | recycle/chunk |
| Sort/filter main-thread work | <=4 ms chunk | >4 ms | yield/chunk |
| Ordinary UI timers | <=4 Hz | n/a | centralize/coalesce |
| Active short presentation timer | <=10 Hz | n/a | local only |
| Low/normal notification queue | <=8 | full | coalesce/drop lower priority |
| High-priority transient queue | <=2 | full | critical state becomes persistent surface |
| Preference save debounce | 2 s | n/a | dedicated persistence <=1/30 s/player |
| Telemetry queue | <=512 events and <=256 KiB | 75% full | sample/coalesce low priority |
| Analytics event size | <=2 KiB | n/a | reject/sanitize |
| Product analytics/player | <=2/min steady | burst | <=10/min burst then sample |
| Config refresh | >=30 s apart | n/a | no per-frame polling |
| Config validation | <=2 ms p95 | >2 ms | chunk before atomic activation |
| Experiment assignment | <=0.25 ms p95 | >0.25 ms | cache/optimize |
| Product metadata cache | 5 min target TTL | stale | refresh safely; never fabricate price |
| Ownership reconciliation | 5 retries: 1/2/4/8/16 s | unknown persists | no infinite retry |
| Join click-to-interactive | p95 <=10 s controlled | regression | investigate/block release when reproducible |
| Healthy profile readiness | p95 <=8 s controlled | regression | ProtectedLoadFailure/Pending remains safe |
| Pressure recovery hysteresis | 30 s below warning | n/a | no instant catch-up spike |

P = currently connected players in the server.

Budget crossings are operational signals, not permission to modify durable semantics.

**Budget matrix result: PASS.**
