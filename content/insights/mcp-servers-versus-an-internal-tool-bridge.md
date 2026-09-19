---
title: "MCP servers versus an internal tool bridge"
description: "What an MCP server can replace between an agent and your app, what we kept on an internal bridge and why, and a safe way to migrate one tool category at a time."
date: 2026-09-19T11:40:00+02:00
tags: ["llm", "mcp", "agents", "architecture"]
keywords: ["mcp server vs internal tool bridge", "model context protocol tools", "mcp migration agent", "mcp server for agents"]
series: "Agent design patterns"
toc: true
source_product: "www.nevergoblank.com"
source_url: "https://www.nevergoblank.com/"
related_service: "ai-workflows"
---

An agent needs a way to reach your application's data and actions. Many teams build an internal bridge for it: a message channel between the agent process and the app, with hand-made request and response types. The Model Context Protocol (MCP) offers a standard for the same job. This article covers what we learned running both, and what the protocol itself says.

The protocol facts below are from the official specification, as it stood on 19 September 2026 (the version dated 2026-07-28). The protocol moves quickly, so check the current spec before you build on any detail.

## What MCP is

MCP is an open protocol for connecting LLM applications to external data and tools. It uses JSON-RPC 2.0 messages between a **host** (the LLM application), a **client** (a connector inside the host) and a **server** (the service that provides context and capabilities). A server can offer three kinds of feature: **tools** (functions the model can execute), **resources** (context and data) and **prompts** (templated messages). The standard transports are **stdio**, for a server launched as a subprocess, and **Streamable HTTP**, for a remote server. The spec also defines a way for a server to ask the user for more information through the client, called elicitation.

The spec's security principles say that hosts must get explicit user consent before invoking any tool. It also says the protocol cannot enforce this by itself: your application has to build the consent flow.

## What an MCP server can replace

The clearest fit is the **data and tool-call path**: the agent asks for something, your app returns it. That is what tools are for, and a standard protocol means any MCP-capable agent can use them, not just the one you built.

It also fits when you want to open your product to **outside agents**. There, we found one design rule matters: give outside agents **intent-level tools** (a few coarse actions that map to what the user wants), and keep the **granular tools** for your own internal agent. Granular tools are easy to misuse without the context an internal agent has.

## What we kept on the internal bridge

We did not move everything, and these were choices for our setup, not limits of the protocol:

- **The model call itself.** A model completion is the opposite of a tool call: the app calls the model, not the other way round. It is also a billed, metered path. We left it as a gateway.
- **User confirmation and audit streams.** These stayed on the bridge for now. MCP does have a way for servers to request user input, so this was a decision about scope, not a claim that MCP cannot do it.
- **Ranked retrieval tools.** Our per-turn relevance signals were not being forwarded over MCP, so tools that depend on them could not move yet.

## A safe way to migrate

- **Route by category, with a switch.** A router sends each tool category over the bridge or over MCP, and the switch can be flipped back instantly. Migrate one category, watch it, then the next.
- **Share the handlers.** Both paths call the same tool handlers, including the write-tool duplicate protection. Then behaviour cannot drift between paths.
- **Keep the real schemas on the client.** Our minimal server listed tools with loose schemas, so the agent kept the precise ones itself. That is a limit of our implementation, not the protocol, and worth fixing before you rely on it.
- **Keep the implementation small.** We wrote a minimal server and client to avoid a large dependency tree. Whether that is right depends on your team; the trade-off is that you own the protocol details as they change.

## How to decide

- One agent, one app, and a bridge that works: there is little to gain from switching yet.
- Several agents, or outside agents, need your tools: a standard protocol pays for itself.
- Either way, treat every tool as an action that needs the same care: consent, duplicate protection and a metering story ([confirmation-gated write tools and idempotency](/insights/confirmation-gated-write-tools-and-idempotency/)).

If you are deciding how to expose your product to agents, [get in touch](/contact/).
