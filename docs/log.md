# Work Log

## 2026-10-04

### Done (Insights draft: when the model writes its tool call as text)

- Added `content/insights/a-tool-call-that-arrives-as-text.md` as `draft: true` (series "LLM tool calling in production", products referenced by URL only). Written as a story for marketing, not a how-to: an open-weight model wrote its tool call as tag text, our parser threw valid answers away as errors, how we found it, how we built a parser that refuses ambiguity, and the bug we found in our own fix (an optional `null` skipped the duplicate check). Structure: hook, the raw response, why it stayed hidden, the tempting fix and why it is a trap, the twist, how it was proven, takeaways, contact CTA.
- Followed the plan's disclosure rules: no vendor or model names, no internal names, no tuning values, no counts or dates from production, no prompts or schemas. The code sample is written for the article, run against six failure cases and checked by removing its duplicate guard.
- Verified: `hugo` into a scratch directory shows the draft is absent from a normal build and rendered under `hugo -D` (title, canonical URL, series anchor, both related links resolve). No em dashes or non-ASCII characters in the file.

### Done (review fixes for the tool-call-as-text draft)

- Standards: description trimmed to 155 chars (plan range 140-160), `toc: true` (siblings over ~730 words all have it), tone trimmed ("most dangerous", "pleased with ourselves", "best one" removed), three links added to published siblings (fallback-hid-an-outage, record-and-replay-for-llm-tests, a-stub-llm-that-returns-clean-json-hides-parsing-bugs); all resolve under `hugo -D`.
- Disclosure: tool, field and value names are now invented (`submit_review`, `decision`, `score`, `notes`, `weight`) and the article says so in a note. Removed "action", "typed result" and "incident log" wording, and the "every parse error came from one model" claim is now "clustered on one model". The optional `size` field (hinted at the product domain) is now `weight`.
- Code: the sample parser had holes found by running it (a forged extra parameter via an echoed `</parameter>`, `nan`/`inf` scores, a non-list value in a list field). It now rejects unknown names, non-finite numbers and wrong-shaped lists. Tested with 16 cases (all pass) and by removing each guard in turn (known-names, duplicate, finite, list-shape, last-closer, seen-before-continue): each removal fails at least one case. The text now says "last `</function>`" and lists the new guards, and the "break every guard" bullet includes the known-names check.
- Wording at the owner's request: "three problems" from the adversarial review is now "a few problems".

### Done (release of the tool-call-as-text article)

- Removed `draft: true` from `content/insights/a-tool-call-that-arrives-as-text.md`, so it publishes with the Insights section.
- Added back-links to it from `fallback-hid-an-outage.md` and `a-stub-llm-that-returns-clean-json-hides-parsing-bugs.md`.
- Scrubbed three internal project and path names from this log before publishing, because the repository is public and the plan's disclosure rules forbid internal names.
- Left out of the commit on purpose: `docs/seo-article-plan-agentic-llm.md` (needs owner review; it also names internal projects), the unreferenced third-party screenshot in `static/images/clients/`, and the local `.gitignore` edit.

### Plan

- Owner reviews `docs/seo-article-plan-agentic-llm.md`, then commits it. Before that, strip the internal project names and paths it contains, since the repository is public.

## 2026-09-19

### Done (SEO article plan for agentic development / LLM tool-calling)

- Added `docs/seo-article-plan-agentic-llm.md`: backlog of ~25 article ideas in six tracks, publishing prerequisites, and disclosure rules. Products are referenced only by URL (www.biidin.com, www.nevergoblank.com); the plan carries no internal file paths, names, or implementation details, and articles are to teach general lessons rather than document internals.
- Key finding: neither product's codebase contains HuggingFace Inference Providers / router / Inference API work. The tool-calling R&D used an OpenAI-compatible provider for open-weight models. The plan reframes the articles accordingly and lists real HF content as a separate R&D track.
- Follow-up (same day): implemented the plan's publishing prerequisites and reviewed the plan. See "Done (SEO plan implementation)" below.

### Done (SEO plan implementation + NeverGoBlank product page)

- Added `content/products/nevergoblank.md` (same structure as `biidin.md`, limited to what `data/clients.json` and the product README support: career coaching for interviews, reviews and negotiations, plus a desktop companion). No usage, revenue or stack claims.
- Added an `insights` section: `content/insights/_index.md` (kept `draft: true` until the first article is ready; the nav entry is in its front matter), `layouts/insights/list.html` and `single.html`, `archetypes/insights.md`, `assets/scss/pages/insights/_page-insights.scss`, and `layouts/partials/article-jsonld.html`.
- `baseof.html`: added canonical URL and RSS alternate link on all pages, optional `keywords`, and `og:type=article`, `article:*` tags and `Article` JSON-LD for insights articles.
- `config.toml`: Contact menu weight 6 -> 7 (leaves 6 for Insights); added `[markup]` highlight (`github` style) and table-of-contents settings.
- Verified with `make build` (31 pages, no insights output while draft) and a temporary article built with `hugo -D` (canonical, JSON-LD, TOC, code block, related-service link, RSS and sitemap all present; screenshots checked). The test article was removed.
- Self-review pass: confirmed JSON-LD stays valid when a title contains `</script>` or quotes, articles with no optional front matter render without errors, mobile layout at 390px is fine, and no existing content uses fenced code (so the highlight config changes nothing today). Corrected the plan's HF evidence list (added the NeverGoBlank backend). Updated the stale section lists in `AGENTS.md` and `CLAUDE.md` (`protocols/` was removed earlier; `products/` and `insights/` added).
- `content/products/biidin.md`: removed the three "community" claims (thriving community, community-contributed strategies, "Community-driven" result bullet) at the owner's direction; they were not true. Other unverified claims on that page (user counts, profitability) are still in place.
- `content/products/biidin.md`: removed the Go/Fiber framework mention and other sensitive implementation detail at the owner's direction (pipeline phase count, "shared execution kernel", named datastores and Kubernetes, multi-tenant note, BYOK/key-handling note, credit-based tiering, LLM provider fallback chains, role-based access model, WebSocket transport, named execution venues in the stack list). The stack section is now "The Technical Approach" and stays generic. Left in place: freemium/premium and enterprise licensing wording in "The Result", and the unverified user/profit claims.
- Product pages with screenshots: added `static/images/products/biidin-trade-journal.webp` (cropped from a Playwright visual-test output in the product's own test output; entry/exit/result values blurred, sidebar, alpha banner and test masks cropped out, floating chat bubble removed; captioned as test data) and `nevergoblank-hero.webp` (live capture of nevergoblank.com homepage). Added an "Inside the App" section to `biidin.md` and "The Product Today" to `nevergoblank.md`, describing only what the images show. Added figure/caption styles in `_content.scss`. Removed the duplicate H1 from both product pages (the front-matter title already renders as H1). Deliberately not used: seeded dashboard screenshots (invented equity/P&L/win rate, tier and usage counters), competitor-comparison and pricing pages, admin pages, and three unrelated third-party images sitting untracked in `static/images/clients/`.
- Wave 1 SEO drafts: added five unpublished articles in `content/insights/` (`draft: true`): fallback-hid-an-outage, eval-scored-100-percent-with-zero-tool-calls, the-400-that-only-happens-on-the-tool-result-turn, catalog-metadata-is-not-a-health-check, llm-cost-tracking-wrong-both-directions. Facts were checked against the internal incident and cost-reconciliation docs in the product repos; unsupported wording was removed. Corrected the plan: B-series and A1 belong to NeverGoBlank, and D1's cached-input gap over-states recorded cost. Verified with `hugo -D`: no broken internal links, descriptions 154-158 chars, disclosure scan clean. Not committed or deployed; waiting on owner review.
- Wave 2 SEO drafts (Tracks B, C, D, E, F): added 20 unpublished articles in `content/insights/` (`draft: true`). Facts came from four read-only research passes over the product repos plus the official MCP and Hugging Face docs; each draft was then reviewed against those facts and unsupported claims were removed (for example the plan's forced-schema judge claim, which is not true of our judge). F1 is method-only because no HF token is available; F2 includes a real measurement (SciFact, 100 queries, TEI 1.9 CPU, nDCG@10 and Recall@10 with and without rerank) and deliberately no latency numbers. Verified with `hugo -D`: no broken internal links, descriptions 141-160 chars, disclosure scan clean; production build still excludes drafts. Not committed or deployed. Cleaned up: the temporary TEI container and image were removed.
- Fixed the `nevergoblabk` typo to `nevergoblank` in the plan and this log. Review findings are in section 8 of the plan.

### Plan (SEO)

- Owner: confirm the facts and disclosure decisions for wave 1 (plan section 7 and 8) before any draft is written.
- To launch the section with the first article: remove `draft: true` from `content/insights/_index.md`.
- Optional: decide whether to trim stack details from `content/products/biidin.md`.

### Plan

- Section, layouts, menu entry and meta/OG/JSON-LD: done (see above).
- Write wave 1 once the owner confirms facts: fallback-hid-outage postmortem, zero-calls-scored-100% eval bug, tool-result-turn 400, catalog-metadata-lies, LLM-bill-reconciliation.
- Decide whether to run the HF Inference Providers probe (Track F). The separate eval-bench project was checked and holds no HF work.

## 2026-04-15 (late afternoon)

### Done

- Contact page (`content/contact.md`): dropped the generic "Opening Hours" table (mon–sun 9–5 filler) and added a direct `info@privorum.com` mailto with a one-business-day response line. The `call.html` partial already pulls the email from `data/contact.yaml`, so no template change was needed.
- Clients page de-dated: removed every `years` field from `data/clients.json`, and stripped inline dates from the Zoover, Coull status, Comentarismo status, and the Blockchain-protocols group intro (`layouts/clients/list.html`). Dropped the now-dead `.clients-years` span from the template and its SCSS in `_page-clients-list.scss`.
- Added `https://gosmilo.com/` as the Smilo link in `data/clients.json`.

## 2026-04-15 (afternoon)

### Done

- Clients page rebuilt around five engagement categories (`direct`, `protocol`, `agency`, `advisory`, `community`) via a new `category` field in `data/clients.json` and a grouped rendering pass in `themes/hugo-serif-theme/layouts/clients/list.html`.
- Vosbor Exchange pinned to the top of Direct clients as a `featured` founder engagement with expanded copy — Lux Capital-led $7M seed, Market One Capital / FJ Labs / 7percent / Athos / Nucleus, plus Chris Mahoney (ex-Glencore Agri) and Soren Schroder (ex-Bunge) strategic co-investors.
- Added two new direct clients (Biidin, NeverGoBlank) and two previously missing ones (Reusify B.V., Zoover International B.V.).
- Added Polkadot and Cosmos under the `protocol` category with a shared intro explaining the ChainSafe 2019–2020 route; removed ChainSafe as a standalone direct-client card.
- Rewrote Genie AI (NVIDIA Inception, Alpha Sigma Capital) and DefyTrends (BIP Ventures, Ghaf Capital, Panoramic Ventures) descriptions with accurate investor info.
- Introduced a `legal_name` field rendered small under each card (SPHX Inc, Genie AI Inc, DefyTrends Inc, Unveil B.V., Mavin B.V., Dusk Network B.V., Weeronline B.V., Coull Ltd, Bookerzzz B.V., HolidayCheck AG, Spilberg B.V., Progressive B.V., Visser & Van Baars B.V., Reusify B.V., Zoover International B.V., DeepDesk B.V., Vosbor B.V.).
- Added a `status` field + mono tag styling; used on Coull ("Acquired by Acuity Ads (2018)") and Comentarismo ("Open source · in revival").
- Reframed SouJava as community / NGO (JCP Executive Committee seat) and Comentarismo as open-source.
- New/replaced assets: `static/images/clients/dtg.svg` (via Wayback — live CDN behind Akamai), `genie.svg` (refreshed to the purple full-logo variant), `reusify.svg`, `zoover.svg`, `nevergoblank.svg`, `biidin.svg`, and `static/images/protocols/cosmos.svg`.
- Additive SCSS in `_page-clients-list.scss` for `.clients-group`, `.clients-group-title`, `.clients-group-intro`, `.clients-row--featured`, `.clients-legal-name`, `.clients-eyebrow`, `.clients-status`.
- `content/clients/_index.md` intro refreshed to reflect the five-group structure; removed the standalone "Open-source contributions" bullet list (now covered by the community category).

### Plan

- Sharpen NeverGoBlank and Biidin descriptions with scope / years once the client confirms what can be said publicly.
- Confirm legal entities for remaining clients (DTG, Datafloq, William Hill, IBM) and backfill `legal_name` where useful.

## 2026-04-15

### Done

- Clients portfolio cleanup: dropped the `role` field sitewide (template, SCSS, and all 28 `data/clients.json` entries).
- Split the combined `HydraDX · Basilisk` row into two separate entries with their own logos, links, and descriptions.
- Renamed `Picasso (Composable)` to `Composable Finance`; description now calls out the Cosmos ↔ Polkadot IBC bridge work and notes the project has wound down.
- Added logos and external links for DeepDesk, HydraDX, Basilisk, Composable Finance, Weeronline, and DTG (now titled `DTG (De Telefoongids)`).
- New logo assets dropped in `static/images/clients/` (sourced from each homepage's favicon/apple-touch-icon; DTG pulled from the DuckDuckGo icon service since the site is behind Incapsula; Composable from the supplied Twitter avatar).
- `make build` clean; all six new images resolve under `public/images/clients/`.

## 2026-04-13

### Done

- Created `docs/log.md` to keep a running repository work log.
- Updated `AGENTS.md` to require maintaining this log with completed work and next plans.
- Removed the mistakenly placed `dock/log.md`.
- Reviewed the site and planning documents from a strategic positioning perspective.
- Added `docs/positioning-and-content-plan.md` to define the final AI/workflow/backend positioning and the homepage, About, and Services rewrite plan.
- Updated planning documents to remove `AI sidebots`, reduce blockchain-first framing, and align future work around one company story.
- Generated a PDF for `docs/positioning-and-content-plan.md` and placed it in `pdfs/`.
- Added `docs/current-site-page-inventory.md` documenting the current website content page by page.
- Generated a PDF for `docs/current-site-page-inventory.md` and placed it in `docs/pdfs/`.
- Updated the site inventory so the Clients page includes the currently rendered client archive entries.
- Regenerated `docs/pdfs/current-site-page-inventory.pdf` after updating the Clients section.
- Expanded the site inventory to capture dynamic homepage, clients, protocols, services, contact, and team content rendered from layouts and data files.
- Regenerated `docs/pdfs/current-site-page-inventory.pdf` after expanding the inventory to include dynamic rendered content.
- Reformatted the Clients section in the inventory document to separate company names from descriptions for better PDF readability.
- Regenerated `docs/pdfs/current-site-page-inventory.pdf` after improving the Clients section formatting.
- Reworked the Clients section again to use explicit `Company:` and `Description:` lines instead of inline monospace formatting.
- Regenerated `docs/pdfs/current-site-page-inventory.pdf` after changing the Clients section to explicit company/description lines.
- Changed the Clients section to a two-column table for better readability in the document and PDF.
- Regenerated `docs/pdfs/current-site-page-inventory.pdf` after converting the Clients section to a table.

### Plan

- Use the new positioning plan as the source of truth for upcoming homepage, About, and Services rewrites.
- Keep future planning and copy changes aligned with the AI/workflow/backend position, with blockchain as supporting depth.
- Keep generated document exports in `pdfs/` when explicitly requested.
- Use the page inventory document as the baseline for future copy rewrites and comparisons.
- Keep document exports aligned with the user-requested destination when generating PDFs.
- Continue the visual redesign with reference-driven layout changes, starting with the homepage before services and clients.

### Done

- Reworked the homepage to move closer to the reference-driven, platform-style direction.
- Added a new `Platform Thinking` section to the homepage to explain Privorum's delivery model in a more product-oriented way.
- Added dedicated homepage styles for the new platform cards and tags so the layout reads less like a generic services grid.
- Increased the visual contrast of the homepage with a more dramatic hero, metric blocks, deeper systems panel treatment, and a stronger proof overlap.

### Plan

- Verify the homepage build and review how the new middle section changes the page rhythm.
- Continue with the next structural redesign pass for services and clients if the homepage direction is approved.
- If the homepage still feels too close to the old site, push the services and clients pages into the same stronger visual language.

## 2026-04-15

### Done (Phase 0 — Copy & metadata)

- Rewrote `config.toml` title, meta description, OG title/description/image, and logo alt around the AI / automation / backend positioning. Fixed the `odeneis` typo and the 2017/2020 founding-year contradiction. Replaced the upstream `raw.githubusercontent.com/JugglerX/...` OG placeholder with a Privorum asset.
- Reordered the main nav to Services · About · Team · Clients · Contact. Removed the Protocols entry. Removed `menu: 'main'` front matter from `about.md` and `contact.md` to avoid double menu entries.
- Replaced the homepage H1 `Build AI sidebots and serious backend systems.` (banned term per the positioning plan) with `Senior engineering for AI workflows, automation, and backend platforms.` and reworded the supporting paragraph to reuse `senior engineering judgment`.
- Restructured `content/services/`: deleted `dapp-development.md`, `permissioned.md`, `permissionless.md`, `reduce-costs.md`, and `security audit.md` (the space-in-filename page). Added `ai-workflows.md` (weight 1), `workflow-automation.md` (weight 2), `backend-platforms.md` (weight 3), `security-audit.md` (weight 4), `blockchain-systems.md` (weight 5, consolidating the two permissioned/permissionless pages), and set `blockchain-advisory.md` to weight 6.
- Deleted `content/protocols/` entirely — empty primary nav item damaged credibility.
- Replaced the placeholder Clients page with a real named list (WeShare Ventures, go-ethereum, CoinD, waves-go-client) plus an NDA-work disclosure.
- Copy hygiene: fixed the `10:am` typo in `contact.md`, grouped the tech stack in `about.md` under Languages / Frontend / Infrastructure / Data, and deduped the `You have a vision…` closer between the two team bios.
- Filled out `content/404/_index.md` with a short not-found page linking home, services, and contact.
- Confirmed `hugo` builds cleanly — only remaining warning is the `.Site.Data` deprecation, which is the Phase 1 target.

### Plan

- Phase 1 — engineering correctness: migrate `.Site.Data` → `site.Data` (6 files), self-host Fraunces + IBM Plex Sans + IBM Plex Mono, add a global `:focus-visible` ring, enforce 44px touch targets, wrap every `transform`/`transition` in a `prefers-reduced-motion` guard, and remove the dead `scripts.js` include in `baseof.html`.
- Phase 2 — commit the Technical Editorial design tokens in `_variables.scss` and publish `docs/design-system.md`.
- Phases 3–7 — hero rebuild (Execution Ledger), strip glassmorphism site-wide, structural cleanup (theme rename, dead-component removal, SCSS split, slim Bootstrap), client-logo strip, and final perf / image-pipeline polish.

### Done (Phase 1 — Engineering correctness)

- Migrated every `.Site.Data` reference in the theme to `hugo.Data` across `layouts/index.html`, `layouts/clients/list.html`, `layouts/protocols/list.html`, `layouts/services/list.html`, `layouts/partials/call.html`, and `layouts/partials/sub-footer.html`. Build is now deprecation-free.
- Self-hosted Fraunces (500/600/700), IBM Plex Sans (400/500/600), and IBM Plex Mono (400/500) as latin-subset WOFF2 files under `static/fonts/`. Added `themes/hugo-serif-theme/assets/scss/components/_fonts.scss` with matching `@font-face` rules at `font-display: swap`. Removed the Google Fonts `<link>` and `preconnect` tags from `baseof.html`; replaced them with `<link rel="preload">` hints for the two hero-critical faces (Fraunces 600, Plex Sans 400). No third-party font requests remain in the rendered HTML.
- Added `themes/hugo-serif-theme/assets/scss/components/_focus.scss` with a global `:focus-visible` ring (2px burnt-orange `#C2410C`, 3px offset, 3px on buttons) plus a skip-link shell for future use. Imported it from `style.scss` alongside the new fonts partial.
- Added a blanket `@media (prefers-reduced-motion: reduce)` guard in `_focus.scss` that collapses transitions and animations site-wide, and wired local reduced-motion overrides on the primary `.button` and `.main-menu a` transitions.
- Enforced 44px minimum touch targets on the primary button (`min-height: 46px; min-width: 46px`), main-menu links (`min-height: 44px`), and sub-footer links.
- Left `assets/js/scripts.js` in place — the plan flagged it as a no-op but it still wires the mobile-menu toggle, so deleting it would break mobile navigation. Noted this and moved on.
- `hugo` build is clean — no deprecation warnings, no missing-asset errors.

### Plan

- Phase 2 — commit Technical Editorial design tokens in `_variables.scss` (ink, paper, paper-deep, rule, accent, mute; Fraunces / Plex Sans / Plex Mono; 96/128/160 section spacing; z-index scale) and publish `docs/design-system.md`.
- Phases 3–7 — hero rebuild, glassmorphism strip, structural cleanup, client-logo strip, final perf polish.

### Done (Phase 2 — Design system token commit)

- Rewrote `themes/hugo-serif-theme/assets/scss/_variables.scss` to the locked Technical Editorial tokens: `$ink`, `$paper`, `$paper-deep`, `$rule`, `$accent` (burnt orange `#C2410C`), `$mute`; `$font-display` (Fraunces), `$font-body` (IBM Plex Sans), `$font-mono` (IBM Plex Mono); 96 / 128 / 160 section spacing; and an explicit z-index scale.
- Kept legacy aliases (`$primary`, `$black`, `$graphite`, `$steel`, `$ghost`, `$mist`, `$cloud`, `$paper`, `$font-family-base`, `$font-family-heading`) pointed at the new tokens so downstream SCSS keeps compiling while Phases 3–5 rewrite each page. Will remove the aliases when Phase 5 finishes the rewrites.
- Published `docs/design-system.md` as the authoritative reference — color hierarchy, type roles, spacing, z-index scale, motion budget, accessibility rules, structural no-gos, and the per-PR delivery gate.
- `hugo` build is clean after the token swap; old blue CTAs now render in burnt orange, which is exactly what Phase 4 will consolidate into a single accent per section.

### Plan

- Phase 3 — rebuild the hero in `layouts/index.html` and `pages/_home.scss` as the Execution Ledger: 7/12 Fraunces H1 column plus 5/12 mono ledger column, hairline rows, one orange CTA, hero motion budget of a single H1 load animation.
- Phase 4 — strip glassmorphism site-wide (backdrop-filter, cards → hairline rows, cap homepage motion at three animations total).
- Phases 5–7 — theme detach + dead-component removal + SCSS split + slim Bootstrap; client-logo strip; final perf / image-pipeline polish.

### Done (Phases 3 + 4 — Hero rebuild and glassmorphism strip)

- Rebuilt the homepage (`themes/hugo-serif-theme/layouts/index.html`) around the Execution Ledger: a 7/12 Fraunces lede column with inline metric hairlines and one burnt-orange CTA, and a 5/12 right-column monospace Execution Ledger listing real engagements (WeShare Ventures, go-ethereum, CoinD, waves-go-client, NDA row). Replaced the systems-art composition, stripped the dark-hero gradient, removed backdrop-filter, blue glow, and every card-with-radius block.
- Restructured every downstream homepage section as hairline rows: Capabilities as a numbered `.capability-list` with mono index + Fraunces title + mute body, Delivery as a three-step `.platform-list`, Why-Privorum as a two-column `.trust-list`, Proof as a mono `.proof-strip`, and a closing ink-band CTA with an accent text link.
- Rewrote `assets/scss/pages/_home.scss` end-to-end in the Technical Editorial style: warm paper background, `$rule` hairlines, single accent per section, mono load-bearing labels, exactly three motion sources (hero H1 letter-spacing tighten on load, ledger on-scroll fade reserved, CTA underline transition). The site-wide `prefers-reduced-motion` guard (from Phase 1) also suppresses these.
- Rewrote `_type.scss`, `_buttons.scss`, `_main-menu.scss`, `_header.scss`, `_footer.scss`, `_sub-footer.scss`, `_call.scss`, and `_content.scss` to the new tokens — no glass backgrounds, no multi-stop gradients, no `border-radius > 4px` on structural elements. Buttons are now sharp-cornered (2px radius) burnt-orange rectangles with a 48px min hit area.
- Rewrote services, clients, and team list templates as hairline-row archives (`layouts/services/list.html`, `layouts/clients/list.html`, `layouts/team/list.html`, `layouts/_default/list.html`). Corresponding page SCSS (`pages/clients/_page-clients-list.scss`, `pages/team/_team-summary.scss`, `pages/services/_page-services-single.scss`) now use grid-based hairline rows instead of cards with radii and shadows.
- Gated the dev breakpoint widget behind `body.dev` in `style.scss` so it no longer leaks into production output, and wired the new `$z-toast` scale value into it.
- Cleaned up banned terminology in the data files (`data/service_areas.json`, `data/features.json`) — `AI Sidebots` became `AI Workflows` with rewritten descriptions matching the positioning plan's voice.
- Smoke-tested the running `hugo server`: `/`, `/services/`, `/services/ai-workflows/`, `/clients/`, `/team/`, and `/contact/` all return 200 and the rendered HTML contains no `sidebot`, no `JugglerX`, no `odeneis`, and no `fonts.googleapis.com` references.

### Done (Phase 5 — Structural cleanup)

- Deleted the orphan `layouts/protocols/list.html` and the now-dead component SCSS files: `_strip.scss`, `_whitebox.scss`, `_intro.scss`, `_sub-menu.scss`, `_feature.scss`, `_intro-image.scss`. Removed their imports from `style.scss`. Nothing in `layouts/` or `content/` still references the deleted classes.
- Confirmed that the Bootstrap import in `style.scss` was already slim — only `bootstrap-grid`, `mixins`, and the `utilities/text` subset are pulled in — so no further trimming was required. Rendered CSS is ~83KB minified, dominated by the grid system and our token-driven component styles.
- Kept the theme named `hugo-serif-theme/` for now. The plan allowed a rename to `themes/privorum/`, but the benefit is cosmetic and the rename would churn every layout + config path. Deferring until there's a concrete reason to diverge from the upstream directory name.

### Done (Phase 6 — Client logos & iconography) — deferred

- This phase depends on approved monochrome SVG logos for the client strip. No logos have been approved, so the homepage Proof strip currently renders as a mono text list backed by `data/clients.json`, which is in keeping with the Technical Editorial aesthetic anyway. Revisit once logos are cleared — replace the `.proof-item` text spans with SVG `<img>` tags and desaturate them via CSS.

### Done (Phase 7 — Perf & polish)

- Added explicit `width`, `height`, and `loading="lazy"` attributes to team photos (`layouts/team/summary.html`) and explicit `width` / `height` to the desktop and mobile logos in `layouts/partials/header.html` so the browser can reserve layout space and avoid CLS on first paint.
- Added `<link rel="preload" as="font" type="font/woff2">` hints in `baseof.html` for the two hero-critical WOFF2 files (Fraunces 600, IBM Plex Sans 400). Combined with the `font-display: swap` declarations in `components/_fonts.scss`, fonts render without FOIT even on slow connections.
- Did **not** touch `deploy.sh`. The plan listed two options — modernize to a GitHub Action, or delete — but both are user-facing process decisions and not safe to make unilaterally. Left a note here so the next session picks it up.
- Did **not** run a Lighthouse audit; that requires a browser environment. Pre-delivery gate in `docs/design-system.md` calls for Lighthouse mobile LCP < 2.5s, CLS < 0.1, a11y = 100. Recommended as the next verification step once the site is deployed to a preview URL.

### Plan

- Open a PR for the seven-phase overhaul off the current `dev` branch.
- Next session: (a) run a Lighthouse pass against a deployed preview, (b) decide whether to modernize or retire `deploy.sh`, (c) commit monochrome client SVG logos and switch the homepage Proof strip over to them, (d) optionally rename `themes/hugo-serif-theme/` → `themes/privorum/` once there's a concrete reason.

### Done (Clients overhaul — CV rebuild + logos restored + background to white)

- Reverted the warm paper background to white. Edited `themes/hugo-serif-theme/assets/scss/_variables.scss`: `$paper` `#F4F1EA` → `#FFFFFF`, `$paper-deep` `#EBE6DB` → `#F7F7F5`. Kept `$ink`, `$rule`, `$accent`, `$mute`, and the typography / spacing / z-index tokens identical. The identity now rides on hairlines, mono labels, and the burnt-orange accent — the paper warmth was fighting the colour PNG logos (IBM, William Hill, HolidayCheck, etc.).
- Updated `docs/design-system.md` to describe the white baseline and note the warm-paper revert so the document stops describing an aesthetic the site no longer ships.
- Rewrote `data/clients.json` from Thomas's CV as the source of truth: 22 chronological engagements (DeepDesk 2025–2026 → IBM 2009–2013) plus the six retained entries the user wanted to keep (HolidayCheck, Spilberg, Progressive, Visser & Van Baars, SouJava, Comentarismo). Added `years` and `role` fields to every entry so the UI can render a mono eyebrow and accent role label. Trimmed every description to ≤2 short sentences focused on what Privorum delivered (AI platform, trading platform, bid switch, etc.) rather than corporate marketing blurbs.
- Restored logo rendering on the homepage Proof strip: bumped `{{ range first 8 }}` to `{{ range first 12 }}`, added `{{ if .image }} <img> {{ else }} <span class="proof-item-text">{{ end }}` inside each `.proof-item`. Rebuilt `.proof-strip` in `pages/_home.scss` as a 4-column (2 on mobile, 3 on sm) grid of 96px cells separated by `$rule` hairlines, with `object-fit: contain`, a max logo height of 48px, and an 0.85 → 1 opacity hover. Mono text fallback sits in the same cell rhythm for entries that still lack a logo (DeepDesk, HydraDX/Basilisk, Picasso).
- Rebuilt the Clients archive (`layouts/clients/list.html` + `pages/clients/_page-clients-list.scss`) as a logo-led hairline grid: `160px` logo column → meta column (mono year eyebrow + Fraunces title + accent role label) → body column (trimmed description) → arrow. Static rows (no link) use a `.clients-row-link--static` variant so the hover state doesn't lie about interactivity. Mobile collapses to a single column with the logo above the meta block.
- Added a closing `clients-note` line acknowledging additional NDA engagements so the page doesn't look artificially short while recruiters and community contributions are visible.
- Smoke-tested `hugo server`: `/` and `/clients/` return 200. The proof strip now mixes real PNG/SVG logos with mono text fallbacks, and the clients archive renders 28 rows with 23 logo images (5 text-fallback rows for engagements without a logo asset yet).

### Plan

- Upload logos for DeepDesk, HydraDX / Basilisk, Picasso, Weeronline, and DTG so the five remaining mono fallbacks can be swapped to real brand marks.
- Decide whether to move the retained Spilberg / Progressive / Visser & Van Baars / SouJava / Comentarismo block into a visually distinct "Additional" cluster on the Clients page (currently they sit contiguously after the CV chronology).
- Keep the logo-optimisation pass (WebP/AVIF, `<picture>`, responsive `srcset`) queued for the next perf pass.

### Done (Services — add Machine Learning and Data Engineering pages)

- Added `content/services/machine-learning.md` (weight 2) and `content/services/data-engineering.md` (weight 3) matching the existing service-page pattern: practical-question list, typical engagement areas, technology depth, and a closing production-mindset line. ML covers model design, training/eval, serving, MLOps, and drift monitoring. Data Engineering covers ingestion, ETL/ELT, warehousing, streaming, data quality/contracts, and feature stores feeding ML.
- Reweighted existing service pages so the services index orders by topic adjacency: AI Workflows (1) → Machine Learning (2) → Data Engineering (3) → Workflow Automation (4) → Backend Platforms (5) → Security Audits (6) → Blockchain Systems (7) → Blockchain Advisory (8).
- Updated `data/service_areas.json` so the homepage "What Privorum builds" capability list surfaces the two new areas. Replaced the generic "Analytics & Data Systems" card with more specific "Machine Learning" and "Data Engineering & Pipelines" entries; kept "Integrations & Infrastructure" and "Blockchain & Distributed Systems" so the list still reads as a full capability map.
- Verified with `hugo`: build passes, `public/services/machine-learning/` and `public/services/data-engineering/` render, services index lists all eight pages.

### Plan

- Decide whether ML and Data Engineering warrant dedicated case-study rows on the Execution Ledger / Proof strip or should stay described at the service-page level only.
- Consider adding inline references (github links, blog posts) on the ML and Data Engineering pages similar to Blockchain Systems, once non-NDA artefacts are available.
