# Success Criteria and Product Gates

> **Status:** Design Complete  
> **Owning phase:** GDS-1  
> **Authority:** Product-level success hierarchy, validation gates, and pivot/scale criteria

## 1. Success Hierarchy

MonsterVault optimizes product health in this order:

1. **player comprehension and satisfaction**;
2. **retention**;
3. **meaningful engagement**;
4. **intentional social/co-play value**;
5. **acquisition/discovery conversion**;
6. **monetization**.

Revenue is a project goal, but monetization is not allowed to compensate for a weak core loop or to override player trust.

## 2. Why Relative Benchmarks Are Authoritative

Roblox comparable-experience benchmarks change over time and vary by player population. Therefore, GDS-1 does **not** lock universal static D1/D7 percentages as permanent product truth.

When Creator Analytics exposes a relevant similar-experience benchmark, MonsterVault should evaluate itself relative to that benchmark at the time of testing.

Static internal funnel targets below remain useful because they measure MonsterVault-specific product promises rather than platform-wide category performance.

## 3. Closed-Playtest First-Session Gate

Before public scaling, controlled playtests should demonstrate all of the following on a representative first-time-player sample:

- at least **80%** can identify the immediate gameplay goal without external developer explanation;
- at least **75%** complete or meaningfully participate in a first capture within **3 minutes**;
- at least **60%** complete the first full `capture -> secure/return -> visible progression choice` loop within **8 minutes**;
- at least **60%** complete **two meaningful capture/progression loops** within the first **15 minutes**, unless the tested content intentionally replaces the second loop with a server event;
- at least **70%** can identify a concrete desirable next goal after the first progression choice;
- at least **50%** spontaneously express interest in a specific rarer creature, mutation, biome, vault milestone, event reward, or other collection/progression aspiration.

These are product validation targets, not permanent live-game KPI targets.

## 4. Public Alpha/Beta Product Gate

Once sufficient Creator Analytics data exists, the experience should not be scaled aggressively unless the following are true for representative organic cohorts:

### Acquisition / first impression

- Home Recommendation play-through rate is at or above the **50th percentile** of relevant similar-experience benchmarks, after reasonable packaging iteration.
- `<60 second` and `61–180 second` first-play bounce rates are not materially worse than relevant benchmark expectations.

### Retention

- D1 retention is at or above the **50th percentile** of relevant similar-experience benchmarks.
- D7 retention is at or above the **50th percentile** once enough cohort data exists.
- D30 is monitored as a long-term health signal once the product has existed long enough, but is not required to begin small-scale testing.

### Engagement

- average session time is at or above the **50th percentile** of relevant similar-experience benchmarks;
- first-session funnel behavior remains consistent with the product promise;
- longer session time does not come primarily from AFK waiting, forced timers, or friction.

### Social value

- intentional co-play behavior should show a positive and sustained signal after social systems are available;
- player feedback should indicate that other players create memorable opportunities, status, cooperation, or competition rather than primarily frustration.

## 5. Production Expansion Gate

Large content-production investment should begin only when:

1. the first-session internal gate passes or has a documented, evidence-based exception;
2. D1 retention is at least benchmark-median for a stable measurement period;
3. D7 retention is at least benchmark-median once statistically meaningful;
4. average session time is at least benchmark-median;
5. play-through rate can be brought to at least benchmark-median through honest packaging;
6. qualitative testing shows genuine collection desire rather than players progressing only for currency numbers;
7. no high-severity fairness, griefing, persistence-loss, or monetization issue undermines trust.

A stretch target is to move **two or more** of the core acquisition/retention/engagement metrics into roughly the top quartile of the relevant benchmark set before committing to aggressive user-acquisition spending.

## 6. Monetization Gate

Monetization may be prototyped during design/testing, but it is not considered a product success signal until the core loop is healthy.

Scaled monetization work should follow evidence that:

- players understand and enjoy the core loop;
- collection/progression desire exists without payment;
- D1/session health is competitive;
- purchases can add convenience, expression, status, or bounded acceleration without invalidating earned progress.

Payer conversion, ARPPU, and ARPDAU are later commercial KPIs, but a monetization improvement is rejected if it materially damages retention, satisfaction, or fairness.

Exact monetization experiments are owned by GDS-13/GDS-16.

## 7. Discovery Packaging Rule

Icons, thumbnails, title text, and description should maximize truthful play-through rather than misrepresent gameplay.

A packaging variant is invalid if it improves clicks by promising a feature, reward, conflict level, or visual fantasy that the actual experience does not deliver.

Detailed experimentation belongs to GDS-16.

## 8. Pivot Gate

The project should reconsider or materially redesign the core loop before large-scale production if, after **three substantive gameplay/UX iterations**:

- first-session comprehension remains weak;
- first capture/progression timing remains materially outside the intended experience promise;
- D1 retention remains materially below similar-experience median;
- testers show weak desire for rarer creatures/variants or visible collection progression;
- social interactions are primarily frustrating rather than additive.

The correct response to a failed product hypothesis is to change the product, not to compensate with more content, larger rewards, aggressive notifications, or stronger monetization pressure.

## 9. Commercial Success Definition

MonsterVault's long-term commercial goal is a self-sustaining Roblox experience with enough organic retention and discovery to support continued live content and creator revenue.

GDS-1 deliberately does not define a fixed DAU or Robux target as a design-completion requirement because audience acquisition depends on market conditions, release timing, marketing, platform distribution, and later live-operations execution.

The game is considered product-healthy when users voluntarily return, pursue collection goals, play meaningfully with others, respond to honest discovery packaging, and convert to paid products without those paid products being necessary to make the core experience enjoyable.
