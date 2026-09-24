# TA-13 Roblox Analytics / Config / Live-Ops Platform Snapshot

> **Snapshot date:** 2026-09-24  
> **Status:** PASS  
> **Purpose:** dated external-platform evidence; not permanent gameplay semantics.

## Sources

- AnalyticsService: https://create.roblox.com/docs/reference/engine/classes/AnalyticsService
- Analytics event types: https://create.roblox.com/docs/production/analytics/event-types
- Custom events: https://create.roblox.com/docs/production/analytics/custom-events
- Custom fields: https://create.roblox.com/docs/production/analytics/custom-fields
- Analytics dashboard: https://create.roblox.com/docs/production/analytics/analytics-dashboard
- ConfigService: https://create.roblox.com/docs/reference/engine/classes/ConfigService
- Experience configs: https://create.roblox.com/docs/cloud/guides/configs
- Cloud-service comparison: https://create.roblox.com/docs/cloud-services/data-stores-vs-memory-stores
- MessagingService: https://create.roblox.com/docs/reference/engine/classes/MessagingService
- Open Cloud: https://create.roblox.com/docs/cloud
- Universe endpoints: https://create.roblox.com/docs/cloud/reference/features/universes
- Config endpoints: https://create.roblox.com/docs/cloud/reference/features/configs

## AnalyticsService

Current surface includes LogCustomEvent, LogEconomyEvent, LogFunnelStepEvent, LogOnboardingFunnelStepEvent, progression events, LogJourneyEvent and GetPlayerSegmentsAsync. Older Fire* analytics APIs shown in the reference are deprecated.

Roblox documents production custom-event emission from servers in published experiences. TA-13 therefore emits consequential metrics after server-authoritative outcomes.

## Current analytics limits

The current event-types/custom-field documentation reports limits including a CCU-based request budget, up to three custom fields for economy/funnel/custom events, 100 custom event names, 10 economy resources, 10 funnels and 100 steps per funnel, with excessive unique values grouped as Other.

These are dated platform limits, not MonsterVault gameplay constants. TA-17/implementation must revalidate them.

## ConfigService / Experience Configs

Current ConfigService is non-replicated and exposes GetConfigAsync / GetConfigForPlayerAsync plus testing helpers.

Experience Configs are intended for feature flags/live variables, are read-only from the experience, support draft/publish/revision history/revert workflows and runtime snapshot refresh/update behavior.

TA-13 uses the global/server config path as baseline and wraps it with MonsterVault C2 allowlist validation + immutable atomic ConfigSnapshot activation. Per-player ConfigService lookup is not baseline value-affecting assignment authority.

## Config API maturity

Current programmatic Open Cloud config endpoints are marked Beta. Therefore programmatic deployment is an optional operator adapter and must be revalidated in TA-17. Runtime correctness cannot depend on a Beta management endpoint.

## Messaging / Open Cloud

MessagingService provides server cross-server publish/subscribe.

Open Cloud currently exposes a stable Publish Universe Message endpoint and a stable Restart Universe Servers endpoint.

TA-13 uses messages only as refresh/emergency-disable accelerators, never durable positive configuration truth.

## Storage distinction

Current Roblox guidance separates:

- DataStore: persistent cross-server data;
- MemoryStore: high-throughput ephemeral data with TTL;
- Configs: read-only-in-game application configuration/feature flags.

MemoryStore is not baseline live-config or analytics authority.

## Security

Open Cloud supports scoped API keys/OAuth 2.0. Production tooling uses least privilege/environment scoping; secrets never live in client code or source-controlled gameplay config.

## Platform player segments

GetPlayerSegmentsAsync exists, including payer/activity-style platform segmentation. GDS-16/TA-13 prohibit using such segments for hidden rarity, claim priority, reward strength, safety or progression treatment.

## Revalidation

TA-17/release review must re-check AnalyticsService methods/limits, ConfigService behavior, config API maturity/auth scopes and universe-message/restart behavior.

**Snapshot result: PASS — current Roblox capabilities support TA-13 without an external runtime framework.**
