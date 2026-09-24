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
| Vault.SetProductionAssignment | C | slotId:string, creatureInstanceId:string? |
| Vault.ClaimProduction | C | claimScope:enum |
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
