# TA-11 Decision Index

> **Phase:** TA-11  
> **Status:** Accepted

## TA11-D01 — Separate Semantic Product Identity from Roblox IDs
ProductDefinitionId is stable MonsterVault identity; platform IDs are environment bindings.

## TA11-D02 — Keep Sold Grant Meaning Immutable
Materially different grants cannot silently reuse an already-sold binding; legacy mappings remain resolvable.

## TA11-D03 — Use Game Pass Ownership for Baseline One-Time Account Products
Durable cosmetics/capacity/supporter and Starter products use Game Pass ownership where practical; a one-time product is not a repeatable Developer Product protected only by UI.

## TA11-D04 — Reconcile Pass Entitlements from Platform Ownership
Join/readiness and post-prompt refresh query ownership; prompt completion is a refresh trigger.

## TA11-D05 — Treat Ownership API Failure as Unknown, Not Revocation
Failure creates no new entitlement and does not destructively remove last-known-good active state.

## TA11-D06 — Make Starter Historical Grant Separately Exact-Once
Repeated pass reconciliation cannot duplicate historical Starter Energy/value.

## TA11-D07 — Use Server Receipt Authority for Developer Products
PromptProductPurchaseFinished is never grant authority.

## TA11-D08 — Use PurchaseId as Exact-Once Receipt Identity
Immutable receipt facts are journaled by PurchaseId.

## TA11-D09 — Route Receipt Apply Through TA-4 Profile Authority
Apply uses the active lease-owner writer queue or legally acquired profile authority; commerce creates no writer bypass.

## TA11-D10 — Finalize Receipt Journal Only After Profile Apply
FINALIZED follows durable grant + profile marker.

## TA11-D11 — Make Commercial Capacity Reversal Non-Destructive
Removal uses TA-8 Overflow-Held reconciliation and creates no Release/debt.

## TA11-D12 — Treat Runtime Platform Price as Presentation Truth
No hard-coded transactional price; price variation never changes grant semantics.

## TA11-D13 — Disable Subscriptions and Robux Transfers at Baseline
Platform capability alone does not authorize MonsterVault use; GDS change control is required.

## TA11-D14 — Close TA-11 and Advance to TA-12
TA-11 is Architecture Complete — PASS with 240/240 scenarios and zero blocking questions. TA-12 becomes NEXT; gameplay implementation remains blocked until TA-17.
