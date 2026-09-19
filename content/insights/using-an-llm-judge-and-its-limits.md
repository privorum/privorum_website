---
title: "Using an independent LLM judge, and its limits"
description: "A method note on LLM-as-judge: keep the judge independent, keep samples honest, treat a past production answer as a baseline and not as truth."
date: 2026-09-19T10:20:00+02:00
tags: ["llm", "evals", "llm-as-judge", "testing"]
keywords: ["llm as a judge", "llm judge bias", "self-grading llm", "evaluating llm outputs"]
series: "Evaluating models"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

When there is no single correct answer, an LLM can grade another LLM's output. We use one in our own bench. This is a note on how, and on where it should not be trusted. It is a method piece, so it contains no model rankings and no scores.

## What our judge does

For each candidate answer, the judge is given the evidence that was in the prompt, a reference answer, and the candidate's output. It returns a small verdict:

- **Grounding:** does the answer use the evidence that was actually provided, without inventing data or claiming data is missing?
- **Decision match:** does it reach the same conclusion as the reference?
- **A score** between 0 and 1, and a one-sentence rationale.

We run the judge at temperature zero, cap its output length, and ship the raw candidate output and the rationale in the report. That last part matters: a human can double-check any score in seconds.

The grounding check earned its keep. It caught answers that invented context, such as details about the market situation that were never in the prompt.

## Limit 1: the judge must be independent

If the judge is from the same model family as a candidate, it may prefer that candidate's style. Self-grading tends to inflate scores.

In one run our preferred judge was unavailable and a candidate model had to act as judge. We wrote the caveat straight into the config and the report: that model's own rows were self-graded, and only the cross-model comparison between the other candidates counted as unbiased. We did not measure how large the inflation was, so we do not claim a size.

The rule we follow: use a judge from a different family than any candidate, and if you cannot, say which rows are affected.

## Limit 2: small samples

A few dozen judged runs is a small sample. It can show a large gap, but it cannot separate models that are close. Report the sample size beside every result, and re-run before you act on a narrow lead.

## Limit 3: the reference is not ground truth

Our reference answers are earlier answers from our production system, replayed against the same inputs. That makes them a **consistency baseline**: they tell you whether a candidate agrees with what production said before. They do not tell you the production answer was right.

A candidate can score badly by disagreeing with a wrong reference, and well by agreeing with one. Use this kind of baseline to catch regressions and drift, and use human review or real outcomes when you need to know what is correct.

## Limit 4: parsing the verdict

Our judge is asked in plain prose to return only JSON, and the parser is lenient about surrounding text. It works, but a stricter setup would force the verdict through a schema, using a structured-output or tool-call mechanism, so that a malformed verdict is an error and not a guess. If you build a judge today, start there. It also avoids the trap in [Grade the tool call, not the text](/insights/grade-the-tool-call-not-the-text/), where the answer is in a different place than the grader looks.

## A short checklist

- Is the judge from a different family than the candidates?
- Are self-graded rows marked?
- Is the sample size printed beside every score?
- Do you call the reference a baseline, not the truth?
- Can a human see the raw output next to each score?
- Does a malformed verdict fail loudly?

If you are setting up model evaluation for a product, [get in touch](/contact/).
