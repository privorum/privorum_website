---
title: "Open weights are not open availability"
description: "A provider retired a model that worked, its successor failed our tests, and so did about half the alternatives. What running open models in production costs."
date: 2026-10-09T10:00:00+02:00
tags: ["llm", "inference-providers", "reliability", "model-selection"]
keywords: ["open weight models in production", "open source llm reliability", "llm provider model deprecation", "open weight model hosting risk", "llm cost per valid answer"]
series: "Changing models and providers"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

The pitch for open-weight models is that you are not locked in. The weights are public, many companies serve them, and if one provider stops, you move.

One inference provider retired the model our decision path ran on, [DeepSeek V3.2](https://huggingface.co/deepseek-ai/DeepSeek-V3.2). It was a model that worked. The model we were pointed to instead failed our reliability bar, and so did about half of the more than twenty other models we tried. Three options survived a full replay.

## How to read the results

Every result below is about one task: a long prompt and one forced tool call that returns a label, a confidence and reasons. Our bar is a valid tool call on every call of a replay of real prompts, in production's request shape. One large run used the smaller output budget of our last-resort step in production, noted below.

Samples are small: a handful of prompts for a host screen, a short set run several times for a first model test, and the large set for fewer than half the candidates. A result is a reason to look closer, not a ranking. The provider, the hosts and most models are described by behaviour.

## The retirement

The provider announced the retirement little more than a week ahead, in a batch with other models. The notice was on its changelog, not in the API, and we were not reading that page. That part is our failure, and [we wrote it up](/insights/a-provider-retired-our-model-and-the-api-said-nothing/).

Asked afterwards, the provider said it had no plan to restore the model and pointed us to its successor.

## The successor was not a drop-in

[DeepSeek V4.1 Flash](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash), a model from DeepSeek's cheaper Flash tier, was fast on the same provider and its confidence was steady. We shipped it as a stopgap. But a few percent of its tool calls came back as invalid JSON: the arguments string carried a fragment of the model's own parameter markup. On this task, production had recorded no unparseable answer from the old model in the weeks before.

We reproduced the fault and reported it. It looks like a fault in how the host converts the model's output into a tool call, but we ran it on one host only and see only the converted result, so we cannot rule out the model. V4.1 Flash changed its tool-call tag format from V4 ([DeepSeek's encoding notes](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash/blob/main/encoding/README.md)), and a host parser that had not caught up could produce this. [The details of the swap are here](/insights/the-newer-model-was-worse-for-our-job/).

## Everything else we tried

The failure types are in [What broke when we tested 20+ models on one tool call](/insights/what-broke-when-we-tested-twenty-models-on-one-tool-call/). In short:

- **On the same provider, thirteen other models.** Most failed the bar somewhere: empty answers, timeouts or malformed tool calls. Several empty answers ended at the output limit, as reasoning models do when thinking uses the budget. For the three models we ran only at the smaller budget that is expected, not a defect, though they still failed this task at that budget. One model was valid on every call and returned confidence almost only at the extremes. A few stayed valid and steady in a short run, and cost more.
- **Through a router, seven models served by their own vendor and three older siblings of the retired model.** Two vendor models failed outright, on reasoning budget or malformed tool calls, and one sibling returned nothing on its single call. The rest were valid, in a short run, on a single prompt or on a handful.
- **In the full replay, three options returned a valid tool call on every call.** Two were the retired model itself, on two other hosts, after retries on rate-limit refusals. The third was [GPT-4o mini](https://developers.openai.com/api/docs/models/gpt-4o-mini), an older closed model with no reasoning mode, which needed no retries. The most dependable single option was closed, and two of the three survivors were open weights.

## A dozen hosts of the same model

Open weights meant other hosts still served the retired model. Through [OpenRouter](https://openrouter.ai/) we pinned each host in turn and sent it the same few replayed prompts. Of about a dozen hosts, more than half were not routable for a forced tool call. Of the rest, a few returned graded confidence. A couple returned only two confidence values, and one returned zero on every answer. The details are in [Same model ID, different hosts, different answers](/insights/same-model-id-different-hosts-different-answers/).

None of the hosts that answered returned an error. Half of them returned something that looked right and was unusable behind a threshold.

We do not know why, and we are not claiming a cause. Most of the hosts that answered list no precision at all, and price did not predict it either. What makes it hard to catch is that the answer changes under the same name and nothing flags it. With a database, a wrong result is a bug. With a language model, a slightly worse result looks like a normal result.

## What it costs, and what to ask for

If a decision path runs on a model you do not control, a retirement is an operations event with a deadline you did not set. Ours ran for days on a weaker fallback, because it returned a success status and nothing alerted. The swap itself was a small code change. The testing around it took two days of replay runs, and failed calls are metered too.

Providers have to retire old models, and running every version forever is not free. The ask is small: notice in the API, a named replacement that has been tested for tool calls, and a window long enough to test one against the other.

## What we do now, and what ships next

The first is how we test now. The next three are built and tested, not yet in production. The last two are advice we have not automated.

- **Qualify on replayed production prompts,** with repeat passes and zero tolerated failures. [Our protocol](/insights/five-model-picks-in-one-day/).
- **Read the provider's changelog on a schedule,** by machine.
- **Pin the host.** [What we verified about pinning](/insights/openrouter-provider-pinning-what-we-verified/).
- **Keep a second route** on a different model, and alert when it is serving.
- **Keep a golden set** of real inputs and trusted answers, and rerun it when a host or a model changes.
- **Measure cost per valid answer,** including failed calls and retries.

Open weights did what they promise: the model we lost was still served elsewhere. But unless you host the weights yourself, which has a bill of its own, somebody else decides how long your model is served, and how. Plan for that.

If you are running an open-weight model on a decision path and want a qualification test or a second route built before the next retirement, [get in touch](/contact/).
