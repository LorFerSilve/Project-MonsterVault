# GDS-5 Scenario Validation

> **Phase:** GDS-5 — Capture, Contesting, Transport, and Extraction  
> **Status:** PASS  
> **Purpose:** Compound validation of ordinary acquisition, contesting, transport, capacity, interruption, onboarding, multiplayer, and exact-once finalization semantics.

## Validation Method

Each scenario is tested against the closed GDS-1 through GDS-4 contracts plus `capture/05_capture_contesting_transport_and_extraction.md`.

A scenario passes only if:

- ownership remains unambiguous;
- GDS-2 persistence/finalization semantics are preserved;
- GDS-3 input/onboarding/Recovery constraints are preserved;
- GDS-4 instance identity/Collection Registry/capacity safety is preserved;
- ordinary contesting cannot create contradictory winners;
- reset/disconnect/server lifecycle has deterministic player-facing consequences;
- downstream authority is not silently stolen.

## Scenarios

| # | Scenario | Expected Result | Result |
|---:|---|---|---|
| 1 | Player approaches eligible unclaimed creature | Primary Interact may establish valid Engagement Claim | PASS |
| 2 | Two players interact nearly simultaneously | One ordinary claim becomes authoritative; loser receives non-success feedback | PASS |
| 3 | Second player interacts after claim established | Active claimant is not overwritten | PASS |
| 4 | Claimed player idles | Claim expires through bounded inactivity rule | PASS |
| 5 | Claimed player moves too far away | Claim invalidates/releases according to bounded range rule | PASS |
| 6 | Player repeatedly starts/cancels | Cannot monopolize creature indefinitely | PASS |
| 7 | Attempt initiation is invalid | No cost/claim ownership effect is finalized | PASS |
| 8 | Accepted attempt later fails | No secured ownership is created | PASS |
| 9 | Failed attempt leaves creature available | Opportunity reopens if encounter lifetime remains valid | PASS |
| 10 | Failed attempt coincides with encounter expiry | Explicit encounter-owned end; no hidden ownership | PASS |
| 11 | Player succeeds capture challenge | One Provisional Capture is created | PASS |
| 12 | Capture Success occurs while another player is nearby | Contesting ends; observer cannot hijack custody | PASS |
| 13 | Capture Success client visual repeats | Still one provisional semantic instance | PASS |
| 14 | Player already transports another creature | New ordinary capture initiation is blocked | PASS |
| 15 | Provisional carrier reaches Secure Point | Extraction completes after authoritative revalidation when all conditions remain valid | PASS |
| 16 | Player reaches Secure Point without provisional creature | No creature is created/finalized | PASS |
| 17 | Secure interaction delivered twice | One Secured Ownership Finalization only | PASS |
| 18 | Finalization succeeds then client disconnects immediately | Creature remains GDS-4 Secured Creature | PASS |
| 19 | Finalization succeeds then server changes | Same secured instance persists | PASS |
| 20 | Provisional creature reaches extraction | Same instance identity becomes secured; no reroll/substitution | PASS |
| 21 | Player resets during Engagement Claim | Claim ends; no ownership | PASS |
| 22 | Player resets during Capture Attempt | Attempt interrupted; no automatic success | PASS |
| 23 | Player resets during transport | Recovery does not extract; provisional custody ends | PASS |
| 24 | Player intentionally leaves during transport | No secured ownership; provisional state ends | PASS |
| 25 | Client disconnects during transport then reconnects within grace | Same provisional custody resumes once in the same server session | PASS |
| 26 | Client reconnects after grace expires | No provisional ownership resumes | PASS |
| 27 | Player joins different server while provisional state existed elsewhere | Provisional creature does not become cross-server owned state | PASS |
| 28 | Orderly server-originated shutdown occurs with valid provisional custody | Protected Shutdown Finalization secures the same provisional creature exactly once while authoritative custody state is available | PASS |
| 29 | Player simulates disconnect hoping for shutdown protection | Ordinary disconnect path does not invoke shutdown exception | PASS |
| 30 | Shutdown occurs after normal extraction already finalized | No duplicate creature/finalization | PASS |
| 31 | Capacity is full before attempt begins | Ordinary initiation blocked with clear capacity reason | PASS |
| 32 | Capacity available at attempt start but fills before extraction | Finalization succeeds into GDS-4 Overflow-Held | PASS |
| 33 | Player has unresolved Overflow-Held creature | New ordinary capture initiation blocked | PASS |
| 34 | Capacity entitlement expires while transporting | Completed extraction remains safe via Overflow-Held if necessary | PASS |
| 35 | New player starts with zero usable capacity due config error | Violates GDS-4/GDS-5 onboarding contract; must be prevented | PASS |
| 36 | New player sees tutorial creature consumed by veteran | Onboarding-Protected Opportunity prevents denial/replenishes | PASS |
| 37 | New player skips hint text | Does not fabricate Capture Success or ownership | PASS |
| 38 | New player performs first capture on touch | Full capture/extraction path remains practical | PASS |
| 39 | New player performs first capture on controller | No pointer-only requirement | PASS |
| 40 | Desktop player uses faster aim/look | No exclusive progression capability is granted | PASS |
| 41 | Capture prompt is stale and creature becomes claimed before activation | Revalidation rejects stale initiation cleanly | PASS |
| 42 | Player opens modal while capture context is visible | Modal focus prevents accidental attempt activation | PASS |
| 43 | Player closes modal with same input near creature | Input spillover does not start consequential capture | PASS |
| 44 | Two players race to same Secure Point with different provisional creatures | Each may finalize only their own valid custody | PASS |
| 45 | Two players somehow receive stale visuals for same creature | Authoritative single claim/finalization prevents dual ownership | PASS |
| 46 | Observer stands on carrier/provisional creature | Proximity does not transfer custody | PASS |
| 47 | Other player body-blocks transporter | GDS-10 must preserve operability; no ownership transfer occurs | PASS |
| 48 | Player dies to world hazard during transport | Recovery does not secure; interruption path applies | PASS |
| 49 | Player intentionally uses reset to shorten return route | Reset cannot produce extraction benefit | PASS |
| 50 | Player server-hops after failed capture | No refund/duplicate of finalized attempt cost or same finite claim | PASS |
| 51 | Capture includes chance and player performs valid input | Result is clearly communicated as capture outcome rather than ignored input | PASS |
| 52 | Rare/mutated creature is provisionally captured | Instance properties remain attached through transport/finalization | PASS |
| 53 | Event encounter is explicitly multi-award | GDS-11 must define override; ordinary single-award rule is not silently applied | PASS |
| 54 | Party member assumes shared claim | Friendship/party alone does not share ownership or claim | PASS |
| 55 | Capture cost request is delivered twice | Cost and accepted attempt apply once | PASS |
| 56 | Attempt becomes invalid after cost check but before acceptance | No finalized cost is consumed for invalid initiation | PASS |
| 57 | Creature expiry timer reaches zero during active attempt | Explicit finish/interruption rule is required; silent vanish prohibited | PASS |
| 58 | Provisional carrier waits AFK indefinitely | Transport itself gives no ownership; downstream/world may impose bounded encounter/custody rules only if explicit | PASS |
| 59 | Secure Point interaction fails validation | No finalization; player receives understandable rejection | PASS |
| 60 | Finalization acknowledgement packet is lost after server committed | Retry resolves to same one secured instance, not zero or two | PASS |

## Cross-Cutting Results

### Ownership integrity
All ordinary scenarios maintain a single unambiguous path from unsecured opportunity to one secured instance.

### Contest fairness
The ordinary social competition occurs before successful provisional capture. Active attempts and transport custody cannot be casually overwritten by later proximity/input.

### Lifecycle consistency
Reset/Recovery and voluntary leave never count as extraction. Unexpected disconnect deterministically enters bounded same-session Transport Grace. An orderly authoritative server-originated shutdown finalizes valid provisional custody exactly once when the state remains verifiable; abrupt unverifiable process failure cannot promise that exception.

### Capacity safety
Known full capacity blocks normal capture initiation, while late capacity races cannot destroy a completed acquisition because GDS-4 Overflow-Held absorbs the integrity case.

### Onboarding
The first capture remains a real capture/extraction loop while its opportunity is protected against unrelated-player denial.

### Device/accessibility
No tested scenario requires platform-exclusive precision, chat negotiation, color-only state, or high-frequency tapping.

## Verdict

**60 / 60 scenarios: PASS.**

No GDS-5-blocking scenario contradiction remains.