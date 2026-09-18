# GDS-17 Decision Index

> **Phase:** GDS-17 — Cross-System Consistency and Design-Complete Audit  
> **Status:** Accepted  
> **Purpose:** Record the final design-promotion decisions and handoff boundary to Technical Architecture.

## GDS17-D01 — Promote the Complete GDS to Design Complete

**Status:** Accepted

### Decision

The complete MonsterVault Game Design Specification GDS-0 through GDS-17 is promoted to **Design Complete**.

### Evidence

- all ordinary subsystem phases GDS-0 through GDS-16 closed PASS;
- all authoritative GDS-1 through GDS-16 specs marked Design Complete;
- authority/namespace audit PASS;
- maturity/open-question audit PASS;
- 200 / 200 final compound scenarios PASS;
- final cross-system audit PASS;
- zero implementation-critical open design questions.

### Consequence

Technical Architecture may begin at TA-0.

---

## GDS17-D02 — Technical Architecture May Not Redefine Gameplay

**Status:** Accepted

### Decision

TA receives the completed GDS as immutable gameplay authority unless a technical constraint exposes a genuine design contradiction.

If TA requires a player-facing semantic change, the issue returns to the owning GDS phase through change control.

### Rationale

Architecture translates approved behavior; it does not silently redesign the game.

---

## GDS17-D03 — Gameplay Implementation Remains Blocked

**Status:** Accepted

### Decision

GDS Design Complete opens **Technical Architecture only**.

Gameplay implementation remains blocked until:

- TA-0 through TA-15 are Architecture Complete;
- TA-16 integration/readiness audit passes;
- TA-17 locks implementation contracts, dependency order and vertical slice.

### Rationale

A complete design is necessary but not sufficient for safe implementation.

---

## GDS17-D04 — Tuneable Values Remain Tuneable Under Semantic Constraints

**Status:** Accepted

### Decision

Playtesting/content production may later tune numeric/content values without reopening GDS when locked semantics remain unchanged.

Examples include:

- rates/costs;
- spawn weights;
- event duration;
- cooldowns;
- UI timing;
- capacity quantities;
- exact commercial pricing;
- analytics thresholds.

### Rationale

Design Complete must not freeze all balance/content iteration.

---

## GDS17-D05 — Material Semantic Changes Reopen Owning GDS Domains

**Status:** Accepted

### Decision

Post-GDS changes to player-facing semantics require:

1. identify owning GDS;
2. update authoritative spec;
3. update affected cross-references;
4. record rationale when material;
5. rerun relevant scenario/cross-system audits;
6. update downstream TA/implementation contracts.

### Rationale

This preserves design-to-architecture traceability.

---

## GDS17-D06 — Platform Policy Remains a Live External Constraint

**Status:** Accepted

### Decision

GDS-15 permanent safety semantics remain Design Complete, while current Roblox policy/API details must be revalidated during TA and launch readiness.

### Rationale

Mutable platform policy is not a reason to freeze ephemeral thresholds into game-design semantics.

---

## GDS17-D07 — Final Design Risk Register Transfers to TA

**Status:** Accepted

### Decision

Remaining risks are implementation/architecture risks, including persistence races, idempotency, network trust, RNG, cross-server orchestration, receipt recovery, policy integration, performance, telemetry/config services and exploit testing.

They do not block GDS Design Complete because the intended player-facing outcomes are already specified.

---

## GDS17-D08 — Close GDS-17 and Open TA-0

**Status:** Accepted

### Decision

GDS-17 is formally closed **Complete — PASS**.

The Game Design Specification is **DESIGN COMPLETE**.

The active project dependency becomes:

> **TA-0 — Architecture Governance, Constraints, and GDS Traceability**

### Change-Control Boundary

GDS-17 must be re-audited when:

- a material baseline mechanic is added;
- a locked semantic invariant changes;
- a new top-level design domain is introduced;
- TA discovers a player-facing contradiction that cannot be resolved technically;
- a material platform-policy change requires gameplay redesign.

Pure technical implementation choices do not reopen GDS-17.
