# TA-5 Roblox Content Authoring Platform Snapshot

> **Review date:** 2026-09-18  
> **Status:** PASS  
> **Purpose:** Record current Roblox platform behavior relevant to tags, attributes, GUID generation and content authoring boundaries used by TA-5.

## 1. CollectionService

Official source:

https://create.roblox.com/docs/reference/engine/classes/CollectionService

Current platform behavior reviewed:

- CollectionService manages string tags on Instances;
- tags can be queried with GetTagged/GetTags/HasTag;
- instance-added/removed signals are available for a given tag;
- tags are useful for categorizing related runtime/world Instances.

TA-5 consequence:

> Tags may identify world/runtime authoring roles such as SpawnPoint or Landmark, but tag strings are not persistent semantic IDs by themselves.

## 2. Tags in Studio / Replication

Official source:

https://create.roblox.com/docs/studio/properties

Current documented behavior:

- tags can be authored in Studio through the Properties window;
- tags are serialized when places are saved;
- tags replicate from the server to clients.

TA-5 consequence:

> Any tag on a replicated Instance is disclosure-safe metadata only. Hidden odds, security thresholds or private reward data do not belong in tags.

## 3. Instance Attributes

Official source:

https://create.roblox.com/docs/scripting/attributes

Current platform behavior:

- attributes are custom Instance properties;
- attributes can be authored in Studio or set through script;
- attributes can be read via GetAttribute/GetAttributes;
- clients can observe replicated attributes.

TA-5 consequence:

> Attributes may carry stable public references such as RegionId, LandmarkId or SpawnContextId, but replicated attributes are never treated as secret or authoritative merely because they are attached to an Instance.

## 4. Reference Project Use of Attributes / Tags

Official source:

https://create.roblox.com/docs/resources/plant-reference-project

The current Roblox reference project demonstrates:

- attributes as replicated configuration/state metadata;
- tags for categorizing world Instances;
- custom network messages when client-to-server communication is actually required.

TA-5 consequence:

> MonsterVault uses tags/attributes for world authoring linkage and presentation-safe metadata, while authoritative game rules remain in validated server registries/domain logic.

## 5. HttpService:GenerateGUID

Official API references indicate Roblox provides:

- `HttpService:GenerateGUID()`.

TA-5 consequence:

> Server-generated GUID-style identities are a suitable baseline for dynamic CreatureInstanceId, operation/runtime identities and other globally unique runtime entities, subject to exact formatting being locked at TA-17.

## 6. Roblox Packages / Root Attributes

Official source:

https://create.roblox.com/docs/projects/assets/packages

Current package documentation also supports attributes as configurable package-root values.

TA-5 consequence:

> Package attributes may later support Studio-authored asset configuration where appropriate, but source-controlled TA-5 registries remain the semantic source of truth for persistent content identity.

## 7. Disclosure Rule

Current Roblox replication behavior reinforces TA-2/TA-3:

- replicated tags/attributes are inspectable;
- public registry data must therefore be disclosure-safe;
- hidden spawn odds, commercial grant rules and anti-abuse configuration stay server-private.

## Verdict

**TA-5 ROBLOX CONTENT AUTHORING SNAPSHOT: PASS.**
