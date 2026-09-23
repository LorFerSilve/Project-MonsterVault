# TA-10 — Social Systems, Server Events, Cross-Server Coordination, and Trading

> **Status:** Architecture Complete  
> **Owning TA phase:** TA-10 — Social Systems, Server Events, Cross-Server Coordination, and Trading  
> **Authority:** Transient Party/social runtime state, social coordination and contribution accounting, Friendly Challenge runtime boundaries, event occurrence identity/lifecycle, cross-server event discovery/notification, server-local event instances, event contribution/rewards, event multi-award capture orchestration, direct same-server bilateral trading, Trade Reservations, Trade Revision/consent, durable cross-profile Trade transaction protocol, cooldown/provenance/discovery effects, recovery and exact-once semantics  
> **Depends on:** TA-0 through TA-9 Architecture Complete; GDS-10, GDS-11, GDS-12, GDS-15, GDS-17

## 1. Purpose

TA-10 defines how MonsterVault adds consent-based social play, live events and safe creature trading without weakening the already-closed ownership, capture, world, persistence or economy contracts.

The architecture contract is:

> **Party and ordinary social state are transient, same-server and non-authoritative over another player's value. Shared objectives record contribution per player and finalize personal rewards exactly once. Event Occurrences have stable wall-clock identity shared across servers while each server runs its own bounded Server Event Instance; cross-server messaging accelerates discovery but never becomes durable truth. Ordinary event modifiers affect only future generation. Trading is direct, bilateral and same-server. Negotiation is transient, but once authoritative Trade Commit begins it is coordinated by a durable transaction journal and transaction-fenced participant profiles so a crash, retry or disconnect cannot duplicate, lose or partially expose creature ownership.**

No gameplay Luau modules are implemented in TA-10. Gameplay implementation remains blocked until TA-17.

## 2. Domain Ownership

TA-10 owns:

- Party identity, membership, leadership, invites and same-server rejoin grace;
- Social Ping and Party waypoint runtime routing;
- Shared Objective contribution accounting and personal Collaboration Reward orchestration;
- Friendly Challenge session state;
- Showcase/Visitor runtime permission projection boundary;
- Event Template runtime interpretation;
- Global Event Window and Event Occurrence identity;
- server-local Server Event Instance lifecycle;
- event contribution, completion and reward operation identities;
- persistent personal Event Cooldown state and wall-clock reconciliation;
- Event Spawn Modifier injection into TA-9 prospective Spawn Context generation;
- Event Resolution Grace;
- event multi-award qualification and creation of distinct personal capture opportunities;
- event cross-server discovery/notification;
- Trade Invite/Session/Revision/Ready/Final Confirmation state;
- exact-instance Trade Reservations;
- cross-profile Trade transaction journal;
- transaction-fenced participant profile mutation and recovery;
- post-trade cooldown/provenance/discovery/protection effects.

TA-10 does not own:

- permanent social platform policy, reporting/blocking, parental or age eligibility — TA-12/15 implementation from GDS-15;
- Marketplace receipt processing or paid entitlements — TA-11;
- final Party/event/trade UI and accessibility — TA-12;
- analytics/experimentation/live rollout infrastructure — TA-13;
- exact request/MemoryStore/Messaging/DataStore budgets — TA-14;
- CI/fault/security harnesses — TA-15;
- concrete module/store/topic/tag/remote names — TA-17.

## 3. Social Runtime Scope

Baseline Parties, Party Invites, Pings, Friendly Challenges and Trade Sessions are server-session-local.

### SOCIAL-10-01

No ordinary Party survives a server transition.

### SOCIAL-10-02

Persistent player value created during social play survives normally because the outcome is owned by its profile domain, not the Party runtime.

### SOCIAL-10-03

Roblox friendship may be queried as an invitation/visibility input where allowed, but friendship never becomes ownership, progression or consent authority.

## 4. Party Identity and Membership

Each Party has one server-generated PartyId.

Conceptual runtime record:

- PartyId;
- member UserIds, maximum four;
- leader UserId;
- join sequence;
- partyRevision;
- active invites;
- rejoin-grace reservations;
- bounded Ping state;
- cleanup owner.

### PARTY-10-01

A player belongs to at most one Party in a server.

### PARTY-10-02

Joining requires explicit acceptance of a still-valid invite/join request.

### PARTY-10-03

Leadership is coordination authority only.

### PARTY-10-04

Every membership mutation increments partyRevision so stale invites/actions can be rejected.

### PARTY-10-05

Party state is never persisted in Player Profile.

## 5. Party Mutation Serialization

Party-local mutations are serialized by PartyId through one server-owned mutation queue/critical section.

Any mutation that can change a player's Party affiliation additionally acquires a participant-scoped membership guard keyed by UserId against one server-owned membership index. This prevents the same player from concurrently joining two different Parties whose PartyId queues are otherwise independent.

When an operation spans a participant guard and one or more Party queues, locks/guards are acquired in deterministic key order and released in reverse order so cross-Party admission cannot deadlock.

Operations include:

- invite;
- accept;
- decline/expire;
- leave;
- remove member;
- leadership transfer;
- disband;
- same-server rejoin.

### PARTY-10-06

Two simultaneous accept operations cannot overfill the four-seat cap.

### PARTY-10-07

Deterministic leader succession uses join sequence among remaining eligible members.

### PARTY-10-08

A Party acceptance/rejoin must atomically validate and transition the server membership index while holding the participant-scoped membership guard.

### PARTY-10-09

Two concurrent valid invitations for the same player into different Parties can produce at most one membership transition; the loser revalidates the membership index and fails safely.

## 6. Party Rejoin Grace

Unexpected disconnect may reserve the player's Party Seat for a short same-server grace window.

The reservation contains:

- PartyId;
- UserId;
- prior join sequence;
- grace deadline;
- partyRevision at disconnect.

### REJOIN-10-01

Grace does not persist cross-server or after server shutdown.

### REJOIN-10-02

Absent players accumulate no contribution merely because a seat is reserved.

### REJOIN-10-03

If the Party is disbanded or membership becomes invalid, grace cannot resurrect it.

## 7. Social Pings

Pings are predefined structured messages.

The server validates:

- sender membership;
- ping kind;
- target semantic/runtime ID if any;
- target disclosure safety;
- rate limits;
- recipient scope;
- current runtime revision.

### PING-10-01

No arbitrary user text is required.

### PING-10-02

A Ping cannot create claims, discoveries, objective credit, rewards or spawn reservations.

### PING-10-03

Pings are P0 runtime state and may be dropped under backpressure.

## 8. Shared Objective Contribution

TA-10 adds contribution tracking only for objectives explicitly declared cooperative.

Conceptual per-instance participant record:

- ObjectiveInstanceId;
- UserId;
- contribution counters/facts;
- firstEligibleAt;
- eligibility finalization state;
- rewardOperationId.

### CONTRIB-10-01

Party membership/proximity is insufficient.

### CONTRIB-10-02

Only server-observed objective-specific actions contribute.

### CONTRIB-10-03

Contribution state is bounded and cannot grow by raw event spam.

### CONTRIB-10-04

Leaving/removal after eligibility does not erase already-earned eligibility if the GDS participation window remains valid.

## 9. Collaboration Rewards

Each eligible player's persistent completion/reward is a separate single-profile P2 operation.

Operation identity derives from:

- ObjectiveInstanceId;
- reward slot/kind;
- UserId.

### COLLAB-10-01

One objective can reward several eligible players without sharing one wallet mutation.

### COLLAB-10-02

Retries/Party churn cannot duplicate the same personal reward.

### COLLAB-10-03

Energy flows through TA-8's normal reason-coded/deferred-grant path.

## 10. Friendly Challenges

Friendly Challenge runtime state is explicit opt-in and server-session-local.

State includes:

- ChallengeId;
- definition/version;
- participant set;
- acceptance state;
- start boundary;
- authoritative result inputs;
- terminal result.

### CHALLENGE-10-01

No participant is enrolled implicitly.

### CHALLENGE-10-02

Baseline result is status/session feedback, not a transferable-value transaction.

### CHALLENGE-10-03

No staking, Energy escrow, creature escrow, damage, knockback or forced movement exists.

## 11. Player Collision Boundary

TA-10 requires player-player collision configuration that prevents ordinary body-blocking.

### COLLISION-10-01

Player Characters must not physically deny Safe Routes, Secure Points, Recovery Anchors, Travel Nodes, Vault Access or encounter interactions.

### COLLISION-10-02

Collision implementation is a physics/presentation mechanism and cannot override capture/interaction authority.

Exact collision-group names/settings are TA-17.

## 12. Showcase and Visitor Projection

Showcase/Visitor access is read-only.

The owner controls a bounded Visitor Access Policy.

### VISITOR-10-01

Visitor access never grants ownership, Discovery, production, trade eligibility or mutation authority.

### VISITOR-10-02

Only disclosure-safe profile projections are exposed.

### VISITOR-10-03

Changing visitor policy affects future access, not historical value.

## 13. Event Occurrence Identity

TA-10 distinguishes:

- EventTemplateId — static TA-5 content identity;
- EventOccurrenceId — one global wall-clock occurrence;
- ServerEventInstanceId — one server-local realization;
- ObjectiveInstanceId — event objective runtime identity;
- RewardOperationId — exact-once personal outcome;
- PersonalEventOpportunityId / CreatureInstanceId — distinct personal capture outcome.

### EVENT-ID-10-01

EventOccurrenceId is stable across servers.

### EVENT-ID-10-02

ServerEventInstanceId is unique per server realization and is not used as the player's global completion identity.

## 14. Scheduled Event Occurrences

Scheduled events are derived from validated Event Schedule definitions and server wall-clock time.

A scheduled occurrence declares/pins:

- EventOccurrenceId;
- EventTemplateId;
- start/end Unix timestamps;
- EventSchedule/config snapshot;
- resolution-grace deadline;
- Availability/version references.

### EVENT-SCHED-10-01

Joining another server never restarts start/end time.

### EVENT-SCHED-10-02

A server booting mid-window reconstructs the same current occurrence.

### EVENT-SCHED-10-03

Client time is never used.

## 15. Dynamically Authorized Global Occurrences

An operator/live system may create a non-precomputed occurrence only through a durable occurrence record before it becomes authoritative.

The durable occurrence record stores:

- occurrence ID;
- template/version;
- start/end;
- authorization source;
- status;
- snapshot references.

### EVENT-DYN-10-01

MessagingService publication alone cannot create durable event truth.

### EVENT-DYN-10-02

If notification fails, servers can still discover the occurrence from authoritative configuration/durable state.

## 16. Cross-Server Coordination Strategy

TA-10 deliberately separates durability from acceleration.

### Durable truth

Use standard DataStore/config authority for:

- dynamically authorized occurrence descriptors when needed;
- long-lived occurrence/reward identities that must survive server restarts;
- player completion/reward state.

### MessagingService

Use for low-latency invalidation/announcement hints such as:

- occurrence created/changed/disabled;
- configuration refresh hint;
- operational event notice.

### MemoryStoreService

May be used only for ephemeral cross-server acceleration such as:

- short-lived occurrence cache;
- server liveness/diagnostic routing;
- bounded coordination state that may disappear without corrupting durable outcomes.

### XSERVER-10-01

Neither MessagingService nor MemoryStore is required for correctness of finalized ownership/rewards.

### XSERVER-10-02

A missed message causes delayed refresh at worst, not a different authoritative event outcome.

### XSERVER-10-03

MemoryStore TTL expiry is treated as cache/coordination expiry, never persistent-value deletion.

## 17. Server Event Instance Lifecycle

Each participating server materializes one Server Event Instance for an applicable Event Occurrence.

Lifecycle:

- Dormant/NotApplicable;
- Announced;
- Active;
- Resolving;
- Grace;
- Ended;
- Destroyed.

Runtime record pins:

- occurrence/template IDs;
- server instance ID;
- config/content snapshot;
- phase deadlines;
- local objective/public-progress state;
- Event Zones;
- event-created spawn modifier handles;
- cleanup owner.

### EVENT-LIFE-10-01

Lifecycle phase follows authoritative wall clock and declared occurrence semantics.

### EVENT-LIFE-10-02

A server cannot extend the Global Event Window by restarting.

## 18. Event Spawn Modifiers

Event modifiers are explicit inputs to TA-9 future Spawn Reservations.

### EVENT-SPAWN-10-01

Modifier application is prospective only.

### EVENT-SPAWN-10-02

Already-existing Creature Instances keep Species/Variant identity.

### EVENT-SPAWN-10-03

Every event-created creature records occurrence/template provenance and generation snapshot where applicable.

### EVENT-SPAWN-10-04

Event modifier evaluation never consumes payer/spending state unless GDS authority is materially changed.

## 19. Event Zones and Rifts

Event Zones/Rifts are server-local runtime projections of the current Server Event Instance.

### EVENT-ZONE-10-01

Creating/destroying a zone does not alter permanent Region access.

### EVENT-ZONE-10-02

Zone cleanup is idempotent.

### EVENT-ZONE-10-03

A stale zone from an ended occurrence cannot create new eligible spawns/rewards.

## 20. Event Contribution

Event Contribution is tracked per UserId and objective/occurrence.

Contribution inputs must be server-observed, bounded and semantically meaningful.

### EVENT-CONTRIB-10-01

AFK/presence alone is not contribution.

### EVENT-CONTRIB-10-02

Server hopping does not combine unrelated local public-progress bars into one fake global completion unless the Event Template explicitly defines a persistent personal counter.

### EVENT-CONTRIB-10-03

Party membership alone gives no event reward eligibility.

## 21. Event Personal Rewards

Persistent event rewards use a stable identity:

- EventOccurrenceId;
- reward slot/objective identity;
- UserId.

Finalization is one P2 profile operation.

### EVENT-REWARD-10-01

Reconnect/server-hop/repeated server resolution cannot issue the same personal reward twice.

### EVENT-REWARD-10-02

Event Energy uses TA-8 wallet/deferred-grant semantics.

### EVENT-REWARD-10-03

Event Completion Record and attached reward commit coherently when semantically one outcome.

## 21A. Persistent Personal Event Cooldowns

An Event Template may explicitly define a player-scoped cooldown that prevents repeated activation, qualification or reward cycling across server transitions.

A persistent personal cooldown is Player Profile state under TA-4, keyed by a stable EventCooldownDefinitionId plus its authored semantic scope. Conceptual state records the cooldown definition/scope, cooldownUntilUnixSeconds, source EventOccurrenceId when applicable, config version and lastCooldownOperationId.

### EVENT-COOLDOWN-10-01

Persistent personal cooldown time uses server-observed wall-clock timestamps. Client/device time never starts, shortens, expires or clears it.

### EVENT-COOLDOWN-10-02

Starting or extending a value-sensitive persistent personal cooldown is a P2 profile mutation. When semantically coupled to an activation/completion/reward, the cooldown and outcome commit coherently or share one stable operation identity so a crash cannot grant value while losing the anti-repeat fence.

### EVENT-COOLDOWN-10-03

On profile load, reconnect or server hop, the persisted deadline is reconciled before the guarded event action becomes eligible. Changing servers cannot reset or shorten it.

### EVENT-COOLDOWN-10-04

Expired cooldown records may be compacted idempotently only after authoritative server-time comparison; expiry never fabricates a reward or replays a consumed opportunity.

### EVENT-COOLDOWN-10-05

A cooldown explicitly authored as server-session-local may remain P0 runtime state only when GDS semantics permit that scope. A persistent personal cooldown cannot silently downgrade to local state.

### EVENT-COOLDOWN-10-06

A global/shared cooldown that must survive server changes uses durable/config EventOccurrence/global-window authority rather than a fresh per-server timer.

## 22. Event Resolution Grace

After the occurrence end timestamp, a bounded Grace phase may finish already-active/resolving outcomes.

### EVENT-GRACE-10-01

No new participation starts during Grace.

### EVENT-GRACE-10-02

No new ordinary event Spawn Reservations are created after the declared cutoff unless the template explicitly defines pre-created pending opportunities.

### EVENT-GRACE-10-03

Existing protected/active opportunities resolve under their pinned occurrence rules until their own bounded deadline.

## 23. Event Multi-Award Encounters

Multi-award is an explicit encounter mode, not the default capture rule.

The shared event target tracks contribution/qualification but is not directly cloned into several owners.

At qualifying resolution:

1. freeze eligible participant set under server rules;
2. for each eligible participant create a stable PersonalEventOpportunityId;
3. derive/generate a distinct CreatureInstanceId and Variant Identity under the event template;
4. materialize or persist the distinct personal capture opportunity;
5. let each participant resolve their own capture path;
6. exact-once dedupe prevents repeated personal opportunity creation.

### MULTI-10-01

Each awarded player gets a distinct CreatureInstanceId.

### MULTI-10-02

One shared CreatureInstanceId never receives multiple owners.

### MULTI-10-03

Changing server cannot reissue a second personal opportunity for the same occurrence/reward slot.

## 24. Event Disable / Hotfix

A live-content disable can stop future generation/participation prospectively.

### HOTFIX-10-01

Already Secured Creatures remain owned.

### HOTFIX-10-02

Already finalized rewards remain finalized.

### HOTFIX-10-03

Active dangerous/broken runtime content may be terminated only under an explicit safe resolution policy that preserves finalized player value.

## 25. Trade Access Boundary

Baseline trading is direct, bilateral and same-server.

Each participant independently must:

- satisfy Trade Access Milestone;
- have trusted profile/session authority;
- not be in Protected Load Failure;
- not already be in another Trade Session/transaction fence;
- satisfy safety/platform eligibility supplied downstream;
- have no state that GDS-12 forbids at commit.

### TRADE-ACCESS-10-01

Party/friendship does not grant Trade Access.

## 26. Trade Session Runtime

Trade negotiation is P0 server-session state.

Conceptual record:

- TradeSessionId;
- participant UserIds;
- tradeRevision;
- exact offered CreatureInstanceIds per side;
- per-side Ready state;
- per-side Final Confirmation state;
- reserved creature references;
- inactivity deadline;
- state/revision;
- eventual TradeTransactionId.

State:

- Invited;
- Negotiating;
- ReadyReview;
- FinalReview;
- CommitStarting;
- CommitDurable;
- Terminal.

### TRADE-SESSION-10-01

One player participates in at most one Trade Session.

### TRADE-SESSION-10-02

Disconnect before durable commit cancels/no-ops.

## 27. Exact-Instance Trade Reservations

During negotiation, offered creatures receive server-runtime Trade Reservations.

Eligibility checks include:

- exact current ownership;
- Secured state;
- not Provisional;
- Creature Lock removed where required;
- not Production-assigned;
- no incompatible active role;
- trade restriction/cooldown expired;
- not reserved by another transaction;
- participant profile healthy.

### TRADE-RES-10-01

Runtime reservation prevents same-server conflicting Release/assignment/second trade.

### TRADE-RES-10-02

Displayed creature may be reserved; display only clears on successful outgoing commit.

### TRADE-RES-10-03

Overflow-Held sender creature may be offered if otherwise valid.

## 28. Trade Revision and Consent

Any semantic offer change:

1. increments tradeRevision;
2. clears both Ready states;
3. clears both Final Confirmations;
4. recalculates factual offer projection/capacity preview.

### TRADE-CONSENT-10-01

Ready is independent per participant.

### TRADE-CONSENT-10-02

Final Confirmation is independent and bound to an exact immutable revision.

### TRADE-CONSENT-10-03

Closing UI, disconnect, Party role or chat message cannot infer confirmation.

## 29. Pre-Commit Revalidation

After both Final Confirmations on the same revision, ordinary editing closes and the server revalidates both participants from current authoritative profile state.

Checks include:

- same participants and revision;
- both final confirmations;
- profile lease/session state;
- exact ownership;
- runtime/persistent reservations;
- locks/restrictions/cooldowns;
- Production/active-role eligibility;
- no pending conflicting P2 operation;
- complete non-empty offers on both sides;
- net post-trade capacity for each receiver;
- content/provenance resolvability;
- trade access/safety eligibility.

Any failure before durable commit decision cancels without ownership transfer.

## 30. Why a Durable Trade Journal Is Required

Roblox standard DataStore does not provide one general atomic transaction across two Player Profile keys.

TA-10 therefore implements a narrow recoverable transaction protocol using TA-4's reserved transaction store primitive.

Sequential writes without a journal are prohibited.

## 31. Trade Transaction Identity

When final revalidation succeeds, the server creates one globally unique TradeTransactionId.

The durable journal contains canonical immutable transaction intent:

- transaction ID;
- participant UserIds;
- source profile revisions;
- exact final Trade Revision/hash;
- complete outgoing Creature records needed for deterministic participant application;
- precondition hashes;
- intended incoming/outgoing sets;
- resulting cooldown/provenance metadata;
- state/decision;
- participant prepare/apply acknowledgments;
- timestamps/version.

The journal is server-private and never a client-authored payload.

## 32. Trade Journal State Machine

Canonical states:

- PREPARING;
- ABORT_DECIDED;
- COMMIT_DECIDED;
- APPLYING;
- FINALIZED_ABORT;
- FINALIZED_COMMIT;
- QUARANTINED / OPERATOR_REQUIRED for impossible invariant corruption only.

### JOURNAL-10-01

Only a durable COMMIT_DECIDED creates the obligation to finish ownership transfer.

### JOURNAL-10-02

Before COMMIT_DECIDED, failure may abort and release prepared markers.

### JOURNAL-10-03

After COMMIT_DECIDED, ordinary cancellation is forbidden; recovery finishes the committed intent.

## 33. Participant Prepare

Each Player Profile is prepared through UpdateAsync using a transaction-fence marker.

Prepare verifies:

- expected participant;
- exact profile revision/precondition;
- exact outgoing instances still owned/eligible;
- no conflicting transaction fence;
- net capacity still valid;
- canonical journal hash.

It writes a bounded pendingTrade marker/reservation but does not yet expose new ownership for ordinary gameplay.

### PREPARE-10-01

Prepare is idempotent for the same transaction/hash.

### PREPARE-10-02

A profile with pendingTrade is blocked from conflicting irreversible mutations.

### PREPARE-10-03

If either participant cannot prepare, coordinator writes ABORT_DECIDED and cleans any prepared participant idempotently.

## 34. Commit Decision

Only after both participants are durably PREPARED does the coordinator atomically update the transaction journal to COMMIT_DECIDED.

### DECIDE-10-01

The commit decision is immutable.

### DECIDE-10-02

A crash immediately after COMMIT_DECIDED must still resolve to committed ownership.

## 35. Transaction-Fenced Participant Apply

Participant apply is an idempotent profile UpdateAsync authorized only when:

- journal is COMMIT_DECIDED;
- profile pendingTrade matches transaction/hash;
- participant role matches journal;
- outgoing records still match prepared snapshot or are already marked applied.

The transform:

- removes exact outgoing Creature records;
- clears outgoing Display references;
- imports exact incoming Creature records from journal intent;
- preserves immutable Variant/provenance;
- appends bounded trade provenance/history;
- puts incoming creatures into safe Stored state;
- applies Trade Cooldown;
- re-locks incoming Protected Variants;
- finalizes applicable collection Discovery;
- leaves Energy/Production Buffer/Vault upgrades unchanged;
- marks participant apply result as APPLIED for the exact transaction/hash;
- retains the pendingTrade transaction fence/terminal applied marker while the journal is not yet FINALIZED_COMMIT;
- clears the fence only during post-finalization reconciliation after the journal proves both participant applies are durably acknowledged.

### APPLY-10-01

The transform never invents a new CreatureInstanceId.

### APPLY-10-02

Applying twice produces the same terminal participant state.

### APPLY-10-03

Incoming creatures are not auto-assigned to Production/Display.

### APPLY-10-04

An APPLIED participant remains TransactionBlocked until the journal reaches FINALIZED_COMMIT and the profile reconciles/clears the matching transaction fence. Participant apply success alone never exposes a half-applied trade as normal gameplay state.

## 36. Logical Atomicity During Partial Infrastructure Apply

Because two keys cannot physically flip in the same backend instant, TA-10 prevents partial infrastructure state from becoming partially usable gameplay state.

### ATOMIC-10-01

While a participant has unresolved pendingTrade, that profile is TransactionBlocked for ordinary gameplay/value mutations.

### ATOMIC-10-02

On load, pendingTrade must resolve against the durable journal before profile Ready.

### ATOMIC-10-03

After COMMIT_DECIDED, transaction recovery may continue without connected clients, but every participant profile mutation still obeys TA-4 session ownership and its single-writer pipeline.

### ATOMIC-10-04

If a participant has a valid live or unexpired profile lease, recovery is routed through that lease owner's profile writer queue. An external worker must not directly UpdateAsync the profile behind the owner's in-memory aggregate.

### ATOMIC-10-05

If the original owner is unavailable, another worker may mutate the participant only after TA-4's stale/expired-lease rules allow it to atomically acquire recovery/session ownership and reconcile the latest durable profile revision.

### ATOMIC-10-06

A participant already marked APPLIED retains its matching pendingTrade/APPLIED fence and remains TransactionBlocked until both participant applies are acknowledged, the journal reaches FINALIZED_COMMIT, and post-finalization reconciliation clears the fence.

Idempotence makes duplicate attempts safe after legal profile authority is established; it is not permission for concurrent writers. TA-10 creates no exception to TA-4's lease-owning single-writer model.

## 37. Trade Finalization

After both participant applies are durably acknowledged, the journal transitions to FINALIZED_COMMIT. Each participant profile then reconciles that terminal journal state through its authorized TA-4 writer, clears the matching pendingTrade/APPLIED fence idempotently, and only then may become normal gameplay Ready.

For abort, both prepared markers must be cleared before FINALIZED_ABORT where possible; load recovery treats an ABORT_DECIDED marker as mandatory cleanup before Ready.

### FINAL-10-01

Terminal journal result is queryable for reconnect reconciliation.

### FINAL-10-02

Journal retention/compaction is bounded by TA-14/17 and cannot occur before participant recovery safety is satisfied.

## 38. Trade Capacity

Capacity uses the complete post-trade net result.

### CAP-TRADE-10-01

Outgoing creatures may free capacity for incoming creatures atomically in the prepared intent.

### CAP-TRADE-10-02

Baseline trade cannot create new receiver Overflow-Held state.

### CAP-TRADE-10-03

Capacity change before prepare causes safe abort.

### CAP-TRADE-10-04

Once COMMIT_DECIDED exists, later unrelated capacity changes cannot rewrite the committed transaction; conflicting mutations were fenced.

## 39. Trade Cooldown and Restrictions

Trade Cooldown is persistent wall-clock eligibility metadata on the received Creature record.

### COOL-10-01

Cooldown uses server-observed timestamps.

### COOL-10-02

Server transition/device change does not reset it.

### COOL-10-03

Time-Locked/Account-Bound restrictions remain authored semantic state and are checked at offer and prepare.

## 40. Trade Provenance and Discovery

Original acquisition provenance is immutable.

Trade adds bounded transfer-history/provenance metadata.

The recipient may gain Species/Mutation/Variant Discovery from legitimate ownership in the same participant apply.

### PROV-10-01

No Landmark, Region Mastery, Event Contribution or Event Completion is fabricated by trade.

### PROV-10-02

Event provenance remains attached.

## 41. Energy and Trade

Energy is never in the Trade Session schema or journal value exchange.

### ENERGY-TRADE-10-01

Trade creates no Energy source/sink.

### ENERGY-TRADE-10-02

No trade fee exists.

### ENERGY-TRADE-10-03

No Party/friend transfer path exists.

## 42. Trade Recovery Cases

### RECOVER-10-01

Crash before journal creation: no durable trade; runtime reservations disappear.

### RECOVER-10-02

Crash during PREPARING: journal recovery chooses/observes abort unless both valid prepares can complete under the same immutable intent.

### RECOVER-10-03

Crash after one prepared and before decision: abort cleanup is safe.

### RECOVER-10-04

Crash after COMMIT_DECIDED: finish both participant applies.

### RECOVER-10-05

Crash after one participant applied: both participant profiles remain transaction-blocked; the applied participant retains its APPLIED fence while recovery completes the second apply and journal finalization.

### RECOVER-10-06

Reconnect reads journal/profile state and exposes only authoritative terminal/pending result.

### RECOVER-10-07

If recovery finds an active/unexpired participant profile lease, it routes apply/cleanup through the lease-owning server writer queue rather than racing a direct external UpdateAsync.

### RECOVER-10-08

If the lease owner is gone, recovery waits for or atomically acquires profile authority under TA-4 lease rules before applying and reconciling the transaction.

## 43. Trade Session and Server Shutdown

Shutdown behavior:

- invite/negotiation/Ready/one-sided confirmation: cancel and release runtime reservations;
- PREPARING: attempt bounded durable abort/cleanup, otherwise journal recovery owns it;
- COMMIT_DECIDED/APPLYING: transaction recovery must finish independent of client presence;
- FINALIZED: no special ownership action.

Shutdown never upgrades an uncommitted negotiation into a trade.

## 44. Cross-Server Trading Boundary

Baseline GDS-12 trade is same-server only.

### XTRADE-10-01

MemoryStore is not used to create an offline/global marketplace.

### XTRADE-10-02

Players in different servers cannot enter the baseline Trade Session.

### XTRADE-10-03

Transaction recovery may be cross-server because persistence recovery is an infrastructure concern, not a new cross-server negotiation feature.

## 45. Abuse and Security Boundary

The server validates all Party/event/trade actions.

At minimum:

- UserId/session identity;
- same-server presence where required;
- runtime IDs/revisions;
- consent state;
- contribution facts;
- target ownership;
- capacity;
- locks/restrictions;
- operation/journal IDs generated server-side;
- rate limits;
- message/payload bounds.

Clients cannot choose:

- Party membership directly;
- event reward eligibility;
- EventOccurrence identity;
- personal multi-award eligibility;
- TradeTransactionId;
- commit decision;
- incoming creature record;
- cooldown expiry;
- provenance;
- transaction journal state.

## 46. Cross-Server Failure Model

### CROSSFAIL-10-01

Messaging failure is recoverable through periodic/triggered refresh of durable/config event state.

### CROSSFAIL-10-02

MemoryStore throttle/expiry degrades coordination/cache, not durable outcomes.

### CROSSFAIL-10-03

DataStore transaction-journal failure blocks new commit decision rather than weakening atomicity.

### CROSSFAIL-10-04

A stale server event instance cannot finalize a reward for an occurrence/revision that current durable/config authority invalidates.

## 47. Performance Principles

Before TA-14 exact budgets:

- Party/social runtime state remains small and server-local;
- pings/invites are bounded/rate-limited;
- contribution accounting stores compact semantic facts, not raw event logs;
- scheduled events derive from clock/config rather than global polling per frame;
- cross-server refresh is jittered/bounded;
- MessagingService topics are coarse/versioned, not one topic per transient object;
- MemoryStore is not used as durable history;
- Trade negotiation creates no DataStore write per edit;
- DataStore writes begin only at durable Trade Commit;
- transaction recovery is indexed by stable transaction/participant markers, not full-store scans;
- journal payloads remain bounded by offer-count limits.

## 48. Observability

Required diagnostics include:

### Social
- party create/join/leave/remove/disband;
- invite expiry/rate-limit reason;
- rejoin grace success/expiry;
- contribution eligibility;
- collaboration reward outcome;
- challenge lifecycle.

### Events
- active occurrence/template/version;
- server instance phase transitions;
- occurrence refresh source;
- Messaging publish/subscribe error;
- MemoryStore cache hit/error if used;
- contribution/reward dedupe;
- event spawn modifier activation;
- multi-award opportunity issuance;
- resolution-grace completions;
- server-hop duplicate suppression.

### Trading
- Trade Session lifecycle/revision count;
- reservation rejection reason;
- Ready/confirmation reset;
- precommit validation failure;
- journal state transition latency;
- prepare/apply participant state;
- recovery attempts;
- transaction-blocked profile count;
- terminal commit/abort;
- duplicate apply detection;
- cooldown/restriction rejection;
- invariant quarantine.

No full player profiles or private chat content is logged.

## 49. Testability Hooks

TA-10 requires injectable/testable boundaries for:

- wall clock;
- Party ID/invite expiration;
- contribution evaluator;
- event schedule/occurrence source;
- Messaging adapter;
- MemoryStore adapter;
- Event Template/config snapshot;
- event Spawn Modifier injection;
- transaction journal repository;
- Player Profile participant transaction adapter;
- transaction recovery worker;
- friend/platform eligibility adapter;
- collision/visitor policy adapter.

## 50. Downstream Handoffs

### TA-11

Consumes social/event/trade boundaries while ensuring commercial products cannot buy claim priority, event reward duplication, trade safety bypass or transferable tender.

### TA-12

Owns Party/event/trade presentation, immutable final trade review, accessible consent, pings, challenge/event cues and pending-transaction reconciliation UX.

### TA-13

Owns event/live configuration rollout, analytics, experiments and operational admin controls.

### TA-14

Locks exact Party/ping/event refresh, Messaging/MemoryStore, DataStore transaction, recovery, offer-count and transaction-journal budgets.

### TA-15

Implements fault injection for every trade journal cut point, duplicate/replay tests, event cross-server tests and social exploit validation.

### TA-16

Cross-validates commercial, UI, liveops, performance and recovery interactions.

### TA-17

Locks concrete services/modules/stores/topics/remotes/schemas/state enums and implementation sequence.

## 51. Critical Invariants

1. Party/social relation never grants another player's ownership/value authority.
2. Shared rewards require personal server-observed contribution and finalize per player exactly once.
3. Ordinary capture remains single-award unless an explicit event encounter mode says otherwise.
4. EventOccurrence identity/timing is stable across servers.
5. MessagingService/MemoryStore accelerate coordination but are not durable truth.
6. Event modifiers affect future Spawn Reservations only.
7. Event multi-award creates distinct personal CreatureInstanceIds.
8. Authored persistent personal Event Cooldowns use profile-backed server-wall-clock state and survive server changes.
10. Trade requires same-server bilateral explicit consent on one immutable revision.
9. Any semantic offer change clears consent.
11. No durable Trade Commit occurs without both profiles prepared under one immutable journal intent.
12. COMMIT_DECIDED is irreversible and recoverable.
13. Pending Trade profiles cannot expose partial infrastructure state as usable gameplay state.
14. Trade never mints a creature, rerolls Variant Identity, transfers Energy or fabricates active progression.
15. Protected/event provenance and cooldown/restriction semantics survive transfer.

## 52. Open Questions

There are **zero TA-10-blocking open questions**.

Correctly downstream/tuneable:

- exact invite/ping/challenge/rejoin timeouts — TA-14/17;
- exact collaboration contribution thresholds — content/TA-17;
- event catalogs/schedules/reward quantities — content/TA-13;
- exact Messaging topics/cache TTL/refresh cadence — TA-14/17;
- exact MemoryStore use, if any, after measured need — TA-14/17;
- exact Trade Cooldown duration and offer cap within GDS bounds — content/TA-14/17;
- journal retention/compaction windows — TA-14/17;
- high-value trade review timing/presentation — TA-12;
- account/parental/platform eligibility mechanics — TA-12/15;
- exact module/store/schema names — TA-17.

## 53. Architecture-Complete Checklist

- [x] transient Party identity/membership/lifecycle explicit;
- [x] contribution and Collaboration Reward exact-once path explicit;
- [x] Friendly Challenge/collision/visitor boundaries explicit;
- [x] EventOccurrence/ServerEventInstance identities explicit;
- [x] scheduled and dynamic occurrence authority explicit;
- [x] cross-server Messaging/MemoryStore role explicit;
- [x] event lifecycle/spawn/contribution/reward/grace explicit;
- [x] persistent personal/global Event Cooldown scope, wall-clock storage and server-hop reconciliation explicit;
- [x] multi-award distinct-instance architecture explicit;
- [x] direct same-server Trade Session/Revision/consent explicit;
- [x] exact-instance reservations explicit;
- [x] durable transaction journal/prepare/decision/apply explicit;
- [x] crash/disconnect recovery explicit;
- [x] cooldown/provenance/discovery/capacity rules explicit;
- [x] security/performance/observability/testability explicit;
- [x] no implementation-critical TA-10 questions remain.
