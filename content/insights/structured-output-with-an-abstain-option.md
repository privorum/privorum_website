---
title: "Structured output with an abstain option"
description: "Models over-commit to an answer when the right response is insufficient data. Make abstain a first-class value with a required reason, and route it to a human."
date: 2026-09-19T12:20:00+02:00
tags: ["llm", "structured-output", "guardrails", "evals"]
keywords: ["llm abstain option", "llm structured output insufficient data", "llm overconfidence structured output", "llm abstention"]
series: "Output guardrails"
toc: false
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

Ask a model to classify something using a fixed set of answers, and it will pick one. If none fits, it still picks one. In a system where the answer triggers an action, a confident wrong answer is worse than no answer.

## What we saw

In one evaluation, the reference answer for a case was "insufficient data". Every model we tested still committed to a definite assessment. Across the cases, their agreement with the reference was low, and the evaluation's own conclusion was that the models over-call a direction where they should abstain.

The fix we chose was to change the shape of the answer, not only the prompt.

## Make abstaining a normal value

Put the option in the schema, next to the real answers, and require a reason:

```json
{
  "decision": {"enum": ["approve", "reject", "insufficient_data", "abstain"]},
  "abstain_reason": {"enum": ["missing_input", "conflicting_evidence", "low_information"]}
}
```

Two separate values are deliberate. `insufficient_data` says the inputs did not support any answer. `abstain` says the model chose not to commit, and the reason says why. Downstream code and analysts can treat them differently.

A required reason has a second use: a distribution of reasons tells you what to fix. Many "missing input" abstains point at a data pipeline, and many "conflicting evidence" ones point at the prompt.

## Enforce it on the server

A JSON schema is not enough on its own. A rule like "the reason is required when the decision is abstain" is a conditional, and providers and models handle conditionals unevenly. In our schema the requirement is stated in the field description, and the server enforces it:

- An abstain with a missing or invalid reason is coerced to a default reason, and a warning is logged.
- A reason on a decision that is not an abstain is dropped.

Count both cases. A rising number of coerced reasons means the model is not following the schema.

## Route abstain to a person

An abstain should never trigger the automatic action. In our system it is blocked in every mode and goes to a review queue. That is the point of the option: the model can say "I cannot tell", and the system has somewhere safe to send that.

## Check the result

Once the option existed, we looked at where abstains land. They cluster at low confidence, which is what you want from them, and a later counterfactual review of the gate judged it to be working. Check the same for yours: an abstain option that the model uses on easy cases, or never uses, needs a prompt or threshold fix.

## Checklist

- Is abstain a value in the schema, with a required reason?
- Is the requirement enforced server-side, and are violations counted?
- Does an abstain block the automatic action?
- Is there a review path for abstained cases?
- Do you look at where abstains fall?

If you want help designing output schemas and guardrails for an LLM decision system, [get in touch](/contact/).
