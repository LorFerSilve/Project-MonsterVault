# Trading and Player Economy

> **Status:** Design Complete  
> **Owning GDS phase:** GDS-12 — Trading and Player Economy  
> **Authority:** Player-to-player creature trading eligibility, direct bilateral barter, offer/version/confirmation semantics, atomic ownership transfer, trade cooldowns/restrictions, collection/Vault reconciliation, discovery/provenance effects, disconnect/retry behavior, scam/bait-and-switch protections, alternate-account/collusion constraints, value/scarcity philosophy, and the decision on Energy transferability  
> **Depends on:** ../00_design_authority.md, ../01_game_overview.md, ../global_rules/02_global_game_rules_and_session_model.md, ../player/03_player_character_interaction_and_onboarding.md, ../creatures/04_creatures_collection_and_ownership.md, ../capture/05_capture_contesting_transport_and_extraction.md, ../rarity_mutations/06_rarity_mutations_traits_and_variant_value.md, ../vault/07_vault_base_passive_production_capacity_and_upgrades.md, ../economy_progression/08_economy_progression_unlocks_and_pacing.md, ../world/09_world_biomes_exploration_spawning_and_hazards.md, ../social/10_social_play_cooperation_competition_and_pvp_boundaries.md, ../events_liveops/11_server_events_dynamic_encounters_and_live_content.md, ../GLOSSARY.md

## 1. Purpose and Player Fantasy

MonsterVault benefits from player-to-player exchange because collectible duplicates, event history and variant scarcity gain social meaning when players can deliberately swap specific creatures.

The player-facing contract is:

> **I can inspect the exact creatures another player is offering, deliberately choose the exact creatures I am giving, review the final exchange after every change, and know that either the complete agreed trade happens once or nothing changes. I cannot lose a locked creature through a bait-and-switch, disconnect, UI race, partial transfer or hidden Energy charge.**

GDS-12 therefore authorizes direct creature barter while keeping the baseline soft-currency economy non-transferable and avoiding an auction-house economy before monetization, platform safety and analytics design are complete.

## 2. Scope

GDS-12 owns:

- baseline trade-access requirements;
- direct same-server bilateral Trade Sessions;
- trade invitations and consent;
- Trade Offer composition;
- Trade Revision/version semantics;
- Trade Ready and Final Confirmation semantics;
- exact-instance presentation requirements;
- trade eligibility for Secured Creatures;
- Creature Lock behavior;
- Production Assignment/display/active-role reconciliation;
- Overflow-Held participation;
- recipient capacity validation;
- atomic Trade Commit;
- exact-once Trade Ownership Finalization;
- disconnect/reconnect/retry behavior;
- Trade Cooldown;
- Trade Restriction semantics;
- trade-derived collection discovery;
- preservation and extension of provenance;
- the baseline decision on gifting;
- the baseline decision on Energy transfer;
- the baseline decision on trade fees;
- the baseline decision on marketplaces/auctions/offline listings;
- lopsided trade treatment and value philosophy;
- bait-and-switch/scam protections;
- alternate-account/collusion/wash-trade guardrails;
- event-acquired/Protected Variant trading;
- downstream obligations for monetization, final presentation, platform safety, analytics and Technical Architecture.

## 3. Explicit Non-Goals

GDS-12 does **not** define:

- Robux products, paid trade slots, premium marketplaces, commercial trade boosts or real-money exchange — GDS-13;
- final trade UI layout, card visuals, warning styling, accessibility implementation or confirmation animations — GDS-14;
- age gating, parental restrictions, account privacy, reporting/blocking, chat moderation, off-platform solicitation enforcement or Roblox policy implementation — GDS-15;
- market analytics, retention loops, trade recommendation algorithms or experimentation governance — GDS-16;
- persistence transactions, distributed locks, idempotency-key implementation, datastore schemas, network protocols or anti-cheat implementation — Technical Architecture;
- auction houses;
- public buy/sell order books;
- offline listings;
- asynchronous escrow;
- direct Energy transfer;
- creature-for-Energy purchases;
- gifting with nothing offered in return;
- lending/temporary ownership;
- fractional/shared creature ownership;
- player-authored real-money prices;
- automatic fair-value pricing.

## 4. Canonical Terminology

Shared terms remain authoritative in ../GLOSSARY.md.

### Trade Access Milestone
A non-paid persistent progression milestone authorizing baseline player-to-player trading after the player has completed onboarding and Starter Region Mastery. Platform-safety policy may further restrict availability downstream.

### Trade Session
A temporary explicit two-player same-server negotiation context in which both participants can construct and review one bilateral creature exchange.

### Trade Invite
A temporary request from one eligible player to another to open a Trade Session. It requires explicit acceptance and creates no ownership or reservation by itself.

### Trade Offer
The exact set of Creature Instances one participant currently proposes to transfer in the active Trade Session.

### Trade Revision
A monotonically changing semantic version of the complete bilateral Trade Offer. Any change to either side creates a new Trade Revision and invalidates all prior ready/confirmation state.

### Trade Reservation
A temporary server-authoritative reservation preventing one Creature Instance from simultaneously participating in another trade/destructive ownership-changing action while the Trade Session is active. Reservation is not ownership transfer.

### Trade Ready
A participant's explicit statement that they have reviewed the current Trade Revision and want to proceed to final review. Readiness is cleared by any Trade Revision change.

### Final Trade Confirmation
The participant's explicit confirmation of the exact final Trade Revision after both sides are ready and the final review state is presented.

### Trade Commit
The authoritative all-or-nothing operation that revalidates both parties, both exact offers, restrictions, ownership, capacity and concurrent state before applying the exchange.

### Trade Ownership Finalization
The exact-once persistent ownership transition produced by a successful Trade Commit. Every included Creature Instance changes from the previous owner to the receiving owner atomically from the player's perspective.

### Trade Cooldown
A persistent wall-clock interval after successful Trade Ownership Finalization during which the received Creature Instance cannot be offered into another trade.

### Trade Restriction
An authored transfer rule attached to a creature/source. Baseline semantic states are **Tradeable**, **Time-Locked**, and **Account-Bound**.

### Trade History Entry
Append-only provenance metadata recording that a legitimate player-to-player ownership transfer occurred, without replacing the creature's original acquisition provenance.

## 5. Baseline Trading Model

### TM-01 — Launch trading is direct bilateral barter

Baseline trading is a direct exchange between exactly two eligible players.

Each side offers one or more eligible Creature Instances.

### TM-02 — Both sides must offer at least one creature

Baseline GDS-12 does not support zero-sided gifting.

A valid Trade Commit requires at least one eligible Creature Instance from each participant.

This does not guarantee equal subjective value; it prevents the baseline system from becoming a direct free-transfer/funneling mechanism.

### TM-03 — Energy remains non-transferable

GDS-12 explicitly preserves GDS-8's baseline rule:

> **Energy cannot be sent, gifted, dropped, traded, staked or offered player-to-player.**

Trade Offers contain Creature Instances only.

### TM-04 — No creature-for-Energy exchange

A player cannot place Energy on either side of a Trade Offer and cannot designate Energy as consideration for a creature.

### TM-05 — No baseline trade fee

Opening, cancelling or successfully completing a baseline Trade Session consumes no Energy and charges no recurring tax.

### TM-06 — No auction house or marketplace at baseline

GDS-12 authorizes no asynchronous listing, public order book, auction, automated buy offer, global marketplace or offline escrow.

Future marketplace design requires GDS-12 change control plus GDS-13/GDS-15/GDS-16 review.

### TM-07 — Same-server direct interaction only

Both participants must be actively present in the same Server Session during baseline negotiation and confirmation.

Trading does not create a cross-server persistent negotiation.

## 6. Trade Access and Eligibility

### TA-01 — Trading requires Trade Access Milestone

Baseline trading becomes available only after the player has completed required onboarding and finalized Starter Region Mastery.

The milestone is persistent and non-paid.

### TA-02 — Both players require trusted Persistent Player State

Trade Invite acceptance, reservation, confirmation and commit require Active Presence and trusted persistence readiness.

Protected Load Failure blocks irreversible trading.

### TA-03 — Platform safety may further restrict trading

GDS-15 may impose age, account, privacy, parental or policy-based restrictions.

Those restrictions may reduce availability but cannot silently weaken atomicity/ownership safety for permitted trades.

### TA-04 — Acquisition-In-Progress blocks Trade Commit

A player with an active Engagement Claim, Capture Attempt, Provisional Capture or Transport Custody cannot enter final trade confirmation/commit.

They must first resolve the active acquisition.

### TA-05 — One active Trade Session per player

A player may participate in at most one active Trade Session at a time.

### TA-06 — Party/friend status is irrelevant to eligibility

Friendship, Party membership, Visitor status or challenge status does not bypass Trade Access Milestone or safety restrictions.

## 7. Tradeable Creature Eligibility

### CE-01 — Only Secured Creatures can be traded

World Creatures, Engagement Claims, Capture Attempts, Personal Event Capture Opportunities, Provisional Captures and Transport Custody cannot be offered.

### CE-02 — Current owner must be the offering player

A player cannot offer another player's creature, a visitor-viewed creature, a Party member's creature, an event target or a creature whose ownership is already in transfer.

### CE-03 — Creature Lock blocks offering

A locked creature cannot enter a Trade Offer.

The owner must deliberately remove Creature Lock before the creature becomes eligible.

### CE-04 — Protected Variant safeguard remains meaningful

Protected Variants remain locked by their existing GDS-6/GDS-4 protection until the owner deliberately unlocks them.

Final trade review must identify Protected Variant/high-value status clearly.

A Protected Variant received through trade is re-locked on receipt by baseline.

### CE-05 — Production Assignment blocks offering

A creature with an active Production Assignment cannot be added to a Trade Offer.

The owner must deliberately unassign it first.

Previously accrued Production Buffer value remains with the current Vault owner and is not attached to the creature.

### CE-06 — Active gameplay role blocks offering

A creature currently in a mutually exclusive Active gameplay role cannot be offered until returned to an eligible non-active collection state.

### CE-07 — Display/Showcase is presentation, not a hard transfer block

A displayed/showcased eligible creature may be offered.

If Trade Ownership Finalization succeeds, the previous owner's display/showcase reference is cleared safely.

### CE-08 — Stored creatures are tradeable by default

An otherwise eligible Stored Secured Creature may be offered.

### CE-09 — Overflow-Held creatures may be traded

An otherwise eligible Overflow-Held creature may be offered.

This provides a non-destructive way to reduce the owner's over-capacity collection.

It does not allow the recipient to exceed their own capacity.

### CE-10 — Trade Cooldown blocks re-trading

A creature whose Trade Cooldown has not expired cannot enter a new Trade Offer.

### CE-11 — Trade Restriction applies

- **Tradeable:** eligible under ordinary GDS-12 rules.
- **Time-Locked:** ineligible until a clearly defined wall-clock boundary.
- **Account-Bound:** not transferable by baseline trading.

Account-Bound content must be explicitly authored/communicated as such; ordinary captured creatures are not silently made Account-Bound by default.

### CE-12 — Event/Legacy content is not automatically untradeable

Rotating, Event-Limited and Legacy Availability do not themselves prohibit trade.

Specific authored Trade Restrictions may apply, but provenance/Variant Identity remain unchanged.

## 8. Offer Composition

### OF-01 — Offers contain exact Creature Instances

Trade semantics operate on instance identity, never merely one Species count.

If a player owns duplicates, the exact offered duplicate must remain identifiable.

### OF-02 — Offer size is bounded

Each side has a bounded maximum number of Creature Instances per trade.

The launch reference target is up to **four creatures per side**; the exact cap may be tuned without reopening GDS-12 if all atomic/review semantics remain intact.

### OF-03 — Unequal creature counts are allowed

Examples such as 1-for-1, 1-for-2, 2-for-3 and 4-for-1 are valid if both sides deliberately confirm and capacity/restrictions pass.

### OF-04 — Subjective value equality is not enforced

The system does not determine that one Rare equals two Uncommons, that one Mutation has a fixed Energy price, or that one provenance is worth another.

Variant Value remains multi-dimensional and does not equal a guaranteed market price.

### OF-05 — No automated fair-trade certification

The game must not label a trade fair, profitable or good value based on a hidden formula.

It may provide factual comparison/warning information defined by GDS-14.

### OF-06 — Any offer change creates a new Trade Revision

Adding/removing/replacing a creature on either side creates a new Trade Revision.

This clears both Trade Ready states, both Final Trade Confirmations and any prior final-review authorization.

## 9. Reservation and Concurrency

### RS-01 — Offered creatures become Trade Reserved

Once accepted into the active Trade Offer, each exact Creature Instance is reserved for that Trade Session.

### RS-02 — Reservation is not transfer

The offering player remains owner until successful Trade Ownership Finalization.

### RS-03 — Reserved creatures cannot undergo conflicting ownership actions

While Trade Reserved, the creature cannot simultaneously be released, enter another Trade Session, receive a new Production Assignment, enter another ownership-transfer flow or be silently substituted by a duplicate.

### RS-04 — Reservation ends on removal/cancel/failure

Removing the creature from the offer or ending the Trade Session releases the reservation without ownership change.

### RS-05 — Reservation must not create indefinite lockout

Trade Sessions have bounded inactivity/timeout behavior.

A disconnected/abandoned negotiation cannot reserve creatures indefinitely.

## 10. Ready and Final Confirmation

### CF-01 — Ready is revision-specific

A Trade Ready action applies only to the exact current Trade Revision.

### CF-02 — Both players must become ready independently

One player's readiness cannot ready the other player.

### CF-03 — Offer change clears readiness

Any change after one/both players are ready returns the trade to negotiation.

### CF-04 — Final review occurs after both sides are ready

The system presents the exact final offer for both sides with no editing inside the final confirmation state.

### CF-05 — Both players must explicitly confirm the final revision

Trade Commit is allowed only after two valid Final Trade Confirmations for the same unchanged Trade Revision.

### CF-06 — Confirmation cannot be inferred

Closing a menu, pressing a generic interact button, Party leadership, friendship, chat text or prior readiness is not Final Trade Confirmation.

### CF-07 — High-value facts must be reviewable

Before final confirmation, each offered creature's relevant factual identity must be inspectable, including at minimum Species, Species Rarity, Mutation set, Trait identity where exposed, Availability, Protected Variant status, provenance/source where defined, exact instance distinction among duplicates and Trade Restriction/Cooldown status.

Final presentation belongs to GDS-14.

## 11. Atomic Trade Commit

### AC-01 — Trade Commit revalidates everything

Immediately before commit, authoritative state revalidates both players, unchanged Trade Revision, exact ownership, reservations, Creature Locks, Trade Restrictions/Cooldowns, Production/Active-role eligibility, recipient capacity and conflicting transactions.

### AC-02 — Trade is all-or-nothing

A successful trade exchanges the entire agreed set.

The player-facing outcome may not partially move only some creatures or finalize only one side.

### AC-03 — Each Creature Instance remains the same instance

Trading changes current owner.

It does not generate a replacement Creature Instance and does not reroll Species, Mutation, Trait, Variant Signature or original provenance.

### AC-04 — One instance has one owner after commit

Trade Ownership Finalization produces one unambiguous receiving owner for each transferred creature.

### AC-05 — No double-spend through duplicate commit

Retry/reconnect/network replay cannot transfer the same creature twice or duplicate it into both collections.

### AC-06 — Trade revision is immutable during commit

Once authoritative commit begins, offer editing is closed.

### AC-07 — Failure before commit changes nothing

If revalidation fails before Trade Ownership Finalization, ownership remains unchanged for all offered creatures.

## 12. Capacity and Collection Reconciliation

### CP-01 — Recipient capacity is evaluated on the net final exchange

Capacity is checked using the complete atomic post-trade result.

Outgoing creatures may free capacity used by incoming creatures within the same commit.

### CP-02 — Baseline trade may not create new Overflow-Held state for the receiver

A Trade Commit fails safely if a receiving player would exceed usable Collection Capacity after the complete exchange.

Trading cannot be used to dump creatures into another player's overflow.

### CP-03 — Sender may trade an existing Overflow-Held creature

The outgoing Overflow-Held creature leaves the sender's registry only on successful commit.

### CP-04 — Trading can reduce existing overflow

A successful outgoing trade may restore the sender to a non-overflow collection state.

Subsequent ordinary reconciliation follows GDS-7.

### CP-05 — Capacity race causes safe failure before ownership transfer

If capacity changes between confirmation and commit such that the final exchange is no longer eligible, Trade Commit does not partially finalize.

### CP-06 — Trade does not transfer Vault capacity

Collection Capacity, Display Slots, Production Slots and Vault Upgrades remain player-specific.

## 13. Vault and Role Reconciliation

### VR-01 — Production Assignments never transfer with the creature

A creature must already be unassigned to be offered.

The receiving owner gets the Creature Instance, not the sender's Production Slot/assignment relationship.

### VR-02 — Production Buffer stays with the original Vault

Previously accrued Energy in Production Buffer is not creature inventory and does not follow the creature.

### VR-03 — Display/Showcase references clear on successful outgoing transfer

The former owner cannot continue presenting the transferred creature as currently owned.

### VR-04 — Receiver places creature into safe ordinary collection state

A successfully received creature enters a valid receiver-owned collection state, baseline Stored, unless an explicit restriction requires another safe non-active state.

### VR-05 — Trade does not auto-assign received creatures

Receiving a creature does not automatically place it into Production, Active gameplay or Display.

## 14. Discovery and Progression Effects

### DP-01 — Legitimate trade ownership can create collection Discovery

After successful Trade Ownership Finalization, the receiving player legitimately owns the creature and may finalize applicable Species Discovery, Mutation Discovery and Variant Discovery.

### DP-02 — Sender historical Discovery is never erased

Trading away the last currently owned instance of a discovered Species/Mutation/Variant does not erase historical Discovery.

### DP-03 — Trade does not fabricate source-bound active progression

A trade-acquired creature does not automatically complete Landmark Discovery, Field Objectives, Event Contribution, Event Completion Records, Region Mastery active requirements or other source/location/activity-specific Progression Milestones unless the owning specification explicitly defines trade acquisition as eligible.

### DP-04 — Trade ownership alone does not grant event participation history

Receiving an Event-Limited creature through trade does not mean the player participated in its original Event Occurrence.

### DP-05 — Collection completion may count trade-acquired discoveries

General collection/discovery completion can recognize legitimately trade-acquired Species/Variants where its owning definition is based on ownership/discovery rather than source-specific active capture.

## 15. Provenance

### PV-01 — Original acquisition provenance is immutable historical origin

Trading does not rewrite original source into a false new capture origin.

### PV-02 — Trade adds transfer history rather than replacing origin

A successful trade appends a Trade History Entry or equivalent transfer provenance.

### PV-03 — Current owner and original origin remain distinct concepts

The recipient becomes the current owner while the original acquisition source remains historical metadata.

### PV-04 — Event provenance survives trade

Event Template/Occurrence/source provenance defined by GDS-11 remains attached to the same Creature Instance.

### PV-05 — Variant Identity survives trade

Species, Mutations, Traits and Variant Signature remain unchanged.

### PV-06 — Trade history does not imply market price

Number of past owners/trades is historical information, not an automatic value multiplier.

## 16. Trade Cooldown and Anti-Laundering

### TC-01 — Received creatures enter Trade Cooldown

Every creature received through a successful trade receives a persistent wall-clock Trade Cooldown before it can be offered again.

### TC-02 — Cooldown survives server transition

Reset, reconnect, changing server or changing device does not clear the cooldown.

### TC-03 — Cooldown does not remove ownership/use

The new owner still owns the creature and may use it in ordinary eligible non-transfer roles.

### TC-04 — Cooldown prevents rapid chain-laundering

The purpose is to slow rapid account-to-account recirculation, scam relays and transaction spam.

Exact duration is tuneable.

### TC-05 — Cooldown expiry does not alter Variant Identity

It only changes transfer eligibility.

## 17. Trade Restrictions

### TR-01 — Tradeable is the ordinary baseline

Ordinary secured captured creatures are Tradeable once all other eligibility rules pass.

### TR-02 — Time-Locked requires a visible expiry semantic

A Time-Locked creature cannot be traded before its defined wall-clock expiry.

Changing servers does not reset/skip the restriction.

### TR-03 — Account-Bound is exceptional

Account-Bound should be reserved for explicitly authored personal rewards/content whose transfer would undermine its meaning or safety.

### TR-04 — Restrictions must be knowable

A player should not discover only after negotiation that a creature was secretly permanently non-tradeable when the restriction could reasonably have been communicated earlier.

### TR-05 — Restrictions are not retroactive scarcity manipulation

Balance/live-content changes must not silently convert ordinary already-owned Tradeable creatures into Account-Bound merely to manipulate supply without explicit change control.

## 18. Gifting and One-Sided Transfers

### GF-01 — Baseline gifting is not authorized

A Trade Session requires at least one creature on each side.

### GF-02 — Party/friend relationship does not create gifting authority

No send-creature shortcut exists merely because players are friends/Party members.

### GF-03 — Future gifting requires change control

A later gifting feature must address minors/social pressure, account compromise, alternate-account funneling, accidental loss, recovery/rollback expectations and monetization/platform policy.

## 19. Energy and Player Economy Decision

### EN-01 — Energy stays non-transferable

GDS-12 closes the previously deferred Energy-transfer question with **no baseline player-to-player Energy transfer**.

### EN-02 — Energy cannot be offered, requested or escrowed in Trade Sessions

No Energy field exists in the baseline trade contract.

### EN-03 — Trading creates no Energy source or sink

Trade completion does not mint or burn Energy.

### EN-04 — Trading does not modify Passive Production

Ownership transfer can change future production options only after deliberate GDS-7 assignment.

### EN-05 — No trade tax

A future trade tax requires GDS-8/GDS-12 change control.

## 20. Value and Scarcity Philosophy

### VS-01 — Creature value is multi-dimensional

Potential player-perceived value can depend on Species Rarity, Mutation scarcity/count, Trait, Availability, original provenance, event/legacy context, current collectability, personal collection goals and future player demand.

### VS-02 — GDS-12 does not define official market prices

The game does not guarantee a fixed exchange ratio between creatures.

### VS-03 — No hidden price manipulation

The game must not secretly change spawn/variant odds for a player based on what they recently traded or predicted trade behavior.

### VS-04 — Trading does not turn rarity into power

Acquiring a rarer creature through trade does not automatically grant universal gameplay superiority.

### VS-05 — Scarcity remains grounded in legitimate instance supply

Trade changes who owns existing instances; it does not duplicate supply.

## 21. Scam and Bait-and-Switch Protection

### SP-01 — Offer changes cannot be confirmed invisibly

Every change creates a new Trade Revision and clears both parties' ready/confirmation state.

### SP-02 — Final confirmation binds exact final revision

A player cannot confirm revision N and be committed to changed revision N+1.

### SP-03 — Duplicate-looking instances remain distinguishable

The system cannot silently swap one duplicate for another visually similar instance after confirmation.

### SP-04 — Critical identity facts are authoritative

Species/Rarity/Mutation/Availability/provenance shown in trade review come from game state, not the other player's text.

### SP-05 — Off-platform promises are outside the protected trade

Chat agreements, Robux transfers or external payments are not part of Trade Commit.

### SP-06 — Trade cancellation carries no ownership penalty

Declining/cancelling before commit changes no ownership.

### SP-07 — Invite/session spam is bounded

Trade Invites and repeated Trade Session requests require tuneable cooldown/suppression controls.

## 22. Disconnect, Reset, Leave and Retry

### LR-01 — Disconnect during invitation/negotiation cancels safely

No ownership changes occur.

Reservations release after bounded cleanup.

### LR-02 — Disconnect after Ready but before commit does not imply consent

No trade occurs merely because the player had previously clicked Ready.

### LR-03 — Disconnect after one Final Confirmation but before the second changes nothing

The exchange does not finalize.

### LR-04 — Commit has exact-once authoritative resolution

If both confirmations were valid and Trade Commit began, the transaction resolves to complete successful Trade Ownership Finalization or complete failure with no ownership transfer.

### LR-05 — Reconnect displays authoritative result

The player must not need to guess whether a creature was duplicated/lost.

### LR-06 — Avatar reset does not count as confirmation/cancellation

Reset may interrupt presentation; authoritative state resolves safely.

### LR-07 — Server shutdown does not invent completion

A negotiation that had not begun authoritative commit is cancelled/no-op.

A commit already finalized remains finalized.

## 23. Alternate Accounts, Collusion and Exploitation

### AA-01 — Trade creates no reward for volume

Number of trades does not mint Energy, Progression Milestones, event rewards or rare spawn odds.

### AA-02 — No zero-sided gifting reduces direct account funneling

Baseline barter requires both accounts to transfer at least one creature.

### AA-03 — Trade Cooldown slows rapid laundering

Received creatures cannot be immediately relayed through many accounts.

### AA-04 — Alt accounts cannot bypass Trade Access Milestone

Each account independently satisfies trading eligibility.

### AA-05 — Trading does not satisfy active source-bound milestones

An alt cannot trade event/region creatures to fabricate another account's active Event Contribution/Region Mastery.

### AA-06 — Wash trading cannot create additional creature supply

The same Creature Instance moves ownership; no copies are minted.

### AA-07 — Trade history remains traceable conceptually

Legitimate transfer history supports future fraud/abuse analysis without redefining original provenance.

### AA-08 — Trade cannot reset Trade Restriction/Cooldown

Moving the creature between accounts does not erase applicable transfer timer semantics.

## 24. Event Creature Trading

### EV-01 — Event-Limited/Legacy creatures can be tradeable

Availability alone does not prohibit trade.

### EV-02 — Original event provenance remains

The receiver retains the creature's original event/source provenance.

### EV-03 — Receiving event creature does not grant Event Completion Record

Trade is ownership transfer, not proof of participation.

### EV-04 — Personal Event Capture Opportunities cannot be traded

Only fully Secured Creatures may enter GDS-12.

### EV-05 — Event-specific Account-Bound restrictions must be explicit

If an achievement/event reward is intentionally personal, its Trade Restriction must be authored clearly.

## 25. Protected Variants and High-Value Transfers

### HV-01 — Creature Lock must be intentionally removed before offer

Automatic Protected Variant lock cannot be bypassed inside Trade Session.

### HV-02 — High-value status survives transfer

Legendary/Extreme/Compound/Event-Limited/Legacy properties remain unchanged.

### HV-03 — Protected Variants arrive locked

After Trade Ownership Finalization, a received Protected Variant is automatically Creature Locked for the new owner.

### HV-04 — Stronger review is allowed downstream

GDS-14 may require additional hold-to-confirm, semantic acknowledgment or review delay for high-value asymmetric trades.

## 26. Marketplace and Asynchronous Trade Boundary

### MK-01 — No baseline listings

Players cannot leave creatures listed while offline.

### MK-02 — No global price feed

GDS-12 does not create an official average price, floor, chart or market index.

### MK-03 — No automated matching

The system does not auto-match want/offer requests across servers.

### MK-04 — Future marketplace requires new authority

Any future marketplace must revalidate atomic ownership, escrow, offline lifecycle, price manipulation, botting, alternate accounts, child safety/social pressure, monetization, platform policy, market analytics and scarcity effects.

## 27. Monetization Boundary

GDS-12 authorizes no paid trading mechanic.

GDS-13 must preserve at minimum:

- no Robux payment required to complete a normal eligible trade;
- no paid ability to bypass Creature Lock;
- no paid bypass of Trade Cooldown/Account-Bound restriction unless GDS-12 is reopened;
- no paid claim over another player's offered creature without both confirmations;
- no hidden premium trade priority;
- no commercial conversion of Energy into player-to-player transferable tender unless GDS-8/GDS-12 are reopened;
- no monetized scam-protection feature where baseline safety requires payment.

## 28. Platform Safety Boundary

GDS-15 must review account/age/privacy eligibility, parental controls, reporting/blocking, chat/off-platform solicitation risks, account-compromise recovery expectations, high-value/asymmetric-trade warnings and restrictions on user-generated trade text.

GDS-12 baseline does not require unrestricted chat to negotiate a valid exchange.

## 29. Presentation and Accessibility Requirements

GDS-14 must make clear:

- both participants;
- exact offered Creature Instances;
- Species/Rarity/Mutation/Trait/Availability;
- provenance where exposed;
- Protected Variant/high-value status;
- Trade Restriction/Cooldown;
- capacity incompatibility;
- Trade Revision changes;
- own/other Ready state;
- reset of readiness after any change;
- immutable final-review state;
- explicit Final Trade Confirmation;
- success/failure/cancellation;
- received creature lock/cooldown.

Critical meaning cannot rely solely on color, audio, tiny icons, unrestricted text chat or pixel-precise selection.

## 30. Analytics and Experimentation Boundaries

Design-relevant metrics include invite send/accept/decline, milestone attainment, session cancel/completion, revision count, ready-reset frequency, capacity/restriction failure, high-value trade frequency, asymmetric exchange distribution, cooldown recurrence, repeat counterparties, alt/collusion indicators, post-trade reports, Protected Variant trades and event/Legacy transfers.

Experiments may tune invite/session timeouts, maximum creatures per side within bounded limits, Trade Cooldown duration, final-review delay, high-value warning thresholds and factual presentation.

Experiments may **not** enable Energy transfer, zero-sided gifting, partial commit, Creature Lock bypass, hidden rerolls, recipient overflow, provenance erasure, official hidden pricing, reward farming from trade count or premium safety bypass.

## 31. Tuneable Parameters

Tuneable without reopening GDS-12:

- Invite expiry/cooldown;
- negotiation inactivity timeout;
- launch offer-count cap around four per side;
- Trade Cooldown duration;
- Time-Locked durations for authored content;
- final-review delay;
- high-value warning thresholds;
- factual sorting/filtering/presentation;
- rate limits.

Semantic/change-control decisions:

- direct bilateral same-server trading;
- both sides offering at least one creature;
- no Energy transfer;
- no trade fee;
- no auction/marketplace/offline listing;
- Trade Access Milestone;
- exact-instance offers;
- Creature Lock blocking transfer;
- Production Assignment blocking offer;
- Overflow-Held sender eligibility;
- recipient no-new-overflow rule;
- revision invalidating readiness;
- independent Ready plus independent Final Confirmation;
- atomic all-or-nothing Trade Commit;
- stable instance/variant/provenance;
- Discovery from legitimate ownership but no fabricated active milestones;
- received Trade Cooldown;
- Protected Variant re-lock;
- no automatic fair-price certification.

## 32. Dependencies and Downstream Obligations

### GDS-13 — Monetization and Commercial Fairness

Must decide whether any commercial products interact with trading without introducing premium safety, paid transfer priority, transferable paid tender or coercive fees.

### GDS-14 — Presentation, UI/UX, Feedback, Accessibility

Must implement exact-instance inspection, Trade Revision/Ready reset visibility, final immutable review, capacity/restriction errors, high-value warnings and accessible dual confirmation.

### GDS-15 — Roblox Platform, Social Safety and Moderation

Must define account/age/privacy eligibility, reporting/blocking, communication constraints, scam/off-platform solicitation protections and policy restrictions.

### GDS-16 — Retention, Discovery, Analytics and Experimentation

Must monitor liquidity/social value without rewarding raw trade volume, manipulative price/FOMO pressure or experiments that weaken ownership safety.

### Technical Architecture

Must implement secure Trade Reservations, concurrency control, exact Trade Revision identity, atomic multi-instance ownership transfer, capacity revalidation, idempotent commit, durable cooldowns/restrictions/provenance, recovery after disconnect and anti-duplication.

## 33. Edge-Case Matrix

| Situation | Required behavior |
|---|---|
| Player has not completed Starter Region Mastery | Trading unavailable |
| Friend sends trade invite | Explicit acceptance still required |
| Player already in another Trade Session | Cannot join second simultaneously |
| Player has Protected Load Failure | Irreversible trade blocked |
| Player has active Transport Custody | Cannot finalize trade until resolved |
| Player offers Provisional Capture | Ineligible |
| Player offers another player's creature | Rejected |
| Player offers locked creature | Rejected |
| Player unlocks Protected Variant deliberately | May become eligible if all other rules pass |
| Player offers Production-assigned creature | Rejected until unassigned |
| Player offers displayed creature | May be offered; display clears only on successful transfer |
| Player offers Overflow-Held creature | Allowed if otherwise eligible |
| Receiver lacks post-trade capacity | Commit fails safely |
| Outgoing creatures free enough capacity for incoming set | Net capacity may pass atomically |
| Offer is 1-for-1 | Valid |
| Offer is 1-for-3 | Valid if deliberate and capacity-safe |
| One side offers zero creatures | Invalid baseline trade |
| Player tries to add Energy | Invalid |
| Player promises Robux in chat | Outside protected trade; not part of commit |
| Player changes offered duplicate | New Trade Revision; readiness cleared |
| Both players Ready then one edits | Both Ready states cleared |
| One player Final Confirms then offer changes | Old confirmation invalid |
| Both Final Confirm same revision | Commit may begin |
| Ownership changes before commit | Revalidation fails; no partial trade |
| Lock toggled before commit | Revalidation fails |
| Capacity changes before commit | Safe failure if post-trade invalid |
| Network retry repeats commit | No duplicate transfer |
| Disconnect during negotiation | Cancel/no ownership change |
| Disconnect after Ready | No inferred final confirmation |
| Disconnect after one final confirm | No trade |
| Disconnect during authoritative commit | Complete or no-op atomically |
| Reconnect after completed trade | Authoritative new owners shown |
| Sender's last Species copy traded away | Sender retains historical Discovery |
| Receiver never discovered Species | Successful trade may grant Discovery |
| Receiver gets Event-Limited Species | No Event Completion Record fabricated |
| Receiver gets region-native Species | No automatic active Region Mastery |
| Original event creature is traded | Original event provenance preserved |
| Creature traded several times | Same Creature Instance; append transfer history |
| Protected Variant received | Arrives Creature Locked |
| Received creature immediately re-offered | Blocked by Trade Cooldown |
| Player changes server | Cooldown persists |
| Account-Bound creature offered | Rejected |
| Time-Locked expiry reached | May become eligible if other rules pass |
| Event-Limited availability ended | Owned Tradeable instance may still trade |
| Trade cancelled | Reservations release; ownership unchanged |
| Invite spam | Rate-limited/suppressible |
| Party Leader tries accepting member trade | No authority |
| Visitor tries trading owner's displayed creature | No authority |
| Player tries using trade to send Energy to alt | Impossible baseline |
| Players wash-trade same creatures | No value mint; cooldown limits rapid cycling |
| Trade count proposed to grant Energy | Invalid |
| Auction house proposed | Outside baseline; requires change control |
| Offline listing proposed | Outside baseline; requires change control |
| Trade tax proposed | Requires GDS-8/GDS-12 change control |
| Gifting proposed | Requires GDS-12 change control |
| Paid cooldown bypass proposed | Requires GDS-12/GDS-13 change control |
| Same creature appears in two Trade Sessions | Invalid reservation state |
| Same creature appears twice on one offer | Invalid exact-instance duplication |
| Trade succeeds with two-for-one | All included ownership changes finalize atomically |
| One transfer leg fails | Entire trade fails/no partial ownership result |

## 34. Open Questions

There are **zero GDS-12-blocking open questions**.

Exact Trade Cooldown duration, final-review delay, trade invite/session timeouts, launch offer-count cap, final warning language, platform/account restrictions, detailed UI, monetization interactions and transaction implementation are tuneable or downstream authority rather than unresolved GDS-12 semantics.

## 35. Design-Complete Checklist

- [x] Trade access and consent are explicit.
- [x] Baseline direct bilateral barter is defined.
- [x] Energy transfer decision is closed: prohibited.
- [x] Baseline gifting decision is closed: prohibited.
- [x] Marketplace/auction/offline-listing decision is closed: not baseline.
- [x] Exact-instance offer semantics are defined.
- [x] Creature Lock/Protected Variant behavior is defined.
- [x] Production/Active/Display/Overflow eligibility is defined.
- [x] Recipient capacity and net-exchange rules are defined.
- [x] Trade Revision/Ready/final-confirmation semantics are deterministic.
- [x] Atomic exact-once Trade Commit is defined.
- [x] Disconnect/retry/server lifecycle behavior is defined.
- [x] Trade Cooldown/Trade Restriction semantics are defined.
- [x] Discovery versus active-progression effects are defined.
- [x] Provenance preservation/transfer history is defined.
- [x] Event/Legacy creature behavior is defined.
- [x] Scam/bait-and-switch protections are defined.
- [x] Alt-account/wash-trade abuse is addressed.
- [x] Monetization/platform/presentation/analytics authority remains downstream.
- [x] No implementation-relevant open questions remain.
