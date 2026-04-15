# UI Refactor — Design Review

A design-lens counter-read of `docs/ui-refactor-plan.md`. The existing plan is **correct on engineering** (a11y, perf, theme hygiene) and **timid on design**. This doc keeps the former and rewrites the latter.

Frame: Privorum is a small, senior B2B consultancy selling AI systems, backend platforms, and distributed-systems depth. The buyer is a technical executive who has seen a thousand navy-and-sky-blue "Trust & Authority" sites this quarter and dismisses them in four seconds.

---

## 1. What the plan gets right

Keep these verbatim — they are non-negotiable foundations, not design choices:

- §2.1 / §4.1 — `:focus-visible`, `prefers-reduced-motion`, 44px touch targets
- §2.3 — decouple hero "dark island on a light body" coupling
- §3.4 — `.Site.Data → hugo.Data` deprecation
- §3.5 — self-host fonts (also a GDPR win for EU buyers)
- §3.1 / §3.2 — detach the fork, split `_home.scss` by section, delete dead components
- §4.5 — real Hugo image pipeline with `loading="lazy"`, `<picture>`, explicit dimensions
- §7 — pre-delivery checklist

No argument. Ship these.

---

## 2. Where the plan goes wrong

### 2.1 "Trust & Authority" is not an aesthetic direction

It's a positioning label. The plan's concrete recommendation — Poppins + Open Sans, navy `#0F172A`, sky-700 `#0369A1`, slate neutrals, restrained 1px borders — describes roughly 60% of B2B SaaS sites on the internet. Differentiation Anchor test:

> "If screenshotted with the logo removed, how would someone recognize it?"

Under the plan as written: they wouldn't. It would pass for Vercel, Linear's enterprise page, any fintech, any consultancy. **That is a failure state, not a safe default.**

### 2.2 The plan tells us to delete the only interesting thing on the page

The `systems-art` composition (`layouts/index.html:45-76`) — layered cards, rails, nodes, glass panels — is the one piece of current UI with a point of view. The plan frames the "blue radial glow" as SaaS-hype and advises replacing it with "a thin 1px sky-700 border, subtle shadow." That replaces opinion with furniture. The glow is the wrong *execution*; the composition is the right *instinct*.

### 2.3 The typography recommendation undersells the brand

Poppins is a geometric humanist sans used by every Shopify store since 2018. Open Sans is the default-default. Recommending them to a firm whose differentiator is "distributed-systems expertise where protocol complexity actually matters" is vibes-mismatch. The senior backend buyer reads these fonts as marketing-department-picked, not engineer-picked.

### 2.4 "Pick Fraunces OR Poppins — either is fine" is the wrong framing

Two personalities in a brand isn't the problem. **Unmotivated** mixing is. The fix isn't to pick one; it's to make the contrast load-bearing.

---

## 3. Proposed aesthetic direction

### Name: **Technical Editorial**

One sentence: the visual language of a well-designed systems paper or a Bloomberg terminal redrawn by someone who cares — **information-dense, monospaced accents, quiet color, load-bearing typography**, with a single confident structural gesture per page.

Influences (conceptual, not to copy): *Stripe Press*, *Vercel's changelog typography*, engineering-blog–era *Basecamp*, *Werner's Nomenclature of Colours* as a palette stance (named, limited, committed).

Two personalities, both justified:

- **Editorial serif** (display, H1–H2, pull quotes) — signals authored, considered, senior.
- **Monospace** (eyebrows, labels, metric captions, inline code) — signals engineering, not marketing.

Body remains a neutral humanist sans. Three roles, each doing a job no other font can do.

### DFII

| Dimension | Score | Note |
|---|---|---|
| Aesthetic Impact | 4 | Mono-as-label is recognizable at a glance |
| Context Fit | 5 | Matches "senior engineers, not SaaS" positioning |
| Implementation Feasibility | 4 | Hugo + SCSS handles it; no new runtime deps |
| Performance Safety | 4 | Three self-hosted woff2 files, subsettable |
| Consistency Risk | 2 | Mono is easy to overuse — requires discipline |

**DFII = 4+5+4+4 − 2 = 15.** Execute fully.

### Differentiation anchor (pick one, make it unmistakable)

**The Execution Ledger.** Replace the current `systems-art` cluster with a single full-height right-column composition: a monospace, left-aligned "ledger" of real engagements — protocol name, year, scope verb, one-line outcome — rendered as if typeset, not designed. Subtle rule lines, no cards, no glow, no shadows. The hero's entire right half is one long list the eye can actually read.

This is the screenshot-without-logo test. Nothing else on the B2B-consultancy internet looks like that.

---

## 4. Design system snapshot

### Type stack (self-hosted)

| Role | Face | Why |
|---|---|---|
| Display / H1–H2 | **Fraunces** (keep it, use its optical sizes) | Already installed; its wide optical range lets one family carry display + pull quotes without a second serif |
| Body | **Inter Tight** *or* **IBM Plex Sans** (keep Plex) | Plex has the engineered feel Inter lacks; pairs with Plex Mono for free |
| Label / eyebrow / metric / caption | **IBM Plex Mono** | Load-bearing: mono is the visual signature. Eyebrows, section numbers, card labels, inline metrics, ledger entries |

Reject: Poppins, Open Sans, Roboto, Inter (as body), any "AI-default" stack.

### Color — committed, not balanced

Not a palette. A **hierarchy**:

```scss
--ink:        #0B0D0E;   // near-black, not #000
--paper:      #F4F1EA;   // warm off-white — this is the anchor, not white
--paper-deep: #EBE6DB;   // section alternates
--rule:       #1F1C18;   // hairline borders, 1px
--accent:     #C2410C;   // burnt orange — one accent, used sparingly
--mute:       #6B6459;   // secondary text only
```

Rationale for `#F4F1EA` over `#F8FAFC`: slate-50 is the generic B2B default. Warm paper reads as *publication*, not *dashboard* — and it lets the monospace labels sit without the clinical feel. The burnt-orange accent replaces the sky-blue CTA: it is the only non-neutral color on the page and therefore every CTA, link hover, and focus ring points to the same thing.

**Dark surfaces are earned, not default.** Reserve full-ink sections for the Execution Ledger and one closing CTA band. Everything else lives on paper.

### Spatial composition

- Asymmetric 12-col grid; hero is 7/5 left-weighted, every subsequent section alternates 5/7 or 8/4 — never 6/6.
- Vertical rhythm on an 8px base, section padding tokens `--space-section: 96px / 128px / 160px` (adopt §4.4's instinct, larger numbers).
- **Hairlines do the work that cards currently do.** 1px `--rule` dividers between sections replace `border-radius: 18px` glass panels. This is the single biggest visual shift.

### Motion

Three total on the home page:

1. Hero: a single staggered letter-spacing tighten on H1 load (300ms, once).
2. Ledger entries: stagger-fade on scroll into view (respects `prefers-reduced-motion`).
3. CTA hover: underline draws left-to-right in `--accent`, 120ms. No card lift, no glow pulse, no shadow swell.

Delete every other transform currently in `_home.scss`.

---

## 5. Section-by-section rewrite

| Section | Current | Proposed |
|---|---|---|
| Hero | Serif H1 + dark glassy cards + blue radial glow + 3 metric cards | Serif H1 left / **Execution Ledger** monospace right. One orange CTA, one text link. Metrics become 3 inline mono lines under H1, not cards. |
| Capabilities ("overview-cards") | Rounded glass cards with no iconography | Three numbered entries — `01 / AI Systems`, `02 / Backend Platforms`, `03 / Distributed Systems` — hairline-separated, no boxes. Number set in Fraunces, label in Plex Mono, body in Plex Sans. |
| Proof ("proof-item" text tiles) | Text-only tiles | Real monochrome client SVGs on `--paper` (plan §4.2 — correct). Keep them desaturated; never more than 6 logos at a time. |
| Platform / Trust cards | Glassmorphism | Two-column hairline-divided table. Left = what we do, right = how we prove it (shipped protocols, years in production, team credentials). |
| Closing CTA | Button in blue | Full-width `--ink` band. Serif H2, single `--accent` underlined CTA. No card, no gradient. |

---

## 6. Revised execution order

Merges the plan's roadmap with the design shift. Total scope unchanged; sequencing differs.

1. **Week 1 — correctness** (unchanged from plan §6.1): `:focus-visible`, touch targets, reduced-motion, `.Site.Data` migration, self-host fonts — but self-host **Fraunces + Plex Sans + Plex Mono**, not Poppins/Open Sans.
2. **Week 1 — palette + type tokens commit.** Lock `_variables.scss` to the values in §4 of this doc. This is the irreversible moment; everything downstream depends on it.
3. **Week 2 — hero rebuild.** Replace `systems-art` with the Execution Ledger. This is the single highest-leverage change on the site and should be the first visible one.
4. **Week 2 — strip glassmorphism site-wide.** Convert every `.overview-card`, `.trust-card`, `.platform-card`, `.proof-item` from card-with-radius to hairline-row. Delete the `backdrop-filter: blur()` rules entirely.
5. **Week 2–3 — structure** (from plan §3): detach theme, slim Bootstrap, split `_home.scss`.
6. **Week 3 — client logos + iconography** (plan §4.2). Monochrome only.
7. **Week 3–4 — perf + polish** (plan §4.5, §4.6).

---

## 7. Pre-delivery checklist (supersedes plan §7)

Adds four design-discipline gates to the plan's engineering gates.

Engineering (keep):
- [ ] `make build` clean, no new Hugo warnings
- [ ] Tested at 375 / 768 / 1024 / 1440 px
- [ ] Focus ring visible on every interactive element (ring uses `--accent`)
- [ ] `prefers-reduced-motion` respected on every `transform:`
- [ ] No `backdrop-filter: blur()` reintroduced
- [ ] `docs/log.md` appended

Design (new):
- [ ] Zero `border-radius` above `4px` on any structural element (buttons excepted)
- [ ] Exactly one accent color appears on the page; nothing else colored
- [ ] Every mono use is doing a job no other font can do (label, metric, code, ledger)
- [ ] Screenshot-without-logo test: a teammate can identify the page from a cropped grab

---

## 8. What to tell the plan's author

Keep §2 (a11y), §3 (structure), §4.5 and §4.6 (perf/z-index), and §7 (checklist) exactly as written. Replace §1 (design system table), §2.4 (anti-patterns), §4.2 (iconography stance), and §4.3 (type scale) with §3–§5 of this doc. The decision the plan punts on — "pick Fraunces **or** Poppins" — is the wrong question. Keep Fraunces, add Plex Mono as a load-bearing third voice, and commit.
