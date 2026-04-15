# Privorum UI Refactor Plan

Actionable refactor of the current Hugo + `hugo-serif-theme` implementation, benchmarked against the **Enterprise Gateway / Trust & Authority** pattern appropriate for a B2B blockchain + AI consultancy. Findings come from a read of `themes/hugo-serif-theme/` (layouts, partials, SCSS) and `layouts/index.html`.

---

## 1. Recommended Design System (target)

| Layer | Current | Target |
|---|---|---|
| Pattern | Editorial/Serif landing | **Enterprise Gateway** — logo strip, capability grid, path-to-contact |
| Style | Warm serif + glassy card stack | **Trust & Authority** — credentials-forward, metric-driven, restrained |
| Primary | `#3b82f6` (Tailwind blue-500) | `#0369A1` (sky-700) for CTAs; keep navy `#0F172A` as primary brand |
| Secondary | `#60a5fa` | `#334155` (slate-700) |
| Surface | Paper `#f3f5f7` | `#F8FAFC` |
| Text | `#10141b` | `#020617` (near-black) + `#475569` muted |
| Heading font | Fraunces (serif) | **Poppins** (or keep Fraunces if editorial tone is intentional — pick one, don't mix two personalities) |
| Body font | IBM Plex Sans | **Open Sans** (or keep Plex Sans — both are fine; lock one) |

> **Decision required:** keep Fraunces/Plex (editorial consultancy) **or** shift to Poppins/Open Sans (classic B2B enterprise). Pick one — the current hero mixes a serif headline with glassy dark-mode cards, which reads as two different products.

---

## 2. Critical Issues (fix first)

### 2.1 Accessibility — no visible focus styles on primary interactive elements
- `.button` in `themes/hugo-serif-theme/assets/scss/components/_buttons.scss:1` has no `:focus-visible` rule. Bootstrap's reboot actively **suppresses** focus on `[tabindex="-1"]` (`_reboot.scss:62`) and the only custom focus rule is on the hamburger.
- `.hero-link`, `.proof-item`, `.overview-card`, `.trust-card`, `.platform-card` are all hoverable/clickable-looking but have no focus treatment.
- **Action:** add a global `:focus-visible` ring — e.g. `outline: 2px solid $primary; outline-offset: 3px;` — and a dedicated `.button:focus-visible` rule using a 3px ring in the CTA color.

### 2.2 Touch target sizes below 44×44
- `.button` is `height: 46px` ✓ but padding `0 18px` gives narrow targets on short labels (e.g. "Read more"). Enforce `min-width: 44px`.
- `.hero-link` is plain text with no padding — under 44px tall on mobile.
- Header nav items and footer links have no minimum touch area.
- **Action:** audit `_buttons.scss`, `_main-menu.scss`, `_sub-footer.scss` for `min-height: 44px` on anchors.

### 2.3 Light-mode contrast in hero metric cards
- `.hero-metric` uses `background: rgba(15, 23, 42, 0.38)` with `color: rgba(226, 232, 240, 0.82)` — this is a dark card on a page whose default body is light. It works only because the hero section overrides the background to dark navy further down (`_home.scss:361`). This "dark island inside a light page" coupling is fragile: change the hero background and the metric text becomes unreadable.
- **Action:** decouple. Either commit the hero to the dark navy background and stop declaring a light body gradient under it, **or** restyle metric cards for the light surface (slate-900 text on white-ish glass).

### 2.4 Anti-patterns flagged by the Trust & Authority style
- Hero uses `rgba(59, 130, 246, …)` blue glow + `radial-gradient` on `systems-art` — borderline "AI purple/pink gradient" territory (`_home.scss:78`, `:365`). Enterprise/Trust style avoids playful gradient washes.
- **Action:** replace radial glows with a single restrained accent (thin 1px sky-700 border, subtle shadow). Keep it corporate, not SaaS-hype.

---

## 3. High-Priority Structural Refactor

### 3.1 Theme is forked but undocumented
The `hugo-serif-theme` ships as a standalone theme but has been heavily customized (homepage SCSS added "home-hero", "systems-art", "platform-card", etc. that aren't in the upstream theme). This makes theme upgrades impossible.

- **Action:** either (a) fully detach — delete `themes/hugo-serif-theme/LICENSE`/`README`/`netlify.toml`/`stackbit.yaml`, rename the directory to `themes/privorum`, and own it as a project theme, or (b) move project-specific styling out of the theme into `assets/` at the repo root and treat the theme as upstream-trackable.

### 3.2 SCSS is fragmented across the theme
Page-specific CSS (`_home.scss`, ~570 lines) lives next to Bootstrap 4 primitives and legacy components (`_whitebox.scss`, `_intro.scss`, `_strip.scss`, `_sub-menu.scss`) — several unused in the current design.

- **Action:** run `rg -l 'class="[^"]*whitebox'` etc. on `content/` + `layouts/` and delete dead component SCSS. At a glance, `whitebox`, `intro-image`, `strip`, `sub-menu` look stale.
- Split `_home.scss` into `_hero.scss`, `_proof.scss`, `_platform.scss`, `_trust.scss` by section.

### 3.3 Bootstrap 4 is heavy for what's used
Only the grid, a few utilities, and mixins (`media-breakpoint-up`) are actually used. The entire `scss/bootstrap/` directory is imported indirectly.

- **Action:** after a grep audit, import **only** `bootstrap-grid` + `mixins/breakpoints` + the text utilities actually used. Measure `public/css/style.*.css` before/after — expect a meaningful drop. Alternative: drop Bootstrap entirely and write the ~6 breakpoint mixins inline.

### 3.4 `.Site.Data` deprecation
Hugo v0.160 warns: `.Site.Data was deprecated in v0.156`. Used in `layouts/index.html:95,121,194` and likely other files.

- **Action:** replace `.Site.Data.foo` → `hugo.Data.foo` (or `site.Data.foo` via the new API — verify current Hugo migration guide).

### 3.5 External Google Fonts on every page
`baseof.html:14` loads Fraunces + IBM Plex Sans from `fonts.googleapis.com`. Third-party font fetches hurt LCP and have GDPR implications for an EU-focused consultancy.

- **Action:** self-host the two font families (use `hugo-mod-fonts` or drop `.woff2` files into `static/fonts/`), add `font-display: swap`, remove the `preconnect` to Google.

---

## 4. Medium-Priority Polish

### 4.1 Hover-only affordances miss keyboard/touch users
`.proof-item`, `.overview-card`, `.trust-card`, `.platform-card` all lift on hover but have no `:focus-visible` equivalent. On touch, the hover state sticks after tap.
- **Action:** duplicate every `&:hover` block with `&:focus-visible` and wrap decorative motion in `@media (prefers-reduced-motion: reduce) { transform: none; }`.

### 4.2 Icons and visual identity
The current design leans on geometric CSS shapes (`.systems-grid`, `.systems-rail`, `.systems-node`). There are no product/service icons on cards, no trust badges, no client logos — just text tiles (`.proof-item`). For Trust & Authority, **logos and credentials are the conversion driver**.
- **Action:** replace text-only `.proof-item` with real SVG client logos (monochrome, consistent viewBox) in `static/images/clients/`. Add a small icon to each `.overview-card` and `.platform-card` — use Lucide or Heroicons, never emoji.

### 4.3 Typography — heading scale is aggressive
Hero `h1` is `clamp(3.4rem, 7vw, 5.9rem)` with `letter-spacing: -0.045em` and `line-height: 0.94` (`_home.scss:371`). Fine for a product launch page; heavy-handed for enterprise positioning.
- **Action:** tighten to `clamp(2.5rem, 5vw, 4rem)`, `line-height: 1.05`, `letter-spacing: -0.02em`. Add `max-width: 20ch` (current `10ch` forces awkward wrapping).

### 4.4 Section-to-section rhythm
Vertical padding varies section-to-section with no system (`56px`, `88px`, `104px`, `42px`, `84px`). Eye-balled, not scaled.
- **Action:** define a spacing scale (`--space-section-sm: 56px; --space-section-md: 88px; --space-section-lg: 112px;`) and use it consistently.

### 4.5 Content jumps + image optimization
- `baseof.html` doesn't reserve space for async content and doesn't use `loading="lazy"` on images.
- No `<img srcset>` or WebP.
- **Action:** add Hugo image processing (`resources.GetRemote` / `.Resize`) for client logos and team photos; emit `<picture>` with `.webp` + `loading="lazy"` + explicit `width`/`height`.

### 4.6 `z-index` scale
`.header.header-absolute { z-index: 10 }`, body breakpoint indicator `z-index: 9999`, and various stacking contexts are ad-hoc.
- **Action:** document a 4-step scale (`10` nav, `20` dropdowns, `30` modals, `50` toasts) in `_variables.scss`.

---

## 5. Low-Priority / Nice-to-Have

- `baseof.html` still has a no-op `<script src="scripts.js">` include with no actual scripts — remove if unused.
- `deploy.sh` is a legacy gh-pages script mostly commented out. Either modernize (GitHub Action to build + publish) or delete.
- Breakpoint display widget (`_variables.scss` / `style.scss:51-71`) is handy but permanent; gate behind a `.dev` body class toggle so it doesn't fire on every server reload.

---

## 6. Suggested Execution Order

1. **Week 1 — correctness & a11y:** focus-visible, touch targets, reduced-motion, `.Site.Data → hugo.Data`, self-host fonts. (≤2 days, low risk.)
2. **Week 1–2 — design system lock:** decide Fraunces vs Poppins, commit color palette in `_variables.scss`, document the scale in `docs/design-system.md`. Remove unused components (`whitebox`, `strip`, etc.).
3. **Week 2 — structure:** detach theme into `themes/privorum` (or pull project SCSS out), slim Bootstrap imports, split `_home.scss` by section.
4. **Week 3 — visual identity upgrade:** real client logos, iconography on capability cards, restrained gradients, section rhythm scale.
5. **Week 3–4 — perf + polish:** image processing pipeline, z-index scale, spacing tokens.

---

## 7. Pre-Delivery Checklist (for each refactor PR)

- [ ] `make build` clean, no new Hugo warnings
- [ ] Tested at 375 / 768 / 1024 / 1440 px
- [ ] Focus ring visible on every interactive element
- [ ] No emojis as icons (SVG only)
- [ ] Light + dark surfaces both verified — no rgba(15,23,42,0.38) on a light body
- [ ] `prefers-reduced-motion` respected on every `transform:` animation
- [ ] `docs/log.md` appended

---

## 8. Files You'll Touch Most

| File | Why |
|---|---|
| `themes/hugo-serif-theme/assets/scss/_variables.scss` | Palette, font, z-index, spacing tokens |
| `themes/hugo-serif-theme/assets/scss/style.scss` | Slim Bootstrap imports, dev widget gate |
| `themes/hugo-serif-theme/assets/scss/components/_buttons.scss` | Focus + min-width |
| `themes/hugo-serif-theme/assets/scss/pages/_home.scss` | Split into per-section files, remove gradient glow |
| `themes/hugo-serif-theme/layouts/_default/baseof.html` | Self-hosted fonts, image handling |
| `themes/hugo-serif-theme/layouts/index.html` | `.Site.Data → hugo.Data`, real logos |
| `themes/hugo-serif-theme/layouts/partials/header.html` | Keyboard nav, skip link, focus treatment |
