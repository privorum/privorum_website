# Current Site Page Inventory

## Purpose

This document records what the website currently says, page by page, based on the content files and current Hugo configuration in the repository.

It is a current-state reference for future copy and structure rewrites.

## Site-Wide Configuration

Source: `config.toml`

### Site title

- `Privorum Blockchain Software Development Company`

### Logo alt text

- `Privorum Blockchain Software Development Company`

### Homepage meta description

- `Privorum was founded in the year 2020 in Amsterdam and is a dedicated lab of R&D experts for Blockchain technologies.`

### Open Graph title

- `Privorum Blockchain Software Development Company`

### Open Graph description

- `odeneis was founded in the year 2017 in Amsterdam and is a dedicated lab of R&D experts for Blockchain technologies.`

### Main navigation

- Services
- Team
- Clients
- Protocols

### Footer navigation

- Home
- Contact

## Pages

### Home

Source: `content/_index.md`
Rendered with: `themes/hugo-serif-theme/layouts/index.html`, `data/clients.json`, `data/features.json`, and `data/service_areas.json`

- Headline: `Build AI sidebots and serious backend systems.`
- Supporting statement: `Privorum helps companies design and ship workflow automation, AI-driven products, backend platforms, and distributed systems with the discipline needed for production.`
- Positioning line: `We bring senior technical leadership across AI services, backend engineering, platform reliability, and blockchain-native systems when the product requires deeper infrastructure experience.`
- Hero eyebrow: `AI Systems, Backend Platforms, Distributed Software`
- Hero primary CTA: `Book a Consultation`
- Hero secondary CTA: `View Clients`
- Hero system cards:
  - `Orchestration` / `AI sidebots` / `Connected to workflows, APIs, and production systems.`
  - `Delivery` / `Backend platforms` / `Reliable services, integrations, data pipelines, and observability.`
  - `Depth` / `Blockchain support` / `Distributed systems expertise where protocol complexity actually matters.`
- Proof section kicker: `Selected Clients`
- Proof section headline: `Trusted across AI, analytics, trading, infrastructure, and distributed software.`
- Proof grid currently shows the first 8 client names from `data/clients.json`:
  - Genie AI
  - DefyTrends
  - Datafloq
  - Sphinx
  - ChainSafe Systems
  - Dusk BV
  - HolidayCheck
  - BookerZzz
- Capabilities section headline: `What Privorum builds when the work needs technical depth.`
- Capabilities section intro: `We support products that need practical architecture, integration discipline, and production-ready engineering rather than surface-level experimentation.`
- Capability cards rendered from `data/service_areas.json`:
  - `AI Sidebots` / `Design sidebots that connect models to workflows, products, internal tools, and customer operations.`
  - `Workflow Automation` / `Reduce manual work by orchestrating tasks, systems, approvals, and operational handoffs.`
  - `Backend Platforms` / `Build APIs, orchestration layers, services, and data pipelines that hold up in production.`
  - `Integrations & Infrastructure` / `Connect cloud systems, third-party services, CI/CD, observability, and backend environments cleanly.`
  - `Analytics & Data Systems` / `Create reliable data flows, dashboards, platform analytics, and operational reporting systems.`
  - `Blockchain & Distributed Systems` / `Support blockchain-native and distributed architectures when protocol complexity actually matters.`
- Capabilities section CTA: `View All Services`
- Value-strip cards rendered from `data/features.json`:
  - `AI Sidebots` / `Design and deliver sidebots that plug into real workflows, tools, and business operations.`
  - `Backend Platforms` / `Build reliable APIs, services, orchestration layers, and data pipelines that hold up in production.`
  - `Distributed Systems` / `Apply deep experience in blockchain and high-complexity platforms when the system architecture demands it.`
- Trust section kicker: `Why Privorum`
- Trust section headline: `Senior technical leadership for systems that need to survive real use.`
- Trust section intro: `Privorum works best when the product is important, the architecture matters, and the delivery needs to move beyond surface-level implementation.`
- Trust cards:
  - `Hands-on engineering` / `Architecture, APIs, orchestration, cloud systems, and delivery execution with practical technical ownership.`
  - `AI plus infrastructure depth` / `Not just prompts and wrappers. Privorum connects AI workflows to real systems, services, and operations.`
  - `Production mindset` / `Reliability, observability, CI/CD, scaling, and maintainability are treated as part of the product, not afterthoughts.`
  - `Blockchain when it matters` / `Privorum brings protocol and distributed-systems experience when the architecture genuinely requires it.`

### About

Source: `content/about.md`

- Opening statement: Privorum is described as a technical consultancy focused on AI systems, backend platforms, workflow automation, and distributed software.
- Company role: the page says Privorum helps shape architecture, build reliable services, connect systems, and make technical decisions that hold up in production.
- Section `What we do` lists:
  - AI sidebots and workflow automation
  - backend APIs and platform engineering
  - data pipelines and analytics systems
  - cloud infrastructure, CI/CD, and observability
  - blockchain and distributed systems when they are strategically relevant
- Section `Technical depth` lists experience across:
  - Golang
  - Java
  - Node.js
  - React
  - React Native
  - Kubernetes
  - Docker
  - Terraform
  - PostgreSQL
  - ArangoDB
  - Redis
  - Solidity
  - AWS and related cloud environments
- Section `Where blockchain fits` says blockchain is an important part of Privorum's background, especially in protocol work, marketplaces, trading systems, wallets, analytics platforms, and smart-contract-enabled products.
- Section `How we work` says Privorum works hands-on with founders, operators, and technical teams, and aims to help teams ship systems that are reliable, maintainable, and commercially useful.

### Clients

Source: `content/clients/_index.md`
Rendered from: `themes/hugo-serif-theme/layouts/clients/list.html` and `data/clients.json`

- Heading: `Clients`
- Opening statement: Privorum says it has contributed to products, platforms, and technical initiatives across AI, analytics, marketplaces, trading infrastructure, backend systems, and blockchain-native software.
- Structure statement: the page says older and newer clients are brought together in one unified list.
- The page also renders the following current client archive entries:
  
  | Company | Current description |
  | ------- | ------------------- |
  | Genie AI | AI product platform supported through LLM-powered backend services, cloud infrastructure, release practices, and inference performance work. |
  | DefyTrends | Crypto intelligence and news aggregation platform built around analytics, APIs, and reliable data pipelines for dashboards and alerts. |
  | Datafloq | Datafloq is the one-stop source for big data, blockchain and artificial intelligence. We offer information, insights and opportunities to drive innovation with emerging technologies. |
  | Sphinx | High-throughput trading and market-data platform supported through backend engineering, reliability, observability, and platform scale work. |
  | ChainSafe Systems | Chainsafe is a grassroots team of developers from Toronto, they organize a few community initiatives including the G\u00f6rli testnet, University of Toronto Decentralized Tech Association, Blockchain Ryerson, UofT Blockchain Group and a few local hackathons! |
  | Dusk BV | Dusk Network: the new blockchain standard for control, compliance and collaboration. Dusk Network is technology for securities. An open source and secure blockchain (DLT) infrastructure that businesses use to tokenize financial instruments and automate costly processes. |
  | HolidayCheck | HolidayCheck Group AG, Munich, is a leading European digital company for holidaymakers. Employing around 400 personnel, the company brings four well-known holiday brands together under one roof. |
  | BookerZzz | BookerZzz is dedicated to providing our customers with the perfect stay with more value for money, hassle free. We are local specialists with more than 15 years experience and our knowledge is based on feedback from millions of previous guests. Each year, more than 1 million happy travellers trust our advice. |
  | Spilberg | Spilberg is your sidekick within the IT development market. We specialize in staffing for all components of IT Development. We have built up a very large network of developers and testers over the years. |
  | Progressive | As your company adapts to changing market conditions, we grow stronger ensuring you receive professional guidance and expertise on your changing staffing needs. |
  | Visser & Van Baars | Visser & Van Baars has the largest Business Intelligence, Data & Analytics network in the Netherlands. Thanks to our niche-oriented approach, we are the leader in staffing for the BI, Data & Analytics market. |
  | William Hill Plc | William Hill is one of the most recognisable and reputable names in the gaming and betting industry. With extensive operations in the UK, Ireland, Bulgaria and Israel the company employs in excess of 15,000 people; with 2,300 retail shops and a large UK telephone betting business. William Hill PLC was floated on the London Stock Exchange in 2002. |
  | IBM | International Business Machines (IBM), is a global technology company that provides hardware, software, cloud-based services and cognitive computing. Founded in 1911 following the merger of four companies in New York State by Charles Ranlett Flint, it was originally called Computing-Tabulating-Recording Company. |
  | Coull | We're an independent advertising technology company, born in the UK's creative hub over ten years ago. Bristol is home to Coull HQ and we also have a great commercial team in London. |
  | SouJava | The biggest Java User Group in the world, SouJava was founded in September 1999. The name (also spelled as SOUJava) is an acronym for "Sociedade de Usuarios Java" ("Java Users Society"), and "Sou Java" also means "I'm Java" in Portuguese. |
  | Comentarismo | No description text in the current data file. |
  | Mavin.org | A content rating tool to instantly recognise articles you can trust and to rate content yourself. |
  | WeShare Ventures | No description text in the current data file. |
  | Vosbor Exchange | Commodity trading platform built from concept through MVP, funding, and closed beta delivery with hands-on technical leadership across backend, frontend, DevOps, and cloud infrastructure. |
  | Unveil Art | NFT marketplace MVP built with Golang backend services, Solidity smart contracts, and marketplace integration flows. |
  | Hydration / Basilisk DEX | DEX and infrastructure platform supported through architecture, high availability, monitoring, runbooks, and automated rollouts. |
  | Picasso | Platform and integration work across secure inter-service communication, tooling, performance hardening, and release readiness. |

### Contact

Source: `content/contact.md`
Rendered with: `themes/hugo-serif-theme/layouts/page/contact.html`, `themes/hugo-serif-theme/layouts/partials/call.html`, and `data/contact.yaml`

- Opening statement: Privorum invites companies planning an AI workflow, backend platform, analytics system, or distributed product to start a conversation.
- Supporting statement: the page says Privorum can help shape the architecture and move implementation forward.
- Contact callout email: `info@privorum.com`
- Contact callout button: `Contact`
- Contact-hours table:
  - Monday: `9:00am - 5:00pm`
  - Tuesday: `9:00am - 5:00pm`
  - Wednesday: `9:00am - 5:00pm`
  - Thursday: `9:00am - 5:00pm`
  - Friday: `9:00am - 5:00pm`
  - Saturday: `10:am - 4:00pm`
  - Sunday: `Closed`

### Protocols

Source: `content/protocols/_index.md`
Rendered with: `themes/hugo-serif-theme/layouts/protocols/list.html` and `data/protocols.json`

- Heading: `Protocols`
- Intro sentence: `Privorum development team is experienced in the following Protocols.`
- The page also renders the following protocol cards:
  - `Dusk` / `Dusk Network: the new blockchain standard for control, compliance and collaboration. Dusk Network is technology for securities. An open source and secure blockchain (DLT) infrastructure that businesses use to tokenize financial instruments and automate costly processes.`
  - `Ethereum` / `Ethereum is an open source, public, blockchain-based distributed computing platform and operating system featuring smart contract functionality. It supports a modified version of Nakamoto consensus via transaction-based state transitions.`
  - `Polkadot` / `Polkadot is a platform with low barriers to entry for flexible, autonomous economies acting together within Polkadot’s shared security umbrella. Polkadot is a revolution, not just in blockchain technology but also towards enabling fairer peer-to-peer digital jurisdictions.`
  - `Skycoin` / `The Skycoin Skyminer is meticulously designed and configured to provide a rock-solid telecom backbone for the Skywire infrastructure. The custom-built hardware is focused on delivering maximum security, efficiency and performance to the software-defined network.`
  - `Smilo` / `Smilo is a unique full-featured hybrid Blockchain platform that will be able to facilitate hybrid transactions, hybrid smart contracts and hybrid decentralized applications — with ‘hybrid’ referring to both public and private. Smilo uses their unique Blockchain technology to facilitate an alternative protocol for decentralized applications, including GDPR compliant private transactions, reasonable scaling and accurate cost predictions.`
  - `MDL` / `MDL Talent Hub is the ecosystem designed to facilitate the talent sourcing market. Insightful expertise in both IT technologies and the entertainment industry allows us to bring the most efficient and effective medium for collaboration between artists, bookers, and brands.`
  - `Quorum` / `Based on Ethereum, Quorum is an open source blockchain platform that combines the innovation of the public Ethereum community with enhancements to support enterprise needs.`
  - `ETC` / `Ethereum Classic is a decentralized platform that runs smart contracts: applications that can be run exactly as programmed without any possibility of downtime, censorship, or third party interference.`
  - `ETZ` / `EtherZero - Next Generation of Smart Contract Platform.`

### Services Index

Source: `content/services/_index.md`
Rendered with: `themes/hugo-serif-theme/layouts/services/list.html`, `data/service_areas.json`, and service summaries from `themes/hugo-serif-theme/layouts/services/summary.html`

- Heading: `Services for AI systems, backend platforms, and complex technical products`
- Opening statement: the page says Privorum helps teams design, build, and harden production systems across AI workflows, backend services, distributed platforms, and blockchain-native architectures where they are actually required.
- Supporting statement: the page says Privorum works best on projects needing engineering discipline in integrations, reliability, orchestration, performance, and systems that must hold up beyond an MVP.
- Hero eyebrow: `AI Workflows, Backend Engineering, Blockchain Systems`
- Hero CTA: `Discuss Your System`
- Hero system cards:
  - `Build` / `Production services` / `APIs, orchestration, infrastructure, and data systems designed to last.`
  - `Adapt` / `AI and automation` / `Workflow systems that connect models to the tools and operations around them.`
- Service Areas section headline: `What Privorum works on`
- Service Areas section intro: `From AI-assisted workflows to distributed platforms, our services are designed for teams that need implementation depth, technical clarity, and production-ready systems.`
- Service area cards rendered from `data/service_areas.json`:
  - `AI Sidebots` / `Design sidebots that connect models to workflows, products, internal tools, and customer operations.`
  - `Workflow Automation` / `Reduce manual work by orchestrating tasks, systems, approvals, and operational handoffs.`
  - `Backend Platforms` / `Build APIs, orchestration layers, services, and data pipelines that hold up in production.`
  - `Integrations & Infrastructure` / `Connect cloud systems, third-party services, CI/CD, observability, and backend environments cleanly.`
  - `Analytics & Data Systems` / `Create reliable data flows, dashboards, platform analytics, and operational reporting systems.`
  - `Blockchain & Distributed Systems` / `Support blockchain-native and distributed architectures when protocol complexity actually matters.`
- Specialized Services section headline: `Specialist and legacy service depth.`
- Specialized Services section intro: `These pages capture deeper blockchain-specific service areas and related technical capabilities that remain part of Privorum's experience.`
- Each listed service card also includes a `View service` link.

## Service Pages

### Blockchain Advisory

Source: `content/services/blockchain-advisory.md`

- Offer statement: Privorum provides blockchain advisory for investors, operators, and product teams that need technical clarity before implementation.
- Questions the page says it helps answer:
  - Is the architecture viable?
  - Does the protocol choice make sense?
  - What are the operational and security tradeoffs?
  - What should be built now versus later?
  - Where are the real technical risks?
- Typical engagement areas:
  - protocol and architecture review
  - feasibility assessment
  - smart contract and platform strategy
  - team and delivery evaluation
  - infrastructure and operational planning
- Example listed:
  - WeShare Ventures: blockchain advisory and technical review support

### DApp Development

Source: `content/services/dapp-development.md`

- Offer statement: Privorum designs and builds decentralized applications for teams that need more than a prototype.
- Section `Our dApp Development Services` says Privorum supports projects from product definition through implementation, infrastructure, and ongoing refinement.
- Common delivery areas:
  1. MVP strategy
  2. Smart contract implementation
  3. Backend APIs and services
  4. User-facing application layers
  5. Infrastructure and cloud deployment
  6. Upgrades, migrations, and maintenance
- Platform list:
  - Ethereum
  - Hyperledger
  - Smilo
  - Ethereum Classic
  - Bitcoin
  - Skycoin
  - MDL
  - Waves
  - Quorum
  - Clearmatics
- Closing statement: the page says Privorum works best where dApps need integration with serious backend systems, product workflows, and operational reliability.

### Blockchain Permissioned

Source: `content/services/permissioned.md`

- Offer statement: Privorum helps companies design and implement permissioned blockchain systems where trust, control, privacy, and operational structure matter more than open networks.
- It says these systems fit:
  - regulated environments
  - multi-party data sharing
  - enterprise process coordination
  - private transaction flows
  - systems requiring policy and participant control
- Platforms and architectures listed:
  - Hyperledger
  - Corda
  - Quorum
  - Smilo
  - Ethereum-based permissioned models
- What Privorum says it helps with:
  - architecture and protocol selection
  - consensus and privacy tradeoffs
  - smart contract and backend integration
  - private transaction models
  - infrastructure and node operations
  - system review and implementation planning

### Blockchain Permissionless

Source: `content/services/permissionless.md`

- Offer statement: Privorum supports permissionless blockchain projects that need protocol familiarity, backend engineering depth, and practical implementation experience across public networks.
- Ecosystems and codebases mentioned:
  - Ethereum
  - Polkadot
  - Dusk
  - Skycoin
  - Bitcoin
- Typical areas of work:
  - protocol-oriented backend engineering
  - blockchain client and tooling work
  - explorers, wallets, and supporting platform services
  - analytics and data pipelines
  - smart-contract-enabled product architecture
- Networks and technologies listed:
  - Ethereum
  - Polkadot
  - Dusk
  - Bitcoin
  - Skycoin
  - Waves
  - Quorum-derived systems
  - Solidity and related tooling
- Example references linked:
  - `go-ethereum`
  - `CoinD`
  - `My official Golang Waves HTTP Client`
- Closing statement: the page says permissionless work requires sound engineering, clear infrastructure decisions, and practical understanding of protocol-level production behavior.

### Reduce Operational Costs

Source: `content/services/reduce-costs.md`

- Offer statement: Privorum helps companies reduce operational costs through workflow improvements, backend architecture, deployment practices, and system reliability.
- Examples listed:
  - removing manual process bottlenecks
  - automating repetitive internal tasks
  - improving infrastructure efficiency
  - simplifying service communication
  - reducing operational complexity in distributed environments
- Closing statement: the goal is described as measurable reduction in overhead, fragility, and delivery friction.

### Security Audits

Source: `content/services/security audit.md`

- Offer statement: Privorum reviews distributed systems, smart contracts, and backend architectures to identify security issues, design weaknesses, and operational risk.
- The page says audits are designed to produce actionable findings, not generic reports.
- Audit process:
  1. Contact
  2. Quote
  3. Audit
  4. Report
  5. Fixes
  6. Publish
- Security standard statement: the page says risk is reduced by implementing distributed technologies with disciplined engineering, standard tooling, and clear review practices.

## Team Pages

### Team Index

Source: `content/team/_index.md`
Rendered with: `themes/hugo-serif-theme/layouts/team/list.html` and `themes/hugo-serif-theme/layouts/team/summary.html`

- Heading: `Meet the team`
- Opening statement: the page says Privorum combines senior technical leadership with hands-on engineering across backend systems, AI products, infrastructure, analytics, and blockchain-native platforms.
- Supporting statement: the team is described as built for companies that need practical execution, not just high-level advice.
- Each team summary card also renders:
  - profile image
  - role title
  - `Linked In` link when available
  - full profile content on the listing page

### Thomas Modeneis

Source: `content/team/thomas-modeneis.md`

- Role: `Founder`
- Profile summary: Thomas says he helps companies define, build, and scale technical products requiring strong architecture, operational discipline, and senior engineering judgment.
- Experience claim: more than 20 years of experience across industries, countries, and technical environments.
- Roles listed:
  - founder
  - CTO
  - architect
  - developer
  - technical advisor
- Background areas:
  - backend platforms
  - trading systems
  - blockchain products
  - analytics systems
  - distributed software
  - cloud infrastructure
- Closing line: `You have a vision. I help turn it into a system that can actually run.`

### Ivens Signorini

Source: `content/team/ivens-signorini.md`

- Role: `Senior Backend Engineer`
- Profile summary: Ivens says he has more than 18 years of experience designing, building, and maintaining high-performance systems across fintech, e-commerce, blockchain, and analytics.
- Technical specialization:
  - Golang
  - Java
  - Solidity
  - microservices architecture
  - CI/CD automation
  - cloud deployment
- Supporting statement: the page says his focus has been scalable, reliable, and maintainable systems with a practical, solution-oriented approach.
- Closing line: `You have a vision. I build the systems that make it real.`

### 404 Page

Source: `content/404/_index.md`

- Title only: `Page Not Found`

## Summary of Current Positioning

Across the current live content, the site now presents Privorum as:

- a technical consultancy for AI systems, workflow automation, backend platforms, and distributed software
- a company with continuing blockchain and protocol depth
- a senior engineering partner for production systems

At the same time, several older blockchain-focused service pages and some site-wide metadata still present the older blockchain-first identity.
