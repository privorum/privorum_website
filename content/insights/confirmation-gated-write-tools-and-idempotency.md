---
title: "Confirmation-gated write tools and idempotency"
description: "Pause agent write actions for user approval and make retries safe: race conditions, declined and expired approvals, and idempotency keys against double writes."
date: 2026-09-19T11:10:00+02:00
tags: ["llm", "agents", "tool-calling", "safety"]
keywords: ["agent human in the loop confirmation", "llm agent idempotency", "agent write tools approval", "idempotent tool calls"]
series: "Agent design patterns"
toc: true
source_product: "www.nevergoblank.com"
source_url: "https://www.nevergoblank.com/"
related_service: "ai-workflows"
---

Read-only tools are easy to give an agent. Write tools are different: a wrong call changes real data. Two ideas make them safe enough to ship. The user approves the action first, and running the same action twice does no harm.

## Pause for approval

When the model asks for a write tool, do not run it. Send the user a confirmation request that shows what will happen, and have the loop wait for the answer.

A few details matter more than they look.

**Listen before you ask.** If your confirmation travels over a message channel, subscribe to the reply channel **before** you publish the request. Do it the other way round and a fast reply can arrive before anyone is listening, and the loop waits forever. We have a test for this ordering.

**Give the model the outcome, whatever it is.**

- If the user declines, return that to the model as the tool result, so it can adapt and offer an alternative.
- If the request expires, return an expiry result, so the model can re-ask or drop the task.
- If the confirmation channel itself fails, abort the turn. Do not guess.

**Run what was approved.** Execute the tool with the arguments the user saw and approved, not with the model's original arguments if they could have changed in between.

**Bound the waiting.** Give the confirmation a time limit. And note the known gap: a timeout does not by itself stop the agent from asking again. If that matters, count re-requests per turn.

## Make retries safe

Approval prevents unwanted actions. It does not prevent duplicate ones. Duplicates come from redelivered messages after a restart, a client that retries after a dropped response, or a model that repeats a call.

Layers that work together:

- **Skip redelivered messages.** Claim each message ID once, so a restart does not re-run a request that was already handled.
- **Cache successful writes by intent.** Key a short-lived cache on the user, the tool and a hash of the arguments. A duplicate call returns the earlier result instead of writing again. Keying on the user matters, so one user's result is never replayed to another.
- **Use natural keys when you have them.** In an integration that records trades, the external order ID is a natural idempotency key. A retry after a lost acknowledgement finds the existing record and writes nothing.

## Tell the truth about what happened

When a retry is answered from the existing record, say so in the response. In one integration an earlier version reported a full write even on a replay. A user importing a long history could not tell which records were new. The response should distinguish "created" from "already existed".

## Checklist

- Does every write tool require approval, with the arguments shown?
- Is the reply listener registered before the request goes out?
- Do decline and expiry reach the model as results?
- Are duplicates handled at more than one layer?
- Does the response say whether a write happened or was replayed?

If you are designing write actions for an agent, [get in touch](/contact/).
