---
title: "Cheap router model plus stronger fallback: design and blind spots"
description: "A tiered LLM setup saves money until the fallback hides failures or quietly spends more. Design rules for tiers, and the blind spots that break them."
date: 2026-09-19T11:20:00+02:00
tags: ["llm", "agents", "fallback", "cost"]
keywords: ["llm model routing", "cheap model fallback strong model", "llm tiered models cost", "llm fallback design"]
series: "Agent design patterns"
toc: true
source_product: "www.nevergoblank.com"
source_url: "https://www.nevergoblank.com/"
related_service: "ai-workflows"
---

The pattern is common: a small, cheap model handles the frequent, simple steps, and a stronger, costlier model is the fallback when the small one fails. It saves money when it works. This article is about the design decisions and blind spots, and it links to the story of how the pattern failed for us in [Our fallback hid an outage for weeks](/insights/fallback-hid-an-outage/).

## Design rules

**Fall back once, not in a loop.** On an error from the cheap tier, retry a single time on the stronger model. Repeated hops make latency unpredictable and cost invisible.

**Decide what the lowest tier does on failure.** If a free or low-priced tier can fall back to the expensive model, a failure in the cheap model becomes a cost spike that you pay for. The alternative is to retry the same model and never escalate. The trade-off is that a bad model then degrades those users' experience instead of your margin, so that choice needs the monitoring below.

**Keep the tiers separate in your config and metrics.** The router model and the primary model should be independent settings, and each should be labelled in logs and counters. If they share a name or a metric, you cannot tell which tier produced a result.

## Blind spots

**The fallback works, so nobody looks.** This is the central problem. The user sees a good answer whichever tier produced it. Track the fallback rate per tier, and page on a sustained high value. In our incident the failure was total for weeks; a rate alert now guards it.

**Some paths have no fallback.** Fallback logic usually lands on the main path. Secondary steps that call the cheap model, such as a self-check or a summary, can be left without it, and they turn a masked failure into an opaque timeout. Inventory every call site.

**Retrying the unretryable.** A client error (a 400) is a bug in the request or the model setup. If the client retries it, the retries eat the time budget the fallback needed. Fail over immediately on permanent errors.

**Catalog health is not model health.** A provider listing the model as available proves nothing about whether it serves requests. Probe it live ([Catalog metadata is not a health check](/insights/catalog-metadata-is-not-a-health-check/)).

**Single-turn tests pass, real conversations fail.** Test tool-result continuations ([the 400 that only happens on the tool-result turn](/insights/the-400-that-only-happens-on-the-tool-result-turn/)).

**A wrong price.** If the cheap tier's unit price is wrong in your cost table, budgets and dashboards are wrong too. We found a tenfold error on one model, which inflated its recorded spend.

## What we would set up first

1. A live probe for every configured model, run on a schedule.
2. A fallback-rate metric per tier with a sustained-rate alert.
3. A list of every call site of the cheap tier, each with the same failure handling.
4. A written rule for what the lowest tier does on failure.

If you want a review of a tiered LLM design, [get in touch](/contact/).
