---
title: "A model test is a snapshot. Hosts keep changing."
description: "Our best replacement passed thousands of calls on three hosts. It was fast only because those hosts skip a step its maker documents. So we built a trial."
date: 2026-11-03T17:00:00+01:00
tags: ["llm", "model-selection", "inference-providers", "reliability"]
keywords: ["llm shadow testing in production", "llm canary test for model drift", "reasoning model served without reasoning", "switch llm model safely in production", "llm inference host drift"]
series: "Changing models and providers"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

A provider retired the model behind our decision features, [with nine days of notice on a changelog](/insights/a-provider-retired-our-model-and-the-api-said-nothing/). We kept the same model, [DeepSeek V3.2](https://huggingface.co/deepseek-ai/DeepSeek-V3.2), by moving it to two other hosts through a router. Now one of the two has stopped serving it.

The router's catalog listed the model with tool support on three times as many hosts as our request could reach, and only one reachable host was usable. Our model watch had read the listing. It now also checks which hosts our real request can reach, because a listing is [not a health check](/insights/catalog-metadata-is-not-a-health-check/).

So we looked for a replacement again, and the test found a clear winner. The first question after the result was "Are you sure?" The honest answer was no, and this article is about why.

These results are about our requests on the hosts we tried, so the candidate and the hosts are described by behaviour, not by name.

## The test said yes

About fifteen set-ups that our request could reach ([the free check](/insights/another-teams-winning-model-lost-on-our-workload/)) went through a screen on real production prompts. Three finalists and the current model then went through our [full replay protocol](/insights/five-model-picks-in-one-day/): each prompt type that makes a decision, three passes, and outcomes scored afterwards.

The winner, an open-weight model from another family, was tested on each of its three usable hosts separately. Several thousand calls, and not one failure. It was four to eight times faster than the current model, at half to the same cost. On one prompt type it repeated production's labels more often than the current model repeated its own.

Like every model before it, it had its own confidence scale, and one action threshold had to move for it to act about as often as production. That is the lesson of [The newer model was worse for our job](/insights/the-newer-model-was-worse-for-our-job/), and this time we planned for it.

The screen also found a bug of ours: one feature acted on confidence alone, so a confident answer that said not to act could still trigger an action, and once in production it had. It now also requires the label to agree.

## "Are you sure?"

We had passed tests before.

Our stopgap after the retirement, [DeepSeek V4.1 Flash](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash), was stable in our replay, and at volume a few percent of its tool calls came back broken. We moved back to the old model on other hosts. One of those hosts returned a valid tool call on every call of a full test run, and a few days later returned empty tool arguments on nearly one call in five. Same model, same host, same kind of test.

A test tells you how a model behaved on those hosts on the day you ran it. It does not tell you what the hosts will do next week.

## Why the winner was fast

Then we read the maker's documentation. The model always reasons before it answers, at the highest effort unless told otherwise, and a request to turn reasoning off is refused. Reasoning counts against the length limit.

On the three hosts that passed, the model returned no reasoning at all for our request. On six other hosts it reasoned as documented, used up its length budget, and returned no tool call.

So the speed and cost we measured were not properties of the model. They came from a choice those three hosts made, which the maker does not describe. We do not know how they do it.

Served as documented, the model also answers differently. On one such host, at the lowest effort it accepts, a five-prompt probe answered every prompt but took more than twice as long, wrote about twice as many tokens, and gave a different label from a fast host on three of the five.

Our sister product saw the same model on the same hosts reason at length on requests that let it choose a tool or asked for JSON. Whether the step is skipped depends on the host and the request shape together, and the maker promises neither.

## What could go wrong

A behaviour nobody documents can change without notice. A host can update its serving software or move to the maker's defaults, and our test, run once, would still say yes.

The loud version is the easier one. A host that starts reasoning at full effort runs out of length before the answer and sends back no tool call. Our client treats that as an error and asks our backup, a different model. It never reaches the next pinned host: the router moves down the pin list only when a host returns an error, and this host returned success. Three pinned hosts protect us from a host that refuses, not from one that answers badly. So we watch how often the backup answers, the lesson of [Our fallback hid an outage for weeks](/insights/fallback-hid-an-outage/).

The quiet version is harder. A host that reasons briefly still answers in time, but as the probe shows, it may answer differently. No error marks that. Only a comparison of answers does.

## A trial instead of a test

So the switch waits for a trial, built to be reused: we now expect to review our model choice about once a month.

- **Shadow traffic.** For a fixed number of days, decisions the current model makes in production are also sent to every candidate host. The answers are stored next to production's, never acted on, and compared request by request.
- **Only the current model's own answers count.** When production's answer came from another model, such as the backup, that request is not a sample.
- **A daily canary.** The first live requests of the trial become a fixed prompt set. Once a day every host answers it again, the current model included, and each prompt is compared with its own first answer. A host that starts failing or shifts its answers should show within a day.
- **Go/no-go rules written before the start.** Enough samples of every prompt type, zero failures, acting about as often as production, no "act" on a label that says not to, a clean canary for the last several days, every pinned host still reachable, and the offline test repeated before the decision. A scheduler checks them and sends reminders.
- **Promotion and rollback are settings.** The model, its host order, and an optional middle step that keeps yesterday's model between the new one and the backup. Rolling back means setting the old values again.

## Where this leaves us

When we wrote this, production still ran the old model on its one usable host, with a different model as the backup. The trial was deployed and had not started. Nothing switches until its checks pass and someone promotes the candidate.

The test told us which model to try. Only live traffic over time can tell us whether its hosts keep serving it the way we tested it.

## Checklist

- Is your candidate's speed documented behaviour, or a choice of the hosts you tested?
- Did you test each host on its own, and pin the ones you tested?
- Does your fallback cover a host that returns success with no usable answer, and do you watch how often the backup answers?
- Do you compare candidate and production on the same requests, and only on answers the production model gave?
- Is a fixed prompt set replayed every day on every host, the current model included?
- Were the go/no-go rules written before the trial started, and can you roll back by changing settings?

If you are about to change the model behind a production feature and want a trial built around the switch, [get in touch](/contact/).
