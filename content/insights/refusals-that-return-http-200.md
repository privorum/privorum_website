---
title: "Refusals that return HTTP 200"
description: "A model that refuses or has nothing to analyze still returns success. Treat a refusal as its own outcome, retry once, and keep it out of accuracy stats."
date: 2026-09-19T12:50:00+02:00
tags: ["llm", "guardrails", "reliability", "evals"]
keywords: ["llm refusal http 200", "llm non json response", "handle llm refusal", "llm parse error handling"]
series: "Output guardrails"
toc: false
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

You ask a model for a JSON analysis. It replies, with HTTP 200, "I don't see any data to analyze". The request succeeded, the provider reports no error, and your parser fails on prose.

This is a refusal or a non-answer, and it is not an error your transport layer knows about. That makes it easy to mishandle in several ways.

## Why the usual safety nets miss it

Your fallback logic and transport retries fire on errors. A 200 with unusable content has no error, so neither runs. Left alone, the refusal flows into your parser, then into a generic failure.

## Handle it as its own outcome

**Retry once, on the same provider.** A refusal is often a one-off. A single direct retry is cheap and frequently recovers.

**Never cache it.** If your responses go through a cache or request de-duplication, a refusal must bypass both, or you will serve the same refusal to the next caller.

**Measure whether the retry pays.** Count retries by outcome, recovered or exhausted. It answers a real question: does the retry earn its cost, or is it just doubling your spend?

## When the retry fails

Do not return a 500, and do not fake an ordinary answer. Return a **synthetic result with a distinct type**, such as a parse error with zero confidence and an unknown direction, so the caller can see what happened.

Record the incident once, after the retry, not on the first failure. We learned why: a flaky provider with per-attempt reporting would trigger defensive behaviour, such as a reflexive rise in a confidence threshold, for everyone.

## Keep it out of the statistics

Give the refusal its own type, separate from "insufficient data". They mean different things: the first is a failure to produce an answer, the second is a valid verdict. Then:

- Exclude refusals from the paths that grade accuracy or calibrate confidence, and from de-duplication, so a failure marker does not spread to other requests. We verified this for our grading and de-duplication paths.
- Guard against over-exclusion. A real "insufficient data" verdict from a real model is legitimate and stays in the statistics.

## Checklist

- Do you detect non-conforming content even when the status is 200?
- Is there exactly one retry, bypassing cache and de-duplication?
- Do you count recovered versus exhausted retries?
- Does a failed retry return a typed result instead of a 500?
- Are refusals excluded from accuracy stats, and real abstentions kept in?

If you want your model error handling reviewed, [get in touch](/contact/).
