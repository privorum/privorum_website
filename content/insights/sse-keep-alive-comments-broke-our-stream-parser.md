---
title: "SSE keep-alive comments broke our stream parser"
description: "Slow streams on OpenRouter open with comment lines before any data. Our reader took them for broken JSON and reported the host as failed. Fix and tests."
date: 2026-10-06T11:00:00+02:00
tags: ["llm", "streaming", "openrouter", "parsing"]
keywords: ["openrouter processing sse comment", "sse comment line json parse error", "llm streaming parser keep-alive", "server-sent events colon line", "openai compatible streaming parse error"]
series: "Changing models and providers"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

A streaming chat response is a sequence of server-sent events. Many hand-written clients assume a streamed body begins with `data:`. Ours did. Then we tested a route through [OpenRouter](https://openrouter.ai/), and a streamed response opened like this:

```text
: OPENROUTER PROCESSING

: OPENROUTER PROCESSING

data: {"id":"...","choices":[{"delta":{"role":"assistant","content":""}}]}

data: {"id":"...","choices":[{"delta":{"content":"The"}}]}
```

Those first lines are SSE comments. They are legal and documented, and our reader treated the whole response as broken.

## What the reader did

Our client decides from the start of the body whether it has a stream of events or a single JSON document, because we have seen providers answer with either. The rule was: a body that begins with `data:` is a stream. Anything else is JSON.

A body that begins with a colon is neither, by that rule. It went to the JSON parser, which failed on the first character. The provider was marked as failed for that request.

On this route a failed primary hands the request to a backup, and the backup is a different model. So the user would still have received a streamed answer. It would have come from the wrong model, and nothing on the surface would have said so.

## Why nobody saw it

**It showed up with long prompts.** The comments are sent while the upstream host is slow to produce its first token. Our sample is small: the streams we opened with a one-line prompt started with `data:`, and four of the five we opened with a production-sized prompt started with comments.

**Our live test used a one-line prompt.** It passed twice with the defect in place.

**The failure would have been absorbed.** The backup answers, so there is no error for anyone to report.

We found it by running the live tests again before merging the change.

## It was in the documentation

[OpenRouter's streaming documentation](https://openrouter.ai/docs/api_reference/streaming) says that it occasionally sends comments to prevent connection timeouts, shows this exact line, and notes that the comment payload can be ignored per the [SSE specification](https://html.spec.whatwg.org/multipage/server-sent-events.html). It also warns that if you parse the stream by hand you should skip lines that start with a colon before parsing JSON.

Our reader did not follow it. "OpenAI-compatible" describes the JSON. The transport is standard SSE, and a provider may use any part of that standard.

## The fix

The fix was one change, in how we detect a stream: any SSE line marks a stream, not only a data line.

```python
SSE_FIELDS = ("data:", "event:", "id:", "retry:")

def looks_like_sse(body_start: str) -> bool:
    for line in body_start.splitlines():
        line = line.strip()
        if not line:
            continue                      # blank lines separate events
        return line.startswith(":") or line.startswith(SSE_FIELDS)
    return False
```

The check needs the first non-blank line in full, so buffer until you have one before deciding. Where you can rely on it, the `Content-Type` header is the cleaner signal: a stream is `text/event-stream`.

The part of our reader that walks the lines already skipped everything that was not a data line, so it needed no change. If you are writing one from scratch, this is the shape:

```python
import json

def read_stream(lines):
    for raw in lines:
        line = raw.strip()
        if not line or line.startswith(":"):
            continue                      # blank line or comment: not an event
        if not line.startswith("data:"):
            continue                      # event:, id:, retry: carry no payload here
        payload = line[len("data:"):].strip()
        if payload == "[DONE]":
            return
        chunk = json.loads(payload)
        if chunk.get("error"):            # an error can arrive mid-stream with HTTP 200
            raise RuntimeError(chunk["error"])
        yield chunk
```

The error branch is not something we ran into. It comes from the same documentation page. Once response headers are sent, the 200 status is committed. A later error arrives as an event in the stream, not as an HTTP status. A reader that only checks the status code reports success for a stream that carried nothing but an error.

This sketch treats each `data:` line as one complete JSON payload, which is what chat completion streams send. The SSE format also allows one event to span several `data:` lines. If your provider does that, join them before parsing.

It also returns quietly when a stream stops early. A production reader should check that it saw `[DONE]` or a finish reason, and treat a stream of nothing but comments as a failure. Split the stream on line endings only: `str.splitlines()` also splits on characters that are legal inside JSON strings.

## How we test it now

- **The live streaming test uses a production-sized prompt.** With the old detection it failed in three runs out of three. With the fix it passed in four out of four.
- **We kept the real body.** A recorded response that opens with keep-alive comments is replayed in every test run, with no key and no network. How we record it is in [Recording the bad day](/insights/recording-rate-limits-and-retries-for-replay/).
- **Live tests of an intermittent path run more than once.** One green run of something that happens most of the time, not all of the time, proves little.
- **Watch the share of answers served by the backup.** A bug like this one raises no errors. It moves traffic to the backup, and that share is the only number that changes. Check that your measure of it includes streamed answers.

## What to take from it

If you read SSE by hand, read the format's line rules, not just the examples in one provider's quick start. Comments, blank lines, multi-line data and mid-stream errors are all part of it.

And test with the prompt you send in production. A short prompt exercises your code. A long one exercises the path between you and the model, and that path has behaviour of its own.

If you are integrating a new provider and want the edge cases found before your users find them, [get in touch](/contact/).
