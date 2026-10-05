# Golden Slice Executable Task Plan

> Status: READY FOR WORK MODE
> Date: 2026-10-06
> Companion: GOLDEN_SLICE_CODE_INTEGRATION_MAP.md
> Goal: turn the existing production package into an ordered implementation plan with explicit file seams and stop conditions

## 1. Execution model

Do not run the Golden Slice as one uncontrolled art pass.

Use eight implementation slices.

Each slice must leave the project:

- runnable;
- CI-green;
- authority-correct;
- visually inspectable;
- no worse than the prior slice.

One PR is acceptable, but commits should remain reviewable.

## 2. Slice 0 — Studio truth audit

### Goal

Establish the actual current local visual state before modifying art.

### Inspect

- current open Roblox Studio place;
- current Rojo sync state;
- default.project.json;
- Workspace.MonsterVaultWorld;
- tagged gameplay anchors;
- Lighting;
- existing Energy Core;
- any user-local uncommitted Studio assets;
- Blender connection and local Blender CLI fallback.

### Produce

- before screenshots:
  - Starter;
  - Safe Outpost;
  - Home;
  - Vault;
  - creature;
  - capture UI;
- list of local assets that must be preserved;
- exact anchor positions / tags that are gameplay-critical;
- confirmation whether Studio has visuals not represented in repo.

### Stop condition

Do not model production assets until this audit is recorded.

## 3. Slice 1 — Presentation foundation

### Goal

Create the smallest reusable visual foundation before restyling multiple screens.

### Likely files

New, only as used:

- `src/client/presentation/theme/ThemeTokens.luau`
- `src/client/presentation/theme/RarityTokens.luau`
- `src/client/presentation/theme/SeasonalTheme.luau`
- `src/client/presentation/components/Panel.luau`
- `Button.luau`
- `CreatureCard.luau`
- `RarityBadge.luau`
- `EnergyChip.luau`

Optional:

- `PresentationPreferences.luau`

### Preserve

- no gameplay routes;
- no persistent schema;
- no authoritative rarity changes.

### Tests

- token/table validity;
- rarity label/shape coverage Common through Legendary;
- Reduced Motion helper behavior where pure-testable;
- SeasonalTheme OFF returns permanent tokens.

### Stop condition

At least Capture and one Vault/Showcase screen can consume the same components without copy-pasted colors/spacing.

## 4. Slice 2 — Permanent Starter + Home/Vault environment

### Goal

Remove the flat-blockout visual impression while preserving gameplay anchors.

### Work

- build/reuse Blender environment kit;
- safe-outpost shell;
- secure-point presentation;
- travel-terminal presentation;
- Starter terrain/rocks/path;
- Home/Vault exterior/interior shell;
- integrate existing Energy Core;
- permanent Lighting baseline.

### Source paths

Use production standard:

- assets/blender/environment/
- assets/blender/vault/
- assets/exported/...
- tools/blender/...

### Runtime constraints

Do not casually move:

- StarterOutpost;
- secure-point/fixture-spawn;
- travel-node/starter;
- recovery-anchor/starter;
- vault-access-point/home-hub;
- spawn/habitat anchors.

### Validation

- route remains traversable;
- Vault access still opens;
- travel/recovery still works;
- no visual prop blocks hazard/safe-route behavior.

### Stop condition

Halloween OFF Starter and Home screenshots already look production-intentional.

## 5. Slice 3 — Production creature visual path

### Goal

Replace the server-materialized placeholder ball with actual production creature visuals.

### Primary seam

`src/server/bootstrap/WorldRuntimeService.luau::materialize()`

### Implement

- one bounded visual factory/prefab loader;
- production `species/fixture-orb`;
- production `species/stability-orb-dev`;
- optional second Common only if efficient.

### Preserve

`activate()` remains owner of:

- CreatureInstanceId;
- SpeciesId;
- RarityId;
- SpawnContextId;
- RuntimeRevision;
- Availability;
- LifetimeClass;
- CollectionService tag.

### Do not

- choose rarity from prefab;
- change capture radius implicitly through mesh bounds;
- move gameplay root due to idle animation;
- attach gameplay logic to cosmetic bones.

### Tests/evidence

- WorldProjection regression;
- WorldService regression;
- common world screenshot;
- Legendary world screenshot;
- display pose screenshot;
- triangle/material/pivot manifest.

### Stop condition

The representative Common and Legendary are no longer engineering spheres in the Golden path.

## 6. Slice 4 — Capture + rarity sensory presentation

### Goal

Make capture feel production-quality without changing CaptureService.

### Files

Keep:

- CaptureController

Upgrade/wire:

- CaptureRuntimeService
- CaptureView
- new capture presentation helpers/coordinator as needed.

### Presentation sequence

Authoritative state -> presentation:

- Idle/target -> restrained target read;
- Pending -> local acknowledgement;
- Claimed -> containment readiness;
- attempt -> buildup;
- Provisional/transport -> clearly temporary;
- FinalizationPending -> saving/committing;
- Secured -> payoff;
- failure/interruption/expiry -> distinct non-success treatment.

### Legendary

Trigger from authoritative world rarity and exact model presence.

### Optional reserved unreliable route

Only bind Presentation.CaptureTiming if it materially improves synchronized non-authoritative timing.

Not required for first working pass.

### Accessibility

- Reduced Motion;
- camera shake setting;
- non-audio equivalents;
- no rapid full-screen flashing.

### Tests

- CaptureController untouched or existing tests green;
- any local transition coordinator exactly-once per authoritative revision;
- CaptureClientRuntime regression;
- capture Studio probe.

### Stop condition

Capture works and is understandable with effects ON, effects reduced, and audio muted.

## 7. Slice 5 — Vault UI, physical display and Energy Claim

### Goal

Make the Home/Vault payoff the aspirational center of the Golden loop.

### UI

Restyle/decompose:

- VaultRuntimeService;
- VaultAssignmentRuntimeService;
- ProgressionRuntimeService later in Slice 6.

Controllers remain state/intent owners.

### Physical display

First inspect whether local Studio/repo already contains a safe exact-instance visual source.

If not:

- implement the minimal bounded owner display identity projection described in CODE_INTEGRATION_MAP;
- reuse ShowcaseProjection identity filtering where possible;
- do not expose private profile/economy/audit data.

### Energy Claim

Use existing confirmed claim path in VaultAssignmentController.

Add a local callback only after matching server confirmation.

Presentation:

machine response -> visible Energy transfer -> count-up -> completion impact.

### Vault idle

Drive from projected:

- buffer;
- production assignment;
- claimability.

No client accrual.

### Tests

- ProductionClaim;
- VaultProduction;
- assignment regression;
- new presentation callback does not replay on ordinary initial resync;
- exact display identity remains read-only presentation.

### Stop condition

One assigned/displayed creature and one Energy Claim can be demonstrated end-to-end with no duplicated ownership or fake value.

## 8. Slice 6 — Progression + Showcase production UI

### Progression

Use:

- ProgressionController;
- ProgressionProjection.

Restyle with shared components.

Add reward/unlock payoff only after confirmed projection/receipt.

### Showcase extraction

Create:

- production `ShowcaseRuntimeService` or equivalent.

Move production Showcase subscription/UI out of PartyRuntimeService.

Preserve:

- ShowcaseProjectionStore;
- server ShowcaseService;
- read-only contract;
- Close consumes permission according to current semantics.

PartyRuntimeService may retain Party/Challenge diagnostics until later PQL work.

### Tests

- ShowcaseVisitor existing suite;
- progression purchase existing suite;
- subscription ownership is one-shot and clean on stop;
- visitor has no writer.

### Stop condition

Showcase no longer looks like a text diagnostic and still exposes only approved fields.

## 9. Slice 7 — Halloween 2026 presentation layer

### Goal

Apply the launch theme after permanent quality exists.

### Add

- seasonal props;
- Vault dressing;
- autumn/dead foliage;
- spectral hero prop;
- Halloween lighting/effect layer;
- seasonal UI accents;
- ambient audio;
- seasonal capture/reveal layer;
- Legendary-compatible spectral presentation.

### Namespace

Prefer:

- Workspace/MonsterVaultWorld/Presentation/Seasonal/Halloween2026
or equivalent validated Studio/Rojo representation.

### Presentation toggle

DEV/staging toggle only.

No:

- date-authoritative event logic;
- rewards;
- event currency;
- spawn changes;
- commerce.

### Required evidence

Matched camera:

- Halloween ON;
- Halloween OFF.

### Stop condition

ON feels intentionally Halloween; OFF still looks like a finished MonsterVault game.

## 10. Slice 8 — Performance, regression and evidence closure

### Run

Automated:

- full fast/unit suite;
- CI static build;
- applicable native Studio probes.

Manual/Studio:

- Starter;
- Halloween Starter;
- capture;
- Legendary;
- Vault;
- Energy Claim;
- Showcase;
- mobile viewport;
- gamepad;
- PreferredTextSize;
- Reduced Motion.

### Measure

Against authoring guardrails:

- triangles;
- draw calls;
- lights;
- particles;
- UI object count;
- obvious memory/frame regressions.

### Update

- GOLDEN_SLICE_ASSET_MANIFEST
- GOLDEN_SLICE_ACCEPTANCE_MATRIX
- performance evidence
- actual screenshot paths
- PQL status wording.

### Stop condition

Only after evidence supports it, report:

"Golden Playable Vertical Slice reference quality established for the representative Starter/Home path."

Do not claim:

- release ready;
- PQL-1 fully complete;
- all world art complete;
- full scale validated.

## 11. Suggested code-change ownership table

| Feature | Existing owner | Production hook | Avoid |
| --- | --- | --- | --- |
| creature model | WorldRuntimeService | visual factory at materialize() | CaptureService changes |
| world rarity visual | WorldModelObserver/Store | presentation subscriber | client rarity inference |
| capture UX | CaptureController | CaptureRuntime + production view/coordinator | second state machine |
| secured payoff | Capture Secured + SecuredCollectionStore | local presentation transition | ownership remote |
| Vault management | VaultController | production view/components | VaultService rewrite |
| assignment UI | VaultAssignmentController | production view | duplicate assignment logic |
| Energy Claim | confirmed assignment snapshot | local onClaimConfirmed callback | client value calculation |
| progression | ProgressionController | production view | purchase contract changes |
| Showcase | ShowcaseProjectionStore | dedicated runtime/view | ShowcaseService rewrite |
| Halloween | presentation namespace/theme | SeasonalTheme/controller | event authority |

## 12. Expected first Work commit

The first substantive commit should NOT be "add Halloween props".

Preferred first commit:

`golden: establish presentation foundation and permanent Starter/Vault shell`

It should contain:

- baseline audit evidence;
- theme/component foundation actually used;
- permanent environment/Vault first pass;
- no authority changes.

## 13. Expected high-risk review points

Work must explicitly review before merging:

1. creature prefab root/capture distance;
2. Rojo/Studio ownership of imported visual objects;
3. owner display identity projection privacy;
4. Energy Claim local callback replay behavior;
5. Showcase subscription extraction;
6. Halloween OFF completeness;
7. transparent fog/particle overdraw;
8. local lights/shadows in Vault;
9. mobile text scaling;
10. no visual path mutates server truth.

## 14. If Work has to cut scope

Cut in this order:

1. secondary Halloween decorations;
2. optional second Common creature;
3. decorative Vault micro-animation;
4. extra ambient VFX;
5. Photo/Showcase framing extras.

Do NOT cut:

- permanent Starter quality;
- permanent Vault quality;
- first Common;
- Legendary representative;
- capture truth/readability;
- Energy Claim;
- mobile/accessibility;
- Halloween ON/OFF separation;
- Studio evidence.
