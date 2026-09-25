# Implementation Documentation

> **Status:** OPEN — IMP-1 and IMP-2 complete; IMP-3 next
> **Opened by:** TA-17 Implementation Locked — PASS (2026-09-24)

This directory is the authoritative implementation handoff and phase-evidence layer.

## Completed pre-code gates

1. **SATISFIED:** GDS-17 Design Complete — PASS.
2. **SATISFIED:** TA-0 through TA-15 Architecture Complete — PASS.
3. **SATISFIED:** TA-16 Architecture Integration Complete — PASS.
4. **SATISFIED:** TA-17 implementation roadmap, VS-1, toolchain, module graph, test/CI and change-control contract locked.
5. **SATISFIED:** project status changed to implementation open.

## Completed implementation phase

> **IMP-1 — Contracts and Test Harness: COMPLETE — PASS** ([evidence](IMP1_IMPLEMENTATION_EVIDENCE.md))

## Completed implementation phase

> **IMP-2 — Composition and Diagnostics: COMPLETE — PASS** ([evidence](IMP2_IMPLEMENTATION_EVIDENCE.md))

## Active dependency

> **IMP-3 — Profile Session Foundation**

Roadmap: [IMPLEMENTATION_ROADMAP.md](IMPLEMENTATION_ROADMAP.md)  
First vertical slice: [FIRST_VERTICAL_SLICE.md](FIRST_VERTICAL_SLICE.md)

## Implementation rule

Implementation may proceed only inside the GDS/TA contracts. A discovered architecture conflict is escalated to the owning TA/GDS rather than patched around locally.

## Release boundary

Implementation open does **not** mean production release is open. STG/PROD publishing remains gated by TA-15 C0/C1 evidence, TA-14 budgets, actual environment bindings and the later implementation/release phases.
