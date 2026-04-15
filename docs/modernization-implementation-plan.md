# Privorum Modernization Implementation Plan

## Goal

Implement the new visual direction for Privorum using the existing Hugo codebase.

Target style:

- 75% Quiet Enterprise
- 25% Editorial Tech

This plan focuses on the current theme and identifies the highest-impact file changes first.

## Current Theme Assessment

The current site is structurally usable, but visually it still reads as a lightly customized Hugo theme.

Main issues in the current implementation:

- header is too plain and theme-default
- buttons feel generic and slightly dated
- menu styling is basic and too theme-driven
- feature cards are flat and weak as proof/value blocks
- homepage intro is functional but not premium
- typography is not strong enough to carry the new brand direction
- spacing is tighter than it should be for a premium technical brand

## Recommended Font Direction

Use:

- Headings: `Fraunces`
- Body/UI: `IBM Plex Sans`

Why:

- `Fraunces` gives the editorial sophistication needed for the 25% Editorial Tech layer
- `IBM Plex Sans` keeps the body and interface grounded, technical, and readable

Fallback direction if needed:

- headings: Georgia / serif
- body: Helvetica / Arial / sans-serif

## Phase 1: Core Visual System

Priority: high

Files:

- `themes/hugo-serif-theme/assets/scss/_variables.scss`
- `themes/hugo-serif-theme/assets/scss/style.scss`
- `themes/hugo-serif-theme/assets/scss/components/_header.scss`
- `themes/hugo-serif-theme/assets/scss/components/_main-menu.scss`
- `themes/hugo-serif-theme/assets/scss/components/_buttons.scss`
- `themes/hugo-serif-theme/assets/scss/components/_footer.scss`
- `themes/hugo-serif-theme/assets/scss/components/_intro.scss`

### Phase 1 changes

#### 1. Replace the color system

Current variables:

- primary blue is usable
- secondary coral should be reduced
- neutral system is too weak and theme-like

Update to a more disciplined palette:

- new text colors
- new surface colors
- cleaner neutral hierarchy
- stronger CTA blue

#### 2. Strengthen typography

Add font imports and update:

- `$font-family-heading`
- `$font-family-base`

Then rebalance:

- headline sizes
- line heights
- paragraph width
- menu typography

#### 3. Refine the header

Current header:

- very plain
- too close to theme defaults
- lacks premium detail

New header should:

- use more breathing room
- use a more refined divider or soft shadow
- improve logo spacing
- make navigation feel lighter and more deliberate

#### 4. Redesign buttons

Current buttons:

- look generic
- too much startup-template shadow
- uppercase styling feels dated

New buttons should:

- be calmer and more premium
- have better padding
- reduce unnecessary shadow
- rely more on shape, contrast, and subtle hover states

#### 5. Upgrade the footer

Current footer is serviceable but dated.

New footer should:

- feel heavier and more intentional
- use improved spacing
- support trust and contact
- carry the premium tone more strongly

## Phase 2: Homepage Redesign

Priority: highest after Phase 1

Files:

- `content/_index.md`
- `themes/hugo-serif-theme/layouts/index.html`
- `themes/hugo-serif-theme/assets/scss/components/_intro.scss`
- `themes/hugo-serif-theme/assets/scss/components/_feature.scss`
- `data/features.json`

### Phase 2 changes

#### 1. Rewrite the homepage hero

The current homepage copy is too old-positioning and too broad.

Replace with:

- AI-first positioning
- short support statement
- clearer CTA
- stronger trust language

#### 2. Redesign the homepage hero layout

Current layout:

- content left
- illustration right

Recommended update:

- preserve the two-column structure for speed
- make the right column more atmospheric and less stock-illustration dependent
- add a systems-inspired visual treatment instead of relying fully on the existing asset

#### 3. Replace the current feature block content

Current entries:

- Free Consultation
- Certified Developers
- Cost effective

These are weak and generic.

Replace with stronger value pillars such as:

- Production-Ready AI Systems
- Workflow Automation
- Backend & Platform Engineering

#### 4. Improve section rhythm

The homepage needs:

- better vertical spacing
- stronger section contrast
- more premium transitions between hero, services, and proof

## Phase 3: Clients Page Styling

Priority: high

Files:

- `content/clients/_index.md`
- `themes/hugo-serif-theme/layouts/clients/list.html`
- `themes/hugo-serif-theme/assets/scss/components/_feature.scss`

### Phase 3 changes

The clients page structure is now unified again.

The next design task is to make it feel more premium:

- cleaner intro
- tighter descriptions
- more disciplined client grid
- optional logo treatment improvements
- less “feature card” feel, more “proof archive” feel

## Phase 4: Services Page Modernization

Priority: high

Files:

- `content/services/_index.md`
- `content/services/*.md`
- `themes/hugo-serif-theme/layouts/services/list.html`
- `themes/hugo-serif-theme/layouts/services/single.html`
- `themes/hugo-serif-theme/assets/scss/pages/services/page-services-single.scss`

### Phase 4 changes

Service pages should be rewritten and restyled to match the AI-first direction while keeping blockchain as a supporting capability.

Key changes:

- stronger service names
- shorter intros
- clearer outcomes
- improved page hierarchy
- more premium typography and spacing

## Phase 5: Supporting Pages

Priority: medium

Files:

- `content/about.md`
- `content/contact.md`
- `content/team/_index.md`
- `content/team/thomas-modeneis.md`

### Phase 5 changes

These pages should align with the new tone:

- better grammar
- stronger credibility language
- simpler structure
- more modern section hierarchy

## Recommended Work Order

### Step 1

Implement visual system changes:

- palette
- fonts
- header
- menu
- buttons
- footer

### Step 2

Redesign homepage:

- hero
- value pillars
- CTA
- proof rhythm

### Step 3

Restyle clients page

### Step 4

Rewrite and redesign service pages

### Step 5

Clean up supporting pages

## Concrete First Deliverable

The best first coded deliverable is:

**a homepage messaging and proof refresh, followed by the global UI refresh**

That gives the biggest strategic improvement first, then the biggest visible improvement with limited structural risk.

## Success Criteria

After the first implementation phase, the site should feel:

- more premium
- more modern
- more distinct
- less template-like
- more aligned with AI systems and backend credibility

And visually, a visitor should feel:

- this is a serious technical company
- this team builds production systems
- this brand has taste and structure
