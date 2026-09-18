# Project MonsterVault Documentation

> **Project phase:** Pre-implementation specification — GDS-14 next  
> **Implementation status:** Blocked by design and architecture gates

This directory is the authoritative documentation space for Project MonsterVault.

The project follows a specification-first discipline: gameplay is designed first, Technical Architecture is derived from the approved design, and implementation begins only after both layers pass their formal completion gates.

## Documentation Layers

1. [`game_design/`](game_design/) — authoritative Game Design Specification (GDS).
2. [`technical_architecture/`](technical_architecture/) — technical contracts derived from the approved GDS.
3. [`implementation/`](implementation/) — implementation handoff/completion evidence; currently blocked.
4. [`history/`](history/) — preserved early concept material and superseded planning artifacts.

## Authority Order

1. current approved GDS for player-facing behavior;
2. current approved Technical Architecture for implementation constraints;
3. explicit design/architecture decisions;
4. implementation documentation;
5. historical concept material.

## Current Gate

Completed:

- **GDS-0 — Governance, Structure, and Concept Baseline: PASS**
- **GDS-1 — Product Vision, Audience, and Success Criteria: PASS**
- **GDS-2 — Global Game Rules and Session Model: PASS**
- **GDS-3 — Player Character, Interaction, and Onboarding: PASS**
- **GDS-4 — Creatures, Collection, and Ownership: PASS**
- **GDS-5 — Capture, Contesting, Transport, and Extraction: PASS**
- **GDS-6 — Rarity, Mutations, Traits, and Variant Value: PASS**
- **GDS-7 — Vault/Base, Passive Production, Capacity, and Upgrades: PASS**
- **GDS-8 — Economy, Progression, Unlocks, and Pacing: PASS**
- **GDS-9 — World, Biomes, Exploration, Spawning, and Hazards: PASS**
- **GDS-10 — Social Play, Cooperation, Competition, and PvP Boundaries: PASS**
- **GDS-11 — Server Events, Dynamic Encounters, and Live Content: PASS**
- **GDS-12 — Trading and Player Economy: PASS**
- **GDS-13 — Monetization and Commercial Fairness: PASS**

Latest closure evidence:

- [`game_design/monetization/13_monetization_and_commercial_fairness.md`](game_design/monetization/13_monetization_and_commercial_fairness.md);
- [`game_design/GDS13_SCENARIO_VALIDATION.md`](game_design/GDS13_SCENARIO_VALIDATION.md);
- [`game_design/GDS13_CROSS_VALIDATION.md`](game_design/GDS13_CROSS_VALIDATION.md);
- [`game_design/GDS13_DECISION_INDEX.md`](game_design/GDS13_DECISION_INDEX.md);
- [`game_design/GDS13_CLOSURE_REPORT.md`](game_design/GDS13_CLOSURE_REPORT.md).

The active dependency is:

> **GDS-14 — Presentation, UI/UX, Feedback, and Accessibility**

No gameplay implementation should begin until:

- GDS-14 through GDS-16 complete their owning design work;
- GDS-17 records a formal cross-system `Design Complete` PASS;
- the complete Technical Architecture reaches `Architecture Complete`;
- architecture integration validation passes;
- the final implementation roadmap/contract-locking phase explicitly opens implementation.

Scaffolding used only to inspect/document external tooling does not itself open gameplay implementation.
