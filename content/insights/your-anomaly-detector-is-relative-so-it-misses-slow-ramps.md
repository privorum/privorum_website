---
title: "Your anomaly detector is relative, so it misses slow ramps"
description: "Baseline-relative cost alerts stay quiet when spend climbs slowly, and they can be noisy at low volume. Add absolute limits, floors and a provider health check."
date: 2026-09-19T12:00:00+02:00
tags: ["llm", "cost", "monitoring", "alerting"]
keywords: ["llm cost anomaly detection", "relative vs absolute alert threshold", "slow ramp alert missed", "llm spend alerting"]
series: "LLM operations"
toc: false
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

A common design for a cost alert is relative. Each hour, compare the current spend with a rolling baseline, such as the last seven days, and flag it when it exceeds a multiple. It adapts to your traffic and needs no tuning per feature.

It has two weaknesses, and we hit both.

## Weakness 1: it cannot see a slow ramp

If spend grows gradually, the baseline grows with it. Each hour looks normal against the days before, so the ratio never crosses the threshold. A runaway that grew slowly was one cause of the gap between our recorded cost and our invoice ([the trigger loop behind it](/insights/llm-cost-tracking-wrong-both-directions/)), and our own notes conclude that a relative detector would not have caught it.

**Add an absolute limit.** A per-day spend limit, or a per-feature one, does not care what the baseline did. It answers a different question: "is this too much, whatever it was yesterday?" We have a daily limit alert of this kind alongside the relative detector. Use both.

## Weakness 2: it is noisy at low volume

The other problem runs the opposite way. When normal spend is tiny, a fluctuation from almost nothing to a little is a large ratio. Our detector produced a long list of "critical" anomalies for amounts that were fractions of a cent, and none of them were ever acknowledged. An alert nobody reads is worse than no alert, because it teaches people to ignore the channel.

**Add a floor.** Require a minimum absolute spend before the ratio test can fire. Keep it configurable, and allow setting it to zero to disable. To be clear about what it does: a floor **reduces noise**. It does not fix the slow-ramp problem. Those need different tools, and mixing them up gives you false confidence.

## Weakness 3: spend can go down when things break

A third case is the reverse of a runaway. If a provider runs out of credits, your requests start to fail, and your **spend falls**. A spend-based detector cannot catch that. Watch provider health separately, for example the success rate of calls over a window, with an alert on consecutive failing checks.

## A short recipe

- A relative detector for sudden changes.
- An absolute limit per day and per feature for slow growth.
- A minimum-spend floor so the relative detector is not noise.
- A provider health check for outages that reduce spend.
- A rule that every alert is acknowledged or the threshold is fixed.

If you want a second opinion on your LLM cost monitoring, [get in touch](/contact/).
