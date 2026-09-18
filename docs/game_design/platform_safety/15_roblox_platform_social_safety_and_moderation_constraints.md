# Roblox Platform, Social Safety, and Moderation Constraints

> **Status:** Design Complete  
> **Owning GDS phase:** GDS-15 — Roblox Platform, Social Safety, and Moderation Constraints  
> **Authority:** Roblox-policy-facing gameplay constraints, policy-gated feature eligibility, age/account/privacy-resilient social design, text/chat exposure, user-generated text filtering obligations, reporting/blocking integration, experience-level moderation semantics, content-maturity boundaries, commercial/trading policy boundaries, privacy/data-minimization expectations, and moderation-safe persistence behavior  
> **Depends on:** ../00_design_authority.md, ../01_game_overview.md, ../global_rules/02_global_game_rules_and_session_model.md, ../player/03_player_character_interaction_and_onboarding.md, ../creatures/04_creatures_collection_and_ownership.md, ../capture/05_capture_contesting_transport_and_extraction.md, ../rarity_mutations/06_rarity_mutations_traits_and_variant_value.md, ../vault/07_vault_base_passive_production_capacity_and_upgrades.md, ../economy_progression/08_economy_progression_unlocks_and_pacing.md, ../world/09_world_biomes_exploration_spawning_and_hazards.md, ../social/10_social_play_cooperation_competition_and_pvp_boundaries.md, ../events_liveops/11_server_events_dynamic_encounters_and_live_content.md, ../trading/12_trading_and_player_economy.md, ../monetization/13_monetization_and_commercial_fairness.md, ../presentation/14_presentation_ui_ux_feedback_and_accessibility.md, ../GLOSSARY.md

## 1. Purpose and Safety Promise

MonsterVault targets a broad youth audience on Roblox and must remain playable when communication, commerce or social capabilities differ by age, account state, region, platform policy or parental settings.

The player-facing safety contract is:

> **Core MonsterVault progression never requires unrestricted chat, voice, off-platform contact or unsafe user-generated text. Roblox-authoritative safety and eligibility decisions are respected. Reporting/blocking remain accessible. Moderation can restrict unsafe behavior without silently confiscating legitimate secured collection value, and a player who cannot use an optional social/commercial feature still retains a complete core gameplay path.**

## 2. Platform Policy Snapshot

GDS-15 was reviewed against official Roblox platform guidance current on **2026-09-18**, including:

- Roblox Community Standards;
- Roblox Safety Tools and Policies;
- Parental Controls / communication controls;
- Experience Chat safety and age-check behavior;
- TextChatService and Chat System Guidelines;
- Text filtering requirements for user-visible text;
- Content Maturity & Compliance guidance;
- PolicyService guidance for per-user policy restrictions;
- paid random item / paid item trading policy guidance;
- Roblox monetization guidance on truthful urgency/promotion;
- Roblox in-experience reporting guidance.

Because Roblox policies and APIs can change, GDS-15 does **not** hard-code mutable age thresholds, country lists or platform flags into gameplay semantics.

Technical Architecture and launch-readiness review must re-check current official Roblox requirements.

## 3. Scope

GDS-15 owns:

- platform-authoritative feature eligibility;
- age/account/region-sensitive capability degradation;
- chat/voice independence of core progression;
- Roblox communication-control compliance;
- user-generated text policy;
- freeform naming/text decision;
- Social Ping safety;
- Party/trade/visitor social-safety constraints;
- reporting and blocking expectations;
- experience moderation actions;
- anti-harassment/anti-spam rules;
- off-platform contact solicitation boundaries;
- personal-information handling;
- content maturity target;
- authored content boundaries;
- gambling/wagering presentation boundaries;
- paid-random-item policy defense-in-depth;
- paid-item-trading policy boundary;
- platform policy change handling;
- safe moderation/reconciliation behavior;
- downstream GDS-16 and Technical Architecture obligations.

## 4. Explicit Non-Goals

GDS-15 does **not** define:

- retention KPI targets, notification campaigns or experiment cadence — GDS-16;
- Roblox API implementation details — Technical Architecture;
- ban datastore schema;
- moderation classifier implementation;
- fraud-detection models;
- customer-support workflows;
- legal interpretation of every jurisdiction;
- appeals processing;
- account age verification implementation;
- Roblox parental-control UI;
- Roblox platform enforcement decisions;
- platform moderation outcomes outside MonsterVault;
- external identity verification.

## 5. Canonical Terminology

Shared terms remain authoritative in ../GLOSSARY.md.

### Platform Eligibility
A Roblox-authoritative per-player result indicating whether a platform-regulated feature is currently permitted for that user/account/context.

### Policy-Gated Feature
A MonsterVault feature whose availability or behavior must respect Roblox-provided policy/eligibility information rather than a hard-coded local age/country rule.

### Communication Eligibility
The platform-authoritative result governing whether a player may participate in a given text/direct/social communication capability.

### Structured Communication
A predefined non-freeform message/action vocabulary such as GDS-10 Social Pings, where the player selects authored meanings instead of entering arbitrary public text.

### User-Generated Text
Text whose semantic content is chosen by a player and displayed to one or more other users.

### Filtered User Text
User-Generated Text that has successfully passed the appropriate Roblox-authoritative text filtering flow for its intended audience.

### Safety Restriction
A MonsterVault experience-level limitation applied to unsafe/disruptive behavior, such as suppressing directed social requests, restricting trading/social interaction, kicking or banning from the experience.

### Safety Action
An experience-level moderation result that changes access/social capability without rewriting unrelated legitimate collection/economy history.

### Platform Report Flow
Roblox's built-in or platform-authoritative reporting capability for users/content/communication.

### Social Isolation
A safe fallback state in which optional directed social interaction is unavailable while solo/core gameplay remains functional.

### Content Maturity Target
The intended Roblox content-maturity envelope for MonsterVault launch content.

## 6. Platform-Authoritative Eligibility

### PE-01 — Roblox policy decisions outrank local assumptions

If Roblox indicates a feature is unavailable for a user, MonsterVault must not bypass that decision through custom UI or alternate interaction.

### PE-02 — No hard-coded age/country inference for policy decisions

MonsterVault gameplay must not infer communication or commerce permission solely from:

- self-reported age;
- visible profile text;
- language;
- device;
- IP-derived assumptions;
- locally maintained country lists.

Where Roblox exposes policy/eligibility, that result is authoritative.

### PE-03 — Optional features degrade safely

If a Policy-Gated Feature is unavailable:

- core exploration/capture/Vault/progression remains available;
- the UI explains unavailability without exposing sensitive account details;
- the player is not punished economically;
- no fake workaround is offered.

### PE-04 — Policy checks are per user

A feature permitted for one participant does not imply permission for another participant.

### PE-05 — Policy uncertainty fails closed for regulated optional actions

If required eligibility cannot be established for a regulated optional feature, MonsterVault does not guess permissively.

## 7. Core Gameplay Must Not Depend on Chat or Voice

### CV-01 — Chat is optional to progression

A player can complete baseline:

- onboarding;
- capture;
- world progression;
- Vault progression;
- events;
- Trade Access;
- trading negotiation/confirmation;
- collection management

without unrestricted text chat.

### CV-02 — Voice is never required

Voice availability cannot gate:

- Party membership;
- Shared Objective contribution;
- event eligibility;
- trading;
- world progression;
- safety/reporting.

### CV-03 — Structured systems carry core coordination

Social Pings, objective markers, Party state and trade structured UI provide the required communication vocabulary.

### CV-04 — Disabled communication does not reduce gameplay rewards

A player with chat/voice unavailable is not given worse:

- spawn odds;
- event rewards;
- trade rates;
- Energy rewards;
- progression pacing.

## 8. Text Chat Integration Boundary

### CH-01 — Roblox-authoritative chat system only

If MonsterVault exposes in-experience text chat, it must use Roblox's supported chat/communication system and respect per-user communication eligibility.

### CH-02 — MonsterVault does not implement an unrestricted parallel chat network

No custom unfiltered freeform chat channel, guild chat, whisper system or persistent mailbox is authorized.

### CH-03 — Core UI must tolerate chat being absent

No required button, tutorial or objective assumes a visible chat window.

### CH-04 — Chat decoration cannot weaken filtering

Presentation may decorate permitted messages, but cannot reconstruct, expose or re-display unfiltered source text.

### CH-05 — Direct communication follows platform eligibility

MonsterVault-directed messaging features cannot be used to recreate direct chat when Roblox does not permit it.

## 9. User-Generated Text Baseline

### UT-01 — No baseline custom public freeform naming

Launch baseline does not authorize player-authored public:

- creature names;
- Vault names;
- Party names;
- signs;
- bulletin boards;
- custom status text;
- profile bios;
- trade notes.

This sharply reduces moderation and privacy risk for the primary audience.

### UT-02 — Future user-visible text requires filtering

Any future User-Generated Text visible to another player must be successfully filtered for the intended audience before display.

### UT-03 — Filtering failure means do not display

A filter/service failure cannot fall back to raw text.

### UT-04 — Stored text remains subject to safe retrieval/display rules

Persistence does not convert previously entered user text into trusted content.

### UT-05 — User-provided URLs/contact handles are not baseline-authorized

MonsterVault provides no custom field for:

- Discord handles;
- phone numbers;
- email addresses;
- social usernames;
- external URLs;
- school/location contact details.

## 10. Structured Communication

### SC-01 — Social Pings remain predefined

GDS-10 Social Pings use authored meanings such as:

- come here;
- creature sighting;
- objective;
- danger;
- regroup;
- return/Secure Point.

### SC-02 — No text payload attached to baseline Pings

Players cannot append arbitrary text to a Social Ping.

### SC-03 — Rate limits and duplicate suppression remain mandatory

Ping spam cannot become harassment through volume.

### SC-04 — Mute/suppression remains free

No payment is required to suppress Social Pings.

### SC-05 — Block/communication restrictions override directed Pings

Where platform/account restrictions indicate directed interaction should not occur, MonsterVault does not deliver new directed Ping/contact attempts.

## 11. Party Safety

### PS-01 — Party remains explicit consent

Invites require acceptance.

### PS-02 — Party cannot be used as a chat bypass

Party membership does not unlock communication the platform/account otherwise disallows.

### PS-03 — Party leadership remains narrow

Leader controls grouping state only, never:

- account settings;
- reporting;
- player-owned creatures;
- Energy;
- purchases;
- moderation outcomes.

### PS-04 — Blocking/restriction ends unsafe directed Party contact

Where supported by platform state, blocked/restricted users cannot continue sending new Party invites to the affected player.

Existing grouping resolves safely without value loss.

### PS-05 — Party names are not baseline freeform text

The baseline Party has no player-authored public name field.

## 12. Trading Safety

### TS-01 — Structured trade requires no freeform negotiation

The protected Trade Session is complete through authoritative offer state and dual confirmation.

### TS-02 — Off-platform promises are not protected consideration

The trade UI never validates or encourages:

- Robux promises;
- external payment;
- gift-card exchange;
- Discord negotiation;
- real-money purchase;
- account/password exchange.

### TS-03 — Trade UI provides contextual reporting access

A player must be able to reach the platform report flow from a relevant social/trade context without needing the counterparty's cooperation.

### TS-04 — Blocking/restriction suppresses new trade invitations

Where platform/account restrictions indicate interaction should not occur, new directed trade invitations are not delivered.

### TS-05 — Commercial entitlements are not tradable baseline items

GDS-13 paid cosmetics/capacity entitlements remain account-bound presentation/convenience and do not enter GDS-12 Trade Offers.

### TS-06 — Baseline creature trading is not paid-item trading

Baseline GDS-12 trades involve game-earned Secured Creature Instances, not Robux-purchased tradable items.

If future design makes a paid item tradable, GDS-12/GDS-13/GDS-15 must reopen and apply current Roblox paid-item-trading eligibility requirements.

## 13. Reporting

### RP-01 — Roblox report capability remains accessible

MonsterVault must not hide, obstruct or replace the platform's reporting path.

### RP-02 — Contextual report affordances are desirable

Relevant player surfaces such as:

- Party member card;
- trade participant card;
- visitor list;
- social interaction panel

may provide a clear route into the platform report flow.

### RP-03 — Reports target behavior/content, not economic retaliation

Reporting another player does not itself:

- transfer their creatures;
- grant the reporter Energy;
- reverse a trade automatically;
- provide gameplay advantage.

### RP-04 — False-report reward loops are prohibited

No reward is granted for report quantity.

### RP-05 — Report flow does not expose private moderation status

Players need not see internal enforcement history of another account.

## 14. Blocking and Directed Interaction

### BL-01 — Blocking is a safety boundary, not a gameplay penalty

When a block/restriction is known/applicable, MonsterVault suppresses new directed social contact where feasible.

### BL-02 — Core matchmaking/world coexistence does not imply direct contact permission

Two users may still exist in a shared public server while directed invitations/Pings/trade requests are suppressed according to platform capability.

### BL-03 — Blocking does not steal finalized value

Existing Secured Creatures, Energy, unlocks, event records and finalized trade history remain unchanged.

### BL-04 — Blocking cannot be used to reroll opportunities

Blocking another player does not reset public creatures, Event Occurrences or reward eligibility.

## 15. Experience-Level Moderation

### EM-01 — MonsterVault may restrict abusive behavior

Experience-level actions may include, subject to current platform capability and TA:

- directed-social restriction;
- structured-Ping restriction;
- trade-invite restriction;
- temporary kick;
- temporary/permanent experience ban.

### EM-02 — Moderation actions are policy/safety based

Experience moderation is not sold and cannot be purchased as advantage.

### EM-03 — Moderation does not silently confiscate legitimate collection value

A social/trade restriction, kick or experience ban does not itself rewrite:

- Creature ownership;
- Energy;
- Region Mastery;
- Event Completion;
- provenance;
- finalized trade history.

### EM-04 — Platform moderation remains authoritative outside MonsterVault

MonsterVault cannot override Roblox account moderation or platform access restrictions.

### EM-05 — Ban evasion is not tolerated

Where Roblox/TA provides supported mechanisms for detecting/enforcing ban evasion, MonsterVault may apply them consistent with platform policy.

## 16. Harassment and Griefing Boundaries

### HG-01 — No social feature may enable indefinite directed spam

Party invites, trade invites, challenge invites and Pings are rate-limited/suppressible.

### HG-02 — No economic punishment for declining social contact

Declining Party/trade/challenge requests cannot:

- deduct Energy;
- reduce spawn odds;
- remove event eligibility;
- reveal private account details.

### HG-03 — No body-blocking or collision harassment

GDS-10 non-obstructive collision remains unchanged.

### HG-04 — No public humiliation system

MonsterVault does not publish:

- report counts;
- "most rejected" labels;
- non-spender shame;
- trade-loss shame;
- moderation history leaderboards.

### HG-05 — No forced re-contact loop

A declined/blocked directed request cannot immediately reappear indefinitely.

## 17. Personal Information and Off-Platform Safety

### PI-01 — MonsterVault does not solicit unnecessary personal information

The game does not ask players for:

- legal name;
- home address;
- school;
- phone number;
- email;
- password;
- date of birth;
- precise location;
- external social handle.

### PI-02 — No password/account exchange mechanics

No game flow asks one player to share account credentials with another.

### PI-03 — No off-platform contact requirement

Progression, support, trading, events and social participation do not require joining Discord or another external service.

### PI-04 — No external payment negotiation

MonsterVault trading/commercial UI does not direct players to outside payment channels.

### PI-05 — Platform identity is sufficient

Where player identity display is needed, MonsterVault relies on Roblox-authoritative identity fields/capabilities rather than collecting a separate identity profile.

## 18. Content Maturity Target

### CM-01 — Launch targets a broad youth-compatible maturity envelope

MonsterVault is designed for a **Minimal-to-Mild** Roblox content maturity outcome.

The final questionnaire must be answered truthfully from shipped content.

### CM-02 — Moderate/Restricted content is not baseline-authorized

A design/content change expected to require a Moderate or Restricted label must reopen GDS-15 before launch/adoption.

### CM-03 — No realistic gore or graphic injury

Capture/hazards remain stylized and non-graphic.

### CM-04 — No authored sexual/romantic adult content

The baseline game contains no sexual content or adult romantic themes.

### CM-05 — No authored drug/alcohol/tobacco gameplay

The baseline does not use these as collectible, purchasable or reward mechanics.

### CM-06 — No strong profanity in authored content

Core authored text/audio remains suitable for the intended youth audience.

### CM-07 — No playable gambling/wagering loop

MonsterVault contains no stakes-based gambling with value-bearing prizes.

Friendly Challenges remain non-wagering.

## 19. Violence and Competition

### VC-01 — No direct-combat PvP baseline remains

GDS-10 prohibition remains authoritative.

### VC-02 — Capture presentation is creature collection, not graphic harm

Capture challenges avoid realistic injury/gore framing.

### VC-03 — Hazards produce temporary Recovery

Hazards do not present graphic persistent injury or secured-value death penalties.

### VC-04 — Competition stays non-loss-dominant

Players cannot commercially/socially force permanent loss of another player's secured collection.

## 20. Randomization and Paid Random Item Boundary

### PR-01 — GDS-13 baseline has no paid random items

No Robux-paid or Robux-derived currency purchase produces a random creature/Mutation/cosmetic outcome.

### PR-02 — Free gameplay randomization remains separated from paid value

Ordinary world spawn/Mutation randomness is earned through gameplay, not purchased access to a random outcome.

### PR-03 — Future paid random design requires policy-gated review

Any future paid random mechanic must reopen:

- GDS-6;
- GDS-13;
- GDS-15

and comply with current Roblox odds-disclosure and per-user eligibility requirements.

### PR-04 — No indirect paid-random workaround

Buying a premium currency/token that is then consumed for random rewards still counts as paid-random design and is not baseline-authorized.

## 21. Commerce and Purchase Safety

### CO-01 — GDS-13 truthfulness remains mandatory

No fake scarcity, false countdown, fake discount or pressure language.

### CO-02 — Platform commerce eligibility is respected

If a paid product category is policy-gated for a user, MonsterVault does not expose a workaround.

### CO-03 — Parental/account restrictions fail safely

A blocked purchase leaves gameplay state unchanged and the free progression route intact.

### CO-04 — Core safety/accessibility remains free

Reporting, blocking access, Creature Lock, trade safety, Reduced Motion and readability cannot be commercial entitlements.

### CO-05 — Cross-game commerce is not assumed by design

Baseline MonsterVault products are defined for MonsterVault itself; no gameplay requirement depends on cross-game developer-product behavior.

## 22. User-Generated Assets and Content

### UG-01 — Baseline does not require custom user-uploaded game content

MonsterVault does not depend on players uploading images/audio/models/text to participate.

### UG-02 — Roblox avatar content remains platform-managed

Player avatars may contain Roblox-authorized avatar content, but MonsterVault does not reinterpret avatar items as gameplay progression or creature value.

### UG-03 — Future in-game UGC surfaces require GDS-15 reopening

Examples:

- custom decals;
- drawings;
- custom audio;
- signs;
- player-authored creature descriptions;
- public photo/image content.

They require explicit moderation/filtering/content-maturity design.

## 23. Naming and Identity Presentation

### NI-01 — Platform username/display identity may be shown

MonsterVault may use Roblox-provided player identity presentation where appropriate.

### NI-02 — No custom impersonation field

Players cannot define a separate public MonsterVault identity string designed to look like another user's authoritative Roblox identity.

### NI-03 — System labels remain distinguishable from player identity

"Party Leader", "Supporter", "Event Winner" and similar status markers are presentation labels, not account verification.

## 24. Social Feature Degradation Matrix

| Feature | If communication/social eligibility is unavailable |
|---|---|
| Core exploration | Fully available |
| Capture | Fully available |
| Vault | Fully available |
| Region Mastery | Fully available |
| Events | Fully available |
| Party | May be unavailable/restricted; solo path remains |
| Social Pings | Directed delivery may be restricted |
| Friendly Challenge | May be unavailable/restricted |
| Vault Visitors | May be restricted |
| Trade Invite | May be restricted by interaction policy |
| Trade Session | Only available when required participants are eligible |
| Text chat | Absent/limited per Roblox |
| Voice | Absent/limited per Roblox |
| Shop | Governed independently by commerce eligibility |
| Reporting | Remains accessible |

## 25. Safety-Aware Trading and Commercial Interaction

### ST-01 — No player can use commerce to bypass a safety restriction

Paid status cannot re-enable:

- blocked communication;
- blocked trade interaction;
- report suppression;
- moderation bypass.

### ST-02 — Trading remains structured enough to operate without chat

The authoritative offer itself is the protected agreement.

### ST-03 — High-value trade warnings do not shame or manipulate

Warnings remain factual.

### ST-04 — Account-bound commercial entitlements stay outside creature trade

This avoids paid-item trading complexity at baseline.

## 26. Platform Policy Change Handling

### PC-01 — Roblox policy is a moving external dependency

A platform change may require behavior to narrow without reopening unrelated gameplay phases.

### PC-02 — Narrowing for compliance is allowed when upstream value is preserved

Example: disabling an optional social feature for an ineligible user does not violate GDS-10 if solo/core paths remain intact.

### PC-03 — Expanding power requires design change control

A platform change does not automatically authorize:

- paid random acquisition;
- paid-item trading;
- unrestricted custom chat;
- new UGC;
- higher-maturity content.

Such expansion requires the owning GDS phases to reopen.

### PC-04 — Pre-launch platform review is mandatory

Before implementation lock/launch, Technical Architecture/operations must re-check current official Roblox policy and relevant APIs.

## 27. Safety and Moderation Presentation

### SM-01 — Report/block actions are discoverable

Players should not need unrestricted chat to find them.

### SM-02 — Moderation reason presentation is concise and safe

Where MonsterVault displays an experience-level restriction reason, it avoids exposing internal detection methods or another user's private information.

### SM-03 — Safety controls outrank commercial surfaces

A report/block/moderation state cannot be obscured by shop prompts.

### SM-04 — Restricted social feature explains only necessary information

Example:

- `This social feature is unavailable for your account settings.`

rather than revealing age, region or policy internals unnecessarily.

## 28. Accessibility and Safety Interaction

### AS-01 — Safety does not depend on audio/chat

Warnings/reporting/interaction restrictions have non-audio and non-chat paths.

### AS-02 — Reduced Motion does not suppress safety warnings

Calmer presentation still communicates hazards/moderation/trade states.

### AS-03 — Blocking/reporting controls remain accessible across input modes

Touch, keyboard/mouse and gamepad parity applies.

### AS-04 — Safety text supports readability/localization requirements

GDS-14 remains authoritative.

## 29. Analytics and Experimentation Boundary

GDS-16 may measure:

- invite/report/block flow usage;
- social feature availability rates;
- Ping mute rates;
- trade-invite rejection/suppression;
- moderation action counts;
- policy-gated feature unavailability;
- chat-independent completion rates;
- safety funnel abandonment;
- payer/non-payer safety parity.

Experiments may **not**:

- weaken filtering;
- reduce reporting discoverability;
- bypass Roblox eligibility;
- make safety controls premium;
- increase spam limits solely for engagement;
- hide free/solo paths;
- expose restricted communication to improve retention.

## 30. Technical Architecture Obligations

Technical Architecture must define:

- authoritative Policy-Gated Feature checks;
- TextChatService integration where chat is exposed;
- user-generated text filtering path;
- fail-closed behavior on filtering failure;
- safe rate limits;
- report/block contextual integration;
- Ban/kick/restriction implementation;
- social-invite eligibility checks;
- moderation auditability;
- safe persistence of experience restrictions;
- platform-policy configuration/version review;
- content-maturity launch checklist;
- purchase/trading policy checks if future paid-item features exist.

TA may choose exact APIs only after re-validating current Roblox documentation.

## 31. Tuneable Parameters

Tuneable without reopening GDS-15:

- invite/Ping rate limits;
- temporary experience-level restriction duration;
- report shortcut placement;
- safety-warning copy;
- moderation notification wording;
- Social Isolation presentation;
- exact authored content intensity within Minimal-to-Mild target;
- cooldown after declined social request.

Semantic/change-control decisions:

- policy-authoritative eligibility;
- no hard-coded mutable age/country policy logic;
- core progression independent of chat/voice;
- no unrestricted parallel custom chat;
- no baseline freeform public user text/naming;
- successful filtering required for future user-visible text;
- structured Social Pings;
- report/block accessibility;
- blocking suppressing new directed contact where applicable;
- moderation not confiscating legitimate secured value;
- no off-platform contact/payment requirement;
- no unnecessary personal-information solicitation;
- Minimal-to-Mild maturity target;
- no playable gambling/wagering;
- no baseline paid random items;
- commercial entitlements not tradable;
- platform change cannot silently expand gameplay authority.

## 32. Edge-Case Matrix

| Situation | Required behavior |
|---|---|
| Player has chat disabled | Core game remains fully playable |
| Player has voice unavailable | No progression loss |
| Party member cannot use chat | Structured Party/objective UI remains usable |
| Player attempts custom freeform Party name | No baseline field exists |
| Player attempts custom creature name | No baseline public naming field exists |
| Future public text filtering succeeds | Only filtered result may display |
| Text filter service fails | Raw text is not displayed |
| User pastes phone number in future text field | Filtering/policy path applies; no raw fallback |
| User pastes Discord handle | No baseline field; future filtered/moderated path required |
| Player is blocked from direct communication | New directed MonsterVault contact suppressed where applicable |
| Blocked players share public server | Core world may coexist without forced directed contact |
| Player sends repeated Party invites | Rate-limited/suppressible |
| Player sends repeated trade invites | Rate-limited/suppressible |
| Player sends repeated Pings | Rate-limited/muteable |
| Player declines social invite | No gameplay penalty |
| Player reports another user | No report reward |
| Reported player owns rare creature | Ownership not confiscated merely due to report |
| Experience-level kick occurs | Finalized collection remains persistent |
| Experience-level ban occurs | Access restricted; legitimate persistent value not silently rewritten |
| Platform bans account | MonsterVault cannot override platform action |
| User attempts ban evasion | Supported Roblox enforcement may be used |
| Free player wants to report | Same access as payer |
| Paid player wants to bypass block | Impossible |
| Trade counterparty promises Robux | Not protected consideration |
| Trade counterparty asks for password | No legitimate MonsterVault flow supports this |
| Player asks to join Discord to trade | Not required/supported by baseline flow |
| Player cannot receive trade invite due to policy | Trade unavailable; solo core play remains |
| Player cannot use optional Party feature | Solo event/progression path remains |
| Commercial entitlement offered in trade | Not eligible baseline trade asset |
| Paid random creature egg proposed | Invalid baseline; reopen GDS-6/13/15 |
| Premium currency used for random spin | Also invalid baseline paid-random workaround |
| Free world spawn is random | Allowed gameplay randomization, separate from paid item |
| Friendly Challenge proposes creature stake | Invalid wagering |
| Event proposes Energy betting | Invalid |
| Authored content adds realistic gore | Outside baseline maturity target; reopen |
| Authored content adds strong profanity | Outside baseline target |
| Authored content adds alcohol/drug gameplay | Outside baseline target |
| Mild stylized hazard effect | May fit target if questionnaire answered truthfully |
| Maturity questionnaire changes after content update | Must be updated before/with release |
| Player account policy changes mid-session | Optional feature safely narrows at next authoritative check |
| Policy service is unavailable | Regulated optional action fails closed |
| User location/account setting is unknown | Game does not guess permissively |
| Shop product is region/account-ineligible | No bypass; free route remains |
| Safety dialog appears during shop offer | Safety UI outranks commercial UI |
| Report UI requires mouse hover | Invalid under GDS-14 parity |
| Player uses gamepad | Reporting/blocking remains reachable |
| Player uses touch | Reporting/blocking remains reachable |
| Reduced Motion enabled | Safety warnings still semantically present |
| Player cannot hear | Safety warnings remain visible/textual |
| Platform changes chat age thresholds | Gameplay semantics remain valid; eligibility follows platform |
| Platform changes paid-item rules | Future paid-item feature revalidated; baseline unaffected |
| Roblox removes/deprecates API | TA must update implementation; GDS semantics remain |
| UGC sign feature proposed later | Reopen GDS-15 |
| Custom public creature descriptions proposed | Reopen GDS-15 |
| Custom image upload proposed | Reopen GDS-15 |
| External commerce product proposed | Separate platform eligibility/compliance review required |
| Player tries to use trade as real-money market | Not supported/protected by game |
| Player blocks after finalized trade | Trade history remains; new directed contact restricted |
| Player blocks during negotiation | Trade safely cancels/no partial transfer |
| Player reports during Capture Attempt | Reporting path must not create duplicate/ownership mutation |
| Moderation action occurs during event | Event state resolves without confiscatory side effects |
| Moderation removes social privilege | Core collection/world/Vault remains playable where account remains allowed |
| Parent/account settings disable communication | No nag to override settings |
| Game detects inability to chat | Does not reveal precise age/region to peers |
| Player status label implies age category publicly | Invalid unless Roblox itself exposes it as intended |
| Custom safety workaround asks self-reported age | Invalid |
| Platform-provided identity shown | Allowed |
| Player-created impersonation field | Not baseline-authorized |

## 33. Open Questions

There are **zero GDS-15-blocking open questions**.

Exact Roblox API calls, moderation tooling implementation, current age thresholds, current regional eligibility, reporting UI hooks, ban-duration tables, appeal operations, content-maturity questionnaire answers at final asset lock, and launch-policy review are implementation/operations/current-platform concerns rather than unresolved GDS-15 semantics.

## 34. Design-Complete Checklist

- [x] Roblox policy is treated as an external moving dependency.
- [x] Per-user Platform Eligibility is authoritative.
- [x] Hard-coded mutable age/country policy logic is prohibited.
- [x] Core progression is independent of chat/voice.
- [x] Unrestricted parallel custom chat is prohibited.
- [x] Baseline public freeform user text/naming is not authorized.
- [x] Future user-visible text requires successful filtering.
- [x] Structured communication remains safe/muteable.
- [x] Party/trading social restrictions are defined.
- [x] Reporting/blocking expectations are defined.
- [x] Experience-level moderation preserves unrelated finalized value.
- [x] Harassment/spam guardrails are defined.
- [x] Personal-information/off-platform boundaries are defined.
- [x] Content maturity target is explicit.
- [x] Gambling/wagering boundaries are defined.
- [x] Paid-random-item defense-in-depth is defined.
- [x] Paid-item trading boundary is defined.
- [x] Commercial/safety parity is defined.
- [x] Platform change handling is defined.
- [x] GDS-16/TA authority remains downstream.
- [x] No implementation-relevant GDS-15 open questions remain.
