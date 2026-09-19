---
title: "Record and replay for LLM tests"
description: "Record against live APIs once, replay in CI for fast, cheap, deterministic tests. Plus a static test that stops placeholder values reaching the model as facts."
date: 2026-09-19T10:30:00+02:00
tags: ["llm", "testing", "record-replay", "ci"]
keywords: ["record and replay llm tests", "vcr llm tests", "deterministic llm testing", "llm integration tests ci"]
series: "Evaluating models"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

LLM calls are slow, cost money, and return different text every time. That is a hard fit for a CI pipeline. The usual answers are a mock that returns a canned reply, or a live test that runs rarely. Both have a cost. Record and replay sits between them.

## The idea

1. **Record** the real HTTP interaction with the provider once, against the live API.
2. **Save** it as a file (a "cassette").
3. **Replay** it in tests: the code makes a normal HTTP call, and a transport layer answers from the file.

Libraries exist for this in most languages (VCR-style tools such as vcrpy and go-vcr). The test still runs your real request-building and response-parsing code. Only the network is replaced.

## Why not just mock the client

A hand-written mock returns what you expect. Ours returned a neutral, middle-of-the-road answer, and that hid real parsing bugs, because real responses have a different shape than the mock. We wrote about the JSON version of this in [A stub LLM that always returns clean JSON hides your parsing bug](/insights/a-stub-llm-that-returns-clean-json-hides-parsing-bugs/).

A recording is a real response, so the parsing path is exercised with real data.

## How we run it

- **Replay by default.** A mode switch controls it, and the default is replay. Recording is a deliberate act.
- **Required check in CI.** The replay suite is a merge gate, and it is not allowed to fail.
- **Scrub before saving.** Authorization headers, signatures and nonces are removed from the file before it is written. A check in the pipeline fails if a cassette still holds a secret.
- **Match on the stable parts.** Match requests on method, URL and a per-scenario tape, so that a prompt tweak does not invalidate every recording.

## What went wrong on the way

Before we recorded a single paid tape we found and fixed ten defects in the recording path itself. Two are worth knowing about:

- **A recording with no interactions overwrote a good tape.** A failed re-record wiped a working cassette.
- **A long scenario name was truncated**, so two scenarios ended up on the same tape.

Treat the recorder as code that needs tests. A silent recorder bug turns your whole suite into a false green.

## Keep the honest limits in view

Replay proves that your code handles a specific response. It does not prove that today's model still answers that way. Re-record on a schedule, or before a model change, and keep a small live smoke test for the real thing.

## A related lesson: placeholders that look like measurements

While building context for a model, we found a subtle bug that a recording would not have caught. A function that assembled market context set two numeric fields to a default of 0.5, and nothing ever overwrote them. Every prompt then said "Volatility: 0.50", as if it had been measured. The model treated it as evidence, and a downstream grader even marked a claim about volatility as grounded.

The fix has two parts:

- **Render absent values as absent.** If a value was not measured, the prompt says it is unavailable, not a plausible number.
- **A static test that fails the build.** It parses the source, finds the context struct's numeric fields, and fails if any of them is assigned a non-zero literal:

```python
import ast

def literal_defaults(source, struct_fields):
    bad = []
    for node in ast.walk(ast.parse(source)):
        if isinstance(node, ast.keyword) and node.arg in struct_fields:
            if isinstance(node.value, ast.Constant) and node.value.value not in (0, None):
                bad.append((node.arg, node.value.value))
    return bad
```

The list of fields comes from the struct definition, so a new field is covered automatically. The test also has an escape hatch with an explicit marker, and its own test that plants a known violation and checks it is caught, so the check cannot silently pass on nothing.

## Checklist

- Is replay the default, and is it a required check?
- Are secrets scrubbed, with a check that fails if one is left?
- Do you test the recorder?
- Do you re-record on a schedule?
- Can a placeholder reach the prompt looking like a measurement?

If you want to set up a deterministic test suite for an LLM feature, [get in touch](/contact/).
