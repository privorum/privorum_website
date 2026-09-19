---
title: "The eval that scored 100% with zero tool calls"
description: "A tool-calling benchmark reported a perfect score for a model that failed every request. An empty-denominator bug, and how to gate model selection properly."
date: 2026-09-19T09:10:00+02:00
tags: ["llm", "evals", "tool-calling", "testing"]
keywords: ["llm eval bug", "tool calling benchmark", "evaluating llm tool calling", "llm model selection tests"]
series: "LLM tool calling in production"
toc: false
source_product: "www.nevergoblank.com"
source_url: "https://www.nevergoblank.com/"
related_service: "ai-workflows"
---

We wrote a small harness to choose a cheap "router" model for an agent. It ran each candidate against a set of fixtures and reported a few metrics, including a structured call rate: of the tool calls the model made, how many were well-formed.

One candidate scored 100%. It had failed every request.

## The bug

The metric was a ratio of well-formed calls to total calls. When a model returns an API error on every request, it makes zero calls. The ratio has an empty denominator, and the code handled that case, in essence, like this:

```python
if total_calls > 0:
    rate = well_formed / total_calls
else:
    rate = 1.0  # no calls, nothing malformed
```

The reasoning sounds harmless: no calls means nothing was malformed. But it means the worst possible model, one that never answers, gets the best possible score.

The harness did count the API errors in a separate failures column. That column was not part of the selection criteria. So the model with the most failures could win the bake-off, and it did.

## The fix is small, the lesson is not

Change the empty case so that it cannot reward silence:

```python
if total_calls > 0:
    rate = well_formed / total_calls
elif failures > 0:
    rate = 0.0
else:
    rate = None  # undefined: do not rank on this metric
```

The wider fix is how you select models. A ranking should have hard gates first and tiebreakers after.

## Gate first, rank second

Disqualify on failure categories before you look at cost or speed. Categories worth gating on:

- **Any request failure.** An API error is not a slow success.
- **Zero tool calls when a tool call was expected.**
- **Malformed structure** in the calls the model does make.
- **An empty final answer.**
- **Runaway re-planning**, where the model repeats the same plan instead of acting on it.
- **Excessive iterations** to finish a task.

Only models that pass every gate get ranked, and then cost and latency decide. Choose your own thresholds for your workload.

## Make the harness prove itself

The cheapest protection is a canary: a stub "model" that always fails. Run it through the harness on every change and assert that it is disqualified. If the harness ever ranks the stub, you have found this class of bug before a real model paid the price.

A second canary is a stub that never calls a tool when it should. It should fail the "expected a call" gate.

## Read the failure column first

When you look at a leaderboard, read the failure and gate columns before the speed and cost columns. Models that fail early also look fast and cheap, because they stop early. We hit exactly that in [The 400 that only happens on the tool-result turn](/insights/the-400-that-only-happens-on-the-tool-result-turn/).

What the broken benchmark cost us is in [Our fallback hid an outage for weeks](/insights/fallback-hid-an-outage/).

If you are building an eval harness for an agent and want a second pair of eyes on it, [get in touch](/contact/).
