# Creatures, Collection, and Ownership

> **Status:** Design Complete  
> **Owning phase:** GDS-4

Authoritative home for creature identity, Species versus individual Creature Instance semantics, persistent ownership, collection states, duplicates, capacity/overflow safety, voluntary Release, collection discovery/completion, provenance, and ownership-facing lifecycle.

## Authoritative Specification

- [`04_creatures_collection_and_ownership.md`](04_creatures_collection_and_ownership.md) — complete GDS-4 player-facing contract.

## Closure Evidence

- [`../GDS4_SCENARIO_VALIDATION.md`](../GDS4_SCENARIO_VALIDATION.md) — 50 compound ownership/capacity/lifecycle scenarios; PASS.
- [`../GDS4_CROSS_VALIDATION.md`](../GDS4_CROSS_VALIDATION.md) — product, lifecycle, downstream-authority, and technical-boundary audit; PASS.
- [`../GDS4_CLOSURE_REPORT.md`](../GDS4_CLOSURE_REPORT.md) — formal phase closure; PASS.

## Locked Baseline

GDS-4 establishes:

- Species as authored archetypes and Secured Creatures as individual persistent instances;
- stable instance identity across ordinary session/avatar/device lifecycle;
- one ordinary owner per secured instance;
- GDS-5-owned **Secured Ownership Finalization** as the boundary into persistent ownership;
- a persistent logical **Collection Registry**;
- distinct Active, Stored, Overflow-Held, and Released collection-facing states;
- valid duplicate ownership without automatic conversion/deletion;
- non-destructive full-capacity and capacity-reduction behavior;
- explicit voluntary Release with **Creature Lock** protection;
- no baseline involuntary loss of Secured Creatures;
- persistent Species Discovery and discovery-based baseline Species completion;
- stable provenance/history hooks;
- explicit later authority for trading or other ownership transfer.

## Authority Boundary

GDS-4 does **not** define capture probability, contesting, transport/extraction, or the exact event that makes acquisition secure. Those remain GDS-5 authority.

It likewise does not define rarity/mutations (GDS-6), vault placement/production (GDS-7), economy values (GDS-8), optional social risk (GDS-10), event mechanics (GDS-11), trading (GDS-12), monetization (GDS-13), final collection UI (GDS-14), or technical persistence/transaction mechanisms (Technical Architecture).

The next dependency is **GDS-5 — Capture, Contesting, Transport, and Extraction**.
