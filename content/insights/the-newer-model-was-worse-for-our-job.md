---
title: "The newer model was worse for our job"
description: "We tried to replace DeepSeek V3.2 with its V4 Flash successors on one provider and lost a working confidence threshold. What to test before a swap."
date: 2026-10-06T12:30:00+02:00
lastmod: 2026-10-09T21:00:00+02:00
tags: ["llm", "model-selection", "evals", "tool-calling"]
keywords: ["deepseek v3.2 vs v4 flash", "llm model upgrade regression", "llm confidence threshold calibration", "replace deprecated llm model", "deepseek v4.1 flash tool calling"]
series: "Changing models and providers"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

When a provider retires a model, the natural replacement is the next version of the same family. We set out to move a structured-decision task from [DeepSeek V3.2](https://huggingface.co/deepseek-ai/DeepSeek-V3.2) to its successors, first [V4 Flash](https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash) and then [V4.1 Flash](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash), and expected a routine upgrade. Both successors are from the cheaper Flash tier, and by DeepSeek's model card V4 Flash is less than half the size of V3.2.

It was not an upgrade for this job.

A note on scope: everything here is about one task, on the hosts we used. It is not a general ranking of these models.

## The job

The task takes a long prompt of structured context and must return one forced tool call (the request sets `tool_choice` to `required`): a label, a confidence between 0 and 1, and reasons. Downstream, a fixed confidence threshold decides whether anything happens automatically.

## First successor: confidence at the extremes

V4 Flash was the cheapest candidate, it was in the same family, and it returned valid tool calls in a quick probe.

Its confidence, as it was served to us, was the problem. On realistic prompts most answers came back at one extreme or the other. Given the same input several times, it returned a near-zero confidence on some runs and a near-certain one on others. V3.2's confidence in production had been graded.

A label with a coin-flip confidence is not usable behind a threshold. We withdrew that pick. We ran it on one host only, and did not find out whether the cause was the model or how it was served. We later saw the same pattern come and go with the host for V3.2 itself, in [Same model ID, different hosts, different answers](/insights/same-model-id-different-hosts-different-answers/).

## Second successor: fast, steady, and still not a replacement

V4.1 Flash looked much better. Its confidence was graded and steady, and it answered three to four times faster than V3.2 had. We shipped it as a stopgap.

Then we ran it at volume on replayed production prompts and found four differences.

**A few percent of its tool calls arrived broken.** The arguments string sometimes contained fragments of the model's own parameter markup, which made the JSON invalid. On this task, production had not recorded one unparseable answer from V3.2 in the weeks before its removal. We reproduced the fault and reported it. It looks like a fault in how the host converts the model's output into a tool call. V4.1 Flash was under a month old at the time, and its tool-call tag format differs from V4's ([DeepSeek's encoding notes](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash/blob/main/encoding/README.md)). A host parser that had not caught up could produce this. We ran it on one host only and see only the converted result, so we cannot rule out the model.

**Its confidence scale sat lower.** On the same prompts, V3.2's answers clustered around three confidence values and V4.1 Flash's around three values a step lower. The top cluster of one sat above our threshold. The top cluster of the other sat below it. On the part of the product where V3.2 did cross the threshold, V4.1 Flash did not cross it once in several hundred answers. Nothing errored. That feature simply went quiet.

**It reasons by default.** As we ran it, V3.2 answered without a reasoning step. DeepSeek's own API lists V4.1 Flash as "thinking (default)" on its [Models & Pricing page](https://api-docs.deepseek.com/quick_start/pricing), and our host served it the same way. So every request has to [switch thinking off](https://api-docs.deepseek.com/guides/thinking_mode/), or the reasoning uses up the output budget and the tool call is cut short.

**Output tokens cost more on our provider.** A few times as much per token. Per call the difference was smaller, because our prompts are long and mostly cached, but it was still an increase.

## What we got wrong along the way

Two of our early findings against V4.1 Flash did not survive checking.

First, we counted rate-limit refusals against the model. They were our account's per-minute limit: a faster model completes more calls per minute, so it reached a limit the slower model never had. Once the provider raised the limit, a rerun had no refusals. The broken tool calls remained.

Second, we claimed the new model would "never act, unlike the old one" on a part of the product where, on correct data, the old model had almost never acted either. Our sample had mixed two different prompts. That story is in [Half our replay sample tested the wrong prompt](/insights/half-our-replay-sample-tested-the-wrong-prompt/). The claim turned out to be true on the other part of the product, which we had not tested at that point.

And one thing the newer model does well: when it answers, it is stable between identical runs and close to the old model on the most common label.

## A threshold belongs to a model

A confidence number from a language model is not a calibrated probability. It is closer to a habit. One model writes a high number where another writes a middling one for the same strength of evidence. A fixed threshold then means "sometimes" for the first model and "never" for the second.

So a threshold is part of the model, not part of the product. If you change the model, you have changed what the threshold means.

## What we test before a swap now

- **Gate behaviour, not just labels.** Count how often each candidate crosses your threshold, on prompts where the incumbent did and on prompts where it did not.
- **The confidence distribution.** Plot it. Two spikes at the ends, or a ceiling below your threshold, is visible in seconds.
- **Every surface that uses the model.** Ours had more than one prompt, with very different behaviour. A model can pass one and never act on the other.
- **Failures at volume.** A few percent of broken tool calls does not show in a short probe.

Our full protocol is in [We made five model picks in one day](/insights/five-model-picks-in-one-day/).

## Where this left us

The open weights of V3.2 had not gone anywhere. One provider had stopped serving them. At the time of writing the stopgap is still what runs. By our own liveness rule it fails, and it stays only until the replacement ships. The route we have built and tested to replace it keeps the old model through other hosts, with the newer one as a backup. That is the subject of [Same model ID, different hosts, different answers](/insights/same-model-id-different-hosts-different-answers/).

A version number tells you which model is newer. It does not tell you which one fits a job that was built around the older one.

If you are planning a model swap on a decision path and want the test designed before the switch, [get in touch](/contact/).
