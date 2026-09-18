# TA-7 — Capture, Creature Ownership, Mutation, and Reward Resolution

> **Status:** Architecture Complete  
> **Owning TA phase:** TA-7 — Capture, Creature Ownership, Mutation, and Reward Resolution  
> **Authority:** Authoritative capture state machine, claim arbitration, attempt acceptance/resolution, server-owned randomness, Variant Identity generation/finalization, Mutation/Trait selection, Provisional Capture and Transport Custody, disconnect grace, controlled-shutdown protection, Secure Point extraction validation, exact-once Secured Ownership Finalization, discovery/protection bundle, capacity-race reconciliation, capture/reward idempotency, anti-reroll and anti-duplication boundaries  
> **Depends on:** TA-0 through TA-6 Architecture Complete; GDS-4, GDS-5, GDS-6, GDS-8, GDS-9, GDS-11, GDS-13, GDS-14, GDS-17

## 1. Purpose

TA-7 translates the completed creature-acquisition design into a server-authoritative technical contract.

The capture contract is:

> **A newly created Creature Instance receives one server-generated identity and one server-finalized Variant Identity before it becomes individually actionable. One server-owned claim state machine arbitrates ordinary capture. Client input can influence a validated Capture Challenge but can never declare success, variant outcome, custody, extraction or ownership. Capture Success creates one transient Provisional Capture. Only a validated Secure Point extraction, or the narrow controlled-shutdown protection path, may invoke one exact-once P2 Secured Ownership Finalization that persists the same CreatureInstanceId and its unchanged Variant Identity.**

TA-7 does not create gameplay scripts, RNG modules, capture minigame code or profile schema modules. Those implementation artifacts remain blocked until TA-17.

## 2. Technical Ownership Boundaries

### TA-7 owns

- ordinary single-award claim arbitration;
- capture acquisition runtime state;
- challenge acceptance/result authority;
- capture-result randomness when a challenge definition uses randomness;
- Variant Identity generation;
- Mutation/Trait compatibility resolution;
- Protected Variant classification at first security;
- Provisional Capture;
- Transport Custody;
- Transport Grace;
- extraction validation orchestration;
- ownership-finalization operation identity;
- capture/discovery/protection finalization bundle;
- capture-specific retry/replay semantics.

### TA-7 does not own

- encounter population scheduling / Species spawn selection — TA-9;
- persistent profile mechanism — TA-4;
- Collection Capacity schema and Vault placement — TA-8;
- Energy/capture-capability economy — TA-8;
- event multi-award allocation — TA-10;
- UI/input rendering — TA-12;
- live config rollout — TA-13;
- numeric budgets — TA-14.

## 3. Authoritative Acquisition State Machine

The server owns the state of each ordinary Capture Opportunity.

Conceptual state:

```text
IdleAvailable
    ↓ BeginClaim accepted
Claimed
    ↓ attempt start accepted
AttemptActive
    ├── Failure/Cancel/Invalidation
    │      ↓
    │  Releasing
    │      └── IdleAvailable or encounter terminal
    │
    └── CaptureSuccess
            ↓
        Provisional
            ↓
        TransportActive
            ├── Character failure/reset -> Interrupted -> release/terminal
            ├── disconnect -> TransportGrace -> resume or expire
            └── Secure Point extraction
                    ↓
              FinalizationPending
                    ↓ durable P2 success
                 Secured
                    ↓
              WorldRoleTerminal
```

Controlled shutdown adds one narrow branch:

```text
TransportActive
    + authoritative server Draining state
    -> ProtectedShutdownFinalizationPending
    -> same P2 Secured commit
```

### CAP-STATE-01 — State transitions are server-only

The client sends semantic intent/input, never a requested next authoritative state.

### CAP-STATE-02 — One transition owner per Creature Instance

The acquisition domain serializes state mutation for each CreatureInstanceId.

### CAP-STATE-03 — Every transition increments TA-6 runtimeRevision

Commands/timers using stale revision cannot mutate the current state.

## 4. In-Memory Concurrency Model

Ordinary claim/capture state is session-local and does not require DataStore writes before finalization.

### CONC-01 — Per-creature mutation is serialized

For one CreatureInstanceId, claim/attempt/custody transitions execute through one in-memory command/state owner.

### CONC-02 — Claim check-and-set does not yield

The critical sequence:

1. resolve runtime entity;
2. validate current state/eligibility;
3. assign claim epoch/claimant;
4. increment revision;

must not yield to another command between check and mutation.

### CONC-03 — External/P2 work occurs after technical reservation

If a future TA-8 capture attempt cost requires persistence, the creature first enters an internal non-competing accepted/reserved state, then the application coordinator performs the cost transaction before exposing AttemptActive.

This prevents two players from both spending on one single-award creature.

## 5. Engagement Claim Identity

Each accepted claim has a server-generated `claimId` / claim epoch associated with:

- CreatureInstanceId;
- claimant UserId/session;
- characterGeneration;
- starting runtimeRevision;
- accepted time;
- inactivity/range deadline;
- challenge definition/context snapshot.

### CLAIM-01 — ClaimId is not Creature ownership

### CLAIM-02 — ClaimId changes for a genuinely new claim

Releasing and re-engaging the same creature uses the same CreatureInstanceId/Variant Identity but a new claim identity.

### CLAIM-03 — Claim commands must match current claim identity

Stale input from an earlier claim cannot affect a newer claimant.

## 6. Simultaneous Claim Arbitration

Many clients can attempt BeginClaim nearly simultaneously.

### ARB-01 — First accepted authoritative transition wins

"First" means the first request that reaches the server's serialized per-creature state owner and passes all current eligibility checks.

It does not mean:

- lowest client timestamp;
- earliest local animation;
- closest client-reported position;
- lowest ping;
- premium status.

### ARB-02 — Server does not trust client timestamps for ordering

### ARB-03 — Losers receive a current-state rejection

No attempt cost is consumed for a request that never became the accepted claim.

### ARB-04 — No waitlist baseline

After claim release, eligible players compete again under current state.

Event-specific multi-award semantics belong to TA-10.

## 7. Capture Eligibility Pipeline

Before accepting an ordinary claim, server validation includes:

1. Player Session is TA-4 Ready;
2. valid active Character Presence if required;
3. creature exists and is IdleAvailable;
4. runtimeRevision/current content identity valid;
5. target is an ordinary Capture Opportunity;
6. server spatial/context validation passes;
7. world/progression access permits interaction;
8. player has no active ordinary Transport Custody;
9. current Collection Capacity state is known and ordinary acquisition is not blocked by known-full/unresolved overflow;
10. capture capability/tool/cooldown requirements from TA-8 pass;
11. onboarding/event reservation rules pass;
12. no valid competing claim already exists;
13. server is not draining/closing capture admission.

### ELIG-01 — Capacity is checked both at initiation and finalization

Known lack of capacity blocks new ordinary initiation.

A later capacity race cannot delete a legitimately completed capture.

## 8. Capture Attempt Acceptance

Once a claim exists, starting the Capture Attempt is a separate accepted transition.

### ATT-01 — Attempt start validates current claim and character generation

### ATT-02 — Attempt cost, if one exists later, is charged only after accepted initiation

GDS-8 baseline has no mandatory universal per-attempt Energy tax.

### ATT-03 — Duplicate network delivery cannot start/charge twice

TA-3 request correlation plus server claim/attempt state and TA-4 operation identity protect any persistent cost.

### ATT-04 — Attempt has a server-owned bounded lifecycle

Exact challenge windows are TA-14/TA-17 tuning.

## 9. Capture Challenge Input

Challenge-specific client input is treated as evidence of player action, not outcome.

Examples may include:

- Primary Action timing;
- directional choice;
- target selection;
- bounded position/movement state;
- explicit cancel.

### INPUT-01 — Inputs are schema/rate/context validated through TA-3

### INPUT-02 — Server owns time windows

Client-reported elapsed time is advisory at most.

### INPUT-03 — Server validates character/entity state at consequential steps

### INPUT-04 — Input history is bounded

No unbounded event log is kept for one attempt.

### INPUT-05 — Challenge definition must be cross-device compatible

Technical implementation cannot require a higher input rate/precision than GDS allows.

## 10. Capture Resolution

A Capture Attempt terminates as exactly one of:

- Success;
- Failure;
- Cancel;
- Invalidation.

### RES-01 — Terminal attempt result is server-generated

### RES-02 — A terminal attempt result is immutable

Late packets cannot change Failure into Success or vice versa.

### RES-03 — Success may depend on validated performance + authored server-private configuration + optional server RNG

### RES-04 — Failure/cancel/invalidation never creates ownership

### RES-05 — Capture performance never rerolls Variant Identity

## 11. Randomness Authority

MonsterVault uses a first-party server-owned RNG abstraction.

Production baseline:

- server-only generator;
- Roblox `Random` as engine pseudorandom primitive;
- no seed supplied by the client;
- no replicated RNG state;
- no client-side reward/variant roll.

Testing baseline:

- injectable deterministic seeded RNG/fake sequence;
- exact boundary cases reproducible.

### RNG-01 — Random draws occur only after eligibility context is validated

### RNG-02 — One logical outcome is rolled once

Retries read the already-created outcome/state rather than draw again.

### RNG-03 — RNG stream state is not gameplay identity

Creature/Operation IDs remain independent.

### RNG-04 — Production seed/internal state is not exposed

### RNG-05 — Content probabilities come from one validated ContentSnapshot

A resolution does not mix weights from two config snapshots.

## 12. Weighted Selection Primitive

When a downstream/private definition requires weighted random selection:

1. gather eligible canonical entries;
2. validate all weights are finite and non-negative;
3. remove/ignore explicitly zero-weight ineligible outcomes as schema defines;
4. validate total eligible weight > 0;
5. use stable canonical ordering for deterministic test behavior;
6. take one uniform server RNG sample;
7. map it through cumulative weights;
8. persist/attach the selected semantic result to the entity before it can be rerolled.

### WEIGHT-01 — Selection without replacement when uniqueness is required

Mutation selection cannot pick the same Mutation twice.

### WEIGHT-02 — Floating endpoint handling is explicit

If the engine sample reaches the numeric upper endpoint, selection clamps to the last eligible positive-weight entry rather than producing "no result."

### WEIGHT-03 — No client or spend-derived hidden modifier

## 13. Variant Generation Pipeline

TA-9 supplies a newly generated Creature Instance candidate with:

- CreatureInstanceId;
- SpeciesId;
- SpawnContextId;
- applicable ContentSnapshotId / server-private generation context.

Before individual actionability TA-7 performs:

1. resolve Species definition;
2. resolve Species Rarity;
3. resolve eligible Mutation configuration;
4. determine zero/single/compound mutation outcome according to authored private generation rules;
5. choose compatible Mutation IDs without replacement;
6. canonicalize Mutation set;
7. resolve eligible Trait configuration;
8. generate/finalize Trait identity according to authored rules;
9. construct Variant Signature;
10. determine Protected Variant status inputs;
11. store immutable Variant Identity on the runtime record;
12. expose only disclosure-safe/readability fields to projection.

### VAR-01 — Variant generation is one-time per CreatureInstanceId

### VAR-02 — Same surviving instance never re-enters generation pipeline

### VAR-03 — Hidden presentation does not mean unresolved identity

## 14. Mutation Count / Compatibility

GDS-6 baseline permits 0–2 Mutations.

### MUT-01 — More than two is invalid without GDS change control

### MUT-02 — Compound selection requires pair compatibility

Compatibility is resolved from TA-5 private validated content.

### MUT-03 — Canonical Mutation set is order-independent

Variant Signature sorts/canonicalizes Mutation IDs according to stable ID ordering.

### MUT-04 — Content updates do not invalidate existing legitimate compounds

Generation eligibility affects future entities; existing Variant Identity remains.

## 15. Trait Generation

Traits are separate from Mutations.

### TRAIT-01 — Trait identity is finalized alongside Variant Identity before relevant irreversible decision

### TRAIT-02 — If a Trait affects immediate capture decisions, disclosure-safe effect information must be available before irreversible commitment

### TRAIT-03 — Trait generation cannot alter ownership rules

### TRAIT-04 — No post-capture baseline trait reroll

## 16. Variant Identity Record

Conceptual immutable runtime/persistent value:

```text
VariantIdentity {
    speciesRarityId,
    mutationIdsCanonical,
    traitIds,
    variantSignature,
    availability/provenance generation context as required,
    contentSnapshotId,
    protectedVariantReasons
}
```

Exact persisted schema is locked TA-17 with TA-4/5 compatibility.

### VARREC-01 — It contains semantic IDs, not display strings/assets

### VARREC-02 — It survives capture, transport, extraction, storage and trade

### VARREC-03 — Balance-effect values are not necessarily snapshotted into identity

Current effect values may resolve from content while identity remains unchanged unless provenance semantics require generation-time data.

## 17. Protected Variant Classification

At first Secured Ownership Finalization, Protected Variant classification is true when any GDS-6 criterion applies:

- Legendary Species;
- Extreme Mutation;
- Compound-Mutated Variant;
- explicit event/legacy protection marker;
- later equivalent authoritative marker.

### PROTECT-01 — Classification uses actual finalized Variant Identity

### PROTECT-02 — First securisation auto-enables Creature Lock

### PROTECT-03 — Auto-lock is part of the same P2 finalization bundle

No timing gap exists where the high-value new creature is persisted unlocked.

## 18. Capture Success to Provisional Capture

When server capture resolution is Success:

1. current Attempt becomes terminal Success;
2. ordinary contesting ends;
3. creature state becomes Provisional;
4. server generates/assigns a `custodyId` / custody epoch;
5. one UserId becomes Transport Custody holder;
6. a stable server-owned `ownershipFinalizationOperationId` is generated for this provisional creature;
7. transport state becomes active;
8. client receives explicit provisional-not-secured projection.

### PROV-01 — No Player Profile creature ownership is written at Capture Success

### PROV-02 — Provisional state is session-local

### PROV-03 — One player has at most one ordinary active Transport Custody

### PROV-04 — Another player cannot claim/steal this creature through ordinary interaction

## 19. Transport State

Authoritative Transport record includes:

- CreatureInstanceId;
- custodyId;
- holder UserId/session identity;
- valid characterGeneration where needed;
- Variant Identity reference;
- start time;
- owning world/server identity;
- current state;
- grace expiry if suspended;
- ownershipFinalizationOperationId;
- runtimeRevision.

### TRAN-01 — Fast travel/action gates query this authoritative state

### TRAN-02 — Physical carrier/following Model is a projection only

### TRAN-03 — Crowding/other-player contact cannot transfer custody

## 20. Character Failure / Reset During Transport

On authoritative Character failure/reset/Recovery:

1. validate current custody record;
2. mark transport interrupted;
3. clear player's ordinary active custody;
4. resolve creature under GDS-5 encounter interruption semantics;
5. do not call ownership finalization;
6. do not teleport provisional value to Secure Point.

### REC-CAP-01 — Recovery is never extraction

## 21. Disconnect and Transport Grace

GDS-5 requires bounded server-local Transport Grace for unexpected client disconnect.

### GRACE-01 — Grace is session-local suspension, not persistence

A grace record contains the existing provisional CreatureInstanceId/custody identity and expiry.

### GRACE-02 — TA-4 Player Profile session may close normally

Transport Grace does not itself require holding the persistent profile lease.

### GRACE-03 — Resume requires same server session/world

On rejoin:

1. same UserId returns to the same running Roblox server;
2. TA-4 profile becomes Ready again;
3. grace record has not expired;
4. creature/custody record still exists unchanged;
5. no conflicting terminal/finalized outcome occurred;
6. server rebinds custody to the new Player Session/Character Presence.

No cross-server provisional transfer exists.

### GRACE-04 — Grace expiry ends provisional state without ownership

### GRACE-05 — Grace is not active valid custody for Protected Shutdown Finalization

If the player is already disconnected/suspended in grace when the server enters controlled shutdown, TA-7 does not fabricate ownership from the suspended state.

This avoids writing into a profile session the server no longer owns.

## 22. Voluntary Leave versus Network Disconnect

Current Roblox `Players.PlayerRemoving` supplies `PlayerExitReason`, but the currently documented enum is coarse (`Unknown`, `PlatformKick`, `CreatorKick`) and does not by itself prove platform-menu voluntary leave versus network loss.

TA-7 therefore locks a conservative mapping:

### EXIT-01 — Explicit trusted MonsterVault voluntary-exit intent ends custody

If a server-validated in-game exit flow has explicitly classified the departure as voluntary, no grace is created.

### EXIT-02 — CreatorKick / deliberate server removal ends custody

No reconnect grace is granted unless a later safety-specific rule explicitly requires it.

### EXIT-03 — Ambiguous Unknown transport exit is treated as unexpected disconnect for bounded grace

Reason:

- the platform signal cannot reliably prove voluntary versus connectivity loss;
- grace grants no ownership;
- it only preserves a short same-server resume opportunity;
- this is safer than silently destroying provisional value because of an ambiguous platform signal.

### EXIT-04 — A client cannot self-declare "disconnect" to obtain ownership

Grace never finalizes value and cannot cross servers.

This is the platform-constrained implementation mapping of GDS-5's interruption intent.

## 23. Secure Point Extraction Validation

A Secure Point request/trigger is accepted only when:

1. Player Session Ready;
2. current Character Presence valid;
3. holder has active Transport Custody;
4. custodyId/CreatureInstanceId match current record;
5. target is a TA-9 eligible Secure Point;
6. server spatial/context validation passes;
7. no conflicting capture finalization is already terminal;
8. server is permitted to admit the commit;
9. capacity/profile state can be revalidated for finalization.

### SECUREPOINT-01 — Touched/Prompt alone never proves extraction

### SECUREPOINT-02 — Secure Point spam converges on one operation ID/outcome

## 24. Finalization Operation Identity

The server generates one `ownershipFinalizationOperationId` when ordinary Provisional Capture is created.

Both possible secure paths use that same logical operation:

- normal Extraction Completion;
- controlled Protected Shutdown Finalization.

### OP-CAP-01 — Retry uses the same operation identity

### OP-CAP-02 — A second request cannot mint a second Creature entry

### OP-CAP-03 — The operation is tied to exact CreatureInstanceId + intended UserId

### OP-CAP-04 — Network request IDs never replace this durable identity

## 25. Secured Ownership P2 Transaction

Normal extraction finalization is a TA-4 P2 durable-before-final-ack transaction.

The application coordinator provides one immutable finalization payload containing:

- ownershipFinalizationOperationId;
- CreatureInstanceId;
- SpeciesId;
- immutable Variant Identity;
- origin/provenance;
- intended owner UserId;
- current capture source/occurrence context;
- Protected Variant reasons;
- discovery facts to derive;
- capacity reconciliation input.

Inside one Player Profile aggregate commit, TA-7/TA-8-compatible mutation performs:

1. confirm operation not previously applied;
2. confirm CreatureInstanceId not already present;
3. confirm persistent ownership target is this profile;
4. place creature in ordinary eligible collection state or Overflow-Held on race;
5. apply initial Creature Lock if Protected Variant;
6. record Species Discovery if first;
7. record Mutation Discovery entries if first;
8. record Variant Discovery if first;
9. record provenance/acquisition metadata;
10. record operation idempotency/result;
11. commit once.

### OWN-01 — Client receives "Secured" only after durable P2 success

### OWN-02 — The world runtime role ends after commit/reconciliation

### OWN-03 — Profile failure does not silently destroy provisional state before the outcome is known

The runtime enters FinalizationPending and reconciles/retries within owning safety bounds.

## 26. Capacity Race Reconciliation

TA-8 owns capacity schema/rules.

TA-7 locks the transaction behavior:

### CAPACITY-01 — Known full/unresolved overflow blocks new ordinary initiation

### CAPACITY-02 — Finalization revalidates capacity

### CAPACITY-03 — If capacity became unavailable after a legitimately accepted attempt, finalization still succeeds into Overflow-Held

### CAPACITY-04 — Overflow-Held does not alter CreatureInstanceId/Variant Identity

### CAPACITY-05 — Capacity race cannot turn success into deletion

## 27. Discovery Resolution

Secured Ownership Finalization is the discovery trigger.

### DISC-01 — Seeing/claiming/capture success does not grant persistent discovery

### DISC-02 — Species Discovery, Mutation Discovery and Variant Discovery apply in the same exact-once P2 profile transaction where practical

### DISC-03 — Historical discoveries are monotonic facts

Later release/trade does not erase them.

### DISC-04 — Compound signature is Species + canonical Mutation set

Trait permutations do not create baseline Variant Discovery keys.

## 28. Ordinary Capture Reward Boundary

GDS-8 explicitly defines no baseline per-capture Energy payout.

TA-7 therefore treats the secured creature + authorized discovery/milestone changes as the ordinary capture outcome.

### REWARD-01 — No implicit Energy grant just because capture finalized

### REWARD-02 — First-time/milestone/world/event reward owners may attach explicitly authorized P2 rewards

### REWARD-03 — Attached rewards use stable operation sub-IDs or a single atomic finalization operation so retry cannot duplicate them

### REWARD-04 — Capture system never invents rewards from client fields

## 29. Capture Difficulty Inputs

The challenge resolver may consume server-approved inputs such as:

- Species/capture content definition;
- current stable Variant properties where GDS allows;
- TA-8 Capture Capability;
- event/world context;
- validated player challenge performance;
- optional server RNG.

### DIFF-01 — Species Rarity alone is not a hard-coded formula

### DIFF-02 — Mutation effect must be readable before consequential commitment when GDS requires it

### DIFF-03 — Hidden identity cannot retroactively reinterpret valid player input as failure

### DIFF-04 — Premium/spending state is not a capture-success/variant hidden input

## 30. Capture Randomness versus Variant Randomness

These are distinct.

### RNG-CAP-01 — Variant randomness happens before individual actionability

### RNG-CAP-02 — Capture-result randomness, if configured, occurs per accepted attempt

A new legitimate attempt may receive a new capture-result random sample because it is a new attempt, but that sample cannot modify the creature's already-finalized Variant Identity.

### RNG-CAP-03 — Retransmission of the same attempt/result does not redraw

### RNG-CAP-04 — Capture success random draw cannot create multiple rewards

## 31. Claim Failure / Opportunity Release

On Failure/Cancel/Invalidation:

1. terminate attempt;
2. settle any TA-8 attempt-cost consequence once;
3. clear claim;
4. if the creature/encounter still survives, return same CreatureInstanceId to IdleAvailable;
5. preserve Variant Identity;
6. apply bounded re-engagement/grief-control state if configured;
7. otherwise let owning encounter state terminate normally.

### RELEASE-01 — Release does not call the Variant generator

### RELEASE-02 — Release does not duplicate world entity

## 32. Claim Griefing Controls

TA-7 provides technical hooks for:

- inactivity timeout;
- max range/context invalidation;
- bounded post-abandon claimant cooldown;
- repeated abort telemetry;
- rate limiting through TA-3.

### GRIEF-01 — No indefinite claim

### GRIEF-02 — No premium/friend/party priority baseline

### GRIEF-03 — Anti-grief controls cannot delete existing Protected Variant identity

Exact timings are TA-14.

## 33. Controlled Shutdown Protection

GDS-5 authorizes a narrow exception: valid active Provisional Capture / Transport Custody can be secured during an orderly server-originated shutdown.

TA-7 defines:

### SHUT-CAP-01 — Server drain state is trusted internal state

Only the server bootstrap/shutdown coordinator can enter it.

### SHUT-CAP-02 — Stop new capture admission first

No player can begin claims to exploit imminent shutdown.

### SHUT-CAP-03 — Snapshot only active valid Transport Custody

Not:

- IdleAvailable creatures;
- claims;
- AttemptActive without prior Capture Success;
- expired custody;
- TransportGrace suspended after disconnect.

### SHUT-CAP-04 — Invoke the same ownershipFinalizationOperationId

No separate "shutdown reward" identity.

### SHUT-CAP-05 — P2 commit must still succeed

If persistence cannot durably finalize within shutdown capability, architecture cannot fabricate success.

### SHUT-CAP-06 — Abrupt crash has no guaranteed provisional finalization

Matches GDS-5.

## 34. Event Multi-Award Boundary

TA-10 may create Personal Event Capture Opportunities.

### EVENT-CAP-01 — Each personal opportunity must have its own CreatureInstanceId

### EVENT-CAP-02 — TA-7 processes each creature independently

### EVENT-CAP-03 — One shared event creature is never duplicated into multiple owners

### EVENT-CAP-04 — Event can replace ordinary claim arbitration only through explicit TA-10 contract

Variant/finalization anti-reroll/exact-once rules remain.

## 35. Onboarding-Protected Capture

TA-7 supports a personal/reserved onboarding opportunity.

### ONBOARD-01 — Unrelated players cannot establish the claimant slot for another player's protected tutorial opportunity

### ONBOARD-02 — Variant identity still finalizes once

### ONBOARD-03 — Capture/extraction remain real state transitions

### ONBOARD-04 — Failure/retry can be tuned forgivingly without duplicating the creature/reward

## 36. Server Transition / Server Hop

### HOP-01 — Ordinary unfinalized claim/attempt/provisional state does not transfer to another server

### HOP-02 — Same-server grace resume is not cross-server transfer

### HOP-03 — Finalized ownership survives through TA-4

### HOP-04 — A new server population contains distinct session-local World Creature instances

No attempt is made to "find the same rare creature" on another server.

## 37. Client Projection Contract

TA-12 receives presentation states such as:

- Available;
- ClaimedByYou / unavailable due claim;
- AttemptActive;
- CaptureSuccess / Provisional;
- TransportActive;
- Grace/reconnecting where relevant;
- FinalizationPending;
- Secured;
- Failed/Released/Invalidated.

### UI-CAP-01 — Provisional is never labeled secured

### UI-CAP-02 — Protected/Variant cues follow GDS disclosure rules

### UI-CAP-03 — Client animations cannot move authority state

## 38. Security / Exploit Boundary

TA-7 assumes hostile clients may:

- spam BeginClaim;
- fake distance;
- send challenge input early/late;
- fabricate success;
- replay old claim/custody IDs;
- spam Secure Point;
- manipulate physics/carrier model;
- reconnect around outcomes;
- suppress voluntary-exit signal;
- attempt shutdown spoofing.

Countermeasures:

- TA-3 validation/rate control;
- per-creature serialized state;
- server time/context;
- stable claim/custody/op IDs;
- revision/generation checks;
- P2 idempotency;
- server-only shutdown state;
- no client RNG/result authority.

## 39. Randomness / Statistical Validation

TA-15 must validate weighted-resolution code using:

- deterministic seeded/fake RNG;
- boundary values;
- zero/invalid weights;
- compatibility exclusions;
- no-duplicate selection;
- compound eligibility;
- property/statistical tests over large sample counts within tolerance;
- snapshot invariance;
- no reroll on retry.

### STAT-01 — Statistical tests verify implementation, not promise exact player outcomes

Random content remains probabilistic.

## 40. Observability

TA-13 telemetry should support:

- eligibility rejection category;
- claim accepted/contested/released;
- claim duration/abandon rate;
- attempt accepted/result;
- challenge validation rejection;
- capture-resolution configuration/snapshot;
- Variant category/frequency aggregate (privacy-safe);
- Protected Variant generation/finalization;
- Provisional/Transport transitions;
- grace enter/resume/expiry;
- extraction validation result;
- finalization operation outcome/latency;
- Overflow-Held race occurrence;
- shutdown-protection finalizations;
- duplicate/replay rejection;
- suspected claim griefing.

Do not expose production RNG internal state to clients/logs unnecessarily.

## 41. Failure / Retry Matrix

### Network result lost after accepted claim

Client reconciles current claim state; no second claim.

### Network result lost after Capture Success

Current server state remains Provisional/Transport; client snapshot reconciles.

### DataStore result lost after P2 finalization

Same ownershipFinalizationOperationId is reconciled/retried; no duplicate Creature.

### Client disconnect during attempt

Attempt interrupts according to GDS; no success unless already server-finalized.

### Client disconnect during transport

TransportGrace; same-server resume only.

### Server crashes during transport

No guaranteed finalization.

### Controlled server shutdown during active transport

Protected Shutdown Finalization attempts same P2 commit once.

## 42. Current Roblox Capture/Security Platform Snapshot

TA-7 reviewed official Roblox documentation current on 2026-09-18.

Confirmed platform facts:

- Roblox `Random` provides server-usable pseudorandom generators and can be internally seeded or explicitly seeded;
- client input/remotes affecting rewards/progression/shared state must be server validated;
- clients can fabricate remote arguments and manipulate locally simulated physics;
- ProximityPrompt/other client-triggered interaction paths require server-side context/rate validation;
- `Players.PlayerRemoving` currently supplies `PlayerExitReason`;
- the currently documented `PlayerExitReason` values are coarse and do not provide a trusted voluntary-leave-versus-network-loss distinction by themselves.

Dated evidence is recorded in `TA7_ROBLOX_CAPTURE_RANDOMNESS_SNAPSHOT.md`.

## 43. Downstream Ownership

### TA-8

- Collection Capacity exact schema;
- Capture Capability/equipment;
- attempt cost/refund if introduced;
- Overflow-Held placement representation;
- post-security collection/Vault state.

### TA-9

- Species spawn selection;
- SpawnContext/private spawn weights;
- encounter scheduler/lifetimes;
- Secure Point authoritative indexes.

### TA-10

- event multi-award capture allocation;
- Event reward identities;
- social/party capture overrides where explicitly designed.

### TA-12

- capture challenge UI/input/presentation;
- provisional/secured feedback;
- accessibility.

### TA-13

- live C2 capture tuning/telemetry.

### TA-14

- claim/attempt/grace timings;
- RNG/resolution performance;
- capture rate budgets.

### TA-15

- concurrency/fuzz/statistical/idempotency/shutdown tests.

### TA-17

- actual capture service/domain APIs;
- RNG abstraction source;
- exact operation/claim/custody ID representations;
- exact profile Creature/Discovery schema;
- exact remote route names.

## 44. Open Questions

There are **zero TA-7-blocking open questions**.

Correctly downstream:

- exact Capture Challenge mechanic/formula — TA-12/TA-17;
- exact challenge duration/range/cooldown — TA-14/TA-17;
- exact Mutation/Trait rates — content/TA-9;
- exact capture capability/equipment formulas — TA-8;
- exact collection-capacity schema — TA-8;
- exact event capture overrides — TA-10;
- exact visual reveal timing — TA-12;
- implementation APIs — TA-17.

## 45. Architecture-Complete Checklist

- [x] authoritative acquisition state machine defined;
- [x] per-creature serialization defined;
- [x] simultaneous claim arbitration defined;
- [x] claim/attempt identities defined;
- [x] capture eligibility pipeline defined;
- [x] challenge input authority defined;
- [x] capture resolution terminal semantics defined;
- [x] server RNG abstraction defined;
- [x] weighted selection primitive defined;
- [x] Variant Identity generation/finalization pipeline defined;
- [x] mutation count/compatibility/canonical ordering defined;
- [x] Trait generation boundary defined;
- [x] Protected Variant classification/auto-lock defined;
- [x] Provisional Capture/custody state defined;
- [x] disconnect Transport Grace defined;
- [x] ambiguous PlayerExitReason mapping defined;
- [x] Secure Point extraction validation defined;
- [x] stable ownershipFinalizationOperationId defined;
- [x] P2 ownership/discovery/protection transaction defined;
- [x] capacity race -> Overflow-Held rule defined;
- [x] ordinary reward boundary defined;
- [x] no-reroll failure/release behavior defined;
- [x] claim griefing hooks defined;
- [x] controlled-shutdown finalization defined;
- [x] event/onboarding boundaries defined;
- [x] server-hop/retry/replay behavior defined;
- [x] security/statistical/observability/testability defined;
- [x] current Roblox randomness/security/exit signaling reviewed;
- [x] zero TA-7-blocking questions.
