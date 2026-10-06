---
title: "Half our replay sample tested the wrong prompt"
description: "We rebuilt production requests for a model eval and paired nearly half with answers to a different prompt. How it showed, what we withdrew, and the guards."
date: 2026-10-06T14:00:00+02:00
tags: ["llm", "evals", "data-quality", "testing"]
keywords: ["llm eval sample contamination", "replay production data llm evaluation", "llm eval wrong reference answer", "selection bias llm eval", "evaluation dataset mixed prompts"]
series: "Evaluating models"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

To choose a replacement model we replayed real production requests to each candidate and compared the answers with what the old model had said. It is the most realistic test we know. We had fixed the protocol and stratified the sample, as described in [We made five model picks in one day](/insights/five-model-picks-in-one-day/).

Nearly half of that sample was wrong, and we reported conclusions from it before we knew.

## How the sample was built

We do not replay stored request text. We store the answer and the structured inputs, and a small tool rebuilds the request from them with the current prompt. That makes replay cheap, and it carries a hidden assumption: that every stored row was produced by the prompt you rebuild it with.

Ours were not. The store we sampled from holds answers from three features that share a model, and each has its own prompt. We had excluded one of them for exactly this reason. We missed the other, and the tool rebuilt its rows with the first feature's prompt.

So for nearly half the sample, a candidate was asked question A and its answer was compared with the old model's answer to question B.

## What it looked like from inside

Nothing looked wrong. Every request was well formed, and the scoring script produced a clean report. The numbers were strange in an interesting way, and we explained them instead of doubting them:

- One candidate never reached the action threshold where the old model had. We reported that it would never act, unlike the old model.
- Only one candidate reached the threshold the way the old model did, and the decisions it took there turned out badly. We concluded that reproducing the old model's confident answers reproduced its mistakes.
- The old model's high-confidence answers had worse outcomes than its lower-confidence ones. We concluded the confidence threshold on this feature did not select the better decisions.

Each was a reasonable reading of the report. Each rested on rows that belonged to the other feature. Nearly all of the old model's high-confidence answers came from that feature, so mixing its rows in changed every one of those statistics.

## The clue

We had also run the old model itself, the same weights, on two independent hosts. Both disagreed with the production answers on a large group of prompts. And they disagreed in exactly the same way.

One host disagreeing with production could be the host. Two unrelated hosts making the identical "mistake" on the same prompts pointed somewhere else: at the question, not the model.

We grouped the sampled rows by the feature that had produced them. The group where both hosts "failed" was the second feature.

## What we withdrew

We went back through the write-up and marked every statement that depended on the mixed rows. Five conclusions were withdrawn in writing, each with its reason next to it. Some of them we had already reported. One had gone into a message to a provider's support team.

What survived: liveness, speed, cost and stability. A mixed row is still a well-formed request of production size, and whether a model returns a valid answer in time does not depend on whether the reference answer belongs to the prompt.

On the valid half the picture was simpler and less dramatic. The old model had almost never crossed the threshold on that feature either, so the candidate that "would never act" was not a regression there.

## Three guards

**The sampler only takes rows it can rebuild faithfully.** A row is sampled only if it was produced by the prompt version the tool rebuilds with. A stratum can now come back short or empty, and that is the honest result.

**One run is one surface.** The scoring script reads which feature the fixtures belong to and refuses a mix. The second feature got its own sampler, its own request shape and its own scoring rule, and a test that holds the rebuilt request equal to what the feature really sends.

**Check that the reference column means what you think.** While building the second feature's sample we found another trap. The column we had been reading as the model's verdict was a downstream flag that recorded whether the system had acted. Scoring against it would have compared a model with a decision the system took later.

## The selection effect we almost reported next

With the right prompt and the right reference, one result still looked like a gap. We took the prompts where the old model's production answer had crossed the threshold and replayed them to the same model on new hosts. It crossed the threshold on about two thirds of them.

That does not mean the new hosts agree with the old one only two times in three. Those prompts were chosen because production's single answer landed above the line. The model's confidence moves in steps near the threshold, and identical runs on one host landed on different sides of the line on nearly one prompt in five. A second draw from the very same deployment would also fall short of all of them. Part of the gap is selection. We cannot say how much, because the original host no longer serves the model.

Any stratum picked on the incumbent's answer flatters the incumbent. Compare a candidate's count with another candidate's, or with the incumbent's own rerun, never as a percentage of the original.

## Before you trust a replay sample

- Group the sampled rows by the feature and prompt version that produced them. Is it one group?
- Does the reference column hold the model's answer, or something computed from it later?
- Do you have a control, such as the incumbent on a second host, or simply the incumbent run again?
- When a result is surprising, have you checked the data before explaining the model?

The mistake cost us a day and some embarrassment. The run that exposed it cost almost nothing. Run a control first.

If you are building an evaluation on production data and want the sample checked before the conclusions are, [get in touch](/contact/).
