# GDS-7 Strategic Design Decisions

> **Phase:** GDS-7 — Vault/Base, Passive Production, Capacity, and Upgrades  
> **Status:** Accepted  
> **Authority:** Strategic rationale for GDS-7; detailed behavior remains owned by `vault/07_vault_passive_production_capacity_and_upgrades.md`

## G7-DD-01 — Personal Vault Is Persistent State, Not a Server Instance

**Date:** 2026-09-17  
**Status:** Accepted

### Context

Players must trust that their home/base and assigned creatures survive Roblox server churn, while the implementation must not require a continuously running personal world.

### Decision

The Personal Vault is one logical persistent player-owned state. A server may render a physical vault representation, but servers/devices do not create independent economic copies. Vault Intake begins only after GDS-5 Secured Ownership Finalization.

### Rationale

This preserves ownership trust, supports server/device transitions, and keeps the system compatible with a small-team architecture rather than an MMO-scale always-live base.

### Alternatives Rejected

- server-local vault progression;
- requiring the owner to remain in one server for vault state to exist;
- using vault arrival as a second ownership-finalization boundary.

### Affected Specifications

GDS-2, GDS-4, GDS-5, GDS-7, GDS-9, Technical Architecture.

---

## G7-DD-02 — Passive Production Uses Explicit Assignment and One Persistent Timeline

**Date:** 2026-09-17  
**Status:** Accepted

### Context

Passive value can strengthen return motivation, but production from every owned creature or once-per-server simulation would incentivize collection inflation, AFK behavior, and duplication exploits.

### Decision

Passive production requires explicit Production Assignment of a Vault-Eligible Creature to a finite Production Slot. One Creature Instance may occupy at most one Production Slot and uses one persistent elapsed-time timeline across servers/devices.

Overflow-Held creatures and merely Stored/displayed creatures do not produce by baseline.

### Rationale

Finite explicit assignment creates meaningful collection choices while giving production a clear anti-duplication model.

### Alternatives Rejected

- every owned creature producing automatically;
- production once per server instance;
- Overflow-Held creatures producing normally;
- duplicate concurrent device production.

### Affected Specifications

GDS-4, GDS-6, GDS-7, GDS-8, GDS-12, Technical Architecture.

---

## G7-DD-03 — Offline Production Is Real but Doubly Bounded

**Date:** 2026-09-17  
**Status:** Accepted

### Context

The product benefits from a return loop, but unlimited offline accumulation would create inflation and make long absence economically dominant. Requiring client uptime would encourage AFK play.

### Decision

Eligible online and offline elapsed time use the same baseline authored production semantics. Offline accrual is bounded by both finite Output Buffer capacity and a finite Offline Accrual Horizon. No continuous live-server presence is required.

Time beyond either cap is not deferred debt and is not backfilled later.

### Rationale

Players can safely leave and return without being pressured to keep the game open, while economy exposure remains bounded and tuneable.

### Alternatives Rejected

- no offline production at all;
- unlimited offline catch-up;
- online-only passive production encouraging AFK;
- simulated live-world presence while offline.

### Affected Specifications

GDS-2, GDS-7, GDS-8, GDS-11, GDS-16, Technical Architecture.

---

## G7-DD-04 — Production Changes Checkpoint Old State and Apply Prospectively

**Date:** 2026-09-17  
**Status:** Accepted

### Context

Reassignment, upgrades, events, balancing, release, and future trading create a serious backdating exploit if elapsed time can be recalculated using newer/better parameters.

### Decision

Before an assignment, ownership, or relevant production parameter changes, valid elapsed output under the old state is checkpointed once. The new state applies only to later time.

Buffer expansion, production upgrades, higher-output creatures, and event modifiers cannot recreate or reprice earlier capped/elapsed intervals.

### Rationale

This gives each elapsed interval one authoritative economic interpretation and prevents retroactive best-rate selection.

### Alternatives Rejected

- recomputing the whole unclaimed period using current best parameters;
- backfilling time after buffer expansion;
- giving both old and new owner the same transfer interval.

### Affected Specifications

GDS-7, GDS-8, GDS-11, GDS-12, Technical Architecture.

---

## G7-DD-05 — Capacity Types Are Separate and Overflow Is Non-Economic

**Date:** 2026-09-17  
**Status:** Accepted

### Context

One generic capacity number would blur ownership/storage, production power, pending-output storage, and visual display. Overflow safety could also become unlimited free economic capacity if it allowed production.

### Decision

GDS-7 distinguishes Vault Capacity, Production Slot Capacity, Output Buffer Capacity, and Display Capacity. Overflow-Held preserves ownership but provides no ordinary production or display/economic expansion.

Baseline earned Vault Upgrades are durable. Capacity pressure always retains a non-payment resolution path.

### Rationale

Separate capacities create clearer progression surfaces while preserving GDS-4 ownership trust and preventing overflow exploitation.

### Alternatives Rejected

- one capacity scalar controlling every vault function;
- production from overflow;
- silent creature deletion when capacity shrinks;
- payment as the sole capacity-resolution path.

### Affected Specifications

GDS-4, GDS-5, GDS-7, GDS-8, GDS-13, Technical Architecture.

---

## G7-DD-06 — Vault Visitors Are Inspectors, Not Economic Co-Owners

**Date:** 2026-09-17  
**Status:** Accepted

### Context

Visible rare collections are socially valuable, but visitor access must not undermine one-owner semantics or allow griefing of production/output/protected creatures.

### Decision

Baseline visitors may inspect authorized vault/display state but cannot claim output, change Production Assignments, spend owner resources, unlock/release/transfer creatures, alter provenance, or otherwise exercise consequential owner authority.

Visitor presence grants no automatic production multiplier.

### Rationale

This supports social flexing while preserving ownership, economic integrity, and grief resistance. GDS-10/GDS-11 may later define bounded explicit cooperative bonuses.

### Alternatives Rejected

- shared default economic control;
- visitor-based automatic output multiplier;
- visitor ability to rearrange/release/claim owner assets.

### Affected Specifications

GDS-4, GDS-6, GDS-7, GDS-10, GDS-11, GDS-14.

---

## G7-DD-07 — Close GDS-7 Vault/Base Baseline

**Date:** 2026-09-17  
**Status:** Accepted

### Context

GDS-7 now resolves persistent vault authority, intake, placement, passive/offline production, checkpointing, pending-output buffering, capacity, upgrades, visitor permissions, onboarding, lifecycle behavior, and abuse cases and has passed scenario/cross-system validation.

### Decision

GDS-7 is formally closed as `Complete — PASS`.

Material changes to persistent vault identity, explicit assignment, single production timeline, bounded offline accrual, exact-once pending-output claim, prospective-only parameter changes, capacity separation, overflow no-production, durable baseline upgrades, visitor authority, or free capacity-resolution viability require GDS-7 change control and revalidation.

### Evidence

- `vault/07_vault_passive_production_capacity_and_upgrades.md` — Design Complete;
- `GDS7_SCENARIO_VALIDATION.md` — 80 / 80 PASS;
- `GDS7_CROSS_VALIDATION.md` — PASS;
- `GDS7_CLOSURE_REPORT.md` — PASS.

### Consequence

The active dependency advances to **GDS-8 — Economy, Progression, Unlocks, and Pacing**. Technical Architecture and gameplay implementation remain blocked.
