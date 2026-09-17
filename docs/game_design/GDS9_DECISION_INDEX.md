# GDS-9 Decision Index

> **Phase:** GDS-9 — World, Biomes, Exploration, Spawning, and Hazards  
> **Status:** Accepted  
> **Purpose:** Phase-local record of strategic GDS-9 decisions and rationale. Detailed behavior remains authoritative in `world/09_world_biomes_exploration_spawning_and_hazards.md`.

## GDS9-D01 — Launch World Uses a Compact Branching Progression Graph

**Status:** Accepted

### Context

MonsterVault needs enough geographic progression to create discovery, route choice and collection expansion without building a huge open world before the core loop is proven.

### Decision

The launch-baseline structural topology is:

```text
Home Hub
   |
Starter Biome
  /          \
Mid Biome A   Mid Biome B
  \          /
   Advanced Biome
```

The Starter path is free. The two Mid Biomes are independent parallel Access Unlocks after Starter Region Mastery. Advanced access requires active Mastery of both Mid branches plus its own Energy Access Unlock.

Display names, visual themes and exact geometry remain tuneable content.

### Rationale

The graph preserves fast onboarding, creates a meaningful mid-game choice, supports parallel collection goals and provides an advanced convergence point without requiring a large linear world.

### Alternatives Rejected

- one giant seamless open world with no progression structure;
- one strictly linear sequence of every Biome;
- many launch Biomes before the core experience is validated;
- paid-only region branches.

### Affected Specifications

GDS-8 through GDS-16, Technical Architecture.

---

## GDS9-D02 — Region Mastery Requires Exploration, Collection, and Active Objective Play

**Status:** Accepted

### Context

GDS-8 requires active Progression Milestones so passive Energy cannot complete the full progression ladder. A world gate based only on currency or one lucky capture would weaken that rule.

### Decision

Baseline **Region Mastery** requires all three categories:

1. Route Survey through authored Landmark discovery;
2. Regional Collection through a tuneable threshold of distinct Core Species;
3. at least one completed active Field Objective.

Mandatory mastery cannot require Legendary Species, Extreme Mutations, Compound Variants, Event-Limited content, one specific low-probability rare spawn or a paid product. Thresholds remain below full-pool/extreme-RNG completion.

### Rationale

Mastery proves that the player actually explored and participated in the region while keeping progression deterministic enough to be fair.

### Alternatives Rejected

- Energy-only mastery;
- AFK/raw-presence mastery;
- full Pokédex-style region completion as a mandatory gate;
- mandatory Legendary/Extreme/Event-Limited capture;
- purchase-based mastery fabrication.

### Affected Specifications

GDS-8, GDS-9, GDS-11, GDS-13, GDS-16.

---

## GDS9-D03 — Safe Outposts and Secure Points Preserve the Bring-It-Home Loop

**Status:** Accepted

### Context

The product promise and GDS-5 make transport/extraction meaningful. World utility placement could accidentally erase that if every desirable spawn were adjacent to extraction or if any terminal automatically secured a creature.

### Decision

The Home Hub has primary Vault/Secure/Recovery infrastructure. Every field Biome has an entry **Safe Outpost** with an eligible Secure Point and Recovery Anchor. Deep encounter pockets remain spatially separated enough that ordinary captures require a meaningful return route.

A Vault Access Point does not secure a Provisional Capture unless it is separately an eligible Secure Point and GDS-5 Extraction Completion succeeds.

### Rationale

Players always have a predictable safe return destination, while `Bring it home` remains a real gameplay leg rather than a menu transition.

### Alternatives Rejected

- automatic ownership on leaving a Habitat;
- every fast-travel/Vault terminal acting as implicit extraction;
- Secure Points directly beside every high-value spawn pocket;
- no field extraction destination at all.

### Affected Specifications

GDS-3, GDS-5, GDS-7, GDS-9, GDS-10, GDS-14.

---

## GDS9-D04 — Fast Travel Is Discovery-Based Quality of Life, Never a Capture/Transport Bypass

**Status:** Accepted

### Context

A compact world still benefits from faster repeat navigation, but teleportation during a claim/capture/transport sequence would undermine GDS-5 and remove transport risk/distance.

### Decision

Field travel nodes become available after legitimate discovery of the relevant unlocked Safe Outpost. Ordinary travel is allowed between discovered/unlocked nodes only when the player has no **Acquisition-In-Progress**.

Fast travel is blocked during Engagement Claim, Capture Attempt, Provisional Capture and Transport Custody.

### Rationale

This reduces repetitive commuting for established routes without allowing players to teleport a finite encounter or Provisional Capture around the intended acquisition loop.

### Alternatives Rejected

- unrestricted teleport while carrying a Provisional Capture;
- travel to locked/undiscovered nodes;
- no travel quality-of-life at all;
- paid-only baseline fast travel.

### Affected Specifications

GDS-5, GDS-8, GDS-9, GDS-13, GDS-14, Technical Architecture.

---

## GDS9-D05 — Spawning Is Contextual, Bounded, and Prospective

**Status:** Accepted

### Context

The world needs biome/habitat/time variety without turning a surviving creature into a rerollable reward slot or coupling scarcity to hidden player monetization state.

### Decision

New World Creatures are generated under an authored **Spawn Context** that may include Biome, Habitat, ordinary World Cycle, static zone tags and authorized Availability. Encounter population is bounded by an authored population budget.

Spawn eligibility/probability applies only when creating a genuinely new Creature Instance. A surviving instance retains its Species/Mutation/Trait identity through claim release, failure/retry, cycle change, reconnect and transport/finalization processing.

Species Rarity does not prescribe one universal spawn percentage, and hidden spending/wallet state cannot modify spawn odds.

### Rationale

Contextual spawning provides content variety and scalable balancing while preserving GDS-6 scarcity/identity integrity and preventing reroll exploits.

### Alternatives Rejected

- rerolling the same creature after every failed attempt;
- post-claim Mutation generation;
- one hard-coded probability table derived only from rarity labels;
- unbounded spawn populations;
- hidden spender-specific encounter pools.

### Affected Specifications

GDS-5, GDS-6, GDS-9, GDS-11, GDS-13, GDS-16, Technical Architecture.

---

## GDS9-D06 — Rare Encounters Are Scarce but Must Be Real, Readable Opportunities

**Status:** Accepted

### Context

Long-term collection value requires rare outcomes not to be guaranteed every session. At the same time, a publicly actionable high-value creature that disappears almost instantly would feel deceptive and amplify latency/device inequity.

### Decision

Ordinary field density should make baseline opportunities reliably findable, but Legendary/Extreme/Compound outcomes are not guaranteed in a normal session.

Once a Protected Variant becomes publicly actionable, it receives an authored **Rare Encounter Stability Window** with a baseline target of at least several minutes when otherwise idle, plus enough stable world identity that its collectible significance can be perceived before/through capture. Final accessible presentation belongs to GDS-14.

### Rationale

Scarcity remains meaningful while rare discoveries still function as genuine pursuit opportunities rather than visual bait.

### Alternatives Rejected

- guaranteed Legendary per session;
- one-second rare-spawn pop-ins;
- revealing a different Mutation only after extraction;
- server-wide announcement semantics for every naturally rare creature.

### Affected Specifications

GDS-6, GDS-9, GDS-11, GDS-14, GDS-16.

---

## GDS9-D07 — Environmental Hazards Create Temporary Risk, Not Persistent-Value Destruction

**Status:** Accepted

### Context

Biomes need route/risk differences, but loss of secured creatures or currency from environmental failure would conflict with the non-loss-dominant product and closed ownership/economy contracts.

### Decision

Hazards may cause temporary traversal setbacks or avatar failure/Recovery. They may indirectly end Acquisition-In-Progress only through existing GDS-5 interruption rules.

Hazards cannot delete, Release, transfer or reroll Secured Creatures; deduct arbitrary Energy; revoke Access Unlocks; erase discovery/Mastery; or destroy finalized Vault progression. Every unlocked Biome retains at least one non-premium Safe Route, and the onboarding route cannot require opaque high-severity hazard survival.

### Rationale

The world gains meaningful environmental risk without turning permanent collection/economy value into an involuntary loss system.

### Alternatives Rejected

- creature deletion on hazard death;
- automatic Energy fines/debt from environmental failure;
- premium item required for the only viable route;
- invisible instant-failure hazards on mandatory onboarding paths.

### Affected Specifications

GDS-1 through GDS-5, GDS-8 through GDS-15.

---

## GDS9-D08 — Encounter State Is Session-Scoped; World Progression Is Persistent

**Status:** Accepted

### Context

Roblox server worlds are temporary, while player progression must survive ordinary server/session lifecycle. Treating public encounters as persistent player entitlements would create duplication/cross-server ambiguity.

### Decision

Ordinary World Creature populations, local encounter slots and idle lifetimes are **Session-Scoped State**. Access Unlocks, Landmark Discoveries, Region Mastery and finalized objective rewards are persistent Finalized Outcomes.

Changing servers does not carry a public World Creature with the player. Server shutdown does not grant ownership of visible unclaimed creatures. GDS-5's narrow Protected Shutdown Finalization remains the only baseline exception for an already-valid Provisional Capture.

### Rationale

This cleanly separates transient shared-world opportunities from durable earned progression and preserves exact ownership boundaries.

### Alternatives Rejected

- persisting every visible rare encounter to the player across servers;
- resetting persistent mastery per server;
- auto-granting all visible encounters on shutdown;
- storing public population as player-owned progress.

### Affected Specifications

GDS-2, GDS-5, GDS-9, GDS-11, Technical Architecture.

---

## GDS9-D09 — Content Expansion Is Additive and Does Not Rewrite Completed World History

**Status:** Accepted

### Context

A live collection game must add creatures, Biomes and balance changes without making earlier legitimate region completion unstable.

### Decision

New Biomes may extend/branch the world graph; new Species may enter existing Habitats; future spawn weights/densities/lifetimes may rebalance prospectively. These changes do not revoke existing Access Unlocks or Region Mastery, reroll current/owned creature identity, or rewrite historical provenance.

If later content needs a new completion tier, it must create a new explicit Milestone rather than silently changing the historical one.

### Rationale

Players can trust earned progress while live content remains expandable and balanceable.

### Alternatives Rejected

- revoking Mastery whenever a new Species is added;
- forcing players to repurchase old region access after expansion;
- rerolling owned variants because spawn tables changed;
- silently redefining old completion records.

### Affected Specifications

GDS-4, GDS-6, GDS-8, GDS-9, GDS-11, GDS-16.

---

## GDS9-D10 — Close GDS-9 World, Biomes, Exploration, Spawning, and Hazards Baseline

**Status:** Accepted

### Context

The authoritative GDS-9 specification resolves launch topology, region access/mastery, exploration, world utility placement, traversal, habitats, Spawn Context, population/lifetime, rare encounter behavior, World Cycle, hazards, lifecycle state, active rewards, expansion and downstream authority. Scenario and cross-system validation pass.

### Decision

GDS-9 is formally closed as `Complete — PASS`.

Material changes to the baseline world graph, Region Mastery categories, no-extreme-RNG/paid mandatory gate, Secure Point extraction placement semantics, fast-travel prohibition during Acquisition-In-Progress, prospective stable spawn identity, no hidden spending-based spawn odds, hazard persistent-value protection, onboarding availability, session-vs-persistent world boundary or historical Mastery/access preservation require GDS-9 change control and revalidation.

### Evidence

- `world/09_world_biomes_exploration_spawning_and_hazards.md` — Design Complete;
- `GDS9_SCENARIO_VALIDATION.md` — 100 / 100 PASS;
- `GDS9_CROSS_VALIDATION.md` — PASS;
- `GDS9_CLOSURE_REPORT.md` — PASS.

### Consequence

The active dependency advances to **GDS-10 — Social Play, Cooperation, Competition, and PvP Boundaries**. Technical Architecture and gameplay implementation remain blocked.
