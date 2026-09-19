---
title: 'biidin — AI Trading Engine & Fleet'
description: 'Verified AI traders with published track records. An in-house product by Privorum built on the Captain AI engine.'
weight: 1
---

# biidin: Verified AI Traders

biidin is a trading platform and AI agent fleet built in-house by Privorum. It brings together AI-driven signal generation, verified track records, and institutional-grade execution infrastructure.

## The Platform

biidin operates a transparent fleet of AI traders (called the Captain Fleet) that:

- **Generate signals** using machine learning models trained on market data, technical analysis, and sentiment
- **Execute autonomously** across multiple exchanges (crypto, options, CFD) using a shared execution kernel
- **Report live results** with timestamped, verified track records
- **Mirror for followers** — other traders can follow a fleet agent and mirror its moves on their own exchange accounts

The platform is built for three audiences: retail traders who want to follow verified AI agents, traders who want to run their own automated strategies, and institutions that need portfolio management infrastructure.

## The Technical Stack

biidin is built on:

- **Backend** — Go monolith (Fiber) serving REST APIs and WebSocket real-time feeds
- **Execution** — 9-phase pipeline for order routing across Kraken, Phemex, Hydra, IG, Alpaca, and other venues
- **AI Engine** — LLM-powered signal generation (Captain AI) with credit-based tiering
- **Infrastructure** — Kubernetes deployment with PostgreSQL, Redis, and multi-tenant architecture
- **Desktop** — Lean standalone binary for BYOK (Bring Your Own Keys) traders who want local execution

## The Incubator Story

biidin started as an in-house experiment at Privorum: "What if we built the trading platform we wanted to see?"

The project combines:

- **Privorum's backend expertise** — reliable, auditable systems built for production from day one
- **AI integration** — intelligent signal generation using multiple LLM providers and fallback chains
- **Deep exchange knowledge** — connectors for crypto, derivatives, CFDs, and traditional brokers
- **Verified track records** — on-chain proof that results are real, not backtested

What began as a research project evolved into a fully-operated product with thousands of users, a thriving community, and a published fleet of AI traders managing real capital.

## Key Features

**AI Signal Generation**
- Multi-timeframe technical analysis (RSI, MACD, SMA, volume confluences)
- LLM-powered sentiment and macro analysis
- Credit-based access to premium LLM models
- Community-contributed strategies and signal feeds

**Verified Execution**
- Live track records for every AI trader in the fleet
- Real-time position mirroring for followers
- Automated risk management (trailing stops, position protection)
- Paper trading and live trading modes

**Institutional Features**
- Multi-broker support with unified position tracking
- Performance reporting and analytics
- Role-based access (agents, followers, operators)
- Scalable infrastructure for high-frequency updates

## The Result

Today, biidin is:

- **Operationally independent** — runs as its own product with its own user base and revenue
- **Technically robust** — handles 24/7 execution, real-time WebSocket updates, and multi-venue order routing
- **Profitable** — uses a freemium + premium tier model for retail, plus enterprise licensing
- **Community-driven** — trading signals come from both Privorum-built AI models and community contributors

## Learn More

Visit **[biidin.com](https://biidin.com)** to:

- Browse the AI trader fleet
- Read signal documentation and performance reports
- Follow a trader or run your own strategies
- Read the technical blog and trading journal

---

biidin showcases Privorum's approach: build products with the same discipline we bring to consulting engagements, keep deep technical ownership, and ship systems that are reliable and commercially useful.
