# TA-13 Analytics / Config / Live-Ops Matrix

> **Phase:** TA-13  
> **Status:** PASS

## Authority

| Concern | Authority | TA-13 role |
|---|---|---|
| ownership / Creature identity | TA-7/TA-4 | observe/provenance |
| Energy/progression/Vault | TA-8 | observe; C2 within envelope |
| spawn/world | TA-9 | future work may read pinned snapshot |
| events/trade | TA-10 | observe; safe live tuneables only |
| commerce | TA-11/platform | observe; never grant |
| presentation/accessibility | TA-12 | Class A tests with parity |
| product analytics/config/experiments | TA-13 | schema/runtime operational authority only |

## Telemetry channels

| Channel | Example | Gameplay authority |
|---|---|---:|
| Product Analytics | funnels/economy/retention | NO |
| Diagnostics | errors/config/queue health | NO |
| Security/Moderation | restricted exploit/safety signals | owning security only |
| Privileged Audit | publish/rollback history | NO |

## Field policy

| Field | Creator Analytics |
|---|---:|
| bounded result/input/progression/treatment categories | YES |
| CreatureInstanceId / PurchaseId / TradeTransactionId | NO |
| raw chat/freeform text | NO |
| exact location / sensitive inferred trait | NO |

## Platform mapping

| Intent | Adapter |
|---|---|
| onboarding | onboarding/funnel |
| multi-step flow | funnel |
| Energy source/sink | economy |
| progression | progression |
| feature/core-loop health | custom |
| complex journey | journey when justified |

## Config classes

| Class | Live override |
|---|---:|
| C0 | NO |
| C1 | NO |
| C2 | YES, allowlisted/validated/snapshot-versioned |
| C3 | not authoritative gameplay overlay |

## Snapshot activation

bundled safe default -> platform candidate -> C2 allowlist -> full validation -> immutable stage -> safe-boundary atomic swap -> read-only domain consumption.

Existing pinned work remains on its starting snapshot.

## Feature failure

| Situation | Default |
|---|---|
| new optional feature config missing | OFF |
| dangerous/exploitable feature | OFF |
| benign C2 tuneable missing | reviewed safe default/last-known-good |
| positive entitlement/value grant | NEVER inferred |
| historical persisted content | remains resolvable |

## Experiments

| Class | Typical assignment |
|---|---|
| A Presentation | player/session |
| B Scheduling | server/session/occurrence |
| C Value affecting | coherent server/occurrence/shared context preferred |

Payer status, purchase refusal, churn/vulnerability scores and sensitive traits are prohibited gameplay-value assignment inputs.

## Exposure / provenance

Assignment != exposure. Exposure is recorded only when treatment is reached. Persistent-value opportunities retain config/experiment provenance when audit correctness needs it.

## Rollback

Rollback is prospective. Active pinned work resolves. Finalized Creature, Energy/reward, purchase/entitlement and trade outcomes are not silently revoked/repriced.

## Emergency control

Messages may request refresh or conservatively disable new entry. They may not enable features, grant value, change odds or revoke finalized value.

## Privileged operations

No client/admin Remote or arbitrary in-game console baseline. Creator Hub/reviewed Open Cloud tooling uses least privilege, environment scoping, revision history and append-oriented MonsterVault audit metadata.

## Cross-system invariants

TA-13 cannot override one-owner Creature integrity, stable Variant Identity, exact-once persistence, Protected Load Failure, capture custody/finalization, Energy non-transferability/no debt, trade atomicity/revision consent, no paid luck/claim priority, platform safety rules, accessibility parity or truthful commerce.

**Matrix result: PASS.**
