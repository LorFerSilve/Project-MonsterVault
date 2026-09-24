# TA-13 Decision Index

> **Status:** Accepted  
> **Owning phase:** TA-13

## TA13-D01 — Keep Analytics Observational

**Decision:** Product analytics, dashboards, cohorts and alerts never mutate gameplay truth or replace durable transaction/persistence authority.

## TA13-D02 — Use a Versioned Semantic Telemetry Registry

**Decision:** Every event has stable identity, schema, owner, trigger, sampling/privacy policy and adapter mapping; breaking meaning is versioned.

## TA13-D03 — Emit Consequential Success After Authoritative Outcome

**Decision:** Capture, economy, progression, trade and commerce success telemetry originates after the owning server transition, not client intent.

## TA13-D04 — Make Analytics Failure Non-Blocking

**Decision:** Telemetry uses bounded best-effort delivery; gameplay does not wait for analytics and no profile writes exist solely for analytics delivery.

## TA13-D05 — Separate Analytics, Diagnostics, Security and Audit

**Decision:** Different trust/access/durability needs are not collapsed into one unrestricted event stream.

## TA13-D06 — Enforce Data Minimization and Low Cardinality

**Decision:** No raw chat/freeform personal data or sensitive-trait inference; Creator Analytics dimensions remain bounded and exclude runtime IDs.

## TA13-D07 — Use ConfigService as Baseline C2 Transport

**Decision:** Experience Configs provide read-only-in-game live values/flags; MonsterVault wraps them in validation and snapshots.

## TA13-D08 — Activate Config Atomically

**Decision:** Only allowlisted C2 values are materialized; the full candidate is validated, staged and swapped at safe boundaries.

## TA13-D09 — Pin Operations to Coherent Config Context

**Decision:** Transactions/encounters/events retain their starting snapshot when required; new snapshots affect future work prospectively.

## TA13-D10 — Keep C0/C1 Outside Live Flags

**Decision:** Flags may gate reachability but cannot redefine invariants/static identity or break persisted references.

## TA13-D11 — Fail Optional/Unsafe Features Closed

**Decision:** Missing/invalid config keeps optional new features disabled or uses a reviewed safe default; no cross-environment fallback.

## TA13-D12 — Make Rollback Prospective and Non-Destructive

**Decision:** Rollback returns future work to a validated revision and never silently removes legitimate finalized value.

## TA13-D13 — Allow Conservative Emergency Disable Hints Only

**Decision:** Cross-server messages may reduce new reachability/request refresh but cannot enable features, grant value or become durable positive truth.

## TA13-D14 — Separate Reviewed Experiment Semantics from Live Allocation

**Decision:** Experiment plans/treatments/invariants are reviewed; C2 controls only activate/deactivate and allocate inside the approved envelope.

## TA13-D15 — Match Assignment Unit to Blast Radius

**Decision:** Per-player assignment is limited to isolated semantics; shared/value-affecting opportunities use coherent server/occurrence context.

## TA13-D16 — Record Exposure Separately from Assignment

**Decision:** Exposure occurs only when treatment is reached; durable-value opportunities retain config/experiment provenance where needed.

## TA13-D17 — Do Not Use Platform Player Segments as Gameplay Value Authority

**Decision:** Payer/activity segments cannot determine hidden odds, priority, reward strength, pricing, safety or progression.

## TA13-D18 — Keep Production Live-Ops External and Least-Privilege

**Decision:** No baseline client/in-game arbitrary admin console; Creator Hub/Open Cloud tooling uses scoped credentials outside the experience.

## TA13-D19 — Audit Every Privileged Mutation

**Decision:** Config/flag/experiment publish and rollback record operator/action/revision/reason/result metadata; rollback appends history.

## TA13-D20 — Close TA-13 and Advance to TA-14

**Decision:** TA-13 is Architecture Complete — PASS with 260/260 scenarios and zero blocking questions. TA-14 becomes NEXT; gameplay implementation remains blocked until TA-17.

**Decision-index result: PASS.**
