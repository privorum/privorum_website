---
title: "Your LLM cost tracking is probably wrong in both directions"
description: "Our recorded LLM cost did not match the provider invoice. Untracked trigger calls, cached-input discounts and missing prices each skew it. How to reconcile."
date: 2026-09-19T09:40:00+02:00
tags: ["llm", "cost", "observability", "operations"]
keywords: ["llm cost tracking", "llm cost accounting cached tokens", "llm bill higher than expected", "reconcile llm invoice"]
series: "LLM operations"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

We record the cost of every LLM call in our own database. When we compared that record with the provider's invoice, the invoice was higher than what we had recorded, and the difference was not explained by a price we had wrong.

Our first hypothesis was a unit-price error: an output rate that was too low in our table. The invoice disproved it. The real causes were different, and one of them pushed the error in the opposite direction.

## Cause 1: calls nobody was counting

An event handler was wired to fire an LLM call whenever a state-change event arrived. Inside one long-lived session it kept firing on every event.

Those calls used a free-tier model, and the provider layer for that tier reported a cost of zero. Nothing back-filled it. So the calls were real, billed, and recorded at zero.

Two things made this easy to miss. The feature that got blamed first was a different one that shared a word in its name. And the volume ramped slowly, so a relative alert (this hour against a multiple of last week's baseline) never crossed its threshold.

What helps:

- **Debounce event-driven LLM calls.** An event stream is not a request rate you control. Put a floor on how often a trigger can call a model.
- **Never record "unknown" as zero.** If a provider does not report cost, compute it from tokens or store it as unknown and count it.
- **Add an absolute limit per use case per day**, next to any relative detector.

## Cause 2: a discount your model ignores

Providers often bill cached input tokens at a fraction of the normal input rate. If your cost model applies one flat input rate to every input token, it over-estimates whenever caching is working.

In our data, a day with a high cache hit rate made the flat model come out well above the invoice for the same tokens. This error goes in the opposite direction from the first cause: the record is too high, not too low.

A cache-aware cost function separates the token classes:

```python
def cost(usage, price):
    uncached = usage.input_tokens - usage.cached_input_tokens
    return (
        uncached * price.input
        + usage.cached_input_tokens * price.cached_input
        + usage.output_tokens * price.output
    ) / 1_000_000
```

The catch is that this needs the provider to report the cached split. Check what the usage object in your provider's response actually contains, and whether the reported input count already includes cached tokens, before you build on it.

## Cause 3: prices that silently return zero

Two more failures, both quiet:

- **A model missing from the price table** returned a cost of zero instead of an error. Any model added to the code path before the table was updated was free, as far as our records went.
- **A wrong unit price**, in our case one entry off by a factor of ten, inflated the recorded cost of a model.

Make an unknown model a loud event, such as an error or a counter you alert on. Add a test that every model ID your configuration can select has a price entry.

## Reconcile against the invoice

The real check is a daily comparison: the sum of recorded cost across every table that stores LLM usage against the invoice total for that day. Many providers let you export a daily, per-model breakdown; check yours.

Run it, and expect the gap to be non-zero at first. Its size and sign tell you which cause you have:

- Recorded lower than billed: untracked calls or missing prices.
- Recorded higher than billed: caching ignored or a wrong unit price.

Fix the largest gap first, then rerun.

## Takeaway

Cost tracking is an integration between your code and someone else's billing model. Treat it like any other integration: test it, monitor it, and compare it to the source of truth on a schedule.

If you want help instrumenting and reconciling LLM cost in your own system, [get in touch](/contact/).
