# TA-5 Identity and Registry Matrix

> **Phase:** TA-5 — Identity, Content Registries, Configuration, and Data-Driven Content  
> **Status:** PASS  
> **Purpose:** Lock canonical identity classes, persistence/network usage, registry ownership and lifecycle compatibility before downstream domain schemas are authored.

## 1. Identity Matrix

| Identity | Class | Generated/owned by | Persistent? | Client-visible? | Reusable? |
|---|---|---|---:|---:|---:|
| SpeciesId | static content | source registry | YES/reference | YES where needed | NEVER reassigned |
| MutationId | static content | source registry | YES/reference | YES after/public when appropriate | NEVER |
| TraitId | static content | source registry | YES/reference | YES where appropriate | NEVER |
| RarityId | static content | source registry | YES/reference | YES | NEVER |
| RegionId | static content | source registry | YES/reference | YES | NEVER |
| LandmarkId | static content | source registry | YES/reference | YES | NEVER |
| SpawnContextId | static content | source registry | maybe provenance/reference | public reference may be visible | NEVER |
| EventTemplateId | static content | source registry | historical reference as needed | YES/public metadata | NEVER |
| EventOccurrenceId | dynamic durable/runtime | TA-10 server | YES when completion/provenance needs | YES where relevant | NEVER |
| ProductDefinitionId | static content | source registry | YES entitlement semantics | YES/public product metadata | NEVER |
| DeveloperProductId | external platform | Roblox/env binding | receipt/audit only as needed | not semantic authority | platform-owned |
| CosmeticDefinitionId | static content | source registry | YES entitlement | YES | NEVER |
| CreatureInstanceId | runtime persistent entity | server GUID | YES | YES where gameplay needs | NEVER |
| EncounterInstanceId | runtime entity | server | transient/provenance as needed | YES where needed | NEVER |
| CaptureClaimId | runtime entity | server | transient | participant-facing as needed | NEVER |
| TradeSessionId | runtime entity | TA-10 server | transient/recovery as needed | participants only | NEVER |
| OperationId | durable operation | server | YES/dedupe horizon | correlation as needed | NEVER |
| TradeTransactionId | durable transaction | TA-10 server | YES | participants/result only | NEVER |
| ContentSnapshotId | build/config snapshot | build/config system | diagnostic/provenance | optional | NEVER for different snapshot |

## 2. Static ID Grammar Examples

| Kind | Valid example | Invalid example | Reason |
|---|---|---|---|
| SpeciesId | `species/ember-fox` | `Ember Fox` | display text / uppercase / space |
| MutationId | `mutation/gilded` | `mutation:Gilded` | noncanonical separator/case |
| RegionId | `region/starter-grove` | `Workspace.Regions.Starter` | Studio path is not semantic ID |
| LandmarkId | `landmark/starter-grove/old-oak` | `Old Oak` | display name not stable |
| EventTemplateId | `event/template/rift-surge` | `event-2026-09-18` | occurrence/date not template identity |
| ProductDefinitionId | `product/starter-bundle` | `123456789` | platform ID not semantic ID |

## 3. Registry Ownership Matrix

| Registry | Public half? | Server-private half? | Primary downstream owner |
|---|---:|---:|---|
| Species | YES | YES | TA-7 |
| Mutation | YES | YES | TA-7 |
| Trait | YES | YES as needed | TA-7 |
| Rarity | YES | YES as needed | TA-7 |
| Region | YES | YES | TA-9 |
| Landmark | YES | YES as needed | TA-9 |
| SpawnContext | minimal public refs | YES | TA-9 |
| EventTemplate | YES | YES | TA-10 |
| EventObjective | public summary possible | YES | TA-10 |
| Cosmetic | YES | YES/grant binding | TA-11/12 |
| Product | YES storefront projection | YES platform/grant binding | TA-11 |
| CapacityUpgrade | YES | YES authoritative cost/effect | TA-8/11 |

## 4. Content Lifecycle Matrix

| Lifecycle | New generation/use | Existing persisted refs | Client display | Deletion allowed? |
|---|---:|---:|---:|---:|
| Active | YES | YES | normal | NO while referenced |
| Retired | NO by default | YES | normal/legacy presentation | NO |
| Tombstone | NO | YES minimal compatibility | fallback/legacy safe | NO if refs remain |

## 5. Configuration Class Matrix

| Class | Meaning | Live override? | Example |
|---|---|---:|---|
| C0 | semantic invariant | NO | Energy non-transferable |
| C1 | static build content | NO baseline | Species schema/region graph/product grant kind |
| C2 | explicitly approved tuneable | YES through TA-13 only | spawn rate within envelope/event schedule |
| C3 | presentation/default | YES/local or TA-13 as applicable | visual timing/default UI value |

## 6. Public/Private Split Matrix

| Data | Public replicated? | Server private? |
|---|---:|---:|
| Species display/localization key | YES | optional canonical mirror |
| Species icon asset ref | YES | NO need |
| exact hidden spawn weight | NO | YES |
| Mutation odds | NO | YES |
| public Rarity tier/order | YES | canonical server copy okay |
| anti-abuse threshold | NO | YES |
| Region display/key | YES | canonical/private rules as needed |
| product display definition | YES | YES semantic binding |
| DeveloperProductId | only if UI/API requires; not authority | YES authoritative mapping |
| receipt grant mapping | NO | YES |
| Event public name/window | YES | YES canonical schedule/rules |
| unrevealed reward table | NO | YES |

## 7. Persistent Reference Rule

Persisted values should store canonical MonsterVault IDs, not:

- display names;
- localized strings;
- Instance paths;
- Roblox object references;
- mutable array indexes;
- environment-specific asset/product IDs as semantic meaning.

## 8. World Authoring Matrix

| Authoring concept | Tag | Required attribute example | Canonical source |
|---|---|---|---|
| Spawn point | `MV.SpawnPoint` | `SpawnContextId` | SpawnContextRegistry |
| Landmark | `MV.Landmark` | `LandmarkId` / `RegionId` | Landmark/Region registries |
| Secure Point | `MV.SecurePoint` | region/context as needed | world registry |
| Travel Node | `MV.TravelNode` | stable node/content ID | world registry |
| Vault Access Point | `MV.VaultAccessPoint` | stable public context | world/Vault schema |

Tags declare role; stable attributes resolve semantic identity.

## 9. Environment Binding Matrix

| Semantic definition | DEV binding | STAGING binding | PROD binding |
|---|---|---|---|
| product/starter-bundle | DEV DeveloperProductId | staging ID | production ID |
| cosmetic/vault-theme/obsidian | dev assets | staging assets | production assets |
| badge/... if later used | dev/staging mapping | staging mapping | prod ID |

A missing environment binding never falls back across environments.

## 10. Snapshot Compatibility

| Change | Existing generated instance | Future generation |
|---|---|---|
| display name update | identity unchanged | new display visible |
| icon asset update | identity unchanged | new presentation |
| spawn weight update | no reroll | new generation uses new snapshot |
| Mutation weight update | no reroll | future eligible generation only |
| availability retired | owned instance remains | new generation disabled |
| product external ID changes | entitlement identity unchanged | new receipts use current env binding |
| event template tune | old occurrence provenance stable | later occurrence may use new snapshot |

## Verdict

**TA-5 IDENTITY / REGISTRY MATRIX: PASS.**
