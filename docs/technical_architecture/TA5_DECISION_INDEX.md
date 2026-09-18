# TA-5 Decision Index

> **Phase:** TA-5 — Identity, Content Registries, Configuration, and Data-Driven Content  
> **Status:** Accepted

## TA5-D01 — MonsterVault Owns Stable Semantic IDs

**Decision:** Persistent and cross-system semantic references use stable MonsterVault IDs, not display names, Studio paths, indexes or external Roblox IDs.

---

## TA5-D02 — Static IDs Use Lowercase Namespaced Opaque Strings

**Decision:** Canonical static IDs use a readable `<kind>/<slug>` form, but gameplay treats them as opaque typed IDs rather than parsing them for behavior.

---

## TA5-D03 — Shipped IDs Are Immutable and Never Reused

**Decision:** Renaming visible content does not rename its canonical ID. Retired IDs are never reassigned to unrelated content.

---

## TA5-D04 — Runtime Entity IDs Are Server-Generated GUID-Style IDs

**Decision:** CreatureInstanceId and comparable runtime identities are server-generated, globally unique enough for their semantic lifetime and never reused.

---

## TA5-D05 — Content Registries Are Typed, Declarative, Validated, and Immutable Per Server Snapshot

**Decision:** Canonical definitions contain data, not arbitrary executable gameplay callbacks. Invalid core content fails bootstrap closed.

---

## TA5-D06 — Public and Server-Private Registry Data Are Separate

**Decision:** Replicated definitions contain only disclosure-safe fields. Hidden probabilities, reward logic, security thresholds and authoritative commercial mappings remain server-private.

---

## TA5-D07 — Content Lifecycle Is Active / Retired / Tombstone

**Decision:** Existing persisted IDs remain resolvable after content stops being newly generated/offered.

**Consequence:** Deleting a referenced definition without migration/tombstone is prohibited.

---

## TA5-D08 — Existing Generated Identity Is Never Rerolled by Config Changes

**Decision:** Content/config changes apply prospectively. Creature Variant Identity and historical Event provenance remain stable.

---

## TA5-D09 — Configuration Fields Are Classified C0 / C1 / C2 / C3

**Decision:** Semantic invariants and static content cannot be silently modified through live configuration. TA-13 may update only explicitly allowlisted C2 fields through validated snapshots.

---

## TA5-D10 — External Roblox IDs Are Environment Bindings, Not Semantic Identity

**Decision:** ProductDefinitionId, CosmeticDefinitionId and other MonsterVault IDs remain stable across DEV/STAGING/PRODUCTION while platform IDs map per environment.

---

## TA5-D11 — Tags and Attributes Are World Authoring Metadata, Not the Content Database

**Decision:** CollectionService tags declare structural roles and safe attributes carry stable IDs. Replicated tags/attributes never contain hidden odds/security/private grant logic.

---

## TA5-D12 — ContentSnapshotId Tracks Validated Definition/Config Context

**Decision:** Downstream systems may pin snapshot identity where anti-reroll, provenance or event fairness require it.

---

## TA5-D13 — Registry Access Is Read-Only and Dependency-Injected

**Decision:** Domains consume narrow catalog interfaces. No mutable global registry singleton is introduced.

---

## TA5-D14 — Close TA-5 and Advance to TA-6

**Decision:** TA-5 is Architecture Complete — PASS with 180/180 scenarios and zero blocking questions. TA-6 becomes NEXT; gameplay implementation remains blocked.
