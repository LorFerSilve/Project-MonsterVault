# World, Biomes, Exploration, Spawning, and Hazards

> **Status:** Design Complete  
> **Owning GDS phase:** GDS-9 — World, Biomes, Exploration, Spawning, and Hazards  
> **Authority:** Baseline world topology, biome/access progression, exploration structure, landmark/world milestones, creature encounter generation from the player's perspective, encounter lifetime/density, ordinary world-cycle context, hazard semantics, Secure Point/Vault Access Point/Recovery Anchor placement, field travel, active world Energy rewards, and content-expansion rules  
> **Depends on:** `../00_design_authority.md`, `../01_game_overview.md`, `../global_rules/02_global_game_rules_and_session_model.md`, `../player/03_player_character_interaction_and_onboarding.md`, `../creatures/04_creatures_collection_and_ownership.md`, `../capture/05_capture_contesting_transport_and_extraction.md`, `../rarity_mutations/06_rarity_mutations_traits_and_variant_value.md`, `../vault/07_vault_base_passive_production_capacity_and_upgrades.md`, `../economy_progression/08_economy_progression_unlocks_and_pacing.md`, `../GLOSSARY.md`

## 1. Purpose and Player Fantasy

MonsterVault's world must make the product promise physically meaningful:

> **Find it. Catch it. Bring it home. Make your vault legendary.**

The world is therefore not a decorative lobby around menus. It is the place where players actively discover creature opportunities, make route choices, see desirable encounters, complete capture/transport loops, earn active progression proof, and unlock broader hunting space.

The player-facing contract is:

> **I can leave a safe home base, choose a meaningful region, understand what is reachable and why, reliably find ordinary creatures, occasionally discover genuinely scarce opportunities, take readable environmental risks, bring captures back through a real route, and make persistent progress without server-hopping, hidden spending rules, or random hazards rewriting my collection.**

## 2. Scope

GDS-9 owns:

- launch-baseline world topology and progression order;
- Home Hub, field Biomes, safe entry/outpost semantics and route relationships;
- concrete use of GDS-8 Access Unlocks and active Progression Milestones for region progression;
- exploration loops, landmarks, Region Mastery and field objectives;
- ordinary traversal and fast-travel boundaries from the player's perspective;
- world placement rules for Secure Points, Vault Access Points and Recovery Anchors;
- habitat structure and creature spawn pools;
- spawn-context eligibility, population/density targets and encounter lifetime;
- interaction between spawning and GDS-6 Species Rarity / Mutation / Trait generation;
- rare/Protected Variant visibility and stability requirements;
- ordinary environmental hazards and special world-zone semantics;
- baseline world Energy rewards under GDS-8 source constraints;
- session-local world state versus persistent world progression;
- ordinary world-cycle context and server-hop consistency;
- scalability rules for adding later regions/creatures without changing closed contracts;
- downstream obligations for social play, events, trading, monetization, presentation, platform safety, analytics and Technical Architecture.

## 3. Explicit Non-Goals

GDS-9 does **not** define:

- player-party, cooperative reward, PvP, interception, body-blocking or grief rules — GDS-10;
- server-wide rare-rift/event cadence, rotating weather events, shared event encounters or event reward allocation — GDS-11;
- player-to-player trading — GDS-12;
- Robux products or paid traversal/access — GDS-13;
- final map UI, HUD, minimap, art, audio or accessibility presentation — GDS-14;
- Roblox moderation/compliance rules — GDS-15;
- daily/weekly retention cadence or experiment infrastructure — GDS-16;
- persistence stores, replication, streaming, spatial partitioning, RNG algorithms, server allocation, pathfinding or spawn-service implementation — Technical Architecture.

## 4. Canonical World Model

### 4.1 Home Hub

The **Home Hub** is the baseline safe world region containing:

- the primary Vault Access Point;
- a central Secure Point;
- a Recovery Anchor;
- region-travel access;
- onboarding-safe routing into the Starter Biome.

The Home Hub contains no baseline environmental hazard capable of triggering Recovery and is not a normal public creature-farming zone except for explicitly protected onboarding content.

### 4.2 Launch-baseline topology

The baseline world contains one Home Hub plus four progression Biomes:

```text
Home Hub
   |
Starter Biome
  /          \
Mid Biome A   Mid Biome B
  \          /
   Advanced Biome
```

Biome display names, visual themes and exact geometry are authored content and may change without reopening GDS-9 provided these structural roles remain intact.

The topology is intentionally compact rather than a single enormous open world. It supports short sessions, meaningful transport, parallel progression choices and future expansion.

### 4.3 Starter Biome

The Starter Biome is available after Persistence Ready / Safe Arrival and the required onboarding entry step. It provides:

- the protected first Capture Opportunity path;
- ordinary Common/Uncommon-heavy encounter density;
- the first Landmark Discovery and field objective opportunities;
- the first meaningful Region Mastery path;
- one safe field entry outpost containing a Secure Point and Recovery Anchor.

It does not require an Energy Access Purchase.

### 4.4 Mid Biomes A and B

The two Mid Biomes are parallel alternatives. Each requires:

- Starter Region Mastery; and
- its own visible GDS-8 Access Unlock Energy cost.

Purchasing one Mid Biome does not lock or increase the hidden price of the other. Players may choose the order.

Each Mid Biome must provide a materially distinct habitat/route identity and creature pool rather than functioning as a cosmetic recolor of the same progression space.

### 4.5 Advanced Biome

The Advanced Biome requires:

- persistent Region Mastery for Mid Biome A;
- persistent Region Mastery for Mid Biome B; and
- a visible GDS-8 Access Unlock Energy cost.

The requirement deliberately combines economic planning with active progression and cannot be completed by passive Energy alone.

The Advanced Biome may contain harder hazards, deeper habitats and scarcer creature contexts, but ordinary access must remain possible through a non-premium progression path.

## 5. Region Access and Persistence

### WA-01 — Region access is persistent

A finalized Access Unlock remains owned across death, reset, reconnect, server transition, device change and ordinary content price rebalance.

### WA-02 — Locked regions are not bypassed by ordinary travel

Players may not use ordinary fast travel, respawn selection, Recovery, geometry exploits or menu transitions to gain normal gameplay access to a locked region.

### WA-03 — Access does not fabricate completion

Unlocking a region does not grant its Landmark Discovery, Species Discovery, Mutation Discovery, Variant Discovery or Region Mastery.

### WA-04 — Access gates are legible before commitment

A player must be able to know the relevant prerequisite Milestones and Energy cost before confirming a persistent Access Unlock.

### WA-05 — Access cannot depend on rare RNG

Mandatory region progression may not require:

- a Legendary Species;
- an Extreme Mutation;
- a Compound Variant;
- Event-Limited content;
- a specific low-probability rare spawn;
- a paid product.

Scarce content can be aspirational, but baseline progression must not be hostage to extreme encounter variance.

## 6. Region Mastery

**Region Mastery** is a persistent Progression Milestone proving meaningful active engagement with one Biome.

A baseline Region Mastery requirement set includes all three categories:

1. **Route Survey** — reach the Biome's authored required Landmark set;
2. **Regional Collection** — legitimately secure a tuneable threshold of distinct Core Species from the Biome, below full-pool completion and excluding extreme RNG requirements;
3. **Field Objective Completion** — complete at least one authored active world objective belonging to that Biome.

Exact counts are tuneable content values. The semantic rule is that Mastery requires exploration + collection + active objective play and cannot be purchased, passively produced or granted merely by entering the region.

Mastery is historical once finalized. Later content additions to the Biome do not revoke existing Mastery.

## 7. Landmarks and Exploration

### EX-01 — Landmarks are authored exploration targets

A **Landmark** is a meaningful world location used for orientation, route discovery or progression. A Landmark is not created by random spawn state.

### EX-02 — Landmark Discovery is persistent and exact-once

The first legitimate discovery of an eligible Landmark records a persistent Landmark Discovery outcome. Re-entering the same Landmark does not duplicate a first-discovery reward.

### EX-03 — Exploration is movement through playable space, not menu completion

Required Route Survey milestones must be earned by the player reaching the relevant in-world area through a valid route. Buying access alone is insufficient.

### EX-04 — Ordinary exploration should expose choices

A Biome should offer at least one meaningful route fork, habitat choice, elevation/depth choice or risk/reward branch. Progression cannot be only a straight corridor from entrance to Secure Point.

### EX-05 — Core orientation does not require unrestricted chat

Understanding region access, landmarks, hazards and return routes must not depend on asking other players through chat.

## 8. Field Objectives and Active Energy

A **Field Objective** is a bounded active task tied to world interaction, exploration or collection rather than raw presence time.

Examples include:

- surveying an authored set of field points;
- completing a traversal route;
- interacting with a bounded sequence of world objects;
- legitimately securing a defined non-extreme creature category;
- clearing a non-combat environmental route challenge.

### FO-01 — Active objectives may grant Energy

GDS-9 authorizes bounded Energy rewards for valid Field Objective completion and eligible first-time Landmark/Region Mastery outcomes.

### FO-02 — Rewards are exact-once per objective instance

Retry, reconnect or duplicate event delivery cannot duplicate a finalized objective reward.

### FO-03 — Repeated mere presence is not a reward source

Standing in a region, crossing the same trigger repeatedly, fast-travel cycling or touching the same Landmark repeatedly does not mint Energy.

### FO-04 — Repeatable objectives require new objective instances

A repeatable world objective may grant Energy only when a new authored/generated objective instance exists and the player meaningfully completes it. Exact recurrence/cadence is downstream/tuneable and may not become a hidden AFK timer.

### FO-05 — World rewards do not replace Vault production

Field rewards should contribute to GDS-8's intended active income share without making passive Vault Production economically irrelevant.

## 9. Safe Outposts and World Utility Placement

A **Safe Outpost** is the protected entry/utility area of a field Biome.

Baseline placement rules:

- Home Hub: one primary Secure Point, primary Vault Access Point and Recovery Anchor;
- each field Biome: at least one entry Safe Outpost;
- each field entry Safe Outpost: one Secure Point and one Recovery Anchor;
- each field entry Safe Outpost may expose a Vault Access Point/field terminal for permitted Vault management after persistent state is ready;
- hazardous encounter pockets must not overlap the immediate protected radius of a Safe Outpost;
- additional utility points require explicit authored placement and may not accidentally trivialize transport distance.

## 10. Secure Point Rules

### SP-01 — Secure Points are explicit destinations

Ordinary Secured Ownership Finalization still belongs to GDS-5 and occurs at validated Extraction Completion. Merely crossing a Biome boundary, fast-travel node or Recovery Anchor does not secure a Provisional Capture.

### SP-02 — Every baseline field Biome has a reachable Secure Point

A player who completes a valid ordinary capture must have at least one route back to an eligible Secure Point using baseline non-premium traversal.

### SP-03 — Secure Points are separated from deep encounter pockets

The baseline field layout preserves a meaningful `capture -> transport -> return` leg. A Secure Point must not be placed directly beside every high-value spawn pocket solely to erase transport.

### SP-04 — Safe arrival is not extraction

Joining, respawning or Recovery at a co-located safe area never auto-secures an invalid or interrupted Provisional Capture. GDS-5 interruption rules remain authoritative.

## 11. Vault Access Point Rules

### VA-01 — Home Hub has canonical full Vault access

The Home Hub is always the baseline world location where the player can deliberately enter/manage their Vault after trusted persistence is ready.

### VA-02 — Field terminals do not bypass capture finalization

A field Vault Access Point may manage already Secured Creatures and valid Vault state, but it cannot convert a Provisional Capture into ownership unless it is separately an eligible Secure Point and GDS-5 Extraction Completion succeeds.

### VA-03 — Vault access is blocked during Protected Load Failure

World placement does not weaken GDS-2/GDS-7 persistence safety.

## 12. Recovery Anchor Rules

### RA-01 — Recovery Anchors are safe return locations

Recovery Anchors exist in the Home Hub and each field entry Safe Outpost. Additional anchors may be placed at durable safe checkpoints.

### RA-02 — Recovery does not grant extraction

Recovery to an anchor while Acquisition-In-Progress follows GDS-5 interruption semantics. The anchor is not an exploit path to preserve or secure provisional value.

### RA-03 — Anchors cannot place the player inside a hazard or locked region

A Recovery result must return the player to a currently valid, unlocked, navigable safe location.

## 13. Ordinary Traversal and Fast Travel

### TR-01 — Baseline locomotion remains sufficient

Every unlocked launch Biome has at least one **Safe Route** traversable with baseline GDS-3 locomotion. Optional shortcuts/deep habitats may use progression utility, but core region participation cannot require a premium traversal product.

### TR-02 — Travel nodes are discovery-gated quality of life

After legitimately reaching a field entry Safe Outpost, the player may unlock its ordinary travel node for future travel between the Home Hub and that unlocked outpost.

### TR-03 — Fast travel is unavailable during Acquisition-In-Progress

Ordinary fast travel cannot be used while the player has an active Engagement Claim, Capture Attempt, Provisional Capture or Transport Custody.

This prevents teleporting around the intended capture/transport loop.

### TR-04 — Fast travel does not reset world opportunities

Traveling away and back does not reroll a still-existing Creature Instance's Variant Identity, claim state or lifetime.

### TR-05 — Region transitions do not guarantee preserved session-local encounters

Moving to another server does not carry a World Creature or public encounter instance across servers. Only finalized persistent outcomes survive ordinary server transition.

## 14. Habitat Model

A **Habitat** is a sub-region inside a Biome with its own authored creature eligibility, terrain identity and encounter characteristics.

Each launch field Biome should contain at least two materially distinct Habitats, with the Starter Biome containing a simple readable onboarding-adjacent Habitat plus at least one broader ordinary field Habitat.

Habitats may differ by:

- eligible Species pool;
- relative spawn weights;
- local density target;
- traversal shape;
- hazard exposure;
- ordinary World Cycle eligibility;
- deep/edge placement.

A Habitat does not redefine Species Rarity or Mutation Frequency terminology.

## 15. Spawn Context

A **Spawn Context** is the authored eligibility context used to decide which new World Creature may be instantiated. It may include:

- Biome;
- Habitat;
- ordinary World Cycle phase;
- explicit static zone tags;
- content availability status already authorized by GDS-6;
- future event modifiers only when GDS-11 authorizes them.

### SC-01 — Spawn context acts before encounter creation

Spawn-context eligibility and any authorized prospective probability modifier apply when generating a genuinely new Creature Instance.

They cannot reroll an already surviving instance.

### SC-02 — Species Rarity is not a hard-coded spawn formula

Common/Uncommon/Rare/Epic/Legendary remain Species classifications. Concrete species weights are content-authored per eligible Spawn Context; the rarity label alone does not prescribe one universal percentage.

### SC-03 — Mutation generation remains GDS-6 compliant

Mutation/Trait generation may depend on the eligible context, but Variant Identity must be finalized no later than the specific creature becoming individually actionable as a Capture Opportunity.

### SC-04 — Spending state cannot modify hidden spawn odds

Robux history, Energy spending, inferred willingness to pay, recent purchase refusal, loss chasing or wallet balance cannot secretly change a player's chance to receive a rarer Species or Mutation context.

## 16. Encounter Population and Density

### PD-01 — Each active field Biome has a bounded encounter population

The world maintains a bounded **Encounter Population Budget** per relevant area. Population may scale within authored limits for server population/performance, but cannot become unbounded.

### PD-02 — Ordinary opportunities are reliably findable

Along the intended Starter/normal field routes, a player moving at ordinary exploration speed should normally encounter a viable ordinary Capture Opportunity within roughly **20–45 seconds** of active searching, excluding intentionally sparse deep/rare pockets.

This is a tuneable pacing target, not a guarantee that a specific Species appears.

### PD-03 — Rare encounters are not session guarantees

A normal 10–25 minute session is not guaranteed to contain a Legendary Species, Extreme Mutation or Compound Variant. Long-term scarcity remains meaningful.

### PD-04 — Population scaling does not multiply rare odds per player

Increasing encounter count to serve a busier server may increase total opportunities, but the game may not secretly create individualized premium/spending-biased rare pools.

### PD-05 — Onboarding opportunities are separately protected

The onboarding path may use personal/reserved/replenishing protected opportunity semantics from GDS-5 rather than relying on the shared public population budget.

## 17. Encounter Lifetime and Despawn

### EL-01 — World Creatures have bounded lifetimes

An unclaimed ordinary World Creature may expire after an authored Encounter Lifetime so the population can refresh.

### EL-02 — Existing active acquisition state is stable

A creature cannot despawn merely because its ordinary idle lifetime elapsed while a valid Engagement Claim, Capture Attempt, Provisional Capture or Transport Custody is active. GDS-5 state resolution owns that transition.

### EL-03 — Opportunity Release does not reroll the same instance

If a failed/cancelled claim releases the same surviving World Creature, its Species/Mutation/Trait identity remains unchanged until that instance genuinely ends.

### EL-04 — A new instance may roll independently

After a creature genuinely despawns/expires and a later population slot creates a different Creature Instance, the new instance receives independent content generation under the then-current valid context.

### EL-05 — Protected Variants receive stability

Once a Protected Variant becomes publicly discoverable/actionable, it receives a minimum authored **Rare Encounter Stability Window** materially longer than a trivial pop-in. The baseline target is at least several minutes of idle opportunity unless captured or invalidated by an exceptional authoritative world change.

Exact lifetime values are tuneable by context; a rare encounter must not disappear so quickly that ordinary latency, device performance or initial approach makes it effectively fake.

## 18. Rare Encounter Readability

### RR-01 — Collectible significance should be perceivable before irreversible commitment

When a Mutation has a visual identity, the actionable World Creature should present that identity consistently enough for a player to recognize desirability before or during claim/capture rather than revealing a different variant only after extraction.

### RR-02 — Protected Variant cues use more than one channel

Final GDS-14 presentation must not rely solely on color or audio. GDS-9 requires at least one persistent world-readable cue plus downstream accessible presentation for high-value variants.

### RR-03 — Local visibility is not a server-wide event

A naturally rare creature may be noticeable to nearby players. Server-wide announcements, rifts and special allocation rules belong to GDS-11.

### RR-04 — No post-claim rarity upgrade/downgrade

The same actionable creature cannot transform into a different rarity/Mutation outcome because the player succeeded, failed, spent Energy or retried.

## 19. Ordinary World Cycle

The baseline world may use a deterministic repeating **World Cycle** such as Day / Dusk / Night to support habitat variety.

### WC-01 — The cycle is not reset by server hopping

The player-facing phase relationship must be deterministic enough that joining another server does not intentionally restart a private favorable phase.

Technical synchronization belongs to Technical Architecture.

### WC-02 — Cycle eligibility affects future instances only

When the phase changes, existing World Creatures keep their finalized identity and active acquisition state. The new phase affects future Spawn Context eligibility.

### WC-03 — Ordinary cycle is not a live event

The baseline World Cycle is predictable ambient world context, not GDS-11 event authority. Temporary mutation storms, rifts, invasions and server-wide boosted windows remain GDS-11.

## 20. Hazard Model

A **Hazard** is an authored environmental condition that creates traversal/capture risk without becoming direct player-versus-player combat.

Baseline hazard categories may include:

- dangerous terrain/falls;
- timed environmental zones;
- moving environmental obstacles;
- exposure areas requiring route/timing choices;
- traversal-state invalidation zones.

### HZ-01 — Hazards do not destroy secured ownership

Hazards cannot delete, Release, transfer or reroll a Secured Creature, Energy Wallet, Access Unlock, historical discovery or finalized Vault progression.

### HZ-02 — Hazards may cause temporary avatar consequences

A severe hazard may trigger ordinary avatar failure/Recovery. If Acquisition-In-Progress exists, GDS-5 interruption behavior applies; the hazard does not invent a separate ownership rule.

### HZ-03 — Hazards are telegraphed

A player must have a reasonable perceptual/action opportunity before a major hazard consequence. Hidden instant-failure volumes on required routes are invalid baseline design.

### HZ-04 — Core routes remain non-premium viable

Every unlocked Biome has a Safe Route that does not require a paid item or unavailable event capability. Optional riskier shortcuts can exist.

### HZ-05 — Onboarding route is protected

The protected first capture/extraction path cannot require the learner to survive an opaque high-severity hazard.

### HZ-06 — Hazards do not charge arbitrary Energy penalties

Baseline environmental failure does not automatically deduct Energy or impose debt. Any explicit future cost mechanic requires GDS-8 change control.

## 21. Special Zone Classes

GDS-9 recognizes the following baseline world-zone semantics:

### Safe Zone

A world area intended for arrival, utility access and recovery. Major environmental hazards and ordinary public spawn competition are excluded.

### Field Zone

Normal exploration/capture space with ordinary public encounter population.

### Hazard Zone

A telegraphed sub-area whose traversal risk is materially above normal field space. It may contain distinct habitat opportunities but cannot be the only required route without a viable skill/progression path.

### Onboarding Reserve

A protected first-session area/opportunity context that prevents unrelated players from permanently denying the required first capture loop.

### Deep Habitat

An optional or progression-relevant interior area within an unlocked Biome with altered creature pool/density/hazard profile. Deep Habitat access cannot silently bypass the Biome's persistent Access Unlock.

Event Zones are not baseline GDS-9 semantics and belong to GDS-11.

## 22. Capture Capability in the World

### CCW-01 — Region access and capture capability are separate gates

A player may be allowed into a Biome before being able to efficiently engage every advanced encounter there.

### CCW-02 — Required capability must be knowable before claim

If an encounter category requires a minimum Capture Capability, that requirement must be visible before the player commits to an irreversible spend or valid Capture Attempt.

### CCW-03 — Core progression cannot depend on unavailable rare capability walls

Region Mastery requirements must be satisfiable with a reasonable non-premium capability path and cannot require only the hardest optional encounters.

### CCW-04 — Starting capability supports onboarding

The Starter protected opportunity remains compatible with starting Capture Capability.

## 23. Session-Scoped vs Persistent World State

### WS-01 — Encounter populations are session-scoped

Ordinary public World Creature instances, idle lifetimes and local encounter slots belong to the current Server Session unless their owning acquisition flow has already finalized persistent value.

### WS-02 — World progression is persistent

Access Unlocks, Landmark Discoveries, Region Mastery and finalized world-objective rewards are Persistent Player State / Finalized Outcomes.

### WS-03 — Server shutdown does not invent world ownership

Public unclaimed encounters may disappear with the session. Existing valid Provisional Capture shutdown protection remains exactly the narrow GDS-5 rule; GDS-9 does not auto-secure all visible rare encounters.

### WS-04 — Server hopping cannot carry public encounters

A player cannot follow the same World Creature across servers. A new server's session-local population is distinct.

### WS-05 — Persistent milestones do not reset per server

Landmark/Region Mastery cannot be repeatedly re-earned for first-time rewards by changing servers.

## 24. Content Scalability

### CS-01 — Future Biomes extend the graph rather than rewriting old ownership

New regions may branch from existing progression nodes, add later tiers or create optional side regions. They must not revoke existing Access Unlocks merely to force repurchase.

### CS-02 — Biome content is data-authored conceptually

Species pools, habitats, weights, objective sets, landmarks, Access costs and hazard parameters are tuneable content rather than reasons to rewrite the semantic world model.

### CS-03 — New Species do not invalidate old Region Mastery

Adding creatures to an existing Biome does not retroactively revoke already finalized Region Mastery. New optional mastery tiers require explicit new milestones rather than rewriting history.

### CS-04 — Spawn rebalancing is prospective

Changing future encounter weights/densities/lifetimes does not reroll an existing Creature Instance or rewrite a Secured Creature.

### CS-05 — New utility points preserve transport meaning

Adding Secure Points/fast-travel nodes requires route review so the `capture -> transport -> extraction` loop remains meaningful.

## 25. Abuse and Fairness Guardrails

The world design must resist at minimum:

- claim cycling to reroll one creature;
- server hopping to reset a personal World Cycle;
- fast-travel transport bypass;
- repeated Landmark trigger farming;
- repeated first-time objective reward replay;
- entering locked regions through Recovery/respawn selection;
- using full capacity/overflow as unlimited capture storage;
- rare-spawn manipulation from spending state;
- hidden per-player rare pools based on monetization propensity;
- spawn camping of the protected onboarding opportunity;
- hazard placement that forces unavoidable repeated Recovery;
- despawning a creature during valid active capture/transport merely to refresh population;
- post-claim Mutation rerolls;
- retroactively revoking Region Mastery after content expansion.

## 26. Pacing and Spatial Targets

The following are launch reference targets and may be tuned without reopening GDS-9 if semantic rules remain intact:

- protected first Capture Opportunity reachable within roughly the first minute of active play;
- first Secure Point return path short enough to preserve GDS-1 first-secured-creature timing;
- ordinary active field searching normally surfaces a viable opportunity every ~20–45 seconds;
- field entry Safe Outpost is visually/route-legibly distinct from hazard/deep encounter space;
- normal transport routes are long enough to make `Bring it home` meaningful but short enough to fit 10–25 minute sessions;
- Mid Biome access becomes a visible Foundation/Growth goal rather than an opening paywall;
- Advanced Biome access requires both mid-region active progress, preventing one passive Energy purchase from skipping the world arc.

## 27. Tuneable Parameters

The following are tuneable without reopening GDS-9 when semantic rules remain intact:

- Biome display names, visual themes and exact geometry;
- exact Landmark count and placement;
- exact Regional Collection thresholds below full/rare-RNG completion;
- field-objective catalogs and bounded Energy quantities;
- Access Unlock Energy costs consistent with GDS-8;
- habitat pool membership and spawn weights;
- encounter-population budgets/min/max scaling;
- ordinary density targets around the reference pacing range;
- exact Encounter Lifetimes and Rare Encounter Stability Windows;
- World Cycle duration/phase labels;
- hazard timing, geometry and severity parameters;
- Safe Outpost/Recovery Anchor details;
- optional deep-habitat capability requirements;
- future graph expansion points.

The following are **not** tuneable without change control/revalidation:

- Home Hub + Starter -> two parallel Mid -> Advanced baseline topology semantics;
- active Region Mastery requirement categories;
- no rare/extreme/event/paid mandatory progression gate;
- Secure Point as the ordinary extraction destination;
- fast-travel prohibition during Acquisition-In-Progress;
- spawn/variant prospective-only identity rules;
- no hidden spending-based spawn odds;
- persistent world milestones versus session-scoped encounter populations;
- no hazard destruction of secured value;
- onboarding protection;
- existing Mastery/access preservation after ordinary content expansion.

## 28. Downstream Obligations

### GDS-10 — Social Play

Must define player collision/body-blocking, cooperative exploration, shared objectives, rare-encounter social fairness, optional interception and grief prevention without changing GDS-9 world topology invisibly.

### GDS-11 — Events / Live Content

Must define server-wide announcements, rifts, rotating Spawn Context modifiers, event-specific encounter allocation, Availability windows and shared/multi-award overrides. Event modifiers remain prospective for new instances.

### GDS-12 — Trading

Must preserve world provenance/instance identity when ownership transfers and cannot use trade to fabricate Landmark/Region Mastery history.

### GDS-13 — Monetization

Must evaluate any paid traversal/convenience/access product against the guaranteed non-premium Safe Route and non-coercive Access progression. GDS-9 authorizes no paid region skip.

### GDS-14 — Presentation

Must make region locks, prerequisites, routes, Safe Outposts, Secure Points, hazards, high-value encounter cues, Field Objectives and capability requirements legible across supported devices without color/audio-only dependence.

### GDS-15 — Platform Safety

Must review age-appropriate world communication/content and any randomized/commercial intersection without changing GDS-9 fairness rules.

### GDS-16 — Retention / Analytics

Must measure exploration/capture/route/access funnels and govern recurrence/experiments without converting world design into manipulative hidden personalization.

### Technical Architecture

Must implement authoritative region entitlement checks, persistent world milestones, session-local encounter populations, deterministic/secure Spawn Context evaluation, stable Creature Instance/Variant Identity, lifetime/claim interaction, travel-state validation, hazard/recovery integration, exact-once world rewards, world-cycle synchronization, streaming/performance and anti-exploit controls without weakening player-facing rules.

## 29. Edge-Case Matrix

| Situation | Required behavior |
|---|---|
| New player enters world | Home Hub/Safe Arrival then protected Starter path |
| Starter player has no Energy | Starter Biome remains accessible |
| Player has Starter Mastery + Energy | May buy either Mid Biome first |
| Player buys Mid A | Mid B remains separately available at its defined cost |
| Player has Energy but no Starter Mastery | Mid gates remain locked |
| Player owns both Mid unlocks but lacks one Mastery | Advanced remains locked |
| Player has both Mid Masteries + Energy | Advanced Access Unlock may finalize once |
| Access price changes later | Existing unlock remains owned |
| New Species added to completed Biome | Existing Region Mastery remains valid |
| Player revisits Landmark | No duplicate first-discovery reward |
| Player changes server after Landmark reward | No duplicate first-discovery reward |
| Player fast-travels normally | Allowed only between unlocked/discovered nodes |
| Player has Engagement Claim and tries fast travel | Blocked |
| Player carries Provisional Capture and tries fast travel | Blocked |
| Player reaches Recovery Anchor with provisional value via failure | GDS-5 interruption applies; no auto-extraction |
| Ordinary World Creature lifetime expires unclaimed | Instance may despawn |
| Lifetime expires during valid claim | Active acquisition remains governed by GDS-5, not idle despawn |
| Claim fails and creature survives | Same identity; no reroll |
| Creature truly despawns and slot refills | New instance may roll independently |
| World Cycle changes around existing rare creature | Existing identity persists |
| Player server-hops | Cycle is not intentionally restarted for that player |
| High spender joins | Same authored context rules; no hidden spender odds |
| Protected Variant appears | Receives readable significance and non-trivial stability window |
| Hazard causes avatar failure | Recovery; no secured ownership/Energy deletion |
| Hazard interrupts transport | GDS-5 transport interruption semantics apply |
| Player tries Recovery into locked region | Invalid; choose valid unlocked anchor |
| Server shuts down with unclaimed Legendary visible | No ownership grant merely for visibility |
| Server shuts down with valid Provisional Capture | Only GDS-5 protected shutdown rule may finalize |
| Capacity is known full | New ordinary capture initiation remains blocked under GDS-5 |
| Onboarding public area is crowded | Protected opportunity remains functionally available |
| Region Mastery would require Legendary | Invalid baseline mastery design |
| Field Objective reward retries | One finalized Energy reward maximum |
| Player AFKs inside objective area | No raw-presence Energy |
| New Secure Point proposed beside rare pocket | Route/transport-meaning review required |
| Premium shortcut proposed as only safe route | Invalid baseline design |
| Existing Secured Creature's old habitat is removed | Owned instance/provenance remains intact |

## 30. Open Questions

There are **zero GDS-9-blocking open questions**.

Exact Biome names/art themes, map dimensions, exact Species pools/weights, exact spawn counts, exact lifetime seconds, Landmark coordinates, Energy quantities, hazard geometry, final map UI, event modifiers and implementation algorithms are tuneable content or downstream authority rather than unresolved GDS-9 semantics.

## 31. Design-Complete Checklist

- [x] World topology and progression graph are explicit.
- [x] Starter/Mid/Advanced access semantics are explicit.
- [x] Active Region Mastery is defined without rare-RNG gates.
- [x] Landmarks and persistent exploration milestones are defined.
- [x] Field objectives and active Energy boundaries are defined.
- [x] Secure Point/Vault Access Point/Recovery Anchor placement rules are defined.
- [x] Baseline traversal/fast-travel interaction with capture is defined.
- [x] Habitat and Spawn Context semantics are defined.
- [x] Species Rarity/Mutation generation preserves GDS-6 identity timing.
- [x] Encounter population/density/lifetime semantics are defined.
- [x] rare/Protected Variant readability/stability is defined.
- [x] ordinary World Cycle and server-hop boundary are defined.
- [x] hazard consequences preserve secured value and Recovery authority.
- [x] session-scoped versus persistent world state is explicit.
- [x] content expansion preserves completed access/mastery/ownership.
- [x] abuse/fairness cases are addressed.
- [x] downstream authority boundaries are preserved.
- [x] no implementation-relevant open questions remain.
