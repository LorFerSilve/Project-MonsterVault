# Capture, Contesting, Transport, and Extraction

> **Status:** Design Complete  
> **Owning GDS phase:** GDS-5 — Capture, Contesting, Transport, and Extraction  
> **Authority:** Active creature-acquisition loop, encounter eligibility, capture-attempt state, temporary contesting/claim semantics, provisional capture, transport custody, extraction, interruption behavior, Secured Ownership Finalization trigger, and capture-specific anti-frustration/fairness invariants  
> **Depends on:** `../00_design_authority.md`, `../01_game_overview.md`, `../product/session_shape_and_experience_promise.md`, `../product/market_positioning_and_differentiation.md`, `../global_rules/02_global_game_rules_and_session_model.md`, `../player/03_player_character_interaction_and_onboarding.md`, `../creatures/04_creatures_collection_and_ownership.md`, `../GLOSSARY.md`

## 1. Purpose and Player Fantasy

MonsterVault's core acquisition fantasy is not merely clicking a creature and immediately adding a number to inventory. The player should notice something desirable, reach it, commit to a readable capture attempt, win provisional control, and physically or spatially return that value to safety.

The player-facing contract is:

> **I find a creature, earn a fair chance to capture it, know whether I am still competing or already in control, bring a successful provisional capture to safety, and only then know that the specific creature is permanently mine.**

This phase gives the product promise `Find it. Catch it. Bring it home. Make your vault legendary.` a concrete active loop while preserving GDS-4's protected persistent ownership once securisation is complete.

## 2. Scope

GDS-5 owns:

- when a world creature is capture-eligible;
- how a player begins a capture engagement;
- temporary claim/reservation semantics during an active attempt;
- simultaneous-player contest resolution before provisional capture;
- capture-attempt acceptance, cancellation, success, failure, and retry semantics;
- the semantic capture challenge contract across touch, keyboard/mouse, and controller;
- provisional capture / transport custody after successful capture but before persistent ownership;
- the baseline transport-custody limit;
- extraction / secure-point completion;
- the exact GDS-5 trigger for **Secured Ownership Finalization**;
- capacity checks as they affect capture initiation/finalization;
- disconnect, reset, Recovery, player leave, and server-shutdown behavior during each acquisition state;
- anti-grief and anti-monopoly requirements for contested opportunities;
- anti-exploit rules for reset/rejoin/server hop and duplicate finalization;
- onboarding-protected first capture availability;
- capture-specific player feedback requirements;
- downstream obligations for world, social, event, economy, rarity, presentation, and architecture phases.

## 3. Explicit Non-Goals

GDS-5 does **not** define:

- Species taxonomy, stable owned-instance identity, duplicate collection semantics, Collection Registry behavior, Creature Lock, Release, or ordinary secured-creature loss — GDS-4;
- rarity tiers, mutation generation, trait effects, rarity-derived capture modifiers, variant probabilities, or value labels — GDS-6;
- vault layout, production, stored/active slot counts, or final vault intake presentation — GDS-7;
- capture-tool prices, currencies, upgrade costs, exact capture-power progression, or transport-capacity economy — GDS-8;
- world topology, biome access, creature spawn tables, encounter density, hazard layout, or exact Secure Point placement — GDS-9;
- player collision, direct PvP, parties, stealing after securisation, social grief systems, or optional high-risk modes — GDS-10;
- server-event encounter allocation, event participation rewards, seasonal windows, or event-specific multi-participant overrides — GDS-11;
- player-to-player trading — GDS-12;
- paid capture products or monetized convenience — GDS-13;
- final HUD, prompt art, animations, sound design, accessibility settings, or controller-remapping UI — GDS-14;
- persistence schemas, network protocols, server-authority implementation, rollback, datastore transactions, GUID generation, or anti-cheat code — Technical Architecture.

## 4. Terminology

Shared terms are normalized in `../GLOSSARY.md`.

### Capture Opportunity
A World Creature that is currently valid for at least one player to pursue through the ordinary GDS-5 acquisition loop.

### Capture Eligibility
The current rule result indicating whether a specific player is allowed to begin a capture engagement against a specific Capture Opportunity.

### Engagement Claim
A short-lived, non-persistent, exclusive right for one player to perform the current ordinary capture attempt against a creature. It prevents simultaneous contradictory attempts but is **not ownership**.

### Capture Attempt
A bounded active interaction in which the claimed player uses the capture mechanic to seek a success/failure result.

### Capture Challenge
The player-facing action structure inside a Capture Attempt. It may vary by later content/tool tuning but must obey the GDS-3 input/accessibility contract and the invariants in this phase.

### Capture Success
The successful result of a Capture Attempt. Capture Success ends ordinary contesting for that creature and creates a **Provisional Capture**, but does not by itself create Persistent Player State.

### Capture Failure
A non-successful Capture Attempt result. It does not create ownership. It may release the Engagement Claim immediately or after a short clearly signaled recovery/cooldown state.

### Provisional Capture
The post-Capture-Success state in which one player has exclusive temporary custody of the creature for transport/extraction. A Provisional Capture is transient and not yet a Secured Creature.

### Transport Custody
The temporary exclusive association between a player and their Provisional Capture while it is being brought to an eligible Secure Point.

### Secure Point
A world-defined valid destination or interaction that can complete ordinary extraction/security for a Provisional Capture. Exact location, geometry, and world fiction belong to GDS-7/GDS-9.

### Extraction Completion
The validated completion of the required return/secure step at an eligible Secure Point while Transport Custody is valid.

### Secured Ownership Finalization
The irreversible GDS-5 output emitted when a valid Provisional Capture successfully completes Extraction Completion, or when the controlled server-shutdown protection rule applies. This output changes the creature into a GDS-4 Secured Creature owned by that player.

### Transport Grace
A short bounded server-local interruption state entered after unexpected client disconnect while valid Transport Custody exists. A same-session reconnect can resume the same provisional custody; grace expiry ends the provisional state without ownership. Exact duration is tuneable.

### Opportunity Release
The transition that ends an Engagement Claim or failed/abandoned acquisition state and makes the creature available again if its world/encounter lifetime remains valid.

### Onboarding-Protected Opportunity
A first-session Capture Opportunity whose availability cannot be permanently consumed or monopolized by unrelated players before the onboarding player completes the required first capture milestone.

## 5. Acquisition State Model

```text
World Creature / Capture Opportunity
        ↓ valid player begins
Engagement Claim
        ↓
Capture Attempt
   ├── failure / cancel / invalidation
   │        ↓
   │   Opportunity Release or encounter-owned exit
   │
   └── Capture Success
            ↓
      Provisional Capture
            ↓
      Transport Custody
            ↓
      eligible Secure Point
            ↓
      Extraction Completion
            ↓
 Secured Ownership Finalization
            ↓
       Secured Creature
       (GDS-4 authority)
```

Once `Secured Ownership Finalization` occurs, GDS-4 persistent ownership semantics take over immediately. The creature cannot be returned to the GDS-5 unsecured state by normal session lifecycle.

## 6. Core Rules and Invariants

### CA-01 — Capture begins from an eligible world opportunity
A player can begin an ordinary capture only when the creature is currently a valid Capture Opportunity and the player passes Capture Eligibility.

### CA-02 — Eligibility is player-specific
Two players may see the same creature while only one or neither is currently eligible due to progression, encounter state, active custody, onboarding protection, or later-authorized rules.

### CA-03 — Eligibility failure must be legible
If a visible creature cannot currently be captured by the player, the game must provide a concise understandable reason or clearly non-capturable presentation rather than accepting input and silently doing nothing.

### CA-04 — Primary Interact begins ordinary engagement
The baseline contextual entry into an available capture opportunity uses GDS-3 **Primary Interact** or an equivalent clearly exposed contextual action. The capture challenge may then use **Primary Action** as needed.

### CA-05 — Capture cannot depend on platform-exclusive precision
Ordinary capture must remain fully viable on touch, keyboard/mouse, and controller. It may use timing, positioning, readable target selection, bounded movement, or simple action decisions, but cannot require pixel-precision cursor aim, high-frequency button mashing, hover-only controls, or keyboard-only chords.

### CA-06 — An accepted attempt is explicit
A capture cost, cooldown, claim, or attempt state may not be consumed merely because a player brushed past or looked at a creature. The game must first accept a deliberate valid capture initiation.

### CA-07 — One ordinary Engagement Claim at a time per creature
A normal single-award creature may have at most one active ordinary Engagement Claim. Multiple players cannot simultaneously run contradictory single-winner capture attempts against the same instance.

### CA-08 — Engagement Claim is not ownership
The claimant may have temporary attempt priority, but the creature is still unsecured and does not enter the player's Collection Registry.

### CA-09 — Claims are bounded and releasable
An Engagement Claim cannot persist indefinitely through inactivity, excessive separation, abandoned UI, or repeated non-participation. It must end through success, failure, cancel, invalidation, or a bounded inactivity/range rule.

### CA-10 — Claim cycling cannot monopolize a public creature indefinitely
A player repeatedly starting and abandoning claims may not indefinitely deny all other eligible players access. Later tuning may use brief personal re-engagement cooldowns or fairness rotation, but the semantic requirement is that ordinary public opportunities eventually reopen.

### CA-11 — Contesting happens before Provisional Capture by baseline
The baseline social competition is racing to reach and validly engage the opportunity before another player establishes the active ordinary claim. Other later systems may add explicit multi-participant rules, but ordinary capture does not permit unrestricted mid-attempt hijacking.

### CA-12 — Observers cannot overwrite the active claim
Once a valid Engagement Claim exists, unrelated players cannot simply press interact later and replace the claimant while the claim remains valid.

### CA-13 — Capture failure creates no secured ownership
A failed attempt may change encounter behavior, invoke a retry delay, or release the creature, but it never emits Secured Ownership Finalization.

### CA-14 — Failure consequences are communicated before retry decisions
The player must be able to understand whether a failed attempt can be retried, whether the creature is temporarily unavailable, whether an attempt cost was consumed, and whether the encounter itself is ending.

### CA-15 — Failure is not automatically permanent creature destruction
Baseline failure does not inherently delete the creature from the world. Encounter/world rules may still end or move an opportunity under GDS-9/GDS-11, but capture failure itself is not equivalent to creature destruction.

### CA-16 — Retry cannot duplicate attempt benefits or reverse finalized costs
If an accepted attempt consumed a later-authorized cost or cooldown, reconnect/reset/retry cannot refund or duplicate that cost unless the owning economy rule explicitly authorizes it.

### CA-17 — Capture Success creates one Provisional Capture
A successful ordinary Capture Attempt transitions the specific creature into one Provisional Capture associated with exactly one player.

### CA-18 — Capture Success ends ordinary contesting for that creature
Once Provisional Capture exists, unrelated players cannot start a normal capture attempt against the same creature while Transport Custody remains valid.

### CA-19 — Provisional Capture is not secured ownership
A successful capture result must not be presented as already permanently owned if extraction has not completed. The player must understand that they still need to bring/secure it.

### CA-20 — Provisional Capture preserves creature identity
The creature that reaches Capture Success is the same semantic Creature Instance that may later become secured. Transport/extraction cannot silently substitute a different Species/instance or reroll later GDS-6 instance properties.

### CA-21 — Baseline transport custody is singular
A player may ordinarily hold **one active Provisional Capture in Transport Custody at a time**. This keeps the baseline loop readable: capture one desirable creature, bring it to safety, then pursue another.

A future explicit transport-capacity expansion requires GDS-5 change control and downstream economy/world validation; it is not implied by ordinary inventory capacity.

### CA-22 — A player with active Transport Custody cannot begin another ordinary capture
The player must first complete extraction or lose/resolve the current provisional state before starting another standard Capture Attempt.

### CA-23 — Transport is active gameplay, not an invisible timer
A Provisional Capture must require the player to move/return toward a valid Secure Point or perform an equivalent world-facing return action. Ordinary securisation cannot be satisfied solely by waiting in place for an arbitrary countdown.

### CA-24 — Baseline transport cannot be directly stolen from custody
Other players cannot simply interact with, touch, or stand near another player's valid Provisional Capture to transfer Transport Custody to themselves.

### CA-25 — No baseline direct-combat theft requirement
Transport does not require direct PvP combat to keep a provisional creature. Any future optional interception/risk mode must be explicitly designed under GDS-10/GDS-11 and remain consistent with GDS-1's non-loss-dominant product position.

### CA-26 — Crowding cannot invalidate valid custody
Other players may create social presence around a transporter, but ordinary proximity/crowding cannot by itself cancel Transport Custody or finalize the creature for another player.

### CA-27 — Recovery does not secure transport
Player reset, avatar failure, stuck recovery, or manual Recovery does not count as Extraction Completion and cannot convert a Provisional Capture directly into a Secured Creature.

### CA-28 — Reset/failure during transport resolves as interruption
If the Player Character enters Recovery while carrying a Provisional Capture, ordinary Transport Custody ends and the provisional creature follows the GDS-5 interruption path rather than teleporting securely to the player's collection.

### CA-29 — Ordinary voluntary leave forfeits unfinalized transport
If a player intentionally leaves the server while holding a Provisional Capture, no Secured Ownership Finalization occurs. The provisional state ends according to Opportunity Release/encounter cleanup semantics.

### CA-30 — Unexpected client disconnect enters bounded Transport Grace
If the player unexpectedly disconnects while valid Transport Custody exists, that custody enters a short bounded **Transport Grace**. A same-session reconnect during grace resumes the same provisional custody without duplicating or auto-securing the creature.

If grace expires, the Provisional Capture ends without secured ownership and resolves through Opportunity Release or encounter cleanup.

### CA-31 — Transport Grace is not cross-server ownership
A player joining a different ordinary server does not carry an unfinalized provisional creature with them. A Provisional Capture is not Persistent Player State.

### CA-32 — Controlled server-originated shutdown protects valid provisional custody
If an orderly system/server-originated shutdown begins while a valid Provisional Capture exists and authoritative custody state is still available, the game performs **Protected Shutdown Finalization** for that provisional creature exactly once.

An abrupt process/platform failure that prevents the server from executing or verifying shutdown state cannot be promised this exception; it remains an unfinalized transient interruption under GDS-2/GDS-5.

Protected Shutdown Finalization emits the same single Secured Ownership Finalization as ordinary extraction. It does not apply to voluntary leave, player reset, client disconnect, or player-triggered Recovery.

### CA-33 — Protected Shutdown Finalization cannot duplicate ordinary extraction
If Extraction Completion already finalized the creature, shutdown handling must observe that result and cannot grant a second instance.

### CA-34 — Secure Points are explicit world destinations
A Secure Point must be recognizable as a destination that can complete extraction for a valid Provisional Capture. Exact placement, theme, number, and access conditions belong to GDS-7/GDS-9.

### CA-35 — Extraction Completion requires valid custody
Reaching or interacting with a Secure Point without a valid Provisional Capture cannot generate a creature or ownership result.

### CA-36 — Ordinary Secured Ownership Finalization occurs at Extraction Completion
For the baseline acquisition loop, the exact ownership boundary is:

> **A specific valid Provisional Capture reaches/completes an eligible Secure Point interaction under authoritative validation.**

At that moment GDS-5 emits `Secured Ownership Finalization(player, creature)` exactly once.

### CA-37 — Finalization is immediate from the player's semantic perspective
Once Extraction Completion has succeeded and the game communicates that the creature is secured, the creature is governed by GDS-4 Persistent Player State. A later ordinary disconnect or server transition cannot undo it.

### CA-38 — Finalization preserves the same creature instance
The specific provisional instance becomes the Secured Creature. Securisation cannot replace it with a newly rolled generic copy.

### CA-39 — Finalization records provenance hooks
Secured Ownership Finalization supplies GDS-4 with the acquisition-source/provenance context available to GDS-5, such as ordinary capture versus later event-specific source. Exact provenance presentation belongs downstream.

### CA-40 — Full ordinary capacity blocks new normal capture initiation
If the player is already known to have no eligible ordinary collection destination, they cannot begin a new ordinary capture solely to use Overflow-Held as routine unlimited storage. The game must communicate the capacity problem before the attempt is accepted.

### CA-41 — Capacity races do not delete a completed acquisition
If capacity was valid at attempt start but becomes unavailable before Extraction Completion, or another race condition is discovered only at finalization, Secured Ownership Finalization still completes and GDS-4 places the creature into **Overflow-Held** rather than deleting it.

### CA-42 — Existing unresolved overflow blocks ordinary further capture
While a player has unresolved Overflow-Held state caused by unavailable ordinary placement, ordinary new capture initiation remains blocked unless a later explicitly authorized special acquisition rule overrides it.

### CA-43 — Onboarding cannot start capacity-blocked
The first legitimate onboarding capture opportunity must have a valid ordinary collection destination. GDS-5/GDS-7/GDS-8 may not place a new player into a paywall or overflow state before their first secured creature.

### CA-44 — The onboarding first capture is protected from unrelated consumption
A new player's required first capture uses an **Onboarding-Protected Opportunity**: a personal, reserved, replenishing, or otherwise non-deniable opportunity such that unrelated players cannot permanently consume the only path to the first Capture Attempt/Secured Creature milestone.

Exact world spawning/placement belongs to GDS-9; the non-denial requirement is GDS-5 authority.

### CA-45 — Onboarding protection does not fabricate success
The first opportunity may be protected from other-player denial and tuned forgivingly, but the player still performs a genuine Capture Attempt and Extraction Completion. Skipping guidance cannot simply grant the creature.

### CA-46 — The first ordinary loop must satisfy GDS-1 pacing
The onboarding capture path must be compatible with first real Capture Attempt around the first minute and first Secured Creature around the first three minutes for a typical first-time player.

### CA-47 — Attempt tuning is readable before commitment
Where an attempt can consume a resource, start a meaningful cooldown, or expose meaningful risk, the player must be able to understand the relevant commitment before activation. Exact economy values belong to GDS-8.

### CA-48 — Capture challenge feedback exposes state, not hidden certainty
The player must be able to tell that an attempt is active and whether they are progressing/failing at the challenge. The game is not required to expose exact hidden probability formulas unless later GDS-6/GDS-14 design chooses to do so.

### CA-49 — Randomness cannot erase clear input semantics
If later capture tuning contains chance, the player must still understand what action they performed and what result occurred. Random outcomes cannot be presented as though an ignored/failed input caused them.

### CA-50 — Capture difficulty may vary but controls remain stable
Species, rarity, tools, progression, events, or conditions may alter difficulty, timing, windows, or number of challenge steps, but the semantic interaction vocabulary remains compatible with GDS-3.

### CA-51 — Finite opportunity finalization is single-winner by default
A normal single-award creature may emit Secured Ownership Finalization for only one player. Duplicate requests, simultaneous Secure Point entry, or repeated network delivery cannot create multiple owners/instances from one finite creature.

### CA-52 — Shared/multi-award encounters require explicit downstream authority
An event or special encounter that intentionally rewards multiple players must be defined by GDS-11 or another explicit authority. It cannot be inferred from ordinary single-creature capture rules.

### CA-53 — Server hopping cannot restore consumed single-award outcomes
Changing servers may expose different session-local opportunities, but it cannot duplicate a one-time persistent claim, reopen an already-finalized creature instance, or reset a persistent capture entitlement/cooldown.

### CA-54 — Encounter expiry during active claim must be predictable enough to be fair
A creature whose encounter lifetime can end while a valid Capture Attempt is active must not disappear without a rule players can reasonably understand. GDS-9/GDS-11 may define encounter expiry, but an accepted ordinary attempt should either finish, be explicitly interrupted with feedback, or receive a designed transition rather than silently vanish.

### CA-55 — Claim/transport state must be visible to involved players
The claimant/transporter must know whether they currently hold Engagement Claim or Transport Custody. Nearby players must not be encouraged to believe they can ordinarily capture a creature that is already validly claimed or provisionally captured.

### CA-56 — Contesting cannot rely on unrestricted chat
Eligibility, active-claim state, release, and success must be understandable without players negotiating ownership through free-form chat or voice.

### CA-57 — Failure/release transitions cannot create contradictory prompts
When a claim ends or a provisional creature is released, the previous player's interaction state must clear before another player's new valid claim can become authoritative.

### CA-58 — Desync presentation never creates ownership
A stale local visual showing a capture success, carrier, or Secure Point completion is not itself ownership. Only authoritative Secured Ownership Finalization creates the GDS-4 secured state. Technical enforcement belongs to TA.

### CA-59 — Capture and extraction avoid coercive waiting
The baseline acquisition loop must not force arbitrary long idle timers after successful player action solely to inflate session length. Difficulty should come from active pursuit/challenge/return rather than mandatory inactivity.

### CA-60 — Short sessions can complete a meaningful acquisition loop
Ordinary encounter/capture/return tuning should allow a meaningful capture or secure-return action within the GDS-1 short-session envelope where world opportunity/access permits it.

## 7. Capture Eligibility Contract

A player's ordinary Capture Eligibility may consider only rules owned or authorized by current/later design, such as:

- whether the creature is currently a Capture Opportunity;
- whether another valid Engagement Claim exists;
- whether the player already has active Transport Custody;
- whether ordinary collection capacity is known to be available;
- whether unresolved Overflow-Held state blocks ordinary new acquisition;
- whether progression/world access permits this opportunity;
- whether a later event or social rule changes eligibility;
- whether a temporary capture-tool/cooldown state permits initiation.

Eligibility itself is not ownership and must be revalidated when the attempt begins.

## 8. Capture Challenge Contract

### 8.1 Baseline structure

The exact visual minigame is intentionally not locked before presentation/technical design, but every ordinary Capture Challenge must have:

1. a clear accepted start;
2. a bounded active duration or bounded sequence of actions;
3. one or more understandable player actions/decisions;
4. visible active-state feedback;
5. a deterministic semantic end state: Success, Failure, Cancel, or Invalidation;
6. no device-exclusive core capability.

### 8.2 Difficulty inputs

Later systems may legitimately tune capture difficulty using:

- Species/content configuration;
- GDS-6 rarity/mutation/trait properties;
- GDS-8 tool/progression capability;
- encounter/event conditions;
- player execution in the Capture Challenge;
- bounded randomness if explicitly communicated at the design level.

GDS-5 does not lock formulas or numeric success rates.

### 8.3 Attempt cost boundary

If GDS-8 later defines an attempt resource/cost:

- it is committed only after the attempt has been validly accepted;
- invalid initiation cannot consume it;
- duplicate request delivery cannot consume it twice;
- success/failure/refund policy must be explicit;
- reconnect/reset cannot be used to erase an already-finalized cost.

## 9. Contesting and Claim Fairness

### 9.1 Ordinary public race

Before an Engagement Claim exists, multiple eligible players may pursue the same visible Capture Opportunity. The ordinary contest is therefore **who reaches and validly engages first**, not who can overwrite another player's already active attempt.

### 9.2 Active claim protection

During a valid Engagement Claim:

- the claimant has exclusive ordinary attempt authority;
- unrelated players cannot spend attempt costs on the same single-award creature;
- unrelated players cannot reset the claim merely through proximity;
- the claim ends on success, failure/cancel where defined, invalidation, or bounded abandonment.

### 9.3 Reopening after failure

After an attempt releases the opportunity:

- eligible players may compete again;
- the previous claimant is not guaranteed permanent priority;
- a very brief recovery/re-engagement window may be used for readability, but repeated failure/abort cannot create indefinite monopoly.

### 9.4 Special encounters

GDS-11 may later define collaborative or multi-award event captures. Such encounters must declare whether Engagement Claim is replaced, shared, queued, or otherwise modified. Ordinary semantics remain the default outside that explicit override.

## 10. Provisional Capture and Transport

### 10.1 Capture Success boundary

Capture Success means:

- the active ordinary claim resolves successfully;
- no other player can start an ordinary capture against that creature;
- the specific creature enters Provisional Capture;
- the successful player receives Transport Custody;
- the player is told that the creature is **contained/captured but not yet secured**;
- no Collection Registry ownership exists yet.

### 10.2 Transport representation

The creature may be represented physically, in a carrier/container, following the player, or through another later-approved world-facing form. Presentation may vary, but the semantic requirements remain:

- one specific provisional creature is tied to one transporter;
- it is visibly not yet fully secured;
- it cannot be silently converted into a generic token/count;
- ordinary other players cannot directly steal it;
- the transporter has a clear route/goal toward an eligible Secure Point.

### 10.3 Baseline single-custody limit

Ordinary transport supports one Provisional Capture per player. This creates a deliberate return cadence and keeps risk/feedback legible.

The player may still have any number of previously Secured Creatures allowed by downstream capacity; the one-custody rule concerns only unfinalized transport.

## 11. Extraction and Ownership Finalization

### 11.1 Secure Point contract

An eligible Secure Point must:

- be reachable through ordinary supported controls;
- clearly communicate that it can secure the current provisional creature;
- revalidate current Transport Custody;
- not require unrelated monetization to complete an already valid baseline acquisition;
- provide clear success/failure feedback.

### 11.2 Exact ordinary finalization boundary

The baseline ordinary ownership boundary is **Extraction Completion**.

```text
valid Transport Custody
  + eligible Secure Point
  + successful secure/return completion
  + authoritative revalidation
        ↓
Secured Ownership Finalization(player, creature)
        ↓
GDS-4 Secured Creature / Collection Registry
```

Before that event, the creature is not persistent player-owned collection value. After it, ordinary GDS-5 contest/transport rules no longer apply to that creature.

### 11.3 Capacity at finalization

If normal capacity is available, GDS-4 may place the new Secured Creature into the ordinary applicable state.

If capacity unexpectedly becomes unavailable after the attempt was legitimately accepted, finalization still occurs and GDS-4 uses Overflow-Held rather than deleting the creature.

This race-protection rule does not allow a player knowingly over capacity to begin unlimited ordinary capture attempts.

## 12. Interruption and Recovery Matrix

| State | Reset/avatar failure | Client disconnect | Voluntary leave | Server-originated shutdown |
|---|---|---|---|---|
| World/available | no ownership; world rules continue | no ownership | no ownership | session-local opportunity ends |
| Engagement Claim | claim ends / opportunity release or encounter rule | claim ends after short technical tolerance at most; no ownership | claim ends; no ownership | no ownership |
| Capture Attempt | interrupted; no success unless result already finalized | interrupted; no success unless result already finalized | interrupted; no ownership | no ownership unless Capture Success had already created valid Provisional Capture |
| Provisional Capture / Transport Custody | custody ends; no extraction through Recovery | enters bounded Transport Grace; expiry ends provisional state | custody ends; no ownership | orderly shutdown: Protected Shutdown Finalization exactly once when valid custody is authoritatively available; abrupt unverifiable crash: no guaranteed finalization |
| Extraction Completion finalized | already GDS-4 secured; persists | persists | persists | persists |

The matrix describes player-facing semantics. Exact tolerance durations and shutdown-detection/execution mechanisms belong to Technical Architecture.

## 13. Anti-Frustration Requirements

- do not accept an attempt when capacity/eligibility already makes success impossible;
- do not let two players unknowingly spend resources on the same ordinary single-award claim;
- do not label a Provisional Capture as permanently owned before extraction;
- do not silently invalidate a claim without feedback;
- do not allow one player to reserve a creature forever by idling or repeatedly cancelling;
- do not let other players directly steal ordinary Transport Custody by proximity;
- do not let reset/Recovery masquerade as successful extraction;
- do not delete a newly finalized creature because capacity changed mid-loop;
- do not require a new player to win an open-server race for their only tutorial opportunity;
- do not require device-specific precision for capture;
- do not force arbitrary post-capture waiting timers before a valid return can be completed.

## 14. Abuse and Exploit Cases

### 14.1 Claim griefing
Repeated start/cancel behavior may not create indefinite exclusivity. The attempt must either progress or release.

### 14.2 Reset extraction
Resetting while carrying a Provisional Capture does not secure it or transport it to the vault/Collection Registry.

### 14.3 Reconnect duplication
Reconnect cannot recreate a second Provisional Capture or repeat a Secured Ownership Finalization already completed.

### 14.4 Server-hop rerolling
Server hopping may expose different session opportunities but cannot reroll an already-finalized result, refund a finalized attempt cost, or carry an unfinalized Provisional Capture into another ordinary server.

### 14.5 Overflow farming
Known full capacity/unresolved overflow blocks ordinary new capture initiation. Overflow is race/failure protection, not infinite free storage.

### 14.6 Secure Point spam
Repeated activation at a Secure Point cannot finalize the same provisional creature multiple times.

### 14.7 Visual desync
Client-side animation/model state cannot decide capture success or ownership.

### 14.8 Shutdown spoofing
Protected Shutdown Finalization is limited to an authoritative controlled system/server-originated shutdown path. A player action that resembles leaving/reset/disconnect cannot invoke it.

## 15. Multiplayer Semantics

### Ordinary creature

1. many players may notice/pursue it;
2. one valid ordinary Engagement Claim becomes active;
3. that player resolves the Capture Attempt;
4. if failure releases it, competition may reopen;
5. if Capture Success occurs, contesting ends for that creature;
6. the capturer transports it;
7. successful extraction finalizes ownership once.

### Crowded spaces

GDS-10/GDS-9 must prevent player collision, body blocking, or social interaction rules from making ordinary valid capture/transport impossible. GDS-5 does not prescribe collision implementation, but the acquisition loop must remain operable in multiplayer crowds.

### Friends/parties

Being friends or in a party does not automatically share ownership, claims, or capture rewards. Future cooperative mechanics require explicit GDS-10/GDS-11 authority.

## 16. Onboarding Capture Contract

The onboarding sequence consumes GDS-3 and must provide:

1. a visible desirable creature/opportunity;
2. an Onboarding-Protected Opportunity that cannot be permanently denied by unrelated players;
3. a genuine Primary Interact entry into the capture mechanic;
4. a forgiving but real Capture Challenge using supported controls;
5. Capture Success creating a visibly provisional creature;
6. a short understandable route to an eligible Secure Point;
7. Extraction Completion creating the player's first genuine Secured Creature;
8. Collection/next-progression feedback owned by GDS-4/GDS-7/GDS-8/GDS-14.

The protection may be personal, reserved, rapidly replenishing, or functionally equivalent, but may not fabricate ownership without the core loop.

## 17. Accessibility and Cross-Device Requirements

- no color-only distinction between available, claimed, provisional, and secured states;
- no audio-only timing instruction;
- touch targets practical for mobile-first use;
- controller can perform every required action without pointer emulation as the only path;
- capture challenge does not require high-frequency repeated input;
- provisional/secured distinction is understandable without long text;
- exact presentation, reduced-motion behavior, haptics, text sizing, and remapping remain GDS-14 authority.

## 18. Analytics and Tuneable Parameters

GDS-16 may later instrument:

- opportunity noticed-to-engaged conversion;
- eligibility-rejection reasons;
- claim contention rate;
- accepted-attempt success/failure/cancel rate;
- time from engagement to Capture Success;
- Capture Success to Extraction Completion rate;
- transport interruption reason;
- Secure Point completion time;
- capacity-block rate;
- overflow race occurrence;
- onboarding capture completion time;
- first-attempt failure rate;
- claim abandonment/grief indicators.

Tuneable parameters may include:

- engagement range;
- claim inactivity/range tolerance;
- challenge duration/windows;
- retry/re-engagement delay;
- Transport Grace duration;
- Secure Point interaction timing;
- onboarding difficulty/route length;
- capture difficulty modifiers authorized downstream.

Experiments may tune these values but may not silently change the locked ownership boundary, baseline no-theft custody rule, single-custody baseline, capacity safety, or cross-device capability contract.

## 19. Downstream Obligations

### GDS-6 — Rarity, Mutations, Traits, and Variant Value
Must define how rarity/variant properties affect capture difficulty/readability without rerolling the instance during transport/finalization.

### GDS-7 — Vault/Base
Must provide or integrate eligible Secure Point semantics and define post-finalization placement/production behavior.

### GDS-8 — Economy/Progression
Must define capture tools, attempt costs, cooldown/progression tuning, and any later transport-capacity proposal without violating valid-attempt/single-application rules.

### GDS-9 — World
Must define spawn/encounter lifetime, world placement, pursuit routes, hazard interaction, Secure Point locations, and onboarding-protected opportunity placement consistent with active-attempt fairness.

### GDS-10 — Social
Must define collision/body-blocking/grief boundaries and any optional contest/interception modes without weakening ordinary Transport Custody or secured non-loss rules.

### GDS-11 — Events
Must explicitly declare when an event overrides ordinary single-award claim semantics with shared/multi-award participation and must preserve single-application finalization per awarded instance.

### GDS-12 — Trading
Begins only after GDS-5 finalization; Provisional Captures cannot be traded as ordinary owned creatures unless GDS-12 explicitly proposes and validates a different later feature.

### GDS-13 — Monetization
Cannot require payment to finish a capture already validly in ordinary transport or to prevent race-condition deletion at finalization.

### GDS-14 — Presentation
Must clearly distinguish eligibility, active claim, attempt, provisional transport, Secure Point, failure, interruption, and secured completion across all supported devices.

### GDS-16 — Analytics
Must measure the acquisition funnel without experiments that covertly move the ownership boundary or turn tutorial protection into a monetization gate.

### Technical Architecture
Must implement authoritative claims, attempt validation, provisional custody, disconnect grace, controlled-shutdown finalization, exact-once ownership finalization, capacity revalidation, and anti-duplication without weakening these player-facing semantics.

## 20. Open Questions

There are **zero GDS-5-blocking open questions**.

Later phases still own numeric capture rates, rarity modifiers, tool/economy values, spawn density/lifetimes, world hazards, Secure Point placement, collision/PvP rules, event overrides, final UI/audio, and technical algorithms. These are explicit downstream dependencies rather than unresolved GDS-5 behavior.

## 21. Change Control

Material changes to any of the following require reopening GDS-5 and relevant revalidation:

- Engagement Claim as the ordinary single-attempt exclusivity model;
- contesting-before-Provisional-Capture baseline;
- Capture Success producing Provisional Capture rather than immediate persistent ownership;
- one active ordinary Provisional Capture/Transport Custody per player;
- ordinary Transport Custody not being directly stealable;
- Extraction Completion as the ordinary Secured Ownership Finalization boundary;
- reset/Recovery not counting as extraction;
- deterministic bounded same-session Transport Grace for unexpected disconnect;
- controlled server-originated shutdown protection exception;
- full-capacity initiation block plus race-safe Overflow-Held finalization;
- Onboarding-Protected Opportunity requirement;
- cross-device/accessibility capture contract;
- single-winner exact-once finalization for ordinary finite opportunities.

Numeric tuning and presentation implementation do not reopen GDS-5 while these semantics remain intact.

## 22. Design Complete Checklist

- [x] scope and authority are explicit;
- [x] capture eligibility and initiation are defined;
- [x] ordinary contesting/claim semantics are defined;
- [x] capture challenge constraints are defined;
- [x] success/failure/cancel semantics are defined;
- [x] Provisional Capture and Transport Custody are defined;
- [x] extraction and exact secured-ownership boundary are defined;
- [x] capacity/overflow behavior is defined;
- [x] reset/disconnect/leave/shutdown interruption behavior is defined;
- [x] onboarding protection is defined;
- [x] anti-frustration and exploit constraints are defined;
- [x] multiplayer semantics are defined;
- [x] downstream authority boundaries are explicit;
- [x] zero GDS-5-blocking open questions remain.

**GDS-5 specification result: DESIGN COMPLETE.**
