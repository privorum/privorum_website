---
title: "Drop, don't error: sanity checks on model output"
description: "When one field of a model's answer is out of range, discard that field and count it, instead of failing the whole request. How, and when not to clamp."
date: 2026-09-19T12:30:00+02:00
tags: ["llm", "guardrails", "validation", "observability"]
keywords: ["validate llm output", "llm hallucinated numbers", "llm output sanity check", "discard invalid llm fields"]
series: "Output guardrails"
toc: false
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

Models return structured answers with numbers in them: price levels, percentages, quantities. Sometimes a number is nonsense. It is out of range, points in the wrong direction, or is far outside anything plausible. You have to decide what to do.

## Three options

1. **Fail the request.** Safe, but you throw away an answer that was mostly fine, and the user gets an error for one bad field.
2. **Clamp the value** to the nearest allowed number. Tempting, and often wrong: a clamped value looks legitimate, and downstream code cannot tell it was a guess.
3. **Drop the field** and keep the rest.

We drop. A bad take-profit or stop-loss level is treated as a hallucination: the field becomes null, a warning is logged, and the rest of the analysis, which is still useful, is returned. Make sure the code that reads the field treats "absent" as a state it handles safely.

## Why not clamp

A value that is slightly out of range may be a rounding quirk. A value that is far out of range is a signal that the model misread the schema. If a field that should be a fraction comes back as 1.5, clamping it to 1.0 produces a value that looks intentional and is not. When the size of the error suggests confusion, discard it.

## What to check

- **Range**, relative to something real. Compare a price level to the current price with a plausible maximum move. The right band can differ by asset or domain.
- **Direction.** A target that sits on the wrong side of the current value is wrong by construction.
- **Units.** Percent versus fraction, and currency, are frequent confusions.

```python
def clean_level(level, spot, side, max_move):
    if level is None:
        return None
    if abs(level - spot) / spot > max_move:
        record_discard(reason="exceeds_max_move")
        return None
    if (side == "long") != (level > spot):
        record_discard(reason="wrong_direction")
        return None
    return level
```

## Count every drop, per model

A dropped field must not be silent. Emit a counter labelled by the model that served the request, the reason, and the field. Then the behaviour is visible:

- A model with a high drop rate is a candidate for replacement, and the counter is evidence.
- A prompt change that raises the rate is a regression you can see.
- An empty model label becomes "unknown", so nothing is lost.

## Why it matters most where actions are automatic

The main reason for these checks is what happens next. If the answer feeds an automatic action, a level far from the real value would size a position against the wrong distance. The check is the last line before that action.

## Checklist

- Do you have a rule for each field: fail, clamp or drop?
- Do you drop when the size of the error suggests the model misread the schema?
- Is every drop counted by model, reason and field?
- Does downstream code handle the missing value safely?

If you want your model output validation reviewed, [get in touch](/contact/).
