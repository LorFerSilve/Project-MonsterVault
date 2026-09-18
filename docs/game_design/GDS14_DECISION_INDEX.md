# GDS-14 Decision Index

> **Phase:** GDS-14 — Presentation, UI/UX, Feedback, and Accessibility  
> **Status:** Accepted  
> **Purpose:** Phase-local record of strategic GDS-14 decisions and rationale. Detailed behavior remains authoritative in presentation/14_presentation_ui_ux_feedback_and_accessibility.md.

## GDS14-D01 — Presentation Follows a Global Priority Hierarchy

**Status:** Accepted

### Decision

Player-facing priority is:

1. safety/trust failure;
2. committed gameplay/transfer state;
3. time-sensitive opportunity;
4. immediate interaction;
5. persistent progression;
6. social/commercial/informational.

Lower-priority UI cannot obscure or steal focus from higher-priority states.

### Rationale

MonsterVault combines many concurrent systems. A single hierarchy prevents event/shop/social noise from making capture, trade or trust-critical states ambiguous.

---

## GDS14-D02 — One Consequential Modal Owns Focus at a Time

**Status:** Accepted

### Decision

A consequential Modal Screen suppresses conflicting world actions.

Back/Close never doubles as destructive confirmation, and closing restores a deterministic safe focus/control state.

### Rationale

This protects GDS-3 input safety across keyboard, gamepad and touch.

---

## GDS14-D03 — Critical Meaning Uses Semantic Redundancy

**Status:** Accepted

### Decision

Critical state may not depend on color alone, audio alone, memorized icon alone, hover or tiny pointer precision.

Text/shape/icon/audio/pattern channels reinforce one another.

### Rationale

Accessibility must preserve system comprehension rather than be an optional cosmetic layer.

---

## GDS14-D04 — Collection/Trade Presentation Preserves Exact Creature Instance Identity

**Status:** Accepted

### Decision

Species grouping is allowed, but any action involving ownership, Production Assignment, Release or trade keeps exact-instance inspection/selection available.

### Rationale

GDS-4/GDS-12 semantics operate on Creature Instances, not fungible species counts.

---

## GDS14-D05 — Capture Success and Secured Ownership Are Visually Distinct

**Status:** Accepted

### Decision

Capture Success communicates Provisional Capture/Transport Custody.

Only Extraction Completion / Secured Ownership Finalization receives persistent ownership confirmation.

### Rationale

A major upstream semantic boundary would be undermined if presentation told the player they owned a creature before finalization.

---

## GDS14-D06 — Rarity, Mutation, Availability, Provenance, and Commercial Cosmetics Stay Separate Dimensions

**Status:** Accepted

### Decision

Presentation must not collapse these concepts or allow commercial cosmetics to masquerade as intrinsic collectible value.

### Rationale

Collection trust depends on accurately communicating why a creature is rare/distinct/historical.

---

## GDS14-D07 — Capacity and Progression Blocks Explain the Actual Missing Condition

**Status:** Accepted

### Decision

Collection Capacity, Display Slots, Production Slots, Production Buffer and Offline Window remain separately presented.

Progression Gates show each unmet milestone/Energy/access condition independently instead of generic `Locked`.

### Rationale

Players need to know what gameplay action resolves a block.

---

## GDS14-D08 — Event Allocation and Personal Eligibility Are Explicit

**Status:** Accepted

### Decision

Event UI distinguishes:

- shared server progress;
- personal contribution eligibility;
- public single-award opportunities;
- Event Multi-Award Encounters;
- Resolution Grace.

### Rationale

Server success must not be mistaken for a personal reward, and public single-winner content must not look like guaranteed multi-award content.

---

## GDS14-D09 — Trade Consent Is Visually Revision-Bound

**Status:** Accepted

### Decision

Any semantic offer change visibly clears Ready/final confirmation.

The final review is immutable and separate from negotiation.

### Rationale

GDS-12's scam-resistance rules require presentation to make stale consent impossible to mistake for current consent.

---

## GDS14-D10 — Reduced Motion and Readability Are Baseline, Free Accessibility Features

**Status:** Accepted

### Decision

Baseline settings include Reduced Motion/camera-shake reduction, readability support, non-audio equivalents and relevant volume/control options.

They cannot be monetized.

### Rationale

Accessibility is core capability parity and safety, not paid convenience.

---

## GDS14-D11 — No Core UI Flow Is Hover-Only, Drag-Only, or Precision-Pointer-Only

**Status:** Accepted

### Decision

Touch, keyboard/mouse and gamepad retain semantic parity.

Hover, drag/drop and shortcuts may be convenience enhancements only.

### Rationale

This operationalizes GDS-1/GDS-3 mobile-first cross-platform parity.

---

## GDS14-D12 — Commercial Presentation Cannot Interrupt Critical Gameplay or Use False Urgency

**Status:** Accepted

### Decision

GDS-13 commercial offers obey committed-state suppression and must expose real price/content/duration semantics without fake discount/countdown or loss-chasing rescue presentation.

### Rationale

Commercial UX must not weaken gameplay consent or trust.

---

## GDS14-D13 — Close GDS-14 Presentation, UI/UX, Feedback, and Accessibility

**Status:** Accepted

### Decision

GDS-14 is formally closed as **Complete — PASS**.

Material changes to:

- global presentation priority;
- modal focus ownership;
- confirmation severity;
- semantic redundancy;
- exact-instance readability;
- capture-success versus secured-ownership distinction;
- separate collectible identity dimensions;
- progression/capacity clarity;
- event allocation/eligibility distinction;
- revision-bound trade consent;
- baseline Reduced Motion/readability;
- cross-input semantic parity;
- commercial critical-state suppression

require GDS-14 change control and revalidation.

### Evidence

- presentation/14_presentation_ui_ux_feedback_and_accessibility.md — Design Complete;
- GDS14_SCENARIO_VALIDATION.md — 160 / 160 PASS;
- GDS14_CROSS_VALIDATION.md — PASS;
- GDS14_CLOSURE_REPORT.md — PASS.

### Consequence

The active dependency advances to **GDS-15 — Roblox Platform, Social Safety, and Moderation Constraints**.
