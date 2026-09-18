# Monetization and Commercial Fairness

> **Status:** Design Complete  
> **Owning GDS phase:** GDS-13 — Monetization and Commercial Fairness  
> **Authority:** Monetization philosophy, authorized paid product classes, prohibited paid advantages, deterministic purchase semantics, commercial capacity/convenience, bounded starter acceleration, cosmetic/status products, event/trading/commercial boundaries, offer presentation, spending-pressure limits, refund/reversal-facing safety, pricing bands, and commercial fairness constraints  
> **Depends on:** ../00_design_authority.md, ../01_game_overview.md, ../global_rules/02_global_game_rules_and_session_model.md, ../player/03_player_character_interaction_and_onboarding.md, ../creatures/04_creatures_collection_and_ownership.md, ../capture/05_capture_contesting_transport_and_extraction.md, ../rarity_mutations/06_rarity_mutations_traits_and_variant_value.md, ../vault/07_vault_base_passive_production_capacity_and_upgrades.md, ../economy_progression/08_economy_progression_unlocks_and_pacing.md, ../world/09_world_biomes_exploration_spawning_and_hazards.md, ../social/10_social_play_cooperation_competition_and_pvp_boundaries.md, ../events_liveops/11_server_events_dynamic_encounters_and_live_content.md, ../trading/12_trading_and_player_economy.md, ../GLOSSARY.md

## 1. Purpose and Commercial Promise

MonsterVault must be commercially sustainable without turning collection value, safety or ordinary progression into a payment problem.

The player-facing commercial contract is:

> **Paying can make my account look more distinctive or make some collection-management friction more convenient, and a small starter purchase may accelerate an early choice, but payment never buys another player's creature, hidden luck, event priority, core safety, required active milestones, a rare-variant reroll, or freedom from intentionally painful free progression. I know what I am buying before I confirm it, and a successful purchase applies once.**

GDS-13 therefore adopts **moderate, visible-but-non-coercive monetization** centered on cosmetics/status and bounded durable convenience.

## 2. Scope

GDS-13 owns:

- baseline commercial philosophy;
- authorized paid product categories;
- prohibited product categories;
- paid cosmetic/status semantics;
- bounded Collection Capacity convenience;
- Display/preset convenience;
- the baseline decision on direct paid Energy;
- the baseline decision on paid production acceleration;
- the baseline decision on paid spawn/rarity/Mutation/capture probability;
- the baseline decision on paid event access/boosts;
- the baseline decision on paid trading advantages;
- starter-value bundle semantics;
- server-wide paid-value decision;
- subscription/pass position;
- deterministic versus randomized purchase boundaries;
- offer truthfulness and price/content disclosure;
- fake-discount/false-urgency restrictions;
- contextual purchase-prompt restrictions;
- exact-once commercial finalization;
- duplicate receipt/retry behavior;
- durable entitlement and revocation-facing behavior;
- purchase/capacity reconciliation;
- free-progression viability;
- premium/non-premium parity boundaries;
- commercial analytics boundaries;
- downstream obligations for presentation, platform safety, retention/analytics and Technical Architecture.

## 3. Explicit Non-Goals

GDS-13 does **not** define:

- final shop layout, purchase-button visuals, price typography, receipt animation or accessibility implementation — GDS-14;
- current Roblox commerce policy, age restrictions, parental controls, regional sale restrictions, randomized-item legal/platform compliance, refund procedures or platform purchase APIs — GDS-15 / Technical Architecture;
- engagement experimentation governance, offer targeting infrastructure or retention campaign scheduling — GDS-16;
- receipt validation implementation, product identifiers, entitlement storage schema or platform API integration — Technical Architecture;
- external advertising networks;
- sponsorship/brand placement;
- creator affiliate programs;
- real-money cash-out/player marketplace;
- player-to-player premium-currency transfer;
- paid randomized creature acquisition;
- loot boxes/gacha/paid eggs;
- paid rarity/Mutation luck;
- paid claim priority;
- premium-only baseline world progression;
- paid trading safety.

## 4. Canonical Terminology

Shared terms remain authoritative in ../GLOSSARY.md.

### Commercial Offer
A player-facing proposal to exchange platform-paid value for a clearly identified MonsterVault Product Grant.

### Durable Entitlement
A successfully finalized paid account entitlement intended to remain available across sessions, such as a cosmetic collection or approved convenience expansion.

### Consumable Product Grant
A paid deterministic grant that is consumed/applied once rather than remaining as a reusable entitlement.

### Cosmetic Entitlement
A paid presentation/status entitlement that changes appearance or expression without changing Creature Instance identity, claim authority, rarity odds, progression milestones or ownership.

### Convenience Entitlement
A paid durable account capability reducing bounded friction without bypassing required active progression or changing finite-opportunity competition.

### Commercial Capacity Expansion
A bounded Convenience Entitlement increasing Collection Capacity and/or Display Capacity without increasing Production Slots, Production Buffer, Offline Production Window, spawn odds or capture priority.

### Starter Value Bundle
A one-time deterministic introductory Commercial Offer containing clearly listed cosmetic value plus a small bounded Energy grant and/or approved convenience value.

### Commercial Finalization
The exact-once persistent result of a verified successful purchase. Retry/reconnect must not duplicate the grant.

### Purchase Pending
A temporary state in which a purchase has been initiated but MonsterVault has not yet established a verified Commercial Finalization result.

### Commercial Reconciliation
The safe process used when a durable paid entitlement becomes unavailable/revoked under a legitimate downstream platform/account outcome. Reconciliation may remove the entitlement's future benefit but cannot silently delete Secured Creatures or create negative Energy/debt.

### Paid Acceleration
A deterministic paid benefit that reduces time/currency friction for progression already obtainable through ordinary play, without granting active Progression Milestones or exclusive required content.

## 5. Commercial Principles

### CP-01 — Payment is optional to the core loop

A non-paying player can:

- complete onboarding;
- capture and secure creatures;
- progress through Starter/Mid/Advanced baseline world access;
- earn meaningful Collection Capacity;
- operate a viable Vault;
- generate/claim Energy;
- participate in ordinary events;
- unlock Trade Access;
- complete ordinary collection/progression goals.

### CP-02 — Free progression cannot be intentionally degraded to sell relief

The design may not make ordinary non-paying progression artificially painful solely so a paid product feels necessary.

### CP-03 — Paying cannot invalidate free-earned value

Commercial products cannot make a non-paying player's:

- Secured Creatures;
- Creature Locks;
- Variant Identity;
- discoveries;
- Access Unlocks;
- Region Mastery;
- Event Completion Records;
- legitimate trade history

strategically meaningless through overwhelming permanent advantage.

### CP-04 — Safety is never premium

Baseline anti-scam, ownership protection, Creature Lock, trade confirmation, accessibility, reporting/safety-relevant controls and non-destructive capacity reconciliation cannot require payment.

### CP-05 — Commercial effects are explicit and deterministic by baseline

A player must know what category/value they are purchasing before confirmation.

GDS-13 baseline authorizes no randomized paid creature/variant outcome.

### CP-06 — Spending history does not secretly personalize gameplay odds

Purchase history, spend amount, failed purchases, reluctance to buy or predicted lifetime value cannot secretly change:

- Species spawn odds;
- Mutation/Trait odds;
- event reward eligibility;
- claim priority;
- capture success identity;
- trade eligibility;
- Recovery behavior.

## 6. Authorized Baseline Product Portfolio

GDS-13 authorizes the following launch-oriented product classes.

### 6.1 Cosmetic and Status Products — AUTHORIZED

Examples include:

- Vault themes;
- Vault decorative sets;
- non-gameplay visual effects;
- player title frames/nameplate treatments;
- emotes/celebration presentation;
- capture-tool skins;
- UI/profile cosmetics where presentation permits;
- non-intrinsic creature presentation accessories if clearly separated from Species/Mutation/Trait/Variant Identity.

### 6.2 Commercial Capacity Expansion — AUTHORIZED, BOUNDED

A durable paid entitlement may grant a bounded amount of:

- additional Collection Capacity;
- additional Display Capacity;
- approved saved collection/Vault presentation presets.

It may **not** directly grant:

- Production Slots;
- Production Buffer capacity;
- Offline Production Window;
- Passive Production multiplier;
- extra active Transport Custody;
- claim priority;
- rare spawn odds.

### 6.3 Starter Value Bundle — AUTHORIZED, ONE-TIME

A one-time starter offer may combine:

- one or more clearly identified cosmetics;
- a small deterministic Energy grant;
- a small approved convenience component.

The total acceleration must be bounded so it helps make an early choice but does not skip the active progression model.

### 6.4 Supporter/Style Pass — AUTHORIZED

A durable one-time pass may bundle:

- cosmetics/status;
- Vault themes/decor;
- approved Commercial Capacity Expansion;
- presentation presets.

It cannot grant forbidden gameplay advantages.

### 6.5 Recurring Subscription — NOT BASELINE AUTHORIZED

A recurring paid subscription is not part of GDS-13 baseline.

Future subscription proposals require GDS-13 change control plus GDS-15 review of recurring-billing/platform safety.

### 6.6 Server-Wide Gameplay Boost — NOT BASELINE AUTHORIZED

GDS-13 authorizes no paid server-wide gameplay modifier to:

- spawn/variant odds;
- event rewards;
- Passive Production;
- capture difficulty/success;
- claim priority;
- world access.

Purely cosmetic server-wide celebration presentation may be proposed downstream if it creates no gameplay/economy effect.

## 7. Cosmetics and Identity Integrity

### CO-01 — Cosmetics do not rewrite Creature Instance identity

A cosmetic cannot change authoritative:

- Species;
- Mutation;
- Trait;
- Variant Signature;
- Availability;
- provenance;
- current owner.

### CO-02 — Cosmetic creature presentation must remain distinguishable from intrinsic variants

If account-owned accessories/effects are ever shown on creatures, the design must not misrepresent them as a Mutation, Legendary status or event provenance.

### CO-03 — Cosmetics do not transfer through creature trading by default

Account-owned cosmetic entitlements remain with the account.

Trading a creature transfers the creature's real instance identity/provenance, not another player's commercial cosmetic ownership.

### CO-04 — Cosmetic ownership cannot grant Discovery

Viewing/equipping a cosmetic never grants Species/Mutation/Variant Discovery.

### CO-05 — Paid status does not create gameplay authority

Titles, frames, supporter badges or visual prestige do not grant claims, spawn odds, event priority, trade authority or Energy multipliers.

## 8. Commercial Capacity Expansion

### CA-01 — Capacity convenience is collection management, not progression authority

Paid Collection Capacity allows the player to keep more owned creatures in ordinary usable collection states.

It does not complete Progression Milestones or Access Unlocks.

### CA-02 — Free capacity progression remains viable

The non-premium Vault path must provide enough Collection Capacity to:

- complete baseline progression;
- retain a representative meaningful collection;
- avoid forced Release for ordinary required progression;
- use the core Vault/production loop.

### CA-03 — Commercial capacity is bounded

Paid capacity cannot be so large that non-paying Collection Capacity becomes strategically irrelevant.

Exact paid-capacity quantity is tuneable, but it must remain a bounded extension rather than an effectively unlimited inventory.

### CA-04 — Paid capacity cannot increase Production Slots

Owning more creatures does not itself increase simultaneous Production Assignments.

Production Slots remain GDS-7/GDS-8 progression authority.

### CA-05 — Paid capacity cannot bypass unresolved ownership safety

Commercial capacity may resolve eligible Overflow-Held state after entitlement finalizes, but purchase failure/pending state cannot cause deletion or unsafe temporary placement.

### CA-06 — Capacity entitlement loss uses safe reconciliation

If a legitimate platform/account reversal removes paid capacity:

- ownership remains intact;
- capacity reconciliation uses GDS-7 Overflow-Held safety;
- no Secured Creature is deleted/released;
- no negative Energy debt is created.

## 9. Paid Energy and Acceleration Decision

### EA-01 — Unlimited direct Energy packs are not baseline authorized

GDS-13 does not authorize an endlessly repeatable direct Robux-to-Energy exchange.

### EA-02 — A Starter Value Bundle may contain a small fixed Energy grant

The grant is deterministic and one-time per eligible account.

### EA-03 — Starter Energy cannot create active Progression Milestones

Paid Energy can satisfy only Energy portions of otherwise-valid purchases/gates.

It cannot directly create:

- Species/Mutation/Variant Discovery;
- Landmark Discovery;
- Region Mastery;
- Field Objective completion;
- Event Contribution/Completion;
- Trade Access Milestone.

### EA-04 — Paid acceleration cannot skip multiple progression bands

The one-time starter grant must remain bounded to early convenience/value rather than functioning as a full progression purchase.

Exact amount is tuneable relative to GDS-8 economy bands.

### EA-05 — No paid debt or negative-wallet recovery

Commercial systems never create Energy debt.

### EA-06 — No individualized paid acceleration

Different players are not secretly offered stronger Energy grants for the same advertised product based on spend propensity, recent losses or progression frustration.

## 10. Production Monetization Decision

### PM-01 — No paid Production Slot unlock at baseline

Production Slots remain earned through ordinary progression.

### PM-02 — No paid Passive Production multiplier

No commercial entitlement multiplies Production Profile rates.

### PM-03 — No paid Production Buffer capacity

Production Buffer progression remains non-premium baseline.

### PM-04 — No paid Offline Production Window extension

Offline Production Window remains earned through ordinary progression.

### PM-05 — No pay-to-idle loop

Payment cannot make AFK/offline Energy generation the dominant progression strategy.

## 11. Capture, Spawn, Rarity and Variant Monetization

### RV-01 — No paid Species spawn-luck boost

Payment cannot increase a player's hidden/public odds of spawning Rare/Epic/Legendary Species.

### RV-02 — No paid Mutation/Trait luck boost

Payment cannot increase Mutation Frequency, Compound chance or Trait rarity.

### RV-03 — No premium rerolls

A player cannot pay to reroll:

- a current World Creature;
- a failed Capture Attempt;
- a Personal Event Capture Opportunity;
- a secured creature;
- a Trade-received creature.

### RV-04 — No paid capture-success modifier

Commercial products cannot directly make an otherwise identical Capture Attempt easier/successful through paid capture power.

### RV-05 — No paid claim priority

Payment cannot reserve public creatures, override Engagement Claims or increase queue/interaction priority for finite opportunities.

### RV-06 — No paid exclusive baseline Species/Mutation

The baseline rare/variant collection aspiration cannot require paid-only Species or Mutations.

Cosmetic commercial content must not masquerade as collectible Species/Mutation completion.

### RV-07 — No randomized paid creature generator

No paid loot box, gacha, egg, crate, spin or premium random Creature Instance/Variant generator is authorized at baseline.

## 12. World and Progression Monetization

### WP-01 — No paid required-region bypass

Payment cannot directly unlock Mid/Advanced Biomes while bypassing required Starter/Mid Region Mastery.

### WP-02 — No paid Landmark/Region Mastery

World exploration/progression proofs remain active-play achievements.

### WP-03 — No premium-only Safe Route

Baseline world progression always retains a viable non-premium traversal route.

### WP-04 — No paid Recovery advantage

Payment cannot prevent ordinary Recovery consequences or buy immunity from hazards in a way that invalidates baseline traversal challenge.

### WP-05 — Paid cosmetics may theme unlocked spaces

Commercial presentation may decorate the Vault/player interface/world presentation without changing world access authority.

## 13. Event Monetization

### EV-01 — No paid event entry for baseline live content

Ordinary GDS-11 Event Occurrences remain available according to progression/access rules rather than a commercial ticket.

### EV-02 — No paid Global Event Window extension/restart

A player cannot buy more event time or a private restarted occurrence.

### EV-03 — No paid Event Contribution credit

Payment does not satisfy contribution thresholds or Event Completion Records.

### EV-04 — No paid event creature priority/luck

Commercial status cannot change event Species/Mutation odds, claim priority or multi-award eligibility.

### EV-05 — Event-themed cosmetics are allowed

A live event may sell deterministic themed cosmetics/status products if:

- event gameplay remains accessible without purchase;
- cosmetics do not fabricate event participation provenance;
- product availability is communicated truthfully.

### EV-06 — Cosmetic event scarcity is not creature scarcity

A limited commercial cosmetic is not an Event-Limited Creature/Variant and must not be represented as such.

## 14. Trading Monetization

### TR-01 — No paid Trade Access

Trade Access Milestone remains non-paid.

### TR-02 — No paid extra confirmation/safety requirement

All players receive the same baseline atomicity, revision reset, Creature Lock and dual confirmation protections.

### TR-03 — No paid Trade Cooldown bypass

Commercial products cannot skip a creature's Trade Cooldown.

### TR-04 — No paid Account-Bound/Time-Lock bypass

Transfer restrictions remain gameplay/content authority.

### TR-05 — No paid trade priority

Premium/supporter status does not prioritize invites, sessions or ownership commits.

### TR-06 — No premium tender

Robux/commercial entitlements cannot be inserted as protected consideration inside a GDS-12 Trade Offer.

## 15. Starter Value Bundle

### SB-01 — One-time per account

The baseline Starter Value Bundle can Commercially Finalize once per eligible account.

### SB-02 — Contents are deterministic and disclosed

No random creature, random cosmetic rarity or random Energy quantity.

### SB-03 — Starter bundle cannot be required for first-session targets

GDS-1 time-to-first-capture/progression targets must remain viable without purchase.

### SB-04 — Starter bundle is not loss-chasing

It is not triggered specifically because the player failed capture, missed a rare creature, lost an event opportunity or lacks enough Energy for one immediate frustrating purchase.

### SB-05 — Starter offer has no fake countdown

If the product is permanent/long-lived, its presentation cannot use a fabricated expiring timer.

A genuine availability window must reflect real product availability.

## 16. Pricing and Product Bands

Reference launch-oriented price bands are tuneable commercial defaults, not semantic guarantees:

| Product class | Reference paid-price band |
|---|---:|
| Small cosmetic / emote / tool skin | 49–149 Robux |
| Cosmetic bundle / Vault theme | 149–399 Robux |
| Starter Value Bundle | 99–199 Robux |
| Durable Supporter/Style + bounded convenience pass | 299–499 Robux |

### PR-01 — Price is explicit before confirmation

The player must see the actual platform price and product contents before purchase confirmation.

### PR-02 — Product type is explicit

The offer must make clear whether value is:

- permanent/durable;
- one-time consumable;
- one-time per account.

### PR-03 — Discounts must be factual

The game cannot advertise an invented former price, fake percentage saving or permanently-on "limited discount".

### PR-04 — Price personalization cannot exploit vulnerability

GDS-13 baseline does not authorize hidden individualized price increases based on spend history, frustration, recent loss or inferred willingness to pay.

Regional/platform pricing behavior outside MonsterVault's control remains GDS-15/platform authority.

## 17. Purchase Prompt Context and Spending Pressure

### SP-01 — No purchase interruption during critical acquisition

Commercial prompts cannot interrupt:

- active Engagement Claim/Capture Attempt;
- Transport Custody/extraction;
- final trade review/Trade Commit;
- Event Multi-Award personal capture resolution;
- Recovery;
- Protected Load Failure.

### SP-02 — No monetized loss-aversion rescue prompt

The game cannot present "pay now or lose this creature" as a baseline commercial mechanic.

### SP-03 — No failure-chasing storefront

After capture failure, event failure or missing a rare opportunity, the game cannot immediately target the player with a paid luck/capture solution.

### SP-04 — No repeated modal nagging

Declining/closing a Commercial Offer must not cause immediate repeated modal resurfacing.

Exact frequency caps belong GDS-14/GDS-16.

### SP-05 — No social shame for non-spenders

UI/status cannot label free players as inferior, poor or blockers.

### SP-06 — Purchase presentation must not obscure the free route

Where a paid convenience product relates to capacity/progression, the ordinary earnable path must remain discoverable.

### SP-07 — No dark-pattern confirmation

The decline/close path cannot be intentionally hidden, mislabeled or designed to create accidental purchases.

## 18. Commercial Finalization and Lifecycle

### CF-01 — A purchase is not granted from client intent alone

Initiating a purchase creates Purchase Pending until verified commercial outcome exists.

### CF-02 — Commercial Finalization is exact-once

Duplicate receipts, retries, reconnects or repeated callbacks cannot duplicate:

- Durable Entitlement;
- Starter Value Bundle;
- Energy grant;
- capacity expansion;
- cosmetic grant.

### CF-03 — Pending purchase does not block ordinary safe play indefinitely

A pending/uncertain purchase should resolve asynchronously from gameplay where possible; implementation belongs downstream.

### CF-04 — Reconnect shows authoritative ownership

After Commercial Finalization, the player sees the durable entitlement/grant consistently across sessions.

### CF-05 — Purchase failure changes no unrelated progression

A failed/cancelled purchase cannot deduct Energy, remove creatures or erase gameplay state.

### CF-06 — Protected Load Failure blocks unsafe persistent commercial application

A purchase may be platform-successful while player persistent gameplay state is unavailable; MonsterVault must not apply irreversible in-profile grants against an unsafe blank profile.

Technical reconciliation belongs downstream.

## 19. Commercial Reversal and Entitlement Reconciliation

### CR-01 — Reversal cannot delete Secured Creatures

If a durable paid capacity entitlement is legitimately removed downstream, GDS-7 Capacity Reconciliation protects all owned creatures.

### CR-02 — Reversal cannot create Energy debt

If a one-time paid Energy grant was previously finalized/spent, GDS-13 does not authorize a negative Energy balance or forced secured-value seizure.

Platform/remediation handling remains downstream.

### CR-03 — Cosmetic entitlement removal affects presentation only

Removing a cosmetic entitlement must not change Creature Instance identity or progression.

### CR-04 — Paid convenience is not provenance

A commercial entitlement cannot fabricate event/legacy/capture provenance, so removing it cannot erase legitimate provenance.

## 20. Non-Premium Viability Tests

A free account must remain able to pass all of the following design tests:

1. secure the onboarding creature;
2. maintain enough Collection Capacity for baseline progression;
3. build a viable production Vault;
4. earn Energy and buy progression;
5. unlock Starter -> Mid A/Mid B -> Advanced through active milestones + Energy;
6. participate meaningfully in live events;
7. pursue Rare/Epic/Legendary and Mutation/Compound collection through play;
8. use Safe Routes/Recovery/Secure Points;
9. unlock baseline trading;
10. complete trades with the same safety guarantees;
11. maintain secured ownership indefinitely without maintenance payment;
12. access core accessibility/safety settings.

Failure of any item means monetization has crossed the GDS-13 fairness boundary.

## 21. Competitive and Social Fairness

### SF-01 — Paid status cannot alter finite-opportunity competition

No commercial product changes:

- Engagement Claim authority;
- Transport Custody;
- ordinary public creature winner;
- event multi-award contribution eligibility;
- Friendly Challenge result;
- trade confirmation authority.

### SF-02 — Paid players cannot impose commercial effects on non-paying players

A purchase cannot deduct another player's Energy, modify their creature odds or force them into paid content.

### SF-03 — Paid social presentation cannot fabricate achievements

Supporter titles/cosmetics remain visibly presentation/status rather than false Region Mastery/Event Completion/trade provenance.

## 22. Product Availability and Scarcity

### AV-01 — Commercial cosmetic availability may rotate

Cosmetic products may be seasonal/rotating/limited if availability is represented truthfully.

### AV-02 — Returning cosmetics may return

Unless explicitly sold as permanently one-time/non-returning (subject to GDS-15 policy), the game should not imply permanent exclusivity.

### AV-03 — Owned commercial cosmetics remain owned after rotation

Removing a cosmetic from sale does not remove previously finalized entitlement.

### AV-04 — Product rotation cannot revoke free gameplay functionality

Core gameplay/safety cannot disappear because a commercial offer ended.

## 23. No Randomized Paid Acquisition Baseline

### RA-01 — No paid random creature outcome

Commercial payment cannot directly produce a random Creature Instance.

### RA-02 — No paid random Mutation/Trait outcome

Commercial payment cannot create a random collectible variant roll.

### RA-03 — No paid loot-box cosmetic baseline

GDS-13 launch baseline also avoids randomized paid cosmetic containers.

Cosmetics are purchased deterministically.

### RA-04 — Future randomized monetization requires reopening GDS-13

It additionally requires GDS-6 probability review and GDS-15 platform/compliance review.

## 24. Subscriptions and Recurring Billing Boundary

### SU-01 — No baseline recurring subscription

Launch monetization does not depend on recurring billing.

### SU-02 — Durable pass preferred to recurring convenience

If the desired benefit can be expressed as a bounded permanent cosmetic/convenience entitlement, baseline uses a durable pass rather than recurring loss of functionality.

### SU-03 — Future subscription cannot ransom owned gameplay

A future subscription cannot make Secured Creatures, earned access, Creature Locks or ordinary Vault functionality disappear when payment stops.

## 25. Commercial Analytics and Experimentation Boundaries

Design-relevant commercial metrics include:

- shop view rate;
- offer impression-to-purchase conversion;
- product-class conversion;
- starter bundle conversion;
- durable pass attachment;
- cosmetic usage;
- capacity-entitlement usage;
- purchase failure/pending/reconciliation rate;
- payer/non-payer progression/retention divergence;
- purchase-prompt dismiss rate;
- post-purchase satisfaction/support signals;
- free-player capacity friction;
- event/shop interaction;
- device/input purchase-flow completion.

GDS-16 may experiment with:

- factual product ordering;
- cosmetic assortment;
- real price points within product strategy;
- bundle composition within authorized categories;
- non-modal offer placement;
- timing after safe progression moments;
- storefront discovery surfaces.

Experiments may **not**:

- personalize gameplay odds from spend;
- create fake discounts/urgency;
- hide the free path;
- target immediately after rare/capture loss with paid rescue;
- enable prohibited Energy packs;
- enable production/luck/claim/trade advantages;
- weaken purchase exact-once behavior;
- make safety/accessibility premium;
- cause payer-only mandatory progression.

## 26. Tuneable Parameters

Tuneable without reopening GDS-13:

- exact Robux prices within/around reference bands;
- cosmetic catalog;
- bundle cosmetic composition;
- exact bounded Commercial Capacity Expansion quantity;
- small Starter Value Bundle Energy amount;
- shop ordering;
- offer duration when genuinely time-limited;
- cooldown between declined commercial prompts;
- product naming/presentation.

Semantic/change-control decisions:

- moderate non-coercive commercial position;
- cosmetics/status as primary monetization;
- bounded Collection/Display Capacity convenience;
- no paid Production Slots/Buffer/Offline Window/multipliers;
- no unlimited direct Energy packs;
- one-time bounded starter Energy only;
- no paid spawn/Mutation/capture luck;
- no paid random creature/variant acquisition;
- no paid claim priority;
- no paid core world/Event/Trade Access;
- no paid trading safety/cooldown bypass;
- no baseline subscription;
- no baseline server-wide gameplay boosts;
- no randomized paid cosmetic containers;
- truthful offers/no fake urgency;
- exact-once Commercial Finalization;
- free route remains viable.

## 27. Dependencies and Downstream Obligations

### GDS-14 — Presentation, UI/UX, Feedback and Accessibility

Must implement clear product contents, price, durable/consumable semantics, close/decline paths, non-modal safe offer placement, purchase pending/success/failure/reconciliation feedback and separation of cosmetic presentation from intrinsic creature identity.

### GDS-15 — Roblox Platform, Social Safety and Moderation Constraints

Must validate all authorized products against current platform commerce, age/parental, regional, randomized-item, disclosure and refund requirements. GDS-15 may further restrict products but cannot expand GDS-13 gameplay advantages without change control.

### GDS-16 — Retention, Discovery, Analytics and Experimentation

Must govern commercial experiments, targeting, cadence and payer/non-payer analysis without allowing metric optimization to override GDS-13 fairness boundaries.

### Technical Architecture

Must implement authoritative product catalog mapping, receipt verification, idempotent Commercial Finalization, durable entitlements, one-time purchase identity, Purchase Pending reconciliation, capacity entitlement application/removal, and auditability.

## 28. Edge-Case Matrix

| Situation | Required behavior |
|---|---|
| Free player begins game | Core loop fully available |
| Free player reaches Mid/Advanced prerequisites | Can progress without Robux |
| Free player pursues Legendary/Mutation | No paid-only requirement |
| Player buys cosmetic | Presentation only |
| Cosmetic resembles Mutation | Must remain distinguishable from intrinsic Mutation |
| Traded creature had owner's paid accessory | Cosmetic entitlement stays with account by default |
| Player buys capacity expansion | Collection/Display convenience only |
| Paid capacity resolves Overflow | Same owned instances move safely; no new creatures |
| Paid capacity entitlement later removed | Capacity Reconciliation; no creature deletion |
| Player asks to buy Production Slots | Not baseline-authorized |
| Player asks to buy x2 production | Not baseline-authorized |
| Player asks to buy longer Offline Window | Not baseline-authorized |
| Player asks to buy Energy repeatedly | Unlimited direct packs not baseline-authorized |
| Player buys Starter Bundle once | Fixed listed grant exactly once |
| Starter purchase callback repeats | No duplicate Energy/cosmetics/capacity |
| Starter purchase attempted again | One-time identity prevents duplicate grant |
| Starter Energy used toward upgrade | Allowed if normal purchase conditions pass |
| Starter Energy attempts to satisfy Region Mastery | Impossible |
| Player asks to buy Mid Biome | Cannot bypass active progression |
| Player asks to buy Trade Access | Not authorized |
| Player asks to buy event ticket | Baseline events not pay-gated |
| Player asks to extend event timer | Not authorized |
| Player asks to buy Event Contribution | Not authorized |
| Player asks to buy rare spawn boost | Not authorized |
| Player asks to buy Mutation luck | Not authorized |
| Player asks to reroll current creature | Not authorized |
| Player asks to buy capture success | Not authorized |
| Player asks to buy claim priority | Not authorized |
| Player asks to buy Trade Cooldown bypass | Not authorized |
| Player asks to bypass Creature Lock | Not authorized |
| Supporter pass owner trades | Same trade safety/priority as free player |
| Paid player enters public rare race | Same claim semantics |
| Commercial prompt appears during capture | Invalid timing |
| Commercial prompt appears during final trade review | Invalid timing |
| Commercial prompt appears during Protected Load Failure | Invalid timing |
| Player fails capture | No paid rescue/luck prompt |
| Player declines shop | No immediate repeated modal nag |
| Permanent product shows fake 5-minute timer | Invalid |
| Genuine rotating cosmetic ends in 5 minutes | Real timing may be shown |
| Shop claims 50% off without real reference | Invalid |
| Same advertised product secretly gives whale more Energy | Invalid |
| Spending history changes spawn odds | Invalid |
| Purchase pending | No duplicate/unsafe premature in-profile grant |
| Purchase fails | No unrelated gameplay loss |
| Purchase succeeds then reconnects | Durable entitlement persists |
| Platform reversal removes cosmetic | Presentation entitlement reconciles only |
| Platform reversal removes capacity entitlement | Safe overflow reconciliation |
| Reversal of spent starter Energy | No negative Energy/debt or creature seizure authorized |
| Event-themed cosmetic purchased | Does not fabricate Event Completion/provenance |
| Cosmetic leaves shop rotation | Existing entitlement remains |
| Future subscription proposed | Requires GDS-13 change control |
| Paid loot box proposed | Requires GDS-13/GDS-6/GDS-15 reopening/review |
| Paid random cosmetic crate proposed | Not baseline-authorized |
| Paid server-wide luck boost proposed | Not baseline-authorized |
| Purely cosmetic server celebration proposed | May be considered if gameplay-neutral |
| Accessibility option proposed as paid | Invalid |
| Scam-protection trade feature proposed as paid | Invalid |
| Player's collection requires maintenance payment | Invalid |
| Player's earned creature removed for not spending | Invalid |
| Paid account receives hidden favorable prices after loss | Invalid |
| Paid account receives hidden better odds | Invalid |

## 29. Open Questions

There are **zero GDS-13-blocking open questions**.

Exact product names, exact price points, cosmetic art catalog, Commercial Capacity Expansion amount, Starter Bundle Energy quantity, storefront layout, regional/platform restrictions, parental controls, refund mechanics, purchase API integration and analytics implementation are tuneable or downstream authority rather than unresolved GDS-13 semantics.

## 30. Design-Complete Checklist

- [x] Monetization philosophy is explicit.
- [x] Authorized product classes are defined.
- [x] Cosmetics/status boundaries are defined.
- [x] Capacity convenience is bounded and non-production.
- [x] Direct Energy decision is closed.
- [x] Starter acceleration is bounded/deterministic.
- [x] Production monetization decision is closed.
- [x] Spawn/rarity/Mutation/capture monetization is prohibited by baseline.
- [x] Event monetization boundaries are defined.
- [x] Trading monetization boundaries are defined.
- [x] Subscription position is explicit.
- [x] Randomized paid acquisition is not baseline-authorized.
- [x] Pricing/presentation truthfulness requirements are defined.
- [x] Spending-pressure/dark-pattern boundaries are defined.
- [x] Commercial Finalization is exact-once.
- [x] Reversal/capacity reconciliation is safe.
- [x] Non-premium viability tests are explicit.
- [x] Platform/presentation/analytics/architecture authority remains downstream.
- [x] No implementation-relevant open questions remain.
