# Golden Playable Vertical Slice Acceptance Matrix

> Status: IMPLEMENTED REPRESENTATIVE PASS — ACCEPTANCE STILL OPEN
> Date: 2026-10-06
> Native implementation/evidence: [Golden Slice evidence](GOLDEN_SLICE_EVIDENCE.md), [15-image gallery](evidence/golden/README.md).
> Physical controller menus, real increased platform text preference and reference-device performance remain open.
> It does not mark any PQL gate complete by itself.

## 1. Golden reference path

The acceptance path is:

Spawn/Home or Starter arrival -> Starter vista -> Safe Outpost -> field encounter -> capture -> Secured/Collection payoff -> return Home -> enter Vault -> inspect displayed creature -> Energy Claim -> next aspiration -> Showcase.

The exact start ordering may follow current runtime travel/onboarding behavior, but evidence must cover the full representative loop.

## 2. Gate matrix

| Gate | Requirement | Evidence | Status |
| --- | --- | --- | --- |
| GS-01 Permanent Starter vista | Starter reads as authored environment with Halloween OFF | golden_01, native geometry/material audit | PASS, representative Studio inspection |
| GS-02 Halloween Starter vista | Same area reads intentionally seasonal with layer ON | golden_02; matched actual toggle | PASS, representative |
| GS-03 Route readability | Player can identify outpost/route without dev markers | native traversal + actual controller return to safety | PASS, observed representative route |
| GS-04 Safe Outpost | secure/recovery/travel functions wrapped by coherent production art | golden_03, actual Secured and ordinary Home travel | PASS |
| GS-05 Common creature | species/fixture-orb or current authored Common has production model/presentation | golden_04/10; Mossbud mapping | PASS, representative |
| GS-06 Legendary representative | species/stability-orb-dev has clearly stronger intrinsic reveal without fake rarity | golden_07, protected_final_native, Legendary DEV peak stats | PASS, explicitly isolated DEV opportunity |
| GS-07 Capture arc | engage/buildup/outcome/Secured are visually distinct | golden_05/06; custody/failure extras; actual lifecycle/peak | PASS, ordered state evidence; no uninterrupted video |
| GS-08 Capture truth | presentation never invents success/rarity | receipt/projection negative tests; actual Failed then Secured | PASS |
| GS-09 Home destination | Home/Vault reads as intentional aspirational destination | golden_08; permanent/Halloween Home pair | PASS, representative Studio inspection |
| GS-10 Vault interior | display, machinery, Energy areas have hierarchy | golden_09 | PASS, representative |
| GS-11 Existing Energy Core | integrated and material-correct, not accidentally replaced/degraded | preserved original + exact mapping/native inspection; golden_09/11 | PASS, reused functional role; no original Home before screenshot |
| GS-12 Display payoff | owned exact creature can be visually displayed without duplicate ownership semantics | golden_10; display_paging_native; AD-269 fences | PASS |
| GS-13 Energy Claim | source-to-wallet/count-up/completion hero sequence | golden_11, matching +8/+1253 receipts; bounded peak | PASS, ordinary free claim |
| GS-14 Progression payoff | player can tell what changed and what to pursue next | golden_12; actual capacity upgrade/next quote | PASS, capacity representative; broader mastery polish open |
| GS-15 Showcase | one read-only card is polished and still clearly Read Only | golden_13/14 owner preview + 29 distinct native permission/visitor cases | PASS, representative; two real clients remain separate |
| GS-16 UI system | HUD/cards/buttons/rarity/notifications visibly share one system | GoldenTheme/tokens + native screenshots | PASS, foundation; broader rollout open |
| GS-17 Mobile | primary Golden path usable/readable at representative mobile viewport | A06 705x338/359x718; native Touch/Activated, scrolling cards | PASS, emulator/input evidence; physical device gate open |
| GS-18 Gamepad | primary actions/focus/close routes work | human Gamepad1 capture/secure passed; touchpad entry failed; ButtonY synthetic fix | PARTIAL — physical △/menu selection/○ retest required |
| GS-19 Preferred text | increased platform text preference does not destroy core layout | 1.5x declared font stress and TextFits pass; platform stayed Medium | OPEN — actual increased platform preference not tested |
| GS-20 Reduced Motion | semantic capture/UI/reward feedback survives reduced motion | golden_15; native +311 claim with zero transient parts/audio muted | PASS, manual reduction; platform binding covered by tests |
| GS-21 Halloween OFF | disabling seasonal layer leaves complete production-quality base | matched Starter/Home ON/OFF; restored Lighting/Atmosphere | PASS, representative composition |
| GS-22 Seasonal isolation | Halloween disable does not break collision/routes/gameplay | zero seasonal colliders/query/tags/scripts; native OFF disposal + regressions | PASS |
| GS-23 Performance | visual scene stays within working budgets or records measured justified exceptions | six native views; rendering headroom; 22-24ms fresh p95 and 101ms long-session exception recorded | PARTIAL — Studio measurement done, real-device/exception investigation open |
| GS-24 Source completeness | hero 3D assets have editable source + exports + mapping | 14 new sources/13 runtime; GLB/FBX/central IDs; exact native pack roundtrip | PASS |
| GS-25 Studio validation | no hero asset accepted from Blender-only evidence | 15 native screenshots, import/mapping/scale/collision/Play audits | PASS for current assets; historical before coverage incomplete |
| GS-26 CI/regression | applicable existing automated suite remains green | 339/339 fast, 28/28 Python, static/build locally and normal remote CI on validated head; see ci_validated_native_package.json | PASS for recorded implementation; each later head retains normal CI gate |

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
