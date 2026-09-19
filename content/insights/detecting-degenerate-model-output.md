---
title: "Detecting degenerate model output"
description: "Repetition loops and garbled text can burn tokens and reach users. Detect them mid-stream, cancel, retry once at lower temperature, then degrade gracefully."
date: 2026-09-19T12:40:00+02:00
tags: ["llm", "guardrails", "streaming", "reliability"]
keywords: ["llm repetition loop", "detect garbled llm output", "llm degenerate output", "stop llm streaming garbage"]
series: "Output guardrails"
toc: false
source_product: "www.nevergoblank.com"
source_url: "https://www.nevergoblank.com/"
related_service: "ai-workflows"
---

Sometimes a model stops producing language. It repeats the same phrase, or emits a run of garbage, and keeps going until it hits the length limit. You pay for every token of that tail, and the user may see it.

This article describes an approach that works in general. It deliberately contains no thresholds: they depend on your model and your language mix, and you should set them from your own data.

## Detect two signals

**Pathological repetition.** The same substring repeated back to back many times. A regular expression is a poor tool for this, and many engines cannot express a back-reference at all, so write a scan.

**A high share of non-printable characters.** Garbled output often contains control characters or replacement symbols.

Design the detector so it does not punish legitimate text. Ours is language-agnostic: letters, combining marks and symbols are exempt, so emoji and scripts with combining marks do not trip it. Test it with real text in every language you support, not just English.

## Check while streaming

A check at the end of the response catches the problem after you have paid for it. Run the detector during the stream, after a minimum amount of content, so the first few chunks cannot false-positive.

When it trips, **cancel the upstream call**. That stops the billing on a long garbage tail, which in our production traffic was the expensive part.

Keep an end-of-stream check as well, for the responses that were short enough to slip under the mid-stream minimum.

## Retry once, then degrade

A degenerate output is often a sampling accident and not a property of the prompt. So:

1. **First strike:** retry once automatically, with a lower temperature.
2. **Second strike:** stop, and send the user a plain degraded message rather than a third attempt.

Bound the retries. A loop that retries degenerate output forever is another runaway. If your product has tiers, decide what the degraded message says for each.

## Make it observable

- **Count events per model.** A model that produces degenerate output often is a candidate to replace.
- **Record two flags in your audit log:** the output was malformed, and whether the retry recovered it. The second lets QA assert that the retry path really works.

## Test it

Give your test stub a mode that emits a long repetition burst, so integration tests exercise cancellation, retry and the degraded message without needing a misbehaving model. See also [A stub LLM that always returns clean JSON hides your parsing bug](/insights/a-stub-llm-that-returns-clean-json-hides-parsing-bugs/).

## Checklist

- Are repetition and non-printable ratios both detected?
- Is the detector language-safe, with tests?
- Does it run mid-stream, and cancel the call when it trips?
- Is there exactly one retry at lower temperature, then a degraded reply?
- Are events counted per model and recorded in the audit log?

If you want a review of how your product handles bad model output, [get in touch](/contact/).
