---
title: "Another team's winning model lost on our workload"
description: "A sister product picked a new model after a careful test. We ran the same model on our own recorded requests and kept the models we had. What decided it."
date: 2026-11-02T22:30:00+01:00
tags: ["llm", "evals", "model-selection", "tool-calling"]
keywords: ["should we switch llm model", "llm model evaluation on production requests", "reasoning model forced tool call", "llm tool use evaluation", "llm eval noise floor"]
series: "Evaluating models"
toc: true
source_product: "www.nevergoblank.com"
source_url: "https://www.nevergoblank.com/"
related_service: "ai-workflows"
---

A sister product of ours lost a host for its main model and went looking for a replacement. Its team tested carefully: a survey of cheap models with tool calling, a screen on real production prompts, a full test on several hosts. The winner was four to eight times faster than the old model, at the same cost or less.

Should we switch too? We tested it on our own workload with six other models, and kept the models we had. What decided it applies to any team about to copy another team's choice.

These results are about our requests on our hosts, not a general ranking, so the models are described by behaviour, not by name.

## How we tested

We drove our own application through its real API in a test environment, with public sample inputs and a hundred scripted conversations, and recorded every model request exactly as sent: system prompt, tool list, temperature, length limit. No production data was read.

We replayed the recordings on each candidate, pinned to one host at a time: a screening pass, then three passes for the finalists on two or three hosts each, about ten thousand calls in all, and finally our live test suite. The replay is the protocol from [We made five model picks in one day](/insights/five-model-picks-in-one-day/), pointed at a different workload.

## The request shape decides whether the model thinks

The sister product sends one kind of request: a forced tool call against one fixed schema. In that shape its winner does not think before answering. It returns a tool call in about three seconds, every time.

Our product sends two other shapes. The assistant offers tools and lets the model choose, because many turns need a plain reply. Extraction calls send no tools and ask for JSON in text. On the other team's hosts, the same model thought before answering in both shapes, often for thousands of tokens. A JSON call took from a quarter of a minute to almost a minute, and a few percent of assistant answers were cut off at the length limit.

Same model, same host, different behaviour, because the request was different. The other team's test was right for their request and silent about ours.

We then rebuilt our extraction calls in their shape, as a forced tool call. The model stopped thinking: always valid, two to four seconds. But it listed about three times as many items per input as our current model, more than the prompt allows, and on a vague input that should yield nothing it invented items on every run. Fixing the shape made it usable. It did not make it better.

## Valid is not the same as good

The cleanest newcomer answered all but two of almost 1,300 assistant turns validly, on three hosts, never cut off, fast and cheap. On failures alone it was close to perfect.

It was not a winner. Asked to save something for the user, it said it would, and did not call the tool that saves it. Our live test suite caught that on the first run. In the replay, where our current model made a write call, the newcomer made the same call once in thirty and answered in prose almost every other time.

Our agreement score had hidden this, because it counted two text answers as agreement. The figure that exposed it was narrower: on the turns where production called a tool, how often does the candidate call the same one? An assistant that describes what it would do instead of doing it is the failure users notice, and a validity check cannot see it. A related point is in [Grade the tool call, not the text](/insights/grade-the-tool-call-not-the-text/).

## Two rules for reading the numbers

**Replay the incumbent on itself first.** Production's own model, replayed on the same requests, made the same first move as its earlier self on only about three quarters of assistant turns. That is the temperature at work, not a defect, and it is the bar: a candidate at two thirds is close to it, one at one in six is not. Without it, every candidate looks worse than it is.

**Count a cut-off answer as a failure.** Our first quick check passed three answers because they had text in them. All three had stopped at the length limit. A model that thinks spends its length budget before it starts the answer, and what comes back looks like a short reply. We now fail any answer whose finish reason is "length", whatever it contains. That rule decided three of the five models we rejected.

## The host is part of the model

One model answered all of about 300 assistant turns correctly on one host. On the other hosts we tried, the same model ID thought at length and was cut off on about two turns in five. One usable host is one host away from an outage.

We had seen host differences before, in [Same model ID, different hosts, different answers](/insights/same-model-id-different-hosts-different-answers/). This time they changed our configuration: each model is now pinned to the hosts it was tested on. How pinning behaves is in [Pinning providers on OpenRouter](/insights/openrouter-provider-pinning-what-we-verified/).

Routing can also remove a model before you test it. Two models we wanted never answered: we ask the router only for hosts that accept every parameter we send, and none of theirs accepts a temperature. A free check shows this first: pin the real request to a host that does not exist, and the router refuses it without billing, listing every host and the filter that removed it.

## Two failures outside the model

**A setting is only real if the code reads it.** Our configuration named a stronger model for one group of users. The code never read that setting, so the first answer in their conversations came from our JSON extraction model, which on one host answered about one in eight of those turns with nothing. No test checked that the setting was used. It is [Built but never wired](/insights/built-but-never-wired/) again, in configuration instead of code.

**Watch the account, not the key.** Halfway through the final runs, every call started failing with "payment required". The key still had room under its own spending limit, but the account behind it had run out of credit, and every key on the account shares that credit. If a test and a live service share an account, one long test can starve the live service. We now check the account balance before a long run.

## What we kept and what we changed

We kept both models: the assistant model, the only one with no failures that also used tools the way production does, and the extraction model, the most reliable and the cheapest on JSON. The work still changed production: every model is pinned to its tested hosts, the ignored setting is now read, and a test stops an unpinned production model from shipping.

Another team's winner is a good candidate to test. It is not a result for your workload.

## Checklist

- Does your test send your product's request shape, or the other team's?
- Do you measure tool use separately from validity?
- Have you replayed the incumbent on itself, so you know what agreement can reach?
- Do you fail answers that stop at the length limit?
- Is each model pinned to the hosts you tested it on, and is every model setting proven to be read?
- Do you know which account a test spends from, and what else spends from it?

If you are about to change models on a production path and want the test built on your own requests first, [get in touch](/contact/).
