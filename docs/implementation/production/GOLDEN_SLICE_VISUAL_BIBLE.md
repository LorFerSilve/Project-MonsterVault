# Golden Slice Visual Bible

> Status: BASELINE APPLIED TO THE REPRESENTATIVE STUDIO SLICE; BROADER ROLLOUT OPEN
> Date: 2026-10-06
> Scope: first Golden Playable Vertical Slice and reusable production-quality visual language
> Authority: subordinate to the approved GDS, TA contracts, implementation roadmap and Halloween 2026 launch-theme brief

The applied Starter/Home implementation and reusable material/asset/UI/sensory seams are documented in [Golden Slice evidence](GOLDEN_SLICE_EVIDENCE.md). The permanent pine/rock/field-station and ribbed Vault kit now exists in Studio; the removable spectral-harvest layer is inspected ON/OFF. This application does not certify every PQL screen, biome or device.

The [CC0 library refresh](evidence/refresh/README.md) extends this direction with
leafy canopy/understory and textured modular foundry bays. Pack assets retain the
central palette, silhouette hierarchy and route negative space. Surface detail
uses shared <=512px color/alpha atlases where native material alone loses foliage
silhouettes or authored trim detail; geometry and lighting carry the composition.

## 1. Product-facing visual thesis

MonsterVault should read as a **stylized arcane-tech creature expedition**.

The permanent visual identity combines:

- a safe, engineered Vault civilization built from dark metal, clean panels, readable energy systems and purposeful machinery;
- wild authored biomes where creatures feel discovered rather than spawned into test geometry;
- luminous Energy technology as a consistent functional language;
- collectible creatures with strong silhouettes and readable intrinsic rarity;
- restrained premium presentation rather than photorealism or visual noise.

The Halloween 2026 release treatment is a **spectral harvest layer** over this identity, not a second art style.

The visual contrast should be immediately readable:

**Vault / Home = engineered, safe, controlled, aspirational**  
**Field / Starter Region = organic, exploratory, slightly mysterious**  
**Halloween layer = spectral, autumnal, eerie but playful and age-appropriate**

Target audience readability remains more important than realism.

## 2. Core visual pillars

### V-01 — Silhouette first

Important creatures, machines, landmarks, interactables and UI cards must remain recognizable at a glance.

Do not depend on tiny surface detail to establish identity.

### V-02 — Energy has one language

EnergyGreen is a permanent functional signal for MonsterVault technology.

It may communicate:

- powered machinery;
- secure-point technology;
- production flow;
- Energy transfer;
- capture containment;
- valid tech interaction accents.

Halloween may add orange/violet/spectral treatment, but it must not redefine EnergyGreen as a seasonal color.

### V-03 — Rarity is prestigious, not casino-like

Intrinsic rarity uses increasing layers of framing, shape, light, audio and motion.

Higher rarity may feel more exceptional, but avoid:

- slot-machine visual grammar;
- fake near-miss effects;
- excessive flashing;
- misleading paid-cosmetic rarity treatment.

### V-04 — Permanent base before seasonal dressing

Every Golden Slice screenshot must still look intentional with the Halloween layer disabled.

Halloween props may enrich composition; they may not conceal blockout geometry.

### V-05 — Readable on a phone

Primary visual decisions are judged at mobile scale first.

Tiny text, low-contrast detail, hover-only meaning and dense desktop dashboards are not production language.

### V-06 — Premium through consistency

A smaller number of coherent, reusable kits is preferred over many unrelated one-off assets.

A polished repeated kit beats a visually inconsistent asset catalogue.

## 3. Permanent palette

Existing repository-native material groups remain authoritative where used:

| Token / group | RGB | Role |
| --- | --- | --- |
| DarkMetal | 50, 63, 76 | structural tech, frames, machinery |
| SecondaryMetal | 153, 172, 187 | trim, moving mechanical detail, readable edges |
| PanelPlastic | 19, 25, 33 | dark UI-adjacent panels, machine shells |
| EnergyGreen | 76, 255, 110 | powered tech / Energy / containment |
| FixtureCreature reference | 77, 205, 255 | current DEV creature reference only |

Recommended permanent environment support palette:

| Token | RGB | Role |
| --- | --- | --- |
| ForestDeep | 31, 66, 49 | vegetation shadow mass |
| Moss | 65, 104, 72 | mid vegetation |
| StoneCool | 76, 86, 96 | rock / ruin base |
| SoilDark | 65, 53, 45 | earth / path contrast |
| FogNeutral | 155, 166, 176 | atmospheric depth, used sparingly |
| WarmUtility | 235, 187, 98 | non-Energy practical lamps / safe warmth |

These are art-direction targets, not a requirement to hard-code every asset to these exact values.

## 4. Halloween 2026 seasonal palette

Seasonal colors are additive and removable:

| Token | RGB | Role |
| --- | --- | --- |
| HarvestOrange | 255, 138, 52 | pumpkins, seasonal calls-to-attention |
| CandleGold | 255, 211, 122 | candles, lantern warmth |
| SpectralViolet | 167, 107, 255 | supernatural accents and event identity |
| NightPlum | 42, 23, 56 | seasonal shadow/support |
| MoonFog | 170, 178, 190 | fog and moonlit atmospheric support |

Rules:

- EnergyGreen remains distinct from SpectralViolet.
- Seasonal orange is not used as a universal danger color.
- Gameplay danger retains text/icon/shape redundancy.
- Seasonal cosmetics cannot visually impersonate intrinsic rarity.

## 5. Shape language

### Vault and machinery

Use:

- chamfered rectangular masses;
- protective cages / frames;
- exposed but organized energy conduits;
- inset panels;
- readable mechanical joints;
- circular energy containment elements;
- repeated 45-degree cuts and bevels;
- floor-center grounded silhouettes.

Avoid:

- random greeble noise;
- ultra-thin fragile detail;
- realistic military weapon language;
- arbitrary sci-fi panels with no functional read.

### Starter Region

Use:

- broad, navigable ground shapes;
- large rock / foliage clusters;
- readable path edges;
- landmark silhouettes visible above local clutter;
- safe-outpost geometry that looks constructed and intentional;
- terrain height changes that frame routes rather than impede them.

Avoid:

- flat empty test plates;
- uniformly scattered props;
- foliage walls that obscure interaction;
- tiny decorative clutter on primary traversal lines.

### Creatures

Use:

- one dominant silhouette idea per Species;
- oversized readable personality feature;
- 2–4 major body masses;
- secondary accents only after silhouette works;
- clear eye/head/front orientation where relevant;
- animation-friendly topology for creatures intended to move.

Avoid:

- near-identical creatures distinguished only by color;
- complexity that disappears at normal camera distance;
- permanent full-body neon.

## 6. Intrinsic rarity language

Repository GDS rarity order remains:

Common -> Uncommon -> Rare -> Epic -> Legendary.

Initial production presentation tokens:

| Rarity | Color target | Shape cue | Sensory escalation |
| --- | --- | --- | --- |
| Common | 181, 192, 200 | simple circle / single notch | clean base cue |
| Uncommon | 94, 213, 154 | paired notch / leaf-like split | subtle added layer |
| Rare | 88, 175, 255 | diamond | added shimmer / harmonic |
| Epic | 180, 119, 255 | four-point star | stronger reveal layer |
| Legendary | 255, 184, 77 | sunburst / crown-like ring | hero reveal and layered audio |

Critical rules:

- Always show the rarity label in text where the player must make a decision.
- Color is never the only rarity channel.
- Mutation presentation is separate from Species Rarity.
- Traits are not automatically prestige visuals.
- Seasonal cosmetics cannot reuse the full intrinsic rarity frame treatment.
- Current main has authored Common Species and one Legendary DEV Species; there is no authored Rare/Epic Species on current main. Do not silently relabel content to satisfy a visual demo.

## 7. Mutation and variant presentation

Mutation identity must be legible without becoming a second rarity ladder.

Preferred order:

1. preserve base Species silhouette;
2. add one obvious authored variant feature;
3. add supporting material/color/VFX treatment;
4. show explicit Mutation label in Collection/Showcase UI.

For Compound Variants, both Mutations must remain understandable. Do not create a generic rainbow effect that destroys identity.

## 8. World composition quality bar

The Golden Starter Region should contain:

- one strong spawn vista;
- one obvious route toward the first meaningful objective;
- one recognizable safe-outpost cluster;
- one encounter space with visual breathing room;
- one secondary landmark that rewards looking around;
- foreground / midground / background separation;
- environmental framing around the current functional anchors.

Use the current authored coordinates and runtime tags as gameplay constraints. Art may wrap and frame those anchors but must not casually move contract-critical parts without validating WorldDefinitions and Studio behavior.

The Home/Vault must visually read as a destination from the Starter route.

## 9. Vault art direction

The Vault is the aspirational heart of MonsterVault.

It should communicate:

- safety;
- ownership;
- collection pride;
- productive machinery;
- progression;
- future customization.

Minimum visual hierarchy:

1. entry / arrival;
2. creature display zone;
3. Energy Core / production machinery;
4. claim / interaction focal point;
5. clear exit / travel relationship.

Machines should have readable idle states and activation states without constant spectacle.

The existing Energy Core design/material mapping is a reference asset and should be integrated, not casually replaced.

## 10. Lighting and atmosphere

Permanent Starter baseline:

- readable daylight/twilight contrast;
- natural depth through atmosphere, not heavy fog walls;
- EnergyGreen accents visible but not blown out;
- shadows that support terrain readability;
- safe-outpost warmer than the wild field.

Halloween overlay:

- slightly cooler/moonlit ambient balance;
- localized CandleGold / HarvestOrange warmth;
- SpectralViolet as supernatural accent;
- additional low fog or wisps only where traversal remains clear;
- no full-screen purple/orange grade that destroys permanent palette.

Bloom is an accent, not a substitute for lighting.

## 11. VFX and motion language

Motion timing should feel responsive and slightly mechanical.

Initial target ranges:

- button press: 80–140 ms;
- small UI state change: 120–220 ms;
- panel transition: 180–320 ms;
- reward lock-in: 300–700 ms;
- rare/Legendary hero reveal: 0.8–2.0 s, skippable/non-blocking where appropriate.

Reduced Motion substitutes:

- positional motion -> fade/snap;
- shake -> static emphasis;
- looping decorative motion -> reduced/static state;
- large zoom -> framing fade.

VFX principles:

- direction communicates cause;
- Energy travels from source to destination;
- capture effects converge on the creature/containment point;
- rarity adds layers to a shared semantic effect;
- Halloween adds seasonal layers without changing outcome truth.

## 12. Audio identity

Permanent audio families:

- Vault metal/mechanical;
- Energy/electrical;
- vegetation/earth;
- creature personality;
- UI tactile;
- rarity reveal.

Energy Claim should have a recognizable source -> transfer -> count-up -> completion structure.

Halloween overlay may add:

- distant wind;
- leaf movement;
- candle/lantern detail;
- subtle spectral tones;
- occasional bats/creaks/stingers.

Avoid constant horror drones. The target audience should read the season as spooky-fun, not oppressive horror.

## 13. Camera language

Default gameplay remains third-person and player-controlled.

Temporary presentation may use:

- short target framing;
- mild FOV emphasis;
- bounded reveal framing;
- Showcase / Photo presentation.

No camera treatment may determine gameplay eligibility.

Reduced Motion must disable non-essential shake and aggressive zoom.

## 14. UI relationship

The full UI production rules live in GOLDEN_SLICE_UI_UX_SYSTEM.md.

Visual summary:

- dark neutral panels;
- bright high-contrast text;
- EnergyGreen only for tech/positive powered state;
- rarity frames use rarity tokens;
- destructive/error states use their own semantic treatment;
- Halloween appears through decorative border motifs, banner accents and optional background art, not by recoloring every semantic control.

## 15. Golden Slice visual path

The production reference path is:

Spawn -> Starter vista -> safe outpost -> encounter -> capture -> Secured feedback -> return Home -> Vault entry -> displayed creature -> Energy Claim -> progression/next aspiration -> optional Showcase.

Each transition should visibly answer:

- Where am I?
- What matters now?
- What changed?
- What is persistent?
- What should I want to do next?

## 16. Explicit no-go list

Do not:

- make the entire world permanently dark for Halloween;
- use full-body Neon for every rare object;
- make rarity depend only on color;
- use visual noise to compensate for weak shapes;
- create event-only duplicate gameplay systems;
- use unlicensed/random Toolbox visual packs as the production identity;
- turn the Golden Slice into a full-game art rollout;
- fake server outcomes with presentation;
- claim production quality without Studio visual evidence.

## 17. Reuse rule

The Golden Slice is successful only if its language can be repeated.

Every hero decision should answer:

- Can later biomes reuse this kit or rule?
- Can another creature use this rarity language?
- Can Halloween be disabled without visual collapse?
- Can future seasons replace only the seasonal layer?
- Can UI reuse the same tokens rather than restyling per screen?

If not, the design is probably too one-off for the Golden baseline.
