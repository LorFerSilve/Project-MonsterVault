# GDS-10 Decision Index

> **Phase:** GDS-10 — Social Play, Cooperation, Competition, and PvP Boundaries  
> **Status:** Accepted  
> **Purpose:** Phase-local record of strategic GDS-10 decisions and rationale. Detailed behavior remains authoritative in social/10_social_play_cooperation_competition_and_pvp_boundaries.md.

## GDS10-D01 — Parties Are Explicit, Temporary Coordination Groups With No Shared Ownership

**Status:** Accepted

### Context

MonsterVault needs intentional co-play, but treating friendship or Party membership as shared ownership would conflict with GDS-4 one-owner semantics, GDS-5 capture authority and GDS-8 non-transferable Energy.

### Decision

A baseline Party is an explicit consent-based group of up to four players.

Party membership grants coordination capabilities only. It creates no shared:

- Creature ownership;
- Energy Wallet;
- Vault authority;
- Progression Milestones;
- Access Unlocks;
- Engagement Claims;
- Transport Custody.

A player belongs to at most one Party at a time.

### Rationale

This gives players a predictable social group without introducing hidden co-ownership, account-to-account value transfer or large-group public-world monopolies.

### Alternatives Rejected

- automatic Party membership from friendship;
- guild-sized baseline Parties;
- Party-shared collection ownership;
- Party-shared wallet;
- leader authority over member assets.

### Affected Specifications

GDS-2, GDS-4, GDS-5, GDS-7 through GDS-16, Technical Architecture.

---

## GDS10-D02 — Cooperative Progress Requires Personal Meaningful Contribution

**Status:** Accepted

### Context

If Party membership or proximity alone granted objective completion/rewards, social play would become an AFK/alt-account carry mechanism and could fabricate active Progression Milestones.

### Decision

Only explicitly authored Shared Objectives support cooperative completion. Each credited player must independently satisfy an objective-specific Eligible Contribution.

Raw Party membership, spectating, AFK presence or last-second joining is insufficient.

Once valid contribution is made, Party removal alone cannot erase otherwise-valid completion if the objective completes within its participation window.

### Rationale

Cooperation stays useful while each player's progress still represents actual participation and leaders cannot grief contributors by kicking them immediately before completion.

### Alternatives Rejected

- proximity-only shared credit;
- leader-owned reward allocation;
- full Party credit for one player's action;
- kick-at-finish reward denial;
- AFK Party reward accrual.

### Affected Specifications

GDS-8 through GDS-11, GDS-16, Technical Architecture.

---

## GDS10-D03 — Ordinary Capture Remains One Claim, One Custody, One Winner

**Status:** Accepted

### Context

Parties naturally make players want to hunt together, but changing ordinary capture into Party-shared ownership would invalidate the already-closed GDS-5 acquisition contract.

### Decision

Ordinary finite Capture Opportunities remain single-award.

Party members may coordinate discovery, routes and escort-like movement, but:

- one valid Engagement Claim owns the attempt;
- other members do not share capture input authority;
- one player holds Transport Custody;
- custody cannot be handed off;
- teammates cannot extract for the carrier;
- one ordinary Secured Ownership Finalization occurs.

Event-specific cooperative/multi-award capture, if any, remains GDS-11 authority.

### Rationale

Party play improves coordination without weakening instance identity, claim fairness or exact single-winner finalization.

### Alternatives Rejected

- Party-wide Engagement Claim;
- automatic creature copies for Party members;
- teammate custody transfer;
- Party leader claim priority;
- observer discovery from teammate capture.

### Affected Specifications

GDS-4 through GDS-6, GDS-9 through GDS-14, Technical Architecture.

---

## GDS10-D04 — Baseline PvP Does Not Include Combat, Interception, Theft or Player-Caused Persistent Loss

**Status:** Accepted

### Context

The product is socially competitive but explicitly non-loss-dominant and has no direct-combat PvP requirement. Adding ordinary combat/interception would change transport, ownership and safety expectations substantially.

### Decision

Baseline ordinary play does not allow players to:

- damage, knock back, stun, grapple or force-move one another;
- seize another player's valid Transport Custody;
- steal or destroy a Secured Creature;
- steal/deduct another player's Energy;
- force Release or progression loss.

Any future PvP/interception mode requires explicit GDS-10 change control, GDS-4/GDS-5 revalidation and later platform-safety review.

### Rationale

Social tension remains readable and competitive without making ordinary collection value vulnerable to hostile players.

### Alternatives Rejected

- open-world combat;
- transport stealing;
- creature theft;
- Energy drops on player defeat;
- forced PvP zones in core progression.

### Affected Specifications

GDS-1, GDS-4, GDS-5, GDS-8 through GDS-15.

---

## GDS10-D05 — Player Collision Cannot Be Used to Body-Block Gameplay

**Status:** Accepted

### Context

Even without explicit PvP tools, physical avatar collision can become de facto PvP by blocking Safe Routes, Secure Points, Recovery Anchors or rare creatures.

### Decision

Baseline Player Characters are semantically non-obstructive to one another for ordinary traversal and world interaction.

Players cannot physically trap or body-block one another from:

- Safe Routes;
- Secure Points;
- Recovery Anchors;
- Travel Nodes;
- Vault Access Points;
- intended encounter interactions.

Exact collision-group implementation belongs to Technical Architecture.

### Rationale

This removes a common grief vector while preserving crowded social presence visually.

### Alternatives Rejected

- fully blocking player collision;
- collision-enabled choke-point competition;
- premium anti-collision pass;
- allowing crowds to deny extraction.

### Affected Specifications

GDS-3, GDS-5, GDS-9, GDS-10, GDS-14, Technical Architecture.

---

## GDS10-D06 — Social Competition Is Pre-Claim or Explicitly Opt-In and Non-Destructive

**Status:** Accepted

### Context

MonsterVault benefits from visible competition, but winner-takes-assets or forced PvP would conflict with the product contract.

### Decision

Baseline competition takes two forms:

1. natural public pursuit before a valid Engagement Claim exists;
2. explicit opt-in Friendly Challenges.

Friendly Challenges have no baseline wagering, creature staking, Energy staking, direct-combat damage or involuntary persistent loss. Their default outcome is session-visible status/result feedback rather than a repeatable currency farm.

### Rationale

Players get race/status tension without gambling, asset transfer or hostile-loss pressure.

### Alternatives Rejected

- forced open-world challenges;
- creature/energy wagers;
- ranked combat as a core gate;
- repeatable challenge farming for Energy;
- Party leader forcing members into competition.

### Affected Specifications

GDS-1, GDS-5, GDS-8, GDS-10, GDS-13 through GDS-16.

---

## GDS10-D07 — Collaboration Rewards Are Personal, Bounded and Exact-Once

**Status:** Accepted

### Context

Cooperative objectives should feel worthwhile, but social rewards can easily become inflationary or exploitable through Party churn and alternate accounts.

### Decision

An authorized Shared Objective may grant a bounded personal Collaboration Reward after Eligible Contribution.

The reward:

- is game-originated rather than transferred from another player;
- finalizes exact-once per eligible player/objective;
- is not granted for grouping/proximity alone;
- does not automatically increase with Party size;
- does not alter passive production or rarity/spawn odds.

### Rationale

Cooperation can be economically meaningful without creating a Party wallet, alt funnel or social multipliers that make solo play economically nonviable.

### Alternatives Rejected

- Party-wide pooled wallet;
- automatic Party-size reward multiplier;
- Energy for simply staying grouped;
- visitor-count production bonus;
- social rare-spawn bonus.

### Affected Specifications

GDS-7 through GDS-11, GDS-13, GDS-16, Technical Architecture.

---

## GDS10-D08 — Vault Socialization Is Owner-Controlled and Read-Only

**Status:** Accepted

### Context

The Vault should support status/flexing, but GDS-7 already locks ownership and visitor authority as read-only.

### Decision

GDS-10 keeps Visitor authority read-only and adds an owner-controlled Visitor Access Policy.

Showcases/visits may expose legitimate collection/progression presentation, but observers cannot:

- mutate Vault state;
- claim production;
- spend Energy;
- alter creature state;
- gain Species/Mutation/Variant Discovery merely by viewing.

### Rationale

Players can display meaningful collection value without creating shared-management or observation-based progression exploits.

### Alternatives Rejected

- public visitor management rights;
- visitor-triggered discovery;
- views as Energy source;
- Party leader Vault control;
- showcase copies of Creature Instances.

### Affected Specifications

GDS-4, GDS-6 through GDS-10, GDS-12, GDS-14, GDS-15.

---

## GDS10-D09 — Core Social Coordination Does Not Depend on Unrestricted Chat or Voice

**Status:** Accepted

### Context

The primary audience includes younger players and GDS-1 already requires core progression not to depend on unrestricted communication.

### Decision

Parties, Shared Objectives and coordination must remain viable through structured game-owned Social Pings, waypoints and state feedback.

GDS-10 introduces no required free-form Party names, challenge names, visitor notes or other custom-text dependency.

Text/voice/reporting/moderation behavior remains GDS-15 authority.

### Rationale

This preserves cross-platform usability and avoids making unrestricted communication a gameplay prerequisite before platform-safety design is complete.

### Alternatives Rejected

- voice-required objectives;
- text-chat-only Party coordination;
- unrestricted custom social naming as a required mechanic;
- progression gated behind messaging.

### Affected Specifications

GDS-1, GDS-3, GDS-10, GDS-14, GDS-15.

---

## GDS10-D10 — Close GDS-10 Social Play, Cooperation, Competition, and PvP Boundaries

**Status:** Accepted

### Context

The authoritative GDS-10 specification now resolves Party consent/authority/lifecycle, cooperative exploration, Shared Objective contribution, Collaboration Rewards, ordinary capture social semantics, competition, Friendly Challenges, direct-PvP/interception boundaries, collision/body-blocking, grief prevention, Showcase/Visitor behavior, communication constraints, persistence and alternate-account abuse. Scenario and cross-system validation pass.

### Decision

GDS-10 is formally closed as Complete — PASS.

Material changes to:

- Party explicit consent or baseline maximum size;
- no shared ownership/wallet;
- personal access/progression requirements;
- personal contribution requirement for cooperative rewards;
- ordinary single-award capture;
- no custody handoff/interception;
- no baseline direct-combat PvP;
- non-obstructive player collision;
- no wagering;
- visitor read-only authority;
- no discovery from observation;
- no hidden social rarity/spawn advantage;
- no unrestricted-chat dependency

require GDS-10 change control and revalidation.

### Evidence

- social/10_social_play_cooperation_competition_and_pvp_boundaries.md — Design Complete;
- GDS10_SCENARIO_VALIDATION.md — 110 / 110 PASS;
- GDS10_CROSS_VALIDATION.md — PASS;
- GDS10_CLOSURE_REPORT.md — PASS.

### Consequence

The active dependency advances to **GDS-11 — Server Events, Dynamic Encounters, and Live Content**. Technical Architecture and gameplay implementation remain blocked.
