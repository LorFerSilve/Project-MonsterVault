# Social Play, Cooperation, Competition, and PvP Boundaries

> **Status:** Design Complete  
> **Owning GDS phase:** GDS-10 — Social Play, Cooperation, Competition, and PvP Boundaries  
> **Authority:** Baseline party/friend semantics, intentional co-play, shared-objective participation, collaboration rewards, ordinary social competition, Friendly Challenges, player-to-player interference boundaries, collision/body-blocking rules, PvP/interception boundaries, Vault visitor/social showcase permissions, social coordination, grief-prevention rules, alternate-account guardrails, and social lifecycle semantics  
> **Depends on:** ../00_design_authority.md, ../01_game_overview.md, ../global_rules/02_global_game_rules_and_session_model.md, ../player/03_player_character_interaction_and_onboarding.md, ../creatures/04_creatures_collection_and_ownership.md, ../capture/05_capture_contesting_transport_and_extraction.md, ../rarity_mutations/06_rarity_mutations_traits_and_variant_value.md, ../vault/07_vault_base_passive_production_capacity_and_upgrades.md, ../economy_progression/08_economy_progression_unlocks_and_pacing.md, ../world/09_world_biomes_exploration_spawning_and_hazards.md, ../GLOSSARY.md

## 1. Purpose and Player Fantasy

MonsterVault is a multiplayer collection game, so other players should make the world feel more alive, more legible and more worth showing off in without turning ordinary play into involuntary loss, harassment, combat pressure or account-to-account value transfer.

The player-facing social contract is:

> **I can deliberately group with other players, explore and complete eligible objectives together, race fairly for still-public opportunities, show what I have earned, and opt into friendly competition without another player being able to steal my secured collection, take my Energy, body-block my route, sabotage my transport custody, or force me into combat.**

GDS-10 therefore adds meaningful social presence while preserving the closed single-owner, capture, world, rarity and economy contracts.

## 2. Scope

GDS-10 owns:

- explicit Party creation, invitation, acceptance, leaving, removal and leadership semantics;
- the relationship between Roblox friendship and MonsterVault gameplay authority;
- baseline Party size and session lifecycle;
- Party coordination through bounded Social Pings and shared waypoints;
- which world objectives may be completed cooperatively;
- personal contribution requirements for shared-objective credit;
- bounded Collaboration Rewards;
- Party interactions with Landmark Discovery, Region Mastery, Access Unlocks and hazards;
- Party interactions with ordinary capture, Engagement Claims and Transport Custody;
- public competition for still-unclaimed ordinary Capture Opportunities;
- opt-in Friendly Challenges;
- direct-combat PvP, interception, theft, forced movement and staking boundaries;
- player-player collision/body-blocking semantics;
- grief-prevention rules around Safe Arrival, Safe Outposts, Secure Points and public rare encounters;
- baseline social status and Showcase behavior;
- GDS-7 Visitor behavior and social visitor-access policy;
- social communication obligations that do not depend on unrestricted chat or voice;
- alternate-account/collusion guardrails for social rewards;
- social persistence/lifecycle behavior;
- downstream obligations for events, trading, monetization, presentation, platform safety, analytics and Technical Architecture.

## 3. Explicit Non-Goals

GDS-10 does **not** define:

- chat filtering, voice availability, reporting/blocking implementation, age-gating or moderation policy — GDS-15;
- final HUD, Party panels, icons, emotes, notification styling, accessibility presentation or input glyphs — GDS-14;
- server-wide event participation, shared-boss encounters, event-specific multi-award capture or event reward allocation — GDS-11;
- player-to-player trading, gifting, lending or ownership transfer — GDS-12;
- paid Party benefits, premium social boosts, paid matchmaking or commercial social products — GDS-13;
- persistent ranked ladders, retention campaigns, referral systems or social experimentation governance — GDS-16;
- implementation of matchmaking, teleport coordination, networking, replication, collision groups or anti-cheat — Technical Architecture;
- changing ordinary GDS-5 single-award capture into cooperative multi-owner capture;
- guilds/clans, guild banks, territorial ownership or persistent organizations at baseline;
- direct-combat PvP at baseline.

## 4. Canonical Terminology

Shared terms remain authoritative in ../GLOSSARY.md.

### Party
An explicit, consent-based temporary group of up to four players used for coordination and eligible cooperative gameplay. Party membership grants no ownership, wallet, Vault or capture authority over another member.

### Party Leader
The Party member with session-level authority to invite eligible players, remove Party members and disband the Party. Leadership is social coordination authority only.

### Party Invite
A temporary request to join a Party. It requires explicit acceptance and may be declined, ignored or expire without gameplay penalty.

### Party Seat
One occupied membership slot in a Party. A Party has a baseline maximum of four simultaneous Party Seats.

### Social Ping
A bounded predefined coordination signal visible to eligible recipients, such as a location, creature sighting, return route or objective marker. It contains no required free-text input.

### Shared Objective
An objective explicitly authored as cooperatively completable by more than one player. Party membership alone does not complete it.

### Eligible Contribution
A meaningful objective-specific action performed by one player that qualifies that player for personal Shared Objective credit or a Collaboration Reward.

### Collaboration Reward
A bounded exact-once personal reward for an eligible participant in an authorized Shared Objective. It is not a transfer from another player's wallet.

### Friendly Challenge
An explicit opt-in, non-destructive session competition between consenting players. It has no baseline wagering, creature staking, Energy staking, direct-combat damage or involuntary persistent loss.

### Showcase
A read-only social presentation of a player's legitimately owned or earned collection/progression state. Viewing a Showcase does not grant discovery or ownership.

### Visitor Access Policy
The owner's player-controlled rule determining whether their Vault may be visited in read-only mode by nobody, eligible Party/friend connections, or eligible players in the current server, subject to later platform-safety constraints.

### Party Rejoin Grace
A short same-server reservation window after an unexpected disconnect during which a former Party member may recover their Party Seat without gaining gameplay credit while absent.

## 5. Social Design Principles

### SP-01 — Social play is additive, not mandatory

A player can complete the ordinary collection/progression loop without joining a Party, using unrestricted chat, entering a Friendly Challenge or exposing their Vault publicly.

Social features may improve coordination, shared enjoyment and status expression but cannot become a mandatory gate to core progression.

### SP-02 — Social relationships do not imply gameplay authority

Being a Roblox friend, Party member, follower, visitor or challenge opponent does not by itself grant authority over another player's:

- Secured Creatures;
- Creature Locks;
- Production Assignments;
- Energy Wallet;
- Vault Upgrades;
- Access Unlocks;
- Progression Milestones;
- Engagement Claims;
- Transport Custody;
- Showcase configuration.

### SP-03 — Consent is required for grouping and challenges

Party membership and Friendly Challenges require explicit player acceptance. Friendship or proximity does not auto-enroll a player.

### SP-04 — No core dependency on unrestricted communication

The baseline social experience must remain understandable and usable without unrestricted text chat or voice.

Predefined Social Pings and world/objective feedback provide the minimum coordination layer.

### SP-05 — Social advantage cannot become hidden scarcity advantage

Party size, friend count, social engagement, invite frequency or visitor activity do not secretly modify:

- Species spawn odds;
- Mutation odds;
- Trait generation;
- Rare Encounter Stability;
- Capture success identity;
- Production rates.

Any future explicit event modifier remains GDS-11 authority and must preserve GDS-6/GDS-9 prospective-generation rules.

## 6. Party Model

### PA-01 — Party membership is explicit

A player joins a Party only by accepting a valid Party Invite or an equivalent explicit join action.

### PA-02 — Baseline Party size is four

A baseline Party supports one to four simultaneous members.

The cap keeps coordination readable on mobile screens and prevents large groups from becoming default public-world monopolies.

Changing the semantic maximum beyond four requires GDS-10 change control; UI layout within the cap belongs to GDS-14.

### PA-03 — One Party per player

A player may belong to at most one active Party at a time.

Accepting another Party Invite requires leaving the current Party first or an explicit atomic switch flow that cannot create simultaneous memberships.

### PA-04 — Party Leader authority is narrow

The Party Leader may:

- invite eligible players;
- remove members;
- transfer leadership when an explicit transfer flow exists;
- disband the Party.

The Party Leader cannot:

- spend another member's Energy;
- select another member's capture target;
- release, trade, lock or assign another member's creature;
- force another member to travel;
- bypass another member's Access Unlock;
- claim another member's reward.

### PA-05 — Leaving is always available outside modal commit boundaries

A player may leave a Party without losing finalized personal progression, collection or rewards.

If a transient shared objective or challenge is resolving, the player's eligibility follows the already-recorded contribution/challenge rules rather than allowing Party membership churn to duplicate or erase finalized value.

### PA-06 — Leader departure uses deterministic succession

When the Party Leader voluntarily leaves or becomes unavailable, leadership passes deterministically to the longest-present remaining eligible member.

If no members remain, the Party ends.

### PA-07 — Friends do not automatically become Party members

Roblox friendship may be used as one invitation/filtering signal, but friendship does not grant Party membership, visitor access, reward eligibility or gameplay authority by itself.

### PA-08 — Party membership does not bypass progression

A Party member cannot enter a locked Biome, use an undiscovered Travel Node, satisfy another member's Region Mastery, ignore capacity gating or bypass Capture Capability requirements merely because a teammate can.

### PA-09 — Party membership does not create private encounter ownership

Ordinary public World Creatures remain governed by GDS-5/GDS-9. A Party does not reserve a public Habitat, Spawn Context, Rare Encounter or ordinary Capture Opportunity.

### PA-10 — Party state is transient

Party membership, leadership, invites and Party Pings are transient social state, not permanent player progression.

Persistent personal outcomes created during Party play remain governed by their owning systems.

## 7. Party Invitations and Social Friction

### PI-01 — Invites are non-binding

Ignoring, declining or allowing a Party Invite to expire causes no penalty, reward loss or progression disadvantage.

### PI-02 — Invite spam is bounded

Party Invites use tuneable expiry, sender/recipient cooldown and duplicate-request suppression.

A sender cannot indefinitely obscure another player's screen or interaction flow through invite spam.

### PI-03 — Invite presentation cannot steal critical input focus

An incoming Party Invite may notify the player, but it cannot unexpectedly override an active Capture Attempt, transaction confirmation, Recovery action or other critical modal context.

### PI-04 — Player preference can restrict invites

Players must have a simple ability to restrict MonsterVault Party Invites at least to an allowed audience defined by later platform-safety review.

Exact labels/defaults are finalized by GDS-14/GDS-15.

## 8. Social Pings and Coordination

### PG-01 — Social Pings are predefined and bounded

Baseline Pings communicate structured intents such as:

- come here;
- creature sighting;
- objective;
- return/Secure Point;
- danger/hazard;
- wait/regroup.

They do not require arbitrary free text.

### PG-02 — Pings do not grant gameplay state

A Ping can point to a creature, Landmark, objective or route but cannot:

- create an Engagement Claim;
- reveal hidden Variant Identity not otherwise perceivable;
- grant Landmark Discovery;
- grant Region Mastery;
- complete an objective;
- reserve a spawn.

### PG-03 — Pings are rate-limited and dismissible

Recipients can suppress or mute Party Pings without losing core gameplay capability.

### PG-04 — Pings respect information authority

A Party member may signal something they observed, but the game does not fabricate secret rarity, Mutation, event or objective information solely because another player pinged it.

## 9. Cooperative Exploration

### CE-01 — Party coordination may simplify navigation, not access requirements

Party members may share waypoints, pings and intended destinations.

Every player independently satisfies region/access/travel eligibility.

### CE-02 — Landmark Discovery remains personal

A Party member receives Landmark Discovery only when they personally satisfy the GDS-9 discovery condition.

A remote Party member is not granted discovery because a teammate reached the Landmark.

### CE-03 — Region Mastery remains personal

Route Survey, Regional Collection and Field Objective requirements are evaluated per player.

Party play may help players perform an eligible activity together, but one player's historical collection or exploration is not copied to another.

### CE-04 — Hazards remain player-specific

A Party does not remove or transfer another member's hazard consequences.

Helping with navigation cannot turn one player's Recovery into another player's failure or persistent loss.

### CE-05 — Party travel is never forced

A leader or majority vote may suggest a destination, but ordinary Travel Node use remains an individual player action and still respects Acquisition-In-Progress restrictions.

## 10. Shared Objectives

### SO-01 — Only explicitly authored objectives are shared

An objective is cooperative only when its owning design marks it as a Shared Objective.

Ordinary single-player milestones do not become shared merely because Party members are nearby.

### SO-02 — Shared credit requires Eligible Contribution

Each player must perform objective-specific meaningful participation.

Raw proximity, Party membership, AFK presence, spectating or joining immediately before completion is insufficient.

### SO-03 — Contribution thresholds are legible

The objective must expose enough feedback that a reasonable player can understand whether they are participating and whether completion is pending.

Exact UI belongs to GDS-14.

### SO-04 — Completion can credit multiple eligible participants

When a Shared Objective succeeds, every eligible participant may receive their own personal completion record and authorized personal reward.

This does not imply shared creature ownership or duplicate capture finalization.

### SO-05 — Finalized personal credit is not leader-owned

A Party Leader cannot revoke another player's already-finalized Shared Objective completion or Collaboration Reward.

### SO-06 — Party churn does not duplicate one objective

Leaving/rejoining, being removed/reinvited or changing leader cannot create additional first-completion rewards for the same player/objective identity.

### SO-07 — Meeting contribution before Party removal remains meaningful

If a player already satisfied the objective's Eligible Contribution and the objective completes within its authored participation window, removal from the Party alone cannot erase their otherwise-valid personal completion/reward.

This prevents kick-at-finish griefing.

### SO-08 — Shared objectives cannot fabricate personal collection history

A teammate's capture does not grant another player Species Discovery, Mutation Discovery, Variant Discovery or Regional Collection credit unless that other player independently satisfies the authoritative rule.

## 11. Collaboration Rewards and Economy

### CR-01 — Collaboration Rewards are bounded active-play rewards

An authorized Shared Objective may grant a personal Collaboration Reward such as a bounded amount of Energy.

The reward is an Economy Source from the game, not a transfer between players.

### CR-02 — No reward for grouping alone

Creating/joining a Party, remaining near friends, sending Pings or visiting a Vault grants no baseline Energy or Progression Milestone by itself.

### CR-03 — Rewards are exact-once per eligible player/objective

Retries, reconnects, Party churn and duplicate completion messages cannot duplicate the same finalized Collaboration Reward.

### CR-04 — Energy remains non-transferable

No Party wallet, pooled Energy, direct member-to-member Energy transfer or leader-controlled spending exists at baseline.

### CR-05 — Party size does not automatically multiply reward magnitude

Per-player reward values are authored and bounded. A larger Party does not automatically grant each member a multiplicative reward bonus.

### CR-06 — Passive production is unaffected

Party membership, friendship, visitor count and social activity do not automatically modify Production Slots, Production Profiles, Passive Production rates, Production Buffer size or Offline Production Window.

### CR-07 — Collaboration rewards require active anti-carry semantics

A player cannot earn repeated collaboration value by operating idle alternate accounts that contribute no meaningful objective action.

Exact detection belongs to Technical Architecture, but the intended gameplay rule is no AFK/zero-contribution reward.

## 12. Ordinary Capture in Social Play

### CP-01 — Ordinary capture remains single-award

A normal finite World Creature still supports one ordinary Engagement Claim and at most one ordinary Secured Ownership Finalization.

Party membership does not create a multi-winner ordinary capture.

### CP-02 — Public competition exists before a valid claim

Several players, including Party members, may notice and approach the same still-unclaimed public Capture Opportunity.

The first valid Engagement Claim is resolved by GDS-5 rules, not friendship, Party leadership, premium status or visitor status.

### CP-03 — Party membership does not share an Engagement Claim

The claimant alone owns the ordinary capture attempt authority.

Other Party members cannot submit capture input on the claimant's behalf unless a later explicitly authorized encounter type defines different semantics.

### CP-04 — Active claims cannot be stolen by social status

Party leaders, friends, higher-progress players and premium players cannot overwrite another player's valid ordinary Engagement Claim.

### CP-05 — Transport Custody remains exclusive

After Capture Success, the Provisional Capture belongs to one player's Transport Custody.

A teammate cannot:

- take over custody;
- hand off the creature;
- extract it for the carrier;
- duplicate it;
- force it to another player.

### CP-06 — Escorting is social, not ownership

Party members may physically travel with a carrier, point out routes or avoid hazards together, but baseline escort presence grants no automatic creature copy, discovery or Energy reward.

An explicit downstream Shared Objective may reward legitimate escort-like activity only when separately authored without changing custody.

### CP-07 — Capacity remains individual

One member's free Collection Capacity, Overflow state or Vault Upgrade cannot satisfy another member's capture eligibility.

### CP-08 — Viewing another member's capture does not grant discovery

Species/Mutation/Variant Discovery remains tied to legitimate Secured Ownership Finalization for the relevant player.

## 13. Player Competition

### PC-01 — Ordinary public pursuit is the baseline competitive tension

Competition may arise naturally because multiple players can seek the same still-public creature, route or objective before exclusive state is established.

### PC-02 — Competition cannot invalidate closed ownership rules

Competitive pressure ends where GDS-5/GDS-4 exclusive state begins.

A player cannot win by taking another player's:

- valid Engagement Claim;
- Provisional Capture;
- Transport Custody;
- Secured Creature;
- Energy;
- persistent unlock.

### PC-03 — Friendly Challenges are explicit opt-in

A Friendly Challenge begins only after every participating player explicitly accepts a visible challenge definition.

### PC-04 — Friendly Challenges are non-destructive

Baseline Friendly Challenges may compare route time, movement, exploration or other compatible skill/performance results, but cannot:

- inflict direct combat damage;
- steal or stake creatures;
- stake or transfer Energy;
- revoke progression;
- force Release;
- create debt;
- remove Access Unlocks.

### PC-05 — No baseline wagering

MonsterVault does not support betting, staking or winner-takes-player-assets behavior in Friendly Challenges.

### PC-06 — Challenge rewards are status-first at baseline

The baseline Friendly Challenge outcome may create session-visible result/status feedback but grants no recurring Energy farming loop or permanent competitive power.

Any persistent/ranked/rewarded competition requires its owning later phase and GDS-10 revalidation where it changes these boundaries.

### PC-07 — Progression asymmetry must be legible

A Friendly Challenge cannot silently treat unequal region access, traversal unlocks or other meaningful capabilities as equivalent.

Challenge eligibility/rules must either normalize the relevant capability, limit eligibility or clearly expose the difference before acceptance.

## 14. PvP and Interception Boundaries

### PV-01 — No baseline direct-combat PvP

Ordinary MonsterVault play has no player-caused damage, knockback, stun, grapple, forced movement or combat defeat loop between Player Characters.

### PV-02 — No ordinary transport interception

Another player cannot attack, tag, collide with or otherwise seize a valid Provisional Capture from its carrier.

### PV-03 — No secured-creature theft

No social action, challenge, collision, visit, Party action or PvP-like interaction can involuntarily transfer or delete a Secured Creature.

### PV-04 — No player-caused Energy loss

Ordinary social competition cannot directly deduct, steal, drop or transfer another player's Energy.

### PV-05 — No forced tool or input suppression

One player cannot disable another player's ordinary movement, Primary Interact, Primary Action or capture capability through baseline social mechanics.

### PV-06 — Future PvP requires explicit change control

Any future combat, interception, theft-risk or contested-custody mode requires a material GDS-10 change, explicit opt-in/containment semantics, GDS-4/GDS-5 revalidation, and later platform-safety review.

GDS-10 baseline does not pre-authorize such a mode.

## 15. Collision and Body-Blocking

### CB-01 — Players are non-obstructive to ordinary traversal

Baseline Player Characters cannot physically trap, pin or body-block one another from using ordinary Safe Routes, Secure Points, Recovery Anchors, Travel Nodes, Vault Access Points or encounter interactions.

Technical collision-group implementation belongs to Technical Architecture.

### CB-02 — Player overlap cannot steal Active Context

Another player's avatar occupying the same space cannot deliberately make a valid world interaction permanently untargetable.

Final targeting/prompt rules belong to GDS-14/Technical Architecture, but the semantic requirement is access to the intended world interaction.

### CB-03 — Crowding cannot change claim authority

Visual crowding around a rare creature or Secure Point does not grant claim priority and cannot cancel another player's valid claim/custody.

### CB-04 — Safe Arrival and Recovery remain non-trappable

A recovering or newly arrived player must be able to regain direct control and leave the immediate arrival area without another player physically imprisoning them.

## 16. Grief Prevention

### GP-01 — Onboarding protection remains stronger than social competition

An Onboarding-Protected Opportunity cannot be consumed, reserved or griefed by unrelated players or Party members merely through proximity or social interaction.

### GP-02 — Invite/ping spam is not a gameplay weapon

Repeated invites, pings or challenge requests are bounded and suppressible.

### GP-03 — Claim cycling cannot reserve public content indefinitely

GDS-5 claim timeout/inactivity semantics remain active regardless of Party membership. Party members cannot rotate invalid claims merely to hold a creature for their group.

### GP-04 — Parties cannot monopolize spawn generation

Party presence does not increase private spawn ownership, extend a public encounter indefinitely or create exclusive Habitat reservation.

### GP-05 — Kicking cannot confiscate finalized value

Removing a member cannot revoke their finalized captures, Energy, milestones, unlocks or eligible already-earned objective outcome.

### GP-06 — Social features cannot force destructive actions

No Party, visitor or challenge flow can silently trigger Release, unlock Creature Lock, change Production Assignment, purchase an upgrade or accept a future trade for another player.

## 17. Showcase and Social Status

### SH-01 — Showcases reference legitimate state

A Showcase may present owned Secured Creatures, GDS-7 Display choices or approved earned progression/status.

It cannot fabricate ownership, rarity, Mutation, Provenance, Mastery or event history.

### SH-02 — Showcase is read-only to observers

Viewing or inspecting another player's Showcase does not:

- grant Species/Mutation/Variant Discovery;
- create ownership;
- change Creature Lock;
- create Production Assignment;
- produce Energy;
- reserve a future trade;
- create claim authority.

### SH-03 — Showcase does not duplicate Creature Instances

A showcased creature is a reference/presentation of the same underlying Secured Creature, not another owned copy.

### SH-04 — Invalid showcase references reconcile safely

If a showcased creature later ceases to be eligible for display through an explicitly authorized future action, the Showcase reference clears or becomes unavailable without recreating the creature.

### SH-05 — Status is informative, not progression authority

Titles, badges or similar social status surfaces may represent already-earned facts, but equipping/showing them does not grant hidden spawn odds, capture priority or economy power.

## 18. Vault Visitors

### VV-01 — Visitor mode remains read-only

GDS-10 does not expand GDS-7 baseline visitors into management authority.

A Visitor cannot:

- move/store/release/lock a creature;
- change Production Assignments;
- claim Production Buffer;
- spend Energy;
- buy Vault Upgrades;
- alter display configuration;
- transfer ownership.

### VV-02 — Owner controls visitor audience

The Vault owner has a Visitor Access Policy with at least the semantic states:

- Closed;
- eligible Party/friend audience;
- eligible current-server audience.

GDS-15 may further restrict availability/defaults for platform or age safety.

### VV-03 — Revocation is immediate from the owner's perspective

Changing a Visitor Access Policy or ending an explicit visitor session prevents new visitor interactions promptly and cannot strand ownership state in an ambiguous shared-authority condition.

### VV-04 — Visit observation grants no discovery

Merely seeing a creature in another player's Vault never grants Species Discovery, Mutation Discovery or Variant Discovery.

### VV-05 — Visitors cannot block the owner

Visitor presence cannot prevent the owner from accessing their own Vault, Secure Point or management interactions.

## 19. Social Communication and Safety Boundary

### SC-01 — Core coordination is communication-light

Party formation, Shared Objectives, Pings, challenge acceptance and visitor access must not require unrestricted chat or voice.

### SC-02 — Predefined Pings are the baseline game-owned communication channel

They are semantic signals, rate-limited and suppressible.

### SC-03 — Platform communication remains downstream authority

Whether text chat, voice, private messaging or user-generated text appears and under what safety constraints is owned by GDS-15/Roblox platform rules.

### SC-04 — No design depends on harassment-prone custom naming

GDS-10 introduces no required free-form Party names, challenge names, creature messages or visitor notes.

If later allowed, they require GDS-15/GDS-14 authority.

## 20. Lifecycle, Disconnect and Recovery

### LC-01 — Avatar reset does not dissolve Party membership

Party membership is associated with the player within the social session, not the current avatar body.

Reset/Recovery does not automatically leave the Party.

### LC-02 — Unexpected disconnect may reserve a Party Seat briefly

A tuneable Party Rejoin Grace may preserve the disconnected member's seat for a short same-server return window.

The absent player receives no raw-presence objective/reward credit during the disconnect.

### LC-03 — Leadership cannot be frozen by disconnect

If the current leader disconnects/becomes unavailable, leadership passes deterministically to an eligible remaining member rather than blocking Party management.

A returning prior leader does not automatically seize leadership back.

### LC-04 — Voluntary server departure ends ordinary Party membership

Leaving the experience/server ordinarily ends transient Party membership.

Cross-server Party reconstruction, if later implemented, must preserve explicit consent and cannot become persistent progression.

### LC-05 — In-progress social credit follows objective authority

Disconnect/reconnect cannot duplicate a Shared Objective completion or Collaboration Reward.

### LC-06 — Recovery does not fabricate contribution

A player entering Recovery remains a Party member when applicable but does not receive objective credit merely for being in Recovery.

### LC-07 — Friendly Challenge interruption is non-destructive

If a participant leaves, disconnects, resets or becomes ineligible, the challenge ends/cancels or resolves according to its declared non-destructive rules without asset loss.

## 21. Persistence Expectations

Persistent player state introduced or referenced by GDS-10 is limited to finalized personal facts/preferences that genuinely need to survive sessions, such as:

- an authorized persistent Showcase selection/reference;
- Visitor Access Policy when the product chooses to persist it;
- finalized Shared Objective/Progression Milestone outcomes where the owning objective is persistent;
- finalized Collaboration Rewards already entered into Energy;
- downstream legitimate status/badge facts.

The following are baseline transient social state:

- Party membership;
- Party leadership;
- pending Party Invites;
- Social Pings;
- Party shared waypoints;
- active Friendly Challenges;
- pending challenge invitations;
- unfinalized shared-objective contribution windows unless the owning objective explicitly persists them.

## 22. Alternate Accounts, Collusion and Abuse

### AA-01 — No direct social value funnel

Energy and creature ownership are not directly transferable through GDS-10, so Party play cannot be used as a baseline account-to-account wealth funnel.

### AA-02 — Alt presence is not contribution

Multiple idle accounts in a Party do not generate Collaboration Rewards.

### AA-03 — Social rewards are bounded by personal eligibility

Each account must independently satisfy Eligible Contribution and exact-once reward rules.

### AA-04 — Party size does not boost scarcity

Adding alternate accounts cannot increase Species/Mutation odds, create more private Rare Encounters or reroll existing World Creatures.

### AA-05 — Collusion cannot override single-winner capture

Players may intentionally allow a friend to pursue a creature, but they cannot use Party mechanics to duplicate the finalization or transfer an active claim/custody outside GDS-5.

### AA-06 — Friendly Challenges cannot be farmed for baseline currency

Baseline Friendly Challenges do not create a repeatable Energy or player-value transfer loop.

### AA-07 — Visitor traffic is not an economy source

Repeatedly visiting or viewing another Vault does not mint Energy or progression for either party.

## 23. Monetization Interactions

GDS-10 authorizes no paid social product.

Any GDS-13 monetization proposal must preserve at minimum:

- no paid claim priority;
- no paid ability to steal/intercept Transport Custody;
- no paid direct-combat advantage because baseline combat PvP does not exist;
- no payment required to join ordinary Parties;
- no paid increase beyond the baseline Party cap that creates gameplay reward/spawn advantage;
- no paid social feature that grants hidden rarity/Mutation odds;
- no payment required to suppress harassment/spam;
- no paid visitor authority over another player's Vault;
- no premium bypass of personal Access Unlock/Region Mastery requirements.

## 24. Analytics and Experimentation Boundaries

Design-relevant social metrics include:

- Party Invite send/accept/decline/expiry rate;
- Party creation and average Party size;
- time spent in Party;
- Shared Objective participation/completion;
- eligible-contribution failure rate;
- Collaboration Reward distribution;
- Party churn around objective completion;
- Social Ping use/mute rate;
- Friendly Challenge invitation/acceptance/completion;
- visitor-access policy use and Vault visits;
- public rare-encounter contention rate;
- claim failure/claim cycling patterns;
- reports of obstruction/invite spam/social friction when downstream reporting exists;
- solo-versus-Party progression time without treating one as mandatory.

Experiments may tune:

- invite expiry and rate limits;
- Ping cooldowns;
- Party Rejoin Grace duration;
- Shared Objective contribution thresholds;
- Collaboration Reward quantities;
- challenge timeouts;
- visitor prompt frequency;
- presentation/order of social controls.

Experiments may **not**:

- silently change Party size above four;
- create direct player value transfer;
- alter claim/custody authority;
- enable combat PvP;
- allow body-blocking;
- give hidden rarity/spawn advantages to social players;
- fabricate contribution for AFK accounts;
- revoke finalized ownership/progression;
- make unrestricted chat mandatory.

## 25. Tuneable Parameters

The following may be tuned without reopening GDS-10 when semantic rules remain intact:

- Party Invite expiry;
- invite duplicate suppression/cooldown;
- Social Ping cooldown and per-window limits;
- Party Rejoin Grace duration;
- Shared Objective participation windows;
- objective-specific Eligible Contribution thresholds;
- Collaboration Reward Energy quantities;
- Friendly Challenge invitation/ready timeout;
- visitor-session timeout;
- non-authoritative social presentation details.

The following are semantic and are **not** merely tuneable:

- explicit consent for Party/challenge membership;
- maximum baseline Party size of four;
- no shared ownership/wallet;
- personal progression/access requirements;
- single-award ordinary capture;
- exclusive claimant/custody authority;
- no baseline direct-combat PvP;
- no ordinary interception/theft;
- non-obstructive player collision requirement;
- no wagering;
- no discovery from viewing;
- no AFK/grouping-only Collaboration Reward.

## 26. Dependencies and Downstream Obligations

### GDS-11 — Server Events, Dynamic Encounters and Live Content

May define server-wide cooperative objectives, event participation, event-specific multi-award capture or shared reward semantics.

Any event exception to ordinary single-award capture must be explicit and cannot silently rewrite normal GDS-5/GDS-10 behavior.

### GDS-12 — Trading and Player Economy

Owns any explicit transfer/gift/trade of Secured Creatures and any decision to change Energy transferability.

Party, friendship, Showcase or Visitor status is not an implicit transfer mechanism.

### GDS-13 — Monetization

Must review any paid social, convenience, Party or competition proposal against consent, no-claim-priority, no hidden scarcity advantage and non-premium core co-play.

### GDS-14 — Presentation, UI/UX, Feedback and Accessibility

Must make Party state, invites, contribution eligibility, Ping source, challenge consent, claim ownership/custody, visitor state and suppression/mute controls understandable across supported inputs without relying only on color/audio.

### GDS-15 — Roblox Platform, Social Safety and Moderation

Must define platform communication, reporting/blocking, privacy/default audience, age-appropriate social exposure and moderation constraints.

It may further restrict GDS-10 social availability but cannot silently grant other players authority over ownership/economy.

### GDS-16 — Retention, Discovery, Analytics and Experimentation

May define social return loops, referrals, persistent rankings or experiments only within GDS-10 consent/fairness/value-integrity boundaries.

### Technical Architecture

Must implement secure Party membership, invitation rate limiting, contribution/reward idempotency, collision/non-interference semantics, session-state cleanup, visitor authorization, social state replication and anti-abuse validation without weakening GDS-10 player-facing rules.

## 27. Edge-Case Matrix

| Situation | Required behavior |
|---|---|
| Friend joins same server | no automatic Party membership or authority |
| Party Invite ignored | expires/no penalty |
| Invite arrives during Capture Attempt | cannot steal critical input focus |
| Player already in a Party accepts another invite | explicit leave/switch required; never two Parties |
| Party reaches four members | additional join blocked until seat available |
| Leader leaves | deterministic eligible successor |
| Leader disconnects | leadership moves; Party remains functional |
| Disconnected member returns within grace | may recover reserved seat; no absent-time reward credit |
| Member resets avatar | Party membership may remain |
| Member changes server | ordinary transient Party membership ends |
| Party enters locked region | locked member remains blocked |
| Leader fast-travels | other members are not forcibly teleported |
| Party member finds Landmark | only personally eligible players receive discovery |
| Teammate captures new Species | no discovery for observers |
| Shared Objective starts | only authored cooperative objective shares participation |
| AFK member nearby | no Eligible Contribution/no reward |
| Member contributes then is kicked before completion | valid contribution cannot be erased solely by kick |
| Member leaves/rejoins around completion | no duplicate first-completion reward |
| Collaboration Reward retries | one finalized reward maximum |
| Four-player Party completes objective | each eligible player may receive bounded personal reward; no multiplier from Party size |
| Party member has enough Energy for another's unlock | cannot pay/transfer by GDS-10 |
| Party observes public rare spawn | spawn remains public/unreserved until valid claim |
| Two Party members race same creature | ordinary claim rules decide one claimant |
| Non-Party player wins claim | Party cannot override it |
| Teammate tries capture input on claimed creature | no shared claimant authority |
| Carrier has Provisional Capture | teammate cannot take/handoff/extract it |
| Carrier hits hazard/Recovery | GDS-5 interruption applies; Party cannot rescue ownership by transfer |
| Teammates escort carrier | social coordination only unless separate authored objective |
| Player crowd surrounds creature | crowding cannot alter claim authority |
| Players crowd Secure Point | cannot body-block extraction interaction |
| Player stands on Recovery Anchor | cannot trap recovering player |
| Visitor enters Vault | read-only authority |
| Visitor sees Legendary | no Species/Variant Discovery |
| Visitor tries Production Claim | denied; owner-only |
| Owner closes visitor access | no new visitor authority; state remains owner-controlled |
| Showcase creature is later invalidated by authorized future transfer/release | showcase reference safely clears; no recreation |
| Friendly Challenge invite declined | no penalty |
| Challenge starts without all consent | invalid |
| Challenge participant disconnects | non-destructive cancel/declared resolution |
| Challenge loser | no creature/Energy stake loss |
| Challenge winner | baseline status result only; no repeatable Energy farm |
| Player attempts direct combat | baseline mechanic unavailable |
| Player attempts knockback/body-block | baseline social rules do not permit it |
| Player tries to steal Transport Custody | unavailable |
| Player tries to steal Energy | unavailable |
| Party spam-invites player | bounded/suppressible |
| Party spam-pings player | bounded/muteable |
| Party cycles claims to reserve public creature | bounded GDS-5 claim rules prevent indefinite reservation |
| Alt accounts join Party idle | no collaboration reward |
| Alt accounts increase Party size | no spawn/rarity probability boost |
| Party visitor count increases | no Vault production boost |
| Premium player contests opportunity | no paid claim priority from GDS-10 |
| Protected Load Failure | irreversible personal progression/economy actions remain blocked; social state cannot fabricate trusted progress |

## 28. Open Questions

There are **zero GDS-10-blocking open questions**.

Exact Party UI, iconography, friend/visitor privacy defaults after platform review, Social Ping visuals, Shared Objective catalog, Collaboration Reward quantities, Friendly Challenge catalog, moderation/reporting behavior, event-specific cooperative exceptions, trading, monetization and technical networking/collision implementation are downstream authority or tuneable content rather than unresolved GDS-10 semantics.

## 29. Design-Complete Checklist

- [x] Purpose and scope are explicit.
- [x] Social consent boundaries are explicit.
- [x] Party membership/leadership/lifecycle are deterministic.
- [x] Friendship grants no implicit gameplay authority.
- [x] Cooperative exploration and personal progression boundaries are defined.
- [x] Shared Objective contribution and reward rules are defined.
- [x] Ordinary capture remains compatible with GDS-5.
- [x] Competition is defined without asset loss.
- [x] Direct-combat PvP/interception/theft boundaries are explicit.
- [x] Collision/body-blocking behavior is explicit.
- [x] Grief-prevention and alt-account cases are addressed.
- [x] Showcase and Visitor authority are defined.
- [x] Social coordination does not require unrestricted chat/voice.
- [x] Persistence/session-state expectations are defined.
- [x] Economy/monetization boundaries are consistent.
- [x] Downstream authority is preserved.
- [x] Edge cases are covered.
- [x] No implementation-relevant open questions remain.
