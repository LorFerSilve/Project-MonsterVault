# GDS-15 Roblox Platform Policy Snapshot

> **Review date:** 2026-09-18  
> **Purpose:** External-policy evidence consumed by GDS-15.  
> **Authority:** Roblox remains authoritative for its own policies/APIs. This document is a dated design input, not a frozen replacement for Roblox policy.

## 1. Why This Snapshot Exists

GDS-15 depends on platform rules that can change independently of MonsterVault.

The permanent design therefore locks stable principles such as:

- respect Roblox-authoritative eligibility;
- fail closed for regulated optional features when eligibility is unknown;
- keep core gameplay independent of chat/voice;
- filter any future user-visible freeform text;
- preserve report/block access;
- keep safety non-premium;
- re-check platform rules before implementation lock/launch.

This snapshot records the official Roblox guidance reviewed when GDS-15 was closed.

## 2. Official Sources Reviewed

### Roblox Community Standards

Source:

https://about.roblox.com/community-standards

Relevant design consequences:

- harassment, bullying, exploitation, unsafe behavior and privacy violations are not valid MonsterVault social mechanics;
- personal-information solicitation and enforcement-evasion behavior must not be enabled by experience design;
- MonsterVault cannot create mechanics intended to bypass Roblox safety systems.

### Roblox Safety Tools and Policies

Source:

https://about.roblox.com/safety-tools

Relevant design consequences:

- Roblox provides platform-level safety/moderation systems;
- MonsterVault should integrate rather than replace platform safety;
- platform protections and user-facing safety controls remain a first-class dependency.

### Roblox Creator Safety Guidance

Source:

https://create.roblox.com/docs/safety

Relevant design consequences:

- public experiences must accurately maintain the Maturity & Compliance Questionnaire;
- experience moderation may use Roblox-supported kick/ban mechanisms;
- policy/safety handling must remain aligned with current platform tooling.

### Parental Controls Overview

Source:

https://en.help.roblox.com/hc/en-us/articles/30428310121620-Parental-Controls-Overview

Relevant design consequences current at review time:

- communication availability varies according to account/age-check/parental settings;
- MonsterVault must not assume all players have text/direct/party communication;
- core gameplay therefore remains chat-independent.

GDS-15 intentionally does not lock current age thresholds because Roblox can change them.

### Experience Chat

Source:

https://en.help.roblox.com/hc/en-us/articles/203313520-Experience-Chat

Relevant design consequences:

- chat availability is platform/account dependent;
- MonsterVault may not recreate disallowed direct communication through a custom parallel system.

### Safety Features: Chat, Privacy & Filtering

Source:

https://en.help.roblox.com/hc/en-us/articles/203313120-Safety-Features-Chat-Privacy-Filtering

Relevant design consequences:

- filtering/privacy settings differ by account context;
- the game must tolerate communication being unavailable;
- personal/off-platform contact information is safety-sensitive.

### TextChatService

Source:

https://create.roblox.com/docs/reference/engine/classes/TextChatService

Relevant design consequences:

- if MonsterVault exposes text chat, Roblox-supported TextChatService is the platform integration boundary;
- chat permission/filtering behavior belongs to platform-authoritative services rather than a custom unfiltered network.

### Chat System Guidelines

Source:

https://create.roblox.com/docs/chat/guidelines

Relevant design consequences:

- experiences offering text chat must integrate supported Roblox chat;
- user-to-user editable text requires filtering;
- rate limits apply to certain editable user-visible text surfaces;
- user-originated text must not be shown raw to other users.

### Text Input / Filtering Guidance

Sources:

https://create.roblox.com/docs/ui/text-input  
https://create.roblox.com/docs/reference/engine/classes/TextService

Relevant design consequences:

- developers are responsible for filtering displayed user-entered text that Roblox does not automatically control;
- filtering failure cannot fall back to raw display;
- persisted text does not become trusted merely because it was stored.

### Reporting Rule Violations

Source:

https://en.help.roblox.com/hc/en-us/articles/203312410-How-to-Report-Rule-Violations

Relevant design consequences:

- Roblox's Report Abuse flow should remain accessible;
- contextual reports are more useful when attached to the relevant behavior/content;
- MonsterVault reporting affordances must supplement rather than replace platform reporting.

### Content Maturity & Compliance

Source:

https://create.roblox.com/docs/production/promotion/content-maturity

Relevant design consequences:

- public experiences must truthfully answer maturity/compliance questions;
- content updates that change the answer require questionnaire updates;
- MonsterVault launch design targets a broad youth-compatible Minimal-to-Mild envelope;
- Moderate/Restricted-targeting content requires GDS-15 revalidation.

### Paid Random Items Policy

Source:

https://create.roblox.com/docs/production/monetization/paid-random-items

Relevant design consequences:

- paid-random mechanics have explicit odds/policy requirements;
- Roblox exposes per-user restrictions for paid random items and paid-item trading;
- GDS-13's baseline prohibition on paid random acquisition avoids this complexity;
- any future paid-random design must reopen GDS-6/GDS-13/GDS-15.

### Roblox Monetization Guidance

Source:

https://create.roblox.com/docs/production/monetization

Relevant design consequences:

- false urgency/countdowns are not acceptable monetization UX;
- PolicyService is used for policy-sensitive monetization features;
- global/minor-facing commercial presentation must remain appropriate and non-coercive.

### Developer Products

Source:

https://create.roblox.com/docs/production/monetization/developer-products

Relevant design consequences:

- Roblox provides repeat-purchase developer products;
- product/receipt implementation belongs Technical Architecture;
- GDS-13 deliberately does not authorize unlimited repeatable paid Energy even though the platform technically supports repeatable products;
- as of this review, Roblox notes that cross-game developer-product sales are disabled, so MonsterVault design does not depend on cross-game developer-product behavior.

## 3. 2026 Platform Context Consumed but Not Hard-Coded

At the review date, Roblox documentation indicates:

- chat eligibility varies by age check and parental settings;
- platform communication restrictions differ by user;
- Content Maturity & Compliance labels govern experience audience availability;
- Roblox provides per-user policy information for regulated monetization/trading categories;
- Roblox provides built-in reporting and moderation capabilities;
- user-visible custom text must be filtered;
- public experience design must accurately declare maturity/compliance.

These facts justify the permanent GDS-15 rule:

> **Use platform-authoritative eligibility/capability results; never hard-code mutable thresholds as game-design truth.**

## 4. Baseline Features Intentionally Avoiding Policy Complexity

MonsterVault launch baseline intentionally avoids:

- paid random creatures;
- paid random Mutations/Traits;
- randomized paid cosmetic crates;
- paid-item trading;
- tradable commercial entitlements;
- custom public freeform creature names;
- Party names;
- public signs/bulletin boards;
- custom direct-message system;
- custom voice system;
- off-platform trading/contact flow;
- gambling/wagering.

This reduces platform-compliance surface while retaining the full core collection game.

## 5. Required Revalidation Triggers

Platform policy must be re-reviewed before enabling any of the following:

- paid random item;
- paid currency used to access random outcomes;
- tradable paid/commercial item;
- custom user-visible freeform text;
- custom persistent messaging;
- custom UGC image/audio/model surface;
- recurring subscription;
- external commerce;
- materially higher content maturity;
- new voice/social communication path;
- new age/region restricted mechanic.

## 6. Closure Statement

The policy review found no platform-policy contradiction in the GDS-15 baseline.

GDS-15 is deliberately more conservative than Roblox's maximum platform capabilities in several areas. Platform support for a mechanic does not automatically authorize that mechanic for MonsterVault.
