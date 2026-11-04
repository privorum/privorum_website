---
title: "Our A/B test tested our setup, not our strategy"
description: "Two strategy tests ran four months on paper accounts. They could not answer their question, but they found six flaws in how we test. What we fix next."
date: 2026-11-04T17:00:00+01:00
tags: ["llm", "testing", "experimentation", "cost"]
keywords: ["ab test trading strategy", "ab test with an llm in the loop", "experiment budget bias", "ab test sample size", "llm gated trading signals"]
series: "LLM operations"
toc: true
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

While checking on a model trial, we found one failed AI review in the logs. The message said the account was out of credits. The model had answered. Our own billing had refused to charge for it.

The account belonged to an A/B test we started in early July. Four months later, the test could not answer the question we set it. It did show us six flaws in how we run tests, and what a sound rerun needs.

The tests traded paper accounts, so no money was at risk.

## What we wanted to find out

We ran two A/B tests side by side. Each had two arms, and each arm was its own paper account trading its own signals. Every signal went through the AI review our product applies before a trade: a model reads the market context and approves or blocks the trade.

- **Does a regime filter help?** Both arms used the same two entry signals. One arm also dropped trades that went against the market regime, as a Markov model labels it: bear, sideways or bull.
- **Which entry signal is better?** One arm traded a composite score built from several of our signals. The other traded a simpler RSI and MACD crossover, computed on closed bars only.

The written hypotheses were about Bitcoin on one-hour bars, and the main metric was profit.

## What the readout said

After four months, the comparison page showed this:

- **Regime filter.** The unfiltered arm lost 8.7% over 34 trades, with 44% winners. The filtered arm lost 0.9% over 23 trades, with 52% winners.
- **Entry signal.** The composite arm made 0.04% over 14 trades, with 57% winners. The crossover arm made 2.4% over 28 trades, with 46% winners.
- **Verdict.** The control led in both tests, each with a p-value of 1.0.

Read quickly, the filter cut losses and the crossover made more money. Neither holds up, and finding out why was the most useful part of the test.

## The budget ran out at a different time for each arm

Each test account had a monthly allowance of AI reviews. When it ran out, signals were refused until the next top-up.

The busiest arm used up each month's allowance in one day to a week. In July it had 100 signals reviewed and about 5,100 refused. Over the last 30 days, about 5% of its signals were reviewed. The quieter arms lasted longer, and the quietest has not run out since August.

So the arms did not trade on the same days: the first days of each month for one arm, most of the month for another. An A/B test assumes both arms see the same conditions.

We did not notice for four months. A signal refused for budget is recorded as not executed, the same outcome as a signal the review blocked.

## The hypothesis said Bitcoin. The arms traded sixty symbols or more

When we created the tests, the experiment tool had no setting to limit an arm to one asset. That setting arrived four days later, and nobody went back to the running tests.

So each arm traded between 60 and 74 symbols: currency pairs, indices, commodities, stocks and crypto. The busiest arm's most frequent signals were on currency pairs, and Bitcoin was about 2% of its signals. The test measured a mixed basket of markets, not the question we wrote down.

## Why the numbers could not decide

**Too few trades.** Each arm made between 14 and 34 trades in four months. With so few, a handful of lucky or unlucky trades decides the totals, and no test will call a winner. Running longer would not help while the budget cut the arms off.

**Every trade was one unit.** Whatever the price, each trade bought or sold exactly one: from a $0.07 coin to one Bitcoin at about $87,000. So the totals mostly measure the few Bitcoin trades. The comparison page ranks arms by average return per trade instead, on purpose: the mean of each trade's own percentage return, which does not depend on price. By that measure both challengers did worse. The filtered arm averaged -1.24% per trade against -0.15% without the filter, and the crossover -1.46% against +0.69% for the composite. On so few trades, that is not a result either.

**The metric we chose was the wrong one.** We had chosen total profit as the main metric. The readout overrode that choice, correctly, but showed the dollar totals next to its verdict without saying they are not comparable. Read quickly, as above, they tell the opposite story.

The p-value of 1.0 was not a measurement. The readout reports one only for a challenger that beats the control on return per trade, and shows 1.0 when none does, as here.

## A budget failure that looked like a model error

The error that started this was a race. Several signals arrived within seconds, each passed the budget check, and the first ones used the last credits. The model still answered a later one, and charging for it failed. It was recorded as an AI error, so a model that worked counts toward our model failure numbers.

It is rare, but it is the lesson of [Our fallback hid an outage for weeks](/insights/fallback-hid-an-outage/) again: a failure filed under the wrong cause does not get looked at.

## What the test did give us

For about $10 in AI calls, the four months gave us:

- **Six flaws in our setup, found on paper accounts.** Each would have spoiled the next test the same way, and each now has a fix in the plan below.
- **The signal volume of each arm, measured.** The next test's budget is sized from it.
- **A question still open.** By return per trade the filter did worse, but on 23 trades, on many markets besides Bitcoin, and on days that did not match the other arm's. That settles nothing either way, so the filter gets one proper test.
- **The price of doing it properly.** Funding every arm for its full signal volume would cost about $20 a month.

The costly outcome would have been to act on the totals, because they looked like evidence.

## What we will try next

We will stop both tests and keep their data as a record, not as a result.

The regime filter is the question we still want answered, so we will run it again as one test, set up the way our [model trial](/insights/a-model-test-is-a-snapshot-hosts-keep-changing/) is:

- **Scope in the configuration, then checked.** The arms are limited to the asset in the hypothesis, and a check confirms every signal they trade is in scope.
- **One position size for every trade.** Each trade is a fixed share of the account, so a $0.07 coin and a Bitcoin weigh the same in the totals.
- **A budget sized to the volume.** Each arm's allowance comes from its measured signal volume. Alternatively, test accounts are not charged at all, and a spending cap with an alert replaces the allowance.
- **Equal exposure, checked daily.** Every arm gets the same share of its signals reviewed each day. If one falls behind, an alert fires and that day does not count.
- **Rules fixed before the start.** One main metric, used by the readout too, a fixed end date, and an estimate of how many trades the test needs before its result can mean anything.
- **Budget failures recorded as budget failures.** A review that could not be charged is stored as out of budget, not as a model error.

A test that misses its question is still worth running, if you work out why it missed. This one told us how to run the next.

## Checklist

- Can each arm of your test run out of something on its own (budget, rate limit, quota), and would you notice?
- Does every arm see the same share of its inputs, every day?
- Is the scope in your hypothesis enforced in the configuration, and checked against what the arms actually traded?
- Did you estimate how many events you need before starting, and is there a fixed end date?
- Is every trade sized as a share of the account, so the totals compare like with like?
- Is the metric that decides written down, and is it the one your readout ranks by?
- Are refusals for budget recorded apart from model failures?

If you are running experiments on a pipeline with an AI step in it and want the setup reviewed before you trust the result, [get in touch](/contact/).
