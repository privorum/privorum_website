---
title: "Principles for caching LLM responses"
description: "What belongs in an LLM cache key, what must never be shared across users, and which results must not be cached at all. General principles from real near-misses."
date: 2026-09-19T13:00:00+02:00
tags: ["llm", "caching", "security", "cost"]
keywords: ["llm response caching", "llm cache key design", "cache llm responses per user", "semantic cache pitfalls"]
series: "Output guardrails"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

A cache in front of an LLM call can save real money and latency. It can also serve the wrong answer to the wrong person. These principles are general. We are deliberately not describing how our own keys are built.

## What belongs in the key

A cache key must contain everything that would change the answer. Missing an input means serving a stale or wrong answer with full confidence.

- **The prompt version.** When you change the prompt, old answers are invalid. If the key ignores the version, a prompt update does nothing until entries expire.
- **The actual inputs.** Include the data that goes into the prompt, not just an identifier that points at it. If the prompt contains live values, two requests with the same identifier but different values must not share an answer.
- **A freshness bucket.** A time window bounds staleness, so nothing is served forever.
- **Anything that changes the meaning.** For example a coarse state label, so that a regime change invalidates earlier answers.
- **Per-user settings that affect the prompt.** Two users with different preferences or profiles must not share one generated answer.

An early version of our own key ignored the prompt version and part of the context. A later review found it and fixed both. This is the most common failure: the key looks reasonable and quietly omits an input.

## What must not be shared across users

If a prompt depends on one user's data, the answer is that user's data. Sharing it is a privacy failure and an accuracy failure.

We caught a path where a key carrying only shared, market-wide inputs would have served one user's verdict about their own position to another user, whenever two positions on the same instrument fell in the same time bucket. The fix was to not cache that path at all.

The rule: if the prompt contains per-user or per-object detail that the key does not capture, do not cache the result. A cache that is safe only if you remember which paths to avoid will eventually be unsafe.

## What not to cache at all

- **Degraded results**: errors, parse failures, empty answers. A failure that gets cached becomes a permanent failure for the next caller, and can hide the real error.
- **Refusals** ([Refusals that return HTTP 200](/insights/refusals-that-return-http-200/)).
- **Requests where the user brings their own credentials**, if your cost or privacy model depends on it. Decide this explicitly.

## Concurrency and streaming

- **Coalesce concurrent duplicates.** When many identical requests arrive together, let one call go out and share its result.
- **Streaming is different.** Each streamer needs its own stream of chunks, so streaming requests should bypass the coalescing.

## Measure it

If you do not record hits and misses, you cannot tell whether the cache saves anything or hides bugs. Hit and miss counters were a top finding in one of our reviews before we fixed them.

## Checklist

- Does the key include the prompt version and every input in the prompt?
- Can two users ever share an answer that depends on one of them?
- Are errors, failures and refusals excluded?
- Are concurrent duplicates coalesced and streaming excluded?
- Do you record hits and misses?

If you are adding caching to an LLM feature and want it reviewed, [get in touch](/contact/).
