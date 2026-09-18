# TA-3 Scenario Validation

> **Phase:** TA-3 — Networking, Server Authority, Remote Contracts, and Exploit Boundaries  
> **Status:** PASS  
> **Purpose:** Validate client/server trust, remote directions, payload validation, session readiness, rate/replay handling, physics/prompt boundaries, cross-player relays, prediction/reconciliation, observability and failure behavior before implementation.

| # | Scenario | Expected result | Result |
|---:|---|---|---|
| 1 | Client sends valid Session.ClientHello | Gateway validates and returns/queues authoritative session state | PASS |
| 2 | Client claims it is Ready | Claim does not grant server gameplay readiness | PASS |
| 3 | Client sends gameplay command before trusted profile Ready | Rejected NotReady | PASS |
| 4 | Client in Protected Load Failure sends purchase/progression command | Rejected safely | PASS |
| 5 | Client sends unsupported protocol version | Fails closed with safe incompatibility behavior | PASS |
| 6 | Client omits protocolVersion | Reject malformed envelope | PASS |
| 7 | Client sends route as table | Reject malformed envelope | PASS |
| 8 | Client sends overlong route string | Reject before expensive work | PASS |
| 9 | Client sends unknown route | Reject/log; no dynamic module lookup | PASS |
| 10 | Client fires server->client Event transport toward server | Wrong-direction/no authority | PASS |
| 11 | Feature creates ad-hoc RemoteEvent | Violates central registry | PASS |
| 12 | Networking bootstrap creates central remotes | Valid | PASS |
| 13 | Remote names are discovered by exploiter | No security impact by itself | PASS |
| 14 | Exploiter decompiles shared route schemas | Expected disclosure | PASS |
| 15 | Client claims another sender UserId in payload | Ignored; sender is implicit Player | PASS |
| 16 | Client command payload is nil when object expected | Reject | PASS |
| 17 | Client payload contains unexpected key | Reject exact schema | PASS |
| 18 | Client payload omits required key | Reject | PASS |
| 19 | Client sends NaN number | Reject | PASS |
| 20 | Client sends +infinity | Reject | PASS |
| 21 | Client sends negative quantity where positive required | Reject range | PASS |
| 22 | Client sends fractional value where integer required | Reject | PASS |
| 23 | Client sends huge string | Reject bounded length | PASS |
| 24 | Client sends huge table | Reject bounded element count | PASS |
| 25 | Client sends deeply nested table | Reject bounded depth | PASS |
| 26 | Client sends cyclic/unsupported structure | Reject/fail safely | PASS |
| 27 | Client sends arbitrary Instance for generic deletion | Reject | PASS |
| 28 | Client sends stable target ID | Server resolves and validates target | PASS |
| 29 | Route later accepts Instance reference | Must validate class/ancestry/lifecycle/relationship | PASS |
| 30 | Client sends target Instance from unexpected hierarchy | Reject | PASS |
| 31 | Client sends valid payload at excessive frequency | Rate limiter rejects excess | PASS |
| 32 | Client floods many low-cost routes | Global ingress limiter applies | PASS |
| 33 | Client floods one expensive route | Per-route weighted limiter applies | PASS |
| 34 | Client respects local cooldown but maliciously bypasses UI | Server rate limit still authoritative | PASS |
| 35 | Client sends slowly but semantically invalid requests | Validation still rejects | PASS |
| 36 | One rate spike occurs due lag/UI bug | No automatic confiscation/permanent ban | PASS |
| 37 | Repeated impossible requests occur | Safe no-op + structured abuse telemetry | PASS |
| 38 | Client sends same requestId/same request after timeout | Duplicate/retry path, no duplicate value | PASS |
| 39 | Client reuses requestId for different route | Reject request ID misuse | PASS |
| 40 | Client reuses requestId with changed payload | Reject suspicious reuse | PASS |
| 41 | Sensitive command times out client-side | Client treats outcome as unknown | PASS |
| 42 | Client assumes timeout means failure and locally refunds itself | Invalid; reconciliation required | PASS |
| 43 | Client retries irreversible command with new requestId | Not approved automatic retry behavior | PASS |
| 44 | Approved retry uses same requestId | Valid bounded retry | PASS |
| 45 | Network duplicate cache lost on reconnect | Durable exact-once remains downstream transaction responsibility | PASS |
| 46 | Client requestId chosen as Creature Instance ID | Invalid authority boundary | PASS |
| 47 | Server generates durable operation ID after accepted command | Correct | PASS |
| 48 | Standard RemoteEvent command arrives twice | Current state/idempotency prevents duplicate finalization | PASS |
| 49 | RemoteEvent reliable delivery is delayed | Current authoritative state still validated | PASS |
| 50 | Two commands arrive in unexpected temporal relation | Revision/state checks protect correctness | PASS |
| 51 | Trade SetOffer includes current revision | Server may process after validation | PASS |
| 52 | Trade FinalConfirm uses stale revision | Reject StaleRevision | PASS |
| 53 | Client skips Ready and sends FinalConfirm | Domain rejects invalid state | PASS |
| 54 | Client submits "trade succeeded=true" | No authority; ignored/rejected | PASS |
| 55 | Client submits new owner ID for creature | No authority | PASS |
| 56 | Client sends CaptureSuccess=true | No authority | PASS |
| 57 | Client sends captured variant roll | Server ignores/rejects client outcome | PASS |
| 58 | Client sends Energy balance after purchase | Server uses own balance | PASS |
| 59 | Client sends cheaper price than config | Server uses authoritative config | PASS |
| 60 | Client says progression milestone complete | Server verifies persistent progression | PASS |
| 61 | Client says Event reward eligible | Server verifies occurrence/contribution | PASS |
| 62 | Client says Party membership exists | Server verifies social state | PASS |
| 63 | Client sends blocked target for Ping | Server checks block/safety state | PASS |
| 64 | Client relays arbitrary message to another client | No blind relay | PASS |
| 65 | Structured Social Ping valid and allowed | Server constructs approved recipient payload | PASS |
| 66 | Social Ping payload includes hidden extra text | Reject schema | PASS |
| 67 | Future freeform chat route proposed without GDS-15 review | Reject/reopen design | PASS |
| 68 | Client asks private collection of arbitrary UserId | Reject unless explicit authorized public projection | PASS |
| 69 | Server sends own private collection to owner | Valid audience | PASS |
| 70 | Server broadcasts private Energy values to all clients | Invalid | PASS |
| 71 | Public event phase broadcast | Valid if genuinely public | PASS |
| 72 | Personal event reward eligibility broadcast | Invalid; owner only | PASS |
| 73 | Hidden rare roll sent to client before reveal | Invalid disclosure | PASS |
| 74 | Exploit score sent to client | Invalid baseline | PASS |
| 75 | Client prediction shows button animation | Valid | PASS |
| 76 | Client prediction shows provisional progress bar | Valid if reconcilable | PASS |
| 77 | Client prediction adds permanent creature locally | Invalid authoritative prediction | PASS |
| 78 | Client prediction deducts authoritative Energy | Invalid as truth; server result required | PASS |
| 79 | Client prediction marks trade committed | Invalid | PASS |
| 80 | Server rejects predicted action | Client reconciles to server state | PASS |
| 81 | Server event arrives with older stateVersion | Client ignores/safely handles stale projection | PASS |
| 82 | Fresh snapshot arrives after reconnect | Snapshot supersedes cached local history | PASS |
| 83 | Client misses prior event while disconnected | Reconnect state still correct | PASS |
| 84 | ClientHello listener binds after server sent Ready without handshake | Race avoided by defined hello/snapshot protocol | PASS |
| 85 | ClientHello sends input-device type | Treat as presentation hint only | PASS |
| 86 | ClientHello claims premium platform capability | Does not grant entitlement | PASS |
| 87 | UnreliableEvent sends cosmetic trail point | Valid | PASS |
| 88 | UnreliableEvent packet drops | Gameplay correctness unchanged | PASS |
| 89 | UnreliableEvent packets reorder | Gameplay correctness unchanged | PASS |
| 90 | UnreliableEvent sends CaptureSuccess | Prohibited | PASS |
| 91 | UnreliableEvent sends Energy | Prohibited | PASS |
| 92 | UnreliableEvent sends Trade Revision | Prohibited | PASS |
| 93 | Client wants high-frequency unreliable aim stream | Not baseline need; reopen TA-3 if future feature requires | PASS |
| 94 | RemoteFunction proposed for inventory query | Prefer async snapshot/request-result baseline | PASS |
| 95 | Server invokes client RemoteFunction for confirmation | Prohibited | PASS |
| 96 | Client disconnects while server InvokeClient would wait | Avoided entirely | PASS |
| 97 | Future bounded RemoteFunction use proposed | Requires TA-3 change control | PASS |
| 98 | Client character is network owner of physics | Position treated as untrusted/tolerant input | PASS |
| 99 | Client teleports character locally near rare creature | Server context/proximity validation blocks invalid action | PASS |
| 100 | Client moves unanchored target due network ownership | Critical award not based solely on that physics condition | PASS |
| 101 | ProximityPrompt Enabled false locally/server discrepancy | Server gameplay eligibility still checked | PASS |
| 102 | Exploiter fires ProximityPrompt from arbitrary range | Server revalidates context/distance | PASS |
| 103 | Exploiter manipulates Prompt hold timing | Server-owned timing/state prevents shortcut | PASS |
| 104 | ClickDetector/DragDetector event fires unexpectedly | Treat as untrusted interaction intent | PASS |
| 105 | Interaction target ID no longer exists | Reject NotFound/InvalidState | PASS |
| 106 | Interaction target exists but player lacks access | Reject NotAuthorized | PASS |
| 107 | Interaction valid but player is in Acquisition-In-Progress incompatible state | Domain rejects | PASS |
| 108 | Fast travel request sent during custody | Server checks and rejects | PASS |
| 109 | Release request names locked creature | Server rejects via Creature Lock | PASS |
| 110 | Production claim repeated | Network correlation + downstream exact-once prevent duplicate Energy | PASS |
| 111 | Event contribution spammed | Rate/context checks; no reward from raw message count | PASS |
| 112 | Trade request targets non-participant | Reject | PASS |
| 113 | Trade request targets participant but session ended | Reject invalid state | PASS |
| 114 | Purchase UI command claims receipt succeeded | No authority | PASS |
| 115 | Client asks server to grant developer product | Invalid; receipt path is platform/server owned | PASS |
| 116 | Handler throws before any commit | Safe server error/no mutation | PASS |
| 117 | Handler throws after durable downstream commit | Reconcile authoritative state; do not duplicate/guess rollback | PASS |
| 118 | Handler error returns stack trace to client | Prohibited | PASS |
| 119 | Handler error is logged with correlation ID | Valid | PASS |
| 120 | Unknown route attempts string-based require | Static registry blocks arbitrary lookup | PASS |
| 121 | Malicious payload logged verbatim at huge size | Avoid; structured bounded telemetry | PASS |
| 122 | Network telemetry includes route/result/latency class | Valid | PASS |
| 123 | Analytics failure occurs | Gameplay command correctness unaffected | PASS |
| 124 | Server sends full collection after every small change | Violates projection/performance principle | PASS |
| 125 | Server sends changed creature/projection only | Preferred | PASS |
| 126 | Reliable remote fired every frame for cosmetic effect | Invalid baseline performance pattern | PASS |
| 127 | Client creates cosmetic effect locally from one server fact | Preferred where safe | PASS |
| 128 | FireAllClients used for private trade state | Invalid | PASS |
| 129 | FireAllClients used for public event phase | Valid | PASS |
| 130 | Client-to-client lightning/VFX-style relay sent without server gate | Invalid | PASS |
| 131 | Server validates relay intent then sends approved effect fields | Valid | PASS |
| 132 | Feature flag disables server validation for experiment | Prohibited Experiment Invariant violation | PASS |
| 133 | Premium player receives higher remote rate to gain gameplay advantage | Invalid unless purely UI/non-value and explicitly justified | PASS |
| 134 | Low-end client requests less cosmetic traffic | May be presentation optimization, no gameplay value change | PASS |
| 135 | Rate budget numbers are not fixed in TA-3 | Correctly deferred to TA-14 | PASS |
| 136 | Actual route strings/files are not created in TA-3 | Correctly deferred to TA-17 scaffold | PASS |
| 137 | TA-4 defines persistent operation IDs | Compatible with TA-3 request correlation | PASS |
| 138 | TA-10 defines social/trade domain routes | Must conform to TA-3 registry/validation contracts | PASS |
| 139 | TA-15 fuzzes malformed payloads and replay | Required downstream verification | PASS |
| 140 | Gameplay scripts are created while TA-3 closes | Implementation gate violation | PASS |

## Verdict

**140 / 140 scenarios: PASS.**

No TA-3 networking, trust-boundary, rate/replay, prediction or exploit contradiction remains.
