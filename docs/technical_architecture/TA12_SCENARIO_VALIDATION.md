# TA-12 Scenario Validation

> **Phase:** TA-12 — Client Presentation, UI State, Input, Camera, Audio, and Accessibility  
> **Status:** PASS  
> **Scenario count:** 300 / 300 PASS

TA-12 validation covers client/server authority, projection revisions, UI layering, input contexts, device switching, focus/modal safety, confirmations, safe areas, accessibility preferences, notification behavior, virtualization, reconnect, camera/motion, audio/captions, localization, platform safety, commerce and performance/security boundaries.

## Client authority and state partition

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 1 | client opens Collection | local panel state only | PASS |
| 2 | client changes sort | presentation-only reorder | PASS |
| 3 | client changes filter | presentation-only filter | PASS |
| 4 | client highlights creature | no ownership mutation | PASS |
| 5 | client displays Energy | value from server projection | PASS |
| 6 | client locally edits Energy widget | next projection restores truth; no server effect | PASS |
| 7 | client caches owned creature | cache disposable | PASS |
| 8 | client destroys local creature projection | server ownership unchanged | PASS |
| 9 | server marks profile not Ready | irreversible UI disabled | PASS |
| 10 | Protected Load Failure arrives | Critical Trust layer takes priority | PASS |
| 11 | client preference changes contrast | presentation only | PASS |
| 12 | client preference changes sensitivity | input presentation/control only | PASS |
| 13 | client sends semantic target ID | server still validates | PASS |
| 14 | display name changes | semantic ID binding remains | PASS |
| 15 | UI component requests DataStore directly | architecture violation | PASS |

## Projection revisions and resynchronization

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 16 | newer projection arrives | apply | PASS |
| 17 | older projection arrives later | discard stale | PASS |
| 18 | duplicate revision arrives | idempotent | PASS |
| 19 | domain update requires missing base | request/resync snapshot | PASS |
| 20 | reconnect begins | discard stale session assumptions | PASS |
| 21 | fresh snapshot arrives after reconnect | rebuild views | PASS |
| 22 | CreatureInstanceId persists but card instance recycled | semantic identity preserved | PASS |
| 23 | runtime entity revision changes | stale prompt/action rejected locally/server | PASS |
| 24 | EventOccurrence phase jumps forward after reconnect | render current phase | PASS |
| 25 | trade revision changes | clear previous Ready/confirmation presentation | PASS |
| 26 | purchase state moves Pending to Finalized | render authoritative transition | PASS |
| 27 | projection stream temporarily pauses | do not invent success | PASS |
| 28 | server removal projection arrives | remove semantic item safely | PASS |
| 29 | out-of-order notification and state arrive | persistent state wins | PASS |
| 30 | client misses low-priority transient projection | no value corruption | PASS |

## UI layers and priority arbitration

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 31 | ordinary exploration | World HUD visible | PASS |
| 32 | Capture Attempt starts | committed layer dominates | PASS |
| 33 | Transport Custody active | custody state remains prominent | PASS |
| 34 | Protected Load Failure during Toast | critical layer suppresses Toast | PASS |
| 35 | trade final review active | shop prompt suppressed | PASS |
| 36 | event timer during capture | visible without stealing committed focus | PASS |
| 37 | social Ping during Level-2 confirmation | queue/suppress | PASS |
| 38 | commercial Toast during Recovery | delay/drop if stale | PASS |
| 39 | critical trust state active | no lower modal may cover | PASS |
| 40 | progression notice after critical clears | show if still relevant | PASS |
| 41 | multiple low-priority Toasts | aggregate/queue | PASS |
| 42 | critical state ends | restore appropriate lower presentation | PASS |
| 43 | platform menu opens | platform UI dominates interaction | PASS |
| 44 | shop panel already open when capture commits | panel loses conflicting input/focus | PASS |
| 45 | priority changes | presentation only; server obligation unchanged | PASS |

## Semantic InputAction baseline

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 46 | PrimaryInteract on keyboard | same semantic action | PASS |
| 47 | PrimaryInteract on touch | same semantic action | PASS |
| 48 | PrimaryInteract on gamepad | same semantic action | PASS |
| 49 | Back on all inputs | same safe navigation meaning | PASS |
| 50 | raw key handler bypasses action layer | architecture violation | PASS |
| 51 | InputAction has multiple bindings | PreferredBinding chooses current display binding | PASS |
| 52 | reserved Roblox input | not overridden | PASS |
| 53 | core action exists only as right-click | prohibited | PASS |
| 54 | core action exists only as hover | prohibited | PASS |
| 55 | core action exists only as drag | prohibited | PASS |
| 56 | keyboard shortcut exists | explicit UI control still exists | PASS |
| 57 | beta InputActionLabel unavailable | custom glyph resolver still works | PASS |
| 58 | ContextActionService used as parallel authority | prohibited | PASS |
| 59 | compatibility adapter needed | feeds same semantic action interface | PASS |
| 60 | semantic action fires | does not imply server authorization | PASS |

## Input context arbitration

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 61 | normal exploration | WorldContext active | PASS |
| 62 | panel opens | PanelNavigation enabled and conflicting world inputs restricted | PASS |
| 63 | modal opens | ModalContext sinks world confirm input | PASS |
| 64 | same press opens modal | cannot also trigger world action | PASS |
| 65 | Capture Attempt begins | CommittedGameplayContext activates | PASS |
| 66 | Protected Load Failure | SystemBlockedContext limits to safe actions | PASS |
| 67 | Roblox menu opens | MonsterVault gameplay contexts suspended | PASS |
| 68 | Roblox menu closes | restore current safe context | PASS |
| 69 | modal closes into capture | restore CommittedGameplayContext | PASS |
| 70 | panel closes into world | restore WorldContext | PASS |
| 71 | two contexts bind same input | priority/sink deterministic | PASS |
| 72 | stale context owner destroyed | context removed | PASS |
| 73 | device changes | context set unchanged semantically | PASS |
| 74 | system blocked state clears | recompute from current authoritative state | PASS |
| 75 | context local bug attempts Release | server still rejects unauthorized command | PASS |

## Device switching and glyphs

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 76 | keyboard to gamepad mid-panel | glyphs update; panel stays open | PASS |
| 77 | gamepad to touch mid-trade review | review revision preserved | PASS |
| 78 | touch to keyboard during Pending purchase | Pending preserved | PASS |
| 79 | PreferredBinding changes | prompt glyph updates | PASS |
| 80 | glyph asset missing | textual binding fallback | PASS |
| 81 | unknown binding type | semantic label remains | PASS |
| 82 | gamepad connected but mouse moved | preferred binding follows current input policy | PASS |
| 83 | device switch during Level-2 confirmation | confirmation remains unconfirmed | PASS |
| 84 | device switch during camera assist | camera owner unchanged | PASS |
| 85 | device switch during collection filter | filter preserved | PASS |
| 86 | touch-only prompt label | still shows semantic action text | PASS |
| 87 | gamepad glyph alone without label | prohibited for critical prompt | PASS |
| 88 | keyboard shortcut label localized | action semantics unchanged | PASS |
| 89 | multiple gamepads | navigation gamepad behavior remains compatible | PASS |
| 90 | input family change | no gameplay reward/state mutation | PASS |

## Active Context prompt

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 91 | valid nearby creature context | show Capture/Inspect semantics | PASS |
| 92 | context target changes by GDS policy | prompt updates once policy changes | PASS |
| 93 | two nearby candidates jitter | prompt does not flicker independently of Active Context | PASS |
| 94 | target streams out locally | hide/degrade anchor safely | PASS |
| 95 | server entity still exists while streamed out | do not treat as destroyed | PASS |
| 96 | visible prompt target revision stale | command revalidated/rejected | PASS |
| 97 | capacity becomes full | show actionable reason | PASS |
| 98 | creature becomes claimed | show Already claimed/reject | PASS |
| 99 | event ends | prompt invalidates with reason | PASS |
| 100 | travel requires mastery | show requirement | PASS |
| 101 | glyph changes | semantic action label unchanged | PASS |
| 102 | prompt hidden | does not alter server interaction eligibility | PASS |
| 103 | prompt world anchor missing | fallback screen/context presentation | PASS |
| 104 | arbitrary Workspace Instance selected | not authority | PASS |
| 105 | client forges context target | server validation rejects | PASS |

## Modal and gamepad focus

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 106 | modal opens with gamepad | deterministic initial focus | PASS |
| 107 | modal closes | previous valid focus restored | PASS |
| 108 | previous control removed | fallback focus selected | PASS |
| 109 | virtualized focused card recycled | focus restored by semantic key | PASS |
| 110 | Level-2 confirmation opens | confirmation owns focus | PASS |
| 111 | nested modal cancels | returns to parent safe focus | PASS |
| 112 | Back pressed | never maps to destructive confirm | PASS |
| 113 | gamepad directional navigation ambiguous | explicit NextSelection links | PASS |
| 114 | disabled control selected | focus moves to valid target | PASS |
| 115 | focus falls nil unexpectedly | Focus Manager repairs/fallbacks | PASS |
| 116 | mouse user opens modal | no requirement for gamepad selection visual | PASS |
| 117 | switch to gamepad | valid SelectedObject established | PASS |
| 118 | CoreGui menu opens | MonsterVault selection suspended/preserved safely | PASS |
| 119 | all controls unreachable by d-pad | test failure | PASS |
| 120 | focus indicator uses color only | prohibited | PASS |

## Confirmation severity

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 121 | sort change | Level 0 immediate | PASS |
| 122 | Vault upgrade purchase | Level 1 confirmation | PASS |
| 123 | Release creature | Level 2 strong confirmation | PASS |
| 124 | unlock Protected Variant | Level 2 | PASS |
| 125 | final trade confirmation | Level 2 | PASS |
| 126 | Protected Load Failure | Level 3 blocking state | PASS |
| 127 | confirmation identifies exact CreatureInstance | required | PASS |
| 128 | confirmation shows persistence consequence | required | PASS |
| 129 | target revision changes while modal open | invalidate confirmation | PASS |
| 130 | trade revision changes | return to review | PASS |
| 131 | server quote expires | confirm disabled/requote | PASS |
| 132 | Back on confirmation | cancel only | PASS |
| 133 | double confirm input | server idempotency/validation prevents duplicate | PASS |
| 134 | local confirm animation finishes | not success until authoritative | PASS |
| 135 | commercial Buy appears on generic Close control | prohibited | PASS |

## Safe areas and responsive layout

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 136 | phone notch | critical UI inside CoreUISafeInsets | PASS |
| 137 | mobile top bar | action controls avoid overlap | PASS |
| 138 | default thumbstick zone | HUD avoids essential overlap | PASS |
| 139 | jump/action corner | no critical text underneath | PASS |
| 140 | wide desktop | layout expands/reflows | PASS |
| 141 | narrow phone | panels collapse/scroll | PASS |
| 142 | tablet | touch targets remain usable | PASS |
| 143 | TV overscan | critical content inside TV-safe region | PASS |
| 144 | rotating/resizing viewport | layout recomputes | PASS |
| 145 | decorative edge art | may use DeviceSafeInsets | PASS |
| 146 | critical modal uses DeviceSafeInsets into Core UI | prohibited | PASS |
| 147 | long panel content | scroll rather than unreadable shrink | PASS |
| 148 | small viewport | world visibility retained | PASS |
| 149 | safe inset changes at runtime | layout updates | PASS |
| 150 | device-name-specific hardcoded layout only | prohibited | PASS |

## Text size, contrast and accessibility

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 151 | PreferredTextSize Medium | baseline readable layout | PASS |
| 152 | PreferredTextSize Largest | critical actions remain visible | PASS |
| 153 | PreferredTextSize changes live | layout reflows | PASS |
| 154 | critical label uses TextScaled only | architecture test rejects unless preference compensated | PASS |
| 155 | AutomaticSize text grows | container reflows | PASS |
| 156 | wrapped confirmation text | buttons remain reachable | PASS |
| 157 | PreferredTransparency requests opacity | background becomes at least as readable | PASS |
| 158 | MonsterVault contrast mode on | may strengthen opacity/outline | PASS |
| 159 | MonsterVault contrast mode off | cannot weaken platform preference | PASS |
| 160 | Roblox ReducedMotion enabled | effective Reduced Motion true | PASS |
| 161 | MonsterVault Reduced Motion enabled | effective Reduced Motion true | PASS |
| 162 | MonsterVault setting false but Roblox true | motion stays reduced | PASS |
| 163 | camera shake disabled | shake remains off | PASS |
| 164 | critical state encoded only green/red | prohibited | PASS |
| 165 | rarity encoded only color | prohibited | PASS |

## Notifications and rejection feedback

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 166 | informational Toast during world play | show normally | PASS |
| 167 | same Toast repeats rapidly | coalesce | PASS |
| 168 | Toast during trade final review | queue | PASS |
| 169 | queued Toast becomes stale | drop | PASS |
| 170 | critical unresolved purchase | persistent notice, not Toast only | PASS |
| 171 | Overflow unresolved | persistent accessible state | PASS |
| 172 | player mutes Social Pings | social Ping presentation suppressed | PASS |
| 173 | critical safety alert with low notification setting | still shown | PASS |
| 174 | server rejects locked creature trade | show actionable locked reason | PASS |
| 175 | server rejects changed trade revision | show review-again reason | PASS |
| 176 | technical stack trace exists | not required player-facing | PASS |
| 177 | safe retry available | offer retry | PASS |
| 178 | unsafe duplicate retry | do not offer blind retry | PASS |
| 179 | rejected purchase | do not animate owned entitlement | PASS |
| 180 | Toast expires | required action remains accessible elsewhere | PASS |

## Collection, Vault and list virtualization

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 181 | 1000 creature items | bounded/virtualized rendering | PASS |
| 182 | card recycled to new creature | CreatureInstanceId binding updated | PASS |
| 183 | selected card recycled | semantic selection preserved or safely cleared | PASS |
| 184 | gamepad moves through virtualized list | focus graph remains complete | PASS |
| 185 | filter hides focused item | focus chooses deterministic fallback | PASS |
| 186 | sort changes | exact-instance actions still target correct ID | PASS |
| 187 | Species overview card | does not masquerade as exact instance | PASS |
| 188 | Release action from Species aggregate | requires exact-instance selection | PASS |
| 189 | Overflow-Held creature | state visually explicit | PASS |
| 190 | Creature Lock active | visible in high-value action | PASS |
| 191 | Production assignment | targets exact CreatureInstanceId | PASS |
| 192 | large list mutation one item | avoid full rerender when possible | PASS |
| 193 | missing cosmetic thumbnail | text/identity remains usable | PASS |
| 194 | asset load failure | does not hide action facts | PASS |
| 195 | UI object reference sent as creature identity | prohibited | PASS |

## Authoritative timers, load and reconnect

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 196 | event countdown | derived from authoritative deadline | PASS |
| 197 | client device clock changes | no semantic effect | PASS |
| 198 | countdown reaches zero before server phase update | clamp/wait; no new authority | PASS |
| 199 | server hop during Event Cooldown | render persisted authoritative deadline | PASS |
| 200 | trade cooldown reconnect | reconstruct from server state | PASS |
| 201 | profile readiness delayed | show not-ready/loading | PASS |
| 202 | Protected Load Failure | Level-3 trust UI | PASS |
| 203 | reconnect after finalized purchase | show owned/current state, no duplicate grant celebration | PASS |
| 204 | reconnect after event reward | no duplicate-reward implication | PASS |
| 205 | Purchase Pending survives panel close | persistent reconciliation state | PASS |
| 206 | unresolved trade survives reconnect | blocking/reconciliation presentation | PASS |
| 207 | capacity reconciliation creates Overflow | explain ownership preserved | PASS |
| 208 | old session Toast queue survives reconnect | discard disposable stale queue | PASS |
| 209 | new session snapshot received | rebuild state | PASS |
| 210 | local timer stale after snapshot | replace with authoritative boundary | PASS |

## Camera and motion

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 211 | ordinary exploration | Roblox Custom camera baseline | PASS |
| 212 | onboarding cue requests camera | bounded controller ownership | PASS |
| 213 | player moves camera during assist | assist yields/cancels as designed | PASS |
| 214 | capture framing starts | single camera owner | PASS |
| 215 | event framing competes with capture | priority arbiter chooses one | PASS |
| 216 | modal preview closes | camera restores | PASS |
| 217 | character respawns during Scriptable camera | restore/rebind safely | PASS |
| 218 | camera owner errors | finally-style release/restoration | PASS |
| 219 | Reduced Motion on | large pan/zoom replaced | PASS |
| 220 | Reduced Motion on | non-essential shake disabled | PASS |
| 221 | shake setting off only | shake disabled while other motion may remain | PASS |
| 222 | critical VFX obscures hazard | prohibited | PASS |
| 223 | full-screen flash required to understand success | prohibited | PASS |
| 224 | server sends camera target ID | client resolves presentation only | PASS |
| 225 | camera CFrame manipulated | never changes server eligibility | PASS |

## Audio and captions

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 226 | capture success sound plays | visual/text result also exists | PASS |
| 227 | capture sound fails asset load | semantic result still visible | PASS |
| 228 | event start audio cue | caption/visual equivalent available | PASS |
| 229 | hazard pulse sound actionable | caption/visual cue | PASS |
| 230 | instructional dialogue | subtitle/text equivalent | PASS |
| 231 | music volume zero | gameplay remains understandable | PASS |
| 232 | effects volume zero | gameplay remains understandable | PASS |
| 233 | voice/dialogue zero | instruction text remains | PASS |
| 234 | UI notification volume zero | critical notice remains visual | PASS |
| 235 | caption preference on | semantic captions display | PASS |
| 236 | caption text localized | uses localization key | PASS |
| 237 | audio asset name exposed as caption | not required; semantic label used | PASS |
| 238 | SoundGroup unavailable/legacy | semantic Audio Mixer contract unaffected | PASS |
| 239 | platform master volume changed | MonsterVault does not override | PASS |
| 240 | audio category setting saved | presentation preference only | PASS |

## Presentation preference persistence

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 241 | player changes camera shake | apply immediately | PASS |
| 242 | preference save succeeds | restore next session | PASS |
| 243 | preference save fails | current session remains safe; gameplay continues | PASS |
| 244 | profile not Ready | apply platform prefs + safe defaults | PASS |
| 245 | persisted prefs load later | reconcile presentation only | PASS |
| 246 | malformed sensitivity value | validate/clamp/reject | PASS |
| 247 | preference payload attempts Energy field | ignore/reject | PASS |
| 248 | critical notifications disabled request | not allowed | PASS |
| 249 | Social Ping suppression on | safe suppression | PASS |
| 250 | non-essential notification intensity low | reduce optional notices | PASS |
| 251 | Roblox ReducedMotion true and persisted false | effective true | PASS |
| 252 | Roblox PreferredTextSize large and persisted smaller mode | platform size remains floor | PASS |
| 253 | device changes | persisted preferences remain semantic | PASS |
| 254 | preference write races gameplay P2 | does not alter value transaction | PASS |
| 255 | preference corruption | safe defaults + platform settings | PASS |

## Localization, chat and platform safety

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 256 | German string expands | layout grows/wraps | PASS |
| 257 | long localized button label | button remains actionable | PASS |
| 258 | localized text used as ProductDefinitionId | prohibited | PASS |
| 259 | missing translation | source fallback | PASS |
| 260 | locale number formatting differs | semantic numeric value unchanged | PASS |
| 261 | event timer locale formatting | meaning remains clear | PASS |
| 262 | chat unavailable | core progression works | PASS |
| 263 | voice unavailable | Party/event/trade works | PASS |
| 264 | custom freeform unfiltered chat proposed | prohibited | PASS |
| 265 | uncontrolled user text shown | supported Roblox filtering required | PASS |
| 266 | Roblox report menu | remains accessible | PASS |
| 267 | blocking suppresses directed invite | UI affordance removed/disabled | PASS |
| 268 | block state changes | does not alter owned value | PASS |
| 269 | safety warning audio disabled | visual path remains | PASS |
| 270 | report action on gamepad | reachable | PASS |

## Commerce and social/event/trade presentation

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 271 | shop shows product | current runtime price/content | PASS |
| 272 | regional price differs | UI shows current platform metadata | PASS |
| 273 | purchase pending | distinct persistent Pending state | PASS |
| 274 | pass ownership retry is VerificationUnknown | Pending remains while TA-11 async retry runs | PASS |
| 275 | purchase finalizes | authoritative success | PASS |
| 276 | purchase fails | no entitlement-success presentation | PASS |
| 277 | shop prompt during Capture Attempt | suppressed | PASS |
| 278 | commercial capacity sold | exact capability disclosed | PASS |
| 279 | free capacity route | discoverable | PASS |
| 280 | cosmetic item | not styled as intrinsic Mutation identity | PASS |
| 281 | Party leader card | does not imply ownership authority | PASS |
| 282 | event single-award | UI labels allocation model | PASS |
| 283 | event multi-award | UI labels personal opportunity model | PASS |
| 284 | trade revision changes | Ready/confirm reset visibly | PASS |
| 285 | off-platform promise | not integrated into protected trade UI | PASS |

## Performance, security and downstream integration

| # | Situation | Required behavior | Result |
|---:|---|---|---|
| 286 | each UI card creates RenderStepped loop | architecture violation | PASS |
| 287 | central timer ticker handles many timers | preferred bounded approach | PASS |
| 288 | large list scroll | virtualization bounds GuiObjects | PASS |
| 289 | low-end device | drop non-essential animation first | PASS |
| 290 | semantic state update under load | must remain correct | PASS |
| 291 | client receives hidden rarity odds | prohibited projection | PASS |
| 292 | client receives receipt internals unnecessarily | prohibited | PASS |
| 293 | client analytics includes full profile | prohibited | PASS |
| 294 | arbitrary Instance path submitted as authority | server rejects | PASS |
| 295 | TA-13 runs UI experiment | cannot weaken accessibility/consent | PASS |
| 296 | TA-14 sets target sizes/budgets | semantics unchanged | PASS |
| 297 | TA-15 simulates Largest text/gamepad | required | PASS |
| 298 | TA-16 audits client/server authority | closed contract available | PASS |
| 299 | TA-17 names modules/ScreenGuis/actions | must preserve TA-12 invariants | PASS |
| 300 | gameplay implementation attempted now | blocked until TA-17 | PASS |

## Verdict

**300 / 300 scenarios: PASS.**

No TA-12 client-authority, state-projection, input, focus, responsive-layout, accessibility, notification, camera, audio, localization, reconnect, commerce, safety or performance contradiction remains.
