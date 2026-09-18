# TA-7 Scenario Validation

> **Phase:** TA-7 — Capture, Creature Ownership, Mutation, and Reward Resolution  
> **Status:** PASS  
> **Purpose:** Validate claim concurrency, capture resolution, Variant Identity generation, anti-reroll, provisional custody, disconnect/shutdown behavior, exact-once ownership, discovery/protection, capacity races and exploit resistance.

| # | Scenario | Expected result | Result |
|---:|---|---|---|
| 1 | Creature becomes actionable before Variant Identity exists | Prohibited | PASS |
| 2 | New CreatureInstanceId receives Variant Identity once | Valid | PASS |
| 3 | Claim retry requests new Mutation roll | Rejected; identity unchanged | PASS |
| 4 | Capture retry requests new Trait roll | Rejected | PASS |
| 5 | Reconnect requests reroll | Rejected | PASS |
| 6 | Transport arrival requests reroll | Rejected | PASS |
| 7 | Secure Point request requests reroll | Rejected | PASS |
| 8 | Content snapshot changes while creature exists | Existing identity unchanged | PASS |
| 9 | World cycle changes while creature exists | Existing identity unchanged | PASS |
| 10 | Creature truly despawns then replacement spawns | Replacement may roll independently | PASS |
| 11 | Client supplies MutationId result | No authority | PASS |
| 12 | Client supplies TraitId result | No authority | PASS |
| 13 | Client supplies "Legendary=true" | No authority | PASS |
| 14 | Client supplies RNG seed | Ignored/rejected | PASS |
| 15 | Production RNG uses server-owned Random abstraction | Valid | PASS |
| 16 | Test uses deterministic seeded RNG | Valid | PASS |
| 17 | RNG state replicated to clients | Prohibited | PASS |
| 18 | Random draw occurs before eligibility context validated | Invalid | PASS |
| 19 | Logical result retries and redraws | Prohibited | PASS |
| 20 | One logical result stores/reuses selected outcome | Required | PASS |
| 21 | Mutation weight is NaN | Validation failure | PASS |
| 22 | Mutation weight is negative | Validation failure | PASS |
| 23 | Mutation weight is infinity | Validation failure | PASS |
| 24 | All eligible weights are zero | Validation failure | PASS |
| 25 | Same Mutation appears twice in eligible table | Validation failure / no duplicate selection | PASS |
| 26 | Compound outcome selects incompatible pair | Prohibited | PASS |
| 27 | Compound outcome selects same Mutation twice | Prohibited | PASS |
| 28 | Mutation order A+B vs B+A | Same canonical Variant Signature | PASS |
| 29 | Three Mutations generated in baseline | Prohibited | PASS |
| 30 | Zero Mutation generated | Valid Standard Variant | PASS |
| 31 | One Mutation generated | Valid Single-Mutated Variant | PASS |
| 32 | Two compatible Mutations generated | Valid Compound Variant | PASS |
| 33 | Trait differs between otherwise same Variant Signature | Valid | PASS |
| 34 | Trait order changes baseline Variant Signature | Must not | PASS |
| 35 | Species Rarity derived from canonical Species definition | Valid | PASS |
| 36 | Availability tag used as Species Rarity | Invalid conflation | PASS |
| 37 | Spending history changes Mutation odds | Prohibited | PASS |
| 38 | Premium entitlement changes claim priority | Prohibited | PASS |
| 39 | Recent purchase refusal changes capture success | Prohibited | PASS |
| 40 | Event C2 modifier changes future eligible Mutation weights | Valid if explicit/approved | PASS |
| 41 | Event modifier changes already generated creature | Prohibited | PASS |
| 42 | High-value Mutation visually hidden but already finalized | Allowed | PASS |
| 43 | Hidden Mutation generated only after player succeeds | Prohibited | PASS |
| 44 | Trait affecting immediate decision is fully hidden until after irreversible cost | Prohibited | PASS |
| 45 | Flavor-only Trait reveal occurs later | Allowed | PASS |
| 46 | Two players send BeginClaim simultaneously | One serialized accepted claim | PASS |
| 47 | Client timestamp decides winner | Prohibited | PASS |
| 48 | Client ping decides winner by rule | Prohibited | PASS |
| 49 | Premium status breaks tie | Prohibited | PASS |
| 50 | Party leader breaks tie | Prohibited | PASS |
| 51 | First server-accepted eligible transition wins | Required | PASS |
| 52 | Losing BeginClaim spends cost | Prohibited | PASS |
| 53 | Losing BeginClaim receives current-state rejection | Valid | PASS |
| 54 | Active claim overwritten by later player | Prohibited | PASS |
| 55 | ClaimId reused for a new claim | Prohibited | PASS |
| 56 | Same surviving creature gets a new claimId after release | Valid | PASS |
| 57 | Old claim input arrives during new claimant's attempt | Reject stale claim | PASS |
| 58 | Old character generation sends claim input | Reject stale generation | PASS |
| 59 | Creature runtimeRevision changed before input arrives | Reject/reconcile stale revision | PASS |
| 60 | Claim check-and-set yields between check and mutation | Invalid architecture | PASS |
| 61 | Per-creature state owner serializes transitions | Required | PASS |
| 62 | Claim accepted while server draining | Rejected | PASS |
| 63 | Claim accepted while creature terminating | Rejected | PASS |
| 64 | Claim accepted while player profile not Ready | Rejected | PASS |
| 65 | Claim accepted without valid character when required | Rejected | PASS |
| 66 | Claim accepted from impossible distance | Rejected | PASS |
| 67 | Claim accepted from locked region | Rejected | PASS |
| 68 | Claim accepted while another active custody exists | Rejected | PASS |
| 69 | Claim accepted while capacity known full | Rejected | PASS |
| 70 | Claim accepted while unresolved Overflow-Held blocks acquisition | Rejected | PASS |
| 71 | Claim accepted with insufficient Capture Capability | Rejected | PASS |
| 72 | Claim accepted for onboarding opportunity owned by another learner | Rejected | PASS |
| 73 | Eligible onboarding learner claims protected opportunity | Accepted | PASS |
| 74 | Client only looks/touches creature | No accepted claim | PASS |
| 75 | Deliberate valid Primary Interact | May request claim | PASS |
| 76 | Claim remains forever while AFK | Prohibited | PASS |
| 77 | Claim inactivity timeout expires | Release/owning rule | PASS |
| 78 | Claimant leaves allowed range | Invalidate/release under configured rule | PASS |
| 79 | Repeated start/cancel monopolizes indefinitely | Prohibited; grief controls apply | PASS |
| 80 | Very brief re-engagement cooldown configured | Allowed tuneable | PASS |
| 81 | Capture Attempt starts without current claim | Rejected | PASS |
| 82 | Capture Attempt starts with stale claimId | Rejected | PASS |
| 83 | Accepted attempt begins before persistent cost if future cost exists | Reservation prevents competing spend | PASS |
| 84 | Future cost persistence fails | Attempt cannot falsely become active/charged | PASS |
| 85 | Duplicate AttemptStart network packet | No second attempt/cost | PASS |
| 86 | Baseline ordinary attempt charges mandatory Energy | Not authorized by GDS-8 | PASS |
| 87 | Client says attempt succeeded | Ignored | PASS |
| 88 | Client sends action within expected window | Server evaluates | PASS |
| 89 | Client sends action before server challenge start | Reject/ignore | PASS |
| 90 | Client sends action after terminal result | Reject/ignore | PASS |
| 91 | Client reports fabricated elapsed time | Not authoritative | PASS |
| 92 | Client sends excessive challenge events | TA-3 rate limit/bounded log | PASS |
| 93 | Challenge input buffer grows without bound | Prohibited | PASS |
| 94 | Capture Success computed server-side | Required | PASS |
| 95 | Failure computed server-side | Required | PASS |
| 96 | Cancel accepted server-side | Terminal Cancel | PASS |
| 97 | State invalidates attempt | Terminal Invalidation | PASS |
| 98 | Terminal result changes after late packet | Prohibited | PASS |
| 99 | Capture-result RNG allowed by authored challenge | Valid server-side | PASS |
| 100 | Same accepted attempt retries and gets new capture RNG sample | Prohibited | PASS |
| 101 | New legitimate attempt after failure gets new capture-result sample | Allowed | PASS |
| 102 | New legitimate attempt changes creature Variant Identity | Prohibited | PASS |
| 103 | Capture performance influences Success/Failure | Allowed | PASS |
| 104 | Capture performance influences Mutation roll after actionability | Prohibited | PASS |
| 105 | Species Rarity hard-coded to universal success percentage | Not required/invalid assumption | PASS |
| 106 | Mutation modifies challenge where authored | Allowed with readability rules | PASS |
| 107 | Concealed Mutation silently fakes player error | Prohibited | PASS |
| 108 | Capture Failure creates secured creature | Prohibited | PASS |
| 109 | Capture Cancel creates secured creature | Prohibited | PASS |
| 110 | Capture Invalidation creates secured creature | Prohibited | PASS |
| 111 | Capture Success creates persistent ownership immediately | Prohibited | PASS |
| 112 | Capture Success creates one Provisional Capture | Required | PASS |
| 113 | Provisional Capture keeps same CreatureInstanceId | Required | PASS |
| 114 | Provisional Capture rerolls Mutation | Prohibited | PASS |
| 115 | Provisional Capture has exactly one custody holder | Required | PASS |
| 116 | New custody mints a second creature ID | Prohibited | PASS |
| 117 | One player holds two ordinary provisional captures | Prohibited baseline | PASS |
| 118 | Other player touches carrier | No custody transfer | PASS |
| 119 | Other player crowds transporter | No custody cancellation | PASS |
| 120 | Other player starts normal claim on provisional creature | Rejected | PASS |
| 121 | Fast travel requested during custody | Downstream gate rejects | PASS |
| 122 | Carrier Model disappears | Custody state remains server-authoritative | PASS |
| 123 | Client physics moves carrier to Secure Point | Not sufficient for extraction | PASS |
| 124 | Touched fires at Secure Point | Server still validates | PASS |
| 125 | Prompt Triggered at Secure Point | Server still validates | PASS |
| 126 | Character reset during transport | Custody ends; no extraction | PASS |
| 127 | Character death during transport | Interruption; no ownership | PASS |
| 128 | Recovery teleports player to Secure Point | Does not extract | PASS |
| 129 | Client disconnect during attempt before server Success | No success unless result already finalized | PASS |
| 130 | Client disconnect after server Success/active transport | Enter bounded Transport Grace | PASS |
| 131 | Grace is written as secured creature to profile | Prohibited | PASS |
| 132 | Grace retains same CreatureInstanceId/custody | Required | PASS |
| 133 | Grace expires | Provisional ends without ownership | PASS |
| 134 | Player rejoins a different server during grace | No custody transfer | PASS |
| 135 | Same UserId rejoins same server before grace expiry | May resume after profile Ready | PASS |
| 136 | Rejoin occurs but profile not Ready | No custody resume yet | PASS |
| 137 | Rejoin after grace expiry | No resume | PASS |
| 138 | Creature already terminal before rejoin | No resume | PASS |
| 139 | Client requests arbitrary grace extension | Rejected | PASS |
| 140 | Explicit trusted in-game voluntary leave | Custody ends without grace | PASS |
| 141 | CreatorKick during custody | Custody ends | PASS |
| 142 | Ambiguous PlayerExitReason.Unknown during custody | Conservative bounded grace | PASS |
| 143 | Client sends "I disconnected" remote | Does not create ownership/grace by itself | PASS |
| 144 | Ambiguous exit grace is used to cross servers | Prohibited | PASS |
| 145 | Server begins orderly drain with IdleAvailable creature | No secure grant | PASS |
| 146 | Server drain with Claimed creature | No secure grant | PASS |
| 147 | Server drain with AttemptActive but no Success | No secure grant | PASS |
| 148 | Server drain with active valid Transport Custody | Protected finalization eligible | PASS |
| 149 | Server drain with expired custody | No protected finalization | PASS |
| 150 | Server drain with TransportGrace suspended user | No protected finalization | PASS |
| 151 | Player can spoof shutdown via remote | Prohibited | PASS |
| 152 | Shutdown protection uses new operation ID | Prohibited | PASS |
| 153 | Shutdown protection uses existing finalization operation ID | Required | PASS |
| 154 | Abrupt server crash during transport | No guaranteed finalization | PASS |
| 155 | Shutdown P2 persistence fails before deadline | No fabricated success | PASS |
| 156 | Secure Point extraction has active valid custody | Eligible to finalize | PASS |
| 157 | Secure Point target unknown | Reject | PASS |
| 158 | Secure Point wrong/locked context | Reject | PASS |
| 159 | Secure Point request from wrong player | Reject | PASS |
| 160 | Secure Point request uses stale custodyId | Reject | PASS |
| 161 | Secure Point spam repeats same operation | One final result | PASS |
| 162 | ownershipFinalizationOperationId is client-selected | Prohibited | PASS |
| 163 | operation ID generated when Provisional created | Required | PASS |
| 164 | operation ID tied to CreatureInstanceId + intended owner semantics | Required | PASS |
| 165 | Network request ID substituted for durable operation ID | Prohibited | PASS |
| 166 | P2 commit response lost after DataStore success | Retry/reconcile same operation | PASS |
| 167 | Same operation reaches profile twice | No duplicate creature/discovery | PASS |
| 168 | Profile already contains same CreatureInstanceId unexpectedly | Fail/reconcile integrity condition | PASS |
| 169 | P2 succeeds but world Model still visible briefly | Quiescing projection only; no duplicate claim | PASS |
| 170 | World role ends before ownership durability known and commit then fails | Invalid destructive ordering | PASS |
| 171 | Client shown "Secured" before P2 success | Prohibited | PASS |
| 172 | P2 success stores same CreatureInstanceId | Required | PASS |
| 173 | P2 success stores same immutable Variant Identity | Required | PASS |
| 174 | P2 success changes owner to intended profile | Required | PASS |
| 175 | Species Discovery first-time | Recorded once | PASS |
| 176 | Mutation Discovery first-time | Recorded once | PASS |
| 177 | Variant Discovery first-time | Recorded once | PASS |
| 178 | Duplicate existing Discovery | Remains one historical fact | PASS |
| 179 | Seeing rare creature grants discovery | Prohibited | PASS |
| 180 | Capture Success alone grants discovery | Prohibited | PASS |
| 181 | Secured Compound Variant records compound signature | Required | PASS |
| 182 | Owning each single Mutation separately counts as compound discovery | Prohibited | PASS |
| 183 | Trait permutations create baseline Variant Discovery explosion | Prohibited | PASS |
| 184 | Legendary secured | Auto-lock in same commit | PASS |
| 185 | Extreme Mutation secured | Auto-lock in same commit | PASS |
| 186 | Compound Variant secured | Auto-lock in same commit | PASS |
| 187 | Event protection marker secured | Auto-lock in same commit | PASS |
| 188 | Common standard ordinary creature secured | No automatic Protected lock | PASS |
| 189 | Protected creature persisted first, lock written later | Prohibited timing gap | PASS |
| 190 | Player manually unlocks later | Allowed under GDS-4 downstream behavior | PASS |
| 191 | Capacity known full at initiation | Block capture | PASS |
| 192 | Capacity available at initiation but lost before finalization | Finalize Overflow-Held | PASS |
| 193 | Capacity race deletes creature | Prohibited | PASS |
| 194 | Overflow-Held changes Variant Identity | Prohibited | PASS |
| 195 | Ordinary secured capture grants automatic Energy | Prohibited baseline | PASS |
| 196 | Explicit milestone reward attached by owning system | Allowed exact-once | PASS |
| 197 | Retry duplicates attached milestone reward | Prohibited | PASS |
| 198 | Personal event capture opportunity has its own creature instance | Required | PASS |
| 199 | Shared event creature copied into multiple player profiles | Prohibited | PASS |
| 200 | Claim/RNG/custody/P2 pipeline preserves one stable exact creature from world opportunity to secured collection | Required integrated outcome | PASS |

## Verdict

**200 / 200 scenarios: PASS.**

No TA-7 claim-concurrency, capture-resolution, randomness, Variant Identity, custody, shutdown, capacity, discovery or exact-once ownership contradiction remains.
