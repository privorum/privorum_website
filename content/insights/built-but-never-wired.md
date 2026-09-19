---
title: "Built but never wired: monitoring that had no callers"
description: "Our quality scoring and request logging were finished and read by dashboards, but no production code called them. How an audit found it and what to test."
date: 2026-09-19T12:10:00+02:00
tags: ["llm", "observability", "testing", "engineering"]
keywords: ["dead code monitoring", "monitoring not wired production", "empty metrics table", "llm quality scoring not running"]
series: "LLM operations"
toc: false
source_product: "www.biidin.com"
source_url: "https://www.biidin.com/"
related_service: "ai-workflows"
---

We had a quality scorer and a request logger for our LLM calls. Both were written and marked done. An admin page displayed their data, a recalibration loop consumed it, and a daily scheduler checked it for regressions.

The tables they were supposed to fill were empty. They had been empty since the day the features shipped.

## What was wrong

Nothing called the scorer or the logger from the production path. The functions existed. The consumers read from tables that nobody wrote to. Everything downstream handled "no data" quietly, so nothing failed.

A related case was in our metrics: several recorders for requests, fallbacks, circuit trips, retries, truncation and cache hits were defined but never invoked outside tests.

## How it was found

By an architecture audit, not by a test or an alert. The audit searched for references and found that the constructors of both components had no production callers. The admin page's queries were reading a permanently empty table.

The audit recommended deleting the machinery. We wired it in instead, scoring after each analysis is stored and sampling requests where the model is called.

## Why "done" was wrong

- **Existing code is not running code.** A component can compile, pass review and be marked done while nothing calls it. The sampling logic had never executed in production or in any test until we added its first assertions.
- **Empty is a valid state.** Consumers treated "no rows" as normal, so an admin page with nothing on it looked like a quiet week.
- **Each piece looked complete on its own.** The scorer, the logger, the page and the scheduler each existed and each looked finished. The gap was between them.

## What to do

- **Define done as "runs in production and produces data."** For a monitoring component, that means an end-to-end check that a row appears after a real code path runs.
- **Assert on the sink.** Add a test that exercises the production path with a stub provider and checks that the expected table or metric changed.
- **Search for orphans on a schedule.** A list of exported constructors and recorders with no production references is a cheap, useful report.
- **Alert on silence.** A table that should receive rows daily and receives none is an alert, not a state.

Be honest about the state of your own guard. After the fix we added tests for the sampling behaviour, but we did not add a test that fails when either component loses its caller again. The nearest thing we have is a static-analysis test for another wiring problem, and that pattern is the one to copy: [Cache-aware LLM cost accounting](/insights/cache-aware-llm-cost-accounting/) describes it.

If you want a monitoring setup reviewed for gaps like this, [get in touch](/contact/).
