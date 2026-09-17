# Project MonsterVault Documentation

> **Project phase:** Pre-implementation specification — GDS-4 next  
> **Implementation status:** Blocked by design and architecture gates

This directory is the authoritative documentation space for Project MonsterVault.

The project deliberately follows the same specification-first discipline used in Project StarForge: gameplay is designed first, technical architecture is derived from the approved design, and implementation begins only after both layers have passed their formal completion gates.

## Documentation Layers

1. [`game_design/`](game_design/) — authoritative Game Design Specification (GDS).
2. [`technical_architecture/`](technical_architecture/) — technical contracts derived from the approved GDS.
3. [`implementation/`](implementation/) — implementation handoff and later completion evidence. This area remains blocked until the GDS and TA gates are closed.
4. [`history/`](history/) — preserved early concept material and superseded planning artifacts.

## Authority Order

When documents disagree, authority is resolved in this order:

1. current approved Game Design Specification for player-facing behavior;
2. current approved Technical Architecture for implementation constraints;
3. explicit design/architecture decision records;
4. implementation documentation;
5. historical concept material.

Historical documents never override current authoritative specifications.

## Current Gate

Completed:

- **GDS-0 — Governance, Structure, and Concept Baseline: PASS**
- **GDS-1 — Product Vision, Audience, and Success Criteria: PASS**
- **GDS-2 — Global Game Rules and Session Model: PASS**
- **GDS-3 — Player Character, Interaction, and Onboarding: PASS**

GDS-1 closure evidence:

- [`game_design/01_game_overview.md`](game_design/01_game_overview.md);
- [`game_design/product/`](game_design/product/);
- [`game_design/GDS1_CROSS_VALIDATION.md`](game_design/GDS1_CROSS_VALIDATION.md);
- [`game_design/GDS1_CLOSURE_REPORT.md`](game_design/GDS1_CLOSURE_REPORT.md).

GDS-2 closure evidence:

- [`game_design/global_rules/02_global_game_rules_and_session_model.md`](game_design/global_rules/02_global_game_rules_and_session_model.md);
- [`game_design/GDS2_SCENARIO_VALIDATION.md`](game_design/GDS2_SCENARIO_VALIDATION.md);
- [`game_design/GDS2_CROSS_VALIDATION.md`](game_design/GDS2_CROSS_VALIDATION.md);
- [`game_design/GDS2_CLOSURE_REPORT.md`](game_design/GDS2_CLOSURE_REPORT.md).

GDS-3 closure evidence:

- [`game_design/player/03_player_character_interaction_and_onboarding.md`](game_design/player/03_player_character_interaction_and_onboarding.md);
- [`game_design/GDS3_SCENARIO_VALIDATION.md`](game_design/GDS3_SCENARIO_VALIDATION.md);
- [`game_design/GDS3_CROSS_VALIDATION.md`](game_design/GDS3_CROSS_VALIDATION.md);
- [`game_design/GDS3_CLOSURE_REPORT.md`](game_design/GDS3_CLOSURE_REPORT.md).

The active dependency is:

> **GDS-4 — Creatures, Collection, and Ownership**

No gameplay implementation should begin until:

- GDS-4 through GDS-16 have completed their owning design work;
- GDS-17 records a formal cross-system `Design Complete` PASS;
- the complete Technical Architecture reaches `Architecture Complete`;
- architecture integration validation passes;
- the final implementation roadmap and contract-locking phase explicitly opens implementation.

Scaffolding required only to inspect or document external tooling is not gameplay implementation, but even tooling choices should not be locked prematurely when they depend on unresolved architecture decisions.
