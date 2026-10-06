---
title: "Recording the bad day: replay tapes for rate limits and retries"
description: "Our record and replay setup could not hold a 429 followed by a 200. What a sequence recorder needs, and how to capture failures no host gives on demand."
date: 2026-10-06T12:50:00+02:00
tags: ["llm", "testing", "record-replay", "reliability"]
keywords: ["record replay llm retry test", "vcr cassette 429 retry sequence", "test llm rate limit handling", "replay llm failover test", "vcr sequential interactions retry"]
series: "Evaluating models"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

We have used record and replay for LLM tests for a while: record a real exchange with the provider once, then replay it in every test run with no key and no network. The basics are in [Record and replay for LLM tests](/insights/record-and-replay-for-llm-tests/).

That setup covered the good day well. One request, one answer. When we rebuilt a route with pinned hosts, a retry on rate limits and a backup model, the behaviour worth testing was the bad day: a rate-limit refusal followed by success, a refusal on every attempt, a stream that opens strangely. Our live tests for those paths cost money on every run, and they depended on a host misbehaving on cue.

So we recorded the bad day. It needed a different recorder.

## Why our recorder could not hold a retry

Our standard recorder matches a request to a recorded interaction and serves it. If the same request comes again, it serves the same interaction again. Some stock tools avoid this by default (vcrpy plays each recorded response once). Ours allowed repeats, and for a retry that is fatal in two ways.

- **On replay.** A recorded "429, 429, 200" replays as 429 for ever, because the first match wins every time.
- **While recording.** The second attempt matches the interaction just written to the tape and is answered from it. The retry never reaches the host. You end up with a tape of your own first failure.

A retry is a sequence. The recorder has to treat it as one.

## What a sequence recorder needs

```python
import json


class OrderedReplay:
    """Serve each recorded interaction once, in order."""

    def __init__(self, interactions):
        self.interactions = interactions
        self.cursor = 0

    def respond(self, request):
        if self.cursor >= len(self.interactions):
            raise AssertionError("more calls than the tape holds")
        recorded = self.interactions[self.cursor]
        if match_key(request) != match_key(recorded.request):
            raise AssertionError("call does not match the next recorded call")
        self.cursor += 1
        return recorded.response

    def check_nothing_left(self):
        left = len(self.interactions) - self.cursor
        if left:
            raise AssertionError(f"{left} recorded answers were never requested")


def match_key(request):
    body = request.json
    pin = json.dumps(body.get("provider"), sort_keys=True)   # key order must not matter
    return (request.host, body.get("model"), body.get("stream", False), pin)
```

Three rules sit in that sketch.

**Each interaction is served once, in order.** That is what makes "refused, then served" replayable.

**Match on the route, not the prompt.** We match on the host, the model, the stream flag and the routing block that pins the hosts. A reworded prompt does not force a paid re-record, and a changed pin finds no recorded answer and fails, which is what we want from a test about routing.

**Every recorded answer must be used.** A replay that makes fewer calls than the tape holds fails. Without this, a retry that gives up one attempt early passes on the answers it did reach.

## Rules for recording

**A failed recording never replaces a tape.** Record mode writes to a temporary directory and moves the tape into place only if the test passed.

**A missing tape fails. It does not skip.** A skipped test reads as green in most reports.

**Scrub more than the headers.** The error bodies we recorded carried an account identifier. A scrub that only removes credentials from headers would commit that ID.

**Do not hand-edit a tape.** If the route changed on purpose, record it again. An edited tape is a mock with extra steps.

## Getting a host to misbehave on demand

You cannot ask a host to refuse you. We needed a tape of one refusal followed by success, and a tape of a refusal on every attempt.

What worked was to have each test state exactly which shape it wants, run it against the live hosts, and fail the recording if the host did something else. Then run it again. On the afternoon we recorded, our two-host route answered at once eight times in a row, while one of the hosts on its own refused often. So both refusal tapes are pinned to that single host. The "refused on every attempt" tape took six tries.

When recording one of these fails, the host did not misbehave on cue. The failure message says that, so nobody debugs the code.

The same approach captured a streamed response that opens with keep-alive comments, the real body our reader once mistook for broken JSON. That story is in [SSE keep-alive comments broke our stream parser](/insights/sse-keep-alive-comments-broke-our-stream-parser/).

## What the tapes cover now

A dozen tapes, most holding a single recorded call and a few holding a sequence. Among them:

- the pinned route answers and the backup is never asked;
- one refusal, then an answer from the primary;
- a refusal on every attempt, then the backup answers under its own name;
- a "model not found" from one provider, handed over to another: the incident that started this series, now replayed in tests.

All of them replay with no key and no network.

## What a tape cannot tell you

Replay guards your side of the wire, and your reading of answers the hosts really gave. It does not guard the hosts.

- **Hosts change.** A host that starts refusing, drops tool calling or renames a model is invisible to a tape. That needs live tests on a schedule, and monitoring.
- **A refusal rate is not replayable.** How often a host refuses is a measurement of one hour. We saw close to half of first attempts refused in one window and none an hour later.
- **Timing is not on the tape.** Replay shortens the retry waits to almost nothing and keeps the number of attempts and the statuses. Deadlines need unit tests and a list of every caller's deadline, which is the subject of [The retry that could never run](/insights/the-retry-that-could-never-run/).

A replayed test is a regression guard. It is never proof that the integration works today.

## Checklist

- Can your recorder hold the same request with two different answers?
- Does a replay fail when recorded answers go unused?
- Can a failed recording overwrite a good tape?
- Have you scrubbed response bodies, not only headers?

If you want the failure paths of your LLM integration tested without paying for every run, [get in touch](/contact/).
