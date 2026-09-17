# Creatures, Collection, and Ownership

> **Status:** Design Complete  
> **Owning GDS phase:** GDS-4 — Creatures, Collection, and Ownership  
> **Authority:** Creature identity, Species versus Creature Instance semantics, persistent ownership, collection states, duplicates, capacity semantics, voluntary loss protection, collection completion, provenance, and ownership-facing lifecycle  
> **Depends on:** `../00_design_authority.md`, `../01_game_overview.md`, `../product/market_positioning_and_differentiation.md`, `../global_rules/02_global_game_rules_and_session_model.md`, `../player/03_player_character_interaction_and_onboarding.md`, `../GLOSSARY.md`

## 1. Purpose and Player Fantasy

MonsterVault depends on creatures feeling like possessions with identity rather than disposable counters.

The player-facing contract is:

> **When I secure a creature, I own that specific creature. I can recognize it, keep it, organize it, display or use it through later systems, and trust that ordinary session failures will not silently replace or delete it.**

GDS-4 defines what a creature *is* as collection value and what persistent ownership means. GDS-5 owns the active acquisition process and exact moment at which an encounter crosses into the secured-owned state.

## 2. Scope

This specification owns:

- Species versus individual Creature Instance identity;
- world/unowned versus transient-acquisition versus secured-owned creature categories;
- persistent creature instance identity;
- collection registry semantics;
- Active, Stored, Overflow-Held, and Released collection-facing states;
- duplicate ownership semantics;
- capacity semantics and full-capacity behavior;
- provenance/history fields that contribute to collectible identity;
- player-facing ownership visibility;
- voluntary release/disposal safeguards;
- ordinary loss rules for secured creatures;
- collection discovery/completion semantics;
- ownership-transfer prerequisites consumed later by trading;
- collection persistence expectations;
- cross-server and Recovery behavior for secured creatures;
- abuse/integrity invariants around duplicate identities and contradictory ownership.

## 3. Explicit Non-Goals

GDS-4 does **not** define:

- encounter spawning, encounter eligibility, capture input, capture probability, contesting, transport, extraction, interruption, or the exact event that finalizes capture ownership — GDS-5;
- rarity tiers, mutation generation, trait effects, variant probabilities, mutation stacking, or rarity-derived protection thresholds — GDS-6;
- vault layout, production assignment, display-slot counts, visitor interaction, or vault upgrade rules — GDS-7;
- currencies, prices, progression formulas, unlock pacing, or capacity-upgrade economics — GDS-8;
- biome/world spawn pools or encounter ecology — GDS-9;
- stealing, interception, PvP, social contesting, or optional risk modes — GDS-10;
- event reward allocation or event-exclusive spawn rules — GDS-11;
- player-to-player trading flow, trade eligibility, atomic exchange, market restrictions, or scam protection — GDS-12;
- monetization of capacity/convenience — GDS-13;
- final collection UI, vault UI, icons, animation, audio, filtering UX, or accessibility settings — GDS-14;
- persistence schemas, database keys, GUID format, replication, locking, conflict resolution algorithms, or anti-duplication implementation — Technical Architecture.

## 4. Terminology

Shared terms are normalized in `../GLOSSARY.md`.

### Species
A content-authored creature archetype. Species defines shared authored identity such as name, base visual concept, world/content relationships, and later system hooks. Species is not itself player-owned.

### Creature Instance
A concrete individual creature entity with a stable identity. Once secured, a Creature Instance is persistent player-owned collection value rather than a fungible species count.

### World Creature
A Creature Instance or encounter representation that is not yet part of any player's Secured Collection. Exact encounter/capture semantics belong to GDS-5.

### Acquisition-In-Progress
A transient creature-related opportunity for which GDS-5 has begun acquisition/capture semantics but has not yet emitted a Secured Ownership Finalization. It is not yet a Secured Creature.

### Secured Ownership Finalization
The authoritative GDS-5-owned transition event that changes one eligible creature from non-secured/transient acquisition state into a specific player's persistent ownership. GDS-4 owns the consequences after this event; GDS-5 owns the trigger conditions and timing.

### Secured Creature
A Creature Instance for which Secured Ownership Finalization has completed and whose ownership is part of Persistent Player State.

### Collection Registry
The player's authoritative logical set of Secured Creature Instances, including their stable identity and collection-facing metadata. The registry is a semantic concept, not a prescribed storage implementation.

### Active Creature
A Secured Creature currently assigned to a later gameplay-active role permitted by downstream systems. `Active` does not change ownership.

### Stored Creature
A Secured Creature retained in ordinary collection/vault storage and not currently assigned to an active role.

### Overflow-Held Creature
A Secured Creature retained safely when ordinary collection/storage placement capacity is temporarily unavailable. It remains owned but has restricted use until the player creates eligible capacity or a downstream system resolves placement.

### Released Creature
A former Secured Creature whose player intentionally completed an irreversible voluntary removal action. Release ends ordinary ownership and cannot silently occur from session lifecycle.

### Duplicate
Two or more distinct Secured Creature Instances of the same Species. They remain individually identifiable and may differ through provenance, later mutations/traits, or other instance metadata.

### Provenance
Persistent collection-facing information describing a creature's origin or acquisition history where applicable, such as acquisition source category, event association, acquisition timestamp/period, or other later-authorized collectible history.

### Creature Lock
A player-controlled persistent protection flag preventing voluntary destructive or ownership-transfer actions until explicitly unlocked. Later trading semantics must respect it.

### Species Discovery
A persistent collection fact indicating that the player has legitimately secured at least one Creature Instance of a Species at some point, unless a later explicit collection mode defines a different discovery criterion.

## 5. Participating Entities and Ownership

GDS-4 concerns:

- Species definitions, which are game content and have no player owner;
- World Creatures and Acquisition-In-Progress creatures, which are not yet secured persistent possessions;
- Secured Creature Instances, each owned by exactly one player/account at a time unless a later explicit transfer transaction is in progress under GDS-12;
- the Collection Registry, owned by the player/account;
- downstream Active/Stored/Overflow placement systems;
- collection discovery/completion records.

A Player Character, server, vault scene object, UI card, visual model, or active tool is never the authoritative owner of a Secured Creature. Those are representations or placements of player-owned persistent state.

## 6. Core Rules and Invariants

### CR-01 — Species and instance identity are distinct
Owning a creature means owning a specific Creature Instance, not merely incrementing a fungible Species counter.

### CR-02 — Every secured creature has stable individual identity
A Secured Creature preserves a stable identity across ordinary respawn, Recovery, disconnect, reconnect, server change, device change, vault placement changes, and future sessions.

### CR-03 — One secured instance has one ordinary owner
Outside an explicitly defined atomic ownership-transfer operation, the same secured Creature Instance may not simultaneously belong to two players' Collection Registries.

### CR-04 — Secured ownership begins only through an authoritative finalization
Seeing, targeting, damaging, interacting with, beginning capture of, transporting, or being closest to a creature does not by itself create persistent ownership. GDS-5 must emit Secured Ownership Finalization.

### CR-05 — GDS-4 does not redefine the GDS-5 capture boundary
The exact capture/transport/extraction step that emits Secured Ownership Finalization remains GDS-5 authority. Once emitted, GDS-4 ownership semantics apply immediately and consistently.

### CR-06 — Secured creatures are Persistent Player State
Ordinary avatar death/reset, Recovery, disconnect, reconnect, server shutdown, server transition, or device transition does not remove a Secured Creature from the owner's Collection Registry.

### CR-07 — Secured creature identity may not silently collapse into counts
Optimization or UI grouping may summarize duplicates, but the underlying secured collection must preserve instance-level identity for each creature.

### CR-08 — Duplicate creatures are valid collection value
Players may ordinarily own multiple Creature Instances of the same Species. Duplicate ownership is not automatically converted, deleted, merged, or rejected merely because the Species is already discovered.

### CR-09 — Duplicate conversion requires explicit downstream authority
Any future feature that consumes, fuses, recycles, exchanges, upgrades, or otherwise destroys duplicates must have explicit authoritative design. GDS-4 creates no automatic duplicate sink.

### CR-10 — Collection placement state does not change ownership
Moving a Secured Creature among Active, Stored, display, vault, or Overflow-Held representations does not by itself change who owns it.

### CR-11 — Ordinary collection use cannot create a second creature
Activating, storing, displaying, moving, loading, reloading, or recovering a Secured Creature must not semantically clone it into multiple independently owned instances.

### CR-12 — Capacity limits placement/ordinary retention flow, not ownership trust
When an acquisition is eligible to become secured but ordinary placement capacity is unavailable, the game must resolve the situation without silently deleting an already-finalized owned creature or fabricating capacity.

### CR-13 — Overflow-Held ownership is safe but intentionally restricted
If GDS-5 finalizes ownership while ordinary eligible placement capacity is unavailable, the creature enters Overflow-Held state. It remains persistent and owned, but cannot be deployed into ordinary active/vault functions until eligible capacity exists.

### CR-14 — Overflow is not normal infinite storage
Overflow-Held state exists as an integrity/safety path, not as an intended replacement for collection capacity. Downstream design may limit which actions are available while overflow exists and should guide the player to resolve it.

### CR-15 — Capacity cannot retroactively invalidate secured ownership
Reducing, expiring, or changing a capacity entitlement must not silently delete already secured creatures. Excess creatures become or remain restricted/Overflow-Held until capacity is restored or the player intentionally resolves them under valid rules.

### CR-16 — Initial onboarding must have usable collection capacity
A legitimate first secured creature must have a valid collection destination consistent with GDS-3 onboarding. A new player cannot be blocked from the first collection success by starting with zero usable capacity.

### CR-17 — Voluntary destructive loss requires explicit intent
Releasing or permanently deleting a Secured Creature requires an explicit player action with clear consequence presentation. It cannot be triggered by ordinary movement, context switching, closing UI, respawn, disconnect, or capacity overflow.

### CR-18 — Creature Lock blocks voluntary destructive/transfer actions
A locked Secured Creature cannot be voluntarily released or offered into a later ownership-transfer flow until the player explicitly removes the lock. System-required non-destructive state transitions may still occur.

### CR-19 — High-value protection must be extensible
GDS-6/GDS-11 may later identify rarity/event/value categories requiring stronger confirmations or default lock behavior. GDS-4 requires such protection to integrate without changing instance ownership semantics.

### CR-20 — No baseline involuntary loss of secured creatures
The baseline product contains no ordinary mechanic by which another player, server transition, death, hazard, inactivity, capacity change, or random roll permanently removes a Secured Creature from its owner.

### CR-21 — Optional risk cannot silently rewrite baseline ownership
Any future bounded risk mode proposing loss of Secured Creatures must receive explicit authority under the relevant GDS-10/event/risk design and remain consistent with the GDS-1 non-loss-dominant contract. It is not implied by GDS-4.

### CR-22 — Release is irreversible in ordinary gameplay
Once a voluntary Release has produced its Finalized Outcome, reconnecting, resetting, or changing servers does not restore the released instance by default. Support/admin recovery policy is outside player-facing GDS scope.

### CR-23 — Release may not accidentally duplicate derived value
If later systems grant value for releasing/consuming a creature, the release and derived reward must form one coherent finalized outcome. Exact reward design belongs downstream.

### CR-24 — Species Discovery persists after later loss/release
Once Species Discovery is legitimately recorded, voluntarily releasing the last currently owned instance does not erase the historical fact that the player discovered that Species.

### CR-25 — Collection completion is discovery-based unless explicitly refined
Baseline Species collection completion measures whether the player has discovered the required Species set, not whether every instance is simultaneously held. Variant/mutation completion belongs to GDS-6 and event-specific sets may refine requirements later.

### CR-26 — Collection completion cannot depend on unobtainable retired content without labeling
If live content later removes normal access to a Species, completion presentation must distinguish currently obtainable baseline goals from legacy/event-limited goals rather than making an unlabeled impossible target.

### CR-27 — Provenance is instance metadata, not ownership itself
A creature may retain meaningful origin/history metadata across placements and later ownership transfer. Provenance does not create a second owner or override current authoritative ownership.

### CR-28 — Provenance must not be falsified by routine state changes
Moving between Active/Stored/Overflow, respawning, changing servers, or normal UI operations must not rewrite acquisition origin/history as though the creature were newly obtained.

### CR-29 — Ownership-facing state must be legible
Players must be able to distinguish at minimum a transient/unsecured creature opportunity from a Secured Creature they own, consistent with GDS-2/GDS-3 requirements. Final presentation belongs to GDS-14.

### CR-30 — Ownership cannot be inferred from visual proximity alone
A creature standing beside, following, displayed near, or rendered for a player does not become owned merely through visual association. Ownership state must derive from authoritative collection semantics.

### CR-31 — Active assignment is exclusive where the downstream role is singular
If a later system defines a creature occupying one exclusive active slot/placement, the same Creature Instance cannot simultaneously occupy contradictory exclusive placements. Exact active-slot counts belong downstream.

### CR-32 — A secured instance cannot be both Released and owned
Released is terminal with respect to ordinary ownership of that instance. A future reacquisition of the same Species produces a different Creature Instance unless an explicitly designed restoration mechanism exists.

### CR-33 — Creature content updates preserve identity where feasible
Balance, presentation, or authored Species-data changes do not imply deletion/recreation of owned instances. Migration semantics belong to Technical Architecture, but player-facing identity continuity is the default contract.

### CR-34 — Ownership transfer requires explicit transfer authority
GDS-4 does not allow informal gifting, dropping, lending, shared ownership, or trust-based handoff. Player-to-player ownership changes require GDS-12 or another explicitly authorized transfer system.

### CR-35 — No unsecured creature may masquerade as persistent collection value
UI or world presentation must not tell the player a creature is permanently theirs before the relevant Secured Ownership Finalization has occurred.

### CR-36 — No secured creature may silently revert to unsecured state
Once secured, an instance does not return to World Creature/Acquisition-In-Progress merely due to ordinary session lifecycle or placement changes.

## 7. Creature Identity Model

### 7.1 Species-level authored identity

Species may define or reference later-authorized content such as:

- canonical name and species identifier;
- base visual/audio identity;
- habitat/biome relationships;
- encounter/content tags;
- later rarity/mutation compatibility;
- collection-category membership;
- authored descriptive/lore-light metadata where appropriate.

GDS-4 does not define exact Species content lists.

### 7.2 Instance-level identity

A Secured Creature Instance must preserve enough semantic identity to remain the same collectible over time. Instance-level data may include:

- stable instance identity;
- Species identity;
- current owner;
- ownership/collection state;
- acquisition/provenance metadata;
- later mutation/trait/variant data from GDS-6;
- later status/customization fields explicitly authorized by owning phases;
- Creature Lock state;
- creation/acquisition ordering information where useful for player history.

The exact technical schema is TA authority.

### 7.3 Instance individuality principle

Two otherwise identical creatures of the same Species remain distinct owned instances. The product may group them visually for convenience, but later trading, mutation, provenance, locking, display, or active-role systems must be able to target an individual instance.

## 8. Ownership and Collection State Model

Conceptually:

```text
World Creature
    ↓ GDS-5 acquisition begins
Acquisition-In-Progress
    ├── failure/interruption → GDS-5-owned resolution
    └── Secured Ownership Finalization
                 ↓
           Secured Creature
                 ↓
        Collection Registry
          ├── Stored
          ├── Active / assigned downstream role
          ├── Overflow-Held
          └── voluntary transfer later via GDS-12
                 ↓
        voluntary Release (explicit)
                 ↓
             Released
```

Important boundaries:

- GDS-5 owns all transitions before `Secured Ownership Finalization` and its exact trigger;
- GDS-4 owns persistent semantics after finalization;
- GDS-7 owns vault placement/production semantics;
- GDS-12 owns player-to-player transfer semantics;
- Released is not a normal temporary state.

## 9. Collection Registry Semantics

The Collection Registry represents what the player currently owns.

It must support player-facing reasoning such as:

- which Species have I discovered?;
- which specific instances do I currently own?;
- which duplicates differ from one another?;
- which creatures are Active, Stored, or Overflow-Held?;
- which creatures are locked/protected?;
- which creatures carry meaningful provenance or later variant data?;
- what collection goals are complete or incomplete?

The registry may be surfaced through multiple UIs/world representations later, but those representations must resolve to the same underlying ownership facts.

## 10. Capacity Semantics

### 10.1 Capacity categories

Downstream systems may distinguish:

- total ordinary collection/storage capacity;
- active/deployed capacity;
- vault display/production capacity;
- special/event storage categories.

GDS-4's invariant is that capacity restrictions must be explicit and cannot silently destroy secured ownership.

### 10.2 Full-capacity acquisition

GDS-5 must check/coordinate with collection capacity before or at Secured Ownership Finalization. If the finalization is allowed while ordinary capacity is unavailable, GDS-4 requires `Overflow-Held` as the safe collection state.

The player must be told that:

- the creature is secured and owned;
- normal use/placement is restricted;
- a capacity-resolution action is required.

### 10.3 Resolving overflow

Overflow may be resolved through later-authorized actions such as:

- increasing eligible capacity;
- moving/reorganizing eligible collection placements;
- voluntarily releasing an eligible creature;
- completing a later transfer mechanic.

Exact economy, upgrade, and UI flows belong downstream.

### 10.4 No capacity-loss trap

A player whose capacity decreases must retain access to a path for resolving excess creatures. The game may restrict adding/activating more creatures while over capacity but may not require payment as the only path to regain a valid collection state.

## 11. Duplicates and Collection Value

Duplicates are intentional rather than erroneous.

They can support later systems through:

- different mutations/traits;
- provenance/event history;
- display/status value;
- trading;
- active-role selection;
- future explicitly designed duplicate sinks.

However:

- GDS-4 guarantees no automatic duplicate deletion;
- collection completion does not require keeping all discovered Species simultaneously unless a later specialized collection objective explicitly says so;
- owning many duplicates must not corrupt Species Discovery counting.

## 12. Provenance Contract

Where acquisition source/history is recorded, provenance should be stable and truthful enough to matter as collectible history.

Potential provenance categories include:

- ordinary world acquisition;
- named live event or seasonal source;
- future trade acquisition while retaining original origin metadata;
- special achievement/reward source explicitly defined later.

GDS-11/GDS-12 may extend provenance fields, but they may not silently rewrite the historical acquisition origin when ownership later changes.

## 13. Voluntary Release and Protection

### 13.1 Release purpose

Release is the baseline semantic for intentionally removing a Secured Creature from current ownership when a permanent removal path is needed.

Release is not required to grant a reward. GDS-8 or later systems may define one.

### 13.2 Safety requirements

A release flow must:

- identify the exact Creature Instance;
- state that ownership will end;
- require explicit confirmation;
- reject locked creatures;
- avoid input-spillover from GDS-3 menus/prompts;
- avoid presenting ordinary storage moves as equivalent to release.

GDS-14 owns final UI.

### 13.3 Stronger confirmation hooks

Later GDS-6/GDS-11 may require additional safeguards for exceptionally rare, mutated, event-limited, favorited, or otherwise high-value creatures. GDS-4 explicitly permits stronger protection without weakening ordinary release semantics.

## 14. Multiplayer Semantics

### 14.1 Before secured ownership

Competition, claims, simultaneous capture attempts, and transient encounter rights are not GDS-4 ownership. They are GDS-5/GDS-10 authority.

### 14.2 After secured ownership

After Secured Ownership Finalization:

- the Creature Instance belongs to exactly one player;
- another player cannot acquire it through ordinary world capture;
- another player's visual proximity does not grant ownership;
- server changes do not reopen the creature as a public world claim;
- ordinary social interaction cannot destroy or transfer it.

### 14.3 Future trading

GDS-12 may define an explicit temporary transfer transaction state. Until such a transaction finalizes, GDS-4 requires ownership to remain unambiguous and prevents the same creature from being finalized into both players' registries.

### 14.4 Shared display/use

A later social/vault system may allow other players to view, visit, assist with, or temporarily interact with a creature representation. Such access does not imply shared ownership unless a future design explicitly reopens the ownership model.

## 15. Progression and Economy Interactions

GDS-4 establishes only collection-facing constraints:

- Species Discovery may contribute to future progression;
- owning duplicates is allowed and may later have economic value;
- secured ownership is not automatically equivalent to currency value;
- voluntary release is not automatically profitable;
- capacity may be progressed later but must preserve non-paywall resolution paths;
- collection completion may unlock later rewards, but reward formulas belong GDS-8;
- paid capacity/convenience, if later allowed, cannot delete or invalidate free-earned secured creatures when absent/expired.

## 16. Failure, Interruption, and Recovery

### Before Secured Ownership Finalization

GDS-5 owns the result of disconnect, reset, death, Recovery, server shutdown, contest interruption, or transport interruption.

### After Secured Ownership Finalization

The creature is Persistent Player State:

- reset/Recovery does not release it;
- disconnect does not release it;
- server shutdown does not release it;
- rejoin does not create a duplicate copy;
- capacity recalculation does not delete it;
- visual/model load failure does not imply ownership loss.

If a representation fails to load, the ownership fact remains authoritative and the player should receive recoverable presentation rather than silent creature deletion.

## 17. Abuse and Exploit Cases

### Duplicate-delivery / retry abuse
Repeated finalization delivery must not create multiple Creature Instances for one finalized acquisition outcome.

### Same-instance dual ownership
The same instance may not appear authoritatively owned by two accounts outside an explicitly controlled transfer-in-progress state.

### Rejoin duplication
Leaving/rejoining while a creature is being placed, activated, stored, or overflow-resolved must not clone it.

### Capacity bypass
Overflow-Held creatures cannot be used as a permanent hidden infinite active/storage pool. Restricted state must be meaningful.

### Release/reward replay
If release later grants compensation, retry/reconnect may not both restore the creature and retain the finalized compensation.

### Lock bypass
A later trade/release/bulk-management action may not silently ignore Creature Lock.

### UI grouping confusion
Bulk/stacked UI representations may not cause operations intended for one instance to unpredictably affect another duplicate.

### Fake provenance
Client-visible labels or user actions may not authoritatively rewrite provenance/value-significant metadata without an owning gameplay rule.

## 18. Presentation and Feedback Requirements

GDS-4 requires later presentation to make these facts understandable:

- Species versus individual instance where relevant;
- unsecured/transient opportunity versus Secured Creature;
- current owner for ownership-sensitive interactions;
- Active versus Stored versus Overflow-Held state;
- duplicate count/grouping without hiding instance selection;
- Creature Lock state;
- full/over-capacity state and resolution requirement;
- voluntary Release consequence;
- Species Discovery/collection completion progress;
- provenance/value-significant history where exposed.

No critical ownership state may rely solely on color or audio.

## 19. Accessibility

Collection/ownership interaction must preserve GDS-3/GDS-14 accessibility direction:

- selecting one duplicate must not require pixel-precise clicking;
- bulk actions must offer clear scope and confirmation;
- lock/release/overflow states need text/icon/structure beyond color;
- collection browsing should support non-drag-only manipulation;
- long species/instance lists require scalable navigation/filtering owned by GDS-14;
- provenance or completion status must not be audio-only.

## 20. Persistence Expectations

The following are persistent when applicable:

- stable Secured Creature Instance identity;
- current owner;
- Species identity;
- collection state needed to restore Active/Stored/Overflow semantics;
- Creature Lock state;
- relevant provenance;
- later mutation/trait data;
- Species Discovery/completion facts;
- finalized voluntary Release outcome.

Purely visual transient world representation is not itself the persistent ownership record.

## 21. Monetization Interactions

GDS-13 may later monetize bounded capacity/convenience subject to these invariants:

- payment is not required merely to avoid deletion of already secured creatures;
- expiry/loss of paid capacity does not delete creatures;
- over-capacity players retain a non-payment resolution path;
- paid collection tools cannot create duplicate authoritative ownership;
- paid convenience cannot redefine Secured Creature ownership into rental by surprise.

## 22. Analytics and Experimentation Boundaries

Useful later measurements include:

- Species Discovery rate;
- duplicate acquisition rate;
- collection-capacity pressure;
- overflow frequency and resolution path;
- release frequency/cancellation rate;
- lock usage;
- collection completion progress;
- creature ownership/state integrity errors.

Experiments may tune:

- capacity values through GDS-7/GDS-8 authority;
- default sorting/filter hints;
- confirmation presentation;
- collection-goal presentation.

Experiments may not silently change:

- instance-level ownership;
- no-loss baseline;
- one-owner invariant;
- secured persistence;
- release confirmation semantics;
- Species Discovery historical persistence.

## 23. Tuneable Parameters

Tuneable downstream parameters include:

- starting/upgrade collection capacity;
- active/deployed slot counts;
- display capacity;
- overflow warning cadence;
- collection filter/sort defaults;
- confirmation thresholds for later-defined value classes;
- collection-set sizes/content lists.

These values may change without reopening GDS-4 while its semantic rules remain intact.

## 24. Dependencies and Cross-References

- GDS-1: persistent collection, individual collectible identity, non-loss-dominant positioning;
- GDS-2: Persistent Player State, Finalized Outcome, lifecycle safety;
- GDS-3: interaction grammar, modal safety, onboarding, Recovery;
- GDS-5: exact Secured Ownership Finalization trigger and pre-secure acquisition/interruption;
- GDS-6: rarity/mutations/traits and value-sensitive safeguards;
- GDS-7: vault placement/display/production/capacity implementation at design level;
- GDS-8: economy, progression, capacity pricing/upgrades, release rewards if any;
- GDS-10: social competition and any bounded secured-value risk proposals;
- GDS-11: event-limited creatures/provenance;
- GDS-12: ownership transfer/trading;
- GDS-13: monetized capacity/convenience;
- GDS-14: final collection UX/presentation/accessibility;
- Technical Architecture: identifiers, persistence, integrity, replication, migration, transactional mechanisms.

## 25. Edge-Case Matrix

| Scenario | Required GDS-4 result |
|---|---|
| Two creatures of same Species secured | Two distinct owned instances; one Species Discovery |
| Rejoin after securing creature | Same instance remains owned; no duplicate |
| Reset while secured creature active | Ownership unchanged; downstream active representation recovers |
| Capacity full before acquisition finalization | GDS-5 must resolve; if finalization occurs, creature becomes Overflow-Held |
| Paid capacity expires | No deletion; excess becomes/remains restricted/Overflow-Held |
| Last instance of Species released | Current owned count becomes zero; Species Discovery remains |
| Locked creature included in bulk release | Locked instance is rejected/protected |
| UI shows grouped duplicates | Player can still address exact instance for instance-specific actions |
| Server crashes after finalization | Secured creature remains Persistent Player State |
| Duplicate finalization callback | Must not mint an additional instance for same outcome |
| Visual creature model fails to load | Ownership remains; presentation recovers |
| Another player stands beside displayed creature | No ownership effect |
| Creature moved Stored → Active | Same owner and instance identity |
| Creature moved Active → Overflow due capacity recalculation | Same owner; restricted use, no deletion |
| Future trade begins | Ownership remains unambiguous until GDS-12 finalization |
| Released creature after reconnect | Remains released; no rollback by ordinary reconnect |
| Species removed from normal live rotation | Historical Discovery remains; completion presentation labels availability |
| Creature content balance changes | Instance identity preserved by default |

## 26. Open Questions

There are **zero GDS-4-blocking open questions**.

The following implementation-relevant questions are deliberately owned downstream rather than unresolved here:

- exact capture/secure transition and interruption behavior — GDS-5;
- rarity/mutation/trait value — GDS-6;
- exact storage/display/active capacity and vault behavior — GDS-7;
- capacity costs, release compensation, progression rewards — GDS-8;
- optional risk/social loss mechanics — GDS-10;
- event provenance/content availability — GDS-11;
- trading/transfer semantics — GDS-12;
- capacity monetization — GDS-13;
- final collection UX — GDS-14;
- technical instance IDs/persistence/transactions — TA.

## 27. Design-Complete Checklist

- [x] Purpose and scope are explicit.
- [x] Species versus instance identity is deterministic.
- [x] Ownership states and state transitions are defined.
- [x] Secured persistence is defined.
- [x] Duplicate semantics are defined.
- [x] Capacity and overflow behavior are defined.
- [x] Voluntary loss and protection are defined.
- [x] Multiplayer ownership semantics are defined.
- [x] Failure/recovery behavior is defined.
- [x] Abuse/integrity cases are addressed.
- [x] Presentation/accessibility requirements are defined.
- [x] Collection completion/discovery semantics are defined.
- [x] Cross-references preserve one authoritative owner.
- [x] No implementation-relevant GDS-4 open questions remain.
