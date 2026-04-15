# AGENTS.md

## Project

Privorum is a Hugo-based static marketing website for a blockchain and software consultancy.

- Main concerns are content quality, page structure, theme/template changes, and safe static-site builds.
- The repository does not contain an application backend.
- Architecture docs live in `docs/architecture/` and should stay aligned with the actual Hugo setup.

## Repo Map

- `content/` stores page copy and front matter.
- `content/services/` contains service landing pages.
- `content/team/`, `content/clients/`, and `content/protocols/` contain section content.
- `themes/hugo-serif-theme/` contains layouts, partials, styles, and browser-side scripts.
- `config.toml` defines menus, metadata, branding, and optional analytics settings.
- `docs/architecture/` contains C4 documentation for this repo.
- `Makefile` and `deploy.sh` describe local build and publish flow.

## Working Rules

- Prefer small, targeted edits over broad rewrites.
- Preserve Hugo conventions: front matter at the top, markdown content below, and existing section structure.
- Do not invent product capabilities, clients, protocols, case studies, or team credentials that are not already supported by repository content.
- Keep changes compatible with a static Hugo site. Avoid adding heavy client-side JavaScript unless clearly necessary.
- When editing architecture docs, reflect the current repository, not an idealized future state.
- When changing navigation, metadata, or analytics behavior, update `config.toml` deliberately and check for side effects across the site.
- Keep `docs/log.md` up to date. Always append a short entry with what was done and the current plan when making repository changes.

## Content Standards

- Maintain a professional B2B tone: direct, credible, technically competent, not hype-heavy.
- Improve grammar, clarity, and scannability when touching content. Many existing pages have useful material but uneven English.
- Prefer short paragraphs, clear headings, and tight lists.
- Keep service pages outcome-oriented: what Privorum does, for whom, and with which technologies.
- Avoid buzzword stuffing. "Blockchain", "Web3", and protocol names should appear where useful, not repetitively.
- Do not overstate claims such as team size, years of experience, or number of delivered products unless the source content already supports them.

## UI and Theme Changes

- Respect the existing visual direction unless the task is explicitly a redesign.
- Favor semantic HTML, accessible contrast, and responsive layouts.
- Keep templates and styles simple. This site benefits more from clarity and trust than from elaborate interactions.
- If editing Mermaid docs, verify readability on dark documentation surfaces; default Mermaid styling can be too low-contrast.

## Build and Verification

- Use `make start` for local development when needed.
- `make start-watch` is also available and currently runs the same Hugo server command.
- Use `make build` to verify layout, asset, or configuration changes.
- The `Makefile` resolves Hugo through the `hugo` command on `PATH`.
- For static-site changes, the minimum useful verification is that affected markdown, config, and template files remain valid and consistent.
- If you change layout, assets, or configuration, prefer a Hugo build verification before finishing.

## Good Defaults

- For copy-only changes, edit the smallest relevant file under `content/`.
- For shared UI changes, inspect theme layouts and partials before editing page content.
- For structural documentation, update `docs/architecture/README.md` and the related C4 files together when needed.
- Leave deployment flow alone unless the task is explicitly about publishing or the repository's release process.
