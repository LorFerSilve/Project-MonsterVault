# Rarity, Mutations, Traits, and Variant Value

> **Status:** Design Complete  
> **Owning GDS phase:** GDS-6 — Rarity, Mutations, Traits, and Variant Value  
> **Authority:** Species rarity semantics, instance-level mutation and trait identity, variant generation/finalization, compound variants, scarcity/value signaling, discovery/completion semantics, capture-difficulty integration boundaries, high-value protection, probability/fairness guardrails, and variant-facing live-content/economy obligations  
> **Depends on:** `../00_design_authority.md`, `../01_game_overview.md`, `../product/market_positioning_and_differentiation.md`, `../global_rules/02_global_game_rules_and_session_model.md`, `../creatures/04_creatures_collection_and_ownership.md`, `../capture/05_capture_contesting_transport_and_extraction.md`, `../GLOSSARY.md`

## 1. Purpose and Player Fantasy

MonsterVault needs rarity to create desire without collapsing the game into a single power ladder. Players should be able to care about *what species they found*, *which specific variant they found*, *what unusual properties that individual has*, and *where it came from*.

The player-facing contract is:

> **When I see or secure an unusual creature, its rarity and variant identity mean something stable. The game does not secretly reroll it after I engage, confuse scarcity with raw power, or make my collectible stop being special because I reconnect, trade, store, or transport it.**

GDS-6 therefore separates four concepts that must not be conflated:

1. **Species Rarity** — authored scarcity/status of the Species;
2. **Mutation** — persistent instance-level collectible variation, primarily visible/status-oriented;
3. **Trait** — persistent instance-level characteristic that may support bounded downstream gameplay distinctions;
4. **Variant Value** — the collectible/status significance created by the instance's Species, mutations, traits, provenance, and availability context without asserting a guaranteed currency or market price.

## 2. Scope

GDS-6 owns:

- the canonical Species Rarity ladder;
- the distinction between rarity, mutation, trait, provenance, and availability;
- when instance variant identity becomes fixed;
- mutation generation semantics and compatibility;
- baseline mutation-count limits and compound variants;
- mutation frequency/scarcity semantics;
- trait identity and bounded gameplay-impact principles;
- Variant Signature and variant-discovery semantics;
- rarity/mutation readability obligations;
- variant persistence through GDS-5 capture/transport/finalization;
- duplicate behavior when instances differ in variants/traits;
- collection/status value semantics;
- high-value protection triggers consumed by GDS-4 Creature Lock;
- probability communication and anti-manipulation guardrails;
- capture-difficulty integration boundaries;
- event/limited availability tagging boundaries;
- balancing/change-control rules for owned variants;
- downstream obligations for vault, economy, world, social, events, trading, monetization, presentation, platform safety, analytics, and Technical Architecture.

## 3. Explicit Non-Goals

GDS-6 does **not** define:

- stable Creature Instance ownership, Collection Registry, Release, or core Creature Lock semantics — GDS-4;
- capture state machine, Engagement Claim, Transport Custody, Secure Point, or ownership-finalization trigger — GDS-5;
- vault production formulas, creature assignment, display capacity, or offline output — GDS-7;
- currency prices, sell/release values, upgrade economics, capture-tool progression, or long-term income curves — GDS-8;
- exact biome spawn tables, spawn density, encounter lifetimes, or per-biome encounter probability — GDS-9;
- PvP/social contest rules or optional high-risk modes — GDS-10;
- event schedules, event reward allocation, seasonal cadence, or event-specific acquisition rules — GDS-11;
- trading prices, market liquidity, trade restrictions, or price-discovery systems — GDS-12;
- paid products, premium rerolls, boosts, or monetization pricing — GDS-13;
- final colors, icons, VFX, audio, collection-card layout, animation, or accessibility settings — GDS-14;
- Roblox policy/compliance implementation — GDS-15;
- telemetry implementation or experiment infrastructure — GDS-16;
- random-number implementation, seed strategy, persistence schema, anti-tamper implementation, or content-data architecture — Technical Architecture.

## 4. Canonical Terminology

Shared terms are normalized in `../GLOSSARY.md`.

### Species Rarity
The authored scarcity/status class of a Species. It describes the intended relative collectibility of the Species under its eligible content conditions; it is not an instance's mutation state and is not a direct power/stat formula.

### Species Rarity Tier
One of the five baseline ordered Species Rarity labels:

1. **Common**
2. **Uncommon**
3. **Rare**
4. **Epic**
5. **Legendary**

### Mutation
A persistent instance-level variant property that changes collectible identity and must have a legible presentation component. A Mutation may also provide a bounded downstream gameplay hook, but mutation does not mean “strictly stronger.”

### Mutation Frequency Band
A content-authored scarcity category for one Mutation within an eligible generation context:

- **Frequent**
- **Uncommon**
- **Rare**
- **Extreme**

The band describes relative scarcity, not an exact universal probability.

### Compound Variant
A Creature Instance carrying two compatible Mutations simultaneously. Baseline GDS-6 permits at most two Mutations on one instance.

### Trait
A persistent instance-level characteristic distinct from Mutation. Traits may affect downstream behavior, utility, production, capture interaction, or optimization in bounded ways, but are not automatically visible prestige tiers and do not determine ownership.

### Variant Identity Finalization
The point at which an encounter's instance-level Mutation/Trait identity is fixed and may no longer be rerolled by claim retries, capture retries, reset, disconnect, transport, extraction, or server-side message replay.

### Variant Signature
The canonical collectible identity tuple formed by **Species + canonical Mutation set**. Mutation order does not create separate signatures. Traits and provenance remain instance metadata but do not multiply baseline visual-variant completion by default.

### Standard Variant
A Creature Instance with zero Mutations.

### Single-Mutated Variant
A Creature Instance with exactly one Mutation.

### Compound-Mutated Variant
A Creature Instance with exactly two compatible Mutations.

### Mutation Discovery
A persistent player fact that the player has legitimately secured at least one creature carrying a specific Mutation.

### Variant Discovery
A persistent player fact that the player has legitimately secured a specific Variant Signature.

### Protected Variant
A high-value instance category that must receive stronger loss/transfer safeguards, including automatic Creature Lock at initial securisation under the rules in this phase.

### Availability Tag
A non-rarity label describing how content is currently made available, such as Core, Rotating, Event-Limited, or Legacy. Availability is not a sixth Species Rarity tier.

### Variant Value
The collectible/status significance of an individual instance. Variant Value can be informed by Species Rarity, Mutation Frequency, Compound status, Traits, Provenance, and Availability, but does not itself assert a guaranteed currency price or trading market value.

## 5. Rarity Model

### 5.1 Canonical Species Rarity ladder

The baseline project uses exactly five ordered Species Rarity tiers:

| Tier | Intended meaning |
|---|---|
| Common | readily encountered under normal eligible conditions; foundation of collection progression |
| Uncommon | meaningfully less frequent but still regularly obtainable through ordinary play |
| Rare | notable find expected to create a clear collection/status moment |
| Epic | highly scarce aspirational content expected to motivate targeted hunting |
| Legendary | top baseline Species-scarcity/status tier; exceptional ordinary collection target |

These labels are design semantics, not fixed percentages.

### 5.2 Rarity is not power

Species Rarity may influence desirability, encounter scarcity, visual/status treatment, capture challenge tuning, progression requirements, or downstream value. It does **not** automatically grant superior combat/stat output, passive production, or universal utility.

Downstream systems may correlate value with rarity only where their owning design explicitly balances that effect.

### 5.3 Availability is separate from rarity

A Common event creature can be Event-Limited. A Legendary creature can be part of Core availability. `Limited`, `Seasonal`, `Event`, `Legacy`, or similar labels must never be inserted into the Species Rarity ladder merely to imply greater prestige.

### 5.4 Tier labels must remain semantically ordered

Under comparable eligible conditions, higher Species Rarity should represent greater intended scarcity/status than lower Species Rarity. GDS-9/GDS-11 may create context-specific availability where a high-tier creature is temporarily easier to find, but such exceptions must be explicit and must not silently redefine the tier system.

## 6. Variant Identity Generation

### VI-01 — Instance variation belongs to the Creature Instance
Mutations and Traits attach to a specific Creature Instance, not to the owning player, current server, UI card, vault slot, or capture attempt.

### VI-02 — Variant identity finalizes before player commitment can exploit rerolls
A creature's Mutation/Trait identity must become fixed **no later than the moment that specific creature becomes an individually actionable Capture Opportunity**.

The exact technical creation time may be earlier, but a player cannot first commit to an encounter and then have the same instance rerolled because of claim, retry, reset, reconnect, or extraction.

### VI-03 — Claim retries do not reroll
Releasing and reacquiring an Engagement Claim against the same surviving Creature Instance preserves the same finalized variant identity.

### VI-04 — Capture retries do not reroll
A Capture Failure followed by another valid attempt against the same surviving instance preserves Mutations and Traits.

### VI-05 — Transport does not reroll
Capture Success, Provisional Capture, Transport Custody, Secure Point interaction, and Secured Ownership Finalization preserve the same finalized variant identity.

### VI-06 — Reconnect does not reroll a surviving instance
A same-session reconnect or transport-grace resume cannot regenerate the provisional creature's variant identity.

### VI-07 — A new world instance may legitimately differ
If an encounter truly ends and a later/new Creature Instance is spawned, that new instance may have independently generated variant identity. This is not a reroll of the previous instance.

### VI-08 — Hidden-until-reveal is allowed; post-commit mutation is not
A Mutation/Trait may remain visually or informationally unrevealed until a designed discovery moment, but its underlying identity cannot be generated or changed after player commitment merely to manipulate the outcome.

## 7. Mutation Model

### MU-01 — Standard is a valid collectible state
A creature with zero Mutations is a Standard Variant and remains legitimate collection value. Mutation is aspirational variation, not a requirement for the base creature to matter.

### MU-02 — Baseline mutation count is zero to two
A baseline Creature Instance may carry:

- 0 Mutations — Standard Variant;
- 1 Mutation — Single-Mutated Variant;
- 2 compatible Mutations — Compound-Mutated Variant.

More than two simultaneous Mutations is outside the baseline contract and requires GDS-6 change control plus presentation/value audit.

### MU-03 — Mutation order does not create fake uniqueness
`Mutation A + Mutation B` and `Mutation B + Mutation A` are the same mutation set for Variant Signature purposes.

### MU-04 — Mutations require a meaningful presentation hook
Every Mutation must have a player-legible presentation difference at least at close/collection inspection. It may use shape, material, pattern, effect, proportion, accent, animation, or another readable channel. Final art treatment belongs to GDS-14/content production.

### MU-05 — Color alone is insufficient for critical mutation identity
A Mutation may use color, but if that Mutation materially affects collectible status/value it must have at least one additional non-color-only identifying cue in collection/detail presentation.

### MU-06 — Mutations are not automatic stat upgrades
Mutation presence or higher Mutation Frequency does not automatically mean stronger gameplay output. Any mechanical hook must be explicitly authorized and bounded downstream.

### MU-07 — Compatible combinations are authored
Not every pair of Mutations must be combinable. Content data must explicitly define incompatibilities where combinations would conflict visually, semantically, or mechanically.

### MU-08 — Compatibility cannot change an owned creature into invalid state
If content updates later mark a combination unavailable for new generation, already-owned legitimate Compound Variants retain their historical mutation identity unless an explicit migration is required for safety/technical integrity.

### MU-09 — Compound variants are intentionally scarcer than their components
A Compound Variant should ordinarily be harder to obtain than either same-context single mutation alone because two compatible mutation outcomes must coincide under authored generation rules. Exact math belongs to content balancing.

### MU-10 — Mutation generation cannot duplicate one finite instance
Variant generation is part of the finite creature instance. Network retries, capture retries, or finalization retries cannot produce separate copies with different mutation results from one instance.

## 8. Mutation Frequency and Probability Semantics

### MF-01 — Frequency bands are context-aware
Mutation Frequency Band is defined within an eligible generation context rather than as one global immutable percentage across every Species, biome, event, and season.

### MF-02 — Exact rates belong to content configuration, not the tier name
`Rare` Mutation Frequency does not encode one hard-coded universal percentage. Content balancing may use different exact probabilities while preserving the relative semantic ordering.

### MF-03 — Relative ordering is meaningful
Within the same eligible context, an `Extreme` Mutation outcome must not intentionally be more common than a `Rare`, `Uncommon`, or `Frequent` outcome unless an explicit event modifier temporarily and visibly changes the context.

### MF-04 — Probability modifiers are prospective, not retroactive
Any later-authorized boost, event modifier, progression bonus, or monetized effect can influence only future not-yet-finalized instance generation. It cannot reroll or replace an already finalized Variant Identity.

### MF-05 — No hidden individualized spending-based odds
The game must not secretly increase or decrease Mutation/Rarity odds for a specific player based on that player's spending history, purchase reluctance, recent losses, or inferred willingness to pay.

### MF-06 — Paid/randomized probability changes require explicit downstream review
If GDS-13 ever proposes paid probability modifiers or randomized paid acquisition, GDS-6 requires explicit odds/fairness integration, GDS-15 platform review, and clear player-facing disclosure. Such monetization is not authorized by GDS-6 itself.

### MF-07 — Event modifiers must be understandable
If an event materially increases specific variant odds, the game must communicate the affected category/content sufficiently that players are not misled about ordinary scarcity. Exact final UX belongs to GDS-11/GDS-14.

### MF-08 — Experiments cannot covertly fragment collectible scarcity
GDS-16 experiments may tune variant probabilities only with explicit experiment governance. They may not secretly personalize odds based on spending or create uncontrolled long-term scarcity differences that make identical advertised content meaningfully different between players without traceable experiment context.

## 9. Trait Model

### TR-01 — Traits are distinct from Mutations
Traits are persistent instance characteristics. A creature may share the same Variant Signature as another instance while having different Traits.

### TR-02 — Traits do not create a second Species Rarity ladder
A Trait may be common or uncommon in content configuration, but Trait labels do not replace Species Rarity or Mutation Frequency Bands.

### TR-03 — Traits may support bounded optimization
GDS-7/GDS-8/GDS-9 may use Traits for bounded differences such as production preference, environmental affinity, capture-support utility, or other non-destructive optimization. Exact effects belong to those phases.

### TR-04 — No trait can silently override ownership/finalization
Traits cannot change who owns a creature, bypass GDS-5 extraction, disable GDS-4 secured persistence, or create spontaneous player-to-player transfer.

### TR-05 — Traits should create choices, not mandatory supremacy
A healthy Trait system favors situational strengths, preferences, tradeoffs, or specialized optimization over one universally dominant Trait that invalidates otherwise desirable creatures.

### TR-06 — Trait visibility follows decision relevance
If a Trait affects an immediate player decision, its relevant effect must be discoverable before that decision becomes irreversibly consequential. Hidden flavor-only traits may reveal later.

### TR-07 — Trait identity persists across lifecycle and transfer
Once finalized, Traits remain attached to the same Creature Instance through capture, storage, server changes, future trading, and ordinary content use unless an explicitly designed downstream transformation system changes them.

### TR-08 — Trait rerolling is not baseline
No baseline GDS-6 mechanic rerolls Traits after acquisition. Any future reroll/breeding/transformation feature requires explicit owning-phase design and must protect value integrity.

## 10. Variant Signature and Discovery

### VD-01 — Variant Signature is Species plus Mutation set
Baseline Variant Signature ignores mutation order and excludes Traits from the visual-variant completion key.

Examples:

- `Species X + no Mutation` — Standard Variant signature;
- `Species X + Aurora` — one Single-Mutated signature;
- `Species X + Aurora + Crystal` — one Compound-Mutated signature.

### VD-02 — Securing records discovery; seeing does not
A player records Mutation Discovery and Variant Discovery only when a legitimate Creature Instance reaches GDS-5 Secured Ownership Finalization.

### VD-03 — Discovery is historical
Later Release, trade, capacity change, or loss of current possession does not erase legitimate historical Mutation Discovery or Variant Discovery.

### VD-04 — Trait combinations do not explode baseline collection completion
Traits may be searchable/status-relevant later, but baseline variant-completion systems do not require every Trait permutation for every Species.

### VD-05 — Compound discovery is distinct
Securing a Compound Variant records that exact Variant Signature; owning each constituent Single-Mutated Variant separately does not count as having discovered the Compound Variant.

### VD-06 — Discovery cannot be fabricated by UI preview
Catalog previews, other players' creatures, vault visitors, promotional art, or temporary event previews do not grant Mutation/Variant Discovery.

### VD-07 — Legacy variants remain historically legible
If a Variant Signature becomes unavailable for new generation, players who legitimately discovered or own it retain historical recognition. GDS-14/GDS-11 must distinguish legacy status from currently obtainable completion goals.

## 11. Variant Value and Status

### VV-01 — Variant Value is multi-dimensional
An instance's collectible significance may derive from:

- Species Rarity;
- Mutation count;
- Mutation Frequency Band(s);
- Compound status;
- Trait desirability in later systems;
- Provenance;
- Availability Tag;
- event/history context;
- future player-market demand.

No single GDS-6 scalar is declared the guaranteed “true value.”

### VV-02 — Rarity labels are not currency prices
Species Rarity or Mutation Frequency must not be presented as a guaranteed sale/trade price. GDS-8/GDS-12 own economic valuation.

### VV-03 — Variant Value does not guarantee gameplay superiority
A visually exceptional or scarce variant may be prestigious without being mechanically stronger than a standard instance.

### VV-04 — Provenance can increase status without changing rarity
An event source, legacy acquisition period, or notable origin may make an individual more desirable while leaving its Species Rarity and Mutation identity unchanged.

### VV-05 — Availability Tag does not overwrite original identity
Changing an item from Rotating to Legacy does not mutate its Species, Mutation set, Trait set, or provenance.

### VV-06 — Duplicate instances can have materially different collectible value
Two creatures of the same Species may remain valuable duplicates because they differ in Mutation, Trait, provenance, acquisition history, or other authorized instance metadata.

## 12. Protected Variant Rules

A Secured Creature is a **Protected Variant** at initial finalization if at least one of the following is true:

- its Species Rarity is **Legendary**;
- it carries an **Extreme** Mutation;
- it is a **Compound-Mutated Variant**;
- it carries an explicit event/legacy protection marker from GDS-11;
- a later authoritative system marks the instance as requiring equivalent high-value protection.

### PV-01 — Protected Variants auto-lock on first securisation
At Secured Ownership Finalization, a Protected Variant receives GDS-4 **Creature Lock** by default.

### PV-02 — Auto-lock does not make the creature unmanageable forever
The owner can later deliberately unlock it through GDS-4-compliant explicit intent. GDS-12/GDS-14 may require additional warnings before destructive/transfer actions.

### PV-03 — Protection uses actual instance properties
A normal Common Species is not auto-locked merely because the player personally likes it, though the player can manually lock it. Conversely, a Common Species carrying an Extreme Mutation can qualify for automatic protection.

### PV-04 — Protection cannot be bypassed by bulk actions
Bulk Release, future trading, or future conversion systems must respect Creature Lock and cannot silently consume a Protected Variant.

## 13. Capture-Difficulty Integration

### CD-01 — Rarity may influence challenge tuning but not input availability
GDS-5 Capture Challenge may become harder for some Species/variants, but touch/controller/keyboard capability parity remains mandatory.

### CD-02 — Species Rarity is not a mandatory difficulty formula
Legendary may *often* be harder to acquire than Common, but rarity does not itself prescribe exact challenge duration, success rate, or required tool.

### CD-03 — Mutation modifiers require pre-commit readability when consequential
If a visible Mutation materially changes Capture Challenge behavior, the player must have enough indication before committing an irreversible attempt cost/risk to understand that the encounter is unusual.

### CD-04 — Hidden mutation cannot retroactively fake failure
A concealed Mutation may reveal after capture, but hidden identity cannot be used to secretly invalidate otherwise valid input while presenting the outcome as player error.

### CD-05 — Variant generation is not capture reward rerolling
Capture performance may affect success/failure only. It does not reroll the Creature Instance's already-finalized Species/Mutation/Trait identity unless a future explicit mechanic reopens GDS-6.

## 14. Availability and Live Content

Baseline Availability Tags are:

- **Core** — intended to remain generally obtainable through ordinary ongoing content;
- **Rotating** — recurring or intermittently available content;
- **Event-Limited** — tied to a bounded event/content window;
- **Legacy** — no longer normally obtainable through current ordinary acquisition.

### AV-01 — Availability Tag is current-content metadata
Availability describes how content can currently be obtained; it does not replace Species Rarity.

### AV-02 — Event-limited does not automatically mean Legendary
Event status and rarity are independent axes.

### AV-03 — Retirement must not falsify historical rarity
Moving content to Legacy does not retroactively claim that it was always rarer at generation time than its configured Species/Mutation scarcity.

### AV-04 — Completion remains achievable/legible
Collection goals must distinguish currently obtainable baseline completion from legacy/event-limited historical completion so new players are not shown an unlabeled impossible target.

### AV-05 — Event variants preserve exact instance identity
When an Event-Limited variant is secured, later event end does not strip its Mutation, Trait, provenance, or ownership.

## 15. Balancing and Content Change Rules

### BC-01 — Owned instance identity is stable by default
Balance patches can change downstream effects, but they do not silently reroll an owned instance's Species, Mutations, Traits, or provenance.

### BC-02 — Rarity reclassification is exceptional
Changing a Species Rarity tier after release is allowed only through explicit content change control because it affects status/value expectations. The change must be documented and applied consistently rather than per-player.

### BC-03 — Mutation frequency can change prospectively
Future generation rates may be rebalanced. Existing instances retain the Mutation they already have; their historical provenance remains valid.

### BC-04 — Nerfs/buffs do not erase collectible identity
If a Trait or Mutation's downstream mechanical effect changes for balance, the instance remains the same collectible. GDS-8/GDS-7 must avoid deceptive retroactive value claims.

### BC-05 — No silent retroactive upgrade to manufacture scarcity
The game must not arbitrarily relabel old common content as newly ultra-rare solely to manufacture market hype without clear content-change disclosure.

### BC-06 — Content bugs require integrity-first remediation
If an unintended generation bug produces invalid/duplicate variants, remediation must preserve ownership trust where safely possible and must not silently delete legitimate persistent instances. Exact migration/support handling belongs to TA/operations.

## 16. Presentation and Readability Requirements

GDS-14 must provide presentation capable of communicating at minimum:

- Species Rarity;
- Standard versus Single-Mutated versus Compound-Mutated status;
- Mutation identity;
- Trait identity/effect where decision-relevant;
- Protected Variant/Creature Lock state;
- Availability Tag where relevant;
- provenance/history where relevant;
- currently obtainable versus Legacy status.

Critical distinctions cannot rely solely on color, audio, tiny text, or hover-only interaction.

The game should favor a small stable vocabulary over proliferating near-identical prestige labels.

## 17. Multiplayer, Trading, and Social Value Boundaries

### MS-01 — Other players may inspect status without gaining rights
Seeing another player's rare/mutated creature may create social status but grants no ownership, claim, or transfer right.

### MS-02 — Variant status cannot bypass GDS-5 contest rules
A Legendary/Extreme/Compound creature still follows the same ordinary Engagement Claim and Provisional Capture ownership boundary unless an explicit event override applies.

### MS-03 — Future trading transfers the same instance
GDS-12 must transfer the stable Creature Instance with its Mutations, Traits, provenance, lock state rules, and Variant Signature intact. Trading cannot replace it with a generic equivalent.

### MS-04 — Market price is player/economy authority, not GDS-6 truth
GDS-12 may expose market signals, but GDS-6 rarity labels must not be used as a guarantee that one creature is worth a fixed amount to other players.

### MS-05 — Social flex should remain non-destructive
Vault/display/status presentation can celebrate rare variants without enabling visitors to modify, release, steal, or transfer them.

## 18. Monetization and Fairness Boundaries

### MO-01 — Base rare-variant hunting must remain viable through play
The rarest baseline collection aspirations cannot be designed as primarily pay-only acquisition.

### MO-02 — Payment cannot rewrite an already spawned player's opponent-facing finite instance
A paid boost cannot transform or reroll a currently contested already-finalized world Creature Instance after another player has begun pursuing it.

### MO-03 — Paid convenience cannot fabricate historical provenance
A purchase cannot label an instance as event-earned, legacy-earned, or naturally encountered if that provenance did not occur.

### MO-04 — Paid probability mechanics need explicit odds/fairness review
Any future premium reroll, probability boost, loot-like acquisition, or paid variant generator requires GDS-13/GDS-15 review and cannot be inferred from GDS-6.

### MO-05 — Spending history cannot secretly drive odds
No individualized hidden “whale odds,” loss-chasing odds, or pay-reluctance targeting is allowed.

## 19. Analytics and Experiment Boundaries

GDS-16 may measure:

- Species Rarity encounter/securisation distribution;
- mutation-generation distribution by context;
- Standard/Single/Compound distribution;
- Mutation Discovery and Variant Discovery funnels;
- time-to-first Rare/Epic/Legendary secure;
- time-to-first Mutation and Compound Variant;
- capture conversion by rarity/variant;
- variant retention/Release/trade rates later;
- Creature Lock activation/unlock rates;
- event/rotating availability participation;
- duplicate desirability and vault-display behavior.

Experiments may tune prospective rates and presentation but must preserve:

- fixed identity once Variant Identity Finalization occurs;
- no hidden individualized spending-based odds;
- historical discovery integrity;
- stable Species/Mutation/Trait identity of owned creatures;
- clear experiment provenance sufficient to audit scarcity changes;
- GDS-1 non-coercive monetization and retention-first hierarchy.

## 20. Downstream Obligations

### GDS-7 — Vault/Base
Must preserve instance-level variant identity in storage/display/production; if Traits or Mutations influence production, effects must remain bounded and legible without making rare variants mandatory for baseline viability.

### GDS-8 — Economy/Progression
Must define any currency/release/production/capture-tool value associated with rarity/variants without treating rarity labels as fixed prices or requiring pay-only access to core aspirations.

### GDS-9 — World
Must implement encounter/spawn contexts consistent with Species Rarity, Mutation Frequency Bands, Variant Identity Finalization, and event modifiers without post-engagement rerolls.

### GDS-10 — Social
Must preserve ownership and non-destructive status display; optional competitive systems cannot change variant identity or secured ownership without explicit authority.

### GDS-11 — Events/Live Content
Must own event windows, special variant availability, event modifiers, and event protection markers while preserving Availability Tag/rareness separation and historical provenance.

### GDS-12 — Trading
Must transfer exact stable instances and preserve Mutations, Traits, provenance, Variant Signature, one-owner semantics, and high-value protection. Market value remains separate from GDS-6 labels.

### GDS-13 — Monetization
Must respect play-viable variant hunting, no hidden spending-based odds, no provenance fabrication, and explicit probability disclosure/review for randomized paid mechanics.

### GDS-14 — Presentation
Must make rarity, mutation, compound status, decision-relevant Traits, lock/protection, provenance, and availability readable across touch/controller/desktop and accessibility settings.

### GDS-15 — Platform/Safety
Must review any randomized paid or age-sensitive probability mechanic before release and may impose stricter disclosure/availability constraints without weakening ownership identity.

### GDS-16 — Retention/Analytics
Must instrument scarcity/discovery without covert individualized manipulation or uncontrolled experiments that fragment collectible value integrity.

### Technical Architecture
Must implement deterministic/stable instance identity, variant generation/finalization, mutation compatibility, exact persistence, prospective modifiers, idempotent transfer/finalization, auditable content versions, and anti-tamper controls without changing these player-facing semantics.

## 21. Open Questions

There are **zero GDS-6-blocking open questions**.

Exact spawn percentages, mutation tables/content names, per-Species compatibility matrices, Trait catalogs/effects, capture modifiers, economy prices, event schedules, market prices, UI/VFX/audio treatment, and technical RNG/storage mechanisms remain explicitly assigned to downstream content/design/architecture authority.

## 22. Change Control

Material changes to any of the following require reopening GDS-6 and relevant revalidation:

- five-tier Species Rarity ladder;
- separation of Species Rarity, Mutation, Trait, Availability, and economic value;
- Variant Identity Finalization no later than actionable Capture Opportunity;
- no reroll of the same instance through claim/capture/transport/reconnect/finalization retries;
- baseline maximum of two simultaneous Mutations;
- Mutation Frequency Band semantics;
- Variant Signature = Species + canonical Mutation set;
- Trait exclusion from baseline combinatorial completion;
- historical Mutation/Variant Discovery persistence;
- Protected Variant auto-lock rules;
- no hidden individualized spending-based odds;
- prospective-only probability modifiers;
- rarity/variant not guaranteeing raw power or fixed market value;
- Availability Tag being separate from rarity;
- stable owned-instance variant identity across balancing/content updates.

Numeric probabilities and content catalogs may change without reopening GDS-6 when these semantic contracts remain intact.

## 23. Design Complete Checklist

- [x] Species Rarity model is explicit;
- [x] rarity is separated from power, availability, mutation, trait, and price;
- [x] variant generation/finalization boundary is explicit;
- [x] mutation count, compound behavior, and compatibility semantics are explicit;
- [x] probability/frequency semantics are explicit;
- [x] trait semantics and downstream limits are explicit;
- [x] Variant Signature and discovery semantics are explicit;
- [x] high-value protection behavior is explicit;
- [x] capture integration is explicit;
- [x] live-content/legacy semantics are explicit;
- [x] balancing/change-control rules are explicit;
- [x] monetization/experiment guardrails are explicit;
- [x] downstream authority boundaries are explicit;
- [x] zero GDS-6-blocking open questions remain.

**GDS-6 specification result: DESIGN COMPLETE.**
