# TA-11 Roblox Commerce Platform Snapshot

> **Snapshot date:** 2026-09-24  
> **Status:** PASS  
> **Authority:** Supporting platform evidence; TA-11 remains MonsterVault semantic authority.

## Primary Sources

- MarketplaceService API: https://create.roblox.com/docs/reference/engine/classes/MarketplaceService
- Developer Products: https://create.roblox.com/docs/production/monetization/developer-products
- Passes: https://create.roblox.com/docs/production/monetization/passes
- Monetization: https://create.roblox.com/docs/production/monetization
- Regional Pricing: https://create.roblox.com/docs/production/monetization/regional-pricing
- Price Optimization: https://create.roblox.com/docs/production/monetization/price-optimization
- Subscriptions: https://create.roblox.com/docs/production/monetization/subscriptions

## MarketplaceService Surface

The current API exposes pass/product prompting, prompt-finished events, ownership/product-info methods, subscription methods, ProcessReceipt, BindReceiptHandler and Robux-transfer capabilities. TA-11 uses only GDS-authorized paths.

## Developer Products

Current Developer Product guidance directs fulfillment through ProcessReceipt and warns against treating PromptProductPurchaseFinished as proof of successful purchase.

ProcessReceipt can return PurchaseGranted after fulfillment or NotProcessedYet when the grant cannot yet complete. Current receipt examples use PurchaseId for dedupe and account for repeated delivery.

**TA-11 consequence:** PurchaseId is the exact-once external receipt identity; prompt completion is never grant authority.

## ProcessReceipt / BindReceiptHandler

Current MarketplaceService documents both. TA-11 chooses one centralized ProcessReceipt adapter for Developer Products because the current Developer Product guide explicitly directs ProcessReceipt, including external Store-tab purchase fulfillment.

MonsterVault must not register competing value-grant paths for the same ProductIds. TA-17 may revisit concrete adapter choice only after revalidation while preserving TA-11 exact-once semantics.

## Passes

Current Pass guidance uses UserOwnsGamePassAsync, PromptGamePassPurchase and PromptGamePassPurchaseFinished, including server-side ownership checks for already-owned benefits.

**TA-11 consequence:** reconcile ownership on join/readiness and after prompt completion; prompt-finished is a refresh trigger.

## External Purchases

Roblox commerce can occur through experience Store surfaces outside the current session. Developer Product guidance relies on receipt handling for such purchase fulfillment.

**TA-11 consequence:** valid purchase truth cannot depend on MonsterVault's own UI having initiated the transaction.

## Regional Pricing / Price Optimization

Current pricing guidance supports user-visible price variation and directs custom UIs to runtime product information rather than hard-coded prices. Price Optimization can test different supported prices across subsets of users.

**TA-11 consequence:** price is platform presentation metadata; deterministic grants do not vary with price. TA-13 governs any pricing experiment.

## Cross-Game Developer Product Change

Current Developer Product guidance states cross-game Developer Product sales were disabled starting 2026-05-30.

**TA-11 consequence:** MonsterVault does not rely on another experience as commerce authority.

## Subscriptions / Robux Transfers

Current platform APIs expose subscription and Robux-transfer capabilities.

**TA-11 consequence:** GDS-13/GDS-12 still prohibit baseline use for recurring MonsterVault gameplay value or protected player-to-player premium tender.

## Revalidation Rule

Any future platform change affecting receipt identity/redelivery, pass ownership, pricing, subscription or transfer semantics requires a new dated review before implementation changes.
