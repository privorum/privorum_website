# Privorum Copy & Structure Review

Date: 2026-04-15
Scope: `content/`, `config.toml`, primary navigation, homepage, services, about, contact, team, clients, protocols.
Lens: the positioning already agreed in `docs/positioning-and-content-plan.md` — *AI, workflow automation, and backend engineering consultancy with blockchain depth where useful.*

This document is a findings + recommendations list. It does **not** change any code.

---

## 1. Top-line verdict

The new positioning (AI / automation / backend, with blockchain as depth) is clearly articulated in `docs/positioning-and-content-plan.md` and is mostly reflected in `about.md`, `services/_index.md`, `contact.md`, and the team bios. Three things then undermine it across the rest of the site:

1. **The homepage contradicts the positioning in its own H1.** `content/_index.md:8` reads *"Build AI sidebots and serious backend systems."* The positioning plan explicitly lists `AI sidebots` under **Avoid**. This is the first thing every visitor sees.
2. **Site metadata, title, and OG description still describe a blockchain-only company** (`config.toml`). Search engines, social previews, and the browser tab will continue to say "Privorum Blockchain Software Development Company" regardless of what any page says.
3. **Structural gaps betray the new story.** The homepage has no capability pillars, no proof block, and no CTA (plan §Homepage calls for all three). `/clients/` and `/protocols/` are empty scaffolds. Half the service catalog is still blockchain-first. The main nav leads with "Protocols."

Everything below is scoped to those three problems.

---

## 2. Critical copy issues (fix first)

### 2.1 Homepage H1 uses the banned term
- **File:** `content/_index.md:8`
- **Current:** `# Build AI sidebots and serious backend systems.`
- **Problem:** `AI sidebots` is explicitly prohibited by the positioning plan (`positioning-and-content-plan.md:57`, `:183`). It also reads as improvised jargon — a CTO skimming the page will not know what it means and will not ask.
- **Recommend:** a direct, buyer-legible promise. Options:
  - *"Ship AI workflows and backend systems that hold up in production."*
  - *"Senior engineering for AI workflows, automation, and backend platforms."*
  - *"We design and ship the AI and backend systems serious products depend on."*
- **Supporting paragraph** (`_index.md:10`) is fine but can tighten — *"with the discipline needed for production"* is vaguer than the bios' *"senior engineering judgment."* Reuse that phrase; it already performs well in Thomas's and Ivens's bios.

### 2.2 Site-wide metadata still says "blockchain company"
- **File:** `config.toml`
  - `title` (line 3): `"Privorum Blockchain Software Development Company"` → becomes `<title>` fallback and shows in every tab, search result, and bookmark.
  - `params.logo.alt` (line 15): same string → every page's logo alt text.
  - `meta_description` (line 18): `"Privorum was founded in the year 2020 in Amsterdam and is a dedicated lab of R&D experts for Blockchain technologies."` — contradicts the positioning and contradicts itself: the OG description below says *"odeneis was founded in the year 2017"* (typo + different year).
  - `meta_og_title` (line 19): same blockchain-first title.
  - `meta_og_image` (line 22): points at `raw.githubusercontent.com/JugglerX/hugo-serif-theme/...` — the theme's default placeholder, not a Privorum asset. This is what LinkedIn/Twitter/Slack will render when anyone shares the site.
- **Recommend:**
  - New `title`: *"Privorum — AI, Automation & Backend Engineering"* (or similar; keep ≤ 60 chars for SERPs).
  - Rewrite `meta_description` around the agreed positioning, single founding year, no Amsterdam-blockchain-lab framing (unless Amsterdam matters — decide once).
  - Host a real OG image under `static/images/` and point `meta_og_image` at it.
  - Fix the "odeneis"/"2020 vs 2017" contradiction — pick one founding year and use it everywhere, including Thomas's bio context if relevant.

### 2.3 Primary navigation leads with blockchain framing
- **File:** `config.toml:28-48`
- **Current order:** Services · Team · Clients · Protocols.
- **Problems:**
  1. *Protocols* is a blockchain-era artifact. Under the new positioning it is specialist depth, not a top-level destination. It also currently points at an empty page (§3.2).
  2. There is no *About* in the main menu even though `about.md` carries the clearest articulation of what the company now does. Visitors have no path to it except the footer.
  3. No *Contact* in the main menu — it's footer-only. For a consultancy whose goal is to start conversations, burying Contact is self-defeating.
- **Recommend:**
  - New main menu: **Services · About · Team · Clients · Contact**.
  - Demote *Protocols* to either (a) a section inside About, (b) a footer link, or (c) delete until there is real content to show.

### 2.4 Service catalog still blockchain-first
- **Files:** `content/services/*.md`
- **Current catalog:** Blockchain Advisory, DApp Development, Blockchain Permissioned, Blockchain Permissionless, Reduce operational costs, Security Audits. Five of six are blockchain-scoped.
- **Problem:** `services/_index.md` promises AI workflows, backend platforms, and distributed systems, but the listing below it is almost entirely blockchain. A CTO looking for an AI/automation partner will bounce.
- **Recommend (prioritized):**
  1. **Add three AI/backend service pages** to carry the new story. Titles lifted from the positioning plan:
     - `ai-workflows.md` — AI workflow design and implementation
     - `workflow-automation.md` — automation & orchestration
     - `backend-platforms.md` — backend platform engineering (APIs, integrations, reliability)
  2. **Consolidate the four blockchain pages into one or two.** `permissioned.md` and `permissionless.md` say largely the same thing with different platform lists; merge into a single `blockchain-systems.md`. Keep `blockchain-advisory.md` as the standalone advisory offer. Retire or fold `dapp-development.md` — it is the most dated page (see §2.5).
  3. **Set `weight:` front matter** on every service so the order matches the positioning (AI/automation/backend first, blockchain last). Right now `dapp-development.md` has `weight: 1` and `security audit.md` has `weight: 2` — everything else is unweighted, so ordering is non-deterministic.
  4. Rewrite `reduce-costs.md` with a concrete outcome or case. It currently asserts the goal twice and provides no proof — it is the weakest page.

### 2.5 Dated or risky protocol name-drops
- **File:** `content/services/dapp-development.md:28-38`
- **Names listed:** Ethereum, Hyperledger, Smilo, Ethereum Classic, Bitcoin, Skycoin, MDL, Waves, Quorum, Clearmatics.
- **Problem:** Smilo, MDL, Skycoin, Clearmatics, and Waves are either defunct, severely diminished, or associated with scandals. A technical buyer recognizing even one of these reads the whole page as stale (the file dates from 2018). `permissionless.md` has the same issue with `Dusk`, `Skycoin`, `Waves`, `Quorum-derived`.
- **Recommend:** keep the currently-relevant names (Ethereum, Bitcoin, Polkadot, Hyperledger, Corda, Solidity). Drop or relegate the rest. If there is a real reason to keep one (a case study, a live contract), say so inline.

### 2.6 Empty pages presented as real
- `content/clients/_index.md` — advertises *"older and newer clients together in one unified list"* but the list is not on the page; it has to come from a theme layout or front-matter data that currently renders nothing visible. If there is no client list yet, either:
  - remove the promise ("this page brings older and newer clients together…") until there is one, or
  - hard-code a short honest list (even just logos + protocol names) from the work already referenced elsewhere (WeShare Ventures, go-ethereum contributions, etc.).
- `content/protocols/_index.md` — a one-line teaser and a trailing space. Either populate it or remove it from the nav per §2.3.

### 2.7 Small copy hygiene (low effort, high polish)
- `content/contact.md:19` — `"10:am - 4:00pm"` (typo). Either `10:00am - 4:00pm` or drop Saturday if the office isn't actually open weekends.
- `content/contact.md` lists hours but no actual email/phone/form reference in the markdown. The `layout: contact` front matter suggests the theme template provides the form — confirm that it still renders, because the markdown reads as if details are missing.
- `content/services/security audit.md` — filename contains a space. This becomes `/services/security%20audit/` in production (ugly, bad for SEO). Rename to `security-audit.md`.
- `content/services/security audit.md:13-28` — the numbered steps lack headings/visual hierarchy; `1. CONTACT` etc. renders as an ordered list with ALL-CAPS words mid-line. Convert to `### 1. Contact` subsections for readability.
- `content/about.md:22` — the tech list reads as a keyword dump (`Golang, Java, Node.js, React, React Native, Kubernetes, Docker, Terraform, PostgreSQL, ArangoDB, Redis, Solidity`). Group it: *Languages — …; Infrastructure — …; Data — …*. Same information, reads as senior instead of resume-spam.
- Team bios end with near-identical closers: *"You have a vision. I help turn it into a system that can actually run."* / *"You have a vision. I build the systems that make it real."* Keep one person's; rephrase the other so the team page doesn't feel templated.

---

## 3. Structural recommendations

### 3.1 Rebuild the homepage around the plan's recommended sections
The plan (`positioning-and-content-plan.md:76-84`) specifies: headline → supporting paragraph → primary + secondary CTA → capability pillars → proof → selected services → final CTA. The current homepage stops after the supporting paragraph. To get to plan-parity, the homepage needs:

1. **Headline + supporting paragraph** — revise per §2.1.
2. **CTAs** — primary: *Talk to us* → `/contact/`. Secondary: *See our services* → `/services/`.
3. **Capability pillars (×4)** — AI Workflows · Workflow Automation · Backend Platforms · Distributed Systems. Each pillar: one-line promise + link to the matching service page. (This is the main reason §2.4 matters — the pillars need destinations.)
4. **Proof block** — senior-leadership line ("20+ years backend & distributed systems, ex-CTO/architect"), a representative client or contribution (`go-ethereum`, WeShare Ventures), and the stack the work actually runs on. No hype, no logos you can't show.
5. **Selected services** — 3 cards linking into `/services/`.
6. **Final CTA** — *"Planning an AI workflow, backend platform, or distributed system? Start a conversation."* → `/contact/`.

All of this is content + partials; most of the theme scaffolding (`intro_image`, section partials in `themes/hugo-serif-theme/layouts/partials/`) is already there.

### 3.2 Decide Protocols' fate explicitly
It is either (a) a differentiator you still sell on — in which case fill it with real protocol work and a narrative, or (b) legacy — in which case remove it from the menu and either delete the page or make it a 301 to `/services/`. Leaving an empty Protocols page in primary nav damages credibility more than removing it would.

### 3.3 Add a 404 page
There is no `content/404.md`. Hugo will fall back to the theme's default if one exists; otherwise broken links hit a generic server page. Create a short 404 with a link home and a link to `/services/`.

### 3.4 Clients page needs real content or an honest narrative
Two acceptable paths:
- **Path A (preferred):** a short list of named clients/projects with a one-sentence description of what Privorum did. Use what's already in the repo — WeShare Ventures (advisory), go-ethereum contributions, the CoinD / waves-go-client repos Thomas has published.
- **Path B:** reframe the page as *"Selected work"* with two or three anonymized engagements (*"Trading platform — designed settlement architecture, migrated backend to Go, reduced infra spend by X%"*). Still concrete, no name-dropping required.

Avoid a third path: a page that says "we have clients" without evidence.

---

## 4. Suggested order of execution

1. **Metadata & nav pass** (`config.toml`): fix title, descriptions, OG image, menu order, add About/Contact to main menu. ~30 min. Affects every page immediately.
2. **Homepage rewrite** (`content/_index.md` + any homepage partial the theme exposes): H1, sub, CTAs, pillars. ~2 hours including choosing the pillar copy.
3. **Service catalog restructure**: add 3 new AI/backend service pages, consolidate blockchain pages, set `weight:` on all, rename `security audit.md`. ~3-4 hours (mostly writing).
4. **Clients page**: fill with real content per §3.4. Time depends on what's approvable to show publicly.
5. **Protocols decision** (§3.2): 15 min to decide, 15 min to execute either way.
6. **Copy hygiene pass** (§2.7): 30 min.

Total ballpark to get the site coherent with the agreed positioning: **roughly a day of focused writing** + whatever client/legal approvals the clients page needs.

---

## 5. What's already working — leave alone

- `content/about.md` — the clearest articulation of the new positioning on the site. Ship more prose that sounds like this.
- `content/services/_index.md` intro — correct framing, good tone.
- Team bios — both read as credible and senior. Only minor edit is the duplicated closing line (§2.7).
- `content/services/blockchain-advisory.md` — tight, question-led, honest. Good template for the upcoming AI/backend pages.
- The tone across the site is consistent with the plan's *"calm, direct, senior, not flashy"* guideline. That discipline is rare and worth preserving through the rewrite.
