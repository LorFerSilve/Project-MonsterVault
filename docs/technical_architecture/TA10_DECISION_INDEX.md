# TA-10 Decision Index

> **Phase:** TA-10 — Social Systems, Server Events, Cross-Server Coordination, and Trading  
> **Status:** Accepted

## TA10-D01 — Parties Are Same-Server Transient State

**Decision:** Party membership, leadership, invites, pings and rejoin grace are P0 server-session state. Party-local mutations serialize by PartyId, while affiliation transitions additionally serialize through a participant-scoped membership guard/index so one player cannot concurrently join two Parties. Persistent player outcomes produced during social play live in their owning Player Profile domains.

---

## TA10-D02 — Social Relationships Never Grant Value Authority

**Decision:** Friendship, Party membership, challenge participation or visitor status cannot mutate another player's collection, Energy, progression, claim, custody or Vault state.

---

## TA10-D03 — Shared Rewards Are Per-Player Contribution-Gated P2 Outcomes

**Decision:** Shared Objective and Collaboration Rewards require server-observed Eligible Contribution and finalize independently for each player with stable operation identity.

---

## TA10-D04 — Ordinary Friendly Competition Remains Non-Destructive

**Decision:** Friendly Challenges are explicit opt-in session state with no baseline wagering, creature/Energy staking, combat damage, knockback, forced movement or persistent power reward.

---

## TA10-D05 — EventOccurrence Is the Cross-Server Persistent Event Identity

**Decision:** EventOccurrenceId identifies one wall-clock occurrence across servers. ServerEventInstanceId identifies only a local realization and is never used as global reward identity.

---

## TA10-D06 — Scheduled Event Timing Is Derived from Server Wall Clock

**Decision:** Scheduled Global Event Windows are reconstructed from validated schedule/config and server-observed wall time. Joining/restarting a server cannot reset them.

---

## TA10-D07 — Dynamic Global Occurrences Become Authoritative Only After Durable Recording

**Decision:** A dynamically authorized occurrence must exist in durable occurrence state before cross-server notifications can make it active.

---

## TA10-D08 — MessagingService Is Notification, Not Truth

**Decision:** MessagingService accelerates occurrence/config refresh and announcements. Missing/duplicate/stale messages cannot change authoritative event outcomes.

---

## TA10-D09 — MemoryStore Is Optional Ephemeral Coordination Only

**Decision:** MemoryStore may cache or coordinate short-lived live state if measured need justifies it, but TTL expiry/throttling cannot delete ownership, rewards, trade decisions or event history.

---

## TA10-D10 — Event Modifiers Are Prospective

**Decision:** Event Spawn Modifiers affect only future TA-9 Spawn Reservations. Existing World Creatures and Secured Creatures keep their identity.

---

## TA10-D11 — Event Multi-Award Creates Distinct Personal Creature Instances

**Decision:** A shared event target may qualify several players, but each qualified personal opportunity receives a separate CreatureInstanceId/Variant generation. One CreatureInstanceId is never multi-owned.

---

## TA10-D12 — Baseline Trading Is Direct, Bilateral, and Same-Server

**Decision:** Both players must be present in the same server and independently satisfy Trade Access/safety preconditions. No baseline offline listing, global marketplace or cross-server negotiation exists.

---

## TA10-D13 — Trade Consent Binds One Exact Revision

**Decision:** Every semantic offer edit creates a new Trade Revision and clears both Ready and Final Confirmation state. Commit can begin only after both players Final Confirm the same immutable revision.

---

## TA10-D14 — Trade Negotiation Uses Runtime Exact-Instance Reservations

**Decision:** Offered CreatureInstanceIds are reserved in server runtime to prevent conflicting same-server mutation while negotiation is active. Negotiation itself performs no DataStore write per edit.

---

## TA10-D15 — Trade Commit Uses a Durable Multi-Profile Journal Protocol

**Decision:** TA-10 uses TA-4's transaction-store primitive with participant prepare fences, immutable commit/abort decision, idempotent participant apply and recovery. Every participant write continues to obey TA-4 lease ownership/single-writer serialization; sequential unrelated profile writes are not accepted as atomic trade.

---

## TA10-D16 — COMMIT_DECIDED Is Irreversible

**Decision:** Once both profiles are durably prepared and the journal records COMMIT_DECIDED, ordinary cancellation is forbidden and recovery must finish the exact committed exchange.

---

## TA10-D17 — Pending Trade Profiles Are Transaction-Blocked

**Decision:** A profile with unresolved pendingTrade cannot become normal gameplay Ready or execute conflicting irreversible mutations. An APPLIED participant retains its transaction fence until both applies are acknowledged, the journal reaches FINALIZED_COMMIT, and authorized profile reconciliation clears the marker.

---

## TA10-D18 — Participant Apply Transfers the Same Creature Record

**Decision:** Trade participant apply moves the exact CreatureInstanceId/Variant/provenance, clears sender display references, stores incoming creatures safely, applies cooldown, re-locks Protected Variants and never transfers Energy/Production Buffer/Vault upgrades.

---

## TA10-D19 — Trade Recovery Does Not Require Connected Clients

**Decision:** Journal recovery can complete participant transforms without connected clients, but it never bypasses TA-4 profile authority: a live lease routes recovery through the lease-owner writer queue, while an absent owner requires legal stale/expired-lease recovery ownership before UpdateAsync.

---

## TA10-D20 — Close TA-10 and Advance to TA-11

**Decision:** TA-10 is Architecture Complete — PASS with 335/335 scenarios and zero blocking questions. TA-11 becomes NEXT; gameplay implementation remains blocked until TA-17.
