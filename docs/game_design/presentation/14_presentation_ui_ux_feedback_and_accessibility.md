# Presentation, UI/UX, Feedback, and Accessibility

> **Status:** Design Complete  
> **Owning GDS phase:** GDS-14 — Presentation, UI/UX, Feedback, and Accessibility  
> **Authority:** Player-facing information hierarchy, HUD/menu architecture, interaction prompts, collection/Vault/economy/world/capture/event/social/trading/commercial presentation, confirmation/warning patterns, notification priority, cross-input navigation, text/readability, color/audio redundancy, reduced-motion/accessibility settings, onboarding presentation, and presentation-state recovery  
> **Depends on:** ../00_design_authority.md, ../01_game_overview.md, ../global_rules/02_global_game_rules_and_session_model.md, ../player/03_player_character_interaction_and_onboarding.md, ../creatures/04_creatures_collection_and_ownership.md, ../capture/05_capture_contesting_transport_and_extraction.md, ../rarity_mutations/06_rarity_mutations_traits_and_variant_value.md, ../vault/07_vault_base_passive_production_capacity_and_upgrades.md, ../economy_progression/08_economy_progression_unlocks_and_pacing.md, ../world/09_world_biomes_exploration_spawning_and_hazards.md, ../social/10_social_play_cooperation_competition_and_pvp_boundaries.md, ../events_liveops/11_server_events_dynamic_encounters_and_live_content.md, ../trading/12_trading_and_player_economy.md, ../monetization/13_monetization_and_commercial_fairness.md, ../GLOSSARY.md

## 1. Purpose and Experience Promise

MonsterVault has many interacting systems: world exploration, capture, transport, collection, Vault management, progression, events, social play, trading and commercial presentation.

GDS-14 makes those systems understandable without adding new gameplay authority.

The player-facing presentation contract is:

> **At any important moment I can tell what I am looking at, what action is available, what will happen if I choose it, what changed after I act, and whether that change is temporary or persistent. I do not need perfect color vision, hearing, precision cursor control, unrestricted chat, memorized icons or one specific input device to understand or complete the core game.**

## 2. Scope

GDS-14 owns:

- global information hierarchy;
- HUD composition and critical-state priority;
- menu architecture and modal behavior;
- Interaction Prompt and Primary Action presentation;
- input-glyph switching;
- collection browsing and exact-instance presentation;
- Creature Lock / Release / Overflow-Held presentation;
- Vault / Production / Capacity / Energy feedback;
- Progression Gate and purchase-cost presentation;
- world/region/mastery/travel/hazard feedback;
- capture / claim / custody / extraction feedback;
- rarity / Mutation / Trait / Availability / provenance presentation;
- event timing / contribution / allocation / reward presentation;
- Party / Social Ping / challenge / visitor presentation;
- trade invite / offer / revision / readiness / final-confirmation presentation;
- commercial offer / purchase / entitlement presentation;
- notification hierarchy and queueing;
- persistent versus transient-state cues;
- confirmation/warning patterns;
- error/rejection feedback;
- color, text, contrast, icon and audio redundancy requirements;
- subtitle/caption and non-audio equivalents;
- reduced-motion and camera-assistance settings;
- cross-device navigation parity;
- focus restoration and modal safety;
- onboarding guidance presentation;
- safe UI recovery after reconnect/load/reconciliation;
- accessibility settings baseline;
- downstream presentation obligations for GDS-15/GDS-16 and Technical Architecture.

## 3. Explicit Non-Goals

GDS-14 does **not** define:

- platform-age/account/privacy restrictions — GDS-15;
- reporting/blocking/moderation policy — GDS-15;
- current Roblox commerce compliance or parental-control requirements — GDS-15;
- analytics experiment governance or retention-campaign cadence — GDS-16;
- exact font asset, final art style, color palette, animation curves, sound assets or localization implementation — production/TA;
- UI framework choice;
- Roblox GUI object hierarchy;
- controller navigation library;
- safe-area API implementation;
- data-binding architecture;
- localization service integration;
- camera collision algorithm;
- server/client replication implementation;
- telemetry event schemas.

## 4. Canonical Terminology

Shared terms remain authoritative in ../GLOSSARY.md.

### Presentation Layer
The player-facing representation of authoritative game state. Presentation never becomes the owner of gameplay state merely because it displays or animates it.

### HUD
The always-available or contextually visible in-play information surface used while ordinary world control remains active.

### Modal Screen
A presentation state that intentionally owns input focus and suppresses conflicting world actions until closed or resolved.

### Panel
A non-full-screen information surface that may coexist with world view when it does not create ambiguous input focus.

### Critical State Banner
A high-priority, concise presentation of a state that materially changes what the player can safely do, such as Protected Load Failure, Acquisition-In-Progress, unresolved Overflow, Event Resolving, Purchase Pending requiring attention, or trade final review.

### Context Prompt
The visible presentation of the current GDS-3 Active Context and its Primary Interact action.

### Action Feedback
Immediate presentation that confirms an attempted action was accepted, rejected, pending, completed or changed state.

### Toast
A short non-modal informational message that does not require acknowledgment and must not obscure critical gameplay.

### Persistent Notice
A non-modal notice that remains until its underlying state is resolved or explicitly dismissed where dismissal is safe.

### Confirmation Dialog
A modal review requiring deliberate acceptance before a consequential action.

### Destructive Confirmation
A stronger Confirmation Dialog used for irreversible or high-value loss/transfer actions.

### Focus Target
The currently selected actionable UI element for keyboard/gamepad navigation.

### Input Glyph
The visual symbol/text representing the current input binding for an action.

### Reduced Motion
A player setting that decreases or substitutes non-essential camera motion, flashes, large transitions, looping motion and other potentially uncomfortable presentation while preserving semantic feedback.

### Readability Mode
A group of accessibility options affecting text size, contrast, background support, icon labels and visual clarity without changing gameplay rules.

### Semantic Redundancy
Presenting critical meaning through at least two understandable channels such as text + icon/shape, text + sound, or shape + pattern, rather than relying on color or audio alone.

## 5. Global Information Hierarchy

Player-facing information uses this priority order:

1. **Safety / trust failures**
   - Protected Load Failure;
   - invalid persistent state;
   - destructive-action review;
   - purchase/trade finalization uncertainty requiring safe behavior.
2. **Committed gameplay state**
   - Capture Attempt;
   - Provisional Capture / Transport Custody;
   - Extraction;
   - trade final review/commit;
   - other states where conflicting action would create loss or contradiction.
3. **Time-critical opportunity state**
   - event phase/timer;
   - rare/event encounter stability;
   - active Shared Objective;
   - temporary hazard state.
4. **Immediate interaction**
   - Active Context;
   - Primary Interact / Primary Action;
   - local objective.
5. **Persistent progression**
   - Energy;
   - capacity;
   - Region Mastery / milestones;
   - Vault upgrade state.
6. **Social / commercial / informational**
   - Party/Pings;
   - shop offers;
   - low-priority discoveries;
   - cosmetic/status notices.

Lower-priority presentation may not obscure or steal focus from a higher-priority state.

## 6. HUD Architecture

### HUD-01 — Baseline world HUD is intentionally sparse

Normal exploration presents only information needed for immediate orientation and progress.

Baseline persistent elements may include:

- current Energy;
- compact current region/context;
- current objective/guidance when one is active;
- context-sensitive Primary Interact / Primary Action;
- active acquisition/custody state when applicable;
- event state when applicable.

### HUD-02 — Context beats permanent clutter

Rarity, trade, production, event, hazard and commercial information appears when relevant rather than occupying permanent screen space.

### HUD-03 — Critical committed state dominates

During Capture Attempt, Transport Custody, trade final review or equivalent committed interaction:

- unrelated Toasts are delayed/queued;
- shop prompts are suppressed;
- low-priority social popups are suppressed;
- the committed state's relevant feedback remains visually dominant.

### HUD-04 — HUD does not obscure mobile controls

Touch action surfaces and critical world view must remain usable without overlapping essential information.

### HUD-05 — Safe-area-aware layout is mandatory

HUD must adapt to platform display cutouts, aspect ratios and system-reserved areas.

Exact implementation belongs TA.

## 7. Interaction Prompt and Input Presentation

### IP-01 — Context Prompt shows action meaning plus control

A prompt must communicate both:

- the semantic action, such as `Inspect`, `Capture`, `Secure`, `Travel`, `Open Vault`; and
- the current input glyph/control.

A glyph alone is insufficient.

### IP-02 — Input glyph updates dynamically

Switching between touch, keyboard/mouse and gamepad updates presentation without changing capability.

### IP-03 — Prompt stability follows Active Context

The prompt should not visually flicker between nearby candidates faster than the underlying GDS-3 context policy changes.

### IP-04 — Invalidated actions explain briefly

If a visible action becomes invalid before activation, feedback should state the reason when useful, such as:

- `Capacity full`;
- `Creature locked`;
- `Already claimed`;
- `Event ended`;
- `Requires Starter Mastery`.

### IP-05 — No hover-only meaning

Core information/actions cannot require mouse hover.

Touch/gamepad alternatives must expose the same semantic information.

## 8. Menu and Modal Architecture

### MM-01 — One primary modal focus owner

Only one consequential modal flow may own focus at a time.

Nested confirmation may exist only when its relationship is clear and returning/cancelling restores the previous safe state.

### MM-02 — Modal opening suppresses conflicting world input

A menu action cannot accidentally trigger capture, Release, purchase, travel or another world action from the same input event.

### MM-03 — Close/back behavior is predictable

The same semantic Back/Close action:

- closes the topmost safe panel;
- cancels non-final negotiation states when allowed;
- never confirms destructive/commercial actions.

### MM-04 — Focus restoration is deterministic

Closing a modal restores focus to:

- the previously relevant UI element where safe; or
- ordinary world control.

Gamepad focus must never disappear into an unreachable state.

### MM-05 — Consequential actions are not placed on ambiguous generic dismissal controls

`Confirm`, `Release`, `Buy`, `Trade`, `Unlock` and similar actions remain semantically distinct from `Close` / `Back`.

## 9. Confirmation Severity Model

### Level 0 — Immediate

For reversible low-consequence actions:

- filter;
- sort;
- open details;
- equip presentation-only cosmetic.

### Level 1 — Standard confirmation

For meaningful but recoverable purchases/assignments:

- Energy progression purchase;
- Vault upgrade;
- changing Production Assignment where no loss occurs.

### Level 2 — Strong confirmation

For irreversible/high-value actions:

- Release;
- unlocking a Protected Variant before transfer/destruction;
- final Trade Confirmation;
- high-value asymmetric trade;
- any future permanent destructive action.

### Level 3 — System-blocking trust state

For states where irreversible action must stop:

- Protected Load Failure;
- unresolved authoritative trade/purchase result where client presentation cannot safely assume outcome.

### CF-01 — Confirmation states exact target and consequence

A confirmation must identify:

- what exact object/value is affected;
- what will change;
- whether the result is persistent;
- what cannot be undone by ordinary UI.

### CF-02 — High-value exact-instance actions expose distinguishing facts

For creatures this includes relevant Species, Mutation/Variant, Availability/provenance and lock/high-value indicators.

## 10. Collection UI

### CU-01 — Collection supports both Species overview and exact-instance detail

Players can browse:

- Species-level completion/discovery;
- exact owned instances.

Grouped duplicates must never remove access to individual instance selection.

### CU-02 — Default collection card minimum meaning

An owned-instance card/details view must expose enough to distinguish:

- Species;
- current collection state;
- Creature Lock;
- Mutation/Variant significance where applicable;
- Availability/provenance significance where applicable;
- exact instance when duplicates matter.

### CU-03 — Filters/sort support long collections

Baseline semantic filter/sort capabilities include at least useful combinations of:

- Species;
- Species Rarity;
- Mutation presence/category;
- Availability;
- locked/unlocked;
- Stored/Active/Overflow-Held;
- production eligibility/assignment where relevant.

Exact UI form is tuneable.

### CU-04 — No drag-only management

All move/assign/select actions have explicit button/list alternatives.

Drag-and-drop may be an optional shortcut.

### CU-05 — Overflow-Held is unmistakable

Overflow-Held presentation must state:

- creature remains owned;
- ordinary deployment/assignment is restricted;
- how the player can resolve capacity;
- Release is not automatic.

### CU-06 — Release is visually separated from ordinary storage actions

Release cannot be adjacent/identical to routine move/store without strong distinction and explicit confirmation.

### CU-07 — Creature Lock remains visible on high-value actions

Locked state must be understandable before Release/Trade eligibility is attempted.

## 11. Rarity, Mutation, Trait, Availability, and Provenance Presentation

### RV-01 — Species Rarity never relies on color alone

Rarity uses at least:

- textual label; and
- icon/shape/pattern or other redundant signifier.

Color may reinforce but not carry the only meaning.

### RV-02 — Mutation/Variant presentation is distinct from commercial cosmetics

Intrinsic variant status must have authoritative labels/details that paid accessories cannot imitate semantically.

### RV-03 — Trait meaning is inspectable

Where Traits affect gameplay, their effect/category must be understandable without hidden icon memorization.

### RV-04 — Availability is a separate label dimension

`Rotating`, `Event-Limited`, `Legacy` are not presented as higher Species Rarity tiers.

### RV-05 — Provenance is historical, not current ownership

Details may show origin separately from current ownership/trade history.

### RV-06 — Protected Variant state is explicit

Players can tell when a creature is auto-locked/protected and why.

## 12. Capture and Acquisition Feedback

### CA-01 — Claim state is legible

Players can distinguish:

- public opportunity;
- claimed by self;
- unavailable because claimed by another player;
- invalid/no longer eligible.

### CA-02 — Capture Attempt clearly enters committed mode

Start feedback indicates that Primary Action now belongs to the Capture Challenge.

### CA-03 — Capture result is unambiguous

Success, failure, cancel and invalidation must not share nearly identical feedback.

### CA-04 — Capture Success does not falsely imply secured ownership

Presentation must say/communicate that the creature is captured for transport but **not yet secured**.

### CA-05 — Transport Custody stays prominent

While carrying a Provisional Capture, the HUD communicates:

- creature under custody;
- destination/secure objective;
- interruption risk semantics;
- fast-travel restriction where relevant.

### CA-06 — Extraction Completion visibly distinguishes secured ownership

Successful finalization uses a clear persistent-value confirmation separate from ordinary capture success.

### CA-07 — Full/capacity-blocked capture state explains next action

The player is shown whether they must resolve capacity before beginning/finishing acquisition.

## 13. Vault and Production UI

### VP-01 — Capacity categories remain separate

UI must not collapse:

- Collection Capacity;
- Display Slots;
- Production Slots;
- Production Buffer;
- Offline Production Window

into one ambiguous "space" metric.

### VP-02 — Production Assignment is exact-instance

The player can identify which exact creature occupies which production assignment.

### VP-03 — Production rate and buffer are distinguishable

UI separates:

- rate;
- stored/claimable buffer;
- cap;
- offline window.

### VP-04 — Production Claim feedback is exact-once-looking

A successful claim visibly updates Energy and buffer state once; retry/loading presentation must not imply multiple grants.

### VP-05 — Upgrade comparison shows before/after facts

Before an Energy purchase, the player sees:

- current capability;
- next capability;
- Energy cost;
- unmet active milestone where applicable.

### VP-06 — Paid capacity is labeled as commercial convenience, not progression requirement

The non-paid progression route remains discoverable.

## 14. Economy and Progression Presentation

### EP-01 — Energy balance is visible when economically relevant

Energy does not need to dominate every screen, but is clearly visible on:

- upgrade/purchase surfaces;
- Vault economy views;
- relevant progression gates.

### EP-02 — Costs are explicit before confirmation

A purchase button must not hide the Energy cost.

### EP-03 — Progression Gate explains all unmet conditions

If a gate requires:

- prior unlock;
- active Milestone;
- Energy;

the UI shows each independently rather than only a generic `Locked`.

### EP-04 — Insufficient Energy versus missing Milestone are distinct

The player should know whether to earn currency or complete gameplay.

### EP-05 — Completed persistent unlocks are visually stable

A completed unlock should not continue looking temporary/locked after reconnect.

## 15. World, Region Mastery, Travel, and Hazard Presentation

### WR-01 — Region identity is legible

Current region/biome identity is available without requiring map memorization.

### WR-02 — Region Mastery decomposes into owned requirements

The player can inspect the separate components:

- Route Survey / Landmark progression;
- distinct Core Species collection requirement;
- Field Objective;
- any Energy Access Unlock requirement where owned by GDS-8/9.

### WR-03 — Event-Limited/rare content is not implied mandatory

Mastery UI separates optional rare/event collection from required Core progression.

### WR-04 — Travel Node discovery/availability is clear

Players can tell:

- undiscovered;
- discovered but unavailable due to current state;
- available;
- blocked by Acquisition-In-Progress.

### WR-05 — Hazard warnings use redundant cues

Important hazards use more than color/audio alone and give a reasonable opportunity to respond.

### WR-06 — Recovery feedback explains temporary nature

Recovery should not be visually confused with losing persistent collection/progression.

## 16. Event UI

### EV-01 — Event phase/timing is explicit

Players can distinguish:

- Announced;
- Active;
- Resolving;
- Ended.

When time matters, remaining time is visible in a non-audio form.

### EV-02 — Event location and eligibility are discoverable

A player can determine:

- where to go;
- whether they can participate;
- why they are ineligible if blocked.

### EV-03 — Contribution state is visible

For reward-bearing objectives, the player can understand:

- that contribution is required;
- their current contribution status;
- whether minimum eligibility has been met.

### EV-04 — Shared objective versus personal objective is distinguishable

Server progress cannot be mistaken for personal reward eligibility.

### EV-05 — Single-award versus Multi-Award is explicit

Public ordinary event creature, Shared Objective and Event Multi-Award Encounter use distinct labels/presentation patterns.

### EV-06 — Event Resolution Grace is understandable

If active acquisition may continue after event generation ends, presentation tells the involved player that resolution remains valid.

### EV-07 — Already-claimed exact-once reward state is visible

Reconnect/server change cannot make a consumed reward look available again.

### EV-08 — Event announcements do not overwhelm critical states

Major announcements queue or compact themselves during committed capture/trade/recovery states.

## 17. Social UI

### SO-01 — Party membership and leadership are clear

Players can tell:

- current Party;
- leader;
- members;
- invitations;
- leave/remove/disband consequences.

### SO-02 — Party authority is not overstated

Leader UI does not visually imply ownership/economy/progression authority over members.

### SO-03 — Social Pings are structured and identifiable

Ping type/author/location are understandable without unrestricted chat.

### SO-04 — Ping muting/suppression is accessible

Players can reduce spam without paying.

### SO-05 — Friendly Challenge is clearly opt-in/non-destructive

Challenge UI communicates:

- who is participating;
- consent status;
- no creature/Energy wagering;
- result/status nature.

### SO-06 — Vault Visitor mode is visibly read-only

Visitors should not see owner-management controls presented as actionable.

## 18. Trading UI

### TR-01 — Two sides are visually distinct

Trade screen clearly separates:

- `You give`;
- `You receive`.

### TR-02 — Exact offered instances are inspectable

Duplicates cannot be represented only by species count when instance attributes differ.

### TR-03 — Trade Revision change is conspicuous

Any semantic offer change:

- updates visible revision state;
- clears Ready;
- exits/invalidates Final Confirmation.

### TR-04 — Ready and Final Confirmation are distinct stages

Players must not confuse initial readiness with irreversible final transfer.

### TR-05 — Final review is immutable

No editing controls remain active inside final confirmation.

### TR-06 — High-value facts are visible

Final review shows relevant:

- Species;
- Rarity;
- Mutations;
- Trait where meaningful;
- Availability;
- provenance;
- Protected Variant;
- Trade Restriction/Cooldown;
- exact quantity/instances.

### TR-07 — Capacity errors name affected side

`Your collection would exceed capacity` and equivalent counterpart state must not be a generic mysterious failure.

### TR-08 — Trade success/failure is authoritative

After commit, both players receive clear success or no-transfer failure feedback.

### TR-09 — Off-platform promises are not integrated into protected trade UI

The screen cannot imply Robux/chat promises are verified consideration.

## 19. Commercial / Shop UI

### SH-01 — Product contents and actual price are visible before purchase

The shop shows:

- what is granted;
- whether durable/one-time;
- actual platform price.

### SH-02 — Paid cosmetic versus intrinsic collectible identity is clear

Commercial visual items never use presentation that falsely implies Mutation/Rarity/provenance.

### SH-03 — Commercial Capacity shows exact added capability

It identifies whether it adds Collection Capacity, Display Capacity or approved preset value.

### SH-04 — Free route remains visible

When commercial capacity relates to a constrained system, the ordinary earnable progression path remains discoverable.

### SH-05 — Starter Bundle is clearly one-time

No ambiguous recurring semantics.

### SH-06 — Purchase Pending / success / failure are distinguishable

The UI must not display an entitlement as finalized before authoritative completion.

### SH-07 — No fake urgency presentation

Timers/sale markers correspond to real availability.

### SH-08 — Commercial prompts never steal critical focus

GDS-13 suppression states are mandatory.

## 20. Notification System

### NT-01 — Notifications have priority classes

Baseline classes:

- Critical;
- Committed-state;
- Time-sensitive;
- Progression;
- Social;
- Informational/commercial.

### NT-02 — Low-priority Toasts queue during high-priority states

They may appear later if still relevant.

### NT-03 — Notification spam is bounded

Repeated identical state changes should aggregate/suppress where possible.

### NT-04 — Persistent unresolved states use persistent presentation

Examples:

- unresolved Overflow;
- Protected Load Failure;
- active Trade Cooldown detail when viewing trade eligibility;
- Purchase Pending requiring later reconciliation.

### NT-05 — Toast disappearance never hides required action

If the player must act, the underlying state remains accessible after the Toast expires.

## 21. Error and Rejection Feedback

### ER-01 — Errors explain the actionable reason

Prefer:

- `Requires Starter Region Mastery`;
- `Creature is locked`;
- `Trade changed — review again`;
- `Collection would exceed capacity`;

over generic `Error`.

### ER-02 — Technical detail is not required for ordinary users

Player-facing error messages explain consequence/action, not stack traces/IDs.

### ER-03 — Retry is offered only when safe/meaningful

A retry control must not duplicate irreversible actions.

### ER-04 — Rejected irreversible action changes no UI state to falsely imply success

Presentation follows authoritative outcome.

## 22. Text and Readability

### TX-01 — Core text supports scalable readability

Critical text must remain usable under an enlarged text/readability setting without truncating meaning or hiding confirmation actions.

### TX-02 — Short labels use plain semantic language

Primary progression/action labels should be understandable to the target age group.

Specialized lore names may exist alongside clear action meaning.

### TX-03 — Long explanatory text is secondary

Core progression does not depend on reading long paragraphs during active play.

### TX-04 — Important numbers include context

Examples:

- `Energy: 420`;
- `Capacity: 10 / 12`;
- `Event ends: 04:32`;

rather than unexplained numbers.

### TX-05 — Abbreviations are not required knowledge

An abbreviation may appear after/with an understandable full meaning where critical.

## 23. Color, Contrast, Icons, and Patterns

### CL-01 — No critical state relies on color alone

At minimum a text/icon/shape difference accompanies critical color.

### CL-02 — Rarity colors have labels

Common/Uncommon/Rare/Epic/Legendary remain textually identifiable.

### CL-03 — Positive/negative state does not rely only on green/red

Success/failure includes icon/text/structure.

### CL-04 — Selected/focused controls remain visible

Keyboard/gamepad focus must have a clear non-color-only indication.

### CL-05 — Text/background readability support is available

Readability Mode may strengthen background panels/outlines/contrast without changing gameplay.

## 24. Audio, Captions, and Non-Audio Equivalents

### AU-01 — Audio is reinforcement, not the sole carrier of critical meaning

Capture result, event countdown, hazard warning, trade change and purchase result all have visual/text equivalents.

### AU-02 — Important authored dialogue/announcements support text

Where spoken content conveys gameplay instruction, an on-screen text equivalent is required.

### AU-03 — Captions can identify meaningful sound categories

Important non-dialogue cues may use short captions/visual cues such as:

- event started;
- hazard pulse;
- capture success;
- rare encounter alert

when the sound conveys actionable information.

### AU-04 — Volume categories are separable

At minimum design should support independent adjustment for:

- master;
- music;
- effects;
- voice/dialogue where used.

Exact settings implementation belongs TA.

## 25. Motion, Camera, Flash, and Visual Effects

### MO-01 — Reduced Motion is baseline

Reduced Motion must be available without payment.

### MO-02 — Reduced Motion preserves semantics

It may replace:

- camera shake;
- large zoom/pan;
- looping UI motion;
- rapid parallax;
- celebratory screen movement

with calmer alternatives while keeping state/result obvious.

### MO-03 — Camera assistance yields to player input

Onboarding/event framing may guide attention briefly but cannot continuously fight direct camera control.

### MO-04 — Critical VFX cannot obscure play

Capture/event rarity effects cannot hide hazards, prompts or required targets for an unreasonable duration.

### MO-05 — Flashing presentation must be avoidable/bounded

Gameplay-essential feedback cannot depend on rapid full-screen flashing.

Exact platform safety limits belong GDS-15/TA.

## 26. Input and Navigation Accessibility

### IN-01 — Touch, keyboard/mouse and gamepad have semantic parity

No core UI action exists only through:

- hover;
- right-click;
- keyboard chord;
- drag;
- precision cursor;
- pointer emulation.

### IN-02 — Gamepad focus graph is complete

Every actionable core menu element is reachable and has a clear Focus Target.

### IN-03 — Touch targets are not tiny/overlapping

TA must operationalize target sizing for supported devices; GDS-14 prohibits progression-critical micro-targets.

### IN-04 — Keyboard shortcuts duplicate, not replace

Shortcuts may accelerate common actions but an accessible explicit control remains.

### IN-05 — Drag/drop has button alternative

Collection, production and trade manipulation support explicit select/action flows.

### IN-06 — Device switch is seamless

Changing input family updates glyphs/focus without closing or corrupting the current safe UI state.

## 27. Accessibility Settings Baseline

The baseline settings set must include:

- text/readability scaling or equivalent larger-text mode;
- enhanced contrast/background support;
- Reduced Motion;
- camera shake reduction/disable;
- subtitles/text for instructional dialogue;
- relevant sound-cue captions/visual equivalents;
- independent volume categories;
- control sensitivity;
- input glyph adaptation;
- ability to mute/suppress Social Pings;
- ability to reduce non-essential notification intensity where safe.

GDS-15 may add platform/age-specific settings.

## 28. Onboarding Presentation

### OB-01 — Show -> do -> confirm

Each required concept is introduced immediately before the player performs it.

### OB-02 — No store-first onboarding

The shop may not block or become the primary first-session flow.

### OB-03 — No long mandatory manual

Complex systems such as Mutation, Production, Events and Trading are introduced when relevant, not before first capture.

### OB-04 — Guidance Layer is dismissible after required understanding where safe

Dismissal cannot grant the milestone itself.

### OB-05 — First-capture flow prioritizes world target and action

UI clutter and unrelated social/commercial notifications are suppressed.

### OB-06 — Onboarding success feedback distinguishes persistent milestones

Players understand when a tutorial instruction has become permanent progress.

## 29. Reconnect, Load, and Reconciliation Presentation

### RC-01 — Persistence readiness is visible when materially delayed

Players should not be encouraged to make irreversible choices before trusted state is ready.

### RC-02 — Protected Load Failure is unmistakable

The screen explains:

- trusted progression could not be established;
- irreversible play is blocked;
- available safe actions such as retry/reconnect/leave.

### RC-03 — Reconnect restores authoritative state rather than replaying celebratory grants

Previously finalized trade/purchase/reward may be summarized, but presentation must not imply duplicate finalization.

### RC-04 — Capacity reconciliation is explained

If paid/temporary capacity changes create Overflow-Held state, the UI states that ownership remains intact.

## 30. Persistence of Presentation Preferences

Accessibility and major presentation preferences are intended to persist across sessions when feasible, including:

- Reduced Motion;
- camera shake setting;
- readability/contrast mode;
- volume categories;
- control sensitivity;
- Social Ping suppression;
- relevant notification preferences.

Implementation/storage authority belongs TA.

## 31. Localization and Text Expansion Obligations

### LC-01 — Core layout must tolerate text expansion

Buttons, prompts and confirmation text cannot depend on one short language fitting a fixed tiny box.

### LC-02 — Meaning is not encoded in English-specific wordplay

Critical action meaning must remain localizable.

### LC-03 — Numbers/timers/costs remain clear across locale formatting

Technical localization belongs downstream.

## 32. Monetization Presentation Guardrails

GDS-14 must preserve GDS-13 by ensuring:

- clear product price/content;
- durable vs one-time semantics;
- no disguised random outcome;
- no fake discount/countdown;
- no critical-state interruption;
- no misleading paid-vs-intrinsic creature identity;
- no premium-only safety/accessibility presentation;
- clear free progression route.

## 33. Tuneable Presentation Parameters

Tuneable without reopening GDS-14:

- exact HUD anchoring;
- exact panel dimensions;
- exact font family;
- exact colors/palette while semantic redundancy remains;
- animation duration within motion/accessibility boundaries;
- icon art;
- Toast duration;
- notification aggregation timing;
- default filter/sort order;
- exact wording/localization;
- exact controller shortcut mapping where semantic parity remains;
- exact Readability Mode visual treatment.

Semantic/change-control decisions:

- priority hierarchy;
- committed-state focus protection;
- one primary modal focus owner;
- deterministic Back/Close/focus restoration;
- explicit confirmation severity;
- no color/audio-only critical meaning;
- exact-instance collection/trade readability;
- separate rarity/Mutation/Availability/provenance dimensions;
- capture success versus secured ownership distinction;
- separate capacity/production concepts;
- progression gates showing all unmet conditions;
- event single/multi-award distinction;
- immutable trade final review;
- commercial truthfulness/safe prompt suppression;
- Reduced Motion baseline;
- cross-input semantic parity;
- non-drag-only/non-hover-only core UI;
- persistent accessibility preference intent.

## 34. Dependencies and Downstream Obligations

### GDS-15 — Roblox Platform, Social Safety, and Moderation Constraints

Must validate presentation against platform-safe areas, age/privacy restrictions, communication/reporting/blocking, flashing/content rules, commerce disclosures and any mandatory accessibility/platform constraints.

### GDS-16 — Retention, Discovery, Analytics, and Experimentation Boundaries

May measure funnels and experiment with tuneable presentation parameters but cannot weaken GDS-14 semantic clarity, consent, accessibility or commercial-fairness boundaries.

### Technical Architecture

Must implement UI state synchronization, input/focus routing, safe-area handling, accessibility-setting persistence, localization plumbing, notification queueing, authoritative state binding, purchase/trade/persistence recovery presentation and device-switch behavior without changing GDS-14 semantics.

## 35. Edge-Case Matrix

| Situation | Required behavior |
|---|---|
| Player switches keyboard to controller mid-menu | Glyph/focus updates; same capability remains |
| Player switches controller to touch during capture | Capture semantics remain available |
| Two interactables overlap | One Active Context/prompt remains stable |
| Context invalidates before input | Clear safe rejection/no partial action |
| Modal opens while player presses Interact | Input spillover cannot trigger world action |
| Modal closes | Focus/control restores predictably |
| Gamepad focus reaches end of list | Navigation remains reachable/consistent |
| Collection has many duplicates | Exact instance remains selectable |
| Duplicate cards look similar | Distinguishing instance facts remain inspectable |
| Locked creature Release selected | Locked state explained; action blocked |
| High-value unlocked creature Release selected | Strong destructive confirmation |
| Overflow-Held creature viewed | Ownership and restriction both clear |
| Rarity color is not perceivable | Text/icon still identifies rarity |
| Mutation cosmetic resembles variant | Intrinsic Mutation label remains authoritative |
| Event-Limited creature is Common | Availability and Rarity shown separately |
| Capture begins | HUD enters committed capture feedback |
| Capture succeeds | UI says captured/custody, not yet secured |
| Player reaches Secure Point | Secured finalization is visibly distinct |
| Fast travel attempted during custody | Clear blocked reason |
| Capacity blocks new acquisition | Exact capacity reason/next step shown |
| Production claim succeeds | Energy/buffer update once |
| Region gate blocked by milestone | Missing milestone shown separately from Energy |
| Event announced during capture | Announcement queues/compacts |
| Event enters Resolving during active event capture | Resolution Grace state shown |
| Shared event reaches 100% but player lacks contribution | Server success not shown as personal reward eligibility |
| Multi-award event active | Clearly labeled versus public single-award creature |
| Social Ping spam | Can be muted/suppressed |
| Visitor opens Vault | Read-only state obvious |
| Trade offer changes after Ready | Ready cleared visibly |
| Trade final review opens | Offer immutable |
| High-value trade | Relevant identity/provenance/warning visible |
| Trade capacity failure | Affected player's capacity reason clear |
| Purchase prompt during final trade review | Suppressed |
| Permanent shop item shows fake countdown | Invalid |
| Purchase pending | Not shown as finalized entitlement |
| Purchase callback repeats | UI does not celebrate/grant twice |
| Paid capacity revoked | Overflow reconciliation explains ownership retained |
| Protected Load Failure | Irreversible controls blocked with clear recovery options |
| Player disables motion | Camera shake/large motion substitutes calmly |
| Player cannot hear event alarm | Visual/text event signal exists |
| Player cannot distinguish red/green | Success/failure still text/icon distinguishable |
| Player enlarges text | Critical controls/content remain usable |
| Player uses touch | No tiny progression-critical target/hover requirement |
| Player uses gamepad | No pointer-emulation-only core flow |
| Player uses keyboard shortcuts | Equivalent explicit menu action exists |
| Drag/drop impossible | Button-based alternative exists |
| Long translated label | Layout tolerates expansion or wraps/reflows |
| Toast expires for unresolved Overflow | Persistent underlying notice remains accessible |
| Reconnect after finalized trade | Current ownership shown, no fake duplicate finalization |
| Reconnect after finalized event reward | Already-claimed state shown |
| New player starts | Store/social clutter does not dominate first-capture guidance |

## 36. Open Questions

There are **zero GDS-14-blocking open questions**.

Exact visual art direction, final typography asset, exact palette, panel dimensions, animation curves, iconography, localized strings, exact touch target implementation, Roblox safe-area handling, UI framework, notification timing constants and accessibility-setting storage are production/Technical Architecture/tuneable concerns rather than unresolved player-facing semantics.

## 37. Design-Complete Checklist

- [x] Global information hierarchy is explicit.
- [x] HUD and modal focus rules are defined.
- [x] Interaction prompts and input-glyph behavior are defined.
- [x] Confirmation severity and destructive-action presentation are defined.
- [x] Collection exact-instance UI obligations are defined.
- [x] Rarity/Mutation/Trait/Availability/provenance presentation is separated.
- [x] Capture/custody/secure feedback is defined.
- [x] Vault/production/capacity/economy presentation is defined.
- [x] World/mastery/travel/hazard presentation is defined.
- [x] Event phase/contribution/allocation feedback is defined.
- [x] Social presentation is defined.
- [x] Trade revision/final-review UI semantics are defined.
- [x] Commercial purchase presentation is defined.
- [x] Notifications/errors are prioritized.
- [x] Color/audio semantic redundancy is required.
- [x] Reduced Motion/readability baseline is defined.
- [x] Touch/keyboard/gamepad UI parity is defined.
- [x] Onboarding presentation is defined.
- [x] Load/reconnect/reconciliation presentation is defined.
- [x] Localization/text-expansion obligations are defined.
- [x] GDS-15/GDS-16/TA authority remains downstream.
- [x] No implementation-relevant GDS-14 open questions remain.
