# TA-5 — Identity, Content Registries, Configuration, and Data-Driven Content

> **Status:** Architecture Complete  
> **Owning TA phase:** TA-5 — Identity, Content Registries, Configuration, and Data-Driven Content  
> **Authority:** Stable semantic identifiers, runtime instance identifiers, persistent reference compatibility, content-definition registries, public/private configuration separation, registry validation, content lifecycle/tombstones, environment bindings, data-driven definition rules, world authoring tags/attributes, content snapshots, live-tuneable boundaries and config rollout compatibility  
> **Depends on:** TA-0 through TA-4 Architecture Complete; GDS-4, GDS-6, GDS-7, GDS-8, GDS-9, GDS-11, GDS-12, GDS-13, GDS-16, GDS-17

## 1. Purpose

TA-5 defines how MonsterVault names and resolves game content without tying persistence, networking, progression, world authoring or monetization to fragile display names, Studio hierarchy paths, transient Instances or environment-specific Roblox asset/product IDs.

The content contract is:

> **Every persistent or cross-system semantic reference uses a stable MonsterVault-owned ID. Static content definitions are declarative, validated, immutable for a running server and resolved through typed registries. Public replicated definitions contain only disclosure-safe fields; server-private registries own hidden probabilities, reward rules and environment bindings. Existing persisted IDs never silently change meaning, and retired content remains resolvable through compatibility/tombstone definitions.**

TA-5 does not create actual registry modules or content tables. Those implementation artifacts remain blocked until TA-17.

## 2. Identity Classes

MonsterVault distinguishes five identity classes.

### 2.1 Static Content ID

Stable identity of a authored definition.

Examples:

- SpeciesId;
- MutationId;
- TraitId;
- RarityId;
- RegionId;
- LandmarkId;
- SpawnContextId;
- EventTemplateId;
- EventObjectiveDefinitionId;
- CosmeticDefinitionId;
- ProductDefinitionId;
- CapacityUpgradeDefinitionId.

Properties:

- source-controlled;
- stable across builds;
- persisted/referenced where needed;
- never derived from display name;
- opaque to gameplay logic.

### 2.2 Runtime Entity ID

Identity of one runtime-created entity/instance.

Examples:

- CreatureInstanceId;
- EncounterInstanceId;
- CaptureClaimId;
- TradeSessionId;
- PartyId;
- RuntimeEventInstanceId.

Properties:

- server-generated;
- globally unique enough for its lifetime/semantic scope;
- never reused for a different logical entity.

### 2.3 Durable Operation / Transaction ID

Identity of an exact-once mutation or recoverable transaction.

Examples:

- OperationId;
- TradeTransactionId;
- CommercialGrantOperationId;
- EventRewardOperationId.

Owned by TA-4 plus the relevant domain TA.

### 2.4 External Platform ID

Roblox-owned/environment-specific identifier.

Examples:

- asset ID;
- developer product ID;
- game pass ID;
- badge ID;
- animation/audio/image asset ID.

Properties:

- not used as the MonsterVault semantic identity;
- resolved through environment binding/configuration;
- may differ between DEV/STAGING/PRODUCTION.

### 2.5 Build / Content Snapshot ID

Identity of one validated registry/config snapshot.

Used for:

- provenance/debugging;
- experiment/config correlation;
- event/spawn generation snapshot pinning where required;
- incident/recovery analysis.

## 3. Static Content ID Format

Canonical static IDs use lowercase namespaced strings:

```text
<kind>/<slug>
```

Nested scope is allowed where it materially improves uniqueness/readability:

```text
species/ember-fox
mutation/gilded
trait/swift
region/starter-grove
landmark/starter-grove/old-oak
event/template/rift-surge
product/starter-bundle
cosmetic/vault-theme/obsidian
```

### ID-01 — Grammar

Baseline grammar:

- lowercase ASCII letters;
- digits after the first character of a segment;
- hyphen separators inside a slug;
- forward slash only for namespace segments;
- no spaces;
- no display punctuation;
- no localization text.

### ID-02 — IDs are opaque despite readable prefixes

Gameplay logic must not infer behavior by splitting/parsing an ID string.

Example prohibited pattern:

```text
if speciesId starts with "species/fire-" then ...
```

Behavior comes from registry data/contracts.

### ID-03 — ID kind is still validated

A SpeciesId cannot be accepted where a MutationId is expected merely because both are strings.

Strict Luau branded/nominal helper types are the intended implementation pattern.

## 4. Static ID Immutability

### IMM-01 — A shipped/persisted ID is never casually renamed

Changing the display name does not change the ID.

### IMM-02 — A shipped ID never silently changes semantic meaning

`species/ember-fox` cannot later refer to a materially different species.

### IMM-03 — Accidental ID replacement requires migration/change control

If an ID truly must change:

- add explicit migration mapping;
- preserve legacy resolution during migration window;
- update persisted references deterministically;
- retain audit/history;
- never let two IDs ambiguously refer to different semantic records.

### IMM-04 — No ID reuse

A retired ID is never reassigned to a new concept.

## 5. Runtime ID Generation

### RID-01 — Runtime IDs are server-generated

The client may never choose authoritative CreatureInstanceId, transaction IDs or equivalent persistent/runtime ownership identities.

### RID-02 — UUID/GUID is the baseline format

Roblox exposes `HttpService:GenerateGUID()`; MonsterVault uses server-generated GUID-style IDs for runtime identities requiring global uniqueness.

Exact formatting braces/case is locked at TA-17.

### RID-03 — Dynamic IDs are opaque

No gameplay meaning is encoded into GUID bits/string structure.

### RID-04 — Never recycle an ID

Deleted/released/despawned entity IDs are not reused.

## 6. Creature Identity

A persisted Creature Instance is identified by:

```text
CreatureInstanceId
    + SpeciesId
    + Variant Identity
    + origin/provenance fields
```

### CRE-ID-01 — Species definition identity and instance identity are separate

Many creature instances may share one SpeciesId.

### CRE-ID-02 — Variant Identity is data, not a newly generated SpeciesId

Mutations/traits/rarity/availability compose the individual instance state according to GDS-6/TA-7.

### CRE-ID-03 — Instance identity survives transfer

Trading changes ownership, not CreatureInstanceId.

### CRE-ID-04 — Definition updates do not reroll existing creature identity

A later registry change cannot regenerate Mutation/Trait/Variant identity for an already actionable or owned instance.

## 7. Content Registry Model

TA-5 defines a collection of typed registries.

Conceptual examples:

```text
SpeciesRegistry
MutationRegistry
TraitRegistry
RarityRegistry
RegionRegistry
LandmarkRegistry
SpawnContextRegistry
EventTemplateRegistry
EventObjectiveRegistry
CosmeticRegistry
CommercialProductRegistry
CapacityUpgradeRegistry
```

### REG-01 — One canonical record per static ID

Duplicate canonical IDs are fatal bootstrap validation errors.

### REG-02 — Registries are immutable after bootstrap

Running gameplay code reads registry snapshots; it does not mutate static content definitions.

### REG-03 — Registry lookup is explicit

Unknown IDs do not silently fall back to unrelated/default content.

### REG-04 — Registry iteration order is not semantic

Definitions relying on deterministic priority/order must store an explicit priority/order field.

## 8. Public and Server-Private Definitions

Some content is safe/necessary to replicate.

Other content must remain server-private.

### Public definition examples

- display/localization key;
- safe icon/asset reference;
- visible rarity label/order;
- visible region name/key;
- public cosmetic metadata;
- public trade-review facts;
- client presentation parameters where harmless.

### Server-private definition examples

- spawn weights;
- hidden rarity/Mutation probabilities;
- anti-abuse thresholds;
- reward tables not yet revealed;
- private event scheduling logic;
- authoritative product grant mapping;
- environment-specific developer product IDs where not needed by client;
- hidden experiment allocation mechanics.

### PUB-01 — Shared registry is disclosure-safe

TA-2's rule applies: anything in replicated/shared content is considered inspectable by a hostile client.

### PUB-02 — Public/private halves share the same semantic ID

When a Species has public + server definition, both are keyed by the same SpeciesId and validated for one-to-one compatibility.

### PUB-03 — Public data is a projection, not a second authority

The server-private definition remains authoritative for hidden gameplay resolution.

## 9. Future Source Layout

TA-5 refines the TA-2 target layout conceptually:

```text
src/shared/
└── config/
    ├── schema/
    └── registries/
        ├── species/
        ├── rarity/
        ├── regions/
        ├── cosmetics/
        └── public/

src/server/
└── infrastructure/
    └── config/
        ├── private/
        ├── environment/
        ├── validation/
        └── registry/
```

Exact filenames/module grouping remain TA-17.

### LAYOUT-01 — Content records remain source-controlled

Baseline gameplay definitions ship with the reviewed build.

### LAYOUT-02 — Secrets do not live in content registries

Environment secrets remain outside source per TA-1.

## 10. Declarative Data Rule

### DATADEF-01 — Registry definitions are declarative

A content definition should describe data rather than embed executable gameplay callbacks.

### DATADEF-02 — Gameplay logic stays in owning domains

Examples:

- Species definition may state base capture parameters;
- Capture domain interprets them;
- definition does not provide arbitrary `onCapture()` code.

### DATADEF-03 — No function-valued rules in ordinary content records

This avoids:

- hidden behavior;
- impossible static validation;
- serialization/diff problems;
- accidental code execution through configuration.

Narrow implementation-generated helpers are allowed outside the canonical definition data.

## 11. Definition Data Types

Core semantic definitions prefer serialization-friendly values:

- strings/IDs;
- booleans;
- finite numbers;
- bounded arrays;
- bounded key-value objects.

Roblox datatypes may be used only where the owning presentation/world schema intentionally supports them and validation is explicit.

### TYPE-01 — No Instances inside persistent/content semantic records

Use stable IDs/asset references instead.

### TYPE-02 — No threads/functions/userdata in canonical registries

### TYPE-03 — No NaN/infinite numeric configuration

## 12. Schema Ownership

Each registry has a typed schema owned by its technical/domain phase.

TA-5 owns the generic validation framework and identity/reference contracts.

Examples:

- Species schema refined by TA-6/TA-7;
- SpawnContext schema refined by TA-9;
- EventTemplate schema refined by TA-10;
- CommercialProduct schema refined by TA-11.

### SCHEMA-01 — Every definition declares/derives a schema version

Breaking definition-shape changes are versioned/migrated at source/build level.

### SCHEMA-02 — Persistent profile schema and content schema are different concerns

TA-4 `schemaVersion` covers persisted player structure.

TA-5 registry schema versions cover content-definition structure.

## 13. Registry Bootstrap

Server bootstrap sequence:

1. load registry modules;
2. validate IDs/duplicates;
3. validate field types/ranges;
4. validate all references;
5. validate public/private pairing;
6. validate lifecycle state;
7. validate domain-specific invariants;
8. construct immutable registry snapshot;
9. assign ContentSnapshotId/build metadata;
10. only then allow dependent domains to Validate/Start.

### BOOT-REG-01 — Invalid content fails server bootstrap closed

Do not run a production server with a partially valid core content registry.

### BOOT-REG-02 — Validation returns actionable diagnostics

Include registry, ID, field/path and failure code.

Do not leak secrets to clients.

## 14. Referential Integrity

Examples:

- Region references known Landmarks;
- SpawnContext references known Species;
- Mutation table references known MutationIds;
- event objective references valid reward/content IDs;
- commercial bundle references known entitlement/content definitions.

### REF-01 — Unknown hard reference is a fatal definition error

### REF-02 — Optional references are explicitly nullable

No magic empty-string IDs.

### REF-03 — Cross-registry cycles are reviewed

A reference graph may be cyclic only if the semantics do not require recursive construction/evaluation.

Recursive definition loops are rejected.

## 15. Content Lifecycle

Static definitions use a lifecycle classification:

- **Active** — may be newly generated/offered/used;
- **Retired** — no longer newly generated/offered but existing references remain fully supported;
- **Tombstone** — minimal legacy definition retained only so historical/persisted identity remains resolvable.

### LIFE-CONT-01 — Removal does not create dangling persistent IDs

A definition with persisted historical references cannot simply disappear.

### LIFE-CONT-02 — Retired/Tombstone does not erase owned value

Existing creatures/cosmetics/history continue to resolve appropriately.

### LIFE-CONT-03 — Tombstone is not new content eligibility

Tombstones cannot be randomly generated/offered unless explicitly reactivated through change control.

## 16. Availability Versus Identity

GDS-6/9/11 separate rarity, availability and identity.

### AVAIL-01 — Availability is mutable content state/config, not the static identity itself

A SpeciesId stays the same whether:

- normally available;
- event-limited;
- retired from generation;
- temporarily disabled.

### AVAIL-02 — Owned instance identity survives availability change

### AVAIL-03 — Availability changes are prospective

Do not invalidate/reroll existing actionable instances.

## 17. Aliases and Legacy IDs

### ALIAS-01 — Canonical IDs are what persistence stores

### ALIAS-02 — Alias maps exist only for controlled legacy import/migration

Aliases are not ordinary runtime content references.

### ALIAS-03 — Resolved legacy IDs are normalized to canonical IDs

Do not continue generating new persistent aliases.

## 18. Content Snapshot Identity

Each validated server registry/config state has a ContentSnapshotId.

Conceptually derived from:

- build/release identity;
- registry schema revisions;
- approved live-config revision where relevant.

### SNAP-01 — Snapshot identity is diagnostic/provenance metadata

It does not define gameplay by itself.

### SNAP-02 — Existing outcome/encounter may pin the snapshot that created it

Where TA-7/TA-9/TA-10 require anti-reroll/fairness, the generated entity/occurrence records enough snapshot/version information to preserve the original semantic context.

### SNAP-03 — New snapshot does not rewrite existing instances

## 19. Configuration Classes

TA-5 classifies configuration fields into four classes.

### C0 — Semantic invariant

Examples:

- whether Energy is transferable;
- whether trade is atomic;
- whether paid state changes spawn odds.

Requires owning GDS/TA change control.

Not a live tuneable.

### C1 — Static build content

Examples:

- Species definitions;
- region graph;
- Mutation definitions;
- product semantic grant definition.

Changes ship through reviewed build/content update.

### C2 — Approved live tuneable

Examples may include downstream-approved:

- spawn frequency within safe envelope;
- event schedule;
- non-semantic reward quantity;
- rate/timeout tuning;
- presentation timing.

TA-13 owns rollout.

### C3 — Presentation/local client preference/default

Examples:

- default UI timing;
- cosmetic display parameters;
- non-authoritative visual settings.

### CFGCLASS-01 — A field must declare its class before live override

### CFGCLASS-02 — C0/C1 cannot be silently mutated by a live flag service

## 20. Live Configuration Overlay

TA-13 may later supply a versioned live configuration overlay.

TA-5 constraints:

### LIVE-01 — Overlay may change only explicitly allowlisted C2 fields

### LIVE-02 — Overlay is validated against the same schema/ranges

### LIVE-03 — Unknown keys/IDs fail validation

### LIVE-04 — Rollout is snapshot/versioned

### LIVE-05 — Transactions read one coherent config snapshot

A transaction does not observe half old/half new configuration.

### LIVE-06 — Existing generated identity is not rerolled

Live config affects future generation/actions prospectively.

## 21. Server Lifetime Configuration

### SERVERCFG-01 — Core registry snapshot is immutable for a server lifetime

Baseline C0/C1 content does not hot-reload inside a running production server.

### SERVERCFG-02 — C2 live config may update only through TA-13 controlled snapshot replacement

Domains opt into new snapshot at safe boundaries.

### SERVERCFG-03 — Event/encounter/transaction may pin its starting snapshot

Exact pinning is owned downstream.

## 22. Environment Bindings

Internal semantic IDs are environment-independent.

External Roblox IDs are environment-bound.

Example conceptual mapping:

```text
product/starter-bundle
    DEV     -> DeveloperProductId 123...
    STAGING -> DeveloperProductId 456...
    PROD    -> DeveloperProductId 789...
```

### ENV-ID-01 — Profiles store semantic entitlement/content identity where possible

Do not persist a DEV product ID as the meaning of a commercial entitlement.

### ENV-ID-02 — Environment binding is server-owned configuration

### ENV-ID-03 — Missing production binding is bootstrap/feature-disable error, never silent fallback to another environment

## 23. Asset References

Presentation/world definitions may reference Roblox assets.

### ASSET-01 — Semantic content ID is separate from asset ID

Changing an icon/model/audio asset does not rename the Species/Cosmetic ID.

### ASSET-02 — Asset replacement is version-controlled configuration

### ASSET-03 — Asset IDs are validated for expected field type and environment/publishing ownership where feasible downstream

TA-12/TA-15 refine asset validation/security.

## 24. Commercial Product Identity

TA-5 distinguishes:

- ProductDefinitionId — MonsterVault semantic product;
- DeveloperProductId — Roblox platform/environment ID;
- GamePassId — Roblox pass ID if applicable;
- entitlement/grant definition — semantic server-side outcome.

### PRODUCT-01 — ProductDefinitionId is stable across environments

### PRODUCT-02 — Receipt processing resolves external platform ID to one canonical product definition

TA-11 owns actual receipt processing.

### PRODUCT-03 — Unknown platform product ID never grants a fallback product

## 25. Event Identity

TA-5 owns static EventTemplateId.

TA-10 owns dynamic EventOccurrenceId / server event instance identity.

### EVENT-ID-01 — EventTemplateId is not EventOccurrenceId

A recurring Rift Surge uses the same template but a new occurrence identity.

### EVENT-ID-02 — Historical completion references occurrence identity where semantics require it

### EVENT-ID-03 — Editing a template later does not rewrite prior occurrence provenance

## 26. World Authoring: Tags and Attributes

Roblox supports CollectionService tags and Instance attributes.

TA-5 permits them as **authoring/runtime-link metadata**, not as the canonical game-content database.

### WORLD-AUTH-01 — Tags declare structural role

Examples conceptually:

- `MV.SpawnPoint`;
- `MV.Landmark`;
- `MV.SecurePoint`;
- `MV.TravelNode`;
- `MV.VaultAccessPoint`.

Exact names are TA-17.

### WORLD-AUTH-02 — Attributes carry stable harmless references

Examples:

- `RegionId`;
- `LandmarkId`;
- `SpawnContextId`.

### WORLD-AUTH-03 — Tags/attributes are considered replicated/discoverable when attached to replicated Instances

Never store:

- hidden spawn odds;
- secret reward tables;
- anti-cheat thresholds;
- private product grant data;

on replicated world attributes.

### WORLD-AUTH-04 — Authoring metadata validates at server bootstrap

Unknown IDs, duplicate unique landmarks, invalid role combinations or missing required attributes fail validation.

## 27. CollectionService Boundary

CollectionService is appropriate for finding Instances by authoring/runtime role.

It is not appropriate as persistent identity storage.

### TAG-01 — Tag presence does not equal content identity

Two SpawnPoint Instances can share `MV.SpawnPoint` but reference different SpawnContextIds.

### TAG-02 — Persistent player state never stores a CollectionService tag as its semantic owner/reference when a stable content ID is required

## 28. Runtime Instance Attributes

Attributes may be useful for replicated presentation state where safe.

### ATTR-01 — Attribute replication is not authorization

Clients can inspect replicated attributes.

### ATTR-02 — Critical server state is not made authoritative merely by placing it in an attribute

### ATTR-03 — Runtime attributes use stable IDs, not display names/paths

TA-6/TA-12 decide exact runtime projection usage.

## 29. Probability / Weighted Definitions

TA-5 provides generic schema requirements; TA-7/TA-9 own outcome algorithms.

A weighted table must validate:

- stable entry IDs;
- finite non-negative weights;
- no duplicate entries;
- at least one positive eligible weight when active;
- explicit eligibility filters;
- deterministic content snapshot reference.

### PROB-01 — Weight table is not an outcome

The server random-resolution owner selects the outcome.

### PROB-02 — Paid/spending state cannot be a hidden input

GDS-6/GDS-13 prohibit premium/spending-based collectible odds.

### PROB-03 — Existing generated entity does not reroll when weights change

## 30. Feature Flags Versus Content Definitions

Feature flags are TA-13 runtime rollout controls.

They do not replace registry identity.

### FLAG-01 — A feature flag may gate whether new content is reachable

It does not rename or redefine its static ID.

### FLAG-02 — Flags cannot override C0 invariants

### FLAG-03 — Persisted references remain resolvable when a feature is disabled

## 31. Localization Keys

Display text is not canonical identity.

Definitions reference localization keys.

### LOC-01 — Renaming visible content does not change IDs

### LOC-02 — Missing localization may fall back visually, but does not change semantics

TA-12 owns localization presentation.

## 32. Registry Validation Categories

Generic validation includes:

- ID grammar;
- ID uniqueness;
- expected ID kind;
- schema version;
- required fields;
- allowed fields;
- finite numeric ranges;
- bounded arrays;
- no executable values;
- hard reference resolution;
- lifecycle compatibility;
- public/private pair compatibility;
- environment bindings;
- asset/product reference shape;
- no forbidden C0 live override;
- no hidden commercial state in probability config.

Domain validators add more.

## 33. Validation Severity

### Fatal

Server cannot safely start.

Examples:

- duplicate SpeciesId;
- unknown hard Region reference;
- invalid product binding in enabled production product;
- recursive definition dependency;
- invalid probability table;
- missing server-private pair for active public definition.

### Feature-disabled

A non-core optional feature may be disabled only when its downstream TA explicitly defines a safe independent fallback and GDS allows it.

### Warning

Only non-semantic quality concerns.

Warnings must never hide a persistent-identity integrity problem.

## 34. Content Change Compatibility

Before merging content changes, validate:

- no canonical ID reuse;
- no deletion of referenced retired/tombstone definitions without migration;
- no changed ID kind;
- no broken references;
- no semantic C0 change disguised as tuning;
- no public/private mismatch;
- no environment-binding crosswire;
- no invalid lifecycle transition;
- no retroactive Variant Identity rewrite.

TA-15 later automates these checks.

## 35. Content Lifecycle Transitions

Allowed baseline:

```text
Active -> Retired -> Tombstone
Retired -> Active      (explicit reactivation/change review)
```

Forbidden without special migration/change control:

```text
Active -> deleted
Tombstone -> unrelated new content
```

## 36. Persistence Compatibility

TA-4 stores stable IDs.

TA-5 guarantees:

### PERSIST-ID-01 — Every persisted canonical ID remains resolvable

Either to:

- Active;
- Retired;
- Tombstone;
- explicit migration path.

### PERSIST-ID-02 — Unknown persisted ID fails protected

Do not substitute a random/default Species/Product/etc.

### PERSIST-ID-03 — Tombstone carries enough information for safe historical/owned-state handling

Exact minimum fields depend on registry.

## 37. Network Compatibility

TA-3 remote payloads use typed stable IDs.

### NET-ID-01 — Clients cannot invent a meaningful definition by sending a well-formed ID string

Server resolves against authoritative registry.

### NET-ID-02 — Unknown/retired eligibility is validated server-side

### NET-ID-03 — Display names/asset IDs are not command targets when a semantic ID exists

## 38. Registry Access Pattern

Domains receive typed registry interfaces through explicit construction injection.

Examples conceptually:

- `SpeciesCatalog`;
- `RegionCatalog`;
- `ProductCatalog`.

### ACCESS-01 — No global mutable Registry singleton

### ACCESS-02 — Read-only query interface

### ACCESS-03 — Registry internals are not modified by domains

### ACCESS-04 — Test can inject deterministic fixture registry

## 39. Content Snapshot and Deterministic Testing

TA-15 needs fixture snapshots.

Requirements:

- registry snapshot can be constructed from deterministic test definitions;
- content validation is pure/testable;
- outcome tests pin exact snapshot/version;
- migration tests can load legacy/tombstone IDs.

## 40. Data-Driven Does Not Mean Designer-Unsafe

Source-controlled definitions require code review.

TA-5 does not authorize arbitrary production edits through Studio UI or external admin panels.

TA-13 may later authorize tightly validated live tuning only for C2 fields.

## 41. Current Roblox Authoring Platform Snapshot

TA-5 reviewed current official Roblox documentation on 2026-09-18.

Confirmed platform facts:

- CollectionService manages string tags on Instances and exposes tagged-instance lookup/signals;
- tags are serialized with places and replicate from server to client;
- Instance attributes are custom properties that can be authored in Studio or scripts;
- replicated Instance attributes are readable by clients;
- Roblox reference projects use tags/attributes for instance categorization/configuration;
- `HttpService:GenerateGUID()` is available for GUID generation.

Dated evidence is recorded in `TA5_ROBLOX_CONTENT_AUTHORING_SNAPSHOT.md`.

## 42. Downstream Ownership

### TA-6

- runtime entity representation using stable IDs;
- Instance/tag/attribute projection/lifecycle.

### TA-7

- Creature Variant schema;
- weighted Mutation/Rarity resolution;
- provenance snapshot fields.

### TA-8

- Vault/economy/progression definition schemas and upgrade IDs.

### TA-9

- Region/Landmark/SpawnContext definitions;
- world tag/attribute validation;
- spawn-weight snapshots.

### TA-10

- EventTemplate/EventObjective schemas;
- EventOccurrenceId;
- event/live config snapshot rules;
- trade persistent references.

### TA-11

- ProductDefinition schema;
- external DeveloperProduct/GamePass environment mapping;
- entitlement/grant definitions.

### TA-12

- public presentation/localization/icon definitions.

### TA-13

- live C2 config service;
- feature flags;
- snapshot rollout/rollback;
- experiment configuration.

### TA-14

- registry size/load/validation/live-config budgets.

### TA-15

- content validation CI;
- reference integrity/change compatibility tests.

### TA-17

- actual registry module layout;
- branded ID type helpers;
- exact GUID formatting;
- exact tag/attribute names;
- content-manifest/build ID implementation.

## 43. Open Questions

There are **zero TA-5-blocking open questions**.

Correctly downstream:

- exact Species/Mutation/Trait field schemas — TA-7;
- exact world/spawn schemas — TA-9;
- exact event schema — TA-10;
- exact product grant schema/platform IDs — TA-11;
- exact live-config storage/transport — TA-13;
- exact content budgets — TA-14;
- exact registry source filenames/code generation/validators — TA-17.

## 44. Architecture-Complete Checklist

- [x] identity classes defined;
- [x] stable static ID grammar defined;
- [x] ID immutability/non-reuse defined;
- [x] runtime GUID identity baseline defined;
- [x] Creature instance vs species identity separated;
- [x] typed registry model defined;
- [x] public/server-private split defined;
- [x] declarative definition rule defined;
- [x] future registry layout defined;
- [x] schema/version ownership defined;
- [x] registry bootstrap validation defined;
- [x] referential integrity defined;
- [x] Active/Retired/Tombstone lifecycle defined;
- [x] availability separated from identity;
- [x] legacy alias/migration rules defined;
- [x] ContentSnapshotId defined;
- [x] C0/C1/C2/C3 config classes defined;
- [x] controlled live-overlay boundary defined;
- [x] environment-specific platform binding defined;
- [x] asset/product identity separation defined;
- [x] EventTemplate vs EventOccurrence identity defined;
- [x] CollectionService tag/attribute authoring boundary defined;
- [x] weighted-definition generic validation defined;
- [x] feature flag/localization compatibility defined;
- [x] content-change/persistence/network compatibility defined;
- [x] read-only/injectable registry access defined;
- [x] current Roblox authoring platform reviewed;
- [x] zero TA-5-blocking open questions.
