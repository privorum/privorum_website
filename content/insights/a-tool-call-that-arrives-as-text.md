---
title: "The model answered. We threw the answer away."
description: "A model gave complete, valid answers and our system discarded them as errors. How we found it, how we fixed it safely, and the bug we found in our own fix."
date: 2026-10-04T13:50:00+02:00
tags: ["llm", "tool-calling", "parsing", "guardrails"]
keywords: ["llm tool call as text", "parse tool call from message content", "open-weight model tool calling parse error", "llm xml tool call parser", "llm output parser injection"]
series: "LLM tool calling in production"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

Some of the costliest failures look like caution.

One of our AI checks has to return a structured decision before anything else is allowed to happen. For one open-weight model, many of its results came back as "parse error", with a score of zero. The system did what it should do when it cannot read an answer: it stopped. No alarm, no outage.

It took us a while to ask the uncomfortable question. Was the model failing, or were we?

*A note on names: the tool, field and value names in this article are invented for illustration. The shape of the problem and the fix are real.*

## The answer was sitting right there

We stopped reading error messages and read the raw responses. This is what the model had written:

```text
<tool_call>
<function=submit_review>
<parameter=decision>
reject
</parameter>
<parameter=score>
0.40
</parameter>
<parameter=notes>
["first note", "second note"]
</parameter>
</function>
</tool_call>
```

A complete, well-formed answer, with a decision, a score and notes. The model had written its tool call as text instead of returning a structured call, and our parser, which only spoke JSON, saw no answer at all. We had asked a good question and then ignored the reply.

The clue that cracked it was boring. We grouped the failures by the model that served them, and they clustered on one model. A problem that follows a single model is a conversation problem, not a prompt problem.

## Why we did not see it sooner

The system failed safely. The failure was recorded as a failed check, and the action was held back. That is the behaviour you want, and it is also why nobody looked. Our failure tracking covered other failure classes and had almost nothing for this one. Real answers were being thrown away, politely, and everything stayed green. The same pattern shows up in [Our fallback hid an outage for weeks](/insights/fallback-hid-an-outage/).

A safe failure is still a failure. Count them, and count them per model.

## The tempting fix, and why it is a trap

The obvious move is to teach the parser the format. It is a few lines of regular expression. It is also how you ship a vulnerability.

JSON escapes any text a model echoes back from your input. This format does not. If a user-controlled field contains a closing tag followed by a fresh parameter, and the model repeats it, that text can add a field or overwrite one. A parser that quietly picks a winner can let an outsider write part of the decision.

So we built the parser around one idea: **when the text is ambiguous, refuse to read it.**

- **Name decides the type, not the look of the text.** A string field containing `42` stays a string. A score of `85%` becomes a number. We know which fields are which from the tool schema.
- **Only known names are accepted.** A parameter the schema does not define rejects the whole call, so echoed text cannot add a field.
- **Duplicates, a second call, or an unreadable value reject the whole call.** No guessing. That includes numbers that are not finite and a list field that is not a list.
- **Read to the last `</function>`**, so an echoed closer inside a value cannot cut off the real parameters after it. A parameter that never closed, which is what a response cut off by a token limit would leave behind, is dropped, never half-read.
- **Run it before the brace-matching fallback.** A list value such as `[{"k": 1}]` is itself a valid JSON object, and brace matching would happily return that fragment instead of the call.

Here is the idea in a few lines:

```python
import json
import math
import re

PARAM = re.compile(r"<parameter=(\w+)>\s*(.*?)\s*</parameter>", re.S)
STRINGS = {"decision"}
NUMBERS = {"score", "weight"}      # typed by field name, never by how the text looks
OPTIONAL = {"weight"}              # a model may write null for these
LISTS = {"notes"}
KNOWN = STRINGS | NUMBERS | LISTS

def parse_text_tool_call(text):
    """Rebuild tool arguments from a call written as text. None means 'reject'."""
    if text.count("<function=") != 1:
        return None                          # no call, or two: ambiguous
    body = text[text.index("<function="):]
    if "</function>" in body:
        body = body[: body.rindex("</function>")]   # the LAST closer, not the first
    args, seen = {}, set()
    for name, raw in PARAM.findall(body):
        if name not in KNOWN or name in seen:
            return None                      # unknown or repeated name could be forged text
        seen.add(name)                       # record BEFORE any 'continue' below
        if name in OPTIONAL and raw.lower() in {"", "null", "none"}:
            continue
        try:
            if name in NUMBERS:
                pct = raw.endswith("%")
                value = float(raw.rstrip("%")) / (100 if pct else 1)
                if not math.isfinite(value):
                    return None              # nan and inf are not scores
                args[name] = value
            elif name in LISTS:
                value = json.loads(raw)
                if not isinstance(value, list):
                    return None
                args[name] = value
            else:
                args[name] = raw             # everything else stays a string
        except ValueError:
            return None                      # unreadable value: reject, do not guess
    return args or None
```

## The twist: the bug was in our fix

We had the parser and the tests were green. Then we put it through an adversarial review, and that found a few problems we had missed.

When we went back through it ourselves, we found one more, and it is the one worth telling.

A model can write an optional number as `null`. Our first version skipped those, and it decided "have I seen this name before?" by looking at the values it had stored. A skipped field was never stored, so a later repeat of the same name looked like a first appearance and was accepted. That is exactly the forgery the duplicate rule exists to stop, slipping through the gap the optional-field handling had opened.

The cure is one line, and it is the comment in the snippet above: record the name as seen before you decide whether to keep its value. We would not have found it by admiring our tests. We found it by reading our own fix as if someone else had written it.

## How we know the fix does what we say

- **We replayed the model's real responses** through the new parser and then through our normal validation, so we tested what the model actually writes, not what we imagined it writes. The same idea is in [Record and replay for LLM tests](/insights/record-and-replay-for-llm-tests/).
- **We broke every guard on purpose.** Remove the duplicate check, the known-names check, the by-name typing, the last-closer rule, the ordering, and confirm a test fails each time. A guard whose removal changes no test is not tested.
- **We fuzzed it** against one rule: if the extractor returns anything, it is valid JSON. The fuzzer started from the format itself, including truncated, duplicated and forged inputs.

## What we took from it

Fix it at the source when you can. A different endpoint, a provider setting that returns native tool calls, or constrained decoding all beat parsing text. When you cannot, make your parser as suspicious as your firewall.

And look at your failures by model. The answer to "is it flaky?" is often "no, it is perfectly consistent, and we are not listening."

Tests that only ever feed in clean output will not catch this kind of bug, as [A stub LLM that always returns clean JSON hides your parsing bug](/insights/a-stub-llm-that-returns-clean-json-hides-parsing-bugs/) explains.

If you run LLMs in production and want someone to find what your system is quietly discarding, [get in touch](/contact/).
