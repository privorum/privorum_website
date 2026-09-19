---
title: "The 400 that only happens on the tool-result turn"
description: "A model handled a single tool call but returned HTTP 400 when we sent the tool result back, and looked fast because it failed fast. Test the continuation."
date: 2026-09-19T09:20:00+02:00
tags: ["llm", "tool-calling", "openai-compatible", "testing"]
keywords: ["tool calling 400 error", "openai compatible tool result 400", "function calling continuation turn", "open source llm tool calling"]
series: "LLM tool calling in production"
toc: false
source_product: "www.nevergoblank.com"
source_url: "https://www.nevergoblank.com/"
related_service: "ai-workflows"
---

Most quick checks of a model's tool calling look like this: send one request with a tool definition and see whether the model emits a tool call. If it does, the model "supports function calling".

That check covers half of a real agent turn. The other half is what happens when you send the result back.

## The two-turn shape

Every agent loop has the same pattern:

1. You send the conversation and the tool definitions. The model answers with a tool call.
2. You run the tool, append the result, and send the whole conversation again. The model continues.

The second request is different from the first. It contains an assistant message with a tool call and a `tool` message that answers it:

```json
[
  {"role": "user", "content": "What is the weather in Lisbon?"},
  {"role": "assistant", "tool_calls": [
    {"id": "call_1", "type": "function",
     "function": {"name": "get_weather", "arguments": "{\"city\":\"Lisbon\"}"}}
  ]},
  {"role": "tool", "tool_call_id": "call_1", "content": "{\"temp_c\": 21}"}
]
```

Some model and provider combinations accept the first request and reject this one.

## What we saw

While comparing cheap candidates for a routing tier, one model passed every single-turn test. On our multi-turn fixtures it returned HTTP 400. Every failure was on the second request of a conversation, the one that carries the tool result, which pointed at the tool-result message as the trigger.

We could not fix it with a change on our side. Trying different endpoint variants at the same provider gave the same failure, so it was a property of that model at that provider, not of one URL.

## Why it looked good on the leaderboard

A model that fails on turn two stops early. Our benchmark averaged the number of iterations per task, and this model's average was unusually low, because its failing conversations ended at the first error.

A model that fails fast looks fast. If you sort a leaderboard by latency or iteration count without gating on failures first, you promote the broken ones. The full story of the scoring side is in [The eval that scored 100% with zero tool calls](/insights/eval-scored-100-percent-with-zero-tool-calls/).

## How to test for it

- **Always test the continuation turn.** Every fixture that uses tools should include a tool result and a follow-up request. A single-shot probe is a smoke test, not a qualification.
- **Test the shapes you use.** If your agent runs several tools in one turn, or several turns in a row, test those.
- **Log the failing turn index.** "It failed" is not enough. "It failed on turn 1" tells you where to look.
- **Gate on failures.** Any HTTP error in a fixture disqualifies the candidate. Then rank by cost and speed.

## Compatible is not the same as tested

"OpenAI-compatible" describes an API shape, not a guarantee that every model behind it accepts every request shape. Your production loop depends on the shapes you actually send, so those are the ones to test.

Once a model that fails this way is in production, a working fallback will hide it. That is the subject of [Our fallback hid an outage for weeks](/insights/fallback-hid-an-outage/).

If you want help qualifying models for an agent workflow, [get in touch](/contact/).
