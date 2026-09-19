---
title: "A bounded agent loop that fails safely"
description: "Iteration caps, typed tool errors, a final tool-less summary step and cost budgets that fail closed: stop an agent loop from running away or leaking output."
date: 2026-09-19T11:00:00+02:00
tags: ["llm", "agents", "reliability", "cost"]
keywords: ["agent loop iteration limit", "llm agent max iterations", "agent tool error handling", "llm cost budget agent"]
series: "Agent design patterns"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

An agent loop is simple: call the model, run the tools it asks for, feed the results back, repeat until the model answers. The loop is also where most runaway cost and most ugly failures come from. This article covers four guards that make it fail safely.

## 1. Cap the iterations

The first guard is a hard limit on the number of model calls per request. Without it, a model that keeps asking for one more tool call will run until something else stops it: a timeout, a rate limit, or your invoice.

Pick a limit that covers your longest legitimate task with some room, and treat hitting it as an event you count, not as a normal outcome.

## 2. Say what happens at the cap

Hitting the cap is where many systems fail badly. The last thing the model did was call a tool, so the last thing you have is a tool result, often raw JSON. Return that to the user and you have leaked internals and given them nothing readable.

Do this instead: make one final model call **with no tools available**, and ask for a short summary of what was found so far, with a clear instruction that no more tools can be used. Because tools are absent, the model cannot loop again.

Give that step its own fallback. If the summary call fails too, return a plain, human message that says the request was too big and suggests a narrower question, not the last tool output. And write a test that asserts raw tool JSON never reaches the user on this path. We added exactly that test because the alternative was users seeing tool payloads.

Expose the state as a flag on the response, so callers and dashboards can see how often requests hit the cap.

## 3. Type your tool errors

A tool can fail in different ways, and the loop should treat them differently:

- **Transient**: a timeout, a temporary upstream error. The model may try again.
- **Permanent**: the thing does not exist, or the action is not allowed. Trying again cannot help.
- **Schema**: the model sent arguments that do not match the tool's definition. Repeating the same arguments cannot help.

For permanent and schema errors, mark the result so the model is told not to retry, and end the loop after that iteration. Otherwise the model keeps calling the same failing tool until the cap, and you pay for every attempt.

## 4. Make the cost budget fail closed

Check the spend against a per-session and per-day budget **before** doing model work, and refuse the request with a clear message when it is over.

The subtle part is what to do when you cannot read the budget, for example because the store that holds it is down. Failing open means a broken metrics store removes your spending limit. Failing closed means a broken metrics store takes the feature down.

We use a middle path: tolerate an occasional lookup error, but count them, and close the gate after repeated errors. Whatever you choose, decide it on purpose, write it down, and test it. The same goes for an **unknown price**: an unpriced model that is billed at zero also bypasses the budget, as we describe in [Your LLM cost tracking is probably wrong in both directions](/insights/llm-cost-tracking-wrong-both-directions/).

## A checklist

- Is there a hard cap on iterations, and do you count how often it is hit?
- What does a user see when it is hit? Is it a summary, never raw tool output?
- Do tool errors distinguish transient, permanent and schema failures?
- Is the budget checked before work starts?
- What happens when the budget cannot be read? Is that tested?

If you want your agent loop reviewed for failure modes like these, [get in touch](/contact/).
