---
title: "The retry that could never run"
description: "We built a deadline-aware retry for rate-limited LLM calls. On our main path the callers' deadlines were too short for it to start. List the callers first."
date: 2026-10-06T11:45:00+02:00
tags: ["llm", "reliability", "timeouts", "testing"]
keywords: ["llm retry 429 deadline", "deadline-aware retry", "llm timeout fallback", "context deadline retry never runs", "llm rate limit retry backoff"]
series: "LLM operations"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

While testing a route through shared hosts, we saw rate-limit refusals: HTTP 429, in short bursts. A refused call that is sent again a few seconds later usually succeeds.

So we built a retry. We tested it, it passed two code reviews, and we wrote down that retries were in place.

Before merging it we verified it once more, in a different way, and found that on the most important path in the system the retry would almost never run.

## A retry that respects deadlines

The retry was written carefully. It fires only on rate-limit and overload responses. It waits a little longer each time. And it is deadline-aware: it starts another attempt only if the caller's remaining time covers the wait, a full call at the slow end of what the model takes, and a call to the backup model in case that fails too.

That last rule is the right design. A retry that ignores the caller's deadline can use up all the time and leave none for the backup, which turns a refusal into a timeout.

It is also the rule that made the retry disappear.

## The census we had not done

The numbers below are invented for illustration. The shape is real.

Say the retry waits 7 seconds, then 11, and keeps 65 seconds in reserve for the call and the backup. The first retry needs a caller with at least 72 seconds left.

We had read the code that calls the model. We had not listed every caller of that code with the deadline each one sets. When we did, the table looked like this:

```text
caller                    deadline   retry can start?
interactive request       100s       yes
background job            200s       yes
queue worker              40s        no
batch job                 22s        no
```

The workers that carry almost all the traffic on the path that acts on decisions gave a request less time than the first retry needs. There, one refusal would have gone straight to the backup model, every time. The retry was live code on the paths that mattered least and dead code on the one that mattered most.

Our change description had named one of those workers as the exception. It was the rule.

## Why tests and reviews missed it

- **A test asserted the short-deadline behaviour as intended.** It checked that a caller with little time left does not retry. It passed, and it was correct. It also described the main path, and nobody had connected the two.
- **The reviews covered the package that changed.** The deadlines lived in the callers, in other packages, written long before.

## A timing test that could not fail

Earlier in the same work we had met a smaller version of this blindness. A test meant to prove that one route does not wait gave its call a deadline of a few seconds. Under a deadline that short the retry gives up at once, so the test passed whether the code waited or not. We saw it only when we broke the code on purpose and the test stayed green.

The fix is a long deadline plus a watchdog that cancels early, so code that waits fails the test fast.

## The opposite edge

Listing the deadlines exposed a second problem on the other side.

If the primary answered slower than the caller's deadline, the call ended as an error and the backup was never asked. Our failover deliberately skips the backup when the caller's time is already up, because nobody is left to use the answer. With the old model on the old provider, no recorded call had been slower than that deadline. In our test runs on the new hosts, between a few percent and about one call in seven were, depending on the host and the evening.

A deadline shorter than your model's tail does not only disable retries. It turns slow answers into failures with no fallback.

## Two more things the deadline broke

**The circuit breaker.** We skip a primary that keeps failing, so that callers do not wait through a retry schedule for a host that is down. A refusal that was not retried because the caller ran out of time counted the same as an exhausted schedule. A few short-deadline callers in a row could switch the primary off for everyone, including the patient callers that would have retried successfully. In our fix, a refusal that was not retried for lack of time carries its own error type and does not count.

**The status write.** One path wrote its final status using the same context that had just expired. The write failed, and the work item stayed marked as in progress with nothing left to pick it up. Cleanup after a timeout has to run on a fresh context.

## The fix was one number, in one place

The decision was simple: give a request enough time for the retry to run. No duplicate calls and no extra spend, only a later answer when a host is refusing.

What made it safe was how the number is defined:

- **One time limit, defined once**, and used by every path that starts the pipeline.
- **Derived, not chosen.** It is derived from the retry policy, and a test fails the build if the two drift apart.
- **A guard on the callers.** A test reads each path's source and checks the deadline that actually reaches the pipeline call. Another fails when a new path appears that is not on the list.

## Checklist

Before you write "retries are in place":

- List every production caller with its actual deadline, and say for each whether the retry can start.
- Compare your model's slowest percentile, not its median, with each deadline.
- Check what happens when the answer is slower than the deadline. Is the backup asked?
- Check what your circuit breaker counts.
- Honour a `Retry-After` header when the response carries one.
- Break the fix once and watch each test fail, timing tests most of all.

Refusals can be recorded once and replayed for free, which is how we keep these paths tested: [Recording the bad day](/insights/recording-rate-limits-and-retries-for-replay/).

If you want a second pair of eyes on the timeouts and retries around your LLM calls, [get in touch](/contact/).
