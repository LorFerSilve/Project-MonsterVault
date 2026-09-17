# GDS-6 Scenario Validation

> **Phase:** GDS-6 — Rarity, Mutations, Traits, and Variant Value  
> **Status:** PASS  
> **Purpose:** Compound validation of rarity, instance variation, generation stability, discovery, capture integration, high-value protection, live-content, economy/trading boundaries, and probability fairness.

## Validation Method

Each scenario is tested against the closed GDS-1 through GDS-5 contracts plus `rarity_mutations/06_rarity_mutations_traits_and_variant_value.md`.

A scenario passes only if:

- the same Creature Instance keeps stable variant identity;
- Species Rarity remains distinct from Mutation, Trait, Availability, power, and market price;
- GDS-4 ownership/discovery/protection semantics remain coherent;
- GDS-5 claim/capture/transport/finalization semantics remain unchanged;
- probability changes act prospectively rather than rerolling committed instances;
- collectible scarcity cannot be covertly manipulated by spending history;
- downstream authority is not silently stolen.

## Scenarios

| # | Scenario | Expected Result | Result |
|---:|---|---|---|
| 1 | Common Species spawns with no Mutation | Standard Variant; valid collectible, no implication of low gameplay usefulness | PASS |
| 2 | Legendary Species spawns with no Mutation | Legendary Species Rarity; Standard Variant; rarity does not fabricate Mutation | PASS |
| 3 | Common Species spawns with Extreme Mutation | Common Species Rarity + Extreme Mutation remain separate axes | PASS |
| 4 | Event-Limited Common Species appears | Event-Limited availability does not turn Species Rarity into Legendary | PASS |
| 5 | Core Legendary Species appears | Core availability does not lower Legendary Species Rarity | PASS |
| 6 | Creature becomes actionable Capture Opportunity | Variant Identity is finalized no later than this point | PASS |
| 7 | Player inspects actionable creature then waits | Variant identity does not change while same instance survives | PASS |
| 8 | Player claims creature then cancels | Same surviving instance keeps same Mutations/Traits | PASS |
| 9 | Player fails capture then retries same creature | Same instance keeps same Mutations/Traits | PASS |
| 10 | Claim passes to another player after release | New claimant sees same finalized instance identity | PASS |
| 11 | Capture Success creates Provisional Capture | Same variant identity enters provisional transport | PASS |
| 12 | Player reconnects within Transport Grace | Same Provisional Capture and same variant identity resume | PASS |
| 13 | Extraction request retries | One same secured instance; no alternate reroll | PASS |
| 14 | Server shutdown protected finalization occurs | Same provisional variant finalizes exactly once | PASS |
| 15 | Encounter ends and a genuinely new instance later spawns | New instance may roll different Mutations/Traits | PASS |
| 16 | Player server-hops to find another encounter | New server opportunities may differ; prior instance is not rerolled | PASS |
| 17 | Instance has zero Mutations | Classified Standard Variant | PASS |
| 18 | Instance has one Mutation | Classified Single-Mutated Variant | PASS |
| 19 | Instance has two compatible Mutations | Classified Compound-Mutated Variant | PASS |
| 20 | Generation attempts third baseline Mutation | Rejected by GDS-6 baseline maximum-two contract | PASS |
| 21 | Mutation pair A+B is generated | Signature canonicalizes set independent of order | PASS |
| 22 | Same pair B+A is encountered | Same Variant Signature as A+B | PASS |
| 23 | Two incompatible Mutations are selected | Content compatibility rule prevents invalid Compound generation | PASS |
| 24 | Compatibility table later removes an old legal pair | Existing legitimate owned pair keeps historical identity | PASS |
| 25 | Mutation is distinguished only by color in world | Final detail/collection presentation must add non-color cue | PASS |
| 26 | Mutation provides only a visual difference | Valid; Mutation need not provide stat power | PASS |
| 27 | Mutation has downstream gameplay hook | Hook requires explicit bounded downstream authority; identity remains GDS-6 | PASS |
| 28 | Extreme Mutation is visually subtle | Collection/detail presentation must still make identity legible | PASS |
| 29 | Compound Variant combines two individually common Mutations | Compound status remains distinct and ordinarily scarcer than components alone | PASS |
| 30 | Mutation Frequency is marked Rare in one event context | Exact percentage may differ from other contexts without changing semantic band rules | PASS |
| 31 | Extreme outcome becomes more common than Frequent in same context with no modifier | Violates frequency ordering; configuration must be corrected | PASS |
| 32 | Event explicitly boosts one Rare Mutation | Prospective generation may use visible event modifier | PASS |
| 33 | Event boost begins after creature already became actionable | Existing instance is not rerolled; boost affects future instances | PASS |
| 34 | Event boost ends while player transports variant | Provisional variant keeps finalized identity | PASS |
| 35 | Player buys something after instance spawned | Purchase cannot reroll currently actionable finite instance | PASS |
| 36 | System wants to improve odds for high spender secretly | Prohibited individualized spending-based probability manipulation | PASS |
| 37 | System wants loss-chasing odds after repeated misses | Prohibited if secretly individualized from inferred willingness/spending behavior | PASS |
| 38 | A/B test changes mutation odds prospectively | Allowed only with governed experiment context and auditable scarcity impact | PASS |
| 39 | Two players in same contest have one already-fixed creature | Experiment cannot give each player a different identity for that same instance | PASS |
| 40 | Trait differs between two otherwise same Variant Signatures | Both remain same baseline Variant Signature but different instances/Traits | PASS |
| 41 | Trait affects later production preference | GDS-7 may define bounded effect; GDS-6 identity persists | PASS |
| 42 | Trait is universally best across all systems | Violates situational/non-mandatory-supremacy principle; downstream rebalance required | PASS |
| 43 | Trait changes ownership on capture | Prohibited; Trait cannot override GDS-4/GDS-5 | PASS |
| 44 | Trait is hidden but affects irreversible attempt decision | Relevant effect must be discoverable before consequential decision | PASS |
| 45 | Flavor-only Trait reveals after securisation | Allowed because it did not distort prior consequential decision | PASS |
| 46 | Future system proposes Trait reroll | Requires explicit new owning design/change control; not baseline | PASS |
| 47 | Player merely sees another player's mutation | No Mutation/Variant Discovery granted | PASS |
| 48 | Player secures first creature with Mutation X | Mutation Discovery X is recorded persistently | PASS |
| 49 | Player secures Species A + Mutation X | Exact Variant Signature Discovery is recorded | PASS |
| 50 | Player owns A+X and A+Y separately | Does not count as discovery of Compound A+X+Y | PASS |
| 51 | Player secures A+X+Y Compound | Compound Variant Signature Discovery records independently | PASS |
| 52 | Player releases last A+X instance | Historical Variant Discovery remains | PASS |
| 53 | Player trades away last future A+X instance | Historical discovery remains for original discoverer | PASS |
| 54 | Trait permutation differs | Baseline collection completion does not demand every Trait permutation | PASS |
| 55 | Variant becomes Legacy later | Owned instance/discovery remains; currently obtainable completion must remain legible | PASS |
| 56 | Legendary Species finalizes | Protected Variant auto-locks on first securisation | PASS |
| 57 | Common Species with Extreme Mutation finalizes | Protected Variant auto-locks despite Common Species Rarity | PASS |
| 58 | Any Compound-Mutated Variant finalizes | Protected Variant auto-locks | PASS |
| 59 | Ordinary Common Standard Variant finalizes | No mandatory auto-lock; player can still manually lock | PASS |
| 60 | Bulk Release targets locked Compound Variant | Creature Lock blocks destructive action | PASS |
| 61 | Future trade targets locked Extreme variant | Lock must block transfer until explicit unlock | PASS |
| 62 | Legendary label is used as guaranteed high sale price | Invalid; rarity is not a guaranteed currency/market price | PASS |
| 63 | Rare mutation is advertised as always stronger | Invalid unless a bounded downstream effect actually exists; scarcity alone does not imply power | PASS |
| 64 | Provenance makes ordinary mutation historically desirable | Status may increase without changing rarity/mutation identity | PASS |
| 65 | Species Rarity tier is changed in a content patch | Requires explicit consistent change control; not per-player relabeling | PASS |
| 66 | Mutation generation rate is changed in patch | Future rates may change; existing instances keep Mutation identity | PASS |
| 67 | Trait effect is nerfed for balance | Same Creature Instance/Traits remain; effect can change under downstream balance authority | PASS |
| 68 | Bug produced a legitimate persisted unusual variant | Integrity remediation must avoid silent deletion where safely possible | PASS |
| 69 | Premium system fabricates “Event-Limited provenance” | Prohibited; purchase cannot falsify acquisition history | PASS |
| 70 | Player completes capture on mobile/controller/desktop | Rarity/variant status does not alter required input capability parity | PASS |

## Cross-Cutting Results

### Identity integrity
Variant Identity Finalization occurs before actionable player commitment and remains stable through claim, capture, transport, reconnect, finalization, storage, and future transfer semantics.

### Scarcity integrity
Species Rarity, Mutation Frequency, Availability, Trait desirability, and market value are separate axes. No scenario requires converting them into one deceptive score.

### Completion integrity
Species Discovery, Mutation Discovery, and Variant Discovery remain historical. Trait permutations do not create unbounded mandatory completion combinatorics.

### High-value protection
Legendary Species, Extreme Mutation, Compound Variant, and explicit event/legacy protection markers automatically receive Creature Lock at securisation.

### Probability fairness
Prospective tuning is allowed; post-commit rerolls and hidden individualized spending-based odds are not.

### Downstream compatibility
All tested economy, vault, world, event, trading, monetization, presentation, safety, analytics, and architecture concerns remain explicitly delegated rather than silently finalized.

## Verdict

**70 / 70 scenarios: PASS.**

No GDS-6-blocking scenario contradiction remains.
