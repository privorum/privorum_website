---
title: "Same model ID, different hosts, different answers"
description: "After a retirement we found the same open weights on other hosts. Through OpenRouter, some of those hosts behaved like a different model on our task."
date: 2026-10-06T12:00:00+02:00
tags: ["llm", "inference-providers", "openrouter", "huggingface"]
keywords: ["same model different provider results", "openrouter provider differences", "hugging face inference providers tool calling", "open-weight model hosts quantization", "llm provider variance"]
series: "Changing models and providers"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

When our provider retired an open-weight model we depended on, there was one piece of good news. Open weights do not disappear when one host stops serving them. Other hosts still ran the same model, and two routers, [OpenRouter](https://openrouter.ai/) and [Hugging Face Inference Providers](https://huggingface.co/docs/inference-providers/index), put many of those hosts behind an OpenAI-compatible endpoint.

So the plan looked simple: send the same model ID to a router and carry on.

Our first test of that plan said the model was unusable. Our second said it was fine. Both measured correctly. They were measuring different hosts.

## The first test: "this is not the same model"

We sent replayed production prompts to the model through OpenRouter, with default routing. The answers that came back were valid tool calls and the labels were plausible. The confidence field was not. Nearly every answer came back at an extreme, close to zero or close to one. In production the same model had always reported graded confidence, spread across the range.

Behind a confidence threshold, that behaves like a different model. It would have crossed our threshold on about one answer in six, which the model in production had done very rarely. It was also slow, with some calls running past our client timeout.

We wrote it down as rejected.

## The second test: one host at a time

The responses named the hosts that had served them, and default routing had concentrated our calls on very few.

So the next day we pinned each host in turn and sent every one the same small set of production prompts. OpenRouter listed about a dozen hosts for the model:

- **A few returned graded confidence**, in the range production had always shown.
- **A couple returned only two confidence values**, the pattern from the first test.
- **One returned a confidence of zero on every answer.**
- **More than half could not be used at all.** Some did not offer tool calling, and others offered it but not a forced call.

The same weights, the same request, the same prompts. Which host answered decided whether the output was usable.

We do not know why the hosts differ, and we would be guessing if we named a cause. What we can say is that the quantization a host lists (how far it has compressed the weights) did not predict which group it fell into.

## Two hosts, one check

Two of the good hosts went through our full replay test, each pinned and tested on its own.

The two independent hosts behaved the same. Both returned a valid answer on every call, after retrying some rate-limit refusals. Both agreed with what production had answered on nearly all prompts of the most common class. Both ran at about the median speed production had. The slow tail was worse, which mattered later, in [The retry that could never run](/insights/the-retry-that-could-never-run/).

That agreement convinced us we had the old model back, more than either run would have alone. It was also how we later caught a mistake in our own test data, because both hosts disagreed with production in exactly the same way on one group of prompts. That is in [Half our replay sample tested the wrong prompt](/insights/half-our-replay-sample-tested-the-wrong-prompt/).

We had described the method for this kind of test earlier, without results, in [Testing tool calling on Hugging Face Inference Providers](/insights/testing-tool-calling-on-hugging-face-inference-providers/). Its advice to treat each model and provider pair as one candidate turned out to be the whole story.

## The "too slow" mistake

We did reject one of the good hosts for a second reason, and had to take that back. It was several times slower per call than the newer models we were testing.

Then we looked up what production had recorded for the old model on the old provider. It had always been that slow. We had been comparing the old model with its faster replacements instead of with itself.

Before you call a candidate slow, read your own latency history for the incumbent, including the tail.

## What we do now

- **Treat a model ID as a name for weights, not for a deployment.** The unit you qualify is the pair of model and host.
- **Never qualify through default routing.** You will measure whichever host the router prefers that hour, or a mix.
- **Pin, then test each pinned host separately.** How we pin is in [Pinning providers on OpenRouter](/insights/openrouter-provider-pinning-what-we-verified/).
- **Look at the distribution of a numeric field, not only at validity.** Every answer in our first test was a valid tool call. The defect was only visible as a histogram with two bars.
- **Send the request shape you use in production.** More than half the hosts dropped out on tool calling, some of them only because the call was forced.
- **Keep a second independent host as a control.** When two hosts agree with each other and disagree with your reference, suspect the reference.
- **Record which host answered**, on every response.

## The limits of this

Our host-by-host screen used a small prompt set. That is enough to see two-valued confidence, which shows in the first few answers. It is not enough to rank two good hosts against each other, and we did not try.

Speed is a reading, not a constant. A later run through the same pinned host was noticeably slower than the first.

Hosts also change. A host that behaves today can change its configuration next month without changing the model ID. That is a monitoring problem, and a recording of last month's answers will not catch it.

If you depend on an open-weight model and want a plan for the day its host drops it, [get in touch](/contact/).
