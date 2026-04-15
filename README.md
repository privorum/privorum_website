make # Privorum Website

Static Hugo website for Privorum, a blockchain and software consultancy.

The site is content-driven and theme-based:

- page copy lives in `content/`
- site settings and navigation live in `config.toml`
- layouts, partials, styles, and small JavaScript behaviors live in `themes/hugo-serif-theme/`
- architecture documentation lives in `docs/architecture/`

## Stack

- Hugo
- `hugo-serif-theme`
- Markdown content
- SCSS and small JavaScript assets managed through the theme

## Project Structure

- `content/` page content and front matter
- `content/services/` service landing pages
- `content/team/` team pages
- `content/clients/` client section content
- `content/protocols/` protocol section content
- `themes/hugo-serif-theme/` Hugo theme files
- `static/` copied static assets
- `docs/architecture/` C4 architecture documentation
- `config.toml` site metadata, menus, logo, and analytics settings
- `Makefile` local development helpers
- `deploy.sh` legacy publish script

## Local Development

Prerequisite: install Hugo and make sure the `hugo` command is available on your `PATH`.

Start the local server:

```bash
make start
```

Alternative target:

```bash
make start-watch
```

The current development command in `Makefile` is:

```bash
hugo server --watch=true
```

## Build

Generate the static site:

```bash
make build
```

That command removes `public/` and rebuilds the site with Hugo.

## Configuration Notes

- Base URL is configured in `config.toml`.
- Main and footer navigation are configured in `config.toml`.
- Optional Google Analytics and Google Tag Manager IDs are also configured in `config.toml`.
- Branding assets such as the site logo are referenced from `config.toml`.

## Content Editing

Most day-to-day updates should happen in `content/`.

Use content edits for:

- service descriptions
- homepage and about-page copy
- team bios
- client and protocol section updates
- contact page content

Use theme edits for:

- shared page layouts
- partials and navigation markup
- global styling
- browser-side interactions

## Architecture Docs

Architecture documentation is in [docs/architecture](./docs/architecture/README.md).

It includes:

- system context
- container view
- component view for site generation
- deployment view

## Deployment

The repository includes a `deploy.sh` script that reflects a Git-based publish flow using generated output from `public/`.

Treat it as project-specific deployment history, not as the current source of truth for automated releases. Review it carefully before using it in any live publish workflow.
