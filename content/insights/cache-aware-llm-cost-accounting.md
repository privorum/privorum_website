---
title: "Cache-aware LLM cost accounting"
description: "Cached-token discounts are easy to model wrong. The tolerant parsing, the zero-default trap and the tests that keep per-call LLM cost honest."
date: 2026-09-19T11:50:00+02:00
tags: ["llm", "cost", "caching", "observability"]
keywords: ["llm prompt caching cost", "cached tokens cost calculation", "openai cached_tokens usage", "llm cost tracking implementation"]
series: "LLM operations"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

The companion piece, [Your LLM cost tracking is probably wrong in both directions](/insights/llm-cost-tracking-wrong-both-directions/), explains why recorded cost drifts from the invoice. This one is about the implementation: how to add a cached-token discount without breaking the rest of your cost tracking.

## Read the cached count defensively

With an OpenAI-style API, the usage object can carry the number of cached input tokens in an optional details field. In practice that field can be a number, an explicit `null`, or missing entirely. In our own recorded responses, most did not carry the details object at all, and some carried it as `null`.

Model that honestly. In a typed language, use an optional value, so `null` and "absent" mean the same thing: no cached count reported. Do the same on the streaming path, where usage usually arrives in a separate final chunk.

Then check the semantics for each provider. In the OpenAI style, cached tokens are a **subset** of the prompt tokens. Another provider reports cached reads and cache writes as counters **separate** from input tokens. If you add them up wrongly, you either double count or lose them.

## Clamp, and fall back safely

Compute cost from three parts: uncached input, cached input and output. Protect the arithmetic:

```python
def cost(input_tokens, cached_tokens, output_tokens, price):
    cached = max(0, min(cached_tokens, input_tokens))   # a malformed payload cannot go negative
    cached_rate = price.cached_input if price.cached_input > 0 else price.input
    return ((input_tokens - cached) * price.input
            + cached * cached_rate
            + output_tokens * price.output) / 1_000_000
```

Two properties are worth testing: with zero cached tokens, the new function must return exactly what the old one did, and with a bad payload it must not produce a negative number.

## The zero-default trap

When you add a "cached input price" field to a price table, every existing entry gets that field's default, which is zero. Zero is a valid price, so nothing fails. Every cached token is now billed at nothing.

Two defences:

- **Populate every entry on purpose.** Where you know the discount from an invoice, use it. Where you do not, set the cached price equal to the normal input price, so the discount is zero, not the price. Never apply a blanket ratio you have not verified.
- **Add a test over the whole table** asserting that the cached price is above zero and not above the input price.

## Make sure every call site applies the cost

The bug that cost us the most time was structural. Cost was applied inside one wrapper. Code that called a provider directly skipped the wrapper, so its calls were recorded at zero cost. We patched call sites one at a time three times before consolidating it into one function.

The lasting fix was a **static-analysis test** that scans the source and fails if any direct provider call is not followed by the cost function. Price the retry call too, or you will log tokens without dollars.

## Reconcile against the invoice

The full check is a daily comparison of your recorded total with the provider's invoice. We do not yet have this automated, and we recommend it: it is the only test that catches all of the above at once. Until you have it, the tests above are your protection.

If you want help getting LLM cost accounting right, [get in touch](/contact/).
