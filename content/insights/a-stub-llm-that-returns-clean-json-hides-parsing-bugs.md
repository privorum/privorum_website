---
title: "A stub LLM that always returns clean JSON hides your parsing bug"
description: "Our tests passed because the stub returned tidy JSON and the check only looked at the status code. Real models add fences and prose. Test the dirty case."
date: 2026-09-19T10:40:00+02:00
tags: ["llm", "testing", "json", "parsing"]
keywords: ["llm json output parsing", "extract json from llm response", "llm stub testing", "llm markdown code fence json"]
series: "Evaluating models"
toc: false
source_product: "www.nevergoblank.com"
source_url: "https://www.nevergoblank.com/"
related_service: "ai-workflows"
---

A handler asked a model for an evaluation as JSON and stored the result. Tests were green. In production the stored value was the model's raw text, with a fence and a sentence around the JSON, and it was not usable.

## What went wrong

Two things had to be true for this to hide:

1. **The handler stored the raw model output** instead of extracting the JSON from it.
2. **The tests could not see it.** The default test setup used a stub in place of the model, and the stub always returned clean, valid JSON. The scenario that covered the handler asserted one thing: the response status was 200.

Real models often wrap JSON in a markdown code fence, add "Here is the evaluation:" in front, or explain afterwards. The stub never did any of that, so the code path that deals with messy output was never exercised. A live test that would have caught it existed, but it was skipped in CI.

## The fix, in layers

Extract the JSON in steps, each more tolerant than the last, and validate the result:

```python
import json

def extract_json(text):
    for candidate in (text, strip_fence(text), outermost_braces(text)):
        try:
            return json.loads(candidate)
        except (ValueError, TypeError):
            continue
    raise ValueError("no JSON object found")
```

- **Direct parse.** Try the text as it is.
- **Strip a code fence**, including a language tag like `json`.
- **Find the outermost braces**, and be careful with braces that sit inside string values. A naive "first `{` to last `}`" fails on text that follows the object and contains a brace of its own.

The same pattern works for a top-level array. After extraction, validate the shape: required keys, types, ranges. A parse that succeeds is not the same as a payload that is correct.

## The tests that matter

- **Unit tests for the extractor** with dirty input: a fence, a prefix, nested braces, braces inside strings, empty input, and invalid input.
- **Give the stub a dirty mode.** A setting that makes it return fenced output, prefixed output, or both, so integration tests can exercise the messy path.
- **Assert the payload, not just the status.** A scenario that checks "200 OK" proves the request did not crash. It does not prove the stored data is right. Check that the stored value is valid JSON and has the expected keys.

Be honest about how you run the dirty mode. Ours is a manual run, not part of the default pipeline, and that is a gap worth closing: a dirty-output test that nobody runs protects nothing.

## A related failure

The same shape of problem shows up in evaluation: a check that inspects the wrong thing and reports success. See [The eval that scored 100% with zero tool calls](/insights/eval-scored-100-percent-with-zero-tool-calls/).

If you want a review of the test strategy around an LLM feature, [get in touch](/contact/).
