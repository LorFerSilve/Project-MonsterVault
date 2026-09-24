# Testing, Diagnostics, Security Validation, and CI Architecture

> **Status:** Architecture Complete — PASS  
> **Owning TA phase:** TA-15  
> **Date:** 2026-09-24  
> **Authority:** Verification taxonomy, deterministic test contracts, engine/device/security/fault/performance validation, CI trust boundaries, evidence and release-quality gates  
> **Depends on:** TA-0 through TA-14

## 1. Purpose

TA-0 through TA-14 define MonsterVault semantics, authority, failure behavior and measurable runtime budgets. TA-15 defines how implementation must prove those contracts continuously.

The verification contract is:

> **Every consequential architecture invariant must have reproducible evidence at the cheapest trustworthy test layer; critical ownership/value/security/persistence behavior must survive adversarial input and injected failure; engine-dependent behavior must be tested in Roblox Studio or staging; performance claims must be measured against TA-14; and CI must never obtain more trust than the code under test deserves.**

TA-15 distinguishes architecture-closure evidence from implementation test execution. The project still contains no gameplay implementation. TA-17 will create the runner/workflow/configuration artifacts that implement these gates.

## 2. Scope

TA-15 owns:

- test taxonomy and layer selection;
- stable test/scenario identity and architecture traceability;
- formatting/lint/type/build gates;
- deterministic unit/property/state-machine tests;
- deterministic randomness verification;
- Roblox Studio engine/multiplayer/device/input automation;
- network/hostile-client/security validation;
- persistence/migration/lease/retry/fault injection;
- capture/economy/trade/commerce exact-once cut-point verification;
- cross-server and live-ops failure testing;
- TA-14 performance/load/memory/network regression evidence;
- diagnostic capture requirements;
- test environment/data isolation;
- GitHub Actions trust and credential boundaries;
- required PR, trusted-engine, staging and release gates;
- flaky-test/retry/quarantine policy;
- evidence/artifact retention and release decision rules.

TA-15 does **not** own:

- gameplay semantics or balancing;
- implementation class/module names;
- concrete workflow YAML and pinned action SHAs;
- concrete test runner modules and fixtures;
- production deployment/publish automation;
- branch protection/ruleset activation;
- final tool version updates.

Those implementation artifacts are locked by TA-17 after TA-16 integration audit.

## 3. Verification Principles

### VER-15-01 — Test the contract, not the current implementation shape

Tests assert observable domain invariants, public contracts and explicitly locked budgets. They must not make safe refactoring impossible by asserting private table layout or incidental call order unless that order is itself part of the architecture.

### VER-15-02 — Cheapest trustworthy layer wins

Pure deterministic logic belongs in fast isolated tests. Roblox engine/network/device behavior belongs in Studio/staging. A slower engine test is not a substitute for a precise pure unit test, and a pure mock is not evidence for engine behavior.

### VER-15-03 — Every failure is reproducible

Randomized/property tests log the exact seed/case. Fault tests identify the injected cut point. Engine tests identify build SHA, test ID, Studio/runtime version, device/network profile and load class.

### VER-15-04 — No correctness by retry

A failing deterministic test does not become green merely because a rerun passes. Automatic retries may diagnose infrastructure flakiness, but original failure evidence remains visible and mandatory critical suites are not waived.

### VER-15-05 — Production data is never test data

Automated verification never reads/writes production player DataStores, receipts, MemoryStores, config namespaces or privileged production credentials.

## 4. Verification Classes

| Class | Meaning | Examples | Release rule |
|---|---|---|---|
| V0 | repository/spec integrity | architecture status, generated-file bans, traceability | mandatory |
| V1 | static/build | formatting, lint, strict typing, Rojo build | mandatory |
| V2 | deterministic unit | pure domain math/state/schema/validation | mandatory when affected |
| V3 | property/state-machine | generated valid/invalid sequences, invariants | mandatory for stateful critical domains |
| V4 | engine integration | Roblox services, lifecycle, remotes, streaming, UI | mandatory when affected |
| V5 | adversarial/security | malformed/replay/rate/permission/physics abuse | mandatory for client-triggered authority |
| V6 | persistence/transaction fault | cut-point crash/retry/duplicate/recovery | mandatory for P1/P2/durable operations |
| V7 | performance/load | TA-14 L0-L5 frame/memory/network/service budgets | release mandatory |
| V8 | device/accessibility | touch/keyboard/gamepad, safe areas, preferences, localization | release mandatory |
| V9 | staging/platform | real cloud-service behavior in isolated staging | release mandatory for affected adapters |
| V10 | post-deploy smoke | non-destructive production sanity | required after publish, never sole pre-release evidence |

## 5. Test Identity and Traceability

Every durable test definition has:

- stable TestId;
- owning TA/GDS requirement IDs;
- verification class;
- criticality;
- environment requirement;
- deterministic seed/fixture ID where applicable;
- expected invariant/outcome;
- owner;
- timeout/budget;
- artifact policy.

Naming concept:

`T15.<domain>.<contract>.<case>`

Examples:

- `T15.network.remoteEnvelope.nanRejected`;
- `T15.persistence.lease.concurrentWriterDenied`;
- `T15.trade.commit.crashAfterDecision`;
- `T15.client.modal.entryGestureGuard`.

Renaming implementation files does not silently rename test identity.

## 6. Criticality

### C0 — Invariant critical

Includes:

- ownership/exact-instance identity;
- P2 exact-once outcomes;
- Energy/capacity preservation;
- trade atomicity;
- receipt/grant idempotency;
- persistence lease/single-writer safety;
- server authorization/security boundaries;
- schema downgrade/corruption protection;
- protected load/recovery;
- moderation/safety enforcement.

Rules:

- must pass;
- no quarantine;
- no release waiver by ordinary maintainer choice;
- failure blocks merge/release once the implementation gate is active.

### C1 — Release critical

Includes:

- engine integration;
- accessibility/input reachability;
- TA-14 hard performance guardrails;
- staging platform adapters;
- reconnect/reconciliation;
- non-critical persistent preferences.

Must pass before release. A temporary CI infrastructure outage may defer evidence, but the release remains blocked.

### C2 — Diagnostic / warning

Includes:

- TA-14 warning threshold trends;
- long-horizon statistical diagnostics;
- optional presentation polish;
- non-authoritative analytics delivery quality.

May be non-blocking by itself, but regressions require recorded review and cannot hide a C0/C1 failure.

## 7. Static and Build Gates

Once implementation opens, every PR that changes runtime/test/tooling files must prove:

1. **StyLua check** — zero formatting drift;
2. **Selene** — zero lint errors; no new unreviewed warnings/suppressions;
3. **strict Luau analysis** — zero type errors in first-party strict roots;
4. **Rojo build** — deterministic project build succeeds;
5. **source-map generation** where required by analysis tooling succeeds;
6. architecture import/dependency constraints are checked;
7. forbidden generated place/runtime artifacts are not committed;
8. test manifest/traceability references resolve.

Tool versions remain TA-1 pins until TA-17 revalidates them.

No formatting/lint/type failure is converted to a warning solely to unblock a release.

## 8. Pure Unit Tests

Pure tests cover deterministic logic that does not require Roblox engine semantics:

- ID/schema validation;
- content/config candidate validation;
- fixed-point/integer economy math;
- capacity composition/reconciliation;
- production elapsed-time settlement;
- weighted-selection mapping with injected RNG;
- request envelope/schema validation;
- revision comparisons;
- rate-limit/token bucket math;
- migration transforms;
- transaction state transitions;
- experiment deterministic assignment;
- budget/degradation state transitions.

Rules:

- no network/cloud dependency;
- no wall-clock dependency without injected clock;
- no global random dependency without injected RNG;
- fixtures are immutable/copy-isolated;
- one test cannot rely on another's mutation.

TA-17 may add a pinned standalone Luau execution tool for this fast path. It is a development/test dependency only and does not relax TA-1's zero third-party runtime-package baseline.

## 9. Property and Stateful Verification

Stateful domains require generated sequences in addition to example tests.

Fast PR corpus:

- at least **1,000 deterministic generated cases** per affected critical property family.

Extended/nightly/release corpus:

- at least **10,000 deterministic generated cases** per affected critical property family.

Required properties include:

- Energy never negative and never exceeds technical ceiling;
- exact-once operation markers never grant twice;
- collection capacity reconciliation never deletes ownership;
- stale revisions never overwrite newer state;
- runtime entity lifecycle never transitions from Destroyed back to active;
- trade revision mutation invalidates prior readiness;
- committed trade produces either complete agreed ownership transfer or recoverable committed state, never unilateral final loss;
- config rollback never invalidates finalized durable value;
- retry/replay never changes logical operation identity.

Failure output records seed and operation sequence. Shrinking/minimization is preferred but reproducibility is mandatory.

## 10. Deterministic Randomness Verification

Capture/variant/random weighted systems use the TA-7 injected RNG boundary.

Mandatory tests:

- boundary values at 0, near-1 and exact bucket edges;
- zero/negative/invalid weight rejection;
- deterministic selection for known RNG sequences;
- no paid/payer/device/input/accessibility field can alter protected odds;
- Variant Identity generated once and retained through retry/reconnect;
- same protected semantic operation does not reroll from transport/retry.

Statistical sampling is diagnostic, not the sole correctness oracle.

Extended suites may run a fixed seed corpus of >=100,000 draws and compare observed proportions to reviewed expected tolerances. Because the seed corpus is fixed, failures are reproducible.

## 11. Roblox Studio Engine Verification

Current Roblox Studio exposes scripted testing services specifically for programmatic build-pipeline/plugin-driven tests.

TA-15 selects Studio as the authoritative engine-test runtime.

Required engine suites use, where applicable:

- StudioTestService for play/run/multiplayer execution;
- up to eight local simulated clients for deterministic multiplayer integration;
- AddPlayers/disconnect flows for join/leave/recovery;
- StudioDeviceSimulatorService for device/resolution/orientation profiles;
- VirtualInput for UI/input flows;
- Network Simulator for latency/jitter/packet-loss scenarios;
- Player Emulator/pseudolocalization for locale/policy/text-expansion cases;
- TestService/assertion/result collection where useful.

A pure mock cannot claim to verify Roblox replication, streaming, UI focus, engine lifecycle, network ownership or Marketplace/DataStore adapter behavior.

## 12. Engine Automation Trust Boundary

Studio engine tests execute repository code and therefore are privileged compute.

For this **public repository**:

- arbitrary fork PR code must not execute on a long-lived self-hosted personal machine;
- no persistent general-purpose self-hosted runner is an allowed baseline;
- engine automation runs only on trusted code in an isolated/ephemeral Windows environment, or manually in Studio until such compute exists;
- engine jobs use no production credentials;
- staging credentials, if required, are environment-scoped and review-gated;
- untrusted PR validation remains on clean GitHub-hosted runners with no secrets.

A future engine runner that cannot meet this isolation model requires TA-15 change control.

## 13. Client / Device / Accessibility Matrix

At minimum, release evidence covers:

- touch/mobile portrait and landscape;
- tablet;
- keyboard/mouse desktop;
- gamepad/console-like profile;
- narrow/safe-area constrained viewport;
- PreferredTextSize changes;
- PreferredTransparency changes;
- ReducedMotionEnabled;
- custom captions/audio-volume settings;
- localization pseudolocalization with at least +30% text expansion;
- reconnect while a modal/Pending state is visible.

Input tests must prove:

- action parity;
- fixed input-context precedence;
- single-owner dispatch;
- entry and dismissal Input Handoff Guard;
- gamepad focus restoration;
- no critical action becomes inaccessible without pointer/touch;
- platform menus/safety UI remain reachable.

## 14. Network and Hostile-Client Verification

Every client-triggered route receives negative tests for relevant classes:

- wrong direction;
- unknown route/protocol;
- missing/extra keys;
- wrong primitive types;
- NaN, +/-infinity and unsafe numbers;
- overlong strings;
- oversized arrays/tables;
- deep/nested structures;
- invalid enum/ID/revision;
- client-chosen player identity;
- arbitrary/spoofed Instance reference;
- wrong ownership/permission;
- impossible spatial/timing context;
- stale revision;
- duplicate requestId;
- same requestId with different route/payload;
- rapid legal-looking spam;
- burst above route/global budget;
- reconnect/replay after prior completion.

ProximityPrompt/ClickDetector/DragDetector paths receive equivalent server-context tests because client-side Enabled/distance/presentation is not trusted.

Security suites assert both:

1. **no unauthorized state mutation**; and
2. **bounded rejection cost** so abuse does not become a denial-of-service path.

## 15. Physics and Network-Ownership Abuse

Where physics affects a consequential interaction, tests include:

- client-owned assembly moved illegally;
- teleport/speed outlier;
- stale character generation;
- target moved outside authoritative bounds;
- prompt fired while server context denies interaction;
- unanchored target manipulation where relevant.

No test accepts local position/physics as sufficient proof of a critical outcome.

## 16. Persistence Fault Matrix

Every persistence adapter and state machine must support deterministic fault injection.

Required faults:

- Get/Update timeout;
- throttle/budget pressure;
- transient error;
- non-retryable error;
- malformed/corrupt stored value;
- newer-than-server schema;
- crash before write;
- crash after callback mutation but before response;
- duplicate retry;
- lost lease / concurrent session;
- stale lease candidate;
- leave during pending checkpoint;
- BindToClose during queued work.

For Player Profile:

- blank/default overwrite after failed load must be impossible;
- only lease owner mutates durable profile;
- revision monotonicity is asserted;
- migration chain runs exactly supported sequential steps;
- migration is deterministic and fixture-tested from every supported historical schema version;
- recovery preserves validated value.

## 17. Transaction Cut-Point Verification

Every exact-once durable transaction has named cut points.

### Capture / ownership finalization

Inject failure:

- before durable profile mutation;
- during queued P2 checkpoint;
- after durable apply but before client result;
- reconnect/retry after unknown result.

Assert same CreatureInstanceId and zero-or-one ownership grant.

### Production claim / progression purchase

Inject failure around:

- quote/validation;
- debit/claim mutation;
- durable checkpoint;
- result delivery.

Assert no duplicate credit/debit and no negative wallet.

### Trade

For every durable journal transition and each participant apply boundary:

- fail before/after journal decision;
- disconnect either/both clients;
- kill original coordinating server;
- delay participant lease ownership;
- replay recovery.

Assert no durable unilateral-loss terminal state and recoverable committed decisions converge.

### Commerce

For Developer Product receipt:

- duplicate PurchaseId;
- crash before journal;
- crash after journal prepare;
- crash after profile grant/marker;
- crash before journal FINALIZED;
- repeated ProcessReceipt delivery.

Assert zero-or-one grant and only safe acknowledgement.

For Game Pass entitlement reconciliation:

- positive/negative/unknown;
- retry exhaustion;
- delayed platform ownership update;
- product Hidden/Retired while reconciliation remains needed.

## 18. Config / Experiment / Live-Ops Verification

Tests prove:

- only C2 allowlisted fields enter live overlay;
- malformed partial candidates do not partially activate;
- ConfigSnapshot activation is atomic;
- operations pinned to an older valid snapshot complete coherently;
- rollback is prospective/non-destructive;
- emergency messages can disable/refresh but never grant/enable durable truth;
- invalid experiment definitions remain inactive;
- assignment unit matches declared blast radius;
- exposure is separate from assignment;
- payer/device/accessibility segments cannot alter prohibited gameplay value;
- privileged mutation audit records success/failure/rollback lineage.

## 19. Cross-Server Service Verification

MemoryStore and MessagingService tests include:

- unavailable service;
- throttle/quota pressure;
- duplicate message;
- missed message;
- reordered/coalesced refresh;
- expired transient item;
- stale coordination record.

Assert:

- no durable positive truth depends on delivery;
- safe refresh/recovery converges through owning durable contracts;
- TA-14 internal quotas/load shedding are respected.

## 20. TA-14 Performance Verification

TA-14 load classes are mandatory:

- L0 Solo;
- L1 Half occupancy;
- L2 Full occupancy;
- L3 Full + burst;
- L4 Recovery;
- L5 >=60-minute long session.

Required measurements:

- server frame p95;
- MonsterVault script CPU p95;
- scheduler pass p95;
- server memory percentage;
- client frame p95;
- client warm-baseline memory deltas;
- runtime entity/interactable/Persistent-model counts;
- custom remote messages/s and bytes/s;
- profile serialized bytes and record counts;
- DataStore reserve/retries/throttles/latency;
- MemoryStore/Messaging quota fractions if used;
- spatial candidate counts;
- virtualized UI row count;
- telemetry queue/config validation/assignment cost.

### Gate interpretation

- TA-14 **hard guardrail** violation is release-blocking when reproducible;
- target miss with no hard violation is a regression signal requiring review;
- warning threshold may remain C2 only when no user-visible or safety/correctness regression exists;
- benchmarks record build SHA, load class, device profile and test duration.

No single Studio run is sufficient evidence for real-client frame/memory gates.

## 21. Performance Repetition

For automated deterministic server/script benchmarks:

- warm-up excluded;
- minimum 3 independent runs;
- report p50/p95 and worst run;
- hard guardrail must pass in **all** valid runs;
- target regressions compare against an accepted baseline using the same harness/profile.

For physical/reference client checks, store the raw run summaries and device/build identity. Exact statistical aggregation may be refined at TA-17 without relaxing TA-14 hard guards.

## 22. Diagnostics and Evidence

Every failed mandatory test emits enough evidence to reproduce it.

Structured result fields:

- TestId;
- result;
- criticality;
- build/commit SHA;
- TA/GDS requirement IDs;
- environment;
- Studio/client version where applicable;
- load/device/network profile;
- duration;
- deterministic seed/fixture;
- injected fault/cut point;
- concise failure code/message.

Attach when relevant:

- redacted logs;
- Developer Console memory/network summary;
- MicroProfiler capture;
- script profiler/counter summary;
- profile-size/request-budget counters;
- remote-rate/payload diagnostics.

Artifacts never include credentials, raw chat, unnecessary player identifiers or unrestricted persistent profile dumps.

## 23. Environment and Test Data Isolation

### DEV

- pure/unit/local Studio tests;
- disposable local state;
- mocked/fake cloud adapters by default.

### STAGING

- dedicated isolated Roblox environment;
- separate stores/namespaces/config/product bindings;
- real platform-service validation;
- destructive fault tests permitted only against synthetic test accounts/data.

### PRODUCTION

- no destructive automated suite;
- post-publish smoke is read-only/non-destructive or uses explicitly safe synthetic paths;
- production secrets never flow into PR tests.

A test fixture cannot accidentally resolve a production store/product/config binding.

## 24. CI Trust Model

### Untrusted PR lane

Trigger concept: ordinary `pull_request`.

Requirements:

- GitHub-hosted clean runner;
- read-only minimum `GITHUB_TOKEN`;
- no repository/environment secrets;
- no production/staging credentials;
- repository code may execute only in this low-trust sandbox;
- no self-hosted runner;
- no privileged deployment;
- third-party Actions pinned to immutable commit SHAs at TA-17.

### Privileged lane

Used only for trusted branch/manual/release-candidate execution.

Requirements:

- explicit trust decision;
- environment-scoped credentials;
- least-privilege token permissions;
- isolated/ephemeral engine runner if Studio automation is used;
- protected environment/reviewer for staging mutations;
- no arbitrary fork-head checkout into privileged context.

### pull_request_target rule

MonsterVault does not use `pull_request_target` to check out and execute untrusted PR code with secrets/write privileges. Triage-only use would require separate review and never runs PR code.

## 25. CI Pipeline Tiers

### CI-0 — Repository Integrity

Runs on every PR:

- spec/status consistency;
- required docs/links/IDs;
- no generated artifacts/secrets by policy;
- architecture/test manifest validation.

### CI-1 — Static / Build

Runs on every code/tooling PR:

- StyLua;
- Selene;
- strict type analysis;
- Rojo build;
- dependency-direction/static architecture checks.

### CI-2 — Fast Deterministic Logic

Runs on every affected code PR once runner exists:

- unit tests;
- 1,000-case property corpus;
- deterministic migrations/state machines;
- pure security validators.

### CI-3 — Studio Engine

Runs on trusted code before merge/release as configured:

- play/run/multiplayer tests;
- lifecycle/remotes/streaming;
- device/input/accessibility;
- network simulator scenarios.

### CI-4 — Staging Fault/Security

Runs for affected release candidates:

- real DataStore/MemoryStore/Messaging/config/commerce adapter validation;
- persistence/transaction fault cases;
- hostile-client suites that need engine/platform behavior.

### CI-5 — Performance / Long Session

Release candidate/nightly trusted lane:

- TA-14 L0-L5;
- >=60-minute leak session;
- real-client/device evidence.

### CI-6 — Release / Post-Deploy

Pre-release requires all applicable mandatory evidence. Post-deploy smoke validates availability/reconciliation without mutating arbitrary production player value.

## 26. Required Merge / Release Checks

When implementation opens, a PR touching runtime behavior cannot merge without all applicable **available** mandatory PR checks.

A release candidate cannot publish unless:

- CI-0/1 clean;
- all affected C0 V2/V3 tests pass;
- required V4 engine integration passes;
- V5 security suites pass;
- all affected V6 transaction/persistence fault suites pass;
- V7 hard TA-14 guards pass;
- V8 accessibility/device suite passes;
- affected V9 staging adapters pass;
- no unresolved C0/C1 defect;
- architecture/test traceability is complete;
- test evidence is attached to the release candidate identity.

If an engine/staging runner is unavailable, the corresponding release gate is **not** silently skipped; evidence must be produced manually in the controlled environment.

## 27. Change-Based Test Selection

Fast CI may select tests by changed domain/dependency graph, but:

- shared/network/persistence/application-layer changes fan out to all affected domains;
- transaction/persistence/security common-code changes run all dependent C0 suites;
- release candidates run the full mandatory suite regardless of changed-file selection;
- test-selection logic itself is versioned/tested.

## 28. Flaky Tests and Quarantine

A test is flaky only after evidence shows non-determinism/infrastructure instability rather than product behavior.

Rules:

- C0 tests cannot be quarantined;
- a C1 test may not be omitted from release;
- C2 tests may be quarantined for at most **7 days** with owner, issue, first-failure SHA, reason and expiry;
- a quarantined C2 test still runs when feasible and reports separately;
- rerun count is never used to hide original failure rate;
- repeated infrastructure failures become a CI defect with explicit owner.

## 29. Timeouts

Every automated test/suite has a finite timeout.

Guidelines:

- pure unit test: <=1 second each unless justified;
- fast property family: <=30 seconds;
- Studio scenario: <=120 seconds by default;
- staging fault scenario: <=300 seconds by default;
- long performance tests are explicitly labeled and run outside the fast PR lane.

Timeout is failure/unknown evidence, never success.

## 30. Evidence Retention

For the current public GitHub repository:

- ordinary PR diagnostics/artifacts: target **14 days**;
- trusted release-candidate evidence: **90 days** where GitHub repository retention permits;
- final release record stores durable summary/manifest references in repository/release documentation, not only ephemeral CI artifacts.

Sensitive staging logs are minimized/redacted before upload.

## 31. Regression Policy

Every fixed C0/C1 defect adds a regression test at the lowest trustworthy layer unless technically impossible.

A regression test records:

- defect/issue reference;
- failing invariant;
- minimal fixture/seed/cut point;
- fixed expected result.

Deleting or weakening that test requires the same review level as changing the owning architecture invariant.

## 32. Prohibited Testing Shortcuts

Forbidden:

- production profile/store use in automated tests;
- sleeps used as the sole synchronization proof when a deterministic signal exists;
- random seeds not logged;
- retry-until-green;
- exact-once verification that checks only final UI text;
- security tests that only check client-side validation;
- performance tests only in empty solo Studio;
- snapshot/golden tests for volatile private implementation structure with no semantic value;
- `pull_request_target` + untrusted code execution in privileged context;
- public-repo fork code on persistent self-hosted personal machines;
- committed credentials/tokens.

## 33. Platform Snapshot Boundary

TA15_ROBLOX_TESTING_SECURITY_CI_PLATFORM_SNAPSHOT.md records current Roblox/GitHub capabilities on 2026-09-24.

TA-17 must revalidate before concrete workflow/test-runner locking.

Stricter future platform security constraints apply immediately. New convenience features do not automatically weaken this trust model.

## 34. TA-16 Obligations

TA-16 must audit:

- every TA-0..14 invariant has a TA-15 evidence path;
- no required test depends on forbidden authority or production data;
- no quality gate contradicts TA-14 degradation semantics;
- every C0 transaction/security path has negative/fault coverage;
- no integration seam is left with only mock evidence where engine/platform behavior matters.

## 35. TA-17 Obligations

TA-17 must lock:

- concrete `tests/unit|integration|scenarios|fixtures` layout;
- first-party runner APIs;
- exact commands/config for StyLua/Selene/type analysis/Rojo;
- optional standalone Luau test execution tool if adopted;
- Studio automation plugin/runner implementation;
- workflow YAML/action SHAs/permissions;
- environment/ruleset/required-check names;
- test manifest format;
- artifact naming/retention implementation;
- implementation sequencing so test infrastructure precedes critical gameplay modules.

## 36. Open Questions

**Zero TA-15 implementation-blocking architecture questions remain.**

Operational implementation details remain intentionally downstream to TA-17, including the concrete ephemeral Studio runner mechanism available at that time.

## 37. Architecture-Complete Checklist

- [x] verification taxonomy locked;
- [x] test identity/traceability locked;
- [x] criticality/release semantics locked;
- [x] static/build gates locked;
- [x] deterministic unit/property/randomness strategy locked;
- [x] Studio engine automation boundary locked;
- [x] device/input/accessibility matrix locked;
- [x] hostile-client/security matrix locked;
- [x] persistence/migration/transaction fault strategy locked;
- [x] cross-server/config/commerce failure strategy locked;
- [x] TA-14 performance verification locked;
- [x] diagnostics/evidence contract locked;
- [x] DEV/STAGING/PRODUCTION test isolation locked;
- [x] public-repository CI trust model locked;
- [x] merge/release gates locked;
- [x] flake/quarantine/timeout policy locked;
- [x] evidence retention/regression policy locked;
- [x] TA-16/17 obligations explicit;
- [x] zero TA-15-blocking questions.

**TA-15 architecture contract: PASS.**
