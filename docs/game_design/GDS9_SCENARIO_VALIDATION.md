# GDS-9 Scenario Validation

> **Phase:** GDS-9 — World, Biomes, Exploration, Spawning, and Hazards  
> **Status:** PASS  
> **Purpose:** Compound validation of world topology, access progression, Region Mastery, exploration, Secure Point routing, fast travel, habitats, spawn contexts, encounter density/lifetime, variant stability, world cycle, hazards, lifecycle, rewards, expansion, and downstream authority.

## Validation Method

Each scenario is evaluated against the closed GDS-1 through GDS-8 contracts plus `world/09_world_biomes_exploration_spawning_and_hazards.md`.

A scenario passes only if:

- locked world access cannot be bypassed through lifecycle or travel mechanics;
- mandatory progression cannot depend on extreme RNG, paid access, or passive Energy alone;
- GDS-5 claim/capture/transport/extraction semantics remain authoritative;
- a surviving Creature Instance never rerolls Species/Mutation/Trait identity;
- GDS-6 scarcity/value integrity and no hidden spending-based odds remain intact;
- hazards never destroy finalized ownership or persistent progression;
- world rewards are bounded, active, and exact-once;
- session-local encounter state remains distinct from persistent player progress;
- later subsystem authority is not claimed prematurely.

## Scenarios

| # | Scenario | Expected Result | Result |
|---:|---|---|---|
| 1 | New player completes Persistence Ready and Safe Arrival | Player enters the Home Hub and receives the protected Starter path | PASS |
| 2 | New player has zero Energy | Starter Biome remains available; no purchase is required | PASS |
| 3 | Player has abundant Energy but no Starter Region Mastery | Both Mid Biome gates remain locked | PASS |
| 4 | Player has Starter Region Mastery but insufficient Energy | Mid Access Purchase does not finalize | PASS |
| 5 | Player has Starter Region Mastery and enough Energy | Player may buy either Mid Biome Access Unlock exactly once | PASS |
| 6 | Player buys Mid Biome A first | Mid Biome B remains independently available at its defined cost | PASS |
| 7 | Player buys Mid Biome B first | Mid Biome A remains independently available at its defined cost | PASS |
| 8 | Player owns both Mid unlocks but has only one Mid Region Mastery | Advanced Biome remains locked | PASS |
| 9 | Player has both Mid Masteries and enough Energy | Advanced Access Unlock may finalize exactly once | PASS |
| 10 | Advanced access requirement proposes a Legendary capture | Invalid; mandatory progression cannot require extreme rare RNG | PASS |
| 11 | Advanced access requirement proposes an Extreme Mutation | Invalid; mandatory progression cannot require Extreme Mutation | PASS |
| 12 | Advanced access requirement proposes Event-Limited content | Invalid baseline progression gate | PASS |
| 13 | Region gate proposes a paid product as mandatory prerequisite | Invalid; non-premium world progression path is required | PASS |
| 14 | Player changes server after buying region access | Finalized Access Unlock persists | PASS |
| 15 | Region access Energy price changes after purchase | Existing entitlement remains owned | PASS |
| 16 | Player buys access to a Biome | No Landmark, Species, Mutation, Variant or Region Mastery history is fabricated | PASS |
| 17 | Player tries to enter a locked region through ordinary travel | Access is denied | PASS |
| 18 | Player tries to select a Recovery Anchor inside a locked region | Invalid anchor; Recovery chooses a valid unlocked location | PASS |
| 19 | Geometry exploit places player beyond a locked gate | Normal gameplay entitlement remains invalid; access cannot be legitimized by position alone | PASS |
| 20 | Player owns access but has never physically explored the Biome | Region Mastery remains incomplete | PASS |
| 21 | Player reaches all required authored Landmarks | Route Survey category may finalize | PASS |
| 22 | Player buys region access without visiting Landmarks | Route Survey does not finalize | PASS |
| 23 | Player secures the required distinct Core Species threshold | Regional Collection category may finalize | PASS |
| 24 | Player owns duplicate copies of one Core Species only | Duplicates do not satisfy distinct-Species threshold by themselves | PASS |
| 25 | Mastery threshold is set to full pool including rare/extreme content | Invalid tuning; threshold must remain below full/rare-RNG completion | PASS |
| 26 | Player completes an authored active Field Objective | Field Objective category may finalize | PASS |
| 27 | Player waits AFK inside objective area | No active objective completion or Energy merely from presence | PASS |
| 28 | Player satisfies Route Survey + Regional Collection but no Field Objective | Region Mastery remains incomplete | PASS |
| 29 | Player satisfies all three Mastery categories | Region Mastery finalizes persistently | PASS |
| 30 | New Species is added to a Biome after the player mastered it | Existing Region Mastery remains valid | PASS |
| 31 | Player enters an undiscovered eligible Landmark | Landmark Discovery finalizes once | PASS |
| 32 | Player repeatedly crosses the same Landmark boundary | No duplicate first-discovery outcome or reward | PASS |
| 33 | Player changes server and revisits a discovered Landmark | Discovery remains recorded; no duplicate first reward | PASS |
| 34 | Player sees a Landmark on a map but never reaches it | No Route Survey credit merely from UI visibility | PASS |
| 35 | Player completes a first-time world objective with Energy reward | Reward enters Energy Wallet exactly once | PASS |
| 36 | Objective reward response is lost and client retries | Same finalized reward reconciles; no duplicate Energy | PASS |
| 37 | Player repeatedly toggles a world interaction trigger | No reward without a new valid objective instance | PASS |
| 38 | A repeatable objective creates a genuinely new instance | Bounded reward may be earned by meaningful completion | PASS |
| 39 | World objective rewards dominate all recurring income | Violates GDS-8 active/passive relevance; retune required | PASS |
| 40 | Player claims normal Vault production while exploring | Normal passive production and separate valid active rewards may coexist | PASS |
| 41 | New player reaches the Home Hub | Primary Secure Point, Vault Access Point and Recovery Anchor are available after trusted load | PASS |
| 42 | Player enters a field Biome | Entry Safe Outpost provides a Secure Point and Recovery Anchor | PASS |
| 43 | Hazard volume overlaps immediate Safe Outpost arrival | Invalid baseline placement; protected arrival radius must remain safe | PASS |
| 44 | Player completes Capture Success deep in a Biome | The same Provisional Capture must still travel to an eligible Secure Point | PASS |
| 45 | Player walks through a normal fast-travel node while carrying a Provisional Capture | Fast travel is blocked; no extraction occurs | PASS |
| 46 | Player has an active Engagement Claim and attempts fast travel | Fast travel is blocked | PASS |
| 47 | Player is inside a Capture Attempt and attempts fast travel | Fast travel is blocked | PASS |
| 48 | Player has no Acquisition-In-Progress and uses an unlocked discovered travel node | Ordinary fast travel is allowed | PASS |
| 49 | Player reaches a field entry outpost for the first time | Its travel node may become available for future ordinary travel | PASS |
| 50 | Player tries to fast travel to an undiscovered/locked outpost | Travel is denied | PASS |
| 51 | Player opens a field Vault terminal with already Secured Creatures | Valid Vault management may occur under GDS-7 | PASS |
| 52 | Player brings a Provisional Capture to a Vault terminal that is not a Secure Point | No ownership finalization occurs | PASS |
| 53 | Player reaches an eligible Secure Point with valid Transport Custody | GDS-5 Extraction Completion may finalize ownership exactly once | PASS |
| 54 | Player respawns beside a Secure Point after failing during transport | Respawn/Safe Arrival does not auto-secure lost provisional value | PASS |
| 55 | Player uses Recovery after falling during transport | GDS-5 interruption semantics apply; Recovery is not extraction | PASS |
| 56 | New player follows onboarding extraction route | Route is understandable and does not require opaque high-severity hazard survival | PASS |
| 57 | A new Biome has only one linear corridor | Fails baseline exploration-choice requirement; add route/habitat choice | PASS |
| 58 | A field Biome has two materially distinct Habitats | Valid baseline structure | PASS |
| 59 | Two Habitats differ only in cosmetic color but have identical routes/pools/hazards | Insufficient material distinction for the authored baseline | PASS |
| 60 | Starter Biome includes an onboarding-adjacent Habitat and broader field Habitat | Valid | PASS |
| 61 | Spawn Context evaluates Biome + Habitat + World Cycle | Valid prospective encounter eligibility input | PASS |
| 62 | A Species Rarity label is treated as one universal exact spawn percentage | Invalid; concrete weights remain context-authored | PASS |
| 63 | A Common Species has low weight in one specialized Habitat | Valid; rarity label does not prescribe universal weight | PASS |
| 64 | A Rare Species is ineligible in a particular Habitat | Valid authored Spawn Context | PASS |
| 65 | Spawn logic uses Energy Wallet balance to improve rare Species odds | Prohibited | PASS |
| 66 | Spawn logic uses Robux spending history to improve Mutation odds | Prohibited | PASS |
| 67 | Spawn logic uses inferred purchase reluctance to grant pity variants | Prohibited hidden personalization | PASS |
| 68 | World Cycle phase changes before a new instance is generated | New Spawn Context may use the new phase | PASS |
| 69 | World Cycle changes while a creature already exists | Existing Species/Mutation/Trait identity remains unchanged | PASS |
| 70 | Event system later proposes a temporary probability modifier | Deferred to GDS-11 and prospective-only for new instances | PASS |
| 71 | New World Creature is generated | Mutation/Trait identity is fixed no later than becoming individually actionable | PASS |
| 72 | Player claims then cancels/fails against a surviving creature | Same surviving instance retains exactly the same identity | PASS |
| 73 | Player disconnects/reconnects during the same surviving claim context where allowed | No Variant reroll is created by retry/reconnect | PASS |
| 74 | Creature genuinely expires and later another creature fills the population slot | New Creature Instance may generate independently | PASS |
| 75 | A protected onboarding opportunity is consumed by another public player | Invalid; onboarding path must remain functionally available to learner | PASS |
| 76 | Normal field player actively searches ordinary route | Tuning should normally surface a viable ordinary opportunity in roughly 20–45 seconds | PASS |
| 77 | Player expects a Legendary every 10-minute session | No such guarantee; scarcity remains meaningful | PASS |
| 78 | Busy server raises encounter population within authored bound | Allowed; total opportunities may scale without individualized odds | PASS |
| 79 | Encounter population grows without any upper bound | Invalid; bounded Encounter Population Budget required | PASS |
| 80 | Shared server becomes crowded around Starter public spawns | Protected onboarding opportunity remains separately reliable | PASS |
| 81 | Unclaimed ordinary creature reaches its Encounter Lifetime | It may expire and release population capacity | PASS |
| 82 | Encounter Lifetime elapses during a valid Engagement Claim | Idle expiry does not despawn active acquisition; GDS-5 owns resolution | PASS |
| 83 | Lifetime elapses during Capture Attempt | Active attempt is not invalidated merely for idle population refresh | PASS |
| 84 | Lifetime elapses during Provisional Capture/Transport Custody | GDS-5 transport state remains authoritative | PASS |
| 85 | Capture Failure releases a still-valid creature | Same Creature Instance and Variant Identity remain | PASS |
| 86 | Protected Variant becomes actionable and instantly despawns after one second | Invalid; requires a non-trivial stability window | PASS |
| 87 | Protected Variant remains idle for its authored stability period | Valid; it may later expire if still unclaimed | PASS |
| 88 | Mutation has a visible collectible identity | Actionable world creature presents consistent identity before/through capture | PASS |
| 89 | High-value cue relies only on color | Insufficient downstream presentation obligation; GDS-14 must provide non-color support | PASS |
| 90 | Naturally rare creature appears | Nearby visibility is allowed; server-wide announcement is not implied | PASS |
| 91 | Player server-hops to try to restart Day phase | World Cycle must not intentionally restart privately for that player | PASS |
| 92 | Hazard knocks player into avatar failure with no acquisition active | Recovery occurs; Secured Creatures/Energy/unlocks remain intact | PASS |
| 93 | Hazard interrupts a Provisional Capture | GDS-5 interruption semantics apply; hazard does not invent ownership | PASS |
| 94 | Hazard failure automatically deducts Energy | Invalid baseline; no arbitrary Energy penalty/debt | PASS |
| 95 | Only route through an unlocked Biome requires a premium movement product | Invalid; at least one non-premium Safe Route required | PASS |
| 96 | Deep Habitat offers a riskier optional shortcut | Allowed if baseline Safe Route/region participation remains viable | PASS |
| 97 | Server shuts down while unclaimed Legendary is visible | No ownership grant merely because player saw it | PASS |
| 98 | Server shuts down with a valid Provisional Capture | Only the narrow GDS-5 Protected Shutdown Finalization rule may secure it | PASS |
| 99 | Public encounter disappears when Server Session ends | Valid session-scoped world state; no persistent encounter entitlement | PASS |
| 100 | GDS-9 implementation proposal introduces party rewards, rifts, trading or paid skips | Those mechanics remain blocked/deferred to GDS-10/11/12/13 authority | PASS |

## Cross-Cutting Results

### World progression integrity
The compact branching topology creates one safe onboarding path, two parallel mid-game choices and one advanced convergence gate. Access remains persistent and combines active proof with Energy without rare-RNG or paid requirements.

### Exploration integrity
Landmarks, Regional Collection and Field Objectives produce meaningful active Region Mastery rather than menu-only or passive completion.

### Capture/transport integrity
Safe Outposts and Secure Points provide reliable extraction infrastructure while fast travel remains disabled during Acquisition-In-Progress, preserving `Bring it home`.

### Spawn/variant integrity
Habitat/World Cycle context affects only genuinely new instances. A surviving World Creature never rerolls because of claim cycling, retry, travel, spending, or time-of-day changes.

### Scarcity/readability integrity
Ordinary encounters remain findable while rare outcomes are not promised each session. Protected Variants receive a meaningful stability window and readable significance without server-wide event semantics.

### Hazard/value integrity
Environmental risk may cause temporary Recovery but never deletes finalized ownership, Energy, unlocks, discoveries or Vault progression.

### Lifecycle integrity
Encounter populations remain session-scoped; Access Unlocks, Landmark Discovery, Region Mastery and exact-once rewards remain persistent Finalized Outcomes.

### Downstream compatibility
Social collision/co-op/PvP, events, trading, monetization, final presentation, platform compliance, analytics infrastructure and technical implementation remain delegated to their owning phases.

## Verdict

**100 / 100 scenarios: PASS.**

No GDS-9-blocking scenario contradiction remains.
