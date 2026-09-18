# TA-3 Remote Contract and Validation Matrix

> **Phase:** TA-3 — Networking, Server Authority, Remote Contracts, and Exploit Boundaries  
> **Status:** PASS  
> **Purpose:** Lock transport roles, generic envelope fields, validation responsibilities, retry classes and security requirements before domain-specific routes are authored in later TA phases.

## 1. Transport Matrix

| Transport | Roblox primitive | Direction | Reliability | Baseline use | Persistent value allowed? |
|---|---|---|---|---|---:|
| Command | RemoteEvent | Client -> Server | Reliable | semantic intent/commands | only after server validation/owner commit |
| Event | RemoteEvent | Server -> Client | Reliable | command results, snapshots, authoritative facts | projection only |
| UnreliableEvent | UnreliableRemoteEvent | Server -> Client | loss/reorder tolerant | cosmetic/transient high-frequency presentation | NO |
| RemoteFunction | RemoteFunction | none baseline | yielding | not used | NO baseline |

## 2. Command Envelope

| Field | Source | Trust | Validation |
|---|---|---|---|
| protocolVersion | client | untrusted | supported integer/version |
| route | client | untrusted | bounded string + static registry lookup |
| requestId | client | untrusted correlation | bounded format, duplicate/reuse checks |
| expectedRevision | client optional | untrusted expectation | compare to authoritative revision |
| payload | client | fully untrusted | exact route schema + semantic validation |

The authenticated sender is the implicit `Player` argument from Roblox `OnServerEvent`, never a payload-selected sender identity.

## 3. Event Envelope

| Field | Owner | Purpose |
|---|---|---|
| protocolVersion | server | protocol compatibility |
| route | server | client dispatcher route |
| correlationId | server | ties result to request when applicable |
| stateVersion | server optional | stale/snapshot ordering |
| payload | server | minimal safe recipient projection |

## 4. Generic Session Routes

These routes are architecture-level reserved concepts. Exact spelling/file representation is finalized by TA-17.

| Concept | Direction | Class | Purpose |
|---|---|---|---|
| Session.ClientHello | C->S | A | confirms client listener/protocol readiness and requests current session projection |
| Session.Ready | S->C | reliable event | delivers authoritative ready state + initial bounded projection |
| Session.Loading | S->C | reliable event | communicates non-final loading status |
| Session.ProtectedLoadFailure | S->C | reliable event | communicates safe blocked state |
| Command.Result | S->C | reliable event | generic or route-specific command acknowledgement/rejection |

Gameplay route families are owned downstream.

## 5. Validation Pipeline Matrix

| Stage | Owner | Failure behavior | Expensive work allowed? |
|---|---|---|---:|
| implicit sender | Roblox/gateway | impossible sender -> no route execution | NO |
| envelope type/bounds | gateway | reject | NO |
| protocol | gateway | reject incompatibility | NO |
| route/direction | gateway | reject/log | NO |
| global/route rate budget | gateway | reject/drop | NO |
| session readiness | session contract | reject NotReady | low |
| exact payload schema | route validator | reject InvalidPayload | bounded |
| permission/context | owning domain/application | reject NotAuthorized/InvalidState | bounded |
| mutation/use case | owning domain/application | authoritative result | YES within TA budgets |
| result projection | gateway/client projection contract | schema-safe send | bounded |
| telemetry | telemetry adapter | non-authoritative | async/bounded |

## 6. Payload Rules by Type

### Strings

- explicit maximum length;
- allowed format where identifier;
- freeform user text prohibited unless a future GDS-15-compatible route explicitly authorizes and filters it.

### Numbers

- finite;
- route-specific min/max;
- integer where semantically integer;
- client timestamps are advisory only.

### Tables

- explicit allowed keys;
- bounded item count;
- bounded depth;
- no arbitrary user-created key namespace;
- validate nested values recursively within fixed schema.

### Instances

Rejected by default.

If a downstream route has a compelling reason:

- exact expected class;
- exact expected ancestry;
- current lifecycle;
- sender relationship/ownership;
- no generic delete/mutate behavior.

Stable IDs remain preferred.

## 7. Request ID Rules

### Network scope

A requestId:

- correlates async results;
- allows short-lived session duplicate suppression;
- supports safe retry behavior.

It does **not**:

- prove the client created a legitimate action;
- choose the server operation ID;
- become the permanent unique ID of a reward/ownership transfer.

### Reuse

- same ID + same logical route/payload retry -> duplicate handling;
- same ID + different route/payload -> reject as request ID misuse.

## 8. Retry Matrix

| Command class | Automatic retry | Request ID | Authoritative reconciliation |
|---|---:|---|---|
| A session/hello | bounded YES | same | session snapshot |
| B ordinary reversible interaction | route-defined | same | current state |
| C sensitive irreversible/value | only if explicitly allowed | MUST reuse same | owning domain/persistence state |
| D commercial/safety-critical | highly restricted/route-defined | same | platform/server authoritative state |

Timeout for C/D means **unknown outcome**, not failure.

## 9. Rate-Limit Matrix

| Layer | Scope | Purpose |
|---|---|---|
| global ingress | per player | stop many-route flood |
| route bucket | per player + route | protect feature-specific work |
| target/resource optional | per target/use case | stop fanout/target abuse where needed |
| server-wide overload protection | server | graceful degradation/abuse containment |

Exact capacities/refill rates are TA-14 tuneables.

## 10. Sensitive Domain Minimum Validation

| Domain | Minimum network-side/domain checks |
|---|---|
| Interaction | ready, valid interaction ID, target lifecycle, context/proximity, state |
| Capture | ready, active claim/attempt identity, timing/state, target eligibility, no client result |
| Release | ownership, Creature Lock, exact instance, confirmation/revision if applicable |
| Vault | ownership, capacity/state, assignment eligibility |
| Economy | authoritative balance, milestone/state, price/config |
| Travel | access/mastery, acquisition-in-progress restrictions |
| Social | eligibility, target, block state, party/challenge state, rate |
| Event | active occurrence/server instance, eligible presence/contribution context |
| Trade | access, participant/session, revision, exact instance eligibility, readiness/confirmation |
| Monetization | product identity from server config, eligibility; receipt remains platform/server owned |
| Safety | current platform/account restrictions; no client self-asserted privilege |

## 11. Server-to-Client Audience Matrix

| Data | Audience |
|---|---|
| own private collection/economy/progression | owner only |
| Party state | eligible Party members |
| Trade state | exact participants |
| public event phase | relevant server players |
| personal event contribution/reward eligibility | owner only |
| another player's public showcase | authorized viewers only |
| hidden rare spawn/internal roll | not sent until gameplay presentation permits |
| moderation/eligibility internals | minimum affected-player information only |
| exploit/rate score | server only |

## 12. UnreliableEvent Examples

Potentially valid:

- cosmetic trail sample;
- non-critical remote VFX cue;
- rapidly superseded visual indicator.

Never valid:

- "capture succeeded";
- "trade committed";
- "Energy is now X";
- "you own creature Y";
- "purchase granted";
- "event reward claimed";
- "player is banned/restricted";
- Trade Revision/Final Confirmation.

## 13. RemoteFunction Exception Gate

A proposed future RemoteFunction must answer YES to all:

- async Event request/result is materially worse for this case;
- operation is bounded and non-authoritative;
- server never invokes the client for correctness;
- disconnect/yield semantics are explicitly safe;
- rate/validation contracts are defined;
- TA-3 is reopened and scenario validation updated.

Otherwise reject the proposal.

## 14. Exploit-Safe Error Matrix

| Condition | Result | Persistent mutation |
|---|---|---:|
| malformed envelope | reject/drop | NO |
| unsupported protocol | reject incompatibility | NO |
| unknown route | reject/log | NO |
| rate limit | reject/drop | NO |
| not ready | reject | NO |
| stale revision | reject + current revision/projection as safe | NO |
| unauthorized target | reject | NO |
| duplicate request | return/reconcile prior known result where possible | NO duplicate |
| handler internal error before commit | server error + no commit | NO |
| handler error after durable commit | reconcile authoritative final state | no duplicate/rollback guess |

## 15. Verdict

**TA-3 REMOTE CONTRACT AND VALIDATION MATRIX: PASS.**
