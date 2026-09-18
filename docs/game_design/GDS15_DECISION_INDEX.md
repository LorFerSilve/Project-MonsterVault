# GDS-15 Decision Index

> **Phase:** GDS-15 — Roblox Platform, Social Safety, and Moderation Constraints  
> **Status:** Accepted  
> **Purpose:** Phase-local record of strategic GDS-15 decisions and rationale. Detailed behavior remains authoritative in platform_safety/15_roblox_platform_social_safety_and_moderation_constraints.md.

## GDS15-D01 — Roblox-Authoritative Eligibility Overrides Local Assumptions

**Status:** Accepted

### Decision

Policy-gated social/commercial capabilities use Roblox-authoritative per-user eligibility/capability information.

MonsterVault does not hard-code mutable age thresholds or country lists as gameplay truth.

### Rationale

Roblox policies and regional/age rules change independently of MonsterVault.

### Alternatives Rejected

- self-reported age;
- local country tables;
- permissive fallback when policy data is unavailable.

---

## GDS15-D02 — Core Gameplay Is Independent of Unrestricted Chat and Voice

**Status:** Accepted

### Decision

Onboarding, capture, world progression, Vault, events and structured trading remain viable without unrestricted text chat or voice.

### Rationale

The primary audience includes users whose communication capabilities may be restricted by account, age-check, parental or platform settings.

---

## GDS15-D03 — No Baseline Public Freeform User Text

**Status:** Accepted

### Decision

Launch baseline does not include custom public creature names, Vault names, Party names, signs, trade notes, bios or other freeform user-authored public text.

### Rationale

Structured gameplay does not need these surfaces, and excluding them sharply reduces filtering/moderation/privacy risk.

---

## GDS15-D04 — Future User-Visible Text Must Filter Successfully or Not Display

**Status:** Accepted

### Decision

Any future User-Generated Text shown to another user must pass the appropriate Roblox-authoritative filtering path.

Filtering failure never falls back to raw display.

### Rationale

Persistence or custom UI cannot become a bypass around platform filtering.

---

## GDS15-D05 — Structured Social Pings Are the Baseline Coordination Layer

**Status:** Accepted

### Decision

Core social coordination uses authored predefined Social Pings/objective state rather than freeform custom communication.

Pings are rate-limited, duplicate-suppressed and freely muteable.

### Rationale

This preserves social play with low moderation burden and works when chat is unavailable.

---

## GDS15-D06 — Reporting and Blocking Are Safety Boundaries, Not Economy Mechanics

**Status:** Accepted

### Decision

Platform reporting remains accessible and directed social contact respects applicable blocking/restriction state.

Reports/blocks do not themselves alter Creature ownership, Energy, progression or spawn odds.

### Rationale

Safety controls must not become exploitable gameplay weapons.

---

## GDS15-D07 — Experience Moderation Restricts Access/Behavior Without Silent Value Confiscation

**Status:** Accepted

### Decision

Experience-level moderation may mute/restrict social actions, kick or ban, but ordinary moderation does not silently confiscate legitimate secured collection/economy/provenance history.

### Rationale

Moderation should stop harmful access/behavior while preserving the integrity expectations of finalized persistent value.

---

## GDS15-D08 — No Off-Platform Contact or Payment Requirement

**Status:** Accepted

### Decision

MonsterVault never requires Discord, external social handles, phone/email contact, gift cards, external payments or account credential sharing for progression, support, events or trading.

### Rationale

The baseline target audience and platform safety model do not require such exposure.

---

## GDS15-D09 — Launch Content Targets a Minimal-to-Mild Maturity Envelope

**Status:** Accepted

### Decision

Launch content is designed for a broad youth-compatible Minimal-to-Mild Roblox maturity outcome.

Moderate/Restricted-targeting content requires GDS-15 reopening.

### Rationale

This matches the GDS-1 audience and existing non-graphic, non-combat-dominant systems.

---

## GDS15-D10 — No Baseline Playable Gambling or Paid Random Item System

**Status:** Accepted

### Decision

Friendly Challenges and events have no value-bearing wagering.

GDS-13's no-paid-random baseline remains; indirect premium-currency randomization is also excluded.

### Rationale

This avoids gambling-style pressure and complex age/region policy surfaces.

---

## GDS15-D11 — Commercial Entitlements Are Not Tradable

**Status:** Accepted

### Decision

Paid cosmetics/capacity/supporter entitlements remain account-bound and outside GDS-12 Trade Offers.

Baseline creature trading therefore does not function as paid-item trading.

### Rationale

This preserves GDS-12 barter semantics and avoids paid-item-trading policy complexity at launch.

---

## GDS15-D12 — Platform Policy Changes May Narrow Optional Features, Not Expand Authority Automatically

**Status:** Accepted

### Decision

A stricter Roblox rule may safely narrow optional social/commercial functionality while preserving core play.

A more permissive platform rule does not automatically authorize new chat, UGC, paid-random, paid-item-trading or higher-maturity mechanics.

### Rationale

Platform capability is an external ceiling/boundary, not MonsterVault design authority.

---

## GDS15-D13 — Close GDS-15 Roblox Platform, Social Safety, and Moderation Constraints

**Status:** Accepted

### Decision

GDS-15 is formally closed as **Complete — PASS**.

Material changes to:

- platform-authoritative eligibility;
- chat/voice-independent core progression;
- no baseline public freeform user text;
- successful filtering requirement;
- structured Social Pings;
- report/block accessibility;
- non-confiscatory ordinary moderation;
- no off-platform requirement;
- Minimal-to-Mild maturity target;
- no playable wagering;
- no baseline paid-random items;
- non-tradable commercial entitlements;
- platform-change handling

require GDS-15 change control and revalidation.

### Evidence

- platform_safety/15_roblox_platform_social_safety_and_moderation_constraints.md — Design Complete;
- GDS15_ROBLOX_PLATFORM_POLICY_SNAPSHOT.md — dated official-policy snapshot;
- GDS15_SCENARIO_VALIDATION.md — 170 / 170 PASS;
- GDS15_CROSS_VALIDATION.md — PASS;
- GDS15_CLOSURE_REPORT.md — PASS.

### Consequence

The active dependency advances to **GDS-16 — Retention, Discovery, Analytics, and Experimentation Boundaries**.
