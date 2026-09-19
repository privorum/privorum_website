---
title: "Which tools do you show the model?"
description: "Sending every tool definition costs prompt tokens on each call. Showing a subset saves them, but keyword routers and selector models each have blind spots."
date: 2026-09-19T11:30:00+02:00
tags: ["llm", "agents", "tool-calling", "prompting"]
keywords: ["llm tool selection", "reduce prompt tokens tool definitions", "agent tool routing", "too many tools llm"]
series: "Agent design patterns"
toc: true
source_product: "www.nevergoblank.com"
source_url: "https://www.nevergoblank.com/"
related_service: "ai-workflows"
---

Every tool you give a model is a definition in the prompt: a name, a description and a parameter schema. With dozens of tools, that is a lot of input tokens on every call, and more choices to confuse the model. So teams show it a subset. There are two common ways to pick the subset, and each has a characteristic way of failing.

We have not measured the savings, so this article has no numbers on them. Measure yours before you decide the extra complexity is worth it.

## Option 1: a keyword router

Map keywords in the user's message to categories of tools, and include only those categories. It is cheap and fast: no extra model call, just string matching.

What it gets wrong:

- **A message with no keyword.** A question like "should I take the offer?" matches nothing, so the model gets only a default set of tools. It answers from what it has, and it is not told that other tools exist.
- **A tool the model needed but the router did not include.** The failure is silent. The model does its best with the wrong tools.
- **Keyword lists drift.** Every new feature needs new keywords, and nobody notices when they are missing.

Fixes that help:

- Always include the tools the agent relies on in every turn.
- Send the **names and one-line descriptions** of the hidden tools, so the model knows what it could ask for.
- Offer a **meta-tool** that lets the model request more tools.
- Skip filtering for the tiers where the token cost does not matter.
- **Count fallbacks to the default set.** A rising rate means your keywords are not matching real traffic.
- Consider suppressing all tools on plain small talk, so a greeting does not carry the whole toolbox.

## Option 2: a cheap selector model

Make one call to a small, cheap model with the user's message and the list of tools, and ask it to pick the few that are relevant. This understands meaning instead of keywords, so it copes with the message that has no keyword.

What it gets wrong:

- **It is an extra call.** It adds latency and a small cost to every request. Skip it when the tool list is already short.
- **It sees only names and descriptions.** A vague description leads to a wrong pick.
- **It can fail.** Any error, timeout or unparseable answer must fall back to the full tool set, and you should count each of those cases.
- **It needs its own time limit**, so a slow selector cannot delay the whole response.

We keep this option opt-in, off by default.

## Choosing

- If your tools fall into a few clean categories, start with keywords and add the fixes above.
- If requests are open-ended, a selector handles them better, at the price of a call.
- If you have only a handful of tools, show them all. The saving is small and the routing is one more thing to break.

Whichever you pick, watch what it cannot see. Count how often the model needed a tool that was hidden, and how often the router fell back to its default.

If you would like help designing tool exposure for an agent, [get in touch](/contact/).
