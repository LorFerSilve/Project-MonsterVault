# IMP-10 — World registry, mastery and access evidence

Date: 2026-10-02 (Europe/Brussels). Decision: AD-255. Base: merged PR #53, `982a0554f9a538cbb83032bfa10bb5bda965b35b`.

**First dependency PASS; IMP-10 OPEN.** [Native evidence](evidence/IMP10_STUDIO_WORLD_MASTERY_ACCESS_2026-10-02.json) records the connected Studio, source/test hashes, scoped DEV writes, native client replies and a fresh-server rejoin. [Gate matrix](IMP10_GATE_MATRIX.md) distinguishes this dependency from the remaining phase gates.

## Implemented contract chain

- Server-only immutable typed DEV registries validate five existing GDS-9 roles, Region/Species/Habitat/Spawn Context/Landmark/Field Objective references and bounded active mastery recipes. Existing `region/fixture-clearing` retains its identity and is explicitly the Starter role. Mid A/B/Advanced refer to the existing TA-8 access IDs. Their geometry, objectives and spawn/travel content are not authored by this change.
- The authoring index snapshots the two existing Studio point transforms and definition-owned radii once before profile startup. Missing, duplicate, unknown, wrong-region, unanchored or overlapping points fail bootstrap before encounters or player admission. No topology, biome theme or new geometry is introduced.
- Native Survey prompts and `Interaction.PrimaryInteract` resolve only known landmark IDs; alive server-observed character presence, spatial membership, Ready and current access are authoritative. The authored DEV traversal is entry → clearing → entry. Repeated presence at one point cannot complete it.
- Qualified Secured provenance contributes one RegionId + SpeciesId fact in the same P2 as exact-instance ownership, discovery and ordinary/Overflow-Held placement. Unrecognized context/snapshot/species combinations cannot contribute. Old ownership and global discovery are not converted into route/objective/mastery proof.
- Mastery requires both survey points, one distinct Common Core Species out of two registered DEV Core Species, and the complete traversal objective. The existing Orb remains the only materialized encounter; the companion is a registry definition pending content/spawn binding. Mandatory progression therefore uses the existing common capture, below full registered pool completion. Later content expansion and creature release do not revoke the finalized milestone.
- TA-8 consumes this actual mastery reader. Mid A/B remain independent Starter-mastery purchases; Advanced needs both Mid masteries and both prior access receipts. Purchased access does not create world proof. Capture admission/resume/submit/secure recheck injected authority; malformed or unknown provenance fails closed before claim/RNG/mutation. Existing context-before-capacity ordering and immutable admitted finalization/reconciliation remain intact.
- World visits use the existing single writer, immutable P2 candidate and durable facts. Class A `Session.RequestResync` with `domain=world` recovers an admitted unknown result independently of current position and returns bounded owner-only mastery IDs. It cannot grant value. World reward sources, deferred grants, events and commercial/temporary sources remain unbound and protected; this dependency mints no world Energy.

## Validation

| Check | Result |
| --- | --- |
| Complete fast suite | 161/161 PASS, including 8 new C0 world suites |
| Native Studio world C0 suites | 8/8 PASS, including real mastery-owner Mid A/B/Advanced binding in isolated contract-supported content |
| Native authoring bootstrap | 7/7 PASS: valid plus missing tag, unknown ID, duplicate ID, wrong region, overlap and unanchored negatives |
| Native shipped bootstrap | Server/client `BOOTSTRAP_READY`; no script/gateway error |
| Engine character + real DEV P2 | Out-of-range rejection; survey → claim/attempt → Secure Point → atomic regional evidence → active return objective → Starter Mastery PASS |
| Economy/access | Real fixture production settles 720 Energy at a controlled valid 7200-second boundary; Mid B then Mid A debit 100 each, historic retries unchanged, wallet 520; Advanced blocked without Mid mastery |
| Actual client RemoteEvent negatives/readback | Forged mastery and position/region fields reject `REJECT_VALIDATION_PAYLOAD`; Class A world resync reports only Starter mastery and revision 9 |
| Real DEV before-/after-write cut points | Each fresh scope restores exactly the accepted first-visit candidate via Class A resync after the avatar departs; duplicate adds no progress or reward; save/release preserves proof |
| Fresh Play/server rejoin | Shipped ProfileRuntimeService restores world history, exact ownership, wallet and both receipts; two old requests return AlreadyCommitted; Advanced remains blocked |
| Static/local gates | StyLua, Selene, dependency/integrity checks, 28 Python CI tests, Rojo build/sourcemap and zero Luau type errors PASS |
| Final Edit parity/cleanup | 80/80 source files match; four authored objects retained; two expected tags/bindings; native probe folders/remotes removed |

The native spatial probe moves the actual Studio avatar under server control and uses the engine's observed root/humanoid and authored points. Mid fixture tests exercise actual domain/capture actions with real world evidence, not injected completion booleans; they do not assert that Mid maps exist. Controlled production time belongs only to the isolated test harness. No solo Studio result is substituted for L1 or a supported real-client performance run.

## Remaining ownership

Next dependency: author the remaining canonical biome/content and safe-utility bindings, then region-scoped spawn scheduling; travel/recovery/hazards and full scaling remain phase work. Mid mastery recipes and actions stay unavailable until their actual content is authored and validated. Existing topology and non-premium/active progression rules constrain that work.

**VS1-19 / AD-249 remains DEFERRED — environment limitation. Full controlled L0/L1, L1 30 players at MaxPlayers=60, repetitions and supported real-client frame/memory evidence must actually run and pass before IMP-10 COMPLETE.** IMP-11 cannot start while IMP-10 remains open.
