# Subsystem Specification Template

> **Status:** Template
> **Authority:** Required structure for authoritative GDS subsystem specifications

Use this template when creating a new authoritative gameplay specification.

---

# <Subsystem Name>

> **Status:** Draft
> **Owning GDS phase:** GDS-X
> **Authority:** <what this document owns>
> **Depends on:** <authoritative dependencies>

## 1. Purpose and Player Fantasy

What player need, fantasy or product goal does this subsystem serve?

## 2. Scope

What behavior belongs here?

## 3. Explicit Non-Goals

What related behavior is intentionally outside this specification?

## 4. Terminology

Define subsystem-specific terms and link shared terms to `../GLOSSARY.md`.

## 5. Participating Entities and Ownership

Which players, creatures, resources, world objects or other entities participate? Who owns what, and when?

## 6. Core Rules and Invariants

State the rules that must always hold.

## 7. States and State Transitions

Define the relevant state machine or lifecycle.

## 8. Player Actions and Inputs

What can players do, and under which conditions?

## 9. Outputs, Rewards, Costs, and Consequences

What changes as a result?

## 10. Multiplayer Semantics

Define simultaneous interaction, cooperation, contesting, disconnects, late joins, server transitions and relevant race conditions from the player's perspective.

## 11. Progression and Economy Interactions

Define dependencies on progression, currencies, unlocks, capacity or long-term systems.

## 12. Failure, Interruption, and Recovery

Define failure states and how players recover without ambiguous or exploitable behavior.

## 13. Abuse and Exploit Cases

Define intended player-facing rules for griefing, alternate accounts, collusion, rerolling, duplication pressure, AFK behavior or other relevant abuse cases.

## 14. Presentation and Feedback

Define required UI, world-space feedback, animation, VFX, audio, prompts and readability.

## 15. Accessibility

Define relevant alternatives for color, motion, audio, input or readability dependencies.

## 16. Persistence Expectations

What must persist across death, disconnect, server changes or future sessions? Do not prescribe storage technology here.

## 17. Monetization Interactions

If applicable, define what paid advantages are permitted or prohibited and how purchases interact with this subsystem.

## 18. Analytics and Experimentation Boundaries

Which outcomes are important to measure? Which parameters may be experimented on without changing semantic rules?

## 19. Tuneable Parameters

List values expected to change through balance/playtesting.

## 20. Dependencies and Cross-References

List every authoritative external rule relied upon.

## 21. Edge-Case Matrix

Enumerate abnormal or boundary scenarios that could alter implementation behavior.

## 22. Open Questions

Every unresolved implementation-relevant question must be explicit. This section must be empty before `Design Complete`.

## 23. Design-Complete Checklist

- [ ] Purpose and scope are explicit.
- [ ] Core rules are deterministic.
- [ ] State transitions are defined.
- [ ] Multiplayer behavior is defined.
- [ ] Failure/recovery is defined.
- [ ] Abuse cases are addressed.
- [ ] Presentation/accessibility is defined where relevant.
- [ ] Persistence expectations are defined.
- [ ] Economy/monetization interactions are consistent.
- [ ] Edge cases are covered.
- [ ] Cross-references have one authoritative owner.
- [ ] No implementation-relevant open questions remain.
