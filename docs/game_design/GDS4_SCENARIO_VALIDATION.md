# GDS-4 Scenario Validation

> **Phase:** GDS-4 — Creatures, Collection, and Ownership  
> **Status:** Complete  
> **Validation result:** PASS  
> **Date:** 2026-09-17

## 1. Purpose

Stress-test the GDS-4 creature identity, collection, capacity, ownership, voluntary-loss, and persistence rules against compound lifecycle and multiplayer situations before formal closure.

The scenarios intentionally avoid deciding GDS-5 capture mechanics, GDS-6 rarity/mutation rules, GDS-7 vault mechanics, GDS-8 economy values, GDS-10 social-risk mechanics, GDS-12 trading mechanics, or Technical Architecture.

## 2. Scenario Matrix

| # | Scenario | Expected result | Result |
|---:|---|---|---|
| 1 | Player secures first creature | New stable Creature Instance enters Collection Registry and Species Discovery records | PASS |
| 2 | Player secures second creature of same Species | Second distinct instance retained; Species Discovery remains one historical Species fact | PASS |
| 3 | Two visually identical duplicates exist | They remain separately addressable instances | PASS |
| 4 | Player disconnects after Secured Ownership Finalization | Same instance remains owned after reconnect | PASS |
| 5 | Server shuts down after finalization | Same instance remains Persistent Player State | PASS |
| 6 | Player resets avatar after creature is secured | Ownership unchanged; only runtime representation may recover | PASS |
| 7 | Device changes between sessions | Ownership and instance identity unchanged | PASS |
| 8 | Player changes server | Same Collection Registry ownership restored | PASS |
| 9 | Duplicate finalization callback arrives | Same finalized outcome cannot mint another creature | PASS |
| 10 | Creature world model fails to render after join | Ownership remains; presentation must recover | PASS |
| 11 | Another player stands next to owned creature | No ownership effect | PASS |
| 12 | Another player interacts with displayed owned creature | No ownership transfer without later explicit authority | PASS |
| 13 | Owned creature moves Stored → Active | Same instance and owner | PASS |
| 14 | Owned creature moves Active → Stored | Same instance and owner | PASS |
| 15 | Same instance is accidentally requested for two exclusive active slots | Contradictory placement must be rejected/resolved; no clone | PASS |
| 16 | Player reaches ordinary capacity before another capture finalizes | GDS-5 must account for capacity; if finalization occurs, Overflow-Held is safe result | PASS |
| 17 | Finalization occurs while capacity is full | Creature is owned and Overflow-Held, not deleted | PASS |
| 18 | Overflow-Held creature after reconnect | Same creature remains owned and restricted | PASS |
| 19 | Player resolves capacity later | Creature may move from Overflow-Held to ordinary eligible state without new ownership event | PASS |
| 20 | Paid/temporary capacity expires | Excess secured creatures are not deleted | PASS |
| 21 | Player becomes over capacity | New/active placement may be restricted; ownership remains intact | PASS |
| 22 | New account begins onboarding | At least one usable destination exists for legitimate first secured creature | PASS |
| 23 | Player tries to use overflow as infinite active storage | Restricted-use invariant prevents overflow from replacing normal capacity | PASS |
| 24 | Player voluntarily releases ordinary unlocked creature | Explicit irreversible Release ends current ownership | PASS |
| 25 | Player reconnects after finalized release | Released instance does not reappear by ordinary reconnect | PASS |
| 26 | Player releases last owned instance of a Species | Current count becomes zero; Species Discovery remains | PASS |
| 27 | Player attempts to release locked creature | Action rejected until explicit unlock | PASS |
| 28 | Bulk release contains locked and unlocked creatures | Locked creatures remain; scope must be explicit for others | PASS |
| 29 | Input spillover from menu targets Release | GDS-3 modal/input rules prevent accidental destructive action | PASS |
| 30 | Player stores creature while release confirmation is open | Conflicting operation must not produce contradictory ownership outcome | PASS |
| 31 | Future release reward callback repeats | Release/reward must remain single coherent Finalized Outcome | PASS |
| 32 | UI groups 12 duplicates under one Species | Grouping may summarize, but instance-specific selection remains possible | PASS |
| 33 | Player owns event-origin creature and changes servers | Provenance does not rewrite to current server | PASS |
| 34 | Future trade changes owner | Original provenance may persist while current owner changes under GDS-12 | PASS |
| 35 | Future trade starts but does not finalize | Same instance cannot appear finalized in both collections | PASS |
| 36 | Locked creature selected for future trade | Creature Lock must block transfer until unlocked | PASS |
| 37 | Creature Species balance data changes | Existing instance identity persists by default | PASS |
| 38 | Species is temporarily unavailable in live content | Existing owned instances and historical Discovery remain | PASS |
| 39 | Retired/event-limited Species affects completion view | Presentation must distinguish legacy/limited availability rather than unlabeled impossible goal | PASS |
| 40 | World encounter is being captured but not secured | It remains Acquisition-In-Progress, not Collection Registry ownership | PASS |
| 41 | Player resets during Acquisition-In-Progress | Result is delegated to GDS-5; GDS-4 does not falsely secure it | PASS |
| 42 | Player is visually followed by an unsecured creature | Proximity/following alone does not create ownership | PASS |
| 43 | Creature is secured then Recovery begins immediately | Creature remains owned; Recovery does not revert it to world state | PASS |
| 44 | Collection representation loads twice | Same stable instance must not become two authoritative instances | PASS |
| 45 | Two accounts claim same stable instance ID due conflict | One-owner invariant requires conflict resolution; dual authoritative ownership is invalid | PASS |
| 46 | Player moves secured creature into a later vault display | Display placement does not change ownership | PASS |
| 47 | Visitor can interact with displayed creature | Interaction does not imply shared ownership | PASS |
| 48 | Player has no free capacity and refuses payment | A non-payment resolution path must remain available | PASS |
| 49 | Capacity entitlement shrinks below current count | Existing creatures remain; excess use is restricted rather than destroyed | PASS |
| 50 | Species completion achieved then all instances released | Historical Species completion/discovery fact remains unless a later specialized collection goal explicitly requires simultaneous ownership | PASS |

## 3. Invariant Coverage

### Identity integrity
Covered by scenarios 1–5, 8–10, 13–15, 32, 37, 44–45.

### Ownership persistence
Covered by scenarios 4–8, 10–12, 17–21, 33, 38, 43, 46–47.

### Capacity safety
Covered by scenarios 16–23, 48–49.

### Voluntary-loss safety
Covered by scenarios 24–31.

### Collection/discovery semantics
Covered by scenarios 1–3, 26, 32, 38–39, 50.

### Downstream authority boundaries
Covered by scenarios 16, 34–36, 40–41, 46–47.

## 4. Contradiction Scan

No contradiction was found between:

- individual Creature Instance identity and grouped collection UI;
- duplicate ownership and Species-level discovery;
- finite capacity and ownership trust;
- overflow safety and the need for meaningful capacity;
- voluntary Release and the non-loss-dominant product contract;
- historical Species Discovery and current owned-count changes;
- provenance continuity and future ownership transfer;
- GDS-5 ownership-finalization authority and GDS-4 post-finalization semantics;
- GDS-2 persistence guarantees and GDS-4 secured-creature lifecycle;
- GDS-3 onboarding/recovery contracts and GDS-4 collection behavior.

## 5. Verdict

**PASS.**

All 50 scenarios have deterministic GDS-4 outcomes or are explicitly delegated at the correct authority boundary. No GDS-4-owned scenario requires implementation behavior to be invented later.
