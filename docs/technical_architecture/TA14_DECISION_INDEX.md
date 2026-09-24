# TA-14 Decision Index

> **Status:** Accepted  
> **Date:** 2026-09-24  
> **Owning phase:** TA-14

| ID | Decision |
|---|---|
| AD-170 | Separate Roblox platform ceilings from stricter MonsterVault operating budgets. |
| AD-171 | Validate L0 solo, L1 half, L2 full, L3 full+burst, L4 recovery and L5 long-session load classes. |
| AD-172 | Preserve 60 Hz server headroom with a 6 ms p95 MonsterVault script budget and staged load shedding. |
| AD-173 | Make 30 FPS the correctness floor while targeting 60 FPS on reference devices. |
| AD-174 | Use server percentage guardrails and client warm-baseline leak budgets rather than inventing one universal client RAM ceiling. |
| AD-175 | Adopt Roblox's current 64/1024/PauseOutsideLoadedArea/Opportunistic streaming baseline; Persistent use stays rare. |
| AD-176 | Bound active World Creatures, interactables, tasks, connections and caches; no session-age growth. |
| AD-177 | Keep custom remote rates/bytes far below platform throttles with global and per-route budgets. |
| AD-178 | Cap UnreliableRemoteEvent payloads at 768 bytes and prohibit critical truth on unreliable transport. |
| AD-179 | Cap Player Profile architecture at 1.5 MiB and owned Creature records at 2048 before sharding reconsideration. |
| AD-180 | Lock 90 s autosave/lease cadence, 300 s stale threshold and 180 s crash-production allowance. |
| AD-181 | Reserve dynamic DataStore request budget for P2/load/lease/recovery before background writes. |
| AD-182 | Keep MemoryStore optional/transient and limited to a small fraction of universe quotas. |
| AD-183 | Keep MessagingService coarse, bounded and non-authoritative. |
| AD-184 | Lock 250 ms world scheduling, 2 ms passes, 128-stud spatial baseline and <=64 ordinary candidates. |
| AD-185 | Virtualize long UI lists and bound timer/notification/preference persistence work. |
| AD-186 | Bound analytics queues/rates and config/experiment compute without making gameplay wait. |
| AD-187 | Coalesce commerce metadata/ownership work and preserve Unknown/Pending after retry exhaustion. |
| AD-188 | Use GREEN/YELLOW/ORANGE/RED pressure states with 30 s recovery hysteresis; pressure never changes durable semantics. |
| AD-189 | Make performance observability first-class and low-cardinality. |
| AD-190 | Require TA-14 change control before raising hard budgets or reducing platform headroom. |
| AD-191 | Close TA-14 and advance the dependency chain to TA-15. |

**Decision index result: ACCEPTED.**
