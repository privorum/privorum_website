---
title: "Our fallback hid an outage for weeks"
description: "A cheap model failed every request, a fallback to a stronger model kept users happy, and only an unrelated code path noticed. What to monitor and how to test."
date: 2026-09-19T09:00:00+02:00
tags: ["llm", "reliability", "fallback", "monitoring"]
keywords: ["llm fallback model", "llm router model fallback", "silent failure llm production", "llm monitoring fallback rate"]
series: "LLM tool calling in production"
toc: true
source_product: "www.nevergoblank.com"
source_url: "https://www.nevergoblank.com/"
related_service: "ai-workflows"
---

A common way to control LLM cost is a two-tier setup: a small, cheap model handles routing and simple steps, and a stronger model sits behind it as a fallback. If the cheap model errors, the request is retried on the stronger one and the user never notices.

That last part is the problem. We ran this setup with a cheap model that rejected every single request, and users saw normal answers for weeks.

## What happened

We had switched the cheap tier to a new open-weight model behind an OpenAI-compatible provider. From the day it was deployed, that model returned an HTTP 400 on every request. Every call fell through to the stronger model, which answered correctly. Chat looked healthy.

It surfaced through a different code path. A secondary step in the same flow also used the cheap model, but it had no fallback. There the 400 was retried by the client until a fixed time budget ran out, and what we saw in the logs was not "bad request". It was a generic timeout.

Two lessons sit inside that one story:

1. A fallback that works is indistinguishable from a system that works, unless you measure it.
2. A fallback that covers most paths but not all of them turns a total failure into an intermittent, confusing one.

## Why fallbacks hide failures

A fallback is designed so that the failure is invisible to the caller. That is the feature. But the same design removes the signal you would normally use to notice a broken dependency: user complaints, error rates, failed requests.

What remains is a warning-level log line per request. A log line that fires on every request is background noise by the second day.

## What to change

**Track the fallback rate as a metric.** Count how often the primary tier failed and the fallback answered. This is a ratio, and a healthy value is close to zero.

**Alert on sustained fallback, not on individual fallbacks.** One fallback is expected. A high rate sustained over an hour is a broken dependency. Here is the shape of a rule, in pseudocode:

```text
alert if fallback_rate(cheap_tier) > 0.5 for 1h
```

Choose the numbers for your own traffic. The point is that "the fallback is working" and "the primary is down" need different names.

**List every caller of the cheap tier.** Fallback logic tends to be added to the main path and forgotten on the others: summarizers, self-checks, background jobs. Grep for the model configuration key and check each call site for the same failure handling.

**Do not retry client errors.** A 400 means the request is wrong. Retrying it cannot help, and it burns the time budget you needed for the fallback. Classify errors as retryable (timeouts, 429, 5xx) or permanent (most 4xx), and fail over immediately on permanent ones.

**Add a live smoke test for every configured model.** Send a trivial request to each model ID in your configuration and assert a non-empty answer. Run it before a model swap and on a schedule. A fallback masks a dead model in production, so the test has to bypass the fallback. We cover this in [Catalog metadata is not a health check](/insights/catalog-metadata-is-not-a-health-check/).

## How the model got selected

The cheap model was chosen by a benchmark that could not detect the failure. That is a separate story, in [The eval that scored 100% with zero tool calls](/insights/eval-scored-100-percent-with-zero-tool-calls/). The two together are the real lesson: a weak selection gate let a broken model in, and a working fallback let it stay.

## A checklist

- Is the fallback rate a metric you can graph?
- Does an alert fire when it stays high?
- Does every call site of the primary have the same failover?
- Are client errors excluded from retries?
- Does a test call each configured model directly, without the fallback?

If any answer is no, a failure in that place will be quiet.

If you are designing an LLM workflow and want it reviewed for failure modes like this one, [get in touch](/contact/).
