# IMP-11 bounded Party Social Ping evidence

Date: 2026-10-05. Base: main `8651591` (merged PR #69). **TA-10 §7 Ping dependency COMPLETE; IMP-11 OPEN.** [Gate matrix](IMP11_GATE_MATRIX.md), [native artifact](evidence/IMP11_STUDIO_PING_2026-10-05.json), [AD-266](../technical_architecture/ARCHITECTURE_DECISIONS.md#ad-266--bind-bounded-party-pings-and-the-existing-p1-suppression-owner). Completed Party and IMP-10 evidence is preserved.

## Source audit and missing binding

Inspected the current roadmap, Party gate/evidence/native artifact, TA-10 §7/lifecycle/scenarios, GDS-10 PG-01..04 and CE-01, TA-3 gateway, TA-4 ProfileSession, TA-12 §3.3/§25, GDS-14 identifiable SocialPing/suppression, TA-17 namespace, AD-140/260..265, current strategies, Party service/runtime/projection/store, world presence validation, tests/probes and merged PRs #67..69. Main and origin/main matched.

The missing implementation was reserved Social.Ping admission/presentation and its concrete wire binding. The preference owner already existed: ProfileSession.bufferSettings implements validated non-value-critical P1 in the reserved settings bucket. AD-266 binds the one ping intent, current Party revision, live readback, expiry/rate tuning and suppression boolean to these existing owners. No blocker remains for this slice. Full platform restriction/social-safety integration and multiplayer/reconnect release evidence retain their broader owners.

## State, authority and disclosure

- The only enabled intent is **ComeHere**: signal the sender's current validated location. It uses no creature, objective, event, hazard, reward or hidden Variant target; other intent strings and target IDs fail closed.
- Class B `Social.Ping` accepts exactly `{partyId,pingKind="ComeHere"}` and required envelope `expectedRevision`. The authenticated native Player and current private Ready ProfileSession must match active Party membership. The server compares both Party ID and current membership revision, validates the waypoint, then rechecks admission before storing.
- The Party P0 owner holds at most two live ping records, keyed by sender UserId (one slot each). Each has a server GUID, exact private sender identity, pinned Party revision, copied point, server-monotonic cleanup deadline and immutable synced presentation expiry. Repeating one sender replaces its slot; there is no historical list or pending delivery queue.
- Recipient scope comes exclusively from the current four-seat Party. Readback reconciles exact live Player/ProfileSession identities and suppresses non-Ready, absent/reserved, departed, replaced or muted recipients. The sender may receive the same disclosure as another eligible member. No client recipient/owner/session/mute-bypass/text field is accepted.
- `Social.StateChanged` adds `pingsMuted` and at most two `pings` to the existing recipient-only full Party snapshot. Each ping contains `id,senderUserId,kind,position={x,y,z},expiresAt`; the enclosing Party ID/revision supplies context. The shared exact validator requires a present sender in that Party and the existing reliable wire budget. Older V1 Party snapshots remain valid and safely suppressed.
- Ping admission/expiry/preferences advance the recipient view revision, not the Party membership revision. Membership/leader/disconnect/rejoin/remove/disband changes increment the Party revision and clear all pings immediately. Cached duplicates return the previous safe acknowledgment without re-running delivery. `OK_SOCIAL_PING` reveals no recipient presence or mute outcome.

These synchronous transitions reuse existing non-yielding Party admission and participant reconciliation. No concurrency framework, profile checkpoint or semantic target authority is introduced.

## Waypoint and lifetime

The client submits no coordinates. WorldRuntimeService.partyWaypoint reuses current travelContext, the exact expected ProfileSession, validated authored walkable grounding/region/access/hazard checks and trusted arrival readiness. Accessible authored connectors remain valid under that existing world contract. Foreign/unready sessions, invalid position, inaccessible region and out-of-world geometry yield no point. The social boundary independently accepts only exact finite numeric x/y/z with absolute values at most 100000; malformed/NaN/infinite/extreme values fail, with no clamp or coordinate normalization.

The point is a social presentation snapshot, not a world entity or authority handle. It grants no travel/access/discovery/claim/capture/mastery/reward/production/Energy/Party capability. Ping admission leaves the profile exactly unchanged.

DEV ping lifetime is **six seconds**. Existing PartyRuntimeService's one next-deadline timer now also expires pings alongside invites/grace. Its consumed ticket and generation fence protect rearm/stop/replacement. No additional server timer owner, Heartbeat, task per ping or player polling exists. The existing 60-Party bound gives a hard upper bound of 120 live ping slots; four current seats bound each fan-out.

Synced `Workspace:GetServerTimeNow()` supplies immutable presentation expiry; private server monotonic time owns cleanup. The client store discards expired display on reads and rejects stale snapshots. One native diagnostic expiry timer targets the earliest visible deadline, with cancel/ticket/stop fencing. Clock rollback/invalid clock cannot resurrect an expired ping. Native diagnostic copy identifies sender, intent, Party/revision, XYZ and remaining lifetime at render, then removes the row at expiry. It stays collapsed initially and does not steal focus. Final icons/localization/audio/VFX/haptics and input polish belong to later PQL owners.

## Traffic and suppression

The existing NetworkRateLimiter owns a tighter Social.Ping route bucket: capacity one, refill one per three seconds per authenticated UserId. Existing global traffic, ingress payload/schema validation, Ready gate and bounded request/session replay all remain in the same gateway. Other route class budgets are unchanged. Rate rejection is a silent bounded drop, as already contracted; P0 admission may also reject a third sender while two slots are live. Gateway cooldown remains across Party churn. Paid/commercial/status information is absent and cannot change rate, priority, routing or suppression.

`Settings.UpdatePreferences` activates only `{socialPingsMuted:boolean}`, without expectedRevision or other fields. The exact current session's existing bufferSettings writer changes only that boolean; `OK_PREFERENCES_BUFFERED` acknowledges P1 buffering, never durable save. Busy/unavailable/stale writers do not acknowledge a preference change.

Only stored boolean **false** enables pings. Missing, malformed or not-yet-Ready preference defaults to muted; there is no valuable profile migration or parallel preference map. Explicit mute removes already visible pings through a newer recipient snapshot, leaves membership/value untouched and cannot be overridden by a sender. Ordinary reload/rejoin reads the current profile's P1 setting; invitation audience remains its separate session-only AD-265 preference. Replaced sessions cannot inherit Party authority merely because their legitimate presentation preference persists.

## Validation and limits

- **26/26 focused Ping fast; 262/262 full fast**, up from 236. Covers four-peer current recipient scope, reserved seat/explicit rejoin, leave/remove/dissolution, private Player/session replacement, stale/forged context, observation fencing, exact hostile schemas/coordinate validation, mute/revocation/P1 reload/unavailable writer, no profile value change, gateway route/global/replay behavior, bounded simultaneous admission and 1000 same-sender direct-owner replacements, expiry/shutdown and revision/clock-safe readback.
- **28/28 named focused native checks** in the artifact. Actual shipped Command/Event/store/UI prove disclosure, cooldown, within-window replay, expiry, forged recipients/coordinates/target/intent/mute/text/Party/revision, suppression and leave. A scoped actual WorldRuntime/private ProfileSession probe proves authored waypoint/access rejection, unchanged real profile, native deadline expiry, one timer, consumed callback/rearm fences, actual DEV release/acquire P1 persistence, replaced-session cached-request fence, required fresh world arrival and all-zero shutdown/stale callbacks.
- Three preliminary probe failures are recorded as probe failures: replay outside the existing 120-second window and two cooldown ordering mistakes. Corrected final runs respect both established gateway constraints. None is counted as passing evidence.
- **28/28 Python**, format/lint, integrity/dependencies, Rojo build/sourcemap and configured Luau analysis pass. Local Roblox API definitions are absent; configured analysis is not a full native API type pass. Studio supplements compile/runtime evidence.
- Fresh normal server/client boots report BOOTSTRAP_READY, real DEV profile CleanOffline, and no-Party/no-pings/muted readback. Temporary probes are removed, boots enabled, final **Edit**, **91/91 exact source parity**, all **64** existing authored/asset parts and eight recorded Lighting properties preserved.

One real client is proven. Native self-delivery is not two-real-client delivery; fast adapter peers cover the recipient model. Actual private ProfileSession replacement/scoped DEV reload is not a physical same-live-server reconnect. Those broader multiplayer/platform social-safety/release gates remain open. Historical Party 29 native and IMP-10 52 native C0/29 authoring/315 safe-route samples are preserved, not reruns. VS1-19 and high-concurrency/release evidence remain deferred under AD-260.

## Files and next dependency

Production extends existing PartyService, server/client PartyRuntimeService, PartyPolicy/PartyProjectionV1/PartyProjectionStore, NetworkRateLimiter, server WorldRuntimeService/ServerMain and client NetworkingRuntimeService. Tests add unit/SocialPing and manifest entries. Native probes add imp11_ping_client and imp11_ping_authority, reusing the existing world/spawn probes unchanged. Documentation updates roadmap/matrix/TA-17 and adds this evidence/native artifact/AD-266.

Exact next dependency: **TA-10 §10 Friendly Challenges -> visible authored definition and explicit participant opt-in -> non-destructive server-local lifecycle/capability handling**. Visitor/Showcase, cooperative contribution/rewards, event identity/lifecycle/spawning/rewards/cross-server hints remain OPEN. No successor is implemented by this slice.
