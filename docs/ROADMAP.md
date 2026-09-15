# Development Roadmap

This roadmap prioritizes proving the core gameplay loop before expanding scope.

## Phase 0 — Repository and Tooling Foundation

**Goal:** establish a reproducible development environment.

Deliverables:

- Repository structure
- Roblox Studio project linkage strategy
- Luau tooling decision
- Formatting/linting configuration
- Test runner decision
- Basic CI
- Contribution/development conventions

Exit criteria:

- A clean checkout can be opened/built consistently.
- Automated checks can run without manual repository edits.

## Phase 1 — Domain Model and Data Contracts

**Goal:** define the canonical data model before gameplay logic spreads across the codebase.

Deliverables:

- Creature definition schema
- Creature instance/ownership schema
- Rarity definitions
- Mutation definitions
- Player profile schema
- Inventory model
- Upgrade model
- Region/biome identifiers
- Versioned persistence schema

Exit criteria:

- Core gameplay entities have stable identifiers and typed contracts.
- Content can be configured without rewriting system code.

## Phase 2 — Persistence and Player Lifecycle

**Goal:** establish safe profile loading/saving before value-bearing gameplay is implemented.

Deliverables:

- `DataService`
- Default profile
- Session ownership strategy
- Save/retry handling
- Schema migration mechanism
- Development diagnostics

Exit criteria:

- Test profiles survive leave/rejoin cycles reliably.
- Failed loads do not create duplicate or reset value-bearing data.

## Phase 3 — Creature World and Capture Vertical Slice

**Goal:** implement the first end-to-end gameplay action.

Deliverables:

- Creature spawning
- Creature identity
- Basic world interaction
- Capture request protocol
- Server-side capture validation
- Capture success/failure state
- Inventory grant
- Client feedback

Exit criteria:

- A player can find and capture a creature through a server-authoritative flow.

## Phase 4 — Vault and Economy Loop

**Goal:** complete the first meaningful progression cycle.

Deliverables:

- Player vault/base
- Creature placement/storage
- Passive resource production
- Currency ledger APIs
- First upgrade set
- Capacity constraints
- UI feedback for earnings and spending

Exit criteria:

- Capture -> return -> generate -> upgrade can be repeated without developer intervention.

## Phase 5 — Rarity and Mutation System

**Goal:** add collection depth and variable creature value.

Deliverables:

- Rarity resolution
- Mutation rolls
- Mutation modifiers
- Visual mutation hooks
- Deterministic/testable roll logic
- Initial balance configuration

Exit criteria:

- Creatures can spawn with meaningful rarity/mutation differences driven by configuration.

## Phase 6 — Onboarding and First-Session UX

**Goal:** make the core loop understandable without external explanation.

Deliverables:

- Spawn flow
- First capture objective
- Directional/visual guidance
- First upgrade prompt
- Clear next-goal presentation
- Basic sound/VFX feedback

Exit criteria:

- A new tester can complete the intended first loop without developer assistance.

## Phase 7 — Server-Wide Event

**Goal:** introduce the first social convergence mechanic.

Deliverables:

- Event scheduler
- Server announcement flow
- Rare Rift event
- Event-specific spawn table
- Participation/reward validation
- Cleanup and recovery handling

Exit criteria:

- All players receive and can participate in a synchronized event safely.

## Phase 8 — Vertical Slice Hardening

**Goal:** make the prototype suitable for closed playtesting.

Deliverables:

- Exploit-resistance review
- Remote rate limits
- Persistence edge-case testing
- Performance profiling
- Economy sanity checks
- Error logging
- Basic analytics hooks
- Mobile/control usability pass

Exit criteria:

- The vertical slice is stable enough for repeated external test sessions.

## Phase 9 — Closed Playtest and Metrics

**Goal:** determine whether the core loop deserves expansion.

Measure:

- Time to first capture
- Time to first upgrade
- First-session completion
- Early-session abandonment points
- Session length
- Repeat capture cycles
- Event participation
- Qualitative desire for rarer creatures/mutations

Exit criteria:

- A go/no-go decision is made from player behavior rather than developer intuition alone.

## Phase 10 — Content Expansion

Only after the vertical slice is validated:

- Additional creatures
- Additional mutations
- Additional biome(s)
- More upgrades
- More server events
- Improved collection UI
- Cosmetic/status systems

## Phase 11 — Monetization Integration

Monetization should be layered onto a proven loop rather than used to compensate for weak gameplay.

Deliverables may include:

- Storage expansion
- Cosmetic vault themes
- Capture effects
- VIP convenience/status benefits
- Server-wide boosts
- Starter pack
- Optional progression conveniences with explicit balance review

## Phase 12 — Trading and Player Economy

Trading is intentionally late because it amplifies duplication, fraud, support, balance, and economy-integrity risks.

Prerequisites:

- Stable persistence
- Unique creature identity strategy
- Audit-friendly ownership transitions
- Duplicate prevention
- Secure two-party transaction state machine
- Economy balance review

## Scope Rule

No phase should be expanded merely because a feature is interesting. New scope must either:

1. validate the core product hypothesis,
2. remove a technical blocker,
3. materially improve retention/social play,
4. materially improve reliability/security, or
5. support a validated monetization path.
