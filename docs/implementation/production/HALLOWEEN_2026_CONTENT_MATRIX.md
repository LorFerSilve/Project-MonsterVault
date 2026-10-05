# Halloween 2026 Content Matrix

> Status: PRE-PRODUCTION ROUTING MATRIX
> Date: 2026-10-06
> Parent brief: ../HALLOWEEN_2026_LAUNCH_THEME.md
> Purpose: make every Halloween idea land in the correct owner instead of becoming one-off launch debt

## 1. Rule

Halloween 2026 is a launch theme, but implementation authority remains unchanged.

Use:

**Permanent base + Seasonal Presentation + Authoritative Event Layer + Commercial Layer + Live-Ops Layer**

Only implement the layer whose owner already exists.

## 2. Matrix

| Area | Permanent production base | Halloween 2026 layer | Owning phase | Can Golden Slice implement now? |
| --- | --- | --- | --- | --- |
| Starter terrain | authored terrain/rocks/paths | autumn/dead foliage, pumpkins, fog accents | PQL-1 | YES |
| Safe Outpost | reusable tech structure | lanterns/webs/candles | PQL-1 | YES |
| Home/Vault | production Vault architecture | seasonal dressing / spectral accents | PQL-1/4 | YES |
| Lighting | readable permanent lighting | moonlit/candle/spectral additive treatment | PQL-1/4 | YES |
| Common creature | production model | optional cosmetic seasonal dressing | PQL-2 | YES, if presentation-only |
| Legendary | production intrinsic rarity treatment | Halloween-compatible reveal layer | PQL-2/4 | YES |
| UI | reusable native components | decorative seasonal skin/banner | PQL-3 | YES |
| Capture | honest capture feedback | seasonal particles/audio layer | PQL-4 | YES |
| Energy Claim | permanent hero sequence | subtle seasonal Vault dressing | PQL-4 | YES |
| Ambient audio | biome/Vault identity | spooky-fun seasonal overlay | PQL-4 | YES |
| Event occurrence | normal event architecture | Halloween start/end occurrence | IMP-11 events | NO until owner implemented |
| Spawn modifiers | normal prospective event binding | seasonal creature/event spawn changes | IMP-11 events | NO |
| Event objectives | shared/personal contribution contracts | Halloween objectives/community goal | IMP-11 | NO |
| Event rewards | exact-once personal reward path | limited Halloween rewards | IMP-11 | NO |
| Cross-server refresh | durable truth + hints | Halloween occurrence update hints | IMP-11 | NO |
| Seasonal shop | deterministic cosmetic commerce | Halloween bundle/Vault theme | IMP-13 | VISUAL CONCEPT ONLY now |
| Seasonal pass | approved deterministic tracks | Halloween Collection Pass content | IMP-13/14 | NO transactional implementation |
| Avatar/UGC | platform commerce path | Halloween avatar/UGC | IMP-13 | later |
| Activation | normal config/flags | turn seasonal layer/event on/off | IMP-14 | DEV toggle only now |
| Analytics | normal telemetry | seasonal engagement/conversion | IMP-14 | later |
| Store icon/thumbnails | honest product imagery | Halloween launch key art | PQL-10 | later production, can concept now |

## 3. Golden Slice Halloween minimum

The first Golden visual pass should include enough seasonal content to make the intended launch identity obvious:

- one Halloween-dressed Starter vista;
- one Halloween-dressed Safe Outpost;
- one Halloween-dressed Vault view;
- one seasonal hero prop/landmark;
- seasonal lighting/atmosphere treatment;
- one Halloween-compatible creature or Legendary presentation;
- one seasonal UI banner/accent example;
- one seasonal capture/reveal sensory example;
- ambient Halloween audio layer if tooling/assets permit.

This is presentation, not an authoritative timed event.

## 4. Permanent-off-season test

With Halloween disabled:

- paths remain readable;
- major landmarks remain;
- Vault still looks complete;
- creatures still have coherent permanent materials;
- UI loses decorative seasonal tokens only;
- capture/reveal remains satisfying;
- Energy Claim remains satisfying;
- no gameplay objective disappears;
- no permanent collision depends on pumpkin/gravestone props.

Golden evidence must include at least one representative seasonal-OFF view.

## 5. Seasonal namespaces

Recommended content organization:

Workspace presentation container:
MonsterVaultSeasonal/Halloween2026

Repository source:
assets/blender/seasonal/halloween_2026  
assets/exported/seasonal/halloween_2026  
tools/blender/seasonal/halloween_2026

Client presentation should prefer a theme/config layer rather than scattered checks such as if Halloween then across unrelated views.

Do not create production event truth from a local date check in presentation code.

## 6. Creature rule

Halloween may supply:

- costume/presentation cosmetic;
- spectral material variant for an explicitly cosmetic layer;
- seasonal hero presentation around an existing creature;
- later, truly event-authored Species/Variant once GDS/TA event/content owners authorize it.

Halloween may not silently mutate:

- Species Rarity;
- Mutation identity;
- Trait identity;
- owned-instance provenance;
- capture odds.

## 7. Commerce candidates for later

High-fit:

- Haunted Vault theme;
- spectral display plinth;
- pumpkin/lantern Vault decor;
- creature cosmetic accessory/presentation skin;
- seasonal profile frame/nameplate;
- capture/reveal cosmetic effect;
- deterministic Halloween bundle;
- eligible avatar/UGC.

Avoid:

- paid event spawn multiplier;
- paid Legendary chance;
- paid capture odds;
- paid event credit;
- paid safety/access.

## 8. Promotional identity

PQL-10 launch imagery should show actual Golden content.

Suggested visual formula:

- one recognizable creature hero;
- Vault tech / EnergyGreen;
- Halloween moon/fog/lantern framing;
- HarvestOrange + SpectralViolet accents;
- actual in-game landmark/environment language.

Do not advertise a giant event boss, biome or mechanic that does not exist in the game.

## 9. If launch slips beyond Halloween

Do not rush unsafe release gates.

If the Halloween window is no longer appropriate:

- retain all permanent Golden work;
- keep seasonal assets reusable;
- disable Halloween layer;
- move the event pack to the next appropriate seasonal window;
- choose later PQL-7 representative event without rewriting the architecture.

The calendar never owns correctness.
