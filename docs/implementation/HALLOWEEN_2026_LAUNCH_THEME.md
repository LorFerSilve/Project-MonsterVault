# Halloween 2026 Launch Theme

> **Status:** OWNER-AUTHORIZED / ROADMAP-BOUND
> **Date:** 2026-10-05
> **Scope:** launch presentation + later seasonal event/live-ops/commercial integration
> **Release intent:** MonsterVault's first production release targets the Halloween 2026 season as its launch theme. The exact public release date remains subject to the normal implementation, PQL, scale, platform-policy and release gates.

## Purpose

Halloween 2026 is the first launch-season theme for MonsterVault. From this point forward, work on the Golden Playable Vertical Slice and later release-facing phases should make the game feel intentionally seasonal at launch without making the permanent MonsterVault experience depend on temporary Halloween content.

The design rule is:

**production-quality permanent MonsterVault base + removable/configurable Halloween seasonal layer**

The Halloween layer should amplify the game's existing creature-collection, rarity, Vault, discovery and sensory fantasy. It must not become a parallel gameplay architecture.

## Permanent base versus seasonal layer

Permanent world, gameplay and presentation must remain coherent with the seasonal layer disabled.

Halloween-specific content should be modularly authored/namespaced where practical, for example:

- seasonal environment props and decorations;
- seasonal lighting/atmosphere overrides or additive effects;
- themed ambience/SFX;
- temporary UI accents/banners;
- themed creature/cosmetic presentation;
- seasonal VFX;
- event-specific content bindings once IMP-11 event authority exists;
- seasonal offers/content once their IMP-13/14 owners exist.

Removing or disabling the Halloween layer must not break:

- traversal or safe routes;
- capture;
- travel/recovery;
- Vault/Collection;
- production/Energy;
- progression/mastery/access;
- Party/Ping/Challenge/Showcase;
- ordinary spawn populations;
- core onboarding.

No mandatory progression path may require seasonal content.

## Golden Playable Vertical Slice binding

The first production-quality Golden Slice should establish both:

1. the reusable permanent MonsterVault visual quality bar; and
2. the first Halloween 2026 presentation layer.

The Golden Slice should preferentially cover the Starter Region and Home/Vault with a coherent spooky-season treatment while preserving the permanent environment underneath.

Representative Halloween presentation may include:

- pumpkins, lanterns, candles, webs, graveyard/ruin accents and authored spooky props;
- autumn/dead foliage and environmental micro-animation;
- mist/fog, moonlit or eerie atmospheric treatment, restrained orange/purple/green accents and readable lighting;
- bats/embers/ghostly particles where performant;
- spooky ambient beds and location-specific stingers;
- Halloween accents for HUD, notifications, creature cards and Showcase without compromising readability/accessibility;
- themed Vault dressing and machinery accents;
- a high-quality seasonal hero prop/landmark;
- at least one representative spooky creature, cosmetic creature treatment or Legendary reveal asset suitable for the established creature/rarity pipeline;
- capture/reveal/collection sensory treatment that remains semantically honest.

The permanent Starter Region/Home/Vault must still look production-quality when these elements are disabled.

## IMP-11 event boundary

Visual Halloween dressing may begin before remaining IMP-11 event mechanics are complete.

Actual event authority remains owned by IMP-11/TA-10 and must not be faked through presentation code. The following wait for their proper event owners:

- authoritative EventOccurrence lifecycle;
- timed spawn modifiers;
- event contribution/objectives;
- collaboration/event rewards;
- persistent event cooldowns;
- cross-server event refresh hints;
- community/global event progress;
- event-limited reward finalization.

When the remaining IMP-11 event slices are implemented, **Halloween 2026 should be the first representative production event** if the release window remains applicable.

## Commerce binding

Halloween is a priority seasonal presentation opportunity for GDS-13 Commercial Strategy v3, but monetization must remain deterministic, clear and non-pay-to-win.

Once IMP-13 owns the necessary product/receipt flows, preferred Halloween commercial candidates include:

- deterministic seasonal cosmetic bundle;
- Vault theme/decorative style;
- creature presentation cosmetics;
- profile frame/nameplate/status presentation;
- capture/reveal cosmetic VFX or presentation variants;
- seasonal avatar/UGC items where platform-eligible;
- optional premium Seasonal Collection Pass content only through its approved deterministic track semantics.

Halloween monetization may not grant:

- rarity/luck;
- spawn odds;
- capture success;
- claim priority;
- mastery/access bypass;
- persistent production-rate advantage;
- event contribution credit;
- safety/consent authority;
- paid Daily Wheel spins.

## Live-ops binding

IMP-14 should eventually own production activation, scheduling, rollback, flags/config and analytics for seasonal launch content.

Before that owner is implemented, development may use explicit DEV/staging presentation toggles, but those are not production event truth.

Production launch should be able to:

- enable/disable seasonal presentation cleanly;
- start/end authoritative Halloween event content at real configured boundaries;
- recover correctly across server restart/rejoin;
- preserve permanent player value after the season ends;
- remove seasonal presentation without corrupting ordinary content;
- measure engagement, retention, conversion and player-regret/support signals without hidden player-specific gameplay rules.

## PQL bindings

### PQL-1 — World Art

The Golden Starter Region and Home/Vault establish the permanent art bar plus a removable Halloween layer. Seasonal dressing should improve composition rather than hide unfinished base geometry.

### PQL-2 — Creatures & Assets

Representative production creatures and hero assets should include a Halloween-compatible example. Intrinsic rarity remains distinct from temporary/cosmetic seasonal treatment.

### PQL-3 — UI/UX

Launch UI may carry seasonal accents, but navigation, hierarchy, accessibility and semantic state remain stable with the theme disabled.

### PQL-4 — Sensory Game Feel

Use Halloween ambience, reveal layers, environmental motion and seasonal stingers as a coherent extension of the permanent sensory language. Avoid sensory overload or deceptive rarity cues.

### PQL-7 — Live Events

Halloween 2026 is the preferred first representative production seasonal event once its IMP-11/14 dependencies exist.

### PQL-9 — Commerce Presentation

Seasonal products should feel native to the Halloween launch presentation while remaining clearly optional and deterministic.

### PQL-10 — Launch & Promotional Polish

Launch iconography, screenshots, thumbnails, key art, update banners and promotional scenes should intentionally communicate the Halloween release theme while representing actual in-game quality honestly.

## Launch priority

For the first release, prioritize in this order:

1. permanent Golden Slice visual quality;
2. removable Halloween world/Vault presentation layer;
3. Halloween creature/rarity/sensory showcase;
4. Halloween launch UI and promotional identity;
5. authoritative seasonal event mechanics when IMP-11 owners are ready;
6. deterministic seasonal commercial surfaces when IMP-13 is ready;
7. production live-ops scheduling/analytics when IMP-14 is ready.

A calendar target must never justify bypassing correctness, safety, persistence, receipt, platform-policy, accessibility or release gates.

## Post-season requirement

Halloween content must have a clean off-season state.

After the season:

- permanent player-owned legitimate rewards remain valid according to their owning contract;
- temporary world presentation can be disabled;
- ordinary world/spawn/progression remains intact;
- seasonal commercial offers can end without removing already-owned durable cosmetics;
- the reusable seasonal-content pattern becomes the basis for future events rather than being rewritten as a one-off system.
