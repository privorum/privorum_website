---
title: "Grade the tool call, not the text"
description: "Our first benchmark run scored zero for every model because the grader read message text while the answer was in tool-call arguments. How to grade it right."
date: 2026-09-19T10:10:00+02:00
tags: ["llm", "evals", "tool-calling", "testing"]
keywords: ["llm eval tool call arguments", "grading structured output llm", "llm benchmark scores zero", "tool calling evaluation"]
series: "Evaluating models"
toc: false
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

We built a small bench to compare models on real prompts. The first run scored 0.00 for every model. That is a strange result, and the cause was not the models.

## What happened

Some of our fixtures force the model to answer through a tool call. You give it a "record your analysis" tool and require it to use it. That is a good way to get structured output, and it changes where the answer lives: in the arguments of the tool call, and not in the message text.

Our grader read the message text. For those fixtures the text was empty, so the judge was given an empty string and scored it zero. Every model got zero for the same reason.

A related bug appeared in a different bench. A confidence value was read from the message content, so it came out near zero for every tool-based result, when the real value sat in the tool-call arguments.

## The fix

Grade the output the way the contract defines it. If the response has text, grade the text. If not, assemble the answer from the tool-call arguments:

```python
def gradable_output(response):
    if response.text.strip():
        return response.text
    return "\n".join(call.arguments for call in response.tool_calls)
```

Then add two tests: one where the answer is in the text, one where it is only in the tool-call arguments and the score must not be zero.

## Why the bug hid for so long

Two things made it easy to miss.

- **The output looked plausible.** A table of zeros still has all the right columns. Nothing crashed.
- **Nothing pointed at the grader.** Every model scored the same, so the obvious suspects were the models and the prompts, not the code that reads the answer.

## How to catch this class of bug

- **Distrust uniform results.** All zeros, all ones, or identical scores across models are a sign that the grader, not the models, decides the outcome.
- **Print what the grader saw.** Save the exact string handed to the judge for a few samples. An empty string is obvious once you look.
- **Test the grader with known answers.** Feed it a fabricated response with a correct tool call and one with a wrong one, and check the scores separate.
- **Write down where each fixture's answer lives.** Text, tool-call arguments, or a structured-output field. Grade from that place.

## Related pitfalls

A grader that returns 100% on an empty response is the mirror image of this bug: [The eval that scored 100% with zero tool calls](/insights/eval-scored-100-percent-with-zero-tool-calls/). Both come from the same mistake, which is trusting a metric without checking what it measured.

If you want a second pair of eyes on your eval harness, [get in touch](/contact/).
