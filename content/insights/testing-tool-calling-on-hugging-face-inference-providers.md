---
title: "Testing tool calling on Hugging Face Inference Providers"
description: "A method for qualifying tool calling across Hugging Face Inference Providers: the endpoint, provider pinning, fixture design and the traps. No measured results."
date: 2026-09-19T13:10:00+02:00
tags: ["llm", "huggingface", "tool-calling", "evals"]
keywords: ["hugging face inference providers tool calling", "huggingface function calling test", "open source llm tool calling providers", "huggingface router openai compatible"]
series: "Evaluating models"
toc: true
related_service: "ai-workflows"
---

Hugging Face Inference Providers gives one endpoint in front of many providers that serve open-weight models. If you want tool calling from those models, one question comes up quickly: which model, on which provider, actually works for my agent?

This article is a method for answering it. **It contains no measured results.** A pass or fail table depends on the provider, the date and your fixtures, and a table copied from someone else's run tells you little about yours. Everything factual below comes from Hugging Face's documentation as it stood on 19 September 2026, and the docs change, so check them before you build.

## What the endpoint gives you

- **An OpenAI-compatible chat endpoint.** The base URL is `https://router.huggingface.co/v1`, and you authenticate with a Hugging Face token as a bearer token. The docs recommend a fine-grained token with permission to make calls to Inference Providers. This endpoint is for chat completion only; other tasks such as embeddings or images use Hugging Face's own clients.
- **A choice of provider through the model name.** With no suffix, or `:fastest`, the highest-throughput provider is chosen. `:cheapest` picks the lowest price per output token. `:preferred` follows the order in your account settings. Appending a provider name, such as `:groq`, pins that provider.
- **Failover.** With automatic selection, requests can be routed to another provider if the primary is flagged as unavailable. For testing, that is a trap: see below.
- **A list of what is available.** `GET /v1/models` lists models across providers, with per-provider pricing, context length, latency and throughput when available. The `hf models ls --warm` command lists models served by at least one provider, and there is a compatibility table on the site.
- **Billing.** There is a free tier and additional credits on paid plans, and Hugging Face states that it adds no markup on provider rates. Check the current limits before you plan a large run.

## What the docs say about tool calling

The function-calling guide is direct about the limits:

- Each provider has different capabilities and performance characteristics, and switching provider can change a model's responses, because each provider uses a different configuration of the model.
- Pinning a provider reduces variance in function-calling behaviour.
- Strict mode, which forces arguments to match your schema exactly, is not supported by all providers. Neither is streaming.
- Models may call functions that do not exist.
- `tool_choice` can be `auto`, `required`, or a specific function.
- The `InferenceClient` from `huggingface_hub` does not support choosing a specific function through `tool_choice`. The OpenAI client does, so use that for tests.

There is no per-model, per-provider matrix of tool-calling support in the docs. That gap is the reason to test.

## Design the fixtures

A useful fixture set is small and deliberate. Cover:

1. **A single, clear tool call.** The smoke test.
2. **Choosing between several tools.** One correct pick among similar ones.
3. **Required arguments.** The arguments parse and match your schema.
4. **A call that needs no tool.** The model should answer directly. This catches models that call tools compulsively.
5. **`tool_choice: required` and a named function.** Check that the forced choice is respected.
6. **The continuation turn.** Send the tool result back and check that the model continues. Some model and provider combinations pass every single-turn test and fail here ([The 400 that only happens on the tool-result turn](/insights/the-400-that-only-happens-on-the-tool-result-turn/)).
7. **Non-existent tool names.** Give the model a chance to invent one, and check that your harness rejects it.
8. **Streaming and strict mode**, if you use them, as separate cases.

## Run it so the result means something

- **Pin the provider.** A test against automatic selection may silently fail over between providers, and you would be measuring a mix. Pin with a suffix and treat each model and provider pair as one candidate.
- **Record the date.** Provider lists and model configurations change. Store the date, the model ID, the provider and the full request with every result.
- **Repeat.** Model output is not deterministic. Run each fixture several times and report a rate, not a single pass.
- **Gate on failures first**, as in [How to qualify an LLM router model](/insights/how-to-qualify-an-llm-router-model/): any request error, missing call or malformed call disqualifies, and only survivors are ranked.
- **Keep the raw responses.** You will want to read the failures.

A harness can be small:

```python
import os, json
from openai import OpenAI

client = OpenAI(base_url="https://router.huggingface.co/v1",
                api_key=os.environ["HF_TOKEN"])

def run(model, provider, messages, tools, tool_choice="auto"):
    return client.chat.completions.create(
        model=f"{model}:{provider}",      # pin the provider
        messages=messages, tools=tools, tool_choice=tool_choice,
    )
```

## Traps

- **Comparing across providers as if they were one thing.** The same model can behave differently on different providers, so a result belongs to the pair, not to the model.
- **Trusting a listing.** A model that a provider lists for chat completion may still fail on tools ([Catalog metadata is not a health check](/insights/catalog-metadata-is-not-a-health-check/)).
- **A small sample.** A few runs cannot separate two close candidates. They can disqualify a broken one.
- **Budget.** A large fixture set across many pairs uses credits quickly.

If you would like help building a qualification harness for your own agent, [get in touch](/contact/).
