# Player Character, Interaction, and Onboarding

> **Status:** Design Complete  
> **Owning GDS phase:** GDS-3 — Player Character, Interaction, and Onboarding  
> **Authority:** Baseline player locomotion, camera, device-independent action grammar, contextual interaction, first-session onboarding, basic equipment/inventory-facing behavior, reset/recovery presentation, and interaction-accessibility invariants  
> **Depends on:** `../00_design_authority.md`, `../01_game_overview.md`, `../product/target_audience_and_platform.md`, `../product/session_shape_and_experience_promise.md`, `../global_rules/02_global_game_rules_and_session_model.md`, `../GLOSSARY.md`

## 1. Purpose and Player Fantasy

MonsterVault should feel immediately playable to a Roblox player without first requiring them to study controls, menus, system terminology, or economy rules.

The player-facing contract is:

> **I can move, look around, understand what I can interact with, act on it, recover when something goes wrong, and reach the core creature-hunting loop quickly on touch, keyboard/mouse, or controller.**

GDS-3 turns the product-level mobile-first and time-to-fun promises into a concrete interaction contract while leaving creature, capture, world, economy, social, and presentation-specific mechanics to their owning phases.

## 2. Scope

This specification owns:

- baseline avatar locomotion expectations;
- baseline camera mode and player camera control;
- semantic input actions and required device mappings;
- contextual interaction selection and ambiguity resolution;
- interaction availability, validation, cancellation, and feedback requirements;
- basic equipment/tool-facing interaction rules without defining tool content;
- basic inventory-facing access rules without defining inventory capacity/economy;
- first-session onboarding sequence and instructional philosophy;
- onboarding persistence/resume/skip behavior;
- safe initial spawn after GDS-2 Persistence Ready;
- reset, failure, stuck-state, and Recovery presentation behavior;
- UI/gameplay input-focus rules;
- baseline cross-device parity and accessibility-relevant interaction constraints;
- GDS-3 analytics outcomes and tuneable interaction parameters.

## 3. Explicit Non-Goals

GDS-3 does **not** define:

- creature taxonomy, creature behavior, ownership, collection slots, or creature loss — GDS-4;
- capture success rules, capture tools, claim semantics, transport, extraction, contesting, or ownership-transfer timing — GDS-5;
- rarity, mutation, trait, or variant semantics — GDS-6;
- vault layout, storage capacity, production, or upgrade systems — GDS-7;
- currencies, progression formulas, equipment stats, upgrade trees, or prestige — GDS-8;
- world topology, biome traversal requirements, hazards, spawn tables, checkpoints, or fast-travel network — GDS-9;
- PvP, stealing, parties, cooperation, player collision policy, or grief-prevention systems — GDS-10;
- live-event mechanics or participation rules — GDS-11;
- trading interaction flow — GDS-12;
- purchase flows or monetization UI — GDS-13;
- final HUD composition, visual style, iconography, typography, settings screens, remapping UI, reduced-motion implementation, or full accessibility feature set — GDS-14;
- Roblox policy/maturity/moderation constraints — GDS-15;
- retention-loop design or production analytics implementation — GDS-16;
- exact Roblox services, input APIs, camera scripts, character controllers, networking, anti-cheat, persistence storage, or code architecture — Technical Architecture.

## 4. Terminology

Shared terms are normalized in `../GLOSSARY.md`.

### Player Character
The controllable in-world avatar through which the player moves, explores, approaches opportunities, and performs world interactions during Active Presence.

### Primary Interact
The universal semantic action used to activate the currently selected contextual world interaction, such as speaking, opening, inspecting, entering, confirming a world prompt, or beginning a downstream mechanic.

### Primary Action
The semantic action used by the currently active gameplay tool or downstream mechanic. GDS-3 owns its cross-device availability, not the mechanic-specific effect.

### Context Candidate
A nearby or currently targeted world interaction that is valid enough to be considered for Primary Interact.

### Active Context
The single Context Candidate currently selected for Primary Interact and presented as the player's actionable target.

### Interaction Prompt
The player-facing indication that an Active Context exists, including a concise action label and device-appropriate input glyph/control.

### Safe Arrival
The short protected entry/recovery state after Persistence Ready and before ordinary exposed gameplay, used to establish camera, controls, orientation, and a valid recovery position.

### Onboarding Milestone
A persistent player-specific record that a required introductory learning step has been successfully demonstrated or completed.

### Guidance Layer
Non-essential instructional prompts, highlights, arrows, hints, or reminders that teach the player but do not themselves grant progression outcomes.

### Recovery Anchor
A world-defined valid return location that GDS-9 may provide for GDS-2 Recovery. GDS-3 defines how Recovery uses a valid anchor from the player's perspective; GDS-9 owns where anchors exist.

### Input Mode
The currently dominant interaction family: touch, keyboard/mouse, or gamepad. Input Mode may change during a session without changing gameplay capability.

## 5. Participating Entities and Ownership

GDS-3 concerns:

- the player/account, which owns onboarding milestones and settings-compatible interaction preferences when persisted;
- the Player Character, which is temporary runtime presence rather than persistent progression identity;
- the camera, which presents the world and current interaction context;
- Context Candidates and the one Active Context;
- equipment/tools supplied by downstream systems;
- Guidance Layer presentation;
- Recovery Anchors supplied by world design;
- device/input state.

The Player Character does not own Persistent Player State. Destroying, respawning, or replacing the avatar does not itself destroy the player's persistent progression, consistent with GDS-2.

## 6. Core Rules and Invariants

### PC-01 — Immediate direct control after safe readiness
After Persistence Ready and Safe Arrival initialization, the player receives direct movement/camera control without being forced through a long modal tutorial or non-skippable cinematic.

### PC-02 — Third-person character-centric baseline
The baseline exploration camera is third-person and character-centric with player-controlled orbit/look. Core progression must not require first-person mode.

A later optional first-person or special camera may exist only if ordinary progression remains fully viable without it.

### PC-03 — Familiar continuous locomotion
Baseline exploration uses continuous directional movement with a conventional jump action. Ordinary movement must not require rhythm input, repeated tapping, cursor pathing, or precision platforming as a universal prerequisite for the core loop.

### PC-04 — Ordinary movement has no baseline stamina tax
Walking/running and ordinary jump traversal do not consume a universal stamina/energy resource merely to navigate baseline spaces. A later explicitly designed traversal mechanic may have its own bounded resource, but basic locomotion remains dependable.

### PC-05 — Movement remains available during ordinary exploration
Opening a short contextual world prompt must not unexpectedly immobilize the player unless the interaction has clearly transitioned into a mechanic that requires committed control. Modal menus may suppress gameplay input while open.

### PC-06 — One universal contextual interaction semantic
World objects that are activated contextually use **Primary Interact** rather than each inventing unrelated required buttons.

### PC-07 — One Active Context at a time
When several Context Candidates overlap, the game selects one Active Context deterministically and presents only that interaction as immediately actionable. The player must not trigger a hidden secondary candidate by accident.

### PC-08 — Context selection prioritizes player intent and relevance
Active Context selection should favor candidates that are both valid and plausibly intended based on proximity, camera/character facing, visibility, and gameplay priority. Exact scoring is tuneable/technical, but selection must be stable enough not to flicker rapidly between candidates.

### PC-09 — Prompts describe the action, not only the button
An Interaction Prompt must communicate a concise verb/outcome such as `Inspect`, `Enter`, `Talk`, `Open`, or a downstream mechanic-specific action. Showing only a button glyph without semantic meaning is insufficient.

### PC-10 — Invalid actions fail safely
If an interaction becomes invalid between presentation and activation, the action must resolve as a clear no-op or understandable rejection rather than granting a partial/contradictory outcome.

### PC-11 — Device changes do not change capability
Changing between touch, keyboard/mouse, and gamepad during a session may change prompts and input glyphs but does not create or remove core gameplay capabilities.

### PC-12 — Mobile-first parity
Every baseline progression-critical action must have a touch interaction that does not require tiny targets, hover, right-click, keyboard chords, precision cursor placement, or simultaneous multi-finger gestures.

### PC-13 — Controller parity
Every baseline progression-critical action must be reachable through gamepad controls without requiring a pointer-emulation workaround as the only practical path.

### PC-14 — Keyboard/mouse convenience may not become exclusivity
Keyboard/mouse may provide faster camera control or shortcuts, but shortcuts must duplicate accessible actions rather than unlock exclusive progression behavior.

### PC-15 — Critical interactions use explicit activation
Merely walking near, looking at, or brushing against an interactable must not finalize irreversible progression, spending, trading, or other consequential actions unless a later owning system explicitly defines automatic collection with equally clear semantics.

### PC-16 — Consequential actions cannot be accidental input spillover
An input used to dismiss a modal, close a menu, skip a hint, respawn, or regain focus must not simultaneously activate a newly exposed irreversible world action on the same press/release event.

### PC-17 — Tool/action semantics are abstract and consistent
Downstream systems may equip a tool or temporary mechanic that uses **Primary Action**. The action must remain available on every supported Input Mode and must not require a wholly unrelated control vocabulary for each tool.

### PC-18 — Equipment does not redefine basic movement/camera by default
Equipping a gameplay tool may add targeting/presentation but does not remove ordinary locomotion or camera agency unless the downstream mechanic enters a clearly communicated committed state.

### PC-19 — Inventory-facing access is non-time-critical by default
The player may access carried equipment/collection-facing UI through a clear inventory/equipment entry point. Inventory organization must not require drag-and-drop as the only input method. Exact slots, capacity, item semantics, and collection storage remain downstream authority.

### PC-20 — Menus explicitly own input focus
When a modal menu is open, gameplay actions that would conflict with menu navigation are suppressed. Closing the menu restores gameplay control predictably.

### PC-21 — Camera assistance must yield to player intent
Automatic camera framing, recentering, or onboarding focus may briefly guide attention, but direct player camera input takes priority and cannot be continuously fought by automation.

### PC-22 — Core information may not depend on camera precision
A progression-critical interaction cannot require the player to maintain pixel-precise aim on a tiny target. Context selection may use camera direction as one signal, but proximity and accessible targeting must remain viable.

### PC-23 — Camera obstruction must not hide required interaction indefinitely
World/camera design must provide a recoverable view when geometry obstructs the Player Character or required target. Exact collision/zoom algorithms belong to TA/GDS-14, but persistent unrecoverable occlusion is a design failure.

### PC-24 — First-session onboarding is gameplay-first
The first session teaches through short `show -> do -> confirm` steps embedded in real gameplay. It must not begin with a lore dump, store-first flow, multi-page manual, or long mandatory dialogue sequence.

### PC-25 — First-session pacing inherits GDS-1 targets
The onboarding must be designed so that a typical first-time player can target:

- direct interactive control effectively immediately after loading/readiness;
- a clearly visible meaningful goal within roughly 30–45 seconds;
- a first genuine downstream capture attempt within roughly 60 seconds;
- a first secured creature within roughly 3 minutes;
- a first visible progression choice within roughly 6 minutes.

GDS-3 owns instructional sequencing; GDS-5/GDS-7/GDS-8 own the mechanics used to satisfy later milestones.

### PC-26 — The first learning path must be available
A new player must not be permanently blocked from learning the core loop because another player consumed the only nearby opportunity, camped the arrival area, or triggered a server state the newcomer cannot understand.

The exact protection/reservation/world-content mechanism is owned by GDS-5/GDS-9/GDS-10, but those phases must preserve this onboarding availability obligation.

### PC-27 — Guidance is progressive, not front-loaded
The game teaches only the next required concept before asking the player to act. Advanced economy, mutation optimization, trading, monetization, and deep collection management are not introduced before the player has experienced the core acquisition/progression promise.

### PC-28 — Demonstrated knowledge suppresses repeated instruction
Once an Onboarding Milestone proves that the player has successfully performed a basic action, repetitive forced guidance for that action is suppressed in future ordinary sessions.

Optional help/replay presentation may remain available later.

### PC-29 — Guidance can be skipped; progression cannot be fabricated
Players may dismiss or skip non-essential Guidance Layer presentation. Skipping a hint does not grant the reward, ownership, progression, or success that the associated gameplay action would have produced.

### PC-30 — Onboarding resumes rather than restarts destructively
Required Onboarding Milestones persist across ordinary disconnects/server transitions. A returning incomplete player resumes from the earliest valid uncompleted milestone rather than repeating already-finalized rewards or being forced to restart the entire introduction.

### PC-31 — Onboarding must survive late joining
The first-session path may begin in an already-running server. It cannot assume the player observed server startup, an earlier event announcement, or another player's sequence.

### PC-32 — Safe Arrival separates readiness from exposure
After Persistence Ready, the player enters Safe Arrival at a valid world/recovery location before becoming dependent on immediate hazard/competition awareness. Safe Arrival must allow the player to see, orient camera, receive necessary control cues, and gain input control before ordinary exposed play.

### PC-33 — Recovery is short, understandable, and non-punitive globally
Avatar failure/reset/stuck recovery returns the player through a brief clearly signaled Recovery flow to a valid Recovery Anchor. It does not imply a persistent progression wipe or default fee.

### PC-34 — Recovery is not a free fast-travel/extraction exploit
Reset, stuck recovery, or intentional avatar failure must not become a generally superior method to transport transient value, skip traversal costs, escape a finalized consequence, or instantly return valuable unfinalized cargo. The owning downstream system defines what happens to its transient state; GDS-3 only provides the Recovery transition.

### PC-35 — Recovery returns control in a survivable state
The player must not regain control in a position where unavoidable immediate repeat failure is expected. GDS-9/GDS-10 may define hazard/social details, but the selected Recovery Anchor and arrival rules must satisfy GDS-2's safe-recovery invariant.

### PC-36 — Manual stuck recovery is available
If the Player Character becomes trapped or unable to continue due to world/physics state, the player has an understandable route to request Recovery without needing to leave the experience.

The mechanism may reuse the platform reset affordance or a game-provided equivalent; Technical Architecture determines implementation.

### PC-37 — Recovery does not silently change persistent loadout/progression
After Recovery, persistent equipment ownership, unlocks, settings, collection state, and other finalized progression remain unchanged unless a downstream authoritative mechanic had already finalized a consequence before failure.

### PC-38 — Essential controls are readable without free-form text dependence
Control cues may use concise localized labels, icons, input glyphs, highlights, and demonstrations. Understanding movement/interact/jump/basic action may not depend on unrestricted chat or long reading comprehension.

### PC-39 — Critical state feedback uses more than color alone
Available/unavailable/selected/blocked interaction states must not be distinguished solely by color. GDS-14 owns final visual/audio treatment.

### PC-40 — Audio is supportive, not exclusive
No required movement, interaction, recovery, or onboarding instruction may be audio-only.

## 7. Baseline Control Model

GDS-3 defines semantic mappings rather than implementation APIs.

| Semantic | Touch | Keyboard / mouse | Gamepad |
|---|---|---|---|
| Move | virtual movement control | `W/A/S/D` | left stick |
| Camera/look | direct swipe/drag on look region | mouse movement / look control | right stick |
| Jump | dedicated jump button | `Space` | primary south face button / platform-equivalent jump binding |
| Primary Interact | large contextual action button/prompt | `E` as baseline contextual key; mouse activation may duplicate where appropriate | west face button / platform-equivalent contextual binding |
| Primary Action | large mechanic/tool action button | primary mouse button as baseline | right trigger as baseline |
| Cancel/back | device-standard back/cancel affordance | `Esc` / context-appropriate cancel | east face button / platform-equivalent back binding |
| Inventory/equipment access | dedicated reachable UI entry | visible UI entry plus optional shortcut | controller-reachable UI entry |

Rules:

1. platform-equivalent glyphs replace literal Xbox-style labels where necessary;
2. GDS-14 may refine layout, prompt styling, and settings/remapping presentation without removing semantic availability;
3. Technical Architecture may use platform-standard control systems, but behavioral parity above is mandatory;
4. a downstream mechanic may add actions only if it preserves mobile/controller feasibility and does not overload the player with several simultaneous progression-critical buttons;
5. remapping support and final shortcut policy are GDS-14/TA concerns, but no required mechanic may depend on an unchangeable obscure chord.

## 8. Locomotion Contract

### 8.1 Baseline movement

The Player Character supports:

- continuous 2D directional ground movement relative to the playable camera/world control convention;
- conventional jump where world design permits it;
- turning/facing sufficient to make movement and nearby interaction legible;
- recovery from small navigation mistakes without requiring restart.

Exact walk speed, acceleration, jump height, air control, slopes, step height, swimming, climbing, mounts, dashes, gliding, and special traversal are not locked here unless required by another phase.

### 8.2 No precision-platforming gate for the core loop

Optional traversal challenges may exist later, but access to baseline capture/collection/progression cannot universally depend on narrow ledges, frame-perfect jumps, or high dexterity.

### 8.3 Movement during latency or temporary interaction failure

A rejected/expired interaction should not leave the Player Character permanently locked. Any committed mechanic that intentionally restricts movement must define its exit/cancel/interruption state.

## 9. Camera Contract

### 9.1 Baseline exploration camera

The camera:

- is third-person by default;
- supports player-controlled horizontal and vertical look/orbit;
- follows the Player Character during ordinary traversal;
- keeps enough contextual world visibility to notice nearby creatures/opportunities;
- allows device-appropriate sensitivity control in later presentation/settings design.

### 9.2 Guided attention

Short guided camera emphasis may be used to reveal a nearby objective, vault change, creature, or event. It must:

- be brief;
- preserve or rapidly restore player control;
- be interruptible by meaningful player camera input unless a safety-critical transition requires momentary lock;
- not repeatedly yank the camera back after the player deliberately looks away.

### 9.3 Special mechanic cameras

GDS-5 or later systems may introduce temporary target/capture/event framing. Such modes must expose a clear entry/exit, preserve Input Mode parity, and return to the ordinary exploration camera reliably.

## 10. Contextual Interaction State Machine

```text
No Context
   ↓ candidate becomes valid
Candidate Evaluation
   ↓ deterministic selection
Active Context + Prompt
   ├── candidate invalidates → Candidate Evaluation / No Context
   ├── player moves away → No Context
   └── Primary Interact
          ↓
      Revalidate
       ├── invalid → clear rejection/no-op → Candidate Evaluation
       └── valid → Begin owning interaction
                     ↓
              Owning subsystem state machine
                     ↓
          Complete / Cancel / Interrupt
                     ↓
              Candidate Evaluation
```

The prompt itself is not proof that the action will succeed; activation is revalidated at the moment the owning interaction begins.

## 11. Interaction Priority Rules

When multiple Context Candidates overlap, priority is resolved using this design order:

1. currently committed interaction continuation/required confirmation, if any;
2. safety/recovery-critical action;
3. explicit player-targeted/faced valid candidate;
4. nearest high-relevance candidate within practical interaction range;
5. lower-priority ambient/inspect interactions.

A low-value decorative inspection should not steal focus from a nearby progression-critical interaction the player is clearly facing.

The exact numerical scoring/angles/distances belong to tuning/TA, but this semantic ordering is fixed.

## 12. Equipment and Inventory-Facing Behavior

### 12.1 Active tool/equipment

A downstream system may designate one current active tool/action context. GDS-3 requires:

- clear indication that the tool is active;
- availability of Primary Action on every Input Mode;
- a clear exit/unequip path when applicable;
- no silent replacement of persistent owned equipment;
- no requirement to reopen deep menus between every ordinary repeated use.

### 12.2 Inventory access

Basic inventory/equipment UI must:

- be reachable on touch, keyboard/mouse, and controller;
- not require drag-and-drop as the sole way to equip/select/reorder;
- avoid opening automatically over time-critical gameplay unless explicitly required;
- preserve the player's last valid gameplay context when closed where practical;
- never make a hidden UI state the only way to discover the core next action during onboarding.

Capacity, item categories, creature storage, quick-slot count, and equipment stats remain GDS-4/GDS-8 authority.

## 13. First-Session Onboarding Flow

The canonical instructional sequence is:

```text
Persistence Ready
   ↓
Safe Arrival
   ↓
Gain movement + camera control
   ↓
Notice one clear nearby desirable goal
   ↓
Move toward it
   ↓
Learn Primary Interact / relevant Primary Action
   ↓
Enter first real capture opportunity (GDS-5 mechanic)
   ↓
Secure first creature/value (GDS-4/GDS-5 boundary)
   ↓
See visible vault/collection improvement (GDS-7)
   ↓
Make or understand first meaningful progression choice (GDS-8)
   ↓
Receive one clear next aspiration
   ↓
Ordinary play
```

### 13.1 Instruction density

At each step, the Guidance Layer teaches at most the concepts required for the immediate next action. Several unrelated panels are not stacked before control is returned.

### 13.2 Movement teaching

Movement/camera instruction appears only as much as necessary to get the player moving and looking. Once the player demonstrates the action, the corresponding forced cue is completed.

### 13.3 Interaction teaching

The first contextual interaction visibly demonstrates:

- what is interactable;
- what action will happen;
- which current-device input performs it.

### 13.4 First capture handoff

GDS-3 does not define capture. It requires GDS-5 to provide a first capture opportunity whose controls can be taught through the same semantic action grammar, whose difficulty is suitable for first-session learning, and whose availability satisfies PC-26.

### 13.5 First secured outcome

The onboarding must clearly communicate the transition from provisional activity to a secured/finalized owned result once GDS-4/GDS-5 define that boundary.

### 13.6 First progression handoff

After the first secured outcome, the player sees one meaningful collection/vault/progression consequence before being introduced to advanced systems.

## 14. Onboarding Milestones and Persistence

Minimum logical milestones are:

1. `movement_demonstrated`;
2. `camera_control_demonstrated`;
3. `primary_interact_demonstrated`;
4. `first_capture_attempt_started`;
5. `first_secured_outcome_completed`;
6. `first_vault_or_collection_result_seen`;
7. `first_progression_choice_seen_or_completed`;
8. `core_onboarding_complete`.

Names are design-semantic identifiers, not required storage keys.

Rules:

- milestones that correspond to finalized progress are Persistent Player State;
- a reconnect never regrants an already-finalized one-time onboarding reward;
- an incomplete player resumes from the earliest still-valid next step;
- if a later GDS changes the exact mechanic, migration behavior must preserve the semantic fact that an experienced player already learned/completed equivalent basics;
- Guidance Layer prompts may be replayed independently of reward state.

## 15. Skip, Help, and Returning-Player Rules

### 15.1 New player

A genuinely new player receives the canonical onboarding Guidance Layer by default.

### 15.2 Guidance skip

A player may skip/dismiss non-essential instructional overlays. The game then exposes the same real gameplay objectives without fabricating success.

### 15.3 Returning incomplete player

The game resumes incomplete onboarding from a safe valid point with enough context to understand the current next action.

### 15.4 Returning complete player

Forced basic onboarding does not replay every session. Optional contextual help may be accessible when the player appears stuck or explicitly requests guidance.

### 15.5 Device change

Changing Input Mode after onboarding may show a brief updated control cue for the next relevant action without resetting onboarding progression.

## 16. Safe Arrival and Recovery

### 16.1 Safe Arrival sequence

```text
Persistence Ready
  -> establish valid arrival/recovery location
  -> initialize Player Character + camera
  -> show concise orientation/goal cue
  -> grant direct control
  -> ordinary exposure begins
```

Safe Arrival is not a lobby requirement and does not mandate a separate place/server.

### 16.2 Recovery sources

Recovery may be invoked by:

- avatar failure defined by a later hazard/mechanic;
- platform/player reset;
- invalid world position;
- stuck detection or explicit stuck-recovery request;
- subsystem-defined interruption that chooses Recovery as its exit.

### 16.3 Recovery result

Recovery:

- returns the Player Character to a valid Recovery Anchor;
- restores ordinary camera/control state;
- preserves finalized persistent progression;
- gives a concise explanation when the cause/consequence is not obvious;
- does not inherently duplicate or secure transient carried value;
- does not inherently waive downstream finalized costs.

### 16.4 Recovery protection obligation

GDS-9/GDS-10 must ensure a Recovery Anchor is not designed such that a recovering player is predictably subjected to unavoidable immediate hazard/grief before they can regain control.

Exact invulnerability, collision, spawn selection, and protection duration remain later authority.

## 17. Failure, Interruption, and Cancellation

### 17.1 Interaction invalidation

If a target disappears, becomes owned, moves out of range, or otherwise invalidates before activation, the prompt updates/removes and activation safely fails.

### 17.2 Interaction interrupted after begin

Once an owning downstream mechanic begins, that mechanic defines whether the activity:

- completes;
- cancels with no outcome;
- preserves partial session state;
- enters Recovery;
- applies a finalized consequence.

GDS-3 requires a clear exit and restored control; it does not invent subsystem outcomes.

### 17.3 UI interruption

Opening a modal UI during an interaction may be disallowed, cancel the interaction, or pause only local presentation depending on the owning system. It must not accidentally trigger a second world action.

### 17.4 Controller/input loss

Temporary loss of the active input device must not automatically finalize an irreversible action. The player can resume with another supported Input Mode or reconnect controls where the platform permits.

## 18. Multiplayer Semantics

### 18.1 Other players do not change basic controls

The interaction grammar remains the same whether the player is alone or surrounded by others.

### 18.2 Context clutter

Other players and their avatars should not routinely become higher-priority Context Candidates than intended world gameplay targets unless a social mechanic explicitly requires player-to-player interaction.

### 18.3 Onboarding contention

Other players may be visible during onboarding, but they cannot permanently consume all learning opportunities required by the first-session path. Downstream mechanics must provide bounded availability/fallback.

### 18.4 Recovery and social play

Recovery does not guarantee return to the exact pre-failure social position. GDS-9/GDS-10 own anchor placement, party/social regrouping, and grief protections.

## 19. Progression and Economy Interactions

GDS-3 creates no currency values or equipment stats.

It constrains downstream progression as follows:

- onboarding rewards/outcomes must use normal finalized-outcome semantics rather than special duplicate-prone shortcuts;
- basic locomotion is not paywalled or stamina-taxed by default;
- core interaction controls cannot be monetization-gated;
- returning players do not receive repeated one-time onboarding rewards merely because guidance repeats;
- equipment progression may add capability, efficiency, range, or specialized actions only if the baseline interaction grammar remains comprehensible across devices;
- a progression system may not require deep inventory/menu manipulation before the first real core-loop experience.

## 20. Abuse and Exploit Cases

### Reset fast travel
Reset/Recovery must not become a universally optimal vault-return/extraction mechanic for transient value.

### Prompt spoofing/confusion
Consequential prompts require clear action labels and state; decorative or low-value interactions must not visually masquerade as high-value confirmations.

### Context flicker exploitation
Rapid overlap of candidates must not let one input activate a different high-consequence target than the one visibly presented at activation time.

### Input macro advantage
The baseline interaction model should not require extreme tapping rate. Downstream systems should not make macros/turbo input the dominant progression advantage.

### Onboarding reward replay
Disconnect, reset, server hop, device change, or Guidance Layer replay may not regenerate already-finalized one-time onboarding rewards.

### Stuck-recovery farming
Stuck recovery may not refresh finite rewards, cooldowns, paid costs, or persistent timers.

### Multi-account onboarding
GDS-3 does not create transferable high-value rewards solely for completing trivial onboarding. Economy/trading abuse implications remain GDS-8/GDS-12.

## 21. Presentation and Feedback Requirements

Every Active Context should communicate, as applicable:

- what target is selected;
- the action verb;
- current-device input;
- unavailable/blocked state where useful;
- progress if the action intentionally requires a hold/channel;
- completion/cancellation/rejection feedback.

Movement/camera onboarding should use demonstration and concise prompts rather than long text.

Recovery should communicate:

- that a recovery/respawn occurred;
- restored player control;
- any downstream consequence that was finalized;
- where the player is expected to go next when orientation may be lost.

Final HUD/icon/audio/VFX style remains GDS-14 authority.

## 22. Accessibility Baseline

Before GDS-14 adds the full accessibility specification, GDS-3 fixes these interaction invariants:

- no progression-critical action is color-only;
- no required instruction is audio-only;
- touch actions use practical reachable targets rather than tiny precision hit areas;
- the core loop does not require high-frequency repeated tapping;
- the core loop does not require pixel-precision cursor aim;
- essential contextual interactions have a discrete button/press path;
- camera guidance does not continuously override player input;
- ordinary play is viable without free-form chat/voice;
- controller navigation must be possible for every required modal UI exposed during onboarding;
- players who skip non-essential guidance retain access to real objectives and help.

## 23. Analytics and Experimentation Boundaries

GDS-3 considers the following outcomes important to measure later:

- time from control granted to first movement;
- time to first meaningful camera input;
- time to first valid Context activation;
- first-session abandonment before/after each onboarding milestone;
- time to first capture attempt;
- time to first secured outcome;
- time to first progression choice;
- number of repeated failed/invalid interactions;
- time spent in Protected Load Failure/Safe Arrival/Recovery presentation;
- frequency of stuck-recovery/manual reset;
- device/Input Mode distribution and mid-session changes;
- onboarding guidance skip/replay behavior.

Experiments may tune prompt timing, tutorial wording, highlights, camera emphasis, interaction ranges, and guidance sequencing only if they preserve:

- the GDS-1 time-to-fun objective;
- control parity;
- no fabricated progression on skip;
- safe readiness/recovery;
- deterministic consequential interaction;
- accessibility invariants.

Detailed event schemas and experimentation governance remain GDS-16/TA authority.

## 24. Tuneable Parameters

The following are balance/UX parameters rather than semantic rules:

- walk/run speed and acceleration;
- jump height/cooldown if any;
- camera distance, pitch limits, sensitivity defaults, and smoothing;
- context interaction radius;
- facing/visibility weighting for context selection;
- context-switch hysteresis/stability thresholds;
- prompt delay/fade timing;
- hold duration when a later mechanic genuinely needs a hold;
- onboarding hint delay and reminder frequency;
- guided-camera emphasis duration;
- Safe Arrival orientation duration;
- Recovery transition duration;
- time before optional stuck-help is suggested.

Changing these values does not change GDS-3 semantics while the fixed interaction/onboarding rules remain intact.

## 25. Dependencies and Cross-References

### GDS-1
Owns audience, mobile-first parity, time-to-fun, first-session product promise, and short-session viability.

### GDS-2
Owns Persistence Ready, Protected Load Failure, Active Presence, Recovery, session transitions, finalized outcomes, and persistence permanence.

### GDS-4/GDS-5
Must define creature/capture states and the exact secure/finalized boundary while consuming the GDS-3 interaction/onboarding grammar.

### GDS-7/GDS-8
Must provide the first visible vault/progression consequence and any equipment/inventory progression without invalidating the fast onboarding contract.

### GDS-9
Owns world topology, Recovery Anchor placement, hazards, traversal specifics, and world content required to satisfy first-path availability.

### GDS-10
Owns social interference/grief protection and any player-to-player contextual interactions.

### GDS-14
Owns final UI composition, visual/audio language, settings, accessibility implementation, input-glyph presentation, and controller menu navigation detail while preserving GDS-3 semantics.

### Technical Architecture
Owns character controller, camera implementation, input abstraction, context selection implementation, action binding, state machines, validation, networking, anti-cheat, and persistence storage.

## 26. Edge-Case Matrix

| Scenario | Required GDS-3 result |
|---|---|
| New player loads successfully | Safe Arrival -> control -> canonical onboarding |
| Persistent state unavailable | remain outside irreversible play under GDS-2 Protected Load Failure |
| Player joins old/active server | onboarding still has a valid learning path |
| Player changes keyboard to gamepad | prompts update; capability/onboarding state unchanged |
| Mobile player rotates device / UI reflows | critical controls remain reachable; no progression reset |
| Controller disconnects during prompt | no irreversible auto-activation; another Input Mode may resume |
| Two interactables overlap | exactly one visibly selected Active Context |
| Active Context becomes invalid on button press | revalidation -> safe rejection/no contradictory outcome |
| Player closes modal while interactable is underneath | closing input does not spill into world activation |
| Player skips hint | hint closes; gameplay objective remains; no fake reward |
| Disconnect after movement tutorial | completed milestone remains completed |
| Disconnect before first capture finalization | GDS-5 interruption rule decides capture; onboarding resumes from valid milestone |
| First onboarding target taken by another player | downstream system must expose/furnish another valid learning opportunity |
| Player resets during onboarding | Recovery; no duplicate onboarding reward; resume valid milestone |
| Player intentionally resets while carrying transient value | GDS-5/other owning subsystem decides transient consequence; Recovery does not auto-secure it |
| Character falls out of world | Recovery to valid anchor; no global persistent loss |
| Recovery anchor is under active unavoidable hazard | invalid design; GDS-9 must provide safe alternative |
| Camera clips behind geometry | view must be recoverable; required interaction cannot remain unreadable indefinitely |
| Player uses very low camera precision on touch | core contextual targeting remains viable through accessible selection/range |
| Player is color-blind | critical selected/blocked state has non-color cue |
| Player cannot hear audio | all required instructions remain understandable visually/textually/spatially |
| Player replays help after completion | guidance may replay; one-time rewards do not |
| Tool is equipped | Primary Action appears on all Input Modes; locomotion remains available unless committed mechanic says otherwise |
| Tool mechanic ends unexpectedly | gameplay control is restored; owning mechanic defines outcome |
| Inventory opens during exploration | menu owns focus; world actions suppressed until close |
| Player returns months later | no forced full basic tutorial; optional/contextual help can reappear |
| Player joins friend in gated area | social join does not silently bypass GDS-2/GDS-9 progression rules |
| Multiple players crowd an interactable | player avatars do not routinely steal context focus from world target |
| Rapid button spam | no unintended duplicate finalized outcome; owning systems/TA enforce single application |
| Network latency invalidates interaction | clear rejection/retry path; character not permanently locked |
| First-session server state is unusual/event-active | basic onboarding remains understandable and available |
| Player opens settings/help | leaving it restores prior gameplay state predictably |

## 27. Open Questions

There are **no GDS-3-blocking open questions**.

Detailed downstream questions are intentionally delegated to their owning phases, including capture controls/effects, world traversal content, hazard consequences, equipment stats/capacity, social player interaction, final UI composition, and accessibility settings.

## 28. Design-Complete Checklist

- [x] Purpose and scope are explicit.
- [x] Core rules are deterministic.
- [x] Locomotion expectations are defined.
- [x] Camera expectations are defined.
- [x] Cross-device semantic controls are defined.
- [x] Contextual interaction state/priority is defined.
- [x] Basic equipment/inventory-facing behavior is defined.
- [x] First-session onboarding sequence is defined.
- [x] Onboarding persistence/resume/skip rules are defined.
- [x] Safe Arrival and Recovery behavior are defined.
- [x] Multiplayer/onboarding contention obligations are defined.
- [x] Abuse cases are addressed.
- [x] Accessibility-level interaction invariants are defined.
- [x] Analytics/tuning boundaries are explicit.
- [x] Edge cases are covered.
- [x] Cross-references preserve one authoritative owner per rule.
- [x] No implementation-relevant GDS-3 open questions remain.

**GDS-3 subsystem result: DESIGN COMPLETE.**