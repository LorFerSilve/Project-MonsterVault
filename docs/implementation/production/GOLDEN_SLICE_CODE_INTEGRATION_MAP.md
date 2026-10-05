# Golden Slice Code Integration Map

> Status: PRE-WORK CODE AUDIT COMPLETE
> Date: 2026-10-06
> Base audited: main @ 7a61bc0578d98762bd3abd181c5f0d31bf9ebd74
> Purpose: tell Work where production presentation belongs in the existing codebase without reopening gameplay authority

## 1. Core rule

The Golden Slice is a presentation/production-quality pass over already-authoritative gameplay.

Do not create a second gameplay state machine.

Use this flow everywhere:

```
authoritative server state
        ↓
existing bounded projection / world attributes
        ↓
existing client controller/store
        ↓
new production presentation layer
        ↓
UI / animation / VFX / audio / camera
```

Presentation may anticipate input acknowledgement through Pending state, but must never fabricate success.

## 2. Current client composition

Current client entry point:

- `src/client/bootstrap/ClientMain.client.luau`

Current service set:

- PartyRuntimeService
- ProgressionRuntimeService
- VaultAssignmentRuntimeService
- VaultRuntimeService
- NetworkingRuntimeService
- WorldModelObserver
- CaptureRuntimeService

This is the correct composition seam for new production-only client services.

Preferred rule:

- add small presentation services only where existing runtime services would otherwise become unrelated monoliths;
- do not add one service per particle or animation;
- preserve dependency order through existing ClientComposition/StartupPlan.

## 3. Networking / projection seam

Primary files:

- `src/client/bootstrap/NetworkingRuntimeService.luau`
- `src/client/networking/ClientGateway.luau`
- `src/server/bootstrap/NetworkingRuntimeService.luau`
- `src/shared/contracts/RouteIds.luau`

Current reliable projection listeners exist for:

- Capture
- Vault
- Vault Assignments
- Progression
- Party
- Showcase

Current stores also include:

- session ProjectionStore
- PartyProjectionStore
- ShowcaseProjectionStore
- SecuredCollectionStore

Important existing reserved presentation routes:

- `Presentation.CaptureTiming`
- `Presentation.WorldCue`

They are already allowlisted as unreliable events.

Current state:

- the client validates incoming unreliable presentation envelopes;
- there is no production cosmetic consumer bound yet;
- server NetworkingGateway supports `cosmetic(...)`;
- schemas/producers are not currently bound for these PQL routes.

### Integration rule

Do not invent new reliable gameplay messages just for VFX if current authoritative projections already contain enough state.

Use unreliable presentation routes only when a server-originated timing/world cue materially improves synchronization and the payload can remain cosmetic.

If used:

- bind an explicit schema;
- payload must contain no new authority;
- dropped unreliable events must not break semantics;
- reliable projection remains the source of truth;
- Reduced Motion / quality settings may ignore the cue.

## 4. World / environment integration

Primary files:

- `default.project.json`
- `src/server/domains/world/WorldDefinitions.luau`
- `src/server/domains/world/WorldAuthoringIndex.luau`
- `src/server/bootstrap/WorldRuntimeService.luau`
- `src/client/bootstrap/WorldModelObserver.luau`
- `src/client/store/WorldProjectionStore.luau`

### Current functional anchors

The authored blockout currently contains tagged/attributed objects for:

- Starter region;
- Home Hub;
- Secure Points;
- Travel Nodes;
- Recovery Anchors;
- Vault Access Point;
- Safe Outposts;
- Habitats;
- Spawn Anchors;
- hazard volume;
- route geometry.

These are gameplay/authoring contracts.

### Golden environment rule

Production environment art should wrap, replace the visible shell around, or visually integrate these anchors without casually changing:

- RegionId;
- SecurePointId;
- TravelNodeId;
- RecoveryAnchorId;
- VaultAccessPointId;
- HabitatId;
- SpawnContextId;
- collision/query semantics used by gameplay;
- authored coordinates relied on by current tests.

If a gameplay-critical anchor is moved, update and revalidate its owning authoring contract rather than moving it only in Studio.

### Recommended presentation namespace

Use a clearly separated presentation hierarchy where practical, for example:

```
Workspace
└── MonsterVaultWorld
    ├── <existing gameplay anchors>
    └── Presentation
        ├── Permanent
        └── Seasonal
            └── Halloween2026
```

Exact hierarchy may adapt to current Studio/Rojo behavior, but permanent and seasonal presentation must remain separable.

Do not leave important production geometry as unsourced local-only Studio state.

## 5. Runtime creature model integration

Primary seam:

- `src/server/bootstrap/WorldRuntimeService.luau`
- function: `materialize(projection)`

Current implementation is explicitly placeholder-grade:

- creates a `Model` named `FixtureCreature`;
- creates one 4x4x4 Ball Part;
- applies `FixtureCreature` material;
- adds a diagnostic BillboardGui for protected Legendary encounters.

The authoritative identity is applied later by `activate(...)`:

- CreatureInstanceId
- SpeciesId
- RarityId
- SpawnContextId
- Availability
- RuntimeRevision
- LifetimeClass
- availability timestamps
- `MonsterVaultWorldCreature` tag

### Recommended change

Factor visual construction out of `materialize()` into one bounded presentation factory, for example:

```
WorldCreatureVisualFactory.create(projection)
    -> Model
```

The factory may clone/import a Species visual prefab, but:

- `activate()` remains the authoritative attribute/tag owner;
- the factory does not choose Species/Rarity;
- visual fallback must not invent a different identity;
- PrimaryPart/pivot must remain stable for capture distance and streaming;
- lifecycle remains owned by WorldService.

The protected Legendary diagnostic Billboard can be replaced by production presentation only after equivalent semantic readability exists.

### Client presentation data already available

`WorldProjectionStore.view(id)` exposes:

- creatureInstanceId;
- speciesId;
- rarityId;
- spawnContextId;
- runtimeRevision;
- availability;
- lifetimeClass;
- timing;
- presence.

Therefore rarity/reveal presentation does not need client guesses.

## 6. World presentation observer

Current seam:

- `WorldModelObserver`

It already owns CollectionService observation of `MonsterVaultWorldCreature`.

Avoid creating several duplicate CollectionService observers for creature VFX.

Preferred small extension:

- add a bounded `subscribe(listener)` presentation notification to WorldModelObserver/WorldProjectionStore;
- notify after accepted stream-in/update/stream-out;
- listeners receive read-only presentation state;
- no new authority.

Then one future `WorldPresentationRuntimeService` can own:

- spawn/reveal presentation;
- rarity aura attachment;
- Halloween creature presentation;
- ambient creature presentation hooks.

If this extension creates unnecessary churn, Work may consume the observer store directly, but should avoid per-frame full-world scans.

## 7. Capture integration

Primary files:

- `src/client/bootstrap/CaptureRuntimeService.luau`
- `src/client/controllers/CaptureController.luau`
- `src/client/presentation/CaptureView.luau`
- `src/server/bootstrap/CaptureRuntimeService.luau`
- `src/shared/contracts/CaptureProjectionV1.luau`

### Existing authoritative client states

CaptureController already presents:

- Idle
- Pending
- OutcomeUnknown
- Claimed
- AttemptActive / server transitions
- Provisional / transport states
- FinalizationPending
- Secured
- Failed
- Interrupted
- Expired

The controller also preserves exact request/replay/recovery semantics.

### Safe production seam

Do NOT replace CaptureController.

Replace/upgrade presentation around it.

Recommended structure:

```
CaptureController
    ↓ onChanged
CapturePresentationCoordinator
    ├── CaptureView
    ├── CaptureVFX
    ├── CaptureAudio
    ├── CaptureCamera
    └── optional Haptics
```

CaptureRuntimeService remains the owner that wires:

- controller;
- input;
- world target;
- networking subscription;
- presentation.

A local coordinator may compare previous and new presentation state to fire one local sensory transition per authoritative revision.

### Capture outcome rule

- Pending can animate anticipation.
- Secured payoff fires only after authoritative Secured.
- FinalizationPending must look different from Secured.
- Timeout / OutcomeUnknown cannot use a failure animation unless server state confirms failure.
- Reduced Motion may replace camera movement/shake with static/fade emphasis.

No server gameplay change is required for the basic Golden capture arc.

## 8. Rare / Legendary reveal integration

Authoritative source:

- `WorldProjectionStore.view(...).rarityId`
- `LifetimeClass`
- authored Species identity
- protected encounter semantics from WorldDefinitions

Current authored production candidate:

- `species/stability-orb-dev`
- intrinsic `rarity/legendary`
- protected encounter lifetime

### Recommended trigger

Use the first accepted local presence of the exact Legendary world model plus authoritative rarity/lifetime fields.

Do not trigger Legendary presentation from:

- mesh material;
- particle color;
- name substring;
- seasonal skin;
- paid cosmetic.

The same base reveal controller should later support Rare/Epic when such authored content exists.

## 9. Secured / Collection payoff

Existing sources:

- CaptureController authoritative `Secured` state;
- `SecuredCollectionStore` provides a bounded recent exact-instance ownership summary.

For the immediate Golden secured payoff:

- the Capture `Secured` transition is sufficient to trigger confirmation presentation;
- if Collection UI needs recent durable identity verification, read the SecuredCollectionStore rather than inferring from the world model.

Do not add a second ownership confirmation remote just for animation.

## 10. Vault access integration

World seam:

- `WorldRuntimeService.bindVaultAccess(...)`
- Home Vault Access Point delegates to server `publishVault(...)`

Client seams:

- `VaultRuntimeService`
- `VaultController`
- `VaultAssignmentRuntimeService`
- `VaultAssignmentController`

Current Vault UI is functional/diagnostic and may be restyled or decomposed, but existing controllers should remain the intent/state owners.

## 11. Vault Assignment / physical display integration

Current owner projection:

- `VaultAssignmentProjection.fromProfile(...)`

It currently exposes per row:

- creatureInstanceId;
- overflowHeld;
- locked;
- productionSlotId;
- displaySlotId.

It intentionally does NOT expose:

- Species;
- rarity;
- Mutation;
- Trait.

This is enough for assignment authority but not enough by itself to render a production-quality exact creature model in a personal client-side display.

### Known presentation gap

Golden physical display requires exact collectible identity per displayed instance.

GDS-7 requires display to preserve Species, Mutations and relevant Traits.

Do not solve this with a client lookup table based only on creature ID.

Preferred minimal options, in order:

1. **Reuse a bounded existing server-side identity projection path** if current repository/Studio state already provides one after Work inspection.
2. If not, add a dedicated read-only owner display presentation projection containing only the identity fields already approved for Showcase:
   - creatureInstanceId
   - speciesId
   - speciesRarityId
   - mutationIds
   - traitIds
   - displaySlotId
3. Reuse `ShowcaseProjection.fromProfile(...)` filtering logic where possible instead of creating divergent disclosure rules.

Do not broaden VaultAssignmentProjection with unrelated profile data merely because the screen needs richer art.

Any new projection remains presentation-only and must be bounded/revisioned/validated.

## 12. Energy Claim hero sequence

Primary files:

- `src/client/controllers/VaultAssignmentController.luau`
- `src/client/bootstrap/VaultAssignmentRuntimeService.luau`
- `src/server/application/ProductionClaimUseCase.luau`
- `src/server/application/VaultAssignmentProjection.luau`

Important existing server-confirmed fields:

- energyUnits
- claimExpectedRevision
- claimUnits
- bufferMilli
- bufferCapacityMilli

Current controller already knows when a pending claim becomes conclusively saved and already builds:

`Claim saved: +N Energy.`

### Best sensory hook

Add an optional local presentation callback at the exact point where `VaultAssignmentController.handleSnapshot(...)` confirms the matching pending claim.

Example conceptual callback:

```
onClaimConfirmed({
    units = snapshot.state.claimUnits,
    energyUnits = snapshot.state.energyUnits,
    revision = snapshot.revision,
})
```

Then:

```
VaultAssignmentController
    ↓ confirmed receipt
EnergyClaimPresentation
    ├── machine activation
    ├── source-to-wallet VFX
    ├── local count-up
    ├── sound
    └── haptic
```

This avoids replaying a hero animation merely because an old claim receipt appears during an ordinary resync/rejoin.

Do not change ProductionClaimUseCase for visual timing unless a real missing semantic cue is proven.

## 13. Vault idle machinery

Presentation owner should consume current visual state, not production logic.

Allowed local inputs:

- buffer fraction from VaultAssignment snapshot;
- machine assigned/unassigned state;
- local animation quality;
- seasonal theme.

Examples:

- idle Energy pulse based on buffer > 0;
- stronger machine activity when production assignment exists;
- claim-ready indicator when buffer has whole claimable units.

Do not calculate or accrue production client-side.

## 14. Progression integration

Primary files:

- `ProgressionRuntimeService`
- `ProgressionController`
- `ProgressionProjectionV1`
- `ProgressionProjection.fromProfile`

Current projection already contains:

- Energy;
- deferred bounded reward;
- Collection capacity;
- current catalog item;
- quote;
- owned status;
- gate reason;
- receipt/purchase result fields.

### Production rule

Keep ProgressionController as owner of:

- navigation;
- quote review;
- explicit confirm;
- Pending/recovery.

Replace diagnostic visual construction with shared production UI components.

A progression unlock payoff can trigger only after a confirmed server projection/receipt indicates ownership/purchase completion.

## 15. Showcase integration

Current implementation:

- authoritative store: `ShowcaseProjectionStore`;
- current diagnostic UI is embedded inside `PartyRuntimeService`;
- `PartyRuntimeService` owns the single current `subscribeShowcase(...)` listener;
- display is text-only.

### Recommended production extraction

Create one dedicated:

`ShowcaseRuntimeService`

Responsibilities:

- own `subscribeShowcase(...)`;
- render permission state and read-only visit state;
- use the shared CreatureCard component;
- handle Close/Return;
- preserve read-only semantics.

When this service becomes production owner:

- remove the Showcase diagnostic block and `unsubscribeShowcase` ownership from PartyRuntimeService;
- do NOT add a second listener by weakening the single-listener assertion unless multiple listeners are genuinely required.

Party diagnostics may remain for Party/Challenge until their own later PQL pass.

## 16. UI production foundation

Recommended new client layout:

```
src/client/presentation/
├── theme/
│   ├── ThemeTokens.luau
│   ├── RarityTokens.luau
│   └── SeasonalTheme.luau
├── components/
│   ├── Panel.luau
│   ├── Button.luau
│   ├── CreatureCard.luau
│   ├── RarityBadge.luau
│   ├── EnergyChip.luau
│   ├── Notification.luau
│   └── Modal.luau
├── capture/
├── vault/
├── progression/
└── showcase/
```

This is a recommended decomposition, not a requirement to create empty framework folders.

Only create components used by the Golden path.

## 17. Accessibility integration

Existing architecture already requires:

- `GuiService.ReducedMotionEnabled`;
- preferred text size;
- safe insets;
- cross-input focus;
- semantic redundancy.

Current CaptureView already correctly uses CoreUISafeInsets and conservative gamepad focus ownership.

Preserve those behaviors when restyling.

Recommended one local presentation settings helper:

`PresentationPreferences`

It can compose platform settings for:

- Reduced Motion;
- PreferredTextSize;
- transparency/readability where supported;
- local effect quality.

Do not duplicate authoritative player gameplay preferences here.

## 18. Halloween presentation integration

No production event authority exists yet for Halloween timing.

Golden Slice may use a DEV/staging presentation toggle only.

Recommended separation:

```
Permanent Presentation
+ SeasonalTheme(Halloween2026)
```

Seasonal presentation may control:

- decorative world folder;
- UI skin tokens;
- ambient audio layer;
- seasonal particles;
- seasonal lighting effects;
- cosmetic creature overlay.

It may NOT control:

- spawn eligibility;
- rewards;
- capture odds;
- event occurrence;
- progression gates;
- purchases.

Do not use `os.date()` or client local date as production Halloween event truth.

## 19. Lighting integration

Treat Studio Lighting as the permanent baseline.

Seasonal treatment should be additive/reversible, preferably through explicitly named effect instances or a small presentation controller.

Do not overwrite Lighting destructively in a way that makes the permanent baseline impossible to recover.

Evidence must include Halloween ON/OFF from the same representative camera.

## 20. Audio integration

Recommended one client presentation audio owner rather than each view creating unrelated loops.

Logical categories should follow TA-12:

- Effects;
- UI/Notification;
- ambient/music where used.

Do not put a persistent Sound loop on every pumpkin/machine.

Use local semantic events from the same production coordinators:

- Capture transition;
- Legendary reveal;
- Energy Claim confirmation;
- UI press/confirm;
- progression unlock.

## 21. Tests / evidence map

Existing unit tests most relevant to regression:

- tests/unit/CaptureClientRuntime.luau
- tests/unit/CaptureController.luau
- tests/unit/CaptureRuntime.luau
- tests/unit/WorldProjection.luau
- tests/unit/WorldService.luau
- tests/unit/VaultProduction.luau
- tests/unit/ProductionClaim.luau
- tests/unit/ProgressionPurchase.luau
- tests/unit/ShowcaseVisitor.luau
- tests/unit/NetworkIngress.luau
- tests/unit/ProtocolContracts.luau

Existing Studio probes most relevant:

- imp8_capture_diagnostics
- imp9_production_client
- imp9_production_settlement
- imp10_authoring_checks
- imp10_protected_lifetimes
- imp10_travel_client/recovery
- imp11_showcase_authority/client

Production presentation tests should focus on:

- pure token/component logic where testable;
- transition callback exactly-once semantics;
- seasonal ON/OFF state;
- no authority mutation;
- Studio/client visual/input/accessibility evidence.

Do not attempt to unit-test visual quality itself.

## 22. Files that should normally remain authority-stable

Golden visual work should avoid changing these unless a real integration gap proves it necessary:

- CaptureService
- CaptureFinalizationUseCase
- ProductionClaimUseCase
- EnergyService
- ProgressionService
- VaultService
- ShowcaseService
- WorldService
- persistence/session writer architecture
- replay/rate-limiter contracts

Most Golden work belongs at:

- materialization/prefab seam;
- client presentation/runtime seam;
- Studio-authored visual content;
- central material/theme/config presentation;
- cosmetic unreliable cues if later justified.

## 23. Known integration gaps to resolve during Work

These are the only currently identified presentation gaps worth solving:

### GAP-01 — Creature materializer is hard-coded placeholder

Owner:
`WorldRuntimeService.materialize()`

Resolution:
production visual factory/prefab seam.

### GAP-02 — No reusable production UI component layer

Owner:
new client presentation modules.

Resolution:
small ThemeTokens + components used by Golden screens only.

### GAP-03 — Showcase production UI is embedded in Party diagnostic panel

Owner:
client runtime composition.

Resolution:
extract production ShowcaseRuntimeService.

### GAP-04 — Owner physical display projection lacks rich exact-instance visual identity

Owner:
presentation projection boundary.

Resolution:
reuse existing safe identity projection/filter or add one minimal bounded read-only projection.

### GAP-05 — Cosmetic unreliable routes are reserved but have no consumer

Owner:
later PQL presentation if useful.

Resolution:
bind only when needed; not a prerequisite for basic Golden pass.

### GAP-06 — No modular seasonal presentation controller/namespace yet

Owner:
presentation only.

Resolution:
small Halloween2026 theme/toggle layer with no event authority.

## 24. Work decision rule

If Work discovers another gap:

1. prove current projection/controller cannot support the visual requirement;
2. solve at the narrowest presentation boundary;
3. do not modify persistent schema unless absolutely required;
4. do not add a server-authoritative concept that does not already exist in GDS/TA;
5. record the gap and reason in Golden evidence.
