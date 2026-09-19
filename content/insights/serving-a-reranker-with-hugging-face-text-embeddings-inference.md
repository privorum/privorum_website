---
title: "Serving a reranker with Hugging Face text-embeddings-inference"
description: "How to run a cross-encoder reranker with Hugging Face TEI, the fallback pattern that keeps search working, and a small measured before-and-after on SciFact."
date: 2026-09-19T13:20:00+02:00
tags: ["llm", "huggingface", "rag", "reranking"]
keywords: ["text embeddings inference reranker", "hugging face tei rerank", "bge reranker docker", "reranking rag retrieval"]
series: "Retrieval"
toc: true
related_service: "machine-learning"
---

A retriever finds candidate documents quickly and roughly. A reranker looks at each query and candidate together and orders them more carefully. It is a common way to improve the quality of the top few results in a search or RAG pipeline. Hugging Face's Text Embeddings Inference (TEI) is one way to serve such a model as a small HTTP service.

This article covers how to run it, the pattern that keeps a pipeline safe when the reranker misbehaves, and a small measurement we made ourselves. It also says what we did **not** measure.

## What TEI is

TEI is a toolkit for serving text embedding and ranking models. Rerankers are cross-encoders: sequence-classification models that score a query and a text together. The documentation lists example rerankers such as `BAAI/bge-reranker-base` and `BAAI/bge-reranker-large`. It publishes a Docker image with CPU builds and GPU builds for several NVIDIA architectures, and older GPUs are not supported, so check the documentation for your hardware.

## Run it

We used the CPU image with `BAAI/bge-reranker-base`:

```bash
docker run -d -p 8089:80 -v "$PWD/data:/data" \
  ghcr.io/huggingface/text-embeddings-inference:cpu-1.9 \
  --model-id BAAI/bge-reranker-base \
  --max-client-batch-size 64
```

Notes from running it:

- **The first start downloads the model.** The weights we fetched were about a gigabyte, and on our connection the container took around three minutes to become healthy. Mount a volume so restarts do not download again, and treat a cold start as a period when the service does not serve requests.
- **Check the client batch limit.** The `--max-client-batch-size` flag limits how many texts one request may carry. We raised it to fit a candidate pool. Check the default for your version.
- **The service reports its settings.** The `/info` endpoint showed us the model type, the maximum input length (512 tokens for this model) and the version.

## Call it

The rerank endpoint takes a query and a list of texts:

```bash
curl -s localhost:8089/rerank -H 'Content-Type: application/json' \
  -d '{"query": "what is a cat", "texts": ["A cat is a small mammal.", "Cars have wheels."], "truncate": true}'
```

The response is a list of objects with the index of each text and a score. Sort by score yourself and map the indexes back to your documents. Setting `truncate` lets texts longer than the model's limit be cut instead of rejected.

## The pattern that keeps you safe

A reranker adds a network hop and a model to a path that worked without it. Design so that its failure costs you quality, not availability:

1. Get candidates from your first-stage retriever.
2. Send the top N to the reranker with a **short client timeout**.
3. On any error, timeout or missing ID, **return the first-stage order** unchanged.
4. Keep it switchable, and off by default, until a measurement shows it helps you.
5. Count requests and record their durations, so you can see how often you fall back.

Enable it only once you have a baseline showing there is room to improve. A reranker cannot fix a retriever that never surfaced the right document, because it only reorders what it is given.

## A small measurement

We measured the quality effect on a public dataset, so the result does not depend on our data.

- **Data:** SciFact from the BEIR benchmark, test split. 5,183 documents. We used a random sample of 100 of its test queries.
- **First stage:** BM25 over the whole corpus, using a simple tokenizer. This is a plain baseline, not a tuned one.
- **Rerank:** the top 20 BM25 results, reranked with `BAAI/bge-reranker-base` through TEI 1.9 on CPU. Documents beyond the top 20 kept their BM25 order.
- **Metrics:** nDCG@10 and Recall@10 against the dataset's relevance judgments.

| | nDCG@10 | Recall@10 |
|---|---|---|
| BM25 | 0.610 | 0.738 |
| BM25 + rerank (top 20) | 0.677 | 0.782 |

On average, only about 80% of each query's relevant documents were inside the top-20 pool at all, so that caps what reranking that pool can reach. A larger pool raises the ceiling and the cost.

Read this with its limits in mind. It is 100 queries from one dataset, one model, one pool size and one baseline, and we did not compute confidence intervals. Differences of a few points on a sample this size can be noise. Treat it as a check that reranking helps on standard data, not as a forecast for your own.

## What we did not measure

**Latency.** We are not publishing latency numbers. The machine we ran on was heavily loaded by other work, and a single request with 20 candidates took on the order of tens of seconds, which is a fact about that machine and not about the model. A useful latency test needs quiet hardware, a stated concurrency, warm-up excluded, cold start reported separately, and percentiles (p50, p95, p99), not averages. That is the measurement to make before you set your timeout.

**Quality on your data.** Public benchmarks are a sanity check. Build a small labelled set of your own queries before you decide.

If you want help evaluating retrieval and reranking for your own product, [get in touch](/contact/).
