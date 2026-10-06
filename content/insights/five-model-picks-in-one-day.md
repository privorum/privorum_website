---
title: "We made five model picks in one day"
description: "Four ad hoc tests gave four model picks, and a fifth fell to our own scoring. The single replay protocol we use now, and the order we read its results in."
date: 2026-10-06T14:30:00+02:00
tags: ["llm", "evals", "model-selection", "testing"]
keywords: ["llm model evaluation protocol", "replay production prompts llm eval", "how to choose replacement llm model", "llm eval repeated passes stability", "llm model selection outcomes"]
series: "Evaluating models"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

A provider retired the model behind one of our decision features, and we had to choose a replacement quickly. By the end of the first day we had recommended a model, withdrawn it, recommended a second, switched to a third, withdrawn that, gone back to the second, and then argued for a fourth.

The first four were each backed by a test. That was the problem: the test kept changing.

## The five picks

1. **The cheapest model in the same family**, [DeepSeek V4 Flash](https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash). It returned valid tool calls in a short probe. On a realistic prompt, on our provider, its confidence was near zero or near one, sometimes both for the same input. Withdrawn. (DeepSeek had already retired it from its own API. Our provider still served the open weights.)
2. **Its successor**, [V4.1 Flash](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash). Steady confidence, fast. We doubted it on cost, using a figure that turned out to compare output prices only.
3. **A cheaper model from another family.** Clean on every short probe, with the best grounding score from our judge model. A replay of real prompts showed its decision changing between identical runs on about a third of them. Withdrawn, on a number that did not hold up, as the correction below shows.
4. **Back to V4.1 Flash**, which had been stable in that same replay. We shipped it as a stopgap. What that cost is in [The newer model was worse for our job](/insights/the-newer-model-was-worse-for-our-job/).
5. **A small proprietary model**, [GPT-4o mini](https://developers.openai.com/api/docs/models/gpt-4o-mini), after a larger run in which it was the only candidate with zero failures. (The retired model on other hosts went through the same test later and also passed.) We dropped the urgent switch when outcome scoring showed no difference big enough to justify it. This pick came out of the single protocol described below, and it was the protocol's own last step that took it back.

There was a correction in the middle as well. When the two finalists from picks three and four went through one identical protocol, they were level on stability. The gap that had decided between them was noise from a small prompt set.

Each test answered a real question. But the prompts, the concurrency, the number of repeats and the retry rule changed from one test to the next, so the results could not be compared, and whichever test ran last decided the pick. We were going in circles.

## One protocol

We stopped and wrote down a single test. Its first version took under an hour to run and would have replaced most of that day.

It grew twice more before the day ended: a larger sample that included the rare cases, and then a step that scores outcomes. It is now our default for any model or prompt change on a decision path, and the scoring is fixed before a run starts. We did not manage that the first time, as the outcome step below shows.

**Replay production.** The sample is a few hundred real requests that the current model answered in production, rebuilt from the stored inputs, each with the answer it gave at the time.

**Stratify on the rare cases.** The answer that can trigger an action is a few percent of traffic. A small random sample will often contain none. Ours takes a fixed quota of each kind of answer, so the cases the decision turns on are present. Results are re-weighted to the real mix before anyone quotes a traffic-level rate.

**Send the production request.** Same forced tool call, same temperature, same output budget, same flags. A benchmark that sends a slightly different request measures a slightly different system. More on that in [What broke when we tested 20+ models](/insights/what-broke-when-we-tested-twenty-models-on-one-tool-call/).

**Several identical passes.** One pass cannot tell you whether a model agrees with itself. Identical means the same request, at the low temperature production uses.

**All candidates in one run.** Same day, same concurrency, same retry rule, and the client timeout production uses.

## The order we read the results in

The order is part of the protocol. Reading the interesting numbers first is how a broken model gets shipped.

1. **Liveness.** Pass means zero failures. An empty answer, malformed tool JSON, a missing field, a timeout, or a rate-limit refusal that survives the retries all count. A model that fails here is out, and its other numbers are not discussed.
2. **Agreement with the incumbent**, per kind of answer. This ranks candidates against each other. It does not prove a candidate is worse than the incumbent was.
3. **Gate behaviour.** How often does the candidate cross the action threshold where the incumbent did, and where it did not? A model whose confidence never reaches the gate will never act, whatever its labels say.
4. **Stability.** On how many prompts did the action change between identical passes?
5. **Outcomes.** Our decisions can be scored against what happened afterwards. We score each candidate's positive decisions next to the incumbent's, and next to a baseline that says yes to everything.

## What the outcome step taught us

We added step five late, after the large run had already been read. That is the order we now rule out, and it changed how we read step two.

"Agrees with the old model" sounds like quality. It is only quality if the old model was right. Until we scored outcomes we had no evidence either way, and we had been treating the incumbent's answers as ground truth. A past production answer is a baseline. We made the same point about judges in [Using an independent LLM judge, and its limits](/insights/using-an-llm-judge-and-its-limits/).

On the corrected sample, with between one and three dozen positive decisions per model, we could not rank the candidates against one another. That moved the decision to where it belonged: reliability, speed and cost.

## The sixth mistake

The protocol did not make us right. The first large sample it ran on was itself flawed, and several conclusions built on it had to be withdrawn the next day. That is the subject of [Half our replay sample tested the wrong prompt](/insights/half-our-replay-sample-tested-the-wrong-prompt/).

What the protocol did was make the mistake findable. With one sample, one request shape and one scoring script, a wrong result has one place to be wrong.

## Checklist

- Is there one written test for a model change, or a new one each time?
- Was the scoring fixed before the results were read?
- Does the harness send exactly what production sends?
- Do you report failures first, and stop there if there are any?

If you are choosing a model for a decision path and want the test built before the argument starts, [get in touch](/contact/).
