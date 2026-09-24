# TA-11 — Monetization, MarketplaceService, Receipt Processing, and Entitlements

> **Status:** Architecture Complete  
> **Owning TA phase:** TA-11 — Monetization, MarketplaceService, Receipt Processing, and Entitlements  
> **Authority:** commercial product identity, Roblox commerce bindings, offer authorization, Game Pass ownership reconciliation, Developer Product receipt processing, exact-once Commercial Finalization, durable entitlements, Purchase Pending/retry/reconnect, commercial-capacity/Energy/cosmetic integration, runtime price metadata, reversal/reconciliation, auditability, security and failure behavior  
> **Depends on:** TA-0 through TA-10 Architecture Complete; GDS-13, GDS-14, GDS-15, GDS-16, GDS-17

## 1. Purpose

TA-11 translates GDS-13 into a server-authoritative Roblox commerce architecture.

> **MonsterVault owns stable semantic ProductDefinitionIds; Roblox owns external purchase/ownership facts. Platform IDs are environment bindings, never gameplay identity. Pass ownership is reconciled from MarketplaceService. Developer Product grants finalize only from the server receipt path, keyed by PurchaseId, through a durable journal and TA-4 profile writer. Client prompt events never grant value. Commercial effects are deterministic, exact-once, non-destructive on reconciliation, and cannot alter rarity, claim priority, capture success, event eligibility, trade safety or earned progression.**

No gameplay/commerce Luau implementation is introduced. Concrete services, stores, remotes and schemas remain blocked until TA-17.

## 2. Domain Ownership

TA-11 owns semantic ProductDefinition lifecycle, environment-specific platform bindings, deterministic GrantDefinitions, offer authorization, MarketplaceService adapter semantics, Game Pass reconciliation, Developer Product receipt ingress, PurchaseId journaling, exact-once profile grant application, Purchase Pending, Starter exact-once finalization, durable commercial entitlements, capacity/cosmetic/Energy integration, runtime price metadata, reversal/legacy compatibility, auditability and commerce failure/security behavior.

TA-12 owns UI/accessibility; TA-13 rollout/experiments/analytics governance; TA-14 numeric budgets/retention; TA-15 fault/security harnesses; TA-16 integration audit; TA-17 concrete implementation artifacts.

## 3. Semantic Product Identity and Bindings

Every commercial item uses a stable MonsterVault-owned ProductDefinitionId from TA-5.

Conceptual ProductDefinition:

- ProductDefinitionId;
- lifecycle: Active / Hidden / Retired / Tombstone;
- commercial class and platform kind;
- deterministic GrantDefinitionId;
- repeat policy;
- disclosure/localization keys;
- allowed prompt contexts;
- environment binding key;
- grant semantic version.

**PRODUCT-11-01:** Roblox product/pass/subscription IDs are external IDs, not semantic gameplay IDs.  
**PRODUCT-11-02:** ProductDefinitionId is immutable and never reused.  
**PRODUCT-11-03:** One environment platform ID maps to exactly one compatible ProductDefinition.  
**PRODUCT-11-04:** Duplicate/kind-incompatible bindings fail bootstrap closed.

DEV/STAGING/PRODUCTION use separate bindings where practical:

`ProductDefinitionId + EnvironmentId -> platform ID/type`.

A client-visible platform ID conveys no grant authority.

## 4. Sold-Grant Immutability

Once a product has been purchasable, its material grant meaning cannot silently change under the same platform binding. Material meaning includes entitlement class, capacity amount, cosmetic set, one-time Energy and repeatability.

**GRANT-11-01:** Material change requires a new semantic grant/product version and, when needed for safe distinction, a new platform binding.  
**GRANT-11-02:** Retired/tombstoned mappings retain enough legacy definition to fulfill delayed valid outcomes.  
**GRANT-11-03:** Unknown potentially valid receipts are not acknowledged merely to suppress retry; they enter protected handling.

## 5. Baseline Product Mapping

| GDS product class | Roblox baseline | TA-11 semantics |
|---|---|---|
| durable cosmetic/status | Game Pass | durable entitlement |
| Commercial Capacity Expansion | Game Pass | bounded capacity entitlement |
| Starter Value Bundle | Game Pass | durable ownership + separate exact-once Starter grant |
| Supporter/Style bundle | Game Pass | durable bundled entitlement |
| repeatable deterministic consumable | Developer Product only after explicit GDS authorization | PurchaseId-finalized grant |
| recurring subscription | disabled | GDS-13 change control required |
| player-to-player Robux transfer | disabled | not protected tender |
| randomized paid acquisition | disabled | GDS-13 change control required |

A one-time account product is not represented as a repeatable Developer Product protected only by UI, because a player must not be chargeable repeatedly for value MonsterVault intentionally refuses to grant.

The baseline Developer Product catalog may be empty; the safe receipt architecture is still locked now.

## 6. Commercial Offer Authorization / Purchase Pending

The server authorizes an offer only if its product is Active, binding valid, session trusted, product eligibility satisfied, current context commercially safe and truthful runtime product information available.

Blocked contexts include active capture/claim, Transport Custody, final trade review/commit, event personal capture resolution, Recovery and Protected Load Failure.

Purchase Pending is reconciliation state, not provisional value.

**PENDING-11-01:** Pending grants no capacity, cosmetics, Energy or gameplay authority.  
**PENDING-11-02:** Safe gameplay continues where possible while commerce resolves.  
**PENDING-11-03:** Reconnect derives truth from ownership/receipt/profile state, never a previous modal.

External valid platform purchases remain reconcilable even when they did not originate from MonsterVault's current UI.

## 7. Game Pass Ownership Authority

On profile readiness, MonsterVault reconciles configured pass ownership using MarketplaceService. PromptGamePassPurchaseFinished is a refresh trigger; durable mutation uses the same ownership-reconciliation path as join.

**PASS-11-01:** Positive successful ownership may activate mapped entitlement.  
**PASS-11-02:** API failure is VerificationUnknown, not VerifiedInactive.  
**PASS-11-03:** Unknown neither grants a new entitlement nor destructively revokes last-known-good active ownership.  
**PASS-11-04:** Successful authoritative negative ownership may deactivate and invoke safe reconciliation.  
**PASS-11-05:** External pass purchases are discovered on later reconciliation.

**PASS-11-06:** A VerificationUnknown result schedules bounded asynchronous in-session ownership reconciliation while the session remains eligible. The retry uses backoff/jitter, is coalesced per player/product, and stops on authoritative positive/negative resolution, session end, product retirement/ineligibility, or the TA-14 retry budget. A player is not required to reprompt, reconnect, or reopen the shop to obtain a retry.

**PASS-11-07:** Exhausting the current in-session retry budget preserves VerificationUnknown/Pending without inventing entitlement truth; a later safe reconciliation trigger (for example renewed session readiness, product-state refresh, or reconnect) may resume attempts under the current budget policy.

The profile stores a durable entitlement projection with ProductDefinitionId, source kind/binding reference, active state, last successful verification, grant version and reconciliation state. Entitlement activation/removal is P2 when persistent capability/value changes.

## 8. Starter Value Bundle

The Starter Value Bundle combines durable one-time account ownership with a separate exact-once historical grant.

Allowed deterministic grant components: listed cosmetics, bounded convenience and a small fixed Energy grant.

Stable grant identity derives from `UserId + ProductDefinitionId + GrantSemanticVersion`.

**STARTER-11-01:** repeated ownership checks cannot duplicate the historical grant.  
**STARTER-11-02:** Starter Energy and its grant marker commit through the same TA-4 P2 profile operation; overflow uses TA-8 Deferred Energy.  
**STARTER-11-03:** reversal never creates Energy debt or claws back already-spent Starter Energy.  
**STARTER-11-04:** revocable capacity/cosmetic components reconcile separately from historical Energy.

## 9. Developer Product Receipt Authority

TA-11 baseline uses one centralized server-side MarketplaceService.ProcessReceipt adapter for Developer Products.

PromptProductPurchaseFinished is presentation/pending feedback only.

**RECEIPT-11-01:** only the platform receipt callback authorizes a Developer Product grant.  
**RECEIPT-11-02:** PurchaseId is the durable exact-once receipt identity.  
**RECEIPT-11-03:** PlayerId/ProductId must resolve to a valid environment binding.  
**RECEIPT-11-04:** unavailable/unsafe/foreign-owned profiles yield NotProcessedYet rather than unsafe writes.  
**RECEIPT-11-05:** PurchaseGranted is returned only after the grant is durably proven exactly once.

## 10. Durable Receipt Journal

A dedicated durable journal is keyed by PurchaseId.

Stable identity/comparison facts include PurchaseId, PlayerId, ProductId, ProductDefinitionId, GrantSemanticVersion and grant hash.

`firstSeenAt` is **set-on-create journal metadata**, not receipt identity. A redelivery observed later or by another server retains the original journal firstSeenAt and does not compare the new local observation time as an immutable receipt fact. Optional CurrencySpent is receipt/audit metadata and never changes grant semantics.

State:

`RECEIVED -> PROFILE_APPLY_PENDING -> PROFILE_APPLIED -> FINALIZED`

Invariant contradiction -> `QUARANTINED`.

Same PurchaseId plus the same stable receipt/grant identity facts is idempotent even when redelivery is observed at a different local time. Conflicting stable identity facts quarantine. FINALIZED replay acknowledges without regrant.

## 11. Receipt Profile Apply and Finalization

Grant application always obeys TA-4 profile authority.

A live profile lease routes work through the lease owner's one-writer queue. A commerce/recovery worker never directly mutates a profile behind another server's active aggregate.

Profile apply:

1. validate receipt journal identity/hash;
2. validate product/grant compatibility;
3. check PurchaseId applied marker;
4. apply deterministic grant atomically if absent;
5. record the marker;
6. checkpoint durably.

Journal FINALIZED may occur only after durable profile apply.

If journal finalization fails after profile apply, return NotProcessedYet and retry the same PurchaseId; the profile marker suppresses duplicate value.

**FINAL-11-01:** FINALIZED never precedes profile apply.  
**FINAL-11-02:** every crash cut resolves to zero or one durable grant.  
**FINAL-11-03:** terminal dedupe evidence is not destructively compacted without a proven safe platform-redelivery horizon.

## 12. Failure Semantics

Unknown ProductId -> quarantine/alert + NotProcessedYet.  
Profile not Ready / Protected Load Failure -> NotProcessedYet.  
DataStore throttle/error -> preserve reconciliable state + NotProcessedYet.  
Unknown UpdateAsync result -> re-read same PurchaseId/profile marker, never mint a new operation identity.  
Shutdown -> stop new local admission; unresolved receipts remain retryable.

Pass ownership API failure preserves last-known verified state as unknown, not destructive false.

## 13. Commercial Capacity / Cosmetic / Energy Integration

Commercial Capacity is an additive bounded Collection/Display component consumed by TA-8.

Activation never changes Production Slots, Buffer, Offline Window, production rate, Capture Capability or claim priority.

Removal recomputes capacity and uses deterministic non-destructive Overflow-Held reconciliation; it never Releases creatures or creates Energy debt.

Commercial cosmetics/status modify presentation only and cannot alter Species, Mutation, Trait, Rarity, Variant Identity, Discovery, event/world completion or trade provenance.

Only the bounded Starter Value Bundle Energy grant is baseline-authorized. No repeatable Developer Product grants Energy under current GDS-13.

## 14. Runtime Product Price Metadata

MonsterVault does not hard-code a Robux amount as transaction truth.

Custom storefront UI retrieves current runtime product information. The platform prompt remains the final purchase-confirmation surface.

Regional/managed price variation and platform-reported CurrencySpent never change deterministic MonsterVault grant strength.

If current product metadata cannot be loaded, custom UI cannot present a stale numeric price as current fact.

Price optimization is TA-13-governed and cannot violate GDS-13 fairness or TA-11 grant invariants.

## 15. Product Lifecycle and Reversal

Active -> prompt/reconcile.  
Hidden -> normally no prompt, but valid ownership/receipts reconcile.  
Retired -> no new prompt; existing owners and delayed receipts remain valid.  
Tombstone -> compatibility/reconciliation only.

Capacity loss uses Overflow-Held, never Release. Historical Starter Energy is never clawed back into debt. Cosmetic removal affects presentation only. Legitimate capture/event/trade provenance is never erased by commercial reversal.

## 16. Prohibited Commercial Paths

No active binding/grant mapping exists for paid Species/Mutation/Trait luck, rerolls, capture-success modifiers, claim priority, Event Contribution/time extension, Trade Access/safety/cooldown bypass, Production Slots/Buffer/Offline Window/rates, randomized paid creature/variant acquisition, randomized paid cosmetics baseline, premium player-to-player tender, baseline subscription, paid server-wide gameplay boosts or required paid world access.

Definitions attempting prohibited effects fail validation.

## 17. Subscription / Robux Transfer Boundary

Roblox platform capability does not itself authorize MonsterVault gameplay use.

No subscription ProductDefinition is Active at baseline. A future subscription requires GDS-13 change control and TA-11 revalidation.

Robux is not a GDS-12 Trade Offer field. TA-11 creates no player-to-player Robux reward, fee or protected tender.

## 18. Security / Audit / Observability

The client can request to view/prompt a known offer, but never supplies purchase success truth, receipt identity, ProductId-to-grant mapping, grant amount, entitlement state or journal state.

Bounded commercial audit records include semantic product identity, platform kind/binding reference, PurchaseId where applicable, UserId, grant version/hash, entitlement transition, profile revision, reason/result and timestamps.

Never log payment instruments, raw economic-location signals, private billing details or unrelated full profiles.

Observability covers ownership-query failures, Purchase Pending duration, receipt retries/duplicates, journal transitions, profile-apply latency, NotProcessedYet reasons, quarantine, capacity reconciliation and Starter dedupe.

## 19. Performance / Testability

Before TA-14 exact budgets:

- immutable server-local product registries;
- bounded ownership checks;
- freshness-bounded price metadata caching;
- no per-frame commerce polling;
- bounded receipt callback work;
- no full-store receipt scans;
- PurchaseId-keyed recovery.

Injectable/testable boundaries: MarketplaceService adapter, pass ownership resolver, product-info resolver, receipt source, receipt journal repository, profile commerce adapter, clock, Product Binding Registry, prompt policy, TA-8 integration and failure injection at every receipt transition.

## 20. Downstream Handoffs

TA-12 owns storefront/prompt UI, accessibility and Pending/success/failure/reconciliation feedback.

TA-13 owns commercial analytics, rollout, price/order experiments and live administration within GDS-13.

TA-14 locks ownership/product-info/receipt/DataStore/retry/retention budgets.

TA-15 fault-tests duplicate receipts, cross-server replay, all journal/apply cut points, reversal, spoofing and prohibited mappings.

TA-16 performs integration audit.

TA-17 locks concrete schemas/services/stores/remotes/bindings and implementation order.

## 21. Critical Invariants

1. Platform IDs never replace MonsterVault semantic product identity.
2. Sold grant meaning never silently changes under an existing platform binding.
3. Client prompt completion never grants Developer Product value.
4. PurchaseId identifies one Developer Product Commercial Finalization.
5. Receipt FINALIZED never precedes durable profile apply.
6. Receipt apply obeys TA-4 lease ownership/one-writer serialization.
7. Duplicate receipt/retry/reconnect cannot duplicate value.
8. Game Pass ownership reconciliation, not UI state, governs pass entitlement.
9. API failure is unknown, not proof of entitlement absence.
10. Starter historical grant applies once and is never clawed into debt.
11. Capacity entitlement loss is non-destructive.
12. Commercial entitlements never change rarity/capture/claim/event/trade authority.
13. Runtime price variation never changes deterministic grant semantics.
14. Subscriptions and Robux transfer remain disabled baseline capabilities.
15. Retired/tombstoned products remain resolvable for delayed valid outcomes.

## 22. Open Questions

There are **zero TA-11-blocking open questions**.

Downstream/tuneable: exact catalog/IDs/prices/capacity quantities; TA-12 UI; TA-13 rollout/experiments; TA-14 retry/budget/retention; TA-17 concrete service/store/schema names.

## 23. Architecture-Complete Checklist

- [x] semantic product/platform binding separation;
- [x] sold-grant immutability;
- [x] baseline product-kind mapping;
- [x] Game Pass reconciliation;
- [x] Starter exact-once grant;
- [x] Developer Product receipt authority;
- [x] PurchaseId journal and profile-before-finalization ordering;
- [x] TA-4 profile-authority integration;
- [x] failure/retry/reconnect/shutdown behavior;
- [x] capacity/cosmetic/Energy integration;
- [x] runtime/regional price boundary;
- [x] reversal/retirement compatibility;
- [x] prohibited commercial paths;
- [x] subscription/Robux-transfer boundaries;
- [x] security/observability/testability;
- [x] zero implementation-critical questions.
