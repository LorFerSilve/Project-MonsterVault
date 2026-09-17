# Economy, Progression, Unlocks, and Pacing

> **Status:** Design Complete  
> **Owning GDS phase:** GDS-8 — Economy, Progression, Unlocks, and Pacing  
> **Authority:** Baseline soft-currency semantics, resource sources/sinks, progression transactions, Vault/equipment/access upgrade economics, active-progression requirements, pacing bands, catch-up rules, inflation controls, economy-facing rarity/Trait boundaries, and prestige/reset position  
> **Depends on:** `../00_design_authority.md`, `../01_game_overview.md`, `../global_rules/02_global_game_rules_and_session_model.md`, `../player/03_player_character_interaction_and_onboarding.md`, `../creatures/04_creatures_collection_and_ownership.md`, `../capture/05_capture_contesting_transport_and_extraction.md`, `../rarity_mutations/06_rarity_mutations_traits_and_variant_value.md`, `../vault/07_vault_base_passive_production_capacity_and_upgrades.md`, `../GLOSSARY.md`

## 1. Purpose and Player Fantasy

MonsterVault needs an economy that makes the collection loop feel increasingly capable without turning the game into an idle spreadsheet, a compulsory grind, or a pay-to-bypass ladder.

The player-facing contract is:

> **The creatures I secure help my Vault produce useful progression value; active exploration and collection still matter; I can understand what I am saving for; spending is exact and trustworthy; and long-term progression expands my options without deleting the collection I already earned.**

GDS-8 therefore turns the GDS-7 Vault output into an explicit progression economy while preserving the closed ownership, capture, rarity, and lifecycle contracts.

## 2. Scope

GDS-8 owns:

- the canonical baseline non-premium progression currency;
- wallet semantics and economy-integrity rules;
- source and sink categories;
- the economic role of GDS-7 Passive Production and Production Claims;
- active-play reward philosophy;
- progression requirements that cannot be satisfied by passive currency alone;
- Vault Upgrade pricing/progression semantics;
- capture-capability/equipment progression economics;
- region/access unlock economics and prerequisite semantics;
- bounded Trait influence on production/economy;
- creature Release/sale baseline economic consequences;
- exact-once purchase/spend/refund-facing behavior;
- early/mid/long-term pacing bands;
- production-versus-active-play contribution targets;
- cost-curve and compounding guardrails;
- catch-up behavior;
- inflation and late-economy controls;
- balance-change rules;
- prestige/reset position;
- downstream obligations for world, social, events, trading, monetization, presentation, platform safety, analytics, and Technical Architecture.

## 3. Explicit Non-Goals

GDS-8 does **not** define:

- ownership, Release confirmation, Creature Lock, or Overflow-Held semantics — GDS-4;
- capture state machine, contesting, Transport Custody, or Secured Ownership Finalization — GDS-5;
- rarity/Mutation/Variant identity or probability — GDS-6;
- Production Assignment, Production Buffer, Offline Production Window, Production Claim, or Vault Upgrade transaction semantics — GDS-7, except their economic values/progression here;
- exact world/biome topology, encounter tables, hazards, or physical access-point placement — GDS-9;
- party/co-op/PvP/social-reward rules — GDS-10;
- event cadence, event reward allocation, or live modifiers — GDS-11;
- player-to-player trade rules, market price, or ownership-transfer mechanics — GDS-12;
- Robux products, game passes, subscriptions, paid Energy, or paid acceleration — GDS-13;
- final UI/art/audio presentation — GDS-14;
- Roblox policy/compliance details — GDS-15;
- retention campaign scheduling or experiment infrastructure — GDS-16;
- persistence/database/transaction/RNG implementation — Technical Architecture.

## 4. Canonical Terminology

Shared terms are normalized in `../GLOSSARY.md`.

### Energy
The baseline non-premium soft progression currency. Energy is persistent, fungible, non-negative, and spent on approved progression sinks. It is not premium currency and is not automatically tradeable between players.

### Energy Wallet
The player's persistent Energy balance. The wallet stores whole Energy units and may not become negative.

### Economy Source
An authorized event that creates Energy from outside the player's existing Energy Wallet, such as a Production Claim or approved active-play reward.

### Economy Sink
An authorized event that permanently removes Energy in exchange for a defined progression, utility, access, or approved presentation outcome.

### Progression Milestone
A persistent non-currency record proving that a player completed meaningful active gameplay or collection progression. Milestones may gate access independently of Energy and cannot be bought merely by possessing more Energy.

### Progression Gate
A requirement set that must be satisfied before a progression action becomes available. A gate may require one or more Progression Milestones, prior unlocks, Collection/Vault state, and/or an Energy cost.

### Progression Purchase
>An exact-once player-initiated transaction that spends Energy and grants one persistent progression effect.

### Capture Capability
The persistent progression level/capability of the player's ordinary capture equipment. It may affect eligible challenge assistance, allowed encounter classes, or bounded capture tuning under GDS-5, but does not override claim/finalization rules.

### Access Unlock
A persistent exact-once progression effect granting access to a defined content/region/capability gate. GDS-9 owns the actual world region and topology.

### Economy Band
A tuning segment representing a comparable stage of progression for pricing/reward evaluation. It is a balance concept, not a visible player rank unless presentation later chooses to expose it.

### Catch-Up Adjustment
A visible, deterministic, globally/cohort-defined adjustment intended to reduce obsolete progression friction for eligible players without hidden spending-based personalization or skipping required active milestones.

## 5. Baseline Currency Model

### EC-01 — Energy is the single baseline soft progression currency
The launch-baseline economy uses one general-purpose non-premium soft currency named **Energy**.

Additional soft currencies require explicit later design authority and must justify why they cannot be represented by Energy plus non-currency Progression Milestones.

### EC-02 — Energy is persistent and session-independent
Finalized Energy survives ordinary avatar failure, reset, disconnect, reconnect, server transition, device change, and server shutdown under GDS-2.

### EC-03 — Energy is non-negative whole-unit value
Baseline Energy uses whole units from the player's perspective. The wallet may never display or finalize a negative balance.

Technical numeric representation belongs to Technical Architecture.

### EC-04 — Energy is not premium currency
Energy does not represent Robux or a premium balance. GDS-8 does not authorize direct real-money conversion in either direction.

### EC-05 — Energy is not baseline player-to-player transferable
Players cannot directly send/drop/gift Energy to one another under the baseline economy. Any future player-currency transfer requires GDS-12 explicit authority and value-integrity review.

### EC-06 — Energy does not alter rarity/variant odds
Wallet balance, recent spending, saving behavior, progression purchase history, or Energy poverty/wealth cannot secretly change Species Rarity or Mutation odds.

## 6. Energy Sources

Authorized baseline source categories are intentionally limited.

### ES-01 — Vault Production Claim
GDS-7 Production Claim is the baseline recurring passive Energy source.

A successful claim transfers eligible Production Buffer output into the Energy Wallet exactly once.

### ES-02 — Active Progression Rewards
Active exploration/collection systems may award bounded Energy for explicit gameplay objectives, milestones, first-time progression, or world activities defined by their owning later phases.

Rewards must correspond to meaningful activity rather than raw connected time.

### ES-03 — Onboarding rewards
Onboarding may grant a small deterministic Energy amount or a free first progression effect when needed to satisfy GDS-1 time-to-fun targets.

Replay/reconnect cannot duplicate finalized onboarding rewards.

### ES-04 — Event rewards are downstream-authorized
GDS-11 may create bounded Event Energy rewards. GDS-8 establishes that those rewards enter the same Energy economy and must preserve exact-once finalization and economy-health constraints.

### ES-05 — Compensation/admin remediation is exceptional
Support/remediation may grant Energy when correcting a verified value loss or service issue. Compensation is not a normal progression source and requires traceable reason semantics in Technical Architecture.

### ES-06 — No baseline Energy for merely releasing creatures
Voluntary GDS-4 Release grants **zero Energy by default**.

Release is a collection-management/destructive action, not a creature-sale mechanic. A future salvage/sale system requires explicit GDS-8 change control because it materially changes capture incentives, duplication pressure, and collection value.

### ES-07 — No baseline per-capture Energy payout
Ordinary repeated capture does not automatically mint Energy merely because Secured Ownership Finalization occurred.

First-time/milestone/world-objective rewards may reference capture outcomes, but the economy must not create a dominant loop of farming common creatures solely to liquidate repeated captures.

## 7. Energy Sinks

### EK-01 — Vault Upgrades
Energy may purchase GDS-7 Vault Upgrade levels such as:

- Collection Capacity;
- Production Slot count;
- Production Buffer capacity;
- Offline Production Window;
- Display Capacity;
- approved Vault utility/presentation capabilities.

### EK-02 — Capture Capability upgrades
Energy may purchase persistent Capture Capability improvements.

Baseline ordinary capture does **not** require a mandatory Energy payment for every attempt. Progression is primarily through durable capability, not a universal per-attempt tax.

### EK-03 — Access Unlocks
Energy may form one component of persistent region/content Access Unlocks. Relevant active-play Progression Milestones may also be required.

### EK-04 — Exploration/utility upgrades
Energy may purchase approved durable traversal/exploration/utility capabilities when their gameplay behavior is defined by the owning subsystem.

These upgrades cannot contradict GDS-3's ordinary locomotion contract or make the baseline player character unusable without payment.

### EK-05 — Presentation sinks may exist later
Optional cosmetic/Vault-presentation soft-currency sinks are compatible with GDS-8 and useful as late-game sinks, but their concrete catalog/presentation belongs downstream.

### EK-06 — No mandatory maintenance tax on owned collection
Energy is not periodically deducted merely to keep Secured Creatures, Creature Locks, already-earned ownership, or ordinary persistent Vault state alive.

Failure to pay maintenance cannot delete, Release, downgrade, or seize owned creatures.

### EK-07 — No debt
If a player cannot afford a cost, the progression action does not finalize and the wallet remains unchanged. Baseline progression does not create negative Energy, loans, interest, or debt pressure.

## 8. Production Economics

### PE-01 — Production Profile values are Species-authored economic characteristics
Each Species eligible for GDS-7 production may define a baseline Production Profile whose exact Energy rate is tuneable content data.

### PE-02 — Species Rarity is not an automatic production multiplier
Common, Uncommon, Rare, Epic, and Legendary labels do not imply fixed income multipliers.

A Legendary Species may have a high, medium, or specialized Production Profile; a Common Species may remain economically useful.

### PE-03 — Mutation prestige is not automatic income
Mutation presence, Mutation Frequency Band, Compound status, Protected Variant status, Availability Tag, or Provenance does not automatically multiply Energy output.

A specific Mutation may affect production only if explicit later design assigns a bounded mechanical hook; prestige alone is insufficient.

### PE-04 — Traits may provide bounded situational production effects
A Trait may alter production only through an explicit authored rule.

Trait effects must:

- be bounded;
- remain understandable in collection/Vault detail;
- avoid one universal best Trait across all production contexts;
- preserve the instance's stable Trait identity;
- not alter ownership/finalization;
- remain tuneable without rerolling the Trait.

### PE-05 — No negative base production from an eligible assignment
An eligible ordinary Production Assignment never consumes Energy merely by remaining assigned. A production Trait may not turn a normal assigned creature into a passive Energy drain.

### PE-06 — Online presence does not secretly multiply passive rate
The GDS-7 baseline passive rate is elapsed-time based. Remaining AFK-connected does not receive a hidden passive-rate multiplier unavailable to disconnected players.

Active gameplay may earn separate Active Progression Rewards.

### PE-07 — Offline production uses the same baseline production semantics
Offline accrual uses the finalized assignment's eligible rate until the Offline Production Window or Production Buffer cap ends accrual.

GDS-8 does not apply an automatic offline-efficiency penalty. The cap/window is the bounding mechanism.

### PE-08 — Reference Vault progression tuning
Initial balancing should target the following reference shape, all explicitly tuneable through playtesting without changing semantics:

| Capability | Reference starting value | Reference progression shape |
|---|---:|---|
| Collection Capacity | 12 ordinary usable creatures | +6-per-tier style expansion; exact tier count tuneable |
| Production Slots | 2 | gradual expansion toward roughly 5–6 baseline slots |
| Display Slots | 3 | presentation expansion independent from production |
| Offline Production Window | 2 hours | staged upgrades toward 4h, 8h, then 12h baseline cap |
| Production Buffer | roughly 2 hours of expected starting-Vault output | expand in stages aligned with production growth |

These are launch-balance defaults, not immutable semantic rules. They may be tuned provided capacity safety, bounded offline accrual, and non-premium viability remain intact.

## 9. Active Progression and Anti-Idle Gating

### AP-01 — Energy alone cannot complete the entire progression ladder
Major progression cannot be reduced to “wait offline until enough Energy exists.”

Key content Access Unlocks must be allowed to require one or more Progression Milestones earned through active gameplay/collection.

### AP-02 — Progression Milestones are non-spendable proofs, not a second currency
Examples include:

- legitimate Species Discovery count/sets;
- completion of a prior region/world objective;
- first secure capture of a required category;
- completion of an onboarding/progression milestone;
- other explicit active achievements defined downstream.

A Milestone is not consumed when checked unless its owning design explicitly defines a consumable resource, which GDS-8 baseline does not.

### AP-03 — Access Gates may combine milestone plus Energy requirements
A major unlock may require:

```text
required prior unlock(s)
AND required active Progression Milestone(s)
AND Energy >= displayed cost
```

This preserves both economic planning and active game participation.

### AP-04 — Passive production cannot fabricate Milestones
Offline production, Production Claim, wallet balance, or paid acceleration cannot by themselves create Species Discovery, capture milestones, world-completion milestones, or other active proofs.

### AP-05 — First-session progression remains gameplay-first
The first meaningful progression choice should be reachable around GDS-1's opening target without requiring a long idle wait, store visit, or optimization spreadsheet.

## 10. Progression Transactions

### PT-01 — Every persistent purchase is exact-once
A Progression Purchase is a Finalized Outcome. Duplicate input, network retry, reconnect, or server transition cannot duplicate cost or effect.

### PT-02 — Cost and effect are atomic from the player's perspective
A finalized Energy cost must correspond to the intended finalized progression effect.

The game may not permanently deduct Energy and then silently fail to grant the purchased persistent effect.

### PT-03 — Insufficient funds causes no partial spend
Unless a future mechanic explicitly defines staged contribution, baseline purchases require the full displayed cost at finalization. Failure leaves the Energy Wallet unchanged.

### PT-04 — Cost is revalidated at commit
If configuration changes while a purchase UI is open, the player cannot be silently charged a higher cost than the confirmation they accepted.

The action must either honor the valid quoted transaction under an explicit quote window or require a new confirmation with the updated cost; exact policy is selected by Technical Architecture/UX, but silent surprise charging is prohibited.

### PT-05 — Already-owned exact-once unlocks cannot be rebought accidentally
Attempting to purchase an already-finalized one-time Access Unlock or maxed upgrade cannot consume Energy again for no effect.

### PT-06 — Uncertain failure favors recoverability
If the player cannot determine whether a transaction finalized, later reconciliation must resolve to one authoritative result: effect+cost together, or neither. Repeated manual spending must not be required to discover the outcome.

## 11. Vault Upgrade Economy

### VU-01 — Upgrade categories remain independently priced
Collection Capacity, Production Slots, Production Buffer, Offline Production Window, Display Capacity, and other approved capabilities may use different cost curves.

### VU-02 — Costs generally rise with progression value
Within one upgrade line, later tiers should ordinarily cost more Energy than early tiers because they serve later Economy Bands and compound with existing capability.

A later tier may intentionally hold/reduce cost only through explicit catch-up/rebalance rather than accidental inconsistency.

### VU-03 — Production compounding must be controlled
An upgrade that increases Energy generation must not create a runaway loop where its own marginal production repays the purchase almost immediately and accelerates every next upgrade exponentially.

As a reference balance guardrail, a pure passive-production expansion should generally have a marginal payback period measured in **multiple normal sessions**, not minutes. Exact ROI targets are tuneable after telemetry.

### VU-04 — Functional core Vault progression remains non-premium viable
The non-premium progression path must support useful Collection Capacity, Production Slots, Buffer, and Offline Window growth. Premium systems defined later may accelerate/convenience-optimize but cannot be the only path to a functional Vault.

### VU-05 — Capacity upgrades cannot ransom existing ownership
Players may be incentivized to expand ordinary usable capacity, but Overflow-Held ownership remains safe. No upgrade screen may claim that payment is required to prevent deletion of owned creatures.

## 12. Capture Capability Economy

### CC-01 — Baseline capture progression is durable capability
The baseline economy favors persistent Capture Capability upgrades rather than mandatory consumable Energy costs on every ordinary attempt.

### CC-02 — Capability cannot override GDS-5 claim/finalization semantics
Higher Capture Capability cannot:

- steal another player's active Engagement Claim;
- auto-finalize ownership before extraction;
- create multiple winners from a finite single-award creature;
- bypass capacity/overflow eligibility rules;
- reroll the same finalized Variant Identity.

### CC-03 — Encounter requirements must be visible
If a future encounter class requires a minimum Capture Capability, that requirement must be knowable before an irreversible cost/commitment. GDS-9/GDS-14 own the concrete presentation.

### CC-04 — The first real capture does not require prior grinding
GDS-3 onboarding and GDS-1 time-to-fun require the starting Capture Capability to support the protected first capture path without a pre-capture Energy grind.

## 13. Access Unlock Economy

### AU-01 — Access Unlocks are persistent exact-once outcomes
Once legitimately unlocked, ordinary disconnect, death, server change, or later price rebalance does not remove the access entitlement.

### AU-02 — Major access should combine active proof with economy where appropriate
A major new progression region/capability should ordinarily require active Milestone progression in addition to Energy when doing so protects the active core loop.

### AU-03 — Energy cannot buy unearned discovery history
Purchasing access never backfills Species Discovery, Mutation Discovery, Variant Discovery, event participation, or world-completion Milestones that the player did not legitimately earn.

### AU-04 — Region topology remains GDS-9 authority
GDS-8 defines cost/gate semantics only. GDS-9 defines what regions exist, traversal between them, and where gates occur.

## 14. Pacing Model

The pacing model uses **bands and targets**, not immutable prices.

### 14.1 Opening band — first 0–15 minutes
Targets:

- first meaningful visible action remains within GDS-1 opening target;
- first capture attempt around the first minute remains viable;
- first secured creature around the first few minutes remains viable;
- first meaningful progression choice should be offered at roughly **4–8 minutes**;
- the player should understand at least one Energy source and one Energy sink by roughly the first **10–15 minutes**;
- onboarding must not require waiting for long passive accrual.

### 14.2 Foundation band — roughly first 15–90 cumulative minutes
Targets:

- multiple affordable meaningful upgrades rather than one giant savings wall;
- first noticeable capacity/production/capture-capability expansion;
- at least one reason to perform active progression beyond waiting for Energy;
- an early major access goal should become visible well before it is purchased;
- normal 10–25 minute sessions should end with visible progress toward a next goal.

### 14.3 Growth band — roughly 1.5–10 cumulative hours
Targets:

- choice between multiple useful upgrade/access goals;
- increasing value from specialization/collection composition without one required rarity ladder;
- cost growth that preserves decision-making without turning the next upgrade into dozens of unchanged sessions;
- new active Milestones continue to matter.

### 14.4 Long-term band — 10+ cumulative hours
Targets:

- collection completion, Variant hunting, expanding Vault flexibility, future events, world goals, and later social/trading systems carry more of the motivation;
- Energy retains uses through new content/upgrades/presentation sinks rather than artificial wipes;
- completed early progression remains respected.

These hour bands are tuning references, not guaranteed completion times.

## 15. Source/Sink Balance and Active-Play Mix

### SB-01 — Passive production is important but not the entire economy
For a normally progressing player, balancing should target passive Vault Production as a major but not exclusive Energy source.

A useful initial tuning goal is approximately **50–70%** of ordinary recurring Energy income from Vault Production and **30–50%** from meaningful active progression/events/objectives over comparable play periods.

This ratio is explicitly tuneable after telemetry; the fixed semantic rule is that neither ordinary active play nor the Vault becomes economically irrelevant.

### SB-02 — Raw connected time is not an economy source
AFK presence without valid Production Assignment or meaningful gameplay does not independently mint Energy.

### SB-03 — Major new content must include corresponding sinks/goals
When production capacity increases materially, progression content should introduce meaningful Energy uses so the currency does not become permanently irrelevant.

### SB-04 — No arbitrary periodic currency wipe
Energy balances are not reset simply because a season, server, patch, or economy rebalance occurs.

A fundamentally separate seasonal currency would require explicit later design and must not silently overwrite Energy.

## 16. Inflation and Economy Health

### IF-01 — Inflation is controlled by bounded sources and expandable sinks
Primary controls include:

- GDS-7 Production Slot/Buffer/Offline caps;
- staged upgrade/access costs;
- controlled active/event reward budgets;
- content expansion that adds meaningful sinks;
- optional soft-currency presentation sinks;
- catch-up reductions targeted at obsolete progression rather than uncontrolled global minting.

### IF-02 — No ownership destruction as an inflation sink
Deleting creatures, expiring ownership, charging maintenance to retain secured value, or forced Release is not an acceptable Energy sink.

### IF-03 — Balance evaluates time-to-goal, not currency magnitude alone
A larger numerical wallet is not automatically inflation. Economy health is evaluated through:

- time to meaningful next purchase;
- source/sink flow per Economy Band;
- proportion of players at wallet cap if one is exposed;
- Production Buffer saturation;
- upgrade/access completion curves;
- skipped/unused sinks;
- active-versus-passive contribution.

### IF-04 — No hidden personalized prices based on willingness to pay
Energy prices/rewards may not secretly vary per player based on spending history, purchase reluctance, inferred willingness to pay, loss chasing, or similar monetization profiling.

Visible deterministic cohort experiments require GDS-16 governance and cannot alter already-confirmed transactions.

## 17. Wallet Bounds and Large-Value Safety

### WB-01 — The Energy Wallet has an implementation-safe maximum
Technical Architecture must define a safe upper bound compatible with persistence/transaction representation.

Content balance must keep normal progression materially below that bound.

### WB-02 — Overflowing a source cannot silently destroy valuable claimable output
If a Production Claim would exceed the wallet's accepted maximum, only the safely transferable portion may finalize; the untransferred portion remains in the Production Buffer when possible.

For one-time rewards without a persistent source container, the design requires a visible deferred/recovery behavior rather than silent loss. Exact technical queueing belongs to Technical Architecture.

### WB-03 — Purchases cannot underflow
A cost greater than the authoritative wallet balance fails without partial deduction.

## 18. Catch-Up Design

### CU-01 — Catch-up reduces obsolete friction, not active-skill requirements
When the game accumulates substantial content, older progression may receive lower Energy prices, larger fixed milestone rewards, or streamlined prerequisites.

Catch-up must not silently grant discoveries, event history, variants, or world accomplishments never earned.

### CU-02 — Catch-up is deterministic and legible
Eligibility may depend on explicit factors such as content age, a defined returning-player window, or being below a published progression threshold.

It may not depend on hidden spending propensity.

### CU-03 — Global historical price reductions do not imply automatic retroactive refunds
If old upgrade prices are globally reduced for catch-up, previous purchasers do not automatically receive the difference unless the change explicitly announces compensation.

This avoids creating an implicit perpetual price-protection liability while allowing deliberate remediation when warranted.

### CU-04 — Catch-up cannot create negative value pressure
A returning/new player should become able to reach current content faster, but existing players' owned creatures, discoveries, unlocks, or upgrade effects are not removed to compress the gap.

## 19. Balance Changes and Live Rebalancing

### BR-01 — Completed purchases remain completed
Ordinary price changes do not revoke a previously finalized upgrade or unlock.

### BR-02 — Future prices/rewards may change globally
Unpurchased future progression costs and future source rates may be retuned through configuration when needed for health/pacing.

### BR-03 — Production-rate changes are prospective in output, not identity
A Species Production Profile or Trait effect may be rebalanced for future elapsed production. The creature's Species/Mutation/Trait/Provenance identity remains unchanged.

### BR-04 — Severe economy incidents may require remediation, not silent rollback
Duplication bugs/exploit-driven grants may be corrected when necessary for integrity, but broad confiscation of legitimate player progress is not a default balancing tool. Player-facing remediation policy must distinguish verified illegitimate value from ordinary earned value as safely as possible.

## 20. Prestige and Reset Position

### PR-01 — No baseline prestige reset
MonsterVault's baseline progression does **not** include a prestige/rebirth mechanic that wipes Energy, Vault upgrades, Access Unlocks, discoveries, or Secured Creatures in exchange for a permanent multiplier.

### PR-02 — Long-term progression is additive/expansive
Baseline longevity comes from:

- broader collection/Variant goals;
- Vault/capability expansion;
- world access;
- live content;
- presentation/status;
- later social/trading goals.

### PR-03 — Future prestige requires explicit change control
A later optional prestige system would require GDS-8/GDS-4/GDS-7 revalidation and may not involuntarily erase secured creature ownership or historical discovery.

## 21. Monetization Interactions

GDS-8 does not authorize specific paid products.

Any later GDS-13 product interacting with Energy/progression must preserve at minimum:

- a viable non-premium path to functional core progression;
- no hidden spending-based Energy prices/rewards;
- no paid fabrication of Progression Milestones/discovery history unless explicitly safe/appropriate under owning design;
- no payment required to prevent deletion of owned creatures;
- exact-once purchase outcomes;
- clear separation of premium and Energy balances;
- no post-commit reroll of GDS-6 finite variants.

Direct sale of Energy or paid production acceleration remains **unauthorized until GDS-13** explicitly evaluates it.

## 22. Analytics and Experimentation Boundaries

Important design-level economy metrics include:

- time to first Progression Purchase;
- time to first Vault Upgrade;
- Energy earned by source category;
- Energy spent by sink category;
- median/percentile wallet by Economy Band;
- Production Buffer saturation/claim cadence;
- active-versus-passive income share;
- upgrade purchase funnel and abandon rate;
- time to major Access Unlocks;
- percent blocked by Energy versus active Milestones;
- overflow/capacity pressure around Collection Capacity upgrades;
- catch-up progression time;
- players reaching no-use/high-surplus states.

Experiments may tune:

- source quantities;
- upgrade prices;
- reference progression pacing;
- Production Profile rates;
- Trait effect magnitudes;
- catch-up values;
- visible reward bundles.

Experiments may **not**:

- silently personalize prices/rewards from spending propensity;
- duplicate/revoke Finalized Outcomes;
- alter already-confirmed transaction cost mid-commit;
- bypass GDS-6 rarity/variant identity;
- turn passive currency into fabricated active Milestones;
- delete secured ownership;
- create negative Energy/debt.

## 23. Tuneable Parameters

The following are tuneable without reopening GDS-8 when semantic rules remain intact:

- Energy quantities for sources;
- Production Profile rates;
- bounded Trait production modifiers;
- Vault Upgrade price tables;
- Capture Capability price tables;
- Access Unlock Energy costs;
- Collection Capacity tier sizes;
- Production/Display Slot tier counts;
- Production Buffer capacities;
- Offline Production Window tier values within a bounded model;
- active/passive source-share targets;
- early/mid/long-term timing targets;
- catch-up reward/cost modifiers;
- technical wallet upper bound, provided no silent loss/underflow occurs.

## 24. Dependencies and Downstream Obligations

### GDS-9 — World, Biomes, Exploration, Spawning, and Hazards
Must define concrete regions, access topology, active objectives/rewards, exploration utility, and the world meaning of Access Unlocks while preserving GDS-8 gate semantics.

### GDS-10 — Social Play
Must define cooperative/social rewards without direct Energy transfer, alt-account funnels, or visitor authority unless explicitly designed.

### GDS-11 — Server Events / Live Content
Must define event Energy reward budgets, reward eligibility, exact-once allocation, and any temporary progression modifier transparently.

### GDS-12 — Trading
Must decide whether Energy ever participates in player trade. Baseline direct transfer remains prohibited until GDS-12 explicitly authorizes otherwise.

### GDS-13 — Monetization
Must evaluate any paid Energy/boost/capacity/progression product against non-premium viability, transparency, anti-manipulation, and exact-once semantics.

### GDS-14 — Presentation
Must make Energy wallet, costs, insufficient funds, milestones, gates, upgrade effects, purchase confirmation, Production Claim, and catch-up states legible across input modes.

### GDS-15 — Platform Safety
Must review economy/paid/randomized intersections for Roblox platform/audience requirements.

### GDS-16 — Retention/Analytics
Must govern economy experiments, returning-player catch-up, reward cadence, and source/sink telemetry without overriding GDS-8 fairness semantics.

### Technical Architecture
Must implement authoritative wallet transactions, reason-coded ledger/auditability, safe numeric bounds, idempotency, atomic cost/effect behavior, price/config versioning, concurrency control, exact Production Claim integration, and exploit remediation tooling without weakening GDS-8 rules.

## 25. Edge-Case Matrix

| Situation | Required behavior |
|---|---|
| Duplicate purchase request | one cost + one effect maximum |
| Reconnect after uncertain purchase | reconcile one authoritative outcome |
| Purchase price changes while confirmation open | no silent higher charge; re-confirm or honor valid quote |
| Insufficient Energy | no partial deduction/effect |
| Already-owned one-time unlock | no duplicate charge |
| Production Claim exceeds wallet-safe bound | partial safe transfer; remainder preserved when source supports it |
| Release creature | no baseline Energy minting |
| Capture same Common repeatedly | no automatic per-capture Energy minting |
| Legendary creature assigned | no automatic rarity production multiplier |
| Extreme/Compound Mutation assigned | no automatic Mutation production multiplier |
| Trait has explicit production effect | bounded authored effect only |
| Player offline beyond window | accrual stops at window/buffer cap |
| Player server-hops repeatedly | no replay/reset of elapsed production window |
| Player has enough Energy but missing Milestone | Access Gate remains locked |
| Player has Milestone but insufficient Energy | purchase remains unavailable; no partial spend |
| Energy price globally reduced later | future buyers use new price; prior completion remains intact |
| Upgrade effect rebalanced later | owned upgrade remains owned; effect may tune prospectively under authority |
| Player disconnects/death | Energy/unlocks persist |
| Protected Load Failure | irreversible economy actions blocked |
| Event ends during reward retry | exact finalized reward result, no duplicate |
| Catch-up becomes available | visible deterministic adjustment; no fabricated discovery |
| Premium system proposed | deferred to GDS-13; GDS-8 does not authorize it |

## 26. Open Questions

There are **zero GDS-8-blocking open questions**.

Concrete Species Production Profile tables, exact Energy amounts, exact upgrade/access costs, final region count/topology, exact active objective catalogs, event reward budgets, paid products, presentation, and technical transaction implementation are tuneable content or downstream authority rather than unresolved GDS-8 semantics.

## 27. Design-Complete Checklist

- [x] Purpose and scope are explicit.
- [x] One baseline soft currency and wallet semantics are defined.
- [x] Sources/sinks are explicit.
- [x] Passive production economic role is defined.
- [x] Rarity/Mutation/Trait economic boundaries are defined.
- [x] Active progression cannot be replaced by passive waiting.
- [x] Vault/capture/access progression semantics are defined.
- [x] Exact-once spend/failure behavior is defined.
- [x] Pacing bands are defined.
- [x] Inflation/catch-up/rebalance rules are defined.
- [x] Prestige/reset position is defined.
- [x] Failure/lifecycle behavior is inherited consistently.
- [x] Monetization/experiment boundaries are defined.
- [x] Edge cases are covered.
- [x] No implementation-relevant open questions remain.
