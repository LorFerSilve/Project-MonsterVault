# Golden Playable Vertical Slice Acceptance Matrix

> Status: OPEN — PRE-PRODUCTION
> Date: 2026-10-06
> This document defines evidence expected from the first production-quality visual pass.
> It does not mark any PQL gate complete by itself.

## 1. Golden reference path

The acceptance path is:

Spawn/Home or Starter arrival -> Starter vista -> Safe Outpost -> field encounter -> capture -> Secured/Collection payoff -> return Home -> enter Vault -> inspect displayed creature -> Energy Claim -> next aspiration -> Showcase.

The exact start ordering may follow current runtime travel/onboarding behavior, but evidence must cover the full representative loop.

## 2. Gate matrix

| Gate | Requirement | Evidence | Status |
| --- | --- | --- | --- |
| GS-01 Permanent Starter vista | Starter reads as authored environment with Halloween OFF | Studio screenshot + inspection notes | OPEN |
| GS-02 Halloween Starter vista | Same area reads intentionally seasonal with layer ON | matched screenshot | OPEN |
| GS-03 Route readability | Player can identify outpost/route without dev markers | Play observation | OPEN |
| GS-04 Safe Outpost | secure/recovery/travel functions wrapped by coherent production art | screenshot + functional test | OPEN |
| GS-05 Common creature | species/fixture-orb or current authored Common has production model/presentation | world + display screenshot | OPEN |
| GS-06 Legendary representative | species/stability-orb-dev has clearly stronger intrinsic reveal without fake rarity | reveal evidence | OPEN |
| GS-07 Capture arc | engage/buildup/outcome/Secured are visually distinct | video or ordered screenshots | OPEN |
| GS-08 Capture truth | presentation never invents success/rarity | regression + manual inspection | OPEN |
| GS-09 Home destination | Home/Vault reads as intentional aspirational destination | screenshot | OPEN |
| GS-10 Vault interior | display, machinery, Energy areas have hierarchy | screenshot | OPEN |
| GS-11 Existing Energy Core | integrated and material-correct, not accidentally replaced/degraded | before/after + Studio check | OPEN |
| GS-12 Display payoff | owned exact creature can be visually displayed without duplicate ownership semantics | Play evidence | OPEN |
| GS-13 Energy Claim | source-to-wallet/count-up/completion hero sequence | video/screenshots + authority check | OPEN |
| GS-14 Progression payoff | player can tell what changed and what to pursue next | UI evidence | OPEN |
| GS-15 Showcase | one read-only card is polished and still clearly Read Only | screenshot + mutation-negative test | OPEN |
| GS-16 UI system | HUD/cards/buttons/rarity/notifications visibly share one system | component evidence | OPEN |
| GS-17 Mobile | primary Golden path usable/readable at representative mobile viewport | screenshot/input check | OPEN |
| GS-18 Gamepad | primary actions/focus/close routes work | native/input evidence | OPEN |
| GS-19 Preferred text | increased platform text preference does not destroy core layout | screenshot | OPEN |
| GS-20 Reduced Motion | semantic capture/UI/reward feedback survives reduced motion | evidence | OPEN |
| GS-21 Halloween OFF | disabling seasonal layer leaves complete production-quality base | matched evidence | OPEN |
| GS-22 Seasonal isolation | Halloween disable does not break collision/routes/gameplay | functional regression | OPEN |
| GS-23 Performance | visual scene stays within working budgets or records measured justified exceptions | stats artifact | OPEN |
| GS-24 Source completeness | hero 3D assets have editable source + exports + mapping | manifest audit | OPEN |
| GS-25 Studio validation | no hero asset accepted from Blender-only evidence | Studio evidence | OPEN |
| GS-26 CI/regression | applicable existing automated suite remains green | CI | OPEN |

## 3. Required representative screenshots

Use stable names where practical:

- golden_01_starter_permanent.png
- golden_02_starter_halloween.png
- golden_03_safe_outpost.png
- golden_04_common_encounter.png
- golden_05_capture_buildup.png
- golden_06_capture_secured.png
- golden_07_legendary_reveal.png
- golden_08_home_exterior.png
- golden_09_vault_interior.png
- golden_10_creature_display.png
- golden_11_energy_claim.png
- golden_12_progression.png
- golden_13_showcase.png
- golden_14_mobile.png
- golden_15_reduced_motion.png

If tooling supports a short capture video, add one uninterrupted representative path recording.

Screenshots must come from actual Studio/client state, not external concept renders pretending to be gameplay.

## 4. Before/after requirement

At least these views should retain before/after evidence:

- Starter vista;
- Safe Outpost;
- Home/Vault;
- creature representation;
- capture UI;
- Vault/Collection UI.

This helps verify that complexity improved quality rather than only adding clutter.

## 5. Permanent vs seasonal matched pair

For the same Starter/Home camera:

1. capture Halloween ON;
2. disable seasonal layer;
3. capture Halloween OFF;
4. verify navigation, landmark and composition remain strong.

If OFF looks unfinished, the seasonal layer is masking missing production work and GS-21 fails.

## 6. Creature acceptance

For each production creature in the Golden set:

- silhouette readable at normal camera distance;
- expected Species identity unchanged;
- rarity presentation consistent with authored rarity;
- no accidental PBR/material loss in Studio;
- no clipping in idle/display pose;
- capture target remains readable;
- animation does not displace gameplay root incorrectly;
- reasonable geometry budget recorded.

Legendary additionally requires:

- layered reveal;
- label/shape/color redundancy;
- no fake odds/near-miss;
- effect degrades safely.

## 7. UI acceptance

Primary Golden screens must pass:

- safe insets;
- readable contrast;
- practical touch targets;
- gamepad focus;
- keyboard/mouse;
- no hover-only critical data;
- text-size adaptation;
- Reduced Motion;
- semantic Pending/OutcomeUnknown;
- notification priority.

Halloween styling may be toggled without changing control semantics.

## 8. Audio acceptance

Critical semantic events have non-audio equivalents.

Check:

- capture;
- Secured;
- Legendary reveal;
- Energy Claim;
- progression unlock;
- actionable warning.

Halloween ambience must remain mix-safe and optional through normal audio settings.

## 9. Performance evidence

Record at minimum:

- typical Starter scene;
- Halloween Starter scene;
- capture peak;
- Legendary reveal peak;
- Vault idle;
- Energy Claim peak.

Record:

- frame behavior;
- draw calls if available;
- triangle/render stats if available;
- obvious memory delta;
- notable exceptions.

Studio-only data is useful development evidence but does not replace future TA-14 real-client/device gates.

## 10. Regression invariants

Golden art/presentation must not change authority for:

- capture result;
- protected encounter lifetime;
- travel/recovery;
- hazards;
- Creature ownership;
- P2 finalization;
- Energy;
- production;
- assignments;
- progression;
- Party;
- Ping;
- Friendly Challenge;
- Showcase permissions.

If a visual integration exposes an existing bug, fix the smallest root cause and document it separately.

## 11. Placeholder policy

After the Golden slice, placeholders may still exist outside representative scope.

Within the representative path, the following are not acceptable:

- plain neon pads as final hero interactions;
- gray/unmapped imported meshes;
- developer ID text as primary user copy;
- large flat test plates as visible environment;
- raw diagnostic social/capture panels where that screen is part of the Golden path;
- missing creature model for the representative Common/Legendary.

## 12. Completion wording

Allowed after all applicable GS gates pass:

"Golden Playable Vertical Slice reference quality established for the representative Starter/Home path."

Not allowed unless later PQL gates truly pass:

- "all world art complete";
- "PQL-1 complete";
- "all creatures production-ready";
- "release-ready";
- "full scale validated".
