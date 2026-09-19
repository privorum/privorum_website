---
title: "How to qualify an LLM router model: hard gates before cost"
description: "Sorting candidate models by price first surfaces broken ones. Disqualify on failures, then rank on cost and latency. The gates, the process and the traps."
date: 2026-09-19T10:00:00+02:00
tags: ["llm", "evals", "model-selection", "tool-calling"]
keywords: ["how to choose an llm router model", "llm model qualification", "cheap llm for tool calling", "llm model selection checklist"]
series: "Evaluating models"
toc: true
source_product: "www.nevergoblank.com"
source_url: "https://www.nevergoblank.com/"
related_service: "ai-workflows"
---

A router model sits in front of an agent and handles the cheap, frequent decisions: which tool to call, whether to answer directly, when to hand off to a stronger model. It runs on every request, so cost and latency matter a lot. That makes it tempting to start the search from a price list.

We did that, and the cheapest candidates were the broken ones. This article is the process we would use now.

## Why price-first goes wrong

A model that fails early is cheap and fast. It stops after the first error, uses few tokens, and finishes quickly. If your ranking sorts by cost or latency, failure looks like efficiency. We covered one instance of this in [The 400 that only happens on the tool-result turn](/insights/the-400-that-only-happens-on-the-tool-result-turn/).

So the order matters. **Gates come first, ranking comes second.**

## The process

1. **Build the candidate list from the provider's catalog.** Filter on what the catalog says: chat completions, function calling, and a price ceiling you can live with. Treat this as a shortlist, not evidence. Catalog metadata is a claim, not a health check ([more here](/insights/catalog-metadata-is-not-a-health-check/)).
2. **Probe each candidate live.** One trivial request per model ID. Anything that errors is out.
3. **Run your real fixtures.** Use conversations that look like production, including multi-turn ones where a tool result is sent back and the model must continue.
4. **Apply hard gates.** A candidate that fails any gate is disqualified, however cheap.
5. **Rank the survivors** on cost, then latency.
6. **Shadow-deploy and watch.** After the swap, watch the fallback rate and the error logs for a fixed window before you call it done.

## The gates

These are the categories we gate on. Set thresholds for your own workload.

- **Any request failure.** An API error in a fixture is a disqualification, not a slow answer.
- **Zero tool calls** when a call was expected.
- **Malformed structure** in the tool calls the model does make.
- **An empty final answer.**
- **Runaway re-planning**, where the model proposes a plan, then proposes the same plan again instead of acting on it.
- **Excessive iterations** to finish a task.

The last two are easy to miss because nothing errors. In one sweep, a candidate had zero API failures and zero empty answers, and would have passed a naive check. Its problem was that it kept re-proposing the same plan on a large share of fixtures. It only showed up because we counted repeats as a metric of their own.

## Traps we hit

**A metric with an empty denominator.** Our structured-call rate reported 100% for a model that made no calls at all. The full story is in [The eval that scored 100% with zero tool calls](/insights/eval-scored-100-percent-with-zero-tool-calls/).

**Failures that were not part of the selection rule.** The harness counted API errors but the selection criteria did not include them. If a number is displayed but not gated on, it does not protect you.

**Free and promotional models.** Zero-price models in the catalog all had request failures in our sweep. They are often capacity-limited and not meant for production traffic.

**A small fixture set.** Ours was small. That is enough to disqualify a broken model, since a single failure is decisive. It is not enough to claim that two passing models are equally good, so do not over-read the ranking among survivors.

**A one-character mistake in the model ID.** A typo returned a not-found error while a static check looked fine. Only the live probe caught it.

## After you pick one

A good model choice can still be undone by a quiet failure later, so keep the safety net: track the fallback rate, alert on sustained fallback, and cover every code path that calls the router ([the outage that a fallback hid](/insights/fallback-hid-an-outage/)).

## A short checklist

- Is every candidate probed live before it is benchmarked?
- Do your fixtures include a tool-result continuation?
- Are failures, missing calls, empty answers and looping gates, not just columns?
- Does your ranking only run on survivors?
- Do you watch the swap after it ships?

If you would like help building a qualification harness for your own agent, [get in touch](/contact/).
