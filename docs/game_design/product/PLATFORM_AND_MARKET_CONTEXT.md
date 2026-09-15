# Roblox Platform and Market Context

> **Status:** Supporting evidence — not gameplay authority  
> **Owning phase:** GDS-1 research context  
> **Last reviewed:** 2026-09-15

This document records the external Roblox context used while resolving GDS-1. It is intentionally **not** an authoritative gameplay specification. Platform behavior changes over time; external changes do not silently rewrite MonsterVault's GDS.

## 1. Discovery Context

Roblox Creator Hub states that Home/Recommended for You discovery uses engagement, retention, and monetization signals. The most important listed signals include:

- play-through rate;
- first-play bounce rate, including `<60s` and `61–180s` segments;
- play days per user;
- playtime per user.

Important additional signals include intentional co-play days, qualified play sessions, spend days, and Robux spent per user.

The documentation also states that these signals are evaluated per user, so small experiences are not inherently disadvantaged merely because they have fewer total players.

**Product implication:** MonsterVault should optimize for genuine first-session value, repeat play, and social value rather than trying to manufacture raw session length.

Source: Roblox Creator Hub — Discovery  
https://create.roblox.com/docs/discovery

## 2. Analytics and Growth Order

Roblox's analytics guidance recommends optimizing retention, engagement, and monetization before aggressively scaling acquisition. It identifies D1 retention and average session time as early priorities, followed by D7/D30 retention and monetization KPIs such as payer conversion and ARPPU.

Creator Analytics also provides similar-experience benchmarks that update over time.

**Product implication:** GDS-1 uses benchmark-relative public product gates instead of pretending one permanent static D1/D7 percentage applies to every future Roblox cohort.

Sources:

- https://create.roblox.com/docs/production/analytics
- https://create.roblox.com/docs/production/analytics/analytics-dashboard
- https://create.roblox.com/docs/get-started/strategies

## 3. Age-Based Roblox Accounts

Roblox globally rolled out age-based account experiences in June 2026:

- Roblox Kids: ages 5–8;
- Roblox Select: ages 9–15;
- standard Roblox accounts: age 16+.

Roblox Select users have access to selected experiences up to the platform's Moderate content maturity level, subject to Roblox's ongoing selection/review framework. Communication capabilities vary by age/region and age-check state.

**Product implication:** Targeting approximately 9–15 as the primary audience is commercially sensible, but the game should not make unrestricted communication essential to the core progression loop. Exact maturity/safety requirements remain owned by GDS-15.

Sources:

- Roblox Corporation, 2026-06-16 — Roblox Kids and Roblox Select Accounts Now Available Worldwide  
  https://ir.roblox.com/news/news-details/2026/Roblox-Kids-and-Roblox-Select-Accounts-Now-Available-Worldwide/default.aspx
- Roblox Corporation, 2026-04-13 — Roblox Introduces New Age-Based Accounts and Expanded Parental Controls for Users Under 16  
  https://ir.roblox.com/news/news-details/2026/Roblox-Introduces-New-Age-Based-Accounts-and-Expanded-Parental-Controls-for-Users-Under-16/default.aspx

## 4. Monetization Context

Roblox Creator Hub warns that poorly received monetization strategies can produce negative player feedback and recommends designing monetization around player value rather than simply blocking play.

**Product implication:** MonsterVault places retention/player trust ahead of short-term spend optimization and reserves exact paid advantages/prices for GDS-13.

Source: Roblox Creator Hub — Monetization  
https://create.roblox.com/docs/production/monetization

## 5. Engagement Context

Roblox's engagement guidance emphasizes getting users into the fun quickly because joining/leaving friction is low. Creator Analytics includes New User First Session Retention and can expose early drop-off after onboarding changes.

**Product implication:** MonsterVault's time-to-fun requirements are product-level constraints, while exact onboarding steps remain owned by GDS-3/GDS-14.

Source: Roblox Creator Hub — Engagement  
https://create.roblox.com/docs/production/analytics/engagement

## 6. Evidence Freshness Rule

This evidence should be revisited during:

- GDS-15 platform/safety work;
- GDS-16 retention/discovery/analytics work;
- final GDS-17 audit;
- pre-release production planning.

If Roblox changes its discovery, age-account, monetization, or analytics systems, later specifications should update the evidence and determine whether any **explicit MonsterVault design decision** must change through normal change control.
