# MonsterVault Game Overview

> **Status:** Design Complete  
> **Owning GDS phase:** GDS-1 — Product Vision, Audience, and Success Criteria  
> **Authority:** High-level product identity and core experience structure

## 1. Working Title

**MonsterVault**

The repository name remains `Project-MonsterVault`; the consumer-facing title may change later without changing the product contract if the new title preserves the same design identity.

## 2. Genre

MonsterVault is a **multiplayer social creature-collection and progression adventure** on Roblox.

It combines:

- exploration and discovery;
- active creature capture;
- persistent collection;
- a visible personal vault/laboratory;
- rarity and mutations/variants;
- progression and biome unlocks;
- server-wide encounters/events;
- bounded competition and optional cooperation;
- later secure trading;
- ongoing live-content expansion.

## 3. Core Player Fantasy

The player is an explorer, creature hunter, collector, and vault owner.

The short-term fantasy is:

> **I saw something desirable, figured out how to capture it, and brought it home.**

The long-term fantasy is:

> **I built a recognizable vault filled with creatures and rare variants that show how far I have progressed and what I have discovered.**

MonsterVault should make the player's collection feel earned, visible, personal, and worth improving.

## 4. Product Promise

> **Find it. Catch it. Bring it home. Make your vault legendary.**

Every major baseline system must strengthen at least one part of that promise.

## 5. Target Audience

Primary audience:

- Roblox players approximately **9–15**;
- collection/progression-oriented;
- comfortable with short-to-medium gameplay loops;
- motivated by rarity, visible status, unlocks, events, and friends;
- not expected to tolerate heavy tutorials, complex reading, or precision-heavy controls.

Secondary audience:

- older teens and young adults, approximately **16–24+**, especially completionists, optimizers, rarity hunters, event players, and future traders.

Players aged 5–8 are not the primary target, though the product should avoid unnecessary content or complexity that would prevent broad platform accessibility where practical.

Detailed audience/platform rules are owned by [`product/target_audience_and_platform.md`](product/target_audience_and_platform.md).

## 6. Platform Position

MonsterVault uses a **mobile-first interaction constraint with cross-platform gameplay parity**.

The baseline game must be playable without:

- mouse/keyboard-only actions;
- tiny precision UI;
- high-accuracy aiming as a universal progression requirement;
- unrestricted free-form chat;
- voice communication.

Desktop, tablet, mobile, and console players should participate in the same fundamental collection/progression game.

## 7. Tone

The intended tone is:

- colorful;
- energetic;
- slightly mysterious;
- playful;
- aspirational;
- collectible/status-driven.

The game is not positioned as horror, realistic violence, or a mature social hangout.

## 8. Core Gameplay Loop

```text
Choose or notice a desirable goal
            ↓
Explore the current world/biome
            ↓
Discover a creature or opportunity
            ↓
Attempt capture
            ↓
Secure / return the acquired value
            ↓
Add to collection / vault progression
            ↓
Improve capability, capacity, access, or status
            ↓
Pursue rarer creatures / variants / events / regions
            ↓
Repeat
```

The exact capture state machine, ownership-transfer point, economy rewards, rarity rules, transport mechanics, and event logic remain owned by later GDS phases.

## 9. Product Pillars

### 9.1 Immediate comprehension

The player should quickly understand what can be done now and what desirable thing can be pursued next.

### 9.2 Collection desire

Creatures must be desirable as possessions, not merely passive numerical generators.

### 9.3 Visible progression

Progress should be observable through collection, vault state, access, capabilities, cosmetics/status, and increasingly desirable goals.

### 9.4 Active acquisition

The product should reward exploration, timing, choices, capture skill/knowledge, and event participation rather than becoming primarily a menu or idle experience.

### 9.5 Social stories

Other players should create memorable opportunities for cooperation, competition, status, or shared events without making punitive loss the product's defining emotion.

### 9.6 Live-content extensibility

New creatures, variants, biomes, events, and progression goals should extend the same game instead of requiring a replacement core loop.

### 9.7 Commercial sustainability with player trust

The product should eventually monetize successfully without making payment mandatory for ordinary collection progress or making free-earned value strategically irrelevant.

## 10. Differentiation

MonsterVault is not designed as another generic pet simulator or a direct steal-game clone.

Its high-level differentiation combines:

- world-based active acquisition;
- individual collectible identity;
- a persistent visible vault/home for the collection;
- mutation/variant hunting;
- shared high-value server moments;
- socially legible status;
- later secure trading;
- competition that is exciting without defaulting to permanent loss of already-secured collections.

The authoritative differentiation contract is owned by [`product/market_positioning_and_differentiation.md`](product/market_positioning_and_differentiation.md).

## 11. Competition Boundary

MonsterVault is **socially competitive but not loss-dominant**.

Competition may exist around discovery, timing, capture opportunities, events, collection completion, or optional risk modes.

The baseline product does **not** require unrestricted theft of already-secured persistent creatures. Direct combat PvP is not a core product requirement.

GDS-5 and GDS-10 own the exact contesting/interception/PvP rules.

## 12. Session Shape

The intended normal session is approximately **10–25 minutes**, while meaningful progress should remain possible in a **3–5 minute** short session and longer voluntary play should support **30–60 minute** sessions.

First-session product targets include:

- a meaningful visible goal within roughly 30–45 seconds;
- a first real capture attempt within roughly 60 seconds;
- a secured first creature within roughly 3 minutes;
- a first visible progression choice within roughly 6 minutes.

Detailed pacing authority is owned by [`product/session_shape_and_experience_promise.md`](product/session_shape_and_experience_promise.md).

## 13. Long-Term Progression

The product should support meaningful aspirations across **weeks to months** through:

- collection completion;
- rare variants;
- vault development;
- biome/access progression;
- rotating events/content;
- social status;
- later trading/value discovery.

Infinite stat inflation or prestige resets are not GDS-1 requirements.

## 14. Trading Position

Trading is strategically desirable but **not launch-critical**.

It should only ship once ownership, persistence, value integrity, scam resistance, and atomic transfer behavior are mature enough to protect the collection economy.

GDS-12 owns the detailed decision.

## 15. Monetization Position

MonsterVault targets **moderate, visible-but-non-coercive monetization**.

High-level acceptable directions include cosmetics, status, vault themes, viable capacity convenience, bounded acceleration, starter value, and server-wide value.

High-level prohibited directions include making the rarest/strongest collection path primarily pay-only, making normal free progression intentionally painful, or invalidating earned value through overwhelming permanent paid advantages.

GDS-13 owns exact products and prices.

## 16. Live-Operations Position

The game should support frequent small content additions and rotating/shared opportunities. A roughly weekly small-update/event capability is a desirable production target, not a hard promise for every week.

Exact cadence is owned by GDS-11/GDS-16.

## 17. Product Success Model

MonsterVault evaluates success in this priority order:

1. player comprehension/satisfaction;
2. retention;
3. meaningful engagement;
4. intentional social value;
5. acquisition/discovery conversion;
6. monetization.

Internal first-session funnel targets and benchmark-relative public-product gates are defined in [`product/success_criteria_and_product_gates.md`](product/success_criteria_and_product_gates.md).

The project should pivot before large-scale content production if repeated iteration cannot create competitive retention and genuine collection desire.

## 18. Scope Philosophy

The game becomes deep through reusable interconnected systems and content variety, not by adding unrelated mechanics.

Baseline non-goals include:

- narrative campaign;
- combat-first PvP;
- ranked competitive ladders;
- clans/guild warfare;
- large-scale MMO simulation;
- complex crafting trees;
- breeding/fusion as a guaranteed baseline;
- unrestricted theft of secured collections;
- photorealism;
- building a general-purpose Roblox framework as the main product.

Detailed scope/commercial boundaries are owned by [`product/scope_and_commercial_boundaries.md`](product/scope_and_commercial_boundaries.md).

## 19. Vertical Slice Position

The original one-biome/limited-creature vertical-slice proposal remains historical planning input only.

GDS-1 intentionally does not lock exact content counts. The final implementation vertical slice will be derived after later gameplay specifications and Technical Architecture identify the smallest slice capable of proving the complete product promise safely.

## 20. GDS-1 Completion State

All high-level product questions previously listed in this document have authoritative answers or explicitly assigned downstream owners.

No unresolved question remains that can change:

- primary audience;
- device priority;
- product fantasy;
- product category/differentiation;
- competitive intensity;
- session promise;
- long-term progression intent;
- trading launch position;
- monetization intensity;
- live-ops intent;
- product success hierarchy;
- high-level scope/non-goals.

Detailed mechanics remain intentionally unresolved under their owning later GDS phases.
