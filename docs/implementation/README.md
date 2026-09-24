# Implementation Documentation

> **Status:** BLOCKED

This directory is reserved for implementation handoff, phase completion reports, verification evidence and later release/operational implementation records.

## Hard Gate

Gameplay implementation must not begin until all of the following are true:

1. **SATISFIED:** GDS-17 records a formal cross-system PASS and the GDS is `Design Complete`.
2. **BLOCKING:** TA-0 through TA-14 are complete; TA-15 must reach `Architecture Complete`.
3. **BLOCKING:** TA-16 records a formal architecture-integration PASS.
4. **BLOCKING:** TA-17 locks the implementation roadmap, vertical slice, toolchain, module dependency graph, test/CI requirements and change-control rules.
5. **BLOCKING:** The root project status is explicitly changed from Technical Architecture/pre-implementation to implementation.

Until then, this directory intentionally contains no implementation-phase plan that could be mistaken for authorization to code gameplay.
