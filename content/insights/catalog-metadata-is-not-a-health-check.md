---
title: "Catalog metadata is not a health check"
description: "A provider catalog listed our model as healthy with function calling while every real call failed, and a typo passed lint. Only a live probe tells the truth."
date: 2026-09-19T09:30:00+02:00
tags: ["llm", "reliability", "testing", "inference-providers"]
keywords: ["llm model health check", "inference provider catalog function calling", "llm model id typo", "llm smoke test"]
series: "LLM tool calling in production"
toc: false
source_product: "www.nevergoblank.com"
source_url: "https://www.nevergoblank.com/"
related_service: "ai-workflows"
---

Inference providers publish a catalog of the models they serve. Each entry has a status and a list of features: chat completions, function calling, structured outputs. It is tempting to treat that as a health check. It is not one.

## The model that was healthy on paper

We deployed a cheap model to a routing tier. The provider's catalog entry for it showed a healthy status and listed function calling among its features. Every real request to it returned HTTP 400, whatever the payload looked like: with and without a system message, with and without tools, streaming or not, even a bare "hi".

The catalog was describing what the model is supposed to be. The endpoint was describing what it does. Only the endpoint matters for your users.

## The typo that passed the lint

While fixing this we introduced a second failure. A model ID was copied into several configuration files with one character missing at the end. The provider answered with a 404, model not found.

We had a check for this kind of mistake, and it passed. The check compared configured IDs against a static list of known-good ones, and the typo had been copied into that list too. A static check that compares strings to strings can only prove that your files agree with each other.

Treat model IDs like API keys: the only proof they are correct is that they work.

## A probe that tells the truth

A live probe is a minimal request to each configured model, asserting a non-empty answer. It is cheap and fast. A sketch:

```bash
curl -sS "$PROVIDER_URL/chat/completions" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"'"$MODEL_ID"'","max_tokens":20,
       "messages":[{"role":"user","content":"hi"}]}' \
  | jq -e '.choices[0].message.content | length > 0'
```

Run it for every model ID in your configuration, and fail loudly on anything but success.

Two additions make it much more useful:

- **Probe the shape you use.** If you rely on tool calling, include a request with a tool result. Some models pass the bare prompt and fail there, as described in [The 400 that only happens on the tool-result turn](/insights/the-400-that-only-happens-on-the-tool-result-turn/).
- **Run it in three places.** Before any model change, on a schedule (nightly is fine), and as a smoke test in your test suite against the real provider.

## Keep the static check, but say what it is

A lint that catches malformed IDs is still useful, because it is fast and works offline. Name it for what it proves ("model ID syntax") and do not let it stand in for a probe. A check with a reassuring name and a narrow guarantee is worse than no check, because people stop looking.

## The pattern

Metadata answers "what does the provider say this model is?". A health check answers "does it work right now, for the request I send?". When these disagree, believe the second one.

A dead model in production is often hidden by a fallback, which is why the probe has to call the model directly. That story is in [Our fallback hid an outage for weeks](/insights/fallback-hid-an-outage/).

If you want a review of how your team selects and monitors models, [get in touch](/contact/).
