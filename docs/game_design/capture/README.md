# Capture, Contesting, Transport, and Extraction

> **Status:** Design Complete  
> **Owning phase:** GDS-5

Authoritative home for MonsterVault's ordinary active acquisition loop: encounter eligibility, Engagement Claims, capture attempts, Capture Success/Failure, Provisional Capture, Transport Custody, Secure Points, Extraction Completion, Secured Ownership Finalization, interruption behavior, capacity interaction, onboarding protection, contest fairness, grief prevention, and anti-frustration rules.

Primary specification:

- [`05_capture_contesting_transport_and_extraction.md`](05_capture_contesting_transport_and_extraction.md)

Closure evidence:

- [`../GDS5_SCENARIO_VALIDATION.md`](../GDS5_SCENARIO_VALIDATION.md) — 60 compound acquisition scenarios; PASS;
- [`../GDS5_CROSS_VALIDATION.md`](../GDS5_CROSS_VALIDATION.md) — product/lifecycle/ownership/authority validation; PASS;
- [`../GDS5_CLOSURE_REPORT.md`](../GDS5_CLOSURE_REPORT.md) — formal GDS-5 closure; PASS.

Key locked contract:

```text
Capture Opportunity
  -> Engagement Claim
  -> Capture Attempt
  -> Capture Success
  -> Provisional Capture / Transport Custody
  -> Secure Point / Extraction Completion
  -> Secured Ownership Finalization
  -> GDS-4 Secured Creature
```

The exact rarity modifiers, capture-tool economy, world spawn logic, hazards, social/PvP overrides, event-specific multi-award rules, final presentation, and technical implementation remain owned downstream.
