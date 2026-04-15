# Privorum Design System — Technical Editorial

This is the authoritative reference for visual tokens across the Privorum marketing site. If something on the site does not resolve to a value documented here, it is wrong.

Tokens live in `themes/hugo-serif-theme/assets/scss/_variables.scss`. Everything downstream must reference those variables — not hex literals, not ad-hoc values.

## Why Technical Editorial

Two earlier directions were rejected before this system was locked:

- The upstream serif theme's generic blue (`#3b82f6`) glassmorphism. Reads as SaaS hype. Fails the screenshot-without-logo test.
- A "Trust & Authority" corporate blue direction proposed in an early design review. Indistinguishable from ~60% of B2B consultancy sites.

Technical Editorial commits to a distinctive aesthetic: hairline rules instead of cards, a single load-bearing accent color, and a three-voice typography system where monospace is a first-class citizen used for labels, metrics, and the Execution Ledger. The background is white — a deliberate revert from an earlier warm-paper experiment that fought the client logo strip.

## Color hierarchy

Colors are ordered — not a palette. Every screen draws from this order; new colors require a design review.

| Token        | Hex       | Role                                                   |
| ------------ | --------- | ------------------------------------------------------ |
| `$ink`       | `#0B0D0E` | Primary text, structural black                                        |
| `$paper`     | `#FFFFFF` | Page background — white so partner and client logos render cleanly     |
| `$paper-deep`| `#F7F7F5` | Alternate section background — near-white with a hint of warmth        |
| `$rule`      | `#1F1C18` | 1px hairlines between rows                                             |
| `$accent`    | `#C2410C` | Burnt orange — the ONLY non-neutral allowed on a page                  |
| `$mute`      | `#6B6459` | Secondary text, metadata, mono labels                                  |

The previous direction called for a warm paper (`#F4F1EA`) background. That was replaced with white once the client-logo strip returned — colour PNGs (IBM, William Hill, HolidayCheck etc.) were designed against white and fought the warm paper. The identity is now carried by the hairline rules, the IBM Plex Mono labels, the Execution Ledger, and the burnt-orange accent — not by the background colour.

**Accent rule:** exactly one accent instance per section. If a screen shows two orange elements competing, one is wrong.

## Typography

Three type roles — each with a clear job. Mono is load-bearing, not decorative.

| Token           | Family          | Role                                     |
| --------------- | --------------- | ---------------------------------------- |
| `$font-display` | Fraunces        | H1–H2, pull quotes                       |
| `$font-body`    | IBM Plex Sans   | Body copy, navigation, standard UI text  |
| `$font-mono`    | IBM Plex Mono   | Eyebrows, labels, metrics, Execution Ledger |

**Mono rule:** every mono use must be load-bearing — a label, a metric, a code reference, a ledger entry. Mono is not for decorative flair.

Font files are self-hosted as WOFF2 under `/static/fonts/` (latin subset only). Google Fonts is not used at runtime.

## Spacing

Section rhythm. Use for top/bottom section padding.

| Token                | Value  | Use                            |
| -------------------- | ------ | ------------------------------ |
| `$space-section-sm`  | `96px` | Tight stacked sections         |
| `$space-section-md`  | `128px`| Default marketing section padding |
| `$space-section-lg`  | `160px`| Hero and flagship sections     |

Inline spacing (margin, padding, gap) uses an 8px base. Prefer multiples of 8.

## Z-index scale

Layer order is explicit — no arbitrary `z-index: 9999` values.

| Token        | Value | Layer       |
| ------------ | ----- | ----------- |
| `$z-nav`     | `10`  | Navigation  |
| `$z-dropdown`| `20`  | Dropdowns   |
| `$z-modal`   | `30`  | Modals      |
| `$z-toast`   | `50`  | Toasts      |

## Motion

Motion budget on any single page is **three animations total**. More than three and the page reads as a demo, not a document.

- Transitions: `0.18s ease` or shorter.
- Every `transition:` or `transform:` is wrapped in a `@media (prefers-reduced-motion: reduce)` fallback, or covered by the site-wide reduced-motion guard in `components/_focus.scss`.
- No parallax. No scroll-jacking. No entrance animations on every element.

## Accessibility rules

- Every interactive element has a visible `:focus-visible` ring (burnt orange, 2px, 3px offset; 3px on buttons).
- Minimum touch target: 44×44 px. 46×46 on primary buttons.
- Text contrast: body copy meets WCAG AAA against `$paper`.
- `prefers-reduced-motion: reduce` is respected site-wide.

## What structural elements may not do

- No `backdrop-filter: blur()` on structural elements.
- No `border-radius > 4px` on structural elements. Buttons are the single exception (`border-radius: 999px`).
- No drop shadows deeper than `0 1px 0 $rule`.
- No gradient text on headings.
- No card-with-radius containers. Use hairline rows.

## Pre-delivery gate for any PR

- [ ] `make build` passes clean.
- [ ] Tested at 375 / 768 / 1024 / 1440 px.
- [ ] Focus ring visible on every interactive element.
- [ ] `prefers-reduced-motion` honored on every `transform:` or `transition:`.
- [ ] No `backdrop-filter: blur()` reintroduced.
- [ ] Zero `border-radius > 4px` on structural elements (buttons excepted).
- [ ] Exactly one accent color instance per section.
- [ ] Every mono use is load-bearing.
- [ ] `docs/log.md` appended.

## Legacy aliases

`_variables.scss` still exports legacy names (`$primary`, `$black`, `$paper-deep` via `$cloud` etc.) so Phases 3–5 can rebuild downstream SCSS incrementally without breaking the build. **Do not reference the legacy aliases in new code.** When Phase 5 finishes rewriting the page SCSS, the aliases will be removed.
