# Project MonsterVault Documentation

> **Project phase:** Technical Architecture — TA-0..7 complete / TA-8 next  
> **Implementation status:** Blocked by Technical Architecture and implementation-lock gates

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
- **GDS-14 — Presentation, UI/UX, Feedback, and Accessibility: PASS**
- **GDS-15 — Roblox Platform, Social Safety, and Moderation Constraints: PASS**
- **GDS-16 — Retention, Discovery, Analytics, and Experimentation Boundaries: PASS**
- **GDS-17 — Cross-System Consistency and Design-Complete Audit: PASS**

**Game Design Specification: DESIGN COMPLETE**

Latest closure evidence:

- [`game_design/audit/17_cross_system_consistency_and_design_complete_audit.md`](game_design/audit/17_cross_system_consistency_and_design_complete_audit.md);
- [`game_design/GDS17_AUTHORITY_NAMESPACE_AUDIT.md`](game_design/GDS17_AUTHORITY_NAMESPACE_AUDIT.md);
- [`game_design/GDS17_MATURITY_OPEN_QUESTION_AUDIT.md`](game_design/GDS17_MATURITY_OPEN_QUESTION_AUDIT.md);
- [`game_design/GDS17_COMPOUND_SCENARIO_VALIDATION.md`](game_design/GDS17_COMPOUND_SCENARIO_VALIDATION.md);
- [`game_design/GDS17_DECISION_INDEX.md`](game_design/GDS17_DECISION_INDEX.md);
- [`game_design/GDS17_CLOSURE_REPORT.md`](game_design/GDS17_CLOSURE_REPORT.md).

Technical Architecture completed:

- **TA-0 — Architecture Governance, Constraints, and GDS Traceability: Architecture Complete — PASS**
- **TA-1 — Roblox System Context, Toolchain, and Development Environment: Architecture Complete — PASS**
- **TA-2 — Repository Layout, Module Boundaries, Dependency Direction, and Bootstrapping: Architecture Complete — PASS**
- **TA-3 — Networking, Server Authority, Remote Contracts, and Exploit Boundaries: Architecture Complete — PASS**
- **TA-4 — Player Data, Persistence, Session Ownership, Schema Evolution, and Recovery: Architecture Complete — PASS**
- **TA-5 — Identity, Content Registries, Configuration, and Data-Driven Content: Architecture Complete — PASS**
- **TA-6 — Runtime Entity, Player, Creature, and World Lifecycle: Architecture Complete — PASS**
- **TA-7 — Capture, Creature Ownership, Mutation, and Reward Resolution: Architecture Complete — PASS**

TA-7 latest evidence:

- [`technical_architecture/capture/07_capture_creature_ownership_mutation_and_reward_resolution.md`](technical_architecture/capture/07_capture_creature_ownership_mutation_and_reward_resolution.md);
- [`technical_architecture/TA7_ROBLOX_CAPTURE_RANDOMNESS_SNAPSHOT.md`](technical_architecture/TA7_ROBLOX_CAPTURE_RANDOMNESS_SNAPSHOT.md);
- [`technical_architecture/TA7_CAPTURE_VARIANT_FINALIZATION_MATRIX.md`](technical_architecture/TA7_CAPTURE_VARIANT_FINALIZATION_MATRIX.md);
- [`technical_architecture/TA7_GDS_TRACEABILITY.md`](technical_architecture/TA7_GDS_TRACEABILITY.md);
- [`technical_architecture/TA7_SCENARIO_VALIDATION.md`](technical_architecture/TA7_SCENARIO_VALIDATION.md);
- [`technical_architecture/TA7_DECISION_INDEX.md`](technical_architecture/TA7_DECISION_INDEX.md);
- [`technical_architecture/TA7_CLOSURE_REPORT.md`](technical_architecture/TA7_CLOSURE_REPORT.md).

The active dependency is:

> **TA-8 — Vault, Economy, Progression, Inventory, and Offline Accrual**

No gameplay implementation should begin until:

- TA-0 through TA-15 reach `Architecture Complete`;
- TA-16 records a formal architecture-integration/readiness PASS;
- TA-17 locks the implementation roadmap, vertical slice and implementation contracts.

Scaffolding used only to inspect/document external tooling does not itself open gameplay implementation.
