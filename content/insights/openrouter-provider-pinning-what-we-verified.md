---
title: "Pinning providers on OpenRouter: what we verified"
description: "How provider order and allow_fallbacks behave on OpenRouter, the shared rate limits behind a pin, and the checks that keep a pinned route honest."
date: 2026-10-06T11:30:00+02:00
tags: ["llm", "openrouter", "routing", "reliability"]
keywords: ["openrouter provider order allow_fallbacks", "openrouter pin provider", "openrouter 429 rate limited upstream", "openrouter provider routing tool_choice", "openrouter ignore provider"]
series: "Changing models and providers"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

[OpenRouter](https://openrouter.ai/) puts many hosts of the same model behind one endpoint and, by default, chooses between them for you. For an open-weight model on a decision path that default is a risk, because hosts of one model do not all behave alike. What we saw is in [Same model ID, different hosts, different answers](/insights/same-model-id-different-hosts-different-answers/).

The answer is to pin. This article is what we checked before we trusted a pin, from the [provider routing documentation](https://openrouter.ai/docs/guides/routing/provider-selection) and from live calls. The route it describes was built and tested when this was written, and had not yet carried production traffic. Routers change, so read the current docs before you copy anything.

## The request

Provider preferences go in a `provider` object on the request:

```json
{
  "model": "vendor/model-name",
  "messages": [{"role": "user", "content": "..."}],
  "tools": [{"type": "function", "function": {"name": "submit_answer", "parameters": {"type": "object"}}}],
  "tool_choice": "required",
  "provider": {
    "order": ["host-a", "host-b"],
    "allow_fallbacks": false
  }
}
```

## What the documentation says

- **`order`** is the list of provider slugs to try, in order.
- **`allow_fallbacks`** controls whether backup providers may be used when the primary is unavailable. It defaults to true, so `order` on its own is a preference, not a pin.
- **Setting an order turns load balancing off.** The router tries providers in the order you gave.
- **`ignore`** is a list of providers to skip for the request, and **`only`** is a list of the providers allowed for it.
- **`require_parameters`** limits routing to providers that support every parameter in the request. It defaults to false, and then a provider that does not support a parameter can still receive the request and ignore it. We did not set it, because we pinned only hosts we had already tested with the forced call.
- **Know which slug you have.** A base slug matches every endpoint that provider has for the model, variants and regions included. A full slug, with its suffix, targets one. The docs point to a copy button next to each provider name on the model page for the exact slug.

## What we saw on live calls

We tested the pin with forced tool calls against two hosts.

- **With fallbacks off, the request stayed inside the list.** A request that the pinned hosts refused came back as a rate-limit error. It was not served by another host.
- **The response names the provider that served it.** Store that with every answer.

## What a pin does not give you

**Capacity.** The refusals we saw were HTTP 429 with a message that the upstream host was temporarily rate-limited, and a suggestion to add our own key for that host. Through a router you use shared capacity at each host, and with fallbacks off nothing hides a refusal from you. On our two hosts it came in bursts. In one short window close to half of our first attempts were refused. An hour later none were.

With both hosts pinned and a retry on refusals, the route served in every live run we made. Pinned to the flakier host alone, it sometimes refused every attempt.

**A promise that a host stays the same.** A pinned host can stop serving the model or drop tool calling. The watch we built for this route checks the model's list of endpoints on a schedule. One pinned host gone is a warning. All of them gone is critical.

## Five more things we tripped over

**The router can send you back where you came from.** A router may list the provider you are leaving as one of its upstreams, and a failover request can then be routed straight back to it. For a failover, put that provider in `ignore`.

**Tool calling removes hosts, and forcing the call removes more.** With `tool_choice` set to `required`, more than half the hosts of our model were not usable. The long list on the model page is not your list. Yours is the hosts that accept your request shape.

**Model IDs differ between providers.** One of our models has a slightly different ID on the router than on our original provider. A failover needs an alias table and a test per alias.

**Reasoning flags are per model.** Some hosts ignored a reasoning-off flag, so we keep a floor under the output budget on that route. One model rejected the flag outright with a 400. Send it only to models you have tested it on.

**Your data policy removes hosts too.** With our account set to exclude endpoints that may train on prompts, one vendor's own endpoint was not routable for us. That is the setting doing its job.

## When every pinned host refuses

Sooner or later both hosts refuse and the retries run out. Then our route asks a backup, and the backup is a different model. Three rules keep that honest:

- **The backup answers as itself.** The stored model, host and cost are the backup's. An answer relabelled as the primary's makes every later analysis wrong.
- **The backup's answer is not cached as if the primary had given it.** A review found our cache doing exactly that.
- **Being served by the backup raises an alert**, as a share over a time window. A primary route that is not configured raises the same alert. A missing key causes no error on its own.

## Checklist

- Is every request on the decision path pinned, with fallbacks off?
- Did you test each pinned host on its own, not through the mix?
- Do you retry rate-limit refusals, and can the retry run inside your callers' deadlines? See [The retry that could never run](/insights/the-retry-that-could-never-run/).
- Do you store the host that answered?
- Does something check that the pinned hosts still serve the model with tool calling?

If you are moving a production workload onto a router and want the route reviewed, [get in touch](/contact/).
