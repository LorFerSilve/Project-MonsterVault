# Retention, Discovery, Analytics, and Experimentation Boundaries

> **Status:** Design Complete  
> **Owning GDS phase:** GDS-16 — Retention, Discovery, Analytics, and Experimentation Boundaries  
> **Authority:** First-session/return-session funnels, session satisfaction, retention philosophy, goal surfacing, return loops, live-content cadence philosophy, notification boundaries, discovery packaging, analytics taxonomy, cohorting, experiment governance, metric hierarchy, value-affecting experiment constraints, catch-up philosophy, and anti-manipulation guardrails  
> **Depends on:** ../00_design_authority.md, ../01_game_overview.md, ../product/success_criteria_and_product_gates.md, ../product/session_shape_and_experience_promise.md, ../global_rules/02_global_game_rules_and_session_model.md, ../player/03_player_character_interaction_and_onboarding.md, ../creatures/04_creatures_collection_and_ownership.md, ../capture/05_capture_contesting_transport_and_extraction.md, ../rarity_mutations/06_rarity_mutations_traits_and_variant_value.md, ../vault/07_vault_base_passive_production_capacity_and_upgrades.md, ../economy_progression/08_economy_progression_unlocks_and_pacing.md, ../world/09_world_biomes_exploration_spawning_and_hazards.md, ../social/10_social_play_cooperation_competition_and_pvp_boundaries.md, ../events_liveops/11_server_events_dynamic_encounters_and_live_content.md, ../trading/12_trading_and_player_economy.md, ../monetization/13_monetization_and_commercial_fairness.md, ../presentation/14_presentation_ui_ux_feedback_and_accessibility.md, ../platform_safety/15_roblox_platform_social_safety_and_moderation_constraints.md, ../GLOSSARY.md

## 1. Purpose and Product-Health Promise

MonsterVault is intended to retain players because the collection fantasy, visible progression, world opportunities and social stories remain desirable over time.

GDS-16 defines how the product may measure, surface and improve those loops without converting analytics into gameplay authority.

The product-health contract is:

> **MonsterVault measures whether players understand, enjoy and voluntarily return to the game. It may surface useful next goals, rotating opportunities and reminders, but it does not punish absence, fabricate urgency, personalize hidden collectible odds, inflate playtime through friction, or change ownership/safety rules merely because a metric improves. Experiments must preserve upstream invariants and be auditable.**

## 2. Scope

GDS-16 owns:

- first-session funnel measurement;
- repeat-session funnel measurement;
- retention metric interpretation;
- session satisfaction model;
- meaningful-engagement definition;
- goal surfacing / next-aspiration guidance;
- Return Brief behavior;
- daily/weekly engagement philosophy;
- streak/login-reward decision;
- notification/reminder boundaries;
- live-content cadence/return-loop philosophy;
- catch-up philosophy;
- discovery packaging experimentation;
- analytics event domains;
- cohort definitions;
- payer/non-payer fairness monitoring;
- device/input fairness monitoring;
- social-value measurement;
- event and trade health measurement;
- economy source/sink health measurement;
- experiment classes;
- experiment assignment constraints;
- value-affecting experiment rules;
- guardrail metrics;
- stop/rollback rules;
- statistical/decision hygiene principles;
- analytics privacy/data-minimization boundaries;
- prohibition on sensitive/behavioral exploitation;
- downstream Technical Architecture telemetry obligations.

## 3. Explicit Non-Goals

GDS-16 does **not** define:

- final analytics vendor/schema/storage technology — Technical Architecture;
- exact Roblox Creator Analytics benchmark values, which change over time;
- legal data-retention periods;
- external ad attribution implementation;
- marketing campaign execution;
- push-notification API integration;
- content-production staffing/calendar;
- exact live-event dates;
- exact A/B test sample sizes/p-values;
- ML recommender implementation;
- fraud-detection implementation;
- customer-support analytics;
- implementation of dashboards or data warehouse;
- a battle pass;
- a login streak;
- a new daily currency;
- a new quest currency;
- new gameplay rewards not already authorized by upstream owning phases.

## 4. Canonical Terminology

Shared terms remain authoritative in ../GLOSSARY.md.

### Meaningful Session
A session in which the player accomplishes at least one product-relevant satisfaction: acquisition/collection progress, visible Vault/progression improvement, or a memorable intentional social/event outcome.

### First-Session Funnel
The ordered set of measured milestones from initial Active Presence through the first complete capture -> secure -> visible progression cycle and next-goal comprehension.

### Return Funnel
The measured path by which a returning player regains context, identifies a worthwhile goal and performs meaningful play without unnecessary re-tutorialization.

### Return Brief
A concise non-modal/session-entry summary of relevant current opportunities and persistent state, such as claimable Production Buffer, current/nearby event, unresolved capacity state and next progression/collection aspiration.

### Next Aspiration
A surfaced player-relevant goal selected from already-authorized gameplay, such as a collection target, region milestone, Vault improvement, event opportunity or trade/collection objective. It is guidance, not a new progression authority.

### Retention Metric
A measurement of whether players voluntarily return after elapsed time, such as D1/D7/D30 cohort retention.

### Meaningful Engagement
Active play that advances or explores the product promise rather than AFK presence, menu idling, forced waiting or repetitive low-value input.

### Guardrail Metric
A metric that must remain within acceptable bounds while optimizing a primary experiment metric, such as safety incidents, early exits, fairness divergence, persistence failures or monetization regret.

### Experiment Assignment
The deterministic treatment/control allocation used to evaluate a hypothesis. Assignment is not gameplay authority.

### Experiment Invariant
An upstream rule that an experiment may not change, including ownership, exact-once persistence, safety, paid-fairness or stable collectible identity.

### Value-Affecting Experiment
An experiment that can change persistent economic/collection opportunity, such as reward amounts, progression prices, spawn weights or event availability.

### Presentation Experiment
An experiment limited to non-authoritative UI/content presentation, such as truthful onboarding wording, goal ordering or HUD emphasis.

### Discovery Packaging
Public-facing title/thumbnail/icon/description presentation used to attract players to the experience.

### Cohort Health
Measured product behavior for a defined group such as first-time players, returning players, progression band, device/input class or acquisition source.

### Return Support
Non-destructive assistance for a returning/lapsed player that restores comprehension and useful direction without fabricating missed history or requiring paid rescue.

## 5. Product Success Hierarchy Remains Authoritative

GDS-1's success order is preserved:

1. player comprehension and satisfaction;
2. retention;
3. meaningful engagement;
4. intentional social/co-play value;
5. acquisition/discovery conversion;
6. monetization.

### PH-01 — Lower metrics cannot override higher-order health

A monetization or session-time improvement is rejected if it materially harms comprehension, satisfaction, retention, fairness or safety.

### PH-02 — Retention is not permission for coercion

A D1/D7 increase does not justify:

- streak-loss fear;
- fake scarcity;
- misleading notifications;
- forced timers;
- hidden odds personalization;
- ownership instability;
- reduced free progression.

### PH-03 — Session time is diagnostic, not inherently positive

Longer play driven by AFK, waiting, confusion, inaccessible menus or forced checklists is not meaningful engagement.

## 6. First-Session Funnel

The GDS-1 product targets remain the baseline:

- meaningful visible goal within roughly 30–45 seconds;
- first real capture attempt within roughly 60 seconds;
- first secured creature target within roughly 3 minutes;
- first visible progression choice target within roughly 6 minutes.

GDS-1 closed-playtest gates remain authoritative:

- >=80% identify the immediate goal without developer explanation;
- >=75% complete/meaningfully participate in first capture within 3 minutes;
- >=60% complete first capture -> secure -> visible progression choice within 8 minutes;
- >=60% complete two meaningful loops within 15 minutes unless intentionally replaced by event;
- >=70% identify a desirable next goal;
- >=50% spontaneously express interest in a specific collection/progression aspiration.

### FF-01 — Funnel instrumentation cannot change the experience

Telemetry must not add blocking steps merely to improve observability.

### FF-02 — First-session abandonment is segmented by meaningful milestone

At minimum diagnose drop before/after:

- Active Presence ready;
- first target understood;
- first capture attempt;
- first Capture Success;
- first secure/extraction;
- first Vault/collection view;
- first progression choice;
- first next-aspiration recognition.

### FF-03 — Store/social exposure does not become a funnel target before core promise

The first-session funnel is judged on gameplay comprehension and collection/progression, not shop opens or invites.

## 7. Repeat-Session and Return Funnel

A returning player should be able to answer within a short period:

- what changed while I was away?;
- what can I do now?;
- what is worth pursuing next?;
- is there a current event/opportunity?;
- do I have unresolved capacity/production/trade state?

### RF-01 — Return Brief is concise and non-blocking

It may surface:

- claimable Production Buffer;
- current Event Occurrence / remaining time;
- current Region Mastery objective;
- one or more Next Aspirations;
- unresolved Overflow-Held;
- recent finalized collection/trade/event outcome summary where useful.

### RF-02 — Return Brief does not fabricate missed rewards

It cannot claim the player earned:

- missed Event Completion;
- missed creatures;
- unearned daily reward;
- retroactive trade outcomes.

### RF-03 — Returning players are not forced through full onboarding again

Only context-sensitive reminders are used where relevant.

### RF-04 — Return entry cannot be store-first

Commercial offers remain lower priority than restoring gameplay context.

## 8. Session Satisfaction Model

Every healthy session should reasonably support one or more of:

1. **I found/captured something I care about.**
2. **My Vault/collection/progression visibly improved.**
3. **Something memorable happened with other players.**

### SS-01 — Short sessions remain valid

A 3–5 minute player can complete at least one meaningful action without losing value for leaving.

### SS-02 — Normal sessions are not forced to 10–25 minutes

That range is a target shape, not a timer requirement.

### SS-03 — Extended play is voluntary

30–60 minute sessions emerge from desired goals/events/social play rather than blocking the next stopping point.

### SS-04 — Session-end safety

Leaving does not forfeit finalized progress merely to discourage exit.

## 9. Next Aspiration System

GDS-16 authorizes a **Next Aspiration** guidance layer, not a new reward source.

### NA-01 — Aspirations come from existing authorized systems

Examples:

- complete a current Region Mastery component;
- collect a missing Core Species;
- pursue an accessible rare/variant;
- resolve Overflow-Held;
- buy an available Vault upgrade;
- join an active eligible event;
- review a currently available trade/collection goal;
- improve collection completion.

### NA-02 — Aspirations are optional

Ignoring a surfaced aspiration creates no penalty.

### NA-03 — Aspirations do not alter odds

Surfacing "hunt Rare Species X" does not secretly increase or decrease its spawn chance unless an upstream authored event/context explicitly does so for everyone under that context.

### NA-04 — Aspirations do not fabricate eligibility

The system cannot recommend inaccessible/expired content as immediately actionable.

### NA-05 — Personalization is progression-based, not vulnerability-based

Selection may use legitimate game state such as:

- owned collection;
- unlocked regions;
- visible milestones;
- current event eligibility;
- capacity;
- completed onboarding/progression.

It may not use inferred vulnerability, recent purchase refusal, recent loss, spend propensity or sensitive personal attributes to manipulate pressure.

## 10. Daily / Weekly Engagement Decision

### DW-01 — No baseline daily login reward

Simply opening the game does not mint Energy, creatures or permanent progression.

### DW-02 — No baseline login streak

MonsterVault does not reset/multiply value based on consecutive daily attendance.

### DW-03 — Missing a day has no punishment

Absence does not:

- destroy value;
- reset collection/progression;
- reduce future base rewards;
- close mainline progression.

### DW-04 — Daily/weekly checklist is not required

The game remains worthwhile without completing a recurring mandatory task list.

### DW-05 — Rotating opportunities may exist through GDS-11

Events/rotations may create reasons to return, but ordinary progression cannot require attendance at every occurrence.

### DW-06 — Future recurring quest system requires change control

A reward-bearing daily/weekly quest layer is not silently introduced by GDS-16; its reward source/economy impact must be validated against GDS-8/GDS-11/GDS-13/GDS-16.

## 11. Live-Content Cadence Philosophy

### LC-01 — Weekly capability is a production aspiration, not an attendance obligation

Frequent small events/content may support return behavior without promising a mandatory weekly grind.

### LC-02 — Valuable events should allow reasonable participation opportunities

Where practical, important rotating opportunities should use:

- multiple occurrences;
- meaningful windows;
- recurring templates;
- future return potential;

rather than a single short surprise window designed primarily to create fear of missing out.

### LC-03 — Limited availability is truthful

Event timing/Availability is real and follows GDS-11; GDS-16 cannot fabricate countdowns.

### LC-04 — Mainline progression remains non-limited

Event-Limited content is not required for ordinary Region Mastery/Access progression.

## 12. Catch-Up Philosophy

### CU-01 — Baseline catch-up uses existing systems

Return Support may use:

- already-earned Offline Production under GDS-7;
- Return Brief;
- Next Aspirations;
- current accessible events;
- normal progression choices.

### CU-02 — No fabricated missed history

A returning player is not granted Event Completion, provenance or creatures they did not earn.

### CU-03 — No hidden spender catch-up

Spending history does not secretly determine catch-up strength.

### CU-04 — New catch-up rewards require owning-phase review

A future bonus Energy grant, temporary multiplier or other new reward source requires GDS-8/GDS-13/GDS-16 review rather than being inferred from "retention".

## 13. Notifications and Reminders

### NR-01 — No external notification is required for product viability

MonsterVault must remain healthy without push notifications.

### NR-02 — Future platform-native reminders are optional and policy-aware

If later used, reminders must respect current platform eligibility/settings and GDS-15.

### NR-03 — Reminder content is factual

Allowed examples:

- a genuinely scheduled event is active/starting;
- a genuine new content release is available.

Not allowed:

- false "your creature will disappear";
- false "last chance";
- guilt language for absence;
- fabricated personalized scarcity.

### NR-04 — Frequency is bounded

No reminder strategy may rely on high-frequency nagging.

### NR-05 — No loss-chasing commercial reminder

A recent failed capture/event miss/purchase refusal cannot trigger a paid rescue notification.

### NR-06 — No streak-threat reminder

There is no streak to lose at baseline.

## 14. Discovery Packaging

### DP-01 — Title, icon, thumbnail and description must truthfully represent the game

Packaging cannot imply:

- combat-first PvP;
- unrestricted stealing;
- guaranteed Legendary;
- features not shipped;
- graphical fidelity/content not representative.

### DP-02 — Packaging experiments are allowed

Truthful variants may test:

- creature focus;
- Vault focus;
- event/social focus;
- capture fantasy;
- variant/rarity fantasy.

### DP-03 — Click improvement cannot override play-through quality

A higher click/play-start rate is not a win if early bounce, satisfaction or trust materially worsens.

### DP-04 — Packaging test conclusions are benchmark/context aware

Roblox discovery conditions change; GDS-16 does not freeze platform-wide CTR/play-through targets.

## 15. Retention Metrics

### RM-01 — D1, D7 and D30 are health signals

GDS-1 benchmark-relative rules remain authoritative:

- D1 and D7 should reach at least relevant benchmark median before aggressive scaling;
- D30 is monitored once statistically meaningful.

### RM-02 — Cohort definition is explicit

Retention analysis must specify:

- cohort entry date/window;
- first-time vs returning;
- acquisition source where known;
- relevant progression state;
- sufficient sample context.

### RM-03 — Retention is segmented for fairness diagnosis

Useful views may include:

- device/input;
- progression band;
- payer/non-payer;
- social eligibility available/unavailable;
- event participant/nonparticipant;
- trade user/non-user;
- organic/acquired cohort.

These segments are for diagnosis, not permission to alter hidden gameplay odds.

## 16. Meaningful Engagement Metrics

Design-relevant engagement measurements include:

- active capture attempts;
- secured creatures;
- distinct Species/Mutation discoveries;
- Vault management/progression actions;
- Region Mastery progress;
- event Eligible Contribution;
- meaningful Party/shared-objective participation;
- completed structured trades;
- collection inspection/showcase behavior;
- session Next Aspiration interaction;
- short-session meaningful-action completion.

### ME-01 — AFK time is not counted as meaningful engagement

Raw session length must be interpreted with active behavior.

### ME-02 — Repetition is not automatically meaningful

High click/action count on one low-value loop does not imply healthy engagement.

### ME-03 — Engagement must map back to product promise

Analytics should explain whether players are actually collecting, progressing, exploring or socializing intentionally.

## 17. Social-Value Metrics

Useful measures include:

- Party invite -> accept conversion;
- Party duration and meaningful joint activity;
- Shared Objective eligible contribution;
- Social Ping usage/mute rates;
- Friendly Challenge completion;
- Vault visitor usage;
- event co-participation;
- trade invite -> completed trade conversion;
- reports/blocks/rejections following social interactions.

### SV-01 — Social volume is not inherently positive

Invite/Ping volume that correlates with blocks/reports is not a success.

### SV-02 — No reward for invitation volume

Referral/invite spam is not incentivized by baseline progression rewards.

## 18. Economy and Progression Health Metrics

Measure at minimum:

- Energy source distribution;
- Energy sink distribution;
- wallet bands by progression;
- Production Claim share versus active reward share;
- time-to-first/next meaningful upgrade;
- Progression Gate completion time;
- insufficient-Energy block rate;
- active-milestone block rate;
- Collection Capacity pressure;
- Overflow-Held incidence/duration;
- paid-capacity usage;
- progression velocity by cohort.

### EH-01 — Economy metrics diagnose, not silently personalize

A player with low Energy does not receive hidden spawn/Mutation odds changes.

### EH-02 — Payer/non-payer divergence is a fairness guardrail

Commercial convenience must not create overwhelming permanent progression separation.

## 19. Collection / Scarcity Health Metrics

Measure:

- Species Discovery distribution;
- Rarity acquisition distribution;
- Mutation/Compound acquisition;
- duplicate rates;
- Protected Variant frequency;
- Region/source distribution;
- event-limited acquisition;
- trade-acquired discovery;
- collection completion progression.

### CH-01 — Analytics does not define per-player rarity

Observed rarity cannot cause a specific player's next roll to be secretly adjusted for retention.

### CH-02 — Scarcity experiments preserve GDS-6 transparency boundaries

No hidden spending- or frustration-based odds.

## 20. Event Health Metrics

GDS-11 metrics remain valid, including:

- announcement -> arrival;
- eligible participation;
- late join;
- qualified contribution;
- objective completion;
- event reward distribution;
- event capture issue/attempt/secure;
- server-hop behavior;
- AFK/zero-contribution population;
- event economy output.

### EV-01 — Attendance is not the sole event success metric

Player satisfaction, reward clarity, fairness, contention and repeat desire matter.

### EV-02 — Event cadence cannot be optimized toward coercive attendance

A retention uplift does not justify mainline progression FOMO.

## 21. Trading Health Metrics

Useful measures include:

- Trade Access unlock rate;
- invite -> session conversion;
- negotiation -> final confirmation;
- cancel reasons;
- revision resets;
- capacity failures;
- cooldown/restriction failures;
- completed trade frequency;
- high-value warnings;
- report/block rates around trade;
- repeat/wash-trade patterns.

### TH-01 — Trade volume is not itself a progression KPI

No reward is attached to raw trade count.

### TH-02 — Safety complaints outweigh volume growth

An experiment that increases completed trades but materially raises scam/report indicators fails.

## 22. Commercial Health Metrics

Measure:

- product views;
- conversion by product class;
- starter-bundle conversion;
- supporter/style attachment;
- paid-capacity usage;
- purchase failure/pending;
- payer/non-payer retention/progression divergence;
- dismiss rate;
- post-purchase satisfaction/support signals.

### CM-01 — Monetization remains last in success hierarchy

Revenue lift cannot override player trust/fairness/retention guardrails.

### CM-02 — Payer status may be analyzed but not used for hidden collectible odds

Analytics segmentation is not gameplay personalization authority.

## 23. Safety and Platform Health Metrics

GDS-15 may be measured through:

- policy-gated feature unavailability;
- chat-independent completion;
- report/block flow usage;
- Ping mute rates;
- directed-invite suppression;
- moderation actions;
- safety-flow abandonment;
- safety parity payer/non-payer.

### SP-01 — No experiment reduces safety to improve retention

Filtering, reporting, blocking, eligibility or spam limits are Experiment Invariants.

## 24. Analytics Privacy and Data Minimization

### AD-01 — Product analytics does not collect unnecessary personal information

Do not create custom analytics fields for:

- legal name;
- phone;
- email;
- school;
- home address;
- password;
- exact birth date;
- precise location;
- external social handle.

### AD-02 — Raw chat/freeform text is not a retention-analytics input

Structured event types may be counted; message content is not needed for product-retention optimization.

### AD-03 — Moderation/security data is logically separate from product analytics

Safety enforcement may require its own records, but retention experimentation cannot casually consume private moderation content/status.

### AD-04 — Analytics identifiers are implementation-level pseudonymous/internal identifiers

Exact schema belongs TA.

### AD-05 — Sensitive-trait inference is not an experiment feature

Do not infer health, religion, sexuality, ethnicity or similar traits for retention targeting.

## 25. Experiment Governance

Every experiment requires:

1. explicit hypothesis;
2. owning subsystem;
3. target population/cohort;
4. primary metric;
5. guardrail metrics;
6. treatment/control definition;
7. expected duration/sample context;
8. upstream invariants checked;
9. stop/rollback condition;
10. result record with effect direction and uncertainty.

### EG-01 — No metric fishing as design authority

Post-hoc metric exploration may generate hypotheses, but a future decision must identify the intended primary metric/guardrails.

### EG-02 — Small samples do not justify permanent semantic change

Effect size, uncertainty and qualitative evidence matter.

### EG-03 — One metric win is insufficient

A treatment fails if relevant guardrails materially degrade.

### EG-04 — Experiment assignment does not persist as player identity

A player is not permanently categorized as "low-value", "whale", "churn risk" for hidden gameplay treatment.

## 26. Experiment Classes

### Class A — Presentation Experiments

May test:

- onboarding wording/order within GDS-3/14 semantics;
- Next Aspiration ordering;
- HUD emphasis;
- event announcement presentation;
- truthful shop layout;
- collection filter defaults;
- discovery packaging.

May run per-player if capability parity and semantics remain intact.

### Class B — Session/Content Scheduling Experiments

May test:

- event announcement lead time;
- authored event cadence;
- Return Brief composition;
- non-rewarding reminder timing;
- session goal surfacing.

Must preserve GDS-11 wall-clock/event identity and GDS-15 policy boundaries.

### Class C — Value-Affecting Experiments

Includes:

- Energy reward values;
- progression prices;
- event reward quantity;
- prospective spawn weights;
- capture numeric difficulty that materially alters acquisition;
- durable capacity quantity/pricing.

These require stronger controls.

## 27. Value-Affecting Experiment Rules

### VA-01 — No hidden per-player permanent scarcity personalization

Creature/Mutation/Trait odds cannot vary based on:

- spending;
- churn prediction;
- recent failure;
- purchase refusal;
- playtime;
- individual retention score.

### VA-02 — Shared opportunities use shared experiment context

Where an experiment changes a public/shared opportunity, participants in the same Server Event Instance / Spawn Context must not compete under secretly different claim/rarity rules for the same opportunity.

### VA-03 — Persistent value experiments are prospective only

Existing Creature Instances, finalized ownership, completed purchases and historical rewards are never rerolled/revoked by treatment assignment.

### VA-04 — Economy treatment cannot create debt or retroactive repricing

Completed purchases remain valid.

### VA-05 — High-impact live-production economy/scarcity tests are conservative

Prefer:

- closed playtests;
- alpha/beta cohorts;
- server/config-level prospective assignment;

over individualized live persistent-value treatment.

### VA-06 — Treatment provenance/config is auditable

Technical Architecture must make it possible to identify which experiment/config produced a persistent-value opportunity when needed for debugging/fairness audit.

## 28. Experiment Invariants

Experiments may never alter:

- one-owner Creature Instance integrity;
- Secured Ownership Finalization semantics;
- Creature Lock safety;
- exact-once persistence;
- Protected Load Failure;
- Acquisition-In-Progress custody rules;
- Trade atomicity/revision consent;
- Energy non-transferability;
- no debt;
- paid/non-paid safety parity;
- no paid luck/claim priority;
- platform eligibility/filtering/report/block rules;
- no critical accessibility paywall;
- stable owned Variant Identity;
- no hidden spend-based odds;
- no confiscation of finalized value for retention;
- no fake commercial urgency;
- no AFK-only reward qualification.

Changing one requires owning GDS change control, not an experiment flag.

## 29. Experiment Assignment and Contamination

### EA-01 — Assignment is stable enough to interpret treatment

A player/session/server should not oscillate unpredictably between control/treatment during one measured flow.

### EA-02 — Shared-world experiments avoid mixed-rule competition

If a rule affects public contention, use a coherent server/event context rather than per-player contradictory rules.

### EA-03 — Device cohorts are diagnostic, not inferior variants

Touch/controller users must not receive reduced gameplay value for easier metric interpretation.

### EA-04 — Policy-ineligible users are excluded from irrelevant treatment

No experiment attempts to bypass GDS-15 eligibility.

## 30. Guardrail Metrics

Relevant guardrails include:

- first-session comprehension;
- early bounce;
- D1/D7 retention;
- meaningful-action rate;
- satisfaction/qualitative complaints;
- persistence/load failures;
- duplicate/rollback incidents;
- reports/blocks;
- social mute/rejection;
- trade safety complaints;
- payer/non-payer progression divergence;
- device/input completion divergence;
- Overflow-Held incidence;
- economy inflation/source-sink imbalance;
- rare/variant acquisition divergence;
- commercial dismiss/refund/support signals;
- accessibility failure reports.

### GM-01 — Severe trust/safety failures stop the experiment

A strong primary-metric uplift does not justify known ownership loss, unsafe communication or misleading commerce.

## 31. Experiment Stop / Rollback Rules

An experiment must be stopped or rolled back when:

- it violates an Experiment Invariant;
- severe persistence/ownership errors appear;
- safety/reporting materially degrades;
- exploit/duplication emerges;
- payer/non-payer or device fairness diverges beyond intended design;
- players are misled about costs/rewards/availability;
- treatment creates unintended permanent scarcity instability.

Rollback is prospective and must not silently remove legitimate Finalized Outcomes already earned under valid treatment.

## 32. Analytics Event Domains

Design-level telemetry domains include:

- lifecycle/load/persistence;
- onboarding;
- interaction/context;
- capture/acquisition;
- collection/ownership;
- rarity/variant discovery;
- Vault/capacity/production;
- Energy/progression;
- world/mastery/travel;
- Party/social;
- events/live content;
- trading;
- monetization;
- presentation/accessibility settings;
- platform/safety eligibility;
- Return Brief / Next Aspiration;
- discovery packaging attribution where available.

Exact event names/properties belong TA.

## 33. Metric Interpretation Rules

### MI-01 — Correlation is not treated as causation

Players who trade more may already be highly engaged; trade volume alone does not prove trading caused retention.

### MI-02 — Cohort mix matters

A change in acquisition source/device/region/progression mix can move aggregate metrics without a product change.

### MI-03 — Qualitative evidence remains valid

Player confusion, desire, perceived fairness and frustration can reject a metric-positive treatment.

### MI-04 — Relative benchmarks age

Creator Analytics comparable-experience benchmarks are evaluated when used, not hard-coded forever.

## 34. Return-Loop Architecture

The baseline return loop is:

```text
Persistent unfinished aspiration
        +
bounded Offline Production / Vault state
        +
rotating genuine world/event opportunities
        +
social/collection goals
        ↓
Return Brief
        ↓
choose a meaningful goal
        ↓
capture / progress / participate / trade
        ↓
visible finalized value
        ↓
new or deeper aspiration
```

This loop intentionally does **not** require:

- login streak;
- daily claim chest;
- mandatory checklist;
- expiring mainline progression;
- paid rescue;
- artificial energy exhaustion.

## 35. Discovery-to-Retention Integrity

### DR-01 — Discovery promises must be paid off in the first session

If packaging emphasizes creature capture/variants/Vault/social events, the first session must expose a truthful path toward that fantasy.

### DR-02 — Misleading acquisition is worse than lower click-through

High bounce caused by dishonest packaging invalidates the acquisition gain.

### DR-03 — User-acquisition spend follows product health

Aggressive paid acquisition should not scale before GDS-1 product gates show competitive retention/engagement.

## 36. Pivot and Scale Governance

GDS-1 pivot gate remains authoritative.

After three substantive gameplay/UX iterations, persistently weak:

- comprehension;
- first capture/progression timing;
- D1 retention;
- collection desire;
- additive social value

requires reconsideration/material redesign before large-scale content production.

### PS-01 — More rewards/content are not automatic fixes

A weak core loop is not "fixed" by:

- bigger login bonuses;
- stronger paid acceleration;
- more notifications;
- more FOMO;
- artificially increased session length.

## 37. Technical Architecture Obligations

Technical Architecture must define:

- telemetry event schema/versioning;
- event delivery/retry behavior;
- deduplication/idempotency for analytics;
- experiment config/assignment service;
- stable treatment exposure recording;
- server-level assignment for shared-rule experiments;
- configuration audit trail;
- privacy/data-minimization enforcement;
- separation of moderation/security and product analytics where appropriate;
- dashboard/data quality monitoring;
- experiment kill switch;
- attribution of persistent-value opportunities to config/version where needed;
- Creator Analytics / external analytics integration boundaries;
- accessibility/device/input telemetry without changing capability.

## 38. Tuneable Parameters

Tuneable without reopening GDS-16:

- Return Brief ordering;
- number of surfaced Next Aspirations;
- Next Aspiration ranking weights using authorized progression state;
- event cadence within GDS-11 authored bounds;
- reminder frequency within non-coercive boundaries;
- experiment duration/sample thresholds;
- dashboard definitions;
- packaging creative;
- analytics event sampling;
- guardrail alert thresholds;
- cohort reporting windows.

Semantic/change-control decisions:

- product success hierarchy;
- no baseline login reward;
- no baseline login streak;
- no absence punishment;
- no mandatory daily/weekly checklist;
- Next Aspiration as guidance, not reward/odds authority;
- Return Brief non-blocking/no fabricated history;
- no hidden vulnerability/spend-based personalization;
- no hidden per-player rarity odds experimentation;
- AFK/session-time distinction;
- truthful discovery packaging;
- analytics privacy/minimization;
- experiment hypothesis/primary metric/guardrail discipline;
- Experiment Invariants;
- shared-context requirement for public value-affecting tests;
- prospective-only persistent-value experiments;
- non-destructive rollback;
- safety/fairness guardrails outranking metric lift.

## 39. Edge-Case Matrix

| Situation | Required behavior |
|---|---|
| Player returns after one day | No streak reward/loss |
| Player returns after two weeks | Return Brief + existing state, no fabricated missed rewards |
| Player misses limited event | No penalty to mainline progression |
| Player has claimable Production Buffer | Return Brief may surface it |
| Player has unresolved Overflow | Return Brief may prioritize it |
| Player has current eligible event | May surface real remaining window |
| Player is ineligible for event | Aspiration should not claim immediate eligibility |
| Player ignores suggested aspiration | No penalty |
| Suggested rare creature has ordinary odds | Suggestion does not secretly boost odds |
| Recent capture failure | No paid rescue targeting |
| Recent purchase refusal | No stronger hidden gameplay treatment |
| Payer has low retention score | Cannot receive better rarity odds |
| Non-payer has low retention score | Cannot receive manipulated odds |
| Player opens game daily | No automatic login currency |
| Player misses 30 days | Collection/progression remains intact |
| Notification says event starts at real time | Allowed if platform/policy eligible |
| Notification says creature will disappear when false | Invalid |
| Notification threatens streak loss | Invalid baseline |
| Multiple reminders sent in short period | Invalid high-frequency nag strategy |
| Packaging shows real rare creature hunt | Allowed if representative |
| Packaging shows direct-combat PvP | Misleading; invalid |
| Packaging promises stealing secured creatures | Misleading; invalid |
| Packaging test raises clicks but doubles early bounce | Fails product-health review |
| Session time increases from AFK timer | Not meaningful engagement win |
| Session time increases from voluntary rare hunt | Potential meaningful improvement |
| Trade count rises but reports rise sharply | Experiment fails guardrail |
| Party invites rise but block rate rises | Not automatically positive |
| D1 rises but first-session comprehension falls | Higher-order guardrail may reject treatment |
| Revenue rises but D7/fairness worsens | Reject |
| UI copy A/B test | Class A allowed |
| Next Aspiration ordering test | Class A allowed |
| Event announcement lead-time test | Class B allowed |
| Reminder timing test | Class B allowed within policy/frequency rules |
| Energy reward A/B | Class C; stronger controls |
| Vault upgrade price A/B | Class C; no retroactive repricing |
| Rare spawn weight A/B per player in same server | Invalid mixed hidden odds |
| Rare spawn weight experiment by coherent server config | Potentially allowed prospectively under GDS-6/9/11 constraints |
| Experiment rerolls owned creature | Invalid |
| Experiment removes finalized Energy | Invalid |
| Experiment changes Trade atomicity | Invalid |
| Experiment disables Creature Lock | Invalid |
| Experiment hides report button | Invalid |
| Experiment makes Reduced Motion premium | Invalid |
| Experiment gives AFK event reward | Invalid |
| Control/treatment oscillates during onboarding | Invalid unstable exposure |
| Device cohort gets easier but lower-value game | Invalid capability/value disparity |
| Payer cohort analyzed separately | Allowed diagnostic segmentation |
| Payer cohort receives better hidden offers/odds from churn score | Invalid |
| Raw chat text sent into retention dashboard | Invalid baseline |
| Structured Ping type counted | Allowed |
| Exact home location added to analytics | Invalid |
| Public policy eligibility metric aggregated | Allowed where privacy-safe |
| Experiment has no hypothesis | Not valid for decision authority |
| Experiment primary metric chosen after results | Exploratory only, not confirmatory authority |
| Tiny sample shows large variance | Not enough for permanent semantic decision |
| Severe duplication bug during experiment | Stop/rollback |
| Rollback after valid rewards earned | Preserve legitimate finalized value |
| Event cadence increased | Allowed if no coercive attendance/mainline dependency |
| Daily quest reward system proposed | Requires upstream/economy/change-control review |
| Battle pass proposed | Not authorized by GDS-16 baseline |
| Login chest proposed | Requires GDS-16/GDS-8 review |
| Streak multiplier proposed | Requires GDS-16 reopening |
| Return bonus Energy proposed | Requires GDS-8/GDS-16 review |
| Catch-up grants fake Event Completion | Invalid |
| Catch-up uses existing Offline Production | Valid |
| First-session store open optimized as primary KPI | Invalid priority |
| Core loop remains weak after three substantive iterations | Pivot/redesign instead of pressure systems |

## 40. Open Questions

There are **zero GDS-16-blocking open questions**.

Exact telemetry schemas, dashboards, attribution vendor, statistical thresholds, experiment duration, Creator Analytics integration, reminder APIs, specific event calendars, content production cadence and final packaging creative are Technical Architecture/operations/tuneable concerns rather than unresolved player-facing semantics.

## 41. Design-Complete Checklist

- [x] Product success hierarchy is preserved.
- [x] First-session funnel instrumentation is defined.
- [x] Return Funnel / Return Brief is defined.
- [x] Meaningful Session / engagement semantics are defined.
- [x] Next Aspiration guidance is defined.
- [x] Daily login reward decision is closed.
- [x] Login streak decision is closed.
- [x] Daily/weekly checklist philosophy is closed.
- [x] Live-content cadence/FOMO boundary is defined.
- [x] Catch-up philosophy is defined.
- [x] Notification/reminder boundary is defined.
- [x] Discovery packaging honesty/experimentation is defined.
- [x] Retention/engagement/social/economy/collection/event/trade/commercial/safety metrics are defined.
- [x] Analytics privacy/data-minimization is defined.
- [x] Experiment governance and classes are defined.
- [x] Value-Affecting Experiment rules are defined.
- [x] Experiment Invariants are explicit.
- [x] Guardrail/stop/rollback rules are defined.
- [x] Metric interpretation rules are defined.
- [x] GDS-17/Technical Architecture authority remains downstream.
- [x] No implementation-relevant GDS-16 open questions remain.
