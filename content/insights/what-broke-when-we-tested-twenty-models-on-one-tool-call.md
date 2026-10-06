---
title: "What broke when we tested 20+ models on one tool call"
description: "We ran more than twenty models through one structured-decision task with a forced tool call. About half failed on liveness. The failure types, and what passed."
date: 2026-10-06T13:30:00+02:00
tags: ["llm", "tool-calling", "evals", "model-selection"]
keywords: ["llm forced tool call failures", "tool_choice required empty response", "reasoning model max tokens tool call", "gpt-4o mini tool calling reliability", "small llm structured output comparison"]
series: "Evaluating models"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

When our production model was retired we tested more than twenty candidates for one task over two days: read a long structured prompt, then return exactly one forced tool call (`tool_choice` set to `required`) with a label, a confidence and reasons. Small and mid-sized models, open-weight and proprietary, through one inference provider and two routers.

About half of them failed on plain liveness at some point: an empty answer, a broken tool call, a timeout. Most of the rest fell to something a validity check cannot see. This is a catalogue of both, because the failure types were more useful to us than any ranking.

We name one model in this article, the one that surprised us. The rest are described by behaviour. A result belongs to a model on a host on a date, and several of these would likely differ elsewhere.

## Failures that return HTTP 200

**The answer that was generated and lost.** One open-weight model returned a success status, a finish reason of `tool_calls`, and a bill for a few hundred output tokens. The response contained no tool call and no text. On our prompts this happened on about half the calls. It was also the model our fallback chain ended on, which is how it came to serve production during the incident in [Our provider retired a model. The API said nothing.](/insights/a-provider-retired-our-model-and-the-api-said-nothing/)

**The reasoning that ate the budget.** Two reasoning models spent the entire output budget thinking and returned nothing. A small one from a major vendor answered almost none of its calls as sent. Another took more than a minute to produce no answer. On the small one, setting reasoning to minimal helped, and then exposed malformed tool calls underneath.

**The markup in the arguments.** On one host, one model's tool arguments sometimes carried fragments of its own parameter markup, which made the JSON invalid on a few percent of calls. We wrote about parsing a related leak safely in [The model answered. We threw the answer away.](/insights/a-tool-call-that-arrives-as-text/)

## Failures of the request itself

**Flags that cannot both be right.** One model rejected a forced tool call with a 400 unless reasoning was switched off. Another rejected the request with a 400 when reasoning was switched off. There is no single request shape you can send to every model. Flags have to be per model, and each one tested.

**Hosts that do not take a forced tool call.** Through a router, more than half the hosts of one model could not serve a request with `tool_choice` set to `required`. Some of them did not offer tool calling at all.

## Failures you only see in the numbers

In this group the calls came back valid, or nearly all of them did. The problem was in what the valid answers said.

**Two-valued confidence.** Some model and host pairs returned confidence only at the extremes. See [Same model ID, different hosts, different answers](/insights/same-model-id-different-hosts-different-answers/).

**Declining to decide.** One vendor-served model answered "not enough data" on most prompts where the incumbent, and most other candidates, had given a clear negative. It had simply moved the line for what counts as enough.

**Too eager for the gate.** One cheap model that had passed our first liveness run crossed our action threshold on about one answer in five, on prompts where most other candidates never crossed it. It was also the model we use as an independent judge, and a producer graded by its own model is not really being graded.

**A long tail.** That same model had a good median and one call in ten that took most of our client timeout. At volume some of those calls timed out, so it failed liveness after all.

**A different answer each time.** One candidate changed its decision between identical runs on about a quarter of prompts. In a single pass it looked fine.

## What passed

Only a few candidates got as far as the large replay run. Three options returned a valid answer on every call of it.

Two were the retired model itself, the same open weights, on two other hosts.

The third was [GPT-4o mini](https://developers.openai.com/api/docs/models/gpt-4o-mini), a small proprietary model that is more than two years old. It had no failures in any run we put it through, and in the large run it needed no retries at all. It was also the fastest of the three, the cheapest, and the most stable between identical passes.

We had not expected that. We had started with the newest small models, on the reasonable assumption that newer is better at tool calls. For one forced, schema-shaped call under a fixed budget, an older model with no reasoning mode was the most dependable thing we tested.

It did not become our primary. The old model was still available on other hosts and matched what production had been doing, and moving a decision path to a different vendor is a decision of its own. When we wrote this, it was our candidate for the last-resort slot, where dependability is the whole job. OpenAI lists no shutdown date for it today, and its [deprecations page](https://developers.openai.com/api/docs/deprecations) is one more page to watch.

## Our own tooling was wrong too

**The benchmark did not send what production sends.** Our general-purpose bench sent the tools without forcing a call. Production forces it. A model can pass one shape and fail the other: the model that returned empty answers on half its calls had passed that bench a few months earlier. The bench now sends the production request.

**The cost column was far too high.** The bench misread a price unit. We recomputed every cost from token counts before quoting any.

## What we do with a new candidate now

1. One live call in the exact production request shape, including flags.
2. A replay of real prompts, several passes, with zero failures as the bar. The protocol is in [We made five model picks in one day](/insights/five-model-picks-in-one-day/).
3. A look at the distribution of every numeric field.
4. The same input several times.
5. Only then cost and speed, as in [How to qualify an LLM router model](/insights/how-to-qualify-an-llm-router-model/).

If you are choosing a model for structured output and want the candidates screened properly, [get in touch](/contact/).
