# IMP-11 gate matrix

Date: 2026-10-05. **IMP-11 OPEN; server-local Party and bounded Social Ping dependencies COMPLETE.** [Party evidence](IMP11_PARTY_EVIDENCE.md), [Party native artifact](evidence/IMP11_STUDIO_PARTY_2026-10-05.json), AD-265; [Ping evidence](IMP11_SOCIAL_PING_EVIDENCE.md), [Ping native artifact](evidence/IMP11_STUDIO_PING_2026-10-05.json), AD-266. IMP-10 remains functionally COMPLETE under AD-260 with its existing evidence preserved.

| Gate / owner | Status | Proven evidence / remaining work |
| --- | --- | --- |
| TA-10 Party identity/leader/membership/invite/consent | PASS, this bounded P0 slice | Explicit creation/accept/decline/leave/removal/disband; four seats, one affiliation; no auto-join or personal-value authority; 23 focused fast cases |
| TA-10 revision and participant membership guard | PASS | Existing non-yielding admission/critical section includes Party and participant index; pinned invite revision; conflicting final-seat/cross-Party acceptance, stale/replay negatives |
| TA-3/4 live Player/ProfileSession and replay fence | PASS | Exact current identities and Ready; replacement invalidates prior consent/membership/preference; native actual ProfileSession replacement and cached-request rejection |
| TA-10 same-server rejoin/cleanup model | PASS, C0 model + native lifecycle binding | 30-second seat grace, retained join sequence/current-revision explicit rejoin, no return leadership seizure; expiry/remove/disband/no-resurrection and old-session cleanup tests; native actual respawn/CreatorKick/settled disconnect/shutdown |
| TA-3 bounded hostile ingress/readback | PASS | Existing three remotes, Class B schemas/Ready/rate/replay; Class A Party resync; forged IDs/owner/inviter/session/revision/expiry/member/oversized payload negatives |
| GDS-10 invitation audience/spam bounds | PASS, explicit DEV audience | Default None, session-only explicit SameServer opt-in, revocation; sender/recipient cooldowns, outgoing/incoming bounds and duplicate suppression. Full platform policy review/integration remains below |
| TA-6/14 expiry ownership and no leaks | PASS, local bounded envelope | One next-deadline timer, no polling/Heartbeat or per-invite tasks; real engine expiry, consumed callback/rearm/generation fencing and all-zero stop state |
| Minimal authoritative Party client surface | PASS, diagnostic | Strict full snapshot/store, separate view vs Party revisions, absent/reserved status and immutable expiry deadlines; collapsed native controls; focus unchanged. PQL-3/PQL-8 own final presentation |
| Existing gameplay/profile regressions | PASS, applicable local suite | 262/262 fast, 28/28 Python, static/build/analysis/dependency/integrity; pings change no profile/value; mute uses only existing P1 settings; clean shipped boot, 91/91 final Edit parity and all 64 current parts/Lighting preserved |
| TA-10 bounded Social Ping/waypoint routing | PASS, bounded P0 + native | One ComeHere intent; current Party/revision/live recipients; trusted authored-world sender position; two live slots, six seconds, one request per sender per three seconds in the existing gateway; 26 focused fast and 28 focused native checks |
| TA-12 / AD-140 Social Ping suppression | PASS, existing P1 owner | Only explicit false enables delivery; absent/malformed/unready is safely muted. BufferSettings changes the boolean only; recipient mute cannot affect Party/value authority. Real DEV release/acquire preserves the preference; unavailable writer never claims success |
| TA-10 Friendly Challenges | OPEN — exact next dependency | §10 explicit definition/participant opt-in, non-destructive server-local lifecycle and capability handling |
| TA-10 Showcase/Visitor permission projection | OPEN | Authoritative read-only owner/visitor policy; no value authority |
| TA-10 Shared Objective contribution/Collaboration Rewards | OPEN | Authored server-observed per-player eligibility and owning-profile exact-once P2 rewards |
| TA-10 global/server event identity and lifecycle | OPEN | Stable scheduled/durable dynamic occurrence, local realization, wall-clock lifecycle, cooldown/grace |
| TA-10 event spawn/provenance/multi-award | OPEN | Prospective TA-9 binding, pinned lifetimes/context and distinct per-player instances |
| TA-10 event contribution/completion/rewards | OPEN | Personal eligibility/dedupe and exact-once P2 value; no Party copied credit |
| TA-10 cross-server occurrence refresh hints | OPEN | Messaging hints only; durable truth; optional ephemeral cache only when justified |
| Full real multiplayer/reconnect and platform social-safety validation | OPEN — broader social/release owner | Single real client is proven; timer peer is an adapter fixture. Two real clients/physical same-live-server rejoin, blocked/restricted audience binding and final social safety/presentation require their actual environment/owners |
| VS1-19 and full high-concurrency scale/release | DEFERRED under AD-260 | No unavailable 30-player workload performed; never counted as PASS |

Trading is IMP-12; commerce/subscriptions/passes/status presentation is IMP-13/14; polished social UI is PQL-3/PQL-8. No Party authority or consent can derive from paid status. No later gate is closed by this slice.
