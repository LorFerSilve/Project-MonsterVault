# TA-17 Decision Index

> **Status:** Accepted
> **Date:** 2026-09-24
> **Owning phase:** TA-17

| ID | Decision |
|---|---|
| AD-229 | Lock Rokit 1.2.0, Rojo 7.7.0, luau-lsp 1.70.0, StyLua 2.5.2 and Selene 0.31.0. |
| AD-230 | Keep zero third-party runtime Luau packages and no runtime package manager at baseline. |
| AD-231 | Adopt Lune 0.10.5 as dev/test-only deterministic runner. |
| AD-232 | Lock Rojo mapping, local-only serve address and TA-14 streaming properties in default.project.json. |
| AD-233 | Lock protocol generation V1 with Command/Event/UnreliableEvent central transports and registered route IDs. |
| AD-234 | Lock profile schema v1 and PlayerProfile/TradeJournal/ReceiptJournal environment-scoped store namespaces. |
| AD-235 | Lock DEV/STG/PROD logical tags and prohibit fabricated external Roblox IDs in source. |
| AD-236 | Lock server/client/shared physical layers and module/service dependency graph. |
| AD-237 | Select VS-1 Trusted Join -> Capture -> Secure Ownership -> Rejoin as first vertical slice. |
| AD-238 | Lock dependency-driven IMP-1..IMP-15 implementation sequence. |
| AD-239 | Add CI / static-build public-PR workflow with immutable action pins and read-only token. |
| AD-240 | Require tests/runner.luau before any runtime Luau is accepted. |
| AD-241 | Keep privileged Studio/staging/performance evidence outside untrusted PR trust context. |
| AD-242 | Use PR-based implementation flow and squash merge by default; no ordinary direct main pushes. |
| AD-243 | Treat protocol/profile breaking changes as explicit versioned compatibility events. |
| AD-244 | Lock implementation Definition of Done to code + tests + traceability + performance/security evidence. |
| AD-245 | Keep TA-15 C0/C1 and TA-14 hard guards as release blockers after implementation opens. |
| AD-246 | Reopen the owning TA/GDS rather than weakening locked semantics when implementation evidence exposes conflict. |
| AD-247 | Open implementation only after TA-17 closure; external deployment IDs may remain unconfigured without blocking DEV coding. |
| AD-248 | Close TA-17 and advance the project to IMP-1 — Contracts and Test Harness. |
| AD-249 | Accept the owner-authorized VS1-19 environment deferral: IMP-8 COMPLETE with deferred validation, IMP-9 OPEN, full 30-player L1 and real-client performance mandatory before IMP-10 COMPLETE. |
| AD-250 | Register the additive V1 Vault.ResolveOverflow route, bounded Vault projection and explicit capacity-domain migration; retain server authority, P2 recovery and protected production settlement. |
| AD-251 | Register canonical Display/Production assignments, bounded owner pages, versioned production state, epoch settlement and save/rejoin recovery; Energy/progression remains the next IMP-9 dependency. |
| AD-252 | Bind the versioned Energy wallet and exact-once Production Claim, revision-bound receipts and authoritative readback; progression remains open. |
| AD-253 | Bind opaque server quotes, strict purchase confirmation, one atomic Energy debit/capacity unlock and permanent receipts through the existing P2 writer; remaining progression catalog and full IMP-9 gates remain open. |
| AD-254 | Complete the bounded TA-8 Vault/Capture/Access catalog and prospective effects through existing P2 purchases; register compact selected quotes and protected mastery ownership; close the full IMP-9 audit and permit IMP-10 OPEN, retaining VS1-19 before its completion. |
| AD-255 | Bind server world/content registries, existing authored Starter actions, the actual persistent mastery owner and TA-8 access/action authority; register compatible World V1 state and Class A recovery; first IMP-10 dependency PASS while full content/scaling and VS1-19 remain open. |

**Decision index result: ACCEPTED.**
