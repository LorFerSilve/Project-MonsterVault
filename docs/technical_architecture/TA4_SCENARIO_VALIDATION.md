# TA-4 Scenario Validation

> **Phase:** TA-4 — Player Data, Persistence, Session Ownership, Schema Evolution, and Recovery  
> **Status:** PASS  
> **Purpose:** Validate profile loading, session ownership, revision control, autosave/checkpoint behavior, exact-once boundaries, schema migration, corruption handling, crash/shutdown recovery, environment isolation and multi-key transaction primitives.

| # | Scenario | Expected result | Result |
|---:|---|---|---|
| 1 | New player has no DataStore key | Create current default profile under acquired lease | PASS |
| 2 | DataStore Get/Update fails for existing player | Never interpret as new profile | PASS |
| 3 | Load fails transiently | Bounded retry/backoff | PASS |
| 4 | Load keeps failing | ProtectedLoadFailure; no writable default overwrite | PASS |
| 5 | Client says load is complete | Does not make server session Ready | PASS |
| 6 | Client sends gameplay command while Acquiring | Rejected NotReady | PASS |
| 7 | Client sends P2 command during ProtectedLoadFailure | Rejected | PASS |
| 8 | Profile current schema validates | Ready after lease + validation | PASS |
| 9 | Profile older supported schema | Migrate sequentially then validate | PASS |
| 10 | Profile newer than server code | Fail closed; no downgrade | PASS |
| 11 | Migration throws/fails validation | No partial write; protected failure | PASS |
| 12 | Missing optional new field | Explicit default reconciliation | PASS |
| 13 | Missing field default would fabricate rare creature | Prohibited | PASS |
| 14 | Missing field default would fabricate Event Completion | Prohibited | PASS |
| 15 | Missing field default is harmless UI preference | May reconcile | PASS |
| 16 | Stored profile root has wrong type | ProtectedLoadFailure | PASS |
| 17 | Stored Energy invalid/negative beyond domain rules | Validation failure, not silent erase | PASS |
| 18 | Duplicate Creature Instance IDs detected | Protected/recovery path | PASS |
| 19 | Invalid enum/content reference safely remappable | Deterministic migration may repair | PASS |
| 20 | Invalid valuable state cannot be losslessly repaired | Operator recovery required | PASS |
| 21 | Session key is unlocked | Acquire new metadata lease atomically | PASS |
| 22 | Session key has fresh foreign lock | Abort acquisition; no writable load | PASS |
| 23 | Session key has stale foreign lock | Reclaim after expiry policy | PASS |
| 24 | Two servers race to acquire unlocked profile | UpdateAsync permits only one current lease owner | PASS |
| 25 | Losing server sees fresh foreign lease | SessionLocked/protected retry | PASS |
| 26 | Player reconnects before prior leave save unlock finishes | New server waits rather than overwrites | PASS |
| 27 | Prior server releases with final save | New server can acquire afterward | PASS |
| 28 | Prior server crashes without unlock | New server waits until lease stale | PASS |
| 29 | Old crashed server cannot resume | Lease recovery safe | PASS |
| 30 | Network partition causes lease renewal failure | Enter PersistenceAtRisk before unsafe expiry | PASS |
| 31 | Lease renewal later succeeds with own lock | Return to Ready | PASS |
| 32 | Renewal observes foreign lock | OwnershipLost | PASS |
| 33 | OwnershipLost server has dirty in-memory state | Quarantine; no blind overwrite | PASS |
| 34 | OwnershipLost player attempts capture finalization | Block persistent mutation | PASS |
| 35 | OwnershipLost player attempts UI navigation | Non-persistent safe presentation may continue briefly | PASS |
| 36 | Server sees its lock metadata missing unexpectedly | Treat as ownership uncertainty/loss | PASS |
| 37 | Malformed metadata lock | Protected validation/recovery, no blind claim | PASS |
| 38 | Lease metadata is compact | Fits current metadata budget | PASS |
| 39 | Save forgets to preserve metadata | Architecturally prohibited by one repository wrapper | PASS |
| 40 | Domain calls DataStore directly | Forbidden | PASS |
| 41 | Domain calls persistence repository contract | Valid | PASS |
| 42 | Two local coroutines try profile save simultaneously | Serialized by per-profile writer queue | PASS |
| 43 | Autosave starts while P2 checkpoint queued | Ordering/priority prevents unsafe overlap | PASS |
| 44 | Same key receives lease renewal and save at once | Serialized | PASS |
| 45 | Different players save simultaneously | May execute in parallel | PASS |
| 46 | Ordinary profile read in gameplay | Uses in-memory working copy | PASS |
| 47 | Every Energy increment performs GetAsync | Invalid architecture | PASS |
| 48 | P1 setting changes | Dirty buffer; autosave later | PASS |
| 49 | P0 Active Context changes | Never persisted | PASS |
| 50 | P2 creature ownership finalizes | Durable checkpoint before final durable ack | PASS |
| 51 | P2 Energy spend + unlock | One profile atomic commit | PASS |
| 52 | P2 production claim | Buffer clear + Energy grant one profile commit | PASS |
| 53 | P2 Event reward | Stable operation ID + durable player outcome | PASS |
| 54 | P2 trade finalization spans two users | Requires TA-10 multi-key transaction protocol | PASS |
| 55 | P2 developer product grant | TA-11 durable receipt protocol | PASS |
| 56 | P2 checkpoint DataStore call fails transiently | Operation not durably acknowledged; retry/reconcile | PASS |
| 57 | Client times out during P2 checkpoint | Outcome unknown to client; reconcile | PASS |
| 58 | Client retries same request | Server operation identity prevents duplicate | PASS |
| 59 | Client creates new requestId after timeout | Cannot bypass durable operation dedupe | PASS |
| 60 | P2 succeeds in DataStore but response is lost | Reconnect/retry discovers finalized authoritative state | PASS |
| 61 | P1 autosave fails once | Keep dirty and retry | PASS |
| 62 | P1 autosave keeps failing near lease expiry | PersistenceAtRisk blocks new irreversible changes | PASS |
| 63 | P1 preference latest edit lost in catastrophic crash before autosave | Acceptable only for fields classified P1 | PASS |
| 64 | Creature ownership lost in crash after client was told final success | Invalid; ownership is P2 durable-before-ack | PASS |
| 65 | Session lease renews with no dirty fields | Valid/required | PASS |
| 66 | All players autosave on exact same tick | Invalid; stagger schedules | PASS |
| 67 | Autosave interval exceeds lease expiration | Invalid | PASS |
| 68 | Lease renewal interval leaves no retry margin | Invalid; TA-14 must set safe margin | PASS |
| 69 | Autosave uses SetAsync | Invalid profile primitive | PASS |
| 70 | Autosave uses UpdateAsync | Correct | PASS |
| 71 | UpdateAsync transform yields | Invalid Roblox callback usage | PASS |
| 72 | Transform calls MarketplaceService | Invalid | PASS |
| 73 | Transform performs random side effect | Invalid | PASS |
| 74 | Transform receives stale invocation and reruns | Deterministic intended snapshot/validation safe | PASS |
| 75 | Stored profileRevision equals expected | Write may proceed | PASS |
| 76 | Stored revision greater than expected | Abort/reconcile concurrency fault | PASS |
| 77 | Stored revision lower unexpectedly | Abort/recovery; no blind overwrite | PASS |
| 78 | Successful durable content write | Monotonic profileRevision advances | PASS |
| 79 | profileRevision sent by client | Client value not authoritative | PASS |
| 80 | Profile object is missing because key truly absent | New-profile path allowed | PASS |
| 81 | Profile object missing because DataStore request failed | New-profile path forbidden | PASS |
| 82 | Player leaves with clean profile | Final save/lease release still ensures ownership handoff | PASS |
| 83 | Player leaves with dirty P1 state | Save coherent profile + release | PASS |
| 84 | Player leaves with P2 operation in flight | Owning transaction decides bounded resolution before release | PASS |
| 85 | Leave handler removes lease before save | Invalid ordering | PASS |
| 86 | Final save succeeds | Lease removed in same successful update | PASS |
| 87 | Final save fails | Do not falsely unlock; stale lease recovery protects next join | PASS |
| 88 | In-memory profile cleared before final save result | Invalid | PASS |
| 89 | Server BindToClose starts | Stop admission of new persistent operations | PASS |
| 90 | Shutdown saves 30 players sequentially | Invalid risk; parallel across profile keys | PASS |
| 91 | Shutdown saves different player keys in parallel | Correct | PASS |
| 92 | Two saves to same player during shutdown | Still serialized | PASS |
| 93 | Shutdown spends deadline on analytics flush before profiles | Wrong priority | PASS |
| 94 | Shutdown deadline expires | Cannot fabricate successful final saves | PASS |
| 95 | Abrupt process crash bypasses BindToClose | Periodic checkpoints + lease expiry are recovery basis | PASS |
| 96 | Server crash immediately after P1 mutation | May lose only P1-safe delta | PASS |
| 97 | Server crash immediately after P2 durable ack | Data already checkpointed | PASS |
| 98 | DataStore throttles during normal play | Buffer/retry/budget-aware scheduling | PASS |
| 99 | Request budget low | Noncritical autosave may delay within lease safety | PASS |
| 100 | Request budget low during P2 commit | Do not bypass durability; pending/retry/fail safely | PASS |
| 101 | DataStore service internal error | Classified retryable when appropriate | PASS |
| 102 | Permanent serialization/schema error | No infinite retry | PASS |
| 103 | Retry loops forever while player leaves | Prohibited | PASS |
| 104 | Retry uses jitter/backoff | Required | PASS |
| 105 | New deployment introduces schema v5 | current schemaVersion becomes 5 | PASS |
| 106 | v3 profile loads on v5 server | run v3->v4->v5 migrations | PASS |
| 107 | Migration depends on HTTP/web call | Invalid | PASS |
| 108 | Migration depends on current wall-clock for random grant | Invalid unless explicitly deterministic rule authorized | PASS |
| 109 | Migration pure/transforms data | Correct | PASS |
| 110 | v5 profile joins rolled-back v4 server | Fail closed, no downgrade | PASS |
| 111 | Migration changes Creature IDs without mapping | Invalid if identity/provenance breaks | PASS |
| 112 | Migration recomputes derived cache | Potentially valid | PASS |
| 113 | Migration removes valuable unknown field silently | Invalid | PASS |
| 114 | Old schema no longer supported but still in production | Migration code cannot be removed yet | PASS |
| 115 | Current profile corrupt after bad deployment | Protected failure | PASS |
| 116 | Previous DataStore version is valid | Operator may inspect/revert through controlled recovery | PASS |
| 117 | Runtime auto-selects previous version silently | Not baseline | PASS |
| 118 | Operator revert occurs | Audit action and resulting new version | PASS |
| 119 | Operator edits production profile without schema awareness | Prohibited operational practice | PASS |
| 120 | Full profile dumped to telemetry | Invalid privacy/volume pattern | PASS |
| 121 | Validation failure logs schema/version/category only | Preferred | PASS |
| 122 | Data Store Manager used to compare versions | Valid ops workflow | PASS |
| 123 | MemoryStore used as sole profile storage | Invalid | PASS |
| 124 | MemoryStore used as sole session-lock authority | Invalid TA-4 baseline | PASS |
| 125 | MemoryStore later used as ephemeral trade/event coordination | Possible under TA-10; durable truth elsewhere | PASS |
| 126 | OrderedDataStore used for player profile | Invalid | PASS |
| 127 | OrderedDataStore used as leaderboard projection later | Possible downstream | PASS |
| 128 | Profile stores display name as key identity | Invalid; use UserId | PASS |
| 129 | User changes display name | Profile key unaffected | PASS |
| 130 | Profile stores runtime Party invite | Invalid transient state | PASS |
| 131 | Profile stores finalized Trade History reference | Valid downstream | PASS |
| 132 | Profile stores global Event timer as authority | Invalid | PASS |
| 133 | Profile stores personal Event Completion | Valid | PASS |
| 134 | Profile stores client clock for offline production | Invalid authority | PASS |
| 135 | Profile stores trusted server timestamp | Valid input | PASS |
| 136 | Same operationId seen twice in recent ledger | Return/reconcile finalized result, no duplicate | PASS |
| 137 | Recent operation ledger grows forever | Invalid | PASS |
| 138 | Old operation evicted from bounded profile ledger | Acceptable only if its replay horizon no longer needs profile-local dedupe | PASS |
| 139 | Receipt can replay months later | Requires long-lived TA-11 durable receipt handling, not recent ledger only | PASS |
| 140 | Trade transaction may recover after participant disconnect | Durable TA-10 transaction journal required | PASS |
| 141 | Trade writes player A then B sequentially and calls it atomic | Invalid | PASS |
| 142 | Durable transaction record decides commit then participant applications retry idempotently | Valid TA-4 primitive for TA-10 | PASS |
| 143 | Cross-key transaction journal is treated as creature owner | Invalid; coordinates profile ownership writes | PASS |
| 144 | Single-player Energy+unlock split into two DataStore keys | Avoid; violates aggregate atomicity without need | PASS |
| 145 | One-profile aggregate comfortably under budget | Keep unsharded | PASS |
| 146 | Team preemptively shards collection "for scale" | Reject absent evidence | PASS |
| 147 | Profile approaches TA-14 safe size threshold | Reopen TA-4 sharding design | PASS |
| 148 | Sharding added without migration plan | Invalid | PASS |
| 149 | Profile stores redundant derived strings for every creature | Avoid size waste | PASS |
| 150 | Profile stores stable IDs + required instance attributes | Preferred compact model | PASS |
| 151 | DEV Studio connects to production DataStore | Prohibited | PASS |
| 152 | DEV uses isolated development universe/store | Correct | PASS |
| 153 | STAGING shares production persistence | Prohibited | PASS |
| 154 | Production server environment changes at runtime | Prohibited | PASS |
| 155 | Test fixture uses fake persistence repository | Desired | PASS |
| 156 | Test creates two fake servers racing for lock | Required TA-15 coverage | PASS |
| 157 | Test simulates stale lock expiry | Required | PASS |
| 158 | Test simulates lost lease mid-session | Required | PASS |
| 159 | Test simulates UpdateAsync callback retry | Required | PASS |
| 160 | Test simulates profile revision conflict | Required | PASS |
| 161 | Test simulates newer schema | Required | PASS |
| 162 | Test simulates corrupted collection | Required | PASS |
| 163 | Test simulates throttling and shutdown | Required | PASS |
| 164 | Test simulates duplicate operation ID | Required | PASS |
| 165 | Persistence telemetry records load/save latency and result class | Valid | PASS |
| 166 | Persistence telemetry changes gameplay state | Invalid | PASS |
| 167 | Profile save latency spikes | TA-13/14 observe; correctness remains | PASS |
| 168 | Open Cloud operational traffic consumes budget | TA-14/ops account for shared budget | PASS |
| 169 | Third-party profile library proposed | Requires TA-1/TA-4 dependency review | PASS |
| 170 | Native DataStore repository remains sufficient | Preferred baseline | PASS |
| 171 | Gameplay code is written during TA-4 | Implementation gate violation | PASS |
| 172 | TA-5 defines IDs referenced by profile schema | Correct downstream dependency | PASS |
| 173 | TA-8 defines Energy/Vault sub-schema | Correct | PASS |
| 174 | TA-10 defines distributed trade recovery | Correct | PASS |
| 175 | TA-11 defines receipt idempotency | Correct | PASS |
| 176 | TA-14 sets exact autosave/lease numbers | Correct | PASS |
| 177 | TA-15 implements fault-injection validation | Correct | PASS |
| 178 | TA-17 creates DataStore wrapper source | Only after final implementation lock | PASS |
| 179 | TA-17 changes core lease semantics without reopening TA-4 | Invalid | PASS |
| 180 | Session lock + revision + P2 durability chain survives retry/reconnect | Required integrated outcome | PASS |

## Verdict

**180 / 180 scenarios: PASS.**

No TA-4 persistence, session-ownership, schema, recovery, atomicity or durability contradiction remains.
