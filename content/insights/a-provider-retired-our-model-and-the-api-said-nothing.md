---
title: "Our provider retired a model. The API said nothing."
description: "An inference provider retired our production model with about ten days of notice, posted only on a changelog. How we missed it, and what we watch now."
date: 2026-10-06T13:00:00+02:00
tags: ["llm", "operations", "monitoring", "inference-providers"]
keywords: ["llm model deprecation", "inference provider model retired", "llm model not found 404", "llm model deprecation monitoring", "open-weight model removed from provider"]
series: "Changing models and providers"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

One of our production features ran on [DeepSeek V3.2](https://huggingface.co/deepseek-ai/DeepSeek-V3.2), an open-weight model served by an inference provider. One day the provider stopped serving it. Requests for that model ID came back as "model not found".

Nothing paged. We found out days later.

## Nothing looked down

Our main request path has a fallback chain. When the usual model fails, the request drops to the next one, and finally to a small last-resort model. That part worked as written. Every request on that path got an answer from somewhere.

The somewhere was the problem. The last-resort model returned nothing usable on a large share of requests, and when it did answer it was far more eager to say "go" than the model it replaced. For days, a feature that makes decisions was running on a model nobody had qualified for that job.

A second feature used the same model and had no fallback to a different one. It stopped producing output, and a feature that produces nothing looks, from the outside, like a quiet day.

Neither raised an alert. Uptime checks and incident alerts watch for failures, and a fallback that succeeds is not one. We have written about the first half of this before, in [Our fallback hid an outage for weeks](/insights/fallback-hid-an-outage/). That lesson came from another product, and this one did not yet have the alert on fallback rate we recommended there. This time the trigger was not a bad model choice. It was a provider's housekeeping.

## The notice existed. We were not reading it.

When we asked the provider, the answer was polite and short: the model was not coming back, and retirements are announced on the changelog page of the documentation.

They were right. The notice had been posted about ten days before the removal, in a batch with other models.

Three things about that notice are worth knowing if you depend on any hosted open-weight model:

- **It was not in the API.** The provider's model list had no deprecation or expiry field. A model was listed until the day it was not.
- **Nothing read it.** It sat on a documentation page, and no person or job on our side was looking at that page on a schedule.
- **It contained a second model of ours.** The same notice gave a later removal date for our last-resort model. We learned that only because the first incident sent us to read the page.

## A watch that looks at the past

Our first reaction was to build a model-list watch: on a schedule, check every configured model ID against the list of the host that serves it, and page if one is missing.

It is a useful check, and it would only have told us sooner. A list with no retirement date can only tell you that a model is already gone. We had built a faster way to learn about an outage, not a way to avoid one.

So we extended the watch to read the announcements too. The changelog turned out to be readable by a machine. A few details decided whether the reader could be trusted:

- **Find columns by their header, not their position.** Other columns can hold model IDs and dates too.
- **One unreadable row must not discard the rest.** A partial read keeps what it read and reports itself as partial.
- **Unread is not the same as clean.** If a source cannot be fetched, the watch says "unread". Reporting nothing at risk for a source you did not read is the most dangerous answer it can give.
- **Use an expiry field where one exists.** Some routers publish one: [OpenRouter's model list](https://openrouter.ai/docs/api/api-reference/models/list-all-models-and-their-properties) has an `expiration_date` per model. Read it, and alert as soon as a date appears. It covers the model on the router, not one host, so a pinned host still needs its own check.

On its first run against the live page the reader reported the second retirement, with its date.

## Changing the setting would not have fixed it

There was a second surprise. We assumed the model ID came from an environment variable. It did not. The ID that went on the wire came from a constant in the code, and the variable fed a log line.

So the obvious emergency fix, editing the deployment setting, would have changed what the logs said and nothing else.

Before you need it, find out where the model ID on the wire really comes from. Then add a test that fails when the configured default and the value on the wire disagree.

## Every default is a dependency

The main model was the visible dependency. The invisible ones were defaults. Two background features used the retiring last-resort model by default.

A watch list written from memory will miss these. Build it from every model ID the process can put on a request: primaries, backups, last-resort models, and the defaults of features that are switched off today.

## The alerts this led to

When we wrote this, some of these were running and some were built, waiting to ship with the route that replaces our stopgap.

- **A configured model with a retirement date.** A warning when it is weeks away, critical when it is days away.
- **A configured model missing from its host's list.** Critical.
- **A primary answered by its backup.** As a share over a time window, not a count. A successful fallback needs its own name, or it looks like health.
- **A rate of unusable answers.** Our old rule counted parse failures in a short window, and a high failure rate at low volume never reached the count. The new rule is a share over several hours, with a volume floor.

## Checklist

- Do you know where each provider announces retirements, and does anything read it?
- Is your watch list built from the code and configuration, including defaults?
- Would a successful fallback page anyone? Would a feature that simply stops producing output?
- Do you know where the model ID on the wire comes from?

A model list tells you what a provider serves today. It is not a promise about next week. We made the same point about capabilities in [Catalog metadata is not a health check](/insights/catalog-metadata-is-not-a-health-check/).

What we did next is in [The newer model was worse for our job](/insights/the-newer-model-was-worse-for-our-job/) and [Same model ID, different hosts, different answers](/insights/same-model-id-different-hosts-different-answers/).

If you run production features on hosted models and want your failure paths reviewed, [get in touch](/contact/).
