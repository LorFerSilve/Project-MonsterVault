# GDS-12 Decision Index

> **Phase:** GDS-12 — Trading and Player Economy  
> **Status:** Accepted  
> **Purpose:** Phase-local record of strategic GDS-12 decisions and rationale. Detailed behavior remains authoritative in trading/12_trading_and_player_economy.md.

## GDS12-D01 — Launch Trading Is Direct Same-Server Bilateral Creature Barter

**Status:** Accepted

### Context

MonsterVault benefits from social exchange, but a launch marketplace would add asynchronous escrow, pricing, botting, moderation and liquidity problems before those systems are designed.

### Decision

Baseline trading is an explicit same-server exchange between exactly two eligible players.

Both sides offer at least one Creature Instance.

### Rationale

This captures the core social value of trading while keeping ownership/consent legible and the implementation contract bounded.

### Alternatives Rejected

- global auction house;
- offline listings;
- asynchronous escrow;
- zero-sided gifting;
- shared/guild inventory transfer.

### Affected Specifications

GDS-4, GDS-6 through GDS-16, Technical Architecture.

---

## GDS12-D02 — Energy Remains Non-Transferable

**Status:** Accepted

### Context

GDS-8 intentionally made Energy non-transferable pending GDS-12. Allowing currency transfer would create a true player market, alt-account wealth funnel, price economy and stronger RMT pressure.

### Decision

Energy cannot be sent, gifted, dropped, traded, staked or escrowed player-to-player.

Trade Offers contain Creature Instances only.

### Rationale

Creature exchange gains social value without destabilizing the established soft-currency economy.

### Alternatives Rejected

- Energy-for-creature trades;
- direct Energy gifts;
- Party wallet;
- Energy stakes;
- player-authored Energy prices.

### Affected Specifications

GDS-8, GDS-10, GDS-12 through GDS-16.

---

## GDS12-D03 — Trading Requires Active Progression Before Access

**Status:** Accepted

### Context

Immediate first-session trading would let new/alternate accounts bypass the intended early collection/world-learning loop and increases scam/funneling pressure.

### Decision

Baseline Trade Access Milestone requires completion of onboarding plus Starter Region Mastery.

The milestone is non-paid and persistent.

### Rationale

Players learn ownership, capture, Vault and world semantics before irreversible player-to-player transfer becomes available.

### Alternatives Rejected

- trading from first login;
- paid trading unlock;
- friend/Party-based bypass;
- trade access from passive Energy alone.

### Affected Specifications

GDS-3, GDS-8 through GDS-10, GDS-12, GDS-15.

---

## GDS12-D04 — Trade Safety Uses Revision Reset Plus Dual Final Confirmation

**Status:** Accepted

### Context

The main scam risk in direct trades is bait-and-switch: one side changes the offer after the other player thinks they agreed.

### Decision

Any semantic offer change creates a new Trade Revision and clears all Ready/Final Confirmation state.

Trade Commit requires both players to independently confirm the same immutable final revision after final review.

### Rationale

The system protects consent at the exact offered-instance level instead of relying on social trust.

### Alternatives Rejected

- one-click trade after initial invite;
- only one Ready button with editable offers;
- confirmation surviving offer edits;
- Party leader confirmation on behalf of members.

### Affected Specifications

GDS-2, GDS-3, GDS-10, GDS-12, GDS-14, Technical Architecture.

---

## GDS12-D05 — Trade Commit Is Atomic and Exact-Once

**Status:** Accepted

### Context

Multi-creature exchanges create dangerous partial-failure cases if one ownership leg succeeds and another fails.

### Decision

Trade Commit revalidates both sides and applies the entire exchange as one player-facing all-or-nothing ownership transition.

Retries cannot duplicate or reapply the transfer.

### Rationale

No player should end in a state where they lost their offered creature without receiving the exact confirmed return.

### Alternatives Rejected

- sequential per-creature transfer;
- best-effort partial trade;
- client-owned transfer sequencing;
- reconnect-based replay.

### Affected Specifications

GDS-2, GDS-4, GDS-7, GDS-12, Technical Architecture.

---

## GDS12-D06 — Creature Lock and Protected Variant Safeguards Apply Before and After Trading

**Status:** Accepted

### Context

GDS-4/GDS-6 use Creature Lock specifically to prevent destructive/transfer mistakes for valuable creatures.

### Decision

Locked creatures cannot enter Trade Offers.

Protected Variants require deliberate unlock before offer and are automatically re-locked for the receiving owner after successful transfer.

### Rationale

Trading should never become the mechanism that bypasses high-value protection.

### Alternatives Rejected

- trade UI auto-unlocking;
- Party leader override;
- paid lock bypass;
- receiving Protected Variants unlocked by default.

### Affected Specifications

GDS-4, GDS-6, GDS-12 through GDS-15.

---

## GDS12-D07 — Recipient Capacity Must Fit the Complete Net Exchange

**Status:** Accepted

### Context

Trading should not become a way to bypass the GDS-7 capacity contract or dump unwanted creatures into another player's overflow.

### Decision

The complete atomic post-trade collection state is validated.

Outgoing creatures may free capacity for incoming ones, but baseline trading cannot newly place the receiver into Overflow-Held.

An existing sender Overflow-Held creature may be traded out.

### Rationale

Trading supports collection management without becoming infinite hidden storage.

### Alternatives Rejected

- always allowing receiver overflow;
- ignoring capacity during trade;
- forbidding all overflow-held transfers;
- partial transfers based on available slots.

### Affected Specifications

GDS-4, GDS-7, GDS-12, Technical Architecture.

---

## GDS12-D08 — Trade Preserves Instance Identity and Original Provenance

**Status:** Accepted

### Context

Collection value depends on stable Species/Mutation/Trait identity and meaningful origin history.

### Decision

Trade changes current ownership only.

Species, Mutations, Traits, Variant Signature and original provenance remain unchanged; transfer history is appended separately.

### Rationale

A traded event/legacy/rare creature remains the same collectible object rather than a newly generated replacement.

### Alternatives Rejected

- reroll on transfer;
- replacing original provenance with "traded";
- resetting event source/history;
- generating a new instance for the receiver.

### Affected Specifications

GDS-4, GDS-6, GDS-11, GDS-12.

---

## GDS12-D09 — Trade-Acquired Creatures Grant Collection Discovery but Not Source-Bound Active Progression

**Status:** Accepted

### Context

Ownership-based collection completion should recognize legitimate trading, but Region Mastery/Event Completion must still represent active participation.

### Decision

Successful Trade Ownership Finalization may create Species/Mutation/Variant Discovery for the receiver.

It does not automatically grant Region Mastery, Landmark Discovery, Event Completion/Contribution or other source/activity-specific milestones.

### Rationale

Trading strengthens collection strategy without replacing exploration and event participation.

### Alternatives Rejected

- no discovery from legitimate trade ownership;
- trade automatically completing Region Mastery;
- event creature trade granting historical event participation;
- copying sender's milestones.

### Affected Specifications

GDS-4, GDS-6, GDS-9, GDS-11, GDS-12, GDS-16.

---

## GDS12-D10 — Received Creatures Have a Persistent Trade Cooldown

**Status:** Accepted

### Context

Immediate re-trading enables rapid laundering, scam relays and high-volume alt-account circulation.

### Decision

Every received creature enters a persistent wall-clock Trade Cooldown before it can be transferred again.

Ownership/use remains otherwise intact.

### Rationale

This slows abuse without deleting value or blocking ordinary collection/Vault use.

### Alternatives Rejected

- no transfer cooldown;
- server-local cooldown;
- cooldown cleared by reconnect;
- cooldown that disables ownership/use entirely.

### Affected Specifications

GDS-2, GDS-7, GDS-12, GDS-15, GDS-16.

---

## GDS12-D11 — No Baseline Official Pricing, Auction House, Gifting, or Trade Tax

**Status:** Accepted

### Context

Official prices, one-sided gifts, fees and asynchronous markets introduce distinct economy/safety incentives beyond direct barter.

### Decision

GDS-12 baseline has:

- no official fair-price formula;
- no marketplace/auction/order book;
- no zero-sided gifting;
- no Energy trade tax.

Unequal creature-for-creature barter remains allowed with explicit confirmation.

### Rationale

The player economy stays collection-focused and consent-driven rather than becoming a financial market.

### Alternatives Rejected

- game-valued price tables;
- mandatory trade tax;
- public auction house;
- direct gifts;
- price floors/ceilings.

### Affected Specifications

GDS-8, GDS-12 through GDS-16.

---

## GDS12-D12 — Close GDS-12 Trading and Player Economy

**Status:** Accepted

### Context

The authoritative GDS-12 specification resolves trade access, exact-instance eligibility, Creature Lock, Production/capacity interaction, offer/version/confirmation semantics, atomic ownership transfer, Energy/gifting/marketplace decisions, cooldown/restrictions, discovery/provenance, event content, lifecycle failure, scams and alt-account abuse. Scenario and cross-system validation pass.

### Decision

GDS-12 is formally closed as **Complete — PASS**.

Material changes to:

- bilateral same-server barter;
- both sides offering creature value;
- Energy non-transferability;
- no baseline gifting;
- no baseline marketplace/auction/offline listing;
- Trade Access Milestone;
- Creature Lock transfer protection;
- Trade Revision readiness reset;
- dual Final Trade Confirmation;
- atomic all-or-nothing Trade Commit;
- recipient no-new-overflow rule;
- stable instance/Variant/provenance;
- Discovery versus active-milestone boundary;
- Trade Cooldown;
- Protected Variant re-lock

require GDS-12 change control and revalidation.

### Evidence

- trading/12_trading_and_player_economy.md — Design Complete;
- GDS12_SCENARIO_VALIDATION.md — 140 / 140 PASS;
- GDS12_CROSS_VALIDATION.md — PASS;
- GDS12_CLOSURE_REPORT.md — PASS.

### Consequence

The active dependency advances to **GDS-13 — Monetization and Commercial Fairness**. Technical Architecture and gameplay implementation remain blocked.
