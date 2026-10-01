# TA-17 Runtime Namespace Contract

> **Status:** PASS
> **Date:** 2026-09-24
> **Protocol generation:** V1
> **Profile schema generation:** 1

## 1. Remote objects

```text
ReplicatedStorage/MonsterVault/Remotes/V1/Command
ReplicatedStorage/MonsterVault/Remotes/V1/Event
ReplicatedStorage/MonsterVault/Remotes/V1/UnreliableEvent
```

No RemoteFunction exists at baseline.

## 2. Envelopes

### Client -> server Command

```luau
{
    protocolVersion: 1,
    routeId: string,
    requestId: string,
    expectedRevision: number?,
    payload: table,
}
```

Player identity comes only from `OnServerEvent`.

### Server -> client Event

```luau
{
    protocolVersion: 1,
    routeId: string,
    correlationId: string?,
    revision: number?,
    payload: table,
}
```

### Server -> client UnreliableEvent

Same base envelope but no critical/durable truth and <=768 encoded bytes.

## 3. V1 command route IDs

| Route | Class | Required payload fields |
|---|---|---|
| Session.ClientHello | A | clientBuild:string, inputFamily:enum, localeId:string |
| Session.RequestResync | A | domain:enum, knownRevision:number? |
| Interaction.PrimaryInteract | B | interactionId:string |
| Capture.SubmitAction | C | captureSessionId:string, actionId:string, clientSequence:number |
| World.RequestFastTravel | C | nodeId:string |
| Creature.SetLock | C | creatureInstanceId:string, locked:boolean |
| Creature.Release | C | creatureInstanceId:string |
| Vault.SetProductionAssignment | C | slotId:string, creatureInstanceId:string?; required envelope expectedRevision:integer |
| Vault.SetDisplayAssignment | C | slotId:string, creatureInstanceId:string?; required envelope expectedRevision:integer |
| Vault.ClaimProduction | C | claimScope:All; required envelope expectedRevision:integer |
| Vault.ResolveOverflow | C | creatureInstanceId:string; required envelope expectedRevision:integer |
| Progression.PurchaseUnlock | C | unlockId:string, quoteRevision:number |
| Social.PartyInvite | B | targetUserId:number |
| Social.PartyRespond | B | invitationId:string, accept:boolean |
| Social.PartyLeave | B | partyId:string |
| Social.Ping | B | pingKind:enum, targetId:string? |
| Social.ChallengeRequest | B | targetUserId:number |
| Social.ChallengeRespond | B | challengeId:string, accept:boolean |
| Trade.Start | C | targetUserId:number |
| Trade.SetOffer | C | tradeSessionId:string, creatureInstanceIds:string[] <=12 |
| Trade.SetReady | C | tradeSessionId:string, tradeRevision:number, ready:boolean |
| Trade.FinalConfirm | C | tradeSessionId:string, tradeRevision:number |
| Trade.Cancel | C | tradeSessionId:string |
| Commerce.RefreshEntitlements | D | productDefinitionIds:string[] <=8 |
| Settings.UpdatePreferences | B | reducedMotion:boolean?, captionsEnabled:boolean?, masterVolume:number? |

Routes are allowlisted registry constants; unknown strings never map dynamically to module paths.

IMP-9 extension under [AD-250](ARCHITECTURE_DECISIONS.md#ad-250--register-imp-9-capacity-migration-and-explicit-overflow-resolution): RequestResync permits domain=vault and optional afterCreatureInstanceId:string (1..128 bytes). ResolveOverflow permits no other payload field or client capacity/owner/quantity. Both preserve the existing envelope, ingress schema/rate/replay and readiness gates. Class A Vault resync may reconcile an uncertain P2 operation before publishing Ready; Class C cannot grant readiness.

The owner-only Vault snapshot has domain=vault, revision=profileRevision and state={capacity, ordinaryUsed, overflowHeldCount, components={base,earned,commercial,temporary}, overflowCreatureInstanceIds, hasMore}. Pages have at most five sorted exact IDs and 480 total ID bytes and must pass the existing reliable wire budget. The session projection with matching profileRevision precedes each Vault snapshot; only a Ready client store at that revision accepts it.

[AD-251](ARCHITECTURE_DECISIONS.md#ad-251--register-imp-9-assignments-and-production-settlement) enables Production Assignment and adds Display Assignment with strict payloads: slotId (1..128 bytes), optional creatureInstanceId (1..128 bytes) and positive exact expectedRevision. No owner, rate, quantity or time field is accepted. Omitted creatureInstanceId clears the slot. Both use the P2 writer; claims remain reserved.

RequestResync adds domain=vaultAssignments with the same cursor, now allowed exclusively for vault/vaultAssignments. The owner snapshot has domain=vaultAssignments, revision=profileRevision and state={bufferMilli,bufferCapacityMilli,productionSlotCount,displaySlotCount,offlineWindowSeconds,offlineCreditedMilli,creatures,hasMore}. Up to two sorted rows contain creatureInstanceId, overflowHeld, locked and optional productionSlotId/displaySlotId. Row string bytes total at most 300; the 4 KiB validator remains binding. A matching Ready session projection precedes the page. Missing rows or Command.Result alone cannot prove assignment outcomes.

Profile generation 1 adds production-domain version 1, canonical relations, integer buffer/cursor, retained epoch ID, Active/CleanOffline boundary and bounded recap. AD-251 locks initialization/protected migration and single-writer settlement at assignment, save, leave and load; no wallet, grant binding or milestone is added.

## 4. V1 reliable server event routes

| Route | Purpose |
|---|---|
| Command.Result | correlated authoritative result/rejection/unknown |
| Session.Ready | trusted initial session ready |
| Session.ProtectedOutcome | ProtectedLoadFailure/session ownership loss |
| Projection.Snapshot | bounded initial/resync projection chunk |
| Projection.Delta | revisioned authoritative domain delta |
| Capture.StateChanged | capture/provisional/custody projection |
| World.StateChanged | world/access/event-relevant projection |
| Social.StateChanged | party/challenge projection |
| Event.StateChanged | event occurrence/progress projection |
| Trade.StateChanged | revision/ready/commit/recovery projection |
| Commerce.StateChanged | entitlement/pending/reconciliation projection |
| System.Notification | semantic non-authoritative notification |

## 5. V1 unreliable event routes

- `Presentation.CaptureTiming`
- `Presentation.WorldCue`

Loss/reorder may affect presentation only.

## 6. Result code namespaces

Stable public prefixes:

- `OK_*`
- `REJECT_VALIDATION_*`
- `REJECT_PERMISSION_*`
- `REJECT_STATE_*`
- `REJECT_RATE_LIMIT`
- `PENDING_*`
- `OUTCOME_UNKNOWN_*`
- `PROTECTED_*`
- `UNAVAILABLE_*`

Internal exception text is never a client result contract.

## 7. DataStore names

Environment token is one of DEV/STG/PROD.

- `MV_<ENV>_PlayerProfile_v1`
- `MV_<ENV>_TradeJournal_v1`
- `MV_<ENV>_ReceiptJournal_v1`

Keys:

- Player profile: `player/<UserId>`
- Trade journal: `trade/<TransactionId>`
- Receipt journal: `receipt/<PurchaseId>`

Player profile root contains `schemaVersion = 1`.

No username/display name is used as durable identity.

## 8. Operation identities

- ordinary P2 operation ID: server-generated GUID;
- network requestId: client correlation only;
- trade TransactionId: server-generated GUID;
- Marketplace receipt identity: platform PurchaseId;
- event reward identity: occurrence + reward-definition + subject stable composite;
- profileRevision: monotonic durable aggregate version.

These identities are not interchangeable.

## IMP-9 Energy/Claim binding — AD-252

[AD-252](ARCHITECTURE_DECISIONS.md#ad-252--register-imp-9-energy-wallet-and-exact-once-production-claim) enables Vault.ClaimProduction. Its entire payload is `{claimScope = "All"}` with a positive exact expectedRevision. Sender identity supplies the owner; requestId only correlates transport. A server-generated GUID identifies the accepted P2 wallet/buffer transaction. A receipt binds that GUID/outcome to the submitted aggregate revision; another request ID or reconnect cannot turn that old revision into a claim of new production. After bounded audit eviction, the old revision is rejected stale.

Profile generation 1 adds economy-domain version 1, whole-unit Energy capped at 1e12 and 32 recent reason-coded audit/claim receipts. Only production-claim is bound in this DEV slice. Empty wallet initializes to zero; valid legacy energyUnits persists; unavailable source/grant authority and invalid state remain protected. No spending/progression or external deferred-grant reader is enabled.

The existing vaultAssignments owner snapshot adds `energyUnits`, `claimExpectedRevision` and `claimUnits` (zero receipt fields before the first claim). Row ID/slot text totals at most 240 bytes instead of 300 to accommodate these fields under the existing 4 KiB validator. Matching Ready revision and request correlation remain required; Command.Result alone cannot infer a wallet update. Class A readback reconciles accepted unknown checkpoints. A Busy result with fresh readback permits resubmission; a missing receipt during a yielding/unknown write does not prove not-applied. Remotes and protocol V1 are unchanged.

## 9. Cross-server names

If activated:

MemoryStore structure:

- `MV:<env>:EventCoord:v1`

Messaging topics:

- `mv.<env>.event.v1`
- `mv.<env>.config.v1`

They remain hints/coordination only.

## 10. Config / telemetry source registries

Implementation registry modules:

- C0/C1 content IDs: `src/server/domains/*/registry` plus public shared IDs where safe;
- C2 allowlist: `src/server/infrastructure/live_config/ConfigDefinitions.luau`;
- telemetry event definitions: `src/server/infrastructure/telemetry/TelemetryRegistry.luau`;
- product semantic bindings: `src/server/domains/monetization/ProductDefinitions.luau`.

External Roblox product/place/universe IDs are environment binding data and are never guessed.

**Runtime namespace lock: PASS.**
