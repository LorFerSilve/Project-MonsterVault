# GDS-12 Scenario Validation

> **Phase:** GDS-12 — Trading and Player Economy  
> **Status:** PASS  
> **Purpose:** Compound validation of trade access, eligibility, offer/version semantics, atomic ownership transfer, capacity/Vault reconciliation, discovery/provenance, disconnect/retry behavior, Protected Variants, event content, Energy non-transferability, scam resistance, alternate-account abuse and downstream authority.

## Validation Method

Each scenario is tested against closed GDS-1 through GDS-11 plus trading/12_trading_and_player_economy.md.

A scenario passes only if:

- every transferred creature remains one stable Creature Instance with one unambiguous owner;
- no Trade Commit can partially finalize;
- offer changes invalidate all prior ready/confirmation state;
- Creature Lock and transfer restrictions are respected;
- recipient capacity is valid for the complete atomic exchange;
- Energy remains non-transferable;
- trade cannot fabricate source-bound active progression or event participation;
- provenance and Variant Identity survive transfer;
- reconnect/retry cannot duplicate or erase legitimate finalized transfers;
- Party/friend/premium state cannot replace either player's explicit consent.

## Scenarios

| # | Scenario | Expected Result | Result |
|---:|---|---|---|
| 1 | Player has not completed onboarding | Trading unavailable | PASS |
| 2 | Player completed onboarding but not Starter Region Mastery | Trading unavailable | PASS |
| 3 | Player finalized Starter Region Mastery | Trade Access Milestone may be available | PASS |
| 4 | Platform-safety policy later disables trading for player | Trading unavailable without weakening ownership safety | PASS |
| 5 | Friend sends Trade Invite | Explicit acceptance still required | PASS |
| 6 | Party Leader sends Trade Invite | Leadership grants no automatic acceptance | PASS |
| 7 | Stranger sends Trade Invite | May be accepted/declined under invite policy | PASS |
| 8 | Invite ignored | Expires/no ownership effect | PASS |
| 9 | Invite declined | No ownership effect | PASS |
| 10 | Invite spam occurs | Rate-limited/suppressible | PASS |
| 11 | Player already in Trade Session | Cannot enter second simultaneous session | PASS |
| 12 | Players are on different servers | Baseline direct trade unavailable | PASS |
| 13 | Same-server eligible players accept | Trade Session opens | PASS |
| 14 | One player has Protected Load Failure | Irreversible trade blocked | PASS |
| 15 | Player has active Engagement Claim | Cannot reach final Trade Commit | PASS |
| 16 | Player has Capture Attempt active | Cannot reach final Trade Commit | PASS |
| 17 | Player has Provisional Capture | Cannot reach final Trade Commit | PASS |
| 18 | Player has Transport Custody | Cannot reach final Trade Commit | PASS |
| 19 | Player resolves acquisition | May proceed if all other trade rules pass | PASS |
| 20 | Player offers World Creature | Rejected | PASS |
| 21 | Player offers Personal Event Capture Opportunity | Rejected | PASS |
| 22 | Player offers Provisional Capture | Rejected | PASS |
| 23 | Player offers current Secured Creature | Eligible subject to all restrictions | PASS |
| 24 | Player offers someone else's creature | Rejected | PASS |
| 25 | Visitor sees owner's displayed creature and tries to offer it | Rejected | PASS |
| 26 | Party member tries to offer teammate creature | Rejected | PASS |
| 27 | Locked creature is selected | Rejected | PASS |
| 28 | Protected Variant remains auto-locked | Ineligible until deliberate unlock | PASS |
| 29 | Owner deliberately unlocks Protected Variant | May become eligible | PASS |
| 30 | Production-assigned creature is selected | Rejected until unassigned | PASS |
| 31 | Player unassigns production creature | May become eligible | PASS |
| 32 | Existing Production Buffer contains accrued Energy | Buffer remains with original Vault | PASS |
| 33 | Active-role creature is selected | Rejected until returned to eligible state | PASS |
| 34 | Stored creature is selected | Eligible by baseline | PASS |
| 35 | Overflow-Held creature is selected | Eligible if otherwise valid | PASS |
| 36 | Displayed creature is selected | May be offered | PASS |
| 37 | Showcased creature is selected | May be offered | PASS |
| 38 | Displayed creature transfer succeeds | Former owner's display reference clears safely | PASS |
| 39 | Creature is within Trade Cooldown | Rejected | PASS |
| 40 | Cooldown expires | Transfer eligibility may return | PASS |
| 41 | Tradeable restriction | Ordinary eligibility applies | PASS |
| 42 | Time-Locked restriction before expiry | Rejected | PASS |
| 43 | Time-Locked restriction after expiry | May be eligible | PASS |
| 44 | Account-Bound creature offered | Rejected | PASS |
| 45 | Event-Limited creature with no special restriction | May be tradeable | PASS |
| 46 | Legacy creature with no special restriction | May be tradeable | PASS |
| 47 | One side offers one creature | Valid offer side | PASS |
| 48 | One side offers four creatures under launch reference cap | Valid offer size | PASS |
| 49 | Offer exceeds configured bound | Additional creature rejected | PASS |
| 50 | Trade is 1-for-1 | Valid structure | PASS |
| 51 | Trade is 1-for-2 | Valid if deliberate/capacity-safe | PASS |
| 52 | Trade is 4-for-1 | Valid if deliberate/capacity-safe | PASS |
| 53 | One side offers zero creatures | Invalid baseline gifting | PASS |
| 54 | Player tries to add Energy | Invalid | PASS |
| 55 | Player tries creature-for-Energy trade | Invalid | PASS |
| 56 | Player tries Energy-for-Energy transfer | Invalid | PASS |
| 57 | Trade completion proposed to charge Energy fee | Not baseline-authorized | PASS |
| 58 | Player promises Robux externally | Not part of protected Trade Commit | PASS |
| 59 | Player promises future creature outside current offer | Not part of protected Trade Commit | PASS |
| 60 | Offer contains exact duplicate-looking instance A | Instance A is authoritative target | PASS |
| 61 | Player swaps A for visually similar instance B | New Trade Revision required | PASS |
| 62 | Player adds creature after counterpart Ready | Both Ready states cleared | PASS |
| 63 | Player removes creature after both Ready | Both Ready states cleared | PASS |
| 64 | Player changes only order/presentation without semantic offer change | May remain same revision if identity/content unchanged | PASS |
| 65 | Semantic offer changes | New revision mandatory | PASS |
| 66 | One player clicks Ready | Other remains unready | PASS |
| 67 | Both players click Ready on same revision | Final review may open | PASS |
| 68 | Final review allows editing | Invalid; editing requires returning to negotiation/new revision | PASS |
| 69 | One player final-confirms | Commit still blocked until second confirmation | PASS |
| 70 | Both players final-confirm same revision | Commit may begin | PASS |
| 71 | Generic menu close occurs | Not confirmation | PASS |
| 72 | Party Leader says yes in chat | Not confirmation | PASS |
| 73 | One player confirmed old revision | Old confirmation invalid after revision change | PASS |
| 74 | Offered creature becomes reserved | Still owned by current owner until commit | PASS |
| 75 | Reserved creature is selected for Release | Conflicting action rejected | PASS |
| 76 | Reserved creature is selected for second trade | Rejected | PASS |
| 77 | Reserved creature receives Production Assignment | Rejected | PASS |
| 78 | Trade is cancelled | Reservation releases; ownership unchanged | PASS |
| 79 | Session times out from inactivity | Reservation releases safely | PASS |
| 80 | Same creature appears twice in one offer | Invalid | PASS |
| 81 | Same creature appears in two concurrent sessions | Invalid reservation state | PASS |
| 82 | Both final-confirm, then ownership changed by external race before commit | Revalidation fails/no transfer | PASS |
| 83 | Both final-confirm, then Creature Lock is re-enabled | Revalidation fails/no transfer | PASS |
| 84 | Both final-confirm, then restriction activates | Revalidation fails/no transfer | PASS |
| 85 | Both final-confirm, then Production Assignment appears | Revalidation fails/no transfer | PASS |
| 86 | Commit transfers first creature but second leg fails | Invalid; transaction must not expose partial result | PASS |
| 87 | Multi-creature trade succeeds | Entire agreed set moves atomically | PASS |
| 88 | Commit retries after network timeout | No duplicate transfer | PASS |
| 89 | Same commit request delivered twice | Exact-once ownership result | PASS |
| 90 | Successful transfer completes | Same Creature Instance identity persists | PASS |
| 91 | Trade changes Species | Invalid | PASS |
| 92 | Trade rerolls Mutation | Invalid | PASS |
| 93 | Trade rerolls Trait | Invalid | PASS |
| 94 | Trade rewrites original event provenance | Invalid | PASS |
| 95 | Trade appends transfer history | Valid | PASS |
| 96 | One instance ends owned by both players | Invalid | PASS |
| 97 | One instance ends owned by neither after successful commit | Invalid | PASS |
| 98 | Receiver gets creature while sender also retains copy | Invalid duplication | PASS |
| 99 | Receiver capacity sufficient before 1-for-1 | Commit may proceed | PASS |
| 100 | Receiver full but sends one and receives one | Net capacity may remain valid | PASS |
| 101 | Receiver sends one and receives two while full | Commit fails if net result exceeds capacity | PASS |
| 102 | Sender trades Overflow-Held creature out | Allowed and may reduce sender overflow | PASS |
| 103 | Receiver would newly enter Overflow-Held | Baseline commit rejected | PASS |
| 104 | Capacity changes after final confirmation | Commit revalidates | PASS |
| 105 | Sender loses last copy of Species | Historical Species Discovery remains | PASS |
| 106 | Receiver never owned Species before | Successful trade may create Species Discovery | PASS |
| 107 | Receiver never saw Mutation before | Successful trade may create Mutation Discovery | PASS |
| 108 | Receiver never owned Variant Signature | Successful trade may create Variant Discovery | PASS |
| 109 | Receiver gains Species through trade | Does not automatically complete Landmark Discovery | PASS |
| 110 | Receiver gains region-native Species through trade | Does not automatically satisfy active Region Mastery requirement | PASS |
| 111 | Receiver gains Event-Limited creature | Does not create Event Completion Record | PASS |
| 112 | Sender trades event creature | Original event provenance remains | PASS |
| 113 | Creature is traded multiple times | Same instance plus append-only transfer history | PASS |
| 114 | Protected Variant received | Automatically Creature Locked for receiver | PASS |
| 115 | Received ordinary creature enters Trade Cooldown | Cannot immediately re-trade | PASS |
| 116 | Player changes server during cooldown | Cooldown persists | PASS |
| 117 | Player resets during cooldown | Cooldown persists | PASS |
| 118 | Cooldown expires | No identity/provenance change | PASS |
| 119 | Disconnect during Trade Invite | Invite ends/no ownership effect | PASS |
| 120 | Disconnect during negotiation | Session cancels/no ownership effect | PASS |
| 121 | Disconnect after Ready | No inferred final confirmation | PASS |
| 122 | Disconnect after only one Final Confirmation | No trade | PASS |
| 123 | Disconnect during authoritative commit | Authoritative complete-or-no-op result | PASS |
| 124 | Reconnect after successful commit | New ownership displayed | PASS |
| 125 | Server shuts down before commit | Negotiation cancels/no ownership change | PASS |
| 126 | Server shuts down after finalized commit | Finalized ownership persists | PASS |
| 127 | Players repeatedly trade back and forth | No Energy/reward minting | PASS |
| 128 | Alt account has not earned Trade Access Milestone | Cannot receive/send via baseline trade | PASS |
| 129 | Alt and main barter lopsided creatures | Allowed only through explicit bilateral confirmed barter; no system value mint | PASS |
| 130 | Players try rapid relay through several alts | Trade Cooldown blocks immediate chain transfer | PASS |
| 131 | Trade volume proposed to grant Progression Milestone | Invalid baseline | PASS |
| 132 | Trade volume proposed to improve spawn odds | Invalid | PASS |
| 133 | Trade outcome proposed to improve Mutation odds | Invalid | PASS |
| 134 | Marketplace listing requested | Outside baseline GDS-12 | PASS |
| 135 | Auction requested | Outside baseline GDS-12 | PASS |
| 136 | Offline escrow requested | Outside baseline GDS-12 | PASS |
| 137 | Zero-sided gift requested | Outside baseline GDS-12 | PASS |
| 138 | Temporary lending requested | Outside baseline GDS-12 | PASS |
| 139 | Paid cooldown bypass requested | Requires GDS-12/GDS-13 change control | PASS |
| 140 | Paid Creature Lock bypass requested | Invalid baseline | PASS |

## Cross-Cutting Results

### Ownership integrity

Every valid trade operates on exact Creature Instances and finalizes as one atomic ownership exchange. No partial ownership, duplicate instance or ambiguous current owner is permitted.

### Consent and bait-and-switch integrity

Every semantic offer change creates a new Trade Revision and clears readiness/confirmation. Both players independently review and final-confirm the exact same final revision.

### Economy integrity

Energy remains non-transferable and trading itself mints/burns no Energy. There is no fee, Party wallet, trade-volume reward or creature-for-Energy market.

### Collection/progression integrity

Trade-acquired creatures may create legitimate collection Discovery, but trading cannot fabricate Region Mastery, Landmark, Event Completion or other activity/source-specific milestones.

### Value/provenance integrity

Species/Mutation/Trait/Variant Identity and original provenance remain unchanged. Trading appends transfer history rather than rewriting origin.

### Abuse integrity

Trade Access gating, no zero-sided gifting, exact-instance reservations, Trade Cooldown and no reward-for-volume semantics address common alt laundering, replay, duplicate and scam pressure without creating involuntary loss.

## Verdict

**140 / 140 scenarios: PASS.**

No GDS-12-blocking scenario contradiction remains.
